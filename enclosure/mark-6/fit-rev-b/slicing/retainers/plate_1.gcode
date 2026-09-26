; HEADER_BLOCK_START
; BambuStudio 02.08.02.61
; model printing time: 4m 12s; total estimated time: 10m 27s
; total layer number: 20
; total filament length [mm] : 265.60
; total filament volume [cm^3] : 638.84
; total filament weight [g] : 0.80
; model label id: 69,80,91,102
; object max height: 4.00,4.00,4.00,4.00
; filament_density: 1.26
; filament_diameter: 1.75
; max_z_height: 4.00
; filament: 1
; support_material_on_wipe_tower: 0
; HEADER_BLOCK_END

; CONFIG_BLOCK_START
; accel_to_decel_enable = 0
; accel_to_decel_factor = 50%
; activate_air_filtration = 0
; additional_cooling_fan_speed = 70
; additional_fan_full_speed_layer = 0
; alternate_extra_wall = 0
; ams_filament_load_time_ams = 0
; ams_filament_load_time_ams_lite = 0
; ams_filament_load_time_n3f_s = 0
; ams_filament_unload_time_ams = 0
; ams_filament_unload_time_ams_lite = 0
; ams_filament_unload_time_n3f_s = 0
; apply_scarf_seam_on_circles = 1
; auxiliary_fan = 0
; avoid_crossing_wall_includes_support = 0
; bed_custom_model = 
; bed_custom_texture = 
; bed_exclude_area = 
; bed_heat_soak_area = 
; bed_temperature_formula = by_first_filament
; before_layer_change_gcode = 
; best_object_pos = 0.5,0.5
; bottom_color_penetration_layers = 3
; bottom_shell_layers = 5
; bottom_shell_thickness = 0
; bottom_surface_density = 100%
; bottom_surface_pattern = monotonic
; bridge_angle = 0
; bridge_flow = 1
; bridge_no_support = 0
; bridge_speed = 50
; brim_object_gap = 0.1
; brim_type = no_brim
; brim_width = 5
; chamber_temperatures = 0
; change_filament_gcode = ;===== A1 20251031 =======================\nM1007 S0 ; turn off mass estimation\nG392 S0\nM620 S[next_extruder]A\nM204 S9000\nG1 Z{max_layer_z + 3.0} F1200\n\nM400\nM106 P1 S0\nM106 P2 S0\n{if old_filament_temp > 142 && next_extruder < 255}\nM104 S[old_filament_temp]\n{endif}\n\nG1 X267 F18000\n\n{if long_retractions_when_cut[previous_extruder]}\nM620.11 S1 I[previous_extruder] E-{retraction_distances_when_cut[previous_extruder]} F1200\n{else}\nM620.11 S0\n{endif}\nM400\n\nM620.1 E F{flush_volumetric_speeds[previous_extruder]/2.4053*60} T{flush_temperatures[previous_extruder]}\nM620.10 A0 F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nT[next_extruder]\nM620.1 E F{flush_volumetric_speeds[next_extruder]/2.4053*60} T{flush_temperatures[next_extruder]}\nM620.10 A1 F{flush_volumetric_speeds[next_extruder]/2.4053*60} L[flush_length] H[nozzle_diameter] T{flush_temperatures[next_extruder]}\n\nG1 Y128 F9000\n\n{if next_extruder < 255}\n\n{if long_retractions_when_cut[previous_extruder]}\nM620.11 S1 I[previous_extruder] E{retraction_distances_when_cut[previous_extruder]} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nM628 S1\nG92 E0\nG1 E{retraction_distances_when_cut[previous_extruder]} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nM400\nM629 S1\n{else}\nM620.11 S0\n{endif}\n\nM400\nG92 E0\nM628 S0\n\n{if flush_length_1 > 1}\n; FLUSH_START\n; always use highest temperature to flush\nM400\nM1002 set_filament_type:UNKNOWN\nM109 S[flush_temperatures[next_extruder]]\nM106 P1 S60\n{if flush_length_1 > 23.7}\nG1 E23.7 F{flush_volumetric_speeds[previous_extruder]/2.4053*60} ; do not need pulsatile flushing for start part\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\n{else}\nG1 E{flush_length_1} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\n{endif}\n; FLUSH_END\nG1 E-[old_retract_length_toolchange] F1800\nG1 E[old_retract_length_toolchange] F300\nM400\nM1002 set_filament_type:{filament_type[next_extruder]}\n{endif}\n\n{if flush_length_1 > 45 && flush_length_2 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_2 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\n; FLUSH_END\nG1 E-[new_retract_length_toolchange] F1800\nG1 E[new_retract_length_toolchange] F300\n{endif}\n\n{if flush_length_2 > 45 && flush_length_3 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_3 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\n; FLUSH_END\nG1 E-[new_retract_length_toolchange] F1800\nG1 E[new_retract_length_toolchange] F300\n{endif}\n\n{if flush_length_3 > 45 && flush_length_4 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_4 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\n; FLUSH_END\n{endif}\n\nM629\n\nM400\nM106 P1 S60\nM109 S[new_filament_temp]\nG1 E6 F{flush_volumetric_speeds[next_extruder]/2.4053*60} ;Compensate for filament spillage during waiting temperature\nM400\nG92 E0\nG1 E-[new_retract_length_toolchange] F1800\nM400\nM106 P1 S178\nM400 S3\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nG1 X-38.2 F18000\nG1 X-48.2 F3000\nM400\nG1 Z{max_layer_z + 3.0} F3000\nM106 P1 S0\n{if layer_z <= (initial_layer_print_height + 0.001)}\nM204 S[initial_layer_acceleration]\n{else}\nM204 S[default_acceleration]\n{endif}\n{else}\nG1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F12000\n{endif}\n\nM622.1 S0\nM9833 F{outer_wall_volumetric_speed/2.4} A0.3 ; cali dynamic extrusion compensation\nM1002 judge_flag filament_need_cali_flag\nM622 J1\n  G92 E0\n  G1 E-[new_retract_length_toolchange] F1800\n  M400\n  \n  M106 P1 S178\n  M400 S4\n  G1 X-38.2 F18000\n  G1 X-48.2 F3000\n  G1 X-38.2 F18000 ;wipe and shake\n  G1 X-48.2 F3000\n  G1 X-38.2 F12000 ;wipe and shake\n  G1 X-48.2 F3000\n  M400\n  M106 P1 S0 \nM623\n\nM621 S[next_extruder]A\nG392 S0\n\nM1007 S1\n
; circle_compensation_manual_offset = 0
; circle_compensation_speed = 200
; close_additional_fan_first_x_layers = 1
; close_fan_the_first_x_layers = 1
; compatible_printers_condition = 
; complete_print_exhaust_fan_speed = 70
; cool_plate_temp = 35
; cool_plate_temp_initial_layer = 35
; cooling_filter_enabled = 0
; cooling_perimeter_transition_distance = 10
; cooling_slowdown_logic = uniform_cooling
; counter_coef_1 = 0
; counter_coef_2 = 0.008
; counter_coef_3 = -0.041
; counter_limit_max = 0.033
; counter_limit_min = -0.035
; counterbore_hole_bridging = none
; curr_bed_type = Textured PEI Plate
; default_acceleration = 6000
; default_ams_type = -1
; default_filament_colour = ""
; default_filament_profile = "Bambu PLA Basic @BBL A1"
; default_jerk = 0
; default_nozzle_volume_type = Standard
; default_print_profile = 0.20mm Standard @BBL A1
; deretraction_speed = 30
; detect_floating_vertical_shell = 1
; detect_narrow_internal_solid_infill = 1
; detect_overhang_wall = 1
; detect_thin_wall = 0
; diameter_limit = 50
; different_settings_to_system = ;;
; draft_shield = disabled
; during_print_exhaust_fan_speed = 70
; elefant_foot_compensation = 0.075
; embedding_wall_into_infill = 0
; enable_arc_fitting = 1
; enable_circle_compensation = 0
; enable_filament_dynamic_map = 0
; enable_height_slowdown = 0
; enable_long_retraction_when_cut = 2
; enable_mixed_color_sublayer = 0
; enable_order_independent_overlap_carving = 0
; enable_overhang_bridge_fan = 1
; enable_overhang_speed = 1
; enable_pre_heating = 0
; enable_pressure_advance = 0
; enable_prime_tower = 1
; enable_support = 0
; enable_support_ironing = 0
; enable_tower_interface_features = 0
; enable_wrapping_detection = 0
; enforce_support_layers = 0
; eng_plate_temp = 0
; eng_plate_temp_initial_layer = 0
; ensure_vertical_shell_thickness = enabled
; exclude_object = 1
; extruder_ams_count = 
; extruder_clearance_dist_to_rod = 56.5
; extruder_clearance_height_to_lid = 256
; extruder_clearance_height_to_rod = 25
; extruder_clearance_max_radius = 73
; extruder_colour = #018001
; extruder_max_nozzle_count = 1
; extruder_nozzle_stats = 
; extruder_offset = 0x0
; extruder_printable_area = 
; extruder_type = Direct Drive
; extruder_variant_list = "Direct Drive Standard"
; fan_cooling_layer_time = 80
; fan_direction = undefine
; fan_max_speed = 80
; fan_min_speed = 60
; farthest_point_timelapse = 0
; filament_adaptive_volumetric_speed = 0
; filament_adhesiveness_category = 100
; filament_bridge_speed = 25
; filament_change_length = 5
; filament_change_length_nc = 10
; filament_colour = #00AE42
; filament_cooling_before_tower = 0
; filament_cost = 19.99
; filament_density = 1.26
; filament_dev_ams_drying_ams_limitations = 1
; filament_dev_ams_drying_heat_distortion_temperature = 45
; filament_dev_ams_drying_temperature = 45
; filament_dev_ams_drying_time = 12
; filament_dev_chamber_drying_bed_temperature = 70
; filament_dev_chamber_drying_time = 12
; filament_dev_drying_cooling_temperature = 45
; filament_dev_drying_softening_temperature = 50
; filament_diameter = 1.75
; filament_enable_overhang_speed = 1
; filament_end_gcode = "; filament end gcode \n\n"
; filament_extruder_compatibility = 0
; filament_extruder_variant = "Direct Drive Standard"
; filament_flow_ratio = 0.98
; filament_flush_temp = 0
; filament_flush_temp_fast = 0
; filament_flush_volumetric_speed = 0
; filament_ids = GFA00
; filament_is_mixed = 0
; filament_is_support = 0
; filament_long_retractions_when_cut = 1
; filament_map = 1
; filament_map_2 = 0
; filament_map_mode = Auto For Flush
; filament_max_volumetric_speed = 21
; filament_metal_stickiness = None
; filament_minimal_purge_on_wipe_tower = 15
; filament_mixed_components = ""
; filament_mixed_gradient = 0
; filament_mixed_gradient_curve = ""
; filament_mixed_gradient_per_part = 0
; filament_mixed_gradient_range = ""
; filament_mixed_sublayer_ratios = ""
; filament_notes = 
; filament_nozzle_map = 0
; filament_overhang_1_4_speed = 0
; filament_overhang_2_4_speed = 50
; filament_overhang_3_4_speed = 30
; filament_overhang_4_4_speed = 10
; filament_overhang_totally_speed = 10
; filament_pre_cooling_temperature = 0
; filament_pre_cooling_temperature_nc = 0
; filament_preheat_temperature_delta = 0
; filament_prime_volume = 30
; filament_prime_volume_nc = 60
; filament_printable = 3
; filament_ramming_travel_time = 0
; filament_ramming_travel_time_nc = 0
; filament_ramming_volumetric_speed = -1
; filament_ramming_volumetric_speed_nc = -1
; filament_retract_length_nc = 14
; filament_retraction_distances_when_cut = 18
; filament_scarf_gap = 0%
; filament_scarf_height = 10%
; filament_scarf_length = 10
; filament_scarf_seam_type = none
; filament_self_index = 1
; filament_settings_id = "Bambu PLA Basic @BBL A1"
; filament_shrink = 100%
; filament_soluble = 0
; filament_start_gcode = "; filament start gcode\n{if  (bed_temperature[current_extruder] >55)||(bed_temperature_initial_layer[current_extruder] >55)}M106 P3 S200\n{elsif(bed_temperature[current_extruder] >50)||(bed_temperature_initial_layer[current_extruder] >50)}M106 P3 S150\n{elsif(bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}M106 P3 S50\n{endif}\n\n{if activate_air_filtration[current_extruder] && support_air_filtration}\nM106 P3 S{during_print_exhaust_fan_speed_num[current_extruder]} \n{endif}"
; filament_tower_interface_pre_extrusion_dist = 10
; filament_tower_interface_pre_extrusion_length = 0
; filament_tower_interface_print_temp = -1
; filament_tower_interface_purge_volume = 20
; filament_tower_ironing_area = 4
; filament_type = PLA
; filament_velocity_adaptation_factor = 1
; filament_vendor = "Bambu Lab"
; filament_volume_map = 0
; filename_format = {input_filename_base}_{filament_type[0]}_{print_time}.gcode
; fill_multiline = 1
; filter_out_gap_fill = 0
; first_layer_print_sequence = 0
; first_x_layer_fan_speed = 0
; first_x_layer_part_fan_speed = 0
; flush_into_infill = 0
; flush_into_objects = 0
; flush_into_support = 1
; flush_multiplier = 1
; flush_multiplier_fast = 1.2
; flush_volumes_matrix = 0,280,280,280,280,0,280,280,280,280,0,280,280,280,280,0
; flush_volumes_vector = 140,140,140,140,140,140,140,140
; full_fan_speed_layer = 0
; fuzzy_skin = none
; fuzzy_skin_first_layer = 0
; fuzzy_skin_mode = displacement
; fuzzy_skin_noise_type = classic
; fuzzy_skin_octaves = 4
; fuzzy_skin_persistence = 0.5
; fuzzy_skin_point_distance = 0.8
; fuzzy_skin_scale = 1
; fuzzy_skin_thickness = 0.3
; gap_infill_speed = 250
; gcode_add_line_number = 0
; gcode_flavor = marlin
; grab_length = 17.4
; group_algo_with_time = 0
; has_filament_switcher = 0
; has_scarf_joint_seam = 0
; head_wrap_detect_zone = 226x224,256x224,256x256,226x256
; hole_coef_1 = 0
; hole_coef_2 = -0.008
; hole_coef_3 = 0.23415
; hole_limit_max = 0.22
; hole_limit_min = 0.088
; hot_plate_temp = 65
; hot_plate_temp_initial_layer = 65
; hotend_cooling_rate = 2
; hotend_heating_rate = 2
; impact_strength_z = 13.8
; independent_support_layer_height = 1
; infill_combination = 0
; infill_direction = 45
; infill_instead_top_bottom_surfaces = 0
; infill_jerk = 9
; infill_lock_depth = 1
; infill_rotate_step = 0
; infill_shift_step = 0.4
; infill_wall_overlap = 15%
; inherits_group = ;;
; initial_layer_acceleration = 500
; initial_layer_flow_ratio = 1
; initial_layer_infill_speed = 105
; initial_layer_jerk = 9
; initial_layer_line_width = 0.5
; initial_layer_print_height = 0.2
; initial_layer_speed = 50
; initial_layer_travel_acceleration = 6000
; inner_wall_acceleration = 0
; inner_wall_jerk = 9
; inner_wall_line_width = 0.45
; inner_wall_speed = 300
; interface_shells = 0
; interlocking_beam = 0
; interlocking_beam_layer_count = 2
; interlocking_beam_width = 0.8
; interlocking_boundary_avoidance = 2
; interlocking_depth = 2
; interlocking_orientation = 22.5
; internal_bridge_support_thickness = 0.8
; internal_solid_infill_line_width = 0.42
; internal_solid_infill_pattern = zig-zag
; internal_solid_infill_speed = 250
; ironing_direction = 45
; ironing_fan_speed = -1
; ironing_flow = 10%
; ironing_inset = 0.21
; ironing_pattern = zig-zag
; ironing_spacing = 0.15
; ironing_speed = 30
; ironing_type = no ironing
; is_infill_first = 0
; layer_change_gcode = ; layer num/total_layer_count: {layer_num+1}/[total_layer_count]\n; update layer progress\nM73 L{layer_num+1}\nM991 S0 P{layer_num} ;notify layer change
; layer_height = 0.2
; line_width = 0.42
; locked_skeleton_infill_pattern = zigzag
; locked_skin_infill_pattern = crosszag
; long_retractions_when_cut = 0
; long_retractions_when_ec = 0
; machine_bed_mass_Y = 0
; machine_end_gcode = ;===== date: 20260513 =====================\nG392 S0 ;turn off nozzle clog detect\n\nM400 ; wait for buffer to clear\nG92 E0 ; zero the extruder\nG90\nG1 Z{max_layer_z + 0.4} F900 ; lower z a little\nG1 X0 Y{first_layer_center_no_wipe_tower[1]} F18000 ; move to safe pos\nG1 X-13.0 F3000 ; move to safe pos\n{if !spiral_mode && print_sequence != \"by object\"}\nM1002 judge_flag timelapse_record_flag\nM622 J1\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM991 S0 P-1 ;end timelapse at safe pos\nM623\n{endif}\n\nM140 S0 ; turn off bed\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off remote part cooling fan\nM106 P3 S0 ; turn off chamber cooling fan\n\n;G1 X27 F15000 ; wipe\n\n; pull back filament to AMS\nM620 S255\nG1 X267 F15000\nT255\nG1 X-28.5 F18000\nG1 X-48.2 F3000\nG1 X-28.5 F18000\nG1 X-48.2 F3000\nM621 S255\n\nM104 S0 ; turn off hotend\n\nM400 ; wait all motion done\nM17 S\nM17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom\n{if (max_layer_z + 100.0) < 256}\n    G1 Z{max_layer_z + 100.0} F600\n    G1 Z{max_layer_z +98.0}\n{else}\n    G1 Z256 F600\n    G1 Z256\n{endif}\nM400 P100\nM17 R ; restore z current\n\nG90\nG1 X-48 Y180 F3600\n\nM220 S100  ; Reset feedrate magnitude\nM201.2 K1.0 ; Reset acc magnitude\nM73.2   R1.0 ;Reset left time magnitude\nM1002 set_gcode_claim_speed_level : 0\n\n;=====printer finish  sound=========\nM17\nM400 S1\nM1006 S1\nM1006 A0 B20 L100 C37 D20 M40 E42 F20 N60\nM1006 A0 B10 L100 C44 D10 M60 E44 F10 N60\nM1006 A0 B10 L100 C46 D10 M80 E46 F10 N80\nM1006 A44 B20 L100 C39 D20 M60 E48 F20 N60\nM1006 A0 B10 L100 C44 D10 M60 E44 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A0 B10 L100 C39 D10 M60 E39 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A0 B10 L100 C44 D10 M60 E44 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A0 B10 L100 C39 D10 M60 E39 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A0 B10 L100 C48 D10 M60 E44 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10  N80\nM1006 A44 B20 L100 C49 D20 M80 E41 F20 N80\nM1006 A0 B20 L100 C0 D20 M60 E0 F20 N80\nM1006 A0 B20 L100 C37 D20 M30 E37 F20 N60\nM1006 W\n;=====printer finish  sound=========\n\n;M17 X0.8 Y0.8 Z0.5 ; lower motor current to 45% power\nM400\nM18 X Y Z\n\n
; machine_hotend_change_time = 0
; machine_load_filament_time = 25
; machine_max_acceleration_e = 5000,5000
; machine_max_acceleration_extruding = 12000,12000
; machine_max_acceleration_retracting = 5000,5000
; machine_max_acceleration_travel = 6000,6000
; machine_max_acceleration_x = 6000,6000
; machine_max_acceleration_y = 6000,6000
; machine_max_acceleration_z = 1500,1500
; machine_max_force_Y = 0
; machine_max_jerk_e = 3,3
; machine_max_jerk_x = 9,9
; machine_max_jerk_y = 9,9
; machine_max_jerk_z = 3,3
; machine_max_printed_mass = 0
; machine_max_speed_e = 30,30
; machine_max_speed_x = 500,200
; machine_max_speed_y = 500,200
; machine_max_speed_z = 30,30
; machine_min_extruding_rate = 0,0
; machine_min_travel_rate = 0,0
; machine_pause_gcode = M400 U1
; machine_prepare_compensation_time = 260
; machine_start_gcode = ;===== machine: A1 =========================\n;===== date: 20260513 ==================\nG392 S0\nM9833.2\n;M400\n;M73 P1.717\n\n;===== start to heat heatbead&hotend==========\nM1002 gcode_claim_action : 2\nM1002 set_filament_type:{filament_type[initial_no_support_extruder]}\nM104 S140\nM140 S[bed_temperature_initial_layer_single]\n\n;=====start printer sound ===================\nM17\nM400 S1\nM1006 S1\nM1006 A0 B10 L100 C37 D10 M60 E37 F10 N60\nM1006 A0 B10 L100 C41 D10 M60 E41 F10 N60\nM1006 A0 B10 L100 C44 D10 M60 E44 F10 N60\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N60\nM1006 A43 B10 L100 C46 D10 M70 E39 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N80\nM1006 A0 B10 L100 C43 D10 M60 E39 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N80\nM1006 A0 B10 L100 C41 D10 M80 E41 F10 N80\nM1006 A0 B10 L100 C44 D10 M80 E44 F10 N80\nM1006 A0 B10 L100 C49 D10 M80 E49 F10 N80\nM1006 A0 B10 L100 C0 D10 M80 E0 F10 N80\nM1006 A44 B10 L100 C48 D10 M60 E39 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N80\nM1006 A0 B10 L100 C44 D10 M80 E39 F10 N80\nM1006 A0 B10 L100 C0 D10 M60 E0 F10 N80\nM1006 A43 B10 L100 C46 D10 M60 E39 F10 N80\nM1006 W\nM18 \n;=====start printer sound ===================\n\n;=====avoid end stop =================\nG91\nG380 S2 Z40 F1200\nG380 S3 Z-15 F1200\nG90\n\n;===== reset machine status =================\n;M290 X39 Y39 Z8\nM204 S6000\n\nM630 S0 P0\nG91\nM17 Z0.3 ; lower the z-motor current\n\nG90\nM17 X0.65 Y1.2 Z0.6 ; reset motor current to default\nM960 S5 P1 ; turn on logo lamp\nG90\nM220 S100 ;Reset Feedrate\nM221 S100 ;Reset Flowrate\nM73.2   R1.0 ;Reset left time magnitude\n;M211 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem\n\n;====== cog noise reduction=================\nM982.2 S1 ; turn on cog noise reduction\n\nM1002 gcode_claim_action : 13\n\nG28 X\nG91\nG1 Z5 F1200\nG90\nG0 X128 F30000\nG0 Y254 F3000\nG91\nG1 Z-5 F1200\n\nM109 S25 H140\n\nM17 E0.3\nM83\nG1 E10 F1200\nG1 E-0.5 F30\nM17 D\n\nG28 Z P0 T140; home z with low precision,permit 300deg temperature\nM104 S{nozzle_temperature_initial_layer[initial_extruder]}\n\nM1002 judge_flag build_plate_detect_flag\nM622 S1\n  G39.4\n  G90\n  G1 Z5 F1200\nM623\n\n;M400\n;M73 P1.717\n\n;===== prepare print temperature and material ==========\nM1002 gcode_claim_action : 24\n\nM400\n;G392 S1\nM211 X0 Y0 Z0 ;turn off soft endstop\nM975 S1 ; turn on\n\nG90\nG1 X-28.5 F30000\nG1 X-48.2 F3000\n\nM620 M ;enable remap\nM620 S[initial_no_support_extruder]A   ; switch material if AMS exist\n    M1002 gcode_claim_action : 4\n    M400\n    M1002 set_filament_type:UNKNOWN\n    M109 S[nozzle_temperature_initial_layer]\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M104 S220\n{else}\n    M104 S250\n{endif}\n    M400\n    T[initial_no_support_extruder]\n    G1 X-48.2 F3000\n    M400\n\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M620.1 E F{flush_volumetric_speeds[initial_no_support_extruder]/2.4053*60} T220\n    M109 S220 ;set nozzle to common flush temp\n{else}\n    M620.1 E F{flush_volumetric_speeds[initial_no_support_extruder]/2.4053*60} T{flush_temperatures[initial_no_support_extruder]}\n    M109 S250 ;set nozzle to common flush temp\n{endif}\n    M106 P1 S0\n    G92 E0\n    G1 E50 F200\n    M400\n    M1002 set_filament_type:{filament_type[initial_no_support_extruder]}\nM621 S[initial_no_support_extruder]A\n\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M109 S220 H300\n{else}\n    M109 S{flush_temperatures[initial_no_support_extruder]} H300\n{endif}\nG92 E0\nG1 E50 F200 ; lower extrusion speed to avoid clog\nM400\nM106 P1 S178\nG92 E0\nG1 E5 F200\nM104 S{nozzle_temperature_initial_layer[initial_no_support_extruder]}\nG92 E0\nG1 E-0.5 F300\n\nG1 X-28.5 F30000\nG1 X-48.2 F3000\nG1 X-28.5 F30000 ;wipe and shake\nG1 X-48.2 F3000\nG1 X-28.5 F30000 ;wipe and shake\nG1 X-48.2 F3000\n\n;G392 S0\n\nM400\nM106 P1 S0\n;===== prepare print temperature and material end =====\n\n;M400\n;M73 P1.717\n\n;===== auto extrude cali start =========================\nM975 S1\n;G392 S1\n\nG90\nM83\nT1000\nG1 X-48.2 Y0 Z10 F10000\nM400\nM1002 set_filament_type:UNKNOWN\n\nM412 S1 ;  ===turn on  filament runout detection===\nM400 P10\nM620.3 W1; === turn on filament tangle detection===\nM400 S2\n\nM1002 set_filament_type:{filament_type[initial_no_support_extruder]}\n\n;M1002 set_flag extrude_cali_flag=1\nM1002 judge_flag extrude_cali_flag\n\nM622 J1\n    M1002 gcode_claim_action : 8\n\n    M109 S{nozzle_temperature[initial_extruder]}\n    G1 E10 F{outer_wall_volumetric_speed/2.4*60}\n    M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation\n\n    M106 P1 S255\n    M400 S5\n    G1 X-28.5 F18000\n    G1 X-48.2 F3000\n    G1 X-28.5 F18000 ;wipe and shake\n    G1 X-48.2 F3000\n    G1 X-28.5 F12000 ;wipe and shake\n    G1 X-48.2 F3000\n    M400\n    M106 P1 S0\n\n    M1002 judge_last_extrude_cali_success\n    M622 J0\n        M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation\n        M106 P1 S255\n        M400 S5\n        G1 X-28.5 F18000\n        G1 X-48.2 F3000\n        G1 X-28.5 F18000 ;wipe and shake\n        G1 X-48.2 F3000\n        G1 X-28.5 F12000 ;wipe and shake\n        M400\n        M106 P1 S0\n    M623\n    \n    G1 X-48.2 F3000\n    M400\n    M984 A0.1 E1 S1 F{outer_wall_volumetric_speed/2.4} H[nozzle_diameter]\n    M106 P1 S178\n    M400 S7\n    G1 X-28.5 F18000\n    G1 X-48.2 F3000\n    G1 X-28.5 F18000 ;wipe and shake\n    G1 X-48.2 F3000\n    G1 X-28.5 F12000 ;wipe and shake\n    G1 X-48.2 F3000\n    M400\n    M106 P1 S0\nM623 ; end of \"draw extrinsic para cali paint\"\n\n;G392 S0\n;===== auto extrude cali end ========================\n\n;M400\n;M73 P1.717\n\nM104 S170 ; prepare to wipe nozzle\nM106 S255 ; turn on fan\n\n;===== mech mode fast check start =====================\nM1002 gcode_claim_action : 3\n\nG1 X128 Y128 F20000\nG1 Z5 F1200\nM400 P200\nM970.3 Q1 A5 K0 O3\nM974 Q1 S2 P0\n\nM970.2 Q1 K1 W58 Z0.1\nM974 S2\n\nG1 X128 Y128 F20000\nG1 Z5 F1200\nM400 P200\nM970.3 Q0 A10 K0 O1\nM974 Q0 S2 P0\n\nM970.2 Q0 K1 W78 Z0.1\nM974 S2\n\nM975 S1\nG1 F30000\nG1 X0 Y5\nG28 X ; re-home XY\n\nG1 Z4 F1200\n\n;===== mech mode fast check end =======================\n\n;M400\n;M73 P1.717\n\n;===== wipe nozzle ===============================\nM1002 gcode_claim_action : 14\n\nM975 S1\nM106 S255 ; turn on fan (G28 has turn off fan)\nM211 S; push soft endstop status\nM211 X0 Y0 Z0 ;turn off Z axis endstop\n\n;===== remove waste by touching start =====\n\nM104 S170 ; set temp down to heatbed acceptable\n\nM83\nG1 E-1 F500\nG90\nM83\n\nM109 S170\nG0 X108 Y-0.5 F30000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X110 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X112 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X114 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X116 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X118 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X120 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X122 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X124 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X126 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X128 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X130 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X132 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X134 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X136 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X138 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X140 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X142 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X144 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X146 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X148 F10000\nG380 S3 Z-5 F1200\n\nG1 Z5 F30000\n;===== remove waste by touching end =====\n\nG1 Z10 F1200\nG0 X118 Y261 F30000\nG1 Z5 F1200\nM109 S{nozzle_temperature_initial_layer[initial_extruder]-50}\n\nG28 Z P0 T300; home z with low precision,permit 300deg temperature\nG29.2 S0 ; turn off ABL\nM104 S140 ; prepare to abl\nG0 Z5 F20000\n\nG0 X128 Y261 F20000  ; move to exposed steel surface\nG0 Z-1.01 F1200      ; stop the nozzle\n\nG91\nG2 I1 J0 X2 Y0 F2000.1\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\n\nG90\nG1 Z10 F1200\n\n;===== brush material wipe nozzle =====\n\nG90\nG1 Y250 F30000\nG1 X55\nG1 Z1.300 F1200\nG1 Y262.5 F6000\nG91\nG1 X-35 F30000\nG1 Y-0.5\nG1 X45\nG1 Y-0.5\nG1 X-45\nG1 Y-0.5\nG1 X45\nG1 Y-0.5\nG1 X-45\nG1 Y-0.5\nG1 X45\nG1 Z5.000 F1200\n\nG90\nG1 X30 Y250.000 F30000\nG1 Z1.300 F1200\nG1 Y262.5 F6000\nG91\nG1 X35 F30000\nG1 Y-0.5\nG1 X-45\nG1 Y-0.5\nG1 X45\nG1 Y-0.5\nG1 X-45\nG1 Y-0.5\nG1 X45\nG1 Y-0.5\nG1 X-45\nG1 Z10.000 F1200\n\n;===== brush material wipe nozzle end =====\n\nG90\n;G0 X128 Y261 F20000  ; move to exposed steel surface\nG1 Y250 F30000\nG1 X138\nG1 Y261\nG0 Z-1.01 F1200      ; stop the nozzle\n\nG91\nG2 I1 J0 X2 Y0 F2000.1\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\n\nM109 S140\nM106 S255 ; turn on fan (G28 has turn off fan)\n\nM211 R; pop softend status\n\n;===== wipe nozzle end ================================\n\n;M400\n;M73 P1.717\n\n;===== bed leveling ==================================\nM1002 judge_flag g29_before_print_flag\n\nG90\nG1 Z5 F1200\nG1 X0 Y0 F30000\nG29.2 S1 ; turn on ABL\n\nM190 S[bed_temperature_initial_layer_single]; ensure bed temp\nM109 S140\nM106 S0 ; turn off fan , too noisy\n\nM622 J1\n    M1002 gcode_claim_action : 1\n    G29 A1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}\n    M400\n    M500 ; save cali data\nM623\n;===== bed leveling end ================================\n\n;===== home after wipe mouth============================\nM1002 judge_flag g29_before_print_flag\nM622 J0\n\n    M1002 gcode_claim_action : 13\n    G28\n\nM623\n\n;===== home after wipe mouth end =======================\n\n;M400\n;M73 P1.717\n\nG1 X108.000 Y-0.500 F30000\nG1 Z0.300 F1200\nM400\nG2814 Z0.32\n\nM104 S{nozzle_temperature_initial_layer[initial_extruder]} ; prepare to print\n\n;===== nozzle load line ===============================\n;G90\n;M83\n;G1 Z5 F1200\n;G1 X88 Y-0.5 F20000\n;G1 Z0.3 F1200\n\n;M109 S{nozzle_temperature_initial_layer[initial_extruder]}\n\n;G1 E2 F300\n;G1 X168 E4.989 F6000\n;G1 Z1 F1200\n;===== nozzle load line end ===========================\n\n;===== extrude cali test ===============================\n\nM400\n    M900 S\n    M900 C\n    G90\n    M83\n\n    M109 S{nozzle_temperature_initial_layer[initial_extruder]}\n    G0 X128 E8  F{outer_wall_volumetric_speed/(24/20)    * 60}\n    G0 X133 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X138 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X143 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X148 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X153 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G91\n    G1 X1 Z-0.300\n    G1 X4\n    G1 Z1 F1200\n    G90\n    M400\n\nM900 R\n\nM1002 judge_flag extrude_cali_flag\nM622 J1\n    G90\n    G1 X108.000 Y1.000 F30000\n    G91\n    G1 Z-0.700 F1200\n    G90\n    M83\n    G0 X128 E10  F{outer_wall_volumetric_speed/(24/20)    * 60}\n    G0 X133 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X138 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X143 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X148 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X153 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G91\n    G1 X1 Z-0.300\n    G1 X4\n    G1 Z1 F1200\n    G90\n    M400\nM623\n\nG1 Z0.2\n\n;M400\n;M73 P1.717\n\n;========turn off light and wait extrude temperature =============\nM1002 gcode_claim_action : 0\nM400\n\n;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==\n;curr_bed_type={curr_bed_type}\n{if curr_bed_type==\"Textured PEI Plate\"}\nG29.1 Z{-0.02} ; for Textured PEI Plate\n{endif}\n\nM960 S1 P0 ; turn off laser\nM960 S2 P0 ; turn off laser\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off big fan\nM106 P3 S0 ; turn off chamber fan\n\nM975 S1 ; turn on mech mode supression\nG90\nM83\nT1000\n\nM211 X0 Y0 Z0 ;turn off soft endstop\n;G392 S1 ; turn on clog detection\nM1007 S1 ; turn on mass estimation\nG29.4\n
; machine_switch_extruder_time = 0
; machine_unload_filament_time = 29
; master_extruder_id = 1
; max_bridge_length = 0
; max_layer_height = 0.28
; max_travel_detour_distance = 0
; min_bead_width = 85%
; min_feature_size = 25%
; min_layer_height = 0.08
; minimum_sparse_infill_area = 15
; mmu_segmented_region_interlocking_depth = 0
; mmu_segmented_region_max_width = 0
; monotonic_travel_into_wall = 0%
; no_slow_down_for_cooling_on_outwalls = 0
; nozzle_diameter = 0.4
; nozzle_flush_dataset = 0
; nozzle_height = 4.76
; nozzle_temperature = 220
; nozzle_temperature_initial_layer = 220
; nozzle_temperature_range_high = 240
; nozzle_temperature_range_low = 190
; nozzle_type = stainless_steel
; nozzle_volume = 92
; nozzle_volume_type = Standard
; only_one_wall_first_layer = 0
; ooze_prevention = 0
; other_layers_print_sequence = 0
; other_layers_print_sequence_nums = 0
; outer_wall_acceleration = 5000
; outer_wall_jerk = 9
; outer_wall_line_width = 0.42
; outer_wall_speed = 200
; overhang_1_4_speed = 0
; overhang_2_4_speed = 50
; overhang_3_4_speed = 30
; overhang_4_4_speed = 10
; overhang_fan_speed = 100
; overhang_fan_threshold = 50%
; overhang_threshold_participating_cooling = 95%
; overhang_totally_speed = 10
; override_filament_scarf_seam_setting = 0
; override_process_overhang_speed = 0
; physical_extruder_map = 0
; post_process = 
; pre_start_fan_time = 2
; precise_outer_wall = 0
; precise_z_height = 0
; pressure_advance = 0.02
; prime_tower_brim_width = 3
; prime_tower_enable_framework = 0
; prime_tower_extra_rib_length = 0
; prime_tower_fillet_wall = 1
; prime_tower_flat_ironing = 0
; prime_tower_infill_gap = 150%
; prime_tower_lift_height = -1
; prime_tower_lift_speed = 90
; prime_tower_max_speed = 90
; prime_tower_rib_wall = 1
; prime_tower_rib_width = 8
; prime_tower_skip_points = 1
; prime_tower_width = 35
; prime_volume_mode = Default
; print_compatible_printers = "Bambu Lab A1 0.4 nozzle"
; print_extruder_id = 1
; print_extruder_variant = "Direct Drive Standard"
; print_flow_ratio = 1
; print_in_clockwise = 0
; print_sequence = by layer
; print_settings_id = Harmony M6 revision B - 0.20mm A1
; printable_area = 0x0,256x0,256x256,0x256
; printable_height = 256
; printer_extruder_id = 1
; printer_extruder_variant = "Direct Drive Standard"
; printer_model = Bambu Lab A1
; printer_notes = 
; printer_settings_id = Bambu Lab A1 0.4 nozzle
; printer_structure = i3
; printer_technology = FFF
; printer_variant = 0.4
; printing_by_object_gcode = 
; process_notes = 
; raft_contact_distance = 0.1
; raft_expansion = 1.5
; raft_first_layer_density = 90%
; raft_first_layer_expansion = -1
; raft_layers = 0
; reduce_crossing_wall = 0
; reduce_fan_stop_start_freq = 1
; reduce_infill_retraction_mode = Auto
; required_nozzle_HRC = 3
; resolution = 0.012
; retract_before_wipe = 0%
; retract_length_toolchange = 2
; retract_lift_above = 0
; retract_lift_below = 255
; retract_restart_extra = 0
; retract_restart_extra_toolchange = 0
; retract_when_changing_layer = 1
; retraction_distances_when_cut = 18
; retraction_distances_when_ec = 0
; retraction_length = 0.8
; retraction_minimum_travel = 1
; retraction_speed = 30
; role_base_wipe_speed = 1
; scan_first_layer = 0
; scarf_angle_threshold = 155
; seam_gap = 15%
; seam_placement_away_from_overhangs = 0
; seam_position = aligned
; seam_slope_conditional = 1
; seam_slope_entire_loop = 0
; seam_slope_gap = 0
; seam_slope_inner_walls = 1
; seam_slope_min_length = 10
; seam_slope_start_height = 10%
; seam_slope_steps = 10
; seam_slope_type = none
; silent_mode = 0
; single_extruder_multi_material = 1
; skeleton_infill_density = 15%
; skeleton_infill_line_width = 0.45
; skin_infill_density = 15%
; skin_infill_depth = 2
; skin_infill_line_width = 0.45
; skirt_distance = 2
; skirt_height = 1
; skirt_loops = 0
; skirt_per_object = 1
; slice_closing_radius = 0.049
; slicing_mode = regular
; slow_down_for_layer_cooling = 1
; slow_down_layer_time = 6
; slow_down_min_speed = 20
; slowdown_end_acc = 100000
; slowdown_end_height = 400
; slowdown_end_speed = 1000
; slowdown_start_acc = 100000
; slowdown_start_height = 0
; slowdown_start_speed = 1000
; small_perimeter_speed = 50%
; small_perimeter_threshold = 0
; smooth_coefficient = 80
; smooth_speed_discontinuity_area = 1
; solid_infill_filament = 0
; sparse_infill_acceleration = 100%
; sparse_infill_anchor = 400%
; sparse_infill_anchor_max = 20
; sparse_infill_density = 15%
; sparse_infill_filament = 0
; sparse_infill_lattice_angle_1 = -45
; sparse_infill_lattice_angle_2 = 45
; sparse_infill_line_width = 0.45
; sparse_infill_pattern = gyroid
; sparse_infill_speed = 270
; spiral_mode = 0
; spiral_mode_max_xy_smoothing = 200%
; spiral_mode_smooth = 0
; standby_temperature_delta = -5
; start_end_points = 30x-3,54x245
; supertack_plate_temp = 45
; supertack_plate_temp_initial_layer = 45
; support_air_filtration = 0
; support_angle = 0
; support_base_pattern = default
; support_base_pattern_spacing = 2.5
; support_bottom_interface_spacing = 0.5
; support_bottom_z_distance = 0.2
; support_chamber_temp_control = 0
; support_cooling_filter = 0
; support_critical_regions_only = 0
; support_expansion = 0
; support_fast_purge_mode = 0
; support_filament = 0
; support_interface_bottom_layers = 2
; support_interface_filament = 0
; support_interface_loop_pattern = 0
; support_interface_not_for_body = 1
; support_interface_pattern = auto
; support_interface_spacing = 0.5
; support_interface_speed = 80
; support_interface_top_layers = 2
; support_ironing_direction = 0
; support_ironing_flow = 10%
; support_ironing_inset = 0
; support_ironing_pattern = zig-zag
; support_ironing_spacing = 0.15
; support_ironing_speed = 30
; support_line_width = 0.42
; support_object_first_layer_gap = 0.2
; support_object_skip_flush = 0
; support_object_xy_distance = 0.35
; support_on_build_plate_only = 0
; support_remove_small_overhang = 1
; support_speed = 150
; support_style = default
; support_threshold_angle = 30
; support_top_z_distance = 0.2
; support_type = tree(auto)
; symmetric_infill_y_axis = 0
; temperature_vitrification = 45
; template_custom_gcode = 
; textured_plate_temp = 65
; textured_plate_temp_initial_layer = 65
; thick_bridges = 0
; thumbnail_size = 50x50
; time_lapse_gcode = ;===================== date: 20250206 =====================\n{if !spiral_mode && print_sequence != \"by object\"}\n; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer\n; SKIPPABLE_START\n; SKIPTYPE: timelapse\nM622.1 S1 ; for prev firmware, default turned on\nM1002 judge_flag timelapse_record_flag\nM622 J1\nG92 E0\nG1 Z{max_layer_z + 0.4}\nG1 X0 Y{first_layer_center_no_wipe_tower[1]} F18000 ; move to safe pos\nG1 X-48.2 F3000 ; move to safe pos\nM400\nM1004 S5 P1  ; external shutter\nM400 P300\nM971 S11 C11 O0\nG92 E0\nG1 X0 F18000\nM623\n\n; SKIPTYPE: head_wrap_detect\nM622.1 S1\nM1002 judge_flag g39_3rd_layer_detect_flag\nM622 J1\n    ; enable nozzle clog detect at 3rd layer\n    {if layer_num == 2}\n      M400\n      G90\n      M83\n      M204 S5000\n      G0 Z2 F4000\n      G0 X261 Y250 F20000\n      M400 P200\n      G39 S1\n      G0 Z2 F4000\n    {endif}\n\n\n    M622.1 S1\n    M1002 judge_flag g39_detection_flag\n    M622 J1\n      {if !in_head_wrap_detect_zone}\n        M622.1 S0\n        M1002 judge_flag g39_mass_exceed_flag\n        M622 J1\n        {if layer_num > 2}\n            G392 S0\n            M400\n            G90\n            M83\n            M204 S5000\n            G0 Z{max_layer_z + 0.4} F4000\n            G39.3 S1\n            G0 Z{max_layer_z + 0.4} F4000\n            G392 S0\n          {endif}\n        M623\n    {endif}\n    M623\nM623\n; SKIPPABLE_END\n{endif}\n
; timelapse_type = 0
; top_area_threshold = 200%
; top_color_penetration_layers = 5
; top_one_wall_type = all top
; top_shell_layers = 5
; top_shell_thickness = 1
; top_solid_infill_flow_ratio = 1
; top_surface_acceleration = 2000
; top_surface_density = 100%
; top_surface_jerk = 9
; top_surface_line_width = 0.42
; top_surface_pattern = monotonicline
; top_surface_speed = 200
; top_z_overrides_xy_distance = 0
; travel_acceleration = 10000
; travel_jerk = 9
; travel_short_distance_acceleration = 250
; travel_speed = 700
; travel_speed_z = 0
; tree_support_branch_angle = 45
; tree_support_branch_diameter = 2
; tree_support_branch_diameter_angle = 5
; tree_support_branch_distance = 5
; tree_support_wall_count = -1
; upward_compatible_machine = "Bambu Lab H2D 0.4 nozzle";"Bambu Lab H2D Pro 0.4 nozzle";"Bambu Lab H2S 0.4 nozzle";"Bambu Lab P2S 0.4 nozzle";"Bambu Lab H2C 0.4 nozzle";"Bambu Lab X2D 0.4 nozzle";"Bambu Lab A2L 0.4 nozzle"
; use_firmware_retraction = 0
; use_relative_e_distances = 1
; vertical_shell_speed = 80%
; volumetric_speed_coefficients = "0 0 0 0 0 0"
; wall_distribution_count = 1
; wall_filament = 0
; wall_generator = classic
; wall_loops = 4
; wall_sequence = inner wall/outer wall
; wall_transition_angle = 10
; wall_transition_filter_deviation = 25%
; wall_transition_length = 100%
; wipe = 1
; wipe_distance = 2
; wipe_speed = 80%
; wipe_tower_no_sparse_layers = 0
; wipe_tower_rotation_angle = 0
; wipe_tower_x = 15
; wipe_tower_y = 220
; wrapping_detection_gcode = 
; wrapping_detection_layers = 20
; wrapping_exclude_area = 
; xy_contour_compensation = 0
; xy_hole_compensation = 0
; z_direction_outwall_speed_continuous = 0
; z_hop = 0.4
; z_hop_types = Auto Lift
; CONFIG_BLOCK_END

; EXECUTABLE_BLOCK_START
M73 P0 R10
M201 X6000 Y6000 Z1500 E5000
M203 X500 Y500 Z30 E30
M204 P12000 R5000 T12000
M205 X9.00 Y9.00 Z3.00 E3.00
M106 S0
; FEATURE: Custom
;===== machine: A1 =========================
;===== date: 20260513 ==================
G392 S0
M9833.2
;M400
;M73 P1.717

;===== start to heat heatbead&hotend==========
M1002 gcode_claim_action : 2
M1002 set_filament_type:PLA
M104 S140
M140 S65

;=====start printer sound ===================
M17
M400 S1
M1006 S1
M1006 A0 B10 L100 C37 D10 M60 E37 F10 N60
M1006 A0 B10 L100 C41 D10 M60 E41 F10 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A43 B10 L100 C46 D10 M70 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C43 D10 M60 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C41 D10 M80 E41 F10 N80
M1006 A0 B10 L100 C44 D10 M80 E44 F10 N80
M1006 A0 B10 L100 C49 D10 M80 E49 F10 N80
M1006 A0 B10 L100 C0 D10 M80 E0 F10 N80
M1006 A44 B10 L100 C48 D10 M60 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C44 D10 M80 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A43 B10 L100 C46 D10 M60 E39 F10 N80
M1006 W
M18 
;=====start printer sound ===================

;=====avoid end stop =================
G91
G380 S2 Z40 F1200
G380 S3 Z-15 F1200
G90

;===== reset machine status =================
;M290 X39 Y39 Z8
M204 S6000

M630 S0 P0
G91
M17 Z0.3 ; lower the z-motor current

G90
M17 X0.65 Y1.2 Z0.6 ; reset motor current to default
M960 S5 P1 ; turn on logo lamp
G90
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
;M211 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem

;====== cog noise reduction=================
M982.2 S1 ; turn on cog noise reduction

M1002 gcode_claim_action : 13

G28 X
G91
G1 Z5 F1200
G90
G0 X128 F30000
G0 Y254 F3000
G91
G1 Z-5 F1200

M109 S25 H140

M17 E0.3
M83
G1 E10 F1200
G1 E-0.5 F30
M17 D

G28 Z P0 T140; home z with low precision,permit 300deg temperature
M104 S220

M1002 judge_flag build_plate_detect_flag
M622 S1
  G39.4
  G90
M73 P1 R10
  G1 Z5 F1200
M623

;M400
;M73 P1.717

;===== prepare print temperature and material ==========
M1002 gcode_claim_action : 24

M400
;G392 S1
M211 X0 Y0 Z0 ;turn off soft endstop
M975 S1 ; turn on

G90
G1 X-28.5 F30000
G1 X-48.2 F3000

M620 M ;enable remap
M620 S0A   ; switch material if AMS exist
    M1002 gcode_claim_action : 4
    M400
    M1002 set_filament_type:UNKNOWN
    M109 S220

    M104 S220

    M400
    T0
    G1 X-48.2 F3000
    M400


    M620.1 E F523.843 T220
    M109 S220 ;set nozzle to common flush temp

    M106 P1 S0
    G92 E0
    G1 E50 F200
    M400
    M1002 set_filament_type:PLA
M621 S0A


    M109 S220 H300

G92 E0
G1 E50 F200 ; lower extrusion speed to avoid clog
M400
M106 P1 S178
G92 E0
G1 E5 F200
M104 S220
G92 E0
M73 P5 R9
G1 E-0.5 F300

G1 X-28.5 F30000
M73 P7 R9
G1 X-48.2 F3000
M73 P10 R9
G1 X-28.5 F30000 ;wipe and shake
G1 X-48.2 F3000
G1 X-28.5 F30000 ;wipe and shake
G1 X-48.2 F3000

;G392 S0

M400
M106 P1 S0
;===== prepare print temperature and material end =====

;M400
;M73 P1.717

;===== auto extrude cali start =========================
M975 S1
;G392 S1

G90
M83
T1000
G1 X-48.2 Y0 Z10 F10000
M400
M1002 set_filament_type:UNKNOWN

M412 S1 ;  ===turn on  filament runout detection===
M400 P10
M620.3 W1; === turn on filament tangle detection===
M400 S2

M1002 set_filament_type:PLA

;M1002 set_flag extrude_cali_flag=1
M1002 judge_flag extrude_cali_flag

M622 J1
    M1002 gcode_claim_action : 8

    M109 S220
    G1 E10 F377.08
    M983 F6.28466 A0.3 H0.4; cali dynamic extrusion compensation

    M106 P1 S255
    M400 S5
    G1 X-28.5 F18000
    G1 X-48.2 F3000
    G1 X-28.5 F18000 ;wipe and shake
M73 P11 R9
    G1 X-48.2 F3000
M73 P13 R9
    G1 X-28.5 F12000 ;wipe and shake
    G1 X-48.2 F3000
    M400
    M106 P1 S0

    M1002 judge_last_extrude_cali_success
    M622 J0
        M983 F6.28466 A0.3 H0.4; cali dynamic extrusion compensation
        M106 P1 S255
        M400 S5
        G1 X-28.5 F18000
        G1 X-48.2 F3000
        G1 X-28.5 F18000 ;wipe and shake
        G1 X-48.2 F3000
        G1 X-28.5 F12000 ;wipe and shake
        M400
        M106 P1 S0
    M623
    
M73 P14 R8
    G1 X-48.2 F3000
    M400
    M984 A0.1 E1 S1 F6.28466 H0.4
    M106 P1 S178
    M400 S7
    G1 X-28.5 F18000
    G1 X-48.2 F3000
    G1 X-28.5 F18000 ;wipe and shake
    G1 X-48.2 F3000
    G1 X-28.5 F12000 ;wipe and shake
    G1 X-48.2 F3000
    M400
    M106 P1 S0
M623 ; end of "draw extrinsic para cali paint"

;G392 S0
;===== auto extrude cali end ========================

;M400
;M73 P1.717

M104 S170 ; prepare to wipe nozzle
M106 S255 ; turn on fan

;===== mech mode fast check start =====================
M1002 gcode_claim_action : 3

G1 X128 Y128 F20000
G1 Z5 F1200
M400 P200
M970.3 Q1 A5 K0 O3
M974 Q1 S2 P0

M970.2 Q1 K1 W58 Z0.1
M974 S2

G1 X128 Y128 F20000
M73 P15 R8
G1 Z5 F1200
M400 P200
M970.3 Q0 A10 K0 O1
M974 Q0 S2 P0

M970.2 Q0 K1 W78 Z0.1
M974 S2

M975 S1
G1 F30000
G1 X0 Y5
G28 X ; re-home XY

G1 Z4 F1200

;===== mech mode fast check end =======================

;M400
;M73 P1.717

;===== wipe nozzle ===============================
M1002 gcode_claim_action : 14

M975 S1
M106 S255 ; turn on fan (G28 has turn off fan)
M211 S; push soft endstop status
M211 X0 Y0 Z0 ;turn off Z axis endstop

;===== remove waste by touching start =====

M104 S170 ; set temp down to heatbed acceptable

M83
G1 E-1 F500
G90
M83

M109 S170
G0 X108 Y-0.5 F30000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X110 F10000
G380 S3 Z-5 F1200
M73 P56 R4
G1 Z2 F1200
G1 X112 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X114 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X116 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X118 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X120 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X122 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X124 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X126 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X128 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X130 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X132 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X134 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X136 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X138 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X140 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X142 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X144 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X146 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X148 F10000
G380 S3 Z-5 F1200

G1 Z5 F30000
;===== remove waste by touching end =====

G1 Z10 F1200
G0 X118 Y261 F30000
G1 Z5 F1200
M109 S170

G28 Z P0 T300; home z with low precision,permit 300deg temperature
G29.2 S0 ; turn off ABL
M104 S140 ; prepare to abl
G0 Z5 F20000

G0 X128 Y261 F20000  ; move to exposed steel surface
G0 Z-1.01 F1200      ; stop the nozzle

G91
G2 I1 J0 X2 Y0 F2000.1
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
M73 P57 R4
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5

G90
G1 Z10 F1200

;===== brush material wipe nozzle =====

G90
G1 Y250 F30000
G1 X55
G1 Z1.300 F1200
G1 Y262.5 F6000
G91
G1 X-35 F30000
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Z5.000 F1200

G90
G1 X30 Y250.000 F30000
G1 Z1.300 F1200
G1 Y262.5 F6000
G91
G1 X35 F30000
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Y-0.5
G1 X45
G1 Y-0.5
G1 X-45
G1 Z10.000 F1200

;===== brush material wipe nozzle end =====

G90
;G0 X128 Y261 F20000  ; move to exposed steel surface
M73 P58 R4
G1 Y250 F30000
G1 X138
G1 Y261
G0 Z-1.01 F1200      ; stop the nozzle

G91
G2 I1 J0 X2 Y0 F2000.1
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5

M109 S140
M106 S255 ; turn on fan (G28 has turn off fan)

M211 R; pop softend status

;===== wipe nozzle end ================================

;M400
;M73 P1.717

;===== bed leveling ==================================
M1002 judge_flag g29_before_print_flag

G90
G1 Z5 F1200
G1 X0 Y0 F30000
G29.2 S1 ; turn on ABL

M190 S65; ensure bed temp
M109 S140
M106 S0 ; turn off fan , too noisy

M622 J1
    M1002 gcode_claim_action : 1
    G29 A1 X116.989 Y118.501 I22.0217 J18.9977
    M400
    M500 ; save cali data
M623
;===== bed leveling end ================================

;===== home after wipe mouth============================
M1002 judge_flag g29_before_print_flag
M622 J0

    M1002 gcode_claim_action : 13
    G28

M623

;===== home after wipe mouth end =======================

;M400
;M73 P1.717

G1 X108.000 Y-0.500 F30000
G1 Z0.300 F1200
M400
G2814 Z0.32

M104 S220 ; prepare to print

;===== nozzle load line ===============================
;G90
;M83
;G1 Z5 F1200
;G1 X88 Y-0.5 F20000
;G1 Z0.3 F1200

;M109 S220

;G1 E2 F300
;G1 X168 E4.989 F6000
;G1 Z1 F1200
;===== nozzle load line end ===========================

;===== extrude cali test ===============================

M400
    M900 S
    M900 C
    G90
    M83

    M109 S220
    G0 X128 E8  F904.991
    G0 X133 E.3742  F1508.32
    G0 X138 E.3742  F6033.27
    G0 X143 E.3742  F1508.32
    G0 X148 E.3742  F6033.27
    G0 X153 E.3742  F1508.32
    G91
    G1 X1 Z-0.300
    G1 X4
    G1 Z1 F1200
    G90
    M400

M900 R

M1002 judge_flag extrude_cali_flag
M622 J1
    G90
    G1 X108.000 Y1.000 F30000
    G91
    G1 Z-0.700 F1200
    G90
    M83
    G0 X128 E10  F904.991
    G0 X133 E.3742  F1508.32
    G0 X138 E.3742  F6033.27
    G0 X143 E.3742  F1508.32
    G0 X148 E.3742  F6033.27
    G0 X153 E.3742  F1508.32
    G91
    G1 X1 Z-0.300
    G1 X4
    G1 Z1 F1200
    G90
    M400
M623

G1 Z0.2

;M400
;M73 P1.717

;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0
M400

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
;curr_bed_type=Textured PEI Plate

G29.1 Z-0.02 ; for Textured PEI Plate


M960 S1 P0 ; turn off laser
M960 S2 P0 ; turn off laser
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
G90
M83
T1000

M211 X0 Y0 Z0 ;turn off soft endstop
;G392 S1 ; turn on clog detection
M1007 S1 ; turn on mass estimation
G29.4
; MACHINE_START_GCODE_END
; filament start gcode
M106 P3 S200


;VT0 H-1
G90
G21
M83 ; use relative distances for extrusion
M981 S1 P20000 ;open spaghetti detector
; CHANGE_LAYER
; Z_HEIGHT: 0.2
; LAYER_HEIGHT: 0.2
G1 E-.8 F1800
; layer num/total_layer_count: 1/20
; update layer progress
M73 L1
M991 S0 P0 ;notify layer change
M106 S0
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.397 Y121.362 F42000
M204 S6000
G1 Z.4
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.5
M73 P59 R4
G1 F3000
M204 S500
G1 X128.909 Y121.113 E.24186
G2 X128.944 Y120.306 I-3.239 J-.548 E.03017
G1 X135.634 Y120.563 E.24934
G3 X136.23 Y120.248 I2.289 J3.615 E.02514
G3 X136.622 Y120.206 I.283 J.788 E.01482
G3 X136.103 Y121.692 I-.113 J.794 E.10545
G1 X135.603 Y121.37 E.02215
G1 X135.457 Y121.364 E.00545
M204 S6000
G1 X135.333 Y121.817 F42000
G1 F3000
M204 S500
G1 X128.306 Y121.547 E.26194
G2 X128.378 Y119.827 I-2.312 J-.958 E.06548
G1 X135.527 Y120.101 E.26647
G3 X136.192 Y119.782 I1.469 J2.207 E.02759
G3 X136.575 Y119.742 I.333 J1.339 E.01438
G3 X135.871 Y122.086 I-.067 J1.257 E.16968
G1 X135.461 Y121.822 E.01818
G1 X135.393 Y121.819 E.00251
M204 S6000
G1 X135.27 Y122.272 F42000
G1 F3000
M204 S500
G1 X127.478 Y121.975 E.29041
G2 X127.815 Y119.697 I-1.429 J-1.375 E.09151
G1 X127.596 Y119.337 E.01572
G2 X135.419 Y119.64 I31.545 J-712.854 E.29162
G3 X136.607 Y119.286 I1.176 J1.777 E.04684
G3 X135.639 Y122.48 I-.101 J1.713 E.23096
G1 X135.328 Y122.28 E.01378
; WIPE_START
G1 X133.329 Y122.202 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X125.956 Y120.231 Z.6 F42000
G1 X124.876 Y119.942 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X125.053 Y119.692 E.01142
G3 X125.973 Y119.208 I1.068 J.912 E.03967
G3 X126.244 Y119.208 I.135 J1.38 E.01011
G3 X127.579 Y120.476 I-.025 J1.363 E.07531
G3 X126.335 Y121.992 I-1.366 J.148 E.08133
G3 X124.854 Y119.997 I-.215 J-1.388 E.11356
; WIPE_START
M73 P60 R4
G1 X125.053 Y119.692 E-.13863
G1 X125.212 Y119.526 E-.08728
G1 X125.486 Y119.347 E-.12461
G1 X125.698 Y119.262 E-.0866
G1 X125.973 Y119.208 E-.10649
G1 X126.244 Y119.208 E-.10298
G1 X126.539 Y119.252 E-.11341
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X133.604 Y122.14 Z.6 F42000
G1 X135.435 Y122.888 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X135.404 Y122.879 E.00121
G3 X135.176 Y122.726 I1.098 J-1.879 E.01024
G2 X127.465 Y122.432 I-30.593 J702.591 E.28742
G3 X125.887 Y122.438 I-1.073 J-86.25 E.05876
G3 X126.175 Y118.753 I.228 J-1.836 E.2102
G1 X126.636 Y118.792 E.01724
G2 X128.078 Y118.9 I1.921 J-15.975 E.05386
G1 X135.312 Y119.178 E.26966
G3 X135.715 Y123.029 I1.19 J1.822 E.33153
G1 X135.489 Y122.915 E.00946
; WIPE_START
G1 X135.404 Y122.879 E-.03501
G1 X135.176 Y122.726 E-.10436
G1 X133.544 Y122.664 E-.62063
; WIPE_END
G1 E-.04 F1800
M204 S6000
G17
G3 Z.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 1 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z0.6
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer1 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.385 Y120.957 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.393544
G1 F3000
M204 S500
G1 X129.18 Y120.719 E.17741
; WIPE_START
G1 X131.179 Y120.796 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X127.334 Y119.397 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.10562
G1 F3000
M204 S500
G1 X127.3 Y119.354 E.00028
; LINE_WIDTH: 0.133252
G1 X127.205 Y119.244 E.00107
; LINE_WIDTH: 0.158699
G1 X127.044 Y119.068 E.00225
M204 S6000
G1 X127.025 Y119.123 F42000
; LINE_WIDTH: 0.144275
G1 F3000
M204 S500
G1 X126.948 Y119.102 E.00066
; LINE_WIDTH: 0.113424
G1 X126.833 Y119.071 E.00068
M204 S6000
G1 X127.025 Y119.123 F42000
; LINE_WIDTH: 0.159156
G1 F3000
M204 S500
G1 X127.033 Y119.126 E.00009
; LINE_WIDTH: 0.192257
G1 X127.245 Y119.2 E.00273
; WIPE_START
G1 X127.033 Y119.126 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X127.181 Y121.941 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.104669
G1 F3000
M204 S500
G1 X127.148 Y121.974 E.00024
; LINE_WIDTH: 0.131796
G1 X127.036 Y122.076 E.0011
; LINE_WIDTH: 0.157848
G1 X126.887 Y122.204 E.00184
M204 S6000
G1 X126.71 Y122.183 F42000
; LINE_WIDTH: 0.129381
G1 F3000
M204 S500
G2 X127.083 Y122.107 I-.982 J-5.755 E.00268
; WIPE_START
G1 X126.71 Y122.183 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X134.299 Y121.363 Z.6 F42000
G1 X137.124 Y121.058 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.53457
G1 F6300
M204 S500
G1 X136.702 Y120.636 E.02391
G2 X136.372 Y120.612 I-.208 J.597 E.0134
G1 X136.118 Y120.747 E.01153
G1 X136.87 Y121.499 E.04264
; OBJECT_ID: 80
; WIPE_START
G1 X136.118 Y120.747 E-.40441
G1 X136.372 Y120.612 E-.10933
G1 X136.58 Y120.595 E-.07917
G1 X136.702 Y120.636 E-.04901
G1 X136.922 Y120.856 E-.11808
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S6000
G1 X135.371 Y128.329 Z.6 F42000
G1 X135.364 Y128.36 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.5
G1 F3000
M204 S500
G1 X128.888 Y128.112 E.24142
G2 X128.924 Y127.305 I-3.255 J-.549 E.03016
G1 X135.634 Y127.562 E.25014
G1 X136.172 Y127.272 E.02276
G3 X136.559 Y127.199 I.357 J.835 E.01479
G3 X136.104 Y128.691 I-.049 J.801 E.10796
G1 X135.603 Y128.369 E.02216
G1 X135.424 Y128.362 E.00667
M204 S6000
G1 X135.306 Y128.815 F42000
G1 F3000
M204 S500
G1 X128.283 Y128.546 E.26175
G2 X128.351 Y126.826 I-2.259 J-.951 E.06554
G1 X135.527 Y127.101 E.26747
G3 X136.094 Y126.811 I1.58 J2.392 E.02375
G3 X136.587 Y126.742 I.424 J1.242 E.01865
G3 X135.871 Y129.086 I-.079 J1.257 E.16922
G1 X135.461 Y128.821 E.01818
G1 X135.366 Y128.818 E.00355
M204 S6000
G1 X135.247 Y129.27 F42000
G1 F3000
M204 S500
G1 X127.457 Y128.975 E.29033
G2 X127.794 Y126.696 I-1.431 J-1.375 E.09151
G1 X127.575 Y126.336 E.01572
G2 X135.42 Y126.639 I31.689 J-717.709 E.29242
M73 P61 R4
G3 X136.614 Y126.286 I1.141 J1.662 E.04717
G3 X135.639 Y129.48 I-.108 J1.713 E.23067
G1 X135.319 Y129.273 E.01421
G1 X135.307 Y129.273 E.00044
; WIPE_START
G1 X133.308 Y129.197 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X125.825 Y127.697 Z.6 F42000
G1 X124.696 Y127.47 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X124.759 Y127.17 E.01143
G3 X125.949 Y126.207 I1.336 J.434 E.06031
G1 X126.109 Y126.2 E.00594
G3 X127.558 Y127.478 I.056 J1.397 E.07945
G3 X126.315 Y128.991 I-1.366 J.145 E.08119
G3 X124.693 Y127.53 I-.22 J-1.387 E.09315
; WIPE_START
G1 X124.759 Y127.17 E-.13916
G1 X124.868 Y126.912 E-.10637
G1 X125.027 Y126.687 E-.10472
G1 X125.23 Y126.494 E-.10665
G1 X125.421 Y126.369 E-.0864
G1 X125.677 Y126.262 E-.10561
G1 X125.949 Y126.207 E-.10562
G1 X125.964 Y126.206 E-.00547
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X133.085 Y128.953 Z.6 F42000
G1 X135.339 Y129.823 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X135.176 Y129.725 E.00708
G2 X127.447 Y129.432 I-30.723 J707.152 E.28807
G2 X125.946 Y129.445 I.466 J138.182 E.05593
G3 X126.154 Y125.752 I.148 J-1.844 E.21316
G1 X126.616 Y125.792 E.01729
G2 X128.061 Y125.9 I1.927 J-16.076 E.05398
G1 X135.312 Y126.178 E.27028
G3 X135.559 Y129.962 I1.194 J1.822 E.33852
G1 X135.39 Y129.855 E.00747
; WIPE_START
G1 X135.176 Y129.725 E-.095
G1 X133.427 Y129.659 E-.665
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X135.385 Y127.957 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.393545
G1 F3000
M204 S500
G1 X129.159 Y127.718 E.17802
; WIPE_START
G1 X131.158 Y127.795 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X127.313 Y126.396 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.106279
G1 F3000
M204 S500
G1 X127.275 Y126.349 E.00031
; LINE_WIDTH: 0.12773
G1 X127.21 Y126.275 E.00068
; LINE_WIDTH: 0.163714
G1 X127.14 Y126.196 E.00103
; LINE_WIDTH: 0.190486
G2 X127.069 Y126.146 I-.084 J.044 E.00109
G1 X126.815 Y126.058 E.00323
M204 S6000
G1 X126.812 Y126.07 F42000
; LINE_WIDTH: 0.112852
G1 F3000
M204 S500
G1 X126.923 Y126.1 E.00065
; LINE_WIDTH: 0.142827
G1 X126.999 Y126.121 E.00064
; LINE_WIDTH: 0.157233
G1 X127.219 Y126.191 E.00215
; WIPE_START
G1 X126.999 Y126.121 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X127.161 Y128.939 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.105163
G1 F3000
M204 S500
G1 X127.125 Y128.975 E.00026
; LINE_WIDTH: 0.132299
G1 X127.015 Y129.075 E.00108
; LINE_WIDTH: 0.157903
G1 X126.866 Y129.203 E.00184
M204 S6000
G1 X126.689 Y129.182 F42000
; LINE_WIDTH: 0.128738
G1 F3000
M204 S500
G2 X127.062 Y129.107 I-.891 J-5.348 E.00266
; WIPE_START
G1 X126.689 Y129.182 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X134.196 Y127.804 Z.6 F42000
G1 X136.458 Y127.388 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.53529
G1 F6300
M204 S500
G1 X136.87 Y127.8 E.02337
G3 X136.723 Y128.349 I-.354 J.2 E.02527
G1 X135.968 Y127.594 E.04284
; OBJECT_ID: 69
; WIPE_START
G1 X136.723 Y128.349 E-.40579
G1 X136.826 Y128.262 E-.05127
G1 X136.903 Y128.129 E-.05862
G1 X136.922 Y127.984 E-.05547
G1 X136.87 Y127.8 E-.07265
G1 X136.654 Y127.584 E-.11621
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S6000
G1 X135.405 Y135.113 Z.6 F42000
G1 X135.364 Y135.359 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.5
G1 F3000
M204 S500
G1 X128.888 Y135.111 E.24142
G2 X128.924 Y134.304 I-3.255 J-.549 E.03016
G1 X135.634 Y134.561 E.25014
G1 X136.172 Y134.271 E.02276
G3 X136.559 Y134.198 I.357 J.835 E.01479
G3 X136.104 Y135.691 I-.049 J.801 E.10796
G1 X135.603 Y135.368 E.02216
G1 X135.424 Y135.362 E.00667
M204 S6000
G1 X135.306 Y135.814 F42000
G1 F3000
M204 S500
G1 X128.283 Y135.545 E.26175
G2 X128.351 Y133.825 I-2.259 J-.951 E.06554
G1 X135.527 Y134.1 E.26747
G3 X136.094 Y133.81 I1.58 J2.392 E.02375
G3 X136.587 Y133.742 I.424 J1.242 E.01865
G3 X135.871 Y136.085 I-.079 J1.257 E.16922
G1 X135.461 Y135.82 E.01818
G1 X135.366 Y135.817 E.00355
M204 S6000
G1 X135.247 Y136.27 F42000
G1 F3000
M204 S500
G1 X127.457 Y135.974 E.29033
M73 P61 R3
G2 X127.794 Y133.696 I-1.431 J-1.375 E.09151
G1 X127.575 Y133.335 E.01572
G2 X135.42 Y133.638 I31.689 J-717.709 E.29242
G3 X136.614 Y133.285 I1.141 J1.662 E.04717
G3 X135.639 Y136.479 I-.108 J1.713 E.23067
G1 X135.319 Y136.272 E.01421
G1 X135.307 Y136.272 E.00044
; WIPE_START
G1 X133.308 Y136.196 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X125.825 Y134.696 Z.6 F42000
G1 X124.696 Y134.47 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X124.759 Y134.169 E.01143
M73 P62 R3
G3 X125.949 Y133.206 I1.336 J.434 E.06031
G1 X126.109 Y133.199 E.00594
G3 X127.558 Y134.477 I.056 J1.397 E.07945
G3 X126.315 Y135.99 I-1.366 J.145 E.08119
G3 X124.693 Y134.529 I-.22 J-1.387 E.09315
; WIPE_START
G1 X124.759 Y134.169 E-.13916
G1 X124.868 Y133.912 E-.10637
G1 X125.027 Y133.686 E-.10472
G1 X125.23 Y133.493 E-.10665
G1 X125.421 Y133.369 E-.0864
G1 X125.677 Y133.261 E-.10561
G1 X125.949 Y133.206 E-.10562
G1 X125.964 Y133.206 E-.00547
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X133.085 Y135.953 Z.6 F42000
G1 X135.339 Y136.822 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X135.176 Y136.724 E.00708
G2 X127.447 Y136.431 I-30.723 J707.152 E.28807
G2 X125.946 Y136.444 I.466 J138.182 E.05593
G3 X126.154 Y132.751 I.148 J-1.844 E.21316
G1 X126.616 Y132.791 E.01729
G2 X128.061 Y132.899 I1.927 J-16.076 E.05398
G1 X135.312 Y133.177 E.27028
G3 X135.559 Y136.961 I1.194 J1.822 E.33852
G1 X135.39 Y136.854 E.00747
; WIPE_START
G1 X135.176 Y136.724 E-.095
G1 X133.427 Y136.658 E-.665
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X135.385 Y134.956 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.393545
G1 F3000
M204 S500
G1 X129.159 Y134.717 E.17802
; WIPE_START
G1 X131.158 Y134.794 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X127.313 Y133.395 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.106279
G1 F3000
M204 S500
G1 X127.275 Y133.348 E.00031
; LINE_WIDTH: 0.12773
G1 X127.21 Y133.274 E.00068
; LINE_WIDTH: 0.163714
G1 X127.14 Y133.195 E.00103
; LINE_WIDTH: 0.190486
G2 X127.069 Y133.145 I-.084 J.044 E.00109
G1 X126.815 Y133.057 E.00323
M204 S6000
G1 X126.812 Y133.07 F42000
; LINE_WIDTH: 0.112852
G1 F3000
M204 S500
G1 X126.923 Y133.099 E.00065
; LINE_WIDTH: 0.142827
G1 X126.999 Y133.12 E.00064
; LINE_WIDTH: 0.157233
G1 X127.219 Y133.191 E.00215
; WIPE_START
G1 X126.999 Y133.12 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X127.161 Y135.938 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.105163
G1 F3000
M204 S500
G1 X127.125 Y135.974 E.00026
; LINE_WIDTH: 0.132299
G1 X127.015 Y136.074 E.00108
; LINE_WIDTH: 0.157903
G1 X126.866 Y136.202 E.00184
M204 S6000
G1 X126.689 Y136.182 F42000
; LINE_WIDTH: 0.128738
G1 F3000
M204 S500
G2 X127.062 Y136.106 I-.891 J-5.348 E.00266
; WIPE_START
G1 X126.689 Y136.182 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X134.196 Y134.803 Z.6 F42000
G1 X136.458 Y134.387 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.53529
G1 F6300
M204 S500
G1 X136.87 Y134.799 E.02337
G3 X136.723 Y135.349 I-.354 J.2 E.02527
G1 X135.968 Y134.593 E.04284
; OBJECT_ID: 102
; WIPE_START
G1 X136.723 Y135.349 E-.40579
G1 X136.826 Y135.262 E-.05127
G1 X136.903 Y135.128 E-.05862
G1 X136.922 Y134.983 E-.05547
G1 X136.87 Y134.799 E-.07265
G1 X136.654 Y134.583 E-.11621
; WIPE_END
G1 E-.03999 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S6000
G1 X129.913 Y131.002 Z.6 F42000
G1 X119.376 Y125.403 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.5
G1 F3000
M204 S500
G1 X119.682 Y125.44 E.01147
G2 X120.184 Y125.429 I.2 J-2.471 E.01872
G1 X119.927 Y132.124 E.24955
G1 X120.217 Y132.662 E.02276
G3 X118.797 Y132.593 I-.728 J.339 E.12294
G1 X119.12 Y132.093 E.02216
G1 X119.374 Y125.463 E.24712
M204 S6000
G1 X118.942 Y124.801 F42000
G1 F3000
M204 S500
G1 X119.245 Y124.901 E.01187
G2 X120.663 Y124.86 I.644 J-2.304 E.05367
G1 X120.388 Y132.017 E.26675
G3 X120.678 Y132.584 I-2.397 J1.582 E.02378
G3 X118.403 Y132.361 I-1.189 J.417 E.18827
G1 X118.668 Y131.951 E.01818
G1 X118.94 Y124.861 E.26427
; WIPE_START
G1 X119.245 Y124.901 E-.11679
G1 X119.713 Y124.983 E-.18092
G1 X119.976 Y124.988 E-.09962
G1 X120.447 Y124.923 E-.18082
G1 X120.663 Y124.86 E-.08554
G1 X120.653 Y125.114 E-.09632
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X118.514 Y123.956 Z.6 F42000
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X118.728 Y124.142 E.01056
G2 X121.154 Y124.068 I1.166 J-1.562 E.09755
G2 X120.85 Y131.91 I715.54 J31.674 E.29229
G3 X121.165 Y133.374 I-1.633 J1.118 E.05723
G3 X118.009 Y132.129 I-1.676 J-.373 E.221
G1 X118.216 Y131.808 E.0142
G2 X118.513 Y124.016 I-724.059 J-31.479 E.29046
; WIPE_START
G1 X118.728 Y124.142 E-.09496
G1 X119.006 Y124.317 E-.1249
G1 X119.366 Y124.46 E-.14716
G1 X119.745 Y124.527 E-.14611
G1 X119.961 Y124.531 E-.0821
G1 X120.342 Y124.478 E-.14609
G1 X120.389 Y124.464 E-.01867
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X118.758 Y121.777 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X118.816 Y121.709 E.00332
M73 P63 R3
G3 X119.718 Y121.209 I1.101 J.923 E.03927
G3 X121.286 Y122.685 I.162 J1.399 E.0913
G3 X120.356 Y123.998 I-1.359 J.024 E.06413
G3 X118.502 Y122.877 I-.477 J-1.306 E.09251
G3 X118.72 Y121.838 I1.416 J-.246 E.0405
G1 X118.726 Y121.828 E.00047
; WIPE_START
G1 X118.816 Y121.709 E-.05654
G1 X118.97 Y121.542 E-.08643
G1 X119.197 Y121.381 E-.10541
G1 X119.448 Y121.27 E-.10475
G1 X119.718 Y121.209 E-.10487
G1 X119.995 Y121.203 E-.10558
G1 X120.22 Y121.238 E-.08633
G1 X120.377 Y121.286 E-.06243
G1 X120.489 Y121.342 E-.04767
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X118.488 Y128.707 Z.6 F42000
G1 X117.627 Y131.879 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X117.764 Y131.666 E.00943
G2 X118.057 Y123.955 I-708.482 J-30.819 E.28741
G3 X118.052 Y122.377 I88.113 J-1.08 E.05877
G3 X120.068 Y120.758 I1.84 J.226 E.1066
G3 X121.737 Y122.666 I-.184 J1.845 E.10398
G2 X121.589 Y124.571 I44.127 J4.385 E.07116
G1 X121.311 Y131.802 E.26953
G3 X117.591 Y131.926 I-1.822 J1.194 E.34369
; WIPE_START
G1 X117.764 Y131.666 E-.11868
G1 X117.828 Y129.979 E-.64133
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X119.539 Y131.7 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.373162
G1 F3000
M204 S500
G1 X119.58 Y131.77 E.0022
; LINE_WIDTH: 0.332628
G1 X119.621 Y131.84 E.00193
; LINE_WIDTH: 0.292094
G1 X119.662 Y131.911 E.00166
; LINE_WIDTH: 0.25156
G1 X119.703 Y131.981 E.00139
M204 S6000
G1 X119.539 Y131.7 F42000
; LINE_WIDTH: 0.393562
G1 F3000
M204 S500
G1 X119.77 Y125.67 E.17241
; WIPE_START
G1 X119.694 Y127.668 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X121.153 Y123.76 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.12514
G1 F3000
M204 S500
G1 X121.278 Y123.641 E.00115
; LINE_WIDTH: 0.1686
G2 X121.366 Y123.517 I-.214 J-.245 E.00157
; LINE_WIDTH: 0.144566
G1 X121.389 Y123.434 E.00072
; LINE_WIDTH: 0.117297
G1 X121.411 Y123.358 E.00048
; LINE_WIDTH: 0.103314
G1 X121.418 Y123.323 E.00017
; WIPE_START
G1 X121.411 Y123.358 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X118.504 Y123.608 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.10382
G1 F3000
M204 S500
G1 X118.476 Y123.578 E.0002
; LINE_WIDTH: 0.129849
G1 X118.379 Y123.461 E.00108
; LINE_WIDTH: 0.163416
G1 X118.353 Y123.426 E.00042
; LINE_WIDTH: 0.157378
G1 X118.335 Y123.344 E.00078
; LINE_WIDTH: 0.11813
G1 X118.307 Y123.203 E.00088
; WIPE_START
G1 X118.335 Y123.344 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X119.567 Y130.877 Z.6 F42000
G1 X119.976 Y133.379 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.52202
G1 F6300
M204 S500
G1 X119.235 Y132.637 E.04094
G2 X119.138 Y133.217 I.362 J.359 E.02448
G1 X119.535 Y133.615 E.02194
; CHANGE_LAYER
; Z_HEIGHT: 0.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F6300
G1 X119.138 Y133.217 E-.21351
G1 X119.081 Y133.064 E-.06214
G1 X119.092 Y132.893 E-.06509
G1 X119.235 Y132.637 E-.11143
G1 X119.808 Y133.21 E-.30782
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 2/20
; update layer progress
M73 L2
M991 S0 P1 ;notify layer change
M106 S201.45
; open powerlost recovery
M1003 S1
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z.6 I.727 J.976 P1  F42000
G1 X135.324 Y121.639 Z.6
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11487
M204 S6000
G1 X128.556 Y121.379 E.22468
G2 X128.613 Y120.013 I-2.575 J-.791 E.04586
G1 X135.582 Y120.281 E.23135
G3 X136.325 Y119.934 I1.345 J1.914 E.02733
G1 X136.433 Y119.92 E.00363
G3 X136.624 Y119.924 I.072 J1.171 E.00636
G1 X136.731 Y119.94 E.00358
G3 X135.961 Y121.933 I-.221 J1.06 E.12455
G1 X135.516 Y121.647 E.01755
G1 X135.384 Y121.642 E.00439
M204 S10000
G1 X135.267 Y122.045 F42000
G1 F11487
M204 S6000
G1 X127.948 Y121.763 E.24296
G2 X128.015 Y119.583 I-1.988 J-1.152 E.07541
G1 X135.482 Y119.87 E.24788
G3 X136.413 Y119.513 I1.144 J1.597 E.03342
G3 X136.666 Y119.519 I.093 J1.548 E.00839
G3 X135.754 Y122.284 I-.156 J1.482 E.17636
G1 X135.389 Y122.049 E.01439
G1 X135.327 Y122.047 E.00206
M204 S10000
G1 X135.21 Y122.45 F42000
G1 F11487
M204 S6000
G1 X127.013 Y122.135 E.27213
G2 X127.777 Y121.141 I-1.235 J-1.74 E.04219
G2 X127.434 Y119.454 I-1.718 J-.53 E.05957
G1 X127.14 Y119.142 E.01423
G1 X135.383 Y119.458 E.27365
G3 X136.707 Y119.114 I1.14 J1.663 E.04631
G3 X135.547 Y122.635 I-.197 J1.887 E.22462
G1 X135.269 Y122.456 E.01097
; WIPE_START
G1 F15476.087
G1 X133.271 Y122.378 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.938 Y120.259 Z.8 F42000
G1 X124.909 Y119.962 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11487
M204 S5000
G1 X125.048 Y119.75 E.00779
G3 X125.974 Y119.248 I1.06 J.851 E.03324
G1 X126.125 Y119.241 E.00463
G3 X124.881 Y120.015 I-.017 J1.36 E.21498
; WIPE_START
G1 F12000
M204 S6000
G1 X125.048 Y119.75 E-.11895
G1 X125.276 Y119.526 E-.12147
G1 X125.498 Y119.386 E-.09978
G1 X125.709 Y119.301 E-.08653
G1 X125.974 Y119.248 E-.10257
G1 X126.125 Y119.241 E-.05725
G1 X126.349 Y119.262 E-.08573
G1 X126.571 Y119.325 E-.08773
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.619 Y122.255 Z.8 F42000
G1 X135.347 Y122.972 Z.8
G1 Z.4
G1 E.8 F1800
G1 F11487
M204 S5000
G1 X135.14 Y122.839 E.00755
G1 X126.042 Y122.49 E.27978
G3 X126.173 Y118.712 I.074 J-1.888 E.18197
G1 X135.287 Y119.062 E.28025
G3 X136.747 Y118.723 I1.233 J1.996 E.04686
G3 X135.396 Y123.004 I-.243 J2.277 E.24906
; WIPE_START
G1 F12000
M204 S6000
G1 X135.14 Y122.839 E-.11541
G1 X133.445 Y122.774 E-.64459
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 2 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z0.8
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer2 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X129.34 Y120.966 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52314
G1 F11487
M204 S6000
G1 X135.589 Y121.206 E.2447
; LINE_WIDTH: 0.505974
G1 X135.746 Y121.314 E.00721
; LINE_WIDTH: 0.47158
G1 X135.903 Y121.423 E.00667
; LINE_WIDTH: 0.421003
G1 X136.061 Y121.531 E.00589
G1 X136.457 Y121.685 E.01309
G1 X136.812 Y121.618 E.01115
G1 X137.035 Y121.445 E.00869
G1 X137.164 Y121.168 E.00941
G1 X137.197 Y121.007 E.00506
G1 X137.141 Y120.729 E.00874
G1 X137.005 Y120.524 E.00758
G1 X136.788 Y120.374 E.00811
G1 X136.451 Y120.318 E.01053
G1 X136.093 Y120.443 E.01167
; LINE_WIDTH: 0.437502
G1 X135.942 Y120.538 E.00574
; LINE_WIDTH: 0.472525
G1 X135.791 Y120.632 E.00625
; LINE_WIDTH: 0.522764
G1 X135.64 Y120.727 E.00698
G1 X129.115 Y120.476 E.25531
G1 X129.086 Y120.956 E.01878
M73 P64 R3
G1 X129.28 Y120.963 E.00762
M204 S10000
G1 X136 Y120.985 F42000
; LINE_WIDTH: 0.519864
G1 F11487
M204 S6000
G1 X136.443 Y121.232 E.0197
G1 X136.581 Y121.243 E.00538
G1 X136.74 Y121.109 E.0081
G2 X136.738 Y120.895 I-.365 J-.104 E.0084
G1 X136.624 Y120.78 E.0063
G1 X136.426 Y120.772 E.0077
G1 X136.054 Y120.958 E.01619
; WIPE_START
G1 F13209.099
G1 X136.426 Y120.772 E-.17174
G1 X136.624 Y120.78 E-.08164
G1 X136.738 Y120.895 E-.06688
G1 X136.74 Y121.109 E-.08787
G1 X136.581 Y121.243 E-.08589
G1 X136.443 Y121.232 E-.05703
G1 X136 Y120.985 E-.20896
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.404 Y121.734 Z.8 F42000
G1 X127.678 Y121.805 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.110565
G1 F11487
M204 S6000
G1 X127.584 Y121.953 E.00097
; WIPE_START
G1 F15000
G1 X127.678 Y121.805 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.311 Y122.304 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; LINE_WIDTH: 0.203013
G1 F11487
M204 S6000
G1 X126.83 Y122.024 E.0077
M204 S10000
G1 X126.822 Y122.011 F42000
; LINE_WIDTH: 0.127435
G1 F11487
M204 S6000
G3 X126.341 Y122.305 I-5.582 J-8.571 E.00388
M204 S10000
G1 X126.643 Y122.197 F42000
; LINE_WIDTH: 0.229207
G1 F11487
M204 S6000
G1 X126.405 Y122.219 E.00364
; LINE_WIDTH: 0.181497
G1 X126.217 Y122.227 E.00212
G3 X126.123 Y118.977 I-.105 J-1.624 E.05903
G1 X126.394 Y118.994 E.00307
; LINE_WIDTH: 0.224539
G1 X126.79 Y119.057 E.00593
M204 S10000
G1 X126.497 Y118.921 F42000
; LINE_WIDTH: 0.134821
G1 F11487
M204 S6000
G3 X126.96 Y119.271 I-6.826 J9.509 E.00434
M204 S10000
G1 X126.97 Y119.257 F42000
; LINE_WIDTH: 0.197451
G1 F11487
M204 S6000
G1 X126.465 Y118.92 E.00765
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X126.97 Y119.257 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X132.131 Y124.881 Z.8 F42000
G1 X135.689 Y128.757 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11487
M204 S6000
G1 X135.516 Y128.646 E.00681
G1 X128.535 Y128.378 E.23174
G2 X128.594 Y127.012 I-2.613 J-.799 E.04585
G1 X135.567 Y127.279 E.23146
G3 X136.14 Y126.982 I2.006 J3.164 E.02142
G3 X136.625 Y126.923 I.376 J1.073 E.01634
G1 X136.731 Y126.939 E.00357
G3 X135.961 Y128.933 I-.221 J1.06 E.12456
G1 X135.739 Y128.79 E.00876
M204 S10000
G1 X135.503 Y129.122 F42000
G1 F11487
M204 S6000
G1 X135.389 Y129.049 E.00449
G1 X127.921 Y128.762 E.24792
G2 X127.993 Y126.582 I-1.927 J-1.156 E.07556
G1 X135.472 Y126.868 E.24825
G3 X136.54 Y126.51 I1.163 J1.697 E.03787
G1 X136.666 Y126.518 E.00417
G3 X135.754 Y129.284 I-.156 J1.482 E.17636
G1 X135.553 Y129.154 E.00793
M204 S10000
G1 X135.197 Y129.449 F42000
G1 F11487
M204 S6000
G1 X127.003 Y129.134 E.27201
G2 X127.756 Y128.14 I-1.306 J-1.77 E.04192
G2 X127.45 Y126.497 I-1.745 J-.526 E.05761
G1 X127.127 Y126.141 E.01593
G1 X135.377 Y126.457 E.27385
G3 X136.707 Y126.113 I1.148 J1.691 E.04649
G3 X135.548 Y129.635 I-.197 J1.887 E.22462
G1 X135.262 Y129.451 E.01125
G1 X135.257 Y129.451 E.00017
; WIPE_START
G1 F15476.087
G1 X133.259 Y129.374 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.81 Y127.71 Z.8 F42000
G1 X124.736 Y127.47 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11487
M204 S5000
G1 X124.737 Y127.442 E.00084
G3 X125.953 Y126.247 I1.35 J.157 E.05665
G1 X126.103 Y126.24 E.00463
G3 X124.732 Y127.711 I-.016 J1.36 E.19295
G1 X124.735 Y127.53 E.00557
; WIPE_START
G1 F12000
M204 S6000
G1 X124.737 Y127.442 E-.03322
G1 X124.795 Y127.179 E-.10261
G1 X124.904 Y126.932 E-.10264
G1 X125.059 Y126.711 E-.10265
G1 X125.216 Y126.556 E-.08372
G1 X125.439 Y126.405 E-.10248
G1 X125.688 Y126.3 E-.1027
G1 X125.953 Y126.247 E-.10246
G1 X126.025 Y126.244 E-.02751
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.118 Y129.062 Z.8 F42000
G1 X135.249 Y129.909 Z.8
G1 Z.4
G1 E.8 F1800
G1 F11487
M204 S5000
G1 X135.14 Y129.839 E.00398
G1 X126.018 Y129.489 E.2805
G3 X126.152 Y125.712 I.07 J-1.889 E.18224
G1 X135.285 Y126.062 E.28083
G3 X136.747 Y125.722 I1.236 J2.007 E.04693
G3 X135.347 Y129.975 I-.243 J2.277 E.25082
G1 X135.299 Y129.943 E.00179
; WIPE_START
G1 F12000
M204 S6000
G1 X135.14 Y129.839 E-.07197
G1 X133.331 Y129.769 E-.68803
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.318 Y127.965 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.524055
G1 F11487
M204 S6000
G1 X135.609 Y128.206 E.2468
; LINE_WIDTH: 0.507507
G1 X135.763 Y128.316 E.00718
; LINE_WIDTH: 0.4725
G1 X135.917 Y128.427 E.00664
; LINE_WIDTH: 0.421032
G1 X136.071 Y128.537 E.00585
G1 X136.459 Y128.684 E.01277
G1 X136.812 Y128.617 E.01108
G1 X137.035 Y128.444 E.00871
G2 X137.197 Y127.998 I-.843 J-.559 E.01475
G2 X136.788 Y127.373 I-.822 J.092 E.02386
G1 X136.444 Y127.316 E.01075
G1 X136.123 Y127.433 E.01053
; LINE_WIDTH: 0.437494
G1 X135.957 Y127.53 E.00618
; LINE_WIDTH: 0.4725
G1 X135.791 Y127.628 E.00673
; LINE_WIDTH: 0.522728
G1 X135.626 Y127.726 E.00752
G3 X129.079 Y127.475 I40.474 J-1141.988 E.25615
G1 X129.075 Y127.955 E.01878
G1 X129.258 Y127.962 E.00716
M204 S10000
G1 X135.993 Y127.98 F42000
; LINE_WIDTH: 0.518734
G1 F11487
M204 S6000
G1 X136.407 Y128.221 E.01859
G1 X136.581 Y128.242 E.00677
G1 X136.738 Y128.112 E.00792
G1 X136.751 Y127.946 E.00644
G1 X136.661 Y127.804 E.00653
G1 X136.435 Y127.755 E.00895
G1 X136.046 Y127.953 E.01694
; WIPE_START
G1 F13240.472
G1 X136.435 Y127.755 E-.17843
G1 X136.661 Y127.804 E-.09431
G1 X136.751 Y127.946 E-.06876
G1 X136.738 Y128.112 E-.06785
G1 X136.581 Y128.242 E-.08341
G1 X136.407 Y128.221 E-.07134
G1 X135.993 Y127.98 E-.19589
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.533 Y126.367 Z.8 F42000
G1 X126.465 Y125.92 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.208858
G1 F11487
M204 S6000
G1 X126.97 Y126.269 E.00829
M204 S10000
G1 X126.959 Y126.282 F42000
; LINE_WIDTH: 0.13029
G1 F11487
M204 S6000
G2 X126.498 Y125.921 I-7.668 J9.311 E.00417
M204 S10000
G1 X126.788 Y126.06 F42000
; LINE_WIDTH: 0.235849
G1 F11487
M204 S6000
G1 X126.507 Y126.01 E.0045
; LINE_WIDTH: 0.182108
G1 X126.102 Y125.976 E.00461
G2 X126.196 Y129.226 I-.01 J1.627 E.05927
G1 X126.388 Y129.218 E.00218
; LINE_WIDTH: 0.232992
G1 X126.648 Y129.192 E.00404
M204 S10000
G1 X126.347 Y129.305 F42000
; LINE_WIDTH: 0.134767
G1 F11487
M204 S6000
G2 X126.834 Y128.992 I-6.131 J-10.082 E.00433
M204 S10000
G1 X126.843 Y129.006 F42000
; LINE_WIDTH: 0.197507
G1 F11487
M204 S6000
G1 X126.315 Y129.304 E.00764
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X126.843 Y129.006 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X132.911 Y133.637 Z.8 F42000
G1 X135.689 Y135.756 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11487
M204 S6000
G1 X135.516 Y135.645 E.00681
G1 X128.535 Y135.378 E.23174
G2 X128.594 Y134.012 I-2.613 J-.799 E.04585
G1 X135.567 Y134.279 E.23146
G3 X136.14 Y133.981 I2.006 J3.164 E.02142
G3 X136.625 Y133.923 I.376 J1.073 E.01634
G1 X136.731 Y133.938 E.00357
G3 X135.961 Y135.932 I-.221 J1.06 E.12456
G1 X135.739 Y135.789 E.00876
M204 S10000
G1 X135.503 Y136.121 F42000
G1 F11487
M204 S6000
G1 X135.389 Y136.048 E.00449
G1 X127.921 Y135.762 E.24792
G2 X127.993 Y133.581 I-1.927 J-1.156 E.07556
G1 X135.472 Y133.868 E.24825
G3 X136.54 Y133.509 I1.163 J1.697 E.03787
G1 X136.666 Y133.517 E.00417
G3 X135.754 Y136.283 I-.156 J1.482 E.17636
G1 X135.553 Y136.153 E.00793
M204 S10000
G1 X135.197 Y136.448 F42000
G1 F11487
M204 S6000
G1 X127.003 Y136.134 E.27201
G2 X127.756 Y135.14 I-1.306 J-1.77 E.04192
G2 X127.45 Y133.496 I-1.745 J-.526 E.05761
G1 X127.127 Y133.141 E.01593
G1 X135.377 Y133.457 E.27385
G3 X136.707 Y133.112 I1.148 J1.691 E.04649
G3 X135.548 Y136.634 I-.197 J1.887 E.22462
G1 X135.262 Y136.45 E.01125
G1 X135.257 Y136.45 E.00017
; WIPE_START
G1 F15476.087
G1 X133.259 Y136.374 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.81 Y134.709 Z.8 F42000
G1 X124.736 Y134.469 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11487
M204 S5000
G1 X124.737 Y134.442 E.00084
G3 X125.953 Y133.246 I1.35 J.157 E.05665
G1 X126.103 Y133.24 E.00463
G3 X124.732 Y134.71 I-.016 J1.36 E.19295
G1 X124.735 Y134.529 E.00557
; WIPE_START
G1 F12000
M204 S6000
G1 X124.737 Y134.442 E-.03322
G1 X124.795 Y134.178 E-.10261
G1 X124.904 Y133.931 E-.10264
G1 X125.059 Y133.71 E-.10265
G1 X125.216 Y133.555 E-.08372
G1 X125.439 Y133.404 E-.10248
G1 X125.688 Y133.299 E-.1027
G1 X125.953 Y133.246 E-.10246
G1 X126.025 Y133.243 E-.02751
; WIPE_END
M73 P65 R3
G1 E-.04 F1800
M204 S10000
G1 X133.118 Y136.061 Z.8 F42000
G1 X135.249 Y136.908 Z.8
G1 Z.4
G1 E.8 F1800
G1 F11487
M204 S5000
G1 X135.14 Y136.838 E.00398
G1 X126.018 Y136.488 E.2805
G3 X126.152 Y132.711 I.07 J-1.889 E.18224
G1 X135.285 Y133.061 E.28083
G3 X136.747 Y132.722 I1.236 J2.007 E.04693
G3 X135.347 Y136.975 I-.243 J2.277 E.25082
G1 X135.299 Y136.942 E.00179
; WIPE_START
G1 F12000
M204 S6000
G1 X135.14 Y136.838 E-.07197
G1 X133.331 Y136.769 E-.68803
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.318 Y134.964 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.524055
G1 F11487
M204 S6000
G1 X135.609 Y135.205 E.2468
; LINE_WIDTH: 0.507507
G1 X135.763 Y135.315 E.00718
; LINE_WIDTH: 0.4725
G1 X135.917 Y135.426 E.00664
; LINE_WIDTH: 0.421032
G1 X136.071 Y135.537 E.00585
G1 X136.459 Y135.684 E.01277
G1 X136.812 Y135.617 E.01108
G1 X137.035 Y135.443 E.00871
G2 X137.197 Y134.997 I-.843 J-.559 E.01475
G2 X136.788 Y134.373 I-.822 J.092 E.02386
G1 X136.444 Y134.316 E.01075
G1 X136.123 Y134.432 E.01053
; LINE_WIDTH: 0.437494
G1 X135.957 Y134.53 E.00618
; LINE_WIDTH: 0.4725
G1 X135.791 Y134.627 E.00673
; LINE_WIDTH: 0.522728
G1 X135.626 Y134.725 E.00752
G3 X129.079 Y134.474 I40.474 J-1141.988 E.25615
G1 X129.075 Y134.954 E.01878
G1 X129.258 Y134.961 E.00716
M204 S10000
G1 X135.993 Y134.979 F42000
; LINE_WIDTH: 0.518734
G1 F11487
M204 S6000
G1 X136.407 Y135.22 E.01859
G1 X136.581 Y135.241 E.00677
G1 X136.738 Y135.111 E.00792
G1 X136.751 Y134.945 E.00644
G1 X136.661 Y134.804 E.00653
G1 X136.435 Y134.754 E.00895
G1 X136.046 Y134.952 E.01694
; WIPE_START
G1 F13240.472
G1 X136.435 Y134.754 E-.17843
G1 X136.661 Y134.804 E-.09431
G1 X136.751 Y134.945 E-.06876
G1 X136.738 Y135.111 E-.06785
G1 X136.581 Y135.241 E-.08341
G1 X136.407 Y135.22 E-.07134
G1 X135.993 Y134.979 E-.19589
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.533 Y133.366 Z.8 F42000
G1 X126.465 Y132.919 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.208858
G1 F11487
M204 S6000
G1 X126.97 Y133.268 E.00829
M204 S10000
G1 X126.959 Y133.281 F42000
; LINE_WIDTH: 0.13029
G1 F11487
M204 S6000
G2 X126.498 Y132.92 I-7.668 J9.311 E.00417
M204 S10000
G1 X126.788 Y133.059 F42000
; LINE_WIDTH: 0.235849
G1 F11487
M204 S6000
G1 X126.507 Y133.009 E.0045
; LINE_WIDTH: 0.182108
G1 X126.102 Y132.975 E.00461
G2 X126.196 Y136.225 I-.01 J1.627 E.05927
G1 X126.388 Y136.217 E.00218
; LINE_WIDTH: 0.232992
G1 X126.648 Y136.191 E.00404
M204 S10000
G1 X126.347 Y136.304 F42000
; LINE_WIDTH: 0.134767
G1 F11487
M204 S6000
G2 X126.834 Y135.991 I-6.131 J-10.082 E.00433
M204 S10000
G1 X126.843 Y136.005 F42000
; LINE_WIDTH: 0.197507
G1 F11487
M204 S6000
G1 X126.315 Y136.303 E.00764
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X126.843 Y136.005 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X122.441 Y129.771 Z.8 F42000
G1 X119.11 Y125.053 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11487
M204 S6000
G1 X119.471 Y125.133 E.01228
G2 X120.477 Y125.098 I.416 J-2.525 E.03359
G1 X120.209 Y132.059 E.23107
G3 X120.476 Y132.555 I-3.884 J2.407 E.0187
G3 X118.55 Y132.461 I-.987 J.446 E.14688
G1 X118.843 Y132.006 E.01795
G1 X119.108 Y125.113 E.22883
M204 S10000
G1 X118.727 Y124.421 F42000
G1 F11487
M204 S6000
G1 X118.908 Y124.524 E.0069
G2 X120.906 Y124.515 I.991 J-1.997 E.06876
G1 X120.62 Y131.963 E.24723
G3 X120.976 Y132.913 I-1.751 J1.198 E.03397
G3 X118.201 Y132.251 I-1.487 J.086 E.18408
G1 X118.44 Y131.879 E.01468
G1 X118.724 Y124.481 E.24559
; WIPE_START
G1 F15476.087
G1 X118.908 Y124.524 E-.07146
G1 X119.125 Y124.62 E-.09036
G1 X119.539 Y124.731 E-.16293
G1 X119.969 Y124.758 E-.16372
G1 X120.393 Y124.699 E-.16264
G1 X120.577 Y124.647 E-.07253
G1 X120.666 Y124.611 E-.03635
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.354 Y123.524 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F11487
M204 S6000
G1 X118.684 Y123.873 E.01593
G2 X121.04 Y123.92 I1.204 J-1.284 E.08564
G1 X121.348 Y123.629 E.01403
G1 X121.031 Y131.867 E.27347
G3 X120.498 Y134.608 I-1.601 J1.111 E.10324
G3 X117.852 Y132.041 I-1.006 J-1.61 E.16735
G1 X118.038 Y131.752 E.0114
G1 X118.351 Y123.584 E.27115
; WIPE_START
G1 F15476.087
G1 X118.684 Y123.873 E-.1674
G1 X118.959 Y124.085 E-.13189
G1 X119.271 Y124.239 E-.13232
G1 X119.607 Y124.329 E-.13218
G1 X119.757 Y124.347 E-.05751
G1 X120.114 Y124.337 E-.13554
G1 X120.122 Y124.335 E-.00315
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.8 Y121.786 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11487
M204 S5000
G1 X118.811 Y121.769 E.0006
G3 X119.725 Y121.249 I1.077 J.829 E.0332
G1 X119.842 Y121.24 E.0036
G3 X118.668 Y121.998 I.046 J1.359 E.21737
G1 X118.769 Y121.836 E.00585
; WIPE_START
G1 F12000
M204 S6000
G1 X118.811 Y121.769 E-.03021
G1 X119.034 Y121.54 E-.12154
G1 X119.254 Y121.396 E-.09976
G1 X119.504 Y121.294 E-.10259
G1 X119.725 Y121.249 E-.08598
G1 X119.842 Y121.24 E-.04451
G1 X120.102 Y121.256 E-.099
G1 X120.363 Y121.324 E-.10261
G1 X120.538 Y121.41 E-.0738
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.431 Y128.746 Z.8 F42000
G1 X117.563 Y131.771 Z.8
G1 Z.4
G1 E.8 F1800
G1 F11487
M204 S5000
G1 X117.65 Y131.63 E.00509
G1 X118 Y122.532 E.27978
G3 X120.075 Y120.718 I1.902 J.082 E.0947
G3 X121.777 Y122.676 I-.191 J1.885 E.08778
G1 X121.427 Y131.775 E.27981
G3 X117.466 Y131.92 I-1.938 J1.222 E.29528
G1 X117.53 Y131.821 E.00361
; WIPE_START
G1 F12000
M204 S6000
G1 X117.65 Y131.63 E-.0858
G1 X117.718 Y129.857 E-.6742
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.533 Y125.583 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.524095
G1 F11487
M204 S6000
G1 X119.283 Y132.098 E.25564
; LINE_WIDTH: 0.507507
G1 X119.164 Y132.27 E.00793
; LINE_WIDTH: 0.4725
G1 X119.046 Y132.443 E.00734
; LINE_WIDTH: 0.424244
G2 X118.804 Y133.029 I1.083 J.791 E.01989
G1 X118.864 Y133.286 E.00821
G2 X119.486 Y133.687 I.661 J-.344 E.02404
G1 X119.749 Y133.636 E.00833
G1 X119.966 Y133.494 E.00805
G1 X120.12 Y133.27 E.00847
G1 X120.175 Y133.013 E.00817
G2 X120.078 Y132.66 I-1.049 J.098 E.01142
G1 X119.816 Y132.201 E.01642
; LINE_WIDTH: 0.479335
G1 X119.79 Y132.148 E.0021
; LINE_WIDTH: 0.523057
G1 X119.764 Y132.095 E.00231
G1 X120.014 Y125.594 E.25456
G1 X119.593 Y125.584 E.01645
M204 S10000
G1 X119.508 Y132.492 F42000
; LINE_WIDTH: 0.525085
G1 F11487
M204 S6000
G1 X119.258 Y132.941 E.02018
G1 X119.265 Y133.111 E.00672
G1 X119.368 Y133.218 E.00585
G1 X119.585 Y133.23 E.00853
G1 X119.718 Y133.097 E.0074
G1 X119.73 Y132.949 E.00584
G1 X119.535 Y132.546 E.01759
; WIPE_START
G1 F13066.082
G1 X119.73 Y132.949 E-.18538
G1 X119.718 Y133.097 E-.0616
G1 X119.585 Y133.23 E-.07795
G1 X119.368 Y133.218 E-.08994
G1 X119.265 Y133.111 E-.06161
G1 X119.258 Y132.941 E-.07084
G1 X119.508 Y132.492 E-.21268
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.469 Y124.931 Z.8 F42000
G1 X118.183 Y122.856 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.183514
G1 F11487
M204 S6000
G1 X118.355 Y123.139 E.0038
; LINE_WIDTH: 0.157464
G1 X118.425 Y123.249 E.00121
; LINE_WIDTH: 0.114764
G1 X118.509 Y123.369 E.00086
M204 S10000
G1 X118.303 Y123.185 F42000
; LINE_WIDTH: 0.235729
G1 F11487
M204 S6000
G1 X118.266 Y122.827 E.00566
; LINE_WIDTH: 0.18113
G3 X121.511 Y122.528 I1.616 J-.216 E.05919
G1 X121.496 Y122.886 E.00404
; LINE_WIDTH: 0.224894
G1 X121.432 Y123.28 E.00591
M204 S10000
G1 X121.569 Y122.988 F42000
; LINE_WIDTH: 0.134836
G1 F11487
M204 S6000
G3 X121.219 Y123.45 I-10.127 J-7.311 E.00434
M204 S10000
G1 X121.232 Y123.46 F42000
; LINE_WIDTH: 0.197489
G1 F11487
M204 S6000
G1 X121.57 Y122.955 E.00765
; CHANGE_LAYER
; Z_HEIGHT: 0.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X121.232 Y123.46 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 3/20
; update layer progress
M73 L3
M991 S0 P2 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z.8 I.156 J1.207 P1  F42000
G1 X135.32 Y121.639 Z.8
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11583
M204 S6000
G1 X128.556 Y121.379 E.22454
G2 X128.616 Y120.013 I-2.613 J-.799 E.04584
G1 X135.566 Y120.28 E.23073
G3 X136.137 Y119.984 I2.029 J3.213 E.02136
G3 X136.562 Y119.919 I.394 J1.145 E.01434
G3 X135.961 Y121.933 I-.052 J1.081 E.13019
G1 X135.516 Y121.647 E.01755
G1 X135.38 Y121.642 E.00453
M204 S10000
G1 X135.263 Y122.044 F42000
G1 F11583
M204 S6000
G1 X127.948 Y121.763 E.24282
G2 X128.012 Y119.583 I-1.945 J-1.148 E.07552
G1 X135.471 Y119.869 E.24763
G3 X136.433 Y119.513 I1.204 J1.774 E.03437
G3 X136.591 Y119.512 I.083 J1.352 E.00522
G3 X135.754 Y122.284 I-.081 J1.488 E.17887
G1 X135.389 Y122.049 E.01439
G1 X135.323 Y122.047 E.0022
M204 S10000
G1 X135.206 Y122.45 F42000
G1 F11583
M204 S6000
G1 X127.024 Y122.135 E.27161
G2 X127.777 Y121.141 I-1.293 J-1.76 E.04194
G2 X127.434 Y119.453 I-1.736 J-.526 E.05953
G1 X127.139 Y119.142 E.01421
G1 X135.376 Y119.458 E.27343
G3 X136.619 Y119.106 I1.154 J1.703 E.04358
G3 X135.547 Y122.635 I-.11 J1.894 E.22755
G1 X135.266 Y122.454 E.0111
; WIPE_START
G1 F15476.087
G1 X133.267 Y122.377 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.936 Y120.253 Z1 F42000
G1 X124.914 Y119.957 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11583
M204 S5000
G1 X124.924 Y119.932 E.00083
G3 X125.974 Y119.248 I1.184 J.669 E.04002
G1 X126.12 Y119.241 E.00448
G3 X124.811 Y120.191 I-.012 J1.36 E.20928
G1 X124.89 Y120.012 E.00601
; WIPE_START
G1 F12000
M204 S6000
G1 X124.924 Y119.932 E-.03303
G1 X125.048 Y119.75 E-.08375
G1 X125.237 Y119.557 E-.10262
G1 X125.46 Y119.405 E-.10257
G1 X125.709 Y119.301 E-.10264
G1 X125.974 Y119.248 E-.10247
G1 X126.12 Y119.241 E-.05545
G1 X126.351 Y119.263 E-.08831
G1 X126.577 Y119.327 E-.08917
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.629 Y122.247 Z1 F42000
G1 X135.283 Y122.932 Z1
G1 Z.6
G1 E.8 F1800
G1 F11583
M204 S5000
G1 X135.14 Y122.839 E.00523
G1 X126.041 Y122.49 E.2798
G3 X126.165 Y118.712 I.074 J-1.888 E.18169
G1 X135.285 Y119.062 E.28043
G3 X136.647 Y118.715 I1.238 J2.011 E.04384
G3 X135.346 Y122.976 I-.143 J2.285 E.25388
G1 X135.333 Y122.966 E.00052
; WIPE_START
G1 F12000
M204 S6000
G1 X135.14 Y122.839 E-.08747
G1 X133.372 Y122.772 E-.67253
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 3 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    
      M400
      G90
      M83
      M204 S5000
      G0 Z2 F4000
      G0 X261 Y250 F20000
      M400 P200
      G39 S1
      G0 Z2 F4000
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END


G1 Z1.000
; object ids of this layer3 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X129.339 Y120.966 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.524035
G1 F11583
M204 S6000
G1 X135.609 Y121.206 E.24598
; LINE_WIDTH: 0.507515
G1 X135.763 Y121.317 E.00719
; LINE_WIDTH: 0.472505
G1 X135.917 Y121.428 E.00665
; LINE_WIDTH: 0.423806
G1 X136.072 Y121.538 E.0059
G1 X136.456 Y121.685 E.01277
G1 X136.812 Y121.618 E.01123
M73 P66 R3
G1 X137.031 Y121.447 E.00863
G1 X137.164 Y121.211 E.0084
G2 X136.67 Y120.345 I-.697 J-.177 E.03421
G2 X136.172 Y120.407 I-.157 J.758 E.01584
G1 X135.721 Y120.664 E.01613
; LINE_WIDTH: 0.476368
G1 X135.662 Y120.695 E.00235
; LINE_WIDTH: 0.522969
G1 X135.603 Y120.726 E.0026
G1 X129.1 Y120.476 E.25457
G1 X129.096 Y120.956 E.01879
G1 X129.279 Y120.963 E.00716
M204 S10000
G1 X136 Y120.981 F42000
; LINE_WIDTH: 0.52525
G1 F11583
M204 S6000
G1 X136.439 Y121.228 E.01979
G1 X136.58 Y121.24 E.00557
G1 X136.724 Y121.117 E.00745
G2 X136.57 Y120.763 I-.242 J-.106 E.01704
G1 X136.37 Y120.789 E.00792
G1 X136.053 Y120.953 E.01405
; WIPE_START
G1 F13061.596
G1 X136.37 Y120.789 E-.1482
G1 X136.57 Y120.763 E-.08357
G1 X136.711 Y120.861 E-.07114
G1 X136.756 Y121.002 E-.06131
G1 X136.724 Y121.117 E-.04971
G1 X136.58 Y121.24 E-.07855
G1 X136.439 Y121.228 E-.05872
G1 X136 Y120.981 E-.20881
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.405 Y121.741 Z1 F42000
G1 X127.673 Y121.814 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.108074
G1 F11583
M204 S6000
G1 X127.584 Y121.953 E.00088
; WIPE_START
G1 F15000
G1 X127.673 Y121.814 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.363 Y122.306 Z1 F42000
G1 Z.6
G1 E.8 F1800
; LINE_WIDTH: 0.135815
G1 F11583
M204 S6000
G2 X126.855 Y121.993 I-4.857 J-8.176 E.00442
M204 S10000
G1 X126.866 Y122.01 F42000
; LINE_WIDTH: 0.225608
G1 F11583
M204 S6000
G1 X126.533 Y122.193 E.00566
G3 X126.404 Y122.219 I-.097 J-.146 E.00202
; LINE_WIDTH: 0.181532
G1 X126.217 Y122.227 E.00211
G3 X126.264 Y118.982 I-.104 J-1.624 E.06065
G1 X126.398 Y118.994 E.00152
; LINE_WIDTH: 0.226677
G1 X126.79 Y119.058 E.00596
M204 S10000
G1 X126.959 Y119.27 F42000
; LINE_WIDTH: 0.11234
G1 F11583
M204 S6000
G1 X126.852 Y119.185 E.00077
; LINE_WIDTH: 0.144191
G1 X126.783 Y119.136 E.0007
; LINE_WIDTH: 0.18995
G2 X126.47 Y118.92 I-4.374 J6.016 E.00456
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X126.783 Y119.136 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X131.881 Y124.817 Z1 F42000
G1 X135.31 Y128.638 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11583
M204 S6000
G1 X128.535 Y128.378 E.22488
G2 X128.594 Y127.012 I-2.65 J-.799 E.04583
G1 X135.566 Y127.279 E.23143
G3 X136.139 Y126.982 I1.999 J3.155 E.02145
G3 X136.628 Y126.924 I.376 J1.069 E.01645
G1 X136.73 Y126.939 E.00341
G3 X135.961 Y128.933 I-.22 J1.06 E.12454
G1 X135.516 Y128.646 E.01757
G1 X135.37 Y128.64 E.00486
M204 S10000
G1 X135.253 Y129.043 F42000
G1 F11583
M204 S6000
G1 X127.921 Y128.762 E.2434
G2 X128.011 Y126.583 I-1.953 J-1.173 E.07546
G1 X135.471 Y126.868 E.24764
G3 X136.413 Y126.513 I1.218 J1.8 E.0337
G3 X136.67 Y126.519 I.093 J1.549 E.00853
G3 X135.755 Y129.284 I-.159 J1.481 E.17625
G1 X135.389 Y129.049 E.01441
G1 X135.313 Y129.046 E.00253
M204 S10000
G1 X135.196 Y129.449 F42000
G1 F11583
M204 S6000
G1 X127.003 Y129.134 E.27197
G2 X127.76 Y128.127 I-1.297 J-1.761 E.0424
G2 X127.413 Y126.453 I-1.672 J-.526 E.05924
G1 X127.118 Y126.141 E.01422
G1 X135.376 Y126.457 E.27413
G3 X136.711 Y126.113 I1.149 J1.694 E.04664
G3 X135.548 Y129.635 I-.202 J1.886 E.22446
G1 X135.262 Y129.451 E.01125
G1 X135.256 Y129.451 E.00021
; WIPE_START
G1 F15476.087
G1 X133.258 Y129.374 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.808 Y127.712 Z1 F42000
G1 X124.736 Y127.473 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11583
M204 S5000
G1 X124.79 Y127.19 E.00884
G3 X125.953 Y126.247 I1.296 J.409 E.04872
G1 X126.098 Y126.24 E.00449
G3 X124.729 Y127.532 I-.012 J1.359 E.19848
; WIPE_START
G1 F12000
M204 S6000
G1 X124.79 Y127.19 E-.13195
G1 X124.88 Y126.975 E-.08855
G1 X125.059 Y126.711 E-.12133
G1 X125.245 Y126.533 E-.09793
G1 X125.484 Y126.382 E-.10732
G1 X125.724 Y126.29 E-.09788
G1 X125.953 Y126.247 E-.08825
G1 X126.023 Y126.244 E-.02679
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.119 Y129.055 Z1 F42000
G1 X135.207 Y129.882 Z1
G1 Z.6
G1 E.8 F1800
G1 F11583
M204 S5000
G1 X135.14 Y129.839 E.00245
G1 X126.018 Y129.489 E.28051
G3 X126.144 Y125.712 I.07 J-1.889 E.18199
G1 X135.285 Y126.062 E.28108
G3 X136.751 Y125.723 I1.236 J2.01 E.04707
G3 X135.347 Y129.976 I-.242 J2.278 E.25116
G1 X135.257 Y129.916 E.00332
; WIPE_START
G1 F12000
M204 S6000
G1 X135.14 Y129.839 E-.05312
G1 X133.281 Y129.768 E-.70688
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.321 Y127.965 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523115
G1 F11583
M204 S6000
G1 X135.584 Y128.205 E.24526
; LINE_WIDTH: 0.505982
G1 X135.77 Y128.323 E.00829
; LINE_WIDTH: 0.471585
G1 X135.955 Y128.442 E.00768
; LINE_WIDTH: 0.424381
G2 X136.282 Y128.645 I3.503 J-5.267 E.01197
G1 X136.612 Y128.677 E.01033
G1 X136.867 Y128.587 E.0084
G1 X137.076 Y128.366 E.00945
G1 X137.182 Y128.105 E.00874
G2 X136.902 Y127.452 I-.767 J-.058 E.02294
G1 X136.787 Y127.373 E.00433
G1 X136.444 Y127.316 E.01083
G1 X136.175 Y127.405 E.00879
G1 X135.709 Y127.672 E.01669
; LINE_WIDTH: 0.479665
G1 X135.656 Y127.699 E.00211
; LINE_WIDTH: 0.522989
G1 X135.603 Y127.725 E.00232
G1 X129.09 Y127.475 E.25496
G1 X129.065 Y127.955 E.01878
G1 X129.261 Y127.962 E.00768
M204 S10000
G1 X135.997 Y127.978 F42000
; LINE_WIDTH: 0.518457
G1 F11583
M204 S6000
G1 X136.471 Y128.235 E.02091
G1 X136.653 Y128.211 E.00709
G1 X136.761 Y128.038 E.0079
M73 P67 R3
G1 X136.714 Y127.858 E.0072
G1 X136.624 Y127.778 E.00467
G1 X136.409 Y127.765 E.00838
G1 X136.05 Y127.95 E.01563
; WIPE_START
G1 F13248.192
G1 X136.409 Y127.765 E-.16551
G1 X136.624 Y127.778 E-.08869
G1 X136.714 Y127.858 E-.04948
G1 X136.761 Y128.038 E-.07621
G1 X136.653 Y128.211 E-.08368
G1 X136.471 Y128.235 E-.07509
G1 X135.997 Y127.978 E-.22134
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.482 Y126.642 Z1 F42000
G1 X127.74 Y126.51 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.108003
G1 F11583
M204 S6000
G1 X127.662 Y126.366 E.00087
; WIPE_START
G1 F15000
G1 X127.74 Y126.51 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.449 Y125.919 Z1 F42000
G1 Z.6
G1 E.8 F1800
; LINE_WIDTH: 0.190095
G1 F11583
M204 S6000
G3 X126.762 Y126.135 I-4.153 J6.36 E.00456
; LINE_WIDTH: 0.14424
G1 X126.831 Y126.184 E.0007
; LINE_WIDTH: 0.112354
G1 X126.938 Y126.269 E.00077
M204 S10000
G1 X126.769 Y126.057 F42000
; LINE_WIDTH: 0.226687
G1 F11583
M204 S6000
G1 X126.377 Y125.993 E.00596
; LINE_WIDTH: 0.1815
G1 X126.242 Y125.981 E.00152
G2 X126.252 Y129.225 I-.15 J1.622 E.06128
G1 X126.393 Y129.218 E.0016
; LINE_WIDTH: 0.233623
G1 X126.648 Y129.192 E.004
M204 S10000
G1 X126.343 Y129.305 F42000
; LINE_WIDTH: 0.13502
G1 F11583
M204 S6000
G2 X126.793 Y129.021 I-6.744 J-11.19 E.00399
G1 X126.832 Y128.993 E.00036
M204 S10000
G1 X126.842 Y129.007 F42000
; LINE_WIDTH: 0.197551
G1 F11583
M204 S6000
G1 X126.315 Y129.304 E.00762
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X126.842 Y129.007 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X132.852 Y133.712 Z1 F42000
G1 X135.31 Y135.637 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11583
M204 S6000
G1 X128.535 Y135.378 E.22488
G2 X128.594 Y134.012 I-2.65 J-.799 E.04583
G1 X135.566 Y134.279 E.23143
G3 X136.139 Y133.981 I1.999 J3.155 E.02145
G3 X136.628 Y133.923 I.376 J1.069 E.01645
G1 X136.73 Y133.938 E.00341
G3 X135.961 Y135.932 I-.22 J1.06 E.12454
G1 X135.516 Y135.645 E.01757
G1 X135.37 Y135.64 E.00486
M204 S10000
G1 X135.253 Y136.043 F42000
G1 F11583
M204 S6000
G1 X127.921 Y135.762 E.2434
G2 X128.011 Y133.582 I-1.953 J-1.173 E.07546
G1 X135.471 Y133.868 E.24764
G3 X136.413 Y133.512 I1.218 J1.8 E.0337
G3 X136.67 Y133.518 I.093 J1.549 E.00853
G3 X135.755 Y136.283 I-.159 J1.481 E.17625
G1 X135.389 Y136.048 E.01441
G1 X135.313 Y136.045 E.00253
M204 S10000
G1 X135.196 Y136.448 F42000
G1 F11583
M204 S6000
G1 X127.003 Y136.134 E.27197
G2 X127.76 Y135.126 I-1.297 J-1.761 E.0424
G2 X127.413 Y133.452 I-1.672 J-.526 E.05924
G1 X127.118 Y133.14 E.01422
G1 X135.376 Y133.457 E.27413
G3 X136.711 Y133.113 I1.149 J1.694 E.04664
G3 X135.548 Y136.634 I-.202 J1.886 E.22446
G1 X135.262 Y136.45 E.01125
G1 X135.256 Y136.45 E.00021
; WIPE_START
G1 F15476.087
G1 X133.258 Y136.373 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.808 Y134.711 Z1 F42000
G1 X124.736 Y134.472 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11583
M204 S5000
G1 X124.79 Y134.19 E.00884
G3 X125.953 Y133.246 I1.296 J.409 E.04872
G1 X126.098 Y133.24 E.00449
G3 X124.729 Y134.531 I-.012 J1.359 E.19848
; WIPE_START
G1 F12000
M204 S6000
G1 X124.79 Y134.19 E-.13195
G1 X124.88 Y133.975 E-.08855
G1 X125.059 Y133.71 E-.12133
G1 X125.245 Y133.532 E-.09793
G1 X125.484 Y133.381 E-.10732
G1 X125.724 Y133.289 E-.09788
G1 X125.953 Y133.246 E-.08825
G1 X126.023 Y133.243 E-.02679
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.119 Y136.054 Z1 F42000
G1 X135.207 Y136.881 Z1
G1 Z.6
G1 E.8 F1800
G1 F11583
M204 S5000
G1 X135.14 Y136.838 E.00245
G1 X126.018 Y136.488 E.28051
G3 X126.144 Y132.711 I.07 J-1.889 E.18199
G1 X135.285 Y133.061 E.28108
G3 X136.751 Y132.722 I1.236 J2.01 E.04707
G3 X135.347 Y136.975 I-.242 J2.278 E.25116
G1 X135.257 Y136.915 E.00332
; WIPE_START
G1 F12000
M204 S6000
G1 X135.14 Y136.838 E-.05312
G1 X133.281 Y136.767 E-.70688
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.321 Y134.964 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523115
G1 F11583
M204 S6000
G1 X135.584 Y135.204 E.24526
; LINE_WIDTH: 0.505982
G1 X135.77 Y135.322 E.00829
; LINE_WIDTH: 0.471585
G1 X135.955 Y135.441 E.00768
; LINE_WIDTH: 0.424381
G2 X136.282 Y135.644 I3.503 J-5.267 E.01197
G1 X136.612 Y135.676 E.01033
G1 X136.867 Y135.586 E.0084
G1 X137.076 Y135.365 E.00945
G1 X137.182 Y135.104 E.00874
G2 X136.902 Y134.451 I-.767 J-.058 E.02294
G1 X136.787 Y134.372 E.00433
G1 X136.444 Y134.316 E.01083
G1 X136.175 Y134.405 E.00879
G1 X135.709 Y134.672 E.01669
; LINE_WIDTH: 0.479665
G1 X135.656 Y134.698 E.00211
; LINE_WIDTH: 0.522989
G1 X135.603 Y134.724 E.00232
G1 X129.09 Y134.475 E.25496
G1 X129.065 Y134.954 E.01878
G1 X129.261 Y134.962 E.00768
M204 S10000
G1 X135.997 Y134.977 F42000
; LINE_WIDTH: 0.518457
G1 F11583
M204 S6000
G1 X136.471 Y135.234 E.02091
G1 X136.653 Y135.21 E.00709
G1 X136.761 Y135.037 E.0079
G1 X136.714 Y134.857 E.0072
G1 X136.624 Y134.777 E.00467
G1 X136.409 Y134.764 E.00838
G1 X136.05 Y134.95 E.01563
; WIPE_START
G1 F13248.192
G1 X136.409 Y134.764 E-.16551
G1 X136.624 Y134.777 E-.08869
G1 X136.714 Y134.857 E-.04948
G1 X136.761 Y135.037 E-.07621
G1 X136.653 Y135.21 E-.08368
G1 X136.471 Y135.234 E-.07509
G1 X135.997 Y134.977 E-.22134
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.482 Y133.641 Z1 F42000
G1 X127.74 Y133.51 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.108003
G1 F11583
M204 S6000
G1 X127.662 Y133.365 E.00087
; WIPE_START
G1 F15000
G1 X127.74 Y133.51 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.449 Y132.919 Z1 F42000
G1 Z.6
G1 E.8 F1800
; LINE_WIDTH: 0.190095
G1 F11583
M204 S6000
G3 X126.762 Y133.134 I-4.153 J6.36 E.00456
; LINE_WIDTH: 0.14424
G1 X126.831 Y133.184 E.0007
; LINE_WIDTH: 0.112354
G1 X126.938 Y133.268 E.00077
M204 S10000
G1 X126.769 Y133.057 F42000
; LINE_WIDTH: 0.226687
G1 F11583
M204 S6000
G1 X126.377 Y132.992 E.00596
; LINE_WIDTH: 0.1815
G1 X126.242 Y132.981 E.00152
G2 X126.252 Y136.224 I-.15 J1.622 E.06128
G1 X126.393 Y136.217 E.0016
; LINE_WIDTH: 0.233623
G1 X126.648 Y136.191 E.004
M204 S10000
G1 X126.343 Y136.304 F42000
; LINE_WIDTH: 0.13502
G1 F11583
M204 S6000
G2 X126.793 Y136.02 I-6.744 J-11.19 E.00399
G1 X126.832 Y135.992 E.00036
M204 S10000
G1 X126.842 Y136.006 F42000
; LINE_WIDTH: 0.197551
G1 F11583
M204 S6000
G1 X126.315 Y136.303 E.00762
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X126.842 Y136.006 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X122.444 Y129.769 Z1 F42000
G1 X119.11 Y125.042 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11583
M204 S6000
G1 X119.271 Y125.092 E.00559
G2 X120.477 Y125.098 I.616 J-2.623 E.04032
G1 X120.209 Y132.059 E.23107
G3 X120.51 Y132.642 I-2.547 J1.684 E.02181
G3 X118.55 Y132.46 I-1.022 J.358 E.14365
G1 X118.843 Y132.006 E.01791
G1 X119.108 Y125.102 E.22918
M204 S10000
G1 X118.727 Y124.421 F42000
G1 F11583
M204 S6000
G1 X118.908 Y124.524 E.0069
G2 X120.906 Y124.515 I.991 J-1.997 E.06876
G1 X120.62 Y131.963 E.24723
G3 X120.976 Y132.912 I-1.753 J1.199 E.03395
G3 X118.201 Y132.25 I-1.487 J.087 E.18412
G1 X118.44 Y131.879 E.01465
G1 X118.724 Y124.481 E.24558
; WIPE_START
G1 F15476.087
G1 X118.908 Y124.524 E-.07148
G1 X119.134 Y124.624 E-.09425
G1 X119.371 Y124.696 E-.09401
G1 X119.729 Y124.753 E-.13786
G1 X119.971 Y124.758 E-.09168
G1 X120.394 Y124.699 E-.1624
G1 X120.576 Y124.647 E-.0722
G1 X120.665 Y124.612 E-.03612
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.354 Y123.523 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F11583
M204 S6000
G1 X118.684 Y123.872 E.01594
G2 X121.044 Y123.917 I1.205 J-1.284 E.08582
G1 X121.348 Y123.62 E.01409
G1 X121.031 Y131.867 E.27379
G3 X120.499 Y134.607 I-1.601 J1.111 E.10323
G3 X117.852 Y132.041 I-1.004 J-1.613 E.16721
G1 X118.038 Y131.752 E.01139
G1 X118.352 Y123.583 E.2712
; WIPE_START
G1 F15476.087
G1 X118.684 Y123.872 E-.16748
G1 X118.798 Y123.972 E-.05756
G1 X119.091 Y124.16 E-.13212
G1 X119.277 Y124.242 E-.07729
G1 X119.471 Y124.301 E-.07709
G1 X119.757 Y124.347 E-.11021
G1 X120.12 Y124.336 E-.13781
G1 X120.121 Y124.336 E-.00045
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.806 Y121.778 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11583
M204 S5000
G1 X118.833 Y121.739 E.00147
G3 X119.725 Y121.248 I1.054 J.859 E.03206
G1 X119.847 Y121.239 E.00375
G3 X118.747 Y121.858 I.04 J1.359 E.22215
G1 X118.77 Y121.826 E.0012
; WIPE_START
G1 F12000
M204 S6000
G1 X118.833 Y121.739 E-.04093
G1 X119.034 Y121.54 E-.10742
G1 X119.249 Y121.398 E-.09782
G1 X119.499 Y121.296 E-.10259
G1 X119.725 Y121.248 E-.08798
G1 X119.847 Y121.239 E-.04634
G1 X120.104 Y121.256 E-.09775
G1 X120.364 Y121.325 E-.10241
G1 X120.546 Y121.414 E-.07677
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.446 Y128.752 Z1 F42000
G1 X117.599 Y131.713 Z1
G1 Z.6
G1 E.8 F1800
G1 F11583
M204 S5000
G1 X117.65 Y131.63 E.003
G1 X118 Y122.531 E.2798
G3 X120.075 Y120.718 I1.902 J.083 E.09468
G3 X121.777 Y122.676 I-.191 J1.885 E.08778
G1 X121.427 Y131.775 E.27981
G3 X117.464 Y131.924 I-1.938 J1.222 E.29514
G1 X117.567 Y131.764 E.00585
; WIPE_START
G1 F12000
M204 S6000
G1 X117.65 Y131.63 E-.05986
G1 X117.721 Y129.789 E-.70014
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.534 Y125.566 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52409
G1 F11583
M204 S6000
G1 X119.283 Y132.098 E.25628
; LINE_WIDTH: 0.507499
G1 X119.164 Y132.27 E.00793
; LINE_WIDTH: 0.472495
G1 X119.046 Y132.443 E.00733
; LINE_WIDTH: 0.424256
G2 X118.804 Y133.028 I1.102 J.799 E.01986
G1 X118.865 Y133.286 E.00822
G1 X119.024 Y133.505 E.00843
G1 X119.258 Y133.647 E.00851
G1 X119.477 Y133.688 E.00692
G1 X119.749 Y133.636 E.00861
G1 X119.967 Y133.494 E.00806
G1 X120.145 Y133.177 E.0113
G1 X120.149 Y132.891 E.0089
G1 X120.078 Y132.66 E.0075
G1 X119.816 Y132.201 E.01642
; LINE_WIDTH: 0.479333
G1 X119.79 Y132.148 E.0021
; LINE_WIDTH: 0.523052
G1 X119.764 Y132.095 E.00231
G1 X120.013 Y125.607 E.25402
G1 X119.594 Y125.571 E.01646
M204 S10000
G1 X119.508 Y132.49 F42000
; LINE_WIDTH: 0.52277
G1 F11583
M204 S6000
G1 X119.261 Y132.92 E.01942
G1 X119.262 Y133.103 E.00715
G1 X119.414 Y133.24 E.008
G1 X119.586 Y133.231 E.00674
G1 X119.725 Y133.089 E.00776
G1 X119.723 Y132.939 E.0059
G1 X119.534 Y132.544 E.0171
; WIPE_START
G1 F13129.103
G1 X119.723 Y132.939 E-.18038
G1 X119.725 Y133.089 E-.06219
G1 X119.586 Y133.231 E-.08182
G1 X119.414 Y133.24 E-.07104
G1 X119.262 Y133.103 E-.0844
G1 X119.261 Y132.92 E-.07543
G1 X119.508 Y132.49 E-.20474
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.469 Y124.928 Z1 F42000
G1 X118.183 Y122.852 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.185248
G1 F11583
M204 S6000
G2 X118.387 Y123.189 I7.122 J-4.091 E.00456
; LINE_WIDTH: 0.144561
G1 X118.427 Y123.251 E.00061
; LINE_WIDTH: 0.113487
G1 X118.512 Y123.371 E.00085
M204 S10000
G1 X118.302 Y123.182 F42000
; LINE_WIDTH: 0.235334
G1 F11583
M204 S6000
G1 X118.266 Y122.827 E.00559
; LINE_WIDTH: 0.181209
M73 P68 R3
G3 X121.511 Y122.527 I1.616 J-.216 E.05923
G1 X121.496 Y122.882 E.004
; LINE_WIDTH: 0.224628
G1 X121.435 Y123.261 E.00568
M204 S10000
G1 X121.233 Y123.425 F42000
; LINE_WIDTH: 0.107321
G1 F11583
M204 S6000
G1 X121.298 Y123.343 E.00055
; LINE_WIDTH: 0.133526
G1 X121.349 Y123.271 E.00065
; LINE_WIDTH: 0.164822
G1 X121.398 Y123.202 E.00084
; LINE_WIDTH: 0.181655
G1 X121.57 Y122.943 E.00352
; CHANGE_LAYER
; Z_HEIGHT: 0.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X121.398 Y123.202 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 4/20
; update layer progress
M73 L4
M991 S0 P3 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z1 I.136 J1.209 P1  F42000
G1 X135.315 Y121.639 Z1
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11599
M204 S6000
G1 X128.557 Y121.379 E.22436
G2 X128.613 Y120.013 I-2.587 J-.79 E.04585
G1 X135.565 Y120.28 E.2308
G3 X136.139 Y119.983 I2.009 J3.18 E.02146
G3 X136.632 Y119.925 I.375 J1.065 E.01658
G1 X136.729 Y119.94 E.00327
G3 X135.96 Y121.933 I-.222 J1.059 E.12441
G1 X135.516 Y121.647 E.01753
G1 X135.375 Y121.641 E.00468
M204 S10000
G1 X135.259 Y122.044 F42000
G1 F11599
M204 S6000
G1 X127.943 Y121.763 E.24284
G2 X128.032 Y119.584 I-1.954 J-1.171 E.07545
G1 X135.471 Y119.869 E.24692
G3 X136.413 Y119.513 I1.219 J1.803 E.03372
G3 X136.673 Y119.52 I.093 J1.548 E.00865
G3 X135.754 Y122.284 I-.167 J1.48 E.17585
G1 X135.389 Y122.049 E.01437
G1 X135.319 Y122.047 E.00235
M204 S10000
G1 X135.202 Y122.449 F42000
G1 F11599
M204 S6000
G1 X127.024 Y122.135 E.27147
G2 X127.782 Y121.122 I-1.313 J-1.773 E.04257
G2 X127.471 Y119.498 I-1.747 J-.507 E.05695
G1 X127.148 Y119.143 E.01592
G1 X135.376 Y119.458 E.27312
G3 X136.716 Y119.115 I1.149 J1.697 E.0468
G3 X135.547 Y122.635 I-.21 J1.885 E.22402
G1 X135.262 Y122.452 E.01121
G1 X135.262 Y122.452 E.00002
; WIPE_START
G1 F15476.087
G1 X133.263 Y122.375 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.933 Y120.25 Z1.2 F42000
G1 X124.915 Y119.955 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11599
M204 S5000
G1 X124.924 Y119.932 E.00077
G3 X125.974 Y119.248 I1.184 J.669 E.04002
G1 X126.115 Y119.241 E.00434
G3 X124.809 Y120.196 I-.007 J1.36 E.20927
G1 X124.891 Y120.01 E.00623
; WIPE_START
G1 F12000
M204 S6000
G1 X124.924 Y119.932 E-.03234
G1 X125.08 Y119.712 E-.10261
G1 X125.237 Y119.557 E-.0838
G1 X125.461 Y119.405 E-.10261
G1 X125.71 Y119.301 E-.10264
G1 X125.974 Y119.248 E-.10228
G1 X126.115 Y119.241 E-.05363
G1 X126.349 Y119.262 E-.08949
G1 X126.579 Y119.327 E-.09059
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.635 Y122.236 Z1.2 F42000
G1 X135.215 Y122.888 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F11599
M204 S5000
G1 X135.14 Y122.839 E.00275
G1 X126.042 Y122.49 E.27977
G3 X126.157 Y118.712 I.069 J-1.889 E.18175
G1 X135.285 Y119.062 E.28068
G3 X136.756 Y118.724 I1.237 J2.012 E.04721
G3 X135.346 Y122.976 I-.249 J2.277 E.25091
G1 X135.265 Y122.921 E.00298
; WIPE_START
G1 F12000
M204 S6000
G1 X135.14 Y122.839 E-.05679
G1 X133.291 Y122.768 E-.70321
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 4 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.2
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z1.2 F4000
            G39.3 S1
            G0 Z1.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer4 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X129.34 Y120.966 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523105
G1 F11599
M204 S6000
G1 X135.589 Y121.206 E.2447
; LINE_WIDTH: 0.506007
G1 X135.75 Y121.317 E.00737
; LINE_WIDTH: 0.4716
G1 X135.911 Y121.427 E.00683
; LINE_WIDTH: 0.421043
G1 X136.072 Y121.538 E.00602
G1 X136.456 Y121.685 E.01269
G1 X136.812 Y121.618 E.01115
G1 X137.035 Y121.445 E.0087
G2 X137.197 Y121.006 I-.834 J-.558 E.01454
G2 X136.786 Y120.373 I-.825 J.086 E.02413
G1 X136.443 Y120.317 E.01073
G1 X136.124 Y120.432 E.01043
; LINE_WIDTH: 0.437497
G1 X135.958 Y120.53 E.00622
; LINE_WIDTH: 0.47251
G1 X135.791 Y120.628 E.00677
; LINE_WIDTH: 0.522679
G1 X135.624 Y120.726 E.00756
G3 X129.115 Y120.477 I20.309 J-614.563 E.25467
G1 X129.086 Y120.956 E.01877
G1 X129.28 Y120.963 E.0076
M204 S10000
G1 X135.992 Y120.98 F42000
; LINE_WIDTH: 0.518895
G1 F11599
M204 S6000
G1 X136.407 Y121.221 E.0186
G1 X136.58 Y121.243 E.0068
G1 X136.74 Y121.109 E.00808
G1 X136.751 Y120.946 E.00631
G1 X136.66 Y120.805 E.00652
G1 X136.434 Y120.756 E.00895
G1 X136.046 Y120.953 E.01692
; WIPE_START
G1 F13236
G1 X136.434 Y120.756 E-.17817
G1 X136.66 Y120.805 E-.09421
G1 X136.751 Y120.946 E-.06863
G1 X136.74 Y121.109 E-.06643
G1 X136.58 Y121.243 E-.08513
G1 X136.407 Y121.221 E-.07157
G1 X135.992 Y120.98 E-.19585
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.478 Y119.639 Z1.2 F42000
G1 X127.762 Y119.511 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.110753
G1 F11599
M204 S6000
G1 X127.684 Y119.367 E.00091
; WIPE_START
G1 F15000
G1 X127.762 Y119.511 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.484 Y118.921 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; LINE_WIDTH: 0.210973
G1 F11599
M204 S6000
G1 X126.991 Y119.268 E.00841
M204 S10000
G1 X126.98 Y119.282 F42000
; LINE_WIDTH: 0.110496
G1 F11599
M204 S6000
G1 X126.902 Y119.22 E.00055
; LINE_WIDTH: 0.149247
G2 X126.514 Y118.922 I-6.352 J7.863 E.00424
M204 S10000
G1 X126.81 Y119.061 F42000
; LINE_WIDTH: 0.235562
G1 F11599
M204 S6000
G1 X126.528 Y119.011 E.00449
; LINE_WIDTH: 0.18211
G1 X126.263 Y118.982 E.00302
G2 X126.217 Y122.227 I-.151 J1.621 E.0609
G1 X126.409 Y122.219 E.00219
; LINE_WIDTH: 0.233231
G1 X126.669 Y122.193 E.00405
M204 S10000
G1 X126.364 Y122.306 F42000
; LINE_WIDTH: 0.135757
G1 F11599
M204 S6000
G2 X126.852 Y121.996 I-6.33 J-10.504 E.00437
M204 S10000
G1 X126.86 Y122.009 F42000
; LINE_WIDTH: 0.197434
G1 F11599
M204 S6000
G1 X126.336 Y122.305 E.00758
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X126.86 Y122.009 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X132.865 Y126.721 Z1.2 F42000
G1 X135.308 Y128.638 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11599
M204 S6000
G1 X128.536 Y128.379 E.22481
G2 X128.594 Y127.013 I-2.631 J-.797 E.04583
G1 X135.565 Y127.279 E.2314
G3 X136.139 Y126.982 I1.98 J3.123 E.02147
G3 X136.632 Y126.924 I.375 J1.064 E.01658
G1 X136.716 Y126.936 E.00282
G3 X135.961 Y128.933 I-.206 J1.063 E.12502
G1 X135.516 Y128.646 E.01756
G1 X135.368 Y128.64 E.00491
M204 S10000
G1 X135.505 Y129.123 F42000
G1 F11599
M204 S6000
G1 X135.389 Y129.049 E.00457
G1 X127.921 Y128.762 E.24793
G2 X128.011 Y126.583 I-1.946 J-1.172 E.07547
G1 X135.471 Y126.868 E.24762
G3 X136.413 Y126.513 I1.218 J1.801 E.03372
G3 X136.674 Y126.519 I.093 J1.546 E.00866
G3 X135.754 Y129.284 I-.162 J1.481 E.17621
G1 X135.556 Y129.156 E.00784
M204 S10000
G1 X135.319 Y129.488 F42000
G1 F11599
M204 S6000
G1 X135.262 Y129.451 E.00225
G1 X127.003 Y129.135 E.27417
G2 X127.761 Y128.121 I-1.294 J-1.758 E.04259
G2 X127.437 Y126.481 I-1.674 J-.521 E.05779
G1 X127.125 Y126.142 E.0153
G1 X135.376 Y126.457 E.27389
G3 X136.715 Y126.114 I1.149 J1.697 E.04679
G3 X135.548 Y129.635 I-.204 J1.886 E.22444
G1 X135.37 Y129.52 E.00702
; WIPE_START
G1 F15476.087
G1 X135.262 Y129.451 E-.04853
G1 X133.392 Y129.379 E-.71147
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.938 Y127.734 Z1.2 F42000
G1 X124.735 Y127.469 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11599
M204 S5000
G1 X124.788 Y127.195 E.00856
G3 X125.952 Y126.247 I1.298 J.405 E.04888
G1 X126.094 Y126.24 E.00434
G3 X124.728 Y127.528 I-.007 J1.36 E.19885
; WIPE_START
G1 F12000
M204 S6000
G1 X124.788 Y127.195 E-.12848
G1 X124.88 Y126.976 E-.09033
G1 X125.059 Y126.711 E-.12157
G1 X125.255 Y126.525 E-.10249
G1 X125.484 Y126.382 E-.10266
G1 X125.688 Y126.3 E-.08373
G1 X125.952 Y126.247 E-.10235
G1 X126.027 Y126.243 E-.02839
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.125 Y129.049 Z1.2 F42000
G1 X135.165 Y129.855 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F11599
M204 S5000
G1 X135.14 Y129.839 E.00091
G1 X126.02 Y129.489 E.28044
G3 X126.136 Y125.711 I.069 J-1.889 E.18173
G1 X135.285 Y126.062 E.28133
G3 X136.756 Y125.724 I1.237 J2.012 E.04721
G3 X135.347 Y129.976 I-.25 J2.277 E.25075
G1 X135.215 Y129.888 E.00487
; WIPE_START
M73 P69 R3
G1 F12000
M204 S6000
G1 X135.14 Y129.839 E-.034
G1 X133.231 Y129.766 E-.726
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.318 Y127.965 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523095
G1 F11599
M204 S6000
G1 X135.584 Y128.205 E.24533
; LINE_WIDTH: 0.50599
G1 X135.746 Y128.316 E.00744
; LINE_WIDTH: 0.47159
G1 X135.909 Y128.427 E.00689
; LINE_WIDTH: 0.421055
G1 X136.072 Y128.538 E.00607
G1 X136.456 Y128.684 E.01266
G1 X136.738 Y128.633 E.00883
G1 X136.947 Y128.52 E.00734
G2 X136.903 Y127.452 I-.464 J-.515 E.03759
G1 X136.787 Y127.373 E.00434
G1 X136.443 Y127.317 E.01074
G1 X136.124 Y127.431 E.01043
; LINE_WIDTH: 0.437495
G1 X135.958 Y127.529 E.00622
; LINE_WIDTH: 0.472505
G1 X135.791 Y127.628 E.00677
; LINE_WIDTH: 0.52268
G1 X135.624 Y127.726 E.00756
G3 X129.079 Y127.475 I21.505 J-647.521 E.25607
G1 X129.075 Y127.955 E.01878
G1 X129.258 Y127.962 E.00716
M204 S10000
G1 X135.992 Y127.98 F42000
; LINE_WIDTH: 0.519026
G1 F11599
M204 S6000
G1 X136.406 Y128.221 E.0186
G1 X136.526 Y128.254 E.00481
G1 X136.693 Y128.175 E.00718
G1 X136.758 Y128.029 E.00622
G1 X136.715 Y127.86 E.00675
G1 X136.623 Y127.779 E.00474
G1 X136.408 Y127.764 E.00837
G1 X136.045 Y127.952 E.01585
; WIPE_START
G1 F13232.358
G1 X136.408 Y127.764 E-.16607
G1 X136.623 Y127.779 E-.08775
G1 X136.715 Y127.86 E-.0497
G1 X136.758 Y128.029 E-.07072
G1 X136.693 Y128.175 E-.06521
G1 X136.526 Y128.254 E-.07524
G1 X136.406 Y128.221 E-.05041
G1 X135.992 Y127.98 E-.1949
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.478 Y126.641 Z1.2 F42000
G1 X127.741 Y126.51 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.111144
G1 F11599
M204 S6000
G1 X127.662 Y126.366 E.00091
; WIPE_START
G1 F15000
G1 X127.741 Y126.51 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.46 Y125.92 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; LINE_WIDTH: 0.205584
G1 F11599
M204 S6000
G1 X126.964 Y126.265 E.0081
M204 S10000
G1 X126.954 Y126.279 F42000
; LINE_WIDTH: 0.131323
G1 F11599
M204 S6000
G2 X126.494 Y125.921 I-8.152 J10.008 E.0042
M204 S10000
G1 X126.783 Y126.059 F42000
; LINE_WIDTH: 0.23489
G1 F11599
M204 S6000
G1 X126.507 Y126.01 E.0044
; LINE_WIDTH: 0.182134
G1 X126.242 Y125.982 E.00302
G2 X126.196 Y129.226 I-.151 J1.621 E.06091
G1 X126.383 Y129.219 E.00212
; LINE_WIDTH: 0.225776
G2 X126.512 Y129.193 I.033 J-.171 E.00202
G1 X126.846 Y129.009 E.00567
M204 S10000
G1 X126.834 Y128.992 F42000
; LINE_WIDTH: 0.135887
G1 F11599
M204 S6000
G3 X126.343 Y129.305 I-5.436 J-7.992 E.00442
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X126.834 Y128.992 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X132.84 Y133.702 Z1.2 F42000
G1 X135.308 Y135.637 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11599
M204 S6000
G1 X128.536 Y135.378 E.22481
G2 X128.594 Y134.012 I-2.631 J-.797 E.04583
G1 X135.565 Y134.279 E.2314
G3 X136.139 Y133.982 I1.98 J3.123 E.02147
G3 X136.632 Y133.923 I.375 J1.064 E.01658
G1 X136.716 Y133.935 E.00282
G3 X135.961 Y135.932 I-.206 J1.063 E.12502
G1 X135.516 Y135.645 E.01756
G1 X135.368 Y135.64 E.00491
M204 S10000
G1 X135.505 Y136.122 F42000
G1 F11599
M204 S6000
G1 X135.389 Y136.048 E.00457
G1 X127.921 Y135.762 E.24793
G2 X128.011 Y133.582 I-1.946 J-1.172 E.07547
G1 X135.471 Y133.868 E.24762
G3 X136.413 Y133.512 I1.218 J1.801 E.03372
G3 X136.674 Y133.518 I.093 J1.546 E.00866
G3 X135.754 Y136.283 I-.162 J1.481 E.17621
G1 X135.556 Y136.155 E.00784
M204 S10000
G1 X135.319 Y136.487 F42000
G1 F11599
M204 S6000
G1 X135.262 Y136.45 E.00225
G1 X127.003 Y136.134 E.27417
G2 X127.761 Y135.12 I-1.294 J-1.758 E.04259
G2 X127.437 Y133.481 I-1.674 J-.521 E.05779
G1 X127.125 Y133.141 E.0153
G1 X135.376 Y133.457 E.27389
G3 X136.715 Y133.113 I1.149 J1.697 E.04679
G3 X135.548 Y136.634 I-.204 J1.886 E.22444
G1 X135.37 Y136.519 E.00702
; WIPE_START
G1 F15476.087
G1 X135.262 Y136.45 E-.04853
G1 X133.392 Y136.379 E-.71147
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.938 Y134.733 Z1.2 F42000
G1 X124.735 Y134.468 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11599
M204 S5000
G1 X124.788 Y134.194 E.00856
G3 X125.952 Y133.246 I1.298 J.405 E.04888
G1 X126.094 Y133.24 E.00434
G3 X124.728 Y134.527 I-.007 J1.36 E.19885
; WIPE_START
G1 F12000
M204 S6000
G1 X124.788 Y134.194 E-.12848
G1 X124.88 Y133.975 E-.09033
G1 X125.059 Y133.71 E-.12157
G1 X125.255 Y133.524 E-.10249
G1 X125.484 Y133.381 E-.10266
G1 X125.688 Y133.299 E-.08373
G1 X125.952 Y133.246 E-.10235
G1 X126.027 Y133.243 E-.02839
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.125 Y136.048 Z1.2 F42000
G1 X135.165 Y136.854 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F11599
M204 S5000
G1 X135.14 Y136.838 E.00091
G1 X126.02 Y136.488 E.28044
G3 X126.136 Y132.711 I.069 J-1.889 E.18173
G1 X135.285 Y133.061 E.28133
G3 X136.756 Y132.723 I1.237 J2.012 E.04721
G3 X135.347 Y136.975 I-.25 J2.277 E.25075
G1 X135.215 Y136.887 E.00487
; WIPE_START
G1 F12000
M204 S6000
G1 X135.14 Y136.838 E-.034
G1 X133.231 Y136.765 E-.726
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.318 Y134.964 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523095
G1 F11599
M204 S6000
G1 X135.584 Y135.204 E.24533
; LINE_WIDTH: 0.50599
G1 X135.746 Y135.315 E.00744
; LINE_WIDTH: 0.47159
G1 X135.909 Y135.426 E.00689
; LINE_WIDTH: 0.421055
G1 X136.072 Y135.537 E.00607
G1 X136.456 Y135.684 E.01266
G1 X136.738 Y135.632 E.00883
G1 X136.947 Y135.519 E.00734
G2 X136.903 Y134.452 I-.464 J-.515 E.03759
G1 X136.787 Y134.372 E.00434
G1 X136.443 Y134.316 E.01074
G1 X136.124 Y134.431 E.01043
; LINE_WIDTH: 0.437495
G1 X135.958 Y134.529 E.00622
; LINE_WIDTH: 0.472505
G1 X135.791 Y134.627 E.00677
; LINE_WIDTH: 0.52268
G1 X135.624 Y134.725 E.00756
G3 X129.079 Y134.474 I21.505 J-647.521 E.25607
G1 X129.075 Y134.955 E.01878
G1 X129.258 Y134.962 E.00716
M204 S10000
G1 X135.992 Y134.979 F42000
; LINE_WIDTH: 0.519026
G1 F11599
M204 S6000
G1 X136.406 Y135.22 E.0186
G1 X136.526 Y135.254 E.00481
G1 X136.693 Y135.175 E.00718
G1 X136.758 Y135.028 E.00622
G1 X136.715 Y134.859 E.00675
G1 X136.623 Y134.778 E.00474
G1 X136.408 Y134.764 E.00837
G1 X136.045 Y134.951 E.01585
; WIPE_START
G1 F13232.358
G1 X136.408 Y134.764 E-.16607
G1 X136.623 Y134.778 E-.08775
G1 X136.715 Y134.859 E-.0497
G1 X136.758 Y135.028 E-.07072
G1 X136.693 Y135.175 E-.06521
G1 X136.526 Y135.254 E-.07524
G1 X136.406 Y135.22 E-.05041
G1 X135.992 Y134.979 E-.1949
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.478 Y133.641 Z1.2 F42000
G1 X127.741 Y133.509 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.111144
G1 F11599
M204 S6000
G1 X127.662 Y133.365 E.00091
; WIPE_START
G1 F15000
G1 X127.741 Y133.509 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.46 Y132.919 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; LINE_WIDTH: 0.205584
G1 F11599
M204 S6000
G1 X126.964 Y133.265 E.0081
M204 S10000
G1 X126.954 Y133.278 F42000
; LINE_WIDTH: 0.131323
G1 F11599
M204 S6000
G2 X126.494 Y132.921 I-8.152 J10.008 E.0042
M204 S10000
G1 X126.783 Y133.059 F42000
; LINE_WIDTH: 0.23489
G1 F11599
M204 S6000
G1 X126.507 Y133.009 E.0044
; LINE_WIDTH: 0.182134
G1 X126.242 Y132.981 E.00302
G2 X126.196 Y136.226 I-.151 J1.621 E.06091
G1 X126.383 Y136.218 E.00212
; LINE_WIDTH: 0.225776
G2 X126.512 Y136.192 I.033 J-.171 E.00202
G1 X126.846 Y136.008 E.00567
M204 S10000
G1 X126.834 Y135.991 F42000
; LINE_WIDTH: 0.135887
G1 F11599
M204 S6000
G3 X126.343 Y136.305 I-5.436 J-7.992 E.00442
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X126.834 Y135.991 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X122.435 Y129.755 Z1.2 F42000
G1 X119.11 Y125.042 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11599
M204 S6000
G1 X119.271 Y125.092 E.00558
G2 X120.477 Y125.098 I.617 J-2.627 E.04033
G1 X120.209 Y132.059 E.23107
G3 X120.51 Y132.641 I-2.588 J1.706 E.02179
G3 X118.551 Y132.459 I-1.021 J.358 E.14371
G1 X118.843 Y132.006 E.01786
G1 X119.108 Y125.102 E.22918
M204 S10000
G1 X118.727 Y124.421 F42000
G1 F11599
M204 S6000
G1 X118.908 Y124.524 E.0069
G2 X120.906 Y124.515 I.991 J-1.997 E.06875
G1 X120.62 Y131.963 E.24724
G3 X120.979 Y133.029 I-1.675 J1.156 E.03779
G3 X118.202 Y132.249 I-1.49 J-.029 E.1804
G1 X118.44 Y131.879 E.01461
G1 X118.724 Y124.481 E.24559
; WIPE_START
G1 F15476.087
G1 X118.908 Y124.524 E-.07152
G1 X119.134 Y124.624 E-.09411
G1 X119.371 Y124.696 E-.09401
G1 X119.729 Y124.753 E-.13799
G1 X119.967 Y124.758 E-.09035
G1 X120.392 Y124.7 E-.16298
G1 X120.577 Y124.647 E-.07295
G1 X120.665 Y124.612 E-.0361
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.354 Y123.523 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
G1 F11599
M204 S6000
G1 X118.686 Y123.874 E.01603
G2 X121.044 Y123.917 I1.203 J-1.286 E.08573
G1 X121.348 Y123.621 E.01409
G1 X121.031 Y131.867 E.27375
G3 X120.499 Y134.607 I-1.601 J1.111 E.10321
G3 X117.852 Y132.04 I-1.004 J-1.613 E.16726
G1 X118.038 Y131.752 E.01136
G1 X118.352 Y123.583 E.2712
; WIPE_START
G1 F15476.087
G1 X118.686 Y123.874 E-.16843
G1 X118.96 Y124.086 E-.13182
G1 X119.277 Y124.242 E-.13396
G1 X119.613 Y124.33 E-.13217
G1 X119.954 Y124.35 E-.12996
G1 X120.12 Y124.328 E-.06366
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.81 Y121.771 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11599
M204 S5000
G1 X118.81 Y121.768 E.00007
G3 X119.726 Y121.248 I1.077 J.83 E.03323
G1 X119.852 Y121.239 E.00389
G3 X118.667 Y121.997 I.035 J1.359 E.21707
G1 X118.778 Y121.821 E.00639
; WIPE_START
G1 F12000
M204 S6000
G1 X118.81 Y121.768 E-.02357
G1 X118.996 Y121.572 E-.10269
G1 X119.245 Y121.401 E-.11483
G1 X119.494 Y121.297 E-.10259
G1 X119.726 Y121.248 E-.08994
G1 X119.852 Y121.239 E-.04812
G1 X120.102 Y121.256 E-.09516
G1 X120.363 Y121.324 E-.10239
G1 X120.553 Y121.417 E-.0807
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.462 Y128.758 Z1.2 F42000
G1 X117.637 Y131.651 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F11599
M204 S5000
G1 X117.65 Y131.63 E.00075
G1 X118 Y122.532 E.27977
G3 X120.075 Y120.718 I1.902 J.082 E.0947
G3 X121.777 Y122.676 I-.191 J1.885 E.08779
G1 X121.427 Y131.775 E.27981
G3 X117.462 Y131.928 I-1.938 J1.222 E.295
G1 X117.605 Y131.702 E.00823
; WIPE_START
G1 F12000
M204 S6000
G1 X117.65 Y131.63 E-.03206
G1 X117.724 Y129.716 E-.72794
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.534 Y125.566 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.524085
G1 F11599
M204 S6000
G1 X119.283 Y132.098 E.25628
; LINE_WIDTH: 0.507499
G1 X119.165 Y132.27 E.00793
; LINE_WIDTH: 0.472495
G1 X119.046 Y132.443 E.00733
; LINE_WIDTH: 0.424247
G2 X118.804 Y133.027 I1.105 J.801 E.01984
G1 X118.866 Y133.288 E.00832
G1 X119.026 Y133.507 E.00843
G1 X119.258 Y133.648 E.00844
G1 X119.477 Y133.688 E.00692
G1 X119.75 Y133.636 E.00862
G1 X119.967 Y133.493 E.00808
G1 X120.145 Y133.178 E.01124
G2 X120.078 Y132.659 I-.855 J-.154 E.0165
G1 X119.816 Y132.201 E.0164
; LINE_WIDTH: 0.479288
G1 X119.79 Y132.148 E.0021
; LINE_WIDTH: 0.523046
G1 X119.764 Y132.095 E.00231
G1 X120.013 Y125.608 E.25401
G1 X119.594 Y125.572 E.01646
M204 S10000
M73 P70 R3
G1 X119.508 Y132.49 F42000
; LINE_WIDTH: 0.52263
G1 F11599
M204 S6000
G1 X119.261 Y132.919 E.01937
G1 X119.263 Y133.104 E.00724
G1 X119.413 Y133.241 E.00794
G1 X119.586 Y133.231 E.00676
G1 X119.725 Y133.088 E.0078
G1 X119.722 Y132.938 E.00589
G1 X119.534 Y132.544 E.01707
; WIPE_START
G1 F13132.935
G1 X119.722 Y132.938 E-.17999
G1 X119.725 Y133.088 E-.06213
G1 X119.586 Y133.231 E-.08223
G1 X119.413 Y133.241 E-.0713
G1 X119.263 Y133.104 E-.08374
G1 X119.261 Y132.919 E-.07638
G1 X119.508 Y132.49 E-.20424
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.469 Y124.928 Z1.2 F42000
G1 X118.183 Y122.851 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.187517
G1 F11599
M204 S6000
G2 X118.385 Y123.185 I6.674 J-3.801 E.0046
; LINE_WIDTH: 0.145943
G1 X118.425 Y123.248 E.00063
; LINE_WIDTH: 0.11404
G1 X118.509 Y123.368 E.00085
M204 S10000
G1 X118.302 Y123.182 F42000
; LINE_WIDTH: 0.235286
G1 F11599
M204 S6000
G1 X118.266 Y122.828 E.00558
; LINE_WIDTH: 0.181132
G3 X121.504 Y122.427 I1.617 J-.214 E.05803
G1 X121.497 Y122.879 E.00508
; LINE_WIDTH: 0.222445
G1 X121.435 Y123.262 E.00568
M204 S10000
G1 X121.231 Y123.429 F42000
; LINE_WIDTH: 0.114385
G1 F11599
M204 S6000
G1 X121.323 Y123.31 E.00088
; LINE_WIDTH: 0.145279
G1 X121.364 Y123.251 E.0006
; LINE_WIDTH: 0.171655
G1 X121.402 Y123.196 E.0007
; LINE_WIDTH: 0.185983
G1 X121.57 Y122.94 E.00357
; CHANGE_LAYER
; Z_HEIGHT: 1
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X121.402 Y123.196 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 5/20
; update layer progress
M73 L5
M991 S0 P4 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z1.2 I.135 J1.209 P1  F42000
G1 X135.311 Y121.639 Z1.2
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11734
M204 S6000
G1 X128.556 Y121.379 E.22424
G2 X128.616 Y120.014 I-2.612 J-.799 E.04584
G1 X135.584 Y120.281 E.23132
G3 X136.32 Y119.935 I1.332 J1.877 E.02714
G1 X136.416 Y119.922 E.00319
G3 X136.571 Y119.919 I.119 J2.466 E.00514
G3 X135.96 Y121.933 I-.061 J1.081 E.12998
G1 X135.516 Y121.647 E.01751
G1 X135.371 Y121.641 E.00484
M204 S10000
G1 X135.254 Y122.044 F42000
G1 F11734
M204 S6000
G1 X127.948 Y121.763 E.24251
G2 X128.032 Y119.584 I-1.978 J-1.168 E.07539
G1 X135.484 Y119.87 E.24736
G3 X136.596 Y119.513 I1.112 J1.555 E.03939
G3 X135.753 Y122.284 I-.087 J1.488 E.17875
G1 X135.389 Y122.049 E.01435
G1 X135.314 Y122.046 E.00251
M204 S10000
G1 X135.317 Y122.487 F42000
G1 F11734
M204 S6000
G1 X135.262 Y122.452 E.00217
G1 X127.013 Y122.135 E.27385
G2 X127.828 Y120.945 I-1.188 J-1.688 E.04888
G2 X127.454 Y119.478 I-1.747 J-.336 E.05187
G1 X127.145 Y119.143 E.01512
G1 X135.384 Y119.458 E.27348
G3 X136.622 Y119.106 I1.137 J1.646 E.04348
G3 X135.546 Y122.635 I-.113 J1.894 E.22752
G1 X135.368 Y122.52 E.00704
; WIPE_START
G1 F15476.087
G1 X135.262 Y122.452 E-.04765
G1 X133.389 Y122.38 E-.71235
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.051 Y120.281 Z1.4 F42000
G1 X124.912 Y119.955 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11734
M204 S5000
G1 X125.065 Y119.728 E.00841
G3 X125.973 Y119.248 I1.042 J.873 E.03239
G1 X126.11 Y119.241 E.00419
G3 X124.884 Y120.007 I-.003 J1.36 E.21566
; WIPE_START
G1 F12000
M204 S6000
G1 X125.065 Y119.728 E-.12641
G1 X125.237 Y119.557 E-.09231
G1 X125.461 Y119.405 E-.10255
G1 X125.71 Y119.301 E-.1027
G1 X125.973 Y119.248 E-.10221
G1 X126.11 Y119.241 E-.05182
G1 X126.349 Y119.262 E-.09138
G1 X126.579 Y119.327 E-.09062
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.639 Y122.226 Z1.4 F42000
G1 X135.132 Y122.839 Z1.4
G1 Z1
G1 E.8 F1800
G1 F11734
M204 S5000
G1 X126.039 Y122.49 E.27961
G3 X126.149 Y118.712 I.076 J-1.888 E.18113
G1 X135.288 Y119.062 E.28101
G3 X136.647 Y118.715 I1.228 J1.969 E.04381
G3 X135.182 Y122.87 I-.141 J2.286 E.26013
; WIPE_START
G1 F12000
M204 S6000
G1 X133.184 Y122.787 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 5 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.4
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z1.4 F4000
            G39.3 S1
            G0 Z1.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer5 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X129.339 Y120.966 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523085
G1 F11734
M204 S6000
G1 X135.589 Y121.206 E.24472
; LINE_WIDTH: 0.506007
G1 X135.75 Y121.316 E.00737
; LINE_WIDTH: 0.4716
G1 X135.911 Y121.427 E.00682
; LINE_WIDTH: 0.423681
G1 X136.071 Y121.538 E.00606
G1 X136.454 Y121.685 E.01272
G1 X136.737 Y121.634 E.00892
G1 X136.947 Y121.521 E.0074
G2 X137.164 Y121.211 I-.91 J-.866 E.01179
G1 X137.195 Y120.945 E.0083
G1 X137.12 Y120.682 E.00848
G1 X136.91 Y120.454 E.00961
G1 X136.676 Y120.345 E.00802
G2 X136.171 Y120.411 I-.159 J.749 E.0161
G1 X135.73 Y120.67 E.01588
; LINE_WIDTH: 0.475405
G1 X135.669 Y120.698 E.00237
; LINE_WIDTH: 0.522923
G1 X135.607 Y120.726 E.00263
G1 X129.1 Y120.476 E.25472
G1 X129.096 Y120.956 E.01878
G1 X129.279 Y120.963 E.00716
M204 S10000
G1 X136.008 Y120.986 F42000
; LINE_WIDTH: 0.52499
G1 F11734
M204 S6000
G1 X136.445 Y121.23 E.01968
G1 X136.525 Y121.253 E.00326
G1 X136.691 Y121.175 E.00722
G1 X136.753 Y121.028 E.00626
G1 X136.709 Y120.849 E.00722
G1 X136.574 Y120.762 E.00631
G1 X136.374 Y120.789 E.00793
G1 X136.06 Y120.958 E.01398
; WIPE_START
G1 F13068.641
G1 X136.374 Y120.789 E-.14786
G1 X136.574 Y120.762 E-.08388
G1 X136.709 Y120.849 E-.06677
G1 X136.753 Y121.028 E-.07631
G1 X136.691 Y121.175 E-.06618
G1 X136.525 Y121.253 E-.07634
G1 X136.445 Y121.23 E-.03449
G1 X136.008 Y120.986 E-.20817
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.495 Y119.64 Z1.4 F42000
G1 X127.762 Y119.508 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.109601
G1 F11734
M204 S6000
G1 X127.684 Y119.367 E.00088
; WIPE_START
G1 F15000
G1 X127.762 Y119.508 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.481 Y118.921 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; LINE_WIDTH: 0.198811
G1 F11734
M204 S6000
G3 X126.79 Y119.136 I-3.374 J5.172 E.00478
; LINE_WIDTH: 0.147713
G1 X126.864 Y119.191 E.00079
; LINE_WIDTH: 0.11312
G1 X126.973 Y119.278 E.0008
M204 S10000
G1 X126.803 Y119.06 F42000
; LINE_WIDTH: 0.234505
G1 F11734
M204 S6000
G1 X126.528 Y119.011 E.00436
; LINE_WIDTH: 0.182182
G1 X126.262 Y118.982 E.00303
G2 X126.217 Y122.227 I-.15 J1.621 E.06092
G1 X126.409 Y122.219 E.00219
; LINE_WIDTH: 0.230003
G1 X126.646 Y122.195 E.00362
M204 S10000
G1 X126.824 Y122.009 F42000
; LINE_WIDTH: 0.113696
G1 F11734
M204 S6000
G1 X126.702 Y122.088 E.00084
; LINE_WIDTH: 0.155707
G1 X126.588 Y122.154 E.00122
; LINE_WIDTH: 0.182026
G1 X126.315 Y122.304 E.00353
; WIPE_START
G1 F15000
G1 X126.588 Y122.154 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.584 Y121.953 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; LINE_WIDTH: 0.109255
G1 F11734
M204 S6000
G1 X127.676 Y121.808 E.00093
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X127.584 Y121.953 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X133.43 Y126.86 Z1.4 F42000
G1 X135.693 Y128.76 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11734
M204 S6000
G1 X135.516 Y128.646 E.00698
G1 X128.536 Y128.379 E.23171
G2 X128.595 Y127.013 I-2.669 J-.798 E.04582
G1 X135.584 Y127.28 E.23202
G3 X136.321 Y126.934 I1.329 J1.87 E.02715
G1 X136.416 Y126.921 E.00318
G3 X136.571 Y126.918 I.119 J2.453 E.00516
G3 X135.961 Y128.933 I-.061 J1.081 E.12994
G1 X135.743 Y128.793 E.00859
M204 S10000
G1 X135.507 Y129.125 F42000
G1 F11734
M204 S6000
G1 X135.389 Y129.049 E.00466
G1 X127.924 Y128.762 E.24783
G2 X127.991 Y126.582 I-1.956 J-1.152 E.07548
G1 X135.484 Y126.869 E.24873
G3 X136.597 Y126.512 I1.112 J1.553 E.0394
G3 X135.754 Y129.284 I-.087 J1.488 E.17871
G1 X135.558 Y129.157 E.00776
M204 S10000
G1 X135.192 Y129.448 F42000
G1 F11734
M204 S6000
G1 X127.003 Y129.134 E.27184
G2 X127.763 Y128.116 I-1.32 J-1.777 E.04276
G2 X127.45 Y126.497 I-1.749 J-.501 E.05676
G1 X127.128 Y126.142 E.01591
G1 X135.384 Y126.458 E.27408
G3 X136.623 Y126.105 I1.137 J1.646 E.0435
G3 X135.548 Y129.635 I-.113 J1.894 E.22747
G1 X135.262 Y129.451 E.01125
G1 X135.252 Y129.451 E.00034
; WIPE_START
G1 F15476.087
G1 X133.254 Y129.374 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.807 Y127.702 Z1.4 F42000
G1 X124.737 Y127.462 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
M73 P71 R3
G1 F11734
M204 S5000
G1 X124.736 Y127.442 E.00062
G3 X125.952 Y126.247 I1.35 J.158 E.05665
G1 X126.089 Y126.24 E.00419
G3 X124.731 Y127.713 I-.003 J1.36 E.19332
G1 X124.735 Y127.522 E.00585
; WIPE_START
G1 F12000
M204 S6000
G1 X124.736 Y127.442 E-.03048
G1 X124.788 Y127.2 E-.09405
G1 X124.88 Y126.975 E-.09226
G1 X125.045 Y126.728 E-.11294
G1 X125.216 Y126.556 E-.09218
G1 X125.44 Y126.405 E-.10267
G1 X125.688 Y126.3 E-.10256
G1 X125.952 Y126.247 E-.10229
G1 X126.033 Y126.243 E-.03057
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.131 Y129.049 Z1.4 F42000
G1 X135.127 Y129.838 Z1.4
G1 Z1
G1 E.8 F1800
G1 F11734
M204 S5000
G1 X126.02 Y129.489 E.28003
G3 X126.128 Y125.711 I.069 J-1.889 E.18147
G1 X135.287 Y126.062 E.28166
G3 X136.647 Y125.714 I1.228 J1.969 E.04382
G3 X135.178 Y129.866 I-.141 J2.286 E.2603
; WIPE_START
G1 F12000
M204 S6000
G1 X133.18 Y129.784 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.32 Y127.965 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52308
G1 F11734
M204 S6000
G1 X135.589 Y128.205 E.24545
; LINE_WIDTH: 0.505999
G1 X135.75 Y128.316 E.00738
; LINE_WIDTH: 0.471595
G1 X135.911 Y128.427 E.00683
; LINE_WIDTH: 0.423675
G1 X136.072 Y128.538 E.00607
G1 X136.455 Y128.684 E.01272
G1 X136.738 Y128.633 E.00893
G1 X136.947 Y128.52 E.00736
G2 X137.162 Y128.215 I-.91 J-.87 E.01163
G1 X137.195 Y127.946 E.00842
G1 X137.12 Y127.682 E.00853
G1 X136.91 Y127.453 E.00962
G1 X136.676 Y127.344 E.00801
G2 X136.171 Y127.41 I-.158 J.75 E.0161
G1 X135.73 Y127.669 E.01587
; LINE_WIDTH: 0.475335
G1 X135.668 Y127.697 E.00238
; LINE_WIDTH: 0.522918
G1 X135.607 Y127.725 E.00264
G1 X129.09 Y127.475 E.25509
G1 X129.057 Y127.955 E.01878
G1 X129.26 Y127.962 E.00794
M204 S10000
G1 X136.007 Y127.985 F42000
; LINE_WIDTH: 0.52497
G1 F11734
M204 S6000
G1 X136.445 Y128.23 E.01969
G1 X136.525 Y128.252 E.00327
G1 X136.703 Y128.153 E.00801
G1 X136.752 Y128.028 E.00525
G1 X136.709 Y127.849 E.00726
G1 X136.574 Y127.761 E.00631
G1 X136.374 Y127.789 E.00794
G1 X136.06 Y127.957 E.01398
; WIPE_START
G1 F13069.184
G1 X136.374 Y127.789 E-.14821
G1 X136.574 Y127.761 E-.08411
G1 X136.709 Y127.849 E-.06684
G1 X136.752 Y128.028 E-.077
G1 X136.703 Y128.153 E-.05563
G1 X136.525 Y128.252 E-.08486
G1 X136.445 Y128.23 E-.03467
G1 X136.007 Y127.985 E-.20869
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.413 Y128.748 Z1.4 F42000
G1 X127.641 Y128.825 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.107098
G1 F11734
M204 S6000
G1 X127.559 Y128.952 E.00079
; WIPE_START
G1 F15000
G1 X127.641 Y128.825 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.312 Y129.304 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; LINE_WIDTH: 0.208995
G1 F11734
M204 S6000
G1 X126.841 Y129.009 E.00819
M204 S10000
G1 X126.831 Y128.995 F42000
; LINE_WIDTH: 0.136109
G1 F11734
M204 S6000
G3 X126.343 Y129.305 I-6.576 J-9.801 E.0044
M204 S10000
G1 X126.647 Y129.193 F42000
; LINE_WIDTH: 0.232799
G1 F11734
M204 S6000
G1 X126.386 Y129.218 E.00406
; LINE_WIDTH: 0.182231
G1 X126.196 Y129.226 E.00216
G3 X126.241 Y125.982 I-.105 J-1.624 E.06094
G1 X126.507 Y126.01 E.00303
; LINE_WIDTH: 0.235454
G1 X126.789 Y126.06 E.0045
M204 S10000
G1 X126.497 Y125.922 F42000
; LINE_WIDTH: 0.134846
G1 F11734
M204 S6000
G3 X126.959 Y126.282 I-7.279 J9.815 E.00439
M204 S10000
G1 X126.97 Y126.268 F42000
; LINE_WIDTH: 0.209637
G1 F11734
M204 S6000
G1 X126.465 Y125.92 E.00833
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X126.97 Y126.268 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X132.135 Y131.888 Z1.4 F42000
G1 X135.693 Y135.759 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11734
M204 S6000
G1 X135.516 Y135.645 E.00698
G1 X128.536 Y135.378 E.23171
G2 X128.595 Y134.012 I-2.669 J-.798 E.04582
G1 X135.584 Y134.279 E.23202
G3 X136.321 Y133.933 I1.329 J1.87 E.02715
G1 X136.416 Y133.92 E.00318
G3 X136.571 Y133.917 I.119 J2.453 E.00516
G3 X135.961 Y135.932 I-.061 J1.081 E.12994
G1 X135.743 Y135.792 E.00859
M204 S10000
G1 X135.507 Y136.124 F42000
G1 F11734
M204 S6000
G1 X135.389 Y136.048 E.00466
G1 X127.924 Y135.762 E.24783
G2 X127.991 Y133.581 I-1.956 J-1.151 E.07548
G1 X135.484 Y133.868 E.24873
G3 X136.597 Y133.511 I1.112 J1.553 E.0394
G3 X135.754 Y136.283 I-.087 J1.488 E.17871
G1 X135.558 Y136.156 E.00776
M204 S10000
G1 X135.192 Y136.448 F42000
G1 F11734
M204 S6000
G1 X127.003 Y136.134 E.27184
G2 X127.763 Y135.115 I-1.32 J-1.777 E.04276
G2 X127.45 Y133.496 I-1.749 J-.501 E.05676
G1 X127.128 Y133.141 E.01591
G1 X135.384 Y133.457 E.27408
G3 X136.623 Y133.105 I1.137 J1.646 E.0435
G3 X135.548 Y136.634 I-.113 J1.894 E.22747
G1 X135.262 Y136.45 E.01125
G1 X135.252 Y136.45 E.00034
; WIPE_START
G1 F15476.087
M73 P71 R2
G1 X133.254 Y136.373 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.807 Y134.702 Z1.4 F42000
G1 X124.737 Y134.462 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11734
M204 S5000
G1 X124.736 Y134.441 E.00062
G3 X125.952 Y133.246 I1.35 J.158 E.05665
G1 X126.089 Y133.24 E.00419
G3 X124.731 Y134.712 I-.003 J1.36 E.19332
G1 X124.735 Y134.522 E.00585
; WIPE_START
G1 F12000
M204 S6000
G1 X124.736 Y134.441 E-.03048
G1 X124.788 Y134.199 E-.09405
G1 X124.88 Y133.975 E-.09226
G1 X125.045 Y133.727 E-.11294
G1 X125.216 Y133.556 E-.09218
G1 X125.44 Y133.404 E-.10267
G1 X125.688 Y133.299 E-.10256
G1 X125.952 Y133.246 E-.10229
G1 X126.033 Y133.242 E-.03057
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.131 Y136.048 Z1.4 F42000
G1 X135.127 Y136.838 Z1.4
G1 Z1
G1 E.8 F1800
G1 F11734
M204 S5000
G1 X126.02 Y136.488 E.28003
G3 X126.128 Y132.71 I.069 J-1.889 E.18147
G1 X135.287 Y133.061 E.28166
G3 X136.647 Y132.713 I1.228 J1.969 E.04382
G3 X135.178 Y136.865 I-.141 J2.286 E.2603
; WIPE_START
G1 F12000
M204 S6000
G1 X133.18 Y136.783 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.32 Y134.964 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52308
G1 F11734
M204 S6000
G1 X135.589 Y135.204 E.24545
; LINE_WIDTH: 0.505999
G1 X135.75 Y135.315 E.00738
; LINE_WIDTH: 0.471595
G1 X135.911 Y135.426 E.00683
; LINE_WIDTH: 0.423675
G1 X136.072 Y135.537 E.00607
G1 X136.455 Y135.684 E.01272
G1 X136.738 Y135.632 E.00893
G1 X136.947 Y135.52 E.00736
G2 X137.162 Y135.215 I-.91 J-.87 E.01163
G1 X137.195 Y134.945 E.00842
G1 X137.12 Y134.681 E.00853
G1 X136.91 Y134.453 E.00962
G1 X136.676 Y134.343 E.00801
G2 X136.171 Y134.409 I-.158 J.75 E.0161
G1 X135.73 Y134.668 E.01587
; LINE_WIDTH: 0.475335
G1 X135.668 Y134.696 E.00238
; LINE_WIDTH: 0.522918
G1 X135.607 Y134.724 E.00264
G1 X129.09 Y134.475 E.25509
G1 X129.057 Y134.954 E.01878
G1 X129.26 Y134.962 E.00794
M204 S10000
G1 X136.007 Y134.985 F42000
; LINE_WIDTH: 0.52497
G1 F11734
M204 S6000
G1 X136.445 Y135.229 E.01969
G1 X136.525 Y135.251 E.00327
G1 X136.703 Y135.152 E.00801
G1 X136.752 Y135.028 E.00525
G1 X136.709 Y134.848 E.00726
G1 X136.574 Y134.761 E.00631
G1 X136.374 Y134.788 E.00794
G1 X136.06 Y134.956 E.01398
; WIPE_START
G1 F13069.184
G1 X136.374 Y134.788 E-.14821
G1 X136.574 Y134.761 E-.08411
G1 X136.709 Y134.848 E-.06684
G1 X136.752 Y135.028 E-.077
G1 X136.703 Y135.152 E-.05563
G1 X136.525 Y135.251 E-.08486
G1 X136.445 Y135.229 E-.03467
G1 X136.007 Y134.985 E-.20869
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.413 Y135.747 Z1.4 F42000
G1 X127.641 Y135.825 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.107098
G1 F11734
M204 S6000
G1 X127.559 Y135.951 E.00079
; WIPE_START
G1 F15000
G1 X127.641 Y135.825 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.312 Y136.303 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; LINE_WIDTH: 0.208995
G1 F11734
M204 S6000
G1 X126.841 Y136.008 E.00819
M204 S10000
G1 X126.831 Y135.994 F42000
; LINE_WIDTH: 0.136109
G1 F11734
M204 S6000
G3 X126.343 Y136.305 I-6.576 J-9.802 E.0044
M204 S10000
G1 X126.647 Y136.192 F42000
; LINE_WIDTH: 0.232799
G1 F11734
M204 S6000
G1 X126.386 Y136.218 E.00406
; LINE_WIDTH: 0.182231
G1 X126.196 Y136.226 E.00216
G3 X126.241 Y132.981 I-.105 J-1.624 E.06094
G1 X126.507 Y133.009 E.00303
; LINE_WIDTH: 0.235454
G1 X126.789 Y133.06 E.0045
M204 S10000
G1 X126.497 Y132.921 F42000
; LINE_WIDTH: 0.134846
G1 F11734
M204 S6000
G3 X126.959 Y133.281 I-7.279 J9.815 E.00439
M204 S10000
G1 X126.97 Y133.267 F42000
; LINE_WIDTH: 0.209637
G1 F11734
M204 S6000
G1 X126.465 Y132.92 E.00833
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X126.97 Y133.267 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X121.692 Y127.753 Z1.4 F42000
G1 X119.11 Y125.055 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11734
M204 S6000
G1 X119.476 Y125.133 E.01244
G2 X120.477 Y125.098 I.412 J-2.515 E.03342
G1 X120.209 Y132.059 E.23106
G3 X120.51 Y132.641 I-2.627 J1.726 E.02177
G3 X118.552 Y132.458 I-1.021 J.36 E.14393
G1 X118.843 Y132.006 E.01783
G1 X119.107 Y125.115 E.22876
M204 S10000
G1 X118.727 Y124.421 F42000
G1 F11734
M204 S6000
G1 X118.908 Y124.524 E.0069
G2 X120.906 Y124.515 I.991 J-1.996 E.06876
G1 X120.62 Y131.963 E.24724
G3 X120.979 Y133.041 I-1.676 J1.156 E.0382
G3 X118.202 Y132.249 I-1.49 J-.041 E.18003
G1 X118.44 Y131.879 E.01458
G1 X118.724 Y124.481 E.24559
; WIPE_START
G1 F15476.087
G1 X118.908 Y124.524 E-.07145
G1 X119.13 Y124.622 E-.09244
G1 X119.336 Y124.687 E-.08208
G1 X119.729 Y124.753 E-.15163
G1 X119.967 Y124.758 E-.09033
G1 X120.392 Y124.7 E-.16293
G1 X120.577 Y124.647 E-.07301
G1 X120.665 Y124.611 E-.03613
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.354 Y123.523 Z1.4 F42000
G1 Z1
G1 E.8 F1800
G1 F11734
M204 S6000
G1 X118.686 Y123.875 E.01605
G2 X121.043 Y123.917 I1.202 J-1.287 E.08567
G1 X121.348 Y123.622 E.01409
G1 X121.031 Y131.867 E.27372
G3 X120.552 Y134.573 I-1.602 J1.111 E.10114
G3 X117.853 Y132.039 I-1.063 J-1.572 E.16973
G1 X118.038 Y131.752 E.01133
G1 X118.352 Y123.583 E.27119
; WIPE_START
G1 F15476.087
G1 X118.686 Y123.875 E-.16873
G1 X118.961 Y124.086 E-.1317
G1 X119.274 Y124.241 E-.13271
G1 X119.61 Y124.329 E-.13187
G1 X119.954 Y124.35 E-.13131
G1 X120.12 Y124.328 E-.06369
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.818 Y121.762 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11734
M204 S5000
G1 X118.841 Y121.729 E.00122
G3 X119.726 Y121.248 I1.045 J.869 E.03171
G1 X119.857 Y121.239 E.00404
G3 X118.746 Y121.857 I.029 J1.359 E.22185
G1 X118.782 Y121.81 E.00183
; WIPE_START
G1 F12000
M204 S6000
G1 X118.841 Y121.729 E-.03783
G1 X119.034 Y121.54 E-.10268
G1 X119.26 Y121.392 E-.10264
G1 X119.511 Y121.292 E-.10259
G1 X119.726 Y121.248 E-.08347
G1 X119.857 Y121.239 E-.04991
G1 X120.103 Y121.256 E-.09378
G1 X120.363 Y121.324 E-.1022
G1 X120.564 Y121.423 E-.08489
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.464 Y128.761 Z1.4 F42000
G1 X117.651 Y131.601 Z1.4
G1 Z1
G1 E.8 F1800
M73 P72 R2
G1 F11734
M204 S5000
G1 X118 Y122.529 E.27896
G3 X119.957 Y120.711 I1.892 J.074 E.09112
G3 X121.777 Y122.676 I-.083 J1.902 E.09128
G1 X121.427 Y131.775 E.27981
G3 X117.632 Y131.655 I-1.938 J1.223 E.305
; WIPE_START
G1 F12000
M204 S6000
G1 X117.712 Y129.656 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.533 Y125.583 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52409
G1 F11734
M204 S6000
G1 X119.283 Y132.098 E.25564
; LINE_WIDTH: 0.507507
G1 X119.165 Y132.27 E.00792
; LINE_WIDTH: 0.4725
G1 X119.046 Y132.442 E.00732
; LINE_WIDTH: 0.424226
G2 X118.803 Y133.033 I1.1 J.799 E.02003
G1 X118.848 Y133.25 E.0069
G1 X118.997 Y133.48 E.00851
G1 X119.221 Y133.633 E.00842
G1 X119.484 Y133.688 E.00835
G1 X119.729 Y133.644 E.00772
G1 X119.96 Y133.501 E.00845
G1 X120.117 Y133.279 E.00845
G1 X120.175 Y133.024 E.00811
G2 X120.078 Y132.659 I-1.078 J.091 E.0118
G1 X119.816 Y132.201 E.01638
; LINE_WIDTH: 0.479275
G1 X119.79 Y132.148 E.0021
; LINE_WIDTH: 0.523051
G1 X119.764 Y132.095 E.00232
G1 X120.014 Y125.594 E.25454
G1 X119.593 Y125.584 E.01644
M204 S10000
G1 X119.508 Y132.492 F42000
; LINE_WIDTH: 0.5253
G1 F11734
M204 S6000
G1 X119.259 Y132.937 E.02003
G1 X119.253 Y133.084 E.00578
G1 X119.393 Y133.23 E.00796
G1 X119.572 Y133.236 E.00706
G1 X119.717 Y133.1 E.00782
G1 X119.729 Y132.946 E.00604
G1 X119.535 Y132.546 E.01748
; WIPE_START
G1 F13060.243
G1 X119.729 Y132.946 E-.18407
G1 X119.717 Y133.1 E-.06366
G1 X119.572 Y133.236 E-.08233
G1 X119.393 Y133.23 E-.07436
G1 X119.253 Y133.084 E-.08378
G1 X119.259 Y132.937 E-.06083
G1 X119.508 Y132.492 E-.21097
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.469 Y124.931 Z1.4 F42000
G1 X118.184 Y122.855 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.179795
G1 F11734
M204 S6000
G2 X118.391 Y123.195 I6.892 J-3.966 E.00445
; LINE_WIDTH: 0.142766
G1 X118.428 Y123.252 E.00055
; LINE_WIDTH: 0.113319
G1 X118.512 Y123.371 E.00084
M204 S10000
G1 X118.302 Y123.183 F42000
; LINE_WIDTH: 0.235242
G1 F11734
M204 S6000
G1 X118.266 Y122.828 E.00559
; LINE_WIDTH: 0.181235
G3 X121.511 Y122.528 I1.616 J-.217 E.05925
G1 X121.497 Y122.879 E.00396
; LINE_WIDTH: 0.222678
G1 X121.435 Y123.264 E.00572
M204 S10000
G1 X121.23 Y123.431 F42000
; LINE_WIDTH: 0.110051
G1 F11734
M204 S6000
G1 X121.305 Y123.334 E.00067
; LINE_WIDTH: 0.138663
G1 X121.354 Y123.265 E.00066
; LINE_WIDTH: 0.169242
G1 X121.401 Y123.199 E.00083
; LINE_WIDTH: 0.185908
G1 X121.57 Y122.944 E.00357
; CHANGE_LAYER
; Z_HEIGHT: 1.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X121.401 Y123.199 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 6/20
; update layer progress
M73 L6
M991 S0 P5 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z1.4 I.136 J1.209 P1  F42000
G1 X135.302 Y121.639 Z1.4
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11732
M204 S6000
G1 X128.556 Y121.379 E.22395
G2 X128.616 Y120.014 I-2.631 J-.799 E.04583
G1 X135.584 Y120.281 E.23133
G3 X136.324 Y119.934 I1.326 J1.866 E.02726
G1 X136.415 Y119.922 E.00305
G3 X136.57 Y119.919 I.12 J2.459 E.00512
G3 X135.96 Y121.933 I-.06 J1.081 E.13
G1 X135.516 Y121.647 E.01752
G1 X135.362 Y121.641 E.00513
M204 S10000
G1 X135.245 Y122.044 F42000
G1 F11732
M204 S6000
G1 X127.948 Y121.763 E.24222
G2 X128.012 Y119.583 I-1.961 J-1.148 E.07546
G1 X135.484 Y119.87 E.24804
G3 X136.596 Y119.513 I1.111 J1.549 E.03937
G3 X135.753 Y122.284 I-.086 J1.488 E.17877
G1 X135.389 Y122.049 E.01436
G1 X135.305 Y122.046 E.0028
M204 S10000
G1 X135.188 Y122.449 F42000
G1 F11732
M204 S6000
G1 X127.03 Y122.136 E.27082
G2 X127.776 Y121.141 I-1.372 J-1.807 E.04178
G2 X127.471 Y119.498 I-1.741 J-.527 E.05761
G1 X127.149 Y119.143 E.01591
G1 X135.384 Y119.458 E.27338
G3 X136.622 Y119.106 I1.137 J1.646 E.04347
G3 X135.546 Y122.635 I-.112 J1.894 E.22753
G1 X135.263 Y122.452 E.0112
G1 X135.248 Y122.451 E.00047
; WIPE_START
G1 F15476.087
G1 X133.25 Y122.374 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.92 Y120.245 Z1.6 F42000
G1 X124.914 Y119.953 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11732
M204 S5000
G1 X124.912 Y119.951 E.00006
G3 X125.973 Y119.248 I1.194 J.649 E.0407
G1 X126.105 Y119.241 E.00404
G3 X124.814 Y120.179 I.002 J1.36 E.21011
G1 X124.89 Y120.008 E.00575
; WIPE_START
G1 F12000
M204 S6000
G1 X124.912 Y119.951 E-.02312
G1 X125.048 Y119.75 E-.09224
G1 X125.237 Y119.557 E-.10264
G1 X125.505 Y119.382 E-.12152
G1 X125.709 Y119.301 E-.08366
G1 X125.973 Y119.248 E-.10225
G1 X126.105 Y119.241 E-.05
G1 X126.351 Y119.263 E-.09404
G1 X126.58 Y119.328 E-.09054
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.635 Y122.241 Z1.6 F42000
G1 X135.08 Y122.837 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F11732
M204 S5000
G1 X126.041 Y122.49 E.27795
G3 X126.141 Y118.712 I.074 J-1.888 E.18094
G1 X135.288 Y119.062 E.28127
G3 X136.647 Y118.715 I1.227 J1.969 E.0438
G3 X135.14 Y122.839 I-.141 J2.286 E.26174
G1 X135.14 Y122.839 E.00001
; WIPE_START
G1 F12000
M204 S6000
G1 X133.141 Y122.763 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 6 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.6
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z1.6 F4000
            G39.3 S1
            G0 Z1.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer6 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X129.342 Y120.966 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52305
G1 F11732
M204 S6000
G1 X135.589 Y121.206 E.24461
; LINE_WIDTH: 0.506007
G1 X135.75 Y121.317 E.00738
; LINE_WIDTH: 0.4716
G1 X135.911 Y121.428 E.00683
; LINE_WIDTH: 0.423676
G1 X136.072 Y121.538 E.00607
G1 X136.455 Y121.685 E.01273
G2 X136.866 Y121.588 I-.09 J-1.295 E.01315
G1 X137.062 Y121.408 E.00827
G1 X137.183 Y121.147 E.0089
G1 X137.19 Y121.047 E.00313
G1 X137.121 Y120.685 E.01143
G1 X136.905 Y120.451 E.00986
G1 X136.672 Y120.344 E.00796
G2 X136.171 Y120.411 I-.155 J.75 E.01597
G1 X135.73 Y120.67 E.01588
; LINE_WIDTH: 0.475368
G1 X135.669 Y120.698 E.00237
; LINE_WIDTH: 0.522883
G1 X135.607 Y120.726 E.00263
G1 X129.111 Y120.477 E.25427
G1 X129.086 Y120.956 E.01877
G1 X129.282 Y120.963 E.00766
M204 S10000
G1 X136.008 Y120.986 F42000
; LINE_WIDTH: 0.52505
G1 F11732
M204 S6000
G1 X136.446 Y121.23 E.0197
G1 X136.528 Y121.253 E.00334
G1 X136.709 Y121.149 E.00819
G1 X136.761 Y121.017 E.00559
G1 X136.69 Y120.824 E.00806
G1 X136.532 Y120.752 E.00685
G2 X136.061 Y120.958 I.306 J1.344 E.0203
; WIPE_START
G1 F13067.016
G1 X136.319 Y120.819 E-.1216
G1 X136.532 Y120.752 E-.09239
G1 X136.69 Y120.824 E-.07227
G1 X136.761 Y121.017 E-.08511
G1 X136.709 Y121.149 E-.05899
G1 X136.528 Y121.253 E-.08646
G1 X136.446 Y121.23 E-.03524
G1 X136.008 Y120.986 E-.20795
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.413 Y121.741 Z1.6 F42000
G1 X127.673 Y121.815 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.111338
G1 F11732
M204 S6000
G1 X127.584 Y121.953 E.00092
; WIPE_START
G1 F15000
G1 X127.673 Y121.815 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.352 Y122.306 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; LINE_WIDTH: 0.197392
G1 F11732
M204 S6000
G2 X126.677 Y122.113 I-3.715 J-6.626 E.00475
; LINE_WIDTH: 0.147511
G1 X126.754 Y122.065 E.00077
; LINE_WIDTH: 0.113202
G1 X126.869 Y121.986 E.0008
M204 S10000
G1 X126.684 Y122.19 F42000
; LINE_WIDTH: 0.24172
G1 F11732
M204 S6000
G1 X126.469 Y122.214 E.00349
; LINE_WIDTH: 0.216165
G1 X126.282 Y122.226 E.00265
; LINE_WIDTH: 0.180802
G3 X126.262 Y118.982 I-.168 J-1.621 E.06107
; LINE_WIDTH: 0.203005
G1 X126.583 Y119.02 E.00421
; LINE_WIDTH: 0.241668
G1 X126.811 Y119.063 E.00377
M204 S10000
G1 X126.516 Y118.922 F42000
; LINE_WIDTH: 0.13638
G1 F11732
M204 S6000
G3 X126.98 Y119.283 I-6.903 J9.365 E.00447
M204 S10000
G1 X126.99 Y119.27 F42000
; LINE_WIDTH: 0.207711
G1 F11732
M204 S6000
G1 X126.488 Y118.921 E.00821
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X126.99 Y119.27 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X132.056 Y124.979 Z1.6 F42000
G1 X135.302 Y128.638 Z1.6
G1 Z1.2
M73 P73 R2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11732
M204 S6000
G1 X128.535 Y128.378 E.22464
G2 X128.592 Y127.013 I-2.584 J-.791 E.04584
G1 X135.584 Y127.28 E.23213
G3 X136.324 Y126.933 I1.325 J1.864 E.02725
G1 X136.415 Y126.921 E.00306
G3 X136.57 Y126.918 I.12 J2.482 E.00513
G3 X135.965 Y128.935 I-.059 J1.081 E.12987
G1 X135.516 Y128.646 E.0177
G1 X135.362 Y128.64 E.00512
M204 S10000
G1 X135.511 Y129.127 F42000
G1 F11732
M204 S6000
G1 X135.389 Y129.049 E.00479
G1 X127.921 Y128.762 E.24793
G2 X128.011 Y126.583 I-1.95 J-1.173 E.07545
G1 X135.484 Y126.869 E.24807
G3 X136.596 Y126.512 I1.111 J1.549 E.03937
G3 X135.757 Y129.285 I-.086 J1.488 E.17866
G1 X135.561 Y129.159 E.00772
M204 S10000
G1 X135.188 Y129.448 F42000
G1 F11732
M204 S6000
G1 X127.012 Y129.135 E.27141
G2 X127.616 Y128.459 I-1.696 J-2.123 E.0302
G2 X127.43 Y126.473 I-1.577 J-.854 E.07018
G1 X127.124 Y126.142 E.01495
G1 X135.384 Y126.458 E.27421
G3 X136.622 Y126.105 I1.137 J1.645 E.04347
G3 X135.549 Y129.636 I-.112 J1.894 E.22745
G1 X135.262 Y129.451 E.01131
G1 X135.248 Y129.451 E.00048
; WIPE_START
G1 F15476.087
G1 X133.25 Y129.374 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.803 Y127.699 Z1.6 F42000
G1 X124.737 Y127.46 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11732
M204 S5000
G1 X124.736 Y127.442 E.00054
G3 X125.952 Y126.247 I1.35 J.157 E.05664
G1 X126.084 Y126.24 E.00405
G3 X124.732 Y127.713 I.002 J1.359 E.19338
G1 X124.735 Y127.52 E.00593
; WIPE_START
G1 F12000
M204 S6000
G1 X124.736 Y127.442 E-.02941
G1 X124.795 Y127.179 E-.10253
G1 X124.904 Y126.932 E-.10266
G1 X125.059 Y126.711 E-.10257
G1 X125.234 Y126.542 E-.09223
G1 X125.459 Y126.394 E-.1026
G1 X125.71 Y126.294 E-.10258
G1 X125.952 Y126.247 E-.09369
G1 X126.035 Y126.243 E-.03173
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.129 Y129.06 Z1.6 F42000
G1 X135.086 Y129.837 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F11732
M204 S5000
G1 X126.018 Y129.489 E.27884
G3 X126.12 Y125.711 I.071 J-1.888 E.18118
G1 X135.288 Y126.062 E.28191
G3 X136.647 Y125.714 I1.228 J1.969 E.0438
G3 X135.145 Y129.842 I-.141 J2.286 E.26157
; WIPE_START
G1 F12000
M204 S6000
G1 X133.146 Y129.765 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.32 Y127.965 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523045
G1 F11732
M204 S6000
G1 X135.589 Y128.205 E.24545
; LINE_WIDTH: 0.505999
G1 X135.75 Y128.316 E.00741
; LINE_WIDTH: 0.471595
G1 X135.912 Y128.428 E.00686
; LINE_WIDTH: 0.423666
G1 X136.074 Y128.539 E.00609
G1 X136.455 Y128.684 E.01264
G1 X136.812 Y128.617 E.01129
G1 X137.029 Y128.448 E.00853
G1 X137.162 Y128.215 E.00832
G1 X137.195 Y127.949 E.00832
G1 X137.12 Y127.684 E.00857
G1 X136.908 Y127.452 E.00974
G1 X136.675 Y127.344 E.00796
G2 X136.171 Y127.41 I-.158 J.748 E.01609
G1 X135.73 Y127.669 E.01586
; LINE_WIDTH: 0.475275
G1 X135.669 Y127.697 E.00238
; LINE_WIDTH: 0.522878
G1 X135.607 Y127.725 E.00265
G1 X129.094 Y127.476 E.25493
G1 X129.065 Y127.955 E.01878
G1 X129.26 Y127.962 E.00764
M204 S10000
G1 X136.008 Y127.985 F42000
; LINE_WIDTH: 0.52515
G1 F11732
M204 S6000
G1 X136.442 Y128.229 E.01958
G1 X136.58 Y128.24 E.00541
G1 X136.723 Y128.119 E.00737
G1 X136.752 Y128.03 E.00367
G1 X136.709 Y127.849 E.00733
G1 X136.574 Y127.762 E.00631
G1 X136.374 Y127.789 E.00792
G1 X136.061 Y127.957 E.01398
; WIPE_START
G1 F13064.305
G1 X136.374 Y127.789 E-.14851
G1 X136.574 Y127.762 E-.08413
G1 X136.709 Y127.849 E-.06697
G1 X136.752 Y128.03 E-.0778
G1 X136.723 Y128.119 E-.03895
G1 X136.58 Y128.24 E-.07826
G1 X136.442 Y128.229 E-.05746
G1 X136.008 Y127.985 E-.20793
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.494 Y126.644 Z1.6 F42000
G1 X127.74 Y126.51 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.111267
G1 F11732
M204 S6000
G1 X127.662 Y126.366 E.00091
; WIPE_START
G1 F15000
G1 X127.74 Y126.51 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.458 Y125.92 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; LINE_WIDTH: 0.197524
G1 F11732
M204 S6000
G3 X126.768 Y126.136 I-3.509 J5.372 E.00476
; LINE_WIDTH: 0.146695
G1 X126.843 Y126.19 E.00078
; LINE_WIDTH: 0.112649
G1 X126.95 Y126.276 E.00078
M204 S10000
G1 X126.78 Y126.059 F42000
; LINE_WIDTH: 0.234115
G1 F11732
M204 S6000
G1 X126.507 Y126.01 E.00433
; LINE_WIDTH: 0.181739
G1 X126.241 Y125.982 E.00302
G2 X126.317 Y129.223 I-.139 J1.625 E.06196
; LINE_WIDTH: 0.234891
G1 X126.67 Y129.189 E.00555
M204 S10000
G1 X126.37 Y129.306 F42000
; LINE_WIDTH: 0.128043
G1 F11732
M204 S6000
G2 X126.855 Y128.981 I-6.498 J-10.238 E.00405
M204 S10000
G1 X126.864 Y128.994 F42000
; LINE_WIDTH: 0.206657
G1 F11732
M204 S6000
G1 X126.338 Y129.305 E.00816
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X126.864 Y128.994 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X132.861 Y133.716 Z1.6 F42000
G1 X135.302 Y135.637 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11732
M204 S6000
G1 X128.535 Y135.378 E.22464
G2 X128.592 Y134.012 I-2.584 J-.791 E.04584
G1 X135.584 Y134.279 E.23213
G3 X136.324 Y133.932 I1.325 J1.864 E.02725
G1 X136.415 Y133.92 E.00306
G3 X136.57 Y133.917 I.12 J2.482 E.00513
G3 X135.965 Y135.934 I-.059 J1.081 E.12987
G1 X135.516 Y135.645 E.0177
G1 X135.362 Y135.639 E.00512
M204 S10000
G1 X135.511 Y136.126 F42000
G1 F11732
M204 S6000
G1 X135.389 Y136.048 E.00479
G1 X127.921 Y135.762 E.24793
G2 X128.011 Y133.582 I-1.95 J-1.173 E.07545
G1 X135.484 Y133.868 E.24807
G3 X136.596 Y133.511 I1.111 J1.549 E.03937
G3 X135.757 Y136.284 I-.086 J1.488 E.17866
G1 X135.561 Y136.158 E.00772
M204 S10000
G1 X135.188 Y136.447 F42000
G1 F11732
M204 S6000
G1 X127.012 Y136.134 E.27141
G2 X127.616 Y135.458 I-1.696 J-2.123 E.0302
G2 X127.43 Y133.472 I-1.577 J-.854 E.07018
G1 X127.124 Y133.141 E.01495
G1 X135.384 Y133.457 E.27421
G3 X136.622 Y133.105 I1.137 J1.645 E.04347
G3 X135.549 Y136.635 I-.112 J1.894 E.22745
G1 X135.262 Y136.45 E.01131
G1 X135.248 Y136.45 E.00048
; WIPE_START
G1 F15476.087
G1 X133.25 Y136.373 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.803 Y134.699 Z1.6 F42000
G1 X124.737 Y134.459 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11732
M204 S5000
G1 X124.736 Y134.441 E.00054
G3 X125.952 Y133.246 I1.35 J.157 E.05664
G1 X126.084 Y133.24 E.00405
G3 X124.732 Y134.712 I.002 J1.359 E.19338
G1 X124.735 Y134.519 E.00593
; WIPE_START
G1 F12000
M204 S6000
G1 X124.736 Y134.441 E-.02941
G1 X124.795 Y134.178 E-.10253
G1 X124.904 Y133.931 E-.10266
G1 X125.059 Y133.71 E-.10257
G1 X125.234 Y133.541 E-.09223
G1 X125.459 Y133.394 E-.1026
G1 X125.71 Y133.293 E-.10258
G1 X125.952 Y133.246 E-.09369
G1 X126.035 Y133.242 E-.03173
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.129 Y136.059 Z1.6 F42000
G1 X135.086 Y136.836 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F11732
M204 S5000
G1 X126.018 Y136.488 E.27884
G3 X126.12 Y132.71 I.071 J-1.888 E.18118
G1 X135.288 Y133.061 E.28191
G3 X136.647 Y132.713 I1.228 J1.969 E.0438
G3 X135.145 Y136.841 I-.141 J2.286 E.26157
; WIPE_START
G1 F12000
M204 S6000
G1 X133.146 Y136.764 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.32 Y134.964 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523045
G1 F11732
M204 S6000
G1 X135.589 Y135.204 E.24545
; LINE_WIDTH: 0.505999
G1 X135.75 Y135.315 E.00741
; LINE_WIDTH: 0.471595
G1 X135.912 Y135.427 E.00686
; LINE_WIDTH: 0.423666
G1 X136.074 Y135.538 E.00609
G1 X136.455 Y135.684 E.01264
G1 X136.812 Y135.617 E.01129
G1 X137.029 Y135.448 E.00853
G1 X137.162 Y135.215 E.00832
G1 X137.195 Y134.949 E.00832
G1 X137.12 Y134.683 E.00857
G1 X136.908 Y134.451 E.00974
G1 X136.675 Y134.343 E.00796
G2 X136.171 Y134.409 I-.158 J.748 E.01609
G1 X135.73 Y134.668 E.01586
; LINE_WIDTH: 0.475275
G1 X135.669 Y134.696 E.00238
; LINE_WIDTH: 0.522878
G1 X135.607 Y134.724 E.00265
G1 X129.094 Y134.475 E.25493
G1 X129.065 Y134.954 E.01878
G1 X129.26 Y134.962 E.00764
M204 S10000
G1 X136.008 Y134.985 F42000
; LINE_WIDTH: 0.52515
G1 F11732
M204 S6000
G1 X136.442 Y135.228 E.01958
G1 X136.58 Y135.239 E.00541
G1 X136.723 Y135.118 E.00737
G1 X136.752 Y135.029 E.00367
G1 X136.709 Y134.848 E.00733
G1 X136.574 Y134.761 E.00631
G1 X136.374 Y134.788 E.00792
G1 X136.061 Y134.956 E.01398
; WIPE_START
G1 F13064.305
G1 X136.374 Y134.788 E-.14851
G1 X136.574 Y134.761 E-.08413
G1 X136.709 Y134.848 E-.06697
G1 X136.752 Y135.029 E-.0778
G1 X136.723 Y135.118 E-.03895
G1 X136.58 Y135.239 E-.07826
G1 X136.442 Y135.228 E-.05746
G1 X136.008 Y134.985 E-.20793
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.494 Y133.644 Z1.6 F42000
G1 X127.74 Y133.509 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.111267
G1 F11732
M204 S6000
G1 X127.662 Y133.365 E.00091
; WIPE_START
G1 F15000
G1 X127.74 Y133.509 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.458 Y132.919 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; LINE_WIDTH: 0.197524
G1 F11732
M204 S6000
G3 X126.768 Y133.135 I-3.509 J5.372 E.00476
; LINE_WIDTH: 0.146695
G1 X126.843 Y133.19 E.00078
; LINE_WIDTH: 0.112649
G1 X126.95 Y133.276 E.00078
M204 S10000
G1 X126.78 Y133.058 F42000
; LINE_WIDTH: 0.234115
G1 F11732
M204 S6000
G1 X126.507 Y133.009 E.00433
; LINE_WIDTH: 0.181739
G1 X126.241 Y132.981 E.00302
G2 X126.317 Y136.222 I-.139 J1.625 E.06196
; LINE_WIDTH: 0.234891
G1 X126.67 Y136.188 E.00555
M204 S10000
G1 X126.37 Y136.306 F42000
; LINE_WIDTH: 0.128043
G1 F11732
M204 S6000
G2 X126.855 Y135.981 I-6.498 J-10.238 E.00405
M204 S10000
G1 X126.864 Y135.993 F42000
; LINE_WIDTH: 0.206657
G1 F11732
M204 S6000
G1 X126.338 Y136.304 E.00816
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X126.864 Y135.993 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X122.453 Y129.765 Z1.6 F42000
G1 X119.11 Y125.046 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11732
M204 S6000
G1 X119.378 Y125.116 E.0092
G2 X120.476 Y125.105 I.516 J-3.353 E.03658
G1 X120.209 Y132.059 E.23083
G3 X120.51 Y132.64 I-2.65 J1.738 E.02174
G3 X118.552 Y132.457 I-1.021 J.359 E.14379
G1 X118.843 Y132.006 E.01778
G1 X119.108 Y125.106 E.22908
M204 S10000
G1 X118.726 Y124.438 F42000
G1 F11732
M204 S6000
G1 X119.055 Y124.591 E.01203
G2 X120.907 Y124.501 I.831 J-1.999 E.06357
G1 X120.62 Y131.963 E.24771
G3 X120.978 Y133.043 I-1.671 J1.154 E.03824
G3 X118.203 Y132.248 I-1.49 J-.042 E.1801
G1 X118.44 Y131.879 E.01454
G1 X118.724 Y124.498 E.24502
; WIPE_START
G1 F15476.087
G1 X119.055 Y124.591 E-.13065
G1 X119.46 Y124.717 E-.16126
G1 X119.674 Y124.748 E-.08202
G1 X120.073 Y124.751 E-.15183
G1 X120.495 Y124.672 E-.16299
G1 X120.672 Y124.61 E-.07125
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.354 Y123.52 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
G1 F11732
M204 S6000
G1 X118.665 Y123.854 E.01515
G2 X120.992 Y123.961 I1.224 J-1.264 E.08442
G1 X121.348 Y123.638 E.01594
G1 X121.031 Y131.867 E.27319
G3 X120.493 Y134.611 I-1.601 J1.111 E.10344
G3 X117.853 Y132.039 I-1.001 J-1.614 E.16724
G1 X118.038 Y131.752 E.01131
G1 X118.352 Y123.58 E.2713
; WIPE_START
G1 F15476.087
G1 X118.665 Y123.854 E-.15833
G1 X118.911 Y124.054 E-.12022
G1 X119.212 Y124.216 E-.12997
G1 X119.542 Y124.317 E-.13116
M73 P74 R2
G1 X119.887 Y124.352 E-.13173
G1 X120.119 Y124.329 E-.0886
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.826 Y121.754 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11732
M204 S5000
G1 X118.841 Y121.729 E.00089
G3 X119.726 Y121.248 I1.045 J.869 E.0317
G1 X119.862 Y121.239 E.00418
G3 X118.69 Y121.953 I.024 J1.359 E.21828
G1 X118.792 Y121.803 E.00557
; WIPE_START
G1 F12000
M204 S6000
G1 X118.841 Y121.729 E-.03378
G1 X119.034 Y121.54 E-.10267
G1 X119.216 Y121.416 E-.08376
G1 X119.511 Y121.292 E-.12135
G1 X119.726 Y121.248 E-.08352
G1 X119.862 Y121.239 E-.05175
G1 X120.102 Y121.256 E-.09141
G1 X120.363 Y121.324 E-.10269
G1 X120.574 Y121.428 E-.08907
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.458 Y128.761 Z1.6 F42000
G1 X117.653 Y131.548 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F11732
M204 S5000
G1 X118 Y122.531 E.27728
G3 X119.965 Y120.711 I1.892 J.072 E.09143
G3 X121.777 Y122.676 I-.08 J1.891 E.09117
G1 X121.427 Y131.775 E.27981
G3 X117.65 Y131.63 I-1.938 J1.221 E.30569
G1 X117.651 Y131.608 E.00067
; WIPE_START
G1 F12000
M204 S6000
G1 X117.728 Y129.61 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.534 Y125.576 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.524095
G1 F11732
M204 S6000
G1 X119.283 Y132.098 E.25592
; LINE_WIDTH: 0.507507
G1 X119.165 Y132.27 E.00791
; LINE_WIDTH: 0.4725
G1 X119.046 Y132.442 E.00731
; LINE_WIDTH: 0.42422
G2 X118.804 Y133.024 I.985 J.752 E.01979
G1 X118.864 Y133.284 E.00829
G1 X119.022 Y133.503 E.00841
G1 X119.253 Y133.645 E.00843
G1 X119.517 Y133.687 E.00831
G2 X120.17 Y133.085 I-.027 J-.684 E.03004
G2 X120.078 Y132.658 I-1.212 J.04 E.01363
G1 X119.816 Y132.201 E.01635
; LINE_WIDTH: 0.47925
G1 X119.79 Y132.148 E.00211
; LINE_WIDTH: 0.523051
G1 X119.764 Y132.095 E.00232
G1 X120.013 Y125.601 E.25427
G1 X119.594 Y125.579 E.01645
M204 S10000
G1 X119.508 Y132.49 F42000
; LINE_WIDTH: 0.52281
G1 F11732
M204 S6000
G1 X119.261 Y132.919 E.01939
G1 X119.262 Y133.103 E.00719
G1 X119.404 Y133.235 E.0076
G1 X119.583 Y133.234 E.00697
G1 X119.717 Y133.108 E.00721
G1 X119.722 Y132.935 E.00677
G1 X119.534 Y132.544 E.01697
; WIPE_START
G1 F13128.009
G1 X119.722 Y132.935 E-.17888
G1 X119.717 Y133.108 E-.07132
G1 X119.583 Y133.234 E-.07598
G1 X119.404 Y133.235 E-.0735
G1 X119.262 Y133.103 E-.08007
G1 X119.261 Y132.919 E-.07583
G1 X119.508 Y132.49 E-.20441
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.748 Y124.895 Z1.6 F42000
G1 X118.675 Y124.163 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.107827
G1 F11732
M204 S6000
G1 X118.536 Y124.074 E.00087
; WIPE_START
G1 F15000
G1 X118.675 Y124.163 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.184 Y122.843 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; LINE_WIDTH: 0.197423
G1 F11732
M204 S6000
G2 X118.376 Y123.167 I6.718 J-3.773 E.00475
; LINE_WIDTH: 0.147543
G1 X118.424 Y123.244 E.00077
; LINE_WIDTH: 0.1132
G1 X118.504 Y123.359 E.0008
M204 S10000
G1 X118.299 Y123.174 F42000
; LINE_WIDTH: 0.24174
G1 F11732
M204 S6000
G1 X118.276 Y122.959 E.00349
; LINE_WIDTH: 0.216172
G1 X118.264 Y122.772 E.00265
; LINE_WIDTH: 0.181024
G3 X121.511 Y122.527 I1.62 J-.168 E.05862
G1 X121.496 Y122.883 E.004
; LINE_WIDTH: 0.213888
G1 X121.47 Y123.073 E.00267
; LINE_WIDTH: 0.242371
G1 X121.427 Y123.301 E.00377
M204 S10000
G1 X121.568 Y123.006 F42000
; LINE_WIDTH: 0.136368
G1 F11732
M204 S6000
G3 X121.207 Y123.47 I-9.863 J-7.302 E.00448
M204 S10000
G1 X121.219 Y123.48 F42000
; LINE_WIDTH: 0.207677
G1 F11732
M204 S6000
G1 X121.569 Y122.977 E.00822
; CHANGE_LAYER
; Z_HEIGHT: 1.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X121.219 Y123.48 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 7/20
; update layer progress
M73 L7
M991 S0 P6 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z1.6 I.143 J1.209 P1  F42000
G1 X135.705 Y121.768 Z1.6
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11607
M204 S6000
G1 X135.516 Y121.647 E.00743
G1 X128.556 Y121.379 E.23107
G2 X128.614 Y120.014 I-2.587 J-.794 E.04584
G1 X135.584 Y120.281 E.23139
G3 X136.328 Y119.933 I1.322 J1.861 E.02737
G1 X136.415 Y119.922 E.00292
G3 X136.569 Y119.919 I.122 J2.491 E.00511
G3 X135.96 Y121.933 I-.059 J1.081 E.13005
G1 X135.755 Y121.801 E.00809
M204 S10000
G1 X135.519 Y122.133 F42000
G1 F11607
M204 S6000
G1 X135.389 Y122.049 E.0051
G1 X127.945 Y121.763 E.24712
G2 X128.033 Y119.584 I-1.964 J-1.17 E.07541
G1 X135.484 Y119.87 E.24736
G3 X136.595 Y119.513 I1.11 J1.546 E.03934
G3 X135.753 Y122.284 I-.085 J1.488 E.17882
G1 X135.569 Y122.165 E.00725
M204 S10000
G1 X135.333 Y122.497 F42000
G1 F11607
M204 S6000
G1 X135.263 Y122.452 E.00277
G1 X127.033 Y122.136 E.27319
G2 X127.655 Y121.427 I-1.625 J-2.053 E.03144
G2 X127.471 Y119.498 I-1.598 J-.821 E.0679
G1 X127.149 Y119.143 E.0159
G1 X135.384 Y119.458 E.27338
G3 X136.621 Y119.106 I1.137 J1.646 E.04345
G3 X135.546 Y122.634 I-.111 J1.894 E.22758
G1 X135.383 Y122.53 E.00642
; WIPE_START
G1 F15476.087
G1 X135.263 Y122.452 E-.05451
G1 X133.407 Y122.381 E-.70549
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.069 Y120.284 Z1.8 F42000
G1 X124.915 Y119.954 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11607
M204 S5000
G1 X125.058 Y119.736 E.00803
G3 X125.973 Y119.248 I1.049 J.865 E.03268
G1 X126.1 Y119.241 E.0039
G3 X124.885 Y120.005 I.007 J1.36 E.21603
; WIPE_START
G1 F12000
M204 S6000
G1 X125.058 Y119.736 E-.12194
G1 X125.237 Y119.557 E-.09602
G1 X125.476 Y119.397 E-.10923
G1 X125.709 Y119.301 E-.09596
G1 X125.973 Y119.248 E-.10218
G1 X126.1 Y119.241 E-.04818
G1 X126.349 Y119.262 E-.09515
G1 X126.58 Y119.328 E-.09134
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.629 Y122.255 Z1.8 F42000
G1 X135.026 Y122.835 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F11607
M204 S5000
G1 X126.039 Y122.49 E.27634
G3 X126.135 Y118.712 I.073 J-1.888 E.18087
G1 X135.288 Y119.062 E.28145
G3 X136.647 Y118.715 I1.228 J1.969 E.04379
G3 X135.14 Y122.839 I-.141 J2.286 E.26175
G1 X135.086 Y122.837 E.00168
; WIPE_START
G1 F12000
M204 S6000
G1 X133.087 Y122.761 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 7 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.8
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z1.8 F4000
            G39.3 S1
            G0 Z1.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer7 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X129.341 Y120.966 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52308
G1 F11607
M204 S6000
G1 X135.597 Y121.206 E.24493
; LINE_WIDTH: 0.506099
G1 X135.755 Y121.317 E.00729
; LINE_WIDTH: 0.471655
G1 X135.913 Y121.428 E.00675
; LINE_WIDTH: 0.423674
G1 X136.072 Y121.538 E.006
G1 X136.455 Y121.685 E.01274
G1 X136.737 Y121.634 E.00889
G1 X136.947 Y121.521 E.00739
G2 X137.164 Y121.211 I-.921 J-.875 E.01179
G1 X137.195 Y120.951 E.00812
G1 X137.122 Y120.687 E.00849
G1 X136.903 Y120.45 E.01001
G1 X136.672 Y120.344 E.00789
G2 X136.172 Y120.411 I-.155 J.748 E.01595
G1 X135.73 Y120.67 E.01588
; LINE_WIDTH: 0.475373
G1 X135.669 Y120.698 E.00237
; LINE_WIDTH: 0.522851
G1 X135.608 Y120.726 E.00263
G1 X129.108 Y120.477 E.25439
G1 X129.096 Y120.956 E.01877
G1 X129.281 Y120.963 E.00724
M204 S10000
G1 X136.008 Y120.986 F42000
; LINE_WIDTH: 0.52502
G1 F11607
M204 S6000
G1 X136.446 Y121.23 E.0197
G1 X136.524 Y121.253 E.00323
G1 X136.691 Y121.175 E.00724
G1 X136.753 Y121.029 E.00621
G1 X136.709 Y120.85 E.00726
G1 X136.573 Y120.762 E.00636
G1 X136.375 Y120.789 E.00785
G1 X136.061 Y120.958 E.014
; WIPE_START
G1 F13067.829
G1 X136.375 Y120.789 E-.14809
G1 X136.573 Y120.762 E-.08305
G1 X136.709 Y120.85 E-.06726
M73 P75 R2
G1 X136.753 Y121.029 E-.07678
G1 X136.691 Y121.175 E-.06573
G1 X136.524 Y121.253 E-.07657
G1 X136.446 Y121.23 E-.03414
G1 X136.008 Y120.986 E-.20837
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.494 Y119.642 Z1.8 F42000
G1 X127.762 Y119.511 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.110742
G1 F11607
M204 S6000
G1 X127.684 Y119.367 E.0009
; WIPE_START
G1 F15000
G1 X127.762 Y119.511 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.487 Y118.922 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; LINE_WIDTH: 0.208531
G1 F11607
M204 S6000
G1 X126.991 Y119.269 E.00826
M204 S10000
G1 X126.98 Y119.283 F42000
; LINE_WIDTH: 0.127883
G1 F11607
M204 S6000
G2 X126.522 Y118.923 I-7.492 J9.064 E.00403
M204 S10000
G1 X126.81 Y119.061 F42000
; LINE_WIDTH: 0.235165
G1 F11607
M204 S6000
G1 X126.528 Y119.011 E.00449
; LINE_WIDTH: 0.181494
G1 X126.261 Y118.982 E.00302
G2 X126.282 Y122.225 I-.147 J1.622 E.06136
; LINE_WIDTH: 0.216353
G1 X126.476 Y122.213 E.00274
; LINE_WIDTH: 0.24355
G1 X126.693 Y122.187 E.00358
M204 S10000
G1 X126.876 Y121.982 F42000
; LINE_WIDTH: 0.11412
G1 F11607
M204 S6000
G1 X126.759 Y122.064 E.00083
; LINE_WIDTH: 0.156012
G1 X126.649 Y122.134 E.0012
; LINE_WIDTH: 0.181874
G1 X126.364 Y122.306 E.00377
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X126.649 Y122.134 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X132.806 Y126.645 Z1.8 F42000
G1 X135.7 Y128.765 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11607
M204 S6000
G1 X135.516 Y128.646 E.00727
G1 X128.539 Y128.379 E.23161
G2 X128.592 Y127.013 I-2.654 J-.786 E.04581
G1 X135.584 Y127.28 E.23212
G3 X136.327 Y126.933 I1.324 J1.864 E.02736
G1 X136.415 Y126.921 E.00292
G3 X136.569 Y126.918 I.123 J2.516 E.00511
G3 X135.961 Y128.933 I-.058 J1.081 E.13004
G1 X135.751 Y128.797 E.0083
M204 S10000
G1 X135.515 Y129.129 F42000
G1 F11607
M204 S6000
G1 X135.389 Y129.049 E.00495
G1 X127.91 Y128.762 E.24827
G2 X127.992 Y126.583 I-1.84 J-1.16 E.07578
G1 X135.484 Y126.869 E.2487
G3 X136.595 Y126.512 I1.11 J1.546 E.03934
G3 X135.754 Y129.284 I-.085 J1.488 E.17879
G1 X135.565 Y129.162 E.00747
M204 S10000
G1 X135.329 Y129.494 F42000
G1 F11607
M204 S6000
G1 X135.262 Y129.451 E.00262
G1 X127.012 Y129.135 E.27388
G2 X127.649 Y128.398 I-1.698 J-2.11 E.03249
G2 X127.45 Y126.497 I-1.615 J-.792 E.06683
G1 X127.128 Y126.142 E.0159
G1 X135.384 Y126.458 E.27407
G3 X136.621 Y126.105 I1.138 J1.646 E.04345
G3 X135.548 Y129.635 I-.111 J1.894 E.22754
G1 X135.379 Y129.526 E.00665
; WIPE_START
G1 F15476.087
G1 X135.262 Y129.451 E-.05279
G1 X133.403 Y129.38 E-.70721
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.951 Y127.73 Z1.8 F42000
G1 X124.738 Y127.461 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11607
M204 S5000
G1 X124.794 Y127.179 E.00886
G3 X125.952 Y126.247 I1.292 J.421 E.04832
G1 X126.079 Y126.24 E.0039
G3 X124.729 Y127.521 I.008 J1.359 E.19945
; WIPE_START
G1 F12000
M204 S6000
G1 X124.794 Y127.179 E-.13226
G1 X124.904 Y126.931 E-.10273
G1 X125.027 Y126.749 E-.08367
G1 X125.216 Y126.556 E-.10264
G1 X125.484 Y126.382 E-.12137
G1 X125.689 Y126.3 E-.08385
G1 X125.952 Y126.247 E-.10204
G1 X126.034 Y126.243 E-.03144
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.124 Y129.07 Z1.8 F42000
G1 X135.042 Y129.835 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F11607
M204 S5000
G1 X126.02 Y129.489 E.27742
G3 X126.114 Y125.711 I.074 J-1.888 E.18077
G1 X135.287 Y126.062 E.28209
G3 X136.647 Y125.714 I1.228 J1.969 E.04379
G3 X135.14 Y129.839 I-.14 J2.286 E.26175
G1 X135.102 Y129.837 E.00118
; WIPE_START
G1 F12000
M204 S6000
G1 X133.103 Y129.761 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.319 Y127.965 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52302
G1 F11607
M204 S6000
G1 X135.589 Y128.205 E.24544
; LINE_WIDTH: 0.505999
G1 X135.751 Y128.317 E.00743
; LINE_WIDTH: 0.471595
G1 X135.913 Y128.428 E.00688
; LINE_WIDTH: 0.423679
G1 X136.075 Y128.54 E.00611
G1 X136.445 Y128.684 E.0123
G2 X136.863 Y128.588 I-.071 J-1.279 E.01339
G1 X137.063 Y128.406 E.00837
G1 X137.183 Y128.146 E.0089
G1 X137.19 Y128.045 E.00314
G1 X137.122 Y127.686 E.01133
G1 X136.902 Y127.448 E.01005
G1 X136.672 Y127.343 E.00786
G2 X136.171 Y127.41 I-.155 J.749 E.01597
G1 X135.73 Y127.669 E.01587
; LINE_WIDTH: 0.475313
G1 X135.669 Y127.697 E.00238
; LINE_WIDTH: 0.522851
G1 X135.607 Y127.725 E.00264
G1 X129.094 Y127.476 E.25491
G1 X129.065 Y127.955 E.01877
G1 X129.259 Y127.962 E.00763
M204 S10000
G1 X136.008 Y127.985 F42000
; LINE_WIDTH: 0.52568
G1 F11607
M204 S6000
G1 X136.441 Y128.229 E.01954
G1 X136.531 Y128.25 E.00364
G1 X136.709 Y128.148 E.00805
G1 X136.761 Y128.016 E.00558
G1 X136.689 Y127.823 E.0081
G1 X136.531 Y127.752 E.00681
G2 X136.061 Y127.957 I.298 J1.323 E.0203
; WIPE_START
G1 F13049.963
G1 X136.322 Y127.817 E-.1232
G1 X136.531 Y127.752 E-.09073
G1 X136.689 Y127.823 E-.07188
G1 X136.761 Y128.016 E-.08549
G1 X136.709 Y128.148 E-.05892
G1 X136.531 Y128.25 E-.08502
G1 X136.441 Y128.229 E-.03846
G1 X136.008 Y127.985 E-.20629
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.548 Y126.371 Z1.8 F42000
G1 X126.465 Y125.921 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.209989
G1 F11607
M204 S6000
G1 X126.97 Y126.268 E.00834
M204 S10000
G1 X126.959 Y126.282 F42000
; LINE_WIDTH: 0.137764
G1 F11607
M204 S6000
G2 X126.496 Y125.922 I-8.111 J9.945 E.00453
M204 S10000
G1 X126.789 Y126.061 F42000
; LINE_WIDTH: 0.235201
G1 F11607
M204 S6000
G1 X126.507 Y126.01 E.00449
; LINE_WIDTH: 0.181774
G1 X126.24 Y125.982 E.00303
G2 X126.317 Y129.223 I-.14 J1.625 E.062
; LINE_WIDTH: 0.23528
G1 X126.671 Y129.187 E.00558
M204 S10000
G1 X126.855 Y128.982 F42000
; LINE_WIDTH: 0.114426
G1 F11607
M204 S6000
G1 X126.736 Y129.065 E.00085
; LINE_WIDTH: 0.146479
G1 X126.673 Y129.104 E.00062
; LINE_WIDTH: 0.187545
G3 X126.341 Y129.305 I-4.361 J-6.831 E.00458
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X126.673 Y129.104 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X132.815 Y133.635 Z1.8 F42000
G1 X135.7 Y135.764 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11607
M204 S6000
G1 X135.516 Y135.645 E.00727
G1 X128.539 Y135.378 E.23161
G2 X128.592 Y134.012 I-2.654 J-.786 E.04581
G1 X135.584 Y134.279 E.23212
G3 X136.327 Y133.932 I1.324 J1.864 E.02736
G1 X136.415 Y133.92 E.00292
G3 X136.569 Y133.917 I.123 J2.516 E.00511
G3 X135.961 Y135.932 I-.058 J1.081 E.13004
G1 X135.751 Y135.797 E.0083
M204 S10000
G1 X135.515 Y136.129 F42000
G1 F11607
M204 S6000
G1 X135.389 Y136.048 E.00495
G1 X127.91 Y135.761 E.24827
G2 X127.992 Y133.582 I-1.84 J-1.16 E.07578
G1 X135.484 Y133.868 E.2487
G3 X136.595 Y133.511 I1.11 J1.546 E.03934
G3 X135.754 Y136.283 I-.085 J1.488 E.17879
G1 X135.565 Y136.161 E.00747
M204 S10000
G1 X135.329 Y136.493 F42000
G1 F11607
M204 S6000
G1 X135.262 Y136.45 E.00262
G1 X127.012 Y136.134 E.27388
G2 X127.649 Y135.397 I-1.698 J-2.11 E.03249
G2 X127.45 Y133.496 I-1.615 J-.792 E.06683
G1 X127.128 Y133.141 E.0159
G1 X135.384 Y133.457 E.27407
G3 X136.621 Y133.105 I1.138 J1.646 E.04345
G3 X135.548 Y136.634 I-.111 J1.894 E.22754
G1 X135.379 Y136.526 E.00665
; WIPE_START
G1 F15476.087
G1 X135.262 Y136.45 E-.05279
G1 X133.403 Y136.379 E-.70721
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.951 Y134.729 Z1.8 F42000
G1 X124.738 Y134.461 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11607
M204 S5000
G1 X124.794 Y134.178 E.00886
G3 X125.952 Y133.246 I1.292 J.421 E.04832
G1 X126.079 Y133.24 E.0039
G3 X124.729 Y134.52 I.008 J1.359 E.19945
; WIPE_START
G1 F12000
M204 S6000
G1 X124.794 Y134.178 E-.13226
G1 X124.904 Y133.931 E-.10273
G1 X125.027 Y133.748 E-.08367
G1 X125.216 Y133.555 E-.10264
G1 X125.484 Y133.381 E-.12137
G1 X125.689 Y133.299 E-.08385
G1 X125.952 Y133.246 E-.10204
G1 X126.034 Y133.242 E-.03144
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.124 Y136.069 Z1.8 F42000
G1 X135.042 Y136.834 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F11607
M204 S5000
G1 X126.02 Y136.488 E.27742
G3 X126.114 Y132.71 I.074 J-1.888 E.18077
G1 X135.287 Y133.061 E.28209
G3 X136.647 Y132.713 I1.228 J1.969 E.04379
G3 X135.14 Y136.838 I-.14 J2.286 E.26175
G1 X135.102 Y136.837 E.00118
; WIPE_START
G1 F12000
M204 S6000
G1 X133.103 Y136.76 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.319 Y134.964 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52302
G1 F11607
M204 S6000
G1 X135.589 Y135.204 E.24544
; LINE_WIDTH: 0.505999
G1 X135.751 Y135.316 E.00743
; LINE_WIDTH: 0.471595
G1 X135.913 Y135.427 E.00688
; LINE_WIDTH: 0.423679
G1 X136.075 Y135.539 E.00611
G1 X136.445 Y135.683 E.0123
G2 X136.863 Y135.588 I-.071 J-1.279 E.01339
G1 X137.063 Y135.406 E.00837
G1 X137.183 Y135.145 E.0089
G1 X137.19 Y135.044 E.00314
G1 X137.122 Y134.686 E.01133
G1 X136.902 Y134.447 E.01005
G1 X136.672 Y134.343 E.00786
G2 X136.171 Y134.409 I-.155 J.749 E.01597
G1 X135.73 Y134.668 E.01587
; LINE_WIDTH: 0.475313
G1 X135.669 Y134.696 E.00238
; LINE_WIDTH: 0.522851
G1 X135.607 Y134.724 E.00264
G1 X129.094 Y134.475 E.25491
G1 X129.065 Y134.954 E.01877
G1 X129.259 Y134.962 E.00763
M204 S10000
G1 X136.008 Y134.985 F42000
; LINE_WIDTH: 0.52568
G1 F11607
M204 S6000
G1 X136.441 Y135.229 E.01954
G1 X136.531 Y135.249 E.00364
G1 X136.709 Y135.147 E.00805
G1 X136.761 Y135.015 E.00558
G1 X136.689 Y134.822 E.0081
G1 X136.531 Y134.751 E.00681
G2 X136.061 Y134.956 I.298 J1.323 E.0203
; WIPE_START
G1 F13049.963
G1 X136.322 Y134.816 E-.1232
G1 X136.531 Y134.751 E-.09073
G1 X136.689 Y134.822 E-.07188
G1 X136.761 Y135.015 E-.08549
G1 X136.709 Y135.147 E-.05892
G1 X136.531 Y135.249 E-.08502
G1 X136.441 Y135.229 E-.03846
G1 X136.008 Y134.985 E-.20629
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.548 Y133.371 Z1.8 F42000
G1 X126.465 Y132.92 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.209989
G1 F11607
M204 S6000
G1 X126.97 Y133.267 E.00834
M204 S10000
G1 X126.959 Y133.281 F42000
; LINE_WIDTH: 0.137764
G1 F11607
M204 S6000
G2 X126.496 Y132.921 I-8.111 J9.945 E.00453
M204 S10000
G1 X126.789 Y133.06 F42000
; LINE_WIDTH: 0.235201
G1 F11607
M204 S6000
G1 X126.507 Y133.009 E.00449
; LINE_WIDTH: 0.181774
G1 X126.24 Y132.981 E.00303
G2 X126.317 Y136.222 I-.14 J1.625 E.062
; LINE_WIDTH: 0.23528
G1 X126.671 Y136.186 E.00558
M204 S10000
G1 X126.855 Y135.981 F42000
; LINE_WIDTH: 0.114426
G1 F11607
M204 S6000
G1 X126.736 Y136.064 E.00085
; LINE_WIDTH: 0.146479
G1 X126.673 Y136.103 E.00062
; LINE_WIDTH: 0.187545
G3 X126.341 Y136.304 I-4.361 J-6.831 E.00458
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X126.673 Y136.103 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X122.364 Y129.803 Z1.8 F42000
G1 X119.11 Y125.046 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11607
M204 S6000
G1 X119.384 Y125.118 E.0094
G2 X120.476 Y125.104 I.503 J-3.351 E.03639
G1 X120.209 Y132.059 E.23089
G3 X120.51 Y132.639 I-2.672 J1.75 E.02172
G3 X118.553 Y132.456 I-1.021 J.361 E.14396
G1 X118.843 Y132.006 E.01775
G1 X119.108 Y125.106 E.22908
M204 S10000
G1 X118.726 Y124.438 F42000
G1 F11607
M204 S6000
G1 X119.054 Y124.591 E.01202
G2 X120.906 Y124.522 I.846 J-2.182 E.0632
G1 X120.62 Y131.963 E.24701
M73 P76 R2
G3 X120.978 Y133.047 I-1.67 J1.153 E.03837
G3 X118.203 Y132.247 I-1.489 J-.047 E.17994
G1 X118.44 Y131.879 E.01451
G1 X118.724 Y124.498 E.24502
; WIPE_START
G1 F15476.087
G1 X119.054 Y124.591 E-.13056
G1 X119.464 Y124.718 E-.16298
G1 X119.899 Y124.759 E-.16579
G1 X120.324 Y124.715 E-.16246
G1 X120.557 Y124.653 E-.09175
G1 X120.672 Y124.61 E-.04646
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.354 Y123.523 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
G1 F11607
M204 S6000
G1 X118.684 Y123.872 E.01595
G2 X120.992 Y123.961 I1.205 J-1.28 E.08358
G1 X121.348 Y123.638 E.01594
G1 X121.031 Y131.867 E.27319
G3 X120.493 Y134.611 I-1.601 J1.111 E.10344
G3 X117.853 Y132.038 I-1.003 J-1.612 E.16739
G1 X118.038 Y131.752 E.01128
G1 X118.352 Y123.583 E.2712
; WIPE_START
G1 F15476.087
G1 X118.684 Y123.872 E-.16752
G1 X118.911 Y124.054 E-.11045
G1 X119.212 Y124.216 E-.1298
G1 X119.544 Y124.318 E-.13222
G1 X119.895 Y124.352 E-.13389
G1 X120.121 Y124.328 E-.08612
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.829 Y121.747 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11607
M204 S5000
G1 X119.034 Y121.54 E.00895
G3 X119.726 Y121.248 I.853 J1.058 E.02339
G1 X119.867 Y121.239 E.00433
G3 X118.791 Y121.793 I.019 J1.359 E.22388
; WIPE_START
G1 F12000
M204 S6000
G1 X119.034 Y121.54 E-.13331
G1 X119.26 Y121.393 E-.10256
G1 X119.511 Y121.292 E-.10261
G1 X119.726 Y121.248 E-.08361
G1 X119.867 Y121.239 E-.05358
G1 X120.103 Y121.256 E-.08993
G1 X120.362 Y121.324 E-.10194
G1 X120.581 Y121.431 E-.09246
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.45 Y128.76 Z1.8 F42000
G1 X117.655 Y131.493 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F11607
M204 S5000
G1 X118 Y122.529 E.27564
G3 X119.971 Y120.711 I1.894 J.077 E.09151
G3 X121.777 Y122.676 I-.085 J1.891 E.091
G1 X121.427 Y131.775 E.27981
G3 X117.65 Y131.63 I-1.938 J1.223 E.30594
G1 X117.653 Y131.553 E.00238
; WIPE_START
G1 F12000
M204 S6000
G1 X117.73 Y129.554 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.534 Y125.576 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52409
G1 F11607
M204 S6000
G1 X119.283 Y132.098 E.25592
; LINE_WIDTH: 0.507507
G1 X119.162 Y132.274 E.00807
; LINE_WIDTH: 0.4725
G1 X119.042 Y132.449 E.00746
; LINE_WIDTH: 0.424322
G2 X118.802 Y132.984 I1.046 J.789 E.01837
G1 X118.85 Y133.251 E.00843
G1 X118.996 Y133.479 E.00842
G1 X119.22 Y133.633 E.00844
G1 X119.482 Y133.687 E.00831
G1 X119.749 Y133.636 E.00844
G1 X119.974 Y133.486 E.00842
G1 X120.125 Y133.259 E.00847
G1 X120.175 Y132.985 E.00866
G2 X120.084 Y132.67 I-.995 J.118 E.01025
G1 X119.817 Y132.201 E.01676
; LINE_WIDTH: 0.479215
G1 X119.79 Y132.148 E.00211
; LINE_WIDTH: 0.523051
G1 X119.764 Y132.095 E.00232
G1 X120.013 Y125.603 E.25421
G1 X119.594 Y125.579 E.01645
M204 S10000
G1 X119.508 Y132.494 F42000
; LINE_WIDTH: 0.527039
G1 F11607
M204 S6000
G1 X119.255 Y132.934 E.02004
G1 X119.259 Y133.091 E.00618
G1 X119.393 Y133.229 E.00758
G1 X119.582 Y133.229 E.00749
G1 X119.717 Y133.094 E.00753
G1 X119.731 Y132.946 E.00589
G1 X119.535 Y132.548 E.0175
; WIPE_START
G1 F13013.327
G1 X119.731 Y132.946 E-.18423
G1 X119.717 Y133.094 E-.06196
G1 X119.582 Y133.229 E-.07928
G1 X119.393 Y133.229 E-.07879
G1 X119.259 Y133.091 E-.07976
G1 X119.255 Y132.934 E-.06506
G1 X119.508 Y132.494 E-.21092
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X120.848 Y124.98 Z1.8 F42000
G1 X120.978 Y124.252 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.110824
G1 F11607
M204 S6000
G1 X121.123 Y124.174 E.00091
; WIPE_START
G1 F15000
G1 X120.978 Y124.252 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.569 Y122.975 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; LINE_WIDTH: 0.208511
G1 F11607
M204 S6000
G1 X121.22 Y123.481 E.00829
M204 S10000
G1 X121.207 Y123.47 F42000
; LINE_WIDTH: 0.127881
G1 F11607
M204 S6000
G2 X121.568 Y123.01 I-9.103 J-7.524 E.00405
M204 S10000
G1 X121.429 Y123.299 F42000
; LINE_WIDTH: 0.236022
G1 F11607
M204 S6000
G1 X121.479 Y123.018 E.0045
; LINE_WIDTH: 0.181469
G1 X121.512 Y122.562 E.00516
G2 X118.264 Y122.772 I-1.628 J.042 E.05919
; LINE_WIDTH: 0.216347
G1 X118.276 Y122.965 E.00274
; LINE_WIDTH: 0.243539
G1 X118.302 Y123.183 E.00358
M204 S10000
G1 X118.507 Y123.366 F42000
; LINE_WIDTH: 0.114102
G1 F11607
M204 S6000
G1 X118.425 Y123.248 E.00083
; LINE_WIDTH: 0.155965
G1 X118.356 Y123.139 E.0012
; LINE_WIDTH: 0.181841
G1 X118.184 Y122.855 E.00376
; WIPE_START
G1 F15000
G1 X118.356 Y123.139 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.536 Y124.075 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; LINE_WIDTH: 0.107529
G1 F11607
M204 S6000
G1 X118.675 Y124.163 E.00087
; CHANGE_LAYER
; Z_HEIGHT: 1.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X118.536 Y124.075 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 8/20
; update layer progress
M73 L8
M991 S0 P7 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z1.8 I.175 J1.204 P1  F42000
G1 X135.283 Y121.638 Z1.8
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11485
M204 S6000
G1 X128.559 Y121.38 E.22324
G2 X128.614 Y120.014 I-2.657 J-.791 E.04581
G1 X135.584 Y120.281 E.2314
G3 X136.331 Y119.933 I1.318 J1.854 E.02748
G1 X136.414 Y119.922 E.00277
G3 X136.568 Y119.919 I.124 J2.535 E.00511
G3 X135.96 Y121.933 I-.059 J1.081 E.12999
G1 X135.516 Y121.647 E.01749
G1 X135.343 Y121.64 E.00575
M204 S10000
G1 X135.527 Y122.138 F42000
G1 F11485
M204 S6000
G1 X135.389 Y122.049 E.00541
G1 X127.942 Y121.763 E.24724
G2 X128.013 Y119.584 I-1.882 J-1.152 E.07566
G1 X135.484 Y119.87 E.24803
G3 X136.594 Y119.513 I1.108 J1.541 E.03932
G3 X135.753 Y122.283 I-.086 J1.487 E.17872
G1 X135.577 Y122.17 E.00693
M204 S10000
G1 X135.17 Y122.448 F42000
G1 F11485
M204 S6000
G1 X127.031 Y122.136 E.27016
G2 X127.726 Y121.279 I-1.439 J-1.876 E.03692
G2 X127.471 Y119.498 I-1.631 J-.675 E.06262
G1 X127.149 Y119.143 E.01589
G1 X135.384 Y119.458 E.27337
G3 X136.621 Y119.106 I1.137 J1.646 E.04343
G3 X135.545 Y122.634 I-.113 J1.894 E.22744
G1 X135.263 Y122.452 E.01117
G1 X135.23 Y122.451 E.00109
; WIPE_START
G1 F15476.087
G1 X133.231 Y122.374 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.903 Y120.241 Z2 F42000
G1 X124.916 Y119.953 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11485
M204 S5000
G1 X125.048 Y119.749 E.00746
G3 X125.973 Y119.248 I1.06 J.851 E.03321
G1 X126.095 Y119.241 E.00375
G3 X124.885 Y120.005 I.013 J1.36 E.21621
; WIPE_START
G1 F12000
M204 S6000
G1 X125.048 Y119.749 E-.11499
G1 X125.276 Y119.526 E-.1215
G1 X125.472 Y119.4 E-.08844
G1 X125.71 Y119.301 E-.09794
G1 X125.973 Y119.248 E-.10199
G1 X126.095 Y119.241 E-.04642
G1 X126.351 Y119.263 E-.09785
G1 X126.581 Y119.328 E-.09087
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.624 Y122.27 Z2 F42000
G1 X134.97 Y122.833 Z2
G1 Z1.6
G1 E.8 F1800
G1 F11485
M204 S5000
G1 X126.039 Y122.49 E.27463
G3 X126.127 Y118.712 I.076 J-1.888 E.18045
G1 X135.288 Y119.062 E.2817
G3 X136.646 Y118.715 I1.227 J1.969 E.04378
G3 X135.14 Y122.839 I-.138 J2.287 E.26197
G1 X135.03 Y122.835 E.00338
; WIPE_START
G1 F12000
M204 S6000
G1 X133.032 Y122.758 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 8 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2 F4000
            G39.3 S1
            G0 Z2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer8 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X129.339 Y120.966 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.522995
G1 F11485
M204 S6000
G1 X135.589 Y121.206 E.24467
; LINE_WIDTH: 0.506007
G1 X135.75 Y121.316 E.00737
; LINE_WIDTH: 0.4716
G1 X135.911 Y121.427 E.00682
; LINE_WIDTH: 0.423666
G1 X136.071 Y121.538 E.00606
G1 X136.455 Y121.685 E.01275
G1 X136.809 Y121.619 E.01116
G1 X137.027 Y121.452 E.00853
G1 X137.163 Y121.214 E.00851
G1 X137.195 Y120.953 E.00815
G1 X137.123 Y120.689 E.0085
G1 X136.904 Y120.45 E.01005
G1 X136.672 Y120.344 E.00793
G2 X136.172 Y120.411 I-.155 J.746 E.01595
G1 X135.73 Y120.67 E.01588
; LINE_WIDTH: 0.475323
G1 X135.669 Y120.698 E.00238
; LINE_WIDTH: 0.522821
G1 X135.608 Y120.726 E.00264
G1 X129.113 Y120.477 E.25417
G1 X129.077 Y120.956 E.01878
G1 X129.279 Y120.963 E.00791
M204 S10000
G1 X136.008 Y120.986 F42000
; LINE_WIDTH: 0.52503
G1 F11485
M204 S6000
G1 X136.444 Y121.23 E.01963
G1 X136.579 Y121.241 E.00534
G1 X136.724 Y121.116 E.00752
G1 X136.753 Y121.03 E.00355
G1 X136.709 Y120.85 E.00727
G1 X136.572 Y120.762 E.00638
G1 X136.375 Y120.789 E.00784
G1 X136.061 Y120.958 E.014
; WIPE_START
G1 F13067.557
G1 X136.375 Y120.789 E-.14875
M73 P77 R2
G1 X136.572 Y120.762 E-.08333
G1 X136.709 Y120.85 E-.06779
G1 X136.753 Y121.03 E-.07722
G1 X136.724 Y121.116 E-.03776
G1 X136.579 Y121.241 E-.0799
G1 X136.444 Y121.23 E-.05672
G1 X136.008 Y120.986 E-.20853
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.549 Y119.368 Z2 F42000
G1 X126.489 Y118.922 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.208152
G1 F11485
M204 S6000
G1 X126.99 Y119.27 E.00822
M204 S10000
G1 X126.98 Y119.282 F42000
; LINE_WIDTH: 0.121621
G1 F11485
M204 S6000
G1 X126.836 Y119.167 E.00119
; LINE_WIDTH: 0.147246
G1 X126.516 Y118.923 E.00342
M204 S10000
G1 X126.811 Y119.063 F42000
; LINE_WIDTH: 0.241397
G1 F11485
M204 S6000
G1 X126.583 Y119.02 E.00376
; LINE_WIDTH: 0.203071
G1 X126.268 Y118.983 E.00414
; LINE_WIDTH: 0.18062
G1 X126.261 Y118.982 E.00007
G2 X126.282 Y122.225 I-.147 J1.622 E.06096
; LINE_WIDTH: 0.215754
G1 X126.47 Y122.214 E.00265
; LINE_WIDTH: 0.242075
G1 X126.687 Y122.19 E.00355
M204 S10000
G1 X126.39 Y122.307 F42000
; LINE_WIDTH: 0.125064
G1 F11485
M204 S6000
G2 X126.877 Y121.98 I-4.93 J-7.858 E.00393
M204 S10000
G1 X126.887 Y121.994 F42000
; LINE_WIDTH: 0.204095
G1 F11485
M204 S6000
G1 X126.356 Y122.305 E.00809
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X126.887 Y121.994 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X132.875 Y126.726 Z2 F42000
G1 X135.293 Y128.638 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11485
M204 S6000
G1 X128.538 Y128.379 E.22425
G2 X128.595 Y127.013 I-2.661 J-.795 E.04581
G1 X135.584 Y127.28 E.23203
G3 X136.331 Y126.932 I1.319 J1.855 E.02748
G1 X136.414 Y126.921 E.00277
G3 X136.568 Y126.918 I.123 J2.474 E.00511
G3 X135.961 Y128.933 I-.059 J1.081 E.12992
G1 X135.516 Y128.646 E.01756
G1 X135.353 Y128.64 E.00542
M204 S10000
G1 X135.236 Y129.043 F42000
G1 F11485
M204 S6000
G1 X127.927 Y128.763 E.24262
G2 X127.992 Y126.583 I-1.948 J-1.148 E.07549
G1 X135.484 Y126.869 E.24872
G3 X136.594 Y126.512 I1.108 J1.541 E.03932
G3 X135.754 Y129.284 I-.086 J1.487 E.17862
G1 X135.389 Y129.049 E.01441
G1 X135.296 Y129.045 E.00309
M204 S10000
G1 X135.179 Y129.448 F42000
G1 F11485
M204 S6000
G1 X127.011 Y129.135 E.27118
G2 X127.707 Y128.272 I-1.433 J-1.869 E.03712
G2 X127.45 Y126.497 I-1.638 J-.669 E.06239
G1 X127.128 Y126.142 E.01589
G1 X135.384 Y126.458 E.27407
G3 X136.621 Y126.105 I1.137 J1.646 E.04343
G3 X135.548 Y129.635 I-.113 J1.893 E.22731
G1 X135.263 Y129.451 E.01125
G1 X135.239 Y129.45 E.00077
; WIPE_START
G1 F15476.087
G1 X133.241 Y129.374 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.795 Y127.694 Z2 F42000
G1 X124.735 Y127.455 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11485
M204 S5000
G3 X125.952 Y126.247 I1.352 J.145 E.057
G1 X126.074 Y126.24 E.00375
G3 X124.73 Y127.515 I.013 J1.36 E.19989
; WIPE_START
G1 F12000
M204 S6000
G1 X124.784 Y127.214 E-.11587
G1 X124.903 Y126.932 E-.11664
G1 X125.059 Y126.711 E-.10275
G1 X125.226 Y126.549 E-.0884
G1 X125.451 Y126.399 E-.10259
G1 X125.688 Y126.3 E-.09787
G1 X125.952 Y126.247 E-.10203
G1 X126.041 Y126.242 E-.03386
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.125 Y129.082 Z2 F42000
G1 X135 Y129.833 Z2
G1 Z1.6
G1 E.8 F1800
G1 F11485
M204 S5000
G1 X126.02 Y129.489 E.27612
G3 X126.106 Y125.711 I.071 J-1.888 E.18069
G1 X135.287 Y126.062 E.28234
G3 X136.646 Y125.714 I1.228 J1.969 E.04378
G3 X135.14 Y129.839 I-.138 J2.287 E.262
G1 X135.06 Y129.836 E.00247
; WIPE_START
G1 F12000
M204 S6000
G1 X133.061 Y129.759 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.318 Y127.965 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52299
G1 F11485
M204 S6000
G1 X135.589 Y128.205 E.24549
; LINE_WIDTH: 0.505999
G1 X135.75 Y128.316 E.00738
; LINE_WIDTH: 0.471595
G1 X135.911 Y128.427 E.00683
; LINE_WIDTH: 0.423664
G1 X136.072 Y128.538 E.00607
G1 X136.455 Y128.684 E.01272
G1 X136.812 Y128.617 E.01128
G1 X137.029 Y128.448 E.00853
G1 X137.162 Y128.215 E.00835
G1 X137.195 Y127.943 E.00848
G1 X137.123 Y127.689 E.0082
G1 X136.903 Y127.448 E.01012
G1 X136.675 Y127.344 E.00778
G2 X136.171 Y127.41 I-.158 J.747 E.01606
G1 X135.73 Y127.669 E.01587
; LINE_WIDTH: 0.475298
G1 X135.669 Y127.697 E.00238
; LINE_WIDTH: 0.522817
G1 X135.607 Y127.725 E.00264
G1 X129.079 Y127.475 E.25548
G1 X129.075 Y127.955 E.01877
G1 X129.258 Y127.962 E.00715
M204 S10000
G1 X136.008 Y127.985 F42000
; LINE_WIDTH: 0.5251
G1 F11485
M204 S6000
G1 X136.443 Y128.229 E.01958
G1 X136.58 Y128.24 E.0054
G1 X136.722 Y128.12 E.00732
G1 X136.752 Y128.025 E.00392
G1 X136.709 Y127.85 E.00705
G1 X136.574 Y127.762 E.00636
G1 X136.374 Y127.789 E.0079
G1 X136.061 Y127.957 E.01399
; WIPE_START
G1 F13065.66
G1 X136.374 Y127.789 E-.14869
G1 X136.574 Y127.762 E-.08396
G1 X136.709 Y127.85 E-.06759
G1 X136.752 Y128.025 E-.07491
G1 X136.722 Y128.12 E-.0416
G1 X136.58 Y128.24 E-.07774
G1 X136.443 Y128.229 E-.05741
G1 X136.008 Y127.985 E-.20809
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.413 Y128.739 Z2 F42000
G1 X127.652 Y128.814 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.111118
G1 F11485
M204 S6000
G1 X127.563 Y128.952 E.00091
; WIPE_START
G1 F15000
G1 X127.652 Y128.814 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.338 Y129.305 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.183
G1 F11485
M204 S6000
G2 X126.677 Y129.1 I-3.987 J-6.99 E.00452
; LINE_WIDTH: 0.14274
G1 X126.739 Y129.061 E.0006
; LINE_WIDTH: 0.112667
G1 X126.856 Y128.979 E.00081
M204 S10000
G1 X126.668 Y129.187 F42000
; LINE_WIDTH: 0.242956
G1 F11485
M204 S6000
G1 X126.454 Y129.213 E.00352
; LINE_WIDTH: 0.216675
G1 X126.261 Y129.225 E.00273
; LINE_WIDTH: 0.180646
G3 X126.24 Y125.982 I-.168 J-1.621 E.06097
G1 X126.247 Y125.982 E.00007
; LINE_WIDTH: 0.203097
G1 X126.562 Y126.019 E.00414
; LINE_WIDTH: 0.24144
G1 X126.79 Y126.062 E.00376
M204 S10000
G1 X126.495 Y125.922 F42000
; LINE_WIDTH: 0.147342
G1 F11485
M204 S6000
G1 X126.815 Y126.166 E.00342
; LINE_WIDTH: 0.121667
G1 X126.959 Y126.282 E.00119
M204 S10000
G1 X126.969 Y126.269 F42000
; LINE_WIDTH: 0.208219
G1 F11485
M204 S6000
G1 X126.467 Y125.921 E.00822
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X126.969 Y126.269 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X132.039 Y131.974 Z2 F42000
G1 X135.293 Y135.637 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11485
M204 S6000
G1 X128.538 Y135.378 E.22425
G2 X128.595 Y134.012 I-2.661 J-.795 E.04581
G1 X135.584 Y134.279 E.23203
G3 X136.331 Y133.931 I1.319 J1.855 E.02748
G1 X136.414 Y133.92 E.00277
G3 X136.568 Y133.917 I.123 J2.474 E.00511
G3 X135.961 Y135.932 I-.059 J1.081 E.12992
G1 X135.516 Y135.645 E.01756
G1 X135.353 Y135.639 E.00542
M204 S10000
G1 X135.236 Y136.042 F42000
G1 F11485
M204 S6000
G1 X127.927 Y135.762 E.24262
G2 X127.992 Y133.582 I-1.948 J-1.148 E.07549
G1 X135.484 Y133.868 E.24872
G3 X136.594 Y133.511 I1.108 J1.541 E.03932
G3 X135.754 Y136.283 I-.086 J1.487 E.17862
G1 X135.389 Y136.048 E.01441
G1 X135.296 Y136.044 E.00309
M204 S10000
G1 X135.179 Y136.447 F42000
G1 F11485
M204 S6000
G1 X127.011 Y136.134 E.27118
G2 X127.707 Y135.271 I-1.433 J-1.869 E.03712
G2 X127.45 Y133.496 I-1.638 J-.669 E.06239
G1 X127.128 Y133.142 E.01589
G1 X135.384 Y133.457 E.27407
G3 X136.621 Y133.105 I1.137 J1.646 E.04343
G3 X135.548 Y136.634 I-.113 J1.893 E.22731
G1 X135.263 Y136.45 E.01125
G1 X135.239 Y136.449 E.00077
; WIPE_START
G1 F15476.087
G1 X133.241 Y136.373 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.795 Y134.693 Z2 F42000
G1 X124.735 Y134.454 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11485
M204 S5000
G3 X125.952 Y133.246 I1.352 J.145 E.057
G1 X126.074 Y133.24 E.00375
G3 X124.73 Y134.514 I.013 J1.36 E.19989
; WIPE_START
G1 F12000
M204 S6000
G1 X124.784 Y134.214 E-.11587
G1 X124.903 Y133.931 E-.11664
G1 X125.059 Y133.71 E-.10275
G1 X125.226 Y133.548 E-.0884
G1 X125.451 Y133.398 E-.10259
G1 X125.688 Y133.299 E-.09787
G1 X125.952 Y133.246 E-.10203
G1 X126.041 Y133.241 E-.03386
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.125 Y136.081 Z2 F42000
G1 X135 Y136.833 Z2
G1 Z1.6
G1 E.8 F1800
G1 F11485
M204 S5000
G1 X126.02 Y136.488 E.27612
G3 X126.106 Y132.71 I.071 J-1.888 E.18069
G1 X135.287 Y133.061 E.28234
G3 X136.646 Y132.713 I1.228 J1.969 E.04378
G3 X135.14 Y136.838 I-.138 J2.287 E.262
G1 X135.06 Y136.835 E.00247
; WIPE_START
G1 F12000
M204 S6000
G1 X133.061 Y136.758 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.318 Y134.964 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52299
G1 F11485
M204 S6000
G1 X135.589 Y135.204 E.24549
; LINE_WIDTH: 0.505999
G1 X135.75 Y135.315 E.00738
; LINE_WIDTH: 0.471595
G1 X135.911 Y135.426 E.00683
; LINE_WIDTH: 0.423664
G1 X136.072 Y135.537 E.00607
G1 X136.455 Y135.684 E.01272
G1 X136.812 Y135.617 E.01128
G1 X137.029 Y135.448 E.00853
G1 X137.162 Y135.214 E.00835
G1 X137.195 Y134.942 E.00848
G1 X137.123 Y134.688 E.0082
G1 X136.903 Y134.448 E.01012
G1 X136.675 Y134.343 E.00778
G2 X136.171 Y134.409 I-.158 J.747 E.01606
G1 X135.73 Y134.668 E.01587
; LINE_WIDTH: 0.475298
G1 X135.669 Y134.696 E.00238
; LINE_WIDTH: 0.522817
G1 X135.607 Y134.724 E.00264
G1 X129.079 Y134.475 E.25548
G1 X129.075 Y134.955 E.01877
G1 X129.258 Y134.962 E.00715
M204 S10000
G1 X136.008 Y134.985 F42000
; LINE_WIDTH: 0.5251
G1 F11485
M204 S6000
G1 X136.443 Y135.228 E.01958
G1 X136.58 Y135.239 E.0054
G1 X136.722 Y135.119 E.00732
G1 X136.752 Y135.024 E.00392
G1 X136.709 Y134.85 E.00705
G1 X136.574 Y134.761 E.00636
G1 X136.374 Y134.788 E.0079
G1 X136.061 Y134.956 E.01399
; WIPE_START
G1 F13065.66
M73 P78 R2
G1 X136.374 Y134.788 E-.14869
G1 X136.574 Y134.761 E-.08396
G1 X136.709 Y134.85 E-.06759
G1 X136.752 Y135.024 E-.07491
G1 X136.722 Y135.119 E-.0416
G1 X136.58 Y135.239 E-.07774
G1 X136.443 Y135.228 E-.05741
G1 X136.008 Y134.985 E-.20809
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.413 Y135.738 Z2 F42000
G1 X127.652 Y135.813 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.111118
G1 F11485
M204 S6000
G1 X127.563 Y135.951 E.00091
; WIPE_START
G1 F15000
G1 X127.652 Y135.813 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.338 Y136.304 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.183
G1 F11485
M204 S6000
G2 X126.677 Y136.1 I-3.987 J-6.99 E.00452
; LINE_WIDTH: 0.14274
G1 X126.739 Y136.06 E.0006
; LINE_WIDTH: 0.112667
G1 X126.856 Y135.978 E.00081
M204 S10000
G1 X126.668 Y136.186 F42000
; LINE_WIDTH: 0.242956
G1 F11485
M204 S6000
G1 X126.454 Y136.212 E.00352
; LINE_WIDTH: 0.216675
G1 X126.261 Y136.224 E.00273
; LINE_WIDTH: 0.180646
G3 X126.24 Y132.981 I-.168 J-1.621 E.06097
G1 X126.247 Y132.981 E.00007
; LINE_WIDTH: 0.203097
G1 X126.562 Y133.018 E.00414
; LINE_WIDTH: 0.24144
G1 X126.79 Y133.061 E.00376
M204 S10000
G1 X126.495 Y132.921 F42000
; LINE_WIDTH: 0.147342
G1 F11485
M204 S6000
G1 X126.815 Y133.165 E.00342
; LINE_WIDTH: 0.121667
G1 X126.959 Y133.281 E.00119
M204 S10000
G1 X126.969 Y133.268 F42000
; LINE_WIDTH: 0.208219
G1 F11485
M204 S6000
G1 X126.467 Y132.92 E.00822
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X126.969 Y133.268 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X121.694 Y127.752 Z2 F42000
G1 X119.11 Y125.048 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11485
M204 S6000
G1 X119.384 Y125.117 E.00938
G2 X120.476 Y125.105 I.511 J-3.392 E.03638
G1 X120.209 Y132.059 E.23083
G3 X120.509 Y132.639 I-2.563 J1.694 E.0217
G3 X118.553 Y132.455 I-1.021 J.361 E.14396
G1 X118.843 Y132.006 E.01771
G1 X119.108 Y125.108 E.22899
M204 S10000
G1 X118.726 Y124.432 F42000
G1 F11485
M204 S6000
G1 X119.053 Y124.592 E.01206
G2 X120.907 Y124.502 I.833 J-2.009 E.06362
G1 X120.62 Y131.963 E.24767
G3 X120.978 Y133.051 I-1.669 J1.152 E.0385
G3 X118.204 Y132.246 I-1.489 J-.05 E.17989
G1 X118.44 Y131.879 E.01449
G1 X118.724 Y124.492 E.24525
; WIPE_START
G1 F15476.087
G1 X119.053 Y124.592 E-.13056
G1 X119.464 Y124.717 E-.16355
G1 X119.661 Y124.747 E-.07546
G1 X120.073 Y124.751 E-.15671
G1 X120.495 Y124.672 E-.163
G1 X120.67 Y124.61 E-.07072
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.354 Y123.521 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F11485
M204 S6000
G1 X118.674 Y123.862 E.0155
G2 X120.992 Y123.961 I1.215 J-1.273 E.08404
G1 X121.348 Y123.638 E.01594
G1 X121.031 Y131.867 E.27319
G3 X120.493 Y134.611 I-1.601 J1.111 E.10344
G3 X117.854 Y132.038 I-1.001 J-1.614 E.16728
G1 X118.038 Y131.752 E.01126
G1 X118.352 Y123.581 E.27125
; WIPE_START
G1 F15476.087
G1 X118.674 Y123.862 E-.16235
G1 X118.906 Y124.05 E-.11361
G1 X119.211 Y124.216 E-.13179
G1 X119.544 Y124.318 E-.13257
G1 X119.886 Y124.352 E-.13038
G1 X120.12 Y124.329 E-.0893
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.836 Y121.742 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11485
M204 S5000
G1 X118.996 Y121.572 E.00718
G3 X119.726 Y121.248 I.891 J1.027 E.02492
G1 X119.872 Y121.239 E.00448
G3 X118.796 Y121.787 I.015 J1.36 E.22405
; WIPE_START
G1 F12000
M204 S6000
G1 X118.996 Y121.572 E-.11154
G1 X119.26 Y121.393 E-.12133
G1 X119.511 Y121.292 E-.10266
G1 X119.726 Y121.248 E-.08363
G1 X119.872 Y121.239 E-.05541
G1 X120.102 Y121.256 E-.0877
G1 X120.361 Y121.323 E-.10177
G1 X120.588 Y121.434 E-.09596
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.442 Y128.759 Z2 F42000
G1 X117.658 Y131.436 Z2
G1 Z1.6
G1 E.8 F1800
G1 F11485
M204 S5000
G1 X118 Y122.529 E.27388
G3 X119.979 Y120.711 I1.902 J.085 E.09165
G3 X121.777 Y122.676 I-.094 J1.891 E.09075
G1 X121.427 Y131.775 E.27981
G3 X117.65 Y131.63 I-1.938 J1.222 E.30583
G1 X117.655 Y131.496 E.00413
; WIPE_START
G1 F12000
M204 S6000
G1 X117.732 Y129.497 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.524 Y125.832 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.52318
G1 F11485
M204 S6000
G1 X119.284 Y132.077 E.24458
; LINE_WIDTH: 0.505974
G1 X119.168 Y132.251 E.0079
; LINE_WIDTH: 0.47158
G1 X119.052 Y132.426 E.00732
; LINE_WIDTH: 0.423864
G2 X118.802 Y132.984 I1.237 J.888 E.0191
G1 X118.849 Y133.251 E.00842
G1 X118.998 Y133.482 E.00853
G1 X119.185 Y133.617 E.00716
G1 X119.486 Y133.687 E.00958
G1 X119.749 Y133.636 E.00832
G1 X119.975 Y133.486 E.00841
G1 X120.125 Y133.259 E.00846
G1 X120.175 Y132.988 E.00855
G1 X120.073 Y132.637 E.01134
G1 X119.819 Y132.205 E.01556
; LINE_WIDTH: 0.47739
G1 X119.791 Y132.15 E.00217
; LINE_WIDTH: 0.523052
G1 X119.764 Y132.095 E.0024
G1 X120.013 Y125.601 E.25428
G1 X119.534 Y125.576 E.01879
G1 X119.526 Y125.772 E.00769
M204 S10000
G1 X119.509 Y132.493 F42000
; LINE_WIDTH: 0.52675
G1 F11485
M204 S6000
G1 X119.253 Y132.943 E.02042
G1 X119.258 Y133.091 E.00581
G1 X119.367 Y133.217 E.00657
G1 X119.583 Y133.23 E.00851
G1 X119.718 Y133.094 E.00754
G1 X119.727 Y133.042 E.00209
G1 X119.693 Y132.839 E.0081
G1 X119.537 Y132.546 E.01311
; WIPE_START
G1 F13021.103
G1 X119.693 Y132.839 E-.13807
G1 X119.727 Y133.042 E-.08535
G1 X119.718 Y133.094 E-.02203
G1 X119.583 Y133.23 E-.07942
G1 X119.367 Y133.217 E-.08966
G1 X119.258 Y133.091 E-.06919
G1 X119.253 Y132.943 E-.06119
G1 X119.509 Y132.493 E-.21509
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.124 Y125.034 Z2 F42000
G1 X121.569 Y122.977 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.208196
G1 F11485
M204 S6000
G1 X121.22 Y123.48 E.00825
M204 S10000
G1 X121.207 Y123.47 F42000
; LINE_WIDTH: 0.121637
G1 F11485
M204 S6000
G1 X121.323 Y123.326 E.00119
; LINE_WIDTH: 0.147277
G1 X121.568 Y123.004 E.00344
M204 S10000
G1 X121.427 Y123.301 F42000
; LINE_WIDTH: 0.242386
G1 F11485
M204 S6000
G1 X121.47 Y123.073 E.00377
; LINE_WIDTH: 0.213914
G1 X121.496 Y122.883 E.00267
; LINE_WIDTH: 0.18092
G1 X121.504 Y122.427 E.00512
G2 X118.264 Y122.772 I-1.619 J.177 E.05743
; LINE_WIDTH: 0.215965
G1 X118.276 Y122.961 E.00268
; LINE_WIDTH: 0.242407
G1 X118.3 Y123.177 E.00353
M204 S10000
G1 X118.51 Y123.367 F42000
; LINE_WIDTH: 0.113011
G1 F11485
M204 S6000
G1 X118.426 Y123.248 E.00083
; LINE_WIDTH: 0.146303
G1 X118.381 Y123.175 E.00072
; LINE_WIDTH: 0.193852
G3 X118.184 Y122.847 I6.688 J-4.226 E.0047
; CHANGE_LAYER
; Z_HEIGHT: 1.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X118.381 Y123.175 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 9/20
; update layer progress
M73 L9
M991 S0 P8 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z2 I.098 J1.213 P1  F42000
G1 X135.721 Y121.779 Z2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11748
M204 S6000
G1 X135.517 Y121.647 E.00806
G1 X128.556 Y121.379 E.23108
G2 X128.616 Y120.014 I-2.613 J-.799 E.04582
G1 X135.583 Y120.281 E.2313
G3 X136.335 Y119.932 I1.322 J1.866 E.02763
G1 X136.413 Y119.922 E.00262
G3 X136.567 Y119.919 I.126 J2.499 E.00511
G3 X135.959 Y121.933 I-.057 J1.081 E.13014
G1 X135.771 Y121.811 E.00743
M204 S10000
G1 X135.535 Y122.143 F42000
G1 F11748
M204 S6000
G1 X135.39 Y122.049 E.00573
G1 X127.947 Y121.763 E.24707
G2 X128.012 Y119.584 I-1.94 J-1.149 E.0755
G1 X135.483 Y119.87 E.24801
G3 X136.594 Y119.512 I1.109 J1.544 E.03932
G3 X135.752 Y122.283 I-.084 J1.488 E.17889
G1 X135.585 Y122.176 E.00659
M204 S10000
G1 X135.16 Y122.448 F42000
G1 F11748
M204 S6000
G1 X127.032 Y122.136 E.26982
G2 X127.725 Y121.279 I-1.433 J-1.868 E.0369
G2 X127.471 Y119.498 I-1.635 J-.675 E.0626
G1 X127.149 Y119.143 E.01589
G1 X135.384 Y119.458 E.27335
G3 X136.62 Y119.106 I1.138 J1.648 E.04343
G3 X135.545 Y122.634 I-.111 J1.894 E.22764
G1 X135.263 Y122.452 E.01115
G1 X135.22 Y122.45 E.00141
; WIPE_START
G1 F15476.087
G1 X133.222 Y122.373 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.895 Y120.233 Z2.2 F42000
G1 X124.918 Y119.947 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11748
M204 S5000
G1 X124.924 Y119.932 E.00051
G3 X125.972 Y119.248 I1.184 J.669 E.03997
G1 X126.09 Y119.241 E.00361
G3 X124.816 Y120.179 I.019 J1.359 E.2106
G1 X124.894 Y120.002 E.00595
; WIPE_START
G1 F12000
M204 S6000
G1 X124.924 Y119.932 E-.02907
G1 X125.053 Y119.744 E-.08657
G1 X125.276 Y119.526 E-.11862
G1 X125.467 Y119.402 E-.08654
G1 X125.709 Y119.301 E-.09972
G1 X125.972 Y119.248 E-.102
G1 X126.09 Y119.241 E-.04461
G1 X126.35 Y119.262 E-.09911
G1 X126.587 Y119.33 E-.09376
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.623 Y122.288 Z2.2 F42000
G1 X134.914 Y122.831 Z2.2
G1 Z1.8
G1 E.8 F1800
G1 F11748
M204 S5000
G1 X126.039 Y122.49 E.27289
G3 X126.119 Y118.712 I.076 J-1.888 E.18021
G1 X135.287 Y119.062 E.28194
G3 X136.646 Y118.715 I1.228 J1.971 E.04377
G3 X135.14 Y122.839 I-.14 J2.286 E.26176
G1 X134.974 Y122.833 E.00513
; WIPE_START
G1 F12000
M204 S6000
G1 X132.975 Y122.756 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 9 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.2
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.2 F4000
            G39.3 S1
            G0 Z2.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer9 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X129.339 Y120.966 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.523035
G1 F11748
M204 S6000
G1 X135.596 Y121.206 E.24499
; LINE_WIDTH: 0.506099
G1 X135.755 Y121.317 E.00729
; LINE_WIDTH: 0.471655
G1 X135.913 Y121.427 E.00675
; LINE_WIDTH: 0.423708
G1 X136.071 Y121.538 E.00599
G1 X136.454 Y121.685 E.01273
G1 X136.741 Y121.632 E.00906
G1 X136.947 Y121.521 E.00725
G2 X137.163 Y121.214 I-.945 J-.893 E.0117
G2 X136.885 Y120.437 I-.69 J-.191 E.02728
G1 X136.67 Y120.344 E.00728
G2 X136.172 Y120.41 I-.154 J.748 E.0159
G1 X135.729 Y120.67 E.01592
; LINE_WIDTH: 0.475625
G1 X135.668 Y120.698 E.00235
; LINE_WIDTH: 0.522811
G1 X135.608 Y120.726 E.00261
G1 X129.1 Y120.476 E.25469
G1 X129.096 Y120.956 E.01877
G1 X129.279 Y120.963 E.00715
M204 S10000
G1 X136.007 Y120.986 F42000
; LINE_WIDTH: 0.52491
G1 F11748
M204 S6000
G1 X136.445 Y121.23 E.0197
G1 X136.528 Y121.253 E.00335
G1 X136.702 Y121.155 E.00786
G1 X136.756 Y121.007 E.00618
G1 X136.701 Y120.849 E.0066
G1 X136.571 Y120.762 E.00612
G1 X136.374 Y120.789 E.00781
G1 X136.06 Y120.957 E.014
; WIPE_START
G1 F13070.811
G1 X136.374 Y120.789 E-.14853
G1 X136.571 Y120.762 E-.08292
G1 X136.701 Y120.849 E-.06495
G1 X136.756 Y121.007 E-.07
M73 P79 R2
G1 X136.702 Y121.155 E-.06556
G1 X136.528 Y121.253 E-.0834
G1 X136.445 Y121.23 E-.0356
G1 X136.007 Y120.986 E-.20906
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.413 Y121.747 Z2.2 F42000
G1 X127.669 Y121.822 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.108604
G1 F11748
M204 S6000
G1 X127.583 Y121.953 E.00084
; WIPE_START
G1 F15000
G1 X127.669 Y121.822 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.357 Y122.305 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; LINE_WIDTH: 0.205395
G1 F11748
M204 S6000
G1 X126.889 Y121.993 E.00816
M204 S10000
G1 X126.879 Y121.979 F42000
; LINE_WIDTH: 0.125588
G1 F11748
M204 S6000
G3 X126.393 Y122.307 I-5.753 J-7.991 E.00395
M204 S10000
G1 X126.688 Y122.19 F42000
; LINE_WIDTH: 0.242299
G1 F11748
M204 S6000
G1 X126.469 Y122.214 E.00358
; LINE_WIDTH: 0.215746
G1 X126.282 Y122.225 E.00264
; LINE_WIDTH: 0.181606
G3 X126.26 Y118.982 I-.168 J-1.62 E.06141
G1 X126.536 Y119.012 E.00313
; LINE_WIDTH: 0.235914
G1 X126.81 Y119.062 E.00438
M204 S10000
G1 X126.522 Y118.923 F42000
; LINE_WIDTH: 0.127983
G1 F11748
M204 S6000
G3 X126.98 Y119.283 I-7.041 J9.433 E.00404
M204 S10000
G1 X126.991 Y119.27 F42000
; LINE_WIDTH: 0.208491
G1 F11748
M204 S6000
G1 X126.489 Y118.922 E.00824
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X126.991 Y119.27 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X132.052 Y124.983 Z2.2 F42000
G1 X135.288 Y128.637 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11748
M204 S6000
G1 X128.535 Y128.378 E.2242
G2 X128.595 Y127.013 I-2.613 J-.799 E.04582
G1 X135.585 Y127.28 E.23204
G3 X136.335 Y126.931 I1.312 J1.841 E.02759
G1 X136.413 Y126.921 E.00262
G3 X136.567 Y126.918 I.125 J2.493 E.00511
G3 X135.961 Y128.933 I-.057 J1.081 E.12999
G1 X135.516 Y128.646 E.01757
G1 X135.348 Y128.64 E.00557
M204 S10000
G1 X135.232 Y129.043 F42000
G1 F11748
M204 S6000
G1 X127.921 Y128.762 E.2427
G2 X128.011 Y126.584 I-1.946 J-1.172 E.07545
G1 X135.484 Y126.869 E.24808
G3 X136.594 Y126.512 I1.106 J1.535 E.03929
G3 X135.755 Y129.284 I-.084 J1.488 E.17873
G1 X135.389 Y129.049 E.01441
G1 X135.292 Y129.045 E.00324
M204 S10000
G1 X135.175 Y129.448 F42000
G1 F11748
M204 S6000
G1 X127.011 Y129.135 E.271
G2 X127.703 Y128.282 I-1.438 J-1.873 E.03675
G2 X127.45 Y126.497 I-1.634 J-.679 E.06275
G1 X127.128 Y126.142 E.01589
G1 X135.384 Y126.458 E.27407
G3 X136.62 Y126.105 I1.137 J1.644 E.0434
G3 X135.548 Y129.635 I-.111 J1.894 E.22747
G1 X135.263 Y129.451 E.01126
G1 X135.235 Y129.45 E.00092
; WIPE_START
G1 F15476.087
G1 X133.236 Y129.373 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.792 Y127.691 Z2.2 F42000
G1 X124.736 Y127.453 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11748
M204 S5000
G1 X124.736 Y127.45 E.00008
G3 X125.951 Y126.247 I1.351 J.15 E.05682
G1 X126.069 Y126.24 E.00361
G3 X124.732 Y127.712 I.019 J1.359 E.19399
G1 X124.735 Y127.513 E.00614
; WIPE_START
G1 F12000
M204 S6000
G1 X124.736 Y127.45 E-.02378
G1 X124.782 Y127.219 E-.0894
G1 X124.903 Y126.932 E-.1186
G1 X125.059 Y126.711 E-.10261
G1 X125.222 Y126.552 E-.08657
G1 X125.446 Y126.401 E-.10261
G1 X125.689 Y126.3 E-.09988
G1 X125.951 Y126.247 E-.10182
G1 X126.043 Y126.242 E-.03473
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.122 Y129.093 Z2.2 F42000
G1 X134.956 Y129.832 Z2.2
G1 Z1.8
G1 E.8 F1800
G1 F11748
M204 S5000
G1 X126.021 Y129.489 E.27475
G3 X126.097 Y125.711 I.068 J-1.889 E.18063
G1 X135.288 Y126.062 E.2826
G3 X136.646 Y125.714 I1.227 J1.968 E.04376
G3 X135.14 Y129.839 I-.142 J2.285 E.26153
G1 X135.015 Y129.834 E.00384
; WIPE_START
G1 F12000
M204 S6000
G1 X133.017 Y129.757 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.318 Y127.965 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.522965
G1 F11748
M204 S6000
G1 X135.589 Y128.205 E.24548
; LINE_WIDTH: 0.506007
G1 X135.75 Y128.316 E.00738
; LINE_WIDTH: 0.4716
G1 X135.911 Y128.427 E.00683
; LINE_WIDTH: 0.423648
G1 X136.072 Y128.538 E.00607
G1 X136.455 Y128.684 E.01272
G1 X136.812 Y128.617 E.01129
G1 X137.029 Y128.449 E.00853
G1 X137.162 Y128.215 E.00835
G1 X137.194 Y127.943 E.0085
G1 X137.124 Y127.689 E.00817
G1 X136.9 Y127.446 E.01025
G1 X136.672 Y127.343 E.00776
G2 X136.171 Y127.41 I-.156 J.744 E.01596
G1 X135.731 Y127.669 E.01585
; LINE_WIDTH: 0.475158
G1 X135.669 Y127.697 E.00239
; LINE_WIDTH: 0.522787
G1 X135.607 Y127.725 E.00265
G1 X129.079 Y127.475 E.25547
G1 X129.075 Y127.955 E.01877
G1 X129.258 Y127.962 E.00716
M204 S10000
G1 X136.008 Y127.985 F42000
; LINE_WIDTH: 0.52514
G1 F11748
M204 S6000
G1 X136.443 Y128.229 E.01958
G1 X136.58 Y128.24 E.0054
G1 X136.722 Y128.12 E.0073
G1 X136.752 Y128.024 E.00396
G1 X136.709 Y127.85 E.00703
G1 X136.573 Y127.762 E.00637
G1 X136.375 Y127.789 E.00785
G1 X136.061 Y127.957 E.014
; WIPE_START
G1 F13064.577
G1 X136.375 Y127.789 E-.14876
G1 X136.573 Y127.762 E-.08348
G1 X136.709 Y127.85 E-.06771
G1 X136.752 Y128.024 E-.07474
G1 X136.722 Y128.12 E-.04213
G1 X136.58 Y128.24 E-.07763
G1 X136.443 Y128.229 E-.05742
G1 X136.008 Y127.985 E-.20812
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.494 Y126.643 Z2.2 F42000
G1 X127.741 Y126.509 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.109271
G1 F11748
M204 S6000
G1 X127.664 Y126.367 E.00088
; WIPE_START
G1 F15000
G1 X127.741 Y126.509 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.469 Y125.921 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; LINE_WIDTH: 0.206628
G1 F11748
M204 S6000
G1 X126.969 Y126.27 E.00813
M204 S10000
G1 X126.959 Y126.282 F42000
; LINE_WIDTH: 0.127991
G1 F11748
M204 S6000
G2 X126.501 Y125.922 I-7.5 J9.073 E.00404
M204 S10000
G1 X126.79 Y126.062 F42000
; LINE_WIDTH: 0.241272
G1 F11748
M204 S6000
G1 X126.561 Y126.019 E.00377
; LINE_WIDTH: 0.202436
G1 X126.239 Y125.982 E.00421
; LINE_WIDTH: 0.180624
G2 X126.261 Y129.225 I-.147 J1.623 E.06098
; LINE_WIDTH: 0.216722
G1 X126.454 Y129.213 E.00274
; LINE_WIDTH: 0.243264
G1 X126.67 Y129.187 E.00355
M204 S10000
G1 X126.853 Y128.983 F42000
; LINE_WIDTH: 0.11375
G1 F11748
M204 S6000
G1 X126.737 Y129.063 E.00082
; LINE_WIDTH: 0.14392
G1 X126.679 Y129.1 E.00057
; LINE_WIDTH: 0.181865
G3 X126.341 Y129.305 I-4.476 J-6.997 E.00448
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X126.679 Y129.1 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X132.758 Y133.715 Z2.2 F42000
G1 X135.288 Y135.637 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11748
M204 S6000
G1 X128.535 Y135.378 E.2242
G2 X128.595 Y134.012 I-2.613 J-.799 E.04582
G1 X135.585 Y134.279 E.23204
G3 X136.335 Y133.931 I1.312 J1.841 E.02759
G1 X136.413 Y133.92 E.00262
G3 X136.567 Y133.917 I.125 J2.493 E.00511
G3 X135.961 Y135.932 I-.057 J1.081 E.12999
G1 X135.516 Y135.645 E.01757
G1 X135.348 Y135.639 E.00557
M204 S10000
G1 X135.232 Y136.042 F42000
G1 F11748
M204 S6000
G1 X127.921 Y135.762 E.2427
G2 X128.011 Y133.583 I-1.946 J-1.172 E.07545
G1 X135.484 Y133.868 E.24808
G3 X136.594 Y133.511 I1.106 J1.535 E.03929
G3 X135.755 Y136.283 I-.084 J1.488 E.17873
G1 X135.389 Y136.048 E.01441
G1 X135.292 Y136.044 E.00324
M204 S10000
G1 X135.175 Y136.447 F42000
G1 F11748
M204 S6000
G1 X127.011 Y136.134 E.271
G2 X127.703 Y135.282 I-1.438 J-1.873 E.03675
G2 X127.45 Y133.496 I-1.634 J-.679 E.06275
G1 X127.128 Y133.142 E.01589
G1 X135.384 Y133.457 E.27407
G3 X136.62 Y133.105 I1.137 J1.644 E.0434
G3 X135.548 Y136.634 I-.111 J1.894 E.22747
G1 X135.263 Y136.45 E.01126
G1 X135.235 Y136.449 E.00092
; WIPE_START
G1 F15476.087
G1 X133.236 Y136.373 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X125.792 Y134.69 Z2.2 F42000
G1 X124.736 Y134.452 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11748
M204 S5000
G1 X124.736 Y134.449 E.00008
G3 X125.951 Y133.246 I1.351 J.15 E.05682
G1 X126.069 Y133.24 E.00361
G3 X124.732 Y134.712 I.019 J1.359 E.19399
G1 X124.735 Y134.512 E.00614
; WIPE_START
G1 F12000
M204 S6000
G1 X124.736 Y134.449 E-.02378
G1 X124.782 Y134.219 E-.0894
G1 X124.903 Y133.931 E-.1186
G1 X125.059 Y133.71 E-.10261
G1 X125.222 Y133.551 E-.08657
G1 X125.446 Y133.4 E-.10261
G1 X125.689 Y133.299 E-.09988
G1 X125.951 Y133.246 E-.10182
G1 X126.043 Y133.241 E-.03473
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.122 Y136.093 Z2.2 F42000
G1 X134.956 Y136.831 Z2.2
G1 Z1.8
G1 E.8 F1800
G1 F11748
M204 S5000
G1 X126.021 Y136.488 E.27475
G3 X126.097 Y132.71 I.068 J-1.889 E.18063
G1 X135.288 Y133.061 E.2826
G3 X136.646 Y132.713 I1.227 J1.968 E.04376
G3 X135.14 Y136.838 I-.142 J2.285 E.26153
G1 X135.015 Y136.833 E.00384
; WIPE_START
G1 F12000
M204 S6000
G1 X133.017 Y136.757 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.318 Y134.964 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.522965
G1 F11748
M204 S6000
G1 X135.589 Y135.204 E.24548
; LINE_WIDTH: 0.506007
M73 P80 R2
G1 X135.75 Y135.315 E.00738
; LINE_WIDTH: 0.4716
G1 X135.911 Y135.426 E.00683
; LINE_WIDTH: 0.423648
G1 X136.072 Y135.537 E.00607
G1 X136.455 Y135.684 E.01272
G1 X136.812 Y135.616 E.01129
G1 X137.029 Y135.448 E.00853
G1 X137.162 Y135.214 E.00835
G1 X137.194 Y134.942 E.0085
G1 X137.124 Y134.688 E.00817
G1 X136.9 Y134.445 E.01025
G1 X136.672 Y134.343 E.00776
G2 X136.171 Y134.409 I-.156 J.744 E.01596
G1 X135.731 Y134.668 E.01585
; LINE_WIDTH: 0.475158
G1 X135.669 Y134.696 E.00239
; LINE_WIDTH: 0.522787
G1 X135.607 Y134.724 E.00265
G1 X129.079 Y134.475 E.25547
G1 X129.075 Y134.955 E.01877
G1 X129.258 Y134.962 E.00716
M204 S10000
G1 X136.008 Y134.985 F42000
; LINE_WIDTH: 0.52514
G1 F11748
M204 S6000
G1 X136.443 Y135.228 E.01958
G1 X136.58 Y135.239 E.0054
G1 X136.722 Y135.119 E.0073
G1 X136.752 Y135.023 E.00396
G1 X136.709 Y134.849 E.00703
G1 X136.573 Y134.761 E.00637
G1 X136.375 Y134.788 E.00785
G1 X136.061 Y134.956 E.014
; WIPE_START
G1 F13064.577
G1 X136.375 Y134.788 E-.14876
G1 X136.573 Y134.761 E-.08348
G1 X136.709 Y134.849 E-.06771
G1 X136.752 Y135.023 E-.07474
G1 X136.722 Y135.119 E-.04213
G1 X136.58 Y135.239 E-.07763
G1 X136.443 Y135.228 E-.05742
G1 X136.008 Y134.985 E-.20812
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.494 Y133.643 Z2.2 F42000
G1 X127.741 Y133.508 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.109271
G1 F11748
M204 S6000
G1 X127.664 Y133.366 E.00088
; WIPE_START
G1 F15000
G1 X127.741 Y133.508 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.469 Y132.92 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; LINE_WIDTH: 0.206628
G1 F11748
M204 S6000
G1 X126.969 Y133.269 E.00813
M204 S10000
G1 X126.959 Y133.281 F42000
; LINE_WIDTH: 0.127991
G1 F11748
M204 S6000
G2 X126.501 Y132.922 I-7.5 J9.073 E.00404
M204 S10000
G1 X126.79 Y133.061 F42000
; LINE_WIDTH: 0.241272
G1 F11748
M204 S6000
G1 X126.561 Y133.018 E.00377
; LINE_WIDTH: 0.202436
G1 X126.239 Y132.981 E.00421
; LINE_WIDTH: 0.180624
G2 X126.261 Y136.224 I-.147 J1.623 E.06098
; LINE_WIDTH: 0.216722
G1 X126.454 Y136.212 E.00274
; LINE_WIDTH: 0.243264
G1 X126.67 Y136.186 E.00355
M204 S10000
G1 X126.853 Y135.982 F42000
; LINE_WIDTH: 0.11375
G1 F11748
M204 S6000
G1 X126.737 Y136.063 E.00082
; LINE_WIDTH: 0.14392
G1 X126.679 Y136.099 E.00057
; LINE_WIDTH: 0.181865
G3 X126.341 Y136.304 I-4.476 J-6.997 E.00448
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X126.679 Y136.099 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X122.367 Y129.802 Z2.2 F42000
G1 X119.11 Y125.046 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F11748
M204 S6000
G1 X119.385 Y125.118 E.00941
G2 X120.476 Y125.105 I.509 J-3.24 E.03639
G1 X120.209 Y132.058 E.2308
G3 X120.509 Y132.638 I-2.624 J1.724 E.02169
G3 X118.554 Y132.454 I-1.02 J.362 E.14402
G1 X118.843 Y132.007 E.01767
G1 X119.108 Y125.106 E.22909
M204 S10000
G1 X118.726 Y124.437 F42000
G1 F11748
M204 S6000
G1 X119.053 Y124.591 E.01197
G2 X120.907 Y124.502 I.834 J-2.004 E.06363
G1 X120.62 Y131.963 E.24765
G3 X120.978 Y133.055 I-1.675 J1.153 E.03864
G3 X118.204 Y132.246 I-1.489 J-.054 E.17979
G1 X118.44 Y131.88 E.01445
G1 X118.724 Y124.497 E.24508
; WIPE_START
G1 F15476.087
G1 X119.053 Y124.591 E-.12997
G1 X119.465 Y124.718 E-.16381
G1 X119.709 Y124.752 E-.09394
G1 X120.073 Y124.751 E-.13818
G1 X120.495 Y124.672 E-.16296
G1 X120.671 Y124.61 E-.07115
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.354 Y123.522 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
G1 F11748
M204 S6000
G1 X118.678 Y123.866 E.01568
G2 X120.991 Y123.961 I1.211 J-1.274 E.08386
G1 X121.348 Y123.638 E.01595
G1 X121.031 Y131.867 E.27317
G3 X120.553 Y134.572 I-1.603 J1.111 E.10111
G3 X117.854 Y132.037 I-1.063 J-1.573 E.1698
G1 X118.038 Y131.753 E.01123
G1 X118.352 Y123.582 E.27123
; WIPE_START
G1 F15476.087
G1 X118.678 Y123.866 E-.16439
G1 X118.91 Y124.053 E-.11333
G1 X119.211 Y124.215 E-.12977
G1 X119.545 Y124.318 E-.13275
G1 X119.745 Y124.346 E-.07703
G1 X120.036 Y124.345 E-.11049
G1 X120.12 Y124.33 E-.03224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.841 Y121.731 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F11748
M204 S5000
G1 X118.842 Y121.73 E.00003
G3 X119.727 Y121.248 I1.046 J.869 E.03171
G1 X119.877 Y121.239 E.00463
G3 X118.671 Y121.991 I.01 J1.36 E.21654
G1 X118.809 Y121.781 E.00772
; WIPE_START
G1 F12000
M204 S6000
G1 X118.842 Y121.73 E-.02319
G1 X119.034 Y121.54 E-.10266
G1 X119.223 Y121.413 E-.08654
G1 X119.463 Y121.307 E-.09977
G1 X119.727 Y121.248 E-.10255
G1 X119.877 Y121.239 E-.05724
G1 X120.102 Y121.256 E-.08583
G1 X120.362 Y121.324 E-.10198
G1 X120.599 Y121.44 E-.10024
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.434 Y128.759 Z2.2 F42000
G1 X117.66 Y131.378 Z2.2
G1 Z1.8
G1 E.8 F1800
G1 F11748
M204 S5000
G1 X118 Y122.529 E.2721
G3 X119.987 Y120.712 I1.902 J.085 E.0919
G3 X121.777 Y122.676 I-.102 J1.891 E.09051
G1 X121.427 Y131.775 E.2798
G3 X117.65 Y131.63 I-1.938 J1.222 E.30584
G1 X117.657 Y131.438 E.00592
; WIPE_START
G1 F12000
M204 S6000
G1 X117.734 Y129.439 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.534 Y125.576 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.5241
G1 F11748
M204 S6000
G1 X119.283 Y132.098 E.25593
; LINE_WIDTH: 0.507507
G1 X119.167 Y132.266 E.00772
; LINE_WIDTH: 0.4725
G1 X119.051 Y132.434 E.00714
; LINE_WIDTH: 0.423917
G2 X118.802 Y132.983 I1.15 J.852 E.01885
G1 X118.849 Y133.25 E.00843
G1 X118.998 Y133.482 E.00854
G1 X119.186 Y133.617 E.00718
G1 X119.487 Y133.687 E.00959
G1 X119.749 Y133.636 E.00831
G1 X119.975 Y133.486 E.0084
G1 X120.125 Y133.258 E.00846
G1 X120.175 Y132.987 E.00857
G1 X120.074 Y132.639 E.01124
G1 X119.819 Y132.204 E.01568
; LINE_WIDTH: 0.477745
G1 X119.791 Y132.15 E.00214
; LINE_WIDTH: 0.523054
G1 X119.764 Y132.096 E.00237
G1 X120.013 Y125.601 E.25428
G1 X119.594 Y125.579 E.01645
M204 S10000
G1 X119.509 Y132.493 F42000
; LINE_WIDTH: 0.52691
G1 F11748
M204 S6000
G1 X119.253 Y132.943 E.02042
G1 X119.258 Y133.091 E.00582
G1 X119.367 Y133.217 E.00658
G1 X119.583 Y133.23 E.00852
G1 X119.718 Y133.094 E.00753
G1 X119.727 Y133.041 E.00214
G1 X119.694 Y132.841 E.00798
G1 X119.537 Y132.546 E.01319
; WIPE_START
G1 F13016.798
G1 X119.694 Y132.841 E-.13894
G1 X119.727 Y133.041 E-.08403
G1 X119.718 Y133.094 E-.02249
G1 X119.583 Y133.23 E-.07932
G1 X119.367 Y133.217 E-.08968
G1 X119.258 Y133.091 E-.06926
G1 X119.253 Y132.943 E-.06126
G1 X119.509 Y132.493 E-.21503
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.742 Y124.899 Z2.2 F42000
G1 X118.667 Y124.158 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.108604
G1 F11748
M204 S6000
G1 X118.536 Y124.073 E.00084
; WIPE_START
G1 F15000
G1 X118.667 Y124.158 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.184 Y122.846 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; LINE_WIDTH: 0.205429
G1 F11748
M204 S6000
G1 X118.497 Y123.379 E.00818
M204 S10000
G1 X118.511 Y123.369 F42000
; LINE_WIDTH: 0.125616
G1 F11748
M204 S6000
G3 X118.182 Y122.883 I8.14 J-5.858 E.00395
M204 S10000
G1 X118.3 Y123.178 F42000
; LINE_WIDTH: 0.24246
G1 F11748
M204 S6000
G1 X118.276 Y122.959 E.00358
; LINE_WIDTH: 0.216186
G1 X118.264 Y122.772 E.00265
; LINE_WIDTH: 0.181673
G3 X121.508 Y122.75 I1.621 J-.167 E.06141
G1 X121.478 Y123.026 E.00314
; LINE_WIDTH: 0.237018
G1 X121.429 Y123.299 E.00439
M204 S10000
G1 X121.568 Y123.01 F42000
; LINE_WIDTH: 0.127985
G1 F11748
M204 S6000
G3 X121.207 Y123.47 I-9.459 J-7.06 E.00405
M204 S10000
G1 X121.22 Y123.481 F42000
; LINE_WIDTH: 0.208471
G1 F11748
M204 S6000
G1 X121.569 Y122.976 E.00828
; CHANGE_LAYER
; Z_HEIGHT: 2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X121.22 Y123.481 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 10/20
; update layer progress
M73 L10
M991 S0 P9 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z2.2 I.841 J.88 P1  F42000
G1 X124.918 Y119.946 Z2.2
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X124.925 Y119.933 E.00047
G3 X125.972 Y119.248 I1.184 J.667 E.03995
G1 X126.085 Y119.241 E.00346
G3 X124.817 Y120.18 I.025 J1.359 E.21069
G1 X124.894 Y120.001 E.00597
; WIPE_START
M204 S6000
G1 X124.925 Y119.933 E-.02857
G1 X125.048 Y119.75 E-.08365
G1 X125.274 Y119.527 E-.12056
G1 X125.461 Y119.405 E-.08475
G1 X125.709 Y119.301 E-.10243
G1 X125.972 Y119.248 E-.10195
G1 X126.085 Y119.241 E-.04278
G1 X126.351 Y119.263 E-.10162
G1 X126.588 Y119.33 E-.09368
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.091 Y120.731 Z2.4 F42000
G1 X136.506 Y121.182 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X136.355 Y120.995 E.00798
G1 X137.168 Y120.135 E.03926
G1 X137.265 Y120.224 E.00435
G3 X137.098 Y121.914 I-.758 J.779 E.06468
G1 X136.544 Y121.229 E.02924
M204 S10000
G1 X136.244 Y121.505 F42000
G1 F15476.087
M204 S6000
G1 X136.091 Y121.317 E.00804
G3 X136.113 Y120.657 I.428 J-.316 E.0236
G1 X137.093 Y119.623 E.04725
G1 X137.246 Y119.704 E.00575
G3 X136.984 Y122.42 I-.739 J1.299 E.114
G1 X136.282 Y121.552 E.03705
M204 S10000
G1 X135.982 Y121.828 F42000
G1 F15476.087
M204 S6000
G1 X135.765 Y121.56 E.01143
G3 X135.807 Y120.39 I.749 J-.559 E.04199
G1 X136.971 Y119.159 E.05621
G1 X137.103 Y119.198 E.00455
G3 X136.825 Y122.871 I-.594 J1.802 E.16714
G1 X136.019 Y121.875 E.04249
; WIPE_START
G1 X135.765 Y121.56 E-.15377
G1 X135.63 Y121.309 E-.10822
G1 X135.59 Y121.149 E-.06273
G1 X135.579 Y120.968 E-.06877
G1 X135.597 Y120.814 E-.05912
G1 X135.652 Y120.637 E-.07057
G1 X135.807 Y120.39 E-.11061
G1 X136.035 Y120.148 E-.1262
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.856 Y122.829 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X126.041 Y122.49 E.27107
G3 X126.111 Y118.711 I.074 J-1.889 E.18002
G1 X135.288 Y119.062 E.28219
G3 X136.645 Y118.715 I1.227 J1.969 E.04375
G3 X135.14 Y122.839 I-.139 J2.286 E.26178
G1 X134.916 Y122.831 E.00689
; WIPE_START
M204 S6000
G1 X132.918 Y122.754 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 10 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.4
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.4 F4000
            G39.3 S1
            G0 Z2.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer10 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X136.435 Y122.742 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Top surface
G1 F12000
M204 S2000
G1 X136.129 Y123.048 E.01329
G1 X135.718 Y122.925
G1 X136.196 Y122.447 E.02077
G1 X135.958 Y122.152
G1 X135.369 Y122.741 E.02556
G1 X134.952 Y122.625
G1 X135.719 Y121.858 E.03334
G1 X135.495 Y121.549
G1 X134.439 Y122.605 E.04589
G1 X133.925 Y122.585
G1 X135.366 Y121.145 E.0626
G1 X135.465 Y120.512
G1 X133.411 Y122.566 E.08924
G1 X132.898 Y122.546
G1 X136.524 Y118.919 E.15759
G1 X135.898 Y119.012
G1 X132.384 Y122.526 E.15269
G1 X131.871 Y122.506
G1 X135.114 Y119.263 E.14093
G1 X134.6 Y119.244
G1 X131.357 Y122.487 E.14093
G1 X130.844 Y122.467
G1 X134.087 Y119.224 E.14092
G1 X133.573 Y119.204
G1 X130.33 Y122.447 E.14092
G1 X129.817 Y122.427
G1 X133.06 Y119.185 E.14091
G1 X132.546 Y119.165
M73 P80 R1
G1 X129.303 Y122.408 E.14091
G1 X128.79 Y122.388
G1 X132.032 Y119.145 E.14091
G1 X131.519 Y119.126
G1 X128.276 Y122.368 E.1409
G1 X127.763 Y122.349
M73 P81 R1
G1 X131.005 Y119.106 E.1409
G1 X130.491 Y119.086
G1 X127.249 Y122.329 E.1409
G1 X126.759 Y122.286
G1 X129.978 Y119.067 E.13988
G1 X129.464 Y119.047
G1 X127.654 Y120.857 E.07864
G1 X127.651 Y120.327
G1 X128.951 Y119.028 E.05646
G1 X128.437 Y119.008
G1 X127.521 Y119.924 E.03982
G1 X127.313 Y119.599
G1 X127.923 Y118.988 E.02652
G1 X127.41 Y118.969
G1 X127.037 Y119.341 E.01618
; WIPE_START
M204 S6000
G1 X127.41 Y118.969 E-.20007
G1 X127.923 Y118.988 E-.19531
G1 X127.313 Y119.599 E-.328
G1 X127.365 Y119.68 E-.03662
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.813 Y121.349 Z2.4 F42000
G1 X135.468 Y121.496 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.10531
G1 F15000
M204 S6000
G1 X135.413 Y121.416 E.0005
G1 X135.427 Y121.35 E.00034
; WIPE_START
G1 X135.413 Y121.416 E-.31056
G1 X135.468 Y121.496 E-.44944
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.509 Y118.901 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.226779
G1 F15000
M204 S6000
G1 X136.724 Y118.989 E.00349
; LINE_WIDTH: 0.205698
G1 X136.708 Y119.038 E.00069
; LINE_WIDTH: 0.161525
G1 X136.692 Y119.087 E.0005
G2 X135.598 Y120.212 I23.414 J23.867 E.01517
; LINE_WIDTH: 0.19813
G1 X135.457 Y120.379 E.00276
G1 X135.461 Y120.417 E.00048
; LINE_WIDTH: 0.166803
G1 X135.476 Y120.523 E.00108
; WIPE_START
G1 X135.461 Y120.417 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.943 Y119.102 Z2.4 F42000
G1 X126.974 Y118.933 Z2.4
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.142418
G1 F15000
M204 S6000
G1 X126.857 Y119.19 E.00229
G1 X126.883 Y119.228 E.00037
; LINE_WIDTH: 0.0950814
G1 X126.942 Y119.273 E.00031
; WIPE_START
G1 X126.883 Y119.228 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.724 Y120.927 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.12974
G1 F15000
M204 S6000
G1 X127.561 Y121.196 E.00222
M204 S10000
G1 X127.708 Y121.07 F42000
; LINE_WIDTH: 0.115311
G1 F15000
M204 S6000
G1 X127.641 Y120.843 E.00139
; WIPE_START
G1 X127.708 Y121.07 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.682 Y122.052 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.250721
G1 F15000
M204 S6000
G1 X126.596 Y122.2 E.0029
G1 X126.474 Y122.213 E.00207
; LINE_WIDTH: 0.221424
G1 X126.338 Y122.223 E.00199
; LINE_WIDTH: 0.181107
G1 X126.33 Y122.224 E.00009
G3 X126.257 Y118.982 I-.21 J-1.617 E.06159
G1 X126.264 Y118.983 E.00008
; LINE_WIDTH: 0.202547
G1 X126.583 Y119.02 E.00417
; LINE_WIDTH: 0.259061
G1 X126.72 Y119.046 E.00246
G1 X126.795 Y119.199 E.00302
; WIPE_START
G1 X126.72 Y119.046 E-.41886
G1 X126.583 Y119.02 E-.34114
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.075 Y120.476 Z2.4 F42000
G1 X136.839 Y121.014 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.36524
G1 F15000
M204 S6000
G1 X137.109 Y121.348 E.01129
G2 X137.218 Y121.088 I-.335 J-.292 E.00753
G1 X137.147 Y120.688 E.01066
G1 X136.88 Y120.97 E.0102
; OBJECT_ID: 80
; WIPE_START
G1 X137.147 Y120.688 E-.19556
G1 X137.218 Y121.088 E-.20431
G1 X137.196 Y121.196 E-.05584
G1 X137.109 Y121.348 E-.08783
G1 X136.839 Y121.014 E-.21646
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X136.527 Y128.218 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X136.36 Y127.994 E.00927
G1 X137.135 Y127.104 E.03916
G1 X137.265 Y127.223 E.00583
G3 X137.064 Y128.94 I-.762 J.781 E.0662
G1 X136.562 Y128.266 E.02785
M204 S10000
G1 X136.255 Y128.535 F42000
G1 F15476.087
M204 S6000
G1 X136.071 Y128.288 E.0102
G3 X136.103 Y127.669 I.444 J-.287 E.02197
G1 X137.035 Y126.6 E.04703
G1 X137.162 Y126.659 E.00466
G3 X136.923 Y129.433 I-.654 J1.341 E.11908
G1 X136.29 Y128.583 E.03517
M204 S10000
G1 X135.983 Y128.851 F42000
G1 F15476.087
M204 S6000
G1 X135.73 Y128.511 E.01404
G3 X135.786 Y127.413 I.788 J-.51 E.03896
G1 X136.895 Y126.141 E.056
G1 X136.992 Y126.164 E.00329
G3 X136.751 Y129.884 I-.483 J1.836 E.17362
G1 X136.018 Y128.899 E.04071
; WIPE_START
G1 X135.73 Y128.511 E-.1836
G1 X135.616 Y128.262 E-.10423
G1 X135.582 Y128.094 E-.06495
G1 X135.582 Y127.924 E-.0649
G1 X135.643 Y127.657 E-.10403
G1 X135.786 Y127.413 E-.1073
G1 X136.013 Y127.153 E-.13098
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.383 Y127.354 Z2.4 F42000
G1 X124.737 Y127.45 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X124.738 Y127.445 E.00016
G3 X125.951 Y126.247 I1.35 J.154 E.05662
G1 X126.064 Y126.24 E.00346
G3 X124.734 Y127.712 I.025 J1.359 E.19407
G1 X124.736 Y127.51 E.00621
; WIPE_START
M204 S6000
G1 X124.738 Y127.445 E-.02474
G1 X124.78 Y127.227 E-.08459
G1 X124.88 Y126.975 E-.10269
G1 X125.027 Y126.749 E-.10258
G1 X125.218 Y126.555 E-.10353
G1 X125.44 Y126.405 E-.10169
G1 X125.691 Y126.299 E-.10349
G1 X125.951 Y126.247 E-.10091
G1 X126.045 Y126.241 E-.03579
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.12 Y129.106 Z2.4 F42000
G1 X134.907 Y129.83 Z2.4
G1 Z2
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X126.02 Y129.489 E.27326
G3 X126.089 Y125.711 I.071 J-1.889 E.18019
G1 X135.288 Y126.062 E.28284
G3 X136.645 Y125.714 I1.228 J1.969 E.04375
G3 X135.14 Y129.839 I-.137 J2.287 E.26195
G1 X134.967 Y129.832 E.00534
; WIPE_START
M204 S6000
G1 X132.968 Y129.756 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.392 Y129.774 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Top surface
G1 F12000
M204 S2000
G1 X136.121 Y130.044 E.01175
G1 X135.711 Y129.921
G1 X136.164 Y129.468 E.0197
G1 X135.937 Y129.162
G1 X135.363 Y129.736 E.02493
G1 X134.942 Y129.624
G1 X135.709 Y128.856 E.03335
G1 X135.491 Y128.541
G1 X134.428 Y129.604 E.04617
G1 X133.915 Y129.584
G1 X135.363 Y128.135 E.06296
G1 X135.475 Y127.491
G1 X133.401 Y129.565 E.09012
G1 X132.888 Y129.545
G1 X136.514 Y125.919 E.15757
G1 X135.883 Y126.016
G1 X132.374 Y129.525 E.15248
G1 X131.86 Y129.506
G1 X135.104 Y126.262 E.14094
M73 P82 R1
G1 X134.59 Y126.243
G1 X131.347 Y129.486 E.14093
G1 X130.833 Y129.466
G1 X134.076 Y126.223 E.14093
G1 X133.563 Y126.203
G1 X130.32 Y129.446 E.14093
G1 X129.806 Y129.427
G1 X133.049 Y126.184 E.14092
G1 X132.535 Y126.164
G1 X129.293 Y129.407 E.14092
G1 X128.779 Y129.387
G1 X132.022 Y126.145 E.14092
G1 X131.508 Y126.125
G1 X128.265 Y129.368 E.14091
G1 X127.752 Y129.348
G1 X130.995 Y126.105 E.14091
G1 X130.481 Y126.086
G1 X127.238 Y129.328 E.14091
G1 X126.74 Y129.294
G1 X129.967 Y126.066 E.14025
G1 X129.454 Y126.047
G1 X127.632 Y127.868 E.07915
G1 X127.632 Y127.335
G1 X128.94 Y126.027 E.05684
G1 X128.426 Y126.007
G1 X127.503 Y126.931 E.04012
G1 X127.296 Y126.604
G1 X127.913 Y125.988 E.02678
G1 X127.399 Y125.968
G1 X127.024 Y126.343 E.01631
; WIPE_START
M204 S6000
G1 X127.399 Y125.968 E-.20168
G1 X127.913 Y125.988 E-.19533
G1 X127.296 Y126.604 E-.33115
G1 X127.341 Y126.675 E-.03183
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.706 Y127.942 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.102097
G1 F15000
M204 S6000
G3 X127.529 Y128.211 I-5.507 J-3.424 E.00155
M204 S10000
G1 X127.697 Y127.933 F42000
; LINE_WIDTH: 0.173838
G1 F15000
M204 S6000
G3 X127.536 Y128.216 I-5.923 J-3.183 E.00348
; WIPE_START
G1 X127.697 Y127.933 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.962 Y125.933 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.154129
G1 F15000
M204 S6000
G1 X126.841 Y126.188 E.00256
; LINE_WIDTH: 0.126736
G1 X126.869 Y126.231 E.00035
; LINE_WIDTH: 0.0954089
G1 X126.93 Y126.277 E.00033
; WIPE_START
G1 X126.869 Y126.231 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.501 Y126.12 Z2.4 F42000
G1 X136.641 Y126.089 Z2.4
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.105834
G1 F15000
M204 S6000
G1 X136.284 Y126.472 E.00268
; LINE_WIDTH: 0.141169
G1 X135.927 Y126.854 E.00419
; LINE_WIDTH: 0.176729
G1 X135.566 Y127.241 E.00577
; LINE_WIDTH: 0.211359
G1 X135.413 Y127.429 E.00333
; WIPE_START
G1 X135.566 Y127.241 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.832 Y128.012 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.37151
G1 F15000
M204 S6000
G1 X137.109 Y128.379 E.0123
G1 X137.212 Y128.063 E.00889
G1 X137.188 Y127.799 E.00711
G1 X137.123 Y127.678 E.00366
G1 X136.871 Y127.967 E.01025
; WIPE_START
G1 X137.123 Y127.678 E-.18457
G1 X137.188 Y127.799 E-.06591
G1 X137.212 Y128.063 E-.12802
G1 X137.109 Y128.379 E-.15999
G1 X136.832 Y128.012 E-.2215
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.321 Y126.658 Z2.4 F42000
G1 X126.774 Y126.198 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.259041
G1 F15000
M204 S6000
G1 X126.699 Y126.045 E.00301
G1 X126.561 Y126.019 E.00246
; LINE_WIDTH: 0.202707
G1 X126.246 Y125.982 E.00414
; LINE_WIDTH: 0.18107
G1 X126.239 Y125.982 E.00008
G2 X126.317 Y129.223 I-.138 J1.625 E.06167
; LINE_WIDTH: 0.221999
G1 X126.459 Y129.212 E.00208
; LINE_WIDTH: 0.256382
G1 X126.689 Y129.184 E.00404
; OBJECT_ID: 69
; WIPE_START
G1 X126.459 Y129.212 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X133.014 Y133.122 Z2.4 F42000
G1 X136.527 Y135.217 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X136.36 Y134.993 E.00927
G1 X137.135 Y134.103 E.03916
G1 X137.265 Y134.222 E.00583
G3 X137.064 Y135.939 I-.762 J.781 E.0662
G1 X136.562 Y135.266 E.02785
M204 S10000
G1 X136.255 Y135.534 F42000
G1 F15476.087
M204 S6000
G1 X136.071 Y135.287 E.0102
G3 X136.103 Y134.668 I.444 J-.287 E.02197
G1 X137.035 Y133.599 E.04703
G1 X137.162 Y133.658 E.00466
G3 X136.923 Y136.433 I-.654 J1.341 E.11908
G1 X136.29 Y135.582 E.03517
M204 S10000
G1 X135.983 Y135.85 F42000
G1 F15476.087
M204 S6000
G1 X135.73 Y135.511 E.01404
G3 X135.786 Y134.413 I.788 J-.51 E.03896
G1 X136.895 Y133.14 E.056
G1 X136.992 Y133.163 E.00329
G3 X136.751 Y136.883 I-.483 J1.836 E.17362
G1 X136.018 Y135.898 E.04071
; WIPE_START
G1 X135.73 Y135.511 E-.1836
G1 X135.616 Y135.261 E-.10423
G1 X135.582 Y135.094 E-.06495
G1 X135.582 Y134.923 E-.0649
G1 X135.643 Y134.656 E-.10403
G1 X135.786 Y134.413 E-.1073
G1 X136.013 Y134.153 E-.13098
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X128.383 Y134.353 Z2.4 F42000
G1 X124.737 Y134.449 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X124.738 Y134.444 E.00016
G3 X125.951 Y133.246 I1.35 J.154 E.05662
G1 X126.064 Y133.24 E.00346
G3 X124.734 Y134.712 I.025 J1.359 E.19407
G1 X124.736 Y134.509 E.00621
; WIPE_START
M204 S6000
G1 X124.738 Y134.444 E-.02474
G1 X124.78 Y134.226 E-.08459
G1 X124.88 Y133.975 E-.10269
G1 X125.027 Y133.748 E-.10258
G1 X125.218 Y133.554 E-.10353
G1 X125.44 Y133.404 E-.10169
G1 X125.691 Y133.299 E-.10349
G1 X125.951 Y133.246 E-.10091
G1 X126.045 Y133.241 E-.03579
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.12 Y136.105 Z2.4 F42000
G1 X134.907 Y136.829 Z2.4
G1 Z2
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X126.02 Y136.488 E.27326
G3 X126.089 Y132.71 I.071 J-1.889 E.18019
G1 X135.288 Y133.061 E.28284
G3 X136.645 Y132.713 I1.228 J1.969 E.04375
G3 X135.14 Y136.838 I-.137 J2.287 E.26195
G1 X134.967 Y136.831 E.00534
; WIPE_START
M204 S6000
G1 X132.968 Y136.755 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.392 Y136.773 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Top surface
G1 F12000
M204 S2000
G1 X136.121 Y137.043 E.01175
G1 X135.711 Y136.92
G1 X136.164 Y136.467 E.0197
G1 X135.937 Y136.161
G1 X135.363 Y136.735 E.02493
G1 X134.942 Y136.623
G1 X135.709 Y135.855 E.03335
G1 X135.491 Y135.541
G1 X134.428 Y136.603 E.04617
G1 X133.915 Y136.584
G1 X135.363 Y135.135 E.06296
G1 X135.475 Y134.49
G1 X133.401 Y136.564 E.09012
G1 X132.888 Y136.544
G1 X136.514 Y132.918 E.15757
G1 X135.883 Y133.015
G1 X132.374 Y136.524 E.15248
G1 X131.86 Y136.505
G1 X135.104 Y133.261 E.14094
G1 X134.59 Y133.242
G1 X131.347 Y136.485 E.14093
G1 X130.833 Y136.465
G1 X134.076 Y133.222 E.14093
G1 X133.563 Y133.203
G1 X130.32 Y136.446 E.14093
G1 X129.806 Y136.426
G1 X133.049 Y133.183 E.14092
G1 X132.535 Y133.163
G1 X129.293 Y136.406 E.14092
G1 X128.779 Y136.387
G1 X132.022 Y133.144 E.14092
G1 X131.508 Y133.124
G1 X128.265 Y136.367 E.14091
G1 X127.752 Y136.347
G1 X130.995 Y133.105 E.14091
G1 X130.481 Y133.085
G1 X127.238 Y136.328 E.14091
G1 X126.74 Y136.293
G1 X129.967 Y133.065 E.14025
G1 X129.454 Y133.046
G1 X127.632 Y134.867 E.07915
G1 X127.632 Y134.334
G1 X128.94 Y133.026 E.05684
G1 X128.426 Y133.007
G1 X127.503 Y133.93 E.04012
G1 X127.296 Y133.603
G1 X127.913 Y132.987 E.02678
G1 X127.399 Y132.967
G1 X127.024 Y133.343 E.01631
; WIPE_START
M204 S6000
G1 X127.399 Y132.967 E-.20168
G1 X127.913 Y132.987 E-.19533
G1 X127.296 Y133.603 E-.33115
G1 X127.341 Y133.674 E-.03183
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X127.706 Y134.941 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.102097
G1 F15000
M204 S6000
G3 X127.529 Y135.211 I-5.507 J-3.424 E.00155
M204 S10000
G1 X127.697 Y134.932 F42000
; LINE_WIDTH: 0.173838
G1 F15000
M204 S6000
G3 X127.536 Y135.215 I-5.923 J-3.183 E.00348
; WIPE_START
G1 X127.697 Y134.932 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X126.962 Y132.932 Z2.4 F42000
M73 P83 R1
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.154129
G1 F15000
M204 S6000
G1 X126.841 Y133.187 E.00256
; LINE_WIDTH: 0.126736
G1 X126.869 Y133.23 E.00035
; LINE_WIDTH: 0.0954089
G1 X126.93 Y133.277 E.00033
; WIPE_START
G1 X126.869 Y133.23 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.501 Y133.12 Z2.4 F42000
G1 X136.641 Y133.089 Z2.4
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.105834
G1 F15000
M204 S6000
G1 X136.284 Y133.471 E.00268
; LINE_WIDTH: 0.141169
G1 X135.927 Y133.853 E.00419
; LINE_WIDTH: 0.176729
G1 X135.566 Y134.24 E.00577
; LINE_WIDTH: 0.211359
G1 X135.413 Y134.428 E.00333
; WIPE_START
G1 X135.566 Y134.24 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.832 Y135.012 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.37151
G1 F15000
M204 S6000
G1 X137.109 Y135.378 E.0123
G1 X137.212 Y135.063 E.00889
G1 X137.188 Y134.798 E.00711
G1 X137.123 Y134.678 E.00366
G1 X136.871 Y134.966 E.01025
; WIPE_START
G1 X137.123 Y134.678 E-.18457
G1 X137.188 Y134.798 E-.06591
G1 X137.212 Y135.063 E-.12802
G1 X137.109 Y135.378 E-.15999
G1 X136.832 Y135.012 E-.2215
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.321 Y133.657 Z2.4 F42000
G1 X126.774 Y133.198 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.259041
G1 F15000
M204 S6000
G1 X126.699 Y133.044 E.00301
G1 X126.561 Y133.018 E.00246
; LINE_WIDTH: 0.202707
G1 X126.246 Y132.981 E.00414
; LINE_WIDTH: 0.18107
G1 X126.239 Y132.981 E.00008
G2 X126.317 Y136.222 I-.138 J1.625 E.06167
; LINE_WIDTH: 0.221999
G1 X126.459 Y136.211 E.00208
; LINE_WIDTH: 0.256382
G1 X126.689 Y136.183 E.00404
; OBJECT_ID: 102
; WIPE_START
G1 X126.459 Y136.211 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X119.502 Y133.072 Z2.4 F42000
G1 X119.317 Y132.989 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X119.495 Y132.845 E.0076
G1 X120.356 Y133.659 E.03932
G3 X118.575 Y133.589 I-.865 J-.671 E.06908
G1 X119.27 Y133.026 E.02967
M204 S10000
G1 X118.993 Y132.727 F42000
G1 F15476.087
M204 S6000
G1 X119.173 Y132.581 E.00766
G3 X119.563 Y132.48 I.325 J.45 E.01366
G3 X119.832 Y132.603 I-.099 J.574 E.00994
G1 X120.866 Y133.582 E.04723
G3 X118.07 Y133.474 I-1.377 J-.59 E.11976
G1 X118.947 Y132.764 E.03741
M204 S10000
G1 X118.67 Y132.465 F42000
G1 F15476.087
M204 S6000
G1 X118.929 Y132.255 E.01106
G3 X119.614 Y132.076 I.565 J.764 E.02405
G1 X119.623 Y132.077 E.00031
G3 X120.1 Y132.296 I-.145 J.944 E.01762
G1 X121.331 Y133.461 E.05621
G3 X117.617 Y133.317 I-1.842 J-.463 E.17176
G1 X118.623 Y132.502 E.04296
; WIPE_START
G1 X118.929 Y132.255 E-.14955
G1 X119.059 Y132.173 E-.05801
G1 X119.263 Y132.096 E-.08304
G1 X119.432 Y132.069 E-.06496
G1 X119.614 Y132.076 E-.0693
G1 X119.623 Y132.077 E-.00358
G1 X119.853 Y132.142 E-.0907
G1 X120.1 Y132.296 E-.11058
G1 X120.349 Y132.532 E-.13028
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.298 Y124.972 Z2.4 F42000
G1 X118.847 Y121.725 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X118.996 Y121.572 E.00656
G3 X119.727 Y121.248 I.892 J1.026 E.02492
G1 X119.882 Y121.239 E.00478
G3 X118.809 Y121.771 I.006 J1.359 E.22429
; WIPE_START
M204 S6000
G1 X118.996 Y121.572 E-.10373
G1 X119.219 Y121.415 E-.10351
G1 X119.511 Y121.292 E-.12053
G1 X119.727 Y121.248 E-.08362
G1 X119.882 Y121.239 E-.05915
G1 X120.107 Y121.256 E-.08562
G1 X120.367 Y121.326 E-.10258
G1 X120.606 Y121.444 E-.10125
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.426 Y128.758 Z2.4 F42000
G1 X117.662 Y131.319 Z2.4
G1 Z2
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X118 Y122.531 E.27024
G3 X119.994 Y120.712 I1.902 J.083 E.09219
G3 X121.777 Y122.674 I-.11 J1.891 E.09021
G1 X121.427 Y131.775 E.27987
G3 X117.65 Y131.63 I-1.938 J1.223 E.30594
G1 X117.66 Y131.379 E.00772
; WIPE_START
M204 S6000
G1 X117.736 Y129.381 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.476 Y133.332 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.36965
G1 F15000
M204 S6000
G1 X119.144 Y133.6 E.01135
G1 X119.306 Y133.687 E.00488
G1 X119.633 Y133.698 E.00872
G1 X119.802 Y133.64 E.00474
G1 X119.519 Y133.373 E.01036
; WIPE_START
G1 X119.802 Y133.64 E-.19655
G1 X119.633 Y133.698 E-.08996
G1 X119.306 Y133.687 E-.16547
G1 X119.144 Y133.6 E-.0927
G1 X119.476 Y133.332 E-.21533
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.161 Y132.994 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.42
G1 F12000
M204 S2000
G1 X121.536 Y132.619 E.0163
G1 X121.413 Y132.208
G1 X120.887 Y132.735 E.02289
G1 X120.613 Y132.475
G1 X121.234 Y131.854 E.027
G1 X121.237 Y131.317
G1 X120.339 Y132.216 E.03905
G1 X120.038 Y131.984
G1 X121.259 Y130.763 E.05305
G1 X121.28 Y130.208
G1 X119.634 Y131.854 E.07153
G1 X119 Y131.955
G1 X121.301 Y129.654 E.10001
G1 X121.323 Y129.099
G1 X117.396 Y133.026 E.17063
G1 X117.5 Y132.388
G1 X121.344 Y128.545 E.16701
G1 X121.365 Y127.99
G1 X117.863 Y131.492 E.15219
G1 X117.884 Y130.938
G1 X121.386 Y127.435 E.15219
G1 X121.408 Y126.881
G1 X117.906 Y130.383 E.15219
G1 X117.927 Y129.829
G1 X121.429 Y126.326 E.15219
G1 X121.45 Y125.772
G1 X117.948 Y129.274 E.15219
G1 X117.969 Y128.719
G1 X121.472 Y125.217 E.15219
G1 X121.493 Y124.663
G1 X117.991 Y128.165 E.15219
G1 X118.012 Y127.61
G1 X121.514 Y124.108 E.15219
G1 X121.536 Y123.553
G1 X118.033 Y127.056 E.15219
G1 X118.055 Y126.501
G1 X120.526 Y124.03 E.10739
G1 X119.857 Y124.165
G1 X118.076 Y125.947 E.07741
G1 X118.097 Y125.392
G1 X119.4 Y124.089 E.05663
G1 X119.04 Y123.916
G1 X118.119 Y124.837 E.04005
G1 X118.14 Y124.283
G1 X118.75 Y123.673 E.0265
G1 X118.523 Y123.367
G1 X118.161 Y123.728 E.01571
M204 S10000
G1 X118.492 Y123.31 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.0973496
G1 F15000
M204 S6000
G1 X118.409 Y123.214 E.00056
G1 X118.184 Y123.234 E.001
; WIPE_START
G1 X118.409 Y123.214 E-.48579
G1 X118.492 Y123.31 E-.27421
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X117.988 Y130.926 Z2.4 F42000
G1 X117.945 Y131.575 Z2.4
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.108808
G1 F15000
M204 S6000
G3 X117.782 Y131.811 I-.934 J-.471 E.00155
M204 S10000
G1 X118.937 Y131.893 F42000
; LINE_WIDTH: 0.209229
G1 F15000
M204 S6000
G1 X118.761 Y132.033 E.00306
; LINE_WIDTH: 0.174883
G1 X118.51 Y132.259 E.00363
; LINE_WIDTH: 0.1402
G1 X118.259 Y132.485 E.00267
; LINE_WIDTH: 0.105517
G1 X118.008 Y132.71 E.00172
; WIPE_START
G1 X118.259 Y132.485 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X120.865 Y125.311 Z2.4 F42000
G1 X121.56 Y123.398 Z2.4
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.157029
G1 F15000
M204 S6000
G1 X121.357 Y123.375 E.0019
; LINE_WIDTH: 0.194385
G1 X121.317 Y123.385 E.00051
G1 X121.243 Y123.482 E.0015
; LINE_WIDTH: 0.156985
G1 X121.031 Y123.719 E.00295
G1 X120.794 Y123.935 E.00298
; LINE_WIDTH: 0.199968
G1 X120.587 Y124.092 E.00332
; WIPE_START
G1 X120.794 Y123.935 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.292 Y123.283 Z2.4 F42000
G1 Z2
M73 P84 R1
G1 E.8 F1800
; LINE_WIDTH: 0.256882
G1 F15000
M204 S6000
G1 X121.445 Y123.207 E.00298
G1 X121.47 Y123.073 E.00238
; LINE_WIDTH: 0.213792
G1 X121.495 Y122.888 E.00259
; LINE_WIDTH: 0.181265
G1 X121.507 Y122.75 E.00156
G2 X118.266 Y122.828 I-1.625 J-.136 E.0617
; LINE_WIDTH: 0.222058
G1 X118.277 Y122.97 E.00208
; LINE_WIDTH: 0.256411
G1 X118.305 Y123.2 E.00404
; CHANGE_LAYER
; Z_HEIGHT: 2.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X118.277 Y122.97 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 11/20
; update layer progress
M73 L11
M991 S0 P10 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z2.4 I.096 J1.213 P1  F42000
G1 X135.608 Y121.595 Z2.4
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3111
M204 S6000
G1 X135.594 Y121.574 E.00085
G3 X136.484 Y119.918 I.916 J-.575 E.07556
G1 X136.58 Y119.92 E.00318
G3 X135.707 Y121.723 I-.069 J1.079 E.14046
G1 X135.645 Y121.643 E.00337
M204 S10000
G1 X135.284 Y121.839 F42000
G1 F3111
M204 S6000
G1 X135.25 Y121.79 E.00197
G3 X136.477 Y119.511 I1.261 J-.791 E.10411
G1 X136.602 Y119.513 E.00416
G3 X135.399 Y121.988 I-.092 J1.486 E.19371
G1 X135.32 Y121.887 E.00426
M204 S10000
G1 X134.958 Y122.082 F42000
G1 F3111
M204 S6000
G1 X134.906 Y122.006 E.00305
G3 X136.47 Y119.104 I1.605 J-1.008 E.13267
G1 X136.625 Y119.107 E.00514
G3 X135.09 Y122.253 I-.114 J1.892 E.24696
G1 X134.995 Y122.13 E.00518
M204 S250
G1 X134.644 Y122.316 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3111
M204 S5000
G1 X134.574 Y122.215 E.00378
G3 X136.464 Y118.711 I1.936 J-1.217 E.14836
G1 X136.647 Y118.715 E.00564
G3 X134.793 Y122.508 I-.136 J2.283 E.27627
G1 X134.681 Y122.363 E.00563
; WIPE_START
G1 F12000
M204 S6000
G1 X134.574 Y122.215 E-.06951
G1 X134.368 Y121.808 E-.17323
G1 X134.251 Y121.368 E-.17327
G1 X134.223 Y120.918 E-.17119
G1 X134.267 Y120.546 E-.14251
G1 X134.29 Y120.469 E-.03029
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 11 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.6
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.6 F4000
            G39.3 S1
            G0 Z2.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer11 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.825 Y120.974 F42000
G1 Z2.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3111
M204 S6000
G1 X135.868 Y121.243 E.00837
G1 X135.999 Y121.459 E.00776
G1 X136.205 Y121.615 E.00793
G1 X136.468 Y121.685 E.00837
G1 X136.738 Y121.648 E.00838
G1 X136.945 Y121.533 E.00727
G1 X137.125 Y121.307 E.00889
G1 X137.196 Y121.049 E.00821
G1 X137.161 Y120.779 E.00836
G1 X137.024 Y120.545 E.00832
G1 X136.807 Y120.381 E.00835
G1 X136.555 Y120.316 E.008
G1 X136.288 Y120.352 E.00827
G1 X136.031 Y120.512 E.00931
G1 X135.879 Y120.735 E.00829
G1 X135.838 Y120.916 E.0057
M204 S10000
G1 X136.262 Y120.987 F42000
; LINE_WIDTH: 0.52454
G1 F3111
M204 S6000
G1 X136.324 Y121.166 E.00744
G1 X136.496 Y121.248 E.00747
G1 X136.662 Y121.2 E.00679
G1 X136.759 Y121.019 E.00806
G2 X136.529 Y120.753 I-.281 J.011 E.01488
G1 X136.334 Y120.829 E.00822
G1 X136.287 Y120.933 E.00448
; OBJECT_ID: 80
; WIPE_START
G1 F13080.852
G1 X136.334 Y120.829 E-.0593
G1 X136.529 Y120.753 E-.10894
G1 X136.697 Y120.836 E-.09723
G1 X136.759 Y121.019 E-.10031
G1 X136.662 Y121.2 E-.10684
G1 X136.496 Y121.248 E-.08995
G1 X136.324 Y121.166 E-.09891
G1 X136.262 Y120.987 E-.09852
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.74 Y128.602 Z2.6 F42000
G1 X135.73 Y128.746 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3111
M204 S6000
G3 X136.484 Y126.917 I.78 J-.748 E.08284
G1 X136.579 Y126.919 E.00318
G3 X135.773 Y128.788 I-.069 J1.079 E.13726
M204 S10000
G1 X135.428 Y129.022 F42000
G1 F3111
M204 S6000
G1 X135.257 Y128.798 E.00935
G3 X136.477 Y126.51 I1.254 J-.8 E.10443
G1 X136.602 Y126.513 E.00416
G3 X135.472 Y129.062 I-.092 J1.485 E.19014
M204 S10000
G1 X135.109 Y129.273 F42000
G1 F3111
M204 S6000
G1 X134.91 Y129.01 E.01094
G3 X136.47 Y126.103 I1.6 J-1.013 E.13284
G1 X136.625 Y126.106 E.00514
G3 X135.151 Y129.316 I-.114 J1.891 E.24392
M204 S250
G1 X134.801 Y129.515 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3111
M204 S5000
G1 X134.624 Y129.288 E.00885
G3 X136.464 Y125.711 I1.887 J-1.291 E.15107
G1 X136.647 Y125.714 E.00564
G3 X134.858 Y129.576 I-.136 J2.282 E.27327
G1 X134.842 Y129.559 E.00072
; WIPE_START
G1 F12000
M204 S6000
G1 X134.624 Y129.288 E-.13214
G1 X134.401 Y128.89 E-.17309
G1 X134.267 Y128.457 E-.17245
G1 X134.221 Y128.004 E-.17312
G1 X134.249 Y127.718 E-.1092
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.828 Y127.942 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3111
M204 S6000
G1 X135.875 Y128.256 E.00974
G1 X136.015 Y128.474 E.00797
G1 X136.227 Y128.625 E.008
G1 X136.48 Y128.686 E.00799
G1 X136.757 Y128.64 E.00864
G1 X136.994 Y128.487 E.00865
G1 X137.137 Y128.283 E.00767
G1 X137.196 Y128.028 E.00805
G2 X136.814 Y127.385 I-.818 J.051 E.02387
G1 X136.554 Y127.315 E.00826
G1 X136.284 Y127.352 E.00839
G1 X136.076 Y127.469 E.00731
G1 X135.903 Y127.683 E.00847
G1 X135.845 Y127.884 E.00644
M204 S10000
G1 X136.266 Y127.971 F42000
; LINE_WIDTH: 0.524185
G1 F3111
M204 S6000
G1 X136.331 Y128.173 E.0083
G1 X136.496 Y128.248 E.00709
G1 X136.69 Y128.173 E.00819
G1 X136.759 Y128.012 E.00686
G2 X136.358 Y127.803 I-.258 J.005 E.02166
G1 X136.295 Y127.919 E.00518
; OBJECT_ID: 69
; WIPE_START
G1 F13090.506
G1 X136.358 Y127.803 E-.06873
G1 X136.527 Y127.752 E-.09162
G1 X136.661 Y127.809 E-.07567
G1 X136.748 Y127.942 E-.08289
G1 X136.759 Y128.012 E-.03705
G1 X136.69 Y128.173 E-.09108
G1 X136.496 Y128.248 E-.10867
G1 X136.331 Y128.173 E-.09415
G1 X136.266 Y127.971 E-.11012
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.741 Y135.586 Z2.6 F42000
G1 X135.73 Y135.745 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3111
M204 S6000
G3 X136.484 Y133.917 I.78 J-.748 E.08284
G1 X136.579 Y133.918 E.00318
G3 X135.773 Y135.787 I-.069 J1.079 E.13726
M204 S10000
G1 X135.428 Y136.021 F42000
G1 F3111
M204 S6000
G1 X135.257 Y135.797 E.00935
G3 X136.477 Y133.509 I1.254 J-.8 E.10443
G1 X136.602 Y133.512 E.00416
G3 X135.472 Y136.061 I-.092 J1.485 E.19014
M204 S10000
G1 X135.109 Y136.272 F42000
G1 F3111
M204 S6000
G1 X134.91 Y136.01 E.01094
G3 X136.47 Y133.102 I1.6 J-1.013 E.13284
G1 X136.625 Y133.105 E.00514
G3 X135.151 Y136.315 I-.114 J1.891 E.24392
M204 S250
G1 X134.801 Y136.514 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3111
M204 S5000
G1 X134.624 Y136.287 E.00885
G3 X136.464 Y132.71 I1.887 J-1.291 E.15107
G1 X136.647 Y132.713 E.00564
G3 X134.858 Y136.575 I-.136 J2.282 E.27327
G1 X134.842 Y136.558 E.00072
; WIPE_START
G1 F12000
M204 S6000
G1 X134.624 Y136.287 E-.13214
G1 X134.401 Y135.89 E-.17309
G1 X134.267 Y135.456 E-.17245
G1 X134.221 Y135.003 E-.17312
G1 X134.249 Y134.717 E-.1092
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.828 Y134.941 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3111
M204 S6000
G1 X135.875 Y135.255 E.00974
G1 X136.015 Y135.473 E.00797
G1 X136.227 Y135.624 E.008
G1 X136.48 Y135.685 E.00799
G1 X136.757 Y135.64 E.00864
G1 X136.994 Y135.487 E.00865
G1 X137.137 Y135.282 E.00767
G1 X137.196 Y135.027 E.00805
G2 X136.814 Y134.384 I-.818 J.051 E.02387
G1 X136.554 Y134.315 E.00826
G1 X136.284 Y134.351 E.00839
G1 X136.076 Y134.468 E.00731
G1 X135.903 Y134.682 E.00847
G1 X135.845 Y134.884 E.00644
M204 S10000
G1 X136.266 Y134.971 F42000
; LINE_WIDTH: 0.524185
G1 F3111
M204 S6000
G1 X136.331 Y135.172 E.0083
G1 X136.496 Y135.247 E.00709
G1 X136.69 Y135.172 E.00819
G1 X136.759 Y135.011 E.00686
G2 X136.358 Y134.802 I-.258 J.005 E.02166
G1 X136.295 Y134.918 E.00518
; OBJECT_ID: 102
; WIPE_START
G1 F13090.506
M73 P85 R1
G1 X136.358 Y134.802 E-.06873
G1 X136.527 Y134.751 E-.09162
G1 X136.661 Y134.808 E-.07567
G1 X136.748 Y134.941 E-.08289
G1 X136.759 Y135.011 E-.03705
G1 X136.69 Y135.172 E-.09108
G1 X136.496 Y135.247 E-.10867
G1 X136.331 Y135.172 E-.09415
G1 X136.266 Y134.971 E-.11012
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.735 Y133.732 Z2.6 F42000
G1 X118.879 Y132.11 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3111
M204 S6000
G1 X118.917 Y132.086 E.00148
G3 X119.527 Y131.919 I.579 J.915 E.02129
G1 X119.63 Y131.927 E.00345
G3 X118.758 Y132.208 I-.135 J1.074 E.19427
G1 X118.832 Y132.148 E.00318
M204 S10000
G1 X118.637 Y131.785 F42000
G1 F3111
M204 S6000
G1 X118.699 Y131.74 E.00253
G3 X119.542 Y131.512 I.794 J1.26 E.02938
G1 X119.674 Y131.522 E.00441
G3 X118.474 Y131.915 I-.18 J1.479 E.26723
G1 X118.59 Y131.822 E.00495
M204 S10000
G1 X118.391 Y131.462 F42000
G1 F3111
M204 S6000
G1 X118.482 Y131.395 E.00377
G3 X119.557 Y131.105 I1.01 J1.606 E.03747
G1 X119.718 Y131.117 E.00537
G3 X118.189 Y131.622 I-.226 J1.883 E.34019
G1 X118.344 Y131.5 E.00655
M204 S250
G1 X118.153 Y131.153 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3111
M204 S5000
G1 X118.273 Y131.062 E.00466
G3 X119.572 Y130.712 I1.218 J1.938 E.04193
G1 X119.761 Y130.727 E.00583
G3 X117.915 Y131.34 I-.27 J2.273 E.38021
G1 X118.105 Y131.19 E.00743
; WIPE_START
G1 F12000
M204 S6000
G1 X118.273 Y131.062 E-.08038
G1 X118.681 Y130.858 E-.17332
G1 X119.122 Y130.74 E-.17328
G1 X119.572 Y130.712 E-.17118
G1 X119.761 Y130.727 E-.07208
G1 X119.991 Y130.778 E-.08976
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.455 Y132.315 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3111
M204 S6000
G1 X119.167 Y132.395 E.00919
G1 X118.979 Y132.542 E.00732
G1 X118.835 Y132.793 E.0089
G1 X118.803 Y133.032 E.0074
G1 X118.869 Y133.294 E.00832
G1 X119.031 Y133.511 E.00832
G1 X119.264 Y133.649 E.00833
G1 X119.528 Y133.686 E.0082
G1 X119.791 Y133.617 E.00833
G1 X120.005 Y133.452 E.00832
G1 X120.14 Y133.216 E.00833
G1 X120.173 Y132.948 E.00831
G1 X120.098 Y132.686 E.00838
G1 X119.94 Y132.484 E.00788
G1 X119.701 Y132.348 E.00845
G1 X119.515 Y132.323 E.00578
M204 S10000
G1 X119.561 Y132.763 F42000
; LINE_WIDTH: 0.52545
G1 F3111
M204 S6000
G1 X119.364 Y132.786 E.0078
G1 X119.249 Y132.934 E.00735
G1 X119.265 Y133.106 E.00679
G1 X119.408 Y133.235 E.0076
G1 X119.598 Y133.223 E.00746
G1 X119.724 Y133.078 E.00754
G2 X119.708 Y132.884 I-.359 J-.068 E.00775
G1 X119.607 Y132.801 E.00513
; CHANGE_LAYER
; Z_HEIGHT: 2.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13056.183
G1 X119.708 Y132.884 E-.06804
G1 X119.724 Y133.078 E-.1015
G1 X119.598 Y133.223 E-.1
G1 X119.408 Y133.235 E-.09885
G1 X119.265 Y133.106 E-.10075
G1 X119.249 Y132.934 E-.09003
G1 X119.364 Y132.786 E-.09742
G1 X119.561 Y132.763 E-.10342
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 12/20
; update layer progress
M73 L12
M991 S0 P11 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z2.6 I.697 J.997 P1  F42000
G1 X135.585 Y121.561 Z2.6
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3123
M204 S6000
G3 X136.482 Y119.918 I.925 J-.561 E.07503
G1 X136.579 Y119.92 E.0032
G3 X135.618 Y121.611 I-.069 J1.079 E.14521
M204 S10000
G1 X135.243 Y121.78 F42000
G1 F3123
M204 S6000
G3 X136.476 Y119.511 I1.267 J-.782 E.10373
G1 X136.602 Y119.513 E.00417
G3 X135.276 Y121.831 I-.092 J1.486 E.20034
M204 S10000
G1 X134.902 Y122 F42000
G1 F3123
M204 S6000
G3 X136.47 Y119.104 I1.609 J-1.002 E.13242
G1 X136.625 Y119.107 E.00515
G3 X134.934 Y122.051 I-.114 J1.892 E.25547
M204 S250
G1 X134.557 Y122.189 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3123
M204 S5000
G1 X134.37 Y121.805 E.01313
G3 X136.463 Y118.711 I2.14 J-.807 E.13427
G1 X136.647 Y118.715 E.00564
G3 X134.59 Y122.239 I-.136 J2.283 E.28667
; WIPE_START
G1 F12000
M204 S6000
G1 X134.37 Y121.805 E-.18497
G1 X134.251 Y121.367 E-.17232
G1 X134.222 Y120.928 E-.16727
G1 X134.266 Y120.551 E-.14425
G1 X134.336 Y120.321 E-.0912
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 12 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.8
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.8 F4000
            G39.3 S1
            G0 Z2.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer12 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.825 Y120.98 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3123
M204 S6000
G1 X135.864 Y121.231 E.00782
G1 X136.006 Y121.467 E.00845
G1 X136.213 Y121.62 E.00791
G1 X136.466 Y121.686 E.00803
G1 X136.738 Y121.648 E.00844
G1 X136.945 Y121.533 E.00727
G1 X137.12 Y121.316 E.00857
G1 X137.194 Y121.058 E.00825
G1 X137.163 Y120.787 E.00838
G1 X137.03 Y120.552 E.00831
G1 X136.815 Y120.386 E.00833
G1 X136.554 Y120.316 E.00832
G1 X136.29 Y120.352 E.00818
G1 X136.021 Y120.521 E.00976
G1 X135.872 Y120.747 E.00832
G1 X135.837 Y120.921 E.00545
M204 S10000
G1 X136.261 Y120.99 F42000
; LINE_WIDTH: 0.52409
G1 F3123
M204 S6000
G1 X136.33 Y121.172 E.00763
G1 X136.492 Y121.249 E.00705
G1 X136.663 Y121.199 E.00698
G1 X136.758 Y121.022 E.00788
G2 X136.526 Y120.753 I-.28 J.007 E.01509
G1 X136.328 Y120.835 E.00839
G1 X136.285 Y120.935 E.0043
; OBJECT_ID: 80
; WIPE_START
G1 F13093.085
G1 X136.328 Y120.835 E-.05703
G1 X136.526 Y120.753 E-.11118
G1 X136.699 Y120.838 E-.10002
G1 X136.758 Y121.022 E-.10033
G1 X136.663 Y121.199 E-.10438
G1 X136.492 Y121.249 E-.09253
G1 X136.33 Y121.172 E-.09338
G1 X136.261 Y120.99 E-.10115
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.705 Y128.602 Z2.8 F42000
G1 X135.697 Y128.708 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3123
M204 S6000
G1 X135.602 Y128.584 E.00516
G3 X136.483 Y126.917 I.908 J-.586 E.07598
G1 X136.579 Y126.919 E.00319
G3 X135.736 Y128.753 I-.069 J1.079 E.13893
M204 S10000
G1 X135.375 Y128.956 F42000
G1 F3123
M204 S6000
G1 X135.278 Y128.831 E.00528
G3 X136.476 Y126.51 I1.232 J-.833 E.10573
G1 X136.602 Y126.513 E.00417
G3 X135.441 Y129.032 I-.092 J1.485 E.19154
G1 X135.415 Y129.002 E.00134
M204 S10000
G1 X135.06 Y129.213 F42000
G1 F3123
M204 S6000
G1 X134.945 Y129.063 E.00626
G3 X136.47 Y126.103 I1.566 J-1.066 E.13493
G1 X136.625 Y126.106 E.00515
G3 X135.147 Y129.312 I-.114 J1.891 E.24409
G1 X135.1 Y129.258 E.00241
M204 S250
G1 X134.757 Y129.459 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3123
M204 S5000
G1 X134.624 Y129.287 E.00668
G3 X136.463 Y125.711 I1.887 J-1.291 E.15104
G1 X136.647 Y125.714 E.00564
G3 X134.864 Y129.583 I-.136 J2.282 E.27298
G1 X134.796 Y129.504 E.00319
; WIPE_START
G1 F12000
M204 S6000
G1 X134.624 Y129.287 E-.10532
G1 X134.401 Y128.89 E-.17319
G1 X134.267 Y128.456 E-.17243
G1 X134.221 Y128.004 E-.17279
G1 X134.256 Y127.647 E-.13627
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.827 Y127.941 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3123
M204 S6000
G1 X135.854 Y128.196 E.00788
G1 X135.975 Y128.427 E.00799
G1 X136.223 Y128.622 E.00971
G1 X136.48 Y128.686 E.00814
G1 X136.748 Y128.644 E.00833
G1 X136.979 Y128.502 E.00832
G1 X137.137 Y128.282 E.00835
G1 X137.196 Y128.028 E.00799
M73 P86 R1
G2 X136.813 Y127.385 I-.818 J.051 E.0239
G1 X136.554 Y127.315 E.00825
G1 X136.283 Y127.352 E.0084
G1 X136.08 Y127.465 E.00713
G1 X135.905 Y127.679 E.00849
G1 X135.844 Y127.884 E.00656
M204 S10000
G1 X136.263 Y127.982 F42000
; LINE_WIDTH: 0.524016
G1 F3123
M204 S6000
G1 X136.312 Y128.146 E.00673
G1 X136.499 Y128.249 E.00838
G1 X136.68 Y128.182 E.00756
G1 X136.759 Y128.012 E.00734
G2 X136.36 Y127.801 I-.258 J.005 E.02156
G1 X136.291 Y127.929 E.00572
; OBJECT_ID: 69
; WIPE_START
G1 F13095.115
G1 X136.36 Y127.801 E-.07588
G1 X136.527 Y127.752 E-.09011
G1 X136.66 Y127.808 E-.0755
G1 X136.748 Y127.941 E-.08283
G1 X136.759 Y128.012 E-.03751
G1 X136.68 Y128.182 E-.09743
G1 X136.499 Y128.249 E-.1003
G1 X136.312 Y128.146 E-.11118
G1 X136.263 Y127.982 E-.08927
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.705 Y135.594 Z2.8 F42000
G1 X135.697 Y135.707 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3123
M204 S6000
G1 X135.602 Y135.583 E.00516
G3 X136.483 Y133.917 I.908 J-.586 E.07598
G1 X136.579 Y133.918 E.00319
G3 X135.736 Y135.752 I-.069 J1.079 E.13893
M204 S10000
G1 X135.375 Y135.956 F42000
G1 F3123
M204 S6000
G1 X135.278 Y135.83 E.00528
G3 X136.476 Y133.509 I1.232 J-.833 E.10573
G1 X136.602 Y133.512 E.00417
G3 X135.441 Y136.031 I-.092 J1.485 E.19154
G1 X135.415 Y136.001 E.00134
M204 S10000
G1 X135.06 Y136.212 F42000
G1 F3123
M204 S6000
G1 X134.945 Y136.062 E.00626
G3 X136.47 Y133.102 I1.566 J-1.066 E.13493
G1 X136.625 Y133.105 E.00515
G3 X135.147 Y136.312 I-.114 J1.891 E.24409
G1 X135.1 Y136.257 E.00241
M204 S250
G1 X134.757 Y136.459 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3123
M204 S5000
G1 X134.624 Y136.287 E.00668
G3 X136.463 Y132.71 I1.887 J-1.291 E.15104
G1 X136.647 Y132.713 E.00564
G3 X134.864 Y136.582 I-.136 J2.282 E.27298
G1 X134.796 Y136.504 E.00319
; WIPE_START
G1 F12000
M204 S6000
G1 X134.624 Y136.287 E-.10532
G1 X134.401 Y135.889 E-.17319
G1 X134.267 Y135.456 E-.17243
G1 X134.221 Y135.003 E-.17279
G1 X134.256 Y134.646 E-.13627
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.827 Y134.94 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3123
M204 S6000
G1 X135.854 Y135.196 E.00788
G1 X135.975 Y135.426 E.00799
G1 X136.223 Y135.621 E.00971
G1 X136.48 Y135.685 E.00814
G1 X136.748 Y135.643 E.00833
G1 X136.979 Y135.502 E.00832
G1 X137.137 Y135.281 E.00835
G1 X137.196 Y135.027 E.00799
G2 X136.813 Y134.384 I-.818 J.051 E.0239
G1 X136.554 Y134.315 E.00825
G1 X136.283 Y134.352 E.0084
G1 X136.08 Y134.465 E.00713
G1 X135.905 Y134.678 E.00849
G1 X135.844 Y134.883 E.00656
M204 S10000
G1 X136.263 Y134.981 F42000
; LINE_WIDTH: 0.524016
G1 F3123
M204 S6000
G1 X136.312 Y135.145 E.00673
G1 X136.499 Y135.248 E.00838
G1 X136.68 Y135.181 E.00756
G1 X136.759 Y135.012 E.00734
G2 X136.36 Y134.8 I-.258 J.005 E.02156
G1 X136.291 Y134.928 E.00572
; OBJECT_ID: 102
; WIPE_START
G1 F13095.115
G1 X136.36 Y134.8 E-.07588
G1 X136.527 Y134.751 E-.09011
G1 X136.66 Y134.808 E-.0755
G1 X136.748 Y134.94 E-.08283
G1 X136.759 Y135.012 E-.03751
G1 X136.68 Y135.181 E-.09743
G1 X136.499 Y135.248 E-.1003
G1 X136.312 Y135.145 E-.11118
G1 X136.263 Y134.981 E-.08927
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.736 Y133.719 Z2.8 F42000
G1 X118.929 Y132.075 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3123
M204 S6000
G3 X119.519 Y131.919 I.561 J.926 E.02053
G1 X119.619 Y131.926 E.00333
G3 X118.878 Y132.107 I-.13 J1.075 E.1998
M204 S10000
G1 X118.709 Y131.732 F42000
G1 F3123
M204 S6000
G3 X119.533 Y131.512 I.782 J1.268 E.02873
G1 X119.666 Y131.521 E.00443
G3 X118.658 Y131.765 I-.176 J1.479 E.27536
M204 S10000
G1 X118.474 Y131.399 F42000
G1 F3123
M204 S6000
G1 X118.488 Y131.39 E.00056
G3 X119.548 Y131.104 I1.003 J1.61 E.03693
G1 X119.714 Y131.117 E.00552
G3 X118.19 Y131.62 I-.223 J1.884 E.34037
G1 X118.427 Y131.436 E.00997
M204 S250
G1 X118.236 Y131.089 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3123
M204 S5000
G1 X118.276 Y131.061 E.00153
G3 X119.562 Y130.712 I1.215 J1.94 E.04152
G1 X119.759 Y130.727 E.00608
G3 X117.917 Y131.339 I-.267 J2.273 E.38029
G1 X118.188 Y131.126 E.01061
; WIPE_START
G1 F12000
M204 S6000
G1 X118.276 Y131.061 E-.0417
G1 X118.684 Y130.857 E-.17309
G1 X119.122 Y130.74 E-.17245
G1 X119.562 Y130.712 E-.16727
G1 X119.759 Y130.727 E-.07522
G1 X120.095 Y130.796 E-.13027
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.443 Y132.315 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3123
M204 S6000
G1 X119.191 Y132.383 E.00802
G1 X118.975 Y132.547 E.00834
G1 X118.835 Y132.792 E.00867
G1 X118.805 Y133.061 E.00829
G1 X118.883 Y133.324 E.00842
G1 X119.03 Y133.512 E.00733
G1 X119.267 Y133.65 E.00843
G1 X119.525 Y133.686 E.00802
G1 X119.788 Y133.618 E.00835
G1 X120.004 Y133.454 E.00833
G1 X120.139 Y133.219 E.00832
G1 X120.173 Y132.95 E.00832
G1 X120.1 Y132.69 E.00828
G1 X119.923 Y132.47 E.00868
G1 X119.68 Y132.342 E.00844
G1 X119.503 Y132.322 E.00549
M204 S10000
G1 X119.551 Y132.76 F42000
; LINE_WIDTH: 0.52589
G1 F3123
M204 S6000
G1 X119.384 Y132.776 E.00662
G1 X119.253 Y132.928 E.00789
G1 X119.272 Y133.124 E.00773
G1 X119.41 Y133.236 E.00699
G1 X119.597 Y133.223 E.00736
G1 X119.723 Y133.079 E.00754
G2 X119.71 Y132.891 I-.351 J-.07 E.00751
G1 X119.598 Y132.798 E.00575
; CHANGE_LAYER
; Z_HEIGHT: 2.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13044.289
G1 X119.71 Y132.891 E-.07621
G1 X119.723 Y133.079 E-.09841
G1 X119.597 Y133.223 E-.10001
G1 X119.41 Y133.236 E-.09767
G1 X119.272 Y133.124 E-.09277
G1 X119.253 Y132.928 E-.10251
G1 X119.384 Y132.776 E-.10467
G1 X119.551 Y132.76 E-.08775
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 13/20
; update layer progress
M73 L13
M991 S0 P12 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z2.8 I.698 J.997 P1  F42000
G1 X135.571 Y121.536 Z2.8
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3124
M204 S6000
G3 X136.482 Y119.918 I.938 J-.537 E.07408
G1 X136.578 Y119.92 E.00319
G3 X135.602 Y121.587 I-.069 J1.079 E.14607
M204 S10000
G1 X135.216 Y121.738 F42000
G1 F3124
M204 S6000
G1 X135.118 Y121.526 E.00775
G3 X136.476 Y119.511 I1.391 J-.527 E.09428
G1 X136.601 Y119.513 E.00417
G3 X135.248 Y121.787 I-.092 J1.485 E.20198
M204 S10000
G1 X134.849 Y121.912 F42000
G1 F3124
M204 S6000
G1 X134.738 Y121.669 E.00886
G3 X136.469 Y119.104 I1.772 J-.671 E.12012
G1 X136.624 Y119.107 E.00515
G3 X134.88 Y121.963 I-.114 J1.891 E.25882
M204 S250
G1 X134.495 Y122.078 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3124
M204 S5000
G1 X134.372 Y121.806 E.00917
G3 X136.463 Y118.711 I2.139 J-.809 E.13431
G1 X136.647 Y118.715 E.00565
G3 X134.527 Y122.135 I-.136 J2.283 E.29034
G1 X134.525 Y122.131 E.00016
; WIPE_START
G1 F12000
M204 S6000
G1 X134.372 Y121.806 E-.13618
G1 X134.25 Y121.367 E-.17308
G1 X134.221 Y121.003 E-.13887
G1 X134.266 Y120.549 E-.17355
G1 X134.373 Y120.201 E-.13832
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 13 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3 F4000
            G39.3 S1
            G0 Z3 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer13 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.826 Y120.95 F42000
G1 Z2.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3124
M204 S6000
G1 X135.862 Y121.225 E.00852
G1 X135.993 Y121.451 E.00804
G1 X136.205 Y121.615 E.00823
G1 X136.467 Y121.685 E.00833
G1 X136.735 Y121.649 E.00832
G1 X136.969 Y121.511 E.00833
G1 X137.132 Y121.293 E.00838
G1 X137.195 Y121.061 E.00737
G1 X137.162 Y120.785 E.00855
G1 X137.029 Y120.552 E.00825
G1 X136.815 Y120.386 E.00832
G1 X136.553 Y120.316 E.00833
G1 X136.283 Y120.353 E.00839
G1 X136.08 Y120.466 E.00713
G1 X135.898 Y120.692 E.00892
G1 X135.842 Y120.892 E.00638
M204 S10000
G1 X136.264 Y120.981 F42000
; LINE_WIDTH: 0.5262
G1 F3124
M204 S6000
G1 X136.323 Y121.162 E.0075
G1 X136.495 Y121.248 E.00756
G1 X136.676 Y121.185 E.00755
G1 X136.758 Y121.029 E.00691
G2 X136.698 Y120.839 I-.382 J.016 E.00796
G1 X136.526 Y120.754 E.00755
G1 X136.362 Y120.801 E.00671
G1 X136.293 Y120.928 E.00572
; OBJECT_ID: 80
; WIPE_START
G1 F13035.921
G1 X136.362 Y120.801 E-.07575
G1 X136.526 Y120.754 E-.08888
G1 X136.698 Y120.839 E-.09998
G1 X136.758 Y121.029 E-.10424
G1 X136.676 Y121.185 E-.0916
G1 X136.495 Y121.248 E-.10001
G1 X136.323 Y121.162 E-.1001
G1 X136.264 Y120.981 E-.09943
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.655 Y128.589 Z3 F42000
G1 X135.65 Y128.651 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3124
M204 S6000
M73 P87 R1
G1 X135.609 Y128.599 E.00221
G3 X136.482 Y126.917 I.9 J-.6 E.07658
G1 X136.578 Y126.919 E.00319
G3 X135.728 Y128.748 I-.069 J1.08 E.13942
G1 X135.688 Y128.698 E.00212
M204 S10000
G1 X135.332 Y128.903 F42000
G1 F3124
M204 S6000
G1 X135.276 Y128.832 E.00301
G3 X136.476 Y126.51 I1.234 J-.833 E.10578
G1 X136.601 Y126.513 E.00416
G3 X135.438 Y129.032 I-.091 J1.486 E.19184
G1 X135.37 Y128.949 E.00354
M204 S10000
G1 X135.016 Y129.158 F42000
G1 F3124
M204 S6000
G1 X134.942 Y129.064 E.00394
G3 X136.469 Y126.103 I1.568 J-1.066 E.13498
G1 X136.624 Y126.106 E.00514
G3 X135.147 Y129.316 I-.114 J1.892 E.24425
G1 X135.054 Y129.204 E.00484
M204 S250
G1 X134.712 Y129.405 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3124
M204 S5000
G1 X134.621 Y129.288 E.00453
G3 X136.463 Y125.711 I1.889 J-1.29 E.15108
G1 X136.646 Y125.714 E.00564
G3 X134.867 Y129.59 I-.136 J2.284 E.27301
G1 X134.751 Y129.451 E.00558
; WIPE_START
G1 F12000
M204 S6000
G1 X134.621 Y129.288 E-.07882
G1 X134.402 Y128.892 E-.17212
G1 X134.267 Y128.457 E-.17328
G1 X134.221 Y128.005 E-.17236
G1 X134.263 Y127.577 E-.16342
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.827 Y127.939 Z3 F42000
G1 Z2.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3124
M204 S6000
G1 X135.852 Y128.19 E.00776
G1 X135.995 Y128.453 E.00921
G1 X136.211 Y128.617 E.00831
G1 X136.47 Y128.685 E.00825
G1 X136.739 Y128.647 E.00832
G1 X136.971 Y128.508 E.00832
G1 X137.132 Y128.291 E.00832
G1 X137.196 Y128.027 E.00832
G2 X136.813 Y127.384 I-.817 J.051 E.02388
G1 X136.553 Y127.315 E.00826
G1 X136.285 Y127.352 E.00833
G1 X136.053 Y127.488 E.00824
G1 X135.903 Y127.68 E.00748
G1 X135.844 Y127.881 E.00645
M204 S10000
G1 X136.263 Y127.98 F42000
; LINE_WIDTH: 0.5254
G1 F3124
M204 S6000
G1 X136.329 Y128.166 E.00777
G1 X136.496 Y128.247 E.00731
G1 X136.677 Y128.183 E.00754
G1 X136.758 Y128.01 E.00754
G1 X136.747 Y127.941 E.00273
G1 X136.658 Y127.807 E.00633
G1 X136.526 Y127.753 E.00559
G1 X136.341 Y127.817 E.0077
G1 X136.289 Y127.926 E.00475
; OBJECT_ID: 69
; WIPE_START
G1 F13057.537
G1 X136.341 Y127.817 E-.063
G1 X136.526 Y127.753 E-.10218
G1 X136.658 Y127.807 E-.0742
G1 X136.747 Y127.941 E-.08404
G1 X136.758 Y128.01 E-.03624
G1 X136.677 Y128.183 E-.10013
G1 X136.496 Y128.247 E-.10004
G1 X136.329 Y128.166 E-.09706
G1 X136.263 Y127.98 E-.10309
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.655 Y135.588 Z3 F42000
G1 X135.65 Y135.651 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3124
M204 S6000
G1 X135.609 Y135.598 E.00221
G3 X136.482 Y133.917 I.9 J-.6 E.07658
G1 X136.578 Y133.918 E.00319
G3 X135.728 Y135.747 I-.069 J1.08 E.13942
G1 X135.688 Y135.697 E.00212
M204 S10000
G1 X135.332 Y135.902 F42000
G1 F3124
M204 S6000
G1 X135.276 Y135.831 E.00301
G3 X136.476 Y133.509 I1.234 J-.833 E.10578
G1 X136.601 Y133.512 E.00416
G3 X135.438 Y136.031 I-.091 J1.486 E.19184
G1 X135.37 Y135.949 E.00354
M204 S10000
G1 X135.016 Y136.157 F42000
G1 F3124
M204 S6000
G1 X134.942 Y136.064 E.00394
G3 X136.469 Y133.102 I1.568 J-1.066 E.13498
G1 X136.624 Y133.105 E.00514
G3 X135.147 Y136.315 I-.114 J1.892 E.24425
G1 X135.054 Y136.203 E.00484
M204 S250
G1 X134.712 Y136.404 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3124
M204 S5000
G1 X134.621 Y136.288 E.00453
G3 X136.463 Y132.71 I1.889 J-1.29 E.15108
G1 X136.646 Y132.713 E.00564
G3 X134.867 Y136.589 I-.136 J2.284 E.27301
G1 X134.751 Y136.45 E.00558
; WIPE_START
G1 F12000
M204 S6000
G1 X134.621 Y136.288 E-.07882
G1 X134.402 Y135.891 E-.17212
G1 X134.267 Y135.456 E-.17328
G1 X134.221 Y135.005 E-.17236
G1 X134.263 Y134.577 E-.16342
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.827 Y134.938 Z3 F42000
G1 Z2.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3124
M204 S6000
G1 X135.852 Y135.189 E.00776
G1 X135.995 Y135.452 E.00921
G1 X136.211 Y135.616 E.00831
G1 X136.47 Y135.684 E.00825
G1 X136.739 Y135.646 E.00832
G1 X136.971 Y135.508 E.00832
G1 X137.132 Y135.29 E.00832
G1 X137.196 Y135.027 E.00832
G2 X136.813 Y134.384 I-.817 J.051 E.02388
G1 X136.553 Y134.315 E.00826
G1 X136.285 Y134.352 E.00833
G1 X136.053 Y134.487 E.00824
G1 X135.903 Y134.679 E.00748
G1 X135.844 Y134.88 E.00645
M204 S10000
G1 X136.263 Y134.979 F42000
; LINE_WIDTH: 0.5254
G1 F3124
M204 S6000
G1 X136.329 Y135.165 E.00777
G1 X136.496 Y135.246 E.00731
G1 X136.677 Y135.183 E.00754
G1 X136.758 Y135.009 E.00754
G1 X136.747 Y134.94 E.00273
G1 X136.658 Y134.806 E.00633
G1 X136.526 Y134.752 E.00559
G1 X136.341 Y134.816 E.0077
G1 X136.289 Y134.925 E.00475
; OBJECT_ID: 102
; WIPE_START
G1 F13057.537
G1 X136.341 Y134.816 E-.063
G1 X136.526 Y134.752 E-.10218
G1 X136.658 Y134.806 E-.0742
G1 X136.747 Y134.94 E-.08404
G1 X136.758 Y135.009 E-.03624
G1 X136.677 Y135.183 E-.10013
G1 X136.496 Y135.246 E-.10004
G1 X136.329 Y135.165 E-.09706
G1 X136.263 Y134.979 E-.10309
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.736 Y133.712 Z3 F42000
G1 X118.956 Y132.064 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3124
M204 S6000
G3 X119.526 Y131.918 I.543 J.937 E.01978
G1 X119.58 Y131.921 E.00177
G3 X118.905 Y132.096 I-.081 J1.08 E.20216
M204 S10000
G1 X118.753 Y131.711 F42000
G1 F3124
M204 S6000
G3 X119.536 Y131.511 I.746 J1.29 E.02714
G1 X119.61 Y131.515 E.00246
G3 X118.701 Y131.742 I-.112 J1.486 E.27892
M204 S10000
G1 X118.55 Y131.358 F42000
G1 F3124
M204 S6000
G3 X119.545 Y131.104 I.948 J1.643 E.03449
G1 X119.64 Y131.109 E.00316
G3 X118.498 Y131.388 I-.142 J1.891 E.35569
M204 S250
G1 X118.332 Y131.027 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3124
M204 S5000
G1 X118.354 Y131.017 E.00074
G3 X119.554 Y130.712 I1.143 J1.983 E.03851
G1 X119.669 Y130.718 E.00354
G3 X117.985 Y131.282 I-.172 J2.282 E.38582
G1 X118.284 Y131.063 E.01139
; WIPE_START
G1 F12000
M204 S6000
G1 X118.354 Y131.017 E-.03186
G1 X118.768 Y130.827 E-.17303
G1 X119.12 Y130.741 E-.13762
G1 X119.554 Y130.712 E-.16526
G1 X119.669 Y130.718 E-.04378
G1 X120.027 Y130.775 E-.13795
G1 X120.202 Y130.836 E-.0705
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.549 Y132.322 Z3 F42000
G1 Z2.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3124
M204 S6000
G2 X119.147 Y132.406 I.126 J1.6 E.01264
G1 X118.944 Y132.584 E.00829
G1 X118.826 Y132.823 E.00818
G1 X118.809 Y133.092 E.00831
G1 X118.963 Y133.434 E.01154
G2 X119.297 Y133.658 I.981 J-1.101 E.01237
G1 X119.617 Y133.675 E.00985
G1 X119.825 Y133.6 E.0068
G1 X120.031 Y133.42 E.00841
G1 X120.152 Y133.178 E.00832
G1 X120.168 Y132.907 E.00833
G1 X120.08 Y132.652 E.00829
G1 X119.901 Y132.453 E.00823
G1 X119.605 Y132.343 E.00971
M204 S10000
G1 X119.527 Y132.75 F42000
; LINE_WIDTH: 0.52218
G1 F3124
M204 S6000
G1 X119.323 Y132.821 E.00842
G1 X119.248 Y132.935 E.00534
G1 X119.284 Y133.15 E.0085
G1 X119.418 Y133.236 E.00623
G1 X119.604 Y133.224 E.00727
G1 X119.73 Y133.065 E.00792
G2 X119.703 Y132.874 I-.363 J-.048 E.00763
G1 X119.576 Y132.784 E.00608
; CHANGE_LAYER
; Z_HEIGHT: 2.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13145.265
G1 X119.703 Y132.874 E-.08064
G1 X119.73 Y133.065 E-.10001
G1 X119.604 Y133.224 E-.10505
G1 X119.418 Y133.236 E-.09648
G1 X119.284 Y133.15 E-.08262
G1 X119.248 Y132.935 E-.1127
G1 X119.323 Y132.821 E-.0708
G1 X119.527 Y132.75 E-.11172
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 14/20
; update layer progress
M73 L14
M991 S0 P13 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z3 I.7 J.995 P1  F42000
G1 X135.543 Y121.477 Z3
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3115
M204 S6000
G1 X135.48 Y121.339 E.00502
G3 X136.481 Y119.918 I1.028 J-.339 E.06691
G1 X136.577 Y119.92 E.00321
G3 X135.568 Y121.536 I-.069 J1.08 E.1483
G1 X135.566 Y121.532 E.00014
M204 S10000
G1 X135.172 Y121.64 F42000
G1 F3115
M204 S6000
G1 X135.095 Y121.468 E.00626
G3 X136.475 Y119.511 I1.414 J-.468 E.09226
G1 X136.601 Y119.513 E.00418
G3 X135.216 Y121.739 I-.092 J1.487 E.20417
G1 X135.196 Y121.695 E.00159
M204 S10000
G1 X134.802 Y121.804 F42000
G1 F3115
M204 S6000
G1 X134.709 Y121.597 E.00753
G3 X136.468 Y119.104 I1.8 J-.597 E.1176
G1 X136.624 Y119.107 E.00516
G3 X134.863 Y121.941 I-.114 J1.893 E.26004
G1 X134.826 Y121.859 E.00299
M204 S250
G1 X134.445 Y121.963 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3115
M204 S5000
G1 X134.338 Y121.721 E.00814
G3 X136.463 Y118.711 I2.172 J-.721 E.13154
G1 X136.646 Y118.715 E.00565
G3 X134.524 Y122.136 I-.136 J2.285 E.29072
G1 X134.47 Y122.018 E.004
; WIPE_START
G1 F12000
M204 S6000
G1 X134.338 Y121.721 E-.1235
G1 X134.251 Y121.37 E-.13753
G1 X134.222 Y120.946 E-.16136
G1 X134.266 Y120.549 E-.15182
G1 X134.365 Y120.201 E-.13759
G1 X134.421 Y120.087 E-.04821
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 14 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.2
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.2 F4000
            G39.3 S1
            G0 Z3.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer14 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.826 Y120.939 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3115
M204 S6000
G1 X135.86 Y121.217 E.00857
M73 P88 R1
G1 X135.993 Y121.451 E.00829
G1 X136.205 Y121.615 E.00822
G1 X136.468 Y121.686 E.00839
G1 X136.706 Y121.659 E.00735
G1 X136.947 Y121.531 E.0084
G1 X137.119 Y121.318 E.00841
G1 X137.195 Y121.058 E.0083
G1 X137.162 Y120.785 E.00845
G1 X137.029 Y120.551 E.00826
G1 X136.815 Y120.386 E.00833
G1 X136.553 Y120.316 E.00832
G1 X136.284 Y120.353 E.00834
G1 X136.054 Y120.489 E.00822
G1 X135.89 Y120.708 E.00841
G1 X135.842 Y120.882 E.00553
M204 S10000
G1 X136.264 Y120.972 F42000
; LINE_WIDTH: 0.52646
G1 F3115
M204 S6000
G1 X136.325 Y121.164 E.00793
G1 X136.501 Y121.249 E.00773
G1 X136.668 Y121.192 E.00693
G1 X136.757 Y121.022 E.00755
G2 X136.526 Y120.754 I-.279 J.007 E.0151
G1 X136.347 Y120.816 E.00748
G1 X136.292 Y120.919 E.00459
; OBJECT_ID: 80
; WIPE_START
G1 F13028.912
G1 X136.347 Y120.816 E-.06083
G1 X136.526 Y120.754 E-.09909
G1 X136.698 Y120.839 E-.09991
G1 X136.757 Y121.022 E-.10063
G1 X136.668 Y121.192 E-.1001
G1 X136.501 Y121.249 E-.09186
G1 X136.325 Y121.164 E-.10243
G1 X136.264 Y120.972 E-.10514
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.614 Y128.576 Z3.2 F42000
G1 X135.612 Y128.601 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3115
M204 S6000
G1 X135.599 Y128.584 E.00072
G3 X136.481 Y126.917 I.91 J-.585 E.07596
G1 X136.577 Y126.919 E.0032
G3 X135.733 Y128.753 I-.069 J1.08 E.1391
G1 X135.649 Y128.648 E.00447
M204 S10000
G1 X135.296 Y128.854 F42000
G1 F3115
M204 S6000
G1 X135.253 Y128.797 E.00239
G3 X136.475 Y126.51 I1.256 J-.798 E.10437
G1 X136.601 Y126.513 E.00418
G3 X135.444 Y129.038 I-.091 J1.486 E.19148
G1 X135.334 Y128.901 E.00581
M204 S10000
G1 X134.979 Y129.105 F42000
G1 F3115
M204 S6000
G1 X134.907 Y129.009 E.00399
G3 X136.468 Y126.103 I1.603 J-1.012 E.13278
G1 X136.624 Y126.106 E.00516
G3 X135.154 Y129.322 I-.114 J1.892 E.24387
G1 X135.017 Y129.152 E.00724
M204 S250
G1 X134.666 Y129.351 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3115
M204 S5000
G1 X134.574 Y129.214 E.00506
G3 X136.462 Y125.711 I1.937 J-1.217 E.14835
G1 X136.646 Y125.714 E.00564
G3 X134.733 Y129.437 I-.136 J2.283 E.27917
G1 X134.703 Y129.398 E.00151
; WIPE_START
G1 F12000
M204 S6000
G1 X134.574 Y129.214 E-.08532
G1 X134.368 Y128.806 E-.17376
G1 X134.267 Y128.458 E-.1376
G1 X134.221 Y128.001 E-.17461
G1 X134.249 Y127.641 E-.1375
G1 X134.284 Y127.51 E-.05122
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.825 Y127.982 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3115
M204 S6000
G1 X135.869 Y128.242 E.00811
G1 X135.989 Y128.447 E.0073
G1 X136.21 Y128.616 E.00856
G1 X136.47 Y128.685 E.00826
G1 X136.738 Y128.647 E.00832
G1 X136.97 Y128.509 E.00831
G1 X137.136 Y128.283 E.0086
G1 X137.197 Y128.022 E.00824
G2 X136.813 Y127.384 I-.818 J.058 E.02375
G1 X136.553 Y127.315 E.00826
G1 X136.284 Y127.352 E.00833
G1 X136.054 Y127.488 E.00822
G1 X135.891 Y127.705 E.00835
G1 X135.839 Y127.923 E.00689
M204 S10000
G1 X136.263 Y127.997 F42000
; LINE_WIDTH: 0.52594
G1 F3115
M204 S6000
G1 X136.317 Y128.157 E.00663
G1 X136.496 Y128.247 E.00788
G1 X136.675 Y128.184 E.00748
G1 X136.759 Y128.007 E.00773
G1 X136.749 Y127.946 E.00242
G1 X136.662 Y127.81 E.00634
G1 X136.526 Y127.753 E.00579
G1 X136.347 Y127.815 E.00747
G1 X136.288 Y127.942 E.00553
; OBJECT_ID: 69
; WIPE_START
G1 F13042.939
G1 X136.347 Y127.815 E-.07333
G1 X136.526 Y127.753 E-.09917
G1 X136.662 Y127.81 E-.07686
G1 X136.749 Y127.946 E-.0842
G1 X136.759 Y128.007 E-.03215
G1 X136.675 Y128.184 E-.10253
G1 X136.496 Y128.247 E-.0992
G1 X136.317 Y128.157 E-.10459
G1 X136.263 Y127.997 E-.08796
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.612 Y135.6 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3115
M204 S6000
G1 X135.599 Y135.583 E.00072
G3 X136.481 Y133.917 I.91 J-.585 E.07596
G1 X136.577 Y133.918 E.0032
G3 X135.733 Y135.752 I-.069 J1.08 E.1391
G1 X135.649 Y135.647 E.00447
M204 S10000
G1 X135.296 Y135.853 F42000
G1 F3115
M204 S6000
G1 X135.253 Y135.796 E.00239
G3 X136.475 Y133.509 I1.256 J-.798 E.10437
G1 X136.601 Y133.512 E.00418
G3 X135.444 Y136.037 I-.091 J1.486 E.19148
G1 X135.334 Y135.9 E.00581
M204 S10000
G1 X134.979 Y136.105 F42000
G1 F3115
M204 S6000
G1 X134.907 Y136.008 E.00399
G3 X136.468 Y133.102 I1.603 J-1.012 E.13278
G1 X136.624 Y133.105 E.00516
G3 X135.154 Y136.321 I-.114 J1.892 E.24387
G1 X135.017 Y136.151 E.00724
M204 S250
G1 X134.666 Y136.35 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3115
M204 S5000
G1 X134.574 Y136.214 E.00506
G3 X136.462 Y132.71 I1.937 J-1.217 E.14835
G1 X136.646 Y132.713 E.00564
G3 X134.733 Y136.436 I-.136 J2.283 E.27917
G1 X134.703 Y136.397 E.00151
; WIPE_START
G1 F12000
M204 S6000
G1 X134.574 Y136.214 E-.08532
G1 X134.368 Y135.806 E-.17376
G1 X134.267 Y135.458 E-.1376
G1 X134.221 Y135 E-.17461
G1 X134.249 Y134.64 E-.1375
G1 X134.284 Y134.509 E-.05122
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.825 Y134.981 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3115
M204 S6000
G1 X135.869 Y135.241 E.00811
G1 X135.989 Y135.446 E.0073
G1 X136.21 Y135.615 E.00856
G1 X136.47 Y135.684 E.00826
G1 X136.738 Y135.646 E.00832
G1 X136.97 Y135.508 E.00831
G1 X137.136 Y135.283 E.0086
G1 X137.197 Y135.021 E.00824
G2 X136.813 Y134.383 I-.818 J.058 E.02375
G1 X136.553 Y134.315 E.00826
G1 X136.284 Y134.352 E.00833
G1 X136.054 Y134.487 E.00822
G1 X135.891 Y134.705 E.00835
G1 X135.839 Y134.923 E.00689
M204 S10000
G1 X136.263 Y134.996 F42000
; LINE_WIDTH: 0.52594
G1 F3115
M204 S6000
G1 X136.317 Y135.156 E.00663
G1 X136.496 Y135.246 E.00788
G1 X136.675 Y135.183 E.00748
G1 X136.759 Y135.006 E.00773
G1 X136.749 Y134.945 E.00242
G1 X136.662 Y134.81 E.00634
G1 X136.526 Y134.752 E.00579
G1 X136.347 Y134.814 E.00747
G1 X136.288 Y134.942 E.00553
; OBJECT_ID: 102
; WIPE_START
G1 F13042.939
G1 X136.347 Y134.814 E-.07333
G1 X136.526 Y134.752 E-.09917
G1 X136.662 Y134.81 E-.07686
G1 X136.749 Y134.945 E-.0842
G1 X136.759 Y135.006 E-.03215
G1 X136.675 Y135.183 E-.10253
G1 X136.496 Y135.246 E-.0992
G1 X136.317 Y135.156 E-.10459
G1 X136.263 Y134.996 E-.08796
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.738 Y133.721 Z3.2 F42000
G1 X118.957 Y132.063 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3115
M204 S6000
G3 X119.519 Y131.918 I.541 J.938 E.01949
G1 X119.581 Y131.921 E.00208
G3 X118.905 Y132.095 I-.083 J1.08 E.20215
M204 S10000
G1 X118.757 Y131.703 F42000
G1 F3115
M204 S6000
G1 X119.023 Y131.589 E.00961
G3 X119.527 Y131.511 I.475 J1.412 E.017
G1 X119.611 Y131.515 E.00278
G3 X118.709 Y131.737 I-.113 J1.486 E.27918
M204 S10000
G1 X118.593 Y131.333 F42000
G1 F3115
M204 S6000
G1 X118.894 Y131.202 E.01089
G3 X119.536 Y131.104 I.603 J1.798 E.02164
G1 X119.641 Y131.109 E.00349
G3 X118.541 Y131.363 I-.143 J1.891 E.35731
M204 S250
G1 X118.434 Y130.976 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3115
M204 S5000
G1 X118.77 Y130.83 E.01125
G3 X119.544 Y130.712 I.728 J2.17 E.02418
G1 X119.669 Y130.718 E.00386
G3 X118.355 Y131.017 I-.172 J2.282 E.39983
G1 X118.38 Y131.004 E.00088
; WIPE_START
G1 F12000
M204 S6000
G1 X118.77 Y130.83 E-.16188
G1 X119.12 Y130.741 E-.13746
G1 X119.544 Y130.712 E-.16136
G1 X119.669 Y130.718 E-.04773
G1 X120.027 Y130.775 E-.13771
G1 X120.31 Y130.874 E-.11385
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.548 Y132.322 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3115
M204 S6000
G2 X119.148 Y132.406 I.126 J1.597 E.01258
G1 X118.945 Y132.583 E.00829
G1 X118.826 Y132.822 E.00819
G1 X118.809 Y133.096 E.00844
G2 X119.296 Y133.658 I.725 J-.136 E.02395
G1 X119.617 Y133.675 E.00987
G1 X119.825 Y133.6 E.00679
G1 X120.032 Y133.42 E.00842
G1 X120.152 Y133.177 E.00832
G1 X120.168 Y132.907 E.00832
G1 X120.079 Y132.652 E.0083
G1 X119.9 Y132.452 E.00825
M73 P89 R1
G1 X119.604 Y132.343 E.0097
M204 S10000
G1 X119.526 Y132.75 F42000
; LINE_WIDTH: 0.52225
G1 F3115
M204 S6000
G1 X119.324 Y132.821 E.00838
G1 X119.248 Y132.935 E.00534
G1 X119.268 Y133.122 E.00733
G1 X119.418 Y133.236 E.00736
G1 X119.604 Y133.224 E.00728
G1 X119.73 Y133.065 E.00793
G2 X119.703 Y132.874 I-.363 J-.048 E.00763
G1 X119.575 Y132.784 E.0061
; CHANGE_LAYER
; Z_HEIGHT: 3
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13143.346
G1 X119.703 Y132.874 E-.0809
G1 X119.73 Y133.065 E-.10003
G1 X119.604 Y133.224 E-.10522
G1 X119.418 Y133.236 E-.09668
G1 X119.268 Y133.122 E-.09773
G1 X119.248 Y132.935 E-.09732
G1 X119.324 Y132.821 E-.07087
G1 X119.526 Y132.75 E-.11125
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 15/20
; update layer progress
M73 L15
M991 S0 P14 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z3.2 I.706 J.991 P1  F42000
G1 X135.495 Y121.383 Z3.2
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3112
M204 S6000
G3 X136.48 Y119.918 I1.012 J-.383 E.06846
G1 X136.577 Y119.92 E.00321
G3 X135.518 Y121.438 I-.069 J1.08 E.15192
M204 S10000
G1 X135.116 Y121.526 F42000
G1 F3112
M204 S6000
G1 X135.115 Y121.526 E.00003
G3 X136.474 Y119.511 I1.394 J-.526 E.09431
G1 X136.6 Y119.513 E.00419
G3 X135.215 Y121.738 I-.092 J1.487 E.20419
G1 X135.141 Y121.58 E.00577
M204 S10000
G1 X134.749 Y121.699 F42000
G1 F3112
M204 S6000
G1 X134.735 Y121.669 E.0011
G3 X136.468 Y119.104 I1.775 J-.669 E.12015
G1 X136.623 Y119.107 E.00516
G3 X134.862 Y121.941 I-.114 J1.893 E.26006
G1 X134.774 Y121.753 E.00687
M204 S250
G1 X134.395 Y121.866 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3112
M204 S5000
G1 X134.368 Y121.807 E.00198
G3 X136.462 Y118.711 I2.142 J-.807 E.13435
G1 X136.646 Y118.715 E.00565
G3 X134.523 Y122.136 I-.136 J2.285 E.29075
G1 X134.421 Y121.92 E.00735
; WIPE_START
G1 F12000
M204 S6000
G1 X134.368 Y121.807 E-.04733
G1 X134.25 Y121.367 E-.17299
G1 X134.221 Y121.003 E-.13896
G1 X134.257 Y120.598 E-.15428
G1 X134.308 Y120.375 E-.08715
G1 X134.4 Y120.114 E-.105
G1 X134.468 Y119.988 E-.0543
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 15 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.4
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.4 F4000
            G39.3 S1
            G0 Z3.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer15 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.825 Y120.986 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3112
M204 S6000
G1 X135.869 Y121.246 E.00808
G1 X135.991 Y121.449 E.00728
G1 X136.204 Y121.615 E.0083
G1 X136.466 Y121.685 E.00833
G1 X136.734 Y121.649 E.00833
G1 X136.968 Y121.513 E.00831
G1 X137.138 Y121.282 E.0088
G1 X137.196 Y121.059 E.00709
G1 X137.162 Y120.785 E.00847
G1 X137.029 Y120.551 E.00826
G1 X136.814 Y120.386 E.00833
G1 X136.553 Y120.316 E.00832
G1 X136.286 Y120.353 E.00827
G1 X136.037 Y120.505 E.00895
G1 X135.889 Y120.709 E.00773
G1 X135.838 Y120.928 E.00692
M204 S10000
G1 X136.263 Y121 F42000
; LINE_WIDTH: 0.52548
G1 F3112
M204 S6000
G1 X136.318 Y121.159 E.00662
G1 X136.495 Y121.248 E.00779
G1 X136.674 Y121.187 E.00746
G1 X136.759 Y121.03 E.007
G2 X136.698 Y120.839 I-.385 J.017 E.00799
G1 X136.526 Y120.754 E.00755
G1 X136.334 Y120.827 E.00806
G1 X136.286 Y120.944 E.005
; OBJECT_ID: 80
; WIPE_START
G1 F13055.372
G1 X136.334 Y120.827 E-.0662
G1 X136.526 Y120.754 E-.10676
G1 X136.698 Y120.839 E-.09998
G1 X136.759 Y121.03 E-.10468
G1 X136.674 Y121.187 E-.09273
G1 X136.495 Y121.248 E-.09883
G1 X136.318 Y121.159 E-.10318
G1 X136.263 Y121 E-.08765
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.598 Y128.583 Z3.4 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3112
M204 S6000
G3 X136.48 Y126.917 I.91 J-.584 E.07591
G1 X136.577 Y126.919 E.00321
G3 X135.632 Y128.632 I-.069 J1.079 E.14429
M204 S10000
G1 X135.253 Y128.799 F42000
G1 F3112
M204 S6000
G1 X135.252 Y128.796 E.00011
G3 X136.474 Y126.51 I1.256 J-.798 E.10432
G1 X136.6 Y126.512 E.00419
G3 X135.449 Y129.043 I-.091 J1.485 E.19116
G1 X135.29 Y128.846 E.00841
M204 S10000
G1 X134.937 Y129.051 F42000
G1 F3112
M204 S6000
G1 X134.907 Y129.009 E.00172
G3 X136.468 Y126.103 I1.603 J-1.011 E.13275
G1 X136.623 Y126.106 E.00516
G3 X135.16 Y129.328 I-.114 J1.892 E.24352
G1 X134.974 Y129.098 E.00981
M204 S250
G1 X134.627 Y129.295 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3112
M204 S5000
G1 X134.574 Y129.214 E.00299
G3 X136.462 Y125.711 I1.936 J-1.217 E.14832
G1 X136.646 Y125.714 E.00565
G3 X134.733 Y129.437 I-.136 J2.283 E.27914
G1 X134.663 Y129.343 E.00359
; WIPE_START
G1 F12000
M204 S6000
G1 X134.574 Y129.214 E-.05969
G1 X134.368 Y128.806 E-.17371
G1 X134.25 Y128.366 E-.17299
G1 X134.221 Y128.005 E-.13782
G1 X134.266 Y127.548 E-.17426
G1 X134.296 Y127.443 E-.04154
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.825 Y127.963 Z3.4 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3112
M204 S6000
G1 X135.854 Y128.199 E.0073
G1 X135.992 Y128.45 E.0088
G1 X136.209 Y128.616 E.00838
G1 X136.469 Y128.685 E.00827
G1 X136.737 Y128.648 E.00831
G1 X136.97 Y128.51 E.00832
G1 X137.132 Y128.292 E.00833
G1 X137.196 Y128.029 E.00831
G2 X136.812 Y127.384 I-.817 J.049 E.02396
G1 X136.553 Y127.315 E.00826
G1 X136.284 Y127.353 E.00834
G1 X136.053 Y127.489 E.00824
G1 X135.89 Y127.707 E.00836
G1 X135.84 Y127.905 E.00628
M204 S10000
G1 X136.262 Y127.991 F42000
; LINE_WIDTH: 0.52613
G1 F3112
M204 S6000
G1 X136.326 Y128.163 E.00722
G1 X136.496 Y128.247 E.00746
G1 X136.676 Y128.184 E.00754
G1 X136.758 Y128.011 E.00752
G1 X136.747 Y127.94 E.00281
G1 X136.657 Y127.807 E.00632
G1 X136.526 Y127.753 E.00558
G1 X136.346 Y127.815 E.0075
G1 X136.288 Y127.937 E.00531
; OBJECT_ID: 69
; WIPE_START
G1 F13037.809
G1 X136.346 Y127.815 E-.07049
G1 X136.526 Y127.753 E-.09954
G1 X136.657 Y127.807 E-.074
G1 X136.747 Y127.94 E-.08394
G1 X136.758 Y128.011 E-.03729
G1 X136.676 Y128.184 E-.09979
G1 X136.496 Y128.247 E-.10002
G1 X136.326 Y128.163 E-.09903
G1 X136.262 Y127.991 E-.09589
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.598 Y135.582 Z3.4 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3112
M204 S6000
G3 X136.48 Y133.917 I.91 J-.584 E.07591
G1 X136.577 Y133.918 E.00321
G3 X135.632 Y135.632 I-.069 J1.079 E.14429
M204 S10000
G1 X135.253 Y135.798 F42000
G1 F3112
M204 S6000
G1 X135.252 Y135.795 E.00011
M73 P90 R1
G3 X136.474 Y133.509 I1.256 J-.798 E.10432
G1 X136.6 Y133.512 E.00419
G3 X135.449 Y136.043 I-.091 J1.485 E.19116
G1 X135.29 Y135.845 E.00841
M204 S10000
G1 X134.937 Y136.05 F42000
G1 F3112
M204 S6000
G1 X134.907 Y136.008 E.00172
G3 X136.468 Y133.102 I1.603 J-1.011 E.13275
G1 X136.623 Y133.105 E.00516
G3 X135.16 Y136.327 I-.114 J1.892 E.24352
G1 X134.974 Y136.097 E.00981
M204 S250
G1 X134.627 Y136.294 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3112
M204 S5000
G1 X134.574 Y136.213 E.00299
G3 X136.462 Y132.71 I1.936 J-1.217 E.14832
G1 X136.646 Y132.713 E.00565
G3 X134.733 Y136.436 I-.136 J2.283 E.27914
G1 X134.663 Y136.342 E.00359
; WIPE_START
G1 F12000
M204 S6000
G1 X134.574 Y136.213 E-.05969
G1 X134.368 Y135.805 E-.17371
G1 X134.25 Y135.365 E-.17299
G1 X134.221 Y135.004 E-.13782
G1 X134.266 Y134.547 E-.17426
G1 X134.296 Y134.442 E-.04154
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.825 Y134.963 Z3.4 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3112
M204 S6000
G1 X135.854 Y135.198 E.0073
G1 X135.992 Y135.449 E.0088
G1 X136.209 Y135.615 E.00838
G1 X136.469 Y135.684 E.00827
G1 X136.737 Y135.647 E.00831
G1 X136.97 Y135.509 E.00832
G1 X137.132 Y135.291 E.00833
G1 X137.196 Y135.028 E.00831
G2 X136.812 Y134.383 I-.817 J.049 E.02396
G1 X136.553 Y134.315 E.00826
G1 X136.284 Y134.352 E.00834
G1 X136.053 Y134.488 E.00824
G1 X135.89 Y134.706 E.00836
G1 X135.84 Y134.904 E.00628
M204 S10000
G1 X136.262 Y134.99 F42000
; LINE_WIDTH: 0.52613
G1 F3112
M204 S6000
G1 X136.326 Y135.162 E.00722
G1 X136.496 Y135.246 E.00746
G1 X136.676 Y135.183 E.00754
G1 X136.758 Y135.01 E.00752
G1 X136.747 Y134.94 E.00281
G1 X136.657 Y134.806 E.00632
G1 X136.526 Y134.752 E.00558
G1 X136.346 Y134.815 E.0075
G1 X136.288 Y134.936 E.00531
; OBJECT_ID: 102
; WIPE_START
G1 F13037.809
G1 X136.346 Y134.815 E-.07049
G1 X136.526 Y134.752 E-.09954
G1 X136.657 Y134.806 E-.074
G1 X136.747 Y134.94 E-.08394
G1 X136.758 Y135.01 E-.03729
G1 X136.676 Y135.183 E-.09979
G1 X136.496 Y135.246 E-.10002
G1 X136.326 Y135.162 E-.09903
G1 X136.262 Y134.99 E-.09589
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.739 Y133.703 Z3.4 F42000
G1 X119.005 Y132.036 Z3.4
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3112
M204 S6000
G1 X119.153 Y131.974 E.00532
G3 X119.511 Y131.918 I.344 J1.027 E.01205
G1 X119.583 Y131.921 E.0024
G3 X118.953 Y132.065 I-.085 J1.08 E.20393
M204 S10000
G1 X118.843 Y131.665 F42000
G1 F3112
M204 S6000
G1 X119.024 Y131.588 E.00651
G3 X119.518 Y131.511 I.474 J1.412 E.01668
G1 X119.612 Y131.515 E.00311
G3 X118.754 Y131.71 I-.114 J1.485 E.28091
G1 X118.79 Y131.692 E.00131
M204 S10000
G1 X118.679 Y131.294 F42000
G1 F3112
M204 S6000
G1 X118.895 Y131.202 E.00777
G3 X119.526 Y131.104 I.603 J1.798 E.02131
G1 X119.641 Y131.109 E.00382
G3 X118.551 Y131.357 I-.144 J1.891 E.3577
G1 X118.625 Y131.321 E.00273
M204 S250
G1 X118.521 Y130.938 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3112
M204 S5000
G1 X118.77 Y130.83 E.00835
G3 X119.534 Y130.712 I.728 J2.17 E.02386
G1 X119.669 Y130.718 E.00417
G3 X118.356 Y131.017 I-.172 J2.282 E.39985
G1 X118.466 Y130.964 E.00378
; WIPE_START
G1 F12000
M204 S6000
G1 X118.77 Y130.83 E-.12601
G1 X119.12 Y130.741 E-.13745
G1 X119.534 Y130.712 E-.15743
G1 X119.669 Y130.718 E-.05162
G1 X120.026 Y130.775 E-.13736
G1 X120.399 Y130.905 E-.15012
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.547 Y132.322 Z3.4 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3112
M204 S6000
G2 X119.149 Y132.405 I.13 J1.609 E.01254
G1 X118.945 Y132.582 E.00828
G1 X118.827 Y132.821 E.0082
G1 X118.809 Y133.095 E.00844
G2 X119.295 Y133.658 I.724 J-.134 E.02396
G1 X119.617 Y133.675 E.00989
G1 X119.825 Y133.599 E.00681
G1 X120.032 Y133.42 E.00842
G1 X120.152 Y133.177 E.00831
G1 X120.168 Y132.906 E.00833
G1 X120.079 Y132.651 E.0083
G1 X119.899 Y132.451 E.00827
G1 X119.603 Y132.343 E.00969
M204 S10000
G1 X119.525 Y132.75 F42000
; LINE_WIDTH: 0.52225
G1 F3112
M204 S6000
G1 X119.324 Y132.82 E.00834
G1 X119.248 Y132.935 E.00535
G1 X119.268 Y133.123 E.00741
G1 X119.417 Y133.236 E.00728
G1 X119.604 Y133.224 E.00731
G1 X119.73 Y133.065 E.00792
G2 X119.703 Y132.874 I-.362 J-.048 E.00763
G1 X119.575 Y132.784 E.00612
; CHANGE_LAYER
; Z_HEIGHT: 3.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13143.346
G1 X119.703 Y132.874 E-.08127
G1 X119.73 Y133.065 E-.10002
G1 X119.604 Y133.224 E-.10504
G1 X119.417 Y133.236 E-.09704
G1 X119.268 Y133.123 E-.09659
G1 X119.248 Y132.935 E-.09833
G1 X119.324 Y132.82 E-.07101
G1 X119.525 Y132.75 E-.11069
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 16/20
; update layer progress
M73 L16
M991 S0 P15 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z3.4 I.708 J.99 P1  F42000
G1 X135.478 Y121.337 Z3.4
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3134
M204 S6000
G3 X136.478 Y119.918 I1.029 J-.337 E.0668
G1 X136.576 Y119.92 E.00325
G3 X135.499 Y121.393 I-.069 J1.08 E.15356
M204 S10000
G1 X135.093 Y121.466 F42000
G1 F3134
M204 S6000
G3 X136.473 Y119.511 I1.415 J-.466 E.09216
G1 X136.6 Y119.513 E.00421
G3 X135.113 Y121.523 I-.091 J1.487 E.2121
M204 S10000
G1 X134.708 Y121.595 F42000
G1 F3134
M204 S6000
G3 X136.467 Y119.104 I1.801 J-.595 E.11753
G1 X136.623 Y119.107 E.00517
G3 X134.728 Y121.652 I-.114 J1.893 E.27064
M204 S250
G1 X134.351 Y121.752 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3134
M204 S5000
G1 X134.338 Y121.72 E.00107
G3 X136.462 Y118.711 I2.173 J-.72 E.1315
G1 X136.646 Y118.715 E.00565
G3 X134.523 Y122.135 I-.135 J2.285 E.29076
M73 P90 R0
G1 X134.376 Y121.807 E.01107
; WIPE_START
G1 F12000
M204 S6000
G1 X134.338 Y121.72 E-.03602
G1 X134.251 Y121.369 E-.13739
G1 X134.222 Y120.966 E-.15364
G1 X134.266 Y120.549 E-.15927
G1 X134.365 Y120.202 E-.13727
G1 X134.523 Y119.879 E-.1364
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 16 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.6
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.6 F4000
            G39.3 S1
            G0 Z3.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer16 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.827 Y120.937 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3134
M204 S6000
G1 X135.859 Y121.215 E.00858
G1 X135.992 Y121.45 E.00828
G1 X136.205 Y121.615 E.0083
G1 X136.469 Y121.686 E.00839
G1 X136.711 Y121.658 E.0075
G1 X136.946 Y121.532 E.00819
G1 X137.119 Y121.319 E.00842
G1 X137.195 Y121.06 E.00829
G1 X137.162 Y120.785 E.00852
G1 X137.029 Y120.551 E.00826
G1 X136.814 Y120.385 E.00833
G1 X136.552 Y120.316 E.00832
G1 X136.284 Y120.354 E.00833
G1 X136.052 Y120.49 E.00825
G1 X135.889 Y120.71 E.00841
G1 X135.842 Y120.88 E.0054
M204 S10000
G1 X136.264 Y120.97 F42000
; LINE_WIDTH: 0.52636
G1 F3134
M204 S6000
G1 X136.324 Y121.163 E.00794
G1 X136.501 Y121.249 E.00774
G1 X136.667 Y121.193 E.0069
G1 X136.757 Y121.023 E.00758
G2 X136.526 Y120.754 I-.279 J.006 E.01514
G1 X136.346 Y120.817 E.0075
G1 X136.292 Y120.918 E.00451
; OBJECT_ID: 80
; WIPE_START
G1 F13031.608
G1 X136.346 Y120.817 E-.05977
G1 X136.526 Y120.754 E-.09938
G1 X136.697 Y120.839 E-.09995
G1 X136.757 Y121.023 E-.10123
G1 X136.667 Y121.193 E-.10041
G1 X136.501 Y121.249 E-.09145
G1 X136.324 Y121.163 E-.10255
G1 X136.264 Y120.97 E-.10526
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.608 Y128.575 Z3.6 F42000
G1 X135.606 Y128.6 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3134
M204 S6000
G3 X136.479 Y126.917 I.901 J-.6 E.07657
G1 X136.576 Y126.919 E.00324
G3 X135.641 Y128.649 I-.069 J1.08 E.14384
M204 S10000
G1 X135.273 Y128.832 F42000
G1 F3134
M204 S6000
G3 X136.473 Y126.51 I1.235 J-.833 E.10578
G1 X136.6 Y126.512 E.00421
G3 X135.307 Y128.881 I-.091 J1.487 E.19855
M204 S10000
M73 P91 R0
G1 X134.934 Y129.053 F42000
G1 F3134
M204 S6000
G1 X134.762 Y128.739 E.0119
G3 X136.467 Y126.103 I1.747 J-.739 E.12264
G1 X136.623 Y126.106 E.00517
G3 X134.966 Y129.104 I-.114 J1.894 E.25368
M204 S250
G1 X134.591 Y129.24 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3134
M204 S5000
G1 X134.402 Y128.891 E.0122
G3 X136.462 Y125.711 I2.109 J-.891 E.13714
G1 X136.645 Y125.714 E.00565
G3 X134.621 Y129.292 I-.135 J2.285 E.28513
; WIPE_START
G1 F12000
M204 S6000
G1 X134.402 Y128.891 E-.1737
G1 X134.267 Y128.457 E-.17245
G1 X134.221 Y128.003 E-.17363
G1 X134.266 Y127.549 E-.17341
G1 X134.314 Y127.38 E-.0668
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.826 Y127.955 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3134
M204 S6000
G1 X135.855 Y128.203 E.00769
G1 X135.991 Y128.449 E.00863
G1 X136.208 Y128.615 E.00839
G1 X136.468 Y128.685 E.00827
G1 X136.736 Y128.648 E.00832
G1 X136.969 Y128.51 E.00831
G1 X137.137 Y128.282 E.00872
G1 X137.196 Y128.054 E.00723
G1 X137.171 Y127.814 E.0074
G1 X137.026 Y127.547 E.00934
G1 X136.812 Y127.384 E.00827
G1 X136.552 Y127.315 E.00826
G1 X136.284 Y127.353 E.00834
G1 X136.052 Y127.49 E.00826
G1 X135.89 Y127.708 E.00837
G1 X135.841 Y127.897 E.00598
M204 S10000
G1 X136.262 Y127.984 F42000
; LINE_WIDTH: 0.524895
G1 F3134
M204 S6000
G1 X136.324 Y128.163 E.00741
G1 X136.495 Y128.247 E.0075
G1 X136.675 Y128.185 E.00747
G1 X136.761 Y128.021 E.00728
G2 X136.526 Y127.753 I-.282 J.01 E.01515
G1 X136.345 Y127.815 E.00751
G1 X136.288 Y127.931 E.00505
; OBJECT_ID: 69
; WIPE_START
G1 F13071.226
G1 X136.345 Y127.815 E-.06693
G1 X136.526 Y127.753 E-.09954
G1 X136.693 Y127.833 E-.09636
G1 X136.761 Y128.021 E-.10401
G1 X136.675 Y128.185 E-.09643
G1 X136.495 Y128.247 E-.09901
G1 X136.324 Y128.163 E-.09945
G1 X136.262 Y127.984 E-.09827
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.607 Y135.589 Z3.6 F42000
G1 X135.606 Y135.599 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3134
M204 S6000
G3 X136.479 Y133.917 I.901 J-.6 E.07657
G1 X136.576 Y133.918 E.00324
G3 X135.641 Y135.648 I-.069 J1.08 E.14384
M204 S10000
G1 X135.273 Y135.832 F42000
G1 F3134
M204 S6000
G3 X136.473 Y133.509 I1.235 J-.833 E.10578
G1 X136.6 Y133.512 E.00421
G3 X135.307 Y135.881 I-.091 J1.487 E.19855
M204 S10000
G1 X134.934 Y136.053 F42000
G1 F3134
M204 S6000
G1 X134.762 Y135.738 E.0119
G3 X136.467 Y133.102 I1.747 J-.739 E.12264
G1 X136.623 Y133.105 E.00517
G3 X134.966 Y136.103 I-.114 J1.894 E.25368
M204 S250
G1 X134.591 Y136.239 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3134
M204 S5000
G1 X134.402 Y135.89 E.0122
G3 X136.462 Y132.71 I2.109 J-.891 E.13714
G1 X136.645 Y132.713 E.00565
G3 X134.621 Y136.291 I-.135 J2.285 E.28513
; WIPE_START
G1 F12000
M204 S6000
G1 X134.402 Y135.89 E-.1737
G1 X134.267 Y135.457 E-.17245
G1 X134.221 Y135.002 E-.17363
G1 X134.266 Y134.548 E-.17341
G1 X134.314 Y134.379 E-.0668
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.826 Y134.954 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3134
M204 S6000
G1 X135.855 Y135.202 E.00769
G1 X135.991 Y135.448 E.00863
G1 X136.208 Y135.614 E.00839
G1 X136.468 Y135.684 E.00827
G1 X136.736 Y135.647 E.00832
G1 X136.969 Y135.51 E.00831
G1 X137.137 Y135.281 E.00872
G1 X137.196 Y135.053 E.00723
G1 X137.171 Y134.813 E.0074
G1 X137.026 Y134.546 E.00934
G1 X136.812 Y134.383 E.00827
G1 X136.552 Y134.315 E.00826
G1 X136.284 Y134.352 E.00834
G1 X136.052 Y134.489 E.00826
G1 X135.89 Y134.707 E.00837
G1 X135.841 Y134.896 E.00598
M204 S10000
G1 X136.262 Y134.984 F42000
; LINE_WIDTH: 0.524895
G1 F3134
M204 S6000
G1 X136.324 Y135.162 E.00741
G1 X136.495 Y135.247 E.0075
G1 X136.675 Y135.184 E.00747
G1 X136.761 Y135.02 E.00728
G2 X136.526 Y134.752 I-.282 J.01 E.01515
G1 X136.345 Y134.815 E.00751
G1 X136.288 Y134.93 E.00505
; OBJECT_ID: 102
; WIPE_START
G1 F13071.226
G1 X136.345 Y134.815 E-.06693
G1 X136.526 Y134.752 E-.09954
G1 X136.693 Y134.832 E-.09636
G1 X136.761 Y135.02 E-.10401
G1 X136.675 Y135.184 E-.09643
G1 X136.495 Y135.247 E-.09901
G1 X136.324 Y135.162 E-.09945
G1 X136.262 Y134.984 E-.09827
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.742 Y133.677 Z3.6 F42000
G1 X119.088 Y132 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3134
M204 S6000
G1 X119.154 Y131.973 E.00239
G3 X119.503 Y131.918 I.342 J1.027 E.01177
G1 X119.584 Y131.921 E.00266
G3 X118.959 Y132.061 I-.087 J1.078 E.20395
G1 X119.033 Y132.026 E.00274
M204 S10000
G1 X118.926 Y131.628 F42000
G1 F3134
M204 S6000
G1 X119.025 Y131.587 E.00354
G3 X119.51 Y131.511 I.471 J1.412 E.01638
G1 X119.613 Y131.515 E.0034
G3 X118.755 Y131.708 I-.116 J1.484 E.28071
G1 X118.872 Y131.654 E.00427
M204 S10000
G1 X118.763 Y131.257 F42000
G1 F3134
M204 S6000
G1 X118.895 Y131.201 E.00477
G3 X119.517 Y131.104 I.601 J1.798 E.02098
G1 X119.642 Y131.109 E.00413
G3 X118.552 Y131.356 I-.145 J1.89 E.35748
G1 X118.708 Y131.283 E.00573
M204 S250
G1 X118.604 Y130.9 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3134
M204 S5000
G1 X118.77 Y130.83 E.00555
G3 X119.524 Y130.712 I.726 J2.169 E.02354
G1 X119.669 Y130.718 E.00448
G3 X118.356 Y131.016 I-.173 J2.281 E.39963
G1 X118.55 Y130.926 E.00657
; WIPE_START
G1 F12000
M204 S6000
G1 X118.77 Y130.83 E-.0914
G1 X119.121 Y130.741 E-.13732
G1 X119.524 Y130.712 E-.15364
G1 X119.669 Y130.718 E-.05535
G1 X120.026 Y130.775 E-.13721
G1 X120.458 Y130.926 E-.17385
G1 X120.483 Y130.941 E-.01125
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.546 Y132.322 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3134
M204 S6000
G2 X119.15 Y132.405 I.131 J1.613 E.01247
G1 X118.943 Y132.584 E.0084
G1 X118.838 Y132.786 E.007
G1 X118.809 Y133.094 E.00951
G1 X118.897 Y133.349 E.0083
G1 X119.049 Y133.528 E.00721
G1 X119.328 Y133.668 E.0096
G1 X119.637 Y133.658 E.00949
G1 X119.805 Y133.61 E.00535
G1 X120.005 Y133.453 E.00783
G1 X120.152 Y133.174 E.00969
G1 X120.168 Y132.906 E.00824
G1 X120.079 Y132.651 E.00831
G1 X119.899 Y132.451 E.00827
G1 X119.603 Y132.342 E.00969
M204 S10000
G1 X119.525 Y132.749 F42000
; LINE_WIDTH: 0.52206
G1 F3134
M204 S6000
G1 X119.325 Y132.819 E.00825
G1 X119.253 Y132.94 E.00549
G1 X119.276 Y133.133 E.00759
G1 X119.446 Y133.249 E.00803
G1 X119.606 Y133.221 E.00634
G1 X119.73 Y133.056 E.00806
G2 X119.703 Y132.873 I-.335 J-.044 E.0073
G1 X119.574 Y132.784 E.00614
; CHANGE_LAYER
; Z_HEIGHT: 3.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13148.558
G1 X119.703 Y132.873 E-.08173
G1 X119.73 Y133.056 E-.09585
G1 X119.606 Y133.221 E-.10729
G1 X119.446 Y133.249 E-.08437
G1 X119.276 Y133.133 E-.10688
G1 X119.253 Y132.94 E-.10105
G1 X119.325 Y132.819 E-.07306
G1 X119.525 Y132.749 E-.10977
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 17/20
; update layer progress
M73 L17
M991 S0 P16 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z3.6 I.71 J.988 P1  F42000
G1 X135.472 Y121.288 Z3.6
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3121
M204 S6000
G1 X135.45 Y121.204 E.00286
G3 X136.549 Y119.918 I1.063 J-.205 E.06441
G1 X136.561 Y119.919 E.00043
G3 X135.512 Y121.411 I-.049 J1.081 E.15361
G1 X135.49 Y121.345 E.00229
M204 S10000
G1 X135.087 Y121.421 F42000
G1 F3121
M204 S6000
G1 X135.044 Y121.249 E.00589
G3 X136.551 Y119.511 I1.468 J-.249 E.08719
G1 X136.589 Y119.512 E.00125
G3 X135.119 Y121.524 I-.077 J1.487 E.21244
G1 X135.105 Y121.478 E.0016
M204 S10000
G1 X134.696 Y121.527 F42000
G1 F3121
M204 S6000
G1 X134.642 Y121.31 E.00743
G3 X136.554 Y119.104 I1.87 J-.311 E.11053
G1 X136.617 Y119.106 E.00208
G3 X134.738 Y121.668 I-.105 J1.893 E.27022
G1 X134.713 Y121.584 E.00288
M204 S250
G1 X134.32 Y121.627 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3121
M204 S5000
G1 X134.254 Y121.368 E.00821
G3 X136.557 Y118.711 I2.258 J-.37 E.12323
G1 X136.643 Y118.715 E.00266
G3 X134.371 Y121.805 I-.132 J2.284 E.30185
G1 X134.336 Y121.685 E.00385
; WIPE_START
G1 F12000
M204 S6000
G1 X134.254 Y121.368 E-.1243
G1 X134.221 Y120.976 E-.14963
G1 X134.237 Y120.733 E-.09257
G1 X134.285 Y120.464 E-.10388
G1 X134.436 Y120.032 E-.17368
G1 X134.592 Y119.77 E-.11595
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 17 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.8
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.8 F4000
            G39.3 S1
            G0 Z3.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer17 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.825 Y121 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3121
M204 S6000
G1 X135.876 Y121.261 E.00817
G1 X136.026 Y121.487 E.00835
G1 X136.252 Y121.637 E.0083
G1 X136.508 Y121.687 E.00803
G1 X136.776 Y121.634 E.00842
G1 X136.986 Y121.496 E.00771
G1 X137.142 Y121.272 E.00838
G1 X137.198 Y121.017 E.00801
G2 X137.017 Y120.536 I-1.325 J.224 E.01589
G1 X136.807 Y120.381 E.00802
G1 X136.543 Y120.315 E.00835
G1 X136.274 Y120.356 E.00836
G1 X136.052 Y120.49 E.00796
G1 X135.891 Y120.708 E.00831
G1 X135.838 Y120.942 E.00737
M204 S10000
G1 X136.264 Y121.007 F42000
; LINE_WIDTH: 0.52539
G1 F3121
M204 S6000
G1 X136.336 Y121.177 E.00725
G1 X136.508 Y121.249 E.00733
G1 X136.68 Y121.183 E.00727
G1 X136.76 Y121.005 E.00767
G2 X136.522 Y120.753 I-.277 J.023 E.0147
G1 X136.347 Y120.814 E.00731
G1 X136.288 Y120.952 E.00588
; OBJECT_ID: 80
; WIPE_START
G1 F13057.807
G1 X136.347 Y120.814 E-.07785
G1 X136.522 Y120.753 E-.09679
G1 X136.692 Y120.831 E-.09741
G1 X136.76 Y121.005 E-.09703
G1 X136.68 Y121.183 E-.10152
G1 X136.508 Y121.249 E-.09629
G1 X136.336 Y121.177 E-.09705
G1 X136.264 Y121.007 E-.09606
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.568 Y128.529 Z3.8 F42000
G1 Z3.4
M73 P92 R0
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3121
M204 S6000
G3 X136.548 Y126.917 I.944 J-.53 E.07598
G1 X136.561 Y126.918 E.00043
G3 X135.599 Y128.581 I-.049 J1.082 E.14729
M204 S10000
G1 X135.214 Y128.732 F42000
G1 F3121
M204 S6000
G1 X135.211 Y128.725 E.00025
G3 X136.551 Y126.51 I1.301 J-.726 E.10408
G1 X136.589 Y126.511 E.00126
G3 X135.384 Y128.973 I-.077 J1.488 E.19516
G1 X135.249 Y128.781 E.00779
M204 S10000
G1 X134.882 Y128.964 F42000
G1 F3121
M204 S6000
G1 X134.854 Y128.922 E.00167
G3 X136.554 Y126.103 I1.658 J-.922 E.13219
G1 X136.617 Y126.105 E.00208
G3 X135.08 Y129.244 I-.105 J1.894 E.24806
G1 X134.917 Y129.013 E.00937
M204 S250
G1 X134.558 Y129.191 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3121
M204 S5000
G1 X134.51 Y129.111 E.00286
G3 X136.556 Y125.71 I2.001 J-1.111 E.14753
G1 X136.643 Y125.714 E.00266
G3 X134.619 Y129.288 I-.132 J2.285 E.28538
G1 X134.59 Y129.241 E.00169
; WIPE_START
G1 F12000
M204 S6000
G1 X134.51 Y129.111 E-.05815
G1 X134.329 Y128.693 E-.17288
G1 X134.235 Y128.248 E-.17287
G1 X134.228 Y127.821 E-.16248
G1 X134.285 Y127.463 E-.13757
G1 X134.333 Y127.324 E-.05605
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.827 Y127.941 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3121
M204 S6000
G1 X135.858 Y128.211 E.00837
G1 X135.99 Y128.447 E.00831
G1 X136.207 Y128.615 E.00841
G1 X136.467 Y128.685 E.00827
G1 X136.735 Y128.648 E.00832
G1 X136.968 Y128.511 E.00832
G1 X137.136 Y128.284 E.00866
G1 X137.196 Y128.024 E.00822
G1 X137.143 Y127.733 E.00909
G2 X136.543 Y127.314 I-.68 J.335 E.02344
G1 X136.274 Y127.355 E.00838
G1 X136.052 Y127.49 E.00797
G1 X135.889 Y127.71 E.00842
G1 X135.842 Y127.883 E.0055
M204 S10000
G1 X136.263 Y127.973 F42000
; LINE_WIDTH: 0.525625
G1 F3121
M204 S6000
G1 X136.322 Y128.161 E.00775
G1 X136.495 Y128.247 E.00758
G1 X136.674 Y128.185 E.00747
G1 X136.757 Y128.013 E.0075
G2 X136.524 Y127.752 I-.278 J.013 E.0149
G1 X136.347 Y127.814 E.00739
G1 X136.291 Y127.92 E.00471
; OBJECT_ID: 69
; WIPE_START
G1 F13051.453
G1 X136.347 Y127.814 E-.06248
G1 X136.524 Y127.752 E-.09802
G1 X136.658 Y127.804 E-.07449
G1 X136.743 Y127.939 E-.08349
G1 X136.757 Y128.013 E-.03962
G1 X136.674 Y128.185 E-.09949
G1 X136.495 Y128.247 E-.0991
G1 X136.322 Y128.161 E-.10052
G1 X136.263 Y127.973 E-.1028
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.568 Y135.529 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3121
M204 S6000
G3 X136.548 Y133.917 I.944 J-.53 E.07598
G1 X136.561 Y133.917 E.00043
G3 X135.599 Y135.58 I-.049 J1.082 E.14729
M204 S10000
G1 X135.214 Y135.732 F42000
G1 F3121
M204 S6000
G1 X135.211 Y135.725 E.00025
G3 X136.551 Y133.509 I1.301 J-.726 E.10408
G1 X136.589 Y133.511 E.00126
G3 X135.384 Y135.972 I-.077 J1.488 E.19516
G1 X135.249 Y135.781 E.00779
M204 S10000
G1 X134.882 Y135.963 F42000
G1 F3121
M204 S6000
G1 X134.854 Y135.921 E.00167
G3 X136.554 Y133.102 I1.658 J-.922 E.13219
G1 X136.617 Y133.104 E.00208
G3 X135.08 Y136.243 I-.105 J1.894 E.24806
G1 X134.917 Y136.012 E.00937
M204 S250
G1 X134.558 Y136.19 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3121
M204 S5000
G1 X134.51 Y136.11 E.00286
G3 X136.556 Y132.71 I2.001 J-1.111 E.14753
G1 X136.643 Y132.713 E.00266
G3 X134.619 Y136.287 I-.132 J2.285 E.28538
G1 X134.59 Y136.24 E.00169
; WIPE_START
G1 F12000
M204 S6000
G1 X134.51 Y136.11 E-.05815
G1 X134.329 Y135.693 E-.17288
G1 X134.235 Y135.247 E-.17287
G1 X134.228 Y134.82 E-.16248
G1 X134.285 Y134.462 E-.13757
G1 X134.333 Y134.323 E-.05605
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.827 Y134.94 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3121
M204 S6000
G1 X135.858 Y135.21 E.00837
G1 X135.99 Y135.447 E.00831
G1 X136.207 Y135.614 E.00841
G1 X136.467 Y135.684 E.00827
G1 X136.735 Y135.648 E.00832
G1 X136.968 Y135.51 E.00832
G1 X137.136 Y135.283 E.00866
G1 X137.196 Y135.023 E.00822
G1 X137.143 Y134.732 E.00909
G2 X136.543 Y134.313 I-.68 J.335 E.02344
G1 X136.274 Y134.355 E.00838
G1 X136.052 Y134.489 E.00797
G1 X135.889 Y134.709 E.00842
G1 X135.842 Y134.882 E.0055
M204 S10000
G1 X136.263 Y134.972 F42000
; LINE_WIDTH: 0.525625
G1 F3121
M204 S6000
G1 X136.322 Y135.16 E.00775
G1 X136.495 Y135.246 E.00758
G1 X136.674 Y135.185 E.00747
G1 X136.757 Y135.013 E.0075
G2 X136.524 Y134.751 I-.278 J.013 E.0149
G1 X136.347 Y134.813 E.00739
G1 X136.291 Y134.919 E.00471
; OBJECT_ID: 102
; WIPE_START
G1 F13051.453
G1 X136.347 Y134.813 E-.06248
G1 X136.524 Y134.751 E-.09802
G1 X136.658 Y134.803 E-.07449
G1 X136.743 Y134.938 E-.08349
G1 X136.757 Y135.013 E-.03962
G1 X136.674 Y135.185 E-.09949
G1 X136.495 Y135.246 E-.0991
G1 X136.322 Y135.16 E-.10052
G1 X136.263 Y134.972 E-.1028
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.742 Y133.675 Z3.8 F42000
G1 X119.066 Y132.006 Z3.8
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3121
M204 S6000
G3 X119.495 Y131.918 I.428 J.994 E.01463
G1 X119.585 Y131.922 E.00299
G3 X119.012 Y132.032 I-.091 J1.079 E.20597
M204 S10000
G1 X118.916 Y131.626 F42000
G1 F3121
M204 S6000
G1 X119.201 Y131.54 E.00987
G3 X119.501 Y131.511 I.294 J1.46 E.01004
G1 X119.614 Y131.515 E.00373
G3 X118.862 Y131.652 I-.119 J1.484 E.28474
M204 S10000
G1 X118.796 Y131.239 F42000
G1 F3121
M204 S6000
G1 X119.116 Y131.142 E.01109
G3 X119.507 Y131.104 I.379 J1.858 E.01306
G1 X119.642 Y131.109 E.00447
G3 X118.74 Y131.26 I-.147 J1.89 E.36454
M204 S250
G1 X118.681 Y130.866 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3121
M204 S5000
G1 X119.035 Y130.758 E.01137
G3 X119.514 Y130.711 I.46 J2.241 E.0148
G1 X119.67 Y130.718 E.0048
G3 X118.599 Y130.894 I-.174 J2.281 E.40804
G1 X118.624 Y130.885 E.00083
; WIPE_START
G1 F12000
M204 S6000
G1 X119.035 Y130.758 E-.16333
G1 X119.306 Y130.718 E-.10393
G1 X119.514 Y130.711 E-.07905
G1 X119.67 Y130.718 E-.05936
G1 X120.026 Y130.775 E-.13701
G1 X120.457 Y130.926 E-.1737
G1 X120.556 Y130.984 E-.04361
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.546 Y132.322 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3121
M204 S6000
G1 X119.265 Y132.37 E.00875
G1 X119.053 Y132.484 E.00739
G2 X118.806 Y133.063 I.499 J.555 E.01996
G1 X118.883 Y133.322 E.00833
G1 X119.055 Y133.532 E.00832
G1 X119.295 Y133.658 E.00833
G1 X119.571 Y133.682 E.00851
G2 X120.005 Y133.452 I-.08 J-.677 E.01546
G1 X120.155 Y133.164 E.00996
G2 X120.08 Y132.652 I-1.273 J-.075 E.01603
G1 X119.898 Y132.45 E.00834
G1 X119.602 Y132.342 E.00968
M204 S10000
G1 X119.524 Y132.75 F42000
; LINE_WIDTH: 0.52292
G1 F3121
M204 S6000
G1 X119.327 Y132.813 E.00811
G1 X119.246 Y132.975 E.00707
G1 X119.269 Y133.117 E.00562
G1 X119.418 Y133.239 E.00751
G1 X119.606 Y133.222 E.00738
G1 X119.731 Y133.05 E.00831
G2 X119.573 Y132.784 I-.244 J-.035 E.01309
; CHANGE_LAYER
; Z_HEIGHT: 3.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13125
G1 X119.705 Y132.876 E-.08351
G1 X119.731 Y133.05 E-.09159
G1 X119.606 Y133.222 E-.11047
G1 X119.418 Y133.239 E-.09807
G1 X119.269 Y133.117 E-.09987
G1 X119.246 Y132.975 E-.07477
G1 X119.327 Y132.813 E-.09395
G1 X119.524 Y132.75 E-.10777
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 18/20
; update layer progress
M73 L18
M991 S0 P17 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z3.8 I.714 J.986 P1  F42000
G1 X135.453 Y121.22 Z3.8
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3131
M204 S6000
G3 X136.547 Y119.918 I1.06 J-.22 E.06491
G1 X136.561 Y119.919 E.00046
G3 X135.467 Y121.279 I-.048 J1.082 E.15829
M204 S10000
G1 X135.053 Y121.3 F42000
G1 F3131
M204 S6000
G3 X136.55 Y119.511 I1.459 J-.301 E.08894
M73 P93 R0
G1 X136.589 Y119.512 E.00127
G3 X135.066 Y121.359 I-.077 J1.487 E.21822
M204 S10000
G1 X134.654 Y121.387 F42000
G1 F3131
M204 S6000
G1 X134.654 Y121.38 E.00024
G3 X136.553 Y119.104 I1.858 J-.381 E.1129
G1 X136.616 Y119.106 E.00209
G3 X134.765 Y121.737 I-.105 J1.893 E.26777
G1 X134.672 Y121.444 E.01021
M204 S250
G1 X134.281 Y121.502 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3131
M204 S5000
G1 X134.269 Y121.457 E.00145
G3 X136.556 Y118.711 I2.242 J-.458 E.12598
G1 X136.643 Y118.715 E.00266
G3 X134.404 Y121.89 I-.132 J2.284 E.29912
G1 X134.299 Y121.56 E.01065
; WIPE_START
G1 F12000
M204 S6000
G1 X134.269 Y121.457 E-.04076
G1 X134.221 Y121.004 E-.1731
G1 X134.237 Y120.733 E-.10306
G1 X134.285 Y120.464 E-.10375
G1 X134.436 Y120.033 E-.17373
G1 X134.658 Y119.658 E-.16561
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 18 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4 F4000
            G39.3 S1
            G0 Z4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer18 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.825 Y121.004 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3131
M204 S6000
G1 X135.878 Y121.268 E.00828
G1 X136.032 Y121.493 E.00837
G1 X136.251 Y121.636 E.00803
G1 X136.507 Y121.687 E.00804
G1 X136.776 Y121.634 E.00841
G1 X136.988 Y121.494 E.00782
G1 X137.141 Y121.273 E.00827
G1 X137.198 Y121.018 E.00801
G2 X137.018 Y120.538 I-1.313 J.218 E.01585
G1 X136.787 Y120.373 E.00872
G1 X136.544 Y120.315 E.00767
G1 X136.274 Y120.356 E.0084
G1 X136.051 Y120.491 E.00799
G1 X135.891 Y120.708 E.00828
G1 X135.838 Y120.945 E.00747
M204 S10000
G1 X136.265 Y121.008 F42000
; LINE_WIDTH: 0.52514
G1 F3131
M204 S6000
G1 X136.339 Y121.18 E.00736
G1 X136.508 Y121.249 E.00716
G1 X136.682 Y121.181 E.00736
G1 X136.76 Y121.005 E.00756
G2 X136.695 Y120.836 I-.341 J.033 E.00722
G1 X136.526 Y120.752 E.00741
G1 X136.347 Y120.815 E.00748
G1 X136.288 Y120.953 E.00591
; OBJECT_ID: 80
; WIPE_START
G1 F13064.577
G1 X136.347 Y120.815 E-.07825
G1 X136.526 Y120.752 E-.09904
G1 X136.695 Y120.836 E-.09822
G1 X136.76 Y121.005 E-.09451
G1 X136.682 Y121.181 E-.10015
G1 X136.508 Y121.249 E-.09753
G1 X136.339 Y121.18 E-.09482
G1 X136.265 Y121.008 E-.09747
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.571 Y128.536 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3131
M204 S6000
G3 X136.547 Y126.917 I.94 J-.537 E.07622
G1 X136.561 Y126.918 E.00046
G3 X135.602 Y128.587 I-.05 J1.082 E.14699
M204 S10000
G1 X135.215 Y128.733 F42000
G1 F3131
M204 S6000
G3 X136.55 Y126.51 I1.297 J-.733 E.10434
G1 X136.589 Y126.511 E.00129
G3 X135.245 Y128.784 I-.077 J1.488 E.20291
M204 S10000
G1 X134.858 Y128.93 F42000
G1 F3131
M204 S6000
G3 X136.553 Y126.103 I1.653 J-.93 E.13247
G1 X136.616 Y126.105 E.0021
G3 X134.888 Y128.981 I-.105 J1.894 E.25882
M204 S250
G1 X134.525 Y129.136 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3131
M204 S5000
G1 X134.515 Y129.119 E.00063
G3 X136.556 Y125.71 I1.996 J-1.12 E.14783
G1 X136.643 Y125.714 E.00267
G3 X134.786 Y129.504 I-.132 J2.285 E.27696
G1 X134.56 Y129.185 E.01199
; WIPE_START
G1 F12000
M204 S6000
G1 X134.515 Y129.119 E-.03053
G1 X134.332 Y128.703 E-.17283
G1 X134.236 Y128.258 E-.1728
G1 X134.228 Y127.821 E-.16622
G1 X134.285 Y127.463 E-.13747
G1 X134.354 Y127.264 E-.08014
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.827 Y127.941 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3131
M204 S6000
G1 X135.86 Y128.216 E.00852
G1 X135.989 Y128.446 E.00813
G1 X136.205 Y128.614 E.00841
G1 X136.465 Y128.685 E.00828
G1 X136.734 Y128.649 E.00833
G1 X136.967 Y128.512 E.0083
G1 X137.133 Y128.289 E.00854
G1 X137.197 Y128.023 E.00842
G1 X137.15 Y127.75 E.0085
G1 X137.006 Y127.525 E.00822
G1 X136.798 Y127.376 E.00788
G1 X136.543 Y127.314 E.00804
G1 X136.274 Y127.356 E.00838
G1 X136.051 Y127.49 E.00799
G1 X135.889 Y127.711 E.00842
G1 X135.842 Y127.883 E.00547
M204 S10000
G1 X136.264 Y127.972 F42000
; LINE_WIDTH: 0.526485
G1 F3131
M204 S6000
G1 X136.322 Y128.16 E.00773
G1 X136.494 Y128.247 E.00762
G1 X136.674 Y128.185 E.00749
G1 X136.758 Y128.008 E.00771
G2 X136.525 Y127.752 I-.28 J.021 E.0147
G1 X136.347 Y127.814 E.00741
G1 X136.292 Y127.919 E.00466
; OBJECT_ID: 69
; WIPE_START
G1 F13028.239
G1 X136.347 Y127.814 E-.06175
G1 X136.525 Y127.752 E-.09814
G1 X136.688 Y127.827 E-.09389
G1 X136.758 Y128.008 E-.10151
G1 X136.674 Y128.185 E-.10213
G1 X136.494 Y128.247 E-.09916
G1 X136.322 Y128.16 E-.10093
G1 X136.264 Y127.972 E-.10247
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.571 Y135.535 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3131
M204 S6000
G3 X136.547 Y133.916 I.94 J-.537 E.07622
G1 X136.561 Y133.917 E.00046
G3 X135.602 Y135.586 I-.05 J1.082 E.14699
M204 S10000
G1 X135.215 Y135.732 F42000
G1 F3131
M204 S6000
G3 X136.55 Y133.509 I1.297 J-.733 E.10434
G1 X136.589 Y133.511 E.00129
G3 X135.245 Y135.784 I-.077 J1.488 E.20291
M204 S10000
G1 X134.858 Y135.929 F42000
G1 F3131
M204 S6000
G3 X136.553 Y133.102 I1.653 J-.93 E.13247
G1 X136.616 Y133.104 E.0021
G3 X134.888 Y135.98 I-.105 J1.894 E.25882
M204 S250
G1 X134.525 Y136.136 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3131
M204 S5000
G1 X134.515 Y136.118 E.00063
G3 X136.556 Y132.71 I1.996 J-1.12 E.14783
G1 X136.643 Y132.713 E.00267
G3 X134.786 Y136.503 I-.132 J2.285 E.27696
G1 X134.56 Y136.185 E.01199
; WIPE_START
G1 F12000
M204 S6000
G1 X134.515 Y136.118 E-.03053
G1 X134.332 Y135.702 E-.17283
G1 X134.236 Y135.257 E-.1728
G1 X134.228 Y134.82 E-.16622
G1 X134.285 Y134.463 E-.13747
G1 X134.354 Y134.264 E-.08014
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.827 Y134.94 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3131
M204 S6000
G1 X135.86 Y135.215 E.00852
G1 X135.989 Y135.446 E.00813
G1 X136.205 Y135.613 E.00841
G1 X136.465 Y135.684 E.00828
G1 X136.734 Y135.648 E.00833
G1 X136.967 Y135.512 E.0083
G1 X137.133 Y135.289 E.00854
G1 X137.197 Y135.022 E.00842
G1 X137.15 Y134.75 E.0085
G1 X137.006 Y134.524 E.00822
G1 X136.798 Y134.375 E.00788
G1 X136.543 Y134.313 E.00804
G1 X136.274 Y134.355 E.00838
G1 X136.051 Y134.49 E.00799
G1 X135.889 Y134.71 E.00842
G1 X135.842 Y134.882 E.00547
M204 S10000
G1 X136.264 Y134.971 F42000
; LINE_WIDTH: 0.526485
G1 F3131
M204 S6000
G1 X136.322 Y135.159 E.00773
G1 X136.494 Y135.246 E.00762
G1 X136.674 Y135.184 E.00749
G1 X136.758 Y135.008 E.00771
G2 X136.525 Y134.752 I-.28 J.021 E.0147
G1 X136.347 Y134.814 E.00741
G1 X136.292 Y134.918 E.00466
; OBJECT_ID: 102
; WIPE_START
G1 F13028.239
G1 X136.347 Y134.814 E-.06175
G1 X136.525 Y134.752 E-.09814
G1 X136.688 Y134.826 E-.09389
G1 X136.758 Y135.008 E-.10151
G1 X136.674 Y135.184 E-.10213
G1 X136.494 Y135.246 E-.09916
G1 X136.322 Y135.159 E-.10093
G1 X136.264 Y134.971 E-.10247
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.744 Y133.665 Z4 F42000
G1 X119.11 Y131.99 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
M73 P94 R0
G1 F3131
M204 S6000
G1 X119.286 Y131.938 E.00607
G3 X119.487 Y131.918 I.207 J1.062 E.00674
G1 X119.586 Y131.922 E.00327
G3 X119.054 Y132.01 I-.094 J1.078 E.20751
M204 S10000
G1 X118.993 Y131.602 F42000
G1 F3131
M204 S6000
G1 X119.201 Y131.539 E.00723
G3 X119.493 Y131.511 I.292 J1.46 E.00974
G1 X119.614 Y131.515 E.00403
G3 X118.909 Y131.63 I-.121 J1.484 E.28645
G1 X118.935 Y131.621 E.00093
M204 S10000
G1 X118.874 Y131.215 F42000
G1 F3131
M204 S6000
G1 X119.117 Y131.141 E.00843
G3 X119.498 Y131.103 I.376 J1.858 E.01275
G1 X119.642 Y131.109 E.00478
G3 X118.751 Y131.255 I-.149 J1.89 E.36492
G1 X118.816 Y131.233 E.00228
M204 S250
G1 X118.758 Y130.842 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3131
M204 S5000
G1 X119.035 Y130.757 E.00889
G3 X119.503 Y130.711 I.458 J2.242 E.01448
G1 X119.67 Y130.718 E.00511
G3 X118.599 Y130.893 I-.176 J2.281 E.40805
G1 X118.701 Y130.86 E.0033
; WIPE_START
G1 F12000
M204 S6000
G1 X119.035 Y130.757 E-.13274
G1 X119.503 Y130.711 E-.1788
G1 X119.67 Y130.718 E-.06322
G1 X120.025 Y130.775 E-.13687
G1 X120.457 Y130.926 E-.17372
G1 X120.626 Y131.026 E-.07464
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.545 Y132.321 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3131
M204 S6000
G2 X119.149 Y132.404 I.151 J1.71 E.01246
G1 X118.962 Y132.561 E.00749
G1 X118.834 Y132.795 E.00821
G1 X118.806 Y133.065 E.00834
G1 X118.884 Y133.325 E.00833
G1 X119.057 Y133.533 E.00832
G1 X119.295 Y133.659 E.00828
G1 X119.545 Y133.684 E.0077
G1 X119.835 Y133.593 E.00935
G1 X120.006 Y133.452 E.0068
G1 X120.155 Y133.161 E.01005
G2 X120.079 Y132.651 I-1.267 J-.072 E.01596
G1 X119.897 Y132.45 E.00835
G1 X119.602 Y132.342 E.00967
M204 S10000
G1 X119.499 Y132.748 F42000
; LINE_WIDTH: 0.52292
G1 F3131
M204 S6000
G1 X119.299 Y132.837 E.00856
G1 X119.241 Y133.024 E.00766
G1 X119.333 Y133.195 E.00757
G1 X119.5 Y133.249 E.00687
G1 X119.665 Y133.178 E.00703
G1 X119.734 Y133.003 E.00735
G1 X119.675 Y132.844 E.00663
G1 X119.552 Y132.776 E.00549
; CHANGE_LAYER
; Z_HEIGHT: 3.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13125
G1 X119.675 Y132.844 E-.07303
G1 X119.734 Y133.003 E-.08814
G1 X119.665 Y133.178 E-.09776
G1 X119.5 Y133.249 E-.09344
G1 X119.333 Y133.195 E-.09139
G1 X119.241 Y133.024 E-.1006
G1 X119.299 Y132.837 E-.10179
G1 X119.499 Y132.748 E-.11385
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 19/20
; update layer progress
M73 L19
M991 S0 P18 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z4 I.712 J.987 P1  F42000
G1 X135.457 Y121.244 Z4
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3122
M204 S6000
G1 X135.421 Y121.053 E.00645
G3 X136.474 Y119.918 I1.082 J-.052 E.05722
G1 X136.57 Y119.92 E.00319
G3 X135.462 Y121.301 I-.068 J1.081 E.15695
M204 S10000
G1 X135.056 Y121.306 F42000
G1 F3122
M204 S6000
G1 X135.016 Y121.064 E.00812
G3 X136.47 Y119.511 I1.489 J-.064 E.0786
G1 X136.594 Y119.513 E.00412
G3 X135.06 Y121.365 I-.089 J1.488 E.21778
M204 S10000
G1 X134.655 Y121.364 F42000
G1 F3122
M204 S6000
G1 X134.611 Y121.076 E.00967
G3 X136.465 Y119.104 I1.896 J-.075 E.09998
G1 X136.617 Y119.106 E.00505
G3 X134.664 Y121.453 I-.11 J1.894 E.27779
G1 X134.661 Y121.424 E.00098
M204 S250
G1 X134.269 Y121.418 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3122
M204 S5000
G1 X134.221 Y121.087 E.01028
G3 X136.46 Y118.711 I2.288 J-.087 E.11168
G1 X136.64 Y118.715 E.00551
G3 X134.285 Y121.546 I-.131 J2.286 E.31061
G1 X134.276 Y121.478 E.0021
; WIPE_START
G1 F12000
M204 S6000
G1 X134.221 Y121.087 E-.14995
G1 X134.248 Y120.651 E-.16603
G1 X134.362 Y120.211 E-.17278
G1 X134.56 Y119.802 E-.17274
G1 X134.717 Y119.596 E-.09849
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 19 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.2
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4.2 F4000
            G39.3 S1
            G0 Z4.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer19 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X135.826 Y120.965 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3122
M204 S6000
G1 X135.868 Y121.243 E.00864
G1 X136.009 Y121.468 E.00817
G1 X136.226 Y121.625 E.00823
G1 X136.479 Y121.687 E.00801
G1 X136.748 Y121.645 E.00837
G1 X136.98 Y121.502 E.00835
G1 X137.132 Y121.292 E.00799
G1 X137.197 Y121.016 E.00871
G1 X137.15 Y120.751 E.00826
G1 X137.01 Y120.53 E.00804
G1 X136.796 Y120.376 E.00809
G1 X136.549 Y120.315 E.00782
G1 X136.292 Y120.35 E.00796
G1 X136.057 Y120.486 E.00835
G1 X135.893 Y120.701 E.00832
G1 X135.84 Y120.907 E.00651
M204 S10000
G1 X136.264 Y120.986 F42000
; LINE_WIDTH: 0.52616
G1 F3122
M204 S6000
G1 X136.33 Y121.169 E.00766
G1 X136.497 Y121.248 E.0073
G1 X136.681 Y121.181 E.00772
G1 X136.758 Y121.003 E.00761
G2 X136.526 Y120.753 I-.278 J.024 E.01449
G1 X136.347 Y120.815 E.00745
G1 X136.29 Y120.932 E.00514
; OBJECT_ID: 80
; WIPE_START
G1 F13037
G1 X136.347 Y120.815 E-.06802
G1 X136.526 Y120.753 E-.09862
G1 X136.691 Y120.83 E-.09549
G1 X136.758 Y121.003 E-.09663
G1 X136.681 Y121.181 E-.10083
G1 X136.497 Y121.248 E-.10223
G1 X136.33 Y121.169 E-.09672
G1 X136.264 Y120.986 E-.10147
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X135.576 Y128.541 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3122
M204 S6000
G1 X135.496 Y128.399 E.00544
G3 X136.475 Y126.917 I1.007 J-.399 E.06905
G1 X136.57 Y126.919 E.00317
G3 X135.599 Y128.596 I-.067 J1.081 E.14612
M204 S10000
G1 X135.217 Y128.73 F42000
G1 F3122
M204 S6000
G1 X135.115 Y128.537 E.00725
G3 X136.47 Y126.51 I1.39 J-.537 E.09471
G1 X136.594 Y126.512 E.00411
G3 X135.243 Y128.793 I-.089 J1.488 E.20225
G1 X135.24 Y128.785 E.00029
M204 S10000
G1 X134.832 Y128.88 F42000
G1 F3122
M204 S6000
G1 X134.819 Y128.867 E.0006
G3 X136.465 Y126.103 I1.687 J-.868 E.12737
G1 X136.617 Y126.106 E.00505
G3 X134.988 Y129.137 I-.11 J1.894 E.25251
G1 X134.863 Y128.932 E.00796
M204 S250
G1 X134.5 Y129.087 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3122
M204 S5000
G1 X134.473 Y129.047 E.00149
G3 X136.46 Y125.711 I2.036 J-1.047 E.14244
G1 X136.639 Y125.714 E.0055
G3 X134.672 Y129.366 I-.131 J2.286 E.28253
G1 X134.531 Y129.138 E.00823
; WIPE_START
G1 F12000
M204 S6000
G1 X134.473 Y129.047 E-.04126
G1 X134.308 Y128.623 E-.17286
G1 X134.251 Y128.368 E-.09906
G1 X134.223 Y128.096 E-.10391
G1 X134.248 Y127.65 E-.16973
G1 X134.362 Y127.21 E-.17279
G1 X134.362 Y127.209 E-.0004
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.826 Y127.963 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3122
M204 S6000
G1 X135.873 Y128.253 E.00905
G1 X136.008 Y128.467 E.00778
G1 X136.226 Y128.625 E.00826
G1 X136.48 Y128.686 E.00802
G1 X136.749 Y128.644 E.00837
G1 X136.98 Y128.501 E.00833
G1 X137.138 Y128.28 E.00835
G1 X137.196 Y128.027 E.00799
G1 X137.153 Y127.758 E.00836
G1 X137.017 Y127.535 E.00802
G1 X136.806 Y127.38 E.00803
G1 X136.549 Y127.315 E.00817
G1 X136.292 Y127.349 E.00795
G1 X136.057 Y127.485 E.00833
G1 X135.893 Y127.701 E.00834
G1 X135.841 Y127.905 E.00646
M204 S10000
G1 X136.265 Y127.983 F42000
; LINE_WIDTH: 0.52568
G1 F3122
M204 S6000
G1 X136.327 Y128.167 E.00768
G1 X136.498 Y128.248 E.00741
G1 X136.68 Y128.181 E.00765
G1 X136.758 Y128.012 E.00732
G2 X136.523 Y127.752 I-.28 J.017 E.0149
G1 X136.347 Y127.814 E.00734
G1 X136.291 Y127.929 E.00503
; OBJECT_ID: 69
; WIPE_START
G1 F13049.963
M73 P95 R0
G1 X136.347 Y127.814 E-.06665
G1 X136.523 Y127.752 E-.09728
G1 X136.694 Y127.831 E-.0979
G1 X136.758 Y128.012 E-.10005
G1 X136.68 Y128.181 E-.09694
G1 X136.498 Y128.248 E-.10131
G1 X136.327 Y128.167 E-.09814
G1 X136.265 Y127.983 E-.10173
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X135.576 Y135.541 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3122
M204 S6000
G1 X135.496 Y135.398 E.00544
G3 X136.475 Y133.916 I1.007 J-.399 E.06905
G1 X136.57 Y133.918 E.00317
G3 X135.599 Y135.596 I-.067 J1.081 E.14612
M204 S10000
G1 X135.217 Y135.729 F42000
G1 F3122
M204 S6000
G1 X135.115 Y135.536 E.00725
G3 X136.47 Y133.509 I1.39 J-.537 E.09471
G1 X136.594 Y133.511 E.00411
G3 X135.243 Y135.793 I-.089 J1.488 E.20225
G1 X135.24 Y135.784 E.00029
M204 S10000
G1 X134.832 Y135.88 F42000
G1 F3122
M204 S6000
G1 X134.819 Y135.867 E.0006
G3 X136.465 Y133.102 I1.687 J-.868 E.12737
G1 X136.617 Y133.105 E.00505
G3 X134.988 Y136.136 I-.11 J1.894 E.25251
G1 X134.863 Y135.931 E.00796
M204 S250
G1 X134.5 Y136.086 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3122
M204 S5000
G1 X134.473 Y136.046 E.00149
G3 X136.46 Y132.71 I2.036 J-1.047 E.14244
G1 X136.639 Y132.713 E.0055
G3 X134.672 Y136.365 I-.131 J2.286 E.28253
G1 X134.531 Y136.137 E.00823
; WIPE_START
G1 F12000
M204 S6000
G1 X134.473 Y136.046 E-.04126
G1 X134.308 Y135.622 E-.17286
G1 X134.251 Y135.368 E-.09906
G1 X134.223 Y135.096 E-.10391
G1 X134.248 Y134.65 E-.16973
G1 X134.362 Y134.209 E-.17279
G1 X134.362 Y134.208 E-.0004
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.826 Y134.962 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3122
M204 S6000
G1 X135.873 Y135.253 E.00905
G1 X136.008 Y135.467 E.00778
G1 X136.226 Y135.624 E.00826
G1 X136.48 Y135.685 E.00802
G1 X136.749 Y135.643 E.00837
G1 X136.98 Y135.5 E.00833
G1 X137.138 Y135.279 E.00835
G1 X137.196 Y135.026 E.00799
G1 X137.153 Y134.757 E.00836
G1 X137.017 Y134.535 E.00802
G1 X136.806 Y134.379 E.00803
G1 X136.549 Y134.314 E.00817
G1 X136.292 Y134.348 E.00795
G1 X136.057 Y134.484 E.00833
G1 X135.893 Y134.7 E.00834
G1 X135.841 Y134.904 E.00646
M204 S10000
G1 X136.265 Y134.982 F42000
; LINE_WIDTH: 0.52568
G1 F3122
M204 S6000
G1 X136.327 Y135.167 E.00768
G1 X136.498 Y135.247 E.00741
G1 X136.68 Y135.18 E.00765
G1 X136.758 Y135.011 E.00732
G2 X136.523 Y134.751 I-.28 J.017 E.0149
G1 X136.347 Y134.813 E.00734
G1 X136.291 Y134.928 E.00503
; OBJECT_ID: 102
; WIPE_START
G1 F13049.963
G1 X136.347 Y134.813 E-.06665
G1 X136.523 Y134.751 E-.09728
G1 X136.694 Y134.831 E-.0979
G1 X136.758 Y135.011 E-.10005
G1 X136.68 Y135.18 E-.09694
G1 X136.498 Y135.247 E-.10131
G1 X136.327 Y135.167 E-.09814
G1 X136.265 Y134.982 E-.10173
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X128.747 Y133.661 Z4.2 F42000
G1 X119.162 Y131.976 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F3122
M204 S6000
G1 X119.316 Y131.934 E.0053
G3 X119.495 Y131.918 I.182 J1.065 E.00595
G1 X119.587 Y131.922 E.00307
G3 X119.069 Y132.007 I-.089 J1.077 E.20767
G1 X119.105 Y131.995 E.00128
M204 S10000
G1 X119.05 Y131.587 F42000
G1 F3122
M204 S6000
G1 X119.251 Y131.531 E.00691
G3 X119.495 Y131.511 I.245 J1.467 E.00813
G1 X119.615 Y131.516 E.00398
G3 X118.91 Y131.631 I-.119 J1.483 E.28613
G1 X118.993 Y131.605 E.00288
M204 S10000
G1 X118.919 Y131.193 F42000
G1 F3122
M204 S6000
G1 X119.186 Y131.129 E.00912
G3 X119.495 Y131.103 I.308 J1.869 E.01031
G1 X119.643 Y131.109 E.0049
G3 X118.862 Y131.212 I-.149 J1.888 E.3685
M204 S250
G1 X118.826 Y130.813 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F3122
M204 S5000
G1 X119.123 Y130.741 E.0094
G3 X119.496 Y130.711 I.369 J2.256 E.0115
G1 X119.67 Y130.718 E.00536
G3 X118.768 Y130.829 I-.177 J2.279 E.41325
; WIPE_START
G1 F12000
M204 S6000
G1 X119.123 Y130.741 E-.13907
G1 X119.496 Y130.711 E-.14207
G1 X119.67 Y130.718 E-.06623
G1 X120.025 Y130.774 E-.13673
G1 X120.455 Y130.924 E-.1728
G1 X120.688 Y131.063 E-.10309
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X119.635 Y132.329 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F3122
M204 S6000
G2 X119.179 Y132.389 I-.1 J1.006 E.01426
G1 X118.965 Y132.558 E.0084
G1 X118.834 Y132.798 E.00841
G1 X118.806 Y133.068 E.00832
G1 X118.885 Y133.326 E.00831
G1 X119.061 Y133.537 E.00842
G1 X119.301 Y133.661 E.00832
G1 X119.539 Y133.685 E.00733
G1 X119.814 Y133.606 E.00879
G1 X120.005 Y133.452 E.00754
G1 X120.155 Y133.163 E.01
G1 X120.167 Y132.896 E.00822
G1 X120.074 Y132.642 E.00833
G1 X119.889 Y132.443 E.00833
G1 X119.69 Y132.354 E.00671
M204 S10000
G1 X119.53 Y132.752 F42000
; LINE_WIDTH: 0.523436
G1 F3122
M204 S6000
G1 X119.378 Y132.778 E.00603
G1 X119.252 Y132.928 E.00768
G1 X119.27 Y133.118 E.00748
G1 X119.426 Y133.243 E.00781
G1 X119.612 Y133.217 E.00737
G1 X119.731 Y133.05 E.00805
G2 X119.579 Y132.786 I-.246 J-.034 E.01284
; CHANGE_LAYER
; Z_HEIGHT: 4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F13110.907
G1 X119.701 Y132.871 E-.07721
G1 X119.731 Y133.05 E-.09418
G1 X119.612 Y133.217 E-.10668
G1 X119.426 Y133.243 E-.09768
G1 X119.27 Y133.118 E-.10346
G1 X119.252 Y132.928 E-.09911
G1 X119.378 Y132.778 E-.1018
G1 X119.53 Y132.752 E-.07988
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; layer num/total_layer_count: 20/20
; update layer progress
M73 L20
M991 S0 P19 ;notify layer change
; OBJECT_ID: 91
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
M204 S10000
G17
G3 Z4.2 I.746 J.962 P1  F42000
G1 X134.249 Y121.339 Z4.2
G1 Z4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F4473
M204 S5000
G1 X134.239 Y121.276 E.00195
G3 X136.46 Y118.711 I2.272 J-.277 E.11744
G1 X136.646 Y118.715 E.00572
G3 X134.288 Y121.545 I-.135 J2.285 E.31037
G1 X134.26 Y121.398 E.00459
; WIPE_START
G1 F12000
M204 S6000
G1 X134.239 Y121.276 E-.04685
G1 X134.221 Y121.004 E-.10378
G1 X134.265 Y120.554 E-.17187
G1 X134.398 Y120.117 E-.1735
G1 X134.475 Y119.952 E-.06928
G1 X134.667 Y119.643 E-.13826
G1 X134.765 Y119.53 E-.05645
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 91
M625
; object ids of layer 20 start: 69,80,91,102
M624 DwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.4
G1 X0 Y128 F18000 ; move to safe pos
G1 X-48.2 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4.4 F4000
            G39.3 S1
            G0 Z4.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer20 end: 69,80,91,102
M625
; start printing object, unique label id: 91
M624 BAAAAAAAAAA=
G1 X136.642 Y123.068 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Top surface
G1 F4473
M204 S2000
G1 X138.585 Y121.125 E.08445
G1 X138.549 Y120.627
G1 X136.138 Y123.039 E.1048
G1 X135.725 Y122.918
G1 X138.428 Y120.215 E.11747
G1 X138.245 Y119.865
G1 X135.376 Y122.734 E.12467
G1 X135.079 Y122.498
G1 X138.01 Y119.567 E.12735
G1 X137.726 Y119.317
G1 X134.831 Y122.212 E.12581
G1 X134.634 Y121.877
G1 X137.392 Y119.119 E.11985
G1 X136.996 Y118.981
G1 X134.496 Y121.481 E.10865
G1 X134.439 Y121.004
G1 X136.516 Y118.928 E.09025
G1 X135.89 Y119.02
G1 X134.528 Y120.383 E.05921
; WIPE_START
G1 F12000
M204 S6000
G1 X135.89 Y119.02 E-.73228
G1 X135.963 Y119.009 E-.02772
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.266 Y119.348 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.101103
G1 F4473
M204 S6000
G2 X134.814 Y119.801 I3.422 J3.863 E.00303
; WIPE_START
G1 F15000
G1 X135.121 Y119.473 E-.53322
G1 X135.266 Y119.348 E-.22678
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.55 Y119.227 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.097159
G1 F4473
M204 S6000
G1 X137.446 Y119.144 E.00059
; WIPE_START
G1 F15000
G1 X137.55 Y119.227 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.533 Y121.565 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.326674
G1 F4473
M204 S6000
G1 X138.274 Y121.886 E.00953
; LINE_WIDTH: 0.367703
G1 X138.015 Y122.206 E.0109
; LINE_WIDTH: 0.379409
G3 X137.511 Y122.676 I-2.868 J-2.569 E.01892
; LINE_WIDTH: 0.317103
G1 X137.342 Y122.795 E.00462
; LINE_WIDTH: 0.270816
G1 X137.173 Y122.913 E.00384
; LINE_WIDTH: 0.224529
G1 X137.004 Y123.032 E.00306
; OBJECT_ID: 80
; WIPE_START
G1 F15000
G1 X137.173 Y122.913 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 80
M624 AgAAAAAAAAA=
M204 S10000
G1 X134.483 Y129.04 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
M73 P96 R0
G1 F4473
M204 S5000
G1 X134.401 Y128.89 E.00527
G3 X136.46 Y125.711 I2.109 J-.891 E.13706
G1 X136.644 Y125.714 E.00565
G3 X134.619 Y129.289 I-.134 J2.285 E.28521
G1 X134.512 Y129.093 E.00685
; WIPE_START
G1 F12000
M204 S6000
G1 X134.401 Y128.89 E-.08798
G1 X134.267 Y128.455 E-.17279
G1 X134.223 Y128.092 E-.13899
G1 X134.25 Y127.638 E-.17281
G1 X134.365 Y127.201 E-.17184
G1 X134.383 Y127.164 E-.01558
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.631 Y130.068 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Top surface
G1 F4473
M204 S2000
G1 X138.585 Y128.114 E.08493
G1 X138.548 Y127.618
G1 X136.129 Y130.037 E.10511
G1 X135.717 Y129.915
G1 X138.425 Y127.207 E.11766
G1 X138.24 Y126.858
G1 X135.369 Y129.729 E.12476
G1 X135.074 Y129.492
G1 X138.004 Y126.561 E.12734
G1 X137.72 Y126.312
G1 X134.827 Y129.206 E.12572
G1 X134.63 Y128.869
G1 X137.384 Y126.115 E.11966
G1 X136.987 Y125.978
G1 X134.494 Y128.472 E.10835
G1 X134.439 Y127.993
G1 X136.505 Y125.927 E.08978
G1 X135.882 Y126.017
G1 X134.535 Y127.364 E.05852
; WIPE_START
G1 F12000
M204 S6000
G1 X135.882 Y126.017 E-.72375
G1 X135.976 Y126.004 E-.03625
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.534 Y128.557 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.334034
G1 F4473
M204 S6000
G1 X138.273 Y128.88 E.00985
; LINE_WIDTH: 0.385639
G3 X137.745 Y129.473 I-3.229 J-2.346 E.02221
; LINE_WIDTH: 0.38146
G1 X137.597 Y129.595 E.00531
; LINE_WIDTH: 0.345536
G1 X137.448 Y129.718 E.00475
; LINE_WIDTH: 0.307999
G1 X137.328 Y129.799 E.00313
; LINE_WIDTH: 0.268842
G1 X137.208 Y129.88 E.00267
; LINE_WIDTH: 0.229685
G1 X137.087 Y129.961 E.00221
; LINE_WIDTH: 0.190528
G1 X136.967 Y130.042 E.00174
; WIPE_START
G1 F15000
G1 X137.087 Y129.961 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.471 Y127.541 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.0896582
G1 F4473
M204 S6000
G1 X138.514 Y127.385 E.00062
; WIPE_START
G1 F15000
G1 X138.471 Y127.541 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.543 Y126.223 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.0977664
G1 F4473
M204 S6000
G1 X137.434 Y126.137 E.00062
; WIPE_START
G1 F15000
G1 X137.543 Y126.223 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.246 Y126.358 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.0964771
G1 F4473
M204 S6000
G2 X134.856 Y126.747 I3.639 J4.024 E.0024
; OBJECT_ID: 69
; WIPE_START
G1 F15000
G1 X135.246 Y126.358 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 69
M624 AQAAAAAAAAA=
M204 S10000
G1 X134.646 Y133.967 Z4.4 F42000
G1 X134.483 Y136.04 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F4473
M204 S5000
G1 X134.401 Y135.889 E.00527
G3 X136.46 Y132.71 I2.109 J-.891 E.13706
G1 X136.644 Y132.713 E.00565
G3 X134.619 Y136.288 I-.134 J2.285 E.28521
G1 X134.512 Y136.092 E.00685
; WIPE_START
G1 F12000
M204 S6000
G1 X134.401 Y135.889 E-.08798
G1 X134.267 Y135.455 E-.17279
G1 X134.223 Y135.091 E-.13899
G1 X134.25 Y134.637 E-.17281
G1 X134.365 Y134.2 E-.17184
G1 X134.383 Y134.163 E-.01558
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.631 Y137.067 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Top surface
G1 F4473
M204 S2000
G1 X138.585 Y135.113 E.08493
G1 X138.548 Y134.617
G1 X136.129 Y137.036 E.10511
G1 X135.717 Y136.914
G1 X138.425 Y134.206 E.11766
G1 X138.24 Y133.858
G1 X135.369 Y136.729 E.12476
G1 X135.074 Y136.491
G1 X138.004 Y133.56 E.12734
G1 X137.72 Y133.312
G1 X134.827 Y136.205 E.12572
G1 X134.63 Y135.868
G1 X137.384 Y133.114 E.11966
G1 X136.987 Y132.978
G1 X134.494 Y135.471 E.10835
G1 X134.439 Y134.993
G1 X136.505 Y132.926 E.08978
G1 X135.882 Y133.017
G1 X134.535 Y134.363 E.05852
; WIPE_START
G1 F12000
M204 S6000
G1 X135.882 Y133.017 E-.72375
G1 X135.976 Y133.003 E-.03625
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.534 Y135.556 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.334034
G1 F4473
M204 S6000
G1 X138.273 Y135.879 E.00985
; LINE_WIDTH: 0.385639
G3 X137.745 Y136.472 I-3.229 J-2.346 E.02221
; LINE_WIDTH: 0.38146
G1 X137.597 Y136.595 E.00531
; LINE_WIDTH: 0.345536
G1 X137.448 Y136.717 E.00475
; LINE_WIDTH: 0.307999
G1 X137.328 Y136.798 E.00313
; LINE_WIDTH: 0.268842
G1 X137.208 Y136.879 E.00267
; LINE_WIDTH: 0.229685
G1 X137.087 Y136.96 E.00221
; LINE_WIDTH: 0.190528
G1 X136.967 Y137.041 E.00174
; WIPE_START
G1 F15000
G1 X137.087 Y136.96 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.471 Y134.54 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.0896582
G1 F4473
M204 S6000
G1 X138.514 Y134.384 E.00062
; WIPE_START
G1 F15000
G1 X138.471 Y134.54 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.543 Y133.222 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.0977664
G1 F4473
M204 S6000
G1 X137.434 Y133.136 E.00062
; WIPE_START
G1 F15000
G1 X137.543 Y133.222 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.246 Y133.357 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.0964771
G1 F4473
M204 S6000
G2 X134.856 Y133.747 I3.639 J4.024 E.0024
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X135.246 Y133.357 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 69
M625
; start printing object, unique label id: 102
M624 CAAAAAAAAAA=
M204 S10000
G1 X127.705 Y132.178 Z4.4 F42000
G1 X118.894 Y130.801 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F4473
M204 S5000
G1 X119.123 Y130.74 E.00727
G3 X119.488 Y130.711 I.366 J2.26 E.01126
G1 X119.574 Y130.712 E.00266
G3 X118.684 Y130.857 I-.086 J2.287 E.414
G1 X118.836 Y130.816 E.00486
; WIPE_START
G1 F12000
M204 S6000
G1 X119.123 Y130.74 E-.11267
G1 X119.488 Y130.711 E-.13908
G1 X119.574 Y130.712 E-.03293
G1 X119.938 Y130.755 E-.13909
G1 X120.373 Y130.888 E-.1727
G1 X120.751 Y131.093 E-.16353
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.559 Y133.128 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Top surface
G1 F4473
M204 S2000
G1 X119.62 Y135.068 E.08428
G1 X119.115 Y135.04
G1 X121.535 Y132.62 E.10516
G1 X121.412 Y132.21
G1 X118.702 Y134.92 E.11776
G1 X118.353 Y134.735
G1 X121.229 Y131.859 E.12497
G1 X120.991 Y131.564
G1 X118.057 Y134.498 E.12751
G1 X117.809 Y134.212
G1 X120.704 Y131.317 E.12581
G1 X120.367 Y131.121
G1 X117.612 Y133.876 E.11973
G1 X117.474 Y133.481
G1 X119.972 Y130.983 E.10856
G1 X119.497 Y130.925
G1 X117.416 Y133.006 E.09041
G1 X117.515 Y132.373
G1 X118.865 Y131.023 E.05867
; WIPE_START
G1 F12000
M204 S6000
G1 X117.515 Y132.373 E-.72551
G1 X117.501 Y132.463 E-.03449
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.281 Y134.692 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.0908364
G1 F4473
M204 S6000
G3 X118.201 Y134.62 I.314 J-.43 E.00042
; WIPE_START
G1 F15000
G1 X118.281 Y134.692 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.242 Y131.349 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.101247
G1 F4473
M204 S6000
G2 X117.804 Y131.786 I1.981 J2.423 E.00295
; WIPE_START
G1 F15000
G1 X118.071 Y131.5 E-.47999
G1 X118.242 Y131.349 E-.28001
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X121.513 Y133.534 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.283403
M73 P97 R0
G1 F4473
M204 S6000
G1 X121.366 Y133.728 E.00478
; LINE_WIDTH: 0.318541
G1 X121.218 Y133.922 E.00547
; LINE_WIDTH: 0.35368
G1 X121.071 Y134.116 E.00617
; LINE_WIDTH: 0.379428
G3 X120.518 Y134.653 I-2.961 J-2.494 E.02116
; LINE_WIDTH: 0.327516
G1 X120.343 Y134.778 E.005
; LINE_WIDTH: 0.28423
G1 X120.167 Y134.904 E.00424
; LINE_WIDTH: 0.240943
G1 X119.992 Y135.03 E.00348
; close powerlost recovery
M1003 S0
; WIPE_START
G1 F15000
G1 X120.167 Y134.904 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 102
M625
M106 S0
M981 S0 P20000 ; close spaghetti detector
; FEATURE: Custom
; MACHINE_END_GCODE_START
; filament end gcode 

;===== date: 20260513 =====================
G392 S0 ;turn off nozzle clog detect

M400 ; wait for buffer to clear
G92 E0 ; zero the extruder
G90
G1 Z4.4 F900 ; lower z a little
G1 X0 Y128 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos

M1002 judge_flag timelapse_record_flag
M622 J1
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M991 S0 P-1 ;end timelapse at safe pos
M623


M140 S0 ; turn off bed
M106 S0 ; turn off fan
M106 P2 S0 ; turn off remote part cooling fan
M106 P3 S0 ; turn off chamber cooling fan

;G1 X27 F15000 ; wipe

; pull back filament to AMS
M620 S255
G1 X267 F15000
T255
G1 X-28.5 F18000
G1 X-48.2 F3000
G1 X-28.5 F18000
G1 X-48.2 F3000
M621 S255

M104 S0 ; turn off hotend

M400 ; wait all motion done
M17 S
M17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom

    G1 Z104 F600
    G1 Z102

M400 P100
M17 R ; restore z current

G90
G1 X-48 Y180 F3600

M220 S100  ; Reset feedrate magnitude
M201.2 K1.0 ; Reset acc magnitude
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 0

;=====printer finish  sound=========
M17
M400 S1
M1006 S1
M1006 A0 B20 L100 C37 D20 M40 E42 F20 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C46 D10 M80 E46 F10 N80
M1006 A44 B20 L100 C39 D20 M60 E48 F20 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A0 B10 L100 C39 D10 M60 E39 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A0 B10 L100 C39 D10 M60 E39 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A0 B10 L100 C48 D10 M60 E44 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10  N80
M1006 A44 B20 L100 C49 D20 M80 E41 F20 N80
M1006 A0 B20 L100 C0 D20 M60 E0 F20 N80
M1006 A0 B20 L100 C37 D20 M30 E37 F20 N60
M1006 W
;=====printer finish  sound=========

;M17 X0.8 Y0.8 Z0.5 ; lower motor current to 45% power
M400
M18 X Y Z

M73 P100 R0
; EXECUTABLE_BLOCK_END

