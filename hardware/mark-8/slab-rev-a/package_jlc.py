"""Write the JLCPCB fabrication and assembly package into jlcpcb/. Never uploads or orders.

Run with KiCad's bundled Python after verify.py passes:
  panel             -> the verified board inside its own 1 x 1 assembly frame (design.PANEL, review CC-1):
                       5 mm rails, 2 mm routed gap, three mouse-bite tabs (left edge, right end of the top
                       edge, right edge below the antenna), three fiducials and four 2.0 mm tooling holes.
                       Only the Gerbers and drill files come from the panel; the board, its STEP and
                       mechanical-interface.json stay the bare board, so the outline that goes into the case
                       does not change.
  gerbers/ + drill  -> jlcpcb/harmony-mark8-slab-gerbers.zip (Protel names, no X2, mask subtracted, no drill maps)
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

# --- assembly panel (design.PANEL) -------------------------------------------------------------------------
PANEL_PCB = OUT / (NAME + '-panel.kicad_pcb')


def kpt(q):
    kx, ky = to_kicad(*q)
    return p.FromMM(kx), p.FromMM(ky)


def sps_of(pts):
    s_ = p.SHAPE_POLY_SET(); s_.NewOutline()
    for q in pts:
        s_.Append(*kpt(q))
    return s_


def rect(x0, x1, y0, y1):
    return [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]


def edge_seg(b_, a, z):
    e = p.PCB_SHAPE(b_); e.SetShape(p.SHAPE_T_SEGMENT)
    e.SetStart(p.VECTOR2I(*a)); e.SetEnd(p.VECTOR2I(*z)); e.SetLayer(p.Edge_Cuts); e.SetWidth(p.FromMM(0.05))
    b_.Add(e)


def hole_fp(b_, ref, q, d, fid=False):
    """NPTH hole (mouse bite, tooling hole) or fiducial (1 mm copper dot, 2 mm mask opening) as a footprint."""
    f = p.FOOTPRINT(b_)
    f.SetReference(ref); f.Reference().SetVisible(False); f.Value().SetVisible(False)
    f.SetAttributes(p.FP_EXCLUDE_FROM_POS_FILES | p.FP_EXCLUDE_FROM_BOM | p.FP_BOARD_ONLY | p.FP_ALLOW_MISSING_COURTYARD)
    pad = p.PAD(f); pad.SetShape(p.PAD_SHAPE_CIRCLE)
    if fid:
        pad.SetAttribute(p.PAD_ATTRIB_SMD); pad.SetSize(p.VECTOR2I(p.FromMM(d), p.FromMM(d)))
        ls = p.LSET(); ls.AddLayer(p.F_Cu); ls.AddLayer(p.F_Mask); pad.SetLayerSet(ls)
        pad.SetLocalSolderMaskMargin(p.FromMM((PANEL['fiducial_mask'] - d) / 2))
    else:
        pad.SetAttribute(p.PAD_ATTRIB_NPTH); pad.SetSize(p.VECTOR2I(p.FromMM(d), p.FromMM(d)))
        pad.SetDrillSize(p.VECTOR2I(p.FromMM(d), p.FromMM(d)))
        ls = p.LSET.AllCuMask(); ls.AddLayer(p.F_Mask); ls.AddLayer(p.B_Mask); pad.SetLayerSet(ls)
    f.Add(pad)
    f.SetPosition(p.VECTOR2I(*kpt(q)))
    b_.Add(f)


def build_panel():
    P = PANEL
    bp = p.LoadBoard(str(PCB))
    for d_ in list(bp.GetDrawings()):       # the bare outline moves to User.Drawings (not plotted);
        if d_.GetLayer() == p.Edge_Cuts:     # BOARD.Remove() from Python breaks KiCad 8.0.9's SWIG wrappers
            d_.SetLayer(p.Dwgs_User)
    (x0, x1), (y0, y1) = BOARD_X, BOARD_Y
    g, r = P['gap'], P['rail']
    ix0, ix1, iy0, iy1 = x0 - g, x1 + g, y0 - g, y1 + g          # inner edge of the frame
    ox0, ox1, oy0, oy1 = ix0 - r, ix1 + r, iy0 - r, iy1 + r      # outer edge of the panel
    solid = sps_of(board_outline())
    bites = []
    for edge, c, width in P['tabs']:
        w = width / 2
        n = int((width - 2 * P['bite_end_web'] - P['bite_d']) / P['bite_pitch'] + 1e-9) + 1   # holes in this tab
        row = [c + (k - (n - 1) / 2) * P['bite_pitch'] for k in range(n)]
        if edge == 'top':
            solid.BooleanAdd(sps_of(rect(c - w, c + w, y1 - 0.1, iy1 + 0.1)), p.SHAPE_POLY_SET.PM_FAST)
            bites += [(q, y1 + P['bite_offset']) for q in row]
        elif edge == 'left':
            solid.BooleanAdd(sps_of(rect(ix0 - 0.1, x0 + 0.1, c - w, c + w)), p.SHAPE_POLY_SET.PM_FAST)
            bites += [(x0 - P['bite_offset'], q) for q in row]
        elif edge == 'right':
            solid.BooleanAdd(sps_of(rect(x1 - 0.1, ix1 + 0.1, c - w, c + w)), p.SHAPE_POLY_SET.PM_FAST)
            bites += [(x1 + P['bite_offset'], q) for q in row]
        else:
            raise ValueError(edge)
    slots = sps_of(rect(ix0, ix1, iy0, iy1))
    slots.BooleanSubtract(solid, p.SHAPE_POLY_SET.PM_STRICTLY_SIMPLE)
    for i in range(slots.OutlineCount()):
        o = slots.COutline(i)
        pts = [(o.CPoint(k).x, o.CPoint(k).y) for k in range(o.PointCount())]
        for a, z in zip(pts, pts[1:] + pts[:1]):
            edge_seg(bp, a, z)
    outer = [kpt(q) for q in rect(ox0, ox1, oy0, oy1)]
    for a, z in zip(outer, outer[1:] + outer[:1]):
        edge_seg(bp, a, z)
    for k, q in enumerate(bites, 1):
        hole_fp(bp, 'MB%d' % k, q, P['bite_d'])
    tx, ty = P['tooling_from_edge']
    for k, q in enumerate([(ox0 + tx, oy1 - ty), (ox1 - tx, oy1 - ty), (ox0 + tx, oy0 + ty), (ox1 - tx, oy0 + ty)], 1):
        hole_fp(bp, 'TH%d' % k, q, P['tooling_d'])
    fe = P['fiducial_from_edge']
    fids = [(-22.0, oy1 - fe), (22.0, oy1 - fe), (-22.0, oy0 + fe)]        # three, asymmetric
    for k, q in enumerate(fids, 1):
        hole_fp(bp, 'FID%d' % k, q, P['fiducial_cu'], fid=True)
    p.SaveBoard(str(PANEL_PCB), bp)
    info = dict(size_mm=[round(ox1 - ox0, 2), round(oy1 - oy0, 2)], routed_slots=slots.OutlineCount(),
                tabs=P['tabs'], mouse_bites=len(bites), fiducials=fids, tooling_holes=4)
    return info


panel = build_panel()
# the panel takes the board's net classes and custom rules, so its DRC checks the same rules as the board's
import shutil
_side = [(HERE / (NAME + ext), OUT / (NAME + '-panel' + ext)) for ext in ('.kicad_pro', '.kicad_dru')]
for src_, dst_ in _side:
    shutil.copyfile(src_, dst_)
drc_panel = OUT / '_panel-drc.json'
subprocess.run([CLI, 'pcb', 'drc', '--format', 'json', '--severity-all', '--output', str(drc_panel), str(PANEL_PCB)],
               check=True, capture_output=True)
dp = json.loads(drc_panel.read_text())
panel['drc_error_items'] = sorted({' | '.join(i['description'] for i in v['items']) for v in dp['violations']
                                   if v['severity'] == 'error'})[:20]
panel['drc'] = dict(errors=sorted({v['type'] for v in dp['violations'] if v['severity'] == 'error'}),
                    error_count=sum(1 for v in dp['violations'] if v['severity'] == 'error'),
                    warning_types=sorted({v['type'] for v in dp['violations'] if v['severity'] == 'warning'}),
                    unconnected=len(dp['unconnected_items']))
drc_panel.unlink()

layers = 'F.Cu,In1.Cu,In2.Cu,B.Cu,F.Paste,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,Edge.Cuts'
subprocess.run([CLI, 'pcb', 'export', 'gerbers', '--layers', layers, '--subtract-soldermask', '--no-x2',
                '--no-netlist', '--output', str(GER) + '/', str(PANEL_PCB)], check=True)
subprocess.run([CLI, 'pcb', 'export', 'drill', '--format', 'excellon', '--drill-origin', 'absolute',
                '--excellon-units', 'mm', '--excellon-zeros-format', 'decimal', '--excellon-oval-format', 'alternate', '--excellon-separate-th',
                '--output', str(GER) + '/', str(PANEL_PCB)], check=True)
# a picture of the panel for the order check (component side, as JLC's viewer shows it)
svg = HERE / 'review' / '_panel.svg'
subprocess.run([CLI, 'pcb', 'export', 'svg', '--layers', 'F.Cu,F.Mask,F.Silkscreen,Edge.Cuts', '--page-size-mode', '2',
                '--exclude-drawing-sheet', '--output', str(svg), str(PANEL_PCB)], check=True, capture_output=True)
subprocess.run(['magick', '-density', '600', '-background', 'white', str(svg), '-flatten', str(HERE / 'review' / 'render-panel.png')],
               check=True)
svg.unlink()
for f in GER.iterdir():                 # the panel file names its outputs after itself
    if f.name.startswith(NAME + '-panel'):
        f.rename(GER / f.name.replace(NAME + '-panel', NAME))
# the job file lists the Gerbers by name: give it the new names, and the finish ORDER.md asks for (review FAB-4)
job_path = GER / (NAME + '-job.gbrjob')
job = json.loads(job_path.read_text())
for fa in job.get('FilesAttributes', []):
    fa['Path'] = fa['Path'].replace(NAME + '-panel', NAME)
job['GeneralSpecs']['ProjectId']['Name'] = NAME
job['GeneralSpecs']['Finish'] = 'ENIG'
job_path.write_text(json.dumps(job, indent=2) + '\n')
PANEL_PCB.unlink()
for src_, dst_ in _side:
    dst_.unlink()
for f in OUT.glob(NAME + '-panel*'):        # KiCad may leave a .kicad_prl or a lock file beside the panel
    f.unlink()
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
         'D1': 'diode: cathode band to VSYS', 'D2': 'diode: cathode band to BZ_P', 'BZ1': '+ pad to BZ_P',
         # review FP-11: polarised parts whose 90 or 180 degree error would short a rail
         'U3': 'SOT-23-5: pin 1 mark (STAT); pins 4 (VDD) and 3 (VBAT) on opposite sides',
         'U4': 'TSOT-23-5: pin 1 mark (VIN); a 180 degree error puts VSYS on VOUT',
         'U8': 'SOT-23-6: pin 1 mark; pin 5 is VBUS and pin 2 GND',
         'Q2': 'SOT-23: single pin 3 (drain) on the side the footprint shows', 'Q3': 'SOT-23: single pin 3 (drain)',
         'Q4': 'SOT-23: single pin 3 (drain)', 'Q5': 'SOT-23: single pin 3 (drain)', 'Q6': 'SOT-23: single pin 3 (drain)'}
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
summary = dict(bom_lines=len(bom), placements=len(rows), basic_lines=basic, extended_lines=len(bom) - basic, panel=panel,
               gerber_files=[f.name for f in files], zip=zpath.name,
               zip_sha256=hashlib.sha256(zpath.read_bytes()).hexdigest(), board_sha256=ver['sha256'][PCB.name])
(OUT / 'package.json').write_text(json.dumps(summary, indent=1) + '\n')
print(json.dumps(summary, indent=1))
