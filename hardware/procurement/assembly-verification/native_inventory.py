#!/usr/bin/env python3
"""Independent reference extraction through KiCad's native pcbnew API.

Run with the Python interpreter bundled with KiCad 8.0.9.
Does not modify or save a board.
"""
import hashlib
import json
from pathlib import Path

import pcbnew
import wx

app = wx.App(False)
HERE = Path(__file__).resolve().parent
HARDWARE = HERE.parents[1]
boards = []
for name in ("tangara-mainboard", "tangara-faceplate"):
    path = HARDWARE / "tangara-reference" / name / (name + ".kicad_pcb")
    before = hashlib.sha256(path.read_bytes()).hexdigest()
    board = pcbnew.LoadBoard(str(path))
    origin = board.GetDesignSettings().GetAuxOrigin()
    box = board.GetBoardEdgesBoundingBox()
    footprints = []
    for fp in board.GetFootprints():
        pos = fp.GetPosition()
        fields = {f.GetName(): f.GetText() for f in fp.GetFields()}
        footprints.append({
            "uuid": str(fp.m_Uuid.AsString()),
            "reference": fp.GetReference(),
            "value": fp.GetValue(),
            "mpn": fields.get("MPN", "").strip(),
            "footprint": str(fp.GetFPID().GetLibItemName()),
            "x_board_mm": pcbnew.ToMM(pos.x),
            "y_board_mm": pcbnew.ToMM(pos.y),
            "x_aux_mm": pcbnew.ToMM(pos.x - origin.x),
            "y_aux_up_mm": pcbnew.ToMM(origin.y - pos.y),
            "rotation_deg": fp.GetOrientationDegrees(),
            "side": fp.GetLayerName(),
            "dnp": fp.IsDNP(),
            "exclude_bom": fp.IsExcludedFromBOM(),
            "exclude_position": fp.IsExcludedFromPosFiles(),
            "attributes": fp.GetAttributes(),
            "pads": [{"number": p.GetNumber(), "net": p.GetNetname()} for p in fp.Pads()],
        })
    assert before == hashlib.sha256(path.read_bytes()).hexdigest()
    boards.append({
        "board": name,
        "source_sha256": before,
        "copper_layers": board.GetCopperLayerCount(),
        "thickness_mm": pcbnew.ToMM(board.GetDesignSettings().GetBoardThickness()),
        "aux_origin_mm": [pcbnew.ToMM(origin.x), pcbnew.ToMM(origin.y)],
        "edge_bbox_mm": [pcbnew.ToMM(box.GetX()), pcbnew.ToMM(box.GetY()),
                         pcbnew.ToMM(box.GetWidth()), pcbnew.ToMM(box.GetHeight())],
        "footprints": sorted(footprints, key=lambda x: (x["reference"], x["uuid"])),
    })
(HERE / "native-inventory.json").write_text(json.dumps({
    "tool": "pcbnew " + pcbnew.GetBuildVersion(),
    "coordinate_convention": "Native board coordinates; aux X right, aux Y up; native footprint rotation",
    "boards": boards,
}, indent=2) + "\n")
print(json.dumps({b["board"]: len(b["footprints"]) for b in boards}))
