"""Build the project footprint library lib/Harmony8.pretty and lib/Harmony8.3dshapes.

Run with KiCad's bundled Python. Sources:
- lib/easyeda: easyeda2kicad imports of the LCSC parts (footprint = JLC/EasyEDA land pattern and
  origin, so JLC rotations in the CPL equal the KiCad orientation).
- KiCad 8.0.9 library passives and test pads.
- Footprints drawn here: touch wheel connection pads, motor pads, NPTH locating hole, press pad.

The EasyEDA STEP files are not positioned like the WRL files (easyeda2kicad only offsets the WRL).
MODEL_FIX holds the KiCad model rotation and offset that put each STEP body on its pads. Each
value was found by slicing the STEP at the board plane and matching legs to pads (rotation and
offset), then cross-checked against the vendor drawing (README, "3D model alignment").
"""
import shutil
import pcbnew as p
import wx
from design import *

app = wx.App(False)
EASY = LIBDIR / 'easyeda'
PRETTY = LIBDIR / (LIBNAME + '.pretty')
SHAPES = LIBDIR / (LIBNAME + '.3dshapes')
KLIB = KICAD / 'SharedSupport/footprints'
K3D = KICAD / 'SharedSupport/3dmodels'
PRETTY.mkdir(parents=True, exist_ok=True)
SHAPES.mkdir(parents=True, exist_ok=True)
io = p.PCB_IO_KICAD_SEXPR()

# easyeda name -> (project name, step model, KiCad model rotation z, offset xyz)
MODEL_FIX = {
    'BULETM-SMD_ESP32-PICO-MINI-02-N8R2': ('ESP32-PICO-MINI-02', 'BULETM-SMD_ESP32-PICO-MINI-02-N8R2', 0, (0, 2.70, 0)),
    'USB-C_SMD-TYPE-C-31-M-12_1': ('USB-C_HRO_TYPE-C-31-M-12', 'USB-C_SMD-TYPE-C-31-M-12_1', 180, (0, -2.33, 0)),
    'CONN-SMD_P2.00_S2B-PH-SM4-TB-LF-SN': ('JST_PH_S2B-PH-SM4-TB', 'CONN-SMD_P2.00_S2B-PH-SM4-TB-LF-SN', 0, (1.00, -2.75, 0)),
    'FPC-SMD_15P-P0.60_HRS_FH35C-15S-0.3SHW': ('FH35C-15S-0.3SHW', 'FPC-SMD_15P-P0.60_HRS_FH35C-15S-0.3SHW', 0, (0, 0.07, -1.94)),
    'SD-SMD_DM3AT-SF-PEJM5': ('DM3AT-SF-PEJM5', 'SD-SMD_DM3AT-SF-PEJM5', 0, (0.07, -0.33, 1.89)),
    'KEY-SMD_SKRTLAE010': ('SW_SKRTLAE010', 'KEY-SMD_L4.6-W3.4-H3.4', 0, (0, 0.07, -0.05)),
    'SW-SMD_L3.9-W3.0-P4.45': ('SW_TS-1088', 'SW-SMD_L3.9-W2.9-H2.0-LS4.8', 0, (0, 0, 0)),
    'BUZ-SMD_L5.0-W5.5-P4.60': ('Buzzer_MLT-5020', 'BUZ-SMD_3P-L5.2-W5.2-H2.0-P3.50', 90, (0, 0, 0)),
    'QFN-20_L3.0-W3.0-P0.40-BL': ('QFN-20_3x3_P0.4', 'QFN-20_L3.0-W3.0-H0.6-P0.40-BL', 270, (0, 0, 0)),
    'QFN-24_L4.0-W4.0-P0.50-BL-EP2.5': ('QFN-24_4x4_P0.5_EP2.5', 'QFN-24_L4.0-W4.0-P0.50-BL-EP2.5', 270, (0, 0, 0.01)),
    'TDFN-8_L2.0-W2.0-P0.50-BL-EP1.2': ('TDFN-8_2x2_P0.5_EP', 'TDFN-8_L2.0-W2.0-P0.50-BL-EP1.2', 0, (0, 0, 0.02)),
    'VSSOP-10_L3.0-W3.0-P0.50-LS4.9-BL': ('VSSOP-10_DRV2605L', 'VSSOP-10_L3.0-W3.0-H1.1-LS4.9-P0.50', 270, (0, 0, 0.15)),
    'SOT-23-3_L2.9-W1.3-P1.90-LS2.4-BR': ('SOT-23_AO3400A', 'SOT-23-3P_L2.9-W1.3-H1.0-LS2.4-P0.95', 180, (0, 0, -0.05)),
    'SOT-23_L2.9-W1.3-P1.90-LS2.4-BR': ('SOT-23_AO3401A', 'SOT-23-3P_L2.9-W1.3-H1.0-LS2.4-P0.95', 180, (0, 0, -0.05)),
    'SOT-23-5_L3.0-W1.7-P0.95-LS2.8-BL': ('SOT-23-5_MCP73831', 'SOT-23-5_L2.9-W1.6-H1.1-LS2.8-P0.95', 270, (0, 0, 0.05)),
    'SOT-23-6_L2.9-W1.6-P0.95-LS2.8-BL': ('SOT-23-6', 'SOT-23-6_L2.9-W1.6-H1.5-LS2.8-P0.95', 270, (0, 0, 0.05)),
    'TSOT-23-5_L2.9-W1.6-P0.95-LS2.8-BL': ('TSOT-23-5_RT9080', 'TSOT-23-5_L2.9-W1.6-H1.00-LS2.8-P0.95', 270, (0, 0, -0.05)),
    'SC-70-6_L2.2-W1.3-P0.65-LS2.1-BR': ('SOT-363', 'SC-70-6_L2.1-W1.3-H1.0-LS2.1-P0.65', 0, (0, 0, 0.10)),
    'SOD-123_L2.7-W1.6-LS3.7-RD-1': ('SOD-123_B5819W', 'SOD-123_L2.7-W1.6-LS3.7-RD-1', 0, (0, 0, 0.60)),
    'LED-SMD_L1.6-W0.8-R-RD': ('LED_0603_EasyEDA', 'LED0603_L1.6-W0.8-H0.6', 0, (0, 0, 0)),
}
KICAD_FPS = [('Resistor_SMD', n, 'Resistor_SMD') for n in (R0402, R0603, R0805, R1206)] + \
            [('Capacitor_SMD', n, 'Capacitor_SMD') for n in (C0402, C0603, C0805)] + \
            [('TestPoint', 'TestPoint_Pad_D1.0mm', None)]


def v(x, y):
    return p.VECTOR2I(p.FromMM(x), p.FromMM(y))


def tidy(fp, name):
    fp.SetFPID(p.LIB_ID(LIBNAME, name))
    fp.Reference().SetLayer(p.F_Fab)
    fp.Reference().SetTextSize(v(0.5, 0.5))
    fp.Reference().SetTextThickness(p.FromMM(0.08))
    fp.Value().SetLayer(p.F_Fab)
    fp.Value().SetVisible(False)
    # EasyEDA's pin-1 marks on User.Comments stay; FOOTPRINT.Remove() from Python corrupts the
    # SWIG wrappers in KiCad 8.0.9, and the comment layer is not fabricated.


# --- land-pattern fixes from the 2026-11-21 pre-order review (README, "Review dispositions") ------------
import re as _re


def raw_custom_polys(src_name):
    """Pad number -> (polygon points, stroke width) of every custom pad in the EasyEDA source file.
    easyeda2kicad keeps EasyEDA's 0.1 mm outline stroke on custom pads; KiCad adds half of it on every side,
    so the copper, mask and paste come out 0.1 mm wider than the maker's land pattern (review L1, FP-2, FP-8)."""
    txt = (EASY / 'lcsc.pretty' / (src_name + '.kicad_mod')).read_text()
    out = {}
    for m in _re.finditer(r'\(pad (\S+) smd custom .*?\(gr_poly\s*\(pts (.*?)\)\s*\(width ([\d.]+)\)', txt, _re.S):
        pts = [(float(a), float(b)) for a, b in _re.findall(r'\(xy ([-\d.]+) ([-\d.]+)\)', m.group(2))]
        out[m.group(1)] = (pts, float(m.group(3)))
    return out


STROKE_FIXED = {}   # footprint -> [(pad, stroke removed)], reported at the end


def fix_custom_pads(fp, src, name):
    """Redraw every custom pad from its polygon with no stroke, so the copper is the drawn land pattern."""
    polys = raw_custom_polys(src)
    for pad in fp.Pads():
        if pad.GetShape() != p.PAD_SHAPE_CUSTOM or pad.GetNumber() not in polys:
            continue
        pts, width = polys[pad.GetNumber()]
        xs, ys = [x for x, y in pts], [y for x, y in pts]
        if name == 'USB-C_HRO_TYPE-C-31-M-12':
            # the four VBUS/GND pads are plain rectangles: HRO "4-0.60" wide, 1.30 long like the EasyEDA pattern
            pad.DeletePrimitivesList()
            pad.SetShape(p.PAD_SHAPE_RECT)
            pad.SetSize(v(round(max(xs) - min(xs), 2), round(max(ys) - min(ys), 2)))
            pad.SetOffset(v(0, 0))
        else:
            sps = p.SHAPE_POLY_SET(); sps.NewOutline()
            for x, y in pts:
                sps.Append(p.FromMM(x), p.FromMM(y))
            pad.DeletePrimitivesList()
            pad.AddPrimitivePoly(sps, 0, True)
        STROKE_FIXED.setdefault(name, []).append((pad.GetNumber(), width))


def fix_land_pattern(fp, name):
    if name == 'USB-C_HRO_TYPE-C-31-M-12':
        # Shell legs (review FP-1, L2): HRO's recommended layout (C165948.pdf) has 0.60 wide plated slots,
        # 1.70 long beside the contact row and 1.40 long near the board edge, in 0.90 wide pads 2.00 / 1.70 long.
        # The real legs are about 0.30 thick, 1.10 (rear) and 0.80 (front) wide (HRO side view), so they keep
        # 0.15 per side across the slot and 0.30 per end along it. Pin-in-paste: each pad gets a paste opening
        # 0.25 larger than the pad all round, printed over the slot, so the legs solder in the reflow pass.
        for pad in fp.Pads():
            if pad.GetNumber() in ('1', '4', '2', '3'):
                rear = pad.GetNumber() in ('1', '4')
                pad.SetSize(v(0.9, 2.0 if rear else 1.7))
                pad.SetDrillShape(p.PAD_DRILL_SHAPE_OBLONG)
                pad.SetDrillSize(v(0.6, 1.7 if rear else 1.4))
                ls = pad.GetLayerSet(); ls.AddLayer(p.F_Paste); pad.SetLayerSet(ls)
                pad.SetLocalSolderPasteMargin(p.FromMM(0.25))
    if name == 'FH35C-15S-0.3SHW':
        # Hirose EDC3-338903-01 recommended stencil (t = 0.1): contact openings 0.23 wide, 0.70 long on the
        # contact-1 row (0.8 pads) and 0.55 long on the contact-2 row (0.65 pads); fitting openings 0.30 x 0.70
        # (0.4 x 0.95 pads). Margin m plus ratio r per side: 0.3 -> 0.23, 0.8 -> 0.70, 0.65 -> 0.56 (review FP-3).
        for pad in fp.Pads():
            if pad.GetNumber() in ('16', '17'):
                pad.SetLocalSolderPasteMargin(p.FromMM(0.0045)); pad.SetLocalSolderPasteMarginRatio(-0.1364)
            else:
                pad.SetLocalSolderPasteMargin(p.FromMM(-0.026)); pad.SetLocalSolderPasteMarginRatio(-0.03)
    if name == 'QFN-24_4x4_P0.5_EP2.5':
        # CH9102F exposed pad: 2.0 x 2.0 paste opening, 64 percent of the 2.5 x 2.5 pad (review FP-10), so the
        # QFN does not float on the paste; the four open GND vias stay inside the opening.
        for pad in fp.Pads():
            if pad.GetNumber() == '25':
                pad.SetLocalSolderPasteMargin(p.FromMM(-0.25))


def set_model(fp, step, rot, off):
    fp.Models().clear()
    m = p.FP_3DMODEL()
    m.m_Filename = '${KIPRJMOD}/lib/' + LIBNAME + '.3dshapes/' + step + '.step'
    m.m_Rotation = p.VECTOR3D(0, 0, rot)
    m.m_Offset = p.VECTOR3D(*off)
    m.m_Scale = p.VECTOR3D(1, 1, 1)
    fp.Models().push_back(m)


def add_courtyard(fp, margin=0.12):
    """Courtyard = bounding box of pads plus the imported body courtyard, plus margin.
    EasyEDA courtyards cover the body only; the imported lines move to User.Comments."""
    xs, ys = [], []
    for g in fp.GraphicalItems():
        if g.GetLayer() == p.F_CrtYd:
            b = g.GetBoundingBox()
            xs += [b.GetLeft(), b.GetRight()]; ys += [b.GetTop(), b.GetBottom()]
            g.SetLayer(p.Cmts_User)
    for pad in fp.Pads():
        b = pad.GetBoundingBox()
        xs += [b.GetLeft(), b.GetRight()]; ys += [b.GetTop(), b.GetBottom()]
    o = fp.GetPosition()
    x0, x1 = p.ToMM(min(xs) - o.x) - margin, p.ToMM(max(xs) - o.x) + margin
    y0, y1 = p.ToMM(min(ys) - o.y) - margin, p.ToMM(max(ys) - o.y) + margin
    r = p.PCB_SHAPE(fp, p.SHAPE_T_RECT)
    r.SetStart(v(x0, y0)); r.SetEnd(v(x1, y1)); r.SetLayer(p.F_CrtYd); r.SetWidth(p.FromMM(0.05))
    fp.Add(r)


for src, (name, step, rot, off) in MODEL_FIX.items():
    fp = p.FootprintLoad(str(EASY / 'lcsc.pretty'), src)
    tidy(fp, name)
    for pad in fp.Pads():
        # EasyEDA marks the locating-post holes as plated pads without a number; make them NPTH.
        if pad.GetAttribute() == p.PAD_ATTRIB_PTH and pad.GetNumber() == '':
            pad.SetAttribute(p.PAD_ATTRIB_NPTH)
            pad.SetSize(pad.GetDrillSize())
            ls = p.LSET.AllCuMask(); ls.AddLayer(p.F_Mask); ls.AddLayer(p.B_Mask)
            pad.SetLayerSet(ls)
    fp.SetAttributes(p.FP_SMD)
    fix_custom_pads(fp, src, name)
    fix_land_pattern(fp, name)
    add_courtyard(fp, 0.05 if name in ('USB-C_HRO_TYPE-C-31-M-12', 'FH35C-15S-0.3SHW') else 0.12)
    set_model(fp, step, rot, off)
    src_step = EASY / 'lcsc.3dshapes' / (step + '.step')
    if src_step.exists():          # lib/easyeda/lcsc.3dshapes only exists after import_lcsc.sh
        shutil.copyfile(src_step, SHAPES / (step + '.step'))
    assert (SHAPES / (step + '.step')).exists(), step
    io.FootprintSave(str(PRETTY), fp)

for lib, name, shapes in KICAD_FPS:
    fp = p.FootprintLoad(str(KLIB / (lib + '.pretty')), name)
    tidy(fp, name)
    if shapes:
        set_model(fp, name, 0, (0, 0, 0))
        shutil.copyfile(K3D / (shapes + '.3dshapes') / (name + '.step'), SHAPES / (name + '.step'))
    else:
        fp.Models().clear()
    io.FootprintSave(str(PRETTY), fp)


def new_fp(name, attrs):
    fp = p.FOOTPRINT(None)
    fp.SetFPID(p.LIB_ID(LIBNAME, name))
    fp.SetAttributes(attrs)
    fp.Reference().SetLayer(p.F_Fab); fp.Reference().SetTextSize(v(0.5, 0.5))
    fp.Value().SetLayer(p.F_Fab); fp.Value().SetVisible(False)
    return fp


def circle(fp, r, layer, width=0.1, fill=False):
    c = p.PCB_SHAPE(fp, p.SHAPE_T_CIRCLE)
    c.SetCenter(v(0, 0)); c.SetEnd(v(r, 0)); c.SetLayer(layer); c.SetWidth(p.FromMM(width))
    c.SetFilled(fill)
    fp.Add(c)


# Motor pad: one 2.0 x 1.5 SMD pad (no paste: the optional motor is hand-soldered).
fp = new_fp('MotorPad_2.0x1.5', p.FP_SMD | p.FP_EXCLUDE_FROM_POS_FILES | p.FP_EXCLUDE_FROM_BOM)
pad = p.PAD(fp); pad.SetNumber('1'); pad.SetAttribute(p.PAD_ATTRIB_SMD); pad.SetShape(p.PAD_SHAPE_ROUNDRECT)
pad.SetRoundRectRadiusRatio(0.15); pad.SetSize(v(2.0, 1.5))
ls = p.LSET(); ls.AddLayer(p.F_Cu); ls.AddLayer(p.F_Mask); pad.SetLayerSet(ls); fp.Add(pad)
r = p.PCB_SHAPE(fp, p.SHAPE_T_RECT); r.SetStart(v(-1.0, -0.75)); r.SetEnd(v(1.0, 0.75))
r.SetLayer(p.F_Fab); r.SetWidth(p.FromMM(0.1)); fp.Add(r)   # hand-solder pad: no courtyard
io.FootprintSave(str(PRETTY), fp)

# NPTH locating hole for a front-skin pin.
fp = new_fp('LocatingHole_NPTH_1.6', p.FP_EXCLUDE_FROM_POS_FILES | p.FP_EXCLUDE_FROM_BOM | p.FP_BOARD_ONLY)
pad = p.PAD(fp); pad.SetNumber(''); pad.SetAttribute(p.PAD_ATTRIB_NPTH); pad.SetShape(p.PAD_SHAPE_CIRCLE)
pad.SetSize(v(LOCATING_HOLE_D, LOCATING_HOLE_D)); pad.SetDrillSize(v(LOCATING_HOLE_D, LOCATING_HOLE_D))
ls = p.LSET.AllCuMask(); ls.AddLayer(p.F_Mask); ls.AddLayer(p.B_Mask); pad.SetLayerSet(ls); fp.Add(pad)
circle(fp, LOCATING_HOLE_D / 2 + 0.4, p.F_CrtYd, 0.05)
io.FootprintSave(str(PRETTY), fp)

# Press pad: a 4.0 mm area kept free of parts (courtyard) and marked on the silkscreen.
fp = new_fp('PressPad_4.0', p.FP_EXCLUDE_FROM_POS_FILES | p.FP_EXCLUDE_FROM_BOM | p.FP_BOARD_ONLY)
circle(fp, PRESS_PAD_D / 2, p.F_CrtYd, 0.05)
circle(fp, PRESS_PAD_D / 2, p.F_SilkS, 0.12)
circle(fp, PRESS_PAD_D / 2, p.F_Fab, 0.1)
io.FootprintSave(str(PRETTY), fp)

# Touch wheel: plated connection pads, one per electrode, at ELECTRODE_VIAS. The electrode copper
# itself is drawn as B.Cu zones by build_pcb.py. Footprint origin = wheel centre, KiCad angle 0,
# so a device offset (dx, dy) is the footprint-local point (-dx, -dy).
fp = new_fp('TouchWheel', p.FP_SMD | p.FP_EXCLUDE_FROM_POS_FILES | p.FP_EXCLUDE_FROM_BOM)
for num, (x, y) in ELECTRODE_VIAS.items():
    pad = p.PAD(fp); pad.SetNumber(num); pad.SetAttribute(p.PAD_ATTRIB_PTH); pad.SetShape(p.PAD_SHAPE_CIRCLE)
    pad.SetSize(v(0.6, 0.6)); pad.SetDrillSize(v(0.3, 0.3))
    pad.SetPosition(v(-(x - WHEEL_C[0]), -(y - WHEEL_C[1])))
    pad.SetLayerSet(p.LSET.AllCuMask())       # tented: no mask openings
    fp.Add(pad)
circle(fp, WHEEL_DISC_D / 2, p.F_Fab, 0.1)
io.FootprintSave(str(PRETTY), fp)

(HERE / 'fp-lib-table').write_text(
    '(fp_lib_table\n  (version 7)\n  (lib (name "%s")(type "KiCad")(uri "${KIPRJMOD}/lib/%s.pretty")(options "")(descr "Mark-8 slab footprints"))\n)\n'
    % (LIBNAME, LIBNAME))
print('library:', len(list(PRETTY.glob('*.kicad_mod'))), 'footprints,', len(list(SHAPES.glob('*.step'))), 'STEP models')
for nm, pads in sorted(STROKE_FIXED.items()):
    print('custom pads redrawn without the EasyEDA stroke:', nm, ' '.join('%s(%.2f)' % pw for pw in pads))
