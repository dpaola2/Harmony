#!/usr/bin/env python3
"""Build a deterministic, quote-only Tangara PCBA review package.

The routed PCB is the quantity authority. This script never edits the pinned
sources and never marks any output as released for fabrication.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import shutil
import subprocess
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SOURCE_COMMIT = "9853b4a1dc8a0e3ea3ec75450522e42df12eaa52"
BOARDS = {
    "mainboard": REPO / "hardware/revisions/harmony-r3/tangara-mainboard/tangara-mainboard.kicad_pcb",
    "faceplate": REPO / "hardware/revisions/harmony-r3/tangara-faceplate/tangara-faceplate.kicad_pcb",
}
QUOTE_QUANTITIES = (1, 2, 5)


def blocks(text: str):
    """Yield balanced top-level footprint forms, respecting quoted strings."""
    start = 0
    while True:
        start = text.find("\n\t(footprint ", start)
        if start < 0:
            return
        start += 2
        depth = 0
        quoted = escaped = False
        for end in range(start, len(text)):
            char = text[end]
            if quoted:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    quoted = False
            elif char == '"':
                quoted = True
            elif char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0:
                    yield text[start : end + 1]
                    start = end + 1
                    break


def prop(block: str, name: str) -> str:
    match = re.search(rf'\(property "{re.escape(name)}" "((?:\\.|[^"\\])*)"', block)
    return match.group(1).replace(r'\"', '"').replace(r"\\", "\\").strip() if match else ""


def natural(value: str):
    return [int(part) if part.isdigit() else part for part in re.split(r"(\d+)", value)]


def footprint_rows(board: str, path: Path) -> list[dict]:
    rows = []
    for index, block in enumerate(blocks(path.read_text()), 1):
        library = re.match(r'\(footprint "([^"]+)"', block).group(1)
        layer = re.search(r'\n\s*\(layer "([FB])\.Cu"\)', block)
        at = re.search(r'\n\s*\(at ([^ )]+) ([^ )]+)(?: ([^ )]+))?\)', block)
        attr = re.search(r"\n\s*\(attr ([^)]+)\)", block)
        attrs = set(attr.group(1).split()) if attr else set()
        ref = prop(block, "Reference")
        value = prop(block, "Value")
        mpn = prop(block, "MPN")
        excluded = "exclude_from_bom" in attrs
        dnp = "dnp" in attrs
        rows.append({
            "board": board,
            "source_index": index,
            "reference": ref,
            "value": value,
            "mpn": mpn,
            "footprint": library,
            "side": "Top" if layer and layer.group(1) == "F" else "Bottom" if layer else "Unknown",
            "x_mm": at.group(1) if at else "",
            "y_mm": at.group(2) if at else "",
            "rotation_deg": at.group(3) if at and at.group(3) else "0",
            "dnp": dnp,
            "excluded_from_bom": excluded,
            "excluded_from_position": "exclude_from_pos_files" in attrs,
            "board_only": "board_only" in attrs,
            "population": "excluded" if excluded else "dnp" if dnp else "fitted",
        })
    return rows


def purchasing_state(row: dict) -> str:
    if row["population"] == "dnp":
        return "DNP"
    if row["excluded_from_bom"]:
        return "PCB_FEATURE"
    if row["board"] == "faceplate" and (
        row["reference"].startswith(("H", "TP"))
        or row["reference"] in {"J1", "J2", "SW1", "SW2", "SW3"}
    ):
        return "PCB_FEATURE"
    return "PURCHASE"


def normalized_mpn(row: dict) -> tuple[str, str]:
    if row["board"] == "faceplate" and row["reference"] == "LCD1":
        return "ER-TFT018-4", "CANDIDATE_HOLD_MECHANICAL"
    return row["mpn"], "SOURCE_MPN" if row["mpn"] else "MISSING_MPN_HOLD"


def write_csv(path: Path, headings: list[str], rows: list[dict]):
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, headings, extrasaction="ignore", lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def build_bom(board: str, rows: list[dict]) -> list[dict]:
    groups = defaultdict(list)
    for row in rows:
        if row["board"] != board or purchasing_state(row) != "PURCHASE":
            continue
        mpn, status = normalized_mpn(row)
        groups[(mpn, row["value"], row["footprint"], status)].append(row["reference"])
    result = []
    for (mpn, value, footprint, status), refs in groups.items():
        per_board = len(refs)
        result.append({
            "board": board,
            "mpn": mpn,
            "value": value,
            "footprint": footprint,
            "references": " ".join(sorted(refs, key=natural)),
            "qty_per_board": per_board,
            "qty_for_1_board": per_board,
            "qty_for_2_boards": per_board * 2,
            "qty_for_5_boards": per_board * 5,
            "identity_status": status,
        })
    return sorted(result, key=lambda x: (natural(x["references"].split()[0]), x["mpn"]))


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def filter_native_position(board: str, raw_path: Path, rows: list[dict]):
    purchased_refs = {
        row["reference"]
        for row in rows
        if row["board"] == board and purchasing_state(row) == "PURCHASE"
    }
    with raw_path.open(newline="") as handle:
        raw_rows = list(csv.DictReader(handle))
        headings = handle.seek(0) or next(csv.reader(handle))
    filtered = [row for row in raw_rows if row["Ref"] in purchased_refs]
    found = {row["Ref"] for row in filtered}
    if found != purchased_refs:
        raise SystemExit(f"Native position coverage mismatch for {board}: missing={sorted(purchased_refs - found)} extra={sorted(found - purchased_refs)}")
    write_csv(HERE / f"{board}-placement-supplier.csv", headings, filtered)


def run_native(kicad_cli: Path, rows: list[dict]):
    fab = HERE / "fabrication"
    if fab.exists():
        shutil.rmtree(fab)
    fab.mkdir()
    logs = HERE / "logs"
    logs.mkdir(exist_ok=True)
    for board, source in BOARDS.items():
        board_dir = fab / board
        board_dir.mkdir()
        copper = "F.Cu,In1.Cu,In2.Cu,B.Cu" if board == "mainboard" else "F.Cu,B.Cu"
        fabrication_layers = copper + ",F.Paste,B.Paste,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,Edge.Cuts"
        raw_position = HERE / f"{board}-placement-kicad-raw.csv"
        commands = [
            [str(kicad_cli), "pcb", "export", "gerbers", "--layers", fabrication_layers, "--output", str(board_dir) + "/", str(source)],
            [str(kicad_cli), "pcb", "export", "drill", "--output", str(board_dir) + "/", str(source)],
            [str(kicad_cli), "pcb", "export", "pos", "--format", "csv", "--units", "mm", "--side", "both", "--output", str(raw_position), str(source)],
        ]
        log = []
        for command in commands:
            proc = subprocess.run(command, text=True, capture_output=True)
            log.append({"command": command, "returncode": proc.returncode, "stdout": proc.stdout, "stderr": proc.stderr})
            if proc.returncode:
                raise SystemExit(f"KiCad export failed for {board}: {' '.join(command)}")
        (logs / f"{board}-export.json").write_text(json.dumps(log, indent=2) + "\n")
        filter_native_position(board, raw_position, rows)


def stage_programming_files():
    destination = HERE / "programming"
    if destination.exists():
        shutil.rmtree(destination)
    destination.mkdir()
    esp_source = REPO / "firmware/esp32-validation/artifacts"
    samd_source = REPO / "firmware/samd-validation/artifacts"
    layout = json.loads((esp_source / "flash-layout.json").read_text())
    staged = []
    for image in layout["images"]:
        source = esp_source / image["file"]
        target = destination / f"esp32-{image['file']}"
        shutil.copyfile(source, target)
        assert source.stat().st_size == image["bytes"] and sha256(source) == image["sha256"]
        staged.append({"processor": "ESP32", "file": target.name, "address": image["offset"], "bytes": target.stat().st_size, "sha256": sha256(target), "purpose": "factory flash image"})
    samd_files = [
        ("bootloader-tangara-bc1632d.bin", "0x00000000", "factory bootloader via SWD"),
        ("bootloader-tangara-bc1632d.elf", "0x00000000", "factory bootloader debug/programming image via SWD"),
        ("tangara-samd-v6.0.bin", "0x00002000", "application binary after bootloader"),
        ("tangara-samd-v6.0.uf2", "0x00002000", "application update for working UF2 bootloader"),
    ]
    for filename, address, purpose in samd_files:
        source = samd_source / filename
        target = destination / f"samd-{filename}"
        shutil.copyfile(source, target)
        staged.append({"processor": "SAMD21", "file": target.name, "address": address, "bytes": target.stat().st_size, "sha256": sha256(target), "purpose": purpose})
    (destination / "programming-manifest.json").write_text(json.dumps({"status": "QUOTE_REVIEW_ONLY_HARDWARE_UNQUALIFIED", "images": staged}, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--kicad-cli", type=Path, help="KiCad 8 CLI path for native Gerber, drill, and position exports")
    args = parser.parse_args()
    HERE.mkdir(parents=True, exist_ok=True)
    for obsolete in (HERE / "mainboard-placement-kicad.csv", HERE / "faceplate-placement-kicad.csv"):
        obsolete.unlink(missing_ok=True)
    all_rows = [row for board, path in BOARDS.items() for row in footprint_rows(board, path)]
    stage_programming_files()

    bom_headings = ["board", "mpn", "value", "footprint", "references", "qty_per_board", "qty_for_1_board", "qty_for_2_boards", "qty_for_5_boards", "identity_status"]
    for board in BOARDS:
        write_csv(HERE / f"{board}-bom.csv", bom_headings, build_bom(board, all_rows))

    placement_headings = ["board", "reference", "value", "mpn", "footprint", "x_mm", "y_mm", "side", "rotation_deg", "coordinate_basis", "rotation_status"]
    for board in BOARDS:
        placement = []
        for row in all_rows:
            if row["board"] != board or purchasing_state(row) != "PURCHASE" or row["excluded_from_position"]:
                continue
            out = dict(row)
            out["mpn"] = normalized_mpn(row)[0]
            out["coordinate_basis"] = "KiCad PCB absolute source coordinates; auxiliary-origin offset not applied"
            out["rotation_status"] = "SOURCE_ORIENTATION_REVIEW_ONLY"
            placement.append(out)
        placement.sort(key=lambda x: natural(x["reference"]))
        write_csv(HERE / f"{board}-placement-review.csv", placement_headings, placement)

    structures = []
    for row in all_rows:
        state = purchasing_state(row)
        if state == "PURCHASE":
            continue
        note = "Do not purchase or place"
        if state == "DNP":
            note = "DNP; leave pads unpopulated"
        elif row["reference"] in {"J1", "J2"} and row["board"] == "faceplate":
            note = "Haptic motor solder pads; motor appears once in external addendum"
        structures.append({**row, "classification": state, "supplier_instruction": note})
    structures.sort(key=lambda x: (x["board"], natural(x["reference"]), x["source_index"]))
    write_csv(HERE / "dnp-and-non-purchased-structures.csv", ["board", "reference", "value", "footprint", "classification", "dnp", "excluded_from_bom", "excluded_from_position", "board_only", "supplier_instruction"], structures)

    external = [
        {"item": "Board interconnect FFC", "mpn": "FJH-15-R-03.00-4", "qty_per_set": 1, "qty_for_1_set": 1, "qty_for_2_sets": 2, "qty_for_5_sets": 5, "assembly_scope": "Final assembly or return as kit; confirm tin contacts"},
        {"item": "Haptic motor", "mpn": "VC1034B018F", "qty_per_set": 1, "qty_for_1_set": 1, "qty_for_2_sets": 2, "qty_for_5_sets": 5, "assembly_scope": "Attach to faceplate J1/J2 pads; do not count pads as components"},
        {"item": "Protected battery pack", "mpn": "LP574459 candidate", "qty_per_set": 1, "qty_for_1_set": 1, "qty_for_2_sets": 2, "qty_for_5_sets": 5, "assembly_scope": "HOLD: finished dimensions, NTC curve, pin order, protection and 1 A charge rating unresolved"},
    ]
    write_csv(HERE / "external-parts-addendum.csv", list(external[0]), external)

    if args.kicad_cli:
        if not args.kicad_cli.is_file():
            raise SystemExit(f"KiCad CLI not found: {args.kicad_cli}")
        run_native(args.kicad_cli.resolve(), all_rows)

    pins = {
        "hardware": {"url": "https://codeberg.org/cool-tech-zone/tangara-hw", "upstream_commit": SOURCE_COMMIT, "derived_revision": "harmony-r3", "pcb_format": "KiCad 8.0"},
        "kicad": {"version": subprocess.check_output([str(args.kicad_cli), "--version"], text=True).strip() if args.kicad_cli else None, "path_used": str(args.kicad_cli.resolve()) if args.kicad_cli else None},
        "firmware": {
            "esp32_application": "c092c5aae83aac241b3756b15d8b9dad9ed2c3fd",
            "esp_idf": "8c750b088c7cd857d079c0eeb495da199b359461",
            "samd_application": "8066c54bff5d26398fa08955d2bc24e7f05702a2",
            "samd_bootloader": "bc1632d9736493467000ba119fd0b16fd46ccbe6",
            "release_state": "build-validated; hardware-unqualified; programming draft only",
        },
    }
    (HERE / "source-and-tool-pins.json").write_text(json.dumps(pins, indent=2) + "\n")

    outputs = sorted(path for path in HERE.rglob("*") if path.is_file() and path.name != "manifest.json")
    manifest = {
        "status": "QUOTE_REVIEW_ONLY_NOT_FABRICATION_RELEASED",
        "upstream_source_commit": SOURCE_COMMIT,
        "derived_revision": "harmony-r3",
        "quote_quantities_complete_sets": list(QUOTE_QUANTITIES),
        "generator": "generate_quote_package.py",
        "native_kicad_cli": str(args.kicad_cli.resolve()) if args.kicad_cli else None,
        "source_files": [{"path": str(path.relative_to(REPO)), "bytes": path.stat().st_size, "sha256": sha256(path)} for path in sorted((REPO / "hardware/revisions/harmony-r3").rglob("*")) if path.is_file() and "verification" not in path.parts],
        "outputs": [{"path": str(path.relative_to(HERE)), "bytes": path.stat().st_size, "sha256": sha256(path)} for path in outputs],
    }
    (HERE / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    main()
