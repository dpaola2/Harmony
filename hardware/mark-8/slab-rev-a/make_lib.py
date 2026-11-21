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
import math
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


# --- paste-only openings (2026-11-21 change review: REG-1, USBC-2, USBC-3, USBC-4) ---------------------------
# KiCad's paste margin is one number for both axes and is centred on the pad, so the openings that are not
# centred or not rectangles are drawn as aperture pads: pads with no number and no copper, on F.Paste only.
# The copper pad under each one loses its own F.Paste layer.
def _sps(pts):
    s = p.SHAPE_POLY_SET(); s.NewOutline()
    for x, y in pts:
        s.Append(p.FromMM(x), p.FromMM(y))
    return s


def _arc(cx, cy, r, a0, a1, n, outside):
    """Points on an arc from angle a0 to a1 (radians). outside=True puts the vertices on radius r / cos(step / 2),
    so the chords never come closer than r to the centre (for keep-outs); False keeps them on r (for openings)."""
    step = (a1 - a0) / n
    rr = r / math.cos(step / 2) if outside else r
    return [(cx + rr * math.cos(a0 + step * k), cy + rr * math.sin(a0 + step * k)) for k in range(n + 1)]


def _stadium(cx, cy, w, l, n=32):
    """Opening: a slot pad shape (w across, l along y), vertices on the true outline."""
    r, h = w / 2, l / 2 - w / 2
    return _arc(cx, cy + h, r, 0, math.pi, n, False) + _arc(cx, cy - h, r, math.pi, 2 * math.pi, n, False)


def _keepout(a, z, r, n=16):
    """Keep-out: everything within r of the segment a-z (a circle when a == z), never undercut."""
    t = math.atan2(z[1] - a[1], z[0] - a[0])
    return (_arc(z[0], z[1], r, t - math.pi / 2, t + math.pi / 2, n, True) +
            _arc(a[0], a[1], r, t + math.pi / 2, t + 3 * math.pi / 2, n, True))


def _box_keepout(x0, x1, y0, y1, r, n=8):
    """Keep-out: everything within r of the rectangle, never undercut."""
    pts = []
    for cx, cy, a in ((x1, y1, 0), (x0, y1, math.pi / 2), (x0, y0, math.pi), (x1, y0, 1.5 * math.pi)):
        pts += _arc(cx, cy, r, a, a + math.pi / 2, n, True)
    return pts


def add_aperture(fp, centre, outline):
    """Paste-only pad at centre (footprint mm) whose opening is the polygon outline (footprint mm)."""
    ap = p.PAD(fp)
    ap.SetNumber('')
    ap.SetAttribute(p.PAD_ATTRIB_SMD)
    ap.SetShape(p.PAD_SHAPE_CUSTOM)
    ap.SetAnchorPadShape(p.PAD_SHAPE_CIRCLE)
    ap.SetSize(v(0.1, 0.1))                  # anchor, inside every opening here
    ls = p.LSET(); ls.AddLayer(p.F_Paste); ap.SetLayerSet(ls)
    ap.SetPosition(v(*centre))
    ap.AddPrimitivePoly(_sps([(x - centre[0], y - centre[1]) for x, y in outline]), 0, True)
    fp.Add(ap)


def add_aperture_rect(fp, centre, w, h):
    ap = p.PAD(fp)
    ap.SetNumber('')
    ap.SetAttribute(p.PAD_ATTRIB_SMD)
    ap.SetShape(p.PAD_SHAPE_RECT)
    ap.SetSize(v(w, h))
    ls = p.LSET(); ls.AddLayer(p.F_Paste); ap.SetLayerSet(ls)
    ap.SetPosition(v(*centre))
    fp.Add(ap)


def no_paste(pad):
    ls = pad.GetLayerSet(); ls.RemoveLayer(p.F_Paste); pad.SetLayerSet(ls)
    pad.SetLocalSolderPasteMargin(0); pad.SetLocalSolderPasteMarginRatio(0)


def clipped_opening(shape, keepouts):
    """shape minus every keep-out polygon; the largest piece (the one over the pad) as a point list."""
    s = _sps(shape)
    for k in keepouts:
        s.BooleanSubtract(_sps(k), p.SHAPE_POLY_SET.PM_STRICTLY_SIMPLE)
    best = max((s.Outline(i) for i in range(s.OutlineCount())), key=lambda o: abs(o.Area()))
    return [(p.ToMM(best.CPoint(k).x), p.ToMM(best.CPoint(k).y)) for k in range(best.PointCount())]


# J1 pin-in-paste (FP-1, REG-1, USBC-3). Each shell-slot opening is the pad grown by 0.25 mm, cut back to stay
# PASTE_CLEAR (0.15 plus 0.01 for rounding) from the other-net copper and the via rings next to it and from J1's
# own signal-pad openings. The copper below comes from the routed board, in J1 footprint mm (J1 sits at rotation 0,
# so device x = -x and device y = -45.47 - y). verify.py measures the result against the board (j1_paste_clearance),
# so a re-route that brings copper closer fails there.
J1_PASTE_MARGIN, PASTE_CLEAR = 0.25, 0.16
J1_PASTE_NEAR = [
    # (what, end a, end b, half width): segments, or circles when a == b
    ('LCD_MOSI on L1 beside pad 1', (5.2548, -1.0465), (2.8766, 1.3317), 0.075),
    ('LCD_MOSI on L1 beside pad 1', (5.2548, -3.4070), (5.2548, -1.0465), 0.075),
    ('CC2 via below pad 1', (4.9862, -0.1218), (4.9862, -0.1218), 0.25),
    ('CHG_STAT via above pad 2 (tented)', (5.1128, 1.4570), (5.1128, 1.4570), 0.25),
    ('VBUS via above pad 2 (tented)', (3.4782, 1.4968), (3.4782, 1.4968), 0.25),
    ('VBUS on L1 into that via', (3.4783, 1.3150), (3.4783, 1.4968), 0.2),
    ('VBUS on L1 from that via', (3.4783, 1.3150), (4.0533, 0.7400), 0.2),
    ('CHG_STAT on L1 beside pad 2', (5.2933, 2.2942), (5.2933, 1.6375), 0.075),
]


def fix_land_pattern(fp, name):
    if name == 'USB-C_HRO_TYPE-C-31-M-12':
        # Shell legs (review FP-1, L2): HRO's recommended layout (C165948.pdf) has 0.60 wide plated slots,
        # 1.70 long beside the contact row and 1.40 long near the board edge, in 0.90 wide pads 2.00 / 1.70 long.
        # The real legs are about 0.30 thick, 1.10 (rear) and 0.80 (front) wide (HRO side view), so they keep
        # 0.15 per side across the slot and 0.30 per end along it. Pin-in-paste: each slot gets a paste opening
        # printed over it, up to 0.25 larger than the pad (J1_PASTE_NEAR), so the legs solder in the reflow pass.
        sig = [pd for pd in fp.Pads() if pd.GetAttribute() == p.PAD_ATTRIB_SMD and pd.IsOnLayer(p.F_Paste)]
        near = [_keepout(a, z, r + PASTE_CLEAR) for what, a, z, r in J1_PASTE_NEAR]
        for pd in sig:
            c, s_ = pd.GetPosition(), pd.GetSize()
            x, y, w, h = p.ToMM(c.x), p.ToMM(c.y), p.ToMM(s_.x), p.ToMM(s_.y)
            near.append(_box_keepout(x - w / 2, x + w / 2, y - h / 2, y + h / 2, PASTE_CLEAR))
        for pad in list(fp.Pads()):
            if pad.GetNumber() in ('1', '4', '2', '3'):
                rear = pad.GetNumber() in ('1', '4')
                pad.SetSize(v(0.9, 2.0 if rear else 1.7))
                pad.SetDrillShape(p.PAD_DRILL_SHAPE_OBLONG)
                pad.SetDrillSize(v(0.6, 1.7 if rear else 1.4))
                no_paste(pad)
                cx, cy = p.ToMM(pad.GetPosition().x), p.ToMM(pad.GetPosition().y)
                m = J1_PASTE_MARGIN
                add_aperture(fp, (cx, cy), clipped_opening(_stadium(cx, cy, 0.9 + 2 * m, (2.0 if rear else 1.7) + 2 * m), near))
    if name == 'FH35C-15S-0.3SHW':
        # Hirose EDC3-338903-01 sheet 1, "Recommended stencil pattern (t = 0.1)", measured on the 400 ppi scan
        # (157.5 px/mm from the 0.6 pitch): contact-1 row (0.8 pads) 0.23 x 0.65, contact-2 row (0.65 pads)
        # 0.23 x 0.55, each flush with its pad's outer edge, so the pull-back is on the inner side and the rows
        # are 2.40 apart (0.55 + 2.40 + 0.65 = 3.6, the pad pattern's outer span). Fittings (0.4 x 0.95 pads):
        # 0.30 x 0.70, flush with the pad's outer end and its contact-1 side, as drawn (review FP-3, USBC-2).
        for pad in list(fp.Pads()):
            num = pad.GetNumber()
            if not num:
                continue
            x, y = p.ToMM(pad.GetPosition().x), p.ToMM(pad.GetPosition().y)
            w, h = p.ToMM(pad.GetSize().x), p.ToMM(pad.GetSize().y)
            no_paste(pad)
            sy = 1 if y > 0 else -1                          # +1: contact-1 row side of the footprint
            if num in ('16', '17'):
                sx = 1 if x > 0 else -1
                add_aperture_rect(fp, (x + sx * (w / 2 - 0.15), y + h / 2 - 0.35), 0.30, 0.70)
            else:
                ln = 0.65 if sy > 0 else 0.55
                add_aperture_rect(fp, (x, y + sy * (h / 2 - ln / 2)), 0.23, ln)
    if name == 'QFN-24_4x4_P0.5_EP2.5':
        # CH9102F exposed pad (USBC-4): nine windows on a 3 x 3 grid with 0.2 mm webs through the four GND vias
        # (U2_EP_VIAS), each window at least 0.1 mm off a via land (0.5 mm) and 0.1 mm inside the 2.5 mm pad:
        # about 47 percent of the pad. The webs hold the stencil over each via, so no paste prints on the open
        # barrels.
        for pad in fp.Pads():
            if pad.GetNumber() == '25':
                no_paste(pad)
        lim, web = 1.15, 0.2
        o = abs(U2_EP_VIAS[0][0])
        cuts = [_keepout(q, q, 0.25 + 0.1 + 0.01) for q in U2_EP_VIAS]
        spans = [(-lim, -o - web / 2), (-o + web / 2, o - web / 2), (o + web / 2, lim)]
        for x0, x1 in spans:
            for y0, y1 in spans:
                win = clipped_opening([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], cuts)
                add_aperture(fp, ((x0 + x1) / 2, (y0 + y1) / 2), win)


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
        if not any(pad.IsOnLayer(L) for L in (p.F_Cu, p.B_Cu)):
            continue                     # paste-only openings do not set the courtyard
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
