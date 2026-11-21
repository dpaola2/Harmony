"""Dimensioned close-ups. Sections are exact cuts of the STEP solids; numbers
come from measurements.json and clearances.json (ydl)."""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import cadquery as cq  # noqa: E402

import common as C  # noqa: E402
import drawing as D  # noqa: E402
import scene  # noqa: E402

FS = D.FS_DIM


def head(fig, t, sub):
    D.title(fig, t, sub)


# ------------------------------------------------------------------ USB-C
def usb(m):
    S = scene.solids()
    u = m["usb"]
    fig = D.new(10, 11.2)
    head(fig, "Close-up: USB-C opening and J1",
         "Top: the bottom wall cut at y -50.5 (between the port recess and the inner face), seen from outside; J1 shows through the opening. "
         "Bottom: cut along the plug axis at x = 0, seen from the right (+X) side. Values in mm.")
    ax = D.panel(fig, [0.03, 0.50, 0.94, 0.42], (-11.0, 11.0), (-8.2, 1.2), title="a  Wall at y -50.5, seen from outside")
    j1 = C.section(S["board J1"], "y", -50.2)
    D.fill_faces(ax, j1, D.FILL["metal"], z=2)
    scene.draw_section(ax, S, "y", -50.5, (-12, 12, -10, 2), only={"front shell"})
    rx_, rb_ = u["recess_x"], u["recess_bottom_z"]
    ax.plot([rx_[0], rx_[0], rx_[1], rx_[1]], [0.0, rb_, rb_, 0.0], color=D.MUTED, lw=0.9, ls=(0, (3, 2)), zorder=6)
    ax.text(-10.0, -3.0, "card slot", fontsize=8, color=D.MUTED, ha="left", va="center")
    ox, oz = u["opening_x"], u["opening_z"]
    jx, jz = u["j1_shell_x"], u["j1_shell_z"]
    D.dim(ax, (ox[0], oz[1]), (ox[1], oz[1]), f"opening {u['opening_w']:.2f}", off=1.15, orient="h")
    D.dim(ax, (ox[1], oz[1]), (ox[1], oz[0]), f"opening {u['opening_h']:.2f}", off=2.6, orient="v", tpos=0.75)
    D.dim(ax, (jx[0], jz[0]), (jx[1], jz[0]), f"J1 shell {u['j1_shell_w']:.2f}", off=-0.75, orient="h", tside=-1)
    D.dim(ax, (jx[0], jz[1]), (jx[0], jz[0]), f"J1 {u['j1_shell_h']:.2f}", off=-2.6, orient="v", tside=-1, tpos=0.75)
    D.gap(ax, jz[1], oz[1], -1.5, f"top {u['gap_top']:.2f}", orient="v", tx=-3.8, ty=0.7, ha="center", arm=0.5)
    D.gap(ax, oz[0], jz[0], 1.5, f"bottom {u['gap_bottom']:.2f}", orient="v", tx=3.6, ty=-6.6, ha="center", arm=0.5)
    D.gap(ax, ox[0], jx[0], -3.5, f"{u['gap_left']:.2f}", orient="h", tx=-6.6, ty=-2.4, ha="center", arm=0.6)
    D.gap(ax, jx[1], ox[1], -3.5, f"{u['gap_right']:.2f}", orient="h", tx=6.6, ty=-2.4, ha="center", arm=0.6)
    D.dim(ax, (u["recess_x"][0], u["recess_bottom_z"]), (u["recess_x"][1], u["recess_bottom_z"]),
          f"port recess {u['recess_w']:.2f} wide, from z {u['recess_bottom_z']:.2f} up through the front edge", off=-0.75, orient="h", tside=-1)
    D.zline(ax, u["j1_centre_z"], -10.8, -8.6)
    ax.text(-10.8, u["j1_centre_z"] + 0.15, f"J1 centre z {u['j1_centre_z']:.2f}", fontsize=FS, color=D.ACC, va="bottom")
    D.zline(ax, u["opening_centre_z"], 8.6, 10.8)
    ax.text(10.8, u["opening_centre_z"] + 0.15, f"opening centre z {u['opening_centre_z']:.2f}", fontsize=FS, color=D.ACC, va="bottom", ha="right")
    ax.text(0, 1.0, "dashed: the port recess in front of the wall (y -51.75 to -50.85)", fontsize=8, color=D.MUTED, ha="center", va="top")

    ax = D.panel(fig, [0.03, 0.04, 0.94, 0.40], (-52.4, -42.2), (-9.8, 0.6), title="b  Cut at x = 0, seen from the right (+X) side")
    scene.draw_section(ax, S, "x", 0.0, (-60, -40, -11, 2))
    D.gap(ax, u["j1_face_y"], u["wall_inner_face_y"], -2.05, f"J1 face {u['j1_into_wall']:.2f} into the wall", orient="h", tx=-49.4, ty=-2.6, ha="left", arm=0.5)
    D.dim(ax, (u["outer_face_y"], -6.76), (u["recess_floor_y"], -6.76), f"recess {u['recess_depth']:.2f}", off=-1.0, orient="h", tside=-1)
    D.dim(ax, (u["recess_floor_y"], -6.0), (u["j1_face_y"], -6.0), f"{u['overmold_reach_to_face']:.2f}", off=-2.6, orient="h", tside=-1)
    ax.text(-50.5, -9.3, "a plug overmold can reach the recess floor", fontsize=8, color=D.MUTED, ha="left", va="center")
    D.label(ax, (-50.5, -6.0), f"wall {m['walls']['bottom_wall_behind_port_recess']:.2f} (thin)", (-48.6, -7.4), fs=FS, color=D.ACC)
    D.zline(ax, u["opening_z"][1], -52.3, -51.0)
    D.zline(ax, u["opening_z"][0], -52.3, -51.0)
    D.dim(ax, (-52.0, u["opening_z"][1]), (-52.0, u["opening_z"][0]), f"{u['opening_h']:.2f}", off=0.0, orient="v", ext=False, toff=0.1)
    D.label(ax, (-46.0, -3.5), "J1 (receptacle shell, tongue)", (-45.0, -6.2), fs=D.FS_LABEL)
    D.label(ax, (-46.0, -1.4), "board", (-44.4, 0.3), fs=D.FS_LABEL)
    D.label(ax, (-43.5, -0.5), "wheel disc", (-43.4, 0.35), fs=D.FS_LABEL)
    D.label(ax, (-50.0, -0.5), "skin", (-51.8, 0.35), fs=D.FS_LABEL)
    D.label(ax, (-46.0, -8.9), "back plate", (-44.6, -9.6), fs=D.FS_LABEL)
    return D.save(fig, "closeup-usb-c")


# ------------------------------------------------------------------ microSD
def microsd(m):
    S = scene.solids()
    sd = m["microsd"]
    card_k = "drawing estimate (z -2.38 to -3.38)"
    cd = sd["cards"][card_k]
    cs = sd["cards"]["STEP: top face on the J3 cover"]
    fig = D.new(10, 10.6)
    head(fig, "Close-up: microSD slot and J3, with a 1.0 card",
         "The card is drawn at the drawing's card plane (z -2.38 to -3.38, ASSEMBLY review MECH-5). The dashed card is the plane the J3 STEP model gives "
         "(top face on the J3 cover, z -2.64 to -3.64). Values in mm.")
    ax = D.panel(fig, [0.04, 0.37, 0.92, 0.53], (-55.6, -44.0), (-6.4, 1.4), title="a  Cut along the card centre line (x -13.7), seen from the right (+X) side")
    scene.draw_section(ax, S, "x", -13.7, (-60, -40, -10, 2))
    yo = m["stack"]["outline_y"] / -2.0
    j3y = sd["j3_entry_y"]
    D.rect(ax, yo - 1.0, cd["card_z"][0], j3y, cd["card_z"][1], fc=D.FILL["card"], ec=D.INK, lw=0.9, z=7)
    D.rect(ax, yo - 1.0, cs["card_z"][0], j3y, cs["card_z"][1], fc="none", ec=D.MUTED, lw=0.9, z=7, ls=(0, (3, 2)))
    ax.text(yo - 0.9, cd["card_z"][1] + 0.08, "1.0 card", fontsize=D.FS_LABEL, va="bottom")
    sz = sd["slot_z"]
    D.zline(ax, sz[1], -51.0, -49.95)
    D.zline(ax, sz[0], -51.0, -49.95)
    D.dim(ax, (-50.4, sz[1]), (-50.4, sz[0]), f"slot {sd['slot_h']:.2f}\n(z {sz[1]:.2f} to {sz[0]:.2f})", off=-3.0, orient="v", tside=-1)
    D.gap(ax, cd["card_z"][1], sz[1], -50.6, f"{cd['margin_board_side']:.2f}", orient="v", tx=-50.0, ty=0.6, ha="left")
    D.gap(ax, sz[0], cd["card_z"][0], -50.6, f"{cd['margin_back_side']:.2f}", orient="v", tx=-50.0, ty=-5.6, ha="left")
    D.zline(ax, sd["j3_cover_underside_z"], -49.1, -47.0, f"J3 cover underside {sd['j3_cover_underside_z']:.2f}")
    D.label(ax, (j3y + 0.05, cd["card_z"][1] - 0.05),
            f"at the drawing plane the card top is {cd['card_z'][1] - sd['j3_cover_underside_z']:.2f}\nabove the J3 model's cover underside",
            (-48.4, 0.9), fs=FS, color=D.ACC)
    D.dim(ax, (yo, -4.6), (sd["scallop_floor_y_at_x-20"], -4.6), f"scallop {sd['scallop_depth']:.2f}", off=-1.0, orient="h", tside=-1)
    D.dim(ax, (sd["scallop_floor_y_at_x-20"], -4.6), (-50.15, -4.6), f"wall {sd['wall_behind_scallop']:.2f}", off=-1.0, orient="h", tside=-1)
    D.label(ax, (-47.5, -3.6), "J3", (-46.6, -5.4), fs=D.FS_LABEL)
    ax = D.panel(fig, [0.04, 0.09, 0.92, 0.24], (-21.5, -5.9), (-5.0, -0.6), title="b  Wall cut at y -50.3, seen from outside, card at the drawing plane")
    scene.draw_section(ax, S, "y", -50.3, (-25, -3, -6, 0), only={"front shell"})
    D.rect(ax, -13.7 - 5.5, cd["card_z"][0], -13.7 + 5.5, cd["card_z"][1], fc=D.FILL["card"], ec=D.INK, lw=0.9, z=7)
    sx = sd["slot_x"]
    D.dim(ax, (sx[0], sz[1]), (sx[1], sz[1]), f"slot {sd['slot_w']:.2f}", off=0.55, orient="h")
    D.dim(ax, (-19.2, cd["card_z"][0]), (-8.2, cd["card_z"][0]), "card 11.00", off=-0.75, orient="h", tside=-1)
    D.gap(ax, sx[0], -19.2, -2.88, f"{cd['margin_sides'][0]:.2f}", orient="h", tx=-20.9, ty=-1.4, ha="center")
    D.gap(ax, -8.2, sx[1], -2.88, f"{cd['margin_sides'][1]:.2f}", orient="h", tx=-6.6, ty=-1.4, ha="center")
    pz = sd["slot_z_at_0.2_layers"]
    D.note(fig, 0.04, 0.06, f"Printed face down at 0.2 layers the slot faces fall near z {pz[1]:.1f} and {pz[0]:.1f}: "
           f"margins {cd['printed_margin_board_side']:.2f} and {cd['printed_margin_back_side']:.2f} at the drawing plane, "
           f"{cs['printed_margin_board_side']:.2f} and {cs['printed_margin_back_side']:.2f} at the J3 model plane.", width=125)
    return D.save(fig, "closeup-microsd")


# ------------------------------------------------------------------ LED light tube
def led(m):
    S = scene.solids()
    lt = m["led"]
    fig = D.new(10, 9.0)
    head(fig, "Close-up: charge LED light tube between J3 and J1",
         "Cut across the device at y -48.0 through the tube and LED1, seen from the bottom end. Values in mm.")
    ax = D.panel(fig, [0.05, 0.06, 0.90, 0.84], (-10.6, -1.0), (-10.0, 0.6))
    scene.draw_section(ax, S, "y", -48.0, (-12, 0, -11, 1))
    bz = lt["by_z"]
    neck, base = bz["-4.0"], bz["-6.5"]
    D.dim(ax, (neck["outer"][0], -3.4), (neck["outer"][1], -3.4), f"neck {neck['od']:.2f}", off=0.0, orient="h", ext=False, toff=0.1)
    D.dim(ax, (base["outer"][0], -7.0), (base["outer"][1], -7.0), f"base {base['od']:.2f}", off=0.0, orient="h", ext=False, toff=0.1)
    D.dim(ax, (base["hole"][0], -8.9), (base["hole"][1], -8.9), f"hole {base['hole_d']:.2f}", off=0.0, orient="h", ext=False, toff=-0.35)
    D.zline(ax, lt["tip_z"], -7.4, -4.0)
    D.zline(ax, lt["led1_top_z"], -7.4, -4.0)
    D.dim(ax, (-4.6, lt["led1_top_z"]), (-4.6, lt["tip_z"]), "", off=0.0, orient="v", ext=False)
    ax.text(-1.9, (lt["led1_top_z"] + lt["tip_z"]) / 2, f"tip to LED top {abs(lt['tip_to_led_top_z']):.2f}\n(tip z {lt['tip_z']:.2f}, LED top {lt['led1_top_z']:.2f})",
            fontsize=FS, color=D.ACC, va="center", ha="left", bbox=dict(boxstyle="square,pad=0.1", fc="white", ec="none"), zorder=12)
    ax.plot([-4.6, -1.95], [(lt["led1_top_z"] + lt["tip_z"]) / 2] * 2, color=D.ACC, lw=0.45, zorder=11)
    D.zline(ax, lt["base_top_z"], -7.2, -3.6)
    D.zline(ax, lt["j1_bottom_z"], -4.6, -1.5)
    D.dim(ax, (-2.0, lt["j1_bottom_z"]), (-2.0, lt["base_top_z"]), f"{lt['base_top_to_j1_bottom']:.2f}", off=0.0, orient="v", ext=False, toff=0.1)
    ax.text(-1.85, lt["base_top_z"] - 0.4, f"neck starts z {lt['base_top_z']:.2f}\nJ1 bottom z {lt['j1_bottom_z']:.2f}", fontsize=FS, color=D.ACC, va="top")
    D.gap(ax, lt["to_J1_at"][0], lt["to_J1_at"][0] + lt["to_J1"], -4.4, f"to J1 {lt['to_J1']:.2f}", orient="h", tx=-2.6, ty=-4.0, ha="left")
    D.gap(ax, lt["to_J3_at"][0] - lt["to_J3"], lt["to_J3_at"][0], -3.6, f"to J3 {lt['to_J3']:.2f}", orient="h", tx=-9.6, ty=-4.3, ha="center")
    D.dim(ax, (lt["j3_j1_gap_x"][0], -1.9), (lt["j3_j1_gap_x"][1], -1.9), f"J3 to J1 {lt['j3_j1_gap_x'][2]:.2f}", off=1.9, orient="h")
    D.label(ax, (lt["led1_centre_x"], -2.3), f"LED1, tube {lt['hole_offset_from_led_x']:+.2f} off its centre", (-9.8, -0.3), fs=FS)
    D.label(ax, (-7.4, -3.0), "J3", (-10.3, -5.6), fs=D.FS_LABEL)
    D.label(ax, (-1.6, -5.0), "J1", (-2.3, -6.4), fs=D.FS_LABEL)
    D.label(ax, (-9.5, -1.4), "board", (-10.4, -2.3), fs=D.FS_LABEL)
    D.label(ax, (-9.5, -0.5), "skin", (-10.4, 0.3), fs=D.FS_LABEL)
    D.label(ax, (-9.5, -8.9), "back plate", (-10.3, -9.8), fs=D.FS_LABEL)
    D.label(ax, (-5.83 - 0.8, -7.8), f"wall {m['walls']['led_tube_base_wall']:.2f}", (-9.0, -7.6), fs=FS, color=D.ACC)
    D.label(ax, (-5.83 + 0.72, -4.8), f"wall {m['walls']['led_tube_neck_wall']:.2f} (thin)", (-3.9, -7.6), fs=FS, color=D.ACC)
    return D.save(fig, "closeup-led-tube")


# ------------------------------------------------------------------ side button
def button(m):
    S = scene.solids()
    b = m["button"]
    fig = D.new(10, 7.4)
    head(fig, "Close-up: side button cap and SW1",
         "Plan cut at z -3.5 (the actuator axis), seen from the front. Left: at rest. Right: pressed to the stop. The cap is the darker printed part. Values in mm.")
    win = (23.0, 31.2, -20.6, -10.4)
    ax = D.panel(fig, [0.02, 0.04, 0.47, 0.84], win[:2], win[2:], title="a  At rest")
    CAPC = {"button cap": "#d2c9b4"}
    scene.draw_section(ax, S, "z", -3.5, (20, 33, -22, -9), only={"front shell", "button cap", "board SW1"}, fills=CAPC)
    D.gap(ax, b["sw1_tip_x"], b["plunger_x"], -15.6, f"rest gap {b['rest_gap']:.2f}", orient="h", tx=24.0, ty=-11.0, ha="left", arm=0.5)
    D.dim(ax, (b["pocket_floor_x"], -18.4), (b["head_inner_x"], -18.4), f"travel {b['travel_to_stop']:.2f}", off=-1.6, orient="h", tside=-1, tpos=1.6)
    D.dim(ax, (29.3, -13.0), (b["head_outer_x"], -13.0), f"proud {b['head_proud']:.2f}", off=1.9, orient="h", tpos=0.2)
    D.dim(ax, (28.4, -15.6 - b["slot_w"] / 2), (28.4, -15.6 + b["slot_w"] / 2), f"slot\n{b['slot_w']:.2f}", off=2.1, orient="v", toff=0.08)
    D.dim(ax, (b["ear_x"], -19.0), (27.7, -19.0), f"ear {27.7 - b['ear_x']:.2f}", off=-0.9, orient="h", tside=-1, tpos=-0.6)
    D.dim(ax, (b["flange_mid_x"], -17.2), (27.7, -17.2), f"{27.7 - b['flange_mid_x']:.2f}", off=0.0, orient="h", ext=False, toff=0.05)
    D.label(ax, (25.0, -16.5), "SW1", (23.4, -19.6), fs=D.FS_LABEL)
    D.label(ax, (29.4, -17.6), "cap head", (29.7, -19.3), fs=D.FS_LABEL)
    D.label(ax, (28.8, -20.3), "right wall", (29.6, -20.4), fs=D.FS_LABEL)
    ax2 = D.panel(fig, [0.51, 0.04, 0.47, 0.84], win[:2], win[2:], title="b  Pressed to the stop")
    T = b["travel_to_stop"]
    sh = {"front shell": S["front shell"], "board SW1": S["board SW1"], "button cap": S["button cap"].translate(cq.Vector(-T, 0, 0))}
    scene.draw_section(ax2, sh, "z", -3.5, (20, 33, -22, -9), fills=CAPC)
    D.zline(ax2, -15.6, 0, 0)
    ax2.plot([b["sw1_tip_x"], b["sw1_tip_x"]], [-17.0, -14.2], color=D.ACC, lw=0.6, ls=(0, (3, 2)), zorder=12)
    D.gap(ax2, b["plunger_x"] - T, b["sw1_tip_x"], -15.6, f"plunger {b['past_tip_at_stop']:.2f} past the rest tip;\n"
          f"switch travel 0.20, so {b['over_travel_vs_0.2']:.2f} over-travel", orient="h", tx=23.2, ty=-11.2, ha="left", arm=0.5)
    D.gap(ax2, b["sw1_body_front_x"], b["flange_to_sw1_at_stop_at"][0], b["flange_to_sw1_at_stop_at"][1],
          f"flange to SW1 {b['flange_to_sw1_at_stop']:.2f}", orient="h", tx=24.6, ty=-12.6, ha="left", arm=0.5)
    D.label(ax2, (b["head_inner_x"] - T, -18.6), "head on the pocket floor", (29.0, -20.3), fs=D.FS_LABEL, ha="left")
    return D.save(fig, "closeup-side-button")


# ------------------------------------------------------------------ FPC fold and J2
def fpc(m):
    S = scene.solids()
    f = m["fpc"]
    fig = D.new(10, 8.2)
    head(fig, "Close-up: screen FPC tail, fold and J2",
         "Cut across the device at y -39.0 (the J2 slot centre line), seen from the bottom end. The tail's first layer lies in the back plate channel, "
         "folds 180 degrees and rises to J2. Values in mm.")
    ax = D.panel(fig, [0.03, 0.47, 0.94, 0.42], (-8.0, 24.0), (-10.2, 0.8), title="a  Whole tail")
    scene.draw_section(ax, S, "y", -39.0, (-10, 26, -11, 1))
    ko = m["antenna"]["keepout"]["x"][0]
    ax.plot([ko, ko], [-10.0, 0.5], color=D.ACC, lw=0.8, ls=(0, (4, 2)))
    ax.text(ko - 0.15, 0.3, f"antenna keep-out from x {ko:.1f}", fontsize=FS, color=D.ACC, va="top", ha="right")
    D.dim(ax, (f["fold_outer_x"], -7.7), (ko, -7.7), f"{ko - f['fold_outer_x']:.2f}", off=0.0, orient="h", ext=False, toff=0.1)
    D.label(ax, (f["fold_outer_x"], -8.2), f"fold outside x {f['fold_outer_x']:.2f}", (19.8, -10.0), fs=FS, color=D.ACC)
    D.label(ax, (-2.24, -2.3), f"J2 mouth x {f['j2_mouth_x']:.2f}", (-7.6, 0.5), fs=FS, color=D.ACC)
    D.label(ax, (5.0, -8.5), "first layer in the 0.30 channel", (1.0, -10.0), fs=D.FS_LABEL)
    D.label(ax, (10.0, -7.9), "folded layer", (9.0, -5.6), fs=D.FS_LABEL)
    D.label(ax, (3.0, -5.0), "S-curve rise", (3.6, -3.6), fs=D.FS_LABEL)
    # zoom: J2 entry
    ax2 = D.panel(fig, [0.03, 0.04, 0.45, 0.38], (-5.6, 0.6), (-3.6, -1.2), title="b  Tail end in J2")
    scene.draw_section(ax2, S, "y", -39.0, (-8, 2, -4, 0))
    D.dim(ax2, (f["tail_tip_x"], -2.7), (f["j2_mouth_x"], -2.7), f"inserted {f['insertion']:.2f}", off=-0.55, orient="h", tside=-1)
    g = f["j2_slot_gap_z"]
    D.zline(ax2, g[0], -2.2, -0.5, f"slot z {g[0]:.2f}")
    D.zline(ax2, g[1], -2.2, -0.5, f"slot z {g[1]:.2f}")
    tz = f["tail_z_at_mouth"][-1]
    ax2.text(-5.4, -1.35, f"FPC z {tz[0]:.2f} to {tz[1]:.2f} at the mouth;\noverlaps the J2 model {f['tail_j2_overlap_mm3']:.3f} mm3",
             fontsize=FS, color=D.ACC, va="top")
    D.label(ax2, (-1.5, -1.8), f"FPC to board {f['tail_to_pcb']:.2f}", (-0.9, -3.4), fs=FS, color=D.ACC)
    # zoom: fold
    la0 = f["layers_at_x10"]
    ax3 = D.panel(fig, [0.52, 0.04, 0.45, 0.38], (16.0, 19.6), (la0[0][0] - 0.42, la0[-1][1] + 0.38), title="c  Fold")
    scene.draw_section(ax3, S, "y", -39.0, (14, 22, -11, -6))
    la = f["layers_at_x10"]
    D.zline(ax3, la[0][0], 16.1, 16.9, f"{la[0][0]:.2f}")
    D.zline(ax3, la[0][1], 16.1, 16.9, f"{la[0][1]:.2f}")
    D.zline(ax3, la[1][0], 16.1, 16.9, f"{la[1][0]:.2f}")
    D.zline(ax3, la[1][1], 16.1, 16.9, f"{la[1][1]:.2f}")
    D.label(ax3, (f["fold_outer_x"] - 0.3, -8.18), f"inner radius {f['fold_inner_r']:.2f}", (18.6, -7.55), fs=FS, color=D.ACC)
    pf, cf = f["plate_outside_channel"][0][1], f["plate_in_channel"][0][1]
    D.dim(ax3, (17.8, pf), (17.8, cf), f"channel {f['channel_depth']:.2f}", off=0.0, orient="v", ext=False, toff=0.05)
    return D.save(fig, "closeup-fpc-j2")


# ------------------------------------------------------------------ screw boss
def boss(m):
    S = scene.solids()
    fig = D.new(10, 7.2)
    head(fig, "Close-up: screw boss, heat-set insert and M2 x 4 screw",
         "Cuts through the bottom left boss (y -47.15) and the top left boss (y 47.15). Values in mm.")
    for k, (tag, yb, rect) in enumerate((("bottom_left", -47.15, [0.02, 0.20, 0.47, 0.70]), ("top_left", 47.15, [0.51, 0.20, 0.47, 0.70]))):
        o = m["bosses"][tag]
        ax = D.panel(fig, rect, (-30.0, -19.4), (-10.0, 0.6), title=("a  Bottom left boss" if k == 0 else "b  Top left boss, under the screen"))
        scene.draw_section(ax, S, "y", yb, (-31, -18, -11, 1))
        bx = -24.7
        iz = o["insert_z"]
        D.dim(ax, (bx + 1.6, iz[0]), (bx + 1.6, iz[1]), f"insert {o['insert_len']:.2f}", off=0.5, orient="v")
        D.dim(ax, (bx - 1.5, o["boss_face_z"]), (bx - 1.5, o["hole_bottom_z"]), f"depth {o['hole_depth']:.2f}", off=-1.4, orient="v", tside=-1)
        D.dim(ax, (bx - 1.5, -5.0), (bx + 1.5, -5.0), "", off=0.0, orient="h", ext=False)
        ax.text(bx - 2.0, -5.5, f"hole {o['hole_d']:.2f}", fontsize=FS, color=D.ACC, ha="right", va="center", zorder=12,
                bbox=dict(boxstyle="square,pad=0.1", fc="white", ec="none"))
        D.dim(ax, (bx - 1.75, o["screw_head_z"][0]), (bx + 1.75, o["screw_head_z"][0]), f"head {o['screw_head_d']:.2f}", off=-0.4, orient="h", tside=-1)
        D.gap(ax, o["screw_z"][1], o["hole_bottom_z"], bx, f"tip to hole bottom {o['tip_to_hole_bottom']:.2f}", orient="v",
              tx=-29.6, ty=-2.6 if k == 0 else -0.6, ha="left", arm=0.5)
        D.dim(ax, (bx + 2.0, o["screw_head_z"][1]), (bx + 2.0, o["screw_z"][1]), f"screw {o['screw_len_under_head']:.2f}", off=1.6, orient="v")
        ax.text(-20.2, o["boss_face_z"] - 0.15, f"boss face\nz {o['boss_face_z']:.2f}", fontsize=FS, color=D.ACC, ha="right", va="top", zorder=12,
                bbox=dict(boxstyle="square,pad=0.1", fc="white", ec="none"))
        D.note(fig, rect[0] + 0.01, 0.17,
               f"Screw engagement {o['engagement']:.2f} (the full insert). Plastic under the head {o['plate_under_head_t']:.2f}. "
               f"Counterbore {o['counterbore_d']:.2f} x {o['counterbore_depth']:.2f}, clearance hole {o['clearance_hole_d']:.2f}. "
               f"Insert knurl {o['knurl_interference_radial']:.2f} into the hole wall per side. "
               f"An M2 x 5 would end {abs(o['m2x5_tip_to_hole_bottom']):.2f} past the hole bottom (it bottoms out).", width=58, color=D.INK)
        if tag == "top_left":
            D.gap(ax, o["boss_top_z"], o["boss_top_z"] + o["boss_top_to_screen_back"], -22.6,
                  f"to screen {o['boss_top_to_screen_back']:.2f}", orient="v", tx=-21.2, ty=-2.3, ha="left", arm=0.4)
            D.label(ax, (-23.6, (o["boss_top_z"] + o["hole_bottom_z"]) / 2), f"roof {o['roof']:.2f} (thin)", (-21.2, -3.4), fs=FS, color=D.ACC)
            D.label(ax, (-21.0, -2.0), "screen", (-20.4, 0.3), fs=D.FS_LABEL)
    return D.save(fig, "closeup-screw-boss")


# ------------------------------------------------------------------ board edges and frame tabs
def edges(m):
    S = scene.solids()
    e = m["edges"]
    fig = D.new(10, 12.6)
    head(fig, "Close-up: board edge to the walls, and the three frame tabs",
         "Plan cut at z -1.4 (mid board), seen from the front. Hatched: a 0.35 nub left on each mouse-bite tab. Values in mm.")
    ax = D.panel(fig, [0.03, 0.40, 0.94, 0.52], (-30.2, 30.2), (-52.4, -6.6), title="a  Board in the front shell")
    scene.draw_section(ax, S, "z", -1.4, (-31, 31, -53, -5), only={"front shell", "board PCB"})
    tabs = {t["edge"]: t for t in e["frame_tabs"]}
    nubs = {"left": (-27.55, -27.2, -17.9, -13.1), "top": (22.1, 26.1, -10.0, -9.65), "right": (27.2, 27.55, -45.4, -40.6)}
    for k, (x0, x1, y0, y1) in nubs.items():
        D.rect(ax, x0, y0, x1, y1, fc="white", ec=D.INK, lw=0.6, hatch="////", z=8)
    sg = e["side_gaps"][2]
    D.gap(ax, -27.7, -27.2, -30.0, f"{sg['left_gap']:.2f}", orient="h", tx=-24.0, ty=-29.0, ha="left")
    D.gap(ax, 27.2, 27.7, -30.0, f"{sg['right_gap']:.2f}", orient="h", tx=24.0, ty=-29.0, ha="right")
    for s in e["standoffs"]:
        D.gap(ax, s["face_y"], -49.6, s["x"], f"{s['gap_to_board_edge']:.2f}", orient="v", tx=s["x"], ty=-46.5, ha="center")
    bt = next(r for r in e["bottom_top_gaps"] if r["x"] == 0.0)
    D.gap(ax, -50.15, -49.6, 2.0, f"wall {bt['bottom_gap_at_z-1.4']:.2f}", orient="v", tx=6.0, ty=-46.5, ha="center")
    tp = next(r for r in e["bottom_top_gaps"] if r["x"] == -20.9)
    D.gap(ax, -10.0, -10.0 + tp["top_gap_at_z-1.4"], -20.9, f"lip {tp['top_gap_at_z-1.4']:.2f}", orient="v", tx=-17.0, ty=-12.5, ha="left")
    for n in e["notches"]:
        gap_ = n.get("gap")
        if gap_ is not None:
            ax.text(n["boss_x"] * 0.86, -44.3, f"notch {gap_:.2f}", fontsize=FS, color=D.ACC, ha="center")
    ax.text(-26.8, -15.5, "left tab", fontsize=FS, rotation=90, ha="left", va="center")
    ax.text(24.1, -9.2, "top tab", fontsize=FS, ha="center", va="bottom")
    ax.text(26.8, -43.0, "right tab", fontsize=FS, rotation=90, ha="right", va="center")
    ax.text(0.0, -25.0, "board 54.4 x 39.6", fontsize=D.FS_LABEL, ha="center")
    ax.text(0.0, -8.3, "screen lips and screen above (y > -9)", fontsize=8, color=D.MUTED, ha="center")
    # insets
    ins = [("left", (-28.6, -25.6, -18.9, -15.9), "b  Left tab (y -17.9 to -13.1)"),
           ("top", (21.2, 24.2, -11.0, -8.0), "c  Top tab (x 22.1 to 26.1)"),
           ("right", (25.6, 28.6, -47.2, -44.2), "d  Right tab, near the bottom right boss")]
    for i, (k, w, t_) in enumerate(ins):
        axi = D.panel(fig, [0.03 + i * 0.325, 0.04, 0.30, 0.30], w[:2], w[2:], title=t_, frame=True)
        scene.draw_section(axi, S, "z", -1.4, (w[0] - 1, w[1] + 1, w[2] - 1, w[3] + 1), only={"front shell", "board PCB"})
        x0, x1, y0, y1 = nubs[k]
        D.rect(axi, x0, y0, x1, y1, fc="white", ec=D.INK, lw=0.6, hatch="////", z=8)
        t = tabs[k]
        if k == "left":
            D.gap(axi, -27.7, -27.55, -17.0, f"nub {t['nub_0.35_to_shell']:.2f}", orient="h", tx=-26.0, ty=-18.4, ha="center", arm=0.35)
            D.gap(axi, -27.7, -27.2, -16.3, f"filed {t['filed_flush_to_shell']:.2f}", orient="h", tx=-26.2, ty=-16.3, ha="left", arm=0.35)
        elif k == "top":
            D.gap(axi, -9.65, -8.79, 22.6, f"nub {t['nub_0.35_to_shell']:.2f}", orient="v", tx=23.0, ty=-10.6, ha="left", arm=0.35)
            D.gap(axi, -10.0, -8.79, 21.6, f"filed {t['filed_flush_to_shell']:.2f}", orient="v", tx=22.4, ty=-8.3, ha="left", arm=0.35)
        else:
            D.gap(axi, 27.55, 27.7, -45.0, f"nub {t['nub_0.35_to_shell']:.2f}", orient="h", tx=26.4, ty=-44.6, ha="center", arm=0.35)
            nd = e["notches"][1]
            axi.text(25.7, -47.1, f"board corner to boss {t['filed_flush_to_shell']:.2f}", fontsize=FS, color=D.ACC, va="bottom")
    return D.save(fig, "closeup-board-edges-tabs")


# ------------------------------------------------------------------ antenna corner
def antenna(m):
    S = scene.solids()
    a = m["antenna"]
    f = m["fpc"]
    fw = m["fpc_wing"]
    fig = D.new(10, 10.4)
    head(fig, "Close-up: antenna corner",
         f"Plan view seen from the front, x 8 to 31, y -50 to -8. Board parts, walls and button cap cut at z -3.0; FPC tail at z {sum(m['fpc']['layers_at_x10'][0]) / 2:.2f} (first layer); "
         "FPC wide section and its small part at z -5.5; insert and screw at z -6.0. Values in mm.")
    ax = D.panel(fig, [0.02, 0.04, 0.64, 0.87], (8.0, 31.2), (-50.2, -8.0))
    scene.draw_section(ax, S, "z", -1.4, (5, 33, -52, -6), only={"board PCB"}, alpha=0.5)
    scene.draw_section(ax, S, "z", -3.0, (5, 33, -52, -6), only={n for n in S if n.startswith("board ") and n != "board PCB"} | {"front shell", "button cap"})
    scene.draw_section(ax, S, "z", sum(f["layers_at_x10"][0]) / 2, (5, 33, -52, -6), only={"FPC tail"})
    scene.draw_section(ax, S, "z", -5.5, (5, 33, -52, -6), only={"FPC leg and wide section", "FPC part"})
    scene.draw_section(ax, S, "z", -6.0, (5, 33, -52, -6), only={"insert 2", "screw 2"})
    wb = fw["routed_full_wing_bbox"]
    D.rect(ax, fw["model_wing_x_max"], wb[2], fw["flat_wing_x_max"], wb[3], fc="none", ec=D.INK, lw=0.8, z=9, hatch="////")
    kx, ky = a["keepout"]["x"], a["keepout"]["y"]
    D.rect(ax, kx[0], ky[0], kx[1], ky[1], fc="none", ec=D.ACC, lw=1.2, z=11)
    D.rect(ax, kx[0], ky[0], kx[1] + 5.0, ky[1], fc="none", ec=D.ACC, lw=0.7, z=11, ls=(0, (4, 2)))
    ar = a["antenna_region"]
    D.rect(ax, ar["x"][0], ar["y"][0], ar["x"][1], ar["y"][1], fc="none", ec=D.INK, lw=0.8, z=11, ls=(0, (1, 1.5)))
    ax.text(kx[0] + 0.2, -30.0, f"copper keep-out,\nall layers\nx {kx[0]} to {kx[1]}\ny {ky[0]} to {ky[1]}", fontsize=FS, color=D.ACC, va="center",
            bbox=dict(boxstyle="square,pad=0.1", fc="white", ec="none", alpha=0.85), zorder=12)
    ax.text(ar["x"][0] + 0.2, ar["y"][0] + 0.3, "antenna (U1 end)", fontsize=FS, color=D.INK, va="bottom", zorder=12)
    ax.text(28.0, -27.0, "plus 5 mm outside the wall", fontsize=8, color=D.ACC, rotation=90, ha="center", va="center")
    d = a["distances"]
    D.dim(ax, (f["fold_outer_x"], -41.8), (kx[0], -41.8), f"fold {kx[0] - f['fold_outer_x']:.2f}", off=0.0, orient="h", ext=False, toff=0.15)
    ax.plot([kx[0], kx[0]], [ky[0], -42.4], color=D.ACC, lw=0.45, ls=(0, (2, 2)))
    D.dim(ax, (24.7, d["screw 2"]["at"][1]), (24.7, ky[0]), f"screw head {d['screw 2']['to_keepout']:.2f}\ninsert {d['insert 2']['to_keepout']:.2f}",
          off=0.0, orient="v", ext=False, toff=0.2)
    D.dim(ax, (25.0, ky[1]), (25.0, -17.902), f"SW1 {d['board SW1']['to_keepout']:.2f}", off=-3.2, orient="v", tside=-1)
    D.dim(ax, (fw["flat_wing_x_max"], -14.0), (kx[0], -14.0), f"{fw['full_wing_to_keepout_x']:.2f}", off=0.0, orient="h", ext=False, toff=0.15)
    ax.plot([kx[0], kx[0]], [ky[1], -13.5], color=D.ACC, lw=0.45, ls=(0, (2, 2)))
    D.label(ax, ((fw["model_wing_x_max"] + fw["flat_wing_x_max"]) / 2, -11.0),
            f"hatched: FPC wing at the vendor width (x {fw['flat_wing_x_max']:.2f});\nthe case model stops at x {fw['model_wing_x_max']:.2f}", (8.4, -9.0), fs=FS, color=D.ACC)
    D.label(ax, (27.4, -18.6), "cap ears reach y -18.2 (plastic)", (20.5, -16.4), fs=FS, ha="right")
    D.label(ax, (28.5, -40.0), f"wall {m['walls']['side_wall']:.2f} (plastic)", (29.0, -47.8), fs=FS, ha="center")
    D.label(ax, (14.0, -28.0), "U1 module", (9.0, -26.0), fs=D.FS_LABEL)
    D.label(ax, (12.0, -39.0), "FPC tail (first layer)", (8.4, -44.6), fs=D.FS_LABEL)
    D.label(ax, (16.6, -12.4), "FPC small part", (8.4, -12.2), fs=D.FS_LABEL)
    D.label(ax, (24.6, -40.6), "pin H2", (19.4, -46.5), fs=D.FS_LABEL)
    D.label(ax, (24.7, -47.15), "insert and screw, bottom right", (9.0, -49.4), fs=D.FS_LABEL)
    D.note(fig, 0.68, 0.88,
           "Distances in plan from the copper keep-out (x 21.8 to 27.2, y -37.9 to -18.2):\n\n"
           f"FPC tail fold: {kx[0] - f['fold_outer_x']:.2f}\n"
           f"FPC wing, case model: {d['FPC leg and wide section']['to_keepout']:.2f}; at the vendor width: {fw['full_wing_to_keepout_x']:.2f} in x\n"
           f"Bottom right screw head: {d['screw 2']['to_keepout']:.2f} (to the antenna itself {d['screw 2']['to_antenna_region']:.2f})\n"
           f"Bottom right insert: {d['insert 2']['to_keepout']:.2f}\n"
           f"SW1 (board part, metal): {d['board SW1']['to_keepout']:.2f}\n"
           f"Battery, case model pack: {d['battery pack']['to_keepout']:.2f}\n"
           f"Motor: {d['motor']['to_keepout']:.2f}\n\n"
           "Plastic inside the keep-out in plan: the 1.0 skin, the 0.8 x 0.8 back plate lip (dashed) and the tips of the button cap ears. "
           "No case metal, boss or thickened wall is inside it.", width=40)
    lip = a["back_plate_lip_x_at_y-28"][0]
    ax.plot([lip[0], lip[0]], [-44.0, -12.0], color=D.MUTED, lw=0.7, ls=(0, (3, 2)))
    ax.plot([lip[1], lip[1]], [-44.0, -12.0], color=D.MUTED, lw=0.7, ls=(0, (3, 2)))
    D.label(ax, (lip[0], -37.0), f"back plate lip {lip[1] - lip[0]:.2f} wide", (20.8, -38.6), fs=FS, ha="right")
    return D.save(fig, "closeup-antenna-corner")


# ------------------------------------------------------------------ screen top corner (extra)
def screen_corner(m):
    S = scene.solids()
    s = m["screen"]
    c = s["top_corners"][1]
    overlap = (s.get("overlap_with_shell_mm3") or 0.0) > 0.001
    fig = D.new(10, 9.0)
    head(fig, "Close-up: screen top corner and the side wall" + (" (FAIL)" if overlap else ""),
         "Plan cut at z -2.0 through the screen pocket, top right corner, seen from the front. Dashed: the screen's outline "
         "(53.36 x 57.49, corner radius under 0.1)" + ("; dark: shell wall inside it" if overlap else "") +
         ". The top left corner is the mirror image. Values in mm.")
    ax = D.panel(fig, [0.04, 0.05, 0.92, 0.84], (21.4, 30.0), (44.8, 52.0))
    scene.draw_section(ax, S, "z", -2.0, (20, 31, 43, 53), only={"front shell"})
    sbb = C.bb(S["screen body"])
    ax.plot([sbb[1], sbb[1], 21.4], [44.8, sbb[3], sbb[3]], color=D.INK, lw=1.3, ls=(0, (5, 2)), zorder=11)
    cx, cy = c["corner"]
    u = (1 / math.sqrt(2), 1 / math.sqrt(2))
    if overlap:
        import cadquery as cq_
        outline = cq_.Solid.makeBox(sbb[1] - sbb[0], sbb[3] - sbb[2], 0.2, cq_.Vector(sbb[0], sbb[2], -2.1))
        v, com = C.common(S["front shell"], outline)
        if v:
            D.fill_faces(ax, C.section(com, "z", -2.0), "#444448", ec=D.INK, lw=0.6, z=10)
        d = c["wall_into_screen_on_diagonal"]
        ax.annotate("", xy=(cx, cy), xytext=(cx - u[0] * d, cy - u[1] * d),
                    arrowprops=dict(arrowstyle="<|-|>", color=D.ACC, lw=1.0, shrinkA=0, shrinkB=0, mutation_scale=8), zorder=12)
        D.label(ax, (cx - u[0] * d * 0.6, cy - u[1] * d * 0.6),
                f"wall reaches {d:.2f} into the screen corner (on the diagonal)\noverlap {s['overlap_with_shell_mm3']:.2f} mm3 in all",
                (21.6, 46.6), fs=FS, color=D.ACC)
    else:
        g = c.get("gap_to_wall_on_diagonal") or 0.0
        wt = c.get("wall_outside_corner_on_diagonal")
        p0 = (cx + u[0] * g, cy + u[1] * g)
        if g > 0:
            ax.annotate("", xy=(cx, cy), xytext=p0, arrowprops=dict(arrowstyle="<|-|>", color=D.ACC, lw=1.0, shrinkA=0, shrinkB=0,
                                                                     mutation_scale=7), zorder=12)
        if wt:
            p1 = (p0[0] + u[0] * wt, p0[1] + u[1] * wt)
            ax.annotate("", xy=p0, xytext=p1, arrowprops=dict(arrowstyle="<|-|>", color=D.ACC, lw=1.0, shrinkA=0, shrinkB=0,
                                                              mutation_scale=7), zorder=12)
            D.label(ax, ((p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2), f"wall left at the corner {wt:.2f} (on the diagonal)",
                    (21.6, 50.9), fs=FS, color=D.ACC)
        D.label(ax, (cx, cy), f"screen corner to the pocket: {c['corner_clearance']:.2f} (closest point)",
                (21.6, 46.6), fs=FS, color=D.ACC)
    D.gap(ax, s["screen_bbox"][1], s["pocket_x_at_y20"][1], 45.6, f"pocket side {s['side_gap_right']:.2f}", orient="h",
          tx=29.8, ty=45.3, ha="right", arm=0.4)
    D.gap(ax, s["screen_bbox"][3], s["pocket_top_y"], 22.4, f"pocket top {s['top_gap']:.2f}", orient="v", tx=22.6, ty=51.4, ha="left", arm=0.4)
    D.label(ax, (24.5, s["screen_bbox"][3]), "screen outline (dashed)", (22.0, 48.2), fs=D.FS_LABEL)
    D.label(ax, (28.4, 48.0), f"side wall (inner corner radius {m['extra']['inner_corner_r']:.2f})", (26.2, 44.95), fs=D.FS_LABEL)
    return D.save(fig, "closeup-screen-corner")


# ------------------------------------------------------------------ planned battery (extra)
def battery(m, y):
    S = scene.solids()
    yd = y["nominal"]
    pk = yd["bbox"]
    ld = y["lead"]
    fig = D.new(10, 12.4)
    head(fig, "Close-up: planned battery YDL 403450 in the case",
         f"Plan view, seen from the front. Pack 34 x 52 x 4.0 on the 0.5 foam, cable end toward J4, centred, near edge at y {yd['near_edge_y']:.2f}, "
         f"{yd['near_edge_from_screen_edge']:.2f} from the screen's lower edge (ASSEMBLY.md step 13 allows {y['pack']['window_from_screen_edge'][0]} to "
         f"{y['pack']['window_from_screen_edge'][1]}; dashed outlines). Back plate ribs from its cut at z {m['stack']['back_plate'][1] + 0.6:.2f}. Values in mm.")
    ax = D.panel(fig, [0.03, 0.07, 0.94, 0.83], (-30.5, 30.5), (-17.5, 52.4))
    scene.draw_section(ax, S, "z", -5.0, (-31, 31, -23, 53), only={"front shell"})
    scene.draw_section(ax, S, "z", m["stack"]["back_plate"][1] + 1.0, (-31, 31, -23, 53), only={"back plate"}, alpha=0.9)
    scene.draw_section(ax, S, "z", -1.4, (-31, 31, -23, 53), only={"board PCB"}, alpha=0.45)
    scene.draw_section(ax, S, "z", -4.0, (-31, 31, -23, 53), only={"board J4", "battery plug PHR-2"})
    scene.draw_section(ax, S, "z", -3.4, (-31, 31, -23, 53), only={"battery foam"}, alpha=0.7)
    D.rect(ax, pk[0], pk[2], pk[1], pk[3], fc=D.FILL["planned"], ec=D.INK, lw=1.0, z=6, alpha=0.75)
    w_lo, w_hi = y["pack"]["window_from_screen_edge"]
    for tag in (f"window_{w_lo}", f"window_{w_hi}"):
        wb = y[tag]["bbox"]
        D.rect(ax, wb[0] + 0.3, wb[2], wb[1] - 0.3, wb[3], fc="none", ec=D.ACC, lw=0.6, z=7, ls=(0, (3, 2)))
    sb = C.bb(S["screen body"])
    D.rect(ax, sb[0], sb[2], sb[1], sb[3], fc="none", ec=D.MUTED, lw=0.8, z=7, ls=(0, (4, 2)))
    fp = C.bb(S["FPC leg and wide section"])
    D.rect(ax, fp[0], -10.0, fp[1], sb[2], fc="none", ec=D.INK, lw=0.6, z=7, hatch="....")
    # leads: plug exit to the pack end nearest J4
    ex = ld["plug_wire_exit"]
    p_ = ld["pack_lead_exits"]["near J4 (x -15)"]
    by = (ld["bay_y_range"][0] + ld["bay_y_range"][1]) / 2
    ax.plot([ex[0], ex[0], p_[0], p_[0]], [ex[1], by, by, p_[1]], color="#a01818", lw=1.6, zorder=9)
    D.dim(ax, (pk[0], 12.0), (pk[1], 12.0), f"pack {pk[1] - pk[0]:.2f}", off=0.0, orient="h", ext=False, toff=0.2)
    D.dim(ax, (pk[1], pk[2]), (pk[1], pk[3]), f"{pk[3] - pk[2]:.2f}", off=1.2, orient="v")
    D.dim(ax, (-3.0, sb[2]), (-3.0, pk[2]), f"{pk[2] - sb[2]:.2f}", off=0.0, orient="v", ext=False, toff=0.2)
    D.dim(ax, (pk[1], 46.0), (22.0, 46.0), f"to boss {min(yd['to_top_bosses']):.2f}", off=0.0, orient="h", ext=False, toff=0.2)
    ovp = yd.get("back_plate_overlap_mm3") or 0.0
    if ovp > 0.001:
        D.label(ax, (0.0, pk[3] - 1.0), f"FAIL: pack overlaps the back plate by {ovp:.2f} mm3", (-28.0, 38.0), fs=FS, bold=True)
    if yd.get("lip_inner_y") is not None:
        D.dim(ax, (-14.0, pk[3]), (-14.0, yd["lip_inner_y"]), f"{yd['far_edge_to_lip_y']:.2f} to lip", off=-2.5, orient="v", tside=-1)
    hi = y[f"window_{w_hi}"]
    ax.text(-28.5, 44.0, f"at {w_hi} from the screen edge: far end y {hi['far_edge_y']:.2f}, {hi['far_edge_to_lip_y']:.2f} to the lip, "
            f"{hi['to_back_plate']:.2f} to the back plate", fontsize=FS, color=D.ACC, va="center",
            bbox=dict(boxstyle="square,pad=0.1", fc="white", ec="none", alpha=0.9), zorder=12)
    lo = y[f"window_{w_lo}"]
    ax.text(-28.5, -2.0, f"at {w_lo}: near edge y {lo['near_edge_y']:.2f}, {lo['near_edge_to_bottom_rib']} to the bottom ribs",
            fontsize=FS, color=D.ACC, va="center", bbox=dict(boxstyle="square,pad=0.1", fc="white", ec="none", alpha=0.9), zorder=12)
    D.label(ax, (ex[0], ex[1]), f"plug exit, {ld['plug_exit_left_of_fpc']:.2f} left of the FPC", (-29.5, -15.5), fs=FS)
    D.label(ax, (-18.0, by), "leads in the cable bay", (-29.5, 5.0), fs=FS)
    D.label(ax, (5.0, -8.8), "FPC dive (dotted), y below -7.84", (2.0, -14.5), fs=FS)
    D.label(ax, (sb[1], 30.0), "screen outline (dashed)", (21.0, 20.0), fs=D.FS_LABEL)
    D.label(ax, (pk[1] - 2, 20.0), "YDL 403450", (8.0, 25.0), fs=D.FS_LABEL)
    fig.text(0.03, 0.035,
            f"Lead 50: straight distance plug to pack {ld['flat']['near J4 (x -15)']:.1f} (exit near J4), {ld['flat']['centre (x 0)']:.1f} (centre), "
            f"{ld['flat']['far end (x +15)']:.1f} (far end); worst while the board tilts in {ld['worst_straight_distance']:.1f}.",
            fontsize=8.5, color=D.INK, va="bottom")
    return D.save(fig, "closeup-battery-ydl403450")


ALL = ["usb", "microsd", "led", "button", "fpc", "boss", "edges", "antenna", "screen_corner", "battery"]

if __name__ == "__main__":
    m = json.load(open(os.path.join(HERE, "measurements.json")))
    y = json.load(open(os.path.join(HERE, "clearances.json")))["ydl_403450"]
    which = sys.argv[1:] or ALL
    for w in which:
        f = globals()[w]
        print(f(m, y) if w == "battery" else f(m))
