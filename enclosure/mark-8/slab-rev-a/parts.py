"""The four printed parts: front shell, wheel disc, side button cap, back plate.

All parts are built in device coordinates (SPEC 1). print_pose() in export.py
moves each one into its print orientation.
"""
import math

import cadquery as cq

import params as P
from geom import V, box, cone_z, cut, cyl_z, one_solid, prism, rrect_xy, rrect_xz, union

FONT = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


# ------------------------------------------------------------------ profiles
def outline(z0, z1, inset=0.0, r=None):
    """Rounded-rectangle prism of the body outline, inset by `inset`."""
    r = (P.CORNER_R - inset) if r is None else r
    return rrect_xy(0, 0, 2 * (P.X_OUT - inset), 2 * (P.Y_OUT - inset), r, z0, z1)


def boss_fill(cx, cy, z0, z1):
    """Fill the quadrant between a corner boss and the corner walls."""
    sx = 1 if cx > 0 else -1
    sy = 1 if cy > 0 else -1
    xa, xb = sorted([cx, sx * (P.X_IN + 0.1)])
    ya, yb = sorted([cy, sy * (P.Y_IN + 0.1)])
    return box(xa, xb, ya, yb, z0, z1)


# ------------------------------------------------------------------ front shell
def front_shell():
    # Body with the 1.0 front edge round, then the window and its chamfer.
    wp = (cq.Workplane("XY", origin=(0, 0, P.SPLIT_Z)).rect(2 * P.X_OUT, 2 * P.Y_OUT)
          .extrude(-P.SPLIT_Z).edges("|Z").fillet(P.CORNER_R)
          .faces(">Z").edges().fillet(P.EDGE_ROUND))
    win_w = 2 * (P.AA_X + P.WIN_MARGIN)
    win_y0, win_y1 = P.AA_Y0 - P.WIN_MARGIN, P.AA_Y1 + P.WIN_MARGIN
    window = rrect_xy(0, (win_y0 + win_y1) / 2, win_w, win_y1 - win_y0, P.WIN_R, -2.0, 1.0)
    wp = wp.cut(window)
    wp = wp.edges(cq.selectors.BoxSelector((-26, win_y0 - 0.5, -0.01), (26, win_y1 + 0.5, 0.01))).chamfer(P.WIN_CHAMFER)
    shell = wp.val()

    # Interior cavity behind the skin.
    cavity = outline(P.SPLIT_Z - 1, -P.SKIN, inset=P.WALL)
    shell = shell.cut(cavity)

    # Screen locating band: the interior between the walls and the screen pocket,
    # over the screen thickness, above the screen's bottom edge.
    c = P.SCR_CLEAR
    pocket_y0, pocket_y1 = P.SCR_Y0 - c, P.SCR_Y1 + c
    # The pocket runs 1 mm past the band's lower end, so its lower corners
    # do not leave feather edges in the band.
    pocket = rrect_xy(0, (pocket_y0 - 1.0 + pocket_y1) / 2, 2 * (P.SCR_X + c), pocket_y1 - pocket_y0 + 1.0,
                      P.SCR_POCKET_R, P.SCR_Z0, -P.SKIN + 0.01)
    band = outline(P.SCR_Z0, -P.SKIN + 0.01, inset=P.WALL - 0.05).intersect(
        box(-30, 30, pocket_y0, 52, P.SCR_Z0, -P.SKIN + 0.01))
    band = band.cut(pocket)
    # Bottom lips stop the screen in -Y, outside the FPC dive zone.
    lips = [box(-P.X_IN - 0.05, -14.5, pocket_y0 - 0.8, pocket_y0, P.SCR_LIP_Z, -P.SKIN + 0.01),
            box(19.5, P.X_IN + 0.05, pocket_y0 - 0.8, pocket_y0, P.SCR_LIP_Z, -P.SKIN + 0.01)]
    shell = union(shell, band, *lips)
    # The screen's top corners lie outside the walls' R3.9 inner corners, so the
    # pocket is also cut into the walls there (about 1.0 of wall is left inside
    # the R5.5 outer corner). Without this cut the walls reached 0.56 into both
    # top corners of the screen (diagram, November 21).
    shell = cut(shell, rrect_xy(0, (pocket_y0 + pocket_y1) / 2, 2 * (P.SCR_X + c), pocket_y1 - pocket_y0,
                                P.SCR_POCKET_R, P.SCR_Z0, -P.SKIN))

    # Corner bosses with heat-set insert holes.
    feats = []
    for (bx, by) in P.BOTTOM_BOSSES:
        feats += [cyl_z(bx, by, P.BOSS_D / 2, P.BOSS_END_Z, -P.SKIN + 0.01),
                  boss_fill(bx, by, P.BOSS_END_Z, -P.SKIN + 0.01)]
    for (bx, by) in P.TOP_BOSSES:
        feats += [cyl_z(bx, by, P.BOSS_D / 2, P.BOSS_END_Z, P.TOP_BOSS_TOP_Z),
                  boss_fill(bx, by, P.BOSS_END_Z, P.TOP_BOSS_TOP_Z)]
    # Locating pins for H1 and H2.
    for h in P.HOLES:
        hx, hy = h["centre"]
        r = P.PIN_D / 2
        feats += [cyl_z(hx, hy, r, P.PIN_TIP_Z + P.PIN_CHAMFER, -P.SKIN + 0.01),
                  cone_z(hx, hy, r - P.PIN_CHAMFER, r, P.PIN_TIP_Z, P.PIN_TIP_Z + P.PIN_CHAMFER)]
    shell = union(shell, *feats)
    # Insert holes, with a 0.3 lead-in at the mouth.
    holes = []
    for (bx, by) in P.BOSSES:
        z_bot = P.BOSS_END_Z + P.INSERT_HOLE_DEPTH
        holes += [cyl_z(bx, by, P.INSERT_HOLE_D / 2, P.BOSS_END_Z - 0.1, z_bot),
                  cone_z(bx, by, P.INSERT_HOLE_D / 2 + 0.4, P.INSERT_HOLE_D / 2, P.BOSS_END_Z - 0.1, P.BOSS_END_Z + 0.3)]
    shell = cut(shell, *holes)

    # Wheel opening, flange recess and key notch.
    wx, wy = P.WC
    tools = [cyl_z(wx, wy, P.DISC_R + P.DISC_GAP, -1.5, 1.0),
             cyl_z(wx, wy, P.RECESS_R, -1.5, -P.SKIN + P.FLANGE_T),
             key_tab(P.DISC_GAP, -1.5, -P.SKIN + P.FLANGE_T)]
    # Reliefs for the USB-C shell legs on the touch side.
    tools += leg_reliefs()
    # USB-C: opening through the wall plus the overmold pocket.
    uz0, uz1 = P.USB_OPEN_Z[1], P.USB_OPEN_Z[0]
    tools.append(rrect_xz(0, (uz0 + uz1) / 2, P.USB_OPEN_W, uz1 - uz0, P.USB_OPEN_R, -53, -49.9))
    ztop = 3.0   # corner rounds of the tool sit above the part
    tools.append(rrect_xz(0, (P.USB_POCKET_ZBOT + ztop) / 2, P.USB_POCKET_W, ztop - P.USB_POCKET_ZBOT,
                          P.USB_POCKET_R, -53, -P.Y_OUT + P.USB_POCKET_DEPTH))
    # microSD: slot, outer lead-in chamfer and finger scallop.
    sd_xc = (P.SD_X0 + P.SD_X1) / 2
    sd_floor = -P.Y_OUT + P.SD_SCALLOP_DEPTH
    tools.append(box(sd_xc - P.SD_SLOT_W / 2, sd_xc + P.SD_SLOT_W / 2, -53, -49.9,
                     P.SD_ZC - P.SD_SLOT_H / 2, P.SD_ZC + P.SD_SLOT_H / 2))
    ch = P.SD_CHAMFER
    hw, hh = P.SD_SLOT_W / 2, P.SD_SLOT_H / 2
    # Lead-in that starts inside the scallop, so no ledge is left. In Z it is
    # 45 deg; in X it grows less, so it stays inside the scallop's ends.
    ex, ez = P.SD_LEAD_EXT_X, P.SD_LEAD_EXT_Z
    tools.append(frustum_y(sd_xc, P.SD_ZC, 2 * (hw + ch + ex), 2 * (hh + ch + ez), 2 * hw, 2 * hh,
                           sd_floor - ez, sd_floor + ch))
    a = P.SD_SCALLOP_R - P.SD_SCALLOP_DEPTH
    sc = cq.Solid.makeCylinder(P.SD_SCALLOP_R, P.SD_SCALLOP_X[1] - P.SD_SCALLOP_X[0],
                               V(P.SD_SCALLOP_X[0], -P.Y_OUT - a, P.SD_ZC), V(1, 0, 0))
    tools.append(sc)
    # Side button: stem slot and outer pocket in the right wall.
    tools += button_wall_cuts()
    shell = cut(shell, *tools)
    # Standoffs on the inner face of the bottom wall (MECH-6).
    shell = union(shell, *bottom_standoffs())
    return one_solid(shell)


def bottom_standoffs():
    """Small blocks on the bottom wall's inner face, 0.1 from the board edge,
    from the skin to 0.4 past the board's component side. The back edge facing
    the board is chamfered so the board edge slides past it on the tilt-in."""
    out = []
    y_wall = -P.Y_IN - 0.05            # 0.05 into the wall
    y_face = P.BOARD_Y0 - P.STANDOFF_GAP
    z0, z1 = P.STANDOFF_Z1, -P.SKIN + 0.01
    c = P.STANDOFF_CHAMFER
    for x in P.STANDOFF_X:
        prof = [(x, y_wall, z0), (x, y_face - c, z0), (x, y_face, z0 + c), (x, y_face, z1), (x, y_wall, z1)]
        prof = [(px - P.STANDOFF_W / 2, py, pz) for px, py, pz in prof]
        out.append(prism(prof, (P.STANDOFF_W, 0, 0)))
    return out


def leg_reliefs():
    """One 0.5 deep relief per side over both USB-C shell legs, 0.5 larger than
    the pads on every side. One box per side leaves no thin ridge between the
    two legs, the disc recess and the disc flange."""
    out = []
    g = P.RELIEF_GROW
    for sgn in (-1, 1):
        its = [it for it in P.PROT["items"] if it["centre"][0] * sgn > 0]
        x0 = min(it["x"][0] for it in its) - g
        x1 = max(it["x"][1] for it in its) + g
        y0 = min(it["y"][0] for it in its) - g
        y1 = max(it["y"][1] for it in its) + g
        out.append(box(x0, x1, y0, y1, -1.5, -P.SKIN + P.RELIEF_DEPTH))
    return out


def frustum_y(xc, zc, w0, h0, w1, h1, y0, y1):
    """Rectangular frustum along Y: w0 x h0 at y0, w1 x h1 at y1."""
    a = [(xc - w0 / 2, y0, zc - h0 / 2), (xc + w0 / 2, y0, zc - h0 / 2),
         (xc + w0 / 2, y0, zc + h0 / 2), (xc - w0 / 2, y0, zc + h0 / 2)]
    b = [(xc - w1 / 2, y1, zc - h1 / 2), (xc + w1 / 2, y1, zc - h1 / 2),
         (xc + w1 / 2, y1, zc + h1 / 2), (xc - w1 / 2, y1, zc + h1 / 2)]
    wa = cq.Wire.makePolygon([V(*p) for p in a], close=True)
    wb = cq.Wire.makePolygon([V(*p) for p in b], close=True)
    return cq.Solid.makeLoft([wa, wb], True)


def key_tab(grow, z0, z1):
    """The disc's orientation key (grow > 0 gives the matching notch)."""
    wx, wy = P.WC
    a = math.radians(P.KEY_ANGLE)
    r0, r1 = P.KEY_R0 - 0.5, P.KEY_R1 + grow
    hw = P.KEY_W / 2 + grow
    ux, uy = math.cos(a), math.sin(a)
    vx, vy = -uy, ux
    pts = []
    for r, s in [(r0, -hw), (r1, -hw), (r1, hw), (r0, hw)]:
        pts.append((wx + r * ux + s * vx, wy + r * uy + s * vy, z0))
    return prism(pts, (0, 0, z1 - z0))


# ------------------------------------------------------------------ side button
def cap_geometry():
    """Return x positions of the cap (at rest, pulled out against the wall)."""
    x_wall_in = P.X_IN
    x_out = P.X_OUT + P.CAP_PROUD                  # 29.8
    head_in = x_out - P.CAP_HEAD_T                 # 29.1
    pocket_floor = head_in - P.CAP_STOP            # stop face in the wall
    flange_in = x_wall_in - P.CAP_FLANGE_T
    plunger = P.SB_TIP[0] + P.CAP_REST_GAP         # 27.58
    return dict(x_out=x_out, head_in=head_in, pocket_floor=pocket_floor,
                flange_in=flange_in, plunger=plunger, x_wall_in=x_wall_in)


def button_wall_cuts():
    g = cap_geometry()
    _, yc, zc = P.SB_TIP
    c = P.CAP_CLEAR
    hz = P.CAP_Z_H / 2 + c
    slot = box(P.X_IN - 0.2, P.X_OUT + 0.5, yc - P.CAP_STEM_W / 2 - c, yc + P.CAP_STEM_W / 2 + c, zc - hz, zc + hz)
    pocket = box(g["pocket_floor"], P.X_OUT + 0.5, yc - P.CAP_HEAD_W / 2 - 0.2, yc + P.CAP_HEAD_W / 2 + 0.2, zc - hz, zc + hz)
    return [slot, pocket]


def button_cap():
    """2.5D cap: one XY profile extruded over its z height, so it prints flat."""
    g = cap_geometry()
    _, yc, zc = P.SB_TIP
    z0, z1 = zc - P.CAP_Z_H / 2, zc + P.CAP_Z_H / 2
    head = box(g["head_in"], g["x_out"], yc - P.CAP_HEAD_W / 2, yc + P.CAP_HEAD_W / 2, z0, z1)
    head = cq.Workplane().add(head).edges("|Z and >X").fillet(0.6).val()
    stem = box(P.X_IN - 0.01, g["head_in"] + 0.01, yc - P.CAP_STEM_W / 2, yc + P.CAP_STEM_W / 2, z0, z1)
    # Flange: 0.6 thick ears beyond SW1's body and tabs, 0.4 thick in front of SW1,
    # so that the flange stays clear of SW1 at the travel stop.
    mid_in = P.X_IN - P.CAP_FLANGE_MID_T
    flange = box(mid_in, P.X_IN, yc - P.CAP_EAR_DY, yc + P.CAP_EAR_DY, z0, z1)
    ears = [box(g["flange_in"], P.X_IN, yc + P.CAP_EAR_DY, yc + P.CAP_FLANGE_W / 2, z0, z1),
            box(g["flange_in"], P.X_IN, yc - P.CAP_FLANGE_W / 2, yc - P.CAP_EAR_DY, z0, z1)]
    cap = union(head, stem, flange, *ears)
    cup = box(mid_in - 0.1, g["plunger"], yc - P.CAP_CUP_W / 2, yc + P.CAP_CUP_W / 2, z0 - 0.1, z1 + 0.1)
    cap = cut(cap, cup)
    return one_solid(cap)


# ------------------------------------------------------------------ wheel disc
def _poly(pts, z0, z1):
    return prism([(x, y, z0) for x, y in pts], (0, 0, z1 - z0))


def label_tools():
    """Debossed labels on the disc front: HOME, previous, next, play/pause."""
    wx, wy = P.WC
    r = P.LABEL_R
    z0, z1 = -P.DEBOSS, 0.5
    out = []
    # HOME at 12 o'clock
    # HOME, letters placed one by one with a 0.6 gap so the ridges between them print
    letters = []
    for ch_ in "HOME":
        t = (cq.Workplane("XY", origin=(0, 0, z0))
             .text(ch_, 3.2, z1 - z0, combine=False, halign="left", valign="center", fontPath=P_FONT()))
        letters.append(t.val())
    widths = [lt.BoundingBox().xmax - lt.BoundingBox().xmin for lt in letters]
    gap = 0.6
    x = -(sum(widths) + gap * (len(widths) - 1)) / 2
    for lt, w in zip(letters, widths):
        b = lt.BoundingBox()
        out.append(lt.translate(cq.Vector(wx + x - b.xmin, wy + r, 0)))
        x += w + gap
    s = 1.35  # half height of the icons; gaps between cavities are at least 0.45
    # previous at 9 o'clock: bar, then two left-pointing triangles
    cx, cy = wx - r, wy
    out.append(_poly([(cx - 2.6, cy - s), (cx - 2.0, cy - s), (cx - 2.0, cy + s), (cx - 2.6, cy + s)], z0, z1))
    for x0 in (-1.55, 0.7):
        out.append(_poly([(x0 + cx, cy), (x0 + cx + 1.8, cy - s), (x0 + cx + 1.8, cy + s)], z0, z1))
    # next at 3 o'clock: mirror of previous
    cx = wx + r
    out.append(_poly([(cx + 2.0, cy - s), (cx + 2.6, cy - s), (cx + 2.6, cy + s), (cx + 2.0, cy + s)], z0, z1))
    for x0 in (1.55, -0.7):
        out.append(_poly([(x0 + cx, cy), (x0 + cx - 1.8, cy + s), (x0 + cx - 1.8, cy - s)], z0, z1))
    # play/pause at 6 o'clock: triangle and two bars
    cx, cy = wx, wy - r
    out.append(_poly([(cx - 2.6, cy - s), (cx - 0.5, cy), (cx - 2.6, cy + s)], z0, z1))
    for x0 in (0.0, 1.25):
        out.append(_poly([(cx + x0, cy - s), (cx + x0 + 0.7, cy - s), (cx + x0 + 0.7, cy + s), (cx + x0, cy + s)], z0, z1))
    return out


def P_FONT():
    return FONT


def wheel_disc():
    wx, wy = P.WC
    disc = cyl_z(wx, wy, P.DISC_R, -P.SKIN, 0.0)
    flange = cyl_z(wx, wy, P.FLANGE_R, -P.SKIN, -P.SKIN + P.FLANGE_T)
    disc = union(disc, flange, key_tab(0.0, -P.SKIN, -P.SKIN + P.FLANGE_T))
    tools = leg_reliefs()
    tools += label_tools()
    disc = cut(disc, *tools)
    return one_solid(disc)


# ------------------------------------------------------------------ back plate
def back_plate():
    z0, z1 = -P.T, P.SPLIT_Z
    wp = (cq.Workplane("XY", origin=(0, 0, z0)).rect(2 * P.X_OUT, 2 * P.Y_OUT).extrude(z1 - z0)
          .edges("|Z").fillet(P.CORNER_R).faces("<Z").edges().fillet(P.EDGE_ROUND))
    plate = wp.val()
    adds = []
    # Screw pads under the bosses.
    inside = outline(z1 - 0.02, P.BOSS_END_Z + 0.01, inset=P.WALL + 0.1)
    for (bx, by) in P.BOSSES:
        adds.append(cyl_z(bx, by, P.BOSS_D / 2, z1 - 0.01, P.BOSS_END_Z).intersect(inside))
    # Registration lip inside the walls, broken at the bosses.
    o = P.WALL + P.LIP_GAP
    lip = outline(z1 - 0.01, z1 + P.LIP_H, inset=o).cut(outline(z1 - 0.5, z1 + P.LIP_H + 0.5, inset=o + P.LIP_W))
    for (bx, by) in P.BOSSES:
        # square cuts, so the lip ends are flat, not feathered
        sx, sy = (1 if bx > 0 else -1), (1 if by > 0 else -1)
        xa, xb = sorted([bx - sx * 3.3, sx * 40])
        ya, yb = sorted([by - sy * 3.3, sy * 60])
        lip = lip.cut(box(xa, xb, ya, yb, z1 - 1, z1 + 2))
    adds.append(lip)
    # Press posts on PP1 to PP4.
    for pp in P.PADS:
        px, py = pp["centre"]
        adds += [cyl_z(px, py, P.POST_BASE_D / 2, z1 - 0.01, P.POST_CONE_Z),
                 cone_z(px, py, P.POST_BASE_D / 2, P.POST_TIP_D / 2, P.POST_CONE_Z, P.POST_NECK_Z),
                 cyl_z(px, py, P.POST_TIP_D / 2, P.POST_NECK_Z, P.POST_TIP_Z)]
    # Battery ribs: two side ribs for a 40 wide pack and two low ribs that keep
    # the pack out of the cable bay below y -4.0. No top rib: the lip stops a
    # pack up to 53 long (diagram, November 21: a 52 pack hit the old top rib).
    bw, bl, _ = P.BAT_404050
    gx = bw / 2 + P.RIB_GAP
    yb0 = P.BAT_POCKET_Y0
    yb1 = yb0 + bl
    zr = z1 + P.RIB_H
    adds += [box(-gx - P.RIB_W, -gx, yb0 + 5, yb1 - 6, z1 - 0.01, zr),
             box(gx, gx + P.RIB_W, yb0 + 5, yb1 - 6, z1 - 0.01, zr),
             box(-16, -6, yb0 - P.RIB_GAP - P.RIB_W, yb0 - P.RIB_GAP, z1 - 0.01, zr),
             box(6, 16, yb0 - P.RIB_GAP - P.RIB_W, yb0 - P.RIB_GAP, z1 - 0.01, zr)]
    # Charge LED light tube: 2.3 base, 1.9 neck beside J1 and J3, chamfered tip (MECH-2).
    ly = P.LED["centre"][1]
    rn, c = P.LED_NECK_OD / 2, P.LED_TIP_CHAMFER
    adds += [cyl_z(P.LED_X, ly, P.LED_TUBE_OD / 2, z1 - 0.01, P.LED_NECK_Z),
             cyl_z(P.LED_X, ly, rn, P.LED_NECK_Z - 0.01, P.LED_TUBE_TOP - c),
             cone_z(P.LED_X, ly, rn, rn - c, P.LED_TUBE_TOP - c, P.LED_TUBE_TOP)]
    plate = union(plate, *adds)
    tools = []
    # Screw counterbores and clearance holes.
    for (bx, by) in P.BOSSES:
        tools += [cyl_z(bx, by, P.CBORE_D / 2, z0 - 1, z0 + P.CBORE_DEPTH),
                  cyl_z(bx, by, P.SCREW_HOLE_D / 2, z0 - 1, P.BOSS_END_Z + 1)]
    # Buzzer grille: three slots, 0.8 x 3.4.
    bxc, byc = P.BZ["centre"]
    for dx in (-1.6, 0.0, 1.6):
        tools.append(rrect_xy(bxc + dx, byc, 0.8, 3.4, 0.39, z0 - 1, z1 + 1))
    # LED light hole through the plate and the tube.
    tools.append(cyl_z(P.LED_X, ly, P.LED_HOLE_D / 2, z0 - 1, P.LED_TUBE_TOP + 1))
    # Shallow round seat for the optional motor.
    mx, my = P.MOTOR_C
    tools.append(cyl_z(mx, my, P.MOTOR_POCKET_D / 2, z1 - P.MOTOR_POCKET_DEPTH, z1 + 0.01))
    # Shallow channel for the first layer of the FPC tail.
    tools.append(box(-13.6, 19.4, P.J2_YC - P.TAIL_CHANNEL_W / 2, P.J2_YC + P.TAIL_CHANNEL_W / 2,
                     z1 - P.TAIL_CHANNEL_DEPTH, z1 + 0.01))
    plate = cut(plate, *tools)
    return one_solid(plate)
