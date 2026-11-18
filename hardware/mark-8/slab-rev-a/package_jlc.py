"""Write the JLCPCB fabrication and assembly package into jlcpcb/. Never uploads or orders.

Run with KiCad's bundled Python after verify.py passes:
  gerbers/ + drill  -> jlcpcb/harmony-mark8-slab-gerbers.zip (Protel names, no X2, mask subtracted)
  BOM               -> jlcpcb/bom.csv  (Comment, Designator, Footprint, LCSC Part #)
  CPL               -> jlcpcb/cpl.csv  (Designator, Mid X, Mid Y, Layer, Rotation)
  rotation audit    -> jlcpcb/rotation-check.csv
CPL coordinates are KiCad board coordinates with Y negated, the same frame KiCad writes into the
Gerbers, so the placements line up with the copper. Every assembled part uses either an EasyEDA
footprint (same origin and 0-degree orientation as JLC's library, so JLC rotation = KiCad angle) or a
KiCad 0402/0603/0805/1206 R or C (pad 1 on -X, same as JLC; non-polar).
"""
import csv
import hashlib
import json
import subprocess
import zipfile
import pcbnew as p
import wx
from design import *

app = wx.App(False)
OUT = HERE / 'jlcpcb'
GER = OUT / 'gerbers'
GER.mkdir(parents=True, exist_ok=True)
for f in GER.iterdir():
    f.unlink()
PCB = HERE / (NAME + '.kicad_pcb')
CLI = str(KICAD / 'MacOS/kicad-cli')
ver = json.loads((HERE / 'verification.json').read_text())
assert ver['status'] == 'PASS', 'verify.py must pass first'
assert ver['sha256'][PCB.name] == hashlib.sha256(PCB.read_bytes()).hexdigest(), 'board changed after verification'

layers = 'F.Cu,In1.Cu,In2.Cu,B.Cu,F.Paste,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,Edge.Cuts'
subprocess.run([CLI, 'pcb', 'export', 'gerbers', '--layers', layers, '--subtract-soldermask', '--no-x2',
                '--no-netlist', '--output', str(GER) + '/', str(PCB)], check=True)
subprocess.run([CLI, 'pcb', 'export', 'drill', '--format', 'excellon', '--drill-origin', 'absolute',
                '--excellon-units', 'mm', '--excellon-zeros-format', 'decimal', '--excellon-oval-format', 'alternate', '--excellon-separate-th',
                '--generate-map', '--map-format', 'gerberx2', '--output', str(GER) + '/', str(PCB)], check=True)
files = sorted(GER.iterdir())
zpath = OUT / (NAME + '-gerbers.zip')
with zipfile.ZipFile(zpath, 'w', zipfile.ZIP_DEFLATED) as z:
    for f in files:
        z.write(f, f.name)

b = p.LoadBoard(str(PCB))
by = {prt['ref']: prt for prt in PARTS}
EASYEDA = {'ESP32-PICO-MINI-02', 'USB-C_HRO_TYPE-C-31-M-12', 'JST_PH_S2B-PH-SM4-TB', 'FH35C-15S-0.3SHW',
           'DM3AT-SF-PEJM5', 'SW_SKRTLAE010', 'SW_TS-1088', 'Buzzer_MLT-5020', 'QFN-20_3x3_P0.4',
           'QFN-24_4x4_P0.5_EP2.5', 'TDFN-8_2x2_P0.5_EP', 'VSSOP-10_DRV2605L', 'SOT-23_AO3400A', 'SOT-23_AO3401A',
           'SOT-23-5_MCP73831', 'SOT-23-6', 'TSOT-23-5_RT9080', 'SOT-363', 'SOD-123_B5819W', 'LED_0603_EasyEDA'}
# Parts whose JLC placement origin may differ from the footprint origin or whose orientation is
# easy to get wrong: Dave checks these in JLC's placement preview before paying.
CHECK = {'U1': 'module: footprint origin is the pad-field centre, 2.7 mm from the module centre toward the pins',
         'J1': 'USB-C: origin at the pad row; body extends 4.9 toward the board edge. Opening must face the edge',
         'J2': 'FPC: slot must face the ramp (device +X = KiCad -X); pin 1 at the KiCad lower (+Y) end',
         'J3': 'microSD: card slot must face the bottom board edge',
         'J4': 'JST PH: cable entry must face the top board edge; origin is not the body centre',
         'SW1': 'side switch: actuator must overhang the right (device +X) board edge',
         'U2': 'QFN-24: pin 1 dot', 'U6': 'QFN-20: pin 1 dot', 'U5': 'TDFN-8: pin 1 dot',
         'Q1': 'SOT-363: pin 1 dot', 'U7': 'VSSOP-10: pin 1 dot', 'LED1': 'LED: cathode (pin 2) toward CHG_STAT',
         'D1': 'diode: cathode band to VSYS', 'D2': 'diode: cathode band to BZ_P', 'BZ1': '+ pad to BZ_P'}
rows, bom = [], {}
for fp in sorted(b.GetFootprints(), key=lambda f: f.GetReference()):
    ref = fp.GetReference()
    prt = by.get(ref)
    if not prt or not prt['bom']:
        continue
    fpname = str(fp.GetFPID().GetLibItemName())
    pos = fp.GetPosition()
    x, y = p.ToMM(pos.x), -p.ToMM(pos.y)
    rot = fp.GetOrientationDegrees() % 360
    rows.append([ref, '%.4fmm' % x, '%.4fmm' % y, 'Top', '%g' % rot])
    key = (fpname, prt['lcsc'])           # one BOM line per LCSC part; SW2 BOOT and SW3 RESET share one
    bom.setdefault(key, []).append((ref, prt['value']))
with (OUT / 'cpl.csv').open('w', newline='') as f:
    w = csv.writer(f); w.writerow(['Designator', 'Mid X', 'Mid Y', 'Layer', 'Rotation']); w.writerows(rows)
with (OUT / 'bom.csv').open('w', newline='') as f:
    w = csv.writer(f); w.writerow(['Comment', 'Designator', 'Footprint', 'LCSC Part #'])
    for (fpname, lcsc), items in sorted(bom.items(), key=lambda kv: kv[1][0][0]):
        refs = sorted((r for r, _ in items), key=lambda r: (r.rstrip('0123456789'), int(''.join(c for c in r if c.isdigit()) or 0)))
        values = list(dict.fromkeys(v for _, v in sorted(items, key=lambda it: refs.index(it[0]))))
        w.writerow(['/'.join(values), ','.join(refs), fpname, lcsc])
stock = json.loads((OUT / 'stock.json').read_text()) if (OUT / 'stock.json').exists() else {'parts': {}}
with (OUT / 'rotation-check.csv').open('w', newline='') as f:
    w = csv.writer(f)
    w.writerow(['Designator', 'Footprint', 'Source', 'KiCad angle', 'CPL rotation', 'Offset applied', 'Check in JLC preview'])
    for r in rows:
        fpname = str(b.FindFootprintByReference(r[0]).GetFPID().GetLibItemName())
        src = 'EasyEDA/JLC footprint' if fpname in EASYEDA else 'KiCad library R/C (pad 1 on -X like JLC)'
        w.writerow([r[0], fpname, src, r[4], r[4], 0, CHECK.get(r[0], '')])
basic = sum(1 for k in bom if stock['parts'].get(k[1], {}).get('library_type') == 'base')
summary = dict(bom_lines=len(bom), placements=len(rows), basic_lines=basic, extended_lines=len(bom) - basic,
               gerber_files=[f.name for f in files], zip=zpath.name,
               zip_sha256=hashlib.sha256(zpath.read_bytes()).hexdigest(), board_sha256=ver['sha256'][PCB.name])
(OUT / 'package.json').write_text(json.dumps(summary, indent=1) + '\n')
print(json.dumps(summary, indent=1))
