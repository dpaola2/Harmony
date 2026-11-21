"""Stack sections: along the long axis at x = 0, and across at y = 20.
Every number printed comes from measurements.json, clearances.json (ydl) or a
probe of the solids made here."""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import common as C  # noqa: E402
import drawing as D  # noqa: E402
import scene  # noqa: E402

f2 = D.fmt


def long_section(m, y):
    S = scene.solids()
    st = m["stack"]
    yd = y["nominal"]
    pk = yd["bbox"]
    X = 0.0
    fig = D.new(10, 15.6)
    D.title(fig, "Stack section along the long axis (x = 0)",
            "Cut through the USB-C receptacle, the wheel disc, the FPC tail, the screen and the planned YDL 403450 pack on 0.5 foam. "
            "Front face up. True scale in each window; the overview shows where the windows are. All values in mm, measured on the STEP solids.")
    # overview
    ax0 = D.panel(fig, [0.04, 0.855, 0.92, 0.07], (-53.5, 53.5), (-10.5, 1.0))
    scene.draw_section(ax0, S, "x", X, (-60, 60, -12, 2), lw=0.3)
    wins = [("A", -52.6, -24.0), ("B", -14.5, 7.5), ("C", 35.5, 52.6)]
    for nm, a, b in wins:
        D.rect(ax0, a, -10.2, b, 0.7, ec=D.ACC, lw=0.9, z=12)
        ax0.text((a + b) / 2, 0.9, nm, color=D.ACC, fontsize=9, ha="center", va="bottom", fontweight="bold")
    ax0.text(-53.5, -10.6, "USB-C end (y -51.75)", fontsize=7.5, color=D.MUTED, va="top")
    ax0.text(53.5, -10.6, "top end (y 51.75)", fontsize=7.5, color=D.MUTED, va="top", ha="right")

    sc = 0.0262   # figure height fraction per mm at this width (10 in wide, 15.6 tall)
    # ---------------- window A
    a0, a1 = -52.6, -24.0
    ax = D.panel(fig, [0.05, 0.60, 0.80, 0.23], (a0, a1), (-11.2, 2.6), title="A  USB-C end: wall, J1, board, disc, FPC tail, back plate")
    scene.draw_section(ax, S, "x", X, (a0, a1, -12, 2))
    u = m["usb"]
    # total thickness
    zin, zback = st["back_plate"][1], st["back_plate"][0]
    D.dim(ax, (a1 - 1.0, 0.0), (a1 - 1.0, zback), f"{st['total_thickness']:.2f} total", off=0.3, orient="v")
    # skin and disc
    D.dim(ax, (-48.0, 0.0), (-48.0, -1.0), f"skin {st['skin_t']:.2f}", off=-3.2, orient="v", tside=-1)
    D.dim(ax, (-30.0, 0.0), (-30.0, -1.0), f"disc {st['disc_t']:.2f}", off=0.35, orient="v")
    D.dim(ax, (-27.0, -1.0), (-27.0, -1.8), f"board {st['pcb_t']:.2f}", off=0.35, orient="v")
    # recess and thin wall
    D.dim(ax, (u["outer_face_y"], -6.76), (u["recess_floor_y"], -6.76), f"recess {u['recess_depth']:.2f}", off=-0.9, orient="h", tside=-1)
    D.gap(ax, u["recess_floor_y"], u["wall_inner_face_y"], -6.0, f"thin wall {m['walls']['bottom_wall_behind_port_recess']:.2f}",
          orient="h", tx=-49.2, ty=-6.9, ha="left")
    # opening and J1
    D.dim(ax, (-51.2, u["opening_z"][1]), (-51.2, u["opening_z"][0]), f"opening {u['opening_h']:.2f}", off=-0.8, orient="v", tside=-1)
    D.zline(ax, u["j1_shell_z"][1], -50.4, -46.4)
    D.zline(ax, u["j1_shell_z"][0], -50.4, -46.4)
    ax.text(-46.3, (u["j1_shell_z"][0] + u["j1_shell_z"][1]) / 2, f"J1 shell z {u['j1_shell_z'][1]:.2f} to {u['j1_shell_z'][0]:.2f}\n"
            f"gap to opening {u['gap_top']:.2f} top, {u['gap_bottom']:.2f} bottom", fontsize=D.FS_DIM, color=D.ACC, va="center",
            bbox=dict(boxstyle="square,pad=0.1", fc="white", ec="none", alpha=0.9), zorder=12)
    D.gap(ax, u["j1_face_y"], u["wall_inner_face_y"], -2.2, f"J1 face {u['j1_into_wall']:.2f} into the wall",
          orient="h", tx=-49.0, ty=1.6, ha="left")
    # FPC tail and channel
    f = m["fpc"]
    lay = f["layers_at_x10"]
    D.label(ax, (-39.0, (lay[0][0] + lay[0][1]) / 2), f"FPC tail in the {f['channel_depth']:.2f} channel, z {lay[0][1]:.2f} to {lay[0][0]:.2f}", (-44.0, -10.6), fs=D.FS_DIM, color=D.ACC)
    D.label(ax, (-38.5, -2.2), "FPC tail end, flat into J2", (-33.5, 0.9), fs=D.FS_DIM)
    D.dim(ax, (-33.0, zin), (-33.0, zback), f"back plate {st['back_plate_t']:.2f}", off=0.35, orient="v")
    D.dim(ax, (-29.0, st["pcb"][0]), (-29.0, zin), f"part space {st['component_space']:.2f}", off=0.0, orient="v", ext=False, tpos=0.62, toff=0.1)
    D.label(ax, (-45.65, -0.3), f"skin over the flange recess {m['walls']['skin_over_disc_recess']:.2f} (thin)", (-43.0, 2.0), fs=D.FS_DIM, color=D.ACC)
    D.label(ax, (-27.4, -2.2), "U6", (-28.5, -4.5), fs=D.FS_LABEL)
    D.label(ax, (-36.0, -0.5), "wheel disc", (-38.0, -4.7), fs=D.FS_LABEL)
    D.label(ax, (-44.0, -1.4), "board", (-41.5, -5.6), fs=D.FS_LABEL)
    D.label(ax, (-51.0, -7.5), "front shell", (-52.4, -10.6), fs=D.FS_LABEL)

    # ---------------- window B
    b0, b1 = -14.5, 7.5
    ax = D.panel(fig, [0.05, 0.36, 0.80, 0.23], (b0, b1 + 6.0), (-11.2, 2.6), title="B  Board top edge, FPC dive, screen, foam and pack")
    scene.draw_section(ax, S, "x", X, (b0, b1, -12, 2))
    ax.plot([b1, b1], [-10.0, 1.0], color="#bbbbbb", lw=0.6, ls=":")
    D.dim(ax, (3.0, -1.0), (3.0, -3.15), f"screen {st['screen_t']:.2f}", off=4.6, orient="v")
    D.dim(ax, (3.0, -3.15), (3.0, -3.65), f"foam {st['foam_t']:.2f}", off=4.6, orient="v", tpos=0.5, toff=0.0)
    D.dim(ax, (3.0, pk[5]), (3.0, pk[4]), f"pack {pk[5] - pk[4]:.2f}", off=4.6, orient="v")
    zin, zback = st["back_plate"][1], st["back_plate"][0]
    D.dim(ax, (3.0, pk[4]), (3.0, zin), f"room {yd['to_back_plate_face']:.2f}", off=4.6, orient="v")
    D.dim(ax, (3.0, zin), (3.0, zback), f"plate {st['back_plate_t']:.2f}", off=4.6, orient="v")
    D.dim(ax, (b0 + 0.6, 0.0), (b0 + 0.6, zback), f"{st['total_thickness']:.2f}", off=-0.3, orient="v", tside=-1)
    sb = C.bb(S["screen body"])
    D.dim(ax, (-10.0, -1.4), (sb[2], -1.4), f"{m['edges']['board_top_to_screen']:.2f}", off=1.6, orient="h")
    D.dim(ax, (sb[2], pk[5]), (pk[2], pk[5]), f"pack edge {pk[2] - sb[2]:.2f} from screen edge", off=-7.0, orient="h", tside=-1, tpos=1.6)
    D.label(ax, (-12.0, -1.4), "board top edge y -10.0", (-14.0, 2.2), fs=D.FS_DIM)
    D.label(ax, (-11.0, -5.0), "FPC wide section on its slant", (-14.3, -10.6), fs=D.FS_LABEL)
    D.label(ax, (0.0, -2.0), "screen (body, glass, polarizers)", (-6.5, 2.2), fs=D.FS_LABEL)
    D.label(ax, (5.0, -5.6), "YDL 403450 (planned)", (6.0, -10.6), fs=D.FS_LABEL)
    D.label(ax, (-3.0, -0.4), "skin, window edge", (-8.0, 1.2), fs=D.FS_LABEL)

    # ---------------- window C
    c0, c1 = 35.5, 52.6
    ax = D.panel(fig, [0.05, 0.12, 0.80, 0.23], (c0 - 4.0, c1 + 1.0), (-11.2, 2.6), title="C  Top end: screen pocket, top wall, pack far end, back plate lip")
    scene.draw_section(ax, S, "x", X, (c0, c1, -12, 2))
    ax.plot([c0, c0], [-10.0, 1.0], color="#bbbbbb", lw=0.6, ls=":")
    sm = m["screen"]
    D.gap(ax, sb[3], sm["pocket_top_y"], -2.0, f"pocket {sm['top_gap']:.2f}", orient="h", tx=44.0, ty=1.7, ha="right")
    wy = m["extra"]["interior_y"][1]
    D.dim(ax, (wy, -5.0), (m["stack"]["outline_y"] / 2, -5.0), f"wall {m['walls']['top_wall']:.2f}", off=0.0, orient="h", ext=False, tside=1, toff=0.15)
    bp_ov = yd.get("back_plate_overlap_mm3") or 0.0
    if bp_ov > 0.001:
        ax.text(35.0, -10.6, f"FAIL: the pack overlaps the back plate by {bp_ov:.2f} mm3", fontsize=D.FS_DIM, fontweight="bold", va="center")
    if yd.get("lip_inner_y") is not None:
        zl = (yd["bbox"][4] + zin) / 2
        D.dim(ax, (pk[3], zl), (yd["lip_inner_y"], zl), f"{yd['far_edge_to_lip_y']:.2f} to lip", off=-1.6, orient="h", tside=-1, tpos=0.5)
    D.dim(ax, (40.0, pk[4]), (40.0, zin), f"{yd['to_back_plate_face']:.2f}", off=-6.0, orient="v", tside=-1)
    D.label(ax, (sb[3] - 0.3, -2.0), f"screen top edge y {sb[3]:.2f}", (40.5, 2.2), fs=D.FS_DIM)
    D.label(ax, (pk[3] - 0.5, -5.6), f"pack far end y {pk[3]:.2f}", (41.0, -3.9), fs=D.FS_DIM)
    D.label(ax, (37.0, -3.4), "foam ends y 44.0", (33.0, -1.9), fs=D.FS_DIM)

    # stack table
    t = m["stack"]
    rows = [
        ("Front face (skin, disc)", "0.00"),
        ("Skin back = screen front = board touch side", f"{t['skin'][0]:.2f}"),
        ("Board component side", f"{t['pcb'][0]:.2f}"),
        ("Screen back", f"{t['screen'][0]:.2f}"),
        ("Foam back (0.5 foam)", f"{t['foam'][0]:.2f}"),
        ("YDL pack back (on the foam)", f"{pk[4]:.2f}"),
        (f"Lowest board part ({t['lowest_board_part']})", f"{t['lowest_board_part_z']:.2f}"),
        ("Back plate inner face = shell rim", f"{t['back_plate'][1]:.2f}"),
        ("Back face", f"{t['back_plate'][0]:.2f}"),
    ]
    D.note(fig, 0.05, 0.105, "Z levels (device z, mm)", fs=9.5, color=D.INK, fontweight="bold")
    for i, (a, b) in enumerate(rows):
        fig.text(0.05, 0.088 - i * 0.0098, a, fontsize=8.5, color=D.INK, va="top")
        fig.text(0.47, 0.088 - i * 0.0098, b, fontsize=8.5, color=D.ACC, va="top", ha="right")
    w = m["walls"]
    thin = [("Skin over the USB-C leg reliefs", w["skin_over_usb_leg_relief"]), ("Top boss roof over the insert hole", w["top_boss_roof"]),
            ("LED light tube neck wall", w["led_tube_neck_wall"]), ("Skin over the disc flange recess", w["skin_over_disc_recess"]),
            ("Bottom wall behind the port recess", w["bottom_wall_behind_port_recess"]), ("Bottom wall at the card scallop", w["bottom_wall_at_card_scallop"]),
            ("Back plate under a screw head", w["plate_under_screw_head"]), ("Disc flange", w["disc_flange"])]
    thin.sort(key=lambda r: r[1])
    D.note(fig, 0.53, 0.105, "Thinnest walls (measured)", fs=9.5, color=D.INK, fontweight="bold")
    for i, (a, b) in enumerate(thin):
        fig.text(0.53, 0.088 - i * 0.0098, a, fontsize=8.5, color=D.INK, va="top")
        fig.text(0.95, 0.088 - i * 0.0098, f"{b:.2f}", fontsize=8.5, color=D.ACC, va="top", ha="right")
    return D.save(fig, "stack-section", dpi=170)


def cross_section(m, y):
    S = scene.solids()
    yd = y["nominal"]
    pk = yd["bbox"]
    Y = 20.0
    fig = D.new(10, 8.2)
    D.title(fig, "Stack section across (y = 20)",
            "Cut through the screen, the foam, the planned YDL 403450 pack, the side ribs, the back plate lip and both side walls. "
            "Front face up. Values in mm, measured on the STEP solids.")
    ax = D.panel(fig, [0.04, 0.55, 0.92, 0.33], (-31.0, 31.0), (-11.5, 2.0), title="Full width")
    scene.draw_section(ax, S, "y", Y, (-40, 40, -12, 2))
    D.dim(ax, (-29.3, 0.0), (29.3, 0.0), f"{m['stack']['outline_x']:.2f}", off=0.8, orient="h")
    D.dim(ax, (pk[0], pk[4]), (pk[1], pk[4]), f"pack {pk[1] - pk[0]:.2f}", off=-2.2, orient="h", tside=-1)
    ribs = m["battery"]["side_ribs_x"]
    rtz = m["battery"]["rib_top_z"] or -7.2
    D.dim(ax, (ribs[0][1], rtz), (ribs[1][0], rtz), f"side ribs {ribs[1][0] - ribs[0][1]:.2f} apart", off=-3.6, orient="h", tside=-1)
    sm = m["screen"]
    D.label(ax, (0.0, -2.0), "screen", (-6.0, 1.7), fs=D.FS_LABEL)
    D.label(ax, (10.0, -3.4), "foam 35 wide", (6.0, 1.7), fs=D.FS_LABEL)
    D.label(ax, (8.0, -5.6), "YDL 403450 (planned), on the foam", (12.0, -10.9), fs=D.FS_LABEL)

    # zoom on the right wall
    ax = D.panel(fig, [0.04, 0.06, 0.60, 0.44], (16.0, 30.6), (-10.2, 0.8), title="Right wall, enlarged")
    scene.draw_section(ax, S, "y", Y, (14, 31, -11, 1))
    w = m["walls"]
    D.dim(ax, (m["extra"]["interior_x"][1], -5.0), (m["stack"]["outline_x"] / 2, -5.0), f"wall {w['side_wall']:.2f}", off=0.0, orient="h", ext=False, toff=0.12)
    D.gap(ax, sm["screen_bbox"][1], sm["pocket_x_at_y20"][1], -2.1, f"screen to pocket {sm['side_gap_right']:.2f}", orient="h",
          tx=22.5, ty=0.35, ha="center")
    lip = w["lip_x"]
    zin = m["stack"]["back_plate"][1]
    D.gap(ax, lip[1], lip[1] + w["lip_gap_to_wall"], zin + 0.4, f"lip gap {w['lip_gap_to_wall']:.2f}", orient="h", tx=29.0, ty=zin - 1.5, ha="left")
    D.dim(ax, (lip[0], zin), (lip[1], zin), f"lip {w['lip_w']:.2f} x {w['lip_h']:.2f}", off=-1.4, orient="h", tside=-1, tpos=-1.2)
    D.dim(ax, (pk[1], -6.0), (ribs[1][0], -6.0), f"{ribs[1][0] - pk[1]:.2f}", off=0.0, orient="h", ext=False, toff=0.1)
    D.dim(ax, (20.0, -1.0), (20.0, -3.15), f"{m['stack']['screen_t']:.2f}", off=-3.0, orient="v", tside=-1)
    D.dim(ax, (17.4, pk[5]), (17.4, pk[4]), f"{pk[5] - pk[4]:.2f}", off=-1.0, orient="v", tside=-1)
    D.label(ax, (ribs[1][0] + 0.2, zin + 0.5), f"side rib {m['battery']['rib_h']:.2f} tall", (22.5, -9.6), fs=D.FS_DIM)
    D.note(fig, 0.67, 0.47,
           "The YDL pack is 34 wide, so it has "
           f"{ribs[1][0] - pk[1]:.2f} to each side rib.\n\n"
           f"Pack back face z {pk[4]:.2f}; back plate inner face z {zin:.2f}: {yd['to_back_plate_face']:.2f} room for swelling "
           f"({yd['to_back_plate_face_with_thick_screen_0.1']:.2f} with a screen 0.10 thicker).\n\n"
           f"Screen pocket: {sm['side_gap_left']:.2f} left, {sm['side_gap_right']:.2f} right, {sm['top_gap']:.2f} top.",
           width=42, fs=8.8)
    return D.save(fig, "stack-section-across", dpi=170)


if __name__ == "__main__":
    m = json.load(open(os.path.join(HERE, "measurements.json")))
    y = json.load(open(os.path.join(HERE, "clearances.json")))["ydl_403450"]
    print(long_section(m, y))
    print(cross_section(m, y))
