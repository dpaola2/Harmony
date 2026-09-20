#!/usr/bin/env python3
"""Fail if the generated quote package loses quantity or reference coverage."""

import csv
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
EXPECTED = {
    "mainboard": {"bom_qty": 92, "bom_groups": 35, "supplier_pos": 92, "raw_pos": 97},
    "faceplate": {"bom_qty": 19, "bom_groups": 10, "supplier_pos": 19, "raw_pos": 22},
}


def rows(name):
    with (HERE / name).open(newline="") as handle:
        return list(csv.DictReader(handle))


def file_hash(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


for board, expected in EXPECTED.items():
    bom = rows(f"{board}-bom.csv")
    supplier = rows(f"{board}-placement-supplier.csv")
    raw = rows(f"{board}-placement-kicad-raw.csv")
    assert len(bom) == expected["bom_groups"], (board, "bom groups", len(bom))
    assert sum(int(row["qty_per_board"]) for row in bom) == expected["bom_qty"]
    assert len(supplier) == expected["supplier_pos"]
    assert len(raw) == expected["raw_pos"]
    for row in bom:
        per = int(row["qty_per_board"])
        assert int(row["qty_for_1_board"]) == per
        assert int(row["qty_for_2_boards"]) == per * 2
        assert int(row["qty_for_5_boards"]) == per * 5
    bom_refs = {ref for row in bom for ref in row["references"].split()}
    pos_refs = {row["Ref"] for row in supplier}
    assert bom_refs == pos_refs, (board, "BOM/position reference mismatch", sorted(bom_refs ^ pos_refs))

structures = rows("dnp-and-non-purchased-structures.csv")
assert len(structures) == 59
assert len(rows("external-parts-addendum.csv")) == 3
assert sum(item["classification"] == "DNP" for item in structures) == 3
assert sum(item["board"] == "faceplate" and item["reference"] in {"J1", "J2"} for item in structures) == 2

programming = json.loads((HERE / "programming/programming-manifest.json").read_text())
assert len(programming["images"]) == 11
assert sum(image["processor"] == "ESP32" for image in programming["images"]) == 7
assert sum(image["processor"] == "SAMD21" for image in programming["images"]) == 4
for image in programming["images"]:
    path = HERE / "programming" / image["file"]
    assert path.stat().st_size == image["bytes"] and file_hash(path) == image["sha256"]

manifest = json.loads((HERE / "manifest.json").read_text())
assert manifest["source_commit"] == "9853b4a1dc8a0e3ea3ec75450522e42df12eaa52"
for item in manifest["source_files"]:
    path = HERE.parents[2] / item["path"]
    assert path.stat().st_size == item["bytes"] and file_hash(path) == item["sha256"]
for item in manifest["outputs"]:
    path = HERE / item["path"]
    # manifest.json intentionally excludes itself; validate every recorded output.
    assert path.stat().st_size == item["bytes"] and file_hash(path) == item["sha256"], item["path"]

print("PASS: 170 routed footprints = 111 purchased/fitted + 59 DNP/non-purchased; BOM, placement, quote multipliers, and manifest hashes reconcile.")
