#!/usr/bin/env python3
"""Extract one row per routed-board footprint from pinned KiCad PCB files."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BOARDS = {
    "tangara-mainboard": ROOT / "tangara-reference/tangara-mainboard/tangara-mainboard.kicad_pcb",
    "tangara-faceplate": ROOT / "tangara-reference/tangara-faceplate/tangara-faceplate.kicad_pcb",
}


def footprint_blocks(text: str):
    start = 0
    while True:
        start = text.find("\n\t(footprint ", start)
        if start < 0:
            return
        start += 2
        depth = 0
        quoted = False
        escaped = False
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


def field(block: str, name: str):
    match = re.search(rf'\(property "{re.escape(name)}" "((?:\\.|[^"\\])*)"', block)
    return match.group(1).replace(r'\"', '"').replace(r"\\", "\\") if match else None


items = []
for board, path in BOARDS.items():
    for block in footprint_blocks(path.read_text()):
        library_match = re.match(r'\(footprint "([^"]+)"', block)
        attr_match = re.search(r"\n\s*\(attr ([^)]+)\)", block)
        attrs = attr_match.group(1).split() if attr_match else []
        ref = field(block, "Reference")
        items.append(
            {
                "board": board,
                "reference": ref,
                "value": field(block, "Value"),
                "mpn": field(block, "MPN"),
                "footprint": library_match.group(1) if library_match else None,
                "dnp": "dnp" in attrs,
                "exclude_from_bom": "exclude_from_bom" in attrs,
                "exclude_from_position_files": "exclude_from_pos_files" in attrs,
                "board_only": "board_only" in attrs,
                "population": "excluded" if "exclude_from_bom" in attrs else ("dnp" if "dnp" in attrs else "fitted"),
            }
        )

items.sort(key=lambda item: (item["board"], item["reference"] or ""))
duplicates = []
for board in BOARDS:
    refs = [
        item["reference"]
        for item in items
        if item["board"] == board
        and item["reference"]
        and "*" not in item["reference"]
    ]
    duplicates.extend(f"{board}:{ref}" for ref in sorted(set(refs)) if refs.count(ref) > 1)

summary = {}
for board in BOARDS:
    board_items = [item for item in items if item["board"] == board]
    fitted = [item for item in board_items if item["population"] == "fitted"]
    summary[board] = {
        "footprints_total": len(board_items),
        "fitted": len(fitted),
        "dnp_flag": sum(item["dnp"] for item in board_items),
        "excluded_from_bom": sum(item["exclude_from_bom"] for item in board_items),
        "fitted_missing_mpn": sum(not item["mpn"] for item in fitted),
    }

audit = json.loads((ROOT / "procurement/schematic-parts-audit.json").read_text())["parts"]
for item in items:
    candidates = [
        row.get("mpn") or None
        for row in audit
        if row["board"] == item["board"] and row["ref"] == item["reference"]
    ]
    item["schematic_audit_mpn_candidates"] = sorted(
        {candidate for candidate in candidates if candidate}
    )
    if not candidates:
        item["mpn_reconciliation"] = "no_matching_schematic_audit_row"
    elif not item["mpn"] and not item["schematic_audit_mpn_candidates"]:
        item["mpn_reconciliation"] = "missing_in_both"
    elif item["mpn"] in item["schematic_audit_mpn_candidates"]:
        item["mpn_reconciliation"] = "pcb_matches_one_audit_candidate"
    else:
        item["mpn_reconciliation"] = "pcb_differs_from_audit_candidates"

result = {
    "source_commit": "9853b4a1dc8a0e3ea3ec75450522e42df12eaa52",
    "derivation": "One record per footprint in each routed .kicad_pcb; population follows PCB attr flags.",
    "summary": summary,
    "duplicate_references_within_board": duplicates,
    "mpn_reconciliation_counts": {
        state: sum(item["mpn_reconciliation"] == state for item in items)
        for state in sorted({item["mpn_reconciliation"] for item in items})
    },
    "items": items,
}
(Path(__file__).with_name("pcb-physical-inventory.json")).write_text(json.dumps(result, indent=2) + "\n")
