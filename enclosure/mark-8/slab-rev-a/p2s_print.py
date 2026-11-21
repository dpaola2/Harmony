"""Make the Bambu Studio project for the Bambu P2S (0.4 nozzle, AMS, textured PEI).

    python3 p2s_print.py

Writes print/mark8-slab-p2s.3mf (the project) and print/mark8-slab-p2s.gcode.3mf
(the same plate, sliced), then prints a summary. All four parts are on one plate:
front shell, back plate and button cap in filament 1 (Jade White), wheel disc in
filament 2 (Black). Per-part settings follow PRINTING.md. The method (Bambu
Studio CLI with the resolved system profiles) is the one in
~/projects/print-shop/cutout/slicer.py. Needs Bambu Studio 2.x and Python 3.9+.
Run it again after build.py changes a part.
"""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

HERE = Path(__file__).resolve().parent
PRINT = HERE / "print"
APP = Path(os.environ.get("BAMBU_STUDIO", "/Applications/BambuStudio.app/Contents/MacOS/BambuStudio"))
PROFILES = APP.parent.parent / "Resources" / "profiles" / "BBL"

MACHINE = "Bambu Lab P2S 0.4 nozzle"
PROCESS = "0.20mm Standard @BBL P2S"
FILAMENT = "Bambu PLA Basic @BBL P2S"
STEM = "mark8-slab-p2s"
FILAMENTS = [("Jade White", "#FFFFFF"), ("Black", "#000000")]  # project filament 1, 2

# Per-part settings from PRINTING.md. They are written on each object, so they
# stay with the part if someone changes the process preset.
SHELL = {"wall_loops": "4", "top_shell_layers": "5", "bottom_shell_layers": "5",
         "sparse_infill_density": "25%", "sparse_infill_pattern": "gyroid",
         "elefant_foot_compensation": "0.15", "brim_type": "no_brim", "enable_support": "0"}
SOLID = {"wall_loops": "3", "top_shell_layers": "5", "bottom_shell_layers": "5",
         "sparse_infill_density": "100%", "sparse_infill_pattern": "zig-zag",
         "elefant_foot_compensation": "0.075", "enable_support": "0"}
# (STL stem in print/, object name, filament, part centre on the plate, settings)
PARTS = [
    ("front-shell", "front shell", 1, (75.0, 120.0), SHELL),
    ("back-plate", "back plate", 1, (145.0, 120.0), SHELL),
    ("wheel-disc", "wheel disc", 2, (210.0, 140.0),
     {**SOLID, "brim_type": "no_brim", "ironing_type": "topmost"}),
    # Arachne walls: the classic generator leaves gaps in the 0.4 flange.
    ("button-cap", "button cap", 1, (210.0, 95.0),
     {**SOLID, "brim_type": "outer_only", "brim_width": "3", "wall_generator": "arachne"}),
]
# Whole plate. One layer height for all parts, because the prime tower needs it.
PLATE = {"curr_bed_type": "Textured PEI Plate", "layer_height": "0.2",
         "initial_layer_print_height": "0.2", "seam_position": "aligned",
         "print_sequence": "by layer", "enable_prime_tower": "1", **SHELL}
# Hook to try other settings without editing this file, for example
# P2S_SET="wheel-disc:layer_height=0.1;plate:enable_prime_tower=0"
SET = [kv.split(":", 1) for kv in filter(None, os.environ.get("P2S_SET", "").split(";"))]


def _load(files, name):
    d = json.loads(files[name].read_text())
    out = {}
    if d.get("inherits"):
        out.update(_load(files, d["inherits"]))
    for inc in d.get("include", []):
        out.update(_load(files, inc))
    out.update(d)
    for k in ("inherits", "include"):
        out.pop(k, None)
    return out


def _run(args, log):
    with open(log, "w") as f:
        return subprocess.run([str(APP), *args], stdout=f, stderr=subprocess.STDOUT, timeout=1800).returncode


def _fmt(x):
    return f"{x:.4f}".rstrip("0").rstrip(".")


def build(work: Path) -> Path:
    files = {p.stem: p for p in PROFILES.rglob("*.json")}
    machine, process, fil = _load(files, MACHINE), _load(files, PROCESS), _load(files, FILAMENT)
    (work / "machine.json").write_text(json.dumps(machine, indent=1))
    (work / "process.json").write_text(json.dumps(process, indent=1))
    fpaths = []
    for i, (_, colour) in enumerate(FILAMENTS):
        p = work / f"filament{i + 1}.json"
        p.write_text(json.dumps(dict(fil, filament_colour=[colour]), indent=1))
        fpaths.append(str(p))

    # 1. Bambu Studio writes a project with the four meshes, the resolved
    #    profiles and its own flush volumes for the two colours.
    stls = [str(PRINT / f"{stem}.stl") for stem, *_ in PARTS]
    rc = _run(["--load-settings", f"{work / 'machine.json'};{work / 'process.json'}",
               "--load-filaments", ";".join(fpaths),
               "--load-filament-ids", ",".join(str(p[2]) for p in PARTS),
               "--arrange", "0", "--orient", "0", "--export-3mf", "template.3mf",
               "--outputdir", str(work), *stls], work / "template.log")
    if rc != 0:
        sys.exit(f"template export failed ({rc}), see {work / 'template.log'}")
    t = work / "t"
    with zipfile.ZipFile(work / "template.3mf") as z:
        z.extractall(t)

    # 2. Object names, filaments, per-object settings, and one plate.
    ms = t / "Metadata" / "model_settings.config"
    root = ET.parse(ms).getroot()
    ids = {}
    for obj in root.findall("object"):
        stem = obj.find("part/metadata[@key='source_file']").get("value").rsplit(".", 1)[0]
        _, name, filament, _, settings = next(p for p in PARTS if p[0] == stem)
        settings = {**settings, **dict(kv.split("=", 1) for who, kv in SET if who == stem)}
        ids[stem] = obj.get("id")
        obj.find("metadata[@key='name']").set("value", name)
        obj.find("metadata[@key='extruder']").set("value", str(filament))
        obj.find("part/metadata[@key='name']").set("value", name)
        idx = list(obj).index(obj.find("metadata[@key='extruder']")) + 1
        for k, v in sorted(settings.items()):
            obj.insert(idx, ET.Element("metadata", {"key": k, "value": v}))
            idx += 1
    for old in root.findall("plate"):
        root.remove(old)
    plate = ET.Element("plate")
    for k, v in (("plater_id", "1"), ("plater_name", "Mark-8 slab rev A"), ("locked", "false"),
                 ("filament_map_mode", "Auto For Flush"), ("gcode_file", ""),
                 ("thumbnail_file", "Metadata/plate_1.png"),
                 ("thumbnail_no_light_file", "Metadata/plate_no_light_1.png"),
                 ("top_file", "Metadata/top_1.png"), ("pick_file", "Metadata/pick_1.png")):
        plate.append(ET.Element("metadata", {"key": k, "value": v}))
    for n, (stem, *_) in enumerate(PARTS):
        mi = ET.SubElement(plate, "model_instance")
        for k, v in (("object_id", ids[stem]), ("instance_id", "0"), ("identify_id", str(100 + n))):
            mi.append(ET.Element("metadata", {"key": k, "value": v}))
    root.insert(list(root).index(root.find("assemble")), plate)
    ET.indent(root, "  ")
    ms.write_bytes(b'<?xml version="1.0" encoding="UTF-8"?>\n' + ET.tostring(root, encoding="utf-8") + b"\n")

    # 3. Place the parts. No rotation: the files are already in print
    #    orientation (front face of the shell down).
    mp = t / "3D" / "3dmodel.model"
    model = mp.read_text()
    comp = {m.group(1): m.group(2) for m in re.finditer(
        r'<object id="(\d+)"[^>]*>\s*<components>\s*<component [^>]*transform="([^"]+)"', model)}
    for stem, _, _, (x, y), _ in PARTS:
        cx, cy = (float(v) for v in comp[ids[stem]].split()[9:11])
        tf = f"1 0 0 0 1 0 0 0 1 {_fmt(x - cx)} {_fmt(y - cy)} 0"
        model, n = re.subn(rf'(<item objectid="{ids[stem]}"[^>]*transform=")[^"]+(")',
                           rf"\g<1>{tf}\g<2>", model)
        assert n == 1, stem
    mp.write_text(model)

    # 4. Whole-plate settings.
    ps = t / "Metadata" / "project_settings.config"
    cfg = json.loads(ps.read_text())
    changed = []
    for k, v in {**PLATE, **dict(kv.split("=", 1) for who, kv in SET if who == "plate")}.items():
        if k not in cfg:
            sys.exit(f"unknown setting {k}")
        if isinstance(cfg[k], list):
            v = [v] * len(cfg[k])
        if cfg[k] != v:
            changed.append(k)
        cfg[k] = v
    for k in ("filament_map", "filament_volume_map", "default_filament_colour"):
        if isinstance(cfg.get(k), list) and len(cfg[k]) == 1:
            cfg[k] = cfg[k] * len(FILAMENTS)
    cfg["filament_colour"] = [c for _, c in FILAMENTS]
    cfg["different_settings_to_system"] = [
        ";".join(sorted(k for k in changed if k != "curr_bed_type")), "", "", ""]
    ps.write_text(json.dumps(cfg, indent=4) + "\n")

    for p in t.glob("Metadata/*.png"):
        p.unlink()
    out = work / "input.3mf"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for p in sorted(t.rglob("*")):
            if p.is_file():
                z.write(p, p.relative_to(t).as_posix())
    return out


def summary(sliced: Path, result: dict) -> dict:
    with zipfile.ZipFile(sliced) as z:
        gcode = z.read("Metadata/plate_1.gcode").decode()
    plate = result["sliced_plates"][0]
    swap_layers, z_now = [], None
    for line in gcode.splitlines():
        if line.startswith("; Z_HEIGHT:"):
            z_now = float(line.split(":")[1])
        elif re.fullmatch(r"T[0-9]", line) and z_now is not None:
            swap_layers.append(z_now)
    fil = {f["id"]: f for f in plate["filaments"]}
    return {
        "total_time_min": round(plate["total_predication"] / 60, 1),
        "filament_g": {FILAMENTS[i - 1][0]: round(f["total_used_g"], 2) for i, f in fil.items()},
        "in_parts_g": {FILAMENTS[i - 1][0]: round(f["main_used_g"], 2) for i, f in fil.items()},
        "waste_g": round(sum(f["total_used_g"] - f["main_used_g"] for f in fil.values()), 2),
        "filament_changes": plate["filament_change_times"],
        "layers_with_a_change_z": sorted(set(swap_layers)),
        "slicer_warning": plate.get("warning_message") or result.get("error_string"),
    }


def main():
    if not APP.exists():
        sys.exit(f"Bambu Studio not found at {APP}")
    work = Path(tempfile.mkdtemp(prefix="p2s-"))
    try:
        inp = build(work)
        (work / "out").mkdir()
        (work / "sliced").mkdir()
        # 5. Bambu Studio reads the project and writes it back (with plate
        #    thumbnails), then slices it. All settings come from the 3MF.
        if _run(["--export-3mf", f"{STEM}.3mf", "--outputdir", str(work / "out"), str(inp)],
                work / "project.log") != 0:
            sys.exit((work / "project.log").read_text()[-2000:])
        proj = work / "out" / f"{STEM}.3mf"
        rc = _run(["--slice", "0", "--export-3mf", f"{STEM}.gcode.3mf", "--outputdir",
                   str(work / "sliced"), str(proj)], work / "slice.log")
        sliced = work / "sliced" / f"{STEM}.gcode.3mf"
        rj = work / "sliced" / "result.json"
        result = json.loads(rj.read_text()) if rj.exists() else {}
        if rc != 0 or not sliced.exists():
            print(json.dumps(result, indent=1))
            sys.exit((work / "slice.log").read_text()[-2000:])
        shutil.copy2(proj, PRINT / f"{STEM}.3mf")
        shutil.copy2(sliced, PRINT / f"{STEM}.gcode.3mf")
        print(json.dumps(summary(sliced, result), indent=1))
    finally:
        if os.environ.get("P2S_KEEP_WORK"):
            print("work dir:", work, file=sys.stderr)
        else:
            shutil.rmtree(work, ignore_errors=True)


if __name__ == "__main__":
    main()
