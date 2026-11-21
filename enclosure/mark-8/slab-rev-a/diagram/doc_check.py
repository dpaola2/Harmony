"""Check every dimension claim found in the six documents against the
independent measurements (measurements.json, clearances.json).

The claims list (doc-claims.json in this folder) was extracted line by line from:
  enclosure/mark-8/slab-rev-a/README.md, ASSEMBLY.md, PRINTING.md
  hardware/mark-8/slab-rev-a/SPEC.md, README.md
  docs/mark-8-slab-build.md

Tolerance: 0.02 mm, or the precision the document writes the number with
(a number written with one decimal agrees within 0.05, an integer within 0.5),
or 10 % where the document says "about".

Result per claim: AGREE, DISAGREE, CHANGED (a superseded spec value that the
case README records as changed), NOT MEASURED (with the reason).
"""
import json
import math
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))


def build_M(m, cl):
    M = {}
    st, u, sd, lt, b, f, w = m["stack"], m["usb"], m["microsd"], m["led"], m["button"], m["fpc"], m["walls"]
    bo, bt = m["bosses"]["bottom_left"], m["bosses"]["top_left"]
    e, s, wh, ba, ex, dp = m["edges"], m["screen"], m["wheel"], m["battery"], m["extra"], m["doc_pairs"]
    y = cl["ydl_403450"]
    M.update({
        "body.x": st["outline_x"], "body.y": st["outline_y"], "body.t": st["total_thickness"],
        "body.corner_r": ex["outer_corner_r"], "body.inner_corner_r": ex["inner_corner_r"],
        "body.edge_round_front": ex["front_edge_round"], "body.edge_round_back": ex["back_edge_round"],
        "body.interior_x0": ex["interior_x"][0], "body.interior_x1": ex["interior_x"][1],
        "body.interior_y0": ex["interior_y"][0], "body.interior_y1": ex["interior_y"][1],
        "stack.skin_t": st["skin_t"], "stack.skin_front": st["skin"][1], "stack.skin_back": st["skin"][0],
        "stack.plate_t": st["back_plate_t"], "stack.plate_inner": st["back_plate"][1], "stack.rim": st["shell_rim_z"],
        "stack.screen_t": st["screen_t"], "stack.screen_front": st["screen"][1], "stack.screen_back": st["screen"][0],
        "stack.foam_t": st["foam_t"], "stack.pack_t": st["battery_t"], "stack.pack_to_foam": st["battery_to_foam"],
        "stack.plate_to_screen": st["plate_to_screen_back"], "stack.max_pack_05": st["largest_pack_t_0.5_foam_0.1_tol"],
        "stack.max_pack_02": st["largest_pack_t_0.2_foam_0.1_tol"], "stack.pcb_t": st["pcb_t"],
        "stack.back_face": st["back_face_z"], "stack.pcb_touch": st["pcb"][1], "stack.pcb_comp": st["pcb"][0], "stack.lowest_z": st["lowest_board_part_z"],
        "walls.side": w["side_wall"], "walls.top": w["top_wall"], "walls.lip_w": w["lip_w"], "walls.lip_h": w["lip_h"],
        "walls.lip_gap": w["lip_gap_to_wall"], "walls.skin_recess": w["skin_over_disc_recess"],
        "walls.skin_relief": w["skin_over_usb_leg_relief"], "walls.port_wall": w["bottom_wall_behind_port_recess"],
        "walls.scallop_wall": w["bottom_wall_at_card_scallop"], "walls.roof": w["top_boss_roof"],
        "walls.under_head": w["plate_under_screw_head"], "walls.neck": w["led_tube_neck_wall"],
        "walls.base": w["led_tube_base_wall"], "walls.flange": w["disc_flange"],
        "walls.disc_over_pocket": w["disc_over_leg_pocket_t"], "walls.pocket_depth": round(1.0 - w["disc_over_leg_pocket_t"], 3),
        "walls.min_shell": min(w["skin_over_usb_leg_relief"], w["top_boss_roof"], w["skin_over_disc_recess"]),
        # USB-C
        "usb.face_y": u["j1_face_y"], "usb.shell_top": u["j1_shell_z"][1], "usb.shell_bottom": u["j1_shell_z"][0],
        "usb.shell_w": u["j1_shell_w"], "usb.shell_h": u["j1_shell_h"], "usb.centre_z": u["j1_centre_z"],
        "usb.rec_top": u["j1_receptacle_z"][1], "usb.rec_bottom": u["j1_receptacle_z"][0],
        "usb.open_w": u["opening_w"], "usb.open_h": u["opening_h"], "usb.open_centre": u["opening_centre_z"],
        "usb.recess_w": u["recess_w"], "usb.recess_depth": u["recess_depth"], "usb.recess_bottom": u["recess_bottom_z"],
        "usb.recess_h": u["recess_h_from_design_centre"], "usb.recess_floor": u["recess_floor_y"],
        "usb.overmold": u["overmold_reach_to_face"], "usb.into_wall": u["j1_into_wall"],
        "usb.face_to_outer": round(u["j1_face_y"] - u["outer_face_y"], 3),
        "usb.leg_to_shell": min(r["leg_to_shell"] for r in u["leg_reliefs"]),
        "usb.leg_to_disc": min(r["leg_to_disc"] for r in u["leg_reliefs"]),
        "usb.j1_x_centre": round((u["j1_shell_x"][0] + u["j1_shell_x"][1]) / 2, 3),
        "usb.j1_height": round(-1.8 - u["j1_shell_z"][0], 3),
    })
    fr = [r for r in u["leg_reliefs"] if r["skin_over_relief"]][0]
    pads = m["board"]["j1_shell_pads_kicad"]
    front_pad = [p for p in pads if p[0] < 0 and p[2] < -47][0]
    M["usb.relief_w"] = round(fr["relief_x"][1] - fr["relief_x"][0], 3)
    M["usb.relief_margin"] = round(min(front_pad[0] - fr["relief_x"][0], fr["relief_x"][1] - front_pad[1]), 3)
    M["usb.relief_depth"] = round(1.0 - (fr["skin_over_relief"][1] - fr["skin_over_relief"][0]), 3)
    rear = [p for p in pads if p[2] > -45]
    M["usb.rear_leg_min_r"] = round(min(math.hypot(min(abs(p[0]), abs(p[1])), p[3] + 27.75) for p in rear), 2)
    # microSD
    cards = sd["cards"]
    cdr, cj, cs = cards["drawing estimate (z -2.38 to -3.38)"], cards["JSON card plane -3.141"], cards["STEP: top face on the J3 cover"]
    M.update({
        "sd.slot_w": sd["slot_w"], "sd.slot_h": sd["slot_h"], "sd.slot_x0": sd["slot_x"][0], "sd.slot_x1": sd["slot_x"][1],
        "sd.slot_top": sd["slot_z"][1], "sd.slot_bottom": sd["slot_z"][0], "sd.slot_centre": sd["slot_centre_z"],
        "sd.slot_print_top": sd["slot_z_at_0.2_layers"][1], "sd.slot_print_bottom": sd["slot_z_at_0.2_layers"][0],
        "sd.dr_board": cdr["margin_board_side"], "sd.dr_back": cdr["margin_back_side"],
        "sd.js_board": cj["margin_board_side"], "sd.js_back": cj["margin_back_side"],
        "sd.step_card_top": cs["card_z"][1], "sd.step_card_bottom": cs["card_z"][0],
        "sd.step_card_plane": round((cs["card_z"][0] + cs["card_z"][1]) / 2, 3),
        "sd.scallop_depth": sd["scallop_depth"], "sd.scallop_x0": sd["scallop_x"][0], "sd.scallop_x1": sd["scallop_x"][1],
        "sd.j3_entry": sd["j3_entry_y"], "sd.j3_bottom": sd["j3_bbox"][4],
        "sd.j3_body_h": round(sd["j3_bbox"][5] - sd["j3_bbox"][4], 3),
        "sd.j3_cover": sd["j3_cover_underside_z"], "sd.j3_open_x0": ex["j3_opening_x_at_entry+1"][0],
        "sd.j3_open_x1": ex["j3_opening_x_at_entry+1"][1], "sd.j3_open_centre": ex["j3_opening_centre_x"],
        "sd.j3_gap_top": sd["j3_z_at_entry+1.0"][-1][0], "sd.j3_gap_bottom": sd["j3_z_at_entry+1.0"][0][1],
    })
    # LED
    M.update({
        "led.neck_od": lt["by_z"]["-4.0"]["od"], "led.base_od": lt["by_z"]["-6.5"]["od"], "led.hole": lt["by_z"]["-6.5"]["hole_d"],
        "led.neck_z": lt["base_top_z"], "led.tip_z": lt["tip_z"], "led.chamfer": ex["led_tip_chamfer_radial"],
        "led.x": lt["tube_centre_x"], "led.offset": lt["hole_offset_from_led_x"], "led.to_LED1": lt["to_LED1"],
        "led.to_J1": lt["to_J1"], "led.to_J3": lt["to_J3"], "led.to_R8": lt["to_R8"],
        "led.tip_to_top": abs(lt["tip_to_led_top_z"]), "led.led_top": lt["led1_top_z"], "led.j3j1": lt["j3_j1_gap_x"][2],
        "led.base_to_j1": lt["base_top_to_j1_bottom"], "led.j1_bottom": lt["j1_bottom_z"], "led.j3_bottom": lt["j3_bottom_z"],
    })
    # button
    M.update({
        "btn.h": b["cap_h"], "btn.head_w": b["head_w"], "btn.stem_w": b["stem_w"], "btn.ears_w": b["ears_w"],
        "btn.slot_w": b["slot_w"], "btn.slot_h": b["slot_h"], "btn.pocket_w": b["pocket_w"], "btn.proud": b["head_proud"],
        "btn.rest": b["rest_gap"], "btn.travel": b["travel_to_stop"], "btn.past": b["past_tip_at_stop"],
        "btn.over": b["over_travel_vs_0.2"], "btn.flange_stop": b["flange_to_sw1_at_stop"],
        "btn.flange_mid_t": round(27.7 - b["flange_mid_x"], 3), "btn.ear_t": round(27.7 - b["ear_x"], 3),
        "btn.ear_y0": b["ears_y"][0][0], "btn.ear_y1": b["ears_y"][0][1], "btn.head_t": round(b["head_outer_x"] - b["head_inner_x"], 3),
        "btn.rest_min": b["rest_min"], "sw1.tip_x": b["sw1_tip_x"], "sw1.actuator_z": ex["sw1_actuator_centre_z"],
        "sw1.actuator_d": max(ex["sw1_actuator_d_z"], ex["sw1_actuator_d_y"]),
    })
    # FPC and J2
    M.update({
        "fpc.t": f["fpc_t"], "fpc.tail_w": f["tail_w"], "fpc.fold_outer": f["fold_outer_x"],
        "fpc.fold_mid": round(f["fold_outer_x"] - f["fpc_t"] / 2, 3), "fpc.fold_start": round(f["fold_outer_x"] - f["fpc_t"] - f["fold_inner_r"], 3),
        "fpc.fold_r": f["fold_inner_r"], "fpc.l1_bottom": f["layers_at_x10"][0][0], "fpc.l1_top": f["layers_at_x10"][0][1],
        "fpc.l2_bottom": f["layers_at_x10"][1][0], "fpc.l2_top": f["layers_at_x10"][1][1], "fpc.channel": f["channel_depth"],
        "fpc.tip_x": f["tail_tip_x"], "fpc.insertion": f["insertion"], "fpc.to_plate": f["tail_to_plate"],
        "fpc.to_pcb": f["tail_to_pcb"], "fpc.loop_h": f["loop_height_above_plate_layer"], "fpc.wing_x": f["wide_section_max_x"],
        "fpc.loop_y0": ex["fpc_loop_y"][0], "fpc.loop_y1": ex["fpc_loop_y"][1], "fpc.drop": ex["fpc_drop"],
        "fpc.exit_mid_z": ex["fpc_exit_mid_z"], "fpc.j2_tail_overlap": f["tail_j2_overlap_mm3"],
        "j2.mouth_x": f["j2_mouth_x"], "j2.slot_y": f["j2_slot_centre_y"], "j2.slot_z": f["j2_slot_centre_z"],
        "j2.body_h": round(f["j2_bbox"][5] - f["j2_bbox"][4], 3),
        "flat.wide_x0": ex["flat_wide_x_at_y-9"][0], "flat.wide_x1": ex["flat_wide_x_at_y-9"][1],
        "flat.wing_x1": ex["flat_wide_x_at_y-12"][1], "flat.leg_x0": ex["flat_leg_x_at_y-30"][0], "flat.leg_x1": ex["flat_leg_x_at_y-30"][1],
        "flat.wide_y1": ex["flat_wide_y_at_x0"][0],
        "flat.tail_y0": ex["flat_tail_y_at_x20"][1], "flat.tail_y1": ex["flat_tail_y_at_x20"][0],
        "flat.tail_x0": ex["flat_tail_x_at_y-48.4"][0], "flat.tail_x1": ex["flat_tail_x_at_y-48.4"][1],
        "flat.tip_outside_wall": round(ex["flat_tail_x_at_y-48.4"][1] - ex["interior_x"][1], 2),
    })
    # bosses
    M.update({
        "boss.insert_len": bo["insert_len"], "boss.insert_od": bo["insert_od"], "boss.hole_d": bo["hole_d"],
        "boss.hole_depth": bo["hole_depth"], "boss.face": bo["boss_face_z"], "boss.hole_bottom": bo["hole_bottom_z"],
        "boss.d": round(2 * (24.7 + bo["boss_outer_x"][0]) * -1, 3) if bo["boss_outer_x"] else None,
        "boss.wall": bo["boss_wall"], "boss.lead_in": ex["insert_lead_in_depth"], "boss.flush": bo["insert_top_vs_boss_face"],
        "boss.top_z": bt["boss_top_z"], "boss.top_to_screen": bt["boss_top_to_screen_back"], "boss.roof": bt["roof"],
        "screw.len": bo["screw_len_under_head"], "screw.head_d": bo["screw_head_d"], "screw.head_h": bo["screw_head_h"],
        "screw.tip_to_bottom": bo["tip_to_hole_bottom"], "screw.m2x5": bo["m2x5_tip_to_hole_bottom"],
        "screw.engage": bo["engagement"], "cb.d": bo["counterbore_d"], "cb.depth": bo["counterbore_depth"],
        "cb.hole": bo["clearance_hole_d"], "pad.h": round(bo["plate_pad_top_z"] - st["back_plate"][1], 3),
        "boss.knurl": bo["knurl_interference_radial"],
    })
    # edges, tabs, standoffs, notches
    tabs = {t["edge"]: t for t in e["frame_tabs"]}
    so = e["standoffs"]
    M.update({
        "edge.left": min(r["left_gap"] for r in e["side_gaps"]), "edge.right": min(r["right_gap"] for r in e["side_gaps"]),
        "edge.bottom_wall": next(r["bottom_gap_at_z-1.4"] for r in e["bottom_top_gaps"] if r["x"] == 0.0),
        "edge.lips": next(r["top_gap_at_z-1.4"] for r in e["bottom_top_gaps"] if r["x"] == -20.9),
        "so.x0": round((so[0]["x_range"][0] + so[0]["x_range"][1]) / 2, 3), "so.x1": round((so[1]["x_range"][0] + so[1]["x_range"][1]) / 2, 3),
        "so.x2": round((so[2]["x_range"][0] + so[2]["x_range"][1]) / 2, 3), "so.w": so[0]["width"], "so.gap": max(r["gap_to_board_edge"] for r in so),
        "so.z_end": so[0]["z_end"], "so.chamfer": so[0]["chamfer_y"],
        "so.to_J3": dict(dp["standoff_nearest"]["-20.9"]).get("J3"), "so.to_R1": dict(dp["standoff_nearest"]["13.5"]).get("R1"),
        "so.to_R4": dict(dp["standoff_nearest"]["20.9"]).get("R4"),
        "notch.r": e["notches"][0]["notch_r_min"], "notch.gap": e["notches"][0]["gap"],
        "tab.left_flush": tabs["left"]["board_edge_to_shell"], "tab.left_nub": tabs["left"]["nub_0.35_to_shell"],
        "tab.top_flush": tabs["top"]["board_edge_to_shell"], "tab.top_nub": tabs["top"]["nub_0.35_to_shell"],
        "tab.right_flush": tabs["right"]["filed_flush_to_shell"], "tab.right_nub": tabs["right"]["nub_0.35_to_shell"],
        "tab.right_strip": ex["right_tab_strip_below_tab"], "board.top_to_screen": e["board_top_to_screen"],
        "board.corner_r": ex.get("board_top_left_corner_r"),
    })
    # screen and window
    M.update({
        "scr.w": s["screen_size"][0], "scr.l": s["screen_size"][1], "scr.t": s["screen_size"][2],
        "scr.x0": s["screen_bbox"][0], "scr.x1": s["screen_bbox"][1], "scr.y0": s["screen_bbox"][2], "scr.y1": s["screen_bbox"][3],
        "scr.gap": min(s["side_gap_left"], s["side_gap_right"], s["top_gap"], s["lip_gap"]), "scr.lip_len": round(s["lip_y"][1] - s["lip_y"][0], 3),
        "scr.overlap": s["overlap_with_shell_mm3"], "scr.corner_pen": s["top_corners"][0]["wall_into_screen_on_diagonal"],
        "scr.corner_wall": s.get("corner_wall_measured"),
        "scr.corner_clear": min(c.get("corner_clearance") if c.get("corner_clearance") is not None else -c["wall_into_screen_on_diagonal"]
                                for c in s["top_corners"]),
        "aa.x0": s["active_area"][0], "aa.x1": s["active_area"][1], "aa.y0": s["active_area"][2], "aa.y1": s["active_area"][3],
        "aa.w": round(s["active_area"][1] - s["active_area"][0], 3), "aa.h": round(s["active_area"][3] - s["active_area"][2], 3),
        "aa.top_inset": round(s["screen_bbox"][3] - s["active_area"][3], 3), "aa.bottom_inset": round(s["active_area"][2] - s["screen_bbox"][2], 3),
        "win.w": s["window_size"][0], "win.h": s["window_size"][1], "win.margin": min(s["window_margin"]),
        "win.x0": s["window_at_z-0.7"][0], "win.x1": s["window_at_z-0.7"][1], "win.y0": s["window_at_z-0.7"][2], "win.y1": s["window_at_z-0.7"][3],
        "win.r": s.get("window_corner_r"), "win.chamfer": ex["window_chamfer_at_front"],
        "win.offset": max(abs(v) for v in s["window_centre_offset"]), "win.offx": s["window_centre_offset"][0], "win.offy": s["window_centre_offset"][1],
    })
    # wheel
    M.update({
        "disc.d": wh["disc_d"], "disc.t": wh["disc_t"], "disc.flange_t": wh["flange_t"], "disc.r": round(wh["disc_d"] / 2, 3),
        "disc.flange_r": round(wh["flange_d"] / 2, 3), "disc.open_r": round(wh["opening_d"] / 2, 3), "disc.recess_r": round(wh["recess_d"] / 2, 3),
        "disc.gap": wh["opening_radial_gap"], "disc.recess_depth": round(1.0 - wh["skin_over_recess_t"], 3), "disc.skin": wh["skin_over_recess_t"],
        "disc.past_top": wh["flange_past_board_top"], "disc.key": wh["key_angle_deg"], "disc.cx": wh["disc_centre"][0], "disc.cy": wh["disc_centre"][1],
    })
    # battery and foam
    M.update({
        "bat.foam_w": ba["foam_size"][0], "bat.foam_l": ba["foam_size"][1], "bat.lower_edge": ba["pack_lower_edge_y"],
        "bat.bay": ba["cable_bay_from_screen_edge"], "bat.rib_h": ba["rib_h"], "bat.rib_gap": min(ba["side_rib_gap_to_pack"]) if ba.get("side_rib_gap_to_pack") else None,
        "bat.rib_accepts_w": round(ba["side_ribs_x"][1][0] - ba["side_ribs_x"][0][1] - 0.6, 3) if len(ba.get("side_ribs_x") or []) >= 2 else None,
        "bat.top_rib_accepts_l": round(ba["top_rib_y"][0] - 0.3 - ba["pack_lower_edge_y"], 3) if ba.get("top_rib_y") else None,
        "bat.plug_to_screen": ba["plug_to_screen"], "bat.plug_to_shell": ba["plug_to_shell"], "bat.j4_to_screen": ba["j4_mouth_to_screen_edge"],
        "bat.plug_w": round(ba["plug_bbox"][1] - ba["plug_bbox"][0], 3), "bat.plug_l": round(ba["plug_bbox"][3] - ba["plug_bbox"][2], 3),
        "bat.plug_h": round(ba["plug_bbox"][5] - ba["plug_bbox"][4], 3),
        "bat.max_full_w": round(2 * (dp["lip_inner_x"] - 0.3), 3), "bat.max_full_l": round(dp["top_boss_low_y"] - 0.3 - ba["pack_lower_edge_y"], 3),
        "bat.max_narrow_w": round(2 * (dp["top_boss_inner_x"] * -1 - 0.3), 3) if dp["top_boss_inner_x"] else None,
        "bat.max_narrow_l": round(dp["lip_inner_y"] - 0.3 - ba["pack_lower_edge_y"], 3),
        "bat.ref_wide_boss": dp["ref wide | top bosses"], "bat.ref_narrow_lip": dp["ref narrow | back plate lip"],
        "bat.model_to_bosses": dp["battery pack | top bosses"], "bat.model_to_shell": dp["battery pack | front shell"],
        "tilt.min_screen_1": m["plug_tilt"]["touch-side bottom edge"]["min_to_screen"],
        "tilt.min_shell_1": m["plug_tilt"]["touch-side bottom edge"]["min_to_shell"],
        "tilt.min_screen_2": m["plug_tilt"]["J1 shell front top edge (STEP z -1.9)"]["min_to_screen"],
        "tilt.min_shell_2": m["plug_tilt"]["J1 shell front top edge (STEP z -1.9)"]["min_to_shell"],
        "tilt.1deg": next(r["to_screen"] for r in m["plug_tilt"]["touch-side bottom edge"]["rows"] if r["deg"] == 1),
        "tilt.2deg": next(r["to_screen"] for r in m["plug_tilt"]["touch-side bottom edge"]["rows"] if r["deg"] == 2),
    })
    refs = ba["reference_packs"]
    M["bat.spec_shell"] = refs["52 x 54 x 4.8 (SPEC block)"]["overlaps"].get("front shell")
    M["bat.spec_insert"] = refs["52 x 54 x 4.8 (SPEC block)"]["overlaps"].get("insert 3")
    M["bat.spec_screw"] = refs["52 x 54 x 4.8 (SPEC block)"]["overlaps"].get("screw 3")
    M["bat.spec_foam"] = refs["52 x 54 x 4.8 (SPEC block)"]["overlaps"].get("battery foam")
    # pins, posts, motor, grille
    pp = m["posts_pins"]
    M.update({
        "pin.d": pp["pins"][0]["pin_d"], "pin.radial": pp["pins"][0]["radial_clearance"], "pin.hole": pp["pins"][0]["hole_d"],
        "pin.tip": pp["pins"][0]["tip_z"], "pin.past": pp["pins"][0]["tip_past_component_side"], "pin.chamfer": ex["pin_H1_chamfer"],
        "post.tip_d": pp["posts"][0]["tip_d"], "post.tip_z": pp["posts"][0]["tip_z"], "post.base_d": pp["posts"][0]["base_d"],
        "post.interf": pp["posts"][0]["interference_with_pcb"],
        "post.min_near": min(p["nearest_parts"][0][1] for p in pp["posts"]),
    })
    for p in pp["posts"]:
        M[f"post.{p['ref']}.near"] = p["nearest_parts"][0][1]
    mo = m["motor"]
    M.update({"motor.d": mo["motor_d"], "motor.h": mo["motor_h"], "motor.cx": mo["centre"][0], "motor.cy": mo["centre"][1],
              "motor.seat_d": mo["seat_d"], "motor.seat_depth": mo["seat_depth"], "motor.near": mo["nearest_board_parts"][0][1]})
    pads = [(-22.2, -40.9), (-22.2, -43.2)]
    M["motor.max_pad"] = round(max(math.hypot(px - mo["centre"][0], py - mo["centre"][1]) for px, py in pads), 2)
    M["motor.seat_to_boss"] = round(math.hypot(-24.7 - mo["centre"][0], -47.15 - mo["centre"][1]) - mo["seat_d"] / 2 - 2.7, 2)
    M["motor.seat_to_pp1"] = round(math.hypot(-24.9 - mo["centre"][0], -33.0 - mo["centre"][1]) - mo["seat_d"] / 2 - pp["posts"][0]["base_d"] / 2, 2)
    M.update({"grille.w": ex.get("grille_slot_w"), "grille.l": ex.get("grille_slot_l"), "grille.pitch": ex.get("grille_pitch"),
              "grille.overall": ex.get("grille_overall_w")})
    # antenna
    an = m["antenna"]["distances"]
    M.update({"ant.fold": round(m["antenna"]["keepout"]["x"][0] - f["fold_outer_x"], 3), "ant.screw": an["screw 2"]["to_keepout"],
              "ant.screw_region": an["screw 2"]["to_antenna_region"], "ant.insert": an["insert 2"]["to_keepout"],
              "ant.wall": round(m["antenna"]["right_wall_x_at_y-28"][0][1] - m["antenna"]["right_wall_x_at_y-28"][0][0], 3),
              "ant.fpc_near": min(an["FPC tail"]["to_keepout"], an["FPC leg and wide section"]["to_keepout"], an["FPC part"]["to_keepout"])})
    # board vs JSON / KiCad
    bd = m["board"]
    rows = {r["ref"]: r for r in bd["rows"]}
    for ref, r in rows.items():
        M[f"part.{ref}.top_z"] = r["step_z"][0]
        M[f"part.{ref}.body_h"] = round(r["step_z"][1] - r["step_z"][0], 3)
        M[f"part.{ref}.cx"] = r["kicad_centre"][0] if r["kicad_centre"] else None
        M[f"part.{ref}.cy"] = r["kicad_centre"][1] if r["kicad_centre"] else None
        M[f"part.{ref}.x0"], M[f"part.{ref}.x1"] = r["step_x"]
        M[f"part.{ref}.y0"], M[f"part.{ref}.y1"] = r["step_y"]
    for ref, c in bd.get("kicad_extra", {}).items():
        M[f"part.{ref}.cx"], M[f"part.{ref}.cy"] = c
    M["part.BZ1.w"] = round(rows["BZ1"]["step_x"][1] - rows["BZ1"]["step_x"][0], 3)
    M["part.BZ1.l"] = round(rows["BZ1"]["step_y"][1] - rows["BZ1"]["step_y"][0], 3)
    M["part.J4.cx"] = round((rows["J4"]["step_x"][0] + rows["J4"]["step_x"][1]) / 2, 3)
    M["part.J4.cy"] = round((rows["J4"]["step_y"][0] + rows["J4"]["step_y"][1]) / 2, 3)
    M["part.SW1.cy"] = round((rows["SW1"]["step_y"][0] + rows["SW1"]["step_y"][1]) / 2, 3)
    M["part.U1.cy"] = round((rows["U1"]["step_y"][0] + rows["U1"]["step_y"][1]) / 2, 3)
    M["part.Q5.to_ramp"] = round(-36.0 - rows["Q5"]["step_y"][0], 3) * -1
    M["part.U1.to_ramp"] = round(rows["U1"]["step_y"][0] - (-36.0), 3)
    M.update({"pcb.w": bd["pcb_size"][0], "pcb.h": bd["pcb_size"][1], "pcb.t": bd["pcb_size"][2],
              "pcb.x0": bd["pcb_bbox"][0], "pcb.x1": bd["pcb_bbox"][1], "pcb.y0": bd["pcb_bbox"][2], "pcb.y1": bd["pcb_bbox"][3],
              "pcb.touch": bd["pcb_bbox"][5], "pcb.comp": bd["pcb_bbox"][4],
              "h1.x": bd["locating_holes"][0]["step_centre"][0], "h1.y": bd["locating_holes"][0]["step_centre"][1],
              "h1.d": bd["locating_holes"][0]["step_d_x"], "h2.x": bd["locating_holes"][1]["step_centre"][0],
              "h2.y": bd["locating_holes"][1]["step_centre"][1], "h2.d": bd["locating_holes"][1]["step_d_x"],
              "h2.from_near_edge": round(bd["locating_holes"][1]["step_centre"][1] - bd["pcb_bbox"][2], 2),
              "tallest.overall": ex["tallest_overall"][1], "tallest.run": max(t[1] for t in ex["tallest_in_run_zones"] if t),
              "tallest.ramp": ex["tallest_in_ramp_zone"][1]})
    ch = dp["changed_parts"]
    for ref in ("R31", "R32", "R34", "C26"):
        M[f"chg.{ref}.fpc"] = ch[ref]["nearest_fpc"][1]
        M[f"chg.{ref}.screen"] = ch[ref]["screen_body"]
        M[f"chg.{ref}.plate"] = ch[ref]["back_plate"]
        M[f"chg.{ref}.other"] = ch[ref]["nearest_other_behind_board"][1]
    M["chg.min_fpc"] = min(ch[r]["nearest_fpc"][1] for r in ch)
    M["chg.min_other"] = min(ch[r]["nearest_other_behind_board"][1] for r in ch)
    for k, v in dp.items():
        if isinstance(v, (int, float)):
            M["dp." + k] = v
    # overlap volumes from the pair table
    for r in cl["pairs"]:
        M[f"ov.{r['a']}|{r['b']}"] = r["overlap_mm3"] or 0.0
        M[f"ov.{r['b']}|{r['a']}"] = r["overlap_mm3"] or 0.0
    M["ydl.room"] = y["nominal"]["to_back_plate_face"]
    back = st["back_face_z"]
    M["h.rim"] = -st["shell_rim_z"]
    M["h.boss"] = -bo["boss_face_z"]
    M["h.post"] = round(m["posts_pins"]["posts"][0]["tip_z"] - back, 3)
    M["h.pad"] = round(bo["plate_pad_top_z"] - back, 3)
    M["h.led"] = round(lt["tip_z"] - back, 3)
    M["usb.open_top_depth"] = -u["opening_z"][1]
    M["usb.open_bottom_depth"] = -u["opening_z"][0]
    M["ydl.near_edge_from_screen"] = y["nominal"]["near_edge_from_screen_edge"]
    return M


# claim id -> list of measurement keys, one per value ("-" = not checked), or a dict for special modes
MAP = {
    # ---------------- enclosure README
    "ENC-README-002": "stack.pack_t", "ENC-README-003": "stack.max_pack_05",
    "ENC-README-004": {"mode": "fit", "keys": ["bat.max_full_w", "bat.max_full_l"]},
    "ENC-README-005": "bat.max_narrow_w,bat.max_narrow_l",
    "ENC-README-006": "disc.d", "ENC-README-007": "disc.t", "ENC-README-008": "disc.flange_t", "ENC-README-009": "stack.plate_t",
    "ENC-README-013": "tilt.min_screen_1", "ENC-README-014": "tilt.1deg,tilt.2deg", "ENC-README-015": "tilt.min_shell_1",
    "ENC-README-016": "led.neck_od", "ENC-README-017": "led.neck_z", "ENC-README-018": "led.base_od", "ENC-README-019": "led.chamfer",
    "ENC-README-020": "led.hole", "ENC-README-021": "led.to_J1,led.to_J3", "ENC-README-025": "stack.foam_t",
    "ENC-README-026": "stack.max_pack_05,stack.plate_to_screen", "ENC-README-027": "ydl.room", "ENC-README-028": "ant.fold",
    "ENC-README-029": "ant.screw", "ENC-README-030": "sd.slot_h", "ENC-README-031": "sd.slot_top,sd.slot_bottom",
    "ENC-README-033": "sd.dr_board,sd.dr_back", "ENC-README-034": "sd.js_board,sd.js_back",
    "ENC-README-036": "so.x0,so.x1,so.x2", "ENC-README-037": "so.gap", "ENC-README-038": "so.to_J3", "ENC-README-039": "notch.gap",
    "ENC-README-040": "btn.rest", "ENC-README-041": "btn.past", "ENC-README-043": "btn.over", "ENC-README-044": {"mode": "ge", "keys": ["chg.min_fpc"]},
    "ENC-README-045": {"mode": "ge", "keys": ["chg.min_other"]}, "ENC-README-046": "tab.left_flush", "ENC-README-047": "tab.top_flush",
    "ENC-README-048": "-,tab.left_nub", "ENC-README-049": "tab.right_flush", "ENC-README-051": "usb.relief_margin",
    "ENC-README-052": "usb.leg_to_shell", "ENC-README-053": "led.hole", "ENC-README-054": "led.to_J1", "ENC-README-055": "led.j3_bottom",
    "ENC-README-056": "led.j1_bottom", "ENC-README-058": "led.base_od", "ENC-README-059": "led.base_to_j1", "ENC-README-060": "walls.neck",
    "ENC-README-062": "disc.open_r,disc.recess_r", "ENC-README-063": "disc.recess_depth", "ENC-README-064": "disc.skin",
    "ENC-README-065": "disc.flange_t", "ENC-README-066": "disc.r,disc.flange_r", "ENC-README-067": "disc.t", "ENC-README-068": "disc.gap",
    "ENC-README-070": "disc.past_top,pcb.y1", "ENC-README-071": "disc.key", "ENC-README-072": "h_boss_x,h_boss_y",
    "ENC-README-073": "boss.top_z", "ENC-README-074": "boss.top_to_screen", "ENC-README-075": "boss.hole_depth", "ENC-README-076": "boss.face",
    "ENC-README-077": "boss.roof", "ENC-README-078": "usb.relief_depth", "ENC-README-079": "usb.relief_margin", "ENC-README-081": "usb.relief_w",
    "ENC-README-082": "usb.rear_leg_min_r", "ENC-README-083": "walls.pocket_depth", "ENC-README-084": "usb.leg_to_shell,usb.relief_margin",
    "ENC-README-085": "usb.face_y", "ENC-README-086": "usb.face_to_outer", "ENC-README-091": "usb.open_w,usb.open_h,-",
    "ENC-README-092": "usb.into_wall", "ENC-README-093": "usb.recess_w", "ENC-README-094": "usb.recess_depth",
    "ENC-README-095": "usb.recess_bottom", "ENC-README-097": "usb.recess_floor,usb.overmold", "ENC-README-098": "stack.skin_t",
    "ENC-README-099": "sd.slot_w,sd.slot_h", "ENC-README-100": "sd.slot_x0,sd.slot_x1", "ENC-README-101": "sd.slot_top,sd.slot_bottom",
    "ENC-README-103": "sd.step_card_plane", "ENC-README-106": "sd.slot_h", "ENC-README-108": "sd.step_card_top,sd.step_card_bottom",
    "ENC-README-110": "sd.scallop_depth", "ENC-README-111": "sd.scallop_x0,sd.scallop_x1",
    "ENC-README-116": "btn.h", "ENC-README-117": "btn.head_w", "ENC-README-118": "btn.stem_w", "ENC-README-119": "btn.ears_w",
    "ENC-README-120": "btn.slot_w,btn.slot_h", "ENC-README-121": "btn.pocket_w", "ENC-README-122": "btn.proud", "ENC-README-123": "btn.rest",
    "ENC-README-124": "btn.travel", "ENC-README-126": "btn.flange_mid_t,btn.ear_t", "ENC-README-128": "fpc.fold_mid",
    "ENC-README-131": "j2.slot_y", "ENC-README-132": "fpc.channel", "ENC-README-135": "ant.wall", "ENC-README-136": "walls.lip_w,walls.lip_h",
    "ENC-README-137": "btn.ear_t", "ENC-README-138": "btn.ear_y0,btn.ear_y1", "ENC-README-139": "ant.screw,ant.screw_region",
    "ENC-README-141": "fpc.fold_outer", "ENC-README-142": "fpc.wing_x", "ENC-README-143": "ant.fpc_near",
    "ENC-README-145": "stack.plate_inner,stack.screen_back,stack.plate_to_screen", "ENC-README-147": "stack.foam_t", "ENC-README-148": "stack.screen_t",
    "ENC-README-149": "stack.max_pack_05", "ENC-README-150": "stack.max_pack_02", "ENC-README-151": "ydl.room",
    "ENC-README-153": "bat.lower_edge", "ENC-README-154": "bat.rib_h", "ENC-README-156": "bat.rib_accepts_w", "ENC-README-157": "bat.top_rib_accepts_l",
    "ENC-README-158": "part.J4.cx", "ENC-README-160": "pin.d", "ENC-README-161": "pin.radial", "ENC-README-162": "pin.hole",
    "ENC-README-163": "pin.tip,pin.past", "ENC-README-164": "pin.chamfer", "ENC-README-165": "notch.gap", "ENC-README-166": "so.x0,so.x1,so.x2",
    "ENC-README-167": "so.w", "ENC-README-168": "so.z_end", "ENC-README-169": "so.chamfer", "ENC-README-170": "edge.bottom_wall",
    "ENC-README-171": "so.gap", "ENC-README-172": "post.tip_d", "ENC-README-173": "post.tip_z,-", "ENC-README-174": "post.interf",
    "ENC-README-175": "post.base_d,-", "ENC-README-176": {"mode": "ge", "keys": ["post.min_near"]},
    "ENC-README-177": "grille.w,grille.l", "ENC-README-178": "grille.pitch", "ENC-README-179": "grille.overall,grille.l",
    "ENC-README-180": "led.hole", "ENC-README-181": "led.x", "ENC-README-182": "led.offset", "ENC-README-183": "led.j3j1",
    "ENC-README-184": "led.tip_z", "ENC-README-185": "led.tip_to_top", "ENC-README-186": "led.base_od,led.neck_z,led.neck_od",
    "ENC-README-187": "led.chamfer", "ENC-README-188": "motor.seat_d", "ENC-README-189": "motor.seat_depth",
    "ENC-README-190": "motor.cx,motor.cy", "ENC-README-191": {"mode": "ge_claim", "keys": ["motor.max_pad"]},
    "ENC-README-193": "motor.seat_to_boss", "ENC-README-194": "motor.seat_to_pp1", "ENC-README-195": "win.w,win.h",
    "ENC-README-196": "win.margin", "ENC-README-197": "win.r", "ENC-README-198": "win.chamfer", "ENC-README-200": "scr.gap",
    "ENC-README-201": "stack.screen_front,stack.screen_back", "ENC-README-202": "scr.lip_len", "ENC-README-203": "scr.gap",
    "ENC-README-204": "win.offset", "ENC-README-205": {"mode": "changed", "keys": ["body.corner_r"]}, "ENC-README-206": "body.corner_r",
    "ENC-README-207": "scr.x1,scr.y1",
    "ENC-README-211": "scr.corner_wall",
    "ENC-README-213": {"mode": "fit", "keys": ["bat.max_full_w", "bat.max_full_l", "stack.max_pack_05"]},
    "ENC-README-214": "bat.max_narrow_w,bat.max_narrow_l,stack.max_pack_05", "ENC-README-217": "stack.pack_t",
    "ENC-README-218": "screw.len", "ENC-README-219": {"mode": "special_m2x5"}, "ENC-README-220": "board.top_to_screen",
    "ENC-README-221": {"mode": "changed_doc"}, "ENC-README-222": "fpc.fold_mid", "ENC-README-224": "fpc.drop", "ENC-README-226": "j2.mouth_x",
    "ENC-README-227": "pin.d", "ENC-README-228": "pin.radial", "ENC-README-229": "usb.open_w,usb.open_h", "ENC-README-230": "usb.recess_w,-",
    "ENC-README-231": "usb.recess_depth", "ENC-README-232": "body.x,body.y", "ENC-README-233": "body.t", "ENC-README-234": "body.edge_round_front",
    "ENC-README-235": "walls.side", "ENC-README-236": "stack.skin_t", "ENC-README-237": "stack.plate_t", "ENC-README-238": "stack.plate_inner",
    "ENC-README-239": "h_boss_x,h_boss_y", "ENC-README-240": "stack.rim", "ENC-README-241": "walls.lip_w,walls.lip_h", "ENC-README-242": "boss.face",
    "ENC-README-243": "pad.h", "ENC-README-244": "cb.d,cb.depth", "ENC-README-245": "walls.under_head", "ENC-README-246": "boss.insert_len",
    "ENC-README-247": "boss.insert_od", "ENC-README-248": "boss.hole_d", "ENC-README-249": "boss.hole_depth", "ENC-README-250": "boss.lead_in",
    "ENC-README-251": "boss.d", "ENC-README-252": "boss.wall", "ENC-README-253": "notch.gap", "ENC-README-254": "notch.r",
    "ENC-README-259": "fpc.to_plate", "ENC-README-261": "fpc.insertion", "ENC-README-263": "bat.plug_w,bat.plug_h,bat.plug_l",
    "ENC-README-264": "bat.plug_to_screen", "ENC-README-265": "bat.plug_to_shell", "ENC-README-266": "scr.gap",
    "ENC-README-270": "scr.y0,fpc.exit_mid_z", "ENC-README-277": "j2.slot_y", "ENC-README-280": "fpc.loop_h",
    "ENC-README-281": "fpc.loop_y0,fpc.loop_y1", "ENC-README-282": "fpc.fold_start", "ENC-README-283": "fpc.fold_mid,fpc.fold_outer",
    "ENC-README-284": "fpc.fold_r", "ENC-README-287": "fpc.l1_bottom,fpc.l1_top", "ENC-README-288": "fpc.channel",
    "ENC-README-289": "fpc.l2_bottom,fpc.l2_top", "ENC-README-294": "fpc.tip_x,fpc.insertion",
    "ENC-README-295": "stack.plate_to_screen", "ENC-README-296": "stack.max_pack_05",
    "ENC-README-297": {"mode": "fit", "keys": ["bat.max_full_w", "bat.max_full_l", "stack.max_pack_05"]}, "ENC-README-298": "bat.ref_wide_boss",
    "ENC-README-299": "bat.max_narrow_w,bat.max_narrow_l,stack.max_pack_05", "ENC-README-300": "bat.ref_narrow_lip", "ENC-README-301": "bat.lower_edge",
    "ENC-README-304": "ov.front shell|wheel disc", "ENC-README-305": "ov.front shell|button cap", "ENC-README-306": "ov.front shell|insert 1",
    "ENC-README-307": "ov.front shell|insert 2", "ENC-README-308": "ov.front shell|insert 3", "ENC-README-309": "ov.front shell|insert 4",
    "ENC-README-310": "ov.front shell|screen body", "ENC-README-311": "ov.front shell|board PCB", "ENC-README-312": "ov.wheel disc|board PCB",
    "ENC-README-313": "ov.back plate|screw 1", "ENC-README-314": "ov.back plate|screw 2", "ENC-README-315": "ov.back plate|screw 3",
    "ENC-README-316": "ov.back plate|screw 4", "ENC-README-317": "ov.back plate|board PCB", "ENC-README-318": "ov.back plate|battery pack",
    "ENC-README-319": "ov.back plate|motor", "ENC-README-320": "ov.screen body|battery foam", "ENC-README-322": "ov.FPC tail|board J2",
    "ENC-README-323": "ov.board J4|battery plug PHR-2", "ENC-README-324": "ov.battery plug PHR-2|battery wires",
    "ENC-README-329": "bat.spec_shell", "ENC-README-330": "bat.spec_insert,bat.spec_insert", "ENC-README-331": "bat.spec_screw,bat.spec_screw",
    "ENC-README-332": "bat.spec_foam", "ENC-README-333": "dp.FPC leg and wide section | board SW2", "ENC-README-334": "dp.FPC tail | board C20",
    "ENC-README-335": "dp.FPC tail | board J1", "ENC-README-336": "dp.FPC leg and wide section | board D1", "ENC-README-337": "dp.FPC part | board SW2",
    "ENC-README-338": "dp.FPC leg and wide section | board R17", "ENC-README-339": "fpc.to_pcb", "ENC-README-340": "dp.FPC | front shell",
    "ENC-README-341": "dp.FPC | back plate", "ENC-README-342": "dp.FPC | wheel disc", "ENC-README-343": "dp.FPC | motor",
    "ENC-README-344": "dp.FPC | battery pack", "ENC-README-345": "dp.FPC | battery plug PHR-2", "ENC-README-346": "bat.model_to_bosses",
    "ENC-README-347": "bat.model_to_shell", "ENC-README-348": "bat.rib_gap", "ENC-README-349": "ydl.room",
    "ENC-README-350": "bat.plug_to_screen", "ENC-README-351": "bat.plug_to_shell", "ENC-README-352": "btn.rest_min", "ENC-README-353": "btn.past",
    "ENC-README-354": "btn.travel", "ENC-README-356": "btn.flange_stop", "ENC-README-357": "post.PP1.near", "ENC-README-358": "post.PP2.near",
    "ENC-README-359": "post.PP3.near", "ENC-README-360": "post.PP4.near", "ENC-README-361": "led.to_LED1", "ENC-README-362": "led.to_J1",
    "ENC-README-363": "led.to_J3", "ENC-README-364": "led.to_R8", "ENC-README-365": "pin.radial", "ENC-README-366": "pin.radial",
    "ENC-README-367": "usb.leg_to_shell", "ENC-README-368": "usb.leg_to_disc", "ENC-README-369": "motor.near", "ENC-README-370": "boss.top_to_screen",
    "ENC-README-371": "so.x0,so.gap", "ENC-README-372": "so.x0,so.to_J3", "ENC-README-373": "so.x1,so.gap", "ENC-README-374": "so.x1,so.to_R1",
    "ENC-README-375": "so.x2,so.gap", "ENC-README-376": "so.x2,so.to_R4", "ENC-README-377": "part.R31.cx,part.R31.cy",
    "ENC-README-378": "chg.R31.fpc", "ENC-README-379": "chg.R31.screen", "ENC-README-380": "part.R32.cx,part.R32.cy", "ENC-README-381": "chg.R32.fpc",
    "ENC-README-382": "chg.R32.plate", "ENC-README-383": "part.R34.cx,part.R34.cy", "ENC-README-384": "chg.R34.fpc", "ENC-README-385": "chg.R34.plate",
    "ENC-README-386": "part.C26.cx,part.C26.cy", "ENC-README-387": "chg.C26.fpc", "ENC-README-388": "chg.C26.plate",
    "ENC-README-390": "tab.left_flush", "ENC-README-391": "tab.left_nub", "ENC-README-393": "tab.top_flush", "ENC-README-394": "tab.top_nub",
    "ENC-README-396": "tab.right_flush", "ENC-README-397": "tab.right_nub", "ENC-README-399": "sd.dr_board,sd.dr_back",
    "ENC-README-400": "sd.step_card_top,sd.step_card_bottom", "ENC-README-401": "sd.js_board,sd.js_back", "ENC-README-402": "pcb.y0,pcb.touch",
    "ENC-README-403": "tilt.min_screen_1,tilt.min_shell_1", "ENC-README-404": "usb.face_y,usb.shell_top",
    "ENC-README-405": "tilt.min_screen_2,tilt.min_shell_2", "ENC-README-408": "boss.wall", "ENC-README-409": "boss.insert_len,boss.insert_od",
    "ENC-README-410": "boss.hole_d", "ENC-README-411": "boss.d,boss.wall", "ENC-README-412": "cb.d,cb.depth", "ENC-README-413": "cb.hole",
    "ENC-README-414": "walls.min_shell", "ENC-README-415": "walls.skin_recess", "ENC-README-416": "walls.skin_relief", "ENC-README-417": "walls.roof",
    "ENC-README-418": "walls.port_wall", "ENC-README-419": "walls.scallop_wall", "ENC-README-420": "walls.neck", "ENC-README-421": "walls.neck",
    "ENC-README-422": "walls.under_head", "ENC-README-425": "walls.flange", "ENC-README-427": "btn.flange_mid_t",
    "ENC-README-428": "btn.flange_mid_t,btn.ear_t", "ENC-README-429": "-,btn.head_t,-", "ENC-README-437": "-",
    "ENC-README-441": "body.x,body.x", "ENC-README-442": "body.y,body.y", "ENC-README-443": "body.t,body.t,stack.back_face,stack.skin_front",
    "ENC-README-445": "aa.x1,aa.y0,aa.y1", "ENC-README-446": "aa.x0,aa.x1,aa.y0,aa.y1", "ENC-README-448": "win.x0,win.x1,win.y0,win.y1",
    "ENC-README-449": "win.offx,win.offy", "ENC-README-451": "scr.corner_wall",
    "ENC-README-452": "so.gap", "ENC-README-455": "disc.t", "ENC-README-458": "sd.slot_h", "ENC-README-460": "bat.plug_to_screen",
    # ---------------- ASSEMBLY.md
    "ENC-ASSY-001": "boss.insert_len", "ENC-ASSY-002": "boss.insert_od", "ENC-ASSY-003": "stack.pack_t", "ENC-ASSY-004": "screw.len",
    "ENC-ASSY-005": "screw.head_d,screw.head_h", "ENC-ASSY-007": "bat.foam_w,bat.foam_l", "ENC-ASSY-008": "stack.plate_to_screen",
    "ENC-ASSY-009": "stack.pack_t", "ENC-ASSY-010": {"mode": "le", "keys": ["stack.max_pack_05"]}, "ENC-ASSY-014": "pcb.t",
    "ENC-ASSY-015": "edge.left", "ENC-ASSY-016": "boss.lead_in", "ENC-ASSY-017": "boss.flush,-", "ENC-ASSY-018": "boss.insert_len",
    "ENC-ASSY-019": "boss.hole_depth", "ENC-ASSY-020": "bat.foam_w,bat.foam_l", "ENC-ASSY-023": "bat.j4_to_screen",
    "ENC-ASSY-024": "bat.plug_to_screen", "ENC-ASSY-025": "tilt.min_screen_1", "ENC-ASSY-026": {"mode": "about", "keys": ["h2.from_near_edge"]},
    "ENC-ASSY-027": "so.gap", "ENC-ASSY-031": "fpc.insertion", "ENC-ASSY-033": {"mode": "about", "keys": ["ant.fold"]},
    "ENC-ASSY-035": {"mode": "about", "keys": ["bat.bay"]}, "ENC-ASSY-037": "screw.len", "ENC-ASSY-039": {"mode": "special_m2x5"},
    # ---------------- PRINTING.md
    "ENC-PRINT-001": "disc.flange_t", "ENC-PRINT-003": "disc.t", "ENC-PRINT-005": "walls.pocket_depth", "ENC-PRINT-007": "walls.disc_over_pocket",
    "ENC-PRINT-009": "btn.h", "ENC-PRINT-011": "walls.neck", "ENC-PRINT-014": "disc.t", "ENC-PRINT-015": "body.edge_round_front",
    "ENC-PRINT-017": "win.chamfer", "ENC-PRINT-019": "neg:boss.top_z", "ENC-PRINT-021": "boss.top_to_screen", "ENC-PRINT-022": "walls.skin_recess",
    "ENC-PRINT-023": "walls.skin_relief", "ENC-PRINT-024": "walls.port_wall", "ENC-PRINT-025": "walls.flange", "ENC-PRINT-026": "btn.flange_mid_t,btn.ear_t",
    "ENC-PRINT-027": "walls.base", "ENC-PRINT-028": "walls.neck", "ENC-PRINT-029": "walls.under_head", "ENC-PRINT-030": "walls.roof",
    "ENC-PRINT-031": "neg:stack.rim", "ENC-PRINT-034": "neg:boss.face", "ENC-PRINT-036": "walls.skin_relief", "ENC-PRINT-039": "cb.depth",
    "ENC-PRINT-041": "screw.head_h", "ENC-PRINT-043": "neg:sd.slot_top,neg:sd.slot_bottom",
    # ---------------- hardware SPEC.md
    "HW-SPEC-001": "body.x,body.y", "HW-SPEC-002": {"mode": "changed", "keys": ["body.corner_r"]}, "HW-SPEC-003": "body.t",
    "HW-SPEC-005": "body.edge_round_front", "HW-SPEC-006": "walls.side", "HW-SPEC-007": "stack.skin_t,stack.skin_front,stack.skin_back",
    "HW-SPEC-008": "stack.plate_t", "HW-SPEC-009": "stack.plate_inner", "HW-SPEC-010": "h_boss_x,h_boss_y",
    "HW-SPEC-011": "body.interior_x0,body.interior_x1", "HW-SPEC-012": "body.interior_y0,body.interior_y1", "HW-SPEC-013": "stack.skin_back,stack.plate_inner",
    "HW-SPEC-015": "scr.w,scr.l,scr.t", "HW-SPEC-016": "aa.w,aa.h", "HW-SPEC-017": "aa.top_inset", "HW-SPEC-018": "aa.bottom_inset",
    "HW-SPEC-019": "scr.x0,scr.x1", "HW-SPEC-020": "scr.y1,scr.y0", "HW-SPEC-021": "aa.x0,aa.x1,aa.y0,aa.y1",
    "HW-SPEC-022": "stack.screen_front,stack.screen_back", "HW-SPEC-023": "win.margin", "HW-SPEC-024": "win.r", "HW-SPEC-026": "fpc.t",
    "HW-SPEC-027": "fpc.tail_w", "HW-SPEC-028": "flat.wide_x0,flat.wide_x1", "HW-SPEC-029": "flat.wing_x1", "HW-SPEC-030": "part_fpc_x0,part_fpc_x1",
    "HW-SPEC-031": "scr.y0,flat.wide_y1", "HW-SPEC-032": "flat.leg_x0,flat.leg_x1", "HW-SPEC-033": "flat.wide_y1,-",
    "HW-SPEC-034": "flat.tail_y0,flat.tail_y1,fpc.tail_w", "HW-SPEC-035": "flat.tail_x0,flat.tail_x1", "HW-SPEC-036": "contacts_x0,contacts_x1",
    "HW-SPEC-037": {"mode": "about", "keys": ["flat.tip_outside_wall"]}, "HW-SPEC-038": "board.top_to_screen,scr.y0,pcb.y1",
    "HW-SPEC-039": "fpc.l1_bottom,fpc.l2_top", "HW-SPEC-042": {"mode": "changed", "keys": ["fpc.fold_mid"]},
    "HW-SPEC-044": {"mode": "special_dive"}, "HW-SPEC-048": {"mode": "limit", "keys": ["-", "tallest.run", "-"], "idx": 1},
    "HW-SPEC-050": {"mode": "limit", "keys": ["tallest.ramp"]}, "HW-SPEC-051": "disc.cx,disc.cy", "HW-SPEC-052": "disc.d", "HW-SPEC-055": "disc.t",
    "HW-SPEC-057": "j2.body_h", "HW-SPEC-059": "sd.j3_body_h", "HW-SPEC-060": "part.J4.body_h", "HW-SPEC-061": "part.BZ1.w,part.BZ1.l,part.BZ1.body_h",
    "HW-SPEC-062": "pcb.t", "HW-SPEC-063": "pcb.touch", "HW-SPEC-064": "pcb.touch,pcb.comp", "HW-SPEC-065": "pcb.x0,pcb.x1,pcb.y1,pcb.y0",
    "HW-SPEC-066": "notch.r", "HW-SPEC-067": "usb.j1_x_centre", "HW-SPEC-068": "usb.face_y", "HW-SPEC-069": {"mode": "changed", "keys": ["sd.j3_open_centre"]},
    "HW-SPEC-070": {"mode": "changed", "keys": ["part.SW1.cy"]}, "HW-SPEC-071": "part.U1.x1", "HW-SPEC-072": {"mode": "changed", "keys": ["part.U1.cy"]},
    "HW-SPEC-073": {"mode": "range", "keys": ["j2.slot_y"]}, "HW-SPEC-074": {"mode": "range", "keys": ["j2.mouth_x"]},
    "HW-SPEC-075": {"mode": "changed", "keys": ["part.J4.cx", "part.J4.cy"]}, "HW-SPEC-076": "led.hole",
    "HW-SPEC-077": {"mode": "limits3"}, "HW-SPEC-078": "pin.hole", "HW-SPEC-081": "disc.d", "HW-SPEC-084": "boss.insert_len",
    "HW-SPEC-085": "boss.insert_od", "HW-SPEC-086": {"mode": "special_screws"}, "HW-SPEC-087": "motor.d,motor.h",
    # ---------------- hardware README.md
    "HW-README-001": "pcb.t", "HW-README-002": "pcb.w,pcb.h", "HW-README-003": "part.U1.x1", "HW-README-004": "part.Q5.to_ramp",
    "HW-README-005": "part.R15.body_h", "HW-README-007": "usb.face_y", "HW-README-014": "part.U1.y0,part.U1.y1", "HW-README-025": "usb.face_y",
    "HW-README-026": "usb.j1_x_centre", "HW-README-027": "usb.rec_top,usb.rec_bottom", "HW-README-028": "usb.centre_z", "HW-README-030": "sd.j3_entry",
    "HW-README-032": "sd.j3_bottom,sd.j3_cover", "HW-README-033": "sd.step_card_plane",
    "HW-README-035": "sw1.tip_x,part.SW1.cy,sw1.actuator_z", "HW-README-036": "sw1.actuator_d", "HW-README-038": "j2.mouth_x", "HW-README-039": "j2.slot_y",
    "HW-README-041": "j2.slot_z", "HW-README-044": "part.U1.x1", "HW-README-045": "part.U1.x0,part.U1.x1,part.U1.y0,part.U1.y1",
    "HW-README-047": "part.J4.y1", "HW-README-048": "part.J4.x0,part.J4.x1,part.J4.y0,part.J4.y1", "HW-README-049": "part.J4.top_z",
    "HW-README-050": "part.BZ1.cx,part.BZ1.cy", "HW-README-051": "part.BZ1.top_z", "HW-README-052": "part.LED1.cx,part.LED1.cy",
    "HW-README-053": "part.LED1.top_z", "HW-README-054": "led.hole", "HW-README-057": "h1.x,h1.y,h1.d", "HW-README-058": "h2.x,h2.y,h2.d",
    "HW-README-059": "part.PP1.cx,part.PP1.cy", "HW-README-060": "part.PP2.cx,part.PP2.cy", "HW-README-061": "part.PP3.cx,part.PP3.cy",
    "HW-README-062": "part.PP4.cx,part.PP4.cy", "HW-README-063": "stack.lowest_z", "HW-README-064": {"mode": "limit_z", "keys": ["stack.lowest_z"]},
    "HW-README-066": "part.R31.cx,part.R31.cy", "HW-README-068": "part.R32.cx,part.R32.cy", "HW-README-069": "part.R31.body_h",
    "HW-README-071": "part.R34.cx,part.R34.cy", "HW-README-072": "part.R34.body_h", "HW-README-073": "part.C26.cx,part.C26.cy",
    "HW-README-074": "part.C26.body_h", "HW-README-077": "part.J4.body_h,part.J4.top_z", "HW-README-078": "usb.j1_height",
    "HW-README-080": "part.R15.body_h", "HW-README-088": "part.U1.cy", "HW-README-089": "part.U1.y0,part.U1.y1", "HW-README-090": "part.U1.body_h",
    "HW-README-093": "part.U1.to_ramp", "HW-README-094": "part.U1.x1", "HW-README-095": "j2.slot_y,j2.mouth_x",
    "HW-README-096": {"mode": "range2", "keys": ["j2.slot_y", "j2.mouth_x"]},
    "HW-README-099": "notch.r,-,-", "HW-README-103": "board.corner_r", "HW-README-104": "notch.r", "HW-README-105": "notch.r", "HW-README-106": "j2.mouth_x,j2.slot_y",
    "HW-README-137": "pcb.t",
    # ---------------- claims added after the case fixes (doc-claims-extra.json)
    "NEW-PRINT-001": "h.rim,h.boss,h.post,h.pad,h.led", "NEW-PRINT-002": "usb.open_top_depth,usb.open_bottom_depth",
    "NEW-PRINT-003": "body.t", "NEW-ASSY-001": {"mode": "ydl_window"}, "NEW-README-001": "ov.back plate|board PCB,post.interf",
    # ---------------- build guide
    "BUILD-001": "pcb.t", "BUILD-004": "stack.pack_t", "BUILD-005": {"mode": "le", "keys": ["stack.max_pack_05"]}, "BUILD-006": "boss.insert_len",
    "BUILD-007": "boss.insert_od", "BUILD-008": "screw.len", "BUILD-009": {"mode": "special_m2x5"}, "BUILD-011": "bat.foam_w,bat.foam_l",
    "BUILD-012": "stack.plate_to_screen", "BUILD-018": {"mode": "about", "keys": ["tab.right_strip"]}, "BUILD-019": "pcb.t", "BUILD-020": "edge.left",
    "BUILD-021": "screw.len", "BUILD-022": "disc.t",
}

# the loop's ends are tangent to the plate, so the probe can place them only to about 0.1
TOL_OVERRIDE = {"ENC-README-281": 0.15}

NOT_MEASURED_BY_ID = {
    "HW-README-031": "card position from the Hirose drawing; the J3 model's open gap (x -19.24 to -7.70) is not the card guide",
    "HW-README-098": "card centre line from the Hirose drawing; the J3 model's open gap is centred at x -13.47 but is not the card guide",
    "HW-SPEC-069": None,
}

NOT_MEASURED_REASON = {
    "fpc": "FPC route length and bend values are the case model's own construction, not an independent measurement",
    "board_parts": "copper or footprint detail, not in the 3D solids",
    "print_geometry": "slicer or print analysis value",
    "wheel_disc": "label artwork or print value",
}


def decimals(quote, v):
    """Decimals the document writes the number with."""
    for s in re.findall(r"[-+]?\d+(?:\.\d+)?", quote.replace("−", "-")):
        try:
            if abs(abs(float(s)) - abs(v)) < 1e-9:
                return len(s.split(".")[1]) if "." in s else 0
        except ValueError:
            pass
    return 2


def tol_for(c, v):
    q = c["quote"].lower()
    if "about" in q or "~" in q or "roughly" in q:
        return max(0.1 * abs(v), 0.05), "about: 10 %"
    d = decimals(c["quote"], v)
    t = 0.5 * 10 ** (-d) if d < 2 else 0.0
    return max(0.02, t), (f"written to {d} decimals" if t > 0.02 else "0.02")


def get(M, k):
    if k.startswith("neg:"):
        v = M.get(k[4:])
        return None if v is None else -v
    return M.get(k)


def check(claims, M, m, cl=None):
    out = []
    for c in claims:
        r = {"id": c["id"], "doc": c["doc"], "line": c["line"], "quote": c["quote"], "subject": c["subject"],
             "doc_values": c["values"], "unit": c["unit"], "measured": None, "status": None, "note": "",
             "anchor": c.get("anchor"), "doc_values_before_fix": c.get("values_old")}
        spec = MAP.get(c["id"])
        if not c["measurable"]:
            r["status"] = "NOT MEASURED"
            r["note"] = ("not measurable in the 3D solids (marked by the extraction)" if c.get("anchor") in (None, "same text", "reworded, same numbers",
                         "reworded, numbers taken from the new text") else c["anchor"])
            out.append(r)
            continue
        if spec is None or spec == "-":
            r["status"] = "NOT MEASURED"
            r["note"] = NOT_MEASURED_BY_ID.get(c["id"]) or NOT_MEASURED_REASON.get(c["category"], "no independent probe for this claim")
            out.append(r)
            continue
        if isinstance(spec, dict):
            mode = spec["mode"]
            if mode == "special":
                r.update(status=spec["status"], measured=spec["measured"], note=spec["note"])
            elif mode == "special_m2x5":
                v = M["screw.m2x5"]
                r.update(measured=f"M2 x 5 tip {v:+.2f} past the hole bottom", status="AGREE" if v < 0 else "DISAGREE",
                         note="an M2 x 5 would bottom out")
            elif mode == "special_screws":
                v = M["screw.m2x5"]
                r.update(measured=[M["screw.len"], f"M2 x 5 bottoms ({v:+.2f})"], status="CHANGED",
                         note="SPEC allows M2 x 5; the case README restricts to M2 x 4 because x 5 bottoms out")
            elif mode == "changed":
                r.update(measured=[M.get(k) for k in spec["keys"]], status="CHANGED", note="superseded spec value; the case or board README records the change")
            elif mode == "changed_doc":
                r.update(status="CHANGED", note="superseded spec value quoted in the 'Changes from spec' table")
            elif mode == "ydl_window":
                yy = cl["ydl_403450"]
                lo, hi = yy["pack"]["window_from_screen_edge"]
                ends = [yy[f"window_{lo}"], yy[f"window_{hi}"]]
                ok = all((e["back_plate_overlap_mm3"] or 0) <= 0.001 and (e["to_back_plate"] or 0) > 0.02 for e in ends)
                nom = yy["nominal"]["near_edge_from_screen_edge"]
                r.update(measured=[nom] + [e["to_back_plate"] for e in ends],
                         status="AGREE" if ok and abs(nom - c["values"][0]) < 0.5 else "DISAGREE",
                         note=f"nominal near edge {nom:.2f} from the screen edge; clearance to the back plate {ends[0]['to_back_plate']:.2f} at "
                              f"{lo} and {ends[1]['to_back_plate']:.2f} at {hi} (to the lip {ends[1]['far_edge_to_lip_y']} in y)")
            elif mode == "special_dive":
                occ = m["extra"]["dive_zone_case_overlap_mm3"]
                tot = sum(v for v in occ.values() if v)
                r.update(measured=f"case parts in the dive zone: {tot:.3f} mm3", status="AGREE" if tot < 0.001 else "DISAGREE")
            elif mode == "limit":
                k = spec["keys"][spec.get("idx", 0)]
                lim = c["values"][spec.get("idx", 0)]
                v = M[k]
                r.update(measured=v, status="AGREE" if v <= lim + 1e-9 else "DISAGREE", note=f"tallest part (STEP, from the board face) {v:.2f} vs limit {lim}")
            elif mode == "limits3":
                vals = [M["tallest.overall"], M["tallest.run"], M["tallest.ramp"]]
                ok = all(v <= l + 1e-9 for v, l in zip(vals, c["values"]))
                r.update(measured=vals, status="AGREE" if ok else "DISAGREE",
                         note="tallest part above the board face in the STEP (includes the 0.05 the STEP leaves under each part)")
            elif mode == "limit_z":
                v = M["stack.lowest_z"]
                r.update(measured=v, status="AGREE" if v >= c["values"][0] - 1e-9 else "DISAGREE",
                         note=f"lowest part z {v:.3f} stays above the z {c['values'][0]} limit by {v - c['values'][0]:.3f}")
            elif mode in ("range", "range2"):
                vals = [M[k] for k in spec["keys"]]
                if mode == "range":
                    lo, hi = sorted(c["values"][:2])
                    ok = lo <= vals[0] <= hi
                else:
                    ok = (min(c["values"][0:2]) <= vals[0] <= max(c["values"][0:2])) and (min(c["values"][2:4]) <= vals[1] <= max(c["values"][2:4]))
                r.update(measured=vals, status="AGREE" if ok else "DISAGREE", note="inside the allowed range" if ok else "outside the range")
            elif mode in ("le", "ge", "ge_claim", "fit", "about"):
                vals = [M.get(k) for k in spec["keys"]]
                r["measured"] = vals
                cv = c["values"]
                if mode == "le":
                    ok = cv[0] <= vals[0] + 1e-9
                    r["note"] = f"document gives {cv[0]}, measured limit {vals[0]}: the document is the safe side" if ok else ""
                elif mode == "ge":
                    ok = vals[0] >= cv[0] - 1e-9
                    r["note"] = f"claim is a lower bound; measured {vals[0]}"
                elif mode == "ge_claim":
                    ok = vals[0] <= cv[0] + 0.02
                    r["note"] = f"claim is an upper bound; measured {vals[0]}"
                elif mode == "fit":
                    ok = all(cv[i] <= vals[i] + 0.02 for i in range(len(vals)) if vals[i] is not None)
                    r["note"] = "largest pack: the document's size is within the measured limit (0.3 clearance kept)"
                    if any(abs(cv[i] - vals[i]) > tol_for(c, cv[i])[0] for i in range(len(vals)) if vals[i] is not None):
                        r["note"] += f"; measured limits {vals}"
                else:
                    t = max(0.1 * abs(cv[0]), 0.05)
                    ok = abs(vals[0] - cv[0]) <= t
                    r["note"] = f"'about' claim, 10 % tolerance ({t:.2f})"
                r["status"] = "AGREE" if ok else "DISAGREE"
            out.append(r)
            continue
        keys = spec.split(",")
        meas, ok, notes = [], True, []
        any_checked = False
        for i, v in enumerate(c["values"]):
            k = keys[i] if i < len(keys) else "-"
            if k == "-":
                meas.append(None)
                continue
            if k in ("h_boss_x", "h_boss_y"):
                # boss centre from the insert solids: outer edge of the insert group less the 1.6 insert radius
                ib = next(p for p in m["parts"] if p["key"] == "inserts")["bbox"]
                val = round(ib[1] - ib[0], 3) / 2 - 1.6 if k == "h_boss_x" else round(ib[3] - ib[2], 3) / 2 - 1.6
            elif k in ("part_fpc_x0", "part_fpc_x1"):
                pb = m["fpc"]["part_bbox"]
                val = pb[0] if k.endswith("x0") else pb[1]
            elif k in ("contacts_x0", "contacts_x1"):
                val = 41.429 if k.endswith("x0") else 43.629
            else:
                val = get(M, k)
            if val is None:
                meas.append(None)
                notes.append(f"{k} not available")
                continue
            any_checked = True
            meas.append(round(val, 4) if isinstance(val, float) else val)
            t, why = tol_for(c, v)
            if c["id"] in TOL_OVERRIDE:
                t = TOL_OVERRIDE[c["id"]]
            # compare magnitudes when the document gives a size and the measurement is signed the same way
            if abs(val - v) > t + 1e-9:
                ok = False
                notes.append(f"value {i + 1}: document {v}, measured {val:.3f} (diff {val - v:+.3f}, tolerance {t:.2f})")
        r["measured"] = meas
        if not any_checked:
            r["status"] = "NOT MEASURED"
            r["note"] = "; ".join(notes) or "no probe"
        else:
            r["status"] = "AGREE" if ok else "DISAGREE"
            r["note"] = "; ".join(notes)
        out.append(r)
    return out


OFFSET = "the board STEP puts every part 0.05 below the board face (bottom at z -1.85, not -1.80); mechanical-interface.json and the documents leave this out"
CAUSE = {
    "ENC-README-055": OFFSET, "ENC-README-056": OFFSET, "ENC-README-059": OFFSET + "; the gap to the J1 shell is 0.40",
    "HW-README-027": OFFSET, "HW-README-028": OFFSET, "HW-README-032": OFFSET, "HW-README-049": OFFSET, "HW-README-051": OFFSET,
    "HW-README-063": OFFSET, "HW-README-077": OFFSET, "HW-README-078": OFFSET,
    "HW-README-041": "the J2 model's slot is centred at z -2.33 (gap -2.49 to -2.16); 0.05 of this is the STEP offset; the case model's FPC enters at -2.2 and overlaps the J2 model by 0.41 mm3",
    "ENC-README-211": "the case README describes a pocket corner that the CAD does not cut",
    "ENC-README-451": "the case README describes a pocket corner that the CAD does not cut",
    "HW-SPEC-029": "the vendor FPC is full width (x 18.72) from y -11.9 to -17.9 in the flat; the case model's routed FPC also stops short, at x 17.92",
    "HW-SPEC-031": "flat FPC outline from the vendor STEP; the wide section ends with a fillet at y -18.69",
    "HW-SPEC-032": "flat FPC outline from the vendor STEP",
    "HW-SPEC-033": "flat FPC outline from the vendor STEP",
    "HW-SPEC-035": "flat FPC outline: the tail's left end is rounded (x -12.50 on the tail centre line, -13.22 at the leg edge)",
    "HW-SPEC-057": "J2 model body; with the STEP's 0.05 offset it stands 0.95 above the board face",
    "HW-SPEC-059": "known (review MECH-5): the J3 vendor model is taller than the Hirose drawing; the case slot is sized for both",
    "HW-SPEC-061": "BZ1 in the board STEP is 5.20 x 5.28 x 2.01 (mechanical-interface.json uses 2.01)",
    "HW-README-036": "the actuator in the STEP is 1.94 across near its tip",
    "BUILD-018": "the strip is 0.27 at x 27.19 (more board than the guide says)",
}


def line_gives_measured(rows):
    """A document that keeps a drawing value but also writes the measured
    value in the same line (for example "-7.2 (-7.07 in the STEP)") agrees."""
    cache = {}
    for r in rows:
        if r["status"] != "DISAGREE" or not isinstance(r["measured"], list):
            continue
        p = os.path.join(REPO, r["doc"])
        if p not in cache:
            cache[p] = open(p).read().splitlines() if os.path.exists(p) else []
        ln = cache[p][r["line"] - 1] if 0 < r["line"] <= len(cache[p]) else ""
        k = ln.find(r["quote"][:40])
        region = ln[k:k + len(r["quote"]) + 80] if k >= 0 else ""
        nums = [abs(float(x)) for x in NUM.findall(region)]
        ok = bool(region)
        for dv, mv in zip(r["doc_values"], r["measured"]):
            if mv is None or not isinstance(mv, (int, float)):
                continue
            if abs(abs(mv) - abs(dv)) <= tol_for({"quote": r["quote"]}, dv)[0] + 1e-9:
                continue
            if not any(abs(n - abs(mv)) <= 0.011 for n in nums):
                ok = False
        if ok:
            r["status"] = "AGREE"
            r["note"] = "the same line also gives the measured value; " + r["note"]
    return rows


def explain(rows):
    """Known causes for the disagreements, added as notes."""
    for r in rows:
        if r["status"] == "DISAGREE" and r["id"] in CAUSE:
            r["cause"] = CAUSE[r["id"]]
            r["note"] = (r["note"] + "; " if r["note"] else "") + "cause: " + CAUSE[r["id"]]
    return rows


def write_md(rows, path):
    by_status = {}
    for r in rows:
        by_status.setdefault(r["status"], []).append(r)
    n = len(rows)
    L = ["# Document check, Mark-8 slab rev A", "",
         f"Generated by `diagram/build_diagram.py` on 21 November 2026. {n} dimension claims were found in the six documents. "
         f"Each measurable claim is compared with a measurement of the STEP solids made by this folder's scripts, not with the case scripts.", "",
         "| Result | Claims |", "| --- | --- |"]
    for k in ("DISAGREE", "AGREE", "CHANGED", "NOT MEASURED"):
        L.append(f"| {k} | {len(by_status.get(k, []))} |")
    L += ["", "Tolerance: 0.02, or the precision the document writes the number with (one decimal: 0.05; integer: 0.5), "
          "or 10 % where the document says \"about\". CHANGED: a superseded spec value that another document records as changed.", ""]
    for k, title in (("DISAGREE", "Claims that disagree with the measurement"), ("CHANGED", "Superseded spec values"),
                     ("AGREE", "Claims that agree"), ("NOT MEASURED", "Claims not measured")):
        rs = by_status.get(k, [])
        if not rs:
            continue
        L += [f"## {title} ({len(rs)})", "", "| Document | Line | Claim | Document value | Measured | Note |", "| --- | --- | --- | --- | --- | --- |"]
        for r in rs:
            q = r["quote"].replace("|", "/")
            mv = r["measured"]
            if isinstance(mv, list):
                mv = ", ".join("n/a" if x is None else (f"{x:.3f}" if isinstance(x, float) else str(x)) for x in mv)
            elif isinstance(mv, float):
                mv = f"{mv:.3f}"
            elif mv is None:
                mv = ""
            dv = ", ".join(str(x) for x in r["doc_values"])
            L.append(f"| {r['doc'].split('/')[-3] + '/' if 'hardware' in r['doc'] else ''}{r['doc'].split('/')[-1]} | {r['line']} | {q} | {dv} | {mv} | {r['note']} |")
        L.append("")
    open(path, "w").write("\n".join(L) + "\n")


REPO = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
NUM = re.compile(r"[-+]?\d+(?:\.\d+)?")


def _windows(line, n):
    if len(line) <= n:
        yield 0, line
        return
    step = max(1, n // 6)
    for i in range(0, len(line) - n + step, step):
        yield i, line[i:i + n]


CLAIMS_COMMIT = "adab192"     # the documents the claims list was extracted from


def _old_lines(rel):
    import subprocess
    try:
        out = subprocess.run(["git", "-C", REPO, "show", f"{CLAIMS_COMMIT}:{rel}"], capture_output=True, text=True)
        return out.stdout.splitlines() if out.returncode == 0 else []
    except Exception:  # noqa: BLE001
        return []


def reanchor(claims):
    """The claims list was extracted from the documents before the case fixes.
    Find each claim's text in the current document: same text (line updated),
    reworded with new numbers (values taken from the new text when the numbers
    line up one to one), or gone."""
    import difflib
    docs = {}
    olds = {}
    out = []
    for c in claims:
        c = dict(c)
        p = os.path.join(REPO, c["doc"])
        if p not in docs:
            docs[p] = open(p).read().splitlines() if os.path.exists(p) else []
            olds[p] = _old_lines(c["doc"])
        lines = docs[p]
        old = olds[p]
        old_line = old[c["line"] - 1] if 0 < c["line"] <= len(old) and not c["id"].startswith("NEW") else None
        q = c["quote"]
        hit = next((i for i, ln in enumerate(lines) if q in ln), None)
        if hit is not None:
            c["anchor"] = "same text"
            c["line_old"], c["line"] = c["line"], hit + 1
            out.append(c)
            continue
        words = {w for w in re.findall(r"[A-Za-z]{4,}", q.lower())}
        qs = NUM.sub("#", q)
        cands = []
        for i, ln in enumerate(lines):
            lw = set(re.findall(r"[A-Za-z]{4,}", ln.lower()))
            if len(words & lw) < max(2, len(words) // 2):
                continue
            lnq = NUM.sub("#", ln)
            sm = difflib.SequenceMatcher(None, lnq, qs, autojunk=False)
            mt = sm.find_longest_match(0, len(lnq), 0, len(qs))
            starts = {max(0, mt.a - mt.b)} if mt.size > 3 else set(st for st, _ in _windows(ln, len(q)))
            for st0 in starts:
                # map the start in the number-masked line back to the raw line, then widen to whole tokens
                raw = 0
                k = 0
                for mm in NUM.finditer(ln):
                    seg = mm.start() - raw
                    if k + seg >= st0:
                        break
                    k += seg + 1
                    raw = mm.end()
                st = raw + (st0 - k)
                a0, b0 = st, min(len(ln), st + len(q) + 6)
                while a0 > 0 and ln[a0 - 1] not in " |(":
                    a0 -= 1
                while b0 < len(ln) and ln[b0] not in " |),;":
                    b0 += 1
                win = ln[a0:b0]
                r = difflib.SequenceMatcher(None, qs, NUM.sub("#", win)).ratio()
                # the whole old line (with its row label) picks between rows that share the same quote text
                ctx = difflib.SequenceMatcher(None, old_line, ln).ratio() if old_line else 0.0
                cands.append((r, i, win, ctx))
        best = (0.0, None, None)
        if cands:
            top = max(x[0] for x in cands)
            near = [x for x in cands if x[0] >= top - 0.03]
            best = max(near, key=lambda x: (round(x[3], 2), -abs(x[1] + 1 - c["line"]), x[0]))[:3]
        if best[0] >= 0.88:
            old_nums = NUM.findall(q.replace("\u2212", "-"))
            new_nums = NUM.findall(best[2].replace("\u2212", "-"))
            c["line_old"], c["line"] = c["line"], best[1] + 1
            c["quote_old"], c["quote"] = q, best[2].strip()
            if len(old_nums) == len(new_nums):
                mp = {}
                for o, n_ in zip(old_nums, new_nums):
                    mp.setdefault(abs(float(o)), abs(float(n_)))
                newv = []
                for v in c["values"]:
                    nv = mp.get(abs(v))
                    newv.append(v if nv is None else math.copysign(nv, v) if v != 0 else nv)
                c["values_old"], c["values"] = c["values"], newv
                c["anchor"] = "reworded, numbers taken from the new text" if newv != c["values_old"] else "reworded, same numbers"
            else:
                c["anchor"] = "reworded, numbers do not line up: check by hand"
                c["measurable"] = False
            out.append(c)
            continue
        c["anchor"] = "text no longer in the document"
        c["measurable"] = False
        out.append(c)
    return out


def run():
    m = json.load(open(os.path.join(HERE, "measurements.json")))
    cl = json.load(open(os.path.join(HERE, "clearances.json")))
    claims = json.load(open(os.path.join(HERE, "doc-claims.json")))
    xp = os.path.join(HERE, "doc-claims-extra.json")
    if os.path.exists(xp):
        claims += json.load(open(xp))
    claims = reanchor(claims)
    M = build_M(m, cl)
    rows = explain(line_gives_measured(check(claims, M, m, cl)))
    note_line = next((i + 1 for i, ln in enumerate(open(os.path.join(REPO, "hardware/mark-8/slab-rev-a/README.md")).read().splitlines())
                      if "0.04 to 0.05" in ln), None)
    for r in rows:
        if r["status"] == "DISAGREE" and r.get("cause") == OFFSET and note_line:
            r["note"] += f"; the board README (line {note_line}) now notes this offset for the values above it"
    json.dump(rows, open(os.path.join(HERE, "doc-check.json"), "w"), indent=1)
    write_md(rows, os.path.join(HERE, "doc-check.md"))
    return rows


if __name__ == "__main__":
    rows = run()
    import collections
    print(collections.Counter(r["status"] for r in rows))
