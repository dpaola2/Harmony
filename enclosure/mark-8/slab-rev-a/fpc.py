"""Screen FPC route (SPEC 3.1) as swept solids, with its length budget.

The flat FPC is measured from the vendor STEP. The route is built from its
centre lines:

* YZ plane (wide section and leg): exit at the screen edge, bend down in the
  single area, the stiff wide section runs straight on a slant under the board,
  a second bend lays the leg on the back plate, a service loop takes up the
  extra length, and a 0.3 step drops the leg into the tail channel.
* XZ plane (tail): the first layer runs +X in the back plate channel, folds
  180 degrees about a line parallel to Y, runs back -X, rises in an S-curve
  through the ramp zone and enters J2 flat at the entry height.

Both centre lines are solved so that their lengths equal the real FPC.
"""
import math

import cadquery as cq

import params as P
from geom import Path2D, prism, union

V = cq.Vector


def measure_flat(screen):
    """Flat FPC numbers from the vendor STEP (device coordinates)."""
    f = screen["FPC"]
    bb = f.BoundingBox()

    def inside(x, y):
        return f.isInside(V(x, y, -1.515), 1e-4)

    # leg right edge, at a y in the middle of the leg
    y_leg = -30.0
    x = -13.0
    while inside(x + 0.01, y_leg):
        x += 0.01
    leg_x1 = x
    # wide section right edge just below the screen
    x = 0.0
    while inside(x + 0.01, -9.0):
        x += 0.01
    wide_x1 = x
    # wide section bottom (wide-to-leg transition) at x = 0
    y = -8.0
    while inside(0.0, y - 0.01):
        y -= 0.01
    wide_y1 = y
    # extension beside the FPC part (x beyond wide_x1)
    ext = []
    for i in range(0, 130):
        yy = -8.0 - i * 0.1
        if inside(wide_x1 + 1.5, yy):
            ext.append(yy)
    st = screen["FPC stiffener"].BoundingBox()
    part = screen["FPC part"].BoundingBox()
    return {
        "exit_y": P.SCR_Y0,
        "mid_z": (bb.zmin + bb.zmax) / 2,
        "x0": bb.xmin,
        "tip_x": bb.xmax,
        "tail_y0": bb.ymin,
        "tail_y1": bb.ymin + P.FPC_TAIL_W,
        "tail_yc": bb.ymin + P.FPC_TAIL_W / 2,
        "leg_x0": bb.xmin,
        "leg_x1": leg_x1,
        "leg_xc": (bb.xmin + leg_x1) / 2,
        "wide_x1": wide_x1,
        "wide_y1": wide_y1,
        "ext_y": (max(ext), min(ext)) if ext else None,
        "ext_x1": part.xmax + 0.2,
        "stiffener_len": st.xmax - st.xmin,
        "part": (part.xmin, part.xmax, part.ymin, part.ymax, part.zmin, part.zmax),
    }


def dive_path(flat, alpha, loop_y0=-23.5, drop_y0=-36.45, R1=1.0, R2=1.0, RL=1.5, RD=3.0, stiff_end_s=11.0):
    """YZ centre line of the wide section and leg. Returns (path, info)."""
    y0, z0 = flat["exit_y"], flat["mid_z"]
    z_plate = P.SPLIT_Z + P.FPC_GAP + P.FPC_T / 2          # -8.18
    drop = z0 - z_plate
    # slant angle phi: bend 1 (R1), straight to s = stiff_end_s, bend 2 (R2)
    lo, hi = math.radians(5), math.radians(80)
    for _ in range(60):
        phi = (lo + hi) / 2
        L = stiff_end_s - R1 * phi
        d = (R1 + R2) * (1 - math.cos(phi)) + L * math.sin(phi)
        if d > drop:
            hi = phi
        else:
            lo = phi
    L = stiff_end_s - R1 * phi
    p = Path2D(y0, z0, math.pi)
    p.arc(R1, phi).line(L).arc(R2, -phi)
    y_after = p.u
    p.line(p.u - loop_y0)
    p.arc(RL, -alpha).arc(RL, 2 * alpha).arc(RL, -alpha)
    p.line(p.u - drop_y0)
    beta = math.acos(1 - P.TAIL_CHANNEL_DEPTH / (2 * RD))
    p.arc(RD, beta).arc(RD, -beta)
    p.line(p.u - P.J2_YC)
    info = {
        "phi_deg": math.degrees(phi),
        "R1": R1, "R2": R2, "slant_len": L,
        "y_on_plate": y_after,
        "loop_R": RL, "loop_alpha_deg": math.degrees(alpha),
        "loop_span": 4 * RL * math.sin(alpha),
        "loop_height": 2 * RL * (1 - math.cos(alpha)),
        "loop_excess": 4 * RL * (alpha - math.sin(alpha)),
        "loop_y": (loop_y0, loop_y0 - 4 * RL * math.sin(alpha)),
        "z_plate_mid": z_plate,
    }
    return p, info


def tail_path(flat, x_fs, Rs=1.5, theta=math.radians(60)):
    z_low = P.SPLIT_Z - P.TAIL_CHANNEL_DEPTH + P.FPC_GAP + P.FPC_T / 2   # -8.48
    r_m = P.FOLD_RI + P.FPC_T / 2
    z_up = z_low + 2 * r_m
    rise = P.J2_ZC - z_up
    Ls = (rise - 2 * Rs * (1 - math.cos(theta))) / math.sin(theta)
    D = 2 * Rs * math.sin(theta) + Ls * math.cos(theta)
    x_tip = P.J2_XC - P.FPC_INSERT
    x_m = x_tip + flat["stiffener_len"] + 0.2
    x_r = x_m + D
    p = Path2D(flat["leg_xc"], z_low, 0.0)
    p.line(x_fs - flat["leg_xc"]).arc(r_m, math.pi)
    p.line(x_fs - x_r).arc(Rs, -theta).line(Ls).arc(Rs, theta)
    p.line(p.u - x_tip)
    info = {"z_low": z_low, "z_up": z_up, "r_m": r_m, "x_tip": x_tip, "x_m": x_m, "x_r": x_r,
            "S_span": D, "S_len": 2 * Rs * theta + Ls, "Rs": Rs, "theta_deg": math.degrees(theta)}
    return p, info


def solve(flat):
    s_tail = flat["exit_y"] - flat["tail_yc"]      # flat centre-line length in Y
    x_len = flat["tip_x"] - flat["leg_xc"]          # flat centre-line length in X
    # Y: solve the loop angle
    lo, hi = 0.01, math.radians(150)
    for _ in range(80):
        a = (lo + hi) / 2
        p, info = dive_path(flat, a)
        if p.length() > s_tail:
            hi = a
        else:
            lo = a
    alpha = (lo + hi) / 2
    pyz, iyz = dive_path(flat, alpha)
    # without a loop, where would the tail land?
    p0, _ = dive_path(flat, 1e-6)
    y_no_loop = P.J2_YC - (s_tail - p0.length())
    # X: solve the fold position
    lo, hi = 0.0, 27.0
    for _ in range(80):
        x_fs = (lo + hi) / 2
        p, info = tail_path(flat, x_fs)
        if p.length() > x_len:
            hi = x_fs
        else:
            lo = x_fs
    x_fs = (lo + hi) / 2
    pxz, ixz = tail_path(flat, x_fs)
    r_m = ixz["r_m"]
    report = {
        "flat_centre_line_y": s_tail,
        "flat_centre_line_x": x_len,
        "flat_centre_line_total": s_tail + x_len,
        "routed_centre_line_y": pyz.length(),
        "routed_centre_line_x": pxz.length(),
        "routed_centre_line_total": pyz.length() + pxz.length(),
        "tail_y_without_loop": y_no_loop,
        "y_slack": iyz["loop_excess"],
        "fold_start_x": x_fs,
        "fold_apex_x_mid": x_fs + r_m,
        "fold_apex_x_outer": x_fs + r_m + P.FPC_T / 2,
        "fold_from_tip_along_fpc": flat["tip_x"] - (x_fs + math.pi * r_m / 2),
        "x_slack": 0.0,
        "dive": iyz,
        "tail": ixz,
        "flat": {k: v for k, v in flat.items() if k != "part"},
    }
    return pyz, pxz, report


def build(screen):
    """Return (dict of named FPC solids, report)."""
    flat = measure_flat(screen)
    pyz, pxz, rep = solve(flat)
    x0, x1 = flat["leg_x0"], flat["leg_x1"]
    t = P.FPC_T

    # Leg (full YZ path) over the leg width, extended 2.4 past the tail centre line.
    pyz_ext = Path2D(*pyz.start)
    pyz_ext.segs = list(pyz.segs)
    pyz_ext.u, pyz_ext.v, pyz_ext.h = pyz.u, pyz.v, pyz.h
    pyz_ext.line(P.FPC_TAIL_W / 2)
    poly = pyz_ext.thick(t)
    leg = prism([(x0, u, v) for u, v in poly], (x1 - x0, 0, 0))

    # Wide section: the YZ path from the exit to the wide-to-leg transition.
    s_wide = flat["exit_y"] - flat["wide_y1"]
    pw = Path2D(*pyz.start)
    acc = 0.0
    for sgm in pyz.segs:
        ln = sgm[4] if sgm[0] == "L" else abs(sgm[4] * sgm[5])
        if acc + ln <= s_wide:
            pw.segs.append(sgm)
            acc += ln
            continue
        rest = s_wide - acc
        if sgm[0] == "L":
            pw.u, pw.v, pw.h = sgm[1], sgm[2], sgm[3]
            pw.line(rest)
        else:
            pw.u, pw.v, pw.h = sgm[1], sgm[2], sgm[3]
            pw.arc(sgm[4], math.copysign(rest / sgm[4], sgm[5]))
        break
    poly = pw.thick(t)
    wide = prism([(x0, u, v) for u, v in poly], (flat["wide_x1"] - x0, 0, 0))

    # Extension beside the FPC part and the part itself, on the straight slant.
    phi = math.radians(rep["dive"]["phi_deg"])
    R1 = rep["dive"]["R1"]
    # point and direction on the slant at arc length s (s >= R1*phi)
    yb1 = flat["exit_y"] - R1 * math.sin(phi)
    zb1 = flat["mid_z"] - R1 * (1 - math.cos(phi))
    du, dv = -math.cos(phi), -math.sin(phi)      # along the path
    nu, nv = -math.sin(phi), math.cos(phi)       # normal, toward the flat +Z side

    def on_slant(s, n):
        ds = s - R1 * phi
        return (yb1 + du * ds + nu * n, zb1 + dv * ds + nv * n)

    solids = {"FPC leg and wide section": union(leg, wide)}
    if flat["ext_y"]:
        sa = flat["exit_y"] - flat["ext_y"][0]
        sb = flat["exit_y"] - flat["ext_y"][1]
        q = [on_slant(sa, -t / 2), on_slant(sb, -t / 2), on_slant(sb, t / 2), on_slant(sa, t / 2)]
        ext = prism([(flat["wide_x1"] - 0.05, u, v) for u, v in q], (flat["ext_x1"] - flat["wide_x1"] + 0.05, 0, 0))
        solids["FPC leg and wide section"] = union(solids["FPC leg and wide section"], ext)
    px0, px1, py0, py1, pz0, pz1 = flat["part"]
    # the part body sits from y -11.2 to its bbox bottom (STEP outline); offsets from the FPC mid plane
    n0, n1 = pz0 - flat["mid_z"], pz1 - flat["mid_z"]
    sa, sb = flat["exit_y"] - (-11.2), flat["exit_y"] - py0
    q = [on_slant(sa, n0), on_slant(sb, n0), on_slant(sb, n1), on_slant(sa, n1)]
    solids["FPC part"] = prism([(px0, u, v) for u, v in q], (px1 - px0, 0, 0))

    # Tail: XZ path over the tail width, starting at the leg's left edge.
    pt = Path2D(x0, pxz.start[1], 0.0)
    pt.segs = [("L", x0, pxz.start[1], 0.0, pxz.segs[0][4] + (flat["leg_xc"] - x0))] + list(pxz.segs[1:])
    pt.u, pt.v, pt.h = pxz.u, pxz.v, pxz.h
    poly = pt.thick(t)
    ya, yb = P.J2_YC - P.FPC_TAIL_W / 2, P.J2_YC + P.FPC_TAIL_W / 2
    tail = prism([(u, ya, v) for u, v in poly], (0, yb - ya, 0))
    solids["FPC tail"] = tail
    rep["paths"] = {
        "yz": [(round(u, 3), round(v, 3)) for u, v, _ in pyz.sample(0.25)],
        "xz": [(round(u, 3), round(v, 3)) for u, v, _ in pxz.sample(0.25)],
    }
    return solids, rep
