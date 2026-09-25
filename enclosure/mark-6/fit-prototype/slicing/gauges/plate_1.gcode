; HEADER_BLOCK_START
; BambuStudio 02.08.02.61
; model printing time: 26m 13s; total estimated time: 32m 29s
; total layer number: 60
; total filament length [mm] : 4882.75
; total filament volume [cm^3] : 11744.40
; total filament weight [g] : 14.80
; model label id: 80,91,102,113,124
; object max height: 1.60,12.00,12.00,12.00,12.00
; filament_density: 1.26
; filament_diameter: 1.75
; max_z_height: 12.00
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
; print_settings_id = Harmony M6 fit - 0.20mm A1
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
M73 P0 R32
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
M73 P1 R31
G1 E-0.5 F300

G1 X-28.5 F30000
M73 P2 R31
G1 X-48.2 F3000
M73 P3 R31
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
    G1 X-48.2 F3000
M73 P4 R31
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
    
M73 P4 R30
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
M73 P18 R26
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
    G29 A1 X94.7303 Y43.5 I66.5396 J169
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
; layer num/total_layer_count: 1/60
; update layer progress
M73 L1
M991 S0 P0 ;notify layer change
M106 S0
; OBJECT_ID: 80
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X144.562 Y83.551 F42000
M204 S6000
G1 Z.4
G1 Z.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.5
M73 P19 R26
G1 F3000
M204 S500
G1 X144.38 Y83.281 E.01215
G3 X145.642 Y80.818 I1.47 J-.802 E.12134
G1 X145.808 Y80.805 E.00622
G3 X144.602 Y83.596 I.041 J1.674 E.24988
; WIPE_START
G1 X144.38 Y83.281 E-.14656
G1 X144.249 Y82.974 E-.12677
G1 X144.183 Y82.647 E-.12678
G1 X144.183 Y82.313 E-.12687
G1 X144.248 Y81.99 E-.1254
G1 X144.34 Y81.753 E-.09652
G1 X144.356 Y81.728 E-.01109
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X138.431 Y86.54 Z.6 F42000
G1 X96.961 Y120.221 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X97.029 Y119.88 E.01298
G3 X98.805 Y118.383 I2.04 J.619 E.09144
G1 X99.017 Y118.368 E.00792
G3 X96.948 Y120.288 I.053 J2.131 E.38399
G1 X96.95 Y120.28 E.00028
M204 S6000
G1 X97.407 Y120.311 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X97.468 Y120.01 E.01145
G3 X98.862 Y118.838 I1.601 J.489 E.0717
G1 X99.028 Y118.825 E.00622
G3 X97.4 Y120.37 I.041 J1.674 E.30022
; WIPE_START
G1 X97.468 Y120.01 E-.13949
G1 X97.56 Y119.773 E-.0966
G1 X97.734 Y119.488 E-.1267
G1 X97.961 Y119.244 E-.12672
G1 X98.232 Y119.049 E-.12678
G1 X98.536 Y118.912 E-.12688
G1 X98.58 Y118.902 E-.01683
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X99.029 Y111.283 Z.6 F42000
G1 X101.184 Y74.75 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X101.177 Y74.818 E.00254
G3 X98.805 Y72.383 I-2.108 J-.319 E.35233
G1 X99.017 Y72.368 E.00792
G3 X101.201 Y74.486 I.053 J2.131 E.12619
G1 X101.188 Y74.69 E.00764
M204 S6000
G1 X100.729 Y74.718 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X100.725 Y74.749 E.00117
G3 X98.862 Y72.838 I-1.656 J-.251 E.27675
G1 X99.028 Y72.825 E.00622
G3 X100.744 Y74.492 I.041 J1.674 E.09923
G1 X100.733 Y74.658 E.00623
; WIPE_START
G1 X100.725 Y74.749 E-.03474
G1 X100.644 Y75.073 E-.12672
G1 X100.5 Y75.373 E-.12672
G1 X100.298 Y75.64 E-.12685
G1 X100.048 Y75.86 E-.12677
G1 X99.759 Y76.027 E-.12677
G1 X99.531 Y76.104 E-.09143
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X105.001 Y81.427 Z.6 F42000
G1 X155.41 Y130.486 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X155.263 Y130.353 E.00738
G3 X156.747 Y125.929 I1.807 J-1.854 E.21643
G1 X157.005 Y125.91 E.00964
G3 X155.456 Y130.524 I.064 J2.588 E.37021
G1 X155.456 Y130.523 E.00001
M204 S6000
G1 X155.738 Y130.152 F42000
G1 F3000
M204 S500
G1 X155.582 Y130.025 E.00749
G3 X156.804 Y126.384 I1.488 J-1.527 E.1782
G1 X157.017 Y126.368 E.00794
G3 X155.914 Y130.29 I.053 J2.131 E.29691
G1 X155.785 Y130.189 E.00609
M204 S6000
G1 X156.013 Y129.798 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X155.788 Y129.576 E.01177
G3 X156.861 Y126.838 I1.282 J-1.077 E.13375
G1 X157.028 Y126.825 E.00623
G3 X156.06 Y129.835 I.042 J1.674 E.23784
; WIPE_START
G1 X155.788 Y129.576 E-.14269
G1 X155.599 Y129.301 E-.12664
G1 X155.469 Y128.994 E-.12683
G1 X155.403 Y128.667 E-.12676
G1 X155.403 Y128.333 E-.12684
G1 X155.46 Y128.049 E-.11024
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X147.861 Y127.334 Z.6 F42000
G1 X96.766 Y122.527 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X97.306 Y123.004 E.02682
G1 X96.766 Y123.004 E.02011
G1 X96.766 Y122.587 E.01551
; WIPE_START
G1 X97.306 Y123.004 E-.31633
G1 X96.766 Y123.004 E-.25049
G1 X96.766 Y122.587 E-.19318
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X104.191 Y120.82 Z.6 F42000
G1 X143.152 Y111.548 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X143.249 Y111.371 E.00751
G3 X145.471 Y109.935 I2.6 J1.587 E.10192
G1 X145.774 Y109.913 E.01133
G3 X143.104 Y111.637 I.075 J3.045 E.5884
G1 X143.124 Y111.601 E.00154
M204 S6000
G1 X143.554 Y111.766 F42000
G1 F3000
M204 S500
G1 X143.639 Y111.61 E.00666
G3 X145.528 Y110.389 I2.21 J1.349 E.08662
G1 X145.785 Y110.37 E.00963
G3 X143.516 Y111.836 I.064 J2.588 E.50006
G1 X143.525 Y111.819 E.00069
M204 S6000
G1 X143.971 Y111.964 F42000
G1 F3000
M204 S500
G1 X144.15 Y111.672 E.01275
G3 X145.585 Y110.843 I1.7 J1.286 E.06339
G1 X145.797 Y110.828 E.00792
G3 X143.929 Y112.034 I.053 J2.131 E.41173
G1 X143.94 Y112.015 E.00082
M204 S6000
G1 X144.36 Y112.202 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X144.514 Y111.949 E.01105
G3 X145.642 Y111.298 I1.335 J1.01 E.04979
G1 X145.808 Y111.285 E.00622
G3 X144.331 Y112.254 I.041 J1.674 E.32252
; WIPE_START
G1 X144.514 Y111.949 E-.13549
G1 X144.741 Y111.704 E-.12675
G1 X145.012 Y111.509 E-.12678
G1 X145.316 Y111.372 E-.12685
G1 X145.642 Y111.298 E-.12676
G1 X145.808 Y111.285 E-.06348
G1 X145.95 Y111.296 E-.05389
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X138.335 Y111.818 Z.6 F42000
G1 X113.279 Y113.539 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X113.241 Y113.711 E.00658
G3 X109.911 Y109.935 I-2.952 J-.753 E.49224
G1 X110.214 Y109.913 E.01133
G3 X113.301 Y113.415 I.075 J3.046 E.1981
G1 X113.289 Y113.48 E.00246
M204 S6000
G1 X112.831 Y113.448 F42000
G1 F3000
M204 S500
G1 X112.798 Y113.598 E.00573
G3 X109.968 Y110.389 I-2.509 J-.64 E.41834
G1 X110.225 Y110.37 E.00963
G3 X112.849 Y113.346 I.064 J2.588 E.16835
G1 X112.841 Y113.389 E.00162
M204 S6000
G1 X112.373 Y113.382 F42000
G1 F3000
M204 S500
G1 X112.292 Y113.689 E.01182
G3 X110.025 Y110.843 I-2.003 J-.73 E.33652
G1 X110.237 Y110.828 E.00792
G3 X112.397 Y113.278 I.053 J2.131 E.13861
G1 X112.386 Y113.323 E.00173
M204 S6000
G1 X111.931 Y113.269 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X111.863 Y113.532 E.01013
G3 X110.082 Y111.298 I-1.573 J-.573 E.26432
G1 X110.248 Y111.285 E.00622
G3 X111.945 Y113.209 I.041 J1.674 E.10887
G1 X111.945 Y113.211 E.00005
; WIPE_START
G1 X111.863 Y113.532 E-.12612
G1 X111.72 Y113.833 E-.1267
G1 X111.518 Y114.1 E-.12685
G1 X111.268 Y114.32 E-.12679
G1 X110.979 Y114.487 E-.12673
G1 X110.663 Y114.593 E-.12681
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X111.045 Y106.97 Z.6 F42000
G1 X112.151 Y84.89 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X112.067 Y84.952 E.00391
G3 X109.911 Y79.455 I-1.778 J-2.474 E.41305
G1 X110.214 Y79.433 E.01133
G3 X112.305 Y84.762 I.075 J3.046 E.27723
G1 X112.198 Y84.851 E.00518
M204 S6000
G1 X111.866 Y84.532 F42000
G1 F3000
M204 S500
G1 X111.8 Y84.581 E.00306
G3 X109.968 Y79.909 I-1.511 J-2.102 E.35103
G1 X110.225 Y79.89 E.00963
G3 X112.002 Y84.42 I.064 J2.588 E.23561
G1 X111.913 Y84.494 E.00433
M204 S6000
G1 X111.599 Y84.155 F42000
G1 F3000
M204 S500
G1 X111.533 Y84.21 E.00317
G3 X110.025 Y80.363 I-1.244 J-1.731 E.28902
G1 X110.237 Y80.348 E.00792
G3 X111.852 Y83.929 I.053 J2.131 E.18609
G1 X111.644 Y84.115 E.01041
M204 S6000
G1 X111.298 Y83.814 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X111.267 Y83.839 E.00147
G3 X110.082 Y80.818 I-.977 J-1.36 E.22701
G1 X110.248 Y80.805 E.00622
G3 X111.517 Y83.618 I.041 J1.674 E.14617
G1 X111.342 Y83.774 E.00871
; WIPE_START
G1 X111.267 Y83.839 E-.03782
G1 X110.979 Y84.007 E-.12667
G1 X110.663 Y84.113 E-.12681
G1 X110.332 Y84.155 E-.12678
G1 X110.164 Y84.151 E-.06351
G1 X109.836 Y84.093 E-.12673
G1 X109.525 Y83.971 E-.12682
G1 X109.47 Y83.935 E-.02485
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X116.976 Y82.547 Z.6 F42000
G1 X121.574 Y81.696 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X142.908 Y81.696 E.79461
G2 X148.792 Y81.696 I2.942 J.787 E.41563
G1 X159.574 Y81.696 E.40158
G1 X159.574 Y126.722 E1.67705
G2 X157.895 Y125.566 I-2.714 J2.142 E.07706
G2 X159.574 Y130.253 I-.82 J2.937 E.49678
G1 X159.574 Y210.804 E3.00023
G1 X137.097 Y210.804 E.83716
G2 X137.983 Y209.399 I-2.384 J-2.484 E.06247
G2 X132.766 Y206.494 I-2.92 J-.893 E.3092
G1 X132.766 Y123.004 E3.1097
G1 X100.863 Y123.004 E1.18826
G2 X101.671 Y122.09 I-2.694 J-3.194 E.0456
G2 X96.766 Y118.494 I-2.608 J-1.586 E.33752
G1 X96.766 Y76.527 E1.5631
G2 X98.54 Y77.502 I2.467 J-2.389 E.07654
G2 X96.766 Y72.494 I.524 J-3.004 E.47342
G1 X96.766 Y45.196 E1.01674
G1 X140.874 Y45.196 E1.64284
G1 X140.874 Y47.304 E.0785
G1 X136.874 Y47.304 E.14898
G1 X136.874 Y66.196 E.70367
G1 X140.874 Y66.196 E.14898
G1 X140.874 Y68.804 E.09712
G1 X121.574 Y68.804 E.71885
G1 X121.574 Y81.636 E.47796
M204 S6000
G1 X122.031 Y81.239 F42000
G1 F3000
M204 S500
G1 X143.565 Y81.239 E.80208
G2 X148.124 Y81.239 I2.279 J1.234 E.3991
G1 X160.031 Y81.239 E.44347
M73 P19 R25
G1 X160.031 Y211.261 E4.84282
M73 P20 R25
G1 X135.685 Y211.261 E.9068
G1 X135.652 Y211.024 E.0089
G2 X132.549 Y207.914 I-.581 J-2.523 E.41058
G1 X132.309 Y207.884 E.00901
G1 X132.309 Y123.461 E3.14443
G1 X96.309 Y123.461 E1.34086
G1 X96.309 Y121.116 E.08732
G1 X96.549 Y121.086 E.00901
G2 X96.549 Y119.914 I2.518 J-.586 E.56094
G1 X96.309 Y119.884 E.00901
G1 X96.309 Y75.116 E1.66741
G1 X96.549 Y75.086 E.00901
G2 X96.549 Y73.914 I2.518 J-.586 E.56094
G1 X96.309 Y73.884 E.00901
G1 X96.309 Y44.739 E1.08552
G1 X141.331 Y44.739 E1.67689
G1 X141.331 Y47.761 E.11255
G1 X137.331 Y47.761 E.14898
G1 X137.331 Y65.739 E.66962
G1 X141.331 Y65.739 E.14898
G1 X141.331 Y69.261 E.13117
G1 X122.031 Y69.261 E.71885
G1 X122.031 Y81.179 E.44391
; WIPE_START
G1 X124.031 Y81.185 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X124.633 Y88.793 Z.6 F42000
G1 X133.961 Y206.683 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X134.003 Y206.653 E.00193
G3 X134.804 Y206.384 I1.066 J1.846 E.03167
G1 X135.017 Y206.368 E.00794
G3 X133.659 Y206.901 I.053 J2.131 E.44341
G1 X133.913 Y206.718 E.01165
M204 S6000
G1 X134.227 Y207.053 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X134.232 Y207.049 E.00024
G3 X134.861 Y206.838 I.837 J1.45 E.02488
G1 X135.028 Y206.825 E.00623
M73 P21 R25
G3 X133.961 Y207.244 I.042 J1.674 E.34828
G1 X134.178 Y207.088 E.00995
; WIPE_START
G1 X134.232 Y207.049 E-.02525
G1 X134.536 Y206.912 E-.12679
G1 X134.861 Y206.838 E-.1266
G1 X135.028 Y206.825 E-.06359
G1 X135.361 Y206.85 E-.12678
G1 X135.682 Y206.94 E-.12674
G1 X135.834 Y207.009 E-.06351
G1 X136.057 Y207.153 E-.10075
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X132.549 Y209.086 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X132.594 Y209.264 E.00682
G2 X134.478 Y211.031 I2.515 J-.794 E.10055
G1 X134.441 Y211.261 E.00868
G1 X132.309 Y211.261 E.0794
G1 X132.309 Y209.116 E.07988
G1 X132.49 Y209.094 E.00678
; WIPE_START
G1 X132.594 Y209.264 E-.07587
G1 X132.683 Y209.506 E-.09819
G1 X132.795 Y209.739 E-.09819
G1 X132.929 Y209.959 E-.09807
G1 X133.085 Y210.165 E-.0981
G1 X133.261 Y210.355 E-.09816
G1 X133.455 Y210.525 E-.09811
G1 X133.658 Y210.672 E-.09532
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X133.004 Y203.068 Z.6 F42000
G1 X122.488 Y80.782 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X144.54 Y80.782 E.82134
G2 X146.115 Y84.596 I1.329 J1.684 E.20682
G2 X147.484 Y81.109 I-.284 J-2.124 E.16981
G1 X147.181 Y80.782 E.0166
G1 X160.488 Y80.782 E.49564
G1 X160.488 Y211.718 E4.87686
G1 X131.852 Y211.718 E1.06658
G1 X131.852 Y123.918 E3.27022
G1 X95.852 Y123.918 E1.34086
G1 X95.852 Y44.282 E2.96613
G1 X141.788 Y44.282 E1.71094
G1 X141.788 Y48.218 E.1466
G1 X137.788 Y48.218 E.14898
G1 X137.788 Y65.282 E.63557
G1 X141.788 Y65.282 E.14898
G1 X141.788 Y69.718 E.16522
G1 X122.488 Y69.718 E.71885
G1 X122.488 Y80.722 E.40986
M204 S6000
G1 X122.945 Y80.325 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X160.945 Y80.325 E1.41536
G1 X160.945 Y212.175 E4.91091
G1 X131.395 Y212.175 E1.10063
G1 X131.395 Y124.375 E3.27022
G1 X95.395 Y124.375 E1.34086
G1 X95.395 Y43.825 E3.00018
G1 X142.245 Y43.825 E1.74499
G1 X142.245 Y48.675 E.18064
G1 X138.245 Y48.675 E.14898
G1 X138.245 Y64.825 E.60153
G1 X142.245 Y64.825 E.14898
G1 X142.245 Y70.175 E.19927
G1 X122.945 Y70.175 E.71885
G1 X122.945 Y80.265 E.37581
; WIPE_START
G1 X124.945 Y80.268 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G17
G3 Z.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 80
M625
; object ids of layer 1 start: 80,91,102,113,124
M624 HwAAAAAAAAA=
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


; object ids of this layer1 end: 80,91,102,113,124
M625
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X144.866 Y80.818 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.116654
G1 F3000
M204 S500
G1 X144.953 Y80.756 E.00064
; LINE_WIDTH: 0.144113
G1 X145.04 Y80.693 E.00088
; LINE_WIDTH: 0.158859
M73 P22 R25
G1 X145.245 Y80.554 E.00234
M204 S6000
G1 X145.51 Y80.581 F42000
; LINE_WIDTH: 0.108395
G1 F3000
M204 S500
G1 X145.417 Y80.589 E.0005
; LINE_WIDTH: 0.12734
G1 X145.322 Y80.602 E.00066
; LINE_WIDTH: 0.154398
G1 X145.22 Y80.616 E.00093
; LINE_WIDTH: 0.185117
G1 X144.993 Y80.66 E.00269
; WIPE_START
G1 X145.22 Y80.616 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X146.193 Y80.58 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.120225
G1 F3000
M204 S500
G1 X146.376 Y80.601 E.00116
; LINE_WIDTH: 0.15362
G1 X146.476 Y80.617 E.00091
; LINE_WIDTH: 0.185491
G1 X146.571 Y80.633 E.00112
; LINE_WIDTH: 0.212036
G1 X146.769 Y80.675 E.0028
M204 S6000
G1 X146.915 Y80.869 F42000
; LINE_WIDTH: 0.116641
G1 F3000
M204 S500
G1 X146.831 Y80.803 E.00064
; LINE_WIDTH: 0.154964
G2 X146.506 Y80.554 I-4.99 J6.169 E.00374
; WIPE_START
G1 X146.831 Y80.803 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X148.848 Y88.164 Z.6 F42000
G1 X159.21 Y125.988 Z.6
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.111689
G1 F3000
M204 S500
G1 X159.345 Y126.085 E.00093
M204 S6000
G1 X159.49 Y127.008 F42000
; LINE_WIDTH: 0.115129
G1 F3000
M204 S500
G1 X159.582 Y127.13 E.0009
; LINE_WIDTH: 0.146075
G1 X159.654 Y127.234 E.00107
; LINE_WIDTH: 0.183307
G1 X159.723 Y127.336 E.0014
; LINE_WIDTH: 0.192826
G1 X159.732 Y127.374 E.00048
; LINE_WIDTH: 0.162748
G1 X159.755 Y127.507 E.00132
; LINE_WIDTH: 0.122489
G1 X159.777 Y127.633 E.00083
; WIPE_START
G1 X159.755 Y127.507 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X159.716 Y129.727 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.124364
G1 F3000
M204 S500
G2 X159.777 Y129.365 I-7.369 J-1.424 E.00244
M204 S6000
G1 X159.802 Y129.49 F42000
; LINE_WIDTH: 0.152461
G1 F3000
M204 S500
G1 X159.647 Y129.744 E.00265
; LINE_WIDTH: 0.115126
G1 X159.561 Y129.87 E.0009
; WIPE_START
G1 X159.647 Y129.744 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X158.825 Y131.208 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.50129
G1 F6300
M204 S500
G1 X159.185 Y131.568 E.01901
G1 X159.185 Y132.216 E.02421
G1 X158.562 Y131.593 E.03292
G3 X158.098 Y131.777 I-1.706 J-3.624 E.01866
G1 X159.185 Y132.865 E.05744
G1 X159.185 Y133.513 E.02421
G1 X157.57 Y131.898 E.08531
G3 X156.955 Y131.931 I-.506 J-3.64 E.02302
G1 X159.185 Y134.161 E.11778
G1 X159.185 Y134.809 E.02421
G1 X155.879 Y131.504 E.17462
; WIPE_START
G1 X157.294 Y132.918 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X157.611 Y125.292 Z.6 F42000
G1 X159.391 Y82.508 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X158.967 Y82.085 E.02236
G1 X158.319 Y82.085 E.02421
G1 X159.185 Y82.951 E.04574
G1 X159.185 Y83.599 E.02421
G1 X157.671 Y82.085 E.07998
G1 X157.023 Y82.085 E.02421
G1 X159.185 Y84.247 E.11422
G1 X159.185 Y84.895 E.02421
G1 X156.375 Y82.085 E.14846
G1 X155.726 Y82.085 E.02421
G1 X159.185 Y85.544 E.1827
G1 X159.185 Y86.192 E.02421
G1 X155.078 Y82.085 E.21694
G1 X154.43 Y82.085 E.02421
G1 X159.185 Y86.84 E.25119
G1 X159.185 Y87.488 E.02421
G1 X153.782 Y82.085 E.28543
G1 X153.133 Y82.085 E.02421
G1 X159.185 Y88.136 E.31967
G1 X159.185 Y88.785 E.02421
G1 X152.485 Y82.085 E.35391
G1 X151.837 Y82.085 E.02421
G1 X159.185 Y89.433 E.38815
G1 X159.185 Y90.081 E.02421
G1 X151.189 Y82.085 E.42239
G1 X150.54 Y82.085 E.02421
G1 X159.185 Y90.729 E.45664
G1 X159.185 Y91.378 E.02421
G1 X149.892 Y82.085 E.49088
G1 X149.261 Y82.085 E.02357
G1 X149.265 Y82.106 E.0008
G1 X159.185 Y92.026 E.524
G1 X159.185 Y92.674 E.02421
G1 X149.272 Y82.761 E.52364
G3 X149.183 Y83.32 I-2.867 J-.172 E.02117
G1 X159.185 Y93.322 E.52836
G1 X159.185 Y93.971 E.02421
G1 X149.018 Y83.803 E.53707
G3 X148.803 Y84.236 I-2.269 J-.857 E.01809
G1 X159.185 Y94.619 E.54844
G1 X159.185 Y95.267 E.02421
G1 X148.537 Y84.619 E.56248
G3 X148.227 Y84.957 I-1.847 J-1.38 E.01717
G1 X159.185 Y95.915 E.57884
G1 X159.185 Y96.563 E.02421
G1 X147.876 Y85.255 E.59735
G3 X147.477 Y85.504 I-2.671 J-3.842 E.01758
G1 X159.185 Y97.212 E.61845
G1 X159.185 Y97.86 E.02421
G1 X147.03 Y85.705 E.64207
G3 X146.524 Y85.847 I-1.27 J-3.545 E.01965
G1 X159.185 Y98.508 E.66879
G1 X159.185 Y99.156 E.02421
G1 X145.944 Y85.916 E.69942
G3 X145.243 Y85.863 I-.178 J-2.315 E.02636
G1 X159.391 Y100.01 E.74731
; WIPE_START
G1 X157.977 Y98.596 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X152.692 Y93.089 Z.6 F42000
G1 X142.624 Y82.596 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X142.113 Y82.085 E.02698
G1 X141.465 Y82.085 E.02421
G1 X142.745 Y83.364 E.06758
; WIPE_START
G1 X141.465 Y82.085 E-.68757
G1 X141.656 Y82.085 E-.07243
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X140.611 Y81.879 Z.6 F42000
G1 Z.2
G1 E.8 F1800
M73 P23 R25
G1 F6300
M204 S500
G1 X159.185 Y100.453 E.98112
G1 X159.185 Y101.101 E.02421
G1 X140.169 Y82.085 E1.0045
G1 X139.52 Y82.085 E.02421
G1 X159.185 Y101.749 E1.03874
G1 X159.185 Y102.398 E.02421
M73 P23 R24
G1 X138.872 Y82.085 E1.07298
G1 X138.224 Y82.085 E.02421
G1 X159.185 Y103.046 E1.10722
G1 X159.185 Y103.694 E.02421
G1 X137.576 Y82.085 E1.14147
G1 X136.928 Y82.085 E.02421
G1 X159.185 Y104.342 E1.17571
G1 X159.185 Y104.991 E.02421
G1 X136.279 Y82.085 E1.20995
G1 X135.631 Y82.085 E.02421
G1 X159.185 Y105.639 E1.24419
G1 X159.185 Y106.287 E.02421
G1 X134.983 Y82.085 E1.27843
G1 X134.335 Y82.085 E.02421
G1 X159.185 Y106.935 E1.31267
G1 X159.185 Y107.583 E.02421
G1 X133.686 Y82.085 E1.34691
G1 X133.038 Y82.085 E.02421
G1 X159.185 Y108.232 E1.38116
G1 X159.185 Y108.88 E.02421
G1 X132.39 Y82.085 E1.4154
G1 X131.742 Y82.085 E.02421
G1 X159.185 Y109.528 E1.44964
G1 X159.185 Y110.176 E.02421
G1 X131.093 Y82.085 E1.48388
G1 X130.445 Y82.085 E.02421
G1 X159.185 Y110.825 E1.51812
G1 X159.185 Y111.473 E.02421
G1 X129.797 Y82.085 E1.55236
G1 X129.149 Y82.085 E.02421
G1 X159.185 Y112.121 E1.5866
G1 X159.185 Y112.769 E.02421
G1 X128.501 Y82.085 E1.62085
G1 X127.852 Y82.085 E.02421
G1 X159.185 Y113.418 E1.65509
G1 X159.185 Y114.066 E.02421
G1 X127.204 Y82.085 E1.68933
G1 X126.556 Y82.085 E.02421
G1 X159.185 Y114.714 E1.72357
G1 X159.185 Y115.362 E.02421
G1 X125.908 Y82.085 E1.75781
G1 X125.259 Y82.085 E.02421
G1 X159.185 Y116.01 E1.79205
G1 X159.185 Y116.659 E.02421
G1 X124.611 Y82.085 E1.8263
G1 X123.963 Y82.085 E.02421
G1 X159.185 Y117.307 E1.86054
G1 X159.185 Y117.955 E.02421
G1 X123.315 Y82.085 E1.89478
G1 X122.666 Y82.085 E.02421
G1 X159.185 Y118.603 E1.92902
G1 X159.185 Y119.252 E.02421
G1 X121.812 Y81.879 E1.97413
; WIPE_START
G1 X123.227 Y83.293 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X128.604 Y77.877 Z.6 F42000
G1 X140.021 Y66.379 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X140.485 Y66.844 E.02454
G1 X140.485 Y67.492 E.02421
G1 X139.578 Y66.585 E.04791
G1 X138.93 Y66.585 E.02421
G1 X140.485 Y68.14 E.08215
G1 X140.485 Y68.415 E.01028
G1 X140.112 Y68.415 E.01393
G1 X138.282 Y66.585 E.0967
G1 X137.633 Y66.585 E.02421
G1 X139.67 Y68.621 E.10756
; WIPE_START
G1 X138.255 Y67.207 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X139.139 Y59.626 Z.6 F42000
G1 X140.691 Y46.306 Z.6
G1 Z.2
G1 E.8 F1800
M73 P24 R24
G1 F6300
M204 S500
G1 X139.97 Y45.585 E.03809
G1 X139.322 Y45.585 E.02421
G1 X140.485 Y46.748 E.06146
G1 X140.485 Y46.915 E.00624
G1 X140.004 Y46.915 E.01798
G1 X138.673 Y45.585 E.07028
G1 X138.025 Y45.585 E.02421
G1 X139.356 Y46.915 E.07028
G1 X138.707 Y46.915 E.02421
G1 X137.377 Y45.585 E.07028
G1 X136.729 Y45.585 E.02421
G1 X138.059 Y46.915 E.07028
G1 X137.411 Y46.915 E.02421
G1 X136.08 Y45.585 E.07028
G1 X135.432 Y45.585 E.02421
G1 X136.763 Y46.915 E.07028
G1 X136.485 Y46.915 E.01037
G1 X136.485 Y47.286 E.01384
G1 X134.784 Y45.585 E.08986
G1 X134.136 Y45.585 E.02421
G1 X136.485 Y47.934 E.1241
G1 X136.485 Y48.582 E.02421
G1 X133.487 Y45.585 E.15835
G1 X132.839 Y45.585 E.02421
G1 X136.485 Y49.231 E.19259
G1 X136.485 Y49.879 E.02421
G1 X132.191 Y45.585 E.22683
G1 X131.543 Y45.585 E.02421
G1 X136.485 Y50.527 E.26107
G1 X136.485 Y51.175 E.02421
G1 X130.895 Y45.585 E.29531
G1 X130.246 Y45.585 E.02421
G1 X136.485 Y51.824 E.32955
G1 X136.485 Y52.472 E.02421
G1 X129.598 Y45.585 E.36379
G1 X128.95 Y45.585 E.02421
G1 X136.485 Y53.12 E.39804
G1 X136.485 Y53.768 E.02421
G1 X128.302 Y45.585 E.43228
G1 X127.653 Y45.585 E.02421
G1 X136.485 Y54.417 E.46652
G1 X136.485 Y55.065 E.02421
G1 X127.005 Y45.585 E.50076
G1 X126.357 Y45.585 E.02421
G1 X136.485 Y55.713 E.535
G1 X136.485 Y56.361 E.02421
G1 X125.709 Y45.585 E.56924
G1 X125.06 Y45.585 E.02421
G1 X136.485 Y57.009 E.60349
G1 X136.485 Y57.658 E.02421
G1 X124.412 Y45.585 E.63773
G1 X123.764 Y45.585 E.02421
G1 X136.485 Y58.306 E.67197
G1 X136.485 Y58.954 E.02421
G1 X123.116 Y45.585 E.70621
G1 X122.467 Y45.585 E.02421
G1 X136.485 Y59.602 E.74045
G1 X136.485 Y60.251 E.02421
G1 X121.819 Y45.585 E.77469
G1 X121.171 Y45.585 E.02421
G1 X136.485 Y60.899 E.80893
G1 X136.485 Y61.547 E.02421
G1 X120.523 Y45.585 E.84318
G1 X119.875 Y45.585 E.02421
G1 X136.485 Y62.195 E.87742
G1 X136.485 Y62.844 E.02421
G1 X119.226 Y45.585 E.91166
G1 X118.578 Y45.585 E.02421
G1 X136.485 Y63.492 E.9459
G1 X136.485 Y64.14 E.02421
G1 X117.93 Y45.585 E.98014
G1 X117.282 Y45.585 E.02421
G1 X136.485 Y64.788 E1.01438
G1 X136.485 Y65.436 E.02421
G1 X116.633 Y45.585 E1.04862
G1 X115.985 Y45.585 E.02421
G1 X136.485 Y66.085 E1.08287
G1 X136.485 Y66.585 E.01868
G1 X136.985 Y66.585 E.01868
G1 X138.816 Y68.415 E.0967
G1 X138.167 Y68.415 E.02421
G1 X115.337 Y45.585 E1.20597
G1 X114.689 Y45.585 E.02421
G1 X137.519 Y68.415 E1.20597
G1 X136.871 Y68.415 E.02421
G1 X114.04 Y45.585 E1.20597
G1 X113.392 Y45.585 E.02421
G1 X136.223 Y68.415 E1.20597
G1 X135.575 Y68.415 E.02421
G1 X112.744 Y45.585 E1.20597
G1 X112.096 Y45.585 E.02421
G1 X134.926 Y68.415 E1.20597
G1 X134.278 Y68.415 E.02421
G1 X111.448 Y45.585 E1.20597
G1 X110.799 Y45.585 E.02421
G1 X133.63 Y68.415 E1.20597
G1 X132.982 Y68.415 E.02421
G1 X110.151 Y45.585 E1.20597
G1 X109.503 Y45.585 E.02421
G1 X132.333 Y68.415 E1.20597
G1 X131.685 Y68.415 E.02421
G1 X108.855 Y45.585 E1.20597
G1 X108.206 Y45.585 E.02421
G1 X131.037 Y68.415 E1.20597
G1 X130.389 Y68.415 E.02421
G1 X107.558 Y45.585 E1.20597
G1 X106.91 Y45.585 E.02421
G1 X129.74 Y68.415 E1.20597
G1 X129.092 Y68.415 E.02421
G1 X106.262 Y45.585 E1.20597
G1 X105.613 Y45.585 E.02421
G1 X128.444 Y68.415 E1.20597
G1 X127.796 Y68.415 E.02421
G1 X104.965 Y45.585 E1.20597
G1 X104.317 Y45.585 E.02421
G1 X127.148 Y68.415 E1.20597
G1 X126.499 Y68.415 E.02421
G1 X103.669 Y45.585 E1.20597
G1 X103.02 Y45.585 E.02421
G1 X125.851 Y68.415 E1.20597
G1 X125.203 Y68.415 E.02421
G1 X102.372 Y45.585 E1.20597
G1 X101.724 Y45.585 E.02421
G1 X124.555 Y68.415 E1.20597
G1 X123.906 Y68.415 E.02421
G1 X101.076 Y45.585 E1.20597
G1 X100.428 Y45.585 E.02421
M73 P25 R24
G1 X123.258 Y68.415 E1.20597
G1 X122.61 Y68.415 E.02421
G1 X99.779 Y45.585 E1.20597
G1 X99.131 Y45.585 E.02421
G1 X121.962 Y68.415 E1.20597
G1 X121.313 Y68.415 E.02421
G1 X98.483 Y45.585 E1.20597
G1 X97.835 Y45.585 E.02421
G1 X121.185 Y68.935 E1.23344
G1 X121.185 Y69.583 E.02421
G1 X97.186 Y45.585 E1.26768
G1 X97.155 Y45.585 E.00119
G1 X97.155 Y46.201 E.02302
G1 X121.185 Y70.232 E1.26936
G1 X121.185 Y70.88 E.02421
G1 X97.155 Y46.849 E1.26936
G1 X97.155 Y47.498 E.02421
G1 X121.185 Y71.528 E1.26936
G1 X121.185 Y72.176 E.02421
G1 X97.155 Y48.146 E1.26936
G1 X97.155 Y48.794 E.02421
G1 X121.185 Y72.825 E1.26936
G1 X121.185 Y73.473 E.02421
G1 X97.155 Y49.442 E1.26936
G1 X97.155 Y50.091 E.02421
G1 X121.185 Y74.121 E1.26936
G1 X121.185 Y74.769 E.02421
G1 X97.155 Y50.739 E1.26936
G1 X97.155 Y51.387 E.02421
G1 X121.185 Y75.418 E1.26936
G1 X121.185 Y76.066 E.02421
G1 X97.155 Y52.035 E1.26936
G1 X97.155 Y52.683 E.02421
G1 X121.185 Y76.714 E1.26936
G1 X121.185 Y77.362 E.02421
G1 X97.155 Y53.332 E1.26936
G1 X97.155 Y53.98 E.02421
G1 X121.185 Y78.01 E1.26936
G1 X121.185 Y78.659 E.02421
G1 X97.155 Y54.628 E1.26936
G1 X97.155 Y55.276 E.02421
G1 X121.185 Y79.307 E1.26936
G1 X121.185 Y79.955 E.02421
G1 X97.155 Y55.925 E1.26936
G1 X97.155 Y56.573 E.02421
G1 X121.185 Y80.603 E1.26936
G1 X121.185 Y81.252 E.02421
G1 X97.155 Y57.221 E1.26936
G1 X97.155 Y57.869 E.02421
G1 X159.185 Y119.9 E3.27663
G1 X159.185 Y120.548 E.02421
G1 X97.155 Y58.518 E3.27663
G1 X97.155 Y59.166 E.02421
G1 X159.185 Y121.196 E3.27663
G1 X159.185 Y121.845 E.02421
G1 X149.047 Y111.706 E.53553
G2 X147.098 Y109.758 I-3.188 J1.239 E.10593
G1 X97.155 Y59.814 E2.63818
G1 X97.155 Y60.462 E.02421
G1 X146.241 Y109.549 E2.59291
G2 X145.582 Y109.537 I-.391 J3.441 E.02469
G1 X97.155 Y61.11 E2.55805
G1 X97.155 Y61.759 E.02421
G1 X145.022 Y109.627 E2.52851
G2 X144.535 Y109.788 I.564 J2.516 E.01919
G1 X97.155 Y62.407 E2.50279
G1 X97.155 Y63.055 E.02421
G1 X144.102 Y110.002 E2.47988
G2 X143.719 Y110.268 I1.136 J2.043 E.01742
G1 X97.155 Y63.703 E2.45967
G1 X97.155 Y64.352 E.02421
G1 X143.378 Y110.575 E2.44166
G2 X143.081 Y110.927 I3.303 J3.092 E.01719
M73 P26 R24
G1 X113.547 Y81.393 E1.56005
G2 X111.379 Y79.224 I-3.232 J1.064 E.11882
G1 X97.155 Y65 E.75138
G1 X97.155 Y65.648 E.02421
G1 X110.561 Y79.054 E.70814
G2 X109.923 Y79.065 I-.242 J4.589 E.02383
M73 P26 R23
G1 X97.155 Y66.296 E.67447
G1 X97.155 Y66.945 E.02421
G1 X109.38 Y79.17 E.64577
G2 X108.899 Y79.338 I.599 J2.483 E.01904
G1 X97.155 Y67.593 E.6204
G1 X97.155 Y68.241 E.02421
G1 X100.157 Y71.244 E.15861
G3 X102.328 Y73.415 I-1.062 J3.233 E.11897
G1 X108.477 Y79.564 E.32482
G2 X108.1 Y79.835 I1.163 J2.015 E.01738
G1 X102.494 Y74.228 E.29616
G3 X102.48 Y74.863 I-2.657 J.259 E.02376
G1 X107.765 Y80.148 E.27919
G2 X107.478 Y80.509 I1.66 J1.611 E.01726
G1 X102.381 Y75.412 E.26925
G3 X102.21 Y75.889 I-2.463 J-.616 E.01896
G1 X107.234 Y80.913 E.26539
G2 X107.044 Y81.372 I1.668 J.96 E.01858
G1 X101.987 Y76.315 E.26711
G3 X101.714 Y76.69 I-2.007 J-1.177 E.01736
G1 X106.908 Y81.884 E.27436
G2 X106.853 Y82.477 I2.938 J.573 E.02228
G1 X101.399 Y77.023 E.28806
G3 X101.041 Y77.314 I-3.06 J-3.411 E.01722
G1 X107.226 Y83.498 E.3267
; WIPE_START
G1 X105.812 Y82.084 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X101.988 Y75.478 Z.6 F42000
G1 X99.576 Y71.311 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X97.155 Y68.889 E.12791
G1 X97.155 Y69.538 E.02421
G1 X98.702 Y71.085 E.08174
G2 X98.159 Y71.19 I.45 J3.783 E.02068
G1 X97.155 Y70.186 E.05305
G1 X97.155 Y70.834 E.02421
G1 X97.679 Y71.358 E.02768
G2 X97.257 Y71.584 I1.972 J4.183 E.01789
G1 X96.949 Y71.277 E.01626
; WIPE_START
G1 X97.257 Y71.584 E-.1654
G1 X97.679 Y71.358 E-.18194
G1 X97.155 Y70.834 E-.28163
G1 X97.155 Y70.489 E-.13102
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X103.397 Y74.88 Z.6 F42000
G1 X113.477 Y81.97 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X142.831 Y111.325 E1.55058
G2 X142.634 Y111.775 I1.633 J.985 E.01843
G1 X113.703 Y82.845 E1.52817
G3 X113.601 Y83.391 I-3.739 J-.417 E.02077
G1 X142.482 Y112.272 E1.52558
G2 X142.418 Y112.856 I4.667 J.812 E.02194
G1 X113.43 Y83.868 E1.5312
G3 X113.208 Y84.294 I-4.136 J-1.888 E.01795
G1 X142.74 Y113.827 E1.55998
; WIPE_START
G1 X141.326 Y112.412 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X148.958 Y112.326 Z.6 F42000
G1 X149.018 Y112.326 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X159.185 Y122.493 E.53706
G1 X159.185 Y123.141 E.02421
G1 X149.273 Y113.229 E.52357
G3 X149.185 Y113.789 I-2.909 J-.173 E.0212
G1 X159.185 Y123.789 E.52825
G1 X159.185 Y124.438 E.02421
G1 X149.022 Y114.274 E.53687
G3 X148.807 Y114.708 I-2.299 J-.867 E.0181
G1 X159.185 Y125.086 E.54819
G1 X159.185 Y125.422 E.01257
G1 X159.154 Y125.4 E.00142
G1 X159.028 Y125.576 E.00811
G1 X148.543 Y115.092 E.55384
G3 X148.234 Y115.431 I-1.851 J-1.377 E.01717
G1 X157.992 Y125.189 E.51547
G2 X157.224 Y125.07 I-.96 J3.644 E.02907
M73 P27 R23
G1 X147.884 Y115.729 E.4934
G3 X147.486 Y115.979 I-2.6 J-3.694 E.01757
G1 X156.603 Y125.096 E.48159
G2 X156.072 Y125.214 I.326 J2.716 E.02032
G1 X147.039 Y116.181 E.47716
G3 X146.535 Y116.325 I-1.292 J-3.568 E.0196
G1 X155.604 Y125.394 E.47903
G2 X155.189 Y125.628 I.962 J2.188 E.0178
G1 X145.956 Y116.395 E.48771
G3 X145.259 Y116.346 I-.032 J-4.549 E.02612
G1 X154.818 Y125.905 E.50492
G2 X154.494 Y126.229 I3.204 J3.527 E.01713
G1 X112.934 Y84.669 E2.1953
G3 X112.62 Y85.003 I-1.826 J-1.405 E.01716
G1 X154.213 Y126.596 E2.19706
G2 X153.975 Y127.006 I1.935 J1.4 E.01774
G1 X112.262 Y85.293 E2.20337
G3 X111.856 Y85.535 I-1.413 J-1.91 E.01769
G1 X153.793 Y127.472 E2.21524
G2 X153.673 Y128.001 I3.609 J1.094 E.02026
G1 X111.403 Y85.731 E2.23282
G3 X110.885 Y85.861 I-1.328 J-4.193 E.01997
G1 X153.638 Y128.614 E2.25834
G2 X153.75 Y129.374 I3.479 J-.123 E.02874
G1 X110.29 Y85.914 E2.29567
G3 X109.563 Y85.835 I.015 J-3.537 E.02736
G1 X159.185 Y135.457 E2.62117
G1 X159.185 Y136.106 E.02421
G1 X100.635 Y77.556 E3.09278
G3 X100.182 Y77.751 I-1.201 J-2.155 E.01845
G1 X159.185 Y136.754 E3.11668
G1 X159.185 Y137.402 E.02421
G1 X99.664 Y77.881 E3.14406
G3 X99.069 Y77.934 I-.616 J-3.553 E.02235
G1 X159.185 Y138.05 E3.17551
G1 X159.185 Y138.699 E.02421
G1 X98.342 Y77.855 E3.21392
G3 X97.254 Y77.416 I.635 J-3.138 E.04406
G1 X159.185 Y139.347 E3.27137
G1 X159.185 Y139.995 E.02421
G1 X97.155 Y77.965 E3.27663
G1 X97.155 Y78.613 E.02421
G1 X159.185 Y140.643 E3.27663
G1 X159.185 Y141.292 E.02421
G1 X97.155 Y79.261 E3.27663
G1 X97.155 Y79.909 E.02421
G1 X159.185 Y141.94 E3.27663
G1 X159.185 Y142.588 E.02421
G1 X97.155 Y80.557 E3.27663
G1 X97.155 Y81.206 E.02421
G1 X159.185 Y143.236 E3.27663
G1 X159.185 Y143.885 E.02421
G1 X97.155 Y81.854 E3.27663
G1 X97.155 Y82.502 E.02421
G1 X159.185 Y144.533 E3.27663
G1 X159.185 Y145.181 E.02421
G1 X97.155 Y83.15 E3.27663
G1 X97.155 Y83.799 E.02421
G1 X159.185 Y145.829 E3.27663
G1 X159.185 Y146.477 E.02421
G1 X97.155 Y84.447 E3.27663
G1 X97.155 Y85.095 E.02421
G1 X159.185 Y147.126 E3.27663
G1 X159.185 Y147.774 E.02421
G1 X97.155 Y85.743 E3.27663
G1 X97.155 Y86.392 E.02421
G1 X159.185 Y148.422 E3.27663
G1 X159.185 Y149.07 E.02421
M73 P28 R23
G1 X133.155 Y123.04 E1.37501
G1 X133.155 Y122.615 E.01586
G1 X132.73 Y122.615 E.01586
G1 X97.155 Y87.04 E1.8792
G1 X97.155 Y87.688 E.02421
G1 X132.082 Y122.615 E1.84495
G1 X131.434 Y122.615 E.02421
G1 X97.155 Y88.336 E1.81071
G1 X97.155 Y88.984 E.02421
G1 X130.785 Y122.615 E1.77647
G1 X130.137 Y122.615 E.02421
G1 X97.155 Y89.633 E1.74223
G1 X97.155 Y90.281 E.02421
G1 X129.489 Y122.615 E1.70799
G1 X128.841 Y122.615 E.02421
G1 X97.155 Y90.929 E1.67375
G1 X97.155 Y91.577 E.02421
G1 X128.192 Y122.615 E1.63951
G1 X127.544 Y122.615 E.02421
G1 X97.155 Y92.226 E1.60526
G1 X97.155 Y92.874 E.02421
G1 X126.896 Y122.615 E1.57102
G1 X126.248 Y122.615 E.02421
G1 X97.155 Y93.522 E1.53678
G1 X97.155 Y94.17 E.02421
G1 X125.599 Y122.615 E1.50254
G1 X124.951 Y122.615 E.02421
G1 X97.155 Y94.819 E1.4683
G1 X97.155 Y95.467 E.02421
G1 X111.399 Y109.711 E.75241
G3 X113.54 Y111.852 I-1.081 J3.223 E.11723
G1 X124.303 Y122.615 E.56853
G1 X123.655 Y122.615 E.02421
G1 X113.712 Y112.672 E.52522
G3 X113.705 Y113.313 I-2.676 J.291 E.024
G1 X123.007 Y122.615 E.49135
G1 X122.358 Y122.615 E.02421
G1 X113.604 Y113.861 E.4624
G3 X113.434 Y114.339 I-2.464 J-.61 E.01898
G1 X121.71 Y122.615 E.43717
G1 X121.062 Y122.615 E.02421
G1 X113.213 Y114.767 E.41459
G3 X112.94 Y115.142 I-2.01 J-1.173 E.01736
G1 X120.414 Y122.615 E.39476
G1 X119.765 Y122.615 E.02421
M73 P29 R23
G1 X112.627 Y115.476 E.37709
G3 X112.27 Y115.768 I-3.142 J-3.481 E.01721
G1 X119.117 Y122.615 E.36169
G1 X118.469 Y122.615 E.02421
G1 X111.864 Y116.011 E.34887
G3 X111.413 Y116.207 I-1.207 J-2.155 E.01843
G1 X117.821 Y122.615 E.33849
G1 X117.172 Y122.615 E.02421
G1 X110.896 Y116.339 E.33153
G3 X110.303 Y116.394 I-.638 J-3.63 E.02226
G1 X116.524 Y122.615 E.3286
G1 X115.876 Y122.615 E.02421
G1 X109.289 Y116.028 E.34794
; WIPE_START
G1 X110.703 Y117.443 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X110.812 Y109.811 Z.6 F42000
G1 X110.812 Y109.773 Z.6
G1 Z.2
M73 P29 R22
G1 E.8 F1800
G1 F6300
M204 S500
G1 X97.155 Y96.115 E.72144
G1 X97.155 Y96.763 E.02421
G1 X109.935 Y109.544 E.67511
G2 X109.39 Y109.647 I.415 J3.692 E.02075
G1 X97.155 Y97.412 E.64631
G1 X97.155 Y98.06 E.02421
G1 X108.909 Y109.814 E.62089
G2 X108.485 Y110.039 I1.865 J4.029 E.01792
G1 X97.155 Y98.708 E.59852
G1 X97.155 Y99.356 E.02421
G1 X108.108 Y110.309 E.57857
G2 X107.771 Y110.621 I1.388 J1.835 E.01716
G1 X97.155 Y100.004 E.5608
G1 X97.155 Y100.653 E.02421
G1 X107.487 Y110.985 E.54577
G2 X107.238 Y111.385 I1.401 J1.149 E.01763
G1 X97.155 Y101.301 E.53264
G1 X97.155 Y101.949 E.02421
G1 X107.044 Y111.839 E.52241
G2 X106.91 Y112.352 I3.584 J1.216 E.01984
G1 X97.155 Y102.597 E.51529
G1 X97.155 Y103.246 E.02421
G1 X106.853 Y112.944 E.51231
G2 X106.927 Y113.666 I2.383 J.121 E.02722
G1 X97.155 Y103.894 E.51621
G1 X97.155 Y104.542 E.02421
G1 X115.228 Y122.615 E.95468
G1 X114.579 Y122.615 E.02421
G1 X97.155 Y105.19 E.92043
G1 X97.155 Y105.839 E.02421
G1 X113.931 Y122.615 E.88619
G1 X113.283 Y122.615 E.02421
G1 X97.155 Y106.487 E.85195
G1 X97.155 Y107.135 E.02421
G1 X112.635 Y122.615 E.81771
G1 X111.987 Y122.615 E.02421
G1 X97.155 Y107.783 E.78347
G1 X97.155 Y108.431 E.02421
G1 X111.338 Y122.615 E.74923
G1 X110.69 Y122.615 E.02421
G1 X97.155 Y109.08 E.71499
G1 X97.155 Y109.728 E.02421
G1 X110.042 Y122.615 E.68074
G1 X109.394 Y122.615 E.02421
G1 X97.155 Y110.376 E.6465
G1 X97.155 Y111.024 E.02421
G1 X108.745 Y122.615 E.61226
G1 X108.097 Y122.615 E.02421
G1 X97.155 Y111.673 E.57802
G1 X97.155 Y112.321 E.02421
G1 X107.449 Y122.615 E.54378
G1 X106.801 Y122.615 E.02421
G1 X97.155 Y112.969 E.50954
G1 X97.155 Y113.617 E.02421
G1 X106.152 Y122.615 E.4753
G1 X105.504 Y122.615 E.02421
G1 X102.342 Y119.453 E.16703
G2 X100.12 Y117.231 I-3.254 J1.032 E.12197
G1 X97.155 Y114.266 E.15666
G1 X97.155 Y114.914 E.02421
G1 X99.313 Y117.072 E.114
G2 X98.679 Y117.087 I-.244 J3.18 E.02371
G1 X97.155 Y115.562 E.08053
G1 X97.155 Y116.21 E.02421
G1 X98.14 Y117.195 E.05204
G2 X97.661 Y117.365 I.607 J2.475 E.019
G1 X97.155 Y116.859 E.02675
G1 X97.155 Y117.507 E.02421
G1 X97.39 Y117.743 E.01246
; WIPE_START
G1 X97.155 Y117.507 E-.12678
G1 X97.155 Y116.859 E-.24633
G1 X97.661 Y117.365 E-.27215
G1 X97.946 Y117.264 E-.11473
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X102.261 Y120.021 Z.6 F42000
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X104.856 Y122.615 E.13706
G1 X104.208 Y122.615 E.02421
G1 X102.481 Y120.889 E.09121
G3 X102.375 Y121.431 I-3.635 J-.428 E.02066
G1 X103.56 Y122.615 E.06256
G1 X102.911 Y122.615 E.02421
G1 X102.203 Y121.906 E.03744
G3 X101.977 Y122.33 I-3.909 J-1.808 E.01791
G1 X102.469 Y122.821 E.02595
; WIPE_START
G1 X101.977 Y122.33 E-.26404
G1 X102.203 Y121.906 E-.18213
G1 X102.786 Y122.49 E-.31383
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X110.415 Y122.741 Z.6 F42000
G1 X132.949 Y123.482 Z.6
M73 P30 R22
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X159.185 Y149.719 E1.38587
G1 X159.185 Y150.367 E.02421
G1 X133.155 Y124.336 E1.37501
G1 X133.155 Y124.984 E.02421
G1 X159.185 Y151.015 E1.37501
G1 X159.185 Y151.663 E.02421
G1 X133.155 Y125.633 E1.37501
G1 X133.155 Y126.281 E.02421
G1 X159.185 Y152.312 E1.37501
G1 X159.185 Y152.96 E.02421
G1 X133.155 Y126.929 E1.37501
G1 X133.155 Y127.577 E.02421
G1 X159.185 Y153.608 E1.37501
G1 X159.185 Y154.256 E.02421
G1 X133.155 Y128.226 E1.37501
G1 X133.155 Y128.874 E.02421
G1 X159.185 Y154.904 E1.37501
G1 X159.185 Y155.553 E.02421
G1 X133.155 Y129.522 E1.37501
G1 X133.155 Y130.17 E.02421
G1 X159.185 Y156.201 E1.37501
G1 X159.185 Y156.849 E.02421
G1 X133.155 Y130.819 E1.37501
G1 X133.155 Y131.467 E.02421
G1 X159.185 Y157.497 E1.37501
G1 X159.185 Y158.146 E.02421
G1 X133.155 Y132.115 E1.37501
G1 X133.155 Y132.763 E.02421
G1 X159.185 Y158.794 E1.37501
G1 X159.185 Y159.442 E.02421
G1 X133.155 Y133.412 E1.37501
G1 X133.155 Y134.06 E.02421
G1 X159.185 Y160.09 E1.37501
G1 X159.185 Y160.739 E.02421
G1 X133.155 Y134.708 E1.37501
G1 X133.155 Y135.356 E.02421
G1 X159.185 Y161.387 E1.37501
G1 X159.185 Y162.035 E.02421
G1 X133.155 Y136.004 E1.37501
G1 X133.155 Y136.653 E.02421
G1 X159.185 Y162.683 E1.37501
G1 X159.185 Y163.331 E.02421
G1 X133.155 Y137.301 E1.37501
G1 X133.155 Y137.949 E.02421
G1 X159.185 Y163.98 E1.37501
G1 X159.185 Y164.628 E.02421
G1 X133.155 Y138.597 E1.37501
G1 X133.155 Y139.246 E.02421
G1 X159.185 Y165.276 E1.37501
G1 X159.185 Y165.924 E.02421
G1 X133.155 Y139.894 E1.37501
G1 X133.155 Y140.542 E.02421
G1 X159.185 Y166.573 E1.37501
G1 X159.185 Y167.221 E.02421
G1 X133.155 Y141.19 E1.37501
G1 X133.155 Y141.839 E.02421
G1 X159.185 Y167.869 E1.37501
G1 X159.185 Y168.517 E.02421
G1 X133.155 Y142.487 E1.37501
G1 X133.155 Y143.135 E.02421
G1 X159.185 Y169.166 E1.37501
G1 X159.185 Y169.814 E.02421
G1 X133.155 Y143.783 E1.37501
G1 X133.155 Y144.431 E.02421
G1 X159.185 Y170.462 E1.37501
G1 X159.185 Y171.11 E.02421
G1 X133.155 Y145.08 E1.37501
G1 X133.155 Y145.728 E.02421
G1 X159.185 Y171.759 E1.37501
G1 X159.185 Y172.407 E.02421
G1 X133.155 Y146.376 E1.37501
G1 X133.155 Y147.024 E.02421
G1 X159.185 Y173.055 E1.37501
G1 X159.185 Y173.703 E.02421
G1 X133.155 Y147.673 E1.37501
G1 X133.155 Y148.321 E.02421
G1 X159.185 Y174.351 E1.37501
G1 X159.185 Y175 E.02421
G1 X133.155 Y148.969 E1.37501
G1 X133.155 Y149.617 E.02421
G1 X159.185 Y175.648 E1.37501
G1 X159.185 Y176.296 E.02421
G1 X133.155 Y150.266 E1.37501
G1 X133.155 Y150.914 E.02421
G1 X159.185 Y176.944 E1.37501
G1 X159.185 Y177.593 E.02421
G1 X133.155 Y151.562 E1.37501
G1 X133.155 Y152.21 E.02421
M73 P31 R22
G1 X159.185 Y178.241 E1.37501
G1 X159.185 Y178.889 E.02421
G1 X133.155 Y152.859 E1.37501
G1 X133.155 Y153.507 E.02421
G1 X159.185 Y179.537 E1.37501
G1 X159.185 Y180.186 E.02421
G1 X133.155 Y154.155 E1.37501
G1 X133.155 Y154.803 E.02421
G1 X159.185 Y180.834 E1.37501
G1 X159.185 Y181.482 E.02421
G1 X133.155 Y155.451 E1.37501
G1 X133.155 Y156.1 E.02421
G1 X159.185 Y182.13 E1.37501
G1 X159.185 Y182.778 E.02421
G1 X133.155 Y156.748 E1.37501
G1 X133.155 Y157.396 E.02421
G1 X159.185 Y183.427 E1.37501
G1 X159.185 Y184.075 E.02421
G1 X133.155 Y158.044 E1.37501
G1 X133.155 Y158.693 E.02421
G1 X159.185 Y184.723 E1.37501
G1 X159.185 Y185.371 E.02421
G1 X133.155 Y159.341 E1.37501
G1 X133.155 Y159.989 E.02421
G1 X159.185 Y186.02 E1.37501
G1 X159.185 Y186.668 E.02421
G1 X133.155 Y160.637 E1.37501
G1 X133.155 Y161.286 E.02421
G1 X159.185 Y187.316 E1.37501
G1 X159.185 Y187.964 E.02421
G1 X133.155 Y161.934 E1.37501
G1 X133.155 Y162.582 E.02421
G1 X159.185 Y188.613 E1.37501
G1 X159.185 Y189.261 E.02421
G1 X133.155 Y163.23 E1.37501
G1 X133.155 Y163.878 E.02421
G1 X159.185 Y189.909 E1.37501
G1 X159.185 Y190.557 E.02421
G1 X133.155 Y164.527 E1.37501
G1 X133.155 Y165.175 E.02421
G1 X159.185 Y191.206 E1.37501
G1 X159.185 Y191.854 E.02421
G1 X133.155 Y165.823 E1.37501
G1 X133.155 Y166.471 E.02421
G1 X159.185 Y192.502 E1.37501
G1 X159.185 Y193.15 E.02421
G1 X133.155 Y167.12 E1.37501
G1 X133.155 Y167.768 E.02421
G1 X159.185 Y193.798 E1.37501
G1 X159.185 Y194.447 E.02421
G1 X133.155 Y168.416 E1.37501
G1 X133.155 Y169.064 E.02421
G1 X159.185 Y195.095 E1.37501
G1 X159.185 Y195.743 E.02421
G1 X133.155 Y169.713 E1.37501
G1 X133.155 Y170.361 E.02421
G1 X159.185 Y196.391 E1.37501
G1 X159.185 Y197.04 E.02421
G1 X133.155 Y171.009 E1.37501
G1 X133.155 Y171.657 E.02421
G1 X159.185 Y197.688 E1.37501
G1 X159.185 Y198.336 E.02421
G1 X133.155 Y172.306 E1.37501
G1 X133.155 Y172.954 E.02421
G1 X159.185 Y198.984 E1.37501
G1 X159.185 Y199.633 E.02421
G1 X133.155 Y173.602 E1.37501
G1 X133.155 Y174.25 E.02421
M73 P32 R22
G1 X159.185 Y200.281 E1.37501
G1 X159.185 Y200.929 E.02421
G1 X133.155 Y174.898 E1.37501
G1 X133.155 Y175.547 E.02421
G1 X159.185 Y201.577 E1.37501
G1 X159.185 Y202.225 E.02421
G1 X133.155 Y176.195 E1.37501
G1 X133.155 Y176.843 E.02421
G1 X159.185 Y202.874 E1.37501
G1 X159.185 Y203.522 E.02421
G1 X133.155 Y177.491 E1.37501
G1 X133.155 Y178.14 E.02421
G1 X159.185 Y204.17 E1.37501
G1 X159.185 Y204.818 E.02421
G1 X133.155 Y178.788 E1.37501
G1 X133.155 Y179.436 E.02421
G1 X159.185 Y205.467 E1.37501
G1 X159.185 Y206.115 E.02421
G1 X133.155 Y180.084 E1.37501
G1 X133.155 Y180.733 E.02421
G1 X159.185 Y206.763 E1.37501
G1 X159.185 Y207.411 E.02421
M73 P32 R21
G1 X133.155 Y181.381 E1.37501
G1 X133.155 Y182.029 E.02421
G1 X159.185 Y208.06 E1.37501
G1 X159.185 Y208.708 E.02421
G1 X133.155 Y182.677 E1.37501
G1 X133.155 Y183.325 E.02421
G1 X159.185 Y209.356 E1.37501
G1 X159.185 Y210.004 E.02421
G1 X133.155 Y183.974 E1.37501
G1 X133.155 Y184.622 E.02421
G1 X158.948 Y210.415 E1.36248
G1 X158.3 Y210.415 E.02421
G1 X133.155 Y185.27 E1.32823
G1 X133.155 Y185.918 E.02421
G1 X157.651 Y210.415 E1.29399
G1 X157.003 Y210.415 E.02421
G1 X133.155 Y186.567 E1.25975
G1 X133.155 Y187.215 E.02421
G1 X156.355 Y210.415 E1.22551
G1 X155.707 Y210.415 E.02421
G1 X133.155 Y187.863 E1.19127
G1 X133.155 Y188.511 E.02421
G1 X155.058 Y210.415 E1.15703
G1 X154.41 Y210.415 E.02421
G1 X133.155 Y189.16 E1.12279
G1 X133.155 Y189.808 E.02421
G1 X153.762 Y210.415 E1.08854
G1 X153.114 Y210.415 E.02421
G1 X133.155 Y190.456 E1.0543
G1 X133.155 Y191.104 E.02421
G1 X152.466 Y210.415 E1.02006
G1 X151.817 Y210.415 E.02421
G1 X133.155 Y191.753 E.98582
G1 X133.155 Y192.401 E.02421
G1 X151.169 Y210.415 E.95158
G1 X150.521 Y210.415 E.02421
G1 X133.155 Y193.049 E.91734
G1 X133.155 Y193.697 E.02421
G1 X149.873 Y210.415 E.8831
G1 X149.224 Y210.415 E.02421
G1 X133.155 Y194.345 E.84885
G1 X133.155 Y194.994 E.02421
G1 X148.576 Y210.415 E.81461
G1 X147.928 Y210.415 E.02421
G1 X133.155 Y195.642 E.78037
G1 X133.155 Y196.29 E.02421
G1 X147.28 Y210.415 E.74613
G1 X146.631 Y210.415 E.02421
M73 P33 R21
G1 X133.155 Y196.938 E.71189
G1 X133.155 Y197.587 E.02421
G1 X145.983 Y210.415 E.67765
G1 X145.335 Y210.415 E.02421
G1 X133.155 Y198.235 E.64341
G1 X133.155 Y198.883 E.02421
G1 X144.687 Y210.415 E.60916
G1 X144.039 Y210.415 E.02421
G1 X133.155 Y199.531 E.57492
G1 X133.155 Y200.18 E.02421
G1 X143.39 Y210.415 E.54068
G1 X142.742 Y210.415 E.02421
G1 X133.155 Y200.828 E.50644
G1 X133.155 Y201.476 E.02421
G1 X142.094 Y210.415 E.4722
G1 X141.446 Y210.415 E.02421
G1 X138.261 Y207.231 E.1682
G2 X136.335 Y205.304 I-3.216 J1.289 E.10459
G1 X133.155 Y202.124 E.16799
G1 X133.155 Y202.772 E.02421
G1 X135.473 Y205.091 E.12245
G2 X134.811 Y205.077 I-.403 J3.42 E.02477
G1 X133.155 Y203.421 E.08748
G1 X133.155 Y204.069 E.02421
G1 X134.25 Y205.164 E.05786
G2 X133.762 Y205.325 I.556 J2.507 E.01921
G1 X133.155 Y204.717 E.03211
G1 X133.155 Y205.365 E.02421
G1 X133.478 Y205.689 E.0171
; WIPE_START
G1 X133.155 Y205.365 E-.174
G1 X133.155 Y204.717 E-.24633
G1 X133.762 Y205.325 E-.32671
G1 X133.794 Y205.313 E-.01297
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X138.236 Y207.853 Z.6 F42000
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X140.797 Y210.415 E.13532
G1 X140.149 Y210.415 E.02421
G1 X138.494 Y208.76 E.08742
G3 X138.404 Y209.318 I-3.645 J-.302 E.02114
G1 X139.501 Y210.415 E.05794
G1 X138.853 Y210.415 E.02421
G1 X138.086 Y209.649 E.04049
M204 S6000
G1 X137.735 Y210.447 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.11053
G1 F3000
M204 S500
G1 X137.657 Y210.575 E.00083
M204 S6000
G1 X136.788 Y210.767 F42000
; LINE_WIDTH: 0.106564
G1 F3000
M204 S500
G1 X136.734 Y210.818 E.00038
; LINE_WIDTH: 0.126158
G1 X136.647 Y210.893 E.00078
; LINE_WIDTH: 0.150471
G3 X136.399 Y211.012 I-.282 J-.269 E.00247
; WIPE_START
G1 X136.56 Y210.967 E-.45033
G1 X136.647 Y210.893 E-.30967
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X132.538 Y207.127 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.126181
G1 F3000
M204 S500
G1 X132.727 Y206.889 E.00206
; WIPE_START
G1 X132.538 Y207.127 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X129.834 Y199.989 Z.6 F42000
G1 X100.622 Y122.882 Z.6
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.115469
G1 F3000
M204 S500
G1 X100.499 Y122.98 E.00093
; LINE_WIDTH: 0.149583
G1 X100.384 Y123.063 E.00123
; LINE_WIDTH: 0.193127
G1 X100.26 Y123.148 E.00184
; LINE_WIDTH: 0.193351
G1 X100.166 Y123.166 E.00117
; LINE_WIDTH: 0.157853
G1 X100.073 Y123.184 E.00089
; LINE_WIDTH: 0.117186
G1 X99.944 Y123.206 E.00079
; WIPE_START
G1 X100.073 Y123.184 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X97.8 Y123.135 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.150611
G1 F3000
M204 S500
G2 X98.114 Y123.192 I1.309 J-6.311 E.0028
; LINE_WIDTH: 0.115582
G1 X98.207 Y123.207 E.00055
M204 S6000
G1 X98.052 Y123.232 F42000
; LINE_WIDTH: 0.17412
G1 F3000
M204 S500
G1 X97.909 Y123.14 E.00182
; LINE_WIDTH: 0.14318
G1 X97.762 Y123.045 E.00142
; LINE_WIDTH: 0.115071
G1 X97.639 Y122.957 E.00089
; WIPE_START
G1 X97.762 Y123.045 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X96.811 Y122.226 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.11551
G1 F3000
M204 S500
G1 X96.704 Y122.111 E.00093
; LINE_WIDTH: 0.151709
G1 X96.537 Y121.912 E.00229
; WIPE_START
G1 X96.704 Y122.111 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X96.537 Y119.127 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.1262
G1 F3000
M204 S500
G1 X96.727 Y118.889 E.00206
; WIPE_START
G1 X96.537 Y119.127 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X96.586 Y111.494 Z.6 F42000
G1 X96.811 Y76.226 Z.6
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.115523
G1 F3000
M204 S500
G1 X96.704 Y76.11 E.00093
; LINE_WIDTH: 0.151711
G1 X96.537 Y75.912 E.00229
; WIPE_START
G1 X96.704 Y76.11 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X96.537 Y73.127 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; LINE_WIDTH: 0.126198
G1 F3000
M204 S500
G1 X96.727 Y72.889 E.00207
; OBJECT_ID: 124
; WIPE_START
G1 X96.537 Y73.127 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S6000
G1 X97.426 Y80.707 Z.6 F42000
G1 X106.83 Y160.914 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.5
G1 F3000
M204 S500
G1 X106.849 Y160.989 E.00288
G3 X105.13 Y159.585 I-1.652 J.269 E.30144
G1 X105.222 Y159.584 E.00342
G3 X106.763 Y160.667 I-.025 J1.674 E.07452
G1 X106.815 Y160.856 E.00731
; WIPE_START
G1 X106.849 Y160.989 E-.05214
G1 X106.871 Y161.322 E-.12678
G1 X106.826 Y161.652 E-.1267
G1 X106.715 Y161.967 E-.12682
G1 X106.545 Y162.254 E-.12675
G1 X106.321 Y162.501 E-.12684
G1 X106.164 Y162.617 E-.07398
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X105.137 Y163.427 Z.6 F42000
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X105.062 Y163.429 E.00282
G3 X105.224 Y159.084 I.135 J-2.17 E.25045
G1 X105.332 Y159.088 E.00401
G3 X105.494 Y163.413 I-.135 J2.17 E.23829
G1 X105.197 Y163.424 E.01107
; OBJECT_ID: 102
; WIPE_START
G1 X105.062 Y163.429 E-.05156
G1 X104.634 Y163.36 E-.1646
G1 X104.229 Y163.206 E-.16457
G1 X103.862 Y162.976 E-.16456
G1 X103.549 Y162.678 E-.16411
G1 X103.47 Y162.571 E-.0506
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S6000
G1 X104.129 Y154.967 Z.6 F42000
G1 X104.175 Y154.437 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X104.194 Y154.512 E.00288
G3 X102.474 Y153.108 I-1.652 J.269 E.30144
G1 X102.566 Y153.107 E.00342
G3 X104.107 Y154.19 I-.025 J1.674 E.07452
G1 X104.159 Y154.379 E.00731
; WIPE_START
G1 X104.194 Y154.512 E-.05214
G1 X104.215 Y154.845 E-.12678
G1 X104.17 Y155.175 E-.1267
G1 X104.06 Y155.49 E-.12682
G1 X103.889 Y155.777 E-.12675
G1 X103.665 Y156.024 E-.12684
G1 X103.509 Y156.14 E-.07398
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X102.482 Y156.95 Z.6 F42000
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X102.406 Y156.952 E.00282
G3 X102.568 Y152.607 I.135 J-2.17 E.25045
G1 X102.676 Y152.611 E.00401
G3 X102.838 Y156.936 I-.135 J2.17 E.23829
G1 X102.542 Y156.948 E.01107
; OBJECT_ID: 91
; WIPE_START
G1 X102.406 Y156.952 E-.05156
G1 X101.978 Y156.883 E-.1646
G1 X101.573 Y156.73 E-.16457
G1 X101.207 Y156.499 E-.16456
G1 X100.894 Y156.202 E-.16411
G1 X100.814 Y156.095 E-.0506
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S6000
G1 X101.473 Y148.491 Z.6 F42000
G1 X101.519 Y147.96 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X101.538 Y148.035 E.00288
G3 X99.819 Y146.632 I-1.652 J.269 E.30144
G1 X99.91 Y146.63 E.00342
G3 X101.452 Y147.713 I-.025 J1.674 E.07452
G1 X101.503 Y147.902 E.00731
; WIPE_START
G1 X101.538 Y148.035 E-.05214
G1 X101.56 Y148.368 E-.12678
G1 X101.514 Y148.698 E-.1267
G1 X101.404 Y149.013 E-.12682
G1 X101.234 Y149.3 E-.12675
G1 X101.01 Y149.548 E-.12684
G1 X100.853 Y149.663 E-.07398
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X99.826 Y150.473 Z.6 F42000
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X99.75 Y150.475 E.00282
G3 X99.913 Y146.131 I.135 J-2.17 E.25045
G1 X100.02 Y146.135 E.00401
G3 X100.183 Y150.459 I-.135 J2.17 E.23829
G1 X99.886 Y150.471 E.01107
; OBJECT_ID: 113
; WIPE_START
G1 X99.75 Y150.475 E-.05156
G1 X99.323 Y150.406 E-.1646
G1 X98.918 Y150.253 E-.16457
G1 X98.551 Y150.023 E-.16456
G1 X98.238 Y149.725 E-.16411
G1 X98.159 Y149.618 E-.0506
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S6000
G1 X98.818 Y142.014 Z.6 F42000
G1 X98.863 Y141.484 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X98.882 Y141.559 E.00288
G3 X97.163 Y140.155 I-1.652 J.269 E.30144
G1 X97.255 Y140.154 E.00342
G3 X98.796 Y141.236 I-.025 J1.674 E.07452
G1 X98.848 Y141.426 E.00731
; WIPE_START
G1 X98.882 Y141.559 E-.05214
G1 X98.904 Y141.891 E-.12678
G1 X98.859 Y142.222 E-.1267
G1 X98.748 Y142.537 E-.12682
G1 X98.578 Y142.824 E-.12675
G1 X98.354 Y143.071 E-.12684
G1 X98.198 Y143.187 E-.07398
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X97.17 Y143.997 Z.6 F42000
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G1 X97.095 Y143.999 E.00282
G3 X97.257 Y139.654 I.135 J-2.17 E.25045
G1 X97.365 Y139.658 E.00401
G3 X97.527 Y143.982 I-.135 J2.17 E.23829
G1 X97.23 Y143.994 E.01107
; CHANGE_LAYER
; Z_HEIGHT: 0.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F3000
G1 X97.095 Y143.999 E-.05156
G1 X96.667 Y143.929 E-.1646
G1 X96.262 Y143.776 E-.16457
G1 X95.895 Y143.546 E-.16456
G1 X95.582 Y143.248 E-.16411
G1 X95.503 Y143.141 E-.0506
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 2/60
; update layer progress
M73 L2
M991 S0 P1 ;notify layer change
M106 S153
; open powerlost recovery
M1003 S1
; OBJECT_ID: 80
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
M204 S10000
G17
G3 Z.6 I.939 J.774 P1  F42000
G1 X144.656 Y83.482 Z.6
G1 Z.4
G1 E.8 F1800
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G3 X145.656 Y80.932 I1.194 J-1.003 E.10275
G1 X145.811 Y80.92 E.00479
G3 X144.695 Y83.527 I.039 J1.559 E.19167
; WIPE_START
M204 S6000
G1 X144.48 Y83.226 E-.1406
G1 X144.359 Y82.94 E-.11804
G1 X144.297 Y82.635 E-.11813
G1 X144.297 Y82.325 E-.11801
G1 X144.359 Y82.02 E-.11813
G1 X144.48 Y81.734 E-.11799
G1 X144.523 Y81.671 E-.0291
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.208 Y89.115 Z.8 F42000
G1 X155.529 Y130.278 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X155.264 Y130.016 E.01238
G3 X156.776 Y126.158 I1.806 J-1.517 E.1678
G1 X157.011 Y126.14 E.00782
G3 X155.6 Y130.343 I.059 J2.358 E.30043
G1 X155.573 Y130.319 E.00121
M204 S10000
G1 X155.812 Y129.988 F42000
G1 F15476.087
M204 S6000
G1 X155.575 Y129.754 E.01103
G3 X156.827 Y126.562 I1.494 J-1.255 E.13883
G1 X157.021 Y126.548 E.00647
G3 X155.857 Y130.028 I.049 J1.951 E.24841
M204 S250
G1 X156.085 Y129.708 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X155.876 Y129.502 E.00902
G3 X156.876 Y126.952 I1.194 J-1.003 E.10275
G1 X157.031 Y126.94 E.00479
G3 X156.132 Y129.745 I.039 J1.559 E.18263
; WIPE_START
M204 S6000
G1 X155.876 Y129.502 E-.13419
G1 X155.7 Y129.246 E-.11795
G1 X155.579 Y128.96 E-.11811
G1 X155.517 Y128.655 E-.1181
G1 X155.517 Y128.345 E-.11805
G1 X155.579 Y128.04 E-.1181
G1 X155.615 Y127.954 E-.0355
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.023 Y127.17 Z.8 F42000
G1 X96.664 Y121.865 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X96.783 Y122.059 E.00755
G2 X98.09 Y123.091 I2.326 J-1.603 E.05609
G1 X98.049 Y123.284 E.00654
G1 X96.486 Y123.284 E.05184
G1 X96.486 Y121.915 E.0454
G1 X96.606 Y121.881 E.00415
; WIPE_START
G1 X96.783 Y122.059 E-.09521
G1 X96.949 Y122.279 E-.10491
G1 X97.137 Y122.481 E-.10483
G1 X97.344 Y122.664 E-.10486
G1 X97.568 Y122.825 E-.10492
G1 X97.807 Y122.963 E-.10478
G1 X98.09 Y123.091 E-.11812
G1 X98.078 Y123.148 E-.02236
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.737 Y120.185 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X96.815 Y119.804 E.01288
G3 X98.776 Y118.158 I2.254 J.694 E.08979
G1 X99.011 Y118.14 E.00781
G3 X96.722 Y120.265 I.059 J2.358 E.37844
G1 X96.726 Y120.244 E.00072
M204 S10000
G1 X97.135 Y120.265 F42000
G1 F15476.087
M204 S6000
G1 X97.204 Y119.925 E.01153
G3 X98.827 Y118.562 I1.865 J.574 E.07429
G1 X99.021 Y118.548 E.00646
G3 X97.126 Y120.324 I.048 J1.951 E.31248
M204 S250
G1 X97.518 Y120.342 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X97.579 Y120.04 E.00948
G3 X98.876 Y118.952 I1.49 J.459 E.05498
G1 X99.031 Y118.94 E.00478
G3 X97.513 Y120.402 I.039 J1.559 E.22995
; WIPE_START
M204 S6000
G1 X97.579 Y120.04 E-.13979
G1 X97.7 Y119.754 E-.11798
G1 X97.874 Y119.497 E-.11801
G1 X98.039 Y119.329 E-.08941
G1 X98.29 Y119.149 E-.11733
G1 X98.573 Y119.021 E-.11812
G1 X98.725 Y118.986 E-.05936
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.186 Y111.368 Z.8 F42000
G1 X101.395 Y74.85 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X101.323 Y75.195 E.01171
G3 X98.776 Y72.158 I-2.254 J-.697 E.33553
G1 X99.011 Y72.14 E.00781
G3 X101.417 Y74.735 I.059 J2.358 E.13271
G1 X101.406 Y74.791 E.00189
M204 S10000
G1 X100.998 Y74.769 F42000
G1 F15476.087
M204 S6000
G1 X100.934 Y75.075 E.01036
G3 X98.827 Y72.562 I-1.865 J-.576 E.2776
G1 X99.021 Y72.548 E.00646
G3 X101.011 Y74.694 I.048 J1.951 E.10979
G1 X101.009 Y74.71 E.00054
M204 S250
G1 X100.615 Y74.692 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X100.559 Y74.959 E.0084
G3 X98.876 Y72.952 I-1.49 J-.46 E.20545
G1 X99.031 Y72.94 E.00478
G3 X100.623 Y74.633 I.039 J1.559 E.08056
; WIPE_START
M204 S6000
G1 X100.559 Y74.959 E-.12656
G1 X100.44 Y75.246 E-.11793
G1 X100.265 Y75.503 E-.1181
M73 P34 R21
G1 X100.043 Y75.72 E-.11814
G1 X99.848 Y75.852 E-.08954
G1 X99.567 Y75.979 E-.11712
G1 X99.38 Y76.022 E-.07261
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.306 Y80.832 Z.8 F42000
G1 X143.373 Y111.732 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.42 Y111.637 E.00351
G3 X145.505 Y110.214 I2.43 J1.321 E.08697
G1 X145.781 Y110.193 E.00917
G3 X143.3 Y111.885 I.069 J2.765 E.47125
G1 X143.347 Y111.786 E.00365
M204 S10000
G1 X143.729 Y111.945 F42000
G1 F15476.087
M204 S6000
G1 X143.778 Y111.832 E.00409
G3 X145.556 Y110.618 I2.072 J1.127 E.07417
G1 X145.791 Y110.6 E.00782
G3 X143.595 Y112.265 I.059 J2.358 E.39406
G1 X143.706 Y112 E.0095
M204 S10000
G1 X144.103 Y112.102 F42000
G1 F15476.087
M204 S6000
G1 X144.135 Y112.026 E.00274
G3 X145.607 Y111.022 I1.714 J.932 E.06136
G1 X145.801 Y111.008 E.00647
G3 X143.985 Y112.385 I.049 J1.951 E.32602
G1 X144.079 Y112.158 E.00816
M204 S250
G1 X144.463 Y112.254 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.48 Y112.214 E.00134
G3 X145.656 Y111.412 I1.37 J.745 E.04541
G1 X145.811 Y111.4 E.00479
G3 X144.36 Y112.5 I.039 J1.559 E.24129
G1 X144.439 Y112.309 E.00635
; WIPE_START
M204 S6000
G1 X144.48 Y112.214 E-.0394
G1 X144.654 Y111.957 E-.11796
G1 X144.819 Y111.789 E-.08941
G1 X145.07 Y111.609 E-.11733
G1 X145.353 Y111.481 E-.11813
G1 X145.656 Y111.412 E-.11798
G1 X145.811 Y111.4 E-.05918
G1 X146.075 Y111.42 E-.10062
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.457 Y111.891 Z.8 F42000
G1 X113.009 Y113.463 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X112.97 Y113.642 E.00607
G3 X109.946 Y110.214 I-2.68 J-.684 E.39806
G1 X110.221 Y110.193 E.00916
G3 X113.025 Y113.372 I.069 J2.765 E.16019
G1 X113.019 Y113.404 E.00109
M204 S10000
G1 X112.597 Y113.419 F42000
G1 F15476.087
M204 S6000
G1 X112.506 Y113.767 E.01193
G3 X109.996 Y110.618 I-2.216 J-.808 E.33164
G1 X110.231 Y110.6 E.00781
G3 X112.622 Y113.311 I.058 J2.358 E.1366
G1 X112.61 Y113.36 E.00166
M204 S10000
G1 X112.204 Y113.319 F42000
G1 F15476.087
M204 S6000
G1 X112.123 Y113.627 E.01058
G3 X110.047 Y111.022 I-1.834 J-.668 E.27437
G1 X110.241 Y111.008 E.00646
G3 X112.219 Y113.251 I.048 J1.951 E.11301
G1 X112.217 Y113.26 E.00032
M204 S250
G1 X111.825 Y113.222 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.755 Y113.493 E.0086
G3 X110.096 Y111.412 I-1.465 J-.534 E.20307
G1 X110.251 Y111.4 E.00478
G3 X111.835 Y113.163 I.039 J1.559 E.08274
; WIPE_START
M204 S6000
G1 X111.755 Y113.493 E-.12911
G1 X111.621 Y113.774 E-.11804
G1 X111.433 Y114.021 E-.11808
G1 X111.201 Y114.227 E-.11802
G1 X110.932 Y114.382 E-.118
G1 X110.637 Y114.481 E-.11815
G1 X110.531 Y114.494 E-.0406
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X110.904 Y106.871 Z.8 F42000
G1 X111.991 Y84.66 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X111.904 Y84.725 E.00361
G3 X109.946 Y79.733 I-1.614 J-2.246 E.33403
G1 X110.221 Y79.713 E.00916
G3 X112.119 Y84.553 I.068 J2.765 E.22421
G1 X112.037 Y84.621 E.00356
M204 S10000
G1 X111.762 Y84.313 F42000
G1 F15476.087
M204 S6000
G1 X111.666 Y84.394 E.00419
G3 X109.996 Y80.138 I-1.377 J-1.916 E.28484
G1 X110.231 Y80.12 E.00781
G3 X112.018 Y84.084 I.058 J2.358 E.1834
G1 X111.807 Y84.273 E.0094
M204 S10000
G1 X111.494 Y84.009 F42000
G1 F15476.087
M204 S6000
G1 X111.428 Y84.064 E.00284
G3 X110.047 Y80.542 I-1.139 J-1.585 E.23566
G1 X110.241 Y80.528 E.00646
G3 X111.72 Y83.807 I.048 J1.951 E.15174
G1 X111.539 Y83.969 E.00805
M204 S250
G1 X111.236 Y83.716 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.2 Y83.745 E.00143
G3 X110.096 Y80.932 I-.91 J-1.266 E.17441
G1 X110.251 Y80.92 E.00478
G3 X111.432 Y83.54 I.039 J1.559 E.11231
G1 X111.28 Y83.676 E.00626
; WIPE_START
M204 S6000
G1 X111.2 Y83.745 E-.04047
G1 X110.932 Y83.902 E-.11798
G1 X110.637 Y84.001 E-.11806
G1 X110.329 Y84.04 E-.11811
G1 X110.019 Y84.017 E-.11804
G1 X109.72 Y83.932 E-.11808
G1 X109.443 Y83.791 E-.11807
G1 X109.42 Y83.772 E-.01119
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X116.919 Y82.351 Z.8 F42000
G1 X121.854 Y81.416 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.295 Y81.416 E.71125
G2 X148.405 Y81.416 I2.555 J1.062 E.36066
G1 X159.854 Y81.416 E.37979
G1 X159.854 Y127.472 E1.52774
G1 X159.664 Y127.515 E.00646
G2 X159.664 Y129.485 I-2.588 J.985 E.51037
G1 X159.854 Y129.529 E.00646
G1 X159.854 Y211.084 E2.70534
G1 X136.488 Y211.084 E.77509
G1 X136.436 Y210.909 E.00606
G2 X132.658 Y207.13 I-1.372 J-2.407 E.33776
G1 X132.486 Y207.076 E.00598
G1 X132.486 Y123.284 E2.77955
G1 X100.088 Y123.284 E1.0747
G1 X100.05 Y123.085 E.00671
G2 X96.664 Y119.135 I-.98 J-2.587 E.35187
G1 X96.486 Y119.085 E.00614
G1 X96.486 Y75.915 E1.43202
G1 X96.664 Y75.865 E.00614
G2 X96.664 Y73.135 I2.407 J-1.365 E.48194
G1 X96.486 Y73.085 E.00614
G1 X96.486 Y44.916 E.93441
G1 X141.154 Y44.916 E1.48171
G1 X141.154 Y47.584 E.08849
G1 X137.154 Y47.584 E.13269
G1 X137.154 Y65.916 E.60812
G1 X141.154 Y65.916 E.13269
G1 X141.154 Y69.084 E.10507
G1 X121.854 Y69.084 E.64022
G1 X121.854 Y81.356 E.4071
; WIPE_START
G1 X123.854 Y81.362 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.468 Y88.969 Z.8 F42000
G1 X133.959 Y206.425 Z.8
G1 Z.4
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X134.318 Y206.263 E.01307
G3 X134.776 Y206.158 I.752 J2.236 E.0156
G1 X135.011 Y206.14 E.00782
G3 X133.89 Y206.456 I.059 J2.358 E.45261
G1 X133.904 Y206.449 E.00054
M204 S10000
G1 X134.126 Y206.794 F42000
G1 F15476.087
M204 S6000
G1 X134.448 Y206.649 E.01172
G3 X134.827 Y206.562 I.622 J1.85 E.01291
G1 X135.021 Y206.548 E.00647
G3 X134.072 Y206.821 I.049 J1.951 E.37365
M204 S250
G1 X134.29 Y207.149 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G3 X134.876 Y206.952 I.78 J1.35 E.01912
G1 X135.031 Y206.94 E.00479
G3 X134.238 Y207.18 I.039 J1.559 E.27529
; WIPE_START
M204 S6000
G1 X134.573 Y207.021 E-.14072
G1 X134.876 Y206.952 E-.11798
G1 X135.031 Y206.94 E-.05919
G1 X135.341 Y206.963 E-.11809
G1 X135.493 Y206.998 E-.05912
G1 X135.782 Y207.112 E-.11797
G1 X136.043 Y207.28 E-.11811
G1 X136.097 Y207.333 E-.02882
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.664 Y209.865 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X132.783 Y210.059 E.00756
G2 X133.703 Y210.903 I2.324 J-1.611 E.04174
G1 X133.654 Y211.084 E.00622
G1 X132.486 Y211.084 E.03874
G1 X132.486 Y209.915 E.03877
G1 X132.606 Y209.881 E.00415
; WIPE_START
G1 X132.783 Y210.059 E-.09529
G1 X132.949 Y210.279 E-.10477
G1 X133.137 Y210.481 E-.10488
G1 X133.344 Y210.664 E-.10484
G1 X133.703 Y210.903 E-.16371
G1 X133.654 Y211.084 E-.07121
G1 X133.351 Y211.084 E-.11529
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.702 Y203.479 Z.8 F42000
G1 X122.261 Y81.009 Z.8
G1 Z.4
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X143.986 Y81.009 E.72066
G2 X144.042 Y83.997 I1.948 J1.458 E.10674
G2 X147.923 Y81.351 I1.801 J-1.528 E.22963
G1 X147.714 Y81.009 E.0133
G1 X160.261 Y81.009 E.4162
G1 X160.261 Y211.491 E4.32832
G1 X132.079 Y211.491 E.93484
G1 X132.079 Y123.691 E2.91249
G1 X96.079 Y123.691 E1.19419
G1 X96.079 Y44.509 E2.6266
G1 X141.561 Y44.509 E1.50871
G1 X141.561 Y47.991 E.1155
G1 X137.561 Y47.991 E.13269
G1 X137.561 Y65.509 E.58111
G1 X141.561 Y65.509 E.13269
G1 X141.561 Y69.491 E.13208
G1 X122.261 Y69.491 E.64022
G1 X122.261 Y80.949 E.38009
M204 S10000
G1 X122.668 Y80.602 F42000
G1 F15476.087
M204 S6000
G1 X144.84 Y80.602 E.73548
G1 X144.888 Y80.783 E.00622
G2 X146.811 Y80.783 I.962 J1.693 E.33909
G1 X146.86 Y80.602 E.00622
G1 X160.668 Y80.602 E.45803
G1 X160.668 Y211.898 E4.35533
G1 X131.672 Y211.898 E.96185
G1 X131.672 Y124.098 E2.91249
G1 X95.672 Y124.098 E1.19419
G1 X95.672 Y44.102 E2.65361
G1 X141.968 Y44.102 E1.53572
G1 X141.968 Y48.398 E.1425
G1 X137.968 Y48.398 E.13269
G1 X137.968 Y65.102 E.55411
G1 X141.968 Y65.102 E.13269
G1 X141.968 Y69.898 E.15909
G1 X122.668 Y69.898 E.64022
G1 X122.668 Y80.542 E.35309
M204 S250
G1 X123.06 Y80.21 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X161.06 Y80.21 E1.16763
G1 X161.06 Y212.29 E4.05845
G1 X131.28 Y212.29 E.91506
G1 X131.28 Y124.49 E2.69785
G1 X95.28 Y124.49 E1.10618
G1 X95.28 Y43.71 E2.48214
G1 X142.36 Y43.71 E1.44664
G1 X142.36 Y48.79 E.15609
G1 X138.36 Y48.79 E.12291
G1 X138.36 Y64.71 E.48918
G1 X142.36 Y64.71 E.12291
G1 X142.36 Y70.29 E.17146
G1 X123.06 Y70.29 E.59304
G1 X123.06 Y80.15 E.30297
; WIPE_START
M204 S6000
G1 X125.06 Y80.153 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 80
M625
; object ids of layer 2 start: 80,91,102,113,124
M624 HwAAAAAAAAA=
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


; object ids of this layer2 end: 80,91,102,113,124
M625
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X110.437 Y79.555 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X136.82 Y53.172 E1.14739
G1 X136.82 Y52.638 E.01641
G1 X110.068 Y79.39 E1.16345
G2 X109.417 Y79.508 I.225 J3.11 E.02038
G1 X136.82 Y52.104 E1.19176
G1 X136.82 Y51.57 E.01641
G1 X96.819 Y91.572 E1.73963
G1 X96.819 Y91.038 E.01641
G1 X136.82 Y51.037 E1.73963
G1 X136.82 Y50.503 E.01641
G1 X96.819 Y90.504 E1.73963
G1 X96.819 Y89.971 E.01641
G1 X136.82 Y49.969 E1.73963
G1 X136.82 Y49.436 E.01641
G1 X96.819 Y89.437 E1.73963
G1 X96.819 Y88.903 E.01641
G1 X136.82 Y48.902 E1.73963
G1 X136.82 Y48.368 E.01641
G1 X96.819 Y88.37 E1.73963
G1 X96.819 Y87.836 E.01641
G1 X136.99 Y47.665 E1.74701
; WIPE_START
G1 X135.576 Y49.079 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.437 Y47.42 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X140.82 Y47.037 E.01668
M73 P35 R21
G1 X140.82 Y46.503 E.01641
G1 X140.073 Y47.251 E.03251
G1 X139.539 Y47.251 E.01641
G1 X140.82 Y45.969 E.05572
G1 X140.82 Y45.436 E.01641
G1 X139.006 Y47.251 E.07893
G1 X138.472 Y47.251 E.01641
G1 X140.473 Y45.249 E.08703
G1 X139.939 Y45.249 E.01641
G1 X137.938 Y47.251 E.08703
G1 X137.404 Y47.251 E.01641
G1 X139.406 Y45.249 E.08703
G1 X138.872 Y45.249 E.01641
G1 X96.819 Y87.302 E1.82886
G1 X96.819 Y86.768 E.01641
G1 X138.338 Y45.249 E1.80564
G1 X137.805 Y45.249 E.01641
G1 X96.819 Y86.235 E1.78243
G1 X96.819 Y85.701 E.01641
G1 X137.271 Y45.249 E1.75922
G1 X136.737 Y45.249 E.01641
G1 X96.819 Y85.167 E1.73601
G1 X96.819 Y84.634 E.01641
G1 X136.204 Y45.249 E1.7128
G1 X135.67 Y45.249 E.01641
G1 X96.819 Y84.1 E1.68959
G1 X96.819 Y83.566 E.01641
G1 X135.136 Y45.249 E1.66638
G1 X134.602 Y45.249 E.01641
G1 X96.819 Y83.033 E1.64317
G1 X96.819 Y82.499 E.01641
G1 X134.069 Y45.249 E1.61996
G1 X133.535 Y45.249 E.01641
G1 X96.819 Y81.965 E1.59675
G1 X96.819 Y81.432 E.01641
G1 X133.001 Y45.249 E1.57354
G1 X132.468 Y45.249 E.01641
G1 X96.819 Y80.898 E1.55033
G1 X96.819 Y80.364 E.01641
G1 X99.638 Y77.545 E.12259
G3 X99.051 Y77.598 I-.578 J-3.134 E.01814
G1 X96.819 Y79.83 E.09708
G1 X96.819 Y79.297 E.01641
G1 X98.558 Y77.558 E.07563
G3 X98.13 Y77.452 I.742 J-3.926 E.01356
G1 X96.819 Y78.763 E.05701
G1 X96.819 Y78.229 E.01641
G1 X97.747 Y77.302 E.04035
G3 X97.401 Y77.114 I.767 J-1.823 E.01212
G1 X96.819 Y77.696 E.02531
G1 X96.819 Y77.162 E.01641
G1 X97.214 Y76.767 E.01717
M204 S10000
G1 X96.913 Y76.575 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.121792
G1 F15000
M204 S6000
G1 X96.69 Y76.371 E.00194
M204 S10000
G1 X96.523 Y75.693 F42000
; LINE_WIDTH: 0.436852
G1 F15000
M204 S6000
G1 X96.49 Y75.504 E.00616
; LINE_WIDTH: 0.405956
G1 X96.456 Y75.315 E.00568
; LINE_WIDTH: 0.371532
G1 X96.438 Y75.17 E.00391
; LINE_WIDTH: 0.337296
G1 X96.422 Y75.043 E.00309
; LINE_WIDTH: 0.300391
G1 X96.401 Y74.773 E.00567
; LINE_WIDTH: 0.272629
G1 X96.401 Y74.239 E.01
; LINE_WIDTH: 0.29848
G1 X96.42 Y73.971 E.00559
; LINE_WIDTH: 0.335595
G1 X96.438 Y73.83 E.0034
; LINE_WIDTH: 0.369311
G1 X96.454 Y73.702 E.00342
; LINE_WIDTH: 0.404455
G1 X96.49 Y73.496 E.00616
; LINE_WIDTH: 0.436851
G1 X96.523 Y73.307 E.00616
M204 S10000
G1 X96.69 Y72.629 F42000
; LINE_WIDTH: 0.121699
G1 F15000
M204 S6000
G1 X96.912 Y72.426 E.00194
; WIPE_START
G1 X96.69 Y72.629 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.889 Y75.294 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X131.934 Y45.249 E1.30664
G1 X131.4 Y45.249 E.01641
G1 X102.17 Y74.479 E1.27119
G2 X102.126 Y73.99 I-2.466 J-.021 E.01513
G1 X130.867 Y45.249 E1.24993
G1 X130.333 Y45.249 E.01641
G1 X102.024 Y73.559 E1.23115
G2 X101.871 Y73.177 I-1.979 J.571 E.01265
G1 X129.799 Y45.249 E1.21458
G1 X129.266 Y45.249 E.01641
G1 X101.682 Y72.833 E1.19961
G2 X101.458 Y72.523 I-1.667 J.964 E.01178
G1 X128.732 Y45.249 E1.18611
G1 X128.198 Y45.249 E.01641
G1 X101.199 Y72.248 E1.17416
G2 X100.908 Y72.006 I-1.351 J1.334 E.01168
G1 X127.664 Y45.249 E1.16364
G1 X127.131 Y45.249 E.01641
G1 X100.583 Y71.797 E1.15454
G2 X100.224 Y71.622 I-1.054 J1.712 E.0123
G1 X126.597 Y45.249 E1.14695
G1 X126.063 Y45.249 E.01641
G1 X99.819 Y71.494 E1.14135
G2 X99.364 Y71.415 I-.62 J2.232 E.01422
G1 X125.53 Y45.249 E1.13793
G1 X124.996 Y45.249 E.01641
G1 X98.834 Y71.411 E1.13777
G2 X98.169 Y71.543 I.185 J2.686 E.0209
M73 P35 R20
G1 X124.462 Y45.249 E1.14348
G1 X123.929 Y45.249 E.01641
G1 X97.073 Y72.105 E1.16792
G1 X96.901 Y71.91 E.00799
G1 X96.819 Y71.982 E.00337
G1 X96.819 Y71.825 E.00484
G1 X123.395 Y45.249 E1.15576
G1 X122.861 Y45.249 E.01641
G1 X96.819 Y71.291 E1.13255
G1 X96.819 Y70.758 E.01641
G1 X122.327 Y45.249 E1.10934
G1 X121.794 Y45.249 E.01641
G1 X96.819 Y70.224 E1.08613
G1 X96.819 Y69.69 E.01641
G1 X121.26 Y45.249 E1.06292
G1 X120.726 Y45.249 E.01641
G1 X96.819 Y69.157 E1.03971
G1 X96.819 Y68.623 E.01641
G1 X120.193 Y45.249 E1.0165
G1 X119.659 Y45.249 E.01641
G1 X96.819 Y68.089 E.99329
G1 X96.819 Y67.555 E.01641
G1 X119.125 Y45.249 E.97008
G1 X118.592 Y45.249 E.01641
G1 X96.819 Y67.022 E.94687
G1 X96.819 Y66.488 E.01641
G1 X118.058 Y45.249 E.92366
G1 X117.524 Y45.249 E.01641
G1 X96.819 Y65.954 E.90045
G1 X96.819 Y65.421 E.01641
G1 X116.99 Y45.249 E.87724
G1 X116.457 Y45.249 E.01641
G1 X96.819 Y64.887 E.85403
G1 X96.819 Y64.353 E.01641
G1 X115.923 Y45.249 E.83082
G1 X115.389 Y45.249 E.01641
G1 X96.819 Y63.82 E.80761
G1 X96.819 Y63.286 E.01641
G1 X114.856 Y45.249 E.7844
G1 X114.322 Y45.249 E.01641
G1 X96.819 Y62.752 E.76119
G1 X96.819 Y62.218 E.01641
G1 X113.788 Y45.249 E.73798
G1 X113.255 Y45.249 E.01641
G1 X96.819 Y61.685 E.71477
G1 X96.819 Y61.151 E.01641
G1 X112.721 Y45.249 E.69156
G1 X112.187 Y45.249 E.01641
G1 X96.819 Y60.617 E.66835
G1 X96.819 Y60.084 E.01641
G1 X111.654 Y45.249 E.64514
G1 X111.12 Y45.249 E.01641
G1 X96.819 Y59.55 E.62193
G1 X96.819 Y59.016 E.01641
G1 X110.586 Y45.249 E.59872
G1 X110.052 Y45.249 E.01641
G1 X96.819 Y58.483 E.57551
G1 X96.819 Y57.949 E.01641
G1 X109.519 Y45.249 E.5523
G1 X108.985 Y45.249 E.01641
G1 X96.819 Y57.415 E.52909
G1 X96.819 Y56.882 E.01641
G1 X108.451 Y45.249 E.50588
G1 X107.918 Y45.249 E.01641
G1 X96.819 Y56.348 E.48267
G1 X96.819 Y55.814 E.01641
G1 X107.384 Y45.249 E.45946
G1 X106.85 Y45.249 E.01641
G1 X96.819 Y55.28 E.43625
G1 X96.819 Y54.747 E.01641
G1 X106.317 Y45.249 E.41304
G1 X105.783 Y45.249 E.01641
G1 X96.819 Y54.213 E.38983
G1 X96.819 Y53.679 E.01641
G1 X105.249 Y45.249 E.36662
G1 X104.715 Y45.249 E.01641
G1 X96.819 Y53.146 E.34341
G1 X96.819 Y52.612 E.01641
G1 X104.182 Y45.249 E.3202
G1 X103.648 Y45.249 E.01641
G1 X96.819 Y52.078 E.29699
G1 X96.819 Y51.545 E.01641
G1 X103.114 Y45.249 E.27378
G1 X102.581 Y45.249 E.01641
G1 X96.819 Y51.011 E.25057
G1 X96.819 Y50.477 E.01641
G1 X102.047 Y45.249 E.22736
G1 X101.513 Y45.249 E.01641
G1 X96.819 Y49.943 E.20415
G1 X96.819 Y49.41 E.01641
G1 X100.98 Y45.249 E.18093
G1 X100.446 Y45.249 E.01641
G1 X96.819 Y48.876 E.15772
G1 X96.819 Y48.342 E.01641
G1 X99.912 Y45.249 E.13451
G1 X99.379 Y45.249 E.01641
G1 X96.819 Y47.809 E.1113
G1 X96.819 Y47.275 E.01641
G1 X98.845 Y45.249 E.08809
G1 X98.311 Y45.249 E.01641
G1 X96.819 Y46.741 E.06488
G1 X96.819 Y46.208 E.01641
G1 X97.777 Y45.249 E.04167
G1 X97.244 Y45.249 E.01641
G1 X96.65 Y45.844 E.02584
M204 S10000
G1 X107.593 Y81.332 F42000
G1 F15000
M204 S6000
G1 X96.819 Y92.105 E.46855
G1 X96.819 Y92.639 E.01641
G1 X107.199 Y82.259 E.45143
G2 X107.204 Y82.788 I2.641 J.243 E.01631
G1 X96.819 Y93.173 E.45162
G1 X96.819 Y93.707 E.01641
G1 X107.287 Y83.239 E.45522
G2 X107.417 Y83.643 I2.085 J-.448 E.01306
G1 X96.819 Y94.24 E.46087
G1 X96.819 Y94.774 E.01641
G1 X107.59 Y84.003 E.46843
G2 X107.802 Y84.325 I1.714 J-.894 E.01187
G1 X96.819 Y95.308 E.47762
G1 X96.819 Y95.841 E.01641
G1 X108.045 Y84.615 E.48822
G2 X108.321 Y84.874 I1.431 J-1.249 E.01163
G1 X96.819 Y96.375 E.50019
G1 X96.819 Y96.909 E.01641
G1 X108.63 Y85.098 E.51363
G2 X108.976 Y85.286 I1.111 J-1.641 E.01213
G1 X96.819 Y97.442 E.52869
G1 X96.819 Y97.976 E.01641
G1 X109.36 Y85.435 E.54539
G2 X109.79 Y85.539 I1.112 J-3.662 E.01361
G1 X96.819 Y98.51 E.56408
G1 X96.819 Y99.044 E.01641
G1 X110.284 Y85.579 E.58558
G2 X110.874 Y85.523 I-.011 J-3.25 E.01824
G1 X96.65 Y99.747 E.61861
M204 S10000
G1 X100.393 Y117.885 F42000
G1 F15000
M204 S6000
G1 X136.529 Y81.749 E1.57151
G1 X135.995 Y81.749 E.01641
G1 X100.149 Y117.595 E1.5589
G2 X99.736 Y117.475 I-.806 J2.002 E.01326
G1 X135.461 Y81.749 E1.55367
G1 X134.927 Y81.749 E.01641
G1 X99.27 Y117.406 E1.5507
G2 X98.724 Y117.42 I-.207 J2.743 E.01685
G1 X134.394 Y81.749 E1.55128
G1 X133.86 Y81.749 E.01641
G1 X98.028 Y117.581 E1.5583
G2 X96.965 Y118.232 I.927 J2.707 E.03864
G1 X96.907 Y118.169 E.00265
G1 X133.326 Y81.749 E1.58387
G1 X132.793 Y81.749 E.01641
G1 X96.819 Y117.723 E1.56447
G1 X96.819 Y117.189 E.01641
G1 X132.259 Y81.749 E1.54126
G1 X131.725 Y81.749 E.01641
G1 X96.819 Y116.655 E1.51805
G1 X96.819 Y116.122 E.01641
G1 X131.192 Y81.749 E1.49484
G1 X130.658 Y81.749 E.01641
G1 X96.819 Y115.588 E1.47163
G1 X96.819 Y115.054 E.01641
G1 X130.124 Y81.749 E1.44842
G1 X129.591 Y81.749 E.01641
G1 X96.819 Y114.521 E1.42521
M73 P36 R20
G1 X96.819 Y113.987 E.01641
G1 X129.057 Y81.749 E1.402
G1 X128.523 Y81.749 E.01641
G1 X96.819 Y113.453 E1.37879
G1 X96.819 Y112.92 E.01641
G1 X127.989 Y81.749 E1.35558
G1 X127.456 Y81.749 E.01641
G1 X96.819 Y112.386 E1.33237
G1 X96.819 Y111.852 E.01641
G1 X126.922 Y81.749 E1.30916
G1 X126.388 Y81.749 E.01641
G1 X96.819 Y111.319 E1.28595
G1 X96.819 Y110.785 E.01641
G1 X125.855 Y81.749 E1.26274
G1 X125.321 Y81.749 E.01641
G1 X96.819 Y110.251 E1.23953
G1 X96.819 Y109.717 E.01641
G1 X124.787 Y81.749 E1.21632
G1 X124.254 Y81.749 E.01641
G1 X96.819 Y109.184 E1.19311
G1 X96.819 Y108.65 E.01641
G1 X123.72 Y81.749 E1.1699
G1 X123.186 Y81.749 E.01641
G1 X96.819 Y108.116 E1.14669
G1 X96.819 Y107.583 E.01641
G1 X122.652 Y81.749 E1.12348
G1 X122.119 Y81.749 E.01641
G1 X96.819 Y107.049 E1.10027
G1 X96.819 Y106.515 E.01641
G1 X121.585 Y81.749 E1.07705
G1 X121.52 Y81.749 E.00199
G1 X121.52 Y81.28 E.01443
G1 X96.819 Y105.982 E1.07424
G1 X96.819 Y105.448 E.01641
G1 X121.52 Y80.747 E1.07424
G1 X121.52 Y80.213 E.01641
G1 X96.819 Y104.914 E1.07424
G1 X96.819 Y104.38 E.01641
G1 X121.52 Y79.679 E1.07424
G1 X121.52 Y79.146 E.01641
G1 X96.819 Y103.847 E1.07424
G1 X96.819 Y103.313 E.01641
G1 X121.52 Y78.612 E1.07424
G1 X121.52 Y78.078 E.01641
G1 X96.819 Y102.779 E1.07424
G1 X96.819 Y102.246 E.01641
G1 X121.52 Y77.544 E1.07424
G1 X121.52 Y77.011 E.01641
G1 X96.819 Y101.712 E1.07425
G1 X96.819 Y101.178 E.01641
G1 X121.52 Y76.477 E1.07424
G1 X121.52 Y75.943 E.01641
G1 X96.819 Y100.645 E1.07425
G1 X96.819 Y100.111 E.01641
G1 X121.52 Y75.41 E1.07425
G1 X121.52 Y74.876 E.01641
G1 X113.332 Y83.064 E.35611
G2 X113.383 Y82.48 I-2.656 J-.526 E.01809
G1 X121.52 Y74.342 E.35389
G1 X121.52 Y73.809 E.01641
G1 X113.347 Y81.982 E.35544
G2 X113.247 Y81.548 I-4.055 J.709 E.01369
G1 X121.52 Y73.275 E.3598
G1 X121.52 Y72.741 E.01641
G1 X113.095 Y81.166 E.3664
G2 X112.907 Y80.821 I-1.816 J.77 E.01211
G1 X121.52 Y72.207 E.37461
G1 X121.52 Y71.674 E.01641
G1 X112.684 Y80.51 E.3843
G2 X112.426 Y80.234 I-3.945 J3.419 E.01161
G1 X121.52 Y71.14 E.39549
G1 X121.52 Y70.606 E.01641
G1 X112.135 Y79.992 E.40816
G2 X111.811 Y79.782 I-1.214 J1.517 E.01189
G1 X121.52 Y70.073 E.42224
G1 X121.52 Y69.539 E.01641
G1 X111.453 Y79.606 E.43783
G2 X111.05 Y79.476 I-1.454 J3.813 E.01304
G1 X136.82 Y53.705 E1.12076
G1 X136.82 Y54.239 E.01641
G1 X122.309 Y68.751 E.6311
G1 X122.842 Y68.751 E.01641
G1 X136.82 Y54.773 E.60789
G1 X136.82 Y55.306 E.01641
G1 X123.376 Y68.751 E.58468
G1 X123.91 Y68.751 E.01641
G1 X136.82 Y55.84 E.56147
G1 X136.82 Y56.374 E.01641
G1 X124.444 Y68.751 E.53826
G1 X124.977 Y68.751 E.01641
G1 X136.82 Y56.907 E.51505
G1 X136.82 Y57.441 E.01641
G1 X125.511 Y68.751 E.49184
G1 X126.045 Y68.751 E.01641
G1 X136.82 Y57.975 E.46863
G1 X136.82 Y58.509 E.01641
G1 X126.578 Y68.751 E.44542
G1 X127.112 Y68.751 E.01641
G1 X136.82 Y59.042 E.42221
G1 X136.82 Y59.576 E.01641
G1 X127.646 Y68.751 E.399
G1 X128.179 Y68.751 E.01641
G1 X136.82 Y60.11 E.37579
G1 X136.82 Y60.643 E.01641
G1 X128.713 Y68.751 E.35258
G1 X129.247 Y68.751 E.01641
G1 X136.82 Y61.177 E.32937
G1 X136.82 Y61.711 E.01641
G1 X129.781 Y68.751 E.30616
G1 X130.314 Y68.751 E.01641
G1 X136.82 Y62.244 E.28295
G1 X136.82 Y62.778 E.01641
G1 X130.848 Y68.751 E.25974
G1 X131.382 Y68.751 E.01641
G1 X136.82 Y63.312 E.23653
G1 X136.82 Y63.846 E.01641
G1 X131.915 Y68.751 E.21332
G1 X132.449 Y68.751 E.01641
G1 X136.82 Y64.379 E.19011
G1 X136.82 Y64.913 E.01641
G1 X132.983 Y68.751 E.1669
G1 X133.516 Y68.751 E.01641
G1 X136.82 Y65.447 E.14369
G1 X136.82 Y65.98 E.01641
G1 X134.05 Y68.751 E.12048
G1 X134.584 Y68.751 E.01641
G1 X137.085 Y66.249 E.10878
G1 X137.619 Y66.249 E.01641
G1 X135.118 Y68.751 E.10878
G1 X135.651 Y68.751 E.01641
G1 X138.152 Y66.249 E.10878
G1 X138.686 Y66.249 E.01641
G1 X136.185 Y68.751 E.10878
G1 X136.719 Y68.751 E.01641
G1 X139.22 Y66.249 E.10878
G1 X139.754 Y66.249 E.01641
G1 X137.252 Y68.751 E.10878
G1 X137.786 Y68.751 E.01641
G1 X140.287 Y66.249 E.10878
G1 X140.82 Y66.249 E.0164
G1 X138.32 Y68.751 E.10877
G1 X138.853 Y68.751 E.01641
G1 X140.82 Y66.784 E.08555
G1 X140.82 Y67.317 E.01641
G1 X139.387 Y68.751 E.06234
G1 X139.921 Y68.751 E.01641
G1 X140.82 Y67.851 E.03913
G1 X140.82 Y68.385 E.01641
G1 X140.285 Y68.92 E.0233
; WIPE_START
G1 X140.82 Y68.385 E-.28787
G1 X140.82 Y67.851 E-.20281
G1 X140.319 Y68.352 E-.26933
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.702 Y75.603 Z.8 F42000
G1 X144.411 Y80.806 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.113556
G1 F15000
M204 S6000
G1 X144.272 Y80.978 E.00128
M204 S10000
G1 X145.115 Y80.872 F42000
; LINE_WIDTH: 0.399761
G1 F15000
M204 S6000
G1 X145.244 Y80.635 E.00784
; LINE_WIDTH: 0.430273
G1 X145.258 Y80.611 E.00089
G1 X145.427 Y80.588 E.0054
; LINE_WIDTH: 0.374634
G1 X145.81 Y80.565 E.01037
G1 X146.176 Y80.579 E.00991
; LINE_WIDTH: 0.409236
G1 X146.369 Y80.6 E.00578
; LINE_WIDTH: 0.444199
G3 X146.645 Y80.645 I-.766 J5.609 E.00917
M204 S10000
G1 X147.288 Y80.806 F42000
; LINE_WIDTH: 0.113532
G1 F15000
M204 S6000
G1 X147.428 Y80.978 E.00127
; WIPE_START
G1 X147.288 Y80.806 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.77 Y82.317 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X149.337 Y81.749 E.02468
G1 X149.871 Y81.749 E.01641
G1 X148.943 Y82.677 E.04034
G3 X148.832 Y83.322 I-3.363 J-.249 E.02017
G1 X150.405 Y81.749 E.06841
G1 X150.938 Y81.749 E.01641
G1 X109.737 Y122.951 E1.79182
G1 X110.271 Y122.951 E.01641
G1 X151.472 Y81.749 E1.79182
G1 X152.006 Y81.749 E.01641
G1 X110.804 Y122.951 E1.79182
G1 X111.338 Y122.951 E.01641
G1 X152.539 Y81.749 E1.79182
G1 X153.073 Y81.749 E.01641
G1 X111.872 Y122.951 E1.79182
G1 X112.406 Y122.951 E.01641
G1 X153.607 Y81.749 E1.79182
G1 X154.141 Y81.749 E.01641
G1 X112.939 Y122.951 E1.79182
G1 X113.473 Y122.951 E.01641
G1 X154.674 Y81.749 E1.79182
G1 X155.208 Y81.749 E.01641
G1 X114.007 Y122.951 E1.79182
G1 X114.54 Y122.951 E.01641
G1 X155.742 Y81.749 E1.79182
G1 X156.275 Y81.749 E.01641
G1 X115.074 Y122.951 E1.79182
G1 X115.608 Y122.951 E.01641
G1 X156.809 Y81.749 E1.79182
G1 X157.343 Y81.749 E.01641
G1 X116.141 Y122.951 E1.79182
G1 X116.675 Y122.951 E.01641
G1 X157.876 Y81.749 E1.79182
G1 X158.41 Y81.749 E.01641
G1 X117.209 Y122.951 E1.79182
G1 X117.743 Y122.951 E.01641
G1 X158.944 Y81.749 E1.79182
G1 X159.477 Y81.749 E.01641
G1 X118.276 Y122.951 E1.79182
G1 X118.81 Y122.951 E.01641
G1 X159.52 Y82.24 E1.77048
G1 X159.52 Y82.774 E.01641
G1 X119.344 Y122.951 E1.74727
G1 X119.877 Y122.951 E.01641
G1 X159.52 Y83.307 E1.72406
G1 X159.52 Y83.841 E.01641
G1 X120.411 Y122.951 E1.70085
G1 X120.945 Y122.951 E.01641
G1 X159.52 Y84.375 E1.67764
G1 X159.52 Y84.909 E.01641
G1 X121.478 Y122.951 E1.65443
G1 X122.012 Y122.951 E.01641
G1 X159.52 Y85.442 E1.63122
G1 X159.52 Y85.976 E.01641
G1 X122.546 Y122.951 E1.60801
G1 X123.079 Y122.951 E.01641
G1 X159.52 Y86.51 E1.5848
G1 X159.52 Y87.043 E.01641
G1 X123.613 Y122.951 E1.56159
G1 X124.147 Y122.951 E.01641
G1 X159.52 Y87.577 E1.53838
G1 X159.52 Y88.111 E.01641
G1 X124.681 Y122.951 E1.51517
G1 X125.214 Y122.951 E.01641
G1 X159.52 Y88.644 E1.49196
G1 X159.52 Y89.178 E.01641
G1 X125.748 Y122.951 E1.46875
G1 X126.282 Y122.951 E.01641
G1 X159.52 Y89.712 E1.44554
G1 X159.52 Y90.246 E.01641
G1 X126.815 Y122.951 E1.42233
G1 X127.349 Y122.951 E.01641
M73 P37 R20
G1 X159.52 Y90.779 E1.39912
G1 X159.52 Y91.313 E.01641
G1 X127.883 Y122.951 E1.37591
G1 X128.416 Y122.951 E.01641
G1 X159.52 Y91.847 E1.3527
G1 X159.52 Y92.38 E.01641
G1 X128.95 Y122.951 E1.32949
G1 X129.484 Y122.951 E.01641
G1 X159.52 Y92.914 E1.30628
G1 X159.52 Y93.448 E.01641
G1 X130.018 Y122.951 E1.28307
G1 X130.551 Y122.951 E.01641
G1 X159.52 Y93.981 E1.25986
G1 X159.52 Y94.515 E.01641
G1 X131.085 Y122.951 E1.23665
G1 X131.619 Y122.951 E.01641
G1 X159.52 Y95.049 E1.21344
G1 X159.52 Y95.582 E.01641
G1 X145.168 Y109.935 E.62417
G3 X145.777 Y109.86 I.852 J4.399 E.01888
G1 X159.52 Y96.116 E.59769
G1 X159.52 Y96.65 E.01641
G1 X146.279 Y109.892 E.57588
G3 X146.72 Y109.984 I-.573 J3.828 E.01387
G1 X159.52 Y97.184 E.5567
G1 X159.52 Y97.717 E.01641
G1 X147.108 Y110.129 E.5398
G3 X147.459 Y110.312 I-.739 J1.847 E.01219
G1 X159.52 Y98.251 E.52454
G1 X159.52 Y98.785 E.01641
G1 X147.776 Y110.529 E.51077
G3 X148.056 Y110.783 I-3.652 J4.313 E.01162
G1 X159.52 Y99.318 E.4986
G1 X159.52 Y99.852 E.01641
G1 X148.303 Y111.069 E.48782
G3 X148.519 Y111.387 I-1.484 J1.237 E.01184
G1 X159.52 Y100.386 E.47845
G1 X159.52 Y100.919 E.01641
G1 X148.7 Y111.74 E.47056
G3 X148.837 Y112.137 I-4.118 J1.637 E.01292
G1 X159.52 Y101.453 E.46463
G1 X159.52 Y101.987 E.01641
G1 X148.925 Y112.582 E.46077
G1 X148.946 Y113.095 E.01579
G1 X159.52 Y102.521 E.45987
G1 X159.52 Y103.054 E.01641
G1 X148.599 Y113.975 E.47495
; WIPE_START
G1 X150.014 Y112.561 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.072 Y112.031 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X132.152 Y122.951 E.47489
G1 X132.686 Y122.951 E.01641
G1 X142.752 Y112.885 E.43777
G2 X142.782 Y113.389 I3.298 J.058 E.01554
G1 X132.819 Y123.351 E.43327
G1 X132.819 Y123.885 E.01641
G1 X142.875 Y113.829 E.43731
G2 X143.018 Y114.22 I3.884 J-1.207 E.01279
G1 X132.819 Y124.419 E.44355
G1 X132.819 Y124.952 E.01641
G1 X143.203 Y114.569 E.45157
G2 X143.421 Y114.884 I1.682 J-.933 E.01181
G1 X132.819 Y125.486 E.46107
G1 X132.819 Y126.02 E.01641
G1 X143.672 Y115.167 E.47198
G2 X143.958 Y115.415 I3.646 J-3.915 E.01164
G1 X132.819 Y126.553 E.48441
G1 X132.819 Y127.087 E.01641
G1 X144.277 Y115.629 E.4983
G2 X144.631 Y115.809 I1.077 J-1.683 E.01223
G1 X132.819 Y127.621 E.5137
G1 X132.819 Y128.154 E.01641
G1 X145.025 Y115.949 E.53081
G2 X145.473 Y116.035 I.652 J-2.196 E.01405
G1 X132.819 Y128.688 E.55029
G1 X132.819 Y129.222 E.01641
G1 X145.985 Y116.056 E.57256
G2 X146.611 Y115.964 I-.177 J-3.366 E.01949
G1 X132.819 Y129.755 E.59979
G1 X132.819 Y130.289 E.01641
G1 X159.52 Y103.588 E1.16122
G1 X159.52 Y104.122 E.01641
G1 X132.819 Y130.823 E1.16122
G1 X132.819 Y131.357 E.01641
G1 X159.52 Y104.655 E1.16122
G1 X159.52 Y105.189 E.01641
G1 X132.819 Y131.89 E1.16122
G1 X132.819 Y132.424 E.01641
G1 X159.52 Y105.723 E1.16122
G1 X159.52 Y106.256 E.01641
G1 X132.819 Y132.958 E1.16122
G1 X132.819 Y133.491 E.01641
G1 X159.52 Y106.79 E1.16122
G1 X159.52 Y107.324 E.01641
G1 X132.819 Y134.025 E1.16122
G1 X132.819 Y134.559 E.01641
G1 X159.52 Y107.857 E1.16122
G1 X159.52 Y108.391 E.01641
G1 X132.819 Y135.092 E1.16122
G1 X132.819 Y135.626 E.01641
G1 X159.52 Y108.925 E1.16122
G1 X159.52 Y109.459 E.01641
G1 X132.819 Y136.16 E1.16122
G1 X132.819 Y136.694 E.01641
G1 X159.52 Y109.992 E1.16122
G1 X159.52 Y110.526 E.01641
G1 X132.819 Y137.227 E1.16122
G1 X132.819 Y137.761 E.01641
G1 X159.52 Y111.06 E1.16122
G1 X159.52 Y111.593 E.01641
G1 X132.819 Y138.295 E1.16122
G1 X132.819 Y138.828 E.01641
G1 X159.52 Y112.127 E1.16122
G1 X159.52 Y112.661 E.01641
G1 X132.819 Y139.362 E1.16122
G1 X132.819 Y139.896 E.01641
G1 X159.52 Y113.194 E1.16122
G1 X159.52 Y113.728 E.01641
G1 X132.819 Y140.429 E1.16122
G1 X132.819 Y140.963 E.01641
G1 X159.52 Y114.262 E1.16122
G1 X159.52 Y114.796 E.01641
G1 X132.819 Y141.497 E1.16122
G1 X132.819 Y142.03 E.01641
G1 X159.52 Y115.329 E1.16122
G1 X159.52 Y115.863 E.01641
G1 X132.819 Y142.564 E1.16122
G1 X132.819 Y143.098 E.01641
G1 X159.52 Y116.397 E1.16122
G1 X159.52 Y116.93 E.01641
G1 X132.819 Y143.632 E1.16122
G1 X132.819 Y144.165 E.01641
G1 X159.52 Y117.464 E1.16122
G1 X159.52 Y117.998 E.01641
G1 X132.819 Y144.699 E1.16122
G1 X132.819 Y145.233 E.01641
G1 X159.52 Y118.531 E1.16122
G1 X159.52 Y119.065 E.01641
G1 X132.819 Y145.766 E1.16122
G1 X132.819 Y146.3 E.01641
G1 X159.52 Y119.599 E1.16122
G1 X159.52 Y120.132 E.01641
G1 X132.819 Y146.834 E1.16122
G1 X132.819 Y147.367 E.01641
G1 X159.52 Y120.666 E1.16122
G1 X159.52 Y121.2 E.01641
G1 X132.65 Y148.071 E1.1686
M204 S10000
G1 X159.516 Y130.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.108824
G1 F15000
M204 S6000
G2 X159.63 Y130.04 I-.28 J-.3 E.0012
M204 S10000
G1 X159.524 Y129.245 F42000
; LINE_WIDTH: 0.512422
G1 F13418.475
M204 S6000
G1 X159.817 Y129.065 E.01314
G2 X159.838 Y128.788 I-6.361 J-.627 E.01062
; LINE_WIDTH: 0.472769
G1 F14656.323
G2 X159.839 Y128.234 I-7.963 J-.292 E.01941
; LINE_WIDTH: 0.511454
G1 F13446.22
G2 X159.817 Y127.935 I-21.915 J1.486 E.01143
G1 X159.525 Y127.755 E.01309
M204 S10000
G1 X159.65 Y126.905 F42000
; LINE_WIDTH: 0.140566
G1 F15000
M204 S6000
G1 X159.561 Y126.799 E.00111
; LINE_WIDTH: 0.114424
G1 X159.423 Y126.65 E.00118
M204 S10000
G1 X159.69 Y125.833 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X159.24 Y126.284 E.0196
G2 X158.952 Y126.038 I-3.924 J4.294 E.01164
G1 X159.52 Y125.469 E.02473
G1 X159.52 Y124.936 E.01641
G1 X158.631 Y125.825 E.03866
G2 X158.276 Y125.646 I-1.071 J1.686 E.01224
G1 X159.52 Y124.402 E.0541
G1 X159.52 Y123.868 E.01641
G1 X157.881 Y125.508 E.0713
G2 X157.432 Y125.423 I-.647 J2.205 E.01408
G1 X159.52 Y123.335 E.09084
G1 X159.52 Y122.801 E.01641
G1 X156.916 Y125.405 E.11325
G2 X156.285 Y125.503 I.177 J3.233 E.01968
G1 X159.52 Y122.267 E.14072
G1 X159.52 Y121.734 E.01641
G1 X132.819 Y148.435 E1.16122
G1 X132.819 Y148.969 E.01641
G1 X154.073 Y127.714 E.92433
G2 X153.976 Y128.345 I3.006 J.786 E.01967
G1 X132.819 Y149.502 E.9201
G1 X132.819 Y150.036 E.01641
G1 X153.992 Y128.863 E.92079
G2 X154.079 Y129.309 I2.275 J-.214 E.01401
G1 X132.819 Y150.57 E.92459
G1 X132.819 Y151.103 E.01641
G1 X154.214 Y129.709 E.93044
G2 X154.394 Y130.062 I1.852 J-.722 E.01222
G1 X132.819 Y151.637 E.93828
G1 X132.819 Y152.171 E.01641
G1 X154.609 Y130.381 E.94761
G2 X154.856 Y130.668 I1.556 J-1.09 E.01166
G1 X132.819 Y152.704 E.95835
G1 X132.819 Y153.238 E.01641
G1 X155.134 Y130.923 E.97046
G2 X155.45 Y131.141 I3.434 J-4.626 E.0118
G1 X132.819 Y153.772 E.98418
G1 X132.819 Y154.305 E.01641
G1 X155.799 Y131.325 E.9994
G2 X156.187 Y131.471 I.923 J-1.863 E.01276
G1 X132.819 Y154.839 E1.01626
G1 X132.819 Y155.373 E.01641
G1 X156.626 Y131.566 E1.03534
G2 X157.126 Y131.6 I.419 J-2.483 E.01543
G1 X132.819 Y155.907 E1.05708
G1 X132.819 Y156.44 E.01641
G1 X157.73 Y131.529 E1.08338
G2 X158.593 Y131.2 I-.611 J-2.899 E.0285
G1 X132.819 Y156.974 E1.12089
G1 X132.819 Y157.508 E.01641
G1 X159.52 Y130.806 E1.16122
G1 X159.52 Y131.34 E.01641
G1 X132.819 Y158.041 E1.16122
G1 X132.819 Y158.575 E.01641
G1 X159.52 Y131.874 E1.16122
G1 X159.52 Y132.407 E.01641
G1 X132.819 Y159.109 E1.16122
G1 X132.819 Y159.642 E.01641
G1 X159.52 Y132.941 E1.16122
G1 X159.52 Y133.475 E.01641
G1 X132.819 Y160.176 E1.16122
G1 X132.819 Y160.71 E.01641
G1 X159.52 Y134.009 E1.16122
G1 X159.52 Y134.542 E.01641
G1 X132.819 Y161.244 E1.16122
G1 X132.819 Y161.777 E.01641
G1 X159.52 Y135.076 E1.16122
G1 X159.52 Y135.61 E.01641
G1 X132.819 Y162.311 E1.16122
G1 X132.819 Y162.845 E.01641
G1 X159.52 Y136.143 E1.16122
G1 X159.52 Y136.677 E.01641
M73 P38 R20
G1 X132.819 Y163.378 E1.16122
G1 X132.819 Y163.912 E.01641
G1 X159.52 Y137.211 E1.16122
G1 X159.52 Y137.744 E.01641
G1 X132.819 Y164.446 E1.16122
G1 X132.819 Y164.979 E.01641
G1 X159.52 Y138.278 E1.16122
G1 X159.52 Y138.812 E.01641
G1 X132.819 Y165.513 E1.16122
G1 X132.819 Y166.047 E.01641
G1 X159.52 Y139.346 E1.16122
G1 X159.52 Y139.879 E.01641
G1 X132.819 Y166.581 E1.16122
G1 X132.819 Y167.114 E.01641
G1 X159.52 Y140.413 E1.16122
G1 X159.52 Y140.947 E.01641
G1 X132.819 Y167.648 E1.16122
G1 X132.819 Y168.182 E.01641
G1 X159.52 Y141.48 E1.16122
G1 X159.52 Y142.014 E.01641
G1 X132.819 Y168.715 E1.16122
G1 X132.819 Y169.249 E.01641
G1 X159.52 Y142.548 E1.16122
G1 X159.52 Y143.081 E.01641
G1 X132.819 Y169.783 E1.16122
G1 X132.819 Y170.316 E.01641
G1 X159.52 Y143.615 E1.16122
G1 X159.52 Y144.149 E.01641
G1 X132.819 Y170.85 E1.16122
G1 X132.819 Y171.384 E.01641
G1 X159.52 Y144.682 E1.16122
G1 X159.52 Y145.216 E.01641
G1 X132.819 Y171.917 E1.16122
G1 X132.819 Y172.451 E.01641
G1 X159.52 Y145.75 E1.16122
G1 X159.52 Y146.284 E.01641
G1 X132.819 Y172.985 E1.16122
G1 X132.819 Y173.519 E.01641
G1 X159.52 Y146.817 E1.16122
G1 X159.52 Y147.351 E.01641
G1 X132.819 Y174.052 E1.16122
G1 X132.819 Y174.586 E.01641
G1 X159.52 Y147.885 E1.16122
G1 X159.52 Y148.418 E.01641
G1 X132.819 Y175.12 E1.16122
G1 X132.819 Y175.653 E.01641
G1 X159.52 Y148.952 E1.16122
G1 X159.52 Y149.486 E.01641
G1 X132.819 Y176.187 E1.16122
G1 X132.819 Y176.721 E.01641
G1 X159.52 Y150.019 E1.16122
G1 X159.52 Y150.553 E.01641
G1 X132.819 Y177.254 E1.16122
G1 X132.819 Y177.788 E.01641
G1 X159.52 Y151.087 E1.16122
G1 X159.52 Y151.621 E.01641
G1 X132.819 Y178.322 E1.16122
G1 X132.819 Y178.856 E.01641
G1 X159.52 Y152.154 E1.16122
G1 X159.52 Y152.688 E.01641
G1 X132.819 Y179.389 E1.16122
G1 X132.819 Y179.923 E.01641
G1 X159.52 Y153.222 E1.16122
G1 X159.52 Y153.755 E.01641
G1 X132.819 Y180.457 E1.16122
G1 X132.819 Y180.99 E.01641
G1 X159.52 Y154.289 E1.16122
G1 X159.52 Y154.823 E.01641
G1 X132.819 Y181.524 E1.16122
G1 X132.819 Y182.058 E.01641
G1 X159.52 Y155.356 E1.16122
G1 X159.52 Y155.89 E.01641
G1 X132.819 Y182.591 E1.16122
G1 X132.819 Y183.125 E.01641
G1 X159.52 Y156.424 E1.16122
G1 X159.52 Y156.958 E.01641
G1 X132.819 Y183.659 E1.16122
G1 X132.819 Y184.192 E.01641
G1 X159.52 Y157.491 E1.16122
G1 X159.52 Y158.025 E.01641
G1 X132.819 Y184.726 E1.16122
G1 X132.819 Y185.26 E.01641
G1 X159.52 Y158.559 E1.16122
G1 X159.52 Y159.092 E.01641
G1 X132.819 Y185.794 E1.16122
G1 X132.819 Y186.327 E.01641
G1 X159.52 Y159.626 E1.16122
G1 X159.52 Y160.16 E.01641
M73 P38 R19
G1 X132.819 Y186.861 E1.16122
G1 X132.819 Y187.395 E.01641
G1 X159.52 Y160.693 E1.16122
G1 X159.52 Y161.227 E.01641
G1 X132.819 Y187.928 E1.16122
G1 X132.819 Y188.462 E.01641
G1 X159.52 Y161.761 E1.16122
G1 X159.52 Y162.294 E.01641
G1 X132.819 Y188.996 E1.16122
G1 X132.819 Y189.529 E.01641
G1 X159.52 Y162.828 E1.16122
G1 X159.52 Y163.362 E.01641
G1 X132.819 Y190.063 E1.16122
G1 X132.819 Y190.597 E.01641
G1 X159.52 Y163.896 E1.16122
G1 X159.52 Y164.429 E.01641
G1 X132.819 Y191.131 E1.16122
G1 X132.819 Y191.664 E.01641
G1 X159.52 Y164.963 E1.16122
G1 X159.52 Y165.497 E.01641
G1 X132.819 Y192.198 E1.16122
G1 X132.819 Y192.732 E.01641
G1 X159.52 Y166.03 E1.16122
G1 X159.52 Y166.564 E.01641
G1 X132.819 Y193.265 E1.16122
G1 X132.819 Y193.799 E.01641
G1 X159.52 Y167.098 E1.16122
G1 X159.52 Y167.631 E.01641
G1 X132.819 Y194.333 E1.16122
G1 X132.819 Y194.866 E.01641
G1 X159.52 Y168.165 E1.16122
G1 X159.52 Y168.699 E.01641
G1 X132.819 Y195.4 E1.16122
G1 X132.819 Y195.934 E.01641
G1 X159.52 Y169.233 E1.16122
G1 X159.52 Y169.766 E.01641
G1 X132.819 Y196.467 E1.16122
G1 X132.819 Y197.001 E.01641
G1 X159.52 Y170.3 E1.16122
G1 X159.52 Y170.834 E.01641
G1 X132.819 Y197.535 E1.16122
G1 X132.819 Y198.069 E.01641
G1 X159.52 Y171.367 E1.16122
G1 X159.52 Y171.901 E.01641
G1 X132.819 Y198.602 E1.16122
G1 X132.819 Y199.136 E.01641
G1 X159.52 Y172.435 E1.16122
G1 X159.52 Y172.968 E.01641
G1 X132.819 Y199.67 E1.16122
G1 X132.819 Y200.203 E.01641
G1 X159.52 Y173.502 E1.16122
G1 X159.52 Y174.036 E.01641
G1 X132.819 Y200.737 E1.16122
G1 X132.819 Y201.271 E.01641
G1 X159.52 Y174.569 E1.16122
G1 X159.52 Y175.103 E.01641
G1 X132.819 Y201.804 E1.16122
G1 X132.819 Y202.338 E.01641
G1 X159.52 Y175.637 E1.16122
G1 X159.52 Y176.171 E.01641
G1 X132.819 Y202.872 E1.16122
G1 X132.819 Y203.406 E.01641
G1 X159.52 Y176.704 E1.16122
G1 X159.52 Y177.238 E.01641
G1 X132.819 Y203.939 E1.16122
G1 X132.819 Y204.473 E.01641
G1 X159.52 Y177.772 E1.16122
G1 X159.52 Y178.305 E.01641
G1 X132.819 Y205.007 E1.16122
G1 X132.819 Y205.54 E.01641
G1 X159.52 Y178.839 E1.16122
G1 X159.52 Y179.373 E.01641
G1 X132.823 Y206.07 E1.16106
G1 X132.97 Y206.221 E.00648
G3 X133.712 Y205.715 I1.898 J1.987 E.02772
G1 X159.52 Y179.906 E1.12241
G1 X159.52 Y180.44 E.01641
G1 X134.507 Y205.454 E1.08783
G3 X135.092 Y205.402 I.572 J3.12 E.01811
G1 X159.52 Y180.974 E1.06236
G1 X159.52 Y181.508 E.01641
G1 X135.585 Y205.443 E1.04093
G3 X136.013 Y205.549 I-.764 J3.988 E.01355
G1 X159.52 Y182.041 E1.02234
G1 X159.52 Y182.575 E.01641
G1 X136.396 Y205.7 E1.00569
G3 X136.741 Y205.888 I-.769 J1.822 E.01212
G1 X159.52 Y183.109 E.99066
G1 X159.52 Y183.642 E.01641
G1 X137.048 Y206.115 E.97731
G3 X137.323 Y206.374 I-1.157 J1.5 E.01163
G1 X159.52 Y184.176 E.96537
G1 X159.52 Y184.71 E.01641
G1 X137.566 Y206.665 E.95481
G3 X137.776 Y206.988 I-1.51 J1.214 E.01188
G1 X159.52 Y185.243 E.94565
G1 X159.52 Y185.777 E.01641
G1 X137.948 Y207.35 E.93819
G3 X138.077 Y207.755 I-1.96 J.847 E.01309
G1 X159.52 Y186.311 E.93258
G1 X159.52 Y186.844 E.01641
G1 X138.157 Y208.208 E.9291
G3 X138.159 Y208.739 I-2.646 J.279 E.01636
M73 P39 R19
G1 X159.52 Y187.378 E.92898
G1 X159.52 Y187.912 E.01641
G1 X138.039 Y209.393 E.93422
G3 X137.199 Y210.751 I-2.9 J-.857 E.04967
G1 X159.52 Y188.446 E.9704
G1 X159.52 Y188.979 E.01641
G1 X137.749 Y210.751 E.94683
G1 X138.283 Y210.751 E.01641
G1 X159.52 Y189.513 E.92362
G1 X159.52 Y190.047 E.01641
G1 X138.816 Y210.751 E.90041
G1 X139.35 Y210.751 E.01641
G1 X159.52 Y190.58 E.8772
G1 X159.52 Y191.114 E.01641
G1 X139.884 Y210.751 E.85399
G1 X140.418 Y210.751 E.01641
G1 X159.52 Y191.648 E.83078
G1 X159.52 Y192.181 E.01641
G1 X140.951 Y210.751 E.80757
G1 X141.485 Y210.751 E.01641
G1 X159.52 Y192.715 E.78436
G1 X159.52 Y193.249 E.01641
G1 X142.019 Y210.751 E.76115
G1 X142.552 Y210.751 E.01641
G1 X159.52 Y193.783 E.73793
G1 X159.52 Y194.316 E.01641
G1 X143.086 Y210.751 E.71472
G1 X143.62 Y210.751 E.01641
G1 X159.52 Y194.85 E.69151
G1 X159.52 Y195.384 E.01641
G1 X144.153 Y210.751 E.6683
G1 X144.687 Y210.751 E.01641
G1 X159.52 Y195.917 E.64509
G1 X159.52 Y196.451 E.01641
G1 X145.221 Y210.751 E.62188
G1 X145.755 Y210.751 E.01641
G1 X159.52 Y196.985 E.59867
G1 X159.52 Y197.518 E.01641
G1 X146.288 Y210.751 E.57546
G1 X146.822 Y210.751 E.01641
G1 X159.52 Y198.052 E.55225
G1 X159.52 Y198.586 E.01641
G1 X147.356 Y210.751 E.52904
G1 X147.889 Y210.751 E.01641
G1 X159.52 Y199.119 E.50583
G1 X159.52 Y199.653 E.01641
G1 X148.423 Y210.751 E.48262
G1 X148.957 Y210.751 E.01641
G1 X159.52 Y200.187 E.45941
G1 X159.52 Y200.721 E.01641
G1 X149.49 Y210.751 E.4362
G1 X150.024 Y210.751 E.01641
G1 X159.52 Y201.254 E.41299
G1 X159.52 Y201.788 E.01641
G1 X150.558 Y210.751 E.38978
G1 X151.091 Y210.751 E.01641
G1 X159.52 Y202.322 E.36657
G1 X159.52 Y202.855 E.01641
G1 X151.625 Y210.751 E.34336
G1 X152.159 Y210.751 E.01641
G1 X159.52 Y203.389 E.32015
G1 X159.52 Y203.923 E.01641
G1 X152.693 Y210.751 E.29694
G1 X153.226 Y210.751 E.01641
G1 X159.52 Y204.456 E.27373
G1 X159.52 Y204.99 E.01641
G1 X153.76 Y210.751 E.25052
G1 X154.294 Y210.751 E.01641
G1 X159.52 Y205.524 E.22731
G1 X159.52 Y206.058 E.01641
G1 X154.827 Y210.751 E.2041
G1 X155.361 Y210.751 E.01641
G1 X159.52 Y206.591 E.18089
G1 X159.52 Y207.125 E.01641
G1 X155.895 Y210.751 E.15768
G1 X156.428 Y210.751 E.01641
G1 X159.52 Y207.659 E.13447
G1 X159.52 Y208.192 E.01641
G1 X156.962 Y210.751 E.11126
G1 X157.496 Y210.751 E.01641
G1 X159.52 Y208.726 E.08805
G1 X159.52 Y209.26 E.01641
G1 X158.03 Y210.751 E.06484
G1 X158.563 Y210.751 E.01641
G1 X159.52 Y209.793 E.04163
G1 X159.52 Y210.327 E.01641
G1 X158.927 Y210.92 E.0258
; WIPE_START
G1 X159.52 Y210.327 E-.31881
G1 X159.52 Y209.793 E-.2028
G1 X159.077 Y210.237 E-.23839
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X151.449 Y210.507 Z.8 F42000
G1 X136.264 Y211.044 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.43135
G1 F15000
M204 S6000
G3 X135.936 Y211.106 I-1.395 J-6.522 E.01056
; LINE_WIDTH: 0.388744
G1 X135.808 Y211.123 E.00364
; LINE_WIDTH: 0.351518
G1 X135.666 Y211.143 E.00361
; LINE_WIDTH: 0.309141
G1 X135.398 Y211.166 E.00583
; LINE_WIDTH: 0.279208
G1 X134.875 Y211.172 E.01006
G1 X134.595 Y211.155 E.00541
; LINE_WIDTH: 0.322748
G1 X134.467 Y211.14 E.00293
; LINE_WIDTH: 0.353401
G1 X134.323 Y211.124 E.00367
; LINE_WIDTH: 0.390588
G1 X134.2 Y211.103 E.00355
; LINE_WIDTH: 0.432014
G1 X134.071 Y211.072 E.00422
; LINE_WIDTH: 0.417596
G1 X133.938 Y210.81 E.00896
; WIPE_START
G1 X134.071 Y211.072 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.883 Y210.671 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.38672
G1 F15000
M204 S6000
G1 X132.818 Y210.708 E.00208
G1 X132.868 Y210.737 E.00161
; WIPE_START
G1 X132.818 Y210.708 E-.33089
G1 X132.883 Y210.671 E-.42911
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.523 Y209.693 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.436823
G1 F15000
M204 S6000
G1 X132.49 Y209.504 E.00616
; LINE_WIDTH: 0.405908
G1 X132.456 Y209.315 E.00568
; LINE_WIDTH: 0.371475
G1 X132.438 Y209.17 E.00391
; LINE_WIDTH: 0.337269
G1 X132.422 Y209.043 E.00308
; LINE_WIDTH: 0.300371
G1 X132.401 Y208.773 E.00568
; LINE_WIDTH: 0.277029
G1 X132.412 Y208.067 E.01347
; LINE_WIDTH: 0.325384
G1 X132.435 Y207.835 E.00536
; LINE_WIDTH: 0.369621
G1 X132.457 Y207.693 E.00382
; LINE_WIDTH: 0.410153
G1 X132.476 Y207.566 E.00385
; LINE_WIDTH: 0.443775
G3 X132.528 Y207.303 I5.284 J.921 E.00877
M204 S10000
G1 X132.69 Y206.655 F42000
; LINE_WIDTH: 0.106181
G1 F15000
M204 S6000
G1 X132.812 Y206.536 E.00088
; WIPE_START
G1 X132.69 Y206.655 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.61 Y199.311 Z.8 F42000
G1 X109.034 Y123.12 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X146.693 Y85.461 E1.6378
G3 X146.049 Y85.571 I-.846 J-2.992 E.02015
G1 X108.67 Y122.951 E1.6256
G1 X108.136 Y122.951 E.01641
G1 X145.525 Y85.561 E1.62604
G3 X145.073 Y85.48 I.18 J-2.303 E.01416
G1 X107.602 Y122.951 E1.62958
G1 X107.069 Y122.951 E.01641
G1 X144.672 Y85.347 E1.63536
G3 X144.315 Y85.171 I.703 J-1.874 E.01227
G1 X106.535 Y122.951 E1.64303
G1 X106.001 Y122.951 E.01641
G1 X143.992 Y84.96 E1.65221
G3 X143.702 Y84.716 I1.072 J-1.571 E.01167
G1 X105.468 Y122.951 E1.6628
G1 X104.934 Y122.951 E.01641
G1 X143.447 Y84.438 E1.6749
G3 X143.225 Y84.126 I1.451 J-1.264 E.01179
G1 X113.113 Y114.238 E1.30957
G2 X113.347 Y113.47 I-2.994 J-1.333 E.02475
G1 X143.037 Y83.78 E1.29122
G3 X142.887 Y83.396 I1.837 J-.943 E.01268
G1 X113.382 Y112.902 E1.28316
G2 X113.34 Y112.41 I-1.937 J-.081 E.01521
G1 X142.79 Y82.96 E1.28076
G3 X142.749 Y82.467 I4.055 J-.582 E.01522
G1 X113.231 Y111.985 E1.2837
G2 X113.076 Y111.606 I-1.97 J.587 E.0126
G1 X142.809 Y81.874 E1.29305
G3 X142.839 Y81.749 I.635 J.091 E.00395
G1 X142.399 Y81.749 E.01353
G1 X112.884 Y111.265 E1.2836
G2 X112.657 Y110.957 I-4.442 J3.04 E.01174
G1 X141.866 Y81.749 E1.27024
G1 X141.332 Y81.749 E.01641
G1 X112.395 Y110.686 E1.25845
G2 X112.101 Y110.447 I-1.345 J1.351 E.01168
G1 X140.798 Y81.749 E1.24803
G1 X140.264 Y81.749 E.01641
G1 X111.774 Y110.24 E1.23904
G2 X111.411 Y110.069 I-2.247 J4.294 E.01233
G1 X139.731 Y81.749 E1.2316
G1 X139.197 Y81.749 E.01641
G1 X111.001 Y109.945 E1.22622
G2 X110.543 Y109.87 I-.606 J2.255 E.01431
G1 X138.663 Y81.749 E1.22294
G1 X138.13 Y81.749 E.01641
G1 X110.004 Y109.875 E1.22317
G2 X109.334 Y110.011 I.322 J3.306 E.02104
G1 X137.596 Y81.749 E1.22908
G1 X137.062 Y81.749 E.01641
G1 X100.848 Y117.963 E1.57493
G3 X101.145 Y118.2 I-1.031 J1.599 E.0117
G1 X107.341 Y112.004 E.26946
G2 X107.202 Y112.677 I2.077 J.779 E.0212
G1 X101.411 Y118.468 E.25189
G3 X101.643 Y118.77 I-4.03 J3.346 E.0117
G1 X107.201 Y113.212 E.24172
G2 X107.275 Y113.672 I3.524 J-.329 E.01434
G1 X101.838 Y119.108 E.23644
G3 X101.996 Y119.484 I-1.794 J.979 E.01255
G1 X107.401 Y114.079 E.23503
G2 X107.568 Y114.446 I4.776 J-1.953 E.01239
G1 X102.112 Y119.901 E.23725
G3 X102.165 Y120.382 I-2.379 J.507 E.01489
G1 X107.776 Y114.772 E.244
G2 X108.017 Y115.064 I1.582 J-1.055 E.01168
G1 X102.135 Y120.946 E.25578
G3 X101.938 Y121.677 I-3.219 J-.477 E.02334
G1 X108.289 Y115.326 E.27621
G2 X108.593 Y115.555 I1.299 J-1.405 E.01174
G1 X101.322 Y122.826 E.3162
G1 X101.422 Y122.932 E.00448
G1 X101.401 Y122.951 E.00087
G1 X101.732 Y122.951 E.01016
G1 X108.935 Y115.747 E.31328
G2 X109.315 Y115.9 I.956 J-1.824 E.01263
G1 X102.265 Y122.951 E.30661
G1 X102.799 Y122.951 E.01641
G1 X109.738 Y116.011 E.30178
G2 X110.226 Y116.057 I.624 J-4.042 E.01508
G1 X103.333 Y122.951 E.2998
G1 X103.866 Y122.951 E.01641
G1 X110.802 Y116.015 E.30162
G2 X111.563 Y115.788 I-.561 J-3.268 E.02447
G1 X104.23 Y123.12 E.31887
M204 S10000
G1 X100.902 Y122.866 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.120189
G1 F15000
M204 S6000
G1 X100.66 Y123.08 E.00203
M204 S10000
G1 X99.87 Y123.225 F42000
; LINE_WIDTH: 0.50608
G1 F13602.224
M204 S6000
G3 X99.406 Y123.265 I-1.047 J-9.427 E.01758
; LINE_WIDTH: 0.479713
G1 F14423.329
G3 X98.573 Y123.253 I-.326 J-6.231 E.02967
; LINE_WIDTH: 0.517755
G1 F13267.765
G1 X98.271 Y123.219 E.01174
M204 S10000
G1 X97.528 Y123.063 F42000
; LINE_WIDTH: 0.134098
G1 F15000
M204 S6000
G1 X96.69 Y122.816 E.00649
M204 S10000
G1 X96.69 Y122.783 F42000
; LINE_WIDTH: 0.331426
G1 F15000
M204 S6000
G1 X97.524 Y123.075 E.02079
M204 S10000
G1 X97.006 Y123.08 F42000
; LINE_WIDTH: 0.402688
G1 F15000
M204 S6000
G1 X96.691 Y122.334 E.02376
M204 S10000
G1 X96.705 Y122.329 F42000
; LINE_WIDTH: 0.160535
G1 F15000
M204 S6000
G1 X96.978 Y123.08 E.00766
; WIPE_START
G1 X96.705 Y122.329 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.523 Y121.693 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; LINE_WIDTH: 0.436848
G1 F15000
M204 S6000
G1 X96.49 Y121.504 E.00616
; LINE_WIDTH: 0.405943
G1 X96.456 Y121.315 E.00568
; LINE_WIDTH: 0.371497
G1 X96.438 Y121.17 E.00392
; LINE_WIDTH: 0.337242
G1 X96.422 Y121.042 E.00309
; LINE_WIDTH: 0.300368
G1 X96.401 Y120.773 E.00567
; LINE_WIDTH: 0.272629
G1 X96.401 Y120.239 E.01
; LINE_WIDTH: 0.29845
G1 X96.42 Y119.971 E.00558
; LINE_WIDTH: 0.33555
G1 X96.438 Y119.83 E.0034
; LINE_WIDTH: 0.369285
G1 X96.454 Y119.702 E.00343
; LINE_WIDTH: 0.404449
G1 X96.49 Y119.496 E.00616
; LINE_WIDTH: 0.436846
G1 X96.523 Y119.307 E.00616
M204 S10000
G1 X96.708 Y118.672 F42000
; LINE_WIDTH: 0.104416
G1 F15000
M204 S6000
G3 X96.769 Y118.574 I.132 J.015 E.0006
G1 X96.801 Y118.545 E.00022
; OBJECT_ID: 124
; WIPE_START
G1 X96.769 Y118.574 E-.20473
G1 X96.726 Y118.619 E-.29392
G1 X96.708 Y118.672 E-.26135
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G1 X98.468 Y126.099 Z.8 F42000
G1 X106.723 Y160.934 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X106.754 Y161.239 E.00943
G3 X105.061 Y159.705 I-1.559 J.019 E.22222
G1 X105.212 Y159.699 E.00464
G3 X106.707 Y160.877 I-.017 J1.559 E.06292
; WIPE_START
M204 S6000
G1 X106.754 Y161.239 E-.13888
G1 X106.73 Y161.549 E-.118
G1 X106.642 Y161.847 E-.11813
G1 X106.497 Y162.122 E-.11791
G1 X106.3 Y162.362 E-.11804
G1 X106.06 Y162.559 E-.11798
G1 X105.988 Y162.597 E-.03107
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.143 Y163.546 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X104.715 Y163.497 E.01323
G3 X105.225 Y158.969 I.48 J-2.239 E.20707
G1 X105.337 Y158.973 E.00342
G3 X105.203 Y163.548 I-.141 J2.285 E.21645
M204 S10000
G1 X105.173 Y163.183 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38116
G1 F15000
M204 S6000
G3 X103.272 Y161.292 I.024 J-1.924 E.08176
G1 X103.272 Y161.275 E.00046
G3 X103.279 Y161.099 I3.522 J.044 E.00484
G3 X105.233 Y163.183 I1.918 J.159 E.24457
; OBJECT_ID: 102
; WIPE_START
G1 X104.792 Y163.141 E-.16827
G1 X104.503 Y163.054 E-.11449
G1 X104.173 Y162.889 E-.14042
G1 X103.87 Y162.654 E-.14562
G1 X103.62 Y162.363 E-.1459
G1 X103.561 Y162.259 E-.04529
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.055 Y154.642 Z.8 F42000
G1 X104.067 Y154.458 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X104.099 Y154.763 E.00943
G3 X102.405 Y153.228 I-1.559 J.019 E.22222
G1 X102.556 Y153.222 E.00464
G3 X104.051 Y154.4 I-.017 J1.559 E.06292
; WIPE_START
M204 S6000
G1 X104.099 Y154.763 E-.13888
G1 X104.074 Y155.072 E-.118
G1 X103.986 Y155.37 E-.11813
G1 X103.841 Y155.645 E-.11791
G1 X103.645 Y155.885 E-.11804
G1 X103.404 Y156.082 E-.11798
G1 X103.332 Y156.12 E-.03107
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.487 Y157.069 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X102.06 Y157.02 E.01323
G3 X102.57 Y152.492 I.48 J-2.239 E.20707
G1 X102.681 Y152.497 E.00342
G3 X102.547 Y157.071 I-.141 J2.285 E.21645
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38116
G1 F15000
M204 S6000
G3 X100.617 Y154.815 I.024 J-1.924 E.08176
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.522 J.044 E.00484
G3 X102.577 Y156.706 I1.918 J.159 E.24457
; OBJECT_ID: 91
; WIPE_START
G1 X102.136 Y156.664 E-.16827
G1 X101.848 Y156.578 E-.11449
G1 X101.517 Y156.412 E-.14042
G1 X101.215 Y156.177 E-.14562
G1 X100.964 Y155.886 E-.1459
G1 X100.906 Y155.782 E-.04529
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.166 Z.8 F42000
G1 X101.411 Y147.981 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X101.443 Y148.286 E.00943
G3 X99.75 Y146.751 I-1.559 J.019 E.22222
G1 X99.9 Y146.745 E.00464
G3 X101.396 Y147.924 I-.017 J1.559 E.06292
; WIPE_START
M204 S6000
G1 X101.443 Y148.286 E-.13888
G1 X101.419 Y148.596 E-.118
G1 X101.331 Y148.894 E-.11813
G1 X101.186 Y149.168 E-.11791
G1 X100.989 Y149.409 E-.11804
G1 X100.749 Y149.605 E-.11798
G1 X100.677 Y149.643 E-.03107
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.832 Y150.592 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X99.404 Y150.544 E.01323
G3 X99.914 Y146.016 I.48 J-2.239 E.20707
G1 X100.025 Y146.02 E.00342
G3 X99.891 Y150.595 I-.141 J2.285 E.21645
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38116
G1 F15000
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08176
G1 X97.961 Y148.322 E.00046
G3 X97.967 Y148.146 I3.522 J.044 E.00484
G3 X99.921 Y150.229 I1.918 J.159 E.24457
; OBJECT_ID: 113
; WIPE_START
G1 X99.481 Y150.187 E-.16827
G1 X99.192 Y150.101 E-.11449
G1 X98.862 Y149.936 E-.14042
G1 X98.559 Y149.7 E-.14562
G1 X98.309 Y149.409 E-.1459
G1 X98.25 Y149.305 E-.04529
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.744 Y141.689 Z.8 F42000
G1 X98.756 Y141.504 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X98.787 Y141.809 E.00943
G3 X97.094 Y140.274 I-1.559 J.019 E.22222
G1 X97.245 Y140.269 E.00464
G3 X98.74 Y141.447 I-.017 J1.559 E.06292
; WIPE_START
M204 S6000
G1 X98.787 Y141.809 E-.13888
G1 X98.763 Y142.119 E-.118
G1 X98.675 Y142.417 E-.11813
G1 X98.53 Y142.691 E-.11791
G1 X98.333 Y142.932 E-.11804
G1 X98.093 Y143.128 E-.11798
G1 X98.021 Y143.167 E-.03107
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.176 Y144.116 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X96.748 Y144.067 E.01323
G3 X97.259 Y139.539 I.48 J-2.239 E.20707
G1 X97.37 Y139.543 E.00342
G3 X97.236 Y144.118 I-.141 J2.285 E.21645
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38116
G1 F15000
M204 S6000
G3 X95.305 Y141.862 I.024 J-1.924 E.08176
G1 X95.305 Y141.845 E.00046
G3 X95.312 Y141.669 I3.522 J.044 E.00484
G3 X97.266 Y143.753 I1.918 J.159 E.24457
; CHANGE_LAYER
; Z_HEIGHT: 0.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.825 Y143.711 E-.16827
G1 X96.536 Y143.624 E-.11449
G1 X96.206 Y143.459 E-.14042
G1 X95.903 Y143.224 E-.14562
G1 X95.653 Y142.933 E-.1459
G1 X95.595 Y142.829 E-.04529
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 3/60
; update layer progress
M73 L3
M991 S0 P2 ;notify layer change
; OBJECT_ID: 80
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
M204 S10000
G17
G3 Z.8 I.938 J.775 P1  F42000
G1 X144.656 Y83.484 Z.8
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.656 Y83.482 E.00007
G3 X145.656 Y80.932 I1.194 J-1.003 E.10275
G1 X145.811 Y80.92 E.00479
G3 X144.878 Y83.698 I.039 J1.559 E.18396
G1 X144.699 Y83.526 E.00764
; WIPE_START
M204 S6000
G1 X144.656 Y83.482 E-.02344
G1 X144.48 Y83.226 E-.11791
G1 X144.359 Y82.94 E-.11811
G1 X144.297 Y82.635 E-.11811
G1 X144.297 Y82.325 E-.11803
G1 X144.359 Y82.02 E-.11812
G1 X144.48 Y81.734 E-.11807
G1 X144.521 Y81.672 E-.02821
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.206 Y89.117 Z1 F42000
G1 X155.52 Y130.27 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
M73 P40 R19
G1 X155.264 Y130.016 E.01198
G3 X156.776 Y126.158 I1.806 J-1.517 E.16781
G1 X157.011 Y126.14 E.00782
G3 X155.6 Y130.343 I.059 J2.358 E.30044
G1 X155.564 Y130.31 E.0016
M204 S10000
G1 X155.804 Y129.979 F42000
G1 F15476.087
M204 S6000
G1 X155.576 Y129.754 E.01063
G3 X156.827 Y126.562 I1.494 J-1.255 E.13884
G1 X157.021 Y126.548 E.00647
G3 X155.854 Y130.025 I.049 J1.951 E.24856
G1 X155.848 Y130.02 E.00025
M204 S250
G1 X156.076 Y129.7 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X155.876 Y129.502 E.00865
G3 X156.876 Y126.952 I1.194 J-1.003 E.10275
G1 X157.031 Y126.94 E.00479
G3 X156.123 Y129.738 I.039 J1.559 E.18299
; WIPE_START
M204 S6000
G1 X155.876 Y129.502 E-.12968
G1 X155.7 Y129.246 E-.11807
G1 X155.579 Y128.96 E-.11805
G1 X155.517 Y128.655 E-.11811
G1 X155.517 Y128.345 E-.11801
G1 X155.579 Y128.04 E-.11811
G1 X155.62 Y127.943 E-.03998
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.028 Y127.16 Z1 F42000
G1 X96.664 Y121.865 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X96.783 Y122.059 E.00756
G2 X98.09 Y123.091 I2.326 J-1.604 E.05607
G1 X98.049 Y123.284 E.00654
G1 X96.486 Y123.284 E.05184
G1 X96.486 Y121.915 E.0454
G1 X96.606 Y121.881 E.00415
; WIPE_START
G1 X96.783 Y122.059 E-.09533
G1 X96.95 Y122.279 E-.10488
G1 X97.137 Y122.481 E-.10475
G1 X97.344 Y122.664 E-.10491
G1 X97.568 Y122.825 E-.10487
G1 X97.807 Y122.963 E-.10475
G1 X98.09 Y123.091 E-.11813
G1 X98.078 Y123.149 E-.02237
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.721 Y120.348 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X96.723 Y120.265 E.00275
G3 X98.776 Y118.158 I2.347 J.233 E.10538
G1 X99.011 Y118.14 E.00782
G3 X96.723 Y120.735 I.059 J2.358 E.36285
G1 X96.721 Y120.408 E.01083
M204 S10000
G1 X97.127 Y120.348 F42000
G1 F15476.087
M204 S6000
G1 X97.128 Y120.306 E.00141
G3 X98.827 Y118.562 I1.942 J.193 E.08719
G1 X99.021 Y118.548 E.00647
G3 X97.128 Y120.694 I.049 J1.951 E.30019
G1 X97.127 Y120.408 E.00949
M204 S250
G1 X97.517 Y120.348 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X97.518 Y120.345 E.00011
G3 X98.876 Y118.952 I1.552 J.154 E.06453
G1 X99.031 Y118.94 E.00479
G3 X97.518 Y120.655 I.039 J1.559 E.22217
G1 X97.518 Y120.408 E.00759
; WIPE_START
M204 S6000
G1 X97.518 Y120.345 E-.02407
G1 X97.579 Y120.04 E-.11807
G1 X97.7 Y119.754 E-.11808
G1 X97.874 Y119.497 E-.11791
G1 X98.039 Y119.329 E-.08928
G1 X98.29 Y119.149 E-.1176
G1 X98.573 Y119.021 E-.11799
G1 X98.719 Y118.988 E-.05699
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.182 Y111.369 Z1 F42000
G1 X101.41 Y74.733 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X101.402 Y74.851 E.00395
G3 X98.776 Y72.158 I-2.332 J-.353 E.34722
G1 X99.011 Y72.14 E.00782
G3 X101.426 Y74.382 I.059 J2.358 E.12102
G1 X101.413 Y74.673 E.00964
M204 S10000
G1 X101.005 Y74.712 F42000
G1 F15476.087
M204 S6000
G1 X101 Y74.791 E.00261
G3 X98.827 Y72.562 I-1.93 J-.292 E.28726
G1 X99.021 Y72.548 E.00647
G3 X101.019 Y74.403 I.049 J1.951 E.10012
G1 X101.008 Y74.652 E.00829
M204 S250
G1 X100.615 Y74.693 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X100.612 Y74.732 E.00122
G3 X98.876 Y72.952 I-1.542 J-.233 E.2126
G1 X99.031 Y72.94 E.00479
G3 X100.627 Y74.422 I.039 J1.559 E.0741
G1 X100.617 Y74.633 E.00648
; WIPE_START
M204 S6000
G1 X100.612 Y74.732 E-.03783
G1 X100.536 Y75.034 E-.11803
G1 X100.476 Y75.177 E-.05906
G1 X100.314 Y75.442 E-.11816
G1 X100.102 Y75.67 E-.11806
G1 X99.85 Y75.851 E-.11804
G1 X99.567 Y75.979 E-.11807
G1 X99.38 Y76.022 E-.07276
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.31 Y80.827 Z1 F42000
G1 X143.396 Y111.686 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.489 Y111.517 E.0064
G3 X145.505 Y110.214 I2.361 J1.441 E.08239
G1 X145.781 Y110.193 E.00917
G3 X143.357 Y111.759 I.069 J2.765 E.47584
G1 X143.368 Y111.739 E.00075
M204 S10000
G1 X143.776 Y111.85 F42000
G1 F15476.087
M204 S6000
G1 X143.969 Y111.535 E.01224
G3 X145.556 Y110.618 I1.881 J1.423 E.06245
G1 X145.791 Y110.6 E.00782
G3 X143.724 Y111.936 I.059 J2.358 E.40577
G1 X143.745 Y111.901 E.00135
M204 S10000
G1 X144.122 Y112.061 F42000
G1 F15476.087
M204 S6000
G1 X144.294 Y111.781 E.01089
G3 X145.607 Y111.022 I1.556 J1.177 E.05167
G1 X145.801 Y111.008 E.00647
G3 X144.091 Y112.113 I.049 J1.951 E.33571
M204 S250
G1 X144.455 Y112.265 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.606 Y112.018 E.00889
G3 X145.656 Y111.412 I1.243 J.941 E.03824
G1 X145.811 Y111.4 E.00479
G3 X144.428 Y112.318 I.039 J1.559 E.24726
; WIPE_START
M204 S6000
G1 X144.606 Y112.018 E-.13262
G1 X144.817 Y111.79 E-.11812
G1 X145.07 Y111.609 E-.11813
G1 X145.353 Y111.481 E-.11801
G1 X145.656 Y111.412 E-.11796
G1 X145.811 Y111.4 E-.05919
G1 X146.063 Y111.419 E-.09597
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.445 Y111.885 Z1 F42000
G1 X113.013 Y113.44 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X112.97 Y113.642 E.00688
G3 X109.945 Y110.214 I-2.68 J-.684 E.39801
G1 X110.221 Y110.193 E.00917
G3 X113.025 Y113.372 I.069 J2.765 E.16021
G1 X113.024 Y113.38 E.00028
M204 S10000
G1 X112.603 Y113.396 F42000
G1 F15476.087
M204 S6000
G1 X112.506 Y113.767 E.01272
G3 X109.996 Y110.618 I-2.216 J-.808 E.3316
G1 X110.231 Y110.6 E.00782
G3 X112.622 Y113.311 I.059 J2.358 E.13662
G1 X112.616 Y113.337 E.00088
M204 S10000
G1 X112.21 Y113.295 F42000
G1 F15476.087
M204 S6000
G1 X112.123 Y113.627 E.01137
G3 X110.047 Y111.022 I-1.834 J-.669 E.27435
G1 X110.241 Y111.008 E.00647
G3 X112.222 Y113.237 I.049 J1.951 E.11256
M204 S250
G1 X111.831 Y113.199 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.755 Y113.493 E.00933
G3 X110.096 Y111.412 I-1.465 J-.534 E.20305
G1 X110.251 Y111.4 E.00479
G3 X111.839 Y113.14 I.039 J1.559 E.08202
; WIPE_START
M204 S6000
G1 X111.755 Y113.493 E-.13804
G1 X111.621 Y113.774 E-.11802
G1 X111.434 Y114.021 E-.11808
G1 X111.201 Y114.227 E-.11807
G1 X110.932 Y114.382 E-.11808
G1 X110.637 Y114.481 E-.11807
G1 X110.554 Y114.492 E-.03164
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X110.927 Y106.868 Z1 F42000
G1 X112.015 Y84.64 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X111.904 Y84.725 E.00465
G3 X109.945 Y79.734 I-1.614 J-2.247 E.33397
G1 X110.221 Y79.713 E.00917
G3 X112.119 Y84.553 I.069 J2.765 E.22427
G1 X112.061 Y84.602 E.0025
M204 S10000
G1 X111.727 Y84.34 F42000
G1 F15476.087
M204 S6000
G1 X111.468 Y84.522 E.0105
G3 X109.996 Y80.138 I-1.178 J-2.043 E.27698
G1 X110.231 Y80.12 E.00782
G3 X111.85 Y84.248 I.059 J2.358 E.19124
G1 X111.775 Y84.304 E.00309
M204 S10000
G1 X111.49 Y84.01 F42000
G1 F15476.087
M204 S6000
G1 X111.265 Y84.169 E.00915
G3 X110.047 Y80.542 I-.975 J-1.691 E.22916
G1 X110.241 Y80.528 E.00647
G3 X111.581 Y83.943 I.049 J1.951 E.15822
G1 X111.538 Y83.974 E.00175
M204 S250
G1 X111.262 Y83.693 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.069 Y83.83 E.00727
G3 X110.096 Y80.932 I-.779 J-1.351 E.16961
G1 X110.251 Y80.92 E.00479
G3 X111.321 Y83.649 I.039 J1.559 E.1171
G1 X111.31 Y83.657 E.00042
; WIPE_START
M204 S6000
G1 X111.069 Y83.83 E-.11273
G1 X110.787 Y83.959 E-.11796
G1 X110.484 Y84.028 E-.11805
G1 X110.173 Y84.036 E-.11807
G1 X109.867 Y83.982 E-.11809
G1 X109.578 Y83.868 E-.11803
G1 X109.452 Y83.787 E-.05708
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X116.949 Y82.354 Z1 F42000
G1 X121.854 Y81.416 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.295 Y81.416 E.71125
G2 X148.415 Y81.416 I2.56 J1.058 E.36072
G1 X159.854 Y81.416 E.37945
G1 X159.854 Y127.471 E1.52774
G1 X159.664 Y127.515 E.00646
G2 X159.432 Y129.943 I-2.589 J.978 E.49307
G2 X159.658 Y129.478 I-2.213 J-1.363 E.0172
G1 X159.854 Y129.517 E.00663
G1 X159.854 Y211.084 E2.70571
G1 X136.488 Y211.084 E.77509
G1 X136.436 Y210.909 E.00606
G2 X132.658 Y207.13 I-1.372 J-2.407 E.33776
G1 X132.486 Y207.076 E.00598
G1 X132.486 Y123.284 E2.77956
G1 X100.088 Y123.284 E1.0747
G1 X100.05 Y123.085 E.00671
G2 X96.664 Y119.135 I-.985 J-2.582 E.35106
G1 X96.486 Y119.085 E.00614
G1 X96.486 Y75.915 E1.43202
G1 X96.664 Y75.865 E.00614
G2 X96.664 Y73.135 I2.406 J-1.365 E.48191
G1 X96.486 Y73.085 E.00614
G1 X96.486 Y44.916 E.93441
G1 X141.154 Y44.916 E1.48171
G1 X141.154 Y47.584 E.08849
G1 X137.154 Y47.584 E.13269
G1 X137.154 Y65.916 E.60812
G1 X141.154 Y65.916 E.13269
G1 X141.154 Y69.084 E.10507
G1 X121.854 Y69.084 E.64022
G1 X121.854 Y81.356 E.4071
; WIPE_START
G1 X123.854 Y81.362 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.46 Y88.97 Z1 F42000
G1 X133.827 Y206.501 Z1
G1 Z.6
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X133.89 Y206.456 E.00255
G3 X134.776 Y206.158 I1.18 J2.042 E.03122
G1 X135.011 Y206.14 E.00782
G3 X133.508 Y206.731 I.059 J2.358 E.437
G1 X133.778 Y206.536 E.01105
M204 S10000
G1 X134.064 Y206.83 F42000
G1 F15476.087
M204 S6000
G1 X134.094 Y206.809 E.00121
G3 X134.827 Y206.562 I.976 J1.69 E.02583
G1 X135.021 Y206.548 E.00647
G3 X133.778 Y207.036 I.049 J1.951 E.36154
G1 X134.015 Y206.865 E.0097
M204 S250
G1 X134.29 Y207.149 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G3 X134.876 Y206.952 I.78 J1.35 E.01912
G1 X135.031 Y206.94 E.00479
G3 X134.239 Y207.18 I.039 J1.559 E.2753
; WIPE_START
M204 S6000
G1 X134.573 Y207.021 E-.14073
G1 X134.876 Y206.952 E-.11792
G1 X135.031 Y206.94 E-.0592
G1 X135.341 Y206.963 E-.11804
G1 X135.64 Y207.048 E-.11805
G1 X135.916 Y207.189 E-.11805
G1 X136.043 Y207.28 E-.05916
G1 X136.097 Y207.333 E-.02886
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.664 Y209.865 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X132.783 Y210.059 E.00755
G2 X133.703 Y210.903 I2.324 J-1.611 E.04174
G1 X133.654 Y211.084 E.00622
G1 X132.486 Y211.084 E.03875
G1 X132.486 Y209.915 E.03877
G1 X132.606 Y209.881 E.00415
; WIPE_START
G1 X132.783 Y210.059 E-.09527
G1 X132.949 Y210.279 E-.10481
G1 X133.137 Y210.482 E-.10492
G1 X133.344 Y210.664 E-.10476
G1 X133.703 Y210.903 E-.16374
G1 X133.654 Y211.084 E-.07121
G1 X133.351 Y211.084 E-.1153
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.702 Y203.479 Z1 F42000
G1 X122.261 Y81.009 Z1
G1 Z.6
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X143.986 Y81.009 E.72067
G2 X144.042 Y83.997 I1.948 J1.458 E.10675
G2 X147.7 Y81.009 I1.807 J-1.522 E.24378
G1 X160.261 Y81.009 E.41665
G1 X160.261 Y211.491 E4.32832
G1 X132.079 Y211.491 E.93484
G1 X132.079 Y123.691 E2.91249
G1 X96.079 Y123.691 E1.19419
G1 X96.079 Y44.509 E2.6266
G1 X141.561 Y44.509 E1.50871
G1 X141.561 Y47.991 E.1155
G1 X137.561 Y47.991 E.13269
G1 X137.561 Y65.509 E.58111
G1 X141.561 Y65.509 E.13269
G1 X141.561 Y69.491 E.13208
G1 X122.261 Y69.491 E.64022
G1 X122.261 Y80.949 E.38009
M204 S10000
G1 X122.668 Y80.602 F42000
G1 F15476.087
M204 S6000
G1 X144.84 Y80.602 E.73549
G1 X144.891 Y80.777 E.00606
G2 X146.811 Y80.783 I.955 J1.698 E.33942
G1 X146.86 Y80.602 E.00622
G1 X160.668 Y80.602 E.45803
G1 X160.668 Y211.898 E4.35533
G1 X131.672 Y211.898 E.96185
G1 X131.672 Y124.098 E2.91249
G1 X95.672 Y124.098 E1.19419
G1 X95.672 Y44.102 E2.65361
G1 X141.968 Y44.102 E1.53572
G1 X141.968 Y48.398 E.1425
G1 X137.968 Y48.398 E.13269
G1 X137.968 Y65.102 E.55411
G1 X141.968 Y65.102 E.13269
G1 X141.968 Y69.898 E.15909
G1 X122.668 Y69.898 E.64022
G1 X122.668 Y80.542 E.35309
M204 S250
G1 X123.06 Y80.21 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X161.06 Y80.21 E1.16763
G1 X161.06 Y212.29 E4.05845
G1 X131.28 Y212.29 E.91506
G1 X131.28 Y124.49 E2.69785
G1 X95.28 Y124.49 E1.10618
G1 X95.28 Y43.71 E2.48214
G1 X142.36 Y43.71 E1.44664
G1 X142.36 Y48.79 E.15609
G1 X138.36 Y48.79 E.12291
G1 X138.36 Y64.71 E.48918
G1 X142.36 Y64.71 E.12291
G1 X142.36 Y70.29 E.17146
G1 X123.06 Y70.29 E.59304
G1 X123.06 Y80.15 E.30297
; WIPE_START
M204 S6000
G1 X125.06 Y80.153 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1 I1.217 J0 P1  F42000
; stop printing object, unique label id: 80
M625
; object ids of layer 3 start: 80,91,102,113,124
M624 HwAAAAAAAAA=
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
; object ids of this layer3 end: 80,91,102,113,124
M625
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X140.382 Y81.58 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X159.52 Y100.718 E.83354
G1 X159.52 Y101.253 E.01646
G1 X140.017 Y81.749 E.84943
G1 X139.483 Y81.749 E.01646
G1 X159.52 Y101.787 E.87271
G1 X159.52 Y102.322 E.01646
G1 X138.948 Y81.749 E.89598
G1 X138.414 Y81.749 E.01646
G1 X159.52 Y102.856 E.91926
G1 X159.52 Y103.391 E.01646
G1 X137.879 Y81.749 E.94254
G1 X137.345 Y81.749 E.01646
G1 X159.52 Y103.925 E.96582
G1 X159.52 Y104.46 E.01646
G1 X136.81 Y81.749 E.9891
G1 X136.276 Y81.749 E.01646
G1 X159.52 Y104.994 E1.01237
G1 X159.52 Y105.529 E.01646
M73 P41 R19
G1 X135.741 Y81.749 E1.03565
G1 X135.207 Y81.749 E.01646
G1 X159.52 Y106.063 E1.05893
G1 X159.52 Y106.598 E.01646
G1 X134.672 Y81.749 E1.08221
G1 X134.138 Y81.749 E.01646
G1 X159.52 Y107.132 E1.10549
G1 X159.52 Y107.666 E.01646
G1 X133.603 Y81.749 E1.12876
G1 X133.069 Y81.749 E.01646
G1 X159.52 Y108.201 E1.15204
G1 X159.52 Y108.735 E.01646
G1 X132.534 Y81.749 E1.17532
G1 X132 Y81.749 E.01646
G1 X159.52 Y109.27 E1.1986
G1 X159.52 Y109.804 E.01646
G1 X131.465 Y81.749 E1.22187
G1 X130.931 Y81.749 E.01646
G1 X159.52 Y110.339 E1.24515
G1 X159.52 Y110.873 E.01646
G1 X130.397 Y81.749 E1.26843
G1 X129.862 Y81.749 E.01646
G1 X159.52 Y111.408 E1.29171
G1 X159.52 Y111.942 E.01646
G1 X129.328 Y81.749 E1.31499
G1 X128.793 Y81.749 E.01646
G1 X159.52 Y112.477 E1.33826
G1 X159.52 Y113.011 E.01646
G1 X128.259 Y81.749 E1.36154
G1 X127.724 Y81.749 E.01646
G1 X159.52 Y113.546 E1.38482
G1 X159.52 Y114.08 E.01646
G1 X127.19 Y81.749 E1.4081
G1 X126.655 Y81.749 E.01646
G1 X159.52 Y114.615 E1.43137
G1 X159.52 Y115.149 E.01646
G1 X126.121 Y81.749 E1.45465
G1 X125.586 Y81.749 E.01646
G1 X159.52 Y115.684 E1.47793
G1 X159.52 Y116.218 E.01646
G1 X125.052 Y81.749 E1.50121
G1 X124.517 Y81.749 E.01646
G1 X159.52 Y116.753 E1.52449
G1 X159.52 Y117.287 E.01646
G1 X123.983 Y81.749 E1.54776
G1 X123.448 Y81.749 E.01646
G1 X159.52 Y117.821 E1.57104
G1 X159.52 Y118.356 E.01646
G1 X122.914 Y81.749 E1.59432
G1 X122.379 Y81.749 E.01646
G1 X159.52 Y118.89 E1.6176
G1 X159.52 Y119.425 E.01646
G1 X96.819 Y56.724 E2.73082
G1 X96.819 Y56.189 E.01646
G1 X121.52 Y80.89 E1.07581
G1 X121.52 Y80.356 E.01646
G1 X96.819 Y55.655 E1.07581
G1 X96.819 Y55.12 E.01646
G1 X121.52 Y79.821 E1.07581
G1 X121.52 Y79.287 E.01646
G1 X96.819 Y54.586 E1.07581
G1 X96.819 Y54.051 E.01646
G1 X121.52 Y78.752 E1.07581
G1 X121.52 Y78.218 E.01646
G1 X96.819 Y53.517 E1.07581
G1 X96.819 Y52.982 E.01646
G1 X121.52 Y77.684 E1.07581
G1 X121.52 Y77.149 E.01646
G1 X96.819 Y52.448 E1.07581
G1 X96.819 Y51.913 E.01646
G1 X121.52 Y76.615 E1.07581
G1 X121.52 Y76.08 E.01646
G1 X96.819 Y51.379 E1.07581
G1 X96.819 Y50.844 E.01646
G1 X121.52 Y75.546 E1.07581
G1 X121.52 Y75.011 E.01646
G1 X96.819 Y50.31 E1.07581
M73 P41 R18
G1 X96.819 Y49.775 E.01646
G1 X121.52 Y74.477 E1.07581
G1 X121.52 Y73.942 E.01646
G1 X96.819 Y49.241 E1.07581
G1 X96.819 Y48.706 E.01646
G1 X121.52 Y73.408 E1.07581
G1 X121.52 Y72.873 E.01646
G1 X96.819 Y48.172 E1.07581
G1 X96.819 Y47.638 E.01646
G1 X121.52 Y72.339 E1.07581
G1 X121.52 Y71.804 E.01646
G1 X96.819 Y47.103 E1.07581
G1 X96.819 Y46.569 E.01646
G1 X121.52 Y71.27 E1.07581
G1 X121.52 Y70.735 E.01646
G1 X96.819 Y46.034 E1.07581
G1 X96.819 Y45.5 E.01646
G1 X121.52 Y70.201 E1.07581
G1 X121.52 Y69.666 E.01646
G1 X97.103 Y45.249 E1.06343
G1 X97.638 Y45.249 E.01646
G1 X121.52 Y69.132 E1.04016
G1 X121.52 Y68.751 E.01174
G1 X121.674 Y68.751 E.00472
G1 X98.172 Y45.249 E1.02355
G1 X98.707 Y45.249 E.01646
G1 X122.208 Y68.751 E1.02355
G1 X122.743 Y68.751 E.01646
G1 X99.241 Y45.249 E1.02355
G1 X99.776 Y45.249 E.01646
G1 X123.277 Y68.751 E1.02355
G1 X123.811 Y68.751 E.01646
G1 X100.31 Y45.249 E1.02355
G1 X100.845 Y45.249 E.01646
G1 X124.346 Y68.751 E1.02355
G1 X124.88 Y68.751 E.01646
G1 X101.379 Y45.249 E1.02355
G1 X101.914 Y45.249 E.01646
G1 X125.415 Y68.751 E1.02355
G1 X125.949 Y68.751 E.01646
G1 X102.448 Y45.249 E1.02355
G1 X102.983 Y45.249 E.01646
G1 X126.484 Y68.751 E1.02355
G1 X127.018 Y68.751 E.01646
G1 X103.517 Y45.249 E1.02355
G1 X104.052 Y45.249 E.01646
G1 X127.553 Y68.751 E1.02355
G1 X128.087 Y68.751 E.01646
G1 X104.586 Y45.249 E1.02355
G1 X105.12 Y45.249 E.01646
G1 X128.622 Y68.751 E1.02355
G1 X129.156 Y68.751 E.01646
G1 X105.655 Y45.249 E1.02355
G1 X106.189 Y45.249 E.01646
G1 X129.691 Y68.751 E1.02355
G1 X130.225 Y68.751 E.01646
G1 X106.724 Y45.249 E1.02355
G1 X107.258 Y45.249 E.01646
G1 X130.76 Y68.751 E1.02355
G1 X131.294 Y68.751 E.01646
G1 X107.793 Y45.249 E1.02355
G1 X108.327 Y45.249 E.01646
G1 X131.829 Y68.751 E1.02355
G1 X132.363 Y68.751 E.01646
G1 X108.862 Y45.249 E1.02355
G1 X109.396 Y45.249 E.01646
G1 X132.898 Y68.751 E1.02355
G1 X133.432 Y68.751 E.01646
G1 X109.931 Y45.249 E1.02355
G1 X110.465 Y45.249 E.01646
G1 X133.966 Y68.751 E1.02355
G1 X134.501 Y68.751 E.01646
G1 X111 Y45.249 E1.02355
G1 X111.534 Y45.249 E.01646
G1 X135.035 Y68.751 E1.02355
G1 X135.57 Y68.751 E.01646
G1 X112.069 Y45.249 E1.02355
G1 X112.603 Y45.249 E.01646
G1 X136.104 Y68.751 E1.02355
G1 X136.639 Y68.751 E.01646
G1 X113.138 Y45.249 E1.02355
G1 X113.672 Y45.249 E.01646
G1 X137.173 Y68.751 E1.02355
G1 X137.708 Y68.751 E.01646
G1 X114.207 Y45.249 E1.02355
G1 X114.741 Y45.249 E.01646
G1 X138.242 Y68.751 E1.02355
G1 X138.777 Y68.751 E.01646
G1 X115.275 Y45.249 E1.02355
G1 X115.81 Y45.249 E.01646
G1 X139.481 Y68.92 E1.03094
M204 S10000
G1 X140.99 Y66.688 F42000
G1 F15000
M204 S6000
M73 P42 R18
G1 X140.551 Y66.249 E.01911
G1 X140.017 Y66.249 E.01646
G1 X140.82 Y67.053 E.035
G1 X140.82 Y67.588 E.01646
G1 X139.482 Y66.249 E.05828
G1 X138.948 Y66.249 E.01646
G1 X140.82 Y68.122 E.08156
G1 X140.82 Y68.656 E.01646
G1 X138.413 Y66.249 E.10484
G1 X137.879 Y66.249 E.01646
G1 X140.38 Y68.751 E.10894
G1 X139.846 Y68.751 E.01646
G1 X137.344 Y66.249 E.10894
G1 X136.82 Y66.249 E.01614
G1 X136.82 Y65.725 E.01614
G1 X116.344 Y45.249 E.89179
G1 X116.879 Y45.249 E.01646
G1 X136.82 Y65.191 E.86851
G1 X136.82 Y64.656 E.01646
G1 X117.413 Y45.249 E.84523
G1 X117.948 Y45.249 E.01646
G1 X136.82 Y64.122 E.82196
G1 X136.82 Y63.587 E.01646
G1 X118.482 Y45.249 E.79868
G1 X119.017 Y45.249 E.01646
G1 X136.82 Y63.053 E.7754
G1 X136.82 Y62.519 E.01646
G1 X119.551 Y45.249 E.75212
G1 X120.086 Y45.249 E.01646
G1 X136.82 Y61.984 E.72884
G1 X136.82 Y61.45 E.01646
G1 X120.62 Y45.249 E.70557
G1 X121.155 Y45.249 E.01646
G1 X136.82 Y60.915 E.68229
G1 X136.82 Y60.381 E.01646
G1 X121.689 Y45.249 E.65901
G1 X122.224 Y45.249 E.01646
G1 X136.82 Y59.846 E.63573
G1 X136.82 Y59.312 E.01646
G1 X122.758 Y45.249 E.61246
G1 X123.293 Y45.249 E.01646
G1 X136.82 Y58.777 E.58918
G1 X136.82 Y58.243 E.01646
G1 X123.827 Y45.249 E.5659
G1 X124.362 Y45.249 E.01646
G1 X136.82 Y57.708 E.54262
G1 X136.82 Y57.174 E.01646
G1 X124.896 Y45.249 E.51934
G1 X125.43 Y45.249 E.01646
G1 X136.82 Y56.639 E.49607
G1 X136.82 Y56.105 E.01646
G1 X125.965 Y45.249 E.47279
G1 X126.499 Y45.249 E.01646
G1 X136.82 Y55.57 E.44951
G1 X136.82 Y55.036 E.01646
G1 X127.034 Y45.249 E.42623
G1 X127.568 Y45.249 E.01646
G1 X136.82 Y54.501 E.40295
G1 X136.82 Y53.967 E.01646
G1 X128.103 Y45.249 E.37968
G1 X128.637 Y45.249 E.01646
G1 X136.82 Y53.432 E.3564
G1 X136.82 Y52.898 E.01646
G1 X129.172 Y45.249 E.33312
G1 X129.706 Y45.249 E.01646
G1 X136.82 Y52.364 E.30984
G1 X136.82 Y51.829 E.01646
G1 X130.241 Y45.249 E.28657
G1 X130.775 Y45.249 E.01646
G1 X136.82 Y51.295 E.26329
G1 X136.82 Y50.76 E.01646
G1 X131.31 Y45.249 E.24001
G1 X131.844 Y45.249 E.01646
G1 X136.82 Y50.226 E.21673
G1 X136.82 Y49.691 E.01646
G1 X132.379 Y45.249 E.19345
G1 X132.913 Y45.249 E.01646
G1 X136.82 Y49.157 E.17018
G1 X136.82 Y48.622 E.01646
G1 X133.448 Y45.249 E.1469
G1 X133.982 Y45.249 E.01646
G1 X136.82 Y48.088 E.12362
G1 X136.82 Y47.553 E.01646
G1 X134.517 Y45.249 E.10034
G1 X135.051 Y45.249 E.01646
G1 X137.052 Y47.251 E.08716
G1 X137.587 Y47.251 E.01646
G1 X135.585 Y45.249 E.08716
G1 X136.12 Y45.249 E.01646
G1 X138.121 Y47.251 E.08716
G1 X138.656 Y47.251 E.01646
G1 X136.654 Y45.249 E.08716
G1 X137.189 Y45.249 E.01646
G1 X139.19 Y47.251 E.08716
G1 X139.725 Y47.251 E.01646
G1 X137.723 Y45.249 E.08716
G1 X138.258 Y45.249 E.01646
G1 X140.259 Y47.251 E.08716
G1 X140.794 Y47.251 E.01646
G1 X138.792 Y45.249 E.08716
G1 X139.327 Y45.249 E.01646
G1 X140.82 Y46.743 E.06505
G1 X140.82 Y46.209 E.01646
G1 X139.861 Y45.249 E.04178
G1 X140.396 Y45.249 E.01646
G1 X140.99 Y45.844 E.02589
; WIPE_START
G1 X140.396 Y45.249 E-.31943
G1 X139.861 Y45.249 E-.2031
G1 X140.303 Y45.691 E-.23747
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.884 Y52.431 Z1 F42000
G1 X159.69 Y82.181 Z1
G1 Z.6
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X159.258 Y81.749 E.01882
G1 X158.724 Y81.749 E.01646
G1 X159.52 Y82.546 E.0347
G1 X159.52 Y83.081 E.01646
G1 X158.189 Y81.749 E.05798
G1 X157.655 Y81.749 E.01646
G1 X159.52 Y83.615 E.08126
G1 X159.52 Y84.15 E.01646
G1 X157.12 Y81.749 E.10454
G1 X156.586 Y81.749 E.01646
G1 X159.52 Y84.684 E.12782
G1 X159.52 Y85.219 E.01646
G1 X156.051 Y81.749 E.15109
G1 X155.517 Y81.749 E.01646
G1 X159.52 Y85.753 E.17437
G1 X159.52 Y86.288 E.01646
G1 X154.982 Y81.749 E.19765
G1 X154.448 Y81.749 E.01646
G1 X159.52 Y86.822 E.22093
G1 X159.52 Y87.356 E.01646
G1 X153.913 Y81.749 E.2442
G1 X153.379 Y81.749 E.01646
G1 X159.52 Y87.891 E.26748
G1 X159.52 Y88.425 E.01646
G1 X152.844 Y81.749 E.29076
G1 X152.31 Y81.749 E.01646
G1 X159.52 Y88.96 E.31404
G1 X159.52 Y89.494 E.01646
G1 X151.775 Y81.749 E.33732
G1 X151.241 Y81.749 E.01646
G1 X159.52 Y90.029 E.36059
G1 X159.52 Y90.563 E.01646
G1 X150.707 Y81.749 E.38387
G1 X150.172 Y81.749 E.01646
G1 X159.52 Y91.098 E.40715
G1 X159.52 Y91.632 E.01646
G1 X149.638 Y81.749 E.43043
G1 X149.103 Y81.749 E.01646
G1 X159.52 Y92.167 E.45371
G1 X159.52 Y92.701 E.01646
G1 X148.926 Y82.106 E.46144
G3 X148.945 Y82.66 I-3.794 J.41 E.01708
G1 X159.52 Y93.236 E.46059
G1 X159.52 Y93.77 E.01646
G1 X148.879 Y83.129 E.46346
G3 X148.762 Y83.546 I-4.498 J-1.035 E.01336
G1 X159.52 Y94.305 E.46856
G1 X159.52 Y94.839 E.01646
G1 X148.596 Y83.914 E.4758
G3 X148.394 Y84.247 I-1.764 J-.842 E.012
G1 X159.52 Y95.374 E.48458
G1 X159.52 Y95.908 E.01646
G1 X148.159 Y84.547 E.49481
G3 X147.892 Y84.814 I-4.024 J-3.765 E.01164
G1 X159.52 Y96.443 E.50646
G1 X159.52 Y96.977 E.01646
G1 X147.588 Y85.045 E.51968
G3 X147.251 Y85.242 I-1.158 J-1.587 E.01205
G1 X159.52 Y97.511 E.53435
G1 X159.52 Y98.046 E.01646
G1 X146.879 Y85.404 E.55059
G3 X146.458 Y85.518 I-1.213 J-3.631 E.01342
G1 X159.52 Y98.58 E.5689
G1 X159.52 Y99.115 E.01646
G1 X145.982 Y85.576 E.58964
G3 X145.419 Y85.548 I-.109 J-3.415 E.01738
G1 X159.52 Y99.649 E.61416
G1 X159.52 Y100.184 E.01646
G1 X144.693 Y85.357 E.64577
G3 X142.975 Y83.638 I1.177 J-2.895 E.07686
G1 X141.086 Y81.749 E.08227
G1 X141.62 Y81.749 E.01646
G1 X142.782 Y82.911 E.05059
G3 X142.755 Y82.349 I3.097 J-.432 E.01734
G1 X142.155 Y81.749 E.02613
G1 X142.689 Y81.749 E.01646
G1 X142.958 Y82.018 E.01171
; WIPE_START
G1 X142.689 Y81.749 E-.14452
G1 X142.155 Y81.749 E-.2031
G1 X142.755 Y82.349 E-.32236
G1 X142.748 Y82.48 E-.04977
G1 X142.757 Y82.586 E-.04026
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.274 Y80.975 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.112969
G1 F15000
M204 S6000
G1 X144.374 Y80.85 E.00091
G1 X144.443 Y80.824 E.00042
M204 S10000
G1 X145.124 Y80.871 F42000
; LINE_WIDTH: 0.382947
G1 F15000
M204 S6000
G1 X145.242 Y80.643 E.00711
; LINE_WIDTH: 0.412541
G1 X145.251 Y80.627 E.00056
; LINE_WIDTH: 0.439089
G1 X145.26 Y80.611 E.0006
; LINE_WIDTH: 0.429369
G1 X145.427 Y80.588 E.00531
; LINE_WIDTH: 0.374624
G1 X145.81 Y80.565 E.01036
G1 X146.176 Y80.579 E.00991
; LINE_WIDTH: 0.409268
G1 X146.369 Y80.6 E.00579
; LINE_WIDTH: 0.444221
G3 X146.645 Y80.645 I-.747 J5.496 E.00916
; WIPE_START
G1 X146.369 Y80.6 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.599 Y88.194 Z1 F42000
G1 X143.217 Y111.673 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X113.305 Y81.761 E1.30275
G3 X113.388 Y82.378 I-3.451 J.777 E.0192
G1 X142.929 Y111.92 E1.28662
G2 X142.818 Y112.343 I1.609 J.648 E.01352
G1 X113.362 Y82.887 E1.28289
G3 X113.27 Y83.329 I-3.592 J-.522 E.01391
G1 X142.756 Y112.815 E1.28419
G2 X142.779 Y113.373 I3.145 J.145 E.01724
G1 X113.128 Y83.722 E1.29141
G3 X112.948 Y84.076 I-1.859 J-.723 E.01226
G1 X143.34 Y114.469 E1.32368
M204 S10000
G1 X132.216 Y123.12 F42000
G1 F15000
M204 S6000
G1 X96.819 Y87.723 E1.54165
G1 X96.819 Y88.258 E.01646
G1 X131.512 Y122.951 E1.51098
G1 X130.978 Y122.951 E.01646
G1 X96.819 Y88.792 E1.4877
G1 X96.819 Y89.326 E.01646
G1 X130.443 Y122.951 E1.46443
G1 X129.909 Y122.951 E.01646
G1 X96.819 Y89.861 E1.44115
G1 X96.819 Y90.395 E.01646
G1 X129.374 Y122.951 E1.41787
G1 X128.84 Y122.951 E.01646
G1 X96.819 Y90.93 E1.39459
G1 X96.819 Y91.464 E.01646
G1 X128.305 Y122.951 E1.37132
G1 X127.771 Y122.951 E.01646
G1 X96.819 Y91.999 E1.34804
G1 X96.819 Y92.533 E.01646
G1 X127.236 Y122.951 E1.32476
G1 X126.702 Y122.951 E.01646
G1 X96.819 Y93.068 E1.30148
G1 X96.819 Y93.602 E.01646
G1 X126.168 Y122.951 E1.2782
G1 X125.633 Y122.951 E.01646
G1 X96.819 Y94.137 E1.25493
G1 X96.819 Y94.671 E.01646
G1 X125.099 Y122.951 E1.23165
G1 X124.564 Y122.951 E.01646
G1 X96.819 Y95.206 E1.20837
G1 X96.819 Y95.74 E.01646
G1 X111.031 Y109.952 E.61896
G2 X110.409 Y109.864 I-.75 J3.081 E.01937
G1 X96.819 Y96.275 E.59187
G1 X96.819 Y96.809 E.01646
G1 X109.894 Y109.884 E.56946
G2 X109.453 Y109.977 I.246 J2.255 E.01391
G1 X96.819 Y97.344 E.55024
G1 X96.819 Y97.878 E.01646
G1 X109.057 Y110.116 E.533
G2 X108.704 Y110.297 I1.87 J4.091 E.01224
G1 X96.819 Y98.413 E.5176
G1 X96.819 Y98.947 E.01646
G1 X108.387 Y110.515 E.50382
G2 X108.103 Y110.766 I1.109 J1.545 E.01168
G1 X96.819 Y99.481 E.49145
G1 X96.819 Y100.016 E.01646
G1 X107.851 Y111.048 E.48046
G2 X107.636 Y111.368 I1.227 J1.053 E.01189
G1 X96.819 Y100.55 E.47112
G1 X96.819 Y101.085 E.01646
G1 X107.451 Y111.716 E.46303
G2 X107.31 Y112.11 I3.744 J1.562 E.01288
G1 X96.819 Y101.619 E.45689
G1 X96.819 Y102.154 E.01646
G1 X107.218 Y112.553 E.45292
G2 X107.193 Y113.063 I3.214 J.414 E.01572
G1 X96.819 Y102.688 E.45183
G1 X96.819 Y103.223 E.01646
G1 X107.527 Y113.931 E.46637
; WIPE_START
G1 X106.113 Y112.517 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X109.319 Y115.723 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X116.547 Y122.951 E.3148
G1 X117.081 Y122.951 E.01646
G1 X110.187 Y116.056 E.30028
G2 X110.699 Y116.033 I.086 J-3.835 E.01579
G1 X117.616 Y122.951 E.30127
G1 X118.15 Y122.951 E.01646
G1 X111.139 Y115.939 E.30537
G2 X111.534 Y115.8 I-.502 J-2.048 E.01292
G1 X118.685 Y122.951 E.31145
G1 X119.219 Y122.951 E.01646
G1 X111.886 Y115.617 E.3194
G2 X112.201 Y115.398 I-.936 J-1.685 E.01185
G1 X119.754 Y122.951 E.32894
G1 X120.288 Y122.951 E.01646
G1 X112.484 Y115.147 E.33988
G2 X112.736 Y114.864 I-1.29 J-1.401 E.01168
G1 X120.823 Y122.951 E.3522
G1 X121.357 Y122.951 E.01646
G1 X112.953 Y114.546 E.36603
G2 X113.132 Y114.191 I-1.688 J-1.075 E.01227
G1 X121.892 Y122.951 E.38149
G1 X122.426 Y122.951 E.01646
G1 X113.273 Y113.798 E.39864
G2 X113.364 Y113.354 I-3.452 J-.934 E.01396
G1 X122.961 Y122.951 E.41798
G1 X123.495 Y122.951 E.01646
G1 X113.388 Y112.843 E.44022
G2 X113.301 Y112.222 I-3.732 J.204 E.01933
G1 X124.199 Y123.12 E.47466
M204 S10000
G1 X116.182 Y123.12 F42000
G1 F15000
M204 S6000
G1 X96.819 Y103.757 E.84331
G1 X96.819 Y104.292 E.01646
G1 X115.478 Y122.951 E.81265
G1 X114.944 Y122.951 E.01646
G1 X96.819 Y104.826 E.78937
G1 X96.819 Y105.361 E.01646
G1 X114.409 Y122.951 E.76609
G1 X113.875 Y122.951 E.01646
G1 X96.819 Y105.895 E.74281
G1 X96.819 Y106.43 E.01646
M73 P43 R18
G1 X113.34 Y122.951 E.71954
G1 X112.806 Y122.951 E.01646
G1 X96.819 Y106.964 E.69626
G1 X96.819 Y107.499 E.01646
G1 X112.271 Y122.951 E.67298
G1 X111.737 Y122.951 E.01646
G1 X96.819 Y108.033 E.6497
G1 X96.819 Y108.568 E.01646
G1 X111.202 Y122.951 E.62642
G1 X110.668 Y122.951 E.01646
G1 X96.819 Y109.102 E.60315
G1 X96.819 Y109.636 E.01646
G1 X110.133 Y122.951 E.57987
G1 X109.599 Y122.951 E.01646
G1 X96.819 Y110.171 E.55659
G1 X96.819 Y110.705 E.01646
G1 X109.064 Y122.951 E.53331
G1 X108.53 Y122.951 E.01646
G1 X96.819 Y111.24 E.51004
G1 X96.819 Y111.774 E.01646
G1 X107.995 Y122.951 E.48676
G1 X107.461 Y122.951 E.01646
G1 X96.819 Y112.309 E.46348
G1 X96.819 Y112.843 E.01646
G1 X106.926 Y122.951 E.4402
G1 X106.392 Y122.951 E.01646
G1 X96.819 Y113.378 E.41692
G1 X96.819 Y113.912 E.01646
G1 X105.858 Y122.951 E.39365
G1 X105.323 Y122.951 E.01646
G1 X102.061 Y119.689 E.14206
G3 X102.166 Y120.328 I-3.522 J.904 E.01996
G1 X104.789 Y122.951 E.11423
G1 X104.254 Y122.951 E.01646
G1 X102.148 Y120.845 E.09171
G3 X102.066 Y121.297 I-3.772 J-.457 E.01415
G1 X103.72 Y122.951 E.07203
G1 X103.185 Y122.951 E.01646
G1 X101.928 Y121.694 E.05474
G3 X101.752 Y122.052 I-1.878 J-.702 E.01231
G1 X102.651 Y122.951 E.03914
G1 X102.116 Y122.951 E.01646
G1 X101.54 Y122.375 E.02508
G3 X101.291 Y122.66 I-1.552 J-1.102 E.01169
G1 X101.751 Y123.12 E.02003
M204 S10000
G1 X100.739 Y122.984 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.104076
G1 F15000
M204 S6000
G3 X100.611 Y123.061 I-.158 J-.118 E.00076
M204 S10000
G1 X99.87 Y123.225 F42000
; LINE_WIDTH: 0.50608
G1 F13602.226
M204 S6000
G3 X99.406 Y123.265 I-1.046 J-9.415 E.01758
; LINE_WIDTH: 0.479713
G1 F14423.319
G3 X98.573 Y123.253 I-.326 J-6.233 E.02967
; LINE_WIDTH: 0.51776
G1 F13267.644
G1 X98.271 Y123.219 E.01175
; WIPE_START
G1 X98.573 Y123.253 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.006 Y123.08 Z1 F42000
G1 Z.6
G1 E.8 F1800
; LINE_WIDTH: 0.402804
G1 F15000
M204 S6000
G1 X96.691 Y122.334 E.02377
M204 S10000
G1 X96.705 Y122.329 F42000
; LINE_WIDTH: 0.160763
G1 F15000
M204 S6000
G1 X96.979 Y123.08 E.00768
M204 S10000
G1 X96.69 Y122.815 F42000
; LINE_WIDTH: 0.134098
G1 F15000
M204 S6000
G1 X97.528 Y123.063 E.00649
M204 S10000
G1 X97.524 Y123.075 F42000
; LINE_WIDTH: 0.331344
G1 F15000
M204 S6000
G1 X96.69 Y122.783 E.02078
; WIPE_START
G1 X97.524 Y123.075 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.523 Y121.693 Z1 F42000
G1 Z.6
G1 E.8 F1800
; LINE_WIDTH: 0.436864
G1 F15000
M204 S6000
G1 X96.49 Y121.504 E.00616
; LINE_WIDTH: 0.405952
G1 X96.456 Y121.315 E.00568
; LINE_WIDTH: 0.3715
G1 X96.438 Y121.17 E.00391
; LINE_WIDTH: 0.337268
G1 X96.422 Y121.043 E.00309
; LINE_WIDTH: 0.30037
G1 X96.401 Y120.773 E.00567
; LINE_WIDTH: 0.272609
G1 X96.401 Y120.239 E.01
; LINE_WIDTH: 0.29846
G1 X96.42 Y119.971 E.00559
; LINE_WIDTH: 0.335595
G1 X96.438 Y119.83 E.0034
; LINE_WIDTH: 0.369311
G1 X96.454 Y119.702 E.00342
; LINE_WIDTH: 0.404455
G1 X96.49 Y119.496 E.00616
; LINE_WIDTH: 0.436855
G1 X96.523 Y119.307 E.00616
M204 S10000
G1 X96.708 Y118.672 F42000
; LINE_WIDTH: 0.104358
G1 F15000
M204 S6000
G3 X96.769 Y118.575 I.131 J.015 E.00059
G1 X96.801 Y118.545 E.00022
M204 S10000
G1 X96.65 Y117.484 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X97.198 Y118.033 E.02391
G3 X97.516 Y117.816 I.948 J1.047 E.01188
G1 X96.819 Y117.119 E.03035
G1 X96.819 Y116.585 E.01646
G1 X97.876 Y117.641 E.04601
G3 X98.275 Y117.506 I.876 J1.929 E.013
G1 X96.819 Y116.05 E.06339
G1 X96.819 Y115.516 E.01646
G1 X98.723 Y117.42 E.08292
G3 X99.244 Y117.406 I.33 J2.584 E.01606
G1 X96.819 Y114.981 E.10559
G1 X96.819 Y114.447 E.01646
G1 X100.146 Y117.773 E.14487
M204 S10000
G1 X109.297 Y85.235 F42000
G1 F15000
M204 S6000
G1 X159.52 Y135.459 E2.1874
G1 X159.52 Y135.994 E.01646
G1 X100.677 Y77.15 E2.56281
G2 X100.991 Y76.93 I-.942 J-1.683 E.01184
G1 X107.282 Y83.22 E.27397
G3 X107.194 Y82.598 I3.036 J-.745 E.01938
G1 X101.274 Y76.678 E.25786
G2 X101.524 Y76.394 I-1.296 J-1.398 E.01168
G1 X107.217 Y82.086 E.24791
G3 X107.307 Y81.642 I2.262 J.228 E.01398
G1 X101.739 Y76.075 E.24247
G2 X101.918 Y75.719 I-1.689 J-1.069 E.01229
G1 X107.446 Y81.246 E.24075
G3 X107.628 Y80.895 I1.847 J.735 E.01223
G1 X102.057 Y75.324 E.24263
G2 X102.145 Y74.877 I-3.46 J-.912 E.01403
G1 X107.845 Y80.577 E.24825
G3 X108.099 Y80.297 I1.229 J.859 E.01168
G1 X102.167 Y74.365 E.25835
G2 X102.066 Y73.729 I-3.405 J.217 E.01986
G1 X108.5 Y80.163 E.2802
; WIPE_START
G1 X107.085 Y78.748 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.622 Y77.154 Z1 F42000
G1 X96.913 Y76.575 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.121817
G1 F15000
M204 S6000
G1 X96.69 Y76.371 E.00194
M204 S10000
G1 X96.523 Y75.693 F42000
; LINE_WIDTH: 0.436849
G1 F15000
M204 S6000
G1 X96.49 Y75.504 E.00616
; LINE_WIDTH: 0.405945
G1 X96.456 Y75.315 E.00568
; LINE_WIDTH: 0.371522
G1 X96.438 Y75.17 E.00391
; LINE_WIDTH: 0.337302
G1 X96.422 Y75.043 E.00309
; LINE_WIDTH: 0.300413
G1 X96.401 Y74.773 E.00567
; LINE_WIDTH: 0.27262
G1 X96.401 Y74.239 E.01001
; LINE_WIDTH: 0.298472
G1 X96.42 Y73.971 E.00559
; LINE_WIDTH: 0.335617
G1 X96.438 Y73.83 E.0034
; LINE_WIDTH: 0.369327
G1 X96.454 Y73.702 E.00342
; LINE_WIDTH: 0.404458
G1 X96.49 Y73.496 E.00616
; LINE_WIDTH: 0.436862
G1 X96.523 Y73.307 E.00616
M204 S10000
G1 X96.708 Y72.672 F42000
; LINE_WIDTH: 0.104402
G1 F15000
M204 S6000
G3 X96.769 Y72.575 I.13 J.014 E.00059
G1 X96.802 Y72.545 E.00023
M204 S10000
G1 X97.298 Y72.168 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X96.819 Y71.689 E.02086
G1 X96.819 Y71.154 E.01646
G1 X97.495 Y71.83 E.02942
G3 X97.85 Y71.651 I2.214 J3.958 E.01226
G1 X96.819 Y70.62 E.04491
G1 X96.819 Y70.085 E.01646
G1 X98.247 Y71.513 E.0622
G3 X98.69 Y71.422 I1.115 J4.29 E.01394
G1 X96.819 Y69.551 E.08149
G1 X96.819 Y69.016 E.01646
G1 X99.207 Y71.405 E.10402
G3 X99.834 Y71.497 I-.158 J3.248 E.01954
G1 X96.819 Y68.482 E.13132
G1 X96.819 Y67.948 E.01646
G1 X108.694 Y79.823 E.5172
G3 X109.046 Y79.64 I2.262 J3.931 E.01221
G1 X96.819 Y67.413 E.53253
G1 X96.819 Y66.879 E.01646
G1 X109.441 Y79.501 E.54973
G3 X109.882 Y79.407 I.691 J2.152 E.01389
G1 X96.819 Y66.344 E.5689
G1 X96.819 Y65.81 E.01646
G1 X110.393 Y79.384 E.5912
G3 X111.011 Y79.467 I-.107 J3.123 E.01923
G1 X96.819 Y65.275 E.61811
G1 X96.819 Y64.741 E.01646
G1 X143.292 Y111.213 E2.02401
G3 X143.525 Y110.912 I1.62 J1.012 E.01175
G1 X96.819 Y64.206 E2.03416
G1 X96.819 Y63.672 E.01646
G1 X143.79 Y110.642 E2.0457
G3 X144.091 Y110.409 I3.497 J4.194 E.01173
G1 X96.819 Y63.137 E2.0588
G1 X96.819 Y62.603 E.01646
G1 X144.426 Y110.209 E2.07339
G3 X144.797 Y110.046 I1.003 J1.773 E.01251
G1 X96.819 Y62.068 E2.08955
G1 X96.819 Y61.534 E.01646
G1 X145.212 Y109.927 E2.10766
G3 X145.686 Y109.866 I.542 J2.34 E.01473
G1 X96.819 Y60.999 E2.12828
G1 X96.819 Y60.465 E.01646
G1 X146.241 Y109.887 E2.15248
G3 X146.951 Y110.062 I-.419 J3.225 E.02255
G1 X96.819 Y59.93 E2.18337
G1 X96.819 Y59.396 E.01646
G1 X159.52 Y122.097 E2.73082
G1 X159.52 Y121.563 E.01646
G1 X96.819 Y58.861 E2.73082
G1 X96.819 Y58.327 E.01646
G1 X159.52 Y121.028 E2.73082
G1 X159.52 Y120.494 E.01646
G1 X96.819 Y57.793 E2.73082
G1 X96.819 Y57.258 E.01646
G1 X159.69 Y120.129 E2.73821
M204 S10000
G1 X159.69 Y122.801 F42000
G1 F15000
M204 S6000
G1 X148.747 Y111.858 E.4766
G3 X148.924 Y112.57 I-2.118 J.904 E.02267
G1 X159.52 Y123.166 E.46151
G1 X159.52 Y123.701 E.01646
G1 X148.946 Y113.127 E.46053
G3 X148.882 Y113.596 I-2.372 J-.088 E.01463
G1 X159.52 Y124.235 E.46335
G1 X159.52 Y124.77 E.01646
G1 X148.766 Y114.015 E.46839
G3 X148.601 Y114.385 I-4.643 J-1.849 E.01247
G1 X159.52 Y125.304 E.47557
G1 X159.52 Y125.839 E.01646
G1 X148.4 Y114.718 E.48432
G3 X148.166 Y115.019 I-1.617 J-1.019 E.01175
G1 X159.382 Y126.234 E.48847
G1 X159.28 Y126.328 E.00425
G2 X158.245 Y125.632 I-2.256 J2.236 E.0387
G1 X147.9 Y115.287 E.45053
G3 X147.597 Y115.519 I-1.31 J-1.397 E.01176
G1 X157.512 Y125.433 E.43181
G2 X156.947 Y125.403 I-.473 J3.487 E.01745
G1 X147.261 Y115.717 E.42183
G3 X146.889 Y115.88 I-.996 J-1.775 E.01252
G1 X156.47 Y125.46 E.41726
G2 X156.048 Y125.573 I.796 J3.816 E.01345
G1 X146.471 Y115.996 E.41712
G3 X145.996 Y116.055 I-.535 J-2.351 E.01477
G1 X155.675 Y125.734 E.42154
G2 X155.337 Y125.931 I.816 J1.784 E.01205
G1 X145.436 Y116.03 E.43122
G3 X144.72 Y115.848 I.459 J-3.308 E.02281
G1 X155.033 Y126.162 E.44919
G2 X154.768 Y126.431 I.959 J1.213 E.01167
G1 X112.729 Y84.392 E1.8309
G3 X112.477 Y84.674 I-1.538 J-1.122 E.01168
G1 X154.528 Y126.725 E1.83145
G2 X154.326 Y127.058 I3.961 J2.632 E.01199
G1 X112.193 Y84.925 E1.83503
G3 X111.877 Y85.143 I-1.251 J-1.475 E.01185
G1 X154.163 Y127.429 E1.8417
G2 X154.041 Y127.842 I1.999 J.816 E.01327
G1 X111.523 Y85.324 E1.85178
G3 X111.127 Y85.462 I-.892 J-1.911 E.01294
G1 X153.978 Y128.313 E1.86626
G2 X153.992 Y128.861 I3.416 J.187 E.01691
G1 X110.686 Y85.556 E1.88608
G3 X110.172 Y85.576 I-.419 J-4.135 E.01586
G1 X154.161 Y129.565 E1.91587
G2 X156.006 Y131.411 I2.884 J-1.039 E.08302
G1 X159.52 Y134.925 E.15304
G1 X159.52 Y134.39 E.01646
G1 X156.707 Y131.576 E.12255
G2 X157.257 Y131.592 I.366 J-3.124 E.01698
G1 X159.52 Y133.856 E.09857
G1 X159.52 Y133.321 E.01646
G1 X157.729 Y131.529 E.07804
G2 X158.141 Y131.407 I-.932 J-3.909 E.01325
G1 X159.52 Y132.787 E.06008
G1 X159.52 Y132.252 E.01646
G1 X158.511 Y131.242 E.04398
G2 X158.844 Y131.042 I-.839 J-1.772 E.01201
G1 X159.52 Y131.718 E.02945
G1 X159.52 Y131.183 E.01646
G1 X159.023 Y130.685 E.02168
M204 S10000
G1 X159.512 Y130.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.109486
G1 F15000
M204 S6000
G2 X159.631 Y130.046 I-.159 J-.233 E.00122
M204 S10000
G1 X159.792 Y129.297 F42000
; LINE_WIDTH: 0.511603
G1 F13441.925
M204 S6000
G2 X159.83 Y128.908 I-8.128 J-.999 E.01492
; LINE_WIDTH: 0.47605
G1 F14545.292
G1 X159.845 Y128.482 E.01508
G2 X159.838 Y128.212 I-5.381 J.01 E.00952
; LINE_WIDTH: 0.512611
G1 F13413.075
G2 X159.817 Y127.935 I-6.218 J.337 E.01062
G1 X159.525 Y127.755 E.01312
M204 S10000
G1 X159.65 Y126.906 F42000
; LINE_WIDTH: 0.140508
G1 F15000
M204 S6000
G1 X159.561 Y126.799 E.00111
; LINE_WIDTH: 0.114391
G1 X159.423 Y126.651 E.00118
; WIPE_START
G1 X159.561 Y126.799 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X159.66 Y134.431 Z1 F42000
G1 X159.69 Y136.698 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X100.327 Y77.334 E2.58544
G3 X99.933 Y77.475 I-.9 J-1.897 E.0129
G1 X159.52 Y137.063 E2.5952
G1 X159.52 Y137.597 E.01646
G1 X99.494 Y77.571 E2.61432
G3 X98.986 Y77.597 I-.436 J-3.562 E.0157
G1 X159.52 Y138.131 E2.63647
G1 X159.52 Y138.666 E.01646
G1 X98.373 Y77.518 E2.66315
G3 X97.478 Y77.158 I.553 J-2.665 E.02987
G1 X159.52 Y139.2 E2.70213
G1 X159.52 Y139.735 E.01646
G1 X96.819 Y77.034 E2.73082
G1 X96.819 Y77.568 E.01646
G1 X159.52 Y140.269 E2.73082
G1 X159.52 Y140.804 E.01646
G1 X96.819 Y78.103 E2.73082
G1 X96.819 Y78.637 E.01646
G1 X159.52 Y141.338 E2.73082
G1 X159.52 Y141.873 E.01646
G1 X96.819 Y79.171 E2.73082
G1 X96.819 Y79.706 E.01646
G1 X159.52 Y142.407 E2.73082
G1 X159.52 Y142.942 E.01646
G1 X96.819 Y80.24 E2.73082
G1 X96.819 Y80.775 E.01646
G1 X159.52 Y143.476 E2.73082
G1 X159.52 Y144.011 E.01646
G1 X96.819 Y81.309 E2.73082
G1 X96.819 Y81.844 E.01646
G1 X159.52 Y144.545 E2.73082
G1 X159.52 Y145.08 E.01646
G1 X96.819 Y82.378 E2.73082
G1 X96.819 Y82.913 E.01646
G1 X159.52 Y145.614 E2.73082
M73 P44 R18
G1 X159.52 Y146.149 E.01646
G1 X96.819 Y83.447 E2.73082
G1 X96.819 Y83.982 E.01646
G1 X159.52 Y146.683 E2.73082
G1 X159.52 Y147.218 E.01646
G1 X96.819 Y84.516 E2.73082
G1 X96.819 Y85.051 E.01646
G1 X159.52 Y147.752 E2.73082
G1 X159.52 Y148.286 E.01646
G1 X96.819 Y85.585 E2.73082
G1 X96.819 Y86.12 E.01646
G1 X159.52 Y148.821 E2.73082
G1 X159.52 Y149.355 E.01646
G1 X96.819 Y86.654 E2.73082
G1 X96.819 Y87.189 E.01646
G1 X159.52 Y149.89 E2.73082
G1 X159.52 Y150.424 E.01646
G1 X132.819 Y123.723 E1.16292
G1 X132.819 Y124.258 E.01646
G1 X159.52 Y150.959 E1.16292
G1 X159.52 Y151.493 E.01646
G1 X132.819 Y124.792 E1.16292
G1 X132.819 Y125.326 E.01646
G1 X159.52 Y152.028 E1.16292
G1 X159.52 Y152.562 E.01646
G1 X132.819 Y125.861 E1.16292
G1 X132.819 Y126.395 E.01646
G1 X159.52 Y153.097 E1.16292
G1 X159.52 Y153.631 E.01646
G1 X132.819 Y126.93 E1.16292
G1 X132.819 Y127.464 E.01646
G1 X159.52 Y154.166 E1.16292
G1 X159.52 Y154.7 E.01646
G1 X132.819 Y127.999 E1.16292
G1 X132.819 Y128.533 E.01646
G1 X159.52 Y155.235 E1.16292
G1 X159.52 Y155.769 E.01646
G1 X132.819 Y129.068 E1.16292
G1 X132.819 Y129.602 E.01646
G1 X159.52 Y156.304 E1.16292
G1 X159.52 Y156.838 E.01646
G1 X132.819 Y130.137 E1.16292
G1 X132.819 Y130.671 E.01646
G1 X159.52 Y157.373 E1.16292
G1 X159.52 Y157.907 E.01646
G1 X132.819 Y131.206 E1.16292
G1 X132.819 Y131.74 E.01646
G1 X159.52 Y158.441 E1.16292
G1 X159.52 Y158.976 E.01646
G1 X132.819 Y132.275 E1.16292
G1 X132.819 Y132.809 E.01646
G1 X159.52 Y159.51 E1.16292
G1 X159.52 Y160.045 E.01646
G1 X132.819 Y133.344 E1.16292
G1 X132.819 Y133.878 E.01646
G1 X159.52 Y160.579 E1.16292
G1 X159.52 Y161.114 E.01646
G1 X132.819 Y134.413 E1.16292
G1 X132.819 Y134.947 E.01646
G1 X159.52 Y161.648 E1.16292
G1 X159.52 Y162.183 E.01646
G1 X132.819 Y135.481 E1.16292
G1 X132.819 Y136.016 E.01646
G1 X159.52 Y162.717 E1.16292
G1 X159.52 Y163.252 E.01646
G1 X132.819 Y136.55 E1.16292
G1 X132.819 Y137.085 E.01646
G1 X159.52 Y163.786 E1.16292
G1 X159.52 Y164.321 E.01646
G1 X132.819 Y137.619 E1.16292
G1 X132.819 Y138.154 E.01646
G1 X159.52 Y164.855 E1.16292
M73 P44 R17
G1 X159.52 Y165.39 E.01646
G1 X132.819 Y138.688 E1.16292
G1 X132.819 Y139.223 E.01646
G1 X159.52 Y165.924 E1.16292
G1 X159.52 Y166.459 E.01646
G1 X132.819 Y139.757 E1.16292
G1 X132.819 Y140.292 E.01646
G1 X159.52 Y166.993 E1.16292
G1 X159.52 Y167.528 E.01646
G1 X132.819 Y140.826 E1.16292
G1 X132.819 Y141.361 E.01646
G1 X159.52 Y168.062 E1.16292
G1 X159.52 Y168.596 E.01646
G1 X132.819 Y141.895 E1.16292
G1 X132.819 Y142.43 E.01646
G1 X159.52 Y169.131 E1.16292
G1 X159.52 Y169.665 E.01646
G1 X132.819 Y142.964 E1.16292
G1 X132.819 Y143.499 E.01646
G1 X159.52 Y170.2 E1.16292
G1 X159.52 Y170.734 E.01646
G1 X132.819 Y144.033 E1.16292
G1 X132.819 Y144.568 E.01646
G1 X159.52 Y171.269 E1.16292
G1 X159.52 Y171.803 E.01646
G1 X132.819 Y145.102 E1.16292
G1 X132.819 Y145.636 E.01646
G1 X159.52 Y172.338 E1.16292
G1 X159.52 Y172.872 E.01646
G1 X132.819 Y146.171 E1.16292
G1 X132.819 Y146.705 E.01646
G1 X159.52 Y173.407 E1.16292
G1 X159.52 Y173.941 E.01646
G1 X132.819 Y147.24 E1.16292
G1 X132.819 Y147.774 E.01646
G1 X159.52 Y174.476 E1.16292
G1 X159.52 Y175.01 E.01646
G1 X132.819 Y148.309 E1.16292
G1 X132.819 Y148.843 E.01646
G1 X159.52 Y175.545 E1.16292
G1 X159.52 Y176.079 E.01646
G1 X132.819 Y149.378 E1.16292
G1 X132.819 Y149.912 E.01646
G1 X159.52 Y176.614 E1.16292
G1 X159.52 Y177.148 E.01646
G1 X132.819 Y150.447 E1.16292
G1 X132.819 Y150.981 E.01646
G1 X159.52 Y177.683 E1.16292
G1 X159.52 Y178.217 E.01646
G1 X132.819 Y151.516 E1.16292
G1 X132.819 Y152.05 E.01646
G1 X159.52 Y178.751 E1.16292
G1 X159.52 Y179.286 E.01646
G1 X132.819 Y152.585 E1.16292
G1 X132.819 Y153.119 E.01646
G1 X159.52 Y179.82 E1.16292
G1 X159.52 Y180.355 E.01646
G1 X132.819 Y153.654 E1.16292
G1 X132.819 Y154.188 E.01646
G1 X159.52 Y180.889 E1.16292
G1 X159.52 Y181.424 E.01646
G1 X132.819 Y154.723 E1.16292
G1 X132.819 Y155.257 E.01646
G1 X159.52 Y181.958 E1.16292
G1 X159.52 Y182.493 E.01646
G1 X132.819 Y155.792 E1.16292
G1 X132.819 Y156.326 E.01646
G1 X159.52 Y183.027 E1.16292
G1 X159.52 Y183.562 E.01646
G1 X132.819 Y156.86 E1.16292
G1 X132.819 Y157.395 E.01646
G1 X159.52 Y184.096 E1.16292
G1 X159.52 Y184.631 E.01646
M73 P45 R17
G1 X132.819 Y157.929 E1.16292
G1 X132.819 Y158.464 E.01646
G1 X159.52 Y185.165 E1.16292
G1 X159.52 Y185.7 E.01646
G1 X132.819 Y158.998 E1.16292
G1 X132.819 Y159.533 E.01646
G1 X159.52 Y186.234 E1.16292
G1 X159.52 Y186.769 E.01646
G1 X132.819 Y160.067 E1.16292
G1 X132.819 Y160.602 E.01646
G1 X159.52 Y187.303 E1.16292
G1 X159.52 Y187.838 E.01646
G1 X132.819 Y161.136 E1.16292
G1 X132.819 Y161.671 E.01646
G1 X159.52 Y188.372 E1.16292
G1 X159.52 Y188.906 E.01646
G1 X132.819 Y162.205 E1.16292
G1 X132.819 Y162.74 E.01646
G1 X159.52 Y189.441 E1.16292
G1 X159.52 Y189.975 E.01646
G1 X132.819 Y163.274 E1.16292
G1 X132.819 Y163.809 E.01646
G1 X159.52 Y190.51 E1.16292
G1 X159.52 Y191.044 E.01646
G1 X132.819 Y164.343 E1.16292
G1 X132.819 Y164.878 E.01646
G1 X159.52 Y191.579 E1.16292
G1 X159.52 Y192.113 E.01646
G1 X132.819 Y165.412 E1.16292
G1 X132.819 Y165.947 E.01646
G1 X159.52 Y192.648 E1.16292
G1 X159.52 Y193.182 E.01646
G1 X132.819 Y166.481 E1.16292
G1 X132.819 Y167.015 E.01646
G1 X159.52 Y193.717 E1.16292
G1 X159.52 Y194.251 E.01646
G1 X132.819 Y167.55 E1.16292
G1 X132.819 Y168.084 E.01646
G1 X159.52 Y194.786 E1.16292
G1 X159.52 Y195.32 E.01646
G1 X132.819 Y168.619 E1.16292
G1 X132.819 Y169.153 E.01646
G1 X159.52 Y195.855 E1.16292
G1 X159.52 Y196.389 E.01646
G1 X132.819 Y169.688 E1.16292
G1 X132.819 Y170.222 E.01646
G1 X159.52 Y196.924 E1.16292
G1 X159.52 Y197.458 E.01646
G1 X132.819 Y170.757 E1.16292
G1 X132.819 Y171.291 E.01646
G1 X159.52 Y197.993 E1.16292
G1 X159.52 Y198.527 E.01646
G1 X132.819 Y171.826 E1.16292
G1 X132.819 Y172.36 E.01646
G1 X159.52 Y199.061 E1.16292
G1 X159.52 Y199.596 E.01646
G1 X132.819 Y172.895 E1.16292
G1 X132.819 Y173.429 E.01646
G1 X159.52 Y200.13 E1.16292
G1 X159.52 Y200.665 E.01646
G1 X132.819 Y173.964 E1.16292
G1 X132.819 Y174.498 E.01646
G1 X159.52 Y201.199 E1.16292
G1 X159.52 Y201.734 E.01646
G1 X132.819 Y175.033 E1.16292
G1 X132.819 Y175.567 E.01646
G1 X159.52 Y202.268 E1.16292
G1 X159.52 Y202.803 E.01646
G1 X132.819 Y176.102 E1.16292
G1 X132.819 Y176.636 E.01646
G1 X159.52 Y203.337 E1.16292
G1 X159.52 Y203.872 E.01646
G1 X132.819 Y177.17 E1.16292
G1 X132.819 Y177.705 E.01646
G1 X159.52 Y204.406 E1.16292
G1 X159.52 Y204.941 E.01646
G1 X132.819 Y178.239 E1.16292
G1 X132.819 Y178.774 E.01646
G1 X159.52 Y205.475 E1.16292
G1 X159.52 Y206.01 E.01646
G1 X132.819 Y179.308 E1.16292
G1 X132.819 Y179.843 E.01646
G1 X159.52 Y206.544 E1.16292
G1 X159.52 Y207.079 E.01646
G1 X132.819 Y180.377 E1.16292
G1 X132.819 Y180.912 E.01646
G1 X159.52 Y207.613 E1.16292
G1 X159.52 Y208.148 E.01646
G1 X132.819 Y181.446 E1.16292
G1 X132.819 Y181.981 E.01646
G1 X159.52 Y208.682 E1.16292
G1 X159.52 Y209.216 E.01646
G1 X132.819 Y182.515 E1.16292
G1 X132.819 Y183.05 E.01646
G1 X159.52 Y209.751 E1.16292
G1 X159.52 Y210.285 E.01646
G1 X132.819 Y183.584 E1.16292
G1 X132.819 Y184.119 E.01646
G1 X159.451 Y210.751 E1.1599
G1 X158.917 Y210.751 E.01646
G1 X132.819 Y184.653 E1.13662
G1 X132.819 Y185.188 E.01646
G1 X158.382 Y210.751 E1.11334
G1 X157.848 Y210.751 E.01646
G1 X132.819 Y185.722 E1.09007
G1 X132.819 Y186.257 E.01646
G1 X157.313 Y210.751 E1.06679
G1 X156.779 Y210.751 E.01646
G1 X132.819 Y186.791 E1.04351
G1 X132.819 Y187.325 E.01646
G1 X156.244 Y210.751 E1.02023
G1 X155.71 Y210.751 E.01646
G1 X132.819 Y187.86 E.99696
G1 X132.819 Y188.394 E.01646
G1 X155.175 Y210.751 E.97368
G1 X154.641 Y210.751 E.01646
G1 X132.819 Y188.929 E.9504
G1 X132.819 Y189.463 E.01646
G1 X154.106 Y210.751 E.92712
G1 X153.572 Y210.751 E.01646
G1 X132.819 Y189.998 E.90384
G1 X132.819 Y190.532 E.01646
G1 X153.038 Y210.751 E.88057
G1 X152.503 Y210.751 E.01646
G1 X132.819 Y191.067 E.85729
G1 X132.819 Y191.601 E.01646
G1 X151.969 Y210.751 E.83401
G1 X151.434 Y210.751 E.01646
G1 X132.819 Y192.136 E.81073
G1 X132.819 Y192.67 E.01646
G1 X150.9 Y210.751 E.78745
G1 X150.365 Y210.751 E.01646
G1 X132.819 Y193.205 E.76418
G1 X132.819 Y193.739 E.01646
G1 X149.831 Y210.751 E.7409
G1 X149.296 Y210.751 E.01646
G1 X132.819 Y194.274 E.71762
G1 X132.819 Y194.808 E.01646
G1 X148.762 Y210.751 E.69434
G1 X148.227 Y210.751 E.01646
G1 X132.819 Y195.343 E.67107
G1 X132.819 Y195.877 E.01646
G1 X147.693 Y210.751 E.64779
G1 X147.158 Y210.751 E.01646
G1 X132.819 Y196.412 E.62451
G1 X132.819 Y196.946 E.01646
G1 X146.624 Y210.751 E.60123
G1 X146.089 Y210.751 E.01646
G1 X132.819 Y197.48 E.57795
G1 X132.819 Y198.015 E.01646
G1 X145.555 Y210.751 E.55468
G1 X145.02 Y210.751 E.01646
G1 X132.819 Y198.549 E.5314
G1 X132.819 Y199.084 E.01646
G1 X144.486 Y210.751 E.50812
G1 X143.951 Y210.751 E.01646
G1 X132.819 Y199.618 E.48484
G1 X132.819 Y200.153 E.01646
G1 X143.417 Y210.751 E.46157
G1 X142.883 Y210.751 E.01646
G1 X132.819 Y200.687 E.43829
G1 X132.819 Y201.222 E.01646
G1 X142.348 Y210.751 E.41501
G1 X141.814 Y210.751 E.01646
G1 X132.819 Y201.756 E.39173
G1 X132.819 Y202.291 E.01646
G1 X136.11 Y205.582 E.14333
G2 X135.415 Y205.421 I-1.053 J2.977 E.022
G1 X132.819 Y202.825 E.11307
G1 X132.819 Y203.36 E.01646
G1 X134.868 Y205.409 E.08924
G2 X134.398 Y205.473 I.087 J2.386 E.01464
G1 X132.819 Y203.894 E.06876
G1 X132.819 Y204.429 E.01646
G1 X133.988 Y205.597 E.05089
G2 X133.619 Y205.763 I.644 J1.926 E.01247
G1 X132.819 Y204.963 E.03483
G1 X132.819 Y205.498 E.01646
G1 X133.286 Y205.964 E.02033
G2 X132.989 Y206.202 I3.014 J4.068 E.01171
G1 X132.65 Y205.862 E.0148
M204 S10000
G1 X132.812 Y206.535 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.106232
G1 F15000
M204 S6000
G1 X132.69 Y206.655 E.00088
M204 S10000
G1 X132.762 Y207.375 F42000
; LINE_WIDTH: 0.448134
G1 F15000
M204 S6000
G1 X132.486 Y207.513 E.01021
; LINE_WIDTH: 0.433943
G1 X132.47 Y207.604 E.00294
; LINE_WIDTH: 0.400602
G1 X132.453 Y207.71 E.00313
; LINE_WIDTH: 0.367752
G1 X132.437 Y207.834 E.0033
; LINE_WIDTH: 0.335067
G1 X132.42 Y207.971 E.0033
; LINE_WIDTH: 0.29845
G1 X132.401 Y208.239 E.00559
; LINE_WIDTH: 0.272595
G1 X132.401 Y208.773 E.01
; LINE_WIDTH: 0.300391
G1 X132.422 Y209.043 E.00567
; LINE_WIDTH: 0.337269
G1 X132.438 Y209.17 E.00308
; LINE_WIDTH: 0.371477
G1 X132.456 Y209.315 E.00391
; LINE_WIDTH: 0.405914
G1 X132.49 Y209.504 E.00568
; LINE_WIDTH: 0.436852
G1 X132.523 Y209.693 E.00616
; WIPE_START
G1 X132.49 Y209.504 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.883 Y210.671 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.38674
G1 F15000
M204 S6000
G1 X132.818 Y210.708 E.00209
G1 X132.868 Y210.737 E.00161
; WIPE_START
G1 X132.818 Y210.708 E-.33089
G1 X132.883 Y210.671 E-.42911
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.938 Y210.81 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.417778
G1 F15000
M204 S6000
G1 X134.071 Y211.073 E.00897
; LINE_WIDTH: 0.432012
G1 X134.2 Y211.103 E.00421
; LINE_WIDTH: 0.390587
G1 X134.323 Y211.124 E.00354
; LINE_WIDTH: 0.353395
G1 X134.467 Y211.14 E.00367
; LINE_WIDTH: 0.322732
G1 X134.595 Y211.155 E.00293
; LINE_WIDTH: 0.279202
G1 X134.875 Y211.172 E.0054
G1 X135.398 Y211.166 E.01006
; LINE_WIDTH: 0.309171
G1 X135.666 Y211.142 E.00584
; LINE_WIDTH: 0.351565
G1 X135.808 Y211.123 E.00361
; LINE_WIDTH: 0.388758
G1 X135.936 Y211.106 E.00364
; LINE_WIDTH: 0.431349
G2 X136.264 Y211.044 I-1.063 J-6.562 E.01056
; WIPE_START
G1 X135.936 Y211.106 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.707 Y210.92 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X137.368 Y210.581 E.0148
G2 X137.604 Y210.282 I-1.372 J-1.329 E.01174
G1 X138.072 Y210.751 E.0204
G1 X138.607 Y210.751 E.01646
G1 X137.807 Y209.951 E.03483
G2 X137.975 Y209.584 I-1.752 J-1.022 E.01244
G1 X139.141 Y210.751 E.05081
G1 X139.676 Y210.751 E.01646
G1 X138.093 Y209.168 E.06895
G2 X138.161 Y208.702 I-1.85 J-.511 E.01454
G1 X140.21 Y210.751 E.08923
G1 X140.745 Y210.751 E.01646
G1 X138.151 Y208.157 E.11297
G2 X137.987 Y207.459 I-3.23 J.388 E.02212
G1 X141.449 Y210.92 E.15075
; OBJECT_ID: 124
; WIPE_START
G1 X140.035 Y209.506 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G1 X135.718 Y203.212 Z1 F42000
G1 X106.723 Y160.934 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X106.754 Y161.239 E.00942
G3 X105.061 Y159.705 I-1.559 J.019 E.22223
G1 X105.211 Y159.699 E.00461
G3 X106.707 Y160.877 I-.016 J1.559 E.06295
; WIPE_START
M204 S6000
G1 X106.754 Y161.239 E-.13876
G1 X106.751 Y161.395 E-.05908
G1 X106.693 Y161.7 E-.11806
G1 X106.576 Y161.988 E-.11795
G1 X106.405 Y162.247 E-.11808
G1 X106.185 Y162.466 E-.11811
G1 X105.988 Y162.597 E-.08995
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.145 Y163.546 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X104.715 Y163.497 E.01328
G3 X105.225 Y158.969 I.479 J-2.239 E.20713
G1 X105.335 Y158.973 E.00336
G3 X105.205 Y163.548 I-.14 J2.285 E.21639
M204 S10000
G1 X105.173 Y163.183 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381162
M73 P46 R17
G1 F15000
M204 S6000
G3 X103.272 Y161.291 I.024 J-1.924 E.08177
G1 X103.272 Y161.275 E.00046
G3 X103.279 Y161.099 I3.511 J.044 E.00483
G3 X105.233 Y163.183 I1.918 J.159 E.24456
; OBJECT_ID: 102
; WIPE_START
G1 X104.792 Y163.141 E-.16827
G1 X104.504 Y163.054 E-.11437
G1 X104.173 Y162.889 E-.1406
G1 X103.87 Y162.654 E-.14566
G1 X103.62 Y162.363 E-.1457
G1 X103.561 Y162.259 E-.04541
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.055 Y154.642 Z1 F42000
G1 X104.067 Y154.458 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X104.098 Y154.763 E.00942
G3 X102.405 Y153.228 I-1.559 J.019 E.22223
G1 X102.555 Y153.222 E.00461
G3 X104.051 Y154.401 I-.016 J1.559 E.06295
; WIPE_START
M204 S6000
G1 X104.098 Y154.763 E-.13876
G1 X104.096 Y154.918 E-.05908
G1 X104.038 Y155.223 E-.11806
G1 X103.921 Y155.511 E-.11795
G1 X103.749 Y155.77 E-.11808
G1 X103.529 Y155.99 E-.11811
G1 X103.332 Y156.121 E-.08995
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.489 Y157.069 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X102.06 Y157.021 E.01328
G3 X102.57 Y152.492 I.479 J-2.239 E.20713
G1 X102.679 Y152.496 E.00336
G3 X102.549 Y157.071 I-.14 J2.285 E.21639
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381162
G1 F15000
M204 S6000
G3 X100.617 Y154.815 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.511 J.044 E.00483
G3 X102.577 Y156.706 I1.918 J.159 E.24456
; OBJECT_ID: 91
; WIPE_START
G1 X102.136 Y156.664 E-.16827
G1 X101.848 Y156.578 E-.11437
G1 X101.517 Y156.412 E-.1406
G1 X101.214 Y156.177 E-.14566
G1 X100.964 Y155.886 E-.1457
G1 X100.906 Y155.782 E-.04541
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.166 Z1 F42000
G1 X101.411 Y147.981 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X101.443 Y148.286 E.00942
G3 X99.75 Y146.751 I-1.559 J.019 E.22223
G1 X99.899 Y146.745 E.00461
G3 X101.396 Y147.924 I-.016 J1.559 E.06295
; WIPE_START
M204 S6000
G1 X101.443 Y148.286 E-.13876
G1 X101.44 Y148.441 E-.05908
G1 X101.382 Y148.747 E-.11806
G1 X101.265 Y149.034 E-.11795
G1 X101.093 Y149.293 E-.11808
G1 X100.874 Y149.513 E-.11811
G1 X100.676 Y149.644 E-.08995
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.834 Y150.593 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X99.404 Y150.544 E.01328
G3 X99.914 Y146.016 I.479 J-2.239 E.20713
G1 X100.023 Y146.02 E.00336
G3 X99.893 Y150.595 I-.14 J2.285 E.21639
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381162
G1 F15000
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.511 J.044 E.00483
G3 X99.921 Y150.23 I1.918 J.159 E.24456
; OBJECT_ID: 113
; WIPE_START
G1 X99.481 Y150.187 E-.16827
G1 X99.192 Y150.101 E-.11437
G1 X98.861 Y149.936 E-.1406
G1 X98.559 Y149.7 E-.14566
G1 X98.309 Y149.41 E-.1457
G1 X98.25 Y149.305 E-.04541
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.744 Y141.689 Z1 F42000
G1 X98.756 Y141.504 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X98.787 Y141.809 E.00942
G3 X97.094 Y140.274 I-1.559 J.019 E.22223
G1 X97.244 Y140.269 E.00461
G3 X98.74 Y141.447 I-.016 J1.559 E.06295
; WIPE_START
M204 S6000
G1 X98.787 Y141.809 E-.13876
G1 X98.784 Y141.965 E-.05908
G1 X98.727 Y142.27 E-.11806
G1 X98.61 Y142.558 E-.11795
G1 X98.438 Y142.816 E-.11808
G1 X98.218 Y143.036 E-.11811
G1 X98.021 Y143.167 E-.08995
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.178 Y144.116 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X96.748 Y144.067 E.01328
G3 X97.259 Y139.539 I.479 J-2.239 E.20713
G1 X97.368 Y139.543 E.00336
G3 X97.238 Y144.118 I-.14 J2.285 E.21639
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381162
G1 F15000
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.511 J.044 E.00483
G3 X97.266 Y143.753 I1.918 J.159 E.24456
; CHANGE_LAYER
; Z_HEIGHT: 0.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.825 Y143.711 E-.16827
G1 X96.537 Y143.624 E-.11437
G1 X96.206 Y143.459 E-.1406
G1 X95.903 Y143.224 E-.14566
G1 X95.653 Y142.933 E-.1457
G1 X95.595 Y142.829 E-.04541
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 4/60
; update layer progress
M73 L4
M991 S0 P3 ;notify layer change
; OBJECT_ID: 80
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
M204 S10000
G17
G3 Z1 I.938 J.775 P1  F42000
G1 X144.658 Y83.487 Z1
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.656 Y83.482 E.00017
G3 X145.656 Y80.932 I1.194 J-1.003 E.10275
G1 X145.811 Y80.92 E.00478
G3 X144.878 Y83.699 I.039 J1.559 E.18395
G1 X144.702 Y83.528 E.00754
; WIPE_START
M204 S6000
G1 X144.656 Y83.482 E-.02485
G1 X144.48 Y83.226 E-.11792
G1 X144.359 Y82.94 E-.11807
G1 X144.297 Y82.635 E-.11812
G1 X144.297 Y82.325 E-.11801
G1 X144.359 Y82.02 E-.11814
G1 X144.48 Y81.734 E-.11807
G1 X144.519 Y81.675 E-.02682
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.21 Y89.118 Z1.2 F42000
G1 X155.565 Y130.304 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X155.424 Y130.188 E.00605
G3 X156.776 Y126.158 I1.646 J-1.69 E.17561
G1 X157.011 Y126.14 E.00782
G3 X155.791 Y130.48 I.059 J2.358 E.29263
G1 X155.612 Y130.341 E.00753
M204 S10000
G1 X155.818 Y129.987 F42000
G1 F15476.087
M204 S6000
G1 X155.708 Y129.897 E.00471
G3 X156.827 Y126.562 I1.362 J-1.398 E.1453
G1 X157.021 Y126.548 E.00647
G3 X156.012 Y130.139 I.049 J1.951 E.24209
G1 X155.865 Y130.024 E.00618
M204 S250
G1 X156.061 Y129.681 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X155.982 Y129.616 E.00316
G3 X156.876 Y126.952 I1.088 J-1.117 E.10754
G1 X157.031 Y126.94 E.00478
G3 X156.224 Y129.809 I.039 J1.559 E.17917
G1 X156.108 Y129.718 E.00453
; WIPE_START
M204 S6000
G1 X155.982 Y129.616 E-.0619
G1 X155.875 Y129.503 E-.05912
G1 X155.7 Y129.246 E-.11808
G1 X155.579 Y128.96 E-.11802
G1 X155.517 Y128.655 E-.11811
G1 X155.517 Y128.345 E-.11804
G1 X155.579 Y128.041 E-.1177
G1 X155.626 Y127.921 E-.04903
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.033 Y127.141 Z1.2 F42000
G1 X96.664 Y121.865 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X96.783 Y122.059 E.00755
G2 X98.09 Y123.091 I2.327 J-1.604 E.05608
G1 X98.049 Y123.284 E.00654
G1 X96.486 Y123.284 E.05184
G1 X96.486 Y121.915 E.0454
G1 X96.606 Y121.881 E.00415
; WIPE_START
G1 X96.783 Y122.059 E-.09527
G1 X96.949 Y122.279 E-.10482
G1 X97.137 Y122.482 E-.105
G1 X97.344 Y122.664 E-.1048
G1 X97.568 Y122.825 E-.1048
G1 X97.807 Y122.963 E-.10493
G1 X98.09 Y123.091 E-.11802
G1 X98.078 Y123.148 E-.02236
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.721 Y120.362 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X96.723 Y120.265 E.00322
G3 X98.776 Y118.158 I2.347 J.233 E.10539
G1 X99.011 Y118.14 E.00782
G3 X96.723 Y120.735 I.059 J2.358 E.36284
G1 X96.721 Y120.422 E.01036
M204 S10000
G1 X97.127 Y120.362 F42000
G1 F15476.087
M204 S6000
G1 X97.128 Y120.306 E.00188
G3 X98.827 Y118.562 I1.942 J.193 E.0872
G1 X99.021 Y118.548 E.00647
G3 X97.128 Y120.694 I.049 J1.951 E.30019
G1 X97.127 Y120.422 E.00902
M204 S250
G1 X97.517 Y120.362 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X97.518 Y120.345 E.00054
G3 X98.876 Y118.952 I1.552 J.154 E.06454
G1 X99.031 Y118.94 E.00478
G3 X97.518 Y120.655 I.039 J1.559 E.22217
G1 X97.518 Y120.422 E.00715
; WIPE_START
M204 S6000
G1 X97.518 Y120.345 E-.02949
G1 X97.579 Y120.041 E-.11768
G1 X97.664 Y119.822 E-.08932
G1 X97.826 Y119.558 E-.11776
G1 X98.037 Y119.33 E-.11803
G1 X98.29 Y119.149 E-.1181
G1 X98.573 Y119.021 E-.11806
G1 X98.705 Y118.991 E-.05157
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.17 Y111.372 Z1.2 F42000
G1 X101.398 Y74.834 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X101.324 Y75.195 E.01224
G3 X98.776 Y72.158 I-2.254 J-.697 E.33551
G1 X99.011 Y72.14 E.00781
G3 X101.417 Y74.735 I.059 J2.358 E.13272
G1 X101.41 Y74.775 E.00135
M204 S10000
G1 X101.001 Y74.754 F42000
G1 F15476.087
M204 S6000
G1 X100.934 Y75.075 E.01089
G3 X98.827 Y72.562 I-1.865 J-.576 E.27758
G1 X99.021 Y72.548 E.00647
G3 X101.012 Y74.694 I.049 J1.951 E.1098
G1 X101.012 Y74.695 E.00001
M204 S250
G1 X100.618 Y74.676 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X100.56 Y74.96 E.00889
G3 X98.876 Y72.952 I-1.49 J-.461 E.20544
G1 X99.031 Y72.94 E.00479
G3 X100.625 Y74.617 I.039 J1.559 E.08007
; WIPE_START
M204 S6000
G1 X100.56 Y74.96 E-.13263
G1 X100.44 Y75.246 E-.11804
G1 X100.265 Y75.503 E-.118
G1 X100.076 Y75.692 E-.10167
G1 X99.85 Y75.851 E-.10512
G1 X99.567 Y75.979 E-.11806
G1 X99.396 Y76.018 E-.06649
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.325 Y80.825 Z1.2 F42000
G1 X143.394 Y111.689 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.489 Y111.517 E.00651
G3 X145.505 Y110.214 I2.361 J1.441 E.08239
G1 X145.781 Y110.193 E.00917
G3 X143.357 Y111.759 I.069 J2.765 E.47584
G1 X143.366 Y111.742 E.00064
M204 S10000
G1 X143.774 Y111.852 F42000
G1 F15476.087
M204 S6000
G1 X143.969 Y111.535 E.01234
G3 X145.556 Y110.618 I1.881 J1.423 E.06246
G1 X145.791 Y110.6 E.00782
G3 X143.724 Y111.936 I.059 J2.358 E.40578
G1 X143.743 Y111.904 E.00125
M204 S10000
G1 X144.12 Y112.064 F42000
G1 F15476.087
M204 S6000
G1 X144.294 Y111.781 E.01099
G3 X145.607 Y111.022 I1.556 J1.178 E.05167
G1 X145.801 Y111.008 E.00647
G3 X144.09 Y112.115 I.049 J1.951 E.33562
M204 S250
G1 X144.454 Y112.267 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.606 Y112.018 E.00898
G3 X145.656 Y111.412 I1.243 J.941 E.03824
G1 X145.811 Y111.4 E.00478
G3 X144.427 Y112.321 I.039 J1.559 E.24717
; WIPE_START
M204 S6000
G1 X144.606 Y112.018 E-.13377
G1 X144.817 Y111.79 E-.11801
G1 X145.07 Y111.609 E-.11809
G1 X145.353 Y111.481 E-.11804
G1 X145.656 Y111.412 E-.11804
G1 X145.811 Y111.4 E-.05916
G1 X146.06 Y111.419 E-.09487
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.441 Y111.867 Z1.2 F42000
G1 X113.025 Y113.36 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X113.001 Y113.508 E.00497
G3 X109.945 Y110.214 I-2.711 J-.55 E.40258
G1 X110.221 Y110.193 E.00917
G3 X113.042 Y113.235 I.069 J2.765 E.15564
G1 X113.033 Y113.301 E.0022
M204 S10000
G1 X112.62 Y113.26 F42000
G1 F15476.087
M204 S6000
G1 X112.602 Y113.427 E.00557
G3 X109.996 Y110.618 I-2.312 J-.469 E.34331
G1 X110.231 Y110.6 E.00782
G3 X112.649 Y112.96 I.059 J2.358 E.12491
G1 X112.626 Y113.201 E.00802
M204 S10000
G1 X112.217 Y113.22 F42000
G1 F15476.087
M204 S6000
G1 X112.202 Y113.347 E.00423
G3 X110.047 Y111.022 I-1.913 J-.388 E.28404
G1 X110.241 Y111.008 E.00647
G3 X112.241 Y112.96 I.049 J1.951 E.10334
G1 X112.222 Y113.16 E.00667
M204 S250
G1 X111.828 Y113.181 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.818 Y113.269 E.00271
G3 X110.096 Y111.412 I-1.528 J-.31 E.21022
G1 X110.251 Y111.4 E.00478
G3 X111.849 Y112.96 I.039 J1.559 E.07648
G1 X111.834 Y113.121 E.00498
; WIPE_START
M204 S6000
G1 X111.818 Y113.269 E-.05635
G1 X111.728 Y113.566 E-.11808
G1 X111.579 Y113.839 E-.118
G1 X111.409 Y114.046 E-.10166
G1 X111.201 Y114.227 E-.10503
G1 X110.932 Y114.382 E-.11808
G1 X110.637 Y114.481 E-.11806
G1 X110.572 Y114.489 E-.02474
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X110.93 Y106.865 Z1.2 F42000
G1 X111.973 Y84.666 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X111.672 Y84.875 E.01214
G3 X109.945 Y79.734 I-1.382 J-2.396 E.32482
G1 X110.221 Y79.713 E.00917
G3 X112.072 Y84.594 I.069 J2.765 E.22634
G1 X112.021 Y84.631 E.00207
M204 S10000
G1 X111.739 Y84.335 F42000
G1 F15476.087
M204 S6000
G1 X111.469 Y84.522 E.01091
G3 X109.996 Y80.138 I-1.179 J-2.043 E.27699
G1 X110.231 Y80.12 E.00782
G3 X111.81 Y84.283 I.059 J2.358 E.193
G1 X111.787 Y84.299 E.00093
M204 S10000
G1 X111.505 Y84.003 F42000
G1 F15476.087
M204 S6000
G1 X111.265 Y84.169 E.00967
G3 X110.047 Y80.542 I-.975 J-1.691 E.22917
G1 X110.241 Y80.528 E.00647
G3 X111.552 Y83.967 I.049 J1.951 E.15945
M204 S250
G1 X111.279 Y83.684 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.069 Y83.83 E.00787
G3 X110.096 Y80.932 I-.779 J-1.351 E.16961
G1 X110.251 Y80.92 E.00479
G3 X111.325 Y83.645 I.039 J1.559 E.11693
; WIPE_START
M204 S6000
G1 X111.069 Y83.83 E-.12001
G1 X110.787 Y83.959 E-.11799
G1 X110.484 Y84.028 E-.11796
G1 X110.173 Y84.036 E-.11808
G1 X109.867 Y83.982 E-.11812
G1 X109.578 Y83.868 E-.11807
G1 X109.468 Y83.797 E-.04978
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X116.963 Y82.356 Z1.2 F42000
G1 X121.854 Y81.416 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.295 Y81.416 E.71125
G2 X148.405 Y81.416 I2.555 J1.064 E.36082
G1 X159.854 Y81.416 E.37979
G1 X159.854 Y127.471 E1.52774
G1 X159.664 Y127.515 E.00646
G2 X159.664 Y129.485 I-2.588 J.985 E.51036
G1 X159.854 Y129.529 E.00646
G1 X159.854 Y211.084 E2.70534
G1 X136.486 Y211.084 E.77516
G1 X136.437 Y210.903 E.00622
G2 X132.658 Y207.13 I-1.373 J-2.404 E.33754
G1 X132.486 Y207.076 E.00598
G1 X132.486 Y123.284 E2.77955
G1 X100.088 Y123.284 E1.0747
G1 X100.05 Y123.085 E.00671
G2 X96.658 Y119.13 I-.986 J-2.586 E.35176
G1 X96.486 Y119.076 E.00598
G1 X96.486 Y75.915 E1.43174
G1 X96.664 Y75.865 E.00614
G2 X96.664 Y73.135 I2.406 J-1.365 E.48187
G1 X96.486 Y73.085 E.00614
G1 X96.486 Y44.916 E.93441
G1 X141.154 Y44.916 E1.48171
G1 X141.154 Y47.584 E.08849
G1 X137.154 Y47.584 E.13269
G1 X137.154 Y65.916 E.60812
G1 X141.154 Y65.916 E.13269
G1 X141.154 Y69.084 E.10507
G1 X121.854 Y69.084 E.64022
G1 X121.854 Y81.356 E.4071
; WIPE_START
G1 X123.854 Y81.362 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.46 Y88.97 Z1.2 F42000
G1 X133.826 Y206.501 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X133.89 Y206.456 E.00258
G3 X134.776 Y206.158 I1.18 J2.042 E.03122
G1 X135.011 Y206.14 E.00782
G3 X133.508 Y206.731 I.059 J2.358 E.43699
G1 X133.778 Y206.536 E.01102
M204 S10000
G1 X134.063 Y206.831 F42000
G1 F15476.087
M204 S6000
G1 X134.094 Y206.809 E.00124
G3 X134.827 Y206.562 I.976 J1.69 E.02583
G1 X135.021 Y206.548 E.00647
G3 X133.778 Y207.036 I.049 J1.951 E.36153
G1 X134.014 Y206.866 E.00967
M204 S250
G1 X134.29 Y207.149 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G3 X134.876 Y206.952 I.78 J1.35 E.01912
G1 X135.031 Y206.94 E.00478
G3 X134.239 Y207.18 I.039 J1.559 E.2753
; WIPE_START
M204 S6000
G1 X134.573 Y207.021 E-.14076
G1 X134.876 Y206.952 E-.11795
G1 X135.031 Y206.94 E-.05915
G1 X135.341 Y206.963 E-.11805
G1 X135.64 Y207.048 E-.11808
G1 X135.916 Y207.189 E-.11814
G1 X136.097 Y207.334 E-.08787
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.664 Y209.865 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X132.783 Y210.059 E.00756
G2 X133.703 Y210.903 I2.325 J-1.611 E.04174
G1 X133.654 Y211.084 E.00622
G1 X132.486 Y211.084 E.03874
G1 X132.486 Y209.915 E.03877
G1 X132.606 Y209.881 E.00415
; WIPE_START
G1 X132.783 Y210.059 E-.09528
G1 X132.949 Y210.279 E-.10478
G1 X133.137 Y210.482 E-.105
G1 X133.344 Y210.664 E-.10477
G1 X133.703 Y210.903 E-.16365
G1 X133.654 Y211.084 E-.07121
G1 X133.351 Y211.084 E-.1153
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.702 Y203.479 Z1.2 F42000
G1 X122.261 Y81.009 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X143.986 Y81.009 E.72066
G2 X144.041 Y83.997 I1.948 J1.458 E.10674
G2 X147.923 Y81.351 I1.801 J-1.528 E.22966
G1 X147.714 Y81.009 E.0133
G1 X160.261 Y81.009 E.4162
G1 X160.261 Y211.491 E4.32832
G1 X132.079 Y211.491 E.93484
G1 X132.079 Y123.691 E2.91249
G1 X96.079 Y123.691 E1.19419
G1 X96.079 Y44.509 E2.6266
G1 X141.561 Y44.509 E1.50871
G1 X141.561 Y47.991 E.1155
G1 X137.561 Y47.991 E.13269
G1 X137.561 Y65.509 E.58111
G1 X141.561 Y65.509 E.13269
G1 X141.561 Y69.491 E.13208
G1 X122.261 Y69.491 E.64022
G1 X122.261 Y80.949 E.38009
M204 S10000
G1 X122.668 Y80.602 F42000
G1 F15476.087
M204 S6000
G1 X144.84 Y80.602 E.73549
G1 X144.891 Y80.777 E.00606
G2 X146.811 Y80.783 I.955 J1.698 E.33942
G1 X146.86 Y80.602 E.00622
G1 X160.668 Y80.602 E.45803
G1 X160.668 Y211.898 E4.35533
G1 X131.672 Y211.898 E.96185
G1 X131.672 Y124.098 E2.91249
G1 X95.672 Y124.098 E1.19419
G1 X95.672 Y44.102 E2.65361
G1 X141.968 Y44.102 E1.53572
G1 X141.968 Y48.398 E.1425
G1 X137.968 Y48.398 E.13269
G1 X137.968 Y65.102 E.55411
G1 X141.968 Y65.102 E.13269
G1 X141.968 Y69.898 E.15909
G1 X122.668 Y69.898 E.64022
G1 X122.668 Y80.542 E.35309
M204 S250
G1 X123.06 Y80.21 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X161.06 Y80.21 E1.16763
G1 X161.06 Y212.29 E4.05845
G1 X131.28 Y212.29 E.91506
G1 X131.28 Y124.49 E2.69785
G1 X95.28 Y124.49 E1.10618
G1 X95.28 Y43.71 E2.48214
G1 X142.36 Y43.71 E1.44664
G1 X142.36 Y48.79 E.15609
G1 X138.36 Y48.79 E.12291
G1 X138.36 Y64.71 E.48918
G1 X142.36 Y64.71 E.12291
G1 X142.36 Y70.29 E.17146
G1 X123.06 Y70.29 E.59304
G1 X123.06 Y80.15 E.30297
; WIPE_START
M204 S6000
G1 X125.06 Y80.153 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 80
M625
; object ids of layer 4 start: 80,91,102,113,124
M624 HwAAAAAAAAA=
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


; object ids of this layer4 end: 80,91,102,113,124
M625
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X140.285 Y68.92 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X140.82 Y68.385 E.0233
G1 X140.82 Y67.851 E.01641
G1 X139.921 Y68.751 E.03913
G1 X139.387 Y68.751 E.01641
G1 X140.82 Y67.317 E.06234
M73 P47 R17
G1 X140.82 Y66.784 E.01641
G1 X138.853 Y68.751 E.08555
G1 X138.32 Y68.751 E.01641
G1 X140.82 Y66.249 E.10877
G1 X140.287 Y66.249 E.0164
G1 X137.786 Y68.751 E.10878
G1 X137.252 Y68.751 E.01641
G1 X139.754 Y66.249 E.10878
G1 X139.22 Y66.249 E.01641
G1 X136.719 Y68.751 E.10878
G1 X136.185 Y68.751 E.01641
G1 X138.686 Y66.249 E.10878
G1 X138.152 Y66.249 E.01641
G1 X135.651 Y68.751 E.10878
G1 X135.118 Y68.751 E.01641
G1 X137.619 Y66.249 E.10878
G1 X137.085 Y66.249 E.01641
G1 X134.584 Y68.751 E.10878
G1 X134.05 Y68.751 E.01641
G1 X136.82 Y65.98 E.12048
G1 X136.82 Y65.447 E.01641
G1 X133.516 Y68.751 E.14369
G1 X132.983 Y68.751 E.01641
G1 X136.82 Y64.913 E.1669
G1 X136.82 Y64.379 E.01641
G1 X132.449 Y68.751 E.19011
G1 X131.915 Y68.751 E.01641
G1 X136.82 Y63.846 E.21332
G1 X136.82 Y63.312 E.01641
G1 X131.382 Y68.751 E.23653
G1 X130.848 Y68.751 E.01641
G1 X136.82 Y62.778 E.25974
G1 X136.82 Y62.244 E.01641
G1 X130.314 Y68.751 E.28295
G1 X129.781 Y68.751 E.01641
G1 X136.82 Y61.711 E.30616
G1 X136.82 Y61.177 E.01641
G1 X129.247 Y68.751 E.32937
G1 X128.713 Y68.751 E.01641
G1 X136.82 Y60.643 E.35258
G1 X136.82 Y60.11 E.01641
G1 X128.179 Y68.751 E.37579
G1 X127.646 Y68.751 E.01641
G1 X136.82 Y59.576 E.399
G1 X136.82 Y59.042 E.01641
G1 X127.112 Y68.751 E.42221
G1 X126.578 Y68.751 E.01641
G1 X136.82 Y58.509 E.44542
G1 X136.82 Y57.975 E.01641
G1 X126.045 Y68.751 E.46863
G1 X125.511 Y68.751 E.01641
G1 X136.82 Y57.441 E.49184
G1 X136.82 Y56.907 E.01641
G1 X124.977 Y68.751 E.51505
G1 X124.444 Y68.751 E.01641
G1 X136.82 Y56.374 E.53826
G1 X136.82 Y55.84 E.01641
G1 X123.91 Y68.751 E.56147
G1 X123.376 Y68.751 E.01641
G1 X136.82 Y55.306 E.58468
G1 X136.82 Y54.773 E.01641
G1 X122.842 Y68.751 E.60789
G1 X122.309 Y68.751 E.01641
G1 X136.82 Y54.239 E.6311
G1 X136.82 Y53.705 E.01641
G1 X111.05 Y79.476 E1.12076
G3 X111.453 Y79.606 I-1.047 J3.93 E.01304
G1 X121.52 Y69.539 E.43783
G1 X121.52 Y70.073 E.01641
G1 X111.811 Y79.782 E.42224
G3 X112.135 Y79.992 I-.888 J1.724 E.01189
G1 X121.52 Y70.606 E.40816
G1 X121.52 Y71.14 E.01641
G1 X112.426 Y80.234 E.3955
G3 X112.684 Y80.51 I-3.687 J3.696 E.01161
G1 X121.52 Y71.674 E.3843
G1 X121.52 Y72.207 E.01641
G1 X112.907 Y80.821 E.37461
G3 X113.095 Y81.166 I-1.629 J1.116 E.01211
G1 X121.52 Y72.741 E.3664
G1 X121.52 Y73.275 E.01641
G1 X113.247 Y81.548 E.3598
G3 X113.347 Y81.982 I-3.962 J1.145 E.01369
G1 X121.52 Y73.809 E.35544
G1 X121.52 Y74.342 E.01641
G1 X113.391 Y82.472 E.35355
G3 X113.335 Y83.062 I-4.297 J-.111 E.01824
G1 X121.52 Y74.876 E.35599
G1 X121.52 Y75.41 E.01641
G1 X96.819 Y100.111 E1.07425
G1 X96.819 Y100.645 E.01641
G1 X121.52 Y75.943 E1.07425
G1 X121.52 Y76.477 E.01641
G1 X96.819 Y101.178 E1.07424
G1 X96.819 Y101.712 E.01641
G1 X121.52 Y77.011 E1.07425
G1 X121.52 Y77.544 E.01641
G1 X96.819 Y102.246 E1.07424
G1 X96.819 Y102.779 E.01641
G1 X121.52 Y78.078 E1.07424
G1 X121.52 Y78.612 E.01641
G1 X96.819 Y103.313 E1.07424
G1 X96.819 Y103.847 E.01641
G1 X121.52 Y79.146 E1.07424
G1 X121.52 Y79.679 E.01641
G1 X96.819 Y104.38 E1.07424
G1 X96.819 Y104.914 E.01641
G1 X121.52 Y80.213 E1.07424
G1 X121.52 Y80.747 E.01641
G1 X96.819 Y105.448 E1.07424
G1 X96.819 Y105.982 E.01641
G1 X121.52 Y81.28 E1.07424
G1 X121.52 Y81.749 E.01443
G1 X121.585 Y81.749 E.00199
G1 X96.819 Y106.515 E1.07705
G1 X96.819 Y107.049 E.01641
G1 X122.119 Y81.749 E1.10027
G1 X122.652 Y81.749 E.01641
G1 X96.819 Y107.583 E1.12348
G1 X96.819 Y108.116 E.01641
G1 X123.186 Y81.749 E1.14669
G1 X123.72 Y81.749 E.01641
G1 X96.819 Y108.65 E1.1699
G1 X96.819 Y109.184 E.01641
G1 X124.254 Y81.749 E1.19311
G1 X124.787 Y81.749 E.01641
G1 X96.819 Y109.717 E1.21632
G1 X96.819 Y110.251 E.01641
G1 X125.321 Y81.749 E1.23953
G1 X125.855 Y81.749 E.01641
G1 X96.819 Y110.785 E1.26274
G1 X96.819 Y111.319 E.01641
G1 X126.388 Y81.749 E1.28595
G1 X126.922 Y81.749 E.01641
G1 X96.819 Y111.852 E1.30916
G1 X96.819 Y112.386 E.01641
G1 X127.456 Y81.749 E1.33237
G1 X127.989 Y81.749 E.01641
G1 X96.819 Y112.92 E1.35558
G1 X96.819 Y113.453 E.01641
G1 X128.523 Y81.749 E1.37879
G1 X129.057 Y81.749 E.01641
G1 X96.819 Y113.987 E1.402
G1 X96.819 Y114.521 E.01641
G1 X129.591 Y81.749 E1.42521
G1 X130.124 Y81.749 E.01641
G1 X96.819 Y115.054 E1.44842
G1 X96.819 Y115.588 E.01641
G1 X130.658 Y81.749 E1.47163
G1 X131.192 Y81.749 E.01641
G1 X96.819 Y116.122 E1.49484
G1 X96.819 Y116.655 E.01641
G1 X131.725 Y81.749 E1.51805
G1 X132.259 Y81.749 E.01641
G1 X96.819 Y117.189 E1.54126
G1 X96.819 Y117.723 E.01641
G1 X132.793 Y81.749 E1.56447
G1 X133.326 Y81.749 E.01641
G1 X96.913 Y118.162 E1.58358
G1 X96.97 Y118.221 E.0025
G3 X98.028 Y117.581 I2.137 J2.341 E.03827
M73 P47 R16
G1 X133.86 Y81.749 E1.5583
G1 X134.394 Y81.749 E.01641
G1 X98.724 Y117.42 E1.55128
G3 X99.27 Y117.406 I.34 J2.72 E.01685
G1 X134.927 Y81.749 E1.5507
G1 X135.461 Y81.749 E.01641
G1 X99.736 Y117.475 E1.55367
G3 X100.149 Y117.595 I-.394 J2.126 E.01326
G1 X135.995 Y81.749 E1.5589
G1 X136.529 Y81.749 E.01641
G1 X100.393 Y117.885 E1.57151
; WIPE_START
G1 X101.807 Y116.471 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.812 Y118.535 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.106221
G1 F15000
M204 S6000
G1 X96.69 Y118.655 E.00088
M204 S10000
G1 X96.758 Y119.374 F42000
; LINE_WIDTH: 0.434143
G1 F15000
M204 S6000
G1 X96.487 Y119.504 E.00959
; LINE_WIDTH: 0.436675
G1 X96.471 Y119.599 E.00306
; LINE_WIDTH: 0.401876
G1 X96.453 Y119.708 E.00325
; LINE_WIDTH: 0.368156
G1 X96.437 Y119.833 E.00333
; LINE_WIDTH: 0.335201
G1 X96.42 Y119.971 E.00332
; LINE_WIDTH: 0.298451
G1 X96.401 Y120.239 E.00559
; LINE_WIDTH: 0.272609
G1 X96.401 Y120.773 E.01
; LINE_WIDTH: 0.30037
G1 X96.422 Y121.043 E.00567
; LINE_WIDTH: 0.33726
G1 X96.438 Y121.17 E.00309
; LINE_WIDTH: 0.371503
G1 X96.456 Y121.315 E.00391
; LINE_WIDTH: 0.405943
G1 X96.49 Y121.504 E.00567
; LINE_WIDTH: 0.436848
G1 X96.523 Y121.693 E.00616
M204 S10000
G1 X96.705 Y122.329 F42000
; LINE_WIDTH: 0.160467
G1 F15000
M204 S6000
G1 X96.979 Y123.08 E.00766
M204 S10000
G1 X97.006 Y123.08 F42000
; LINE_WIDTH: 0.402993
G1 F15000
M204 S6000
G1 X96.691 Y122.334 E.02378
M204 S10000
G1 X96.69 Y122.783 F42000
; LINE_WIDTH: 0.331325
G1 F15000
M204 S6000
G1 X97.524 Y123.075 E.02078
M204 S10000
G1 X97.528 Y123.063 F42000
; LINE_WIDTH: 0.134204
G1 F15000
M204 S6000
G1 X96.69 Y122.815 E.0065
; WIPE_START
G1 X97.528 Y123.063 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X98.271 Y123.219 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; LINE_WIDTH: 0.517755
G1 F13267.768
M204 S6000
G1 X98.573 Y123.253 E.01175
; LINE_WIDTH: 0.479715
G1 F14423.268
G2 X99.406 Y123.265 I.507 J-6.22 E.02967
; LINE_WIDTH: 0.506078
G1 F13602.284
G2 X99.87 Y123.225 I-.569 J-9.307 E.01759
M204 S10000
G1 X100.655 Y123.08 F42000
; LINE_WIDTH: 0.117726
G1 F15000
M204 S6000
G1 X100.88 Y122.884 E.00182
M204 S10000
G1 X104.23 Y123.12 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X111.562 Y115.788 E.31886
G3 X110.802 Y116.015 I-1.322 J-3.044 E.02447
G1 X103.866 Y122.951 E.30162
G1 X103.333 Y122.951 E.01641
G1 X110.226 Y116.057 E.2998
G3 X109.738 Y116.011 I.136 J-4.085 E.01508
G1 X102.799 Y122.951 E.30178
G1 X102.265 Y122.951 E.01641
G1 X109.315 Y115.9 E.30661
G3 X108.935 Y115.747 I.574 J-1.972 E.01263
G1 X101.732 Y122.951 E.31328
G1 X101.399 Y122.951 E.01022
G1 X101.302 Y122.847 E.00438
G1 X108.593 Y115.555 E.31709
G3 X108.289 Y115.326 I.996 J-1.635 E.01174
G1 X101.938 Y121.677 E.27621
G2 X102.135 Y120.946 I-3.026 J-1.209 E.02334
G1 X108.017 Y115.064 E.25578
G3 X107.776 Y114.772 I1.342 J-1.348 E.01168
G1 X102.165 Y120.382 E.244
G2 X102.112 Y119.901 I-2.43 J.026 E.01489
G1 X107.568 Y114.446 E.23725
G3 X107.401 Y114.079 I4.642 J-2.334 E.0124
G1 X101.996 Y119.484 E.23503
G2 X101.838 Y119.108 I-1.956 J.605 E.01255
G1 X107.275 Y113.672 E.23644
G3 X107.201 Y113.212 I3.441 J-.787 E.01434
G1 X101.643 Y118.77 E.24172
G2 X101.411 Y118.468 I-4.254 J3.038 E.0117
G1 X107.202 Y112.677 E.25189
G3 X107.344 Y112.001 I2.134 J.095 E.0213
G1 X101.145 Y118.2 E.26958
G2 X100.848 Y117.963 I-1.331 J1.365 E.0117
G1 X137.062 Y81.749 E1.57493
G1 X137.596 Y81.749 E.01641
G1 X109.334 Y110.011 E1.22908
G3 X110.004 Y109.875 I.991 J3.166 E.02104
G1 X138.13 Y81.749 E1.22317
G1 X138.663 Y81.749 E.01641
G1 X110.543 Y109.87 E1.22294
M73 P48 R16
G3 X111.001 Y109.945 I-.145 J2.32 E.01431
G1 X139.197 Y81.749 E1.22622
G1 X139.731 Y81.749 E.01641
G1 X111.411 Y110.069 E1.2316
G3 X111.774 Y110.24 I-1.888 J4.473 E.01233
G1 X140.264 Y81.749 E1.23904
G1 X140.798 Y81.749 E.01641
G1 X112.101 Y110.447 E1.24804
G3 X112.395 Y110.686 I-1.051 J1.591 E.01169
G1 X141.332 Y81.749 E1.25845
G1 X141.866 Y81.749 E.01641
G1 X112.657 Y110.957 E1.27024
G3 X112.884 Y111.265 I-4.228 J3.356 E.01174
G1 X142.399 Y81.749 E1.2836
G1 X142.839 Y81.749 E.01353
G2 X142.809 Y81.874 I.604 J.216 E.00395
G1 X113.076 Y111.606 E1.29305
G3 X113.231 Y111.985 I-1.812 J.965 E.0126
G1 X142.749 Y82.467 E1.2837
G2 X142.79 Y82.96 I4.098 J-.089 E.01522
G1 X113.34 Y112.41 E1.28076
G3 X113.388 Y112.895 I-2.398 J.485 E.01502
G1 X142.887 Y83.396 E1.28288
G2 X143.037 Y83.78 I1.992 J-.562 E.01268
G1 X113.345 Y113.472 E1.29129
G3 X113.112 Y114.238 I-2.388 J-.307 E.02476
G1 X143.225 Y84.126 E1.30959
G2 X143.447 Y84.438 I1.678 J-.956 E.01179
G1 X104.934 Y122.951 E1.6749
G1 X105.468 Y122.951 E.01641
G1 X143.702 Y84.716 E1.6628
G2 X143.992 Y84.96 I1.363 J-1.329 E.01167
G1 X106.001 Y122.951 E1.65221
G1 X106.535 Y122.951 E.01641
G1 X144.315 Y85.171 E1.64303
G2 X144.672 Y85.347 I1.058 J-1.694 E.01227
G1 X107.069 Y122.951 E1.63536
G1 X107.602 Y122.951 E.01641
G1 X145.073 Y85.48 E1.62958
G2 X145.525 Y85.561 I.632 J-2.218 E.01416
G1 X108.136 Y122.951 E1.62604
G1 X108.67 Y122.951 E.01641
G1 X146.049 Y85.571 E1.6256
G2 X146.693 Y85.461 I-.202 J-3.107 E.02015
G1 X109.034 Y123.12 E1.6378
M204 S10000
G1 X96.65 Y99.747 F42000
G1 F15000
M204 S6000
G1 X110.874 Y85.522 E.61861
G3 X110.284 Y85.579 I-.601 J-3.196 E.01824
G1 X96.819 Y99.044 E.58558
G1 X96.819 Y98.51 E.01641
G1 X109.79 Y85.539 E.56408
G3 X109.36 Y85.435 I.683 J-3.768 E.01361
G1 X96.819 Y97.976 E.54539
G1 X96.819 Y97.442 E.01641
G1 X108.976 Y85.286 E.52869
G3 X108.63 Y85.098 I.761 J-1.821 E.01213
G1 X96.819 Y96.909 E.51363
G1 X96.819 Y96.375 E.01641
G1 X108.321 Y84.874 E.50019
G3 X108.045 Y84.615 I1.156 J-1.507 E.01163
G1 X96.819 Y95.841 E.48822
G1 X96.819 Y95.308 E.01641
G1 X107.802 Y84.325 E.47762
G3 X107.59 Y84.003 I1.509 J-1.22 E.01187
G1 X96.819 Y94.774 E.46842
G1 X96.819 Y94.24 E.01641
G1 X107.417 Y83.643 E.46087
G3 X107.287 Y83.239 I1.954 J-.852 E.01306
G1 X96.819 Y93.707 E.45522
G1 X96.819 Y93.173 E.01641
G1 X107.204 Y82.788 E.45162
G3 X107.199 Y82.259 I2.636 J-.286 E.01631
G1 X96.819 Y92.639 E.45143
G1 X96.819 Y92.105 E.01641
G1 X107.315 Y81.61 E.45645
G3 X109.417 Y79.508 I3.01 J.908 E.09522
G1 X136.82 Y52.104 E1.19176
G1 X136.82 Y52.638 E.01641
G1 X110.068 Y79.39 E1.16345
G3 X110.596 Y79.396 I.226 J3.257 E.01624
G1 X136.99 Y53.002 E1.14788
; WIPE_START
G1 X135.576 Y54.416 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X139.931 Y48.148 Z1.2 F42000
G1 X140.437 Y47.42 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X140.82 Y47.037 E.01668
G1 X140.82 Y46.503 E.01641
G1 X140.073 Y47.251 E.03251
G1 X139.539 Y47.251 E.01641
G1 X140.82 Y45.969 E.05572
G1 X140.82 Y45.436 E.01641
G1 X139.006 Y47.251 E.07893
G1 X138.472 Y47.251 E.01641
G1 X140.473 Y45.249 E.08703
G1 X139.939 Y45.249 E.01641
G1 X137.938 Y47.251 E.08703
G1 X137.404 Y47.251 E.01641
G1 X139.406 Y45.249 E.08703
G1 X138.872 Y45.249 E.01641
G1 X96.819 Y87.302 E1.82886
G1 X96.819 Y87.836 E.01641
G1 X136.82 Y47.835 E1.73963
G1 X136.82 Y48.368 E.01641
G1 X96.819 Y88.37 E1.73963
G1 X96.819 Y88.903 E.01641
G1 X136.82 Y48.902 E1.73963
G1 X136.82 Y49.436 E.01641
G1 X96.819 Y89.437 E1.73963
G1 X96.819 Y89.971 E.01641
G1 X136.82 Y49.969 E1.73963
G1 X136.82 Y50.503 E.01641
G1 X96.819 Y90.504 E1.73963
G1 X96.819 Y91.038 E.01641
G1 X136.82 Y51.037 E1.73963
G1 X136.82 Y51.57 E.01641
G1 X96.65 Y91.741 E1.74701
M204 S10000
G1 X96.65 Y86.938 F42000
G1 F15000
M204 S6000
G1 X138.338 Y45.249 E1.81302
G1 X137.805 Y45.249 E.01641
G1 X96.819 Y86.235 E1.78243
G1 X96.819 Y85.701 E.01641
G1 X137.271 Y45.249 E1.75922
G1 X136.737 Y45.249 E.01641
G1 X96.819 Y85.167 E1.73601
G1 X96.819 Y84.634 E.01641
G1 X136.204 Y45.249 E1.7128
G1 X135.67 Y45.249 E.01641
G1 X96.819 Y84.1 E1.68959
G1 X96.819 Y83.566 E.01641
G1 X135.136 Y45.249 E1.66638
G1 X134.602 Y45.249 E.01641
G1 X96.819 Y83.033 E1.64317
G1 X96.819 Y82.499 E.01641
G1 X134.069 Y45.249 E1.61996
G1 X133.535 Y45.249 E.01641
G1 X96.819 Y81.965 E1.59675
G1 X96.819 Y81.432 E.01641
G1 X133.001 Y45.249 E1.57354
G1 X132.468 Y45.249 E.01641
G1 X96.819 Y80.898 E1.55033
G1 X96.819 Y80.364 E.01641
G1 X99.638 Y77.545 E.12259
G3 X99.051 Y77.598 I-.579 J-3.136 E.01814
G1 X96.819 Y79.83 E.09708
G1 X96.819 Y79.297 E.01641
G1 X98.558 Y77.558 E.07563
G3 X98.13 Y77.452 I.742 J-3.923 E.01356
G1 X96.819 Y78.763 E.05701
G1 X96.819 Y78.229 E.01641
G1 X97.747 Y77.302 E.04035
G3 X97.401 Y77.114 I.765 J-1.819 E.01212
G1 X96.819 Y77.696 E.02532
G1 X96.819 Y77.162 E.01641
G1 X97.214 Y76.767 E.01717
M204 S10000
G1 X96.913 Y76.575 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.121765
G1 F15000
M204 S6000
G1 X96.69 Y76.371 E.00194
M204 S10000
G1 X96.523 Y75.693 F42000
; LINE_WIDTH: 0.436841
G1 F15000
M204 S6000
G1 X96.49 Y75.504 E.00616
; LINE_WIDTH: 0.405923
G1 X96.456 Y75.315 E.00568
; LINE_WIDTH: 0.371488
G1 X96.438 Y75.17 E.00391
; LINE_WIDTH: 0.337255
G1 X96.422 Y75.043 E.00309
; LINE_WIDTH: 0.300371
G1 X96.401 Y74.773 E.00567
; LINE_WIDTH: 0.272614
G1 X96.401 Y74.239 E.01
; LINE_WIDTH: 0.298461
G1 X96.42 Y73.971 E.00559
; LINE_WIDTH: 0.335573
G1 X96.438 Y73.83 E.0034
; LINE_WIDTH: 0.369284
G1 X96.454 Y73.702 E.00342
; LINE_WIDTH: 0.404446
G1 X96.49 Y73.496 E.00617
; LINE_WIDTH: 0.436874
G1 X96.523 Y73.307 E.00616
M204 S10000
G1 X96.708 Y72.672 F42000
; LINE_WIDTH: 0.104414
G1 F15000
M204 S6000
G3 X96.767 Y72.577 I.128 J.014 E.00058
G1 X96.802 Y72.544 E.00024
; WIPE_START
G1 X96.767 Y72.577 E-.22562
G1 X96.726 Y72.619 E-.27562
G1 X96.708 Y72.672 E-.25876
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.889 Y75.294 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X131.934 Y45.249 E1.30664
G1 X131.4 Y45.249 E.01641
G1 X102.17 Y74.479 E1.27119
G2 X102.126 Y73.99 I-2.469 J-.021 E.01513
G1 X130.867 Y45.249 E1.24993
G1 X130.333 Y45.249 E.01641
G1 X102.024 Y73.559 E1.23115
G2 X101.871 Y73.177 I-1.985 J.573 E.01265
G1 X129.799 Y45.249 E1.21458
G1 X129.266 Y45.249 E.01641
G1 X101.682 Y72.833 E1.19961
G2 X101.458 Y72.523 I-1.667 J.964 E.01178
G1 X128.732 Y45.249 E1.18611
G1 X128.198 Y45.249 E.01641
G1 X101.199 Y72.248 E1.17416
G2 X100.908 Y72.006 I-1.358 J1.341 E.01167
G1 X127.664 Y45.249 E1.16364
G1 X127.131 Y45.249 E.01641
G1 X100.583 Y71.797 E1.15454
G2 X100.224 Y71.622 I-1.053 J1.71 E.0123
G1 X126.597 Y45.249 E1.14695
G1 X126.063 Y45.249 E.01641
G1 X99.819 Y71.494 E1.14135
G2 X99.364 Y71.415 I-.621 J2.234 E.01422
G1 X125.53 Y45.249 E1.13793
G1 X124.996 Y45.249 E.01641
G1 X98.834 Y71.411 E1.13777
G2 X98.179 Y71.533 I.241 J3.128 E.02053
G1 X124.462 Y45.249 E1.14305
G1 X123.929 Y45.249 E.01641
G1 X96.957 Y72.221 E1.17298
G1 X96.819 Y72.074 E.0062
G1 X96.819 Y71.825 E.00764
G1 X123.395 Y45.249 E1.15576
G1 X122.861 Y45.249 E.01641
G1 X96.819 Y71.291 E1.13255
G1 X96.819 Y70.758 E.01641
G1 X122.327 Y45.249 E1.10934
G1 X121.794 Y45.249 E.01641
G1 X96.819 Y70.224 E1.08613
G1 X96.819 Y69.69 E.01641
G1 X121.26 Y45.249 E1.06292
G1 X120.726 Y45.249 E.01641
G1 X96.819 Y69.157 E1.03971
G1 X96.819 Y68.623 E.01641
G1 X120.193 Y45.249 E1.0165
G1 X119.659 Y45.249 E.01641
G1 X96.819 Y68.089 E.99329
G1 X96.819 Y67.555 E.01641
G1 X119.125 Y45.249 E.97008
G1 X118.592 Y45.249 E.01641
G1 X96.819 Y67.022 E.94687
G1 X96.819 Y66.488 E.01641
G1 X118.058 Y45.249 E.92366
G1 X117.524 Y45.249 E.01641
G1 X96.819 Y65.954 E.90045
G1 X96.819 Y65.421 E.01641
M73 P49 R16
G1 X116.99 Y45.249 E.87724
G1 X116.457 Y45.249 E.01641
G1 X96.819 Y64.887 E.85403
G1 X96.819 Y64.353 E.01641
G1 X115.923 Y45.249 E.83082
G1 X115.389 Y45.249 E.01641
G1 X96.819 Y63.82 E.80761
G1 X96.819 Y63.286 E.01641
G1 X114.856 Y45.249 E.7844
G1 X114.322 Y45.249 E.01641
G1 X96.819 Y62.752 E.76119
G1 X96.819 Y62.218 E.01641
G1 X113.788 Y45.249 E.73798
G1 X113.255 Y45.249 E.01641
G1 X96.819 Y61.685 E.71477
G1 X96.819 Y61.151 E.01641
G1 X112.721 Y45.249 E.69156
G1 X112.187 Y45.249 E.01641
G1 X96.819 Y60.617 E.66835
G1 X96.819 Y60.084 E.01641
G1 X111.654 Y45.249 E.64514
G1 X111.12 Y45.249 E.01641
G1 X96.819 Y59.55 E.62193
G1 X96.819 Y59.016 E.01641
G1 X110.586 Y45.249 E.59872
G1 X110.052 Y45.249 E.01641
G1 X96.819 Y58.483 E.57551
G1 X96.819 Y57.949 E.01641
G1 X109.519 Y45.249 E.5523
G1 X108.985 Y45.249 E.01641
G1 X96.819 Y57.415 E.52909
G1 X96.819 Y56.882 E.01641
G1 X108.451 Y45.249 E.50588
G1 X107.918 Y45.249 E.01641
G1 X96.819 Y56.348 E.48267
G1 X96.819 Y55.814 E.01641
G1 X107.384 Y45.249 E.45946
G1 X106.85 Y45.249 E.01641
G1 X96.819 Y55.28 E.43625
G1 X96.819 Y54.747 E.01641
G1 X106.317 Y45.249 E.41304
G1 X105.783 Y45.249 E.01641
G1 X96.819 Y54.213 E.38983
G1 X96.819 Y53.679 E.01641
G1 X105.249 Y45.249 E.36662
G1 X104.715 Y45.249 E.01641
G1 X96.819 Y53.146 E.34341
G1 X96.819 Y52.612 E.01641
G1 X104.182 Y45.249 E.3202
G1 X103.648 Y45.249 E.01641
G1 X96.819 Y52.078 E.29699
G1 X96.819 Y51.545 E.01641
G1 X103.114 Y45.249 E.27378
G1 X102.581 Y45.249 E.01641
G1 X96.819 Y51.011 E.25057
G1 X96.819 Y50.477 E.01641
G1 X102.047 Y45.249 E.22736
G1 X101.513 Y45.249 E.01641
G1 X96.819 Y49.943 E.20415
G1 X96.819 Y49.41 E.01641
G1 X100.98 Y45.249 E.18093
G1 X100.446 Y45.249 E.01641
G1 X96.819 Y48.876 E.15772
G1 X96.819 Y48.342 E.01641
G1 X99.912 Y45.249 E.13451
G1 X99.379 Y45.249 E.01641
G1 X96.819 Y47.809 E.1113
G1 X96.819 Y47.275 E.01641
G1 X98.845 Y45.249 E.08809
G1 X98.311 Y45.249 E.01641
G1 X96.819 Y46.741 E.06488
G1 X96.819 Y46.208 E.01641
G1 X97.777 Y45.249 E.04167
G1 X97.244 Y45.249 E.01641
G1 X96.65 Y45.844 E.02584
; WIPE_START
G1 X97.244 Y45.249 E-.31935
G1 X97.777 Y45.249 E-.2028
G1 X97.335 Y45.692 E-.23785
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X103.436 Y50.278 Z1.2 F42000
G1 X144.274 Y80.974 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.113037
G1 F15000
M204 S6000
G1 X144.374 Y80.85 E.00091
G1 X144.443 Y80.824 E.00042
M204 S10000
G1 X145.124 Y80.871 F42000
; LINE_WIDTH: 0.382735
G1 F15000
M204 S6000
G1 X145.242 Y80.644 E.0071
; LINE_WIDTH: 0.412392
G1 X145.251 Y80.627 E.00056
; LINE_WIDTH: 0.439041
G1 X145.26 Y80.611 E.0006
; LINE_WIDTH: 0.42936
G1 X145.427 Y80.588 E.00531
; LINE_WIDTH: 0.374628
G1 X145.81 Y80.565 E.01036
G1 X146.176 Y80.579 E.00991
; LINE_WIDTH: 0.409247
G1 X146.369 Y80.6 E.00578
; LINE_WIDTH: 0.444215
G3 X146.645 Y80.645 I-.765 J5.614 E.00917
M204 S10000
G1 X147.288 Y80.806 F42000
; LINE_WIDTH: 0.113533
G1 F15000
M204 S6000
G1 X147.428 Y80.978 E.00128
; WIPE_START
G1 X147.288 Y80.806 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.773 Y82.313 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X149.337 Y81.749 E.02453
G1 X149.871 Y81.749 E.01641
G1 X148.941 Y82.679 E.04042
G3 X148.832 Y83.322 I-3.215 J-.216 E.0201
G1 X150.405 Y81.749 E.0684
G1 X150.938 Y81.749 E.01641
G1 X109.737 Y122.951 E1.79182
G1 X110.271 Y122.951 E.01641
G1 X151.472 Y81.749 E1.79182
G1 X152.006 Y81.749 E.01641
G1 X110.804 Y122.951 E1.79182
G1 X111.338 Y122.951 E.01641
G1 X152.539 Y81.749 E1.79182
G1 X153.073 Y81.749 E.01641
G1 X111.872 Y122.951 E1.79182
G1 X112.406 Y122.951 E.01641
G1 X153.607 Y81.749 E1.79182
G1 X154.141 Y81.749 E.01641
G1 X112.939 Y122.951 E1.79182
G1 X113.473 Y122.951 E.01641
G1 X154.674 Y81.749 E1.79182
G1 X155.208 Y81.749 E.01641
G1 X114.007 Y122.951 E1.79182
G1 X114.54 Y122.951 E.01641
G1 X155.742 Y81.749 E1.79182
G1 X156.275 Y81.749 E.01641
G1 X115.074 Y122.951 E1.79182
G1 X115.608 Y122.951 E.01641
G1 X156.809 Y81.749 E1.79182
G1 X157.343 Y81.749 E.01641
G1 X116.141 Y122.951 E1.79182
G1 X116.675 Y122.951 E.01641
G1 X157.876 Y81.749 E1.79182
G1 X158.41 Y81.749 E.01641
G1 X117.209 Y122.951 E1.79182
G1 X117.743 Y122.951 E.01641
G1 X158.944 Y81.749 E1.79182
G1 X159.477 Y81.749 E.01641
G1 X118.276 Y122.951 E1.79182
G1 X118.81 Y122.951 E.01641
G1 X159.52 Y82.24 E1.77048
G1 X159.52 Y82.774 E.01641
G1 X119.344 Y122.951 E1.74727
G1 X119.877 Y122.951 E.01641
G1 X159.52 Y83.307 E1.72406
G1 X159.52 Y83.841 E.01641
G1 X120.411 Y122.951 E1.70085
G1 X120.945 Y122.951 E.01641
G1 X159.52 Y84.375 E1.67764
G1 X159.52 Y84.909 E.01641
G1 X121.478 Y122.951 E1.65443
G1 X122.012 Y122.951 E.01641
G1 X159.52 Y85.442 E1.63122
G1 X159.52 Y85.976 E.01641
G1 X122.546 Y122.951 E1.60801
G1 X123.079 Y122.951 E.01641
G1 X159.52 Y86.51 E1.5848
G1 X159.52 Y87.043 E.01641
G1 X123.613 Y122.951 E1.56159
G1 X124.147 Y122.951 E.01641
G1 X159.52 Y87.577 E1.53838
G1 X159.52 Y88.111 E.01641
G1 X124.681 Y122.951 E1.51517
G1 X125.214 Y122.951 E.01641
G1 X159.52 Y88.644 E1.49196
G1 X159.52 Y89.178 E.01641
G1 X125.748 Y122.951 E1.46875
G1 X126.282 Y122.951 E.01641
G1 X159.52 Y89.712 E1.44554
G1 X159.52 Y90.246 E.01641
G1 X126.815 Y122.951 E1.42233
G1 X127.349 Y122.951 E.01641
G1 X159.52 Y90.779 E1.39912
G1 X159.52 Y91.313 E.01641
G1 X127.883 Y122.951 E1.37591
G1 X128.416 Y122.951 E.01641
G1 X159.52 Y91.847 E1.3527
G1 X159.52 Y92.38 E.01641
G1 X128.95 Y122.951 E1.32949
G1 X129.484 Y122.951 E.01641
G1 X159.52 Y92.914 E1.30628
G1 X159.52 Y93.448 E.01641
G1 X130.018 Y122.951 E1.28307
G1 X130.551 Y122.951 E.01641
G1 X159.52 Y93.981 E1.25986
G1 X159.52 Y94.515 E.01641
G1 X131.085 Y122.951 E1.23665
G1 X131.619 Y122.951 E.01641
G1 X159.52 Y95.049 E1.21344
G1 X159.52 Y95.582 E.01641
G1 X145.168 Y109.935 E.62417
G3 X145.777 Y109.86 I.853 J4.401 E.01888
G1 X159.52 Y96.116 E.59769
G1 X159.52 Y96.65 E.01641
G1 X146.279 Y109.892 E.57589
G3 X146.72 Y109.984 I-.573 J3.825 E.01387
G1 X159.52 Y97.184 E.5567
G1 X159.52 Y97.717 E.01641
G1 X147.108 Y110.129 E.5398
G3 X147.459 Y110.312 I-.739 J1.846 E.01219
G1 X159.52 Y98.251 E.52454
G1 X159.52 Y98.785 E.01641
G1 X147.776 Y110.529 E.51077
G3 X148.056 Y110.783 I-3.627 J4.285 E.01162
G1 X159.52 Y99.318 E.4986
G1 X159.52 Y99.852 E.01641
G1 X148.303 Y111.069 E.48782
G3 X148.519 Y111.387 I-1.485 J1.238 E.01184
G1 X159.52 Y100.386 E.47845
G1 X159.52 Y100.919 E.01641
G1 X148.7 Y111.74 E.47056
G3 X148.837 Y112.137 I-4.1 J1.63 E.01292
G1 X159.52 Y101.453 E.46463
G1 X159.52 Y101.987 E.01641
G1 X148.925 Y112.582 E.46077
G3 X148.945 Y113.096 I-3.284 J.379 E.01585
G1 X159.52 Y102.521 E.45994
G1 X159.52 Y103.054 E.01641
G1 X148.594 Y113.98 E.47517
; WIPE_START
G1 X150.009 Y112.566 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.072 Y112.031 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X132.152 Y122.951 E.47491
G1 X132.686 Y122.951 E.01641
G1 X142.752 Y112.885 E.43777
G2 X142.782 Y113.389 I3.297 J.058 E.01554
G1 X132.819 Y123.351 E.43327
G1 X132.819 Y123.885 E.01641
G1 X142.875 Y113.829 E.43731
G2 X143.018 Y114.219 I3.877 J-1.205 E.01279
M73 P50 R16
G1 X132.819 Y124.419 E.44355
G1 X132.819 Y124.952 E.01641
G1 X143.203 Y114.569 E.45157
G2 X143.421 Y114.884 I1.688 J-.937 E.01181
G1 X132.819 Y125.486 E.46107
G1 X132.819 Y126.02 E.01641
G1 X143.672 Y115.167 E.47198
G2 X143.958 Y115.415 I3.638 J-3.907 E.01164
G1 X132.819 Y126.553 E.48441
G1 X132.819 Y127.087 E.01641
G1 X144.277 Y115.629 E.4983
G2 X144.631 Y115.809 I1.076 J-1.683 E.01223
G1 X132.819 Y127.621 E.5137
G1 X132.819 Y128.154 E.01641
G1 X145.025 Y115.949 E.53081
G2 X145.473 Y116.035 I.652 J-2.194 E.01405
G1 X132.819 Y128.688 E.55029
G1 X132.819 Y129.222 E.01641
G1 X145.985 Y116.056 E.57256
G2 X146.611 Y115.964 I-.177 J-3.365 E.01949
G1 X132.819 Y129.755 E.59979
G1 X132.819 Y130.289 E.01641
G1 X159.52 Y103.588 E1.16122
G1 X159.52 Y104.122 E.01641
G1 X132.819 Y130.823 E1.16122
G1 X132.819 Y131.357 E.01641
G1 X159.52 Y104.655 E1.16122
G1 X159.52 Y105.189 E.01641
G1 X132.819 Y131.89 E1.16122
G1 X132.819 Y132.424 E.01641
G1 X159.52 Y105.723 E1.16122
G1 X159.52 Y106.256 E.01641
G1 X132.819 Y132.958 E1.16122
G1 X132.819 Y133.491 E.01641
G1 X159.52 Y106.79 E1.16122
G1 X159.52 Y107.324 E.01641
G1 X132.819 Y134.025 E1.16122
G1 X132.819 Y134.559 E.01641
G1 X159.52 Y107.857 E1.16122
G1 X159.52 Y108.391 E.01641
G1 X132.819 Y135.092 E1.16122
G1 X132.819 Y135.626 E.01641
G1 X159.52 Y108.925 E1.16122
G1 X159.52 Y109.459 E.01641
G1 X132.819 Y136.16 E1.16122
G1 X132.819 Y136.694 E.01641
G1 X159.52 Y109.992 E1.16122
G1 X159.52 Y110.526 E.01641
G1 X132.819 Y137.227 E1.16122
G1 X132.819 Y137.761 E.01641
G1 X159.52 Y111.06 E1.16122
G1 X159.52 Y111.593 E.01641
G1 X132.819 Y138.295 E1.16122
G1 X132.819 Y138.828 E.01641
G1 X159.52 Y112.127 E1.16122
G1 X159.52 Y112.661 E.01641
G1 X132.819 Y139.362 E1.16122
G1 X132.819 Y139.896 E.01641
G1 X159.52 Y113.194 E1.16122
G1 X159.52 Y113.728 E.01641
G1 X132.819 Y140.429 E1.16122
G1 X132.819 Y140.963 E.01641
G1 X159.52 Y114.262 E1.16122
G1 X159.52 Y114.796 E.01641
G1 X132.819 Y141.497 E1.16122
G1 X132.819 Y142.03 E.01641
G1 X159.52 Y115.329 E1.16122
G1 X159.52 Y115.863 E.01641
G1 X132.819 Y142.564 E1.16122
G1 X132.819 Y143.098 E.01641
G1 X159.52 Y116.397 E1.16122
G1 X159.52 Y116.93 E.01641
G1 X132.819 Y143.632 E1.16122
G1 X132.819 Y144.165 E.01641
G1 X159.52 Y117.464 E1.16122
G1 X159.52 Y117.998 E.01641
G1 X132.819 Y144.699 E1.16122
G1 X132.819 Y145.233 E.01641
G1 X159.52 Y118.531 E1.16122
G1 X159.52 Y119.065 E.01641
G1 X132.819 Y145.766 E1.16122
G1 X132.819 Y146.3 E.01641
G1 X159.52 Y119.599 E1.16122
G1 X159.52 Y120.132 E.01641
G1 X132.819 Y146.834 E1.16122
G1 X132.819 Y147.367 E.01641
G1 X159.52 Y120.666 E1.16122
G1 X159.52 Y121.2 E.01641
G1 X132.65 Y148.071 E1.1686
M204 S10000
G1 X159.505 Y130.242 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.110734
G1 F15000
M204 S6000
G1 X159.65 Y130.067 E.00126
M204 S10000
G1 X159.524 Y129.245 F42000
; LINE_WIDTH: 0.511399
G1 F13447.775
M204 S6000
G1 X159.817 Y129.065 E.01311
G2 X159.839 Y128.766 I-22.031 J-1.796 E.01143
; LINE_WIDTH: 0.472763
G1 F14656.511
G2 X159.838 Y128.212 I-7.969 J-.262 E.01941
; LINE_WIDTH: 0.5124
G1 F13419.12
G2 X159.817 Y127.935 I-6.313 J.345 E.01062
G1 X159.524 Y127.756 E.01314
M204 S10000
G1 X159.65 Y126.905 F42000
; LINE_WIDTH: 0.140595
G1 F15000
M204 S6000
G1 X159.561 Y126.799 E.00111
; LINE_WIDTH: 0.114424
G1 X159.423 Y126.65 E.00118
M204 S10000
G1 X159.69 Y125.833 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X159.24 Y126.284 E.0196
G2 X158.952 Y126.038 I-3.891 J4.255 E.01164
G1 X159.52 Y125.469 E.02473
G1 X159.52 Y124.936 E.01641
G1 X158.631 Y125.825 E.03866
G2 X158.277 Y125.646 I-1.071 J1.686 E.01224
G1 X159.52 Y124.402 E.0541
G1 X159.52 Y123.868 E.01641
G1 X157.881 Y125.508 E.0713
G2 X157.432 Y125.423 I-.647 J2.205 E.01408
G1 X159.52 Y123.335 E.09084
G1 X159.52 Y122.801 E.01641
G1 X156.916 Y125.405 E.11325
G2 X156.285 Y125.503 I.178 J3.234 E.01968
G1 X159.52 Y122.267 E.14072
G1 X159.52 Y121.734 E.01641
G1 X132.819 Y148.435 E1.16122
G1 X132.819 Y148.969 E.01641
G1 X154.073 Y127.714 E.92433
G2 X153.976 Y128.345 I3.008 J.787 E.01967
G1 X132.819 Y149.502 E.9201
G1 X132.819 Y150.036 E.01641
G1 X153.992 Y128.863 E.92079
G2 X154.079 Y129.309 I2.278 J-.215 E.01401
G1 X132.819 Y150.57 E.9246
G1 X132.819 Y151.103 E.01641
G1 X154.214 Y129.709 E.93044
G2 X154.394 Y130.062 I1.852 J-.723 E.01222
G1 X132.819 Y151.637 E.93828
G1 X132.819 Y152.171 E.01641
G1 X154.609 Y130.381 E.94762
G2 X154.856 Y130.668 I1.555 J-1.089 E.01166
G1 X132.819 Y152.704 E.95835
G1 X132.819 Y153.238 E.01641
G1 X155.134 Y130.923 E.97046
G2 X155.45 Y131.141 I3.4 J-4.576 E.0118
G1 X132.819 Y153.772 E.98418
G1 X132.819 Y154.305 E.01641
G1 X155.799 Y131.325 E.9994
G2 X156.187 Y131.471 I.923 J-1.863 E.01276
G1 X132.819 Y154.839 E1.01626
G1 X132.819 Y155.373 E.01641
G1 X156.626 Y131.566 E1.03534
G2 X157.126 Y131.6 I.419 J-2.485 E.01543
G1 X132.819 Y155.907 E1.05708
G1 X132.819 Y156.44 E.01641
G1 X157.73 Y131.529 E1.08338
G2 X158.593 Y131.2 I-.611 J-2.898 E.0285
G1 X132.819 Y156.974 E1.12089
G1 X132.819 Y157.508 E.01641
G1 X159.52 Y130.806 E1.16122
G1 X159.52 Y131.34 E.01641
G1 X132.819 Y158.041 E1.16122
G1 X132.819 Y158.575 E.01641
G1 X159.52 Y131.874 E1.16122
G1 X159.52 Y132.407 E.01641
G1 X132.819 Y159.109 E1.16122
G1 X132.819 Y159.642 E.01641
G1 X159.52 Y132.941 E1.16122
G1 X159.52 Y133.475 E.01641
G1 X132.819 Y160.176 E1.16122
G1 X132.819 Y160.71 E.01641
G1 X159.52 Y134.009 E1.16122
G1 X159.52 Y134.542 E.01641
G1 X132.819 Y161.244 E1.16122
G1 X132.819 Y161.777 E.01641
G1 X159.52 Y135.076 E1.16122
G1 X159.52 Y135.61 E.01641
G1 X132.819 Y162.311 E1.16122
G1 X132.819 Y162.845 E.01641
G1 X159.52 Y136.143 E1.16122
G1 X159.52 Y136.677 E.01641
G1 X132.819 Y163.378 E1.16122
G1 X132.819 Y163.912 E.01641
G1 X159.52 Y137.211 E1.16122
G1 X159.52 Y137.744 E.01641
G1 X132.819 Y164.446 E1.16122
G1 X132.819 Y164.979 E.01641
G1 X159.52 Y138.278 E1.16122
G1 X159.52 Y138.812 E.01641
G1 X132.819 Y165.513 E1.16122
G1 X132.819 Y166.047 E.01641
G1 X159.52 Y139.346 E1.16122
G1 X159.52 Y139.879 E.01641
G1 X132.819 Y166.581 E1.16122
G1 X132.819 Y167.114 E.01641
G1 X159.52 Y140.413 E1.16122
G1 X159.52 Y140.947 E.01641
G1 X132.819 Y167.648 E1.16122
G1 X132.819 Y168.182 E.01641
G1 X159.52 Y141.48 E1.16122
G1 X159.52 Y142.014 E.01641
G1 X132.819 Y168.715 E1.16122
M73 P50 R15
G1 X132.819 Y169.249 E.01641
G1 X159.52 Y142.548 E1.16122
G1 X159.52 Y143.081 E.01641
G1 X132.819 Y169.783 E1.16122
G1 X132.819 Y170.316 E.01641
G1 X159.52 Y143.615 E1.16122
G1 X159.52 Y144.149 E.01641
G1 X132.819 Y170.85 E1.16122
G1 X132.819 Y171.384 E.01641
G1 X159.52 Y144.683 E1.16122
G1 X159.52 Y145.216 E.01641
G1 X132.819 Y171.917 E1.16122
G1 X132.819 Y172.451 E.01641
G1 X159.52 Y145.75 E1.16122
G1 X159.52 Y146.284 E.01641
G1 X132.819 Y172.985 E1.16122
G1 X132.819 Y173.519 E.01641
G1 X159.52 Y146.817 E1.16122
G1 X159.52 Y147.351 E.01641
G1 X132.819 Y174.052 E1.16122
G1 X132.819 Y174.586 E.01641
G1 X159.52 Y147.885 E1.16122
G1 X159.52 Y148.418 E.01641
G1 X132.819 Y175.12 E1.16122
G1 X132.819 Y175.653 E.01641
G1 X159.52 Y148.952 E1.16122
G1 X159.52 Y149.486 E.01641
G1 X132.819 Y176.187 E1.16122
G1 X132.819 Y176.721 E.01641
G1 X159.52 Y150.019 E1.16122
G1 X159.52 Y150.553 E.01641
G1 X132.819 Y177.254 E1.16122
G1 X132.819 Y177.788 E.01641
G1 X159.52 Y151.087 E1.16122
G1 X159.52 Y151.621 E.01641
G1 X132.819 Y178.322 E1.16122
G1 X132.819 Y178.856 E.01641
G1 X159.52 Y152.154 E1.16122
G1 X159.52 Y152.688 E.01641
G1 X132.819 Y179.389 E1.16122
G1 X132.819 Y179.923 E.01641
G1 X159.52 Y153.222 E1.16122
G1 X159.52 Y153.755 E.01641
M73 P51 R15
G1 X132.819 Y180.457 E1.16122
G1 X132.819 Y180.99 E.01641
G1 X159.52 Y154.289 E1.16122
G1 X159.52 Y154.823 E.01641
G1 X132.819 Y181.524 E1.16122
G1 X132.819 Y182.058 E.01641
G1 X159.52 Y155.356 E1.16122
G1 X159.52 Y155.89 E.01641
G1 X132.819 Y182.591 E1.16122
G1 X132.819 Y183.125 E.01641
G1 X159.52 Y156.424 E1.16122
G1 X159.52 Y156.958 E.01641
G1 X132.819 Y183.659 E1.16122
G1 X132.819 Y184.192 E.01641
G1 X159.52 Y157.491 E1.16122
G1 X159.52 Y158.025 E.01641
G1 X132.819 Y184.726 E1.16122
G1 X132.819 Y185.26 E.01641
G1 X159.52 Y158.559 E1.16122
G1 X159.52 Y159.092 E.01641
G1 X132.819 Y185.794 E1.16122
G1 X132.819 Y186.327 E.01641
G1 X159.52 Y159.626 E1.16122
G1 X159.52 Y160.16 E.01641
G1 X132.819 Y186.861 E1.16122
G1 X132.819 Y187.395 E.01641
G1 X159.52 Y160.693 E1.16122
G1 X159.52 Y161.227 E.01641
G1 X132.819 Y187.928 E1.16122
G1 X132.819 Y188.462 E.01641
G1 X159.52 Y161.761 E1.16122
G1 X159.52 Y162.294 E.01641
G1 X132.819 Y188.996 E1.16122
G1 X132.819 Y189.529 E.01641
G1 X159.52 Y162.828 E1.16122
G1 X159.52 Y163.362 E.01641
G1 X132.819 Y190.063 E1.16122
G1 X132.819 Y190.597 E.01641
G1 X159.52 Y163.896 E1.16122
G1 X159.52 Y164.429 E.01641
G1 X132.819 Y191.131 E1.16122
G1 X132.819 Y191.664 E.01641
G1 X159.52 Y164.963 E1.16122
G1 X159.52 Y165.497 E.01641
G1 X132.819 Y192.198 E1.16122
G1 X132.819 Y192.732 E.01641
G1 X159.52 Y166.03 E1.16122
G1 X159.52 Y166.564 E.01641
G1 X132.819 Y193.265 E1.16122
G1 X132.819 Y193.799 E.01641
G1 X159.52 Y167.098 E1.16122
G1 X159.52 Y167.631 E.01641
G1 X132.819 Y194.333 E1.16122
G1 X132.819 Y194.866 E.01641
G1 X159.52 Y168.165 E1.16122
G1 X159.52 Y168.699 E.01641
G1 X132.819 Y195.4 E1.16122
G1 X132.819 Y195.934 E.01641
G1 X159.52 Y169.233 E1.16122
G1 X159.52 Y169.766 E.01641
G1 X132.819 Y196.467 E1.16122
G1 X132.819 Y197.001 E.01641
G1 X159.52 Y170.3 E1.16122
G1 X159.52 Y170.834 E.01641
G1 X132.819 Y197.535 E1.16122
G1 X132.819 Y198.069 E.01641
G1 X159.52 Y171.367 E1.16122
G1 X159.52 Y171.901 E.01641
G1 X132.819 Y198.602 E1.16122
G1 X132.819 Y199.136 E.01641
G1 X159.52 Y172.435 E1.16122
G1 X159.52 Y172.968 E.01641
G1 X132.819 Y199.67 E1.16122
G1 X132.819 Y200.203 E.01641
G1 X159.52 Y173.502 E1.16122
G1 X159.52 Y174.036 E.01641
G1 X132.819 Y200.737 E1.16122
G1 X132.819 Y201.271 E.01641
G1 X159.52 Y174.569 E1.16122
G1 X159.52 Y175.103 E.01641
G1 X132.819 Y201.804 E1.16122
G1 X132.819 Y202.338 E.01641
G1 X159.52 Y175.637 E1.16122
G1 X159.52 Y176.171 E.01641
G1 X132.819 Y202.872 E1.16122
G1 X132.819 Y203.406 E.01641
G1 X159.52 Y176.704 E1.16122
G1 X159.52 Y177.238 E.01641
G1 X132.819 Y203.939 E1.16122
G1 X132.819 Y204.473 E.01641
G1 X159.52 Y177.772 E1.16122
G1 X159.52 Y178.305 E.01641
G1 X132.819 Y205.007 E1.16122
G1 X132.819 Y205.54 E.01641
G1 X159.52 Y178.839 E1.16122
G1 X159.52 Y179.373 E.01641
G1 X132.823 Y206.07 E1.16105
G1 X132.97 Y206.221 E.00647
G3 X133.712 Y205.715 I1.899 J1.989 E.02772
G1 X159.52 Y179.906 E1.12241
G1 X159.52 Y180.44 E.01641
G1 X134.507 Y205.454 E1.08783
G3 X135.092 Y205.402 I.572 J3.125 E.01811
G1 X159.52 Y180.974 E1.06236
G1 X159.52 Y181.508 E.01641
G1 X135.585 Y205.443 E1.04093
G3 X136.013 Y205.549 I-.766 J3.994 E.01355
G1 X159.52 Y182.041 E1.02234
G1 X159.52 Y182.575 E.01641
G1 X136.396 Y205.7 E1.00569
G3 X136.741 Y205.888 I-.768 J1.82 E.01212
G1 X159.52 Y183.109 E.99067
G1 X159.52 Y183.642 E.01641
G1 X137.048 Y206.115 E.97731
G3 X137.323 Y206.374 I-1.158 J1.501 E.01163
G1 X159.52 Y184.176 E.96537
G1 X159.52 Y184.71 E.01641
G1 X137.566 Y206.665 E.95481
G3 X137.776 Y206.988 I-1.509 J1.212 E.01188
G1 X159.52 Y185.243 E.94565
G1 X159.52 Y185.777 E.01641
G1 X137.948 Y207.35 E.93819
G3 X138.077 Y207.755 I-1.96 J.847 E.01309
G1 X159.52 Y186.311 E.93258
G1 X159.52 Y186.844 E.01641
G1 X138.157 Y208.208 E.92909
G3 X138.159 Y208.739 I-2.646 J.279 E.01636
G1 X159.52 Y187.378 E.92898
G1 X159.52 Y187.912 E.01641
G1 X138.039 Y209.393 E.93422
G3 X137.401 Y210.542 I-2.898 J-.858 E.04073
G1 X137.413 Y210.553 E.0005
G1 X159.52 Y188.446 E.96145
G1 X159.52 Y188.979 E.01641
G1 X137.749 Y210.751 E.94683
G1 X138.283 Y210.751 E.01641
G1 X159.52 Y189.513 E.92362
G1 X159.52 Y190.047 E.01641
G1 X138.816 Y210.751 E.90041
G1 X139.35 Y210.751 E.01641
G1 X159.52 Y190.58 E.8772
G1 X159.52 Y191.114 E.01641
G1 X139.884 Y210.751 E.85399
G1 X140.418 Y210.751 E.01641
G1 X159.52 Y191.648 E.83078
G1 X159.52 Y192.181 E.01641
G1 X140.951 Y210.751 E.80757
G1 X141.485 Y210.751 E.01641
G1 X159.52 Y192.715 E.78436
G1 X159.52 Y193.249 E.01641
G1 X142.019 Y210.751 E.76115
G1 X142.552 Y210.751 E.01641
G1 X159.52 Y193.783 E.73794
G1 X159.52 Y194.316 E.01641
G1 X143.086 Y210.751 E.71472
G1 X143.62 Y210.751 E.01641
G1 X159.52 Y194.85 E.69151
G1 X159.52 Y195.384 E.01641
G1 X144.153 Y210.751 E.6683
G1 X144.687 Y210.751 E.01641
G1 X159.52 Y195.917 E.64509
G1 X159.52 Y196.451 E.01641
G1 X145.221 Y210.751 E.62188
G1 X145.755 Y210.751 E.01641
G1 X159.52 Y196.985 E.59867
G1 X159.52 Y197.518 E.01641
G1 X146.288 Y210.751 E.57546
G1 X146.822 Y210.751 E.01641
G1 X159.52 Y198.052 E.55225
G1 X159.52 Y198.586 E.01641
G1 X147.356 Y210.751 E.52904
G1 X147.889 Y210.751 E.01641
G1 X159.52 Y199.119 E.50583
G1 X159.52 Y199.653 E.01641
G1 X148.423 Y210.751 E.48262
G1 X148.957 Y210.751 E.01641
G1 X159.52 Y200.187 E.45941
G1 X159.52 Y200.721 E.01641
G1 X149.49 Y210.751 E.4362
G1 X150.024 Y210.751 E.01641
G1 X159.52 Y201.254 E.41299
G1 X159.52 Y201.788 E.01641
G1 X150.558 Y210.751 E.38978
G1 X151.091 Y210.751 E.01641
G1 X159.52 Y202.322 E.36657
G1 X159.52 Y202.855 E.01641
G1 X151.625 Y210.751 E.34336
G1 X152.159 Y210.751 E.01641
G1 X159.52 Y203.389 E.32015
G1 X159.52 Y203.923 E.01641
G1 X152.693 Y210.751 E.29694
G1 X153.226 Y210.751 E.01641
G1 X159.52 Y204.456 E.27373
G1 X159.52 Y204.99 E.01641
G1 X153.76 Y210.751 E.25052
G1 X154.294 Y210.751 E.01641
G1 X159.52 Y205.524 E.22731
G1 X159.52 Y206.058 E.01641
G1 X154.827 Y210.751 E.2041
G1 X155.361 Y210.751 E.01641
G1 X159.52 Y206.591 E.18089
G1 X159.52 Y207.125 E.01641
G1 X155.895 Y210.751 E.15768
G1 X156.428 Y210.751 E.01641
G1 X159.52 Y207.659 E.13447
G1 X159.52 Y208.192 E.01641
G1 X156.962 Y210.751 E.11126
M73 P52 R15
G1 X157.496 Y210.751 E.01641
G1 X159.52 Y208.726 E.08805
G1 X159.52 Y209.26 E.01641
G1 X158.03 Y210.751 E.06484
G1 X158.563 Y210.751 E.01641
G1 X159.52 Y209.793 E.04163
G1 X159.52 Y210.327 E.01641
G1 X158.927 Y210.92 E.0258
M204 S10000
G1 X137.09 Y210.708 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.110674
G1 F15000
M204 S6000
G1 X136.969 Y210.838 E.00098
G1 X136.902 Y210.862 E.00039
M204 S10000
G1 X136.264 Y211.044 F42000
; LINE_WIDTH: 0.431426
G1 F15000
M204 S6000
G3 X135.935 Y211.106 I-1.408 J-6.593 E.01059
; LINE_WIDTH: 0.388639
G1 X135.808 Y211.123 E.00363
; LINE_WIDTH: 0.35148
G1 X135.665 Y211.143 E.00361
; LINE_WIDTH: 0.309183
G1 X135.398 Y211.166 E.00583
; LINE_WIDTH: 0.279202
G1 X134.875 Y211.172 E.01006
G1 X134.595 Y211.155 E.0054
; LINE_WIDTH: 0.32272
G1 X134.467 Y211.14 E.00294
; LINE_WIDTH: 0.353438
G1 X134.323 Y211.124 E.00367
; LINE_WIDTH: 0.390631
G1 X134.2 Y211.103 E.00354
; LINE_WIDTH: 0.422406
G1 X134.076 Y211.083 E.00387
G1 X133.938 Y210.81 E.00946
; WIPE_START
G1 X134.076 Y211.083 E-.53949
G1 X134.2 Y211.103 E-.22051
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.883 Y210.671 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.38674
G1 F15000
M204 S6000
G1 X132.819 Y210.708 E.00209
G1 X132.868 Y210.737 E.00161
; WIPE_START
G1 X132.819 Y210.708 E-.33089
G1 X132.883 Y210.671 E-.42911
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.523 Y209.693 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.436833
G1 F15000
M204 S6000
G1 X132.49 Y209.504 E.00616
; LINE_WIDTH: 0.405899
G1 X132.456 Y209.315 E.00568
; LINE_WIDTH: 0.37145
G1 X132.438 Y209.17 E.00391
; LINE_WIDTH: 0.337231
G1 X132.422 Y209.043 E.00309
; LINE_WIDTH: 0.300351
G1 X132.401 Y208.773 E.00567
; LINE_WIDTH: 0.272594
G1 X132.401 Y208.239 E.01
; LINE_WIDTH: 0.29843
G1 X132.42 Y207.971 E.00559
; LINE_WIDTH: 0.335156
G1 X132.437 Y207.833 E.00332
; LINE_WIDTH: 0.36811
G1 X132.453 Y207.708 E.00333
; LINE_WIDTH: 0.401842
G1 X132.471 Y207.599 E.00325
; LINE_WIDTH: 0.436677
G1 X132.487 Y207.504 E.00306
; LINE_WIDTH: 0.4334
G1 X132.758 Y207.374 E.00957
M204 S10000
G1 X132.69 Y206.655 F42000
; LINE_WIDTH: 0.106201
G1 F15000
M204 S6000
G1 X132.812 Y206.536 E.00088
; OBJECT_ID: 124
; WIPE_START
G1 X132.69 Y206.655 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G1 X128.92 Y200.018 Z1.2 F42000
G1 X106.723 Y160.934 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X106.753 Y161.239 E.00942
G3 X105.061 Y159.705 I-1.559 J.019 E.22224
G1 X105.209 Y159.699 E.00457
G3 X106.706 Y160.878 I-.015 J1.559 E.06299
; WIPE_START
M204 S6000
G1 X106.753 Y161.239 E-.13864
G1 X106.751 Y161.395 E-.05907
G1 X106.693 Y161.7 E-.11805
G1 X106.576 Y161.988 E-.11804
G1 X106.405 Y162.247 E-.11804
G1 X106.185 Y162.466 E-.11811
G1 X105.987 Y162.598 E-.09005
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.147 Y163.546 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X104.715 Y163.497 E.01335
G3 X105.225 Y158.969 I.478 J-2.239 E.20719
G1 X105.332 Y158.973 E.00329
G3 X105.207 Y163.548 I-.139 J2.285 E.21633
M204 S10000
G1 X105.173 Y163.183 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F15000
M204 S6000
G3 X103.272 Y161.291 I.024 J-1.924 E.08177
G1 X103.272 Y161.275 E.00046
G3 X103.279 Y161.099 I3.526 J.044 E.00483
G3 X105.233 Y163.183 I1.918 J.159 E.24456
; OBJECT_ID: 102
; WIPE_START
G1 X104.792 Y163.141 E-.16824
G1 X104.427 Y163.023 E-.14574
G1 X104.108 Y162.846 E-.1387
G1 X103.87 Y162.654 E-.11619
G1 X103.62 Y162.363 E-.14578
G1 X103.561 Y162.259 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.055 Y154.642 Z1.2 F42000
G1 X104.067 Y154.458 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X104.098 Y154.763 E.00942
G3 X102.405 Y153.228 I-1.559 J.019 E.22224
G1 X102.554 Y153.222 E.00457
G3 X104.051 Y154.401 I-.015 J1.559 E.06299
; WIPE_START
M204 S6000
G1 X104.098 Y154.763 E-.13864
G1 X104.096 Y154.918 E-.05907
G1 X104.038 Y155.223 E-.11805
G1 X103.921 Y155.511 E-.11804
G1 X103.749 Y155.77 E-.11804
G1 X103.529 Y155.99 E-.11811
G1 X103.332 Y156.121 E-.09005
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.491 Y157.069 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X102.06 Y157.021 E.01335
G3 X102.57 Y152.492 I.478 J-2.239 E.20719
G1 X102.677 Y152.496 E.00329
G3 X102.551 Y157.071 I-.139 J2.285 E.21633
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F15000
M204 S6000
G3 X100.617 Y154.815 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.526 J.044 E.00483
G3 X102.577 Y156.706 I1.918 J.159 E.24456
; OBJECT_ID: 91
; WIPE_START
G1 X102.136 Y156.664 E-.16824
G1 X101.771 Y156.547 E-.14574
G1 X101.452 Y156.369 E-.1387
G1 X101.214 Y156.177 E-.11619
G1 X100.964 Y155.886 E-.14578
G1 X100.906 Y155.782 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.166 Z1.2 F42000
G1 X101.411 Y147.981 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X101.442 Y148.286 E.00942
G3 X99.75 Y146.751 I-1.559 J.019 E.22224
G1 X99.898 Y146.745 E.00457
G3 X101.395 Y147.924 I-.015 J1.559 E.06299
; WIPE_START
M204 S6000
G1 X101.442 Y148.286 E-.13864
G1 X101.44 Y148.441 E-.05907
G1 X101.382 Y148.747 E-.11805
G1 X101.265 Y149.034 E-.11804
G1 X101.093 Y149.293 E-.11804
G1 X100.874 Y149.513 E-.11811
G1 X100.676 Y149.644 E-.09005
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.836 Y150.593 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X99.404 Y150.544 E.01335
G3 X99.914 Y146.016 I.478 J-2.239 E.20719
G1 X100.021 Y146.02 E.00329
G3 X99.896 Y150.594 I-.139 J2.285 E.21633
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F15000
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.526 J.044 E.00483
G3 X99.921 Y150.229 I1.918 J.159 E.24456
; OBJECT_ID: 113
; WIPE_START
G1 X99.481 Y150.188 E-.16824
G1 X99.116 Y150.07 E-.14574
G1 X98.797 Y149.892 E-.1387
G1 X98.559 Y149.7 E-.11619
G1 X98.309 Y149.41 E-.14578
G1 X98.25 Y149.305 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.744 Y141.689 Z1.2 F42000
G1 X98.756 Y141.504 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X98.787 Y141.809 E.00942
G3 X97.094 Y140.274 I-1.559 J.019 E.22224
G1 X97.243 Y140.269 E.00457
G3 X98.74 Y141.448 I-.015 J1.559 E.06299
; WIPE_START
M204 S6000
G1 X98.787 Y141.809 E-.13864
G1 X98.784 Y141.965 E-.05907
G1 X98.727 Y142.27 E-.11805
G1 X98.61 Y142.558 E-.11804
G1 X98.438 Y142.817 E-.11804
G1 X98.218 Y143.036 E-.11811
G1 X98.021 Y143.167 E-.09005
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.18 Y144.116 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X96.748 Y144.067 E.01335
G3 X97.259 Y139.539 I.478 J-2.239 E.20719
G1 X97.366 Y139.543 E.00329
G3 X97.24 Y144.118 I-.139 J2.285 E.21633
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F15000
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.526 J.044 E.00483
G3 X97.266 Y143.753 I1.918 J.159 E.24456
; CHANGE_LAYER
; Z_HEIGHT: 1
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.825 Y143.711 E-.16824
G1 X96.46 Y143.593 E-.14574
G1 X96.141 Y143.416 E-.1387
G1 X95.903 Y143.224 E-.11619
G1 X95.653 Y142.933 E-.14578
G1 X95.595 Y142.829 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 5/60
; update layer progress
M73 L5
M991 S0 P4 ;notify layer change
; OBJECT_ID: 80
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
M204 S10000
G17
G3 Z1.2 I.938 J.776 P1  F42000
G1 X144.661 Y83.489 Z1.2
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.656 Y83.482 E.00028
G3 X145.656 Y80.932 I1.194 J-1.003 E.10275
G1 X145.811 Y80.92 E.00478
G3 X144.878 Y83.698 I.039 J1.559 E.18396
G1 X144.704 Y83.531 E.00741
; WIPE_START
M204 S6000
G1 X144.656 Y83.482 E-.02622
G1 X144.48 Y83.226 E-.11798
G1 X144.359 Y82.94 E-.11807
G1 X144.297 Y82.635 E-.11813
G1 X144.297 Y82.325 E-.11801
G1 X144.359 Y82.02 E-.11816
G1 X144.48 Y81.734 E-.11796
G1 X144.517 Y81.679 E-.02546
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.201 Y89.123 Z1.4 F42000
G1 X155.502 Y130.251 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X155.264 Y130.016 E.01111
G3 X156.776 Y126.158 I1.806 J-1.517 E.1678
G1 X157.011 Y126.14 E.00782
G3 X155.6 Y130.343 I.059 J2.358 E.30043
G1 X155.545 Y130.292 E.00247
M204 S10000
G1 X155.785 Y129.961 F42000
G1 F15476.087
M204 S6000
G1 X155.575 Y129.754 E.00977
G3 X156.827 Y126.562 I1.494 J-1.255 E.13883
G1 X157.021 Y126.548 E.00647
G3 X155.854 Y130.025 I.049 J1.951 E.24855
G1 X155.829 Y130.002 E.00113
M204 S250
G1 X156.058 Y129.681 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X155.876 Y129.502 E.00785
G3 X156.876 Y126.952 I1.194 J-1.003 E.10275
G1 X157.031 Y126.94 E.00478
G3 X156.102 Y129.722 I.039 J1.559 E.1838
; WIPE_START
M204 S6000
G1 X155.876 Y129.502 E-.11983
G1 X155.7 Y129.246 E-.11806
G1 X155.579 Y128.96 E-.118
G1 X155.517 Y128.655 E-.11812
G1 X155.517 Y128.345 E-.11801
G1 X155.579 Y128.04 E-.11813
G1 X155.627 Y127.918 E-.04985
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.034 Y127.139 Z1.4 F42000
G1 X96.664 Y121.865 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X96.783 Y122.059 E.00755
G2 X98.09 Y123.091 I2.326 J-1.604 E.05608
G1 X98.049 Y123.284 E.00654
G1 X96.486 Y123.284 E.05184
G1 X96.486 Y121.915 E.0454
G1 X96.606 Y121.881 E.00415
; WIPE_START
G1 X96.783 Y122.059 E-.09525
G1 X96.949 Y122.279 E-.10482
G1 X97.137 Y122.482 E-.1049
G1 X97.344 Y122.664 E-.10476
G1 X97.568 Y122.825 E-.10491
G1 X97.807 Y122.963 E-.10486
G1 X98.09 Y123.091 E-.11813
G1 X98.078 Y123.148 E-.02236
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.721 Y120.377 Z1.4 F42000
G1 Z1
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X96.723 Y120.265 E.00369
G3 X98.776 Y118.158 I2.347 J.233 E.10539
G1 X99.011 Y118.14 E.00782
G3 X96.723 Y120.735 I.059 J2.358 E.36285
G1 X96.721 Y120.437 E.00989
M204 S10000
G1 X97.127 Y120.377 F42000
G1 F15476.087
M204 S6000
G1 X97.128 Y120.306 E.00235
G3 X98.827 Y118.562 I1.942 J.193 E.08719
G1 X99.021 Y118.548 E.00647
G3 X97.128 Y120.694 I.049 J1.951 E.30019
G1 X97.127 Y120.437 E.00855
M204 S250
G1 X97.517 Y120.377 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X97.518 Y120.345 E.00098
G3 X98.876 Y118.952 I1.552 J.154 E.06453
G1 X99.031 Y118.94 E.00478
G3 X97.518 Y120.655 I.039 J1.559 E.22217
G1 X97.518 Y120.437 E.00672
; WIPE_START
M204 S6000
G1 X97.518 Y120.345 E-.03487
G1 X97.579 Y120.04 E-.1181
G1 X97.699 Y119.755 E-.1176
G1 X97.827 Y119.557 E-.08934
G1 X98.037 Y119.33 E-.11779
G1 X98.29 Y119.149 E-.11808
G1 X98.573 Y119.021 E-.11811
G1 X98.691 Y118.994 E-.04612
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.159 Y111.376 Z1.4 F42000
G1 X101.4 Y74.826 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X101.324 Y75.195 E.01251
G3 X98.776 Y72.158 I-2.254 J-.697 E.33551
G1 X99.011 Y72.14 E.00782
G3 X101.417 Y74.735 I.059 J2.358 E.13272
G1 X101.411 Y74.767 E.00108
M204 S10000
G1 X101.003 Y74.745 F42000
G1 F15476.087
M204 S6000
G1 X100.934 Y75.075 E.01117
G3 X98.827 Y72.562 I-1.865 J-.576 E.27758
G1 X99.021 Y72.548 E.00647
G3 X101.012 Y74.686 I.049 J1.951 E.10953
M204 S250
G1 X100.62 Y74.668 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X100.56 Y74.96 E.00915
G3 X98.876 Y72.952 I-1.49 J-.461 E.20544
G1 X99.031 Y72.94 E.00478
G3 X100.625 Y74.608 I.039 J1.559 E.07982
; WIPE_START
M204 S6000
G1 X100.56 Y74.96 E-.13577
G1 X100.44 Y75.246 E-.11797
G1 X100.265 Y75.503 E-.11807
G1 X100.045 Y75.718 E-.11712
G1 X99.85 Y75.851 E-.08955
G1 X99.567 Y75.979 E-.11811
G1 X99.404 Y76.016 E-.06341
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.327 Y80.83 Z1.4 F42000
G1 X143.368 Y111.742 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.42 Y111.637 E.00389
G3 X145.505 Y110.214 I2.43 J1.322 E.08696
G1 X145.781 Y110.193 E.00917
G3 X143.3 Y111.885 I.069 J2.765 E.47125
G1 X143.342 Y111.796 E.00328
M204 S10000
G1 X143.724 Y111.956 F42000
G1 F15476.087
M204 S6000
G1 X143.778 Y111.831 E.00451
G3 X145.556 Y110.618 I2.072 J1.127 E.07416
G1 X145.791 Y110.6 E.00782
G3 X143.595 Y112.264 I.059 J2.358 E.39407
G1 X143.701 Y112.012 E.00908
M204 S10000
G1 X144.098 Y112.114 F42000
G1 F15476.087
M204 S6000
G1 X144.135 Y112.026 E.00316
G3 X145.607 Y111.022 I1.714 J.932 E.06136
G1 X145.801 Y111.008 E.00647
G3 X143.985 Y112.384 I.049 J1.951 E.32602
G1 X144.075 Y112.169 E.00774
M204 S250
G1 X144.458 Y112.266 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.48 Y112.214 E.00173
G3 X145.656 Y111.412 I1.37 J.745 E.04541
G1 X145.811 Y111.4 E.00478
G3 X144.36 Y112.5 I.039 J1.559 E.24129
G1 X144.435 Y112.321 E.00597
; WIPE_START
M204 S6000
G1 X144.48 Y112.214 E-.0442
G1 X144.654 Y111.958 E-.11757
G1 X144.818 Y111.79 E-.08935
G1 X145.07 Y111.609 E-.11781
G1 X145.353 Y111.481 E-.11809
G1 X145.656 Y111.412 E-.11796
G1 X145.811 Y111.4 E-.05917
G1 X146.062 Y111.419 E-.09586
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.443 Y111.866 Z1.4 F42000
G1 X113.022 Y113.359 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X112.969 Y113.649 E.00978
G3 X109.945 Y110.214 I-2.679 J-.691 E.39778
G1 X110.221 Y110.193 E.00917
G3 X113.043 Y113.231 I.069 J2.765 E.15548
G1 X113.031 Y113.3 E.00234
M204 S10000
G1 X112.622 Y113.288 F42000
G1 F15476.087
M204 S6000
G1 X112.574 Y113.547 E.00871
G3 X109.996 Y110.618 I-2.284 J-.588 E.33925
G1 X110.231 Y110.6 E.00782
G3 X112.637 Y113.191 I.059 J2.358 E.1326
G1 X112.631 Y113.229 E.00127
M204 S10000
G1 X112.222 Y113.185 F42000
G1 F15476.087
M204 S6000
G1 X112.211 Y113.304 E.00395
G3 X110.047 Y111.022 I-1.921 J-.345 E.28548
G1 X110.241 Y111.008 E.00647
G3 X112.241 Y112.96 I.049 J1.951 E.10334
G1 X112.227 Y113.126 E.00551
M204 S250
G1 X111.833 Y113.15 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.824 Y113.235 E.00263
G3 X110.096 Y111.412 I-1.535 J-.276 E.21127
G1 X110.251 Y111.4 E.00479
G3 X111.849 Y112.96 I.039 J1.559 E.07648
G1 X111.838 Y113.09 E.00401
; WIPE_START
M204 S6000
G1 X111.824 Y113.235 E-.05536
G1 X111.756 Y113.494 E-.10157
G1 X111.621 Y113.774 E-.11809
G1 X111.434 Y114.021 E-.11808
G1 X111.201 Y114.227 E-.11807
G1 X110.932 Y114.382 E-.118
G1 X110.637 Y114.481 E-.11812
G1 X110.604 Y114.485 E-.01271
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X110.973 Y106.862 Z1.4 F42000
G1 X112.05 Y84.612 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X111.904 Y84.726 E.00615
G3 X109.95 Y79.733 I-1.612 J-2.248 E.33398
G1 X110.221 Y79.713 E.009
G3 X112.115 Y84.559 I.072 J2.765 E.22463
G1 X112.097 Y84.574 E.00079
M204 S10000
G1 X111.762 Y84.314 F42000
G1 F15476.087
M204 S6000
G1 X111.469 Y84.522 E.01193
G3 X110 Y80.138 I-1.177 J-2.044 E.27701
G1 X110.231 Y80.12 E.0077
G3 X111.847 Y84.252 I.061 J2.358 E.1915
G1 X111.811 Y84.279 E.0015
M204 S10000
G1 X111.526 Y83.985 F42000
G1 F15476.087
M204 S6000
G1 X111.265 Y84.17 E.01059
G3 X110.049 Y80.542 I-.975 J-1.691 E.22918
G1 X110.241 Y80.528 E.0064
G3 X111.579 Y83.945 I.05 J1.951 E.15837
G1 X111.574 Y83.949 E.00021
M204 S250
G1 X111.298 Y83.667 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.069 Y83.83 E.00861
G3 X110.096 Y80.932 I-.779 J-1.351 E.16962
G1 X110.251 Y80.92 E.00476
G3 X111.344 Y83.629 I.039 J1.559 E.11619
; WIPE_START
M204 S6000
G1 X111.069 Y83.83 E-.12923
G1 X110.787 Y83.959 E-.11804
G1 X110.484 Y84.028 E-.11806
G1 X110.173 Y84.036 E-.11806
G1 X109.867 Y83.982 E-.11809
G1 X109.578 Y83.868 E-.11807
G1 X109.489 Y83.811 E-.04045
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X116.982 Y82.36 Z1.4 F42000
G1 X121.854 Y81.416 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.295 Y81.416 E.71125
G2 X148.405 Y81.416 I2.555 J1.063 E.36075
G1 X159.854 Y81.416 E.37979
G1 X159.854 Y127.471 E1.52774
G1 X159.664 Y127.515 E.00646
G2 X159.432 Y129.943 I-2.589 J.978 E.49311
G2 X159.658 Y129.478 I-2.216 J-1.364 E.0172
G1 X159.854 Y129.517 E.00663
G1 X159.854 Y211.084 E2.70571
G1 X136.488 Y211.084 E.77509
G1 X136.436 Y210.909 E.00606
G2 X132.664 Y207.135 I-1.366 J-2.406 E.33773
G1 X132.486 Y207.085 E.00614
G1 X132.486 Y123.284 E2.77984
G1 X100.088 Y123.284 E1.0747
G1 X100.05 Y123.085 E.00671
G2 X96.665 Y119.133 I-.98 J-2.587 E.35179
G1 X96.486 Y119.084 E.00617
G1 X96.486 Y75.915 E1.43199
G1 X96.664 Y75.865 E.00614
G2 X96.664 Y73.135 I2.406 J-1.365 E.48193
G1 X96.486 Y73.085 E.00614
G1 X96.486 Y44.916 E.93441
G1 X141.154 Y44.916 E1.48171
G1 X141.154 Y47.584 E.08849
G1 X137.154 Y47.584 E.13269
G1 X137.154 Y65.916 E.60812
G1 X141.154 Y65.916 E.13269
G1 X141.154 Y69.084 E.10507
G1 X121.854 Y69.084 E.64022
G1 X121.854 Y81.356 E.4071
; WIPE_START
G1 X123.854 Y81.362 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.468 Y88.969 Z1.4 F42000
G1 X133.961 Y206.423 Z1.4
G1 Z1
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X134.318 Y206.263 E.01299
G3 X134.776 Y206.158 I.751 J2.236 E.0156
G1 X135.011 Y206.14 E.00782
G3 X133.89 Y206.456 I.059 J2.358 E.45261
G1 X133.907 Y206.448 E.00063
M204 S10000
G1 X134.128 Y206.793 F42000
G1 F15476.087
M204 S6000
G1 X134.448 Y206.649 E.01164
G3 X134.827 Y206.562 I.622 J1.85 E.01291
G1 X135.021 Y206.548 E.00647
G3 X134.075 Y206.82 I.049 J1.951 E.37374
M204 S250
G1 X134.29 Y207.149 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G3 X134.876 Y206.952 I.78 J1.35 E.01912
G1 X135.031 Y206.94 E.00479
G3 X134.238 Y207.18 I.039 J1.559 E.27529
; WIPE_START
M204 S6000
G1 X134.573 Y207.021 E-.14071
G1 X134.876 Y206.952 E-.118
G1 X135.031 Y206.94 E-.05918
G1 X135.341 Y206.963 E-.11804
G1 X135.64 Y207.048 E-.11811
G1 X135.916 Y207.189 E-.11802
G1 X136.097 Y207.334 E-.08794
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.664 Y209.865 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X132.783 Y210.059 E.00755
G2 X133.702 Y210.903 I2.325 J-1.611 E.04175
G1 X133.654 Y211.084 E.00622
G1 X132.486 Y211.084 E.03874
G1 X132.486 Y209.915 E.03877
G1 X132.606 Y209.881 E.00415
; WIPE_START
G1 X132.783 Y210.059 E-.09518
G1 X132.949 Y210.279 E-.10492
G1 X133.137 Y210.481 E-.10483
G1 X133.344 Y210.664 E-.10485
G1 X133.702 Y210.903 E-.16369
G1 X133.654 Y211.084 E-.07121
G1 X133.351 Y211.084 E-.11531
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.702 Y203.479 Z1.4 F42000
G1 X122.261 Y81.009 Z1.4
G1 Z1
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X143.986 Y81.009 E.72066
G2 X144.042 Y83.997 I1.948 J1.458 E.10675
G2 X147.923 Y81.351 I1.801 J-1.528 E.22964
G1 X147.714 Y81.009 E.01329
G1 X160.261 Y81.009 E.41621
G1 X160.261 Y211.491 E4.32832
G1 X132.079 Y211.491 E.93484
G1 X132.079 Y123.691 E2.91249
G1 X96.079 Y123.691 E1.19419
G1 X96.079 Y44.509 E2.6266
G1 X141.561 Y44.509 E1.50871
G1 X141.561 Y47.991 E.1155
G1 X137.561 Y47.991 E.13269
G1 X137.561 Y65.509 E.58111
G1 X141.561 Y65.509 E.13269
G1 X141.561 Y69.491 E.13208
G1 X122.261 Y69.491 E.64022
G1 X122.261 Y80.949 E.38009
M204 S10000
G1 X122.668 Y80.602 F42000
G1 F15476.087
M204 S6000
G1 X144.84 Y80.602 E.73548
G1 X144.888 Y80.783 E.00622
G2 X146.811 Y80.783 I.962 J1.693 E.33909
G1 X146.86 Y80.602 E.00622
G1 X160.668 Y80.602 E.45803
G1 X160.668 Y211.898 E4.35533
G1 X131.672 Y211.898 E.96185
G1 X131.672 Y124.098 E2.91249
G1 X95.672 Y124.098 E1.19419
G1 X95.672 Y44.102 E2.65361
G1 X141.968 Y44.102 E1.53572
G1 X141.968 Y48.398 E.1425
G1 X137.968 Y48.398 E.13269
G1 X137.968 Y65.102 E.55411
G1 X141.968 Y65.102 E.13269
G1 X141.968 Y69.898 E.15909
G1 X122.668 Y69.898 E.64022
G1 X122.668 Y80.542 E.35309
M204 S250
G1 X123.06 Y80.21 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X161.06 Y80.21 E1.16763
G1 X161.06 Y212.29 E4.05845
G1 X131.28 Y212.29 E.91506
G1 X131.28 Y124.49 E2.69785
G1 X95.28 Y124.49 E1.10618
G1 X95.28 Y43.71 E2.48214
G1 X142.36 Y43.71 E1.44664
G1 X142.36 Y48.79 E.15609
G1 X138.36 Y48.79 E.12291
G1 X138.36 Y64.71 E.48918
G1 X142.36 Y64.71 E.12291
G1 X142.36 Y70.29 E.17146
G1 X123.06 Y70.29 E.59304
G1 X123.06 Y80.15 E.30297
; WIPE_START
M204 S6000
G1 X125.06 Y80.153 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 80
M625
; object ids of layer 5 start: 80,91,102,113,124
M624 HwAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
M73 P53 R15
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


; object ids of this layer5 end: 80,91,102,113,124
M625
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X140.382 Y81.58 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X159.52 Y100.718 E.83354
G1 X159.52 Y101.253 E.01646
G1 X140.017 Y81.749 E.84943
G1 X139.483 Y81.749 E.01646
G1 X159.52 Y101.787 E.87271
G1 X159.52 Y102.322 E.01646
G1 X138.948 Y81.749 E.89598
G1 X138.414 Y81.749 E.01646
G1 X159.52 Y102.856 E.91926
G1 X159.52 Y103.391 E.01646
G1 X137.879 Y81.749 E.94254
G1 X137.345 Y81.749 E.01646
G1 X159.52 Y103.925 E.96582
G1 X159.52 Y104.46 E.01646
G1 X136.81 Y81.749 E.9891
G1 X136.276 Y81.749 E.01646
G1 X159.52 Y104.994 E1.01237
G1 X159.52 Y105.529 E.01646
G1 X135.741 Y81.749 E1.03565
G1 X135.207 Y81.749 E.01646
G1 X159.52 Y106.063 E1.05893
G1 X159.52 Y106.598 E.01646
G1 X134.672 Y81.749 E1.08221
G1 X134.138 Y81.749 E.01646
G1 X159.52 Y107.132 E1.10549
G1 X159.52 Y107.666 E.01646
G1 X133.603 Y81.749 E1.12876
G1 X133.069 Y81.749 E.01646
G1 X159.52 Y108.201 E1.15204
G1 X159.52 Y108.735 E.01646
G1 X132.534 Y81.749 E1.17532
G1 X132 Y81.749 E.01646
G1 X159.52 Y109.27 E1.1986
G1 X159.52 Y109.804 E.01646
G1 X131.465 Y81.749 E1.22187
G1 X130.931 Y81.749 E.01646
G1 X159.52 Y110.339 E1.24515
G1 X159.52 Y110.873 E.01646
G1 X130.397 Y81.749 E1.26843
G1 X129.862 Y81.749 E.01646
G1 X159.52 Y111.408 E1.29171
G1 X159.52 Y111.942 E.01646
G1 X129.328 Y81.749 E1.31499
G1 X128.793 Y81.749 E.01646
G1 X159.52 Y112.477 E1.33826
G1 X159.52 Y113.011 E.01646
G1 X128.259 Y81.749 E1.36154
G1 X127.724 Y81.749 E.01646
G1 X159.52 Y113.546 E1.38482
G1 X159.52 Y114.08 E.01646
G1 X127.19 Y81.749 E1.4081
G1 X126.655 Y81.749 E.01646
G1 X159.52 Y114.615 E1.43137
G1 X159.52 Y115.149 E.01646
G1 X126.121 Y81.749 E1.45465
G1 X125.586 Y81.749 E.01646
G1 X159.52 Y115.684 E1.47793
G1 X159.52 Y116.218 E.01646
G1 X125.052 Y81.749 E1.50121
G1 X124.517 Y81.749 E.01646
G1 X159.52 Y116.753 E1.52449
G1 X159.52 Y117.287 E.01646
G1 X123.983 Y81.749 E1.54776
G1 X123.448 Y81.749 E.01646
G1 X159.52 Y117.821 E1.57104
G1 X159.52 Y118.356 E.01646
G1 X122.914 Y81.749 E1.59432
G1 X122.379 Y81.749 E.01646
G1 X159.52 Y118.89 E1.6176
G1 X159.52 Y119.425 E.01646
G1 X96.819 Y56.724 E2.73082
G1 X96.819 Y56.189 E.01646
G1 X121.52 Y80.89 E1.07581
G1 X121.52 Y80.356 E.01646
G1 X96.819 Y55.655 E1.07581
G1 X96.819 Y55.12 E.01646
G1 X121.52 Y79.821 E1.07581
G1 X121.52 Y79.287 E.01646
G1 X96.819 Y54.586 E1.07581
G1 X96.819 Y54.051 E.01646
G1 X121.52 Y78.752 E1.07581
G1 X121.52 Y78.218 E.01646
G1 X96.819 Y53.517 E1.07581
G1 X96.819 Y52.982 E.01646
G1 X121.52 Y77.684 E1.07581
G1 X121.52 Y77.149 E.01646
G1 X96.819 Y52.448 E1.07581
G1 X96.819 Y51.913 E.01646
G1 X121.52 Y76.615 E1.07581
G1 X121.52 Y76.08 E.01646
G1 X96.819 Y51.379 E1.07581
G1 X96.819 Y50.844 E.01646
G1 X121.52 Y75.546 E1.07581
G1 X121.52 Y75.011 E.01646
G1 X96.819 Y50.31 E1.07581
G1 X96.819 Y49.775 E.01646
G1 X121.52 Y74.477 E1.07581
G1 X121.52 Y73.942 E.01646
G1 X96.819 Y49.241 E1.07581
G1 X96.819 Y48.706 E.01646
G1 X121.52 Y73.408 E1.07581
G1 X121.52 Y72.873 E.01646
G1 X96.819 Y48.172 E1.07581
G1 X96.819 Y47.638 E.01646
G1 X121.52 Y72.339 E1.07581
G1 X121.52 Y71.804 E.01646
G1 X96.819 Y47.103 E1.07581
G1 X96.819 Y46.569 E.01646
G1 X121.52 Y71.27 E1.07581
G1 X121.52 Y70.735 E.01646
G1 X96.819 Y46.034 E1.07581
G1 X96.819 Y45.5 E.01646
G1 X121.52 Y70.201 E1.07581
G1 X121.52 Y69.666 E.01646
G1 X97.103 Y45.249 E1.06343
G1 X97.638 Y45.249 E.01646
G1 X121.52 Y69.132 E1.04016
G1 X121.52 Y68.751 E.01174
G1 X121.674 Y68.751 E.00472
G1 X98.172 Y45.249 E1.02355
G1 X98.707 Y45.249 E.01646
M73 P53 R14
G1 X122.208 Y68.751 E1.02355
G1 X122.743 Y68.751 E.01646
G1 X99.241 Y45.249 E1.02355
G1 X99.776 Y45.249 E.01646
G1 X123.277 Y68.751 E1.02355
G1 X123.811 Y68.751 E.01646
G1 X100.31 Y45.249 E1.02355
G1 X100.845 Y45.249 E.01646
G1 X124.346 Y68.751 E1.02355
G1 X124.88 Y68.751 E.01646
G1 X101.379 Y45.249 E1.02355
G1 X101.914 Y45.249 E.01646
G1 X125.415 Y68.751 E1.02355
G1 X125.949 Y68.751 E.01646
G1 X102.448 Y45.249 E1.02355
G1 X102.983 Y45.249 E.01646
G1 X126.484 Y68.751 E1.02355
G1 X127.018 Y68.751 E.01646
G1 X103.517 Y45.249 E1.02355
G1 X104.052 Y45.249 E.01646
G1 X127.553 Y68.751 E1.02355
G1 X128.087 Y68.751 E.01646
G1 X104.586 Y45.249 E1.02355
G1 X105.12 Y45.249 E.01646
G1 X128.622 Y68.751 E1.02355
G1 X129.156 Y68.751 E.01646
G1 X105.655 Y45.249 E1.02355
G1 X106.189 Y45.249 E.01646
G1 X129.691 Y68.751 E1.02355
G1 X130.225 Y68.751 E.01646
G1 X106.724 Y45.249 E1.02355
M73 P54 R14
G1 X107.258 Y45.249 E.01646
G1 X130.76 Y68.751 E1.02355
G1 X131.294 Y68.751 E.01646
G1 X107.793 Y45.249 E1.02355
G1 X108.327 Y45.249 E.01646
G1 X131.829 Y68.751 E1.02355
G1 X132.363 Y68.751 E.01646
G1 X108.862 Y45.249 E1.02355
G1 X109.396 Y45.249 E.01646
G1 X132.898 Y68.751 E1.02355
G1 X133.432 Y68.751 E.01646
G1 X109.931 Y45.249 E1.02355
G1 X110.465 Y45.249 E.01646
G1 X133.966 Y68.751 E1.02355
G1 X134.501 Y68.751 E.01646
G1 X111 Y45.249 E1.02355
G1 X111.534 Y45.249 E.01646
G1 X135.035 Y68.751 E1.02355
G1 X135.57 Y68.751 E.01646
G1 X112.069 Y45.249 E1.02355
G1 X112.603 Y45.249 E.01646
G1 X136.104 Y68.751 E1.02355
G1 X136.639 Y68.751 E.01646
G1 X113.138 Y45.249 E1.02355
G1 X113.672 Y45.249 E.01646
G1 X137.173 Y68.751 E1.02355
G1 X137.708 Y68.751 E.01646
G1 X114.207 Y45.249 E1.02355
G1 X114.741 Y45.249 E.01646
G1 X138.242 Y68.751 E1.02355
G1 X138.777 Y68.751 E.01646
G1 X115.275 Y45.249 E1.02355
G1 X115.81 Y45.249 E.01646
G1 X139.481 Y68.92 E1.03094
M204 S10000
G1 X140.99 Y66.688 F42000
G1 F15000
M204 S6000
G1 X140.551 Y66.249 E.01911
G1 X140.017 Y66.249 E.01646
G1 X140.82 Y67.053 E.035
G1 X140.82 Y67.588 E.01646
G1 X139.482 Y66.249 E.05828
G1 X138.948 Y66.249 E.01646
G1 X140.82 Y68.122 E.08156
G1 X140.82 Y68.656 E.01646
G1 X138.413 Y66.249 E.10484
G1 X137.879 Y66.249 E.01646
G1 X140.38 Y68.751 E.10894
G1 X139.846 Y68.751 E.01646
G1 X137.344 Y66.249 E.10894
G1 X136.82 Y66.249 E.01614
G1 X136.82 Y65.725 E.01614
G1 X116.344 Y45.249 E.89179
G1 X116.879 Y45.249 E.01646
G1 X136.82 Y65.191 E.86851
G1 X136.82 Y64.656 E.01646
G1 X117.413 Y45.249 E.84523
G1 X117.948 Y45.249 E.01646
G1 X136.82 Y64.122 E.82196
G1 X136.82 Y63.587 E.01646
G1 X118.482 Y45.249 E.79868
G1 X119.017 Y45.249 E.01646
G1 X136.82 Y63.053 E.7754
G1 X136.82 Y62.519 E.01646
G1 X119.551 Y45.249 E.75212
G1 X120.086 Y45.249 E.01646
G1 X136.82 Y61.984 E.72884
G1 X136.82 Y61.45 E.01646
G1 X120.62 Y45.249 E.70557
G1 X121.155 Y45.249 E.01646
G1 X136.82 Y60.915 E.68229
G1 X136.82 Y60.381 E.01646
G1 X121.689 Y45.249 E.65901
G1 X122.224 Y45.249 E.01646
G1 X136.82 Y59.846 E.63573
G1 X136.82 Y59.312 E.01646
G1 X122.758 Y45.249 E.61246
G1 X123.293 Y45.249 E.01646
G1 X136.82 Y58.777 E.58918
G1 X136.82 Y58.243 E.01646
G1 X123.827 Y45.249 E.5659
G1 X124.362 Y45.249 E.01646
G1 X136.82 Y57.708 E.54262
G1 X136.82 Y57.174 E.01646
G1 X124.896 Y45.249 E.51934
G1 X125.43 Y45.249 E.01646
G1 X136.82 Y56.639 E.49607
G1 X136.82 Y56.105 E.01646
G1 X125.965 Y45.249 E.47279
G1 X126.499 Y45.249 E.01646
G1 X136.82 Y55.57 E.44951
G1 X136.82 Y55.036 E.01646
G1 X127.034 Y45.249 E.42623
G1 X127.568 Y45.249 E.01646
G1 X136.82 Y54.501 E.40295
G1 X136.82 Y53.967 E.01646
G1 X128.103 Y45.249 E.37968
G1 X128.637 Y45.249 E.01646
G1 X136.82 Y53.432 E.3564
G1 X136.82 Y52.898 E.01646
G1 X129.172 Y45.249 E.33312
G1 X129.706 Y45.249 E.01646
G1 X136.82 Y52.364 E.30984
G1 X136.82 Y51.829 E.01646
G1 X130.241 Y45.249 E.28657
G1 X130.775 Y45.249 E.01646
G1 X136.82 Y51.295 E.26329
G1 X136.82 Y50.76 E.01646
G1 X131.31 Y45.249 E.24001
G1 X131.844 Y45.249 E.01646
G1 X136.82 Y50.226 E.21673
G1 X136.82 Y49.691 E.01646
G1 X132.379 Y45.249 E.19345
G1 X132.913 Y45.249 E.01646
G1 X136.82 Y49.157 E.17018
G1 X136.82 Y48.622 E.01646
G1 X133.448 Y45.249 E.1469
G1 X133.982 Y45.249 E.01646
G1 X136.82 Y48.088 E.12362
G1 X136.82 Y47.553 E.01646
G1 X134.517 Y45.249 E.10034
G1 X135.051 Y45.249 E.01646
G1 X137.052 Y47.251 E.08716
G1 X137.587 Y47.251 E.01646
G1 X135.585 Y45.249 E.08716
G1 X136.12 Y45.249 E.01646
G1 X138.121 Y47.251 E.08716
G1 X138.656 Y47.251 E.01646
G1 X136.654 Y45.249 E.08716
G1 X137.189 Y45.249 E.01646
G1 X139.19 Y47.251 E.08716
G1 X139.725 Y47.251 E.01646
G1 X137.723 Y45.249 E.08716
G1 X138.258 Y45.249 E.01646
G1 X140.259 Y47.251 E.08716
G1 X140.794 Y47.251 E.01646
G1 X138.792 Y45.249 E.08716
G1 X139.327 Y45.249 E.01646
G1 X140.82 Y46.743 E.06505
G1 X140.82 Y46.209 E.01646
G1 X139.861 Y45.249 E.04178
G1 X140.396 Y45.249 E.01646
G1 X140.99 Y45.844 E.02589
; WIPE_START
G1 X140.396 Y45.249 E-.31943
G1 X139.861 Y45.249 E-.2031
G1 X140.303 Y45.691 E-.23747
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.884 Y52.431 Z1.4 F42000
G1 X159.69 Y82.181 Z1.4
G1 Z1
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X159.258 Y81.749 E.01882
G1 X158.724 Y81.749 E.01646
G1 X159.52 Y82.546 E.0347
G1 X159.52 Y83.081 E.01646
G1 X158.189 Y81.749 E.05798
G1 X157.655 Y81.749 E.01646
G1 X159.52 Y83.615 E.08126
G1 X159.52 Y84.15 E.01646
G1 X157.12 Y81.749 E.10454
G1 X156.586 Y81.749 E.01646
G1 X159.52 Y84.684 E.12782
G1 X159.52 Y85.219 E.01646
G1 X156.051 Y81.749 E.15109
G1 X155.517 Y81.749 E.01646
G1 X159.52 Y85.753 E.17437
G1 X159.52 Y86.288 E.01646
G1 X154.982 Y81.749 E.19765
G1 X154.448 Y81.749 E.01646
G1 X159.52 Y86.822 E.22093
G1 X159.52 Y87.356 E.01646
G1 X153.913 Y81.749 E.2442
G1 X153.379 Y81.749 E.01646
G1 X159.52 Y87.891 E.26748
G1 X159.52 Y88.425 E.01646
G1 X152.844 Y81.749 E.29076
G1 X152.31 Y81.749 E.01646
G1 X159.52 Y88.96 E.31404
G1 X159.52 Y89.494 E.01646
G1 X151.775 Y81.749 E.33732
G1 X151.241 Y81.749 E.01646
G1 X159.52 Y90.029 E.36059
G1 X159.52 Y90.563 E.01646
G1 X150.707 Y81.749 E.38387
G1 X150.172 Y81.749 E.01646
G1 X159.52 Y91.098 E.40715
G1 X159.52 Y91.632 E.01646
G1 X149.638 Y81.749 E.43043
G1 X149.103 Y81.749 E.01646
G1 X159.52 Y92.167 E.45371
G1 X159.52 Y92.701 E.01646
G1 X148.926 Y82.107 E.46141
G3 X148.942 Y82.658 I-3.307 J.373 E.01699
G1 X159.52 Y93.236 E.4607
G1 X159.52 Y93.77 E.01646
G1 X148.881 Y83.13 E.46339
G3 X148.759 Y83.543 I-2.129 J-.402 E.01328
G1 X159.52 Y94.305 E.46868
G1 X159.52 Y94.839 E.01646
G1 X148.597 Y83.915 E.47576
G3 X148.396 Y84.249 I-4.197 J-2.3 E.012
G1 X159.52 Y95.374 E.48451
G1 X159.52 Y95.908 E.01646
G1 X148.157 Y84.544 E.49493
G3 X147.892 Y84.814 I-1.221 J-.935 E.01167
G1 X159.52 Y96.443 E.50647
G1 X159.52 Y96.977 E.01646
G1 X147.588 Y85.045 E.51968
G3 X147.251 Y85.242 I-1.158 J-1.588 E.01205
G1 X159.52 Y97.511 E.53435
G1 X159.52 Y98.046 E.01646
G1 X146.879 Y85.404 E.55059
G3 X146.458 Y85.518 I-1.214 J-3.638 E.01342
G1 X159.52 Y98.58 E.5689
G1 X159.52 Y99.115 E.01646
G1 X145.982 Y85.576 E.58964
G3 X145.419 Y85.548 I-.109 J-3.414 E.01738
G1 X159.52 Y99.649 E.61416
G1 X159.52 Y100.184 E.01646
G1 X144.693 Y85.357 E.64577
G3 X142.975 Y83.638 I1.177 J-2.895 E.07686
G1 X141.086 Y81.749 E.08227
G1 X141.62 Y81.749 E.01646
G1 X142.782 Y82.911 E.05059
G3 X142.755 Y82.349 I3.096 J-.432 E.01735
G1 X142.155 Y81.749 E.02613
G1 X142.689 Y81.749 E.01646
G1 X142.958 Y82.018 E.01171
; WIPE_START
G1 X142.689 Y81.749 E-.14453
G1 X142.155 Y81.749 E-.2031
G1 X142.755 Y82.349 E-.32237
G1 X142.748 Y82.48 E-.04977
G1 X142.757 Y82.586 E-.04024
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X144.272 Y80.978 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.11356
G1 F15000
M204 S6000
G1 X144.411 Y80.806 E.00128
M204 S10000
G1 X145.054 Y80.645 F42000
; LINE_WIDTH: 0.438933
G1 F15000
M204 S6000
G1 X145.419 Y80.589 E.01189
; LINE_WIDTH: 0.375022
G1 X145.794 Y80.565 E.01018
G1 X146.176 Y80.579 E.01035
; LINE_WIDTH: 0.409237
G1 X146.369 Y80.6 E.00578
; LINE_WIDTH: 0.444207
G3 X146.645 Y80.645 I-.769 J5.641 E.00917
M204 S10000
G1 X147.288 Y80.806 F42000
; LINE_WIDTH: 0.113535
G1 F15000
M204 S6000
G1 X147.427 Y80.978 E.00127
; WIPE_START
G1 X147.288 Y80.806 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.291 Y88.373 Z1.4 F42000
G1 X143.219 Y111.675 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X113.303 Y81.759 E1.30294
G3 X113.386 Y82.377 I-3.089 J.732 E.01924
G1 X142.931 Y111.922 E1.28677
G2 X142.812 Y112.337 I2.012 J.803 E.01333
G1 X113.361 Y82.886 E1.28266
G3 X113.27 Y83.329 I-2.258 J-.234 E.01396
G1 X142.756 Y112.815 E1.28418
G2 X142.779 Y113.373 I3.147 J.145 E.01724
G1 X113.129 Y83.723 E1.29135
G3 X112.946 Y84.074 I-1.85 J-.743 E.01222
G1 X143.34 Y114.469 E1.32377
M204 S10000
G1 X132.216 Y123.12 F42000
G1 F15000
M204 S6000
G1 X96.819 Y87.723 E1.54165
G1 X96.819 Y88.258 E.01646
G1 X131.512 Y122.951 E1.51098
G1 X130.978 Y122.951 E.01646
G1 X96.819 Y88.792 E1.4877
G1 X96.819 Y89.326 E.01646
G1 X130.443 Y122.951 E1.46443
G1 X129.909 Y122.951 E.01646
G1 X96.819 Y89.861 E1.44115
G1 X96.819 Y90.395 E.01646
G1 X129.374 Y122.951 E1.41787
G1 X128.84 Y122.951 E.01646
G1 X96.819 Y90.93 E1.39459
G1 X96.819 Y91.464 E.01646
G1 X128.305 Y122.951 E1.37132
G1 X127.771 Y122.951 E.01646
G1 X96.819 Y91.999 E1.34804
G1 X96.819 Y92.533 E.01646
G1 X127.236 Y122.951 E1.32476
G1 X126.702 Y122.951 E.01646
G1 X96.819 Y93.068 E1.30148
G1 X96.819 Y93.602 E.01646
G1 X126.168 Y122.951 E1.2782
G1 X125.633 Y122.951 E.01646
G1 X96.819 Y94.137 E1.25493
G1 X96.819 Y94.671 E.01646
G1 X125.099 Y122.951 E1.23165
G1 X124.564 Y122.951 E.01646
G1 X96.819 Y95.206 E1.20837
G1 X96.819 Y95.74 E.01646
G1 X111.031 Y109.952 E.61896
G2 X110.409 Y109.864 I-.75 J3.081 E.01937
G1 X96.819 Y96.275 E.59187
G1 X96.819 Y96.809 E.01646
G1 X109.894 Y109.884 E.56946
G2 X109.453 Y109.977 I.245 J2.252 E.01391
G1 X96.819 Y97.344 E.55024
G1 X96.819 Y97.878 E.01646
G1 X109.057 Y110.116 E.533
G2 X108.704 Y110.297 I1.865 J4.083 E.01224
G1 X96.819 Y98.413 E.5176
G1 X96.819 Y98.947 E.01646
G1 X108.387 Y110.515 E.50382
G2 X108.107 Y110.769 I.867 J1.24 E.01168
G1 X96.819 Y99.481 E.4916
G1 X96.819 Y100.016 E.01646
G1 X107.852 Y111.048 E.4805
G2 X107.634 Y111.365 I1.481 J1.25 E.01186
G1 X96.819 Y100.55 E.47102
G1 X96.819 Y101.085 E.01646
G1 X107.451 Y111.716 E.46303
M73 P55 R14
G2 X107.31 Y112.11 I3.737 J1.56 E.01288
G1 X96.819 Y101.619 E.45689
G1 X96.819 Y102.154 E.01646
G1 X107.218 Y112.553 E.45292
G2 X107.193 Y113.063 I3.217 J.414 E.01572
G1 X96.819 Y102.688 E.45183
G1 X96.819 Y103.223 E.01646
G1 X107.527 Y113.931 E.46637
; WIPE_START
G1 X106.113 Y112.517 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X109.319 Y115.723 Z1.4 F42000
G1 Z1
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X116.547 Y122.951 E.3148
G1 X117.081 Y122.951 E.01646
G1 X110.187 Y116.056 E.30028
G2 X110.699 Y116.033 I.086 J-3.841 E.01579
G1 X117.616 Y122.951 E.30127
G1 X118.15 Y122.951 E.01646
G1 X111.139 Y115.939 E.30537
G2 X111.534 Y115.8 I-.499 J-2.041 E.01292
G1 X118.685 Y122.951 E.31145
G1 X119.219 Y122.951 E.01646
G1 X111.886 Y115.617 E.3194
G2 X112.201 Y115.398 I-.938 J-1.688 E.01185
G1 X119.754 Y122.951 E.32894
G1 X120.288 Y122.951 E.01646
G1 X112.484 Y115.147 E.33988
G2 X112.736 Y114.864 I-1.288 J-1.4 E.01168
G1 X120.823 Y122.951 E.3522
G1 X121.357 Y122.951 E.01646
G1 X112.953 Y114.546 E.36603
G2 X113.132 Y114.191 I-1.681 J-1.072 E.01227
G1 X121.892 Y122.951 E.38149
G1 X122.426 Y122.951 E.01646
G1 X113.273 Y113.798 E.39864
G2 X113.361 Y113.351 I-1.747 J-.577 E.01405
G1 X122.961 Y122.951 E.41808
G1 X123.495 Y122.951 E.01646
G1 X113.385 Y112.841 E.44031
G2 X113.298 Y112.219 I-3.128 J.124 E.01939
G1 X124.199 Y123.12 E.4748
M204 S10000
G1 X116.182 Y123.12 F42000
G1 F15000
M204 S6000
G1 X96.819 Y103.757 E.84331
G1 X96.819 Y104.292 E.01646
G1 X115.478 Y122.951 E.81265
G1 X114.944 Y122.951 E.01646
G1 X96.819 Y104.826 E.78937
G1 X96.819 Y105.361 E.01646
G1 X114.409 Y122.951 E.76609
G1 X113.875 Y122.951 E.01646
G1 X96.819 Y105.895 E.74281
G1 X96.819 Y106.43 E.01646
G1 X113.34 Y122.951 E.71954
G1 X112.806 Y122.951 E.01646
G1 X96.819 Y106.964 E.69626
G1 X96.819 Y107.499 E.01646
G1 X112.271 Y122.951 E.67298
G1 X111.737 Y122.951 E.01646
G1 X96.819 Y108.033 E.6497
G1 X96.819 Y108.568 E.01646
G1 X111.202 Y122.951 E.62642
G1 X110.668 Y122.951 E.01646
G1 X96.819 Y109.102 E.60315
G1 X96.819 Y109.636 E.01646
G1 X110.133 Y122.951 E.57987
G1 X109.599 Y122.951 E.01646
G1 X96.819 Y110.171 E.55659
G1 X96.819 Y110.705 E.01646
G1 X109.064 Y122.951 E.53331
G1 X108.53 Y122.951 E.01646
G1 X96.819 Y111.24 E.51004
G1 X96.819 Y111.774 E.01646
G1 X107.995 Y122.951 E.48676
G1 X107.461 Y122.951 E.01646
G1 X96.819 Y112.309 E.46348
G1 X96.819 Y112.843 E.01646
G1 X106.926 Y122.951 E.4402
G1 X106.392 Y122.951 E.01646
G1 X96.819 Y113.378 E.41692
G1 X96.819 Y113.912 E.01646
G1 X105.858 Y122.951 E.39365
G1 X105.323 Y122.951 E.01646
G1 X102.059 Y119.687 E.14215
G3 X102.163 Y120.325 I-3.034 J.819 E.01993
G1 X104.789 Y122.951 E.11437
G1 X104.254 Y122.951 E.01646
G1 X102.149 Y120.846 E.09167
G1 X102.066 Y121.297 E.01412
G1 X103.72 Y122.951 E.07203
G1 X103.185 Y122.951 E.01646
G1 X101.928 Y121.694 E.05474
G3 X101.752 Y122.052 I-1.877 J-.702 E.01231
G1 X102.651 Y122.951 E.03914
G1 X102.116 Y122.951 E.01646
G1 X101.54 Y122.375 E.02508
G3 X101.291 Y122.66 I-1.549 J-1.1 E.01169
G1 X101.751 Y123.12 E.02003
M204 S10000
G1 X100.739 Y122.985 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.10407
G1 F15000
M204 S6000
G3 X100.611 Y123.061 I-.158 J-.118 E.00076
M204 S10000
G1 X99.87 Y123.225 F42000
; LINE_WIDTH: 0.506079
G1 F13602.261
M204 S6000
G3 X99.406 Y123.265 I-1.031 J-9.235 E.01759
; LINE_WIDTH: 0.479714
G1 F14423.281
G3 X98.573 Y123.253 I-.326 J-6.23 E.02967
; LINE_WIDTH: 0.517767
G1 F13267.451
G1 X98.271 Y123.219 E.01175
; WIPE_START
G1 X98.573 Y123.253 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.006 Y123.08 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; LINE_WIDTH: 0.402814
G1 F15000
M204 S6000
G1 X96.691 Y122.334 E.02377
M204 S10000
G1 X96.705 Y122.329 F42000
; LINE_WIDTH: 0.160401
G1 F15000
M204 S6000
G1 X96.977 Y123.08 E.00765
M204 S10000
G1 X96.69 Y122.815 F42000
; LINE_WIDTH: 0.134228
G1 F15000
M204 S6000
G1 X97.527 Y123.063 E.0065
M204 S10000
G1 X97.524 Y123.075 F42000
; LINE_WIDTH: 0.331629
G1 F15000
M204 S6000
G1 X96.69 Y122.783 E.0208
; WIPE_START
G1 X97.524 Y123.075 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.523 Y121.693 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; LINE_WIDTH: 0.436871
G1 F15000
M204 S6000
G1 X96.49 Y121.504 E.00616
; LINE_WIDTH: 0.405971
G1 X96.456 Y121.315 E.00568
; LINE_WIDTH: 0.371519
G1 X96.438 Y121.17 E.00391
; LINE_WIDTH: 0.337249
G1 X96.422 Y121.042 E.00309
; LINE_WIDTH: 0.300359
G1 X96.401 Y120.773 E.00567
; LINE_WIDTH: 0.272624
G1 X96.401 Y120.239 E.01
; LINE_WIDTH: 0.29846
G1 X96.42 Y119.971 E.00559
; LINE_WIDTH: 0.335578
G1 X96.438 Y119.83 E.0034
; LINE_WIDTH: 0.369298
G1 X96.454 Y119.702 E.00342
; LINE_WIDTH: 0.404547
G1 X96.49 Y119.495 E.00619
; LINE_WIDTH: 0.437185
G1 X96.523 Y119.305 E.00619
M204 S10000
G1 X96.69 Y118.655 F42000
; LINE_WIDTH: 0.106217
G1 F15000
M204 S6000
G1 X96.812 Y118.536 E.00088
M204 S10000
G1 X96.65 Y117.484 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X97.197 Y118.031 E.02385
G3 X97.516 Y117.816 I1.235 J1.485 E.01187
G1 X96.819 Y117.119 E.03035
G1 X96.819 Y116.585 E.01646
G1 X97.876 Y117.641 E.04601
G3 X98.275 Y117.506 I.876 J1.93 E.013
G1 X96.819 Y116.05 E.06339
G1 X96.819 Y115.516 E.01646
G1 X98.723 Y117.42 E.08292
G3 X99.244 Y117.406 I.33 J2.586 E.01606
G1 X96.819 Y114.981 E.10559
G1 X96.819 Y114.447 E.01646
G1 X100.146 Y117.773 E.14487
M204 S10000
G1 X109.297 Y85.235 F42000
G1 F15000
M204 S6000
G1 X159.52 Y135.459 E2.18739
G1 X159.52 Y135.994 E.01646
G1 X100.676 Y77.149 E2.56285
G1 X100.992 Y76.931 E.01183
G1 X107.282 Y83.22 E.27394
G3 X107.194 Y82.598 I3.04 J-.746 E.01938
G1 X101.274 Y76.678 E.25783
G2 X101.523 Y76.392 I-1.305 J-1.383 E.01169
G1 X107.217 Y82.086 E.24799
G3 X107.307 Y81.642 I2.259 J.227 E.01398
G1 X101.738 Y76.074 E.24251
G2 X101.92 Y75.721 I-1.675 J-1.085 E.01224
G1 X107.446 Y81.246 E.24066
G3 X107.628 Y80.895 I1.851 J.738 E.01223
G1 X102.057 Y75.323 E.24266
G2 X102.146 Y74.877 I-2.178 J-.666 E.01402
G1 X107.845 Y80.577 E.24824
G3 X108.094 Y80.292 I1.552 J1.104 E.01168
G1 X102.164 Y74.362 E.25827
G2 X102.071 Y73.734 I-3.101 J.139 E.01957
G1 X108.499 Y80.162 E.27993
; WIPE_START
G1 X107.085 Y78.747 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.62 Y77.153 Z1.4 F42000
G1 X96.912 Y76.574 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.121704
G1 F15000
M204 S6000
G1 X96.69 Y76.371 E.00194
M204 S10000
G1 X96.523 Y75.693 F42000
; LINE_WIDTH: 0.436874
G1 F15000
M204 S6000
G1 X96.49 Y75.504 E.00616
; LINE_WIDTH: 0.405981
G1 X96.456 Y75.315 E.00567
; LINE_WIDTH: 0.371532
G1 X96.438 Y75.17 E.00392
; LINE_WIDTH: 0.337274
G1 X96.422 Y75.043 E.00309
; LINE_WIDTH: 0.300379
G1 X96.401 Y74.773 E.00567
; LINE_WIDTH: 0.272624
G1 X96.401 Y74.239 E.01
; LINE_WIDTH: 0.298449
G1 X96.42 Y73.971 E.00559
; LINE_WIDTH: 0.335559
G1 X96.438 Y73.83 E.0034
; LINE_WIDTH: 0.369279
G1 X96.454 Y73.702 E.00342
; LINE_WIDTH: 0.40442
G1 X96.49 Y73.496 E.00616
; LINE_WIDTH: 0.43683
G1 X96.523 Y73.307 E.00616
M204 S10000
G1 X96.708 Y72.672 F42000
; LINE_WIDTH: 0.104415
G1 F15000
M204 S6000
G3 X96.765 Y72.579 I.126 J.013 E.00057
G1 X96.803 Y72.544 E.00026
M204 S10000
G1 X97.298 Y72.168 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X96.819 Y71.689 E.02086
G1 X96.819 Y71.154 E.01646
G1 X97.495 Y71.83 E.02942
G3 X97.85 Y71.651 I2.226 J3.985 E.01226
G1 X96.819 Y70.62 E.0449
G1 X96.819 Y70.085 E.01646
G1 X98.247 Y71.514 E.0622
G3 X98.69 Y71.422 I1.114 J4.281 E.01394
G1 X96.819 Y69.551 E.08149
G1 X96.819 Y69.016 E.01646
G1 X99.207 Y71.405 E.10402
G3 X99.834 Y71.497 I-.158 J3.249 E.01954
G1 X96.819 Y68.482 E.13132
G1 X96.819 Y67.948 E.01646
G1 X108.695 Y79.824 E.51724
G3 X109.048 Y79.642 I1.084 J1.67 E.01224
G1 X96.819 Y67.413 E.5326
G1 X96.819 Y66.879 E.01646
G1 X109.439 Y79.498 E.54962
G1 X109.882 Y79.407 E.01394
G1 X96.819 Y66.344 E.56893
G1 X96.819 Y65.81 E.01646
G1 X110.393 Y79.384 E.5912
G3 X111.011 Y79.467 I-.107 J3.123 E.01923
G1 X96.819 Y65.275 E.61811
G1 X96.819 Y64.741 E.01646
G1 X143.289 Y111.211 E2.02389
G3 X143.526 Y110.913 I1.309 J.801 E.01174
G1 X96.819 Y64.206 E2.03422
G1 X96.819 Y63.672 E.01646
G1 X143.79 Y110.642 E2.04571
G3 X144.091 Y110.409 I3.299 J3.932 E.01173
G1 X96.819 Y63.137 E2.0588
G1 X96.819 Y62.603 E.01646
G1 X144.426 Y110.209 E2.07339
G3 X144.797 Y110.046 I1.002 J1.771 E.01251
G1 X96.819 Y62.068 E2.08955
G1 X96.819 Y61.534 E.01646
G1 X145.212 Y109.927 E2.10766
G3 X145.686 Y109.866 I.542 J2.34 E.01473
G1 X96.819 Y60.999 E2.12828
G1 X96.819 Y60.465 E.01646
G1 X146.241 Y109.887 E2.15248
G3 X146.951 Y110.062 I-.419 J3.225 E.02255
G1 X96.819 Y59.93 E2.18337
G1 X96.819 Y59.396 E.01646
G1 X159.52 Y122.097 E2.73082
G1 X159.52 Y121.563 E.01646
G1 X96.819 Y58.861 E2.73082
G1 X96.819 Y58.327 E.01646
G1 X159.52 Y121.028 E2.73082
G1 X159.52 Y120.494 E.01646
G1 X96.819 Y57.793 E2.73082
G1 X96.819 Y57.258 E.01646
G1 X159.69 Y120.129 E2.73821
M204 S10000
G1 X159.69 Y122.801 F42000
G1 F15000
M204 S6000
G1 X148.744 Y111.856 E.47672
G3 X148.924 Y112.569 I-2.976 J1.127 E.02271
G1 X159.52 Y123.166 E.46152
G1 X159.52 Y123.701 E.01646
G1 X148.943 Y113.123 E.46067
G3 X148.884 Y113.598 I-3.866 J-.242 E.01475
G1 X159.52 Y124.235 E.46326
G1 X159.52 Y124.77 E.01646
G1 X148.763 Y114.012 E.46851
G3 X148.602 Y114.385 I-1.933 J-.617 E.01254
G1 X159.52 Y125.304 E.47555
G1 X159.52 Y125.839 E.01646
G1 X148.402 Y114.72 E.48422
G3 X148.163 Y115.016 I-1.348 J-.846 E.01173
G1 X159.382 Y126.234 E.48859
G1 X159.28 Y126.328 E.00425
G2 X158.245 Y125.632 I-2.256 J2.237 E.03869
G1 X147.9 Y115.287 E.45053
G3 X147.597 Y115.519 I-1.309 J-1.396 E.01176
G1 X157.512 Y125.434 E.43181
G2 X156.947 Y125.403 I-.473 J3.489 E.01745
G1 X147.261 Y115.717 E.42183
G3 X146.889 Y115.88 I-.995 J-1.773 E.01252
G1 X156.47 Y125.46 E.41726
G2 X156.048 Y125.573 I.795 J3.811 E.01345
G1 X146.471 Y115.996 E.41712
G3 X145.996 Y116.055 I-.535 J-2.35 E.01477
G1 X155.675 Y125.734 E.42154
G2 X155.337 Y125.931 I.817 J1.785 E.01205
G1 X145.436 Y116.03 E.43123
G3 X144.72 Y115.848 I.458 J-3.308 E.02281
G1 X155.033 Y126.162 E.44918
G2 X154.765 Y126.428 I3.603 J3.908 E.01164
G1 X112.728 Y84.391 E1.83082
G3 X112.473 Y84.671 I-1.236 J-.872 E.01168
G1 X154.53 Y126.727 E1.83167
G2 X154.327 Y127.059 I1.556 J1.175 E.012
G1 X112.193 Y84.925 E1.83508
G3 X111.877 Y85.143 I-1.247 J-1.468 E.01185
G1 X154.166 Y127.433 E1.84184
G2 X154.041 Y127.842 I1.504 J.685 E.01321
G1 X111.523 Y85.324 E1.85178
G3 X111.127 Y85.462 I-.893 J-1.915 E.01294
G1 X153.978 Y128.313 E1.86626
G2 X153.992 Y128.861 I3.418 J.187 E.01691
G1 X110.686 Y85.556 E1.88608
G3 X110.172 Y85.576 I-.419 J-4.131 E.01586
G1 X154.161 Y129.565 E1.91587
G2 X156.006 Y131.411 I2.884 J-1.039 E.08302
G1 X159.52 Y134.925 E.15305
G1 X159.52 Y134.39 E.01646
G1 X156.707 Y131.576 E.12255
G2 X157.257 Y131.592 I.366 J-3.128 E.01698
G1 X159.52 Y133.856 E.09857
G1 X159.52 Y133.321 E.01646
G1 X157.729 Y131.529 E.07804
G2 X158.141 Y131.407 I-.933 J-3.911 E.01325
G1 X159.52 Y132.787 E.06008
G1 X159.52 Y132.252 E.01646
G1 X158.511 Y131.242 E.04398
G2 X158.844 Y131.042 I-.839 J-1.771 E.01201
G1 X159.52 Y131.718 E.02945
G1 X159.52 Y131.183 E.01646
G1 X159.023 Y130.685 E.02168
M204 S10000
G1 X159.512 Y130.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.109494
G1 F15000
M204 S6000
G2 X159.631 Y130.046 I-.159 J-.233 E.00122
M204 S10000
G1 X159.791 Y129.297 F42000
; LINE_WIDTH: 0.507998
G1 F13546.113
M204 S6000
G1 X159.839 Y128.762 E.02036
; LINE_WIDTH: 0.472723
M73 P56 R14
G1 F14657.877
G2 X159.838 Y128.212 I-7.951 J-.258 E.01926
; LINE_WIDTH: 0.512464
G1 F13417.285
G2 X159.817 Y127.935 I-6.317 J.345 E.01062
G1 X159.524 Y127.756 E.01315
M204 S10000
G1 X159.65 Y126.905 F42000
; LINE_WIDTH: 0.140569
G1 F15000
M204 S6000
G1 X159.561 Y126.799 E.0011
; LINE_WIDTH: 0.114429
G1 X159.423 Y126.65 E.00118
; WIPE_START
G1 X159.561 Y126.799 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X159.661 Y134.431 Z1.4 F42000
G1 X159.69 Y136.698 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X100.327 Y77.334 E2.58544
G3 X99.933 Y77.475 I-.901 J-1.902 E.0129
G1 X159.52 Y137.063 E2.5952
G1 X159.52 Y137.597 E.01646
G1 X99.494 Y77.571 E2.61432
G3 X98.986 Y77.597 I-.436 J-3.559 E.0157
G1 X159.52 Y138.131 E2.63647
G1 X159.52 Y138.666 E.01646
G1 X98.373 Y77.518 E2.66315
G3 X97.478 Y77.158 I.554 J-2.666 E.02987
G1 X159.52 Y139.2 E2.70213
G1 X159.52 Y139.735 E.01646
G1 X96.819 Y77.034 E2.73082
G1 X96.819 Y77.568 E.01646
G1 X159.52 Y140.269 E2.73082
G1 X159.52 Y140.804 E.01646
G1 X96.819 Y78.103 E2.73082
G1 X96.819 Y78.637 E.01646
G1 X159.52 Y141.338 E2.73082
G1 X159.52 Y141.873 E.01646
G1 X96.819 Y79.171 E2.73082
G1 X96.819 Y79.706 E.01646
G1 X159.52 Y142.407 E2.73082
G1 X159.52 Y142.942 E.01646
G1 X96.819 Y80.24 E2.73082
G1 X96.819 Y80.775 E.01646
G1 X159.52 Y143.476 E2.73082
G1 X159.52 Y144.011 E.01646
G1 X96.819 Y81.309 E2.73082
G1 X96.819 Y81.844 E.01646
G1 X159.52 Y144.545 E2.73082
G1 X159.52 Y145.08 E.01646
G1 X96.819 Y82.378 E2.73082
G1 X96.819 Y82.913 E.01646
G1 X159.52 Y145.614 E2.73082
G1 X159.52 Y146.149 E.01646
G1 X96.819 Y83.447 E2.73082
G1 X96.819 Y83.982 E.01646
G1 X159.52 Y146.683 E2.73082
G1 X159.52 Y147.218 E.01646
G1 X96.819 Y84.516 E2.73082
G1 X96.819 Y85.051 E.01646
G1 X159.52 Y147.752 E2.73082
G1 X159.52 Y148.286 E.01646
G1 X96.819 Y85.585 E2.73082
G1 X96.819 Y86.12 E.01646
G1 X159.52 Y148.821 E2.73082
G1 X159.52 Y149.355 E.01646
G1 X96.819 Y86.654 E2.73082
G1 X96.819 Y87.189 E.01646
G1 X159.52 Y149.89 E2.73082
G1 X159.52 Y150.424 E.01646
G1 X132.819 Y123.723 E1.16292
G1 X132.819 Y124.258 E.01646
G1 X159.52 Y150.959 E1.16292
G1 X159.52 Y151.493 E.01646
G1 X132.819 Y124.792 E1.16292
G1 X132.819 Y125.326 E.01646
G1 X159.52 Y152.028 E1.16292
G1 X159.52 Y152.562 E.01646
G1 X132.819 Y125.861 E1.16292
G1 X132.819 Y126.395 E.01646
G1 X159.52 Y153.097 E1.16292
G1 X159.52 Y153.631 E.01646
G1 X132.819 Y126.93 E1.16292
G1 X132.819 Y127.464 E.01646
G1 X159.52 Y154.166 E1.16292
G1 X159.52 Y154.7 E.01646
G1 X132.819 Y127.999 E1.16292
G1 X132.819 Y128.533 E.01646
G1 X159.52 Y155.235 E1.16292
G1 X159.52 Y155.769 E.01646
G1 X132.819 Y129.068 E1.16292
G1 X132.819 Y129.602 E.01646
G1 X159.52 Y156.304 E1.16292
G1 X159.52 Y156.838 E.01646
G1 X132.819 Y130.137 E1.16292
G1 X132.819 Y130.671 E.01646
G1 X159.52 Y157.373 E1.16292
G1 X159.52 Y157.907 E.01646
G1 X132.819 Y131.206 E1.16292
G1 X132.819 Y131.74 E.01646
G1 X159.52 Y158.441 E1.16292
G1 X159.52 Y158.976 E.01646
G1 X132.819 Y132.275 E1.16292
G1 X132.819 Y132.809 E.01646
G1 X159.52 Y159.51 E1.16292
G1 X159.52 Y160.045 E.01646
G1 X132.819 Y133.344 E1.16292
G1 X132.819 Y133.878 E.01646
G1 X159.52 Y160.579 E1.16292
G1 X159.52 Y161.114 E.01646
G1 X132.819 Y134.413 E1.16292
G1 X132.819 Y134.947 E.01646
G1 X159.52 Y161.648 E1.16292
G1 X159.52 Y162.183 E.01646
G1 X132.819 Y135.481 E1.16292
G1 X132.819 Y136.016 E.01646
G1 X159.52 Y162.717 E1.16292
G1 X159.52 Y163.252 E.01646
G1 X132.819 Y136.55 E1.16292
G1 X132.819 Y137.085 E.01646
G1 X159.52 Y163.786 E1.16292
G1 X159.52 Y164.321 E.01646
G1 X132.819 Y137.619 E1.16292
G1 X132.819 Y138.154 E.01646
G1 X159.52 Y164.855 E1.16292
G1 X159.52 Y165.39 E.01646
G1 X132.819 Y138.688 E1.16292
G1 X132.819 Y139.223 E.01646
G1 X159.52 Y165.924 E1.16292
G1 X159.52 Y166.459 E.01646
G1 X132.819 Y139.757 E1.16292
G1 X132.819 Y140.292 E.01646
G1 X159.52 Y166.993 E1.16292
G1 X159.52 Y167.528 E.01646
G1 X132.819 Y140.826 E1.16292
G1 X132.819 Y141.361 E.01646
G1 X159.52 Y168.062 E1.16292
G1 X159.52 Y168.596 E.01646
G1 X132.819 Y141.895 E1.16292
G1 X132.819 Y142.43 E.01646
G1 X159.52 Y169.131 E1.16292
G1 X159.52 Y169.665 E.01646
G1 X132.819 Y142.964 E1.16292
G1 X132.819 Y143.499 E.01646
G1 X159.52 Y170.2 E1.16292
G1 X159.52 Y170.734 E.01646
G1 X132.819 Y144.033 E1.16292
G1 X132.819 Y144.568 E.01646
G1 X159.52 Y171.269 E1.16292
G1 X159.52 Y171.803 E.01646
G1 X132.819 Y145.102 E1.16292
G1 X132.819 Y145.636 E.01646
G1 X159.52 Y172.338 E1.16292
M73 P56 R13
G1 X159.52 Y172.872 E.01646
G1 X132.819 Y146.171 E1.16292
G1 X132.819 Y146.705 E.01646
G1 X159.52 Y173.407 E1.16292
G1 X159.52 Y173.941 E.01646
G1 X132.819 Y147.24 E1.16292
G1 X132.819 Y147.774 E.01646
G1 X159.52 Y174.476 E1.16292
G1 X159.52 Y175.01 E.01646
G1 X132.819 Y148.309 E1.16292
G1 X132.819 Y148.843 E.01646
G1 X159.52 Y175.545 E1.16292
G1 X159.52 Y176.079 E.01646
G1 X132.819 Y149.378 E1.16292
M73 P57 R13
G1 X132.819 Y149.912 E.01646
G1 X159.52 Y176.614 E1.16292
G1 X159.52 Y177.148 E.01646
G1 X132.819 Y150.447 E1.16292
G1 X132.819 Y150.981 E.01646
G1 X159.52 Y177.683 E1.16292
G1 X159.52 Y178.217 E.01646
G1 X132.819 Y151.516 E1.16292
G1 X132.819 Y152.05 E.01646
G1 X159.52 Y178.751 E1.16292
G1 X159.52 Y179.286 E.01646
G1 X132.819 Y152.585 E1.16292
G1 X132.819 Y153.119 E.01646
G1 X159.52 Y179.82 E1.16292
G1 X159.52 Y180.355 E.01646
G1 X132.819 Y153.654 E1.16292
G1 X132.819 Y154.188 E.01646
G1 X159.52 Y180.889 E1.16292
G1 X159.52 Y181.424 E.01646
G1 X132.819 Y154.723 E1.16292
G1 X132.819 Y155.257 E.01646
G1 X159.52 Y181.958 E1.16292
G1 X159.52 Y182.493 E.01646
G1 X132.819 Y155.792 E1.16292
G1 X132.819 Y156.326 E.01646
G1 X159.52 Y183.027 E1.16292
G1 X159.52 Y183.562 E.01646
G1 X132.819 Y156.86 E1.16292
G1 X132.819 Y157.395 E.01646
G1 X159.52 Y184.096 E1.16292
G1 X159.52 Y184.631 E.01646
G1 X132.819 Y157.929 E1.16292
G1 X132.819 Y158.464 E.01646
G1 X159.52 Y185.165 E1.16292
G1 X159.52 Y185.7 E.01646
G1 X132.819 Y158.998 E1.16292
G1 X132.819 Y159.533 E.01646
G1 X159.52 Y186.234 E1.16292
G1 X159.52 Y186.769 E.01646
G1 X132.819 Y160.067 E1.16292
G1 X132.819 Y160.602 E.01646
G1 X159.52 Y187.303 E1.16292
G1 X159.52 Y187.838 E.01646
G1 X132.819 Y161.136 E1.16292
G1 X132.819 Y161.671 E.01646
G1 X159.52 Y188.372 E1.16292
G1 X159.52 Y188.906 E.01646
G1 X132.819 Y162.205 E1.16292
G1 X132.819 Y162.74 E.01646
G1 X159.52 Y189.441 E1.16292
G1 X159.52 Y189.975 E.01646
G1 X132.819 Y163.274 E1.16292
G1 X132.819 Y163.809 E.01646
G1 X159.52 Y190.51 E1.16292
G1 X159.52 Y191.044 E.01646
G1 X132.819 Y164.343 E1.16292
G1 X132.819 Y164.878 E.01646
G1 X159.52 Y191.579 E1.16292
G1 X159.52 Y192.113 E.01646
G1 X132.819 Y165.412 E1.16292
G1 X132.819 Y165.947 E.01646
G1 X159.52 Y192.648 E1.16292
G1 X159.52 Y193.182 E.01646
G1 X132.819 Y166.481 E1.16292
G1 X132.819 Y167.015 E.01646
G1 X159.52 Y193.717 E1.16292
G1 X159.52 Y194.251 E.01646
G1 X132.819 Y167.55 E1.16292
G1 X132.819 Y168.084 E.01646
G1 X159.52 Y194.786 E1.16292
G1 X159.52 Y195.32 E.01646
G1 X132.819 Y168.619 E1.16292
G1 X132.819 Y169.153 E.01646
G1 X159.52 Y195.855 E1.16292
G1 X159.52 Y196.389 E.01646
G1 X132.819 Y169.688 E1.16292
G1 X132.819 Y170.222 E.01646
G1 X159.52 Y196.924 E1.16292
G1 X159.52 Y197.458 E.01646
G1 X132.819 Y170.757 E1.16292
G1 X132.819 Y171.291 E.01646
G1 X159.52 Y197.993 E1.16292
G1 X159.52 Y198.527 E.01646
G1 X132.819 Y171.826 E1.16292
G1 X132.819 Y172.36 E.01646
G1 X159.52 Y199.061 E1.16292
G1 X159.52 Y199.596 E.01646
G1 X132.819 Y172.895 E1.16292
G1 X132.819 Y173.429 E.01646
G1 X159.52 Y200.13 E1.16292
G1 X159.52 Y200.665 E.01646
G1 X132.819 Y173.964 E1.16292
G1 X132.819 Y174.498 E.01646
G1 X159.52 Y201.199 E1.16292
G1 X159.52 Y201.734 E.01646
G1 X132.819 Y175.033 E1.16292
G1 X132.819 Y175.567 E.01646
G1 X159.52 Y202.268 E1.16292
G1 X159.52 Y202.803 E.01646
G1 X132.819 Y176.102 E1.16292
G1 X132.819 Y176.636 E.01646
G1 X159.52 Y203.337 E1.16292
G1 X159.52 Y203.872 E.01646
G1 X132.819 Y177.17 E1.16292
G1 X132.819 Y177.705 E.01646
G1 X159.52 Y204.406 E1.16292
G1 X159.52 Y204.941 E.01646
G1 X132.819 Y178.239 E1.16292
G1 X132.819 Y178.774 E.01646
G1 X159.52 Y205.475 E1.16292
G1 X159.52 Y206.01 E.01646
G1 X132.819 Y179.308 E1.16292
G1 X132.819 Y179.843 E.01646
G1 X159.52 Y206.544 E1.16292
G1 X159.52 Y207.079 E.01646
G1 X132.819 Y180.377 E1.16292
G1 X132.819 Y180.912 E.01646
G1 X159.52 Y207.613 E1.16292
G1 X159.52 Y208.148 E.01646
G1 X132.819 Y181.446 E1.16292
G1 X132.819 Y181.981 E.01646
G1 X159.52 Y208.682 E1.16292
G1 X159.52 Y209.216 E.01646
G1 X132.819 Y182.515 E1.16292
G1 X132.819 Y183.05 E.01646
G1 X159.52 Y209.751 E1.16292
G1 X159.52 Y210.285 E.01646
G1 X132.819 Y183.584 E1.16292
G1 X132.819 Y184.119 E.01646
G1 X159.451 Y210.751 E1.1599
G1 X158.917 Y210.751 E.01646
G1 X132.819 Y184.653 E1.13662
G1 X132.819 Y185.188 E.01646
G1 X158.382 Y210.751 E1.11334
G1 X157.848 Y210.751 E.01646
G1 X132.819 Y185.722 E1.09007
G1 X132.819 Y186.257 E.01646
G1 X157.313 Y210.751 E1.06679
G1 X156.779 Y210.751 E.01646
G1 X132.819 Y186.791 E1.04351
G1 X132.819 Y187.325 E.01646
G1 X156.244 Y210.751 E1.02023
G1 X155.71 Y210.751 E.01646
G1 X132.819 Y187.86 E.99696
G1 X132.819 Y188.394 E.01646
G1 X155.175 Y210.751 E.97368
G1 X154.641 Y210.751 E.01646
G1 X132.819 Y188.929 E.9504
G1 X132.819 Y189.463 E.01646
G1 X154.106 Y210.751 E.92712
G1 X153.572 Y210.751 E.01646
G1 X132.819 Y189.998 E.90384
G1 X132.819 Y190.532 E.01646
G1 X153.038 Y210.751 E.88057
G1 X152.503 Y210.751 E.01646
G1 X132.819 Y191.067 E.85729
G1 X132.819 Y191.601 E.01646
G1 X151.969 Y210.751 E.83401
G1 X151.434 Y210.751 E.01646
G1 X132.819 Y192.136 E.81073
G1 X132.819 Y192.67 E.01646
G1 X150.9 Y210.751 E.78745
G1 X150.365 Y210.751 E.01646
G1 X132.819 Y193.205 E.76418
G1 X132.819 Y193.739 E.01646
G1 X149.831 Y210.751 E.7409
G1 X149.296 Y210.751 E.01646
G1 X132.819 Y194.274 E.71762
G1 X132.819 Y194.808 E.01646
G1 X148.762 Y210.751 E.69434
G1 X148.227 Y210.751 E.01646
G1 X132.819 Y195.343 E.67107
G1 X132.819 Y195.877 E.01646
G1 X147.693 Y210.751 E.64779
G1 X147.158 Y210.751 E.01646
G1 X132.819 Y196.412 E.62451
G1 X132.819 Y196.946 E.01646
G1 X146.624 Y210.751 E.60123
G1 X146.089 Y210.751 E.01646
G1 X132.819 Y197.48 E.57795
G1 X132.819 Y198.015 E.01646
G1 X145.555 Y210.751 E.55468
G1 X145.02 Y210.751 E.01646
G1 X132.819 Y198.549 E.5314
G1 X132.819 Y199.084 E.01646
G1 X144.486 Y210.751 E.50812
G1 X143.951 Y210.751 E.01646
G1 X132.819 Y199.618 E.48484
G1 X132.819 Y200.153 E.01646
G1 X143.417 Y210.751 E.46157
G1 X142.883 Y210.751 E.01646
G1 X132.819 Y200.687 E.43829
M73 P58 R13
G1 X132.819 Y201.222 E.01646
G1 X142.348 Y210.751 E.41501
G1 X141.814 Y210.751 E.01646
G1 X132.819 Y201.756 E.39173
G1 X132.819 Y202.291 E.01646
G1 X136.11 Y205.582 E.14333
G2 X135.415 Y205.421 I-1.053 J2.978 E.022
G1 X132.819 Y202.825 E.11307
G1 X132.819 Y203.36 E.01646
G1 X134.868 Y205.409 E.08924
G2 X134.398 Y205.473 I.086 J2.381 E.01464
G1 X132.819 Y203.894 E.06876
G1 X132.819 Y204.429 E.01646
G1 X133.988 Y205.597 E.05089
G2 X133.619 Y205.763 I.645 J1.927 E.01247
G1 X132.819 Y204.963 E.03483
G1 X132.819 Y205.498 E.01646
G1 X133.286 Y205.964 E.02033
G2 X132.996 Y206.209 I.715 J1.143 E.01172
G1 X132.65 Y205.862 E.01509
M204 S10000
G1 X132.803 Y206.543 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.104446
G1 F15000
M204 S6000
G1 X132.765 Y206.579 E.00026
G2 X132.708 Y206.672 I.068 J.106 E.00057
M204 S10000
G1 X132.523 Y207.307 F42000
; LINE_WIDTH: 0.436849
G1 F15000
M204 S6000
G1 X132.49 Y207.496 E.00616
; LINE_WIDTH: 0.404439
G1 X132.454 Y207.702 E.00616
; LINE_WIDTH: 0.369278
G1 X132.438 Y207.83 E.00342
; LINE_WIDTH: 0.335545
G1 X132.42 Y207.971 E.0034
; LINE_WIDTH: 0.298429
G1 X132.401 Y208.239 E.00559
; LINE_WIDTH: 0.272604
G1 X132.401 Y208.773 E.01
; LINE_WIDTH: 0.300349
G1 X132.422 Y209.043 E.00567
; LINE_WIDTH: 0.337216
G1 X132.438 Y209.17 E.00309
; LINE_WIDTH: 0.371443
G1 X132.456 Y209.315 E.00391
; LINE_WIDTH: 0.40588
G1 X132.49 Y209.504 E.00568
; LINE_WIDTH: 0.436827
G1 X132.523 Y209.693 E.00616
; WIPE_START
G1 X132.49 Y209.504 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.883 Y210.671 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.38674
G1 F15000
M204 S6000
G1 X132.819 Y210.708 E.00209
G1 X132.868 Y210.737 E.00161
; WIPE_START
G1 X132.819 Y210.708 E-.33089
G1 X132.883 Y210.671 E-.42911
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X133.938 Y210.81 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.422666
G1 F15000
M204 S6000
G1 X134.076 Y211.083 E.00947
G1 X134.2 Y211.103 E.00387
; LINE_WIDTH: 0.390678
G1 X134.323 Y211.124 E.00354
; LINE_WIDTH: 0.353485
G1 X134.467 Y211.14 E.00368
; LINE_WIDTH: 0.322723
G1 X134.595 Y211.155 E.00294
; LINE_WIDTH: 0.279194
G1 X134.875 Y211.172 E.0054
G1 X135.398 Y211.166 E.01006
; LINE_WIDTH: 0.309161
G1 X135.666 Y211.142 E.00584
; LINE_WIDTH: 0.351572
G1 X135.808 Y211.123 E.00361
; LINE_WIDTH: 0.388802
G1 X135.936 Y211.106 E.00364
; LINE_WIDTH: 0.431387
G2 X136.264 Y211.044 I-1.059 J-6.539 E.01056
; WIPE_START
G1 X135.936 Y211.106 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X137.707 Y210.92 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42085
G1 F15000
M204 S6000
G1 X137.368 Y210.581 E.0148
G2 X137.604 Y210.282 I-1.371 J-1.328 E.01174
G1 X138.072 Y210.751 E.0204
G1 X138.607 Y210.751 E.01646
G1 X137.807 Y209.951 E.03483
G2 X137.975 Y209.584 I-1.751 J-1.021 E.01244
G1 X139.141 Y210.751 E.05081
G1 X139.676 Y210.751 E.01646
G1 X138.092 Y209.167 E.06896
G2 X138.161 Y208.702 I-1.816 J-.507 E.01453
G1 X140.21 Y210.751 E.08923
G1 X140.745 Y210.751 E.01646
G1 X138.151 Y208.157 E.11297
G2 X137.987 Y207.459 I-3.229 J.388 E.02212
G1 X141.449 Y210.92 E.15075
; OBJECT_ID: 124
; WIPE_START
G1 X140.035 Y209.506 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G1 X135.718 Y203.212 Z1.4 F42000
G1 X106.723 Y160.935 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X106.753 Y161.239 E.00942
G3 X105.061 Y159.705 I-1.559 J.019 E.22225
G1 X105.208 Y159.699 E.00453
G3 X106.706 Y160.878 I-.014 J1.559 E.06303
; WIPE_START
M204 S6000
G1 X106.753 Y161.239 E-.13856
G1 X106.751 Y161.395 E-.05908
G1 X106.693 Y161.7 E-.11799
G1 X106.576 Y161.988 E-.11813
G1 X106.405 Y162.247 E-.11799
G1 X106.185 Y162.467 E-.11813
G1 X105.987 Y162.598 E-.09011
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.149 Y163.546 Z1.4 F42000
G1 Z1
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X104.715 Y163.498 E.01342
G3 X105.225 Y158.969 I.477 J-2.239 E.20725
G1 X105.331 Y158.973 E.00323
G3 X105.209 Y163.548 I-.138 J2.285 E.21626
M204 S10000
G1 X105.177 Y163.183 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381163
G1 F15000
M204 S6000
G1 X105.173 Y163.183 E.00012
G3 X103.272 Y161.291 I.024 J-1.924 E.08178
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.513 J.043 E.00482
G3 X105.555 Y163.15 I1.918 J.159 E.23564
G1 X105.237 Y163.178 E.0088
; OBJECT_ID: 102
; WIPE_START
G1 X105.173 Y163.183 E-.02437
G1 X104.867 Y163.155 E-.11668
G1 X104.508 Y163.056 E-.14143
G1 X104.173 Y162.889 E-.1425
G1 X103.87 Y162.654 E-.14574
G1 X103.62 Y162.363 E-.14569
G1 X103.564 Y162.263 E-.0436
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.055 Y154.646 Z1.4 F42000
G1 X104.067 Y154.458 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X104.098 Y154.763 E.00942
G3 X102.405 Y153.228 I-1.559 J.019 E.22225
G1 X102.553 Y153.222 E.00453
G3 X104.051 Y154.401 I-.014 J1.559 E.06303
; WIPE_START
M204 S6000
G1 X104.098 Y154.763 E-.13856
G1 X104.096 Y154.918 E-.05908
G1 X104.038 Y155.223 E-.11799
G1 X103.921 Y155.511 E-.11813
G1 X103.749 Y155.77 E-.11799
G1 X103.529 Y155.99 E-.11813
G1 X103.332 Y156.121 E-.09011
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.493 Y157.07 Z1.4 F42000
G1 Z1
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X102.06 Y157.021 E.01342
G3 X102.57 Y152.492 I.477 J-2.239 E.20725
G1 X102.675 Y152.496 E.00323
G3 X102.553 Y157.071 I-.138 J2.285 E.21626
M204 S10000
G1 X102.521 Y156.707 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381163
G1 F15000
M204 S6000
G1 X102.517 Y156.706 E.00012
G3 X100.617 Y154.814 I.024 J-1.924 E.08178
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.513 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23564
G1 X102.581 Y156.701 E.0088
; OBJECT_ID: 91
; WIPE_START
G1 X102.517 Y156.706 E-.02437
G1 X102.211 Y156.678 E-.11668
G1 X101.853 Y156.58 E-.14143
G1 X101.517 Y156.412 E-.1425
G1 X101.214 Y156.177 E-.14574
G1 X100.964 Y155.886 E-.14569
G1 X100.908 Y155.786 E-.0436
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.17 Z1.4 F42000
G1 X101.411 Y147.981 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X101.442 Y148.286 E.00942
G3 X99.75 Y146.751 I-1.559 J.019 E.22225
G1 X99.897 Y146.745 E.00453
G3 X101.395 Y147.924 I-.014 J1.559 E.06303
; WIPE_START
M204 S6000
G1 X101.442 Y148.286 E-.13856
G1 X101.44 Y148.441 E-.05908
G1 X101.382 Y148.747 E-.11799
G1 X101.265 Y149.035 E-.11813
G1 X101.093 Y149.293 E-.11799
G1 X100.874 Y149.513 E-.11813
G1 X100.676 Y149.644 E-.09011
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.838 Y150.593 Z1.4 F42000
G1 Z1
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X99.404 Y150.544 E.01342
G3 X99.914 Y146.016 I.477 J-2.239 E.20725
G1 X100.019 Y146.02 E.00323
G3 X99.898 Y150.594 I-.138 J2.285 E.21626
M204 S10000
G1 X99.866 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381163
G1 F15000
M204 S6000
G1 X99.862 Y150.23 E.00012
G3 X97.961 Y148.338 I.024 J-1.924 E.08178
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.513 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.23564
G1 X99.926 Y150.225 E.0088
; OBJECT_ID: 113
; WIPE_START
G1 X99.862 Y150.23 E-.02437
G1 X99.556 Y150.202 E-.11668
G1 X99.197 Y150.103 E-.14143
G1 X98.861 Y149.936 E-.1425
G1 X98.559 Y149.7 E-.14574
G1 X98.309 Y149.41 E-.14569
G1 X98.252 Y149.309 E-.0436
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.744 Y141.693 Z1.4 F42000
G1 X98.756 Y141.504 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X98.786 Y141.809 E.00942
G3 X97.094 Y140.274 I-1.559 J.019 E.22225
G1 X97.241 Y140.269 E.00453
G3 X98.739 Y141.448 I-.014 J1.559 E.06303
; WIPE_START
M204 S6000
G1 X98.786 Y141.809 E-.13856
G1 X98.784 Y141.965 E-.05908
G1 X98.727 Y142.27 E-.11799
G1 X98.609 Y142.558 E-.11813
G1 X98.438 Y142.817 E-.11799
G1 X98.218 Y143.036 E-.11813
G1 X98.02 Y143.167 E-.09011
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.182 Y144.116 Z1.4 F42000
G1 Z1
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X96.748 Y144.067 E.01342
G3 X97.259 Y139.539 I.477 J-2.239 E.20725
G1 X97.364 Y139.543 E.00323
G3 X97.242 Y144.118 I-.138 J2.285 E.21626
M204 S10000
G1 X97.21 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381163
G1 F15000
M204 S6000
G1 X97.206 Y143.753 E.00012
G3 X95.305 Y141.861 I.024 J-1.924 E.08178
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.513 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23564
G1 X97.27 Y143.748 E.0088
; CHANGE_LAYER
; Z_HEIGHT: 1.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02437
G1 X96.9 Y143.725 E-.11668
G1 X96.541 Y143.626 E-.14143
G1 X96.206 Y143.459 E-.1425
G1 X95.903 Y143.223 E-.14574
G1 X95.653 Y142.933 E-.14569
G1 X95.597 Y142.833 E-.0436
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 6/60
; update layer progress
M73 L6
M991 S0 P5 ;notify layer change
; OBJECT_ID: 80
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
M204 S10000
G17
G3 Z1.4 I.938 J.776 P1  F42000
G1 X144.67 Y83.493 Z1.4
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.52 Y83.293 E.00769
G3 X145.656 Y80.932 I1.33 J-.814 E.09559
G1 X145.811 Y80.92 E.00478
G3 X144.707 Y83.54 I.039 J1.559 E.19112
; WIPE_START
M204 S6000
G1 X144.52 Y83.293 E-.11793
G1 X144.384 Y83.014 E-.11799
G1 X144.307 Y82.713 E-.11807
G1 X144.292 Y82.402 E-.1181
G1 X144.338 Y82.095 E-.11805
G1 X144.444 Y81.803 E-.11811
G1 X144.515 Y81.687 E-.05175
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.205 Y89.13 Z1.6 F42000
G1 X155.548 Y130.293 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X155.454 Y130.217 E.00403
G3 X156.776 Y126.158 I1.616 J-1.718 E.17699
G1 X157.011 Y126.14 E.00782
G3 X155.791 Y130.48 I.059 J2.358 E.29263
G1 X155.596 Y130.33 E.00817
M204 S10000
G1 X155.799 Y129.974 F42000
G1 F15476.087
M204 S6000
G1 X155.732 Y129.92 E.00288
G3 X156.827 Y126.562 I1.338 J-1.421 E.1464
G1 X157.021 Y126.548 E.00647
G3 X156.011 Y130.138 I.049 J1.951 E.2421
G1 X155.847 Y130.011 E.00691
M204 S250
G1 X156.041 Y129.667 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X156 Y129.633 E.00164
G3 X156.876 Y126.952 I1.07 J-1.134 E.10831
G1 X157.031 Y126.94 E.00479
G3 X156.224 Y129.809 I.039 J1.559 E.17918
G1 X156.088 Y129.704 E.00528
; WIPE_START
M204 S6000
G1 X156 Y129.633 E-.04307
G1 X155.826 Y129.442 E-.09816
G1 X155.664 Y129.177 E-.11804
G1 X155.558 Y128.885 E-.11811
G1 X155.512 Y128.578 E-.11808
G1 X155.527 Y128.268 E-.11803
G1 X155.604 Y127.966 E-.11817
G1 X155.636 Y127.899 E-.02833
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.043 Y127.123 Z1.6 F42000
G1 X96.658 Y121.87 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X96.863 Y122.171 E.01208
G2 X98.09 Y123.091 I2.436 J-1.971 E.05138
G1 X98.049 Y123.284 E.00654
G1 X96.486 Y123.284 E.05184
G1 X96.486 Y121.924 E.04512
G1 X96.601 Y121.888 E.00399
; WIPE_START
G1 X96.863 Y122.171 E-.14671
G1 X97.035 Y122.376 E-.10131
G1 X97.347 Y122.666 E-.16198
G1 X97.568 Y122.825 E-.10361
G1 X97.807 Y122.963 E-.10481
G1 X98.09 Y123.091 E-.11811
G1 X98.077 Y123.151 E-.02346
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.728 Y120.278 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X96.784 Y119.918 E.01208
G3 X98.776 Y118.158 I2.286 J.581 E.09368
G1 X99.011 Y118.14 E.00782
G3 X96.714 Y120.382 I.059 J2.358 E.37455
G1 X96.72 Y120.337 E.00152
M204 S10000
G1 X97.129 Y120.338 F42000
G1 F15476.087
M204 S6000
G1 X97.178 Y120.018 E.01073
G3 X98.827 Y118.562 I1.892 J.48 E.0775
G1 X99.021 Y118.548 E.00647
G3 X97.121 Y120.403 I.049 J1.951 E.30987
G1 X97.121 Y120.398 E.00017
M204 S250
G1 X97.515 Y120.396 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X97.559 Y120.115 E.00874
G3 X98.876 Y118.952 I1.511 J.384 E.05736
G1 X99.031 Y118.94 E.00479
G3 X97.511 Y120.456 I.039 J1.559 E.2283
; WIPE_START
M204 S6000
G1 X97.559 Y120.115 E-.13076
G1 X97.664 Y119.823 E-.11812
G1 X97.826 Y119.558 E-.11802
G1 X98.037 Y119.33 E-.11807
G1 X98.29 Y119.149 E-.11803
G1 X98.573 Y119.021 E-.11811
G1 X98.673 Y118.998 E-.03888
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.143 Y111.38 Z1.6 F42000
G1 X101.402 Y74.817 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X101.324 Y75.195 E.0128
G3 X98.776 Y72.158 I-2.254 J-.697 E.33551
G1 X99.011 Y72.14 E.00782
G3 X101.417 Y74.735 I.059 J2.358 E.13272
G1 X101.413 Y74.758 E.00079
M204 S10000
G1 X101.004 Y74.737 F42000
G1 F15476.087
M204 S6000
G1 X100.934 Y75.075 E.01146
G3 X98.827 Y72.562 I-1.865 J-.576 E.27758
G1 X99.021 Y72.548 E.00647
G3 X101.013 Y74.678 I.049 J1.951 E.10925
M204 S250
G1 X100.622 Y74.659 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X100.56 Y74.96 E.00942
G3 X98.876 Y72.952 I-1.49 J-.461 E.20543
G1 X99.031 Y72.94 E.00479
G3 X100.626 Y74.6 I.039 J1.559 E.07955
; WIPE_START
M204 S6000
G1 X100.56 Y74.96 E-.13904
G1 X100.44 Y75.246 E-.11802
G1 X100.265 Y75.503 E-.11802
G1 X100.1 Y75.672 E-.08967
G1 X99.85 Y75.851 E-.11708
G1 X99.567 Y75.979 E-.11804
G1 X99.412 Y76.014 E-.06013
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.339 Y80.823 Z1.6 F42000
G1 X143.391 Y111.695 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.489 Y111.517 E.00674
G3 X145.505 Y110.214 I2.361 J1.441 E.0824
G1 X145.781 Y110.193 E.00917
G3 X143.357 Y111.759 I.069 J2.765 E.47584
G1 X143.363 Y111.749 E.00041
M204 S10000
G1 X143.771 Y111.857 F42000
G1 F15476.087
M204 S6000
G1 X143.969 Y111.535 E.01254
G3 X145.556 Y110.618 I1.881 J1.423 E.06245
G1 X145.791 Y110.6 E.00782
G3 X143.724 Y111.936 I.059 J2.358 E.40577
G1 X143.74 Y111.909 E.00106
M204 S10000
G1 X144.104 Y112.106 F42000
G1 F15476.087
M204 S6000
G1 X144.184 Y111.942 E.00603
G3 X145.607 Y111.022 I1.666 J1.017 E.05814
G1 X145.801 Y111.008 E.00646
G3 X144.016 Y112.292 I.049 J1.951 E.32925
G1 X144.079 Y112.16 E.00486
M204 S250
G1 X144.451 Y112.273 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.606 Y112.018 E.00917
G3 X145.656 Y111.412 I1.243 J.941 E.03824
G1 X145.811 Y111.4 E.00478
G3 X144.425 Y112.327 I.039 J1.559 E.24699
; WIPE_START
M204 S6000
G1 X144.606 Y112.018 E-.13604
G1 X144.817 Y111.79 E-.11806
G1 X145.07 Y111.609 E-.11803
G1 X145.353 Y111.481 E-.11802
G1 X145.656 Y111.412 E-.11808
G1 X145.811 Y111.4 E-.05916
G1 X146.054 Y111.418 E-.09261
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.434 Y111.852 Z1.6 F42000
G1 X113.035 Y113.296 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X113.001 Y113.508 E.00714
G3 X109.945 Y110.214 I-2.711 J-.55 E.40258
G1 X110.221 Y110.193 E.00917
G3 X113.042 Y113.235 I.069 J2.765 E.15564
G1 X113.042 Y113.236 E.00003
M204 S10000
G1 X112.623 Y113.274 F42000
G1 F15476.087
M204 S6000
G1 X112.544 Y113.655 E.01291
G3 X109.996 Y110.618 I-2.254 J-.697 E.33551
G1 X110.231 Y110.6 E.00782
G3 X112.637 Y113.195 I.059 J2.358 E.13272
G1 X112.633 Y113.215 E.00068
M204 S10000
G1 X112.225 Y113.194 F42000
G1 F15476.087
M204 S6000
G1 X112.154 Y113.535 E.01157
G3 X110.047 Y111.022 I-1.865 J-.576 E.27758
G1 X110.241 Y111.008 E.00647
G3 X112.234 Y113.134 I.049 J1.951 E.10914
M204 S250
G1 X111.842 Y113.116 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.78 Y113.42 E.00951
G3 X110.096 Y111.412 I-1.49 J-.46 E.20544
G1 X110.251 Y111.4 E.00478
G3 X111.846 Y113.057 I.039 J1.559 E.07946
; WIPE_START
M204 S6000
G1 X111.78 Y113.42 E-.14011
G1 X111.66 Y113.706 E-.11801
G1 X111.485 Y113.962 E-.11784
G1 X111.321 Y114.131 E-.08938
G1 X111.07 Y114.311 E-.11752
G1 X110.787 Y114.439 E-.11807
G1 X110.635 Y114.474 E-.05907
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X111.027 Y106.851 Z1.6 F42000
G1 X112.177 Y84.497 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X112.112 Y84.559 E.00297
G3 X109.945 Y79.734 I-1.822 J-2.081 E.3428
G1 X110.221 Y79.713 E.00917
G3 X112.41 Y84.255 I.069 J2.765 E.21043
G1 X112.218 Y84.454 E.00918
M204 S10000
G1 X111.78 Y84.302 F42000
G1 F15476.087
M204 S6000
G1 X111.469 Y84.522 E.01266
G3 X109.996 Y80.138 I-1.179 J-2.043 E.27699
G1 X110.231 Y80.12 E.00782
G3 X111.845 Y84.252 I.059 J2.358 E.19146
G1 X111.828 Y84.265 E.00071
M204 S10000
G1 X111.544 Y83.972 F42000
G1 F15476.087
M204 S6000
G1 X111.265 Y84.169 E.01133
G3 X110.047 Y80.542 I-.975 J-1.691 E.22917
G1 X110.241 Y80.528 E.00647
G3 X111.59 Y83.934 I.049 J1.951 E.15779
M204 S250
G1 X111.316 Y83.655 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.069 Y83.83 E.0093
G3 X110.096 Y80.932 I-.779 J-1.351 E.16961
G1 X110.251 Y80.92 E.00478
G3 X111.359 Y83.614 I.039 J1.559 E.1155
; WIPE_START
M204 S6000
G1 X111.069 Y83.83 E-.13759
G1 X110.787 Y83.959 E-.11796
G1 X110.484 Y84.028 E-.11803
G1 X110.176 Y84.036 E-.11709
G1 X109.943 Y84.001 E-.08963
G1 X109.648 Y83.902 E-.11802
G1 X109.508 Y83.821 E-.06168
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X116.999 Y82.362 Z1.6 F42000
G1 X121.854 Y81.416 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.285 Y81.416 E.71092
G2 X148.405 Y81.416 I2.56 J1.058 E.3607
G1 X159.854 Y81.416 E.37978
G1 X159.854 Y127.471 E1.52774
G1 X159.664 Y127.515 E.00646
G2 X159.664 Y129.485 I-2.588 J.985 E.51035
G1 X159.854 Y129.528 E.00646
G1 X159.854 Y211.084 E2.70534
G1 X136.488 Y211.084 E.77509
G1 X136.436 Y210.909 E.00606
G2 X132.664 Y207.135 I-1.366 J-2.407 E.33774
G1 X132.486 Y207.085 E.00614
G1 X132.486 Y123.284 E2.77984
G1 X100.088 Y123.284 E1.0747
G1 X100.05 Y123.085 E.00671
G2 X96.658 Y119.13 I-.986 J-2.586 E.35176
G1 X96.486 Y119.076 E.00598
G1 X96.486 Y75.924 E1.43146
G1 X96.658 Y75.87 E.00598
G2 X96.658 Y73.13 I2.407 J-1.37 E.48211
G1 X96.486 Y73.076 E.00598
G1 X96.486 Y44.916 E.93412
G1 X141.154 Y44.916 E1.48171
G1 X141.154 Y47.584 E.08849
G1 X137.154 Y47.584 E.13269
G1 X137.154 Y65.916 E.60812
G1 X141.154 Y65.916 E.13269
G1 X141.154 Y69.084 E.10507
G1 X121.854 Y69.084 E.64022
G1 X121.854 Y81.356 E.4071
; WIPE_START
G1 X123.854 Y81.362 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.469 Y88.969 Z1.6 F42000
G1 X133.962 Y206.423 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X134.318 Y206.263 E.01295
G3 X134.776 Y206.158 I.752 J2.236 E.01561
G1 X135.011 Y206.14 E.00782
G3 X133.89 Y206.456 I.059 J2.358 E.4526
G1 X133.908 Y206.448 E.00066
M204 S10000
G1 X134.129 Y206.793 F42000
G1 F15476.087
M204 S6000
G1 X134.448 Y206.649 E.01161
G3 X134.827 Y206.562 I.622 J1.85 E.01291
G1 X135.021 Y206.548 E.00647
G3 X134.075 Y206.82 I.049 J1.951 E.37376
M204 S250
G1 X134.29 Y207.149 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G3 X134.876 Y206.952 I.78 J1.35 E.01912
G1 X135.031 Y206.94 E.00478
G3 X134.238 Y207.18 I.039 J1.559 E.27529
; WIPE_START
M204 S6000
G1 X134.573 Y207.021 E-.14077
G1 X134.876 Y206.952 E-.11799
G1 X135.031 Y206.94 E-.05916
G1 X135.341 Y206.963 E-.11808
G1 X135.64 Y207.048 E-.11804
G1 X135.916 Y207.189 E-.11807
G1 X136.097 Y207.334 E-.08789
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.664 Y209.865 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X132.783 Y210.059 E.00755
G2 X133.702 Y210.903 I2.325 J-1.612 E.04174
G1 X133.654 Y211.084 E.00622
G1 X132.486 Y211.084 E.03874
G1 X132.486 Y209.915 E.03877
G1 X132.606 Y209.881 E.00415
; WIPE_START
G1 X132.783 Y210.059 E-.09525
G1 X132.949 Y210.279 E-.1048
G1 X133.137 Y210.481 E-.10487
G1 X133.344 Y210.664 E-.10491
G1 X133.702 Y210.903 E-.16366
G1 X133.654 Y211.084 E-.07122
G1 X133.351 Y211.084 E-.11531
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.702 Y203.479 Z1.6 F42000
G1 X122.261 Y81.009 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X143.999 Y81.009 E.72111
G2 X147.923 Y81.351 I1.849 J1.462 E.3367
G1 X147.714 Y81.009 E.0133
G1 X160.261 Y81.009 E.41621
G1 X160.261 Y211.491 E4.32832
G1 X132.079 Y211.491 E.93484
G1 X132.079 Y123.691 E2.91249
G1 X96.079 Y123.691 E1.19419
G1 X96.079 Y44.509 E2.6266
G1 X141.561 Y44.509 E1.50871
G1 X141.561 Y47.991 E.1155
G1 X137.561 Y47.991 E.13269
G1 X137.561 Y65.509 E.58111
G1 X141.561 Y65.509 E.13269
G1 X141.561 Y69.491 E.13208
G1 X122.261 Y69.491 E.64022
G1 X122.261 Y80.949 E.38009
M204 S10000
G1 X122.668 Y80.602 F42000
G1 F15476.087
M204 S6000
G1 X144.84 Y80.602 E.73549
G1 X144.891 Y80.777 E.00606
G2 X146.811 Y80.783 I.955 J1.698 E.33942
G1 X146.86 Y80.602 E.00622
G1 X160.668 Y80.602 E.45803
G1 X160.668 Y211.898 E4.35533
G1 X131.672 Y211.898 E.96185
G1 X131.672 Y124.098 E2.91249
G1 X95.672 Y124.098 E1.19419
G1 X95.672 Y44.102 E2.65361
G1 X141.968 Y44.102 E1.53572
G1 X141.968 Y48.398 E.1425
G1 X137.968 Y48.398 E.13269
G1 X137.968 Y65.102 E.55411
G1 X141.968 Y65.102 E.13269
G1 X141.968 Y69.898 E.15909
G1 X122.668 Y69.898 E.64022
G1 X122.668 Y80.542 E.35309
M204 S250
G1 X123.06 Y80.21 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X161.06 Y80.21 E1.16763
G1 X161.06 Y212.29 E4.05845
G1 X131.28 Y212.29 E.91506
M73 P59 R13
G1 X131.28 Y124.49 E2.69785
G1 X95.28 Y124.49 E1.10618
G1 X95.28 Y43.71 E2.48214
G1 X142.36 Y43.71 E1.44664
G1 X142.36 Y48.79 E.15609
G1 X138.36 Y48.79 E.12291
G1 X138.36 Y64.71 E.48918
G1 X142.36 Y64.71 E.12291
G1 X142.36 Y70.29 E.17146
G1 X123.06 Y70.29 E.59304
G1 X123.06 Y80.15 E.30297
; WIPE_START
M204 S6000
G1 X125.06 Y80.153 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 80
M625
; object ids of layer 6 start: 80,91,102,113,124
M624 HwAAAAAAAAA=
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


; object ids of this layer6 end: 80,91,102,113,124
M625
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X110.437 Y79.555 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X136.82 Y53.172 E1.14739
G1 X136.82 Y52.638 E.01641
G1 X110.068 Y79.39 E1.16345
G2 X109.417 Y79.508 I.224 J3.108 E.02038
G1 X136.82 Y52.104 E1.19176
G1 X136.82 Y51.57 E.01641
G1 X96.819 Y91.572 E1.73963
G1 X96.819 Y91.038 E.01641
G1 X136.82 Y51.037 E1.73963
G1 X136.82 Y50.503 E.01641
G1 X96.819 Y90.504 E1.73963
G1 X96.819 Y89.971 E.01641
G1 X136.82 Y49.969 E1.73963
G1 X136.82 Y49.436 E.01641
G1 X96.819 Y89.437 E1.73963
G1 X96.819 Y88.903 E.01641
G1 X136.82 Y48.902 E1.73963
G1 X136.82 Y48.368 E.01641
G1 X96.819 Y88.37 E1.73963
G1 X96.819 Y87.836 E.01641
G1 X136.99 Y47.665 E1.74701
; WIPE_START
G1 X135.576 Y49.079 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X140.437 Y47.42 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X140.82 Y47.037 E.01668
G1 X140.82 Y46.503 E.01641
G1 X140.073 Y47.251 E.03251
G1 X139.539 Y47.251 E.01641
G1 X140.82 Y45.969 E.05572
G1 X140.82 Y45.436 E.01641
G1 X139.006 Y47.251 E.07893
G1 X138.472 Y47.251 E.01641
G1 X140.473 Y45.249 E.08703
G1 X139.939 Y45.249 E.01641
G1 X137.938 Y47.251 E.08703
G1 X137.404 Y47.251 E.01641
G1 X139.406 Y45.249 E.08703
G1 X138.872 Y45.249 E.01641
G1 X96.819 Y87.302 E1.82886
G1 X96.819 Y86.768 E.01641
G1 X138.338 Y45.249 E1.80565
G1 X137.805 Y45.249 E.01641
G1 X96.819 Y86.235 E1.78243
G1 X96.819 Y85.701 E.01641
G1 X137.271 Y45.249 E1.75922
G1 X136.737 Y45.249 E.01641
G1 X96.819 Y85.167 E1.73601
G1 X96.819 Y84.634 E.01641
G1 X136.204 Y45.249 E1.7128
G1 X135.67 Y45.249 E.01641
G1 X96.819 Y84.1 E1.68959
G1 X96.819 Y83.566 E.01641
G1 X135.136 Y45.249 E1.66638
G1 X134.602 Y45.249 E.01641
G1 X96.819 Y83.033 E1.64317
G1 X96.819 Y82.499 E.01641
G1 X134.069 Y45.249 E1.61996
G1 X133.535 Y45.249 E.01641
G1 X96.819 Y81.965 E1.59675
G1 X96.819 Y81.432 E.01641
G1 X133.001 Y45.249 E1.57354
G1 X132.468 Y45.249 E.01641
G1 X96.819 Y80.898 E1.55033
G1 X96.819 Y80.364 E.01641
G1 X99.638 Y77.545 E.12259
G3 X99.051 Y77.598 I-.579 J-3.138 E.01814
G1 X96.819 Y79.83 E.09708
G1 X96.819 Y79.297 E.01641
G1 X98.558 Y77.558 E.07563
G3 X98.13 Y77.452 I.744 J-3.932 E.01356
G1 X96.819 Y78.763 E.05701
G1 X96.819 Y78.229 E.01641
G1 X97.747 Y77.302 E.04035
G3 X97.401 Y77.114 I.769 J-1.825 E.01212
G1 X96.819 Y77.696 E.02532
G1 X96.819 Y77.162 E.01641
G1 X97.214 Y76.767 E.01717
M204 S10000
G1 X96.913 Y76.575 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.121332
G1 F15000
M204 S6000
G1 X96.69 Y76.372 E.00193
M204 S10000
G1 X96.528 Y75.697 F42000
; LINE_WIDTH: 0.44464
G1 F15000
M204 S6000
G1 X96.479 Y75.453 E.00815
; LINE_WIDTH: 0.413037
G1 X96.456 Y75.306 E.00449
; LINE_WIDTH: 0.371513
G1 X96.437 Y75.178 E.00346
; LINE_WIDTH: 0.337188
G1 X96.422 Y75.035 E.00345
; LINE_WIDTH: 0.310016
G1 X96.41 Y74.907 E.0028
; LINE_WIDTH: 0.278189
G1 X96.396 Y74.628 E.00537
G1 X96.409 Y74.105 E.01002
; LINE_WIDTH: 0.308768
G1 X96.422 Y73.965 E.00305
; LINE_WIDTH: 0.335552
G1 X96.435 Y73.837 E.00306
; LINE_WIDTH: 0.369197
G1 X96.456 Y73.694 E.00385
; LINE_WIDTH: 0.410027
G1 X96.476 Y73.566 E.00387
; LINE_WIDTH: 0.443783
G3 X96.528 Y73.303 I5.43 J.95 E.00878
M204 S10000
G1 X96.69 Y72.655 F42000
; LINE_WIDTH: 0.106229
G1 F15000
M204 S6000
G1 X96.812 Y72.535 E.00088
; WIPE_START
G1 X96.69 Y72.655 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.889 Y75.294 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X131.934 Y45.249 E1.30664
G1 X131.4 Y45.249 E.01641
G1 X102.17 Y74.479 E1.27119
G2 X102.126 Y73.99 I-2.472 J-.021 E.01513
G1 X130.867 Y45.249 E1.24993
G1 X130.333 Y45.249 E.01641
G1 X102.024 Y73.559 E1.23115
G2 X101.871 Y73.177 I-1.98 J.572 E.01264
G1 X129.799 Y45.249 E1.21458
G1 X129.266 Y45.249 E.01641
G1 X101.682 Y72.833 E1.19961
G2 X101.458 Y72.523 I-1.668 J.965 E.01178
G1 X128.732 Y45.249 E1.18611
G1 X128.198 Y45.249 E.01641
G1 X101.199 Y72.248 E1.17416
G2 X100.908 Y72.006 I-1.35 J1.332 E.01168
G1 X127.664 Y45.249 E1.16364
G1 X127.131 Y45.249 E.01641
G1 X100.583 Y71.797 E1.15454
G2 X100.224 Y71.622 I-1.052 J1.709 E.0123
G1 X126.597 Y45.249 E1.14695
G1 X126.063 Y45.249 E.01641
G1 X99.819 Y71.494 E1.14135
G2 X99.364 Y71.415 I-.621 J2.237 E.01422
G1 X125.53 Y45.249 E1.13793
G1 X124.996 Y45.249 E.01641
G1 X98.834 Y71.411 E1.13777
G2 X98.179 Y71.533 I.24 J3.126 E.02053
G1 X124.462 Y45.249 E1.14305
G1 X123.929 Y45.249 E.01641
G1 X96.964 Y72.214 E1.17268
G1 X96.819 Y72.066 E.00638
G1 X96.819 Y71.825 E.0074
G1 X123.395 Y45.249 E1.15576
G1 X122.861 Y45.249 E.01641
G1 X96.819 Y71.291 E1.13255
G1 X96.819 Y70.758 E.01641
G1 X122.327 Y45.249 E1.10934
G1 X121.794 Y45.249 E.01641
G1 X96.819 Y70.224 E1.08613
G1 X96.819 Y69.69 E.01641
G1 X121.26 Y45.249 E1.06292
G1 X120.726 Y45.249 E.01641
G1 X96.819 Y69.157 E1.03971
G1 X96.819 Y68.623 E.01641
G1 X120.193 Y45.249 E1.0165
G1 X119.659 Y45.249 E.01641
G1 X96.819 Y68.089 E.99329
G1 X96.819 Y67.555 E.01641
G1 X119.125 Y45.249 E.97008
G1 X118.592 Y45.249 E.01641
G1 X96.819 Y67.022 E.94687
G1 X96.819 Y66.488 E.01641
G1 X118.058 Y45.249 E.92366
G1 X117.524 Y45.249 E.01641
G1 X96.819 Y65.954 E.90045
G1 X96.819 Y65.421 E.01641
G1 X116.99 Y45.249 E.87724
G1 X116.457 Y45.249 E.01641
G1 X96.819 Y64.887 E.85403
G1 X96.819 Y64.353 E.01641
G1 X115.923 Y45.249 E.83082
G1 X115.389 Y45.249 E.01641
G1 X96.819 Y63.82 E.80761
G1 X96.819 Y63.286 E.01641
G1 X114.856 Y45.249 E.7844
G1 X114.322 Y45.249 E.01641
G1 X96.819 Y62.752 E.76119
M73 P60 R13
G1 X96.819 Y62.218 E.01641
G1 X113.788 Y45.249 E.73798
M73 P60 R12
G1 X113.255 Y45.249 E.01641
G1 X96.819 Y61.685 E.71477
G1 X96.819 Y61.151 E.01641
G1 X112.721 Y45.249 E.69156
G1 X112.187 Y45.249 E.01641
G1 X96.819 Y60.617 E.66835
G1 X96.819 Y60.084 E.01641
G1 X111.654 Y45.249 E.64514
G1 X111.12 Y45.249 E.01641
G1 X96.819 Y59.55 E.62193
G1 X96.819 Y59.016 E.01641
G1 X110.586 Y45.249 E.59872
G1 X110.052 Y45.249 E.01641
G1 X96.819 Y58.483 E.57551
G1 X96.819 Y57.949 E.01641
G1 X109.519 Y45.249 E.5523
G1 X108.985 Y45.249 E.01641
G1 X96.819 Y57.415 E.52909
G1 X96.819 Y56.882 E.01641
G1 X108.451 Y45.249 E.50588
G1 X107.918 Y45.249 E.01641
G1 X96.819 Y56.348 E.48267
G1 X96.819 Y55.814 E.01641
G1 X107.384 Y45.249 E.45946
G1 X106.85 Y45.249 E.01641
G1 X96.819 Y55.28 E.43625
G1 X96.819 Y54.747 E.01641
G1 X106.317 Y45.249 E.41304
G1 X105.783 Y45.249 E.01641
G1 X96.819 Y54.213 E.38983
G1 X96.819 Y53.679 E.01641
G1 X105.249 Y45.249 E.36662
G1 X104.715 Y45.249 E.01641
G1 X96.819 Y53.146 E.34341
G1 X96.819 Y52.612 E.01641
G1 X104.182 Y45.249 E.3202
G1 X103.648 Y45.249 E.01641
G1 X96.819 Y52.078 E.29699
G1 X96.819 Y51.545 E.01641
G1 X103.114 Y45.249 E.27378
G1 X102.581 Y45.249 E.01641
G1 X96.819 Y51.011 E.25057
G1 X96.819 Y50.477 E.01641
G1 X102.047 Y45.249 E.22736
G1 X101.513 Y45.249 E.01641
G1 X96.819 Y49.943 E.20415
G1 X96.819 Y49.41 E.01641
G1 X100.98 Y45.249 E.18093
G1 X100.446 Y45.249 E.01641
G1 X96.819 Y48.876 E.15772
G1 X96.819 Y48.342 E.01641
G1 X99.912 Y45.249 E.13451
G1 X99.379 Y45.249 E.01641
G1 X96.819 Y47.809 E.1113
G1 X96.819 Y47.275 E.01641
G1 X98.845 Y45.249 E.08809
G1 X98.311 Y45.249 E.01641
G1 X96.819 Y46.741 E.06488
G1 X96.819 Y46.208 E.01641
G1 X97.777 Y45.249 E.04167
G1 X97.244 Y45.249 E.01641
G1 X96.65 Y45.844 E.02584
M204 S10000
G1 X107.599 Y81.326 F42000
G1 F15000
M204 S6000
G1 X96.819 Y92.105 E.4688
G1 X96.819 Y92.639 E.01641
G1 X107.199 Y82.26 E.4514
G2 X107.207 Y82.785 I3.32 J.209 E.01617
G1 X96.819 Y93.173 E.45177
G1 X96.819 Y93.707 E.01641
G1 X107.284 Y83.242 E.45509
G2 X107.418 Y83.642 I4.66 J-1.344 E.01296
G1 X96.819 Y94.24 E.46093
G1 X96.819 Y94.774 E.01641
G1 X107.591 Y84.002 E.46847
G2 X107.8 Y84.327 I1.728 J-.879 E.0119
G1 X96.819 Y95.308 E.47754
G1 X96.819 Y95.841 E.01641
G1 X108.044 Y84.617 E.48816
G2 X108.322 Y84.873 I1.418 J-1.26 E.01163
G1 X96.819 Y96.375 E.50024
G1 X96.819 Y96.909 E.01641
G1 X108.631 Y85.096 E.51371
G2 X108.975 Y85.287 I1.123 J-1.62 E.01209
G1 X96.819 Y97.442 E.52864
G1 X96.819 Y97.976 E.01641
G1 X109.359 Y85.436 E.54536
G2 X109.796 Y85.533 I.589 J-1.624 E.0138
G1 X96.819 Y98.51 E.56435
G1 X96.819 Y99.044 E.01641
G1 X110.284 Y85.579 E.58558
G2 X110.874 Y85.522 I-.012 J-3.254 E.01824
G1 X96.65 Y99.747 E.61861
M204 S10000
G1 X100.393 Y117.885 F42000
G1 F15000
M204 S6000
G1 X136.529 Y81.749 E1.57151
G1 X135.995 Y81.749 E.01641
G1 X100.149 Y117.595 E1.5589
G2 X99.736 Y117.475 I-.808 J2.009 E.01327
G1 X135.461 Y81.749 E1.55368
G1 X134.927 Y81.749 E.01641
G1 X99.27 Y117.406 E1.5507
G2 X98.724 Y117.42 I-.207 J2.733 E.01685
G1 X134.394 Y81.749 E1.55128
G1 X133.86 Y81.749 E.01641
G1 X98.028 Y117.581 E1.5583
G2 X96.97 Y118.221 I1.079 J2.981 E.03827
G1 X96.913 Y118.162 E.0025
G1 X133.326 Y81.749 E1.58358
G1 X132.793 Y81.749 E.01641
G1 X96.819 Y117.723 E1.56447
G1 X96.819 Y117.189 E.01641
G1 X132.259 Y81.749 E1.54126
G1 X131.725 Y81.749 E.01641
G1 X96.819 Y116.655 E1.51805
G1 X96.819 Y116.122 E.01641
G1 X131.192 Y81.749 E1.49484
G1 X130.658 Y81.749 E.01641
G1 X96.819 Y115.588 E1.47163
G1 X96.819 Y115.054 E.01641
G1 X130.124 Y81.749 E1.44842
G1 X129.591 Y81.749 E.01641
G1 X96.819 Y114.521 E1.42521
G1 X96.819 Y113.987 E.01641
G1 X129.057 Y81.749 E1.402
G1 X128.523 Y81.749 E.01641
G1 X96.819 Y113.453 E1.37879
G1 X96.819 Y112.92 E.01641
G1 X127.989 Y81.749 E1.35558
G1 X127.456 Y81.749 E.01641
G1 X96.819 Y112.386 E1.33237
G1 X96.819 Y111.852 E.01641
G1 X126.922 Y81.749 E1.30916
G1 X126.388 Y81.749 E.01641
G1 X96.819 Y111.319 E1.28595
G1 X96.819 Y110.785 E.01641
G1 X125.855 Y81.749 E1.26274
G1 X125.321 Y81.749 E.01641
G1 X96.819 Y110.251 E1.23953
G1 X96.819 Y109.717 E.01641
G1 X124.787 Y81.749 E1.21632
G1 X124.254 Y81.749 E.01641
G1 X96.819 Y109.184 E1.19311
G1 X96.819 Y108.65 E.01641
G1 X123.72 Y81.749 E1.1699
G1 X123.186 Y81.749 E.01641
G1 X96.819 Y108.116 E1.14669
G1 X96.819 Y107.583 E.01641
G1 X122.652 Y81.749 E1.12348
G1 X122.119 Y81.749 E.01641
G1 X96.819 Y107.049 E1.10027
G1 X96.819 Y106.515 E.01641
G1 X121.585 Y81.749 E1.07705
G1 X121.52 Y81.749 E.00199
G1 X121.52 Y81.28 E.01443
G1 X96.819 Y105.982 E1.07424
G1 X96.819 Y105.448 E.01641
G1 X121.52 Y80.747 E1.07424
G1 X121.52 Y80.213 E.01641
G1 X96.819 Y104.914 E1.07424
G1 X96.819 Y104.38 E.01641
G1 X121.52 Y79.679 E1.07424
G1 X121.52 Y79.146 E.01641
G1 X96.819 Y103.847 E1.07424
G1 X96.819 Y103.313 E.01641
G1 X121.52 Y78.612 E1.07424
G1 X121.52 Y78.078 E.01641
G1 X96.819 Y102.779 E1.07424
G1 X96.819 Y102.246 E.01641
G1 X121.52 Y77.544 E1.07424
G1 X121.52 Y77.011 E.01641
G1 X96.819 Y101.712 E1.07425
G1 X96.819 Y101.178 E.01641
G1 X121.52 Y76.477 E1.07424
G1 X121.52 Y75.943 E.01641
G1 X96.819 Y100.645 E1.07425
G1 X96.819 Y100.111 E.01641
G1 X121.52 Y75.41 E1.07425
G1 X121.52 Y74.876 E.01641
G1 X113.335 Y83.062 E.35599
G2 X113.391 Y82.472 I-4.239 J-.701 E.01823
G1 X121.52 Y74.342 E.35355
G1 X121.52 Y73.809 E.01641
G1 X113.347 Y81.982 E.35544
G2 X113.247 Y81.548 I-4.057 J.71 E.01369
G1 X121.52 Y73.275 E.3598
G1 X121.52 Y72.741 E.01641
G1 X113.095 Y81.166 E.3664
G2 X112.907 Y80.821 I-1.818 J.771 E.01211
G1 X121.52 Y72.207 E.37462
G1 X121.52 Y71.674 E.01641
G1 X112.684 Y80.51 E.3843
G2 X112.426 Y80.234 I-3.94 J3.415 E.01161
G1 X121.52 Y71.14 E.3955
G1 X121.52 Y70.606 E.01641
G1 X112.135 Y79.992 E.40816
G2 X111.811 Y79.782 I-1.21 J1.511 E.01189
G1 X121.52 Y70.073 E.42224
G1 X121.52 Y69.539 E.01641
G1 X111.453 Y79.606 E.43783
G2 X111.05 Y79.476 I-1.453 J3.806 E.01304
G1 X136.82 Y53.705 E1.12076
G1 X136.82 Y54.239 E.01641
G1 X122.309 Y68.751 E.6311
G1 X122.842 Y68.751 E.01641
G1 X136.82 Y54.773 E.60789
G1 X136.82 Y55.306 E.01641
G1 X123.376 Y68.751 E.58468
G1 X123.91 Y68.751 E.01641
G1 X136.82 Y55.84 E.56147
G1 X136.82 Y56.374 E.01641
G1 X124.444 Y68.751 E.53826
G1 X124.977 Y68.751 E.01641
G1 X136.82 Y56.907 E.51505
G1 X136.82 Y57.441 E.01641
G1 X125.511 Y68.751 E.49184
G1 X126.045 Y68.751 E.01641
G1 X136.82 Y57.975 E.46863
G1 X136.82 Y58.509 E.01641
G1 X126.578 Y68.751 E.44542
G1 X127.112 Y68.751 E.01641
G1 X136.82 Y59.042 E.42221
G1 X136.82 Y59.576 E.01641
G1 X127.646 Y68.751 E.399
G1 X128.179 Y68.751 E.01641
G1 X136.82 Y60.11 E.37579
G1 X136.82 Y60.643 E.01641
G1 X128.713 Y68.751 E.35258
G1 X129.247 Y68.751 E.01641
G1 X136.82 Y61.177 E.32937
G1 X136.82 Y61.711 E.01641
G1 X129.781 Y68.751 E.30616
G1 X130.314 Y68.751 E.01641
G1 X136.82 Y62.244 E.28295
G1 X136.82 Y62.778 E.01641
G1 X130.848 Y68.751 E.25974
G1 X131.382 Y68.751 E.01641
G1 X136.82 Y63.312 E.23653
G1 X136.82 Y63.846 E.01641
G1 X131.915 Y68.751 E.21332
G1 X132.449 Y68.751 E.01641
G1 X136.82 Y64.379 E.19011
G1 X136.82 Y64.913 E.01641
G1 X132.983 Y68.751 E.1669
G1 X133.516 Y68.751 E.01641
G1 X136.82 Y65.447 E.14369
M73 P61 R12
G1 X136.82 Y65.98 E.01641
G1 X134.05 Y68.751 E.12048
G1 X134.584 Y68.751 E.01641
G1 X137.085 Y66.249 E.10878
G1 X137.619 Y66.249 E.01641
G1 X135.118 Y68.751 E.10878
G1 X135.651 Y68.751 E.01641
G1 X138.152 Y66.249 E.10878
G1 X138.686 Y66.249 E.01641
G1 X136.185 Y68.751 E.10878
G1 X136.719 Y68.751 E.01641
G1 X139.22 Y66.249 E.10878
G1 X139.754 Y66.249 E.01641
G1 X137.252 Y68.751 E.10878
G1 X137.786 Y68.751 E.01641
G1 X140.287 Y66.249 E.10878
G1 X140.82 Y66.249 E.0164
G1 X138.32 Y68.751 E.10877
G1 X138.853 Y68.751 E.01641
G1 X140.82 Y66.784 E.08555
G1 X140.82 Y67.317 E.01641
G1 X139.387 Y68.751 E.06234
G1 X139.921 Y68.751 E.01641
G1 X140.82 Y67.851 E.03913
G1 X140.82 Y68.385 E.01641
G1 X140.285 Y68.92 E.0233
; WIPE_START
G1 X140.82 Y68.385 E-.28787
G1 X140.82 Y67.851 E-.20281
G1 X140.319 Y68.352 E-.26933
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.173 Y75.431 Z1.6 F42000
G1 X145.26 Y80.611 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.429385
G1 F15000
M204 S6000
G1 X145.427 Y80.588 E.0053
; LINE_WIDTH: 0.374636
G1 X145.81 Y80.565 E.01037
G1 X146.176 Y80.579 E.00991
; LINE_WIDTH: 0.409245
G1 X146.369 Y80.6 E.00578
; LINE_WIDTH: 0.444202
G3 X146.645 Y80.645 I-.772 J5.648 E.00917
M204 S10000
G1 X147.288 Y80.806 F42000
; LINE_WIDTH: 0.113508
G1 F15000
M204 S6000
G1 X147.427 Y80.978 E.00127
; WIPE_START
G1 X147.288 Y80.806 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.773 Y82.313 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X149.337 Y81.749 E.02453
G1 X149.871 Y81.749 E.01641
G1 X148.941 Y82.679 E.04043
G3 X148.832 Y83.322 I-3.21 J-.215 E.0201
G1 X150.405 Y81.749 E.0684
G1 X150.938 Y81.749 E.01641
G1 X109.737 Y122.951 E1.79182
G1 X110.271 Y122.951 E.01641
G1 X151.472 Y81.749 E1.79182
G1 X152.006 Y81.749 E.01641
G1 X110.804 Y122.951 E1.79182
G1 X111.338 Y122.951 E.01641
G1 X152.539 Y81.749 E1.79182
G1 X153.073 Y81.749 E.01641
G1 X111.872 Y122.951 E1.79182
G1 X112.406 Y122.951 E.01641
G1 X153.607 Y81.749 E1.79182
G1 X154.141 Y81.749 E.01641
G1 X112.939 Y122.951 E1.79182
G1 X113.473 Y122.951 E.01641
G1 X154.674 Y81.749 E1.79182
G1 X155.208 Y81.749 E.01641
G1 X114.007 Y122.951 E1.79182
G1 X114.54 Y122.951 E.01641
G1 X155.742 Y81.749 E1.79182
G1 X156.275 Y81.749 E.01641
G1 X115.074 Y122.951 E1.79182
G1 X115.608 Y122.951 E.01641
G1 X156.809 Y81.749 E1.79182
G1 X157.343 Y81.749 E.01641
G1 X116.141 Y122.951 E1.79182
G1 X116.675 Y122.951 E.01641
G1 X157.876 Y81.749 E1.79182
G1 X158.41 Y81.749 E.01641
G1 X117.209 Y122.951 E1.79182
G1 X117.743 Y122.951 E.01641
G1 X158.944 Y81.749 E1.79182
G1 X159.477 Y81.749 E.01641
G1 X118.276 Y122.951 E1.79182
G1 X118.81 Y122.951 E.01641
G1 X159.52 Y82.24 E1.77048
G1 X159.52 Y82.774 E.01641
G1 X119.344 Y122.951 E1.74727
G1 X119.877 Y122.951 E.01641
G1 X159.52 Y83.307 E1.72406
G1 X159.52 Y83.841 E.01641
G1 X120.411 Y122.951 E1.70085
G1 X120.945 Y122.951 E.01641
G1 X159.52 Y84.375 E1.67764
G1 X159.52 Y84.909 E.01641
G1 X121.478 Y122.951 E1.65443
G1 X122.012 Y122.951 E.01641
G1 X159.52 Y85.442 E1.63122
G1 X159.52 Y85.976 E.01641
G1 X122.546 Y122.951 E1.60801
G1 X123.079 Y122.951 E.01641
G1 X159.52 Y86.51 E1.5848
G1 X159.52 Y87.043 E.01641
G1 X123.613 Y122.951 E1.56159
G1 X124.147 Y122.951 E.01641
G1 X159.52 Y87.577 E1.53838
G1 X159.52 Y88.111 E.01641
G1 X124.681 Y122.951 E1.51517
G1 X125.214 Y122.951 E.01641
G1 X159.52 Y88.644 E1.49196
G1 X159.52 Y89.178 E.01641
G1 X125.748 Y122.951 E1.46875
G1 X126.282 Y122.951 E.01641
G1 X159.52 Y89.712 E1.44554
G1 X159.52 Y90.246 E.01641
G1 X126.815 Y122.951 E1.42233
G1 X127.349 Y122.951 E.01641
G1 X159.52 Y90.779 E1.39912
G1 X159.52 Y91.313 E.01641
G1 X127.883 Y122.951 E1.37591
G1 X128.416 Y122.951 E.01641
G1 X159.52 Y91.847 E1.3527
G1 X159.52 Y92.38 E.01641
G1 X128.95 Y122.951 E1.32949
G1 X129.484 Y122.951 E.01641
G1 X159.52 Y92.914 E1.30628
G1 X159.52 Y93.448 E.01641
G1 X130.018 Y122.951 E1.28307
G1 X130.551 Y122.951 E.01641
G1 X159.52 Y93.981 E1.25986
G1 X159.52 Y94.515 E.01641
G1 X131.085 Y122.951 E1.23665
G1 X131.619 Y122.951 E.01641
G1 X159.52 Y95.049 E1.21344
G1 X159.52 Y95.582 E.01641
G1 X145.168 Y109.935 E.62417
G3 X145.777 Y109.86 I.853 J4.4 E.01888
G1 X159.52 Y96.116 E.59769
G1 X159.52 Y96.65 E.01641
G1 X146.279 Y109.892 E.57588
G3 X146.72 Y109.984 I-.571 J3.818 E.01387
G1 X159.52 Y97.184 E.5567
G1 X159.52 Y97.717 E.01641
G1 X147.108 Y110.129 E.5398
G3 X147.459 Y110.312 I-.738 J1.844 E.01219
G1 X159.52 Y98.251 E.52454
G1 X159.52 Y98.785 E.01641
G1 X147.776 Y110.529 E.51077
G3 X148.056 Y110.783 I-3.641 J4.3 E.01162
G1 X159.52 Y99.318 E.4986
G1 X159.52 Y99.852 E.01641
G1 X148.304 Y111.069 E.48782
G3 X148.519 Y111.387 I-1.486 J1.238 E.01184
G1 X159.52 Y100.386 E.47845
G1 X159.52 Y100.919 E.01641
G1 X148.7 Y111.74 E.47056
G3 X148.837 Y112.137 I-4.109 J1.633 E.01292
G1 X159.52 Y101.453 E.46463
G1 X159.52 Y101.987 E.01641
G1 X148.925 Y112.582 E.46077
G3 X148.945 Y113.096 I-3.285 J.38 E.01585
G1 X159.52 Y102.521 E.45994
G1 X159.52 Y103.054 E.01641
G1 X148.594 Y113.98 E.47517
; WIPE_START
G1 X150.009 Y112.566 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.072 Y112.031 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
G1 F15000
M204 S6000
G1 X132.152 Y122.951 E.47491
G1 X132.686 Y122.951 E.01641
G1 X142.752 Y112.884 E.43777
G2 X142.78 Y113.391 I2.544 J.115 E.01561
G1 X132.819 Y123.351 E.43318
G1 X132.819 Y123.885 E.01641
G1 X142.876 Y113.828 E.43736
G2 X143.019 Y114.219 I2.024 J-.519 E.01282
G1 X132.819 Y124.419 E.44358
G1 X132.819 Y124.952 E.01641
G1 X143.2 Y114.571 E.45146
G2 X143.421 Y114.884 I4.646 J-3.041 E.01178
G1 X132.819 Y125.486 E.46106
G1 X132.819 Y126.02 E.01641
G1 X143.677 Y115.162 E.47218
G2 X143.958 Y115.415 I1.135 J-.98 E.01165
G1 X132.819 Y126.553 E.48441
G1 X132.819 Y127.087 E.01641
G1 X144.277 Y115.629 E.4983
G2 X144.631 Y115.809 I1.076 J-1.682 E.01223
G1 X132.819 Y127.621 E.5137
G1 X132.819 Y128.154 E.01641
G1 X145.025 Y115.949 E.53081
G2 X145.473 Y116.035 I.653 J-2.203 E.01405
G1 X132.819 Y128.688 E.55029
G1 X132.819 Y129.222 E.01641
G1 X145.985 Y116.056 E.57256
G2 X146.611 Y115.964 I-.177 J-3.37 E.01949
G1 X132.819 Y129.755 E.59979
G1 X132.819 Y130.289 E.01641
G1 X159.52 Y103.588 E1.16122
G1 X159.52 Y104.122 E.01641
G1 X132.819 Y130.823 E1.16122
G1 X132.819 Y131.357 E.01641
G1 X159.52 Y104.655 E1.16122
G1 X159.52 Y105.189 E.01641
G1 X132.819 Y131.89 E1.16122
G1 X132.819 Y132.424 E.01641
G1 X159.52 Y105.723 E1.16122
G1 X159.52 Y106.256 E.01641
G1 X132.819 Y132.958 E1.16122
G1 X132.819 Y133.491 E.01641
G1 X159.52 Y106.79 E1.16122
G1 X159.52 Y107.324 E.01641
G1 X132.819 Y134.025 E1.16122
G1 X132.819 Y134.559 E.01641
G1 X159.52 Y107.857 E1.16122
G1 X159.52 Y108.391 E.01641
G1 X132.819 Y135.092 E1.16122
G1 X132.819 Y135.626 E.01641
G1 X159.52 Y108.925 E1.16122
G1 X159.52 Y109.459 E.01641
G1 X132.819 Y136.16 E1.16122
G1 X132.819 Y136.694 E.01641
G1 X159.52 Y109.992 E1.16122
G1 X159.52 Y110.526 E.01641
G1 X132.819 Y137.227 E1.16122
G1 X132.819 Y137.761 E.01641
G1 X159.52 Y111.06 E1.16122
G1 X159.52 Y111.593 E.01641
G1 X132.819 Y138.295 E1.16122
G1 X132.819 Y138.828 E.01641
G1 X159.52 Y112.127 E1.16122
G1 X159.52 Y112.661 E.01641
G1 X132.819 Y139.362 E1.16122
G1 X132.819 Y139.896 E.01641
G1 X159.52 Y113.194 E1.16122
G1 X159.52 Y113.728 E.01641
G1 X132.819 Y140.429 E1.16122
G1 X132.819 Y140.963 E.01641
G1 X159.52 Y114.262 E1.16122
G1 X159.52 Y114.796 E.01641
G1 X132.819 Y141.497 E1.16122
G1 X132.819 Y142.03 E.01641
G1 X159.52 Y115.329 E1.16122
G1 X159.52 Y115.863 E.01641
G1 X132.819 Y142.564 E1.16122
G1 X132.819 Y143.098 E.01641
G1 X159.52 Y116.397 E1.16122
G1 X159.52 Y116.93 E.01641
G1 X132.819 Y143.632 E1.16122
M73 P62 R12
G1 X132.819 Y144.165 E.01641
G1 X159.52 Y117.464 E1.16122
G1 X159.52 Y117.998 E.01641
G1 X132.819 Y144.699 E1.16122
G1 X132.819 Y145.233 E.01641
G1 X159.52 Y118.531 E1.16122
G1 X159.52 Y119.065 E.01641
G1 X132.819 Y145.766 E1.16122
G1 X132.819 Y146.3 E.01641
G1 X159.52 Y119.599 E1.16122
G1 X159.52 Y120.132 E.01641
G1 X132.819 Y146.834 E1.16122
G1 X132.819 Y147.367 E.01641
G1 X159.52 Y120.666 E1.16122
G1 X159.52 Y121.2 E.01641
G1 X132.65 Y148.071 E1.1686
M204 S10000
G1 X159.491 Y130.261 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.1127
G1 F15000
M204 S6000
G1 X159.65 Y130.071 E.00141
M204 S10000
G1 X159.525 Y129.245 F42000
; LINE_WIDTH: 0.512368
G1 F13420.025
M204 S6000
G1 X159.817 Y129.065 E.01311
G2 X159.838 Y128.788 I-6.257 J-.618 E.01062
; LINE_WIDTH: 0.472779
G1 F14655.982
G2 X159.839 Y128.234 I-7.968 J-.293 E.01941
; LINE_WIDTH: 0.51134
G1 F13449.482
G2 X159.817 Y127.935 I-22.518 J1.531 E.01143
G1 X159.525 Y127.755 E.0131
M204 S10000
G1 X159.65 Y126.905 F42000
; LINE_WIDTH: 0.140504
G1 F15000
M204 S6000
G1 X159.561 Y126.799 E.00111
; LINE_WIDTH: 0.114378
G1 X159.423 Y126.651 E.00118
M204 S10000
G1 X159.69 Y125.833 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X159.24 Y126.284 E.0196
G2 X158.952 Y126.038 I-3.898 J4.264 E.01164
G1 X159.52 Y125.469 E.02473
G1 X159.52 Y124.936 E.01641
G1 X158.631 Y125.825 E.03866
G2 X158.276 Y125.646 I-1.071 J1.685 E.01224
G1 X159.52 Y124.402 E.0541
G1 X159.52 Y123.868 E.01641
G1 X157.881 Y125.508 E.0713
G2 X157.432 Y125.423 I-.647 J2.206 E.01408
G1 X159.52 Y123.335 E.09084
G1 X159.52 Y122.801 E.01641
G1 X156.916 Y125.405 E.11325
G2 X156.285 Y125.503 I.178 J3.235 E.01968
G1 X159.52 Y122.267 E.14072
G1 X159.52 Y121.734 E.01641
G1 X132.819 Y148.435 E1.16122
G1 X132.819 Y148.969 E.01641
G1 X154.069 Y127.719 E.92415
G2 X153.972 Y128.349 I2.035 J.636 E.0197
G1 X132.819 Y149.502 E.91993
G1 X132.819 Y150.036 E.01641
G1 X153.993 Y128.862 E.92083
G2 X154.078 Y129.311 I3.623 J-.457 E.01405
G1 X132.819 Y150.57 E.92454
G1 X132.819 Y151.103 E.01641
G1 X154.217 Y129.706 E.93056
G2 X154.394 Y130.063 I1.872 J-.707 E.01227
G1 X132.819 Y151.637 E.93826
G1 X132.819 Y152.171 E.01641
G1 X154.606 Y130.384 E.94751
G1 X154.86 Y130.664 E.01162
G1 X132.819 Y152.704 E.95853
G1 X132.819 Y153.238 E.01641
G1 X155.143 Y130.914 E.97084
G2 X155.45 Y131.141 I.941 J-.951 E.01177
G1 X132.819 Y153.772 E.98418
G1 X132.819 Y154.305 E.01641
G1 X155.799 Y131.325 E.9994
G2 X156.187 Y131.471 I.922 J-1.859 E.01276
G1 X132.819 Y154.839 E1.01626
G1 X132.819 Y155.373 E.01641
G1 X156.626 Y131.566 E1.03534
G2 X157.126 Y131.6 I.419 J-2.486 E.01543
G1 X132.819 Y155.907 E1.05708
G1 X132.819 Y156.44 E.01641
G1 X157.73 Y131.529 E1.08338
G2 X158.593 Y131.2 I-.612 J-2.9 E.0285
G1 X132.819 Y156.974 E1.12089
G1 X132.819 Y157.508 E.01641
G1 X159.52 Y130.806 E1.16122
G1 X159.52 Y131.34 E.01641
G1 X132.819 Y158.041 E1.16122
G1 X132.819 Y158.575 E.01641
G1 X159.52 Y131.874 E1.16122
G1 X159.52 Y132.407 E.01641
G1 X132.819 Y159.109 E1.16122
G1 X132.819 Y159.642 E.01641
G1 X159.52 Y132.941 E1.16122
G1 X159.52 Y133.475 E.01641
G1 X132.819 Y160.176 E1.16122
G1 X132.819 Y160.71 E.01641
G1 X159.52 Y134.009 E1.16122
G1 X159.52 Y134.542 E.01641
G1 X132.819 Y161.244 E1.16122
G1 X132.819 Y161.777 E.01641
G1 X159.52 Y135.076 E1.16122
G1 X159.52 Y135.61 E.01641
G1 X132.819 Y162.311 E1.16122
G1 X132.819 Y162.845 E.01641
G1 X159.52 Y136.143 E1.16122
G1 X159.52 Y136.677 E.01641
G1 X132.819 Y163.378 E1.16122
G1 X132.819 Y163.912 E.01641
G1 X159.52 Y137.211 E1.16122
G1 X159.52 Y137.744 E.01641
G1 X132.819 Y164.446 E1.16122
G1 X132.819 Y164.979 E.01641
G1 X159.52 Y138.278 E1.16122
G1 X159.52 Y138.812 E.01641
G1 X132.819 Y165.513 E1.16122
G1 X132.819 Y166.047 E.01641
G1 X159.52 Y139.346 E1.16122
G1 X159.52 Y139.879 E.01641
G1 X132.819 Y166.581 E1.16122
G1 X132.819 Y167.114 E.01641
G1 X159.52 Y140.413 E1.16122
G1 X159.52 Y140.947 E.01641
G1 X132.819 Y167.648 E1.16122
G1 X132.819 Y168.182 E.01641
G1 X159.52 Y141.48 E1.16122
G1 X159.52 Y142.014 E.01641
G1 X132.819 Y168.715 E1.16122
G1 X132.819 Y169.249 E.01641
G1 X159.52 Y142.548 E1.16122
G1 X159.52 Y143.081 E.01641
G1 X132.819 Y169.783 E1.16122
G1 X132.819 Y170.316 E.01641
G1 X159.52 Y143.615 E1.16122
G1 X159.52 Y144.149 E.01641
G1 X132.819 Y170.85 E1.16122
G1 X132.819 Y171.384 E.01641
G1 X159.52 Y144.682 E1.16122
G1 X159.52 Y145.216 E.01641
G1 X132.819 Y171.917 E1.16122
G1 X132.819 Y172.451 E.01641
G1 X159.52 Y145.75 E1.16122
G1 X159.52 Y146.284 E.01641
G1 X132.819 Y172.985 E1.16122
G1 X132.819 Y173.519 E.01641
G1 X159.52 Y146.817 E1.16122
G1 X159.52 Y147.351 E.01641
G1 X132.819 Y174.052 E1.16122
G1 X132.819 Y174.586 E.01641
G1 X159.52 Y147.885 E1.16122
G1 X159.52 Y148.418 E.01641
G1 X132.819 Y175.12 E1.16122
G1 X132.819 Y175.653 E.01641
G1 X159.52 Y148.952 E1.16122
G1 X159.52 Y149.486 E.01641
G1 X132.819 Y176.187 E1.16122
G1 X132.819 Y176.721 E.01641
G1 X159.52 Y150.019 E1.16122
G1 X159.52 Y150.553 E.01641
G1 X132.819 Y177.254 E1.16122
G1 X132.819 Y177.788 E.01641
G1 X159.52 Y151.087 E1.16122
G1 X159.52 Y151.621 E.01641
G1 X132.819 Y178.322 E1.16122
G1 X132.819 Y178.856 E.01641
G1 X159.52 Y152.154 E1.16122
G1 X159.52 Y152.688 E.01641
G1 X132.819 Y179.389 E1.16122
G1 X132.819 Y179.923 E.01641
G1 X159.52 Y153.222 E1.16122
G1 X159.52 Y153.755 E.01641
G1 X132.819 Y180.457 E1.16122
G1 X132.819 Y180.99 E.01641
G1 X159.52 Y154.289 E1.16122
G1 X159.52 Y154.823 E.01641
G1 X132.819 Y181.524 E1.16122
G1 X132.819 Y182.058 E.01641
G1 X159.52 Y155.356 E1.16122
G1 X159.52 Y155.89 E.01641
G1 X132.819 Y182.591 E1.16122
G1 X132.819 Y183.125 E.01641
G1 X159.52 Y156.424 E1.16122
G1 X159.52 Y156.958 E.01641
G1 X132.819 Y183.659 E1.16122
G1 X132.819 Y184.192 E.01641
G1 X159.52 Y157.491 E1.16122
G1 X159.52 Y158.025 E.01641
G1 X132.819 Y184.726 E1.16122
G1 X132.819 Y185.26 E.01641
G1 X159.52 Y158.559 E1.16122
G1 X159.52 Y159.092 E.01641
G1 X132.819 Y185.794 E1.16122
G1 X132.819 Y186.327 E.01641
G1 X159.52 Y159.626 E1.16122
G1 X159.52 Y160.16 E.01641
G1 X132.819 Y186.861 E1.16122
G1 X132.819 Y187.395 E.01641
G1 X159.52 Y160.693 E1.16122
G1 X159.52 Y161.227 E.01641
G1 X132.819 Y187.928 E1.16122
G1 X132.819 Y188.462 E.01641
G1 X159.52 Y161.761 E1.16122
G1 X159.52 Y162.294 E.01641
G1 X132.819 Y188.996 E1.16122
G1 X132.819 Y189.529 E.01641
G1 X159.52 Y162.828 E1.16122
G1 X159.52 Y163.362 E.01641
G1 X132.819 Y190.063 E1.16122
G1 X132.819 Y190.597 E.01641
G1 X159.52 Y163.896 E1.16122
G1 X159.52 Y164.429 E.01641
G1 X132.819 Y191.131 E1.16122
G1 X132.819 Y191.664 E.01641
G1 X159.52 Y164.963 E1.16122
G1 X159.52 Y165.497 E.01641
G1 X132.819 Y192.198 E1.16122
G1 X132.819 Y192.732 E.01641
G1 X159.52 Y166.03 E1.16122
G1 X159.52 Y166.564 E.01641
G1 X132.819 Y193.265 E1.16122
M73 P63 R12
G1 X132.819 Y193.799 E.01641
G1 X159.52 Y167.098 E1.16122
G1 X159.52 Y167.631 E.01641
G1 X132.819 Y194.333 E1.16122
G1 X132.819 Y194.866 E.01641
G1 X159.52 Y168.165 E1.16122
G1 X159.52 Y168.699 E.01641
G1 X132.819 Y195.4 E1.16122
G1 X132.819 Y195.934 E.01641
G1 X159.52 Y169.233 E1.16122
G1 X159.52 Y169.766 E.01641
G1 X132.819 Y196.467 E1.16122
G1 X132.819 Y197.001 E.01641
G1 X159.52 Y170.3 E1.16122
G1 X159.52 Y170.834 E.01641
G1 X132.819 Y197.535 E1.16122
M73 P63 R11
G1 X132.819 Y198.069 E.01641
G1 X159.52 Y171.367 E1.16122
G1 X159.52 Y171.901 E.01641
G1 X132.819 Y198.602 E1.16122
G1 X132.819 Y199.136 E.01641
G1 X159.52 Y172.435 E1.16122
G1 X159.52 Y172.968 E.01641
G1 X132.819 Y199.67 E1.16122
G1 X132.819 Y200.203 E.01641
G1 X159.52 Y173.502 E1.16122
G1 X159.52 Y174.036 E.01641
G1 X132.819 Y200.737 E1.16122
G1 X132.819 Y201.271 E.01641
G1 X159.52 Y174.569 E1.16122
G1 X159.52 Y175.103 E.01641
G1 X132.819 Y201.804 E1.16122
G1 X132.819 Y202.338 E.01641
G1 X159.52 Y175.637 E1.16122
G1 X159.52 Y176.171 E.01641
G1 X132.819 Y202.872 E1.16122
G1 X132.819 Y203.406 E.01641
G1 X159.52 Y176.704 E1.16122
G1 X159.52 Y177.238 E.01641
G1 X132.819 Y203.939 E1.16122
G1 X132.819 Y204.473 E.01641
G1 X159.52 Y177.772 E1.16122
G1 X159.52 Y178.305 E.01641
G1 X132.819 Y205.007 E1.16122
G1 X132.819 Y205.54 E.01641
G1 X159.52 Y178.839 E1.16122
G1 X159.52 Y179.373 E.01641
G1 X132.82 Y206.074 E1.16121
G1 X132.969 Y206.233 E.00673
G3 X133.712 Y205.715 I1.991 J2.064 E.02794
G1 X159.52 Y179.906 E1.12241
G1 X159.52 Y180.44 E.01641
G1 X134.507 Y205.454 E1.08783
G3 X135.092 Y205.402 I.572 J3.123 E.01811
G1 X159.52 Y180.974 E1.06236
G1 X159.52 Y181.508 E.01641
G1 X135.585 Y205.443 E1.04093
G3 X136.013 Y205.549 I-.765 J3.988 E.01355
G1 X159.52 Y182.041 E1.02234
G1 X159.52 Y182.575 E.01641
G1 X136.396 Y205.7 E1.00569
G3 X136.741 Y205.888 I-.767 J1.819 E.01212
G1 X159.52 Y183.109 E.99066
G1 X159.52 Y183.642 E.01641
G1 X137.048 Y206.115 E.9773
G3 X137.323 Y206.374 I-1.155 J1.498 E.01163
G1 X159.52 Y184.176 E.96537
G1 X159.52 Y184.71 E.01641
G1 X137.566 Y206.665 E.95481
G3 X137.776 Y206.988 I-1.512 J1.215 E.01188
G1 X159.52 Y185.243 E.94565
G1 X159.52 Y185.777 E.01641
G1 X137.948 Y207.35 E.93819
G3 X138.077 Y207.755 I-1.959 J.846 E.01309
G1 X159.52 Y186.311 E.93258
G1 X159.52 Y186.844 E.01641
G1 X138.157 Y208.208 E.9291
G3 X138.159 Y208.739 I-2.646 J.279 E.01636
G1 X159.52 Y187.378 E.92898
G1 X159.52 Y187.912 E.01641
G1 X138.039 Y209.393 E.93422
G3 X137.389 Y210.543 I-2.927 J-.897 E.04092
G1 X137.407 Y210.559 E.00075
G1 X159.52 Y188.446 E.96169
G1 X159.52 Y188.979 E.01641
G1 X137.749 Y210.751 E.94683
G1 X138.283 Y210.751 E.01641
G1 X159.52 Y189.513 E.92362
G1 X159.52 Y190.047 E.01641
G1 X138.816 Y210.751 E.90041
G1 X139.35 Y210.751 E.01641
G1 X159.52 Y190.58 E.8772
G1 X159.52 Y191.114 E.01641
G1 X139.884 Y210.751 E.85399
G1 X140.418 Y210.751 E.01641
G1 X159.52 Y191.648 E.83078
G1 X159.52 Y192.181 E.01641
G1 X140.951 Y210.751 E.80757
G1 X141.485 Y210.751 E.01641
G1 X159.52 Y192.715 E.78436
G1 X159.52 Y193.249 E.01641
G1 X142.019 Y210.751 E.76115
G1 X142.552 Y210.751 E.01641
G1 X159.52 Y193.783 E.73794
G1 X159.52 Y194.316 E.01641
G1 X143.086 Y210.751 E.71472
G1 X143.62 Y210.751 E.01641
G1 X159.52 Y194.85 E.69151
G1 X159.52 Y195.384 E.01641
G1 X144.153 Y210.751 E.6683
G1 X144.687 Y210.751 E.01641
G1 X159.52 Y195.917 E.64509
G1 X159.52 Y196.451 E.01641
G1 X145.221 Y210.751 E.62188
G1 X145.755 Y210.751 E.01641
G1 X159.52 Y196.985 E.59867
G1 X159.52 Y197.518 E.01641
G1 X146.288 Y210.751 E.57546
G1 X146.822 Y210.751 E.01641
G1 X159.52 Y198.052 E.55225
G1 X159.52 Y198.586 E.01641
G1 X147.356 Y210.751 E.52904
G1 X147.889 Y210.751 E.01641
G1 X159.52 Y199.119 E.50583
G1 X159.52 Y199.653 E.01641
G1 X148.423 Y210.751 E.48262
G1 X148.957 Y210.751 E.01641
G1 X159.52 Y200.187 E.45941
G1 X159.52 Y200.721 E.01641
G1 X149.49 Y210.751 E.4362
G1 X150.024 Y210.751 E.01641
G1 X159.52 Y201.254 E.41299
G1 X159.52 Y201.788 E.01641
G1 X150.558 Y210.751 E.38978
G1 X151.091 Y210.751 E.01641
G1 X159.52 Y202.322 E.36657
G1 X159.52 Y202.855 E.01641
G1 X151.625 Y210.751 E.34336
G1 X152.159 Y210.751 E.01641
G1 X159.52 Y203.389 E.32015
G1 X159.52 Y203.923 E.01641
G1 X152.693 Y210.751 E.29694
G1 X153.226 Y210.751 E.01641
G1 X159.52 Y204.456 E.27373
G1 X159.52 Y204.99 E.01641
G1 X153.76 Y210.751 E.25052
G1 X154.294 Y210.751 E.01641
G1 X159.52 Y205.524 E.22731
G1 X159.52 Y206.058 E.01641
G1 X154.827 Y210.751 E.2041
G1 X155.361 Y210.751 E.01641
G1 X159.52 Y206.591 E.18089
G1 X159.52 Y207.125 E.01641
G1 X155.895 Y210.751 E.15768
G1 X156.428 Y210.751 E.01641
G1 X159.52 Y207.659 E.13447
G1 X159.52 Y208.192 E.01641
G1 X156.962 Y210.751 E.11126
G1 X157.496 Y210.751 E.01641
G1 X159.52 Y208.726 E.08805
G1 X159.52 Y209.26 E.01641
G1 X158.03 Y210.751 E.06484
G1 X158.563 Y210.751 E.01641
G1 X159.52 Y209.793 E.04163
G1 X159.52 Y210.327 E.01641
G1 X158.927 Y210.92 E.0258
M204 S10000
G1 X137.083 Y210.716 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.110993
G1 F15000
M204 S6000
G1 X137.046 Y210.758 E.00031
G3 X136.897 Y210.862 I-.18 J-.098 E.00105
M204 S10000
G1 X136.264 Y211.044 F42000
; LINE_WIDTH: 0.431334
G1 F15000
M204 S6000
G3 X135.936 Y211.106 I-1.41 J-6.605 E.01057
; LINE_WIDTH: 0.388716
G1 X135.808 Y211.123 E.00363
; LINE_WIDTH: 0.351508
G1 X135.666 Y211.143 E.00361
; LINE_WIDTH: 0.309163
G1 X135.398 Y211.166 E.00583
; LINE_WIDTH: 0.279192
G1 X134.875 Y211.172 E.01006
G1 X134.595 Y211.155 E.0054
; LINE_WIDTH: 0.322691
G1 X134.467 Y211.14 E.00294
; LINE_WIDTH: 0.353433
G1 X134.323 Y211.124 E.00367
; LINE_WIDTH: 0.390652
G1 X134.2 Y211.103 E.00354
; LINE_WIDTH: 0.4226
G1 X134.076 Y211.083 E.00387
G1 X133.938 Y210.81 E.00946
; WIPE_START
G1 X134.076 Y211.083 E-.53948
G1 X134.2 Y211.103 E-.22052
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.883 Y210.671 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.38672
G1 F15000
M204 S6000
G1 X132.818 Y210.708 E.00208
G1 X132.868 Y210.737 E.00161
; WIPE_START
G1 X132.818 Y210.708 E-.33089
G1 X132.883 Y210.671 E-.42911
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.523 Y209.693 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.436817
G1 F15000
M204 S6000
G1 X132.49 Y209.504 E.00616
; LINE_WIDTH: 0.405889
G1 X132.456 Y209.315 E.00568
; LINE_WIDTH: 0.371443
G1 X132.438 Y209.17 E.00391
; LINE_WIDTH: 0.337213
G1 X132.422 Y209.042 E.00309
; LINE_WIDTH: 0.300349
G1 X132.401 Y208.773 E.00567
; LINE_WIDTH: 0.272614
G1 X132.401 Y208.239 E.01
; LINE_WIDTH: 0.298419
G1 X132.42 Y207.971 E.00558
; LINE_WIDTH: 0.335524
G1 X132.438 Y207.83 E.0034
; LINE_WIDTH: 0.369254
G1 X132.454 Y207.702 E.00342
; LINE_WIDTH: 0.404422
G1 X132.49 Y207.496 E.00616
; LINE_WIDTH: 0.436851
G1 X132.523 Y207.307 E.00616
M204 S10000
G1 X132.708 Y206.672 F42000
; LINE_WIDTH: 0.104455
G1 F15000
M204 S6000
G3 X132.763 Y206.581 I.122 J.012 E.00055
G1 X132.804 Y206.543 E.00028
; WIPE_START
G1 X132.763 Y206.581 E-.2556
G1 X132.726 Y206.619 E-.24856
G1 X132.708 Y206.672 E-.25584
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X130.627 Y199.329 Z1.6 F42000
G1 X109.034 Y123.12 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.4203
G1 F15000
M204 S6000
G1 X146.693 Y85.461 E1.6378
G3 X146.049 Y85.571 I-.846 J-2.992 E.02015
G1 X108.67 Y122.951 E1.6256
G1 X108.136 Y122.951 E.01641
G1 X145.525 Y85.561 E1.62604
G3 X145.073 Y85.48 I.179 J-2.295 E.01416
G1 X107.602 Y122.951 E1.62958
G1 X107.069 Y122.951 E.01641
G1 X144.672 Y85.347 E1.63536
G3 X144.315 Y85.171 I.703 J-1.873 E.01227
G1 X106.535 Y122.951 E1.64303
G1 X106.001 Y122.951 E.01641
G1 X143.992 Y84.96 E1.65221
G3 X143.707 Y84.711 I.836 J-1.245 E.01166
G1 X105.468 Y122.951 E1.66303
G1 X104.934 Y122.951 E.01641
G1 X143.448 Y84.437 E1.67495
G3 X143.224 Y84.127 I1.434 J-1.275 E.01177
G1 X113.112 Y114.238 E1.30952
G2 X113.345 Y113.472 I-2.156 J-1.074 E.02476
G1 X143.036 Y83.781 E1.29125
G3 X142.89 Y83.393 I1.859 J-.925 E.01275
G1 X113.388 Y112.895 E1.28301
G2 X113.34 Y112.41 I-2.454 J0 E.01502
G1 X142.787 Y82.963 E1.28065
G3 X142.752 Y82.464 I3.859 J-.521 E.01539
G1 X113.231 Y111.985 E1.28385
G2 X113.076 Y111.606 I-1.969 J.587 E.0126
G1 X142.813 Y81.869 E1.29324
G1 X142.837 Y81.749 E.00376
G1 X142.399 Y81.749 E.01347
G1 X112.884 Y111.265 E1.2836
G2 X112.657 Y110.957 I-4.435 J3.034 E.01174
G1 X141.866 Y81.749 E1.27024
G1 X141.332 Y81.749 E.01641
G1 X112.395 Y110.686 E1.25845
G2 X112.101 Y110.447 I-1.344 J1.35 E.01169
G1 X140.798 Y81.749 E1.24803
G1 X140.264 Y81.749 E.01641
G1 X111.774 Y110.24 E1.23904
G2 X111.411 Y110.069 I-2.234 J4.268 E.01233
G1 X139.731 Y81.749 E1.2316
G1 X139.197 Y81.749 E.01641
G1 X111.001 Y109.945 E1.22622
G2 X110.543 Y109.87 I-.605 J2.252 E.01431
G1 X138.663 Y81.749 E1.22294
G1 X138.13 Y81.749 E.01641
G1 X110.004 Y109.875 E1.22317
G2 X109.334 Y110.011 I.321 J3.303 E.02104
G1 X137.596 Y81.749 E1.22908
G1 X137.062 Y81.749 E.01641
M73 P64 R11
G1 X100.848 Y117.963 E1.57493
G3 X101.145 Y118.2 I-1.033 J1.601 E.0117
G1 X107.344 Y112.002 E.26957
G2 X107.205 Y112.674 I2.981 J.964 E.02115
G1 X101.411 Y118.468 E.25201
G3 X101.643 Y118.77 I-3.986 J3.312 E.0117
G1 X107.202 Y113.211 E.24176
G2 X107.274 Y113.673 I2.344 J-.128 E.0144
G1 X101.838 Y119.108 E.2364
G3 X101.996 Y119.484 I-1.799 J.981 E.01255
G1 X107.4 Y114.08 E.23501
G2 X107.57 Y114.443 I1.9 J-.668 E.01236
G1 X102.112 Y119.902 E.23737
G3 X102.165 Y120.382 I-2.38 J.507 E.01489
G1 X107.776 Y114.772 E.24399
G2 X108.014 Y115.067 I4.41 J-3.319 E.01167
G1 X102.135 Y120.946 E.25568
G3 X101.938 Y121.677 I-3.216 J-.476 E.02334
G1 X108.291 Y115.324 E.27628
G2 X108.593 Y115.555 I1.061 J-1.075 E.01174
G1 X101.287 Y122.862 E.31775
G1 X101.369 Y122.951 E.00373
G1 X101.732 Y122.951 E.01114
G1 X108.935 Y115.747 E.31328
G2 X109.315 Y115.901 I.955 J-1.82 E.01263
G1 X102.265 Y122.951 E.30661
G1 X102.799 Y122.951 E.01641
G1 X109.738 Y116.011 E.30178
G2 X110.226 Y116.057 I.624 J-4.036 E.01508
G1 X103.333 Y122.951 E.2998
G1 X103.866 Y122.951 E.01641
G1 X110.802 Y116.015 E.30162
G2 X111.563 Y115.788 I-.56 J-3.263 E.02447
G1 X104.23 Y123.12 E.31887
M204 S10000
G1 X100.864 Y122.897 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.116104
G1 F15000
M204 S6000
G1 X100.652 Y123.08 E.00167
M204 S10000
G1 X99.87 Y123.225 F42000
; LINE_WIDTH: 0.506078
G1 F13602.278
M204 S6000
G3 X99.406 Y123.265 I-1.033 J-9.269 E.01758
; LINE_WIDTH: 0.479702
G1 F14423.687
G3 X98.573 Y123.253 I-.326 J-6.238 E.02967
; LINE_WIDTH: 0.517718
G1 F13268.804
G1 X98.271 Y123.219 E.01175
; WIPE_START
G1 X98.573 Y123.253 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.949 Y122.799 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.50462
G1 F13645.224
M204 S6000
G2 X96.947 Y122.899 I-.029 J.049 E.00893
; WIPE_START
G1 X96.892 Y122.899 E-.18432
G1 X96.863 Y122.849 E-.1919
G1 X96.892 Y122.799 E-.19191
G1 X96.949 Y122.799 E-.19187
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.528 Y121.697 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.444647
G1 F15000
M204 S6000
G1 X96.479 Y121.453 E.00815
; LINE_WIDTH: 0.413065
G1 X96.456 Y121.306 E.00449
; LINE_WIDTH: 0.371546
G1 X96.437 Y121.178 E.00346
; LINE_WIDTH: 0.337225
G1 X96.422 Y121.035 E.00345
; LINE_WIDTH: 0.310022
G1 X96.41 Y120.907 E.0028
; LINE_WIDTH: 0.278185
G1 X96.396 Y120.628 E.00537
G1 X96.409 Y120.105 E.01002
; LINE_WIDTH: 0.308796
G1 X96.422 Y119.965 E.00306
; LINE_WIDTH: 0.335607
G1 X96.435 Y119.837 E.00306
; LINE_WIDTH: 0.369259
G1 X96.456 Y119.694 E.00385
; LINE_WIDTH: 0.410094
G1 X96.476 Y119.566 E.00387
; LINE_WIDTH: 0.443796
G3 X96.528 Y119.303 I5.337 J.933 E.00877
M204 S10000
G1 X96.69 Y118.655 F42000
; LINE_WIDTH: 0.106223
G1 F15000
M204 S6000
G1 X96.812 Y118.535 E.00088
; WIPE_START
G1 X96.69 Y118.655 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.707 Y113.96 Z1.6 F42000
G1 X145.124 Y80.871 Z1.6
G1 Z1.2
G1 E.8 F1800
; LINE_WIDTH: 0.382523
G1 F15000
M204 S6000
G1 X145.242 Y80.644 E.00709
; LINE_WIDTH: 0.412209
G1 X145.251 Y80.627 E.00057
; LINE_WIDTH: 0.43898
G1 X145.26 Y80.611 E.00061
; OBJECT_ID: 124
; WIPE_START
G1 X145.251 Y80.627 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G1 X141.95 Y87.509 Z1.6 F42000
G1 X106.723 Y160.934 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X106.753 Y161.239 E.00942
G3 X105.061 Y159.705 I-1.559 J.019 E.22225
G1 X105.207 Y159.699 E.00449
G3 X106.706 Y160.878 I-.013 J1.559 E.06306
; WIPE_START
M204 S6000
G1 X106.753 Y161.239 E-.13848
G1 X106.73 Y161.549 E-.11798
G1 X106.642 Y161.847 E-.11802
G1 X106.497 Y162.122 E-.11804
G1 X106.405 Y162.247 E-.05907
G1 X106.185 Y162.467 E-.11813
G1 X105.987 Y162.598 E-.09027
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.152 Y163.547 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X104.715 Y163.498 E.0135
G3 X105.225 Y158.969 I.477 J-2.239 E.2073
G1 X105.329 Y158.973 E.00317
G3 X105.211 Y163.548 I-.137 J2.285 E.21619
M204 S10000
G1 X105.18 Y163.183 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F15000
M204 S6000
G1 X105.173 Y163.183 E.00018
G3 X103.272 Y161.291 I.024 J-1.924 E.08178
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.49 J.043 E.00482
G3 X105.555 Y163.15 I1.918 J.159 E.23562
G1 X105.239 Y163.178 E.00873
; OBJECT_ID: 102
; WIPE_START
G1 X105.173 Y163.183 E-.02534
G1 X104.792 Y163.141 E-.14563
G1 X104.497 Y163.052 E-.11727
G1 X104.173 Y162.889 E-.13779
G1 X103.87 Y162.654 E-.14563
G1 X103.62 Y162.363 E-.14565
G1 X103.565 Y162.265 E-.04269
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.055 Y154.648 Z1.6 F42000
G1 X104.067 Y154.458 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X104.097 Y154.763 E.00942
G3 X102.405 Y153.228 I-1.559 J.019 E.22225
G1 X102.551 Y153.222 E.00449
G3 X104.05 Y154.401 I-.013 J1.559 E.06306
; WIPE_START
M204 S6000
G1 X104.097 Y154.763 E-.13848
G1 X104.074 Y155.072 E-.11798
G1 X103.986 Y155.37 E-.11802
G1 X103.841 Y155.645 E-.11804
G1 X103.749 Y155.77 E-.05907
G1 X103.529 Y155.99 E-.11813
G1 X103.331 Y156.121 E-.09027
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.496 Y157.07 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X102.059 Y157.021 E.0135
G3 X102.57 Y152.492 I.477 J-2.239 E.2073
G1 X102.673 Y152.496 E.00317
G3 X102.556 Y157.071 I-.137 J2.285 E.21619
M204 S10000
G1 X102.524 Y156.707 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F15000
M204 S6000
G1 X102.517 Y156.706 E.00018
G3 X100.617 Y154.814 I.024 J-1.924 E.08178
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.49 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23562
G1 X102.584 Y156.701 E.00873
; OBJECT_ID: 91
; WIPE_START
G1 X102.517 Y156.706 E-.02534
G1 X102.136 Y156.664 E-.14563
G1 X101.841 Y156.575 E-.11727
G1 X101.517 Y156.412 E-.13779
G1 X101.214 Y156.177 E-.14563
G1 X100.964 Y155.886 E-.14565
G1 X100.909 Y155.788 E-.04269
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.172 Z1.6 F42000
G1 X101.411 Y147.981 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X101.442 Y148.286 E.00942
G3 X99.75 Y146.751 I-1.559 J.019 E.22225
G1 X99.896 Y146.745 E.00449
G3 X101.395 Y147.925 I-.013 J1.559 E.06306
; WIPE_START
M204 S6000
G1 X101.442 Y148.286 E-.13848
G1 X101.419 Y148.596 E-.11798
G1 X101.331 Y148.894 E-.11802
G1 X101.186 Y149.168 E-.11804
G1 X101.093 Y149.293 E-.05907
G1 X100.874 Y149.513 E-.11813
G1 X100.676 Y149.644 E-.09027
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.84 Y150.593 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X99.404 Y150.544 E.0135
G3 X99.914 Y146.016 I.477 J-2.239 E.2073
G1 X100.017 Y146.02 E.00317
G3 X99.9 Y150.594 I-.137 J2.285 E.21619
M204 S10000
G1 X99.868 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F15000
M204 S6000
G1 X99.862 Y150.23 E.00018
G3 X97.961 Y148.338 I.024 J-1.924 E.08178
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.49 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.23562
G1 X99.928 Y150.224 E.00873
; OBJECT_ID: 113
; WIPE_START
G1 X99.862 Y150.23 E-.02534
G1 X99.481 Y150.188 E-.14563
G1 X99.185 Y150.098 E-.11727
G1 X98.861 Y149.935 E-.13779
G1 X98.559 Y149.7 E-.14563
G1 X98.309 Y149.41 E-.14565
G1 X98.254 Y149.312 E-.04269
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.744 Y141.695 Z1.6 F42000
G1 X98.756 Y141.504 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X98.786 Y141.809 E.00942
G3 X97.094 Y140.274 I-1.559 J.019 E.22225
G1 X97.24 Y140.269 E.00449
G3 X98.739 Y141.448 I-.013 J1.559 E.06306
; WIPE_START
M204 S6000
G1 X98.786 Y141.809 E-.13848
G1 X98.763 Y142.119 E-.11798
G1 X98.675 Y142.417 E-.11802
G1 X98.53 Y142.691 E-.11804
G1 X98.438 Y142.817 E-.05907
G1 X98.218 Y143.036 E-.11813
G1 X98.02 Y143.168 E-.09027
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.185 Y144.117 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X96.748 Y144.068 E.0135
G3 X97.259 Y139.539 I.477 J-2.239 E.2073
G1 X97.362 Y139.543 E.00317
G3 X97.245 Y144.118 I-.137 J2.285 E.21619
M204 S10000
G1 X97.213 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F15000
M204 S6000
G1 X97.206 Y143.753 E.00018
G3 X95.305 Y141.861 I.024 J-1.924 E.08178
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.49 J.043 E.00482
G3 X97.588 Y143.72 I1.918 J.159 E.23562
G1 X97.273 Y143.748 E.00873
; CHANGE_LAYER
; Z_HEIGHT: 1.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02534
G1 X96.825 Y143.711 E-.14563
G1 X96.53 Y143.621 E-.11727
G1 X96.206 Y143.459 E-.13779
G1 X95.903 Y143.224 E-.14563
G1 X95.653 Y142.933 E-.14565
G1 X95.598 Y142.835 E-.04269
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 7/60
; update layer progress
M73 L7
M991 S0 P6 ;notify layer change
; OBJECT_ID: 80
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
M204 S10000
G17
G3 Z1.6 I.938 J.776 P1  F42000
G1 X144.666 Y83.494 Z1.6
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.656 Y83.482 E.0005
G3 X145.656 Y80.932 I1.194 J-1.003 E.10275
G1 X145.811 Y80.92 E.00478
G3 X144.878 Y83.699 I.039 J1.559 E.18395
G1 X144.709 Y83.536 E.0072
; WIPE_START
M204 S6000
G1 X144.656 Y83.482 E-.02894
G1 X144.48 Y83.226 E-.11797
G1 X144.359 Y82.94 E-.11805
G1 X144.297 Y82.636 E-.11799
G1 X144.292 Y82.4 E-.08938
G1 X144.338 Y82.095 E-.11738
G1 X144.444 Y81.803 E-.11812
G1 X144.516 Y81.686 E-.05218
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.204 Y89.129 Z1.8 F42000
G1 X155.536 Y130.281 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X155.424 Y130.188 E.00485
G3 X156.776 Y126.158 I1.646 J-1.689 E.17561
G1 X157.011 Y126.14 E.00782
G3 X155.791 Y130.481 I.059 J2.358 E.29262
G1 X155.584 Y130.318 E.00873
M204 S10000
G1 X155.789 Y129.964 F42000
G1 F15476.087
M204 S6000
G1 X155.708 Y129.897 E.0035
G3 X156.827 Y126.562 I1.362 J-1.398 E.1453
G1 X157.021 Y126.548 E.00647
G3 X156.012 Y130.139 I.049 J1.951 E.24209
G1 X155.836 Y130.001 E.00739
M204 S250
G1 X156.033 Y129.659 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X155.982 Y129.616 E.00205
G3 X156.876 Y126.952 I1.088 J-1.117 E.10754
G1 X157.031 Y126.94 E.00479
G3 X156.224 Y129.809 I.039 J1.559 E.17917
G1 X156.08 Y129.696 E.00565
; WIPE_START
M204 S6000
G1 X155.982 Y129.616 E-.0481
G1 X155.875 Y129.503 E-.05917
G1 X155.699 Y129.246 E-.11811
G1 X155.579 Y128.96 E-.11798
G1 X155.517 Y128.655 E-.11808
G1 X155.517 Y128.345 E-.11804
G1 X155.579 Y128.04 E-.11806
G1 X155.643 Y127.889 E-.06246
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.05 Y127.113 Z1.8 F42000
G1 X96.664 Y121.865 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X96.783 Y122.059 E.00756
G2 X98.09 Y123.091 I2.326 J-1.604 E.05608
G1 X98.049 Y123.284 E.00654
G1 X96.486 Y123.284 E.05184
G1 X96.486 Y121.915 E.0454
G1 X96.606 Y121.881 E.00415
; WIPE_START
G1 X96.783 Y122.059 E-.09531
G1 X96.949 Y122.279 E-.10472
G1 X97.137 Y122.482 E-.10502
G1 X97.344 Y122.664 E-.10475
G1 X97.568 Y122.825 E-.10502
G1 X97.807 Y122.963 E-.10479
G1 X98.09 Y123.091 E-.11803
G1 X98.078 Y123.148 E-.02236
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.726 Y120.288 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X96.784 Y119.918 E.01242
G3 X98.776 Y118.158 I2.286 J.581 E.09368
G1 X99.011 Y118.14 E.00782
G3 X96.714 Y120.374 I.059 J2.358 E.37484
G1 X96.718 Y120.347 E.00088
M204 S10000
G1 X97.127 Y120.349 F42000
G1 F15476.087
M204 S6000
G1 X97.178 Y120.018 E.01109
G3 X98.827 Y118.562 I1.892 J.48 E.07751
G1 X99.021 Y118.548 E.00647
G3 X97.12 Y120.409 I.049 J1.951 E.30968
M204 S250
G1 X97.514 Y120.407 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X97.559 Y120.115 E.00908
G3 X98.876 Y118.952 I1.511 J.384 E.05736
G1 X99.031 Y118.94 E.00478
G3 X97.511 Y120.467 I.039 J1.559 E.22795
; WIPE_START
M204 S6000
G1 X97.559 Y120.115 E-.13503
G1 X97.664 Y119.823 E-.11808
G1 X97.826 Y119.558 E-.11802
G1 X98.037 Y119.33 E-.11812
G1 X98.29 Y119.149 E-.11807
G1 X98.573 Y119.021 E-.1181
G1 X98.662 Y119.001 E-.03457
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.135 Y111.383 Z1.8 F42000
G1 X101.418 Y74.65 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X101.417 Y74.735 E.00281
G3 X98.776 Y72.158 I-2.347 J-.236 E.35111
G1 X99.011 Y72.14 E.00781
G3 X101.418 Y74.265 I.059 J2.358 E.11712
G1 X101.418 Y74.59 E.01078
M204 S10000
G1 X101.013 Y74.65 F42000
G1 F15476.087
M204 S6000
G1 X101.012 Y74.694 E.00147
G3 X98.827 Y72.562 I-1.942 J-.196 E.29049
G1 X99.021 Y72.548 E.00646
G3 X101.012 Y74.306 I.049 J1.951 E.09689
G1 X101.013 Y74.59 E.00944
M204 S250
G1 X100.622 Y74.65 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X100.621 Y74.655 E.00016
G3 X98.876 Y72.952 I-1.551 J-.156 E.21499
G1 X99.031 Y72.94 E.00478
G3 X100.621 Y74.345 I.039 J1.559 E.07171
G1 X100.622 Y74.59 E.00754
; WIPE_START
M204 S6000
G1 X100.621 Y74.655 E-.02474
G1 X100.561 Y74.96 E-.11802
G1 X100.44 Y75.246 E-.11814
G1 X100.265 Y75.503 E-.11796
G1 X100.043 Y75.72 E-.11805
G1 X99.784 Y75.887 E-.11709
G1 X99.567 Y75.979 E-.08968
G1 X99.422 Y76.012 E-.05633
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.348 Y80.822 Z1.8 F42000
G1 X143.389 Y111.698 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.489 Y111.517 E.00685
G3 X145.505 Y110.214 I2.361 J1.441 E.08238
G1 X145.781 Y110.193 E.00917
G3 X143.357 Y111.759 I.069 J2.765 E.47585
G1 X143.361 Y111.751 E.00031
M204 S10000
G1 X143.77 Y111.86 F42000
G1 F15476.087
M204 S6000
G1 X143.969 Y111.535 E.01262
G3 X145.556 Y110.618 I1.881 J1.423 E.06246
G1 X145.791 Y110.6 E.00782
G3 X143.724 Y111.936 I.059 J2.358 E.40578
G1 X143.739 Y111.911 E.00097
M204 S10000
G1 X144.116 Y112.071 F42000
G1 F15476.087
M204 S6000
G1 X144.294 Y111.781 E.01127
G3 X145.607 Y111.022 I1.556 J1.178 E.05167
G1 X145.801 Y111.008 E.00647
G3 X144.086 Y112.123 I.049 J1.951 E.33533
M204 S250
G1 X144.449 Y112.275 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.606 Y112.018 E.00924
G3 X145.656 Y111.412 I1.243 J.941 E.03825
G1 X145.811 Y111.4 E.00478
G3 X144.424 Y112.329 I.039 J1.559 E.24691
; WIPE_START
M204 S6000
G1 X144.606 Y112.018 E-.13697
G1 X144.817 Y111.79 E-.1181
G1 X145.07 Y111.609 E-.11804
G1 X145.353 Y111.481 E-.11804
G1 X145.656 Y111.412 E-.11805
G1 X145.811 Y111.4 E-.05916
G1 X146.051 Y111.418 E-.09164
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X138.429 Y111.818 Z1.8 F42000
G1 X113.048 Y113.151 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X113.042 Y113.235 E.00282
G3 X109.946 Y110.214 I-2.752 J-.277 E.41175
G1 X110.221 Y110.193 E.00916
G3 X113.056 Y112.96 I.069 J2.765 E.14649
G1 X113.051 Y113.091 E.00434
M204 S10000
G1 X112.638 Y113.09 F42000
G1 F15476.087
M204 S6000
G1 X112.637 Y113.195 E.00348
G3 X109.996 Y110.618 I-2.347 J-.236 E.35112
G1 X110.231 Y110.6 E.00781
G3 X112.637 Y112.725 I.059 J2.358 E.11711
G1 X112.638 Y113.03 E.01011
M204 S10000
G1 X112.226 Y113.129 F42000
G1 F15476.087
M204 S6000
G1 X112.202 Y113.347 E.00726
G3 X110.047 Y111.022 I-1.913 J-.388 E.28403
G1 X110.241 Y111.008 E.00646
G3 X112.241 Y112.96 I.049 J1.951 E.10334
G1 X112.231 Y113.069 E.00365
M204 S250
G1 X111.842 Y113.09 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.841 Y113.115 E.00078
G3 X110.096 Y111.412 I-1.551 J-.156 E.21499
G1 X110.251 Y111.4 E.00478
G3 X111.841 Y112.805 I.039 J1.559 E.07171
G1 X111.842 Y113.03 E.00691
; WIPE_START
M204 S6000
G1 X111.841 Y113.115 E-.03243
G1 X111.781 Y113.42 E-.11804
G1 X111.66 Y113.706 E-.11811
G1 X111.485 Y113.963 E-.11789
G1 X111.321 Y114.131 E-.08946
G1 X111.07 Y114.311 E-.11733
G1 X110.787 Y114.439 E-.11813
G1 X110.662 Y114.468 E-.04861
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X111.051 Y106.845 Z1.8 F42000
G1 X112.191 Y84.483 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X112.11 Y84.561 E.00372
G3 X109.945 Y79.734 I-1.82 J-2.083 E.34272
G1 X110.221 Y79.713 E.00917
G3 X112.409 Y84.256 I.069 J2.765 E.21047
G1 X112.232 Y84.439 E.00846
M204 S10000
G1 X111.901 Y84.198 F42000
G1 F15476.087
M204 S6000
G1 X111.844 Y84.254 E.00265
G3 X109.996 Y80.138 I-1.554 J-1.775 E.29232
G1 X110.231 Y80.12 E.00782
G3 X112.097 Y83.994 I.059 J2.358 E.17948
G1 X111.943 Y84.155 E.00738
M204 S10000
G1 X111.611 Y83.913 F42000
G1 F15476.087
M204 S6000
G1 X111.577 Y83.946 E.00157
G3 X110.047 Y80.542 I-1.287 J-1.467 E.24191
G1 X110.241 Y80.528 E.00647
G3 X111.785 Y83.733 I.049 J1.951 E.1485
G1 X111.653 Y83.87 E.00631
M204 S250
G1 X111.332 Y83.64 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X111.32 Y83.65 E.00048
G3 X110.096 Y80.932 I-1.03 J-1.171 E.17911
G1 X110.251 Y80.92 E.00479
G3 X111.484 Y83.482 I.039 J1.559 E.10991
G1 X111.373 Y83.597 E.00491
; WIPE_START
M204 S6000
G1 X111.32 Y83.65 E-.02867
G1 X111.07 Y83.831 E-.11728
G1 X110.787 Y83.959 E-.11812
G1 X110.484 Y84.028 E-.11805
G1 X110.173 Y84.036 E-.11803
G1 X109.867 Y83.982 E-.11813
G1 X109.578 Y83.868 E-.11801
G1 X109.526 Y83.835 E-.02371
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X117.015 Y82.365 Z1.8 F42000
G1 X121.854 Y81.416 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X143.285 Y81.416 E.71092
G2 X148.405 Y81.416 I2.56 J1.058 E.3607
G1 X159.854 Y81.416 E.37979
G1 X159.854 Y127.471 E1.52774
G1 X159.664 Y127.515 E.00646
G2 X159.664 Y129.485 I-2.588 J.985 E.51036
G1 X159.854 Y129.529 E.00646
G1 X159.854 Y211.084 E2.70534
G1 X136.488 Y211.084 E.77509
G1 X136.436 Y210.909 E.00606
G2 X132.668 Y207.129 I-1.366 J-2.407 E.33751
G1 X132.486 Y207.081 E.00624
G1 X132.486 Y123.284 E2.77972
G1 X100.088 Y123.284 E1.0747
G1 X100.05 Y123.085 E.00671
G2 X96.658 Y119.13 I-.986 J-2.586 E.35176
G1 X96.486 Y119.076 E.00598
G1 X96.486 Y75.915 E1.43174
G1 X96.664 Y75.865 E.00614
G2 X96.658 Y73.13 I2.403 J-1.373 E.48192
G1 X96.486 Y73.076 E.00598
G1 X96.486 Y44.916 E.93413
G1 X141.154 Y44.916 E1.48171
G1 X141.154 Y47.584 E.08849
G1 X137.154 Y47.584 E.13269
G1 X137.154 Y65.916 E.60812
G1 X141.154 Y65.916 E.13269
G1 X141.154 Y69.084 E.10507
G1 X121.854 Y69.084 E.64022
G1 X121.854 Y81.356 E.4071
; WIPE_START
G1 X123.854 Y81.362 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X124.46 Y88.97 Z1.8 F42000
G1 X133.824 Y206.503 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X133.89 Y206.456 E.00267
G3 X134.776 Y206.158 I1.18 J2.042 E.03122
G1 X135.011 Y206.14 E.00782
G3 X133.508 Y206.73 I.059 J2.358 E.437
G1 X133.775 Y206.538 E.01092
M204 S10000
G1 X134.061 Y206.832 F42000
G1 F15476.087
M204 S6000
G1 X134.094 Y206.809 E.00133
G3 X134.827 Y206.562 I.976 J1.69 E.02583
G1 X135.021 Y206.548 E.00647
G3 X133.778 Y207.036 I.049 J1.951 E.36154
G1 X134.012 Y206.867 E.00958
M204 S250
G1 X134.289 Y207.149 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X134.29 Y207.149 E.00003
G3 X134.876 Y206.952 I.78 J1.35 E.01912
G1 X135.031 Y206.94 E.00478
G3 X134.038 Y207.33 I.039 J1.559 E.26758
G1 X134.24 Y207.184 E.00767
; WIPE_START
M204 S6000
G1 X134.29 Y207.149 E-.02319
G1 X134.573 Y207.021 E-.11808
G1 X134.876 Y206.952 E-.11799
G1 X135.031 Y206.94 E-.05916
G1 X135.341 Y206.963 E-.11803
G1 X135.64 Y207.048 E-.11801
G1 X135.916 Y207.189 E-.11814
G1 X136.096 Y207.333 E-.0874
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.664 Y209.865 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.45
G1 F15476.087
M204 S6000
G1 X132.783 Y210.059 E.00755
G2 X133.702 Y210.903 I2.324 J-1.611 E.04174
G1 X133.654 Y211.084 E.00622
G1 X132.486 Y211.084 E.03874
G1 X132.486 Y209.915 E.03877
G1 X132.606 Y209.881 E.00415
; WIPE_START
G1 X132.783 Y210.059 E-.09527
G1 X132.949 Y210.279 E-.10478
G1 X133.137 Y210.482 E-.10497
G1 X133.344 Y210.664 E-.10477
G1 X133.702 Y210.903 E-.16369
G1 X133.654 Y211.084 E-.07121
G1 X133.351 Y211.084 E-.1153
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.702 Y203.479 Z1.8 F42000
G1 X122.261 Y81.009 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F15476.087
M204 S6000
G1 X143.999 Y81.009 E.72111
G2 X147.923 Y81.351 I1.849 J1.462 E.3367
G1 X147.714 Y81.009 E.01329
G1 X160.261 Y81.009 E.41621
G1 X160.261 Y211.491 E4.32832
G1 X132.079 Y211.491 E.93484
G1 X132.079 Y123.691 E2.91249
G1 X96.079 Y123.691 E1.19419
G1 X96.079 Y44.509 E2.6266
G1 X141.561 Y44.509 E1.50871
G1 X141.561 Y47.991 E.1155
G1 X137.561 Y47.991 E.13269
G1 X137.561 Y65.509 E.58111
G1 X141.561 Y65.509 E.13269
G1 X141.561 Y69.491 E.13208
G1 X122.261 Y69.491 E.64022
G1 X122.261 Y80.949 E.38009
M204 S10000
G1 X122.668 Y80.602 F42000
G1 F15476.087
M204 S6000
G1 X144.84 Y80.602 E.73549
G1 X144.891 Y80.777 E.00606
G2 X146.811 Y80.783 I.955 J1.698 E.33942
G1 X146.86 Y80.602 E.00622
G1 X160.668 Y80.602 E.45803
G1 X160.668 Y211.898 E4.35533
G1 X131.672 Y211.898 E.96185
G1 X131.672 Y124.098 E2.91249
G1 X95.672 Y124.098 E1.19419
G1 X95.672 Y44.102 E2.65361
G1 X141.968 Y44.102 E1.53572
G1 X141.968 Y48.398 E.1425
M73 P65 R11
G1 X137.968 Y48.398 E.13269
G1 X137.968 Y65.102 E.55411
G1 X141.968 Y65.102 E.13269
G1 X141.968 Y69.898 E.15909
G1 X122.668 Y69.898 E.64022
G1 X122.668 Y80.542 E.35309
M204 S250
G1 X123.06 Y80.21 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X161.06 Y80.21 E1.16763
G1 X161.06 Y212.29 E4.05845
G1 X131.28 Y212.29 E.91506
G1 X131.28 Y124.49 E2.69785
G1 X95.28 Y124.49 E1.10618
G1 X95.28 Y43.71 E2.48214
G1 X142.36 Y43.71 E1.44664
G1 X142.36 Y48.79 E.15609
G1 X138.36 Y48.79 E.12291
G1 X138.36 Y64.71 E.48918
G1 X142.36 Y64.71 E.12291
G1 X142.36 Y70.29 E.17146
G1 X123.06 Y70.29 E.59304
G1 X123.06 Y80.15 E.30297
; WIPE_START
M204 S6000
G1 X125.06 Y80.153 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 80
M625
; object ids of layer 7 start: 80,91,102,113,124
M624 HwAAAAAAAAA=
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


; object ids of this layer7 end: 80,91,102,113,124
M625
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X140.428 Y81.58 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42038
G1 F15000
M204 S6000
G1 X159.52 Y100.672 E.8305
G1 X159.52 Y101.206 E.01642
G1 X140.064 Y81.749 E.84633
G1 X139.53 Y81.749 E.01642
G1 X159.52 Y101.74 E.86955
G1 X159.52 Y102.274 E.01642
G1 X138.996 Y81.749 E.89277
G1 X138.462 Y81.749 E.01642
G1 X159.52 Y102.807 E.91599
G1 X159.52 Y103.341 E.01642
G1 X137.929 Y81.749 E.93921
G1 X137.395 Y81.749 E.01642
G1 X159.52 Y103.875 E.96243
G1 X159.52 Y104.409 E.01642
G1 X136.861 Y81.749 E.98565
G1 X136.327 Y81.749 E.01642
G1 X159.52 Y104.943 E1.00887
G1 X159.52 Y105.476 E.01642
G1 X135.793 Y81.749 E1.03209
G1 X135.26 Y81.749 E.01642
G1 X159.52 Y106.01 E1.05531
G1 X159.52 Y106.544 E.01642
G1 X134.726 Y81.749 E1.07853
G1 X134.192 Y81.749 E.01642
G1 X159.52 Y107.078 E1.10175
G1 X159.52 Y107.612 E.01642
G1 X133.658 Y81.749 E1.12497
G1 X133.124 Y81.749 E.01642
G1 X159.52 Y108.145 E1.14819
G1 X159.52 Y108.679 E.01642
G1 X132.591 Y81.749 E1.17141
G1 X132.057 Y81.749 E.01642
G1 X159.52 Y109.213 E1.19463
G1 X159.52 Y109.747 E.01642
G1 X131.523 Y81.749 E1.21785
G1 X130.989 Y81.749 E.01642
G1 X159.52 Y110.281 E1.24107
G1 X159.52 Y110.814 E.01642
G1 X130.455 Y81.749 E1.26429
G1 X129.922 Y81.749 E.01642
G1 X159.52 Y111.348 E1.28751
G1 X159.52 Y111.882 E.01642
G1 X129.388 Y81.749 E1.31073
G1 X128.854 Y81.749 E.01642
G1 X159.52 Y112.416 E1.33395
G1 X159.52 Y112.95 E.01642
G1 X128.32 Y81.749 E1.35717
G1 X127.786 Y81.749 E.01642
G1 X159.52 Y113.484 E1.38039
G1 X159.52 Y114.017 E.01642
G1 X127.252 Y81.749 E1.40361
G1 X126.719 Y81.749 E.01642
G1 X159.52 Y114.551 E1.42683
G1 X159.52 Y115.085 E.01642
G1 X126.185 Y81.749 E1.45005
G1 X125.651 Y81.749 E.01642
G1 X159.52 Y115.619 E1.47327
G1 X159.52 Y116.153 E.01642
G1 X125.117 Y81.749 E1.49649
G1 X124.583 Y81.749 E.01642
G1 X159.52 Y116.686 E1.51971
G1 X159.52 Y117.22 E.01642
G1 X124.05 Y81.749 E1.54293
G1 X123.516 Y81.749 E.01642
G1 X159.52 Y117.754 E1.56615
G1 X159.52 Y118.288 E.01642
G1 X122.982 Y81.749 E1.58937
G1 X122.448 Y81.749 E.01642
G1 X159.52 Y118.822 E1.61259
G1 X159.52 Y119.355 E.01642
G1 X121.914 Y81.749 E1.63581
G1 X121.52 Y81.749 E.01212
G1 X121.52 Y81.355 E.01212
G1 X96.819 Y56.654 E1.07447
G1 X96.819 Y56.12 E.01642
G1 X121.52 Y80.822 E1.07447
G1 X121.52 Y80.288 E.01642
G1 X96.819 Y55.587 E1.07447
G1 X96.819 Y55.053 E.01642
G1 X121.52 Y79.754 E1.07447
G1 X121.52 Y79.22 E.01642
G1 X96.819 Y54.519 E1.07447
G1 X96.819 Y53.985 E.01642
G1 X121.52 Y78.686 E1.07447
G1 X121.52 Y78.153 E.01642
G1 X96.819 Y53.451 E1.07447
G1 X96.819 Y52.917 E.01642
G1 X121.52 Y77.619 E1.07447
G1 X121.52 Y77.085 E.01642
G1 X96.819 Y52.384 E1.07447
G1 X96.819 Y51.85 E.01642
G1 X121.52 Y76.551 E1.07447
G1 X121.52 Y76.017 E.01642
G1 X96.819 Y51.316 E1.07447
G1 X96.819 Y50.782 E.01642
G1 X121.52 Y75.484 E1.07447
G1 X121.52 Y74.95 E.01642
G1 X96.819 Y50.248 E1.07447
G1 X96.819 Y49.715 E.01642
G1 X121.52 Y74.416 E1.07447
G1 X121.52 Y73.882 E.01642
G1 X96.819 Y49.181 E1.07447
G1 X96.819 Y48.647 E.01642
G1 X121.52 Y73.348 E1.07447
G1 X121.52 Y72.814 E.01642
G1 X96.819 Y48.113 E1.07447
G1 X96.819 Y47.579 E.01642
G1 X121.52 Y72.281 E1.07447
G1 X121.52 Y71.747 E.01642
G1 X96.819 Y47.046 E1.07447
G1 X96.819 Y46.512 E.01642
G1 X121.52 Y71.213 E1.07447
G1 X121.52 Y70.679 E.01642
G1 X96.819 Y45.978 E1.07447
G1 X96.819 Y45.444 E.01642
G1 X121.52 Y70.145 E1.07447
M73 P66 R11
G1 X121.52 Y69.612 E.01642
G1 X97.158 Y45.249 E1.05973
G1 X97.692 Y45.249 E.01642
G1 X121.52 Y69.078 E1.03651
G1 X121.52 Y68.751 E.01006
G1 X121.727 Y68.751 E.00636
G1 X98.226 Y45.249 E1.02227
G1 X98.76 Y45.249 E.01642
G1 X122.261 Y68.751 E1.02227
G1 X122.795 Y68.751 E.01642
G1 X99.293 Y45.249 E1.02227
G1 X99.827 Y45.249 E.01642
G1 X123.329 Y68.751 E1.02227
G1 X123.862 Y68.751 E.01642
G1 X100.361 Y45.249 E1.02227
G1 X100.895 Y45.249 E.01642
G1 X124.396 Y68.751 E1.02227
G1 X124.93 Y68.751 E.01642
G1 X101.429 Y45.249 E1.02227
G1 X101.962 Y45.249 E.01642
G1 X125.464 Y68.751 E1.02227
G1 X125.998 Y68.751 E.01642
G1 X102.496 Y45.249 E1.02227
G1 X103.03 Y45.249 E.01642
G1 X126.531 Y68.751 E1.02227
G1 X127.065 Y68.751 E.01642
G1 X103.564 Y45.249 E1.02227
G1 X104.098 Y45.249 E.01642
G1 X127.599 Y68.751 E1.02227
G1 X128.133 Y68.751 E.01642
G1 X104.632 Y45.249 E1.02227
G1 X105.165 Y45.249 E.01642
G1 X128.667 Y68.751 E1.02227
G1 X129.2 Y68.751 E.01642
M73 P66 R10
G1 X105.699 Y45.249 E1.02227
G1 X106.233 Y45.249 E.01642
G1 X129.734 Y68.751 E1.02227
G1 X130.268 Y68.751 E.01642
G1 X106.767 Y45.249 E1.02227
G1 X107.301 Y45.249 E.01642
G1 X130.802 Y68.751 E1.02227
G1 X131.336 Y68.751 E.01642
G1 X107.834 Y45.249 E1.02227
G1 X108.368 Y45.249 E.01642
G1 X131.869 Y68.751 E1.02227
G1 X132.403 Y68.751 E.01642
G1 X108.902 Y45.249 E1.02227
G1 X109.436 Y45.249 E.01642
G1 X132.937 Y68.751 E1.02227
G1 X133.471 Y68.751 E.01642
G1 X109.97 Y45.249 E1.02227
G1 X110.503 Y45.249 E.01642
G1 X134.005 Y68.751 E1.02227
G1 X134.539 Y68.751 E.01642
G1 X111.037 Y45.249 E1.02227
G1 X111.571 Y45.249 E.01642
G1 X135.072 Y68.751 E1.02227
G1 X135.606 Y68.751 E.01642
G1 X112.105 Y45.249 E1.02227
G1 X112.639 Y45.249 E.01642
G1 X136.14 Y68.751 E1.02227
G1 X136.674 Y68.751 E.01642
G1 X113.172 Y45.249 E1.02227
G1 X113.706 Y45.249 E.01642
G1 X137.208 Y68.751 E1.02227
G1 X137.741 Y68.751 E.01642
G1 X114.24 Y45.249 E1.02227
G1 X114.774 Y45.249 E.01642
G1 X138.275 Y68.751 E1.02227
G1 X138.809 Y68.751 E.01642
G1 X115.308 Y45.249 E1.02227
G1 X115.842 Y45.249 E.01642
G1 X139.512 Y68.92 E1.02965
M204 S10000
G1 X140.99 Y66.661 F42000
G1 F15000
M204 S6000
G1 X140.578 Y66.249 E.01792
G1 X140.044 Y66.249 E.01642
G1 X140.82 Y67.025 E.03376
G1 X140.82 Y67.559 E.01642
G1 X139.511 Y66.249 E.05698
G1 X138.977 Y66.249 E.01642
G1 X140.82 Y68.093 E.0802
G1 X140.82 Y68.627 E.01642
G1 X138.443 Y66.249 E.10342
G1 X137.909 Y66.249 E.01642
G1 X140.41 Y68.751 E.1088
G1 X139.877 Y68.751 E.01642
G1 X137.206 Y66.08 E.11618
M204 S10000
G1 X136.99 Y65.864 F42000
G1 F15000
M204 S6000
G1 X116.375 Y45.249 E.89672
G1 X116.909 Y45.249 E.01642
G1 X136.82 Y65.161 E.86612
G1 X136.82 Y64.627 E.01642
G1 X117.443 Y45.249 E.8429
G1 X117.977 Y45.249 E.01642
G1 X136.82 Y64.093 E.81968
G1 X136.82 Y63.559 E.01642
G1 X118.511 Y45.249 E.79646
G1 X119.044 Y45.249 E.01642
G1 X136.82 Y63.025 E.77324
G1 X136.82 Y62.492 E.01642
G1 X119.578 Y45.249 E.75002
G1 X120.112 Y45.249 E.01642
G1 X136.82 Y61.958 E.7268
G1 X136.82 Y61.424 E.01642
G1 X120.646 Y45.249 E.70358
G1 X121.18 Y45.249 E.01642
G1 X136.82 Y60.89 E.68036
G1 X136.82 Y60.356 E.01642
G1 X121.713 Y45.249 E.65714
G1 X122.247 Y45.249 E.01642
G1 X136.82 Y59.823 E.63392
G1 X136.82 Y59.289 E.01642
G1 X122.781 Y45.249 E.6107
G1 X123.315 Y45.249 E.01642
G1 X136.82 Y58.755 E.58748
G1 X136.82 Y58.221 E.01642
G1 X123.849 Y45.249 E.56426
G1 X124.382 Y45.249 E.01642
G1 X136.82 Y57.687 E.54104
G1 X136.82 Y57.154 E.01642
G1 X124.916 Y45.249 E.51782
G1 X125.45 Y45.249 E.01642
G1 X136.82 Y56.62 E.4946
G1 X136.82 Y56.086 E.01642
G1 X125.984 Y45.249 E.47138
G1 X126.518 Y45.249 E.01642
G1 X136.82 Y55.552 E.44816
G1 X136.82 Y55.018 E.01642
G1 X127.052 Y45.249 E.42494
G1 X127.585 Y45.249 E.01642
G1 X136.82 Y54.485 E.40172
G1 X136.82 Y53.951 E.01642
G1 X128.119 Y45.249 E.3785
G1 X128.653 Y45.249 E.01642
G1 X136.82 Y53.417 E.35528
G1 X136.82 Y52.883 E.01642
G1 X129.187 Y45.249 E.33206
G1 X129.721 Y45.249 E.01642
G1 X136.82 Y52.349 E.30884
G1 X136.82 Y51.815 E.01642
G1 X130.254 Y45.249 E.28562
G1 X130.788 Y45.249 E.01642
G1 X136.82 Y51.282 E.2624
G1 X136.82 Y50.748 E.01642
G1 X131.322 Y45.249 E.23918
G1 X131.856 Y45.249 E.01642
G1 X136.82 Y50.214 E.21596
G1 X136.82 Y49.68 E.01642
G1 X132.39 Y45.249 E.19274
G1 X132.923 Y45.249 E.01642
G1 X136.82 Y49.146 E.16952
G1 X136.82 Y48.613 E.01642
G1 X133.457 Y45.249 E.1463
G1 X133.991 Y45.249 E.01642
G1 X136.82 Y48.079 E.12308
G1 X136.82 Y47.545 E.01642
G1 X134.525 Y45.249 E.09986
G1 X135.059 Y45.249 E.01642
G1 X137.06 Y47.251 E.08705
G1 X137.594 Y47.251 E.01642
G1 X135.592 Y45.249 E.08705
G1 X136.126 Y45.249 E.01642
G1 X138.128 Y47.251 E.08705
G1 X138.661 Y47.251 E.01642
G1 X136.66 Y45.249 E.08705
G1 X137.194 Y45.249 E.01642
G1 X139.195 Y47.251 E.08705
G1 X139.729 Y47.251 E.01642
G1 X137.728 Y45.249 E.08705
G1 X138.262 Y45.249 E.01642
G1 X140.263 Y47.251 E.08705
G1 X140.797 Y47.251 E.01642
G1 X138.795 Y45.249 E.08705
G1 X139.329 Y45.249 E.01642
G1 X140.82 Y46.741 E.06487
G1 X140.82 Y46.207 E.01642
G1 X139.863 Y45.249 E.04165
G1 X140.397 Y45.249 E.01642
G1 X140.99 Y45.843 E.02581
; WIPE_START
G1 X140.397 Y45.249 E-.3189
G1 X139.863 Y45.249 E-.20285
G1 X140.306 Y45.693 E-.23826
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X141.414 Y53.244 Z1.8 F42000
G1 X145.427 Y80.588 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.374631
G1 F15000
M204 S6000
G1 X145.81 Y80.565 E.01036
G1 X146.176 Y80.579 E.00991
; LINE_WIDTH: 0.409248
G1 X146.369 Y80.6 E.00579
; LINE_WIDTH: 0.444223
G3 X146.645 Y80.645 I-.757 J5.557 E.00916
M204 S10000
G1 X147.288 Y80.806 F42000
; LINE_WIDTH: 0.113534
G1 F15000
M204 S6000
G1 X147.427 Y80.978 E.00127
; WIPE_START
G1 X147.288 Y80.806 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.427 Y80.588 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; LINE_WIDTH: 0.429372
G1 F15000
M204 S6000
G1 X145.26 Y80.611 E.00531
; LINE_WIDTH: 0.439083
G1 X145.251 Y80.627 E.0006
; LINE_WIDTH: 0.412508
G1 X145.242 Y80.643 E.00056
; LINE_WIDTH: 0.38291
G1 X145.124 Y80.871 E.00711
; WIPE_START
G1 X145.242 Y80.643 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.964 Y81.98 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42038
G1 F15000
M204 S6000
G1 X142.733 Y81.749 E.01003
G1 X142.199 Y81.749 E.01642
G1 X142.754 Y82.304 E.02414
G1 X142.774 Y82.858 E.01704
G1 X141.665 Y81.749 E.04823
G1 X141.132 Y81.749 E.01642
G1 X142.949 Y83.567 E.07905
G2 X144.766 Y85.384 I2.88 J-1.063 E.08155
G1 X159.52 Y100.138 E.64181
G1 X159.52 Y99.604 E.01642
G1 X145.47 Y85.554 E.61116
G2 X146.023 Y85.573 I.385 J-3.148 E.01704
G1 X159.52 Y99.071 E.58711
G1 X159.52 Y98.537 E.01642
G1 X146.495 Y85.512 E.56658
G2 X146.909 Y85.392 I-.863 J-3.76 E.01326
G1 X159.52 Y98.003 E.54857
G1 X159.52 Y97.469 E.01642
G1 X147.279 Y85.228 E.53247
G2 X147.614 Y85.029 I-.832 J-1.771 E.01199
G1 X159.52 Y96.935 E.51794
G1 X159.52 Y96.402 E.01642
G1 X147.912 Y84.794 E.50494
G1 X148.177 Y84.524 E.01161
G1 X159.52 Y95.868 E.49344
G1 X159.52 Y95.334 E.01642
G1 X148.413 Y84.226 E.48316
G2 X148.609 Y83.889 I-1.591 J-1.152 E.01203
G1 X159.52 Y94.8 E.47462
G1 X159.52 Y94.266 E.01642
G1 X148.769 Y83.515 E.46765
G2 X148.888 Y83.1 I-2.018 J-.803 E.0133
G1 X159.52 Y93.733 E.46248
G1 X159.52 Y93.199 E.01642
G1 X148.944 Y82.623 E.46005
G2 X148.92 Y82.064 I-3.14 J-.142 E.01721
G1 X159.52 Y92.665 E.46111
G1 X159.52 Y92.131 E.01642
G1 X149.139 Y81.749 E.45159
G1 X149.672 Y81.749 E.01642
G1 X159.52 Y91.597 E.42837
G1 X159.52 Y91.064 E.01642
G1 X150.206 Y81.749 E.40515
G1 X150.74 Y81.749 E.01642
G1 X159.52 Y90.53 E.38193
G1 X159.52 Y89.996 E.01642
G1 X151.274 Y81.749 E.35871
G1 X151.808 Y81.749 E.01642
G1 X159.52 Y89.462 E.33549
G1 X159.52 Y88.928 E.01642
G1 X152.342 Y81.749 E.31227
G1 X152.875 Y81.749 E.01642
G1 X159.52 Y88.395 E.28905
G1 X159.52 Y87.861 E.01642
G1 X153.409 Y81.749 E.26583
G1 X153.943 Y81.749 E.01642
G1 X159.52 Y87.327 E.24261
G1 X159.52 Y86.793 E.01642
G1 X154.477 Y81.749 E.21939
G1 X155.011 Y81.749 E.01642
G1 X159.52 Y86.259 E.19617
G1 X159.52 Y85.725 E.01642
G1 X155.544 Y81.749 E.17295
G1 X156.078 Y81.749 E.01642
G1 X159.52 Y85.192 E.14973
G1 X159.52 Y84.658 E.01642
G1 X156.612 Y81.749 E.12651
G1 X157.146 Y81.749 E.01642
G1 X159.52 Y84.124 E.10329
G1 X159.52 Y83.59 E.01642
G1 X157.68 Y81.749 E.08007
G1 X158.213 Y81.749 E.01642
G1 X159.52 Y83.056 E.05685
G1 X159.52 Y82.523 E.01642
G1 X158.747 Y81.749 E.03363
G1 X159.281 Y81.749 E.01642
G1 X159.69 Y82.158 E.0178
M204 S10000
G1 X143.245 Y111.621 F42000
G1 F15000
M204 S6000
G1 X113.275 Y81.651 E1.30364
G3 X113.382 Y82.292 I-3.067 J.84 E.02001
G1 X142.951 Y111.861 E1.28623
G2 X142.829 Y112.272 I3.694 J1.328 E.0132
G1 X113.372 Y82.815 E1.28132
G3 X113.287 Y83.264 I-2.283 J-.201 E.01407
G1 X142.759 Y112.736 E1.28201
G1 X142.765 Y113.276 E.0166
G1 X113.155 Y83.666 E1.288
G3 X112.978 Y84.022 I-4.285 J-1.906 E.01225
G1 X143.236 Y114.281 E1.31622
M204 S10000
G1 X132.324 Y123.12 F42000
G1 F15000
M204 S6000
G1 X96.819 Y87.615 E1.54443
G1 X96.819 Y88.149 E.01642
G1 X131.621 Y122.951 E1.51383
G1 X131.087 Y122.951 E.01642
G1 X96.819 Y88.683 E1.49061
G1 X96.819 Y89.216 E.01642
G1 X130.553 Y122.951 E1.46739
G1 X130.02 Y122.951 E.01642
G1 X96.819 Y89.75 E1.44417
G1 X96.819 Y90.284 E.01642
G1 X129.486 Y122.951 E1.42095
G1 X128.952 Y122.951 E.01642
G1 X96.819 Y90.818 E1.39773
G1 X96.819 Y91.352 E.01642
G1 X128.418 Y122.951 E1.37451
G1 X127.884 Y122.951 E.01642
G1 X96.819 Y91.886 E1.35129
M73 P67 R10
G1 X96.819 Y92.419 E.01642
G1 X127.35 Y122.951 E1.32807
G1 X126.817 Y122.951 E.01642
G1 X96.819 Y92.953 E1.30485
G1 X96.819 Y93.487 E.01642
G1 X126.283 Y122.951 E1.28163
G1 X125.749 Y122.951 E.01642
G1 X96.819 Y94.021 E1.25841
G1 X96.819 Y94.555 E.01642
G1 X125.215 Y122.951 E1.23519
G1 X124.681 Y122.951 E.01642
G1 X96.819 Y95.088 E1.21197
G1 X96.819 Y95.622 E.01642
G1 X111.192 Y109.995 E.62521
G2 X110.532 Y109.868 I-.992 J3.379 E.02073
G1 X96.819 Y96.156 E.59647
G1 X96.819 Y96.69 E.01642
G1 X110.004 Y109.875 E.57354
G2 X109.547 Y109.951 I.352 J3.532 E.01428
G1 X96.819 Y97.224 E.55363
G1 X96.819 Y97.757 E.01642
G1 X109.144 Y110.082 E.5361
G2 X108.781 Y110.253 I.671 J1.9 E.01236
G1 X96.819 Y98.291 E.52031
G1 X96.819 Y98.825 E.01642
G1 X108.455 Y110.461 E.50615
G2 X108.165 Y110.705 I1.074 J1.57 E.01167
G1 X96.819 Y99.359 E.49354
G1 X96.819 Y99.893 E.01642
G1 X107.907 Y110.981 E.48231
G2 X107.681 Y111.288 I1.422 J1.284 E.01176
G1 X96.819 Y100.426 E.47246
G1 X96.819 Y100.96 E.01642
G1 X107.489 Y111.63 E.46412
G2 X107.34 Y112.015 I1.848 J.938 E.01271
G1 X96.819 Y101.494 E.45763
G1 X96.819 Y102.028 E.01642
G1 X107.234 Y112.443 E.45303
G2 X107.196 Y112.939 I2.852 J.468 E.01531
G1 X96.819 Y102.562 E.45138
G1 X96.819 Y103.096 E.01642
G1 X107.241 Y113.518 E.45334
G2 X107.504 Y114.314 I2.563 J-.403 E.0259
G1 X96.819 Y103.629 E.46476
G1 X96.819 Y104.163 E.01642
G1 X115.607 Y122.951 E.81723
G1 X116.14 Y122.951 E.01642
G1 X108.939 Y115.749 E.31327
G2 X109.734 Y116.011 I1.433 J-3.014 E.02583
G1 X116.674 Y122.951 E.30189
G1 X117.208 Y122.951 E.01642
G1 X110.317 Y116.059 E.29976
G2 X110.806 Y116.014 I-.074 J-3.496 E.01512
G1 X117.742 Y122.951 E.30171
G1 X118.276 Y122.951 E.01642
G1 X111.237 Y115.912 E.30619
G2 X111.619 Y115.76 I-1.34 J-3.93 E.01265
G1 X118.81 Y122.951 E.31279
G1 X119.343 Y122.951 E.01642
G1 X111.961 Y115.568 E.32112
G2 X112.27 Y115.343 I-.971 J-1.656 E.01177
G1 X119.877 Y122.951 E.33091
G1 X120.411 Y122.951 E.01642
G1 X112.541 Y115.081 E.34232
G2 X112.787 Y114.793 I-.998 J-1.102 E.01168
G1 X120.945 Y122.951 E.35484
G1 X121.479 Y122.951 E.01642
G1 X112.998 Y114.47 E.36891
G2 X113.169 Y114.107 I-3.956 J-2.09 E.01234
G1 X122.012 Y122.951 E.38468
G1 X122.546 Y122.951 E.01642
G1 X113.297 Y113.702 E.40231
G2 X113.377 Y113.248 I-3.887 J-.915 E.01419
G1 X123.08 Y122.951 E.42207
G1 X123.614 Y122.951 E.01642
G1 X113.379 Y112.716 E.44519
G2 X113.257 Y112.06 I-3.513 J.314 E.02055
G1 X124.317 Y123.12 E.4811
M204 S10000
G1 X115.243 Y123.12 F42000
G1 F15000
M204 S6000
G1 X96.819 Y104.697 E.80139
G1 X96.819 Y105.231 E.01642
G1 X114.539 Y122.951 E.77079
G1 X114.005 Y122.951 E.01642
G1 X96.819 Y105.765 E.74757
G1 X96.819 Y106.298 E.01642
G1 X113.471 Y122.951 E.72435
G1 X112.938 Y122.951 E.01642
G1 X96.819 Y106.832 E.70113
G1 X96.819 Y107.366 E.01642
G1 X112.404 Y122.951 E.67791
G1 X111.87 Y122.951 E.01642
G1 X96.819 Y107.9 E.65469
G1 X96.819 Y108.434 E.01642
G1 X111.336 Y122.951 E.63147
G1 X110.802 Y122.951 E.01642
G1 X96.819 Y108.967 E.60825
G1 X96.819 Y109.501 E.01642
G1 X110.269 Y122.951 E.58503
G1 X109.735 Y122.951 E.01642
G1 X96.819 Y110.035 E.56181
G1 X96.819 Y110.569 E.01642
G1 X109.201 Y122.951 E.53859
G1 X108.667 Y122.951 E.01642
G1 X96.819 Y111.103 E.51537
G1 X96.819 Y111.636 E.01642
G1 X108.133 Y122.951 E.49215
G1 X107.6 Y122.951 E.01642
G1 X96.819 Y112.17 E.46893
G1 X96.819 Y112.704 E.01642
G1 X107.066 Y122.951 E.44571
G1 X106.532 Y122.951 E.01642
G1 X96.819 Y113.238 E.42249
G1 X96.819 Y113.772 E.01642
G1 X105.998 Y122.951 E.39927
G1 X105.464 Y122.951 E.01642
G1 X101.996 Y119.482 E.15087
G3 X102.153 Y120.173 I-3.15 J1.081 E.02185
G1 X104.93 Y122.951 E.1208
G1 X104.397 Y122.951 E.01642
G1 X102.161 Y120.715 E.09726
G3 X102.093 Y121.181 I-3.449 J-.262 E.0145
G1 X103.863 Y122.951 E.07699
G1 X103.329 Y122.951 E.01642
G1 X101.969 Y121.591 E.05915
G3 X101.805 Y121.96 I-1.932 J-.639 E.01246
G1 X102.795 Y122.951 E.04308
G1 X102.261 Y122.951 E.01642
G1 X101.6 Y122.29 E.02876
G3 X101.359 Y122.582 I-1.26 J-.791 E.0117
G1 X101.897 Y123.12 E.0234
M204 S10000
G1 X100.857 Y122.903 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.115473
G1 F15000
M204 S6000
G1 X100.65 Y123.08 E.00161
M204 S10000
G1 X99.87 Y123.225 F42000
; LINE_WIDTH: 0.506075
G1 F13602.364
M204 S6000
G3 X99.405 Y123.265 I-1.035 J-9.293 E.01759
; LINE_WIDTH: 0.479701
G1 F14423.711
G3 X98.573 Y123.253 I-.326 J-6.235 E.02966
; LINE_WIDTH: 0.517725
G1 F13268.604
G1 X98.271 Y123.219 E.01175
M204 S10000
G1 X97.528 Y123.063 F42000
; LINE_WIDTH: 0.133998
G1 F15000
M204 S6000
G1 X96.69 Y122.815 E.00648
M204 S10000
G1 X96.69 Y122.783 F42000
; LINE_WIDTH: 0.331506
G1 F15000
M204 S6000
G1 X97.524 Y123.075 E.0208
M204 S10000
G1 X97.006 Y123.08 F42000
; LINE_WIDTH: 0.402965
G1 F15000
M204 S6000
G1 X96.691 Y122.334 E.02377
M204 S10000
G1 X96.705 Y122.329 F42000
; LINE_WIDTH: 0.160283
G1 F15000
M204 S6000
G1 X96.978 Y123.08 E.00764
; WIPE_START
G1 X96.705 Y122.329 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.523 Y121.693 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; LINE_WIDTH: 0.436833
G1 F15000
M204 S6000
G1 X96.49 Y121.504 E.00616
; LINE_WIDTH: 0.405899
G1 X96.456 Y121.315 E.00568
; LINE_WIDTH: 0.37146
G1 X96.438 Y121.17 E.00391
; LINE_WIDTH: 0.337264
G1 X96.422 Y121.043 E.00308
; LINE_WIDTH: 0.300492
G1 X96.401 Y120.775 E.00564
; LINE_WIDTH: 0.275766
G1 X96.409 Y120.105 E.0127
; LINE_WIDTH: 0.308773
G1 X96.422 Y119.965 E.00306
; LINE_WIDTH: 0.335566
G1 X96.435 Y119.837 E.00306
; LINE_WIDTH: 0.369217
G1 X96.456 Y119.694 E.00385
; LINE_WIDTH: 0.410051
G1 X96.476 Y119.566 E.00387
; LINE_WIDTH: 0.443781
G3 X96.528 Y119.303 I5.358 J.936 E.00877
M204 S10000
G1 X96.69 Y118.655 F42000
; LINE_WIDTH: 0.106261
G1 F15000
M204 S6000
G1 X96.812 Y118.535 E.00088
M204 S10000
G1 X97.104 Y118.327 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42038
G1 F15000
M204 S6000
G1 X96.819 Y118.042 E.01239
G1 X96.819 Y117.508 E.01642
G1 X97.28 Y117.969 E.02003
G3 X97.611 Y117.767 I1.174 J1.554 E.01197
G1 X96.819 Y116.975 E.03446
G1 X96.819 Y116.441 E.01642
G1 X97.979 Y117.6 E.05045
G3 X98.387 Y117.475 I1.554 J4.327 E.01314
G1 X96.819 Y115.907 E.06821
G1 X96.819 Y115.373 E.01642
G1 X98.856 Y117.41 E.08859
G3 X99.399 Y117.419 I.215 J3.165 E.01674
G1 X96.819 Y114.839 E.11223
G1 X96.819 Y114.306 E.01642
G1 X100.403 Y117.889 E.15589
M204 S10000
G1 X109.431 Y85.28 F42000
G1 F15000
M204 S6000
G1 X159.52 Y135.37 E2.17882
G1 X159.52 Y135.904 E.01642
G1 X100.733 Y77.116 E2.55716
G2 X101.042 Y76.891 I-2.866 J-4.248 E.01175
G1 X107.251 Y83.1 E.2701
G3 X107.197 Y82.513 I3.437 J-.612 E.01818
G1 X101.317 Y76.632 E.25578
G2 X101.561 Y76.342 I-1.332 J-1.365 E.01167
G1 X107.225 Y82.007 E.2464
G3 X107.327 Y81.575 I2.208 J.294 E.01367
G1 X101.772 Y76.019 E.24166
G2 X101.945 Y75.659 I-3.883 J-2.084 E.01231
G1 X107.473 Y81.187 E.24048
G3 X107.659 Y80.839 I4.181 J2.013 E.01213
G1 X102.074 Y75.254 E.24294
G2 X102.156 Y74.803 I-4.303 J-1.014 E.01413
G1 X107.883 Y80.529 E.2491
G3 X108.139 Y80.251 I1.521 J1.141 E.01164
G1 X102.16 Y74.273 E.26006
G2 X102.043 Y73.621 I-3.37 J.271 E.02038
G1 X108.546 Y80.125 E.28291
; WIPE_START
G1 X107.132 Y78.711 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.661 Y77.149 Z1.8 F42000
G1 X96.913 Y76.575 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.121814
G1 F15000
M204 S6000
G1 X96.69 Y76.371 E.00194
M204 S10000
G1 X96.523 Y75.693 F42000
; LINE_WIDTH: 0.436845
G1 F15000
M204 S6000
G1 X96.49 Y75.504 E.00616
; LINE_WIDTH: 0.405895
G1 X96.456 Y75.315 E.00568
; LINE_WIDTH: 0.371465
G1 X96.438 Y75.17 E.00391
; LINE_WIDTH: 0.337278
G1 X96.422 Y75.043 E.00308
; LINE_WIDTH: 0.300501
G1 X96.401 Y74.774 E.00565
; LINE_WIDTH: 0.275766
G1 X96.409 Y74.105 E.0127
; LINE_WIDTH: 0.308779
G1 X96.422 Y73.965 E.00306
; LINE_WIDTH: 0.335584
G1 X96.435 Y73.837 E.00306
; LINE_WIDTH: 0.369238
G1 X96.456 Y73.694 E.00385
; LINE_WIDTH: 0.41007
G1 X96.476 Y73.566 E.00387
; LINE_WIDTH: 0.443788
G3 X96.528 Y73.303 I5.361 J.937 E.00877
M204 S10000
G1 X96.69 Y72.655 F42000
; LINE_WIDTH: 0.106202
G1 F15000
M204 S6000
G1 X96.812 Y72.536 E.00088
M204 S10000
G1 X97.347 Y72.129 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42038
G1 F15000
M204 S6000
G1 X96.819 Y71.601 E.02296
G1 X96.819 Y71.067 E.01642
G1 X97.55 Y71.798 E.0318
G3 X97.913 Y71.626 I1.038 J1.725 E.01235
G1 X96.819 Y70.533 E.04756
G1 X96.819 Y69.999 E.01642
G1 X98.314 Y71.495 E.06504
G3 X98.77 Y71.416 I.822 J3.41 E.01422
G1 X96.819 Y69.466 E.08485
G1 X96.819 Y68.932 E.01642
G1 X99.294 Y71.407 E.10767
G3 X99.949 Y71.527 I-.068 J2.207 E.02054
G1 X96.819 Y68.398 E.13613
G1 X96.819 Y67.864 E.01642
G1 X108.746 Y79.791 E.51878
G3 X109.106 Y79.617 I1.048 J1.715 E.01232
G1 X96.819 Y67.33 E.53445
G1 X96.819 Y66.797 E.01642
G1 X109.505 Y79.483 E.55184
G3 X109.955 Y79.399 I.884 J3.488 E.01408
G1 X96.819 Y66.263 E.5714
G1 X96.819 Y65.729 E.01642
G1 X110.476 Y79.386 E.59407
G3 X111.115 Y79.491 I-.276 J3.674 E.01994
G1 X96.819 Y65.195 E.62185
G1 X96.819 Y64.661 E.01642
G1 X143.324 Y111.166 E2.02289
G3 X143.561 Y110.869 I1.6 J1.034 E.0117
G1 X96.819 Y64.127 E2.03319
G1 X96.819 Y63.594 E.01642
G1 X143.832 Y110.607 E2.04501
G3 X144.138 Y110.378 I1.295 J1.411 E.01175
G1 X96.819 Y63.06 E2.05829
G1 X96.819 Y62.526 E.01642
G1 X144.476 Y110.183 E2.07302
G3 X144.851 Y110.024 I.982 J1.795 E.01255
G1 X96.819 Y61.992 E2.08933
G1 X96.819 Y61.458 E.01642
G1 X145.276 Y109.916 E2.10782
G3 X145.755 Y109.861 I.514 J2.369 E.01485
G1 X96.819 Y60.925 E2.12865
G1 X96.819 Y60.391 E.01642
G1 X146.326 Y109.898 E2.15349
G3 X147.078 Y110.116 I-.285 J2.39 E.02418
G1 X96.819 Y59.857 E2.18619
G1 X96.819 Y59.323 E.01642
G1 X159.52 Y122.024 E2.72742
G1 X159.52 Y121.491 E.01642
G1 X96.819 Y58.789 E2.72742
G1 X96.819 Y58.256 E.01642
G1 X159.52 Y120.957 E2.72742
G1 X159.52 Y120.423 E.01642
G1 X96.819 Y57.722 E2.72742
G1 X96.819 Y57.188 E.01642
G1 X159.69 Y120.059 E2.7348
M204 S10000
G1 X159.69 Y122.728 F42000
G1 F15000
M204 S6000
G1 X148.699 Y111.737 E.4781
G3 X148.91 Y112.482 I-2.288 J1.052 E.02392
G1 X159.52 Y123.092 E.46152
G1 X159.52 Y123.626 E.01642
G1 X148.947 Y113.052 E.45994
G3 X148.896 Y113.535 I-2.442 J-.014 E.01496
G1 X159.52 Y124.16 E.46216
G1 X159.52 Y124.694 E.01642
G1 X148.784 Y113.957 E.46704
G3 X148.627 Y114.333 I-1.957 J-.594 E.01258
G1 X159.52 Y125.227 E.47387
G1 X159.52 Y125.761 E.01642
G1 X148.433 Y114.674 E.48229
G3 X148.203 Y114.977 I-3.828 J-2.659 E.01172
G1 X159.422 Y126.197 E.48802
G1 X159.28 Y126.328 E.00595
G2 X158.388 Y125.696 I-2.241 J2.219 E.0338
G1 X147.939 Y115.247 E.45454
G3 X147.646 Y115.488 I-2.784 J-3.086 E.01167
G1 X157.603 Y125.445 E.43312
G2 X157.024 Y125.4 I-.513 J2.875 E.01787
G1 X147.314 Y115.69 E.42237
G3 X146.947 Y115.857 I-1.016 J-1.748 E.01242
G1 X156.539 Y125.448 E.4172
G2 X156.109 Y125.552 I.305 J2.195 E.01362
G1 X146.54 Y115.984 E.41623
G3 X146.072 Y116.05 I-.563 J-2.304 E.01454
G1 X155.729 Y125.706 E.42005
M73 P68 R10
G2 X155.388 Y125.899 I.791 J1.801 E.01207
G1 X145.531 Y116.042 E.42876
G3 X144.845 Y115.89 I.335 J-3.141 E.02163
G1 X155.08 Y126.125 E.44518
G2 X154.81 Y126.388 I.892 J1.184 E.01164
G1 X112.765 Y84.343 E1.82891
G3 X112.515 Y84.628 I-1.231 J-.828 E.01167
G1 X154.565 Y126.677 E1.8291
G2 X154.355 Y127.002 I1.521 J1.211 E.0119
G1 X112.24 Y84.887 E1.83194
G3 X111.929 Y85.109 I-1.267 J-1.445 E.01179
G1 X154.186 Y127.366 E1.83813
G2 X154.059 Y127.773 I1.964 J.839 E.01312
G1 X111.584 Y85.298 E1.8476
G3 X111.195 Y85.443 I-1.729 J-4.025 E.01276
G1 X153.982 Y128.23 E1.86115
G2 X153.981 Y128.763 I2.66 J.269 E.01644
G1 X110.761 Y85.542 E1.88004
G3 X110.263 Y85.578 I-.482 J-3.248 E.01538
G1 X154.11 Y129.426 E1.90732
G2 X156.14 Y131.455 I2.947 J-.918 E.09183
G1 X159.52 Y134.836 E.14704
G1 X159.52 Y134.302 E.01642
G1 X156.807 Y131.589 E.11801
G2 X157.338 Y131.586 I.246 J-3.688 E.01635
G1 X159.52 Y133.768 E.09492
G1 X159.52 Y133.234 E.01642
G1 X157.799 Y131.513 E.07489
G2 X158.203 Y131.383 I-.446 J-2.082 E.01307
G1 X159.52 Y132.701 E.05731
G1 X159.52 Y132.167 E.01642
G1 X158.567 Y131.213 E.04147
G2 X158.894 Y131.007 I-2.518 J-4.357 E.01191
G1 X159.52 Y131.633 E.02723
G1 X159.52 Y131.099 E.01642
G1 X159.063 Y130.642 E.01989
M204 S10000
G1 X159.481 Y130.273 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.114072
G1 F15000
M204 S6000
G1 X159.65 Y130.073 E.00151
M204 S10000
G1 X159.524 Y129.245 F42000
; LINE_WIDTH: 0.512291
G1 F13422.219
M204 S6000
G1 X159.817 Y129.065 E.01313
G2 X159.838 Y128.788 I-6.388 J-.628 E.01061
; LINE_WIDTH: 0.472779
G1 F14655.985
G2 X159.839 Y128.234 I-7.976 J-.293 E.01943
; LINE_WIDTH: 0.511273
G1 F13451.414
G2 X159.817 Y127.935 I-22.393 J1.523 E.01141
G1 X159.524 Y127.756 E.0131
M204 S10000
G1 X159.65 Y126.905 F42000
; LINE_WIDTH: 0.140545
G1 F15000
M204 S6000
G1 X159.561 Y126.799 E.00111
; LINE_WIDTH: 0.114415
G1 X159.423 Y126.651 E.00118
; WIPE_START
G1 X159.561 Y126.799 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X159.661 Y134.431 Z1.8 F42000
G1 X159.69 Y136.607 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42038
G1 F15000
M204 S6000
G1 X100.386 Y77.303 E2.57964
G3 X100.004 Y77.455 I-1.406 J-2.98 E.01265
G1 X159.52 Y136.971 E2.58887
G1 X159.52 Y137.505 E.01642
G1 X99.572 Y77.557 E2.60766
G3 X99.081 Y77.599 I-.532 J-3.325 E.01519
G1 X159.52 Y138.039 E2.62905
G1 X159.52 Y138.573 E.01642
G1 X98.494 Y77.546 E2.65458
G3 X97.69 Y77.276 I.656 J-3.284 E.02615
G1 X159.52 Y139.106 E2.68955
G1 X159.52 Y139.64 E.01642
G1 X96.934 Y77.054 E2.72241
G1 X96.898 Y77.095 E.00167
G1 X96.819 Y77.023 E.0033
G1 X96.819 Y77.473 E.01384
G1 X159.52 Y140.174 E2.72742
G1 X159.52 Y140.708 E.01642
G1 X96.819 Y78.006 E2.72742
G1 X96.819 Y78.54 E.01642
G1 X159.52 Y141.242 E2.72742
G1 X159.52 Y141.775 E.01642
G1 X96.819 Y79.074 E2.72742
G1 X96.819 Y79.608 E.01642
G1 X159.52 Y142.309 E2.72742
G1 X159.52 Y142.843 E.01642
G1 X96.819 Y80.142 E2.72742
G1 X96.819 Y80.676 E.01642
G1 X159.52 Y143.377 E2.72742
G1 X159.52 Y143.911 E.01642
G1 X96.819 Y81.209 E2.72742
G1 X96.819 Y81.743 E.01642
G1 X159.52 Y144.444 E2.72742
G1 X159.52 Y144.978 E.01642
G1 X96.819 Y82.277 E2.72742
G1 X96.819 Y82.811 E.01642
G1 X159.52 Y145.512 E2.72742
G1 X159.52 Y146.046 E.01642
G1 X96.819 Y83.345 E2.72742
G1 X96.819 Y83.878 E.01642
G1 X159.52 Y146.58 E2.72742
G1 X159.52 Y147.113 E.01642
G1 X96.819 Y84.412 E2.72742
G1 X96.819 Y84.946 E.01642
G1 X159.52 Y147.647 E2.72742
G1 X159.52 Y148.181 E.01642
G1 X96.819 Y85.48 E2.72742
G1 X96.819 Y86.014 E.01642
G1 X159.52 Y148.715 E2.72742
G1 X159.52 Y149.249 E.01642
G1 X96.819 Y86.547 E2.72742
G1 X96.819 Y87.081 E.01642
G1 X159.52 Y149.783 E2.72742
G1 X159.52 Y150.316 E.01642
G1 X132.819 Y123.615 E1.16147
G1 X132.819 Y124.149 E.01642
G1 X159.52 Y150.85 E1.16147
G1 X159.52 Y151.384 E.01642
G1 X132.819 Y124.683 E1.16147
G1 X132.819 Y125.217 E.01642
G1 X159.52 Y151.918 E1.16147
G1 X159.52 Y152.452 E.01642
G1 X132.819 Y125.75 E1.16147
G1 X132.819 Y126.284 E.01642
G1 X159.52 Y152.985 E1.16147
G1 X159.52 Y153.519 E.01642
G1 X132.819 Y126.818 E1.16147
G1 X132.819 Y127.352 E.01642
G1 X159.52 Y154.053 E1.16147
G1 X159.52 Y154.587 E.01642
G1 X132.819 Y127.886 E1.16147
G1 X132.819 Y128.419 E.01642
G1 X159.52 Y155.121 E1.16147
G1 X159.52 Y155.654 E.01642
G1 X132.819 Y128.953 E1.16147
G1 X132.819 Y129.487 E.01642
G1 X159.52 Y156.188 E1.16147
G1 X159.52 Y156.722 E.01642
G1 X132.819 Y130.021 E1.16147
G1 X132.819 Y130.555 E.01642
G1 X159.52 Y157.256 E1.16147
G1 X159.52 Y157.79 E.01642
G1 X132.819 Y131.088 E1.16147
G1 X132.819 Y131.622 E.01642
G1 X159.52 Y158.323 E1.16147
G1 X159.52 Y158.857 E.01642
G1 X132.819 Y132.156 E1.16147
G1 X132.819 Y132.69 E.01642
G1 X159.52 Y159.391 E1.16147
G1 X159.52 Y159.925 E.01642
G1 X132.819 Y133.224 E1.16147
G1 X132.819 Y133.757 E.01642
G1 X159.52 Y160.459 E1.16147
G1 X159.52 Y160.993 E.01642
G1 X132.819 Y134.291 E1.16147
G1 X132.819 Y134.825 E.01642
G1 X159.52 Y161.526 E1.16147
G1 X159.52 Y162.06 E.01642
G1 X132.819 Y135.359 E1.16147
G1 X132.819 Y135.893 E.01642
G1 X159.52 Y162.594 E1.16147
G1 X159.52 Y163.128 E.01642
G1 X132.819 Y136.426 E1.16147
G1 X132.819 Y136.96 E.01642
G1 X159.52 Y163.662 E1.16147
G1 X159.52 Y164.195 E.01642
G1 X132.819 Y137.494 E1.16147
G1 X132.819 Y138.028 E.01642
G1 X159.52 Y164.729 E1.16147
G1 X159.52 Y165.263 E.01642
G1 X132.819 Y138.562 E1.16147
G1 X132.819 Y139.096 E.01642
G1 X159.52 Y165.797 E1.16147
G1 X159.52 Y166.331 E.01642
G1 X132.819 Y139.629 E1.16147
G1 X132.819 Y140.163 E.01642
G1 X159.52 Y166.864 E1.16147
M73 P69 R10
G1 X159.52 Y167.398 E.01642
G1 X132.819 Y140.697 E1.16147
G1 X132.819 Y141.231 E.01642
G1 X159.52 Y167.932 E1.16147
G1 X159.52 Y168.466 E.01642
G1 X132.819 Y141.765 E1.16147
G1 X132.819 Y142.298 E.01642
G1 X159.52 Y169 E1.16147
G1 X159.52 Y169.533 E.01642
G1 X132.819 Y142.832 E1.16147
G1 X132.819 Y143.366 E.01642
G1 X159.52 Y170.067 E1.16147
G1 X159.52 Y170.601 E.01642
G1 X132.819 Y143.9 E1.16147
G1 X132.819 Y144.434 E.01642
G1 X159.52 Y171.135 E1.16147
G1 X159.52 Y171.669 E.01642
G1 X132.819 Y144.967 E1.16147
G1 X132.819 Y145.501 E.01642
G1 X159.52 Y172.203 E1.16147
G1 X159.52 Y172.736 E.01642
G1 X132.819 Y146.035 E1.16147
G1 X132.819 Y146.569 E.01642
G1 X159.52 Y173.27 E1.16147
G1 X159.52 Y173.804 E.01642
G1 X132.819 Y147.103 E1.16147
G1 X132.819 Y147.636 E.01642
G1 X159.52 Y174.338 E1.16147
G1 X159.52 Y174.872 E.01642
G1 X132.819 Y148.17 E1.16147
G1 X132.819 Y148.704 E.01642
G1 X159.52 Y175.405 E1.16147
G1 X159.52 Y175.939 E.01642
G1 X132.819 Y149.238 E1.16147
G1 X132.819 Y149.772 E.01642
G1 X159.52 Y176.473 E1.16147
G1 X159.52 Y177.007 E.01642
G1 X132.819 Y150.306 E1.16147
G1 X132.819 Y150.839 E.01642
G1 X159.52 Y177.541 E1.16147
G1 X159.52 Y178.074 E.01642
G1 X132.819 Y151.373 E1.16147
G1 X132.819 Y151.907 E.01642
G1 X159.52 Y178.608 E1.16147
G1 X159.52 Y179.142 E.01642
G1 X132.819 Y152.441 E1.16147
M73 P69 R9
G1 X132.819 Y152.975 E.01642
G1 X159.52 Y179.676 E1.16147
G1 X159.52 Y180.21 E.01642
G1 X132.819 Y153.508 E1.16147
G1 X132.819 Y154.042 E.01642
G1 X159.52 Y180.743 E1.16147
G1 X159.52 Y181.277 E.01642
G1 X132.819 Y154.576 E1.16147
G1 X132.819 Y155.11 E.01642
G1 X159.52 Y181.811 E1.16147
G1 X159.52 Y182.345 E.01642
G1 X132.819 Y155.644 E1.16147
G1 X132.819 Y156.177 E.01642
G1 X159.52 Y182.879 E1.16147
G1 X159.52 Y183.413 E.01642
G1 X132.819 Y156.711 E1.16147
G1 X132.819 Y157.245 E.01642
G1 X159.52 Y183.946 E1.16147
G1 X159.52 Y184.48 E.01642
G1 X132.819 Y157.779 E1.16147
G1 X132.819 Y158.313 E.01642
G1 X159.52 Y185.014 E1.16147
G1 X159.52 Y185.548 E.01642
G1 X132.819 Y158.846 E1.16147
G1 X132.819 Y159.38 E.01642
G1 X159.52 Y186.082 E1.16147
G1 X159.52 Y186.615 E.01642
G1 X132.819 Y159.914 E1.16147
G1 X132.819 Y160.448 E.01642
G1 X159.52 Y187.149 E1.16147
G1 X159.52 Y187.683 E.01642
G1 X132.819 Y160.982 E1.16147
G1 X132.819 Y161.516 E.01642
G1 X159.52 Y188.217 E1.16147
G1 X159.52 Y188.751 E.01642
G1 X132.819 Y162.049 E1.16147
G1 X132.819 Y162.583 E.01642
G1 X159.52 Y189.284 E1.16147
G1 X159.52 Y189.818 E.01642
G1 X132.819 Y163.117 E1.16147
G1 X132.819 Y163.651 E.01642
G1 X159.52 Y190.352 E1.16147
G1 X159.52 Y190.886 E.01642
G1 X132.819 Y164.185 E1.16147
G1 X132.819 Y164.718 E.01642
G1 X159.52 Y191.42 E1.16147
G1 X159.52 Y191.953 E.01642
G1 X132.819 Y165.252 E1.16147
G1 X132.819 Y165.786 E.01642
G1 X159.52 Y192.487 E1.16147
G1 X159.52 Y193.021 E.01642
G1 X132.819 Y166.32 E1.16147
G1 X132.819 Y166.854 E.01642
G1 X159.52 Y193.555 E1.16147
G1 X159.52 Y194.089 E.01642
G1 X132.819 Y167.387 E1.16147
G1 X132.819 Y167.921 E.01642
G1 X159.52 Y194.623 E1.16147
G1 X159.52 Y195.156 E.01642
G1 X132.819 Y168.455 E1.16147
G1 X132.819 Y168.989 E.01642
G1 X159.52 Y195.69 E1.16147
G1 X159.52 Y196.224 E.01642
G1 X132.819 Y169.523 E1.16147
G1 X132.819 Y170.056 E.01642
G1 X159.52 Y196.758 E1.16147
G1 X159.52 Y197.292 E.01642
G1 X132.819 Y170.59 E1.16147
G1 X132.819 Y171.124 E.01642
G1 X159.52 Y197.825 E1.16147
G1 X159.52 Y198.359 E.01642
G1 X132.819 Y171.658 E1.16147
G1 X132.819 Y172.192 E.01642
G1 X159.52 Y198.893 E1.16147
G1 X159.52 Y199.427 E.01642
G1 X132.819 Y172.726 E1.16147
G1 X132.819 Y173.259 E.01642
G1 X159.52 Y199.961 E1.16147
G1 X159.52 Y200.494 E.01642
G1 X132.819 Y173.793 E1.16147
G1 X132.819 Y174.327 E.01642
G1 X159.52 Y201.028 E1.16147
G1 X159.52 Y201.562 E.01642
G1 X132.819 Y174.861 E1.16147
G1 X132.819 Y175.395 E.01642
G1 X159.52 Y202.096 E1.16147
G1 X159.52 Y202.63 E.01642
G1 X132.819 Y175.928 E1.16147
G1 X132.819 Y176.462 E.01642
G1 X159.52 Y203.163 E1.16147
G1 X159.52 Y203.697 E.01642
G1 X132.819 Y176.996 E1.16147
G1 X132.819 Y177.53 E.01642
G1 X159.52 Y204.231 E1.16147
G1 X159.52 Y204.765 E.01642
G1 X132.819 Y178.064 E1.16147
G1 X132.819 Y178.597 E.01642
G1 X159.52 Y205.299 E1.16147
G1 X159.52 Y205.832 E.01642
G1 X132.819 Y179.131 E1.16147
G1 X132.819 Y179.665 E.01642
G1 X159.52 Y206.366 E1.16147
G1 X159.52 Y206.9 E.01642
G1 X132.819 Y180.199 E1.16147
G1 X132.819 Y180.733 E.01642
G1 X159.52 Y207.434 E1.16147
G1 X159.52 Y207.968 E.01642
G1 X132.819 Y181.266 E1.16147
G1 X132.819 Y181.8 E.01642
G1 X159.52 Y208.502 E1.16147
G1 X159.52 Y209.035 E.01642
G1 X132.819 Y182.334 E1.16147
G1 X132.819 Y182.868 E.01642
G1 X159.52 Y209.569 E1.16147
G1 X159.52 Y210.103 E.01642
G1 X132.819 Y183.402 E1.16147
G1 X132.819 Y183.936 E.01642
G1 X159.52 Y210.637 E1.16147
G1 X159.52 Y210.751 E.0035
G1 X159.101 Y210.751 E.01292
G1 X132.819 Y184.469 E1.1432
G1 X132.819 Y185.003 E.01642
G1 X158.567 Y210.751 E1.11998
G1 X158.033 Y210.751 E.01642
G1 X132.819 Y185.537 E1.09676
G1 X132.819 Y186.071 E.01642
G1 X157.499 Y210.751 E1.07354
G1 X156.965 Y210.751 E.01642
G1 X132.819 Y186.605 E1.05032
G1 X132.819 Y187.138 E.01642
G1 X156.431 Y210.751 E1.0271
G1 X155.898 Y210.751 E.01642
G1 X132.819 Y187.672 E1.00388
G1 X132.819 Y188.206 E.01642
G1 X155.364 Y210.751 E.98066
G1 X154.83 Y210.751 E.01642
G1 X132.819 Y188.74 E.95744
G1 X132.819 Y189.274 E.01642
G1 X154.296 Y210.751 E.93422
G1 X153.762 Y210.751 E.01642
G1 X132.819 Y189.807 E.911
G1 X132.819 Y190.341 E.01642
M73 P70 R9
G1 X153.229 Y210.751 E.88778
G1 X152.695 Y210.751 E.01642
G1 X132.819 Y190.875 E.86456
G1 X132.819 Y191.409 E.01642
G1 X152.161 Y210.751 E.84134
G1 X151.627 Y210.751 E.01642
G1 X132.819 Y191.943 E.81812
G1 X132.819 Y192.476 E.01642
G1 X151.093 Y210.751 E.7949
G1 X150.56 Y210.751 E.01642
G1 X132.819 Y193.01 E.77168
G1 X132.819 Y193.544 E.01642
G1 X150.026 Y210.751 E.74846
G1 X149.492 Y210.751 E.01642
G1 X132.819 Y194.078 E.72524
G1 X132.819 Y194.612 E.01642
G1 X148.958 Y210.751 E.70202
G1 X148.424 Y210.751 E.01642
G1 X132.819 Y195.145 E.6788
G1 X132.819 Y195.679 E.01642
G1 X147.891 Y210.751 E.65558
G1 X147.357 Y210.751 E.01642
G1 X132.819 Y196.213 E.63236
G1 X132.819 Y196.747 E.01642
G1 X146.823 Y210.751 E.60914
G1 X146.289 Y210.751 E.01642
G1 X132.819 Y197.281 E.58592
G1 X132.819 Y197.815 E.01642
G1 X145.755 Y210.751 E.5627
G1 X145.221 Y210.751 E.01642
G1 X132.819 Y198.348 E.53948
G1 X132.819 Y198.882 E.01642
G1 X144.688 Y210.751 E.51626
G1 X144.154 Y210.751 E.01642
G1 X132.819 Y199.416 E.49304
G1 X132.819 Y199.95 E.01642
G1 X143.62 Y210.751 E.46982
G1 X143.086 Y210.751 E.01642
G1 X132.819 Y200.484 E.4466
G1 X132.819 Y201.017 E.01642
G1 X142.552 Y210.751 E.42338
G1 X142.019 Y210.751 E.01642
G1 X132.819 Y201.551 E.40016
G1 X132.819 Y202.085 E.01642
G1 X141.485 Y210.751 E.37694
G1 X140.951 Y210.751 E.01642
G1 X138.114 Y207.914 E.1234
G3 X138.171 Y208.505 I-4.372 J.72 E.01827
G1 X140.417 Y210.751 E.0977
G1 X139.883 Y210.751 E.01642
G1 X138.128 Y208.995 E.07636
G3 X138.028 Y209.429 I-4.136 J-.722 E.01371
G1 X139.35 Y210.751 E.05748
G1 X138.816 Y210.751 E.01642
G1 X137.876 Y209.811 E.04086
G3 X137.688 Y210.157 I-1.818 J-.769 E.01212
G1 X138.282 Y210.751 E.02584
G1 X137.748 Y210.751 E.01642
G1 X137.344 Y210.347 E.01757
M204 S10000
G1 X137.084 Y210.716 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.110983
G1 F15000
M204 S6000
G1 X137.044 Y210.76 E.00033
G3 X136.897 Y210.862 I-.176 J-.096 E.00103
M204 S10000
G1 X136.264 Y211.044 F42000
; LINE_WIDTH: 0.431302
G1 F15000
M204 S6000
G3 X135.936 Y211.106 I-1.399 J-6.547 E.01056
; LINE_WIDTH: 0.3887
G1 X135.808 Y211.123 E.00363
; LINE_WIDTH: 0.351503
G1 X135.666 Y211.143 E.00361
; LINE_WIDTH: 0.309151
G1 X135.398 Y211.166 E.00583
; LINE_WIDTH: 0.2792
G1 X134.875 Y211.172 E.01006
G1 X134.595 Y211.155 E.0054
; LINE_WIDTH: 0.322719
G1 X134.467 Y211.14 E.00294
; LINE_WIDTH: 0.353437
G1 X134.323 Y211.124 E.00367
; LINE_WIDTH: 0.390641
G1 X134.2 Y211.103 E.00354
; LINE_WIDTH: 0.422425
G1 X134.076 Y211.083 E.00387
G1 X133.938 Y210.81 E.00946
; WIPE_START
G1 X134.076 Y211.083 E-.53955
G1 X134.2 Y211.103 E-.22045
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.883 Y210.671 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.38674
G1 F15000
M204 S6000
G1 X132.819 Y210.708 E.00209
G1 X132.868 Y210.737 E.00161
; WIPE_START
G1 X132.819 Y210.708 E-.33089
G1 X132.883 Y210.671 E-.42911
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X132.523 Y209.693 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.436812
G1 F15000
M204 S6000
G1 X132.49 Y209.504 E.00616
; LINE_WIDTH: 0.405875
G1 X132.456 Y209.315 E.00568
; LINE_WIDTH: 0.371439
G1 X132.438 Y209.17 E.00391
; LINE_WIDTH: 0.33724
G1 X132.422 Y209.043 E.00308
; LINE_WIDTH: 0.30036
G1 X132.401 Y208.773 E.00567
; LINE_WIDTH: 0.272589
G1 X132.401 Y208.239 E.01
; LINE_WIDTH: 0.29843
G1 X132.42 Y207.971 E.00559
; LINE_WIDTH: 0.33555
G1 X132.438 Y207.83 E.0034
; LINE_WIDTH: 0.369242
G1 X132.454 Y207.702 E.00342
; LINE_WIDTH: 0.40477
G1 X132.49 Y207.493 E.00625
; LINE_WIDTH: 0.43801
G1 X132.524 Y207.302 E.00626
M204 S10000
G1 X132.69 Y206.655 F42000
; LINE_WIDTH: 0.106192
G1 F15000
M204 S6000
G1 X132.812 Y206.536 E.00088
M204 S10000
G1 X132.65 Y205.652 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42038
G1 F15000
M204 S6000
G1 X133.104 Y206.106 E.01975
G3 X133.414 Y205.882 I1.273 J1.437 E.01178
G1 X132.819 Y205.288 E.02585
G1 X132.819 Y204.754 E.01642
G1 X133.757 Y205.692 E.0408
G3 X134.142 Y205.543 I1.687 J3.788 E.0127
G1 X132.819 Y204.22 E.05754
G1 X132.819 Y203.686 E.01642
G1 X134.575 Y205.442 E.07636
G3 X135.068 Y205.401 I.519 J3.295 E.01524
G1 X132.819 Y203.153 E.09781
G1 X132.819 Y202.619 E.01642
G1 X135.886 Y205.685 E.13339
; OBJECT_ID: 124
; WIPE_START
G1 X134.471 Y204.271 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G1 X130.356 Y197.843 Z1.8 F42000
G1 X106.723 Y160.935 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X106.753 Y161.239 E.00942
G3 X105.061 Y159.705 I-1.559 J.019 E.22226
G1 X105.206 Y159.699 E.00446
G3 X106.706 Y160.878 I-.012 J1.559 E.0631
; WIPE_START
M204 S6000
G1 X106.753 Y161.239 E-.1384
G1 X106.73 Y161.549 E-.11791
G1 X106.642 Y161.847 E-.11803
G1 X106.576 Y161.988 E-.05915
G1 X106.405 Y162.247 E-.11806
G1 X106.185 Y162.467 E-.11808
G1 X105.987 Y162.598 E-.09037
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.154 Y163.547 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X104.715 Y163.498 E.01356
G3 X105.225 Y158.969 I.476 J-2.24 E.20736
G1 X105.327 Y158.973 E.00311
G3 X105.213 Y163.548 I-.136 J2.285 E.21613
M204 S10000
G1 X105.181 Y163.183 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381157
G1 F15000
M204 S6000
G1 X105.173 Y163.183 E.00024
G3 X103.272 Y161.291 I.024 J-1.924 E.08178
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.509 J.043 E.00482
G3 X105.555 Y163.15 I1.918 J.159 E.23563
G1 X105.241 Y163.178 E.00868
; OBJECT_ID: 102
; WIPE_START
G1 X105.173 Y163.183 E-.02606
G1 X104.792 Y163.141 E-.14569
G1 X104.427 Y163.023 E-.14569
G1 X104.093 Y162.836 E-.14567
G1 X103.86 Y162.644 E-.1144
G1 X103.62 Y162.363 E-.14042
G1 X103.566 Y162.267 E-.04206
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.055 Y154.65 Z1.8 F42000
G1 X104.067 Y154.458 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X104.097 Y154.763 E.00942
G3 X102.405 Y153.228 I-1.559 J.019 E.22226
G1 X102.55 Y153.222 E.00446
G3 X104.05 Y154.402 I-.012 J1.559 E.0631
; WIPE_START
M204 S6000
G1 X104.097 Y154.763 E-.1384
G1 X104.074 Y155.072 E-.11791
G1 X103.986 Y155.37 E-.11803
G1 X103.921 Y155.511 E-.05915
G1 X103.749 Y155.77 E-.11806
G1 X103.529 Y155.99 E-.11808
G1 X103.331 Y156.121 E-.09037
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.498 Y157.07 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X102.059 Y157.021 E.01356
G3 X102.57 Y152.492 I.476 J-2.24 E.20736
G1 X102.671 Y152.496 E.00311
G3 X102.558 Y157.071 I-.136 J2.285 E.21613
M204 S10000
G1 X102.526 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381157
G1 F15000
M204 S6000
G1 X102.517 Y156.706 E.00024
G3 X100.617 Y154.815 I.024 J-1.924 E.08178
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.509 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23563
G1 X102.586 Y156.701 E.00868
; OBJECT_ID: 91
; WIPE_START
G1 X102.517 Y156.706 E-.02606
G1 X102.136 Y156.664 E-.14569
G1 X101.771 Y156.547 E-.14569
G1 X101.437 Y156.359 E-.14567
G1 X101.205 Y156.167 E-.1144
G1 X100.964 Y155.887 E-.14042
G1 X100.91 Y155.79 E-.04206
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.173 Z1.8 F42000
G1 X101.411 Y147.981 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X101.442 Y148.286 E.00942
G3 X99.75 Y146.751 I-1.559 J.019 E.22226
G1 X99.895 Y146.745 E.00446
G3 X101.395 Y147.925 I-.012 J1.559 E.0631
; WIPE_START
M204 S6000
G1 X101.442 Y148.286 E-.1384
G1 X101.419 Y148.595 E-.11791
G1 X101.331 Y148.893 E-.11803
G1 X101.265 Y149.034 E-.05915
G1 X101.093 Y149.293 E-.11806
G1 X100.874 Y149.513 E-.11808
G1 X100.675 Y149.645 E-.09037
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.842 Y150.593 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X99.404 Y150.544 E.01356
G3 X99.914 Y146.016 I.476 J-2.24 E.20736
G1 X100.015 Y146.019 E.00311
G3 X99.902 Y150.594 I-.136 J2.285 E.21613
M204 S10000
G1 X99.87 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381157
G1 F15000
M204 S6000
G1 X99.862 Y150.23 E.00024
G3 X97.961 Y148.338 I.024 J-1.924 E.08178
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.509 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.23563
G1 X99.93 Y150.224 E.00868
; OBJECT_ID: 113
; WIPE_START
G1 X99.862 Y150.23 E-.02606
G1 X99.481 Y150.187 E-.14569
G1 X99.116 Y150.07 E-.14569
G1 X98.781 Y149.882 E-.14567
G1 X98.549 Y149.691 E-.1144
G1 X98.309 Y149.41 E-.14042
G1 X98.255 Y149.313 E-.04206
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.744 Y141.697 Z1.8 F42000
G1 X98.756 Y141.504 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X98.786 Y141.809 E.00942
G3 X97.094 Y140.274 I-1.559 J.019 E.22226
G1 X97.239 Y140.269 E.00446
G3 X98.739 Y141.448 I-.012 J1.559 E.0631
; WIPE_START
M204 S6000
G1 X98.786 Y141.809 E-.1384
G1 X98.763 Y142.119 E-.11791
G1 X98.675 Y142.417 E-.11803
G1 X98.61 Y142.558 E-.05915
G1 X98.438 Y142.817 E-.11806
G1 X98.218 Y143.036 E-.11808
G1 X98.02 Y143.168 E-.09037
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.187 Y144.117 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X96.748 Y144.068 E.01356
G3 X97.259 Y139.539 I.476 J-2.24 E.20736
G1 X97.36 Y139.543 E.00311
G3 X97.247 Y144.118 I-.136 J2.285 E.21613
M204 S10000
G1 X97.215 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381157
G1 F15000
M204 S6000
G1 X97.206 Y143.753 E.00024
G3 X95.305 Y141.861 I.024 J-1.924 E.08178
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.509 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23563
G1 X97.274 Y143.748 E.00868
; CHANGE_LAYER
; Z_HEIGHT: 1.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02606
G1 X96.825 Y143.711 E-.14569
G1 X96.46 Y143.593 E-.14569
G1 X96.126 Y143.406 E-.14567
G1 X95.894 Y143.214 E-.1144
G1 X95.653 Y142.933 E-.14042
G1 X95.599 Y142.837 E-.04206
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 8/60
; update layer progress
M73 L8
M991 S0 P7 ;notify layer change
; OBJECT_ID: 80
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
M204 S10000
G17
G3 Z1.8 I.645 J1.032 P1  F42000
G1 X144.448 Y112.277 Z1.8
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X144.606 Y112.018 E.00931
G3 X145.656 Y111.412 I1.243 J.941 E.03825
G1 X145.811 Y111.4 E.00478
G3 X144.423 Y112.331 I.039 J1.559 E.24684
; WIPE_START
M204 S6000
G1 X144.606 Y112.018 E-.13781
G1 X144.817 Y111.79 E-.11809
G1 X145.07 Y111.609 E-.11805
G1 X145.353 Y111.481 E-.11809
G1 X145.656 Y111.412 E-.11799
G1 X145.811 Y111.4 E-.05917
G1 X146.049 Y111.418 E-.0908
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X149.714 Y118.113 Z2 F42000
G1 X156.033 Y129.657 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X155.876 Y129.502 E.00678
G3 X156.876 Y126.952 I1.194 J-1.003 E.10276
G1 X157.031 Y126.94 E.00479
G3 X156.098 Y129.719 I.039 J1.559 E.18394
G1 X156.076 Y129.698 E.00092
; WIPE_START
M204 S6000
G1 X155.876 Y129.502 E-.10663
G1 X155.7 Y129.246 E-.11806
G1 X155.579 Y128.96 E-.11802
G1 X155.517 Y128.655 E-.11813
G1 X155.517 Y128.345 E-.11795
G1 X155.579 Y128.04 E-.1181
G1 X155.64 Y127.886 E-.06311
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X153.808 Y120.476 Z2 F42000
G1 X144.668 Y83.496 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X144.656 Y83.482 E.00059
G3 X145.656 Y80.932 I1.194 J-1.003 E.10275
G1 X145.811 Y80.92 E.00478
G3 X144.878 Y83.699 I.039 J1.559 E.18395
G1 X144.711 Y83.538 E.00711
; WIPE_START
M204 S6000
G1 X144.656 Y83.482 E-.03004
G1 X144.48 Y83.226 E-.11787
G1 X144.359 Y82.94 E-.11818
G1 X144.297 Y82.636 E-.11797
G1 X144.292 Y82.395 E-.09126
G1 X144.338 Y82.095 E-.11547
G1 X144.444 Y81.803 E-.11809
G1 X144.514 Y81.688 E-.05113
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.978 Y80.478 Z2 F42000
G1 X100.622 Y74.642 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X100.621 Y74.655 E.0004
G3 X98.876 Y72.952 I-1.551 J-.156 E.21499
G1 X99.031 Y72.94 E.00478
G3 X100.621 Y74.345 I.039 J1.559 E.07171
G1 X100.622 Y74.582 E.0073
; WIPE_START
M204 S6000
G1 X100.621 Y74.655 E-.02775
G1 X100.561 Y74.96 E-.11801
G1 X100.44 Y75.246 E-.11808
G1 X100.265 Y75.503 E-.118
G1 X100.043 Y75.72 E-.11813
G1 X99.788 Y75.885 E-.11533
G1 X99.567 Y75.979 E-.09138
G1 X99.43 Y76.01 E-.05332
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.861 Y80.121 Z2 F42000
G1 X111.344 Y83.627 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X111.319 Y83.65 E.00106
G3 X110.096 Y80.932 I-1.029 J-1.171 E.17909
G1 X110.251 Y80.92 E.00478
G3 X111.484 Y83.482 I.039 J1.559 E.10992
G1 X111.386 Y83.584 E.00434
; WIPE_START
M204 S6000
G1 X111.319 Y83.65 E-.03589
G1 X111.07 Y83.831 E-.11709
G1 X110.787 Y83.959 E-.11807
G1 X110.484 Y84.028 E-.11802
G1 X110.173 Y84.036 E-.118
G1 X109.867 Y83.982 E-.11813
G1 X109.578 Y83.868 E-.11807
G1 X109.541 Y83.845 E-.01674
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X110.14 Y91.453 Z2 F42000
G1 X111.84 Y113.058 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X111.818 Y113.269 E.00652
G3 X110.096 Y111.412 I-1.528 J-.31 E.21021
G1 X110.251 Y111.4 E.00478
G3 X111.849 Y112.96 I.039 J1.559 E.07648
G1 X111.846 Y112.998 E.00119
; WIPE_START
M204 S6000
G1 X111.818 Y113.269 E-.10337
G1 X111.727 Y113.566 E-.11803
G1 X111.579 Y113.839 E-.11801
G1 X111.379 Y114.077 E-.11803
G1 X111.138 Y114.269 E-.1171
G1 X110.931 Y114.382 E-.08969
G1 X110.692 Y114.463 E-.09577
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X103.737 Y117.606 Z2 F42000
G1 X97.512 Y120.42 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X97.513 Y120.415 E.00013
G3 X98.876 Y118.952 I1.557 J.084 E.06671
G1 X99.031 Y118.94 E.00478
G3 X97.518 Y120.655 I.039 J1.559 E.22217
G1 X97.514 Y120.48 E.00539
; WIPE_START
M204 S6000
G1 X97.513 Y120.415 E-.02442
G1 X97.558 Y120.115 E-.11545
G1 X97.664 Y119.823 E-.11812
G1 X97.826 Y119.558 E-.11803
G1 X98.037 Y119.33 E-.11803
G1 X98.29 Y119.149 E-.1181
G1 X98.573 Y119.021 E-.11814
G1 X98.649 Y119.004 E-.02972
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.51 Y126.079 Z2 F42000
G1 X134.291 Y207.148 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X134.573 Y207.021 E.0095
G3 X134.876 Y206.952 I.497 J1.478 E.00956
G1 X135.031 Y206.94 E.00478
G3 X134.24 Y207.179 I.039 J1.559 E.27534
; WIPE_START
M204 S6000
G1 X134.573 Y207.021 E-.14012
G1 X134.876 Y206.952 E-.11801
G1 X135.031 Y206.94 E-.05916
G1 X135.341 Y206.963 E-.11809
G1 X135.64 Y207.048 E-.11801
G1 X135.916 Y207.189 E-.11807
G1 X136.098 Y207.335 E-.08853
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.32 Y199.742 Z2 F42000
G1 X123.06 Y80.21 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X161.06 Y80.21 E1.16763
G1 X161.06 Y212.29 E4.05845
G1 X131.28 Y212.29 E.91506
G1 X131.28 Y124.49 E2.69785
G1 X95.28 Y124.49 E1.10618
G1 X95.28 Y43.71 E2.48214
G1 X142.36 Y43.71 E1.44664
G1 X142.36 Y48.79 E.15609
G1 X138.36 Y48.79 E.12291
G1 X138.36 Y64.71 E.48918
G1 X142.36 Y64.71 E.12291
G1 X142.36 Y70.29 E.17146
G1 X123.06 Y70.29 E.59304
G1 X123.06 Y80.15 E.30297
; WIPE_START
M204 S6000
G1 X125.06 Y80.153 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 80
M625
; object ids of layer 8 start: 80,91,102,113,124
M624 HwAAAAAAAAA=
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


; object ids of this layer8 end: 80,91,102,113,124
M625
; start printing object, unique label id: 80
M624 AQAAAAAAAAA=
G1 X145.124 Y80.871 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.382926
G1 F15000
M204 S6000
G1 X145.242 Y80.643 E.00711
; LINE_WIDTH: 0.412509
G1 X145.251 Y80.627 E.00056
; LINE_WIDTH: 0.439086
G1 X145.26 Y80.611 E.0006
; LINE_WIDTH: 0.429359
G1 X145.427 Y80.588 E.00531
; LINE_WIDTH: 0.37463
G1 X145.81 Y80.565 E.01036
G1 X146.176 Y80.579 E.00991
; LINE_WIDTH: 0.409247
G1 X146.369 Y80.6 E.00578
; LINE_WIDTH: 0.444198
G3 X146.645 Y80.645 I-.751 J5.518 E.00917
; WIPE_START
G1 X146.369 Y80.6 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.209 Y88.186 Z2 F42000
G1 X160.852 Y211.301 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.42
G1 F12000
M204 S2000
G1 X160.071 Y212.083 E.03397
G1 X159.537 Y212.083
G1 X160.852 Y210.768 E.05715
G1 X160.852 Y210.234
G1 X159.004 Y212.083 E.08032
G1 X158.471 Y212.083
G1 X160.852 Y209.701 E.10349
G1 X160.852 Y209.168
G1 X157.938 Y212.083 E.12666
G1 X157.404 Y212.083
G1 X160.852 Y208.635 E.14984
G1 X160.852 Y208.101
G1 X156.871 Y212.083 E.17301
G1 X156.338 Y212.083
G1 X160.852 Y207.568 E.19618
G1 X160.852 Y207.035
G1 X155.805 Y212.083 E.21936
G1 X155.271 Y212.083
G1 X160.852 Y206.501 E.24253
G1 X160.852 Y205.968
M73 P71 R9
G1 X154.738 Y212.083 E.2657
G1 X154.205 Y212.083
G1 X160.852 Y205.435 E.28887
G1 X160.852 Y204.902
G1 X153.672 Y212.083 E.31205
G1 X153.138 Y212.083
G1 X160.852 Y204.368 E.33522
G1 X160.852 Y203.835
G1 X152.605 Y212.083 E.35839
G1 X152.072 Y212.083
G1 X160.852 Y203.302 E.38156
G1 X160.852 Y202.769
G1 X151.538 Y212.083 E.40474
G1 X151.005 Y212.083
G1 X160.852 Y202.235 E.42791
G1 X160.852 Y201.702
G1 X150.472 Y212.083 E.45108
G1 X149.939 Y212.083
G1 X160.852 Y201.169 E.47425
G1 X160.852 Y200.636
G1 X149.405 Y212.083 E.49743
G1 X148.872 Y212.083
G1 X160.852 Y200.102 E.5206
G1 X160.852 Y199.569
G1 X148.339 Y212.083 E.54377
G1 X147.806 Y212.083
G1 X160.852 Y199.036 E.56694
G1 X160.852 Y198.503
G1 X147.272 Y212.083 E.59012
G1 X146.739 Y212.083
G1 X160.852 Y197.969 E.61329
G1 X160.852 Y197.436
G1 X146.206 Y212.083 E.63646
G1 X145.673 Y212.083
G1 X160.852 Y196.903 E.65964
G1 X160.852 Y196.37
G1 X145.139 Y212.083 E.68281
G1 X144.606 Y212.083
G1 X160.852 Y195.836 E.70598
G1 X160.852 Y195.303
G1 X144.073 Y212.083 E.72915
G1 X143.54 Y212.083
G1 X160.852 Y194.77 E.75233
G1 X160.852 Y194.237
G1 X143.006 Y212.083 E.7755
G1 X142.473 Y212.083
G1 X160.852 Y193.703 E.79867
G1 X160.852 Y193.17
G1 X141.94 Y212.083 E.82184
G1 X141.407 Y212.083
G1 X160.852 Y192.637 E.84502
G1 X160.852 Y192.104
G1 X140.873 Y212.083 E.86819
G1 X140.34 Y212.083
G1 X160.852 Y191.57 E.89136
G1 X160.852 Y191.037
G1 X139.807 Y212.083 E.91453
G1 X139.274 Y212.083
G1 X160.852 Y190.504 E.93771
G1 X160.852 Y189.971
G1 X138.74 Y212.083 E.96088
G1 X138.207 Y212.083
G1 X160.852 Y189.437 E.98405
G1 X160.852 Y188.904
G1 X137.674 Y212.083 E1.00722
G1 X137.141 Y212.083
G1 X160.852 Y188.371 E1.0304
G1 X160.852 Y187.837
G1 X136.607 Y212.083 E1.05357
G1 X136.074 Y212.083
G1 X160.852 Y187.304 E1.07674
G1 X160.852 Y186.771
G1 X135.541 Y212.083 E1.09991
G1 X135.008 Y212.083
G1 X160.852 Y186.238 E1.12309
G1 X160.852 Y185.704
G1 X134.474 Y212.083 E1.14626
G1 X133.941 Y212.083
G1 X136.083 Y209.941 E.09308
G1 X135.234 Y210.256
G1 X133.408 Y212.083 E.07936
G1 X132.874 Y212.083
G1 X134.73 Y210.227 E.08063
G1 X134.325 Y210.098
G1 X132.341 Y212.083 E.08622
G1 X131.808 Y212.083
G1 X133.992 Y209.899 E.0949
G1 X133.718 Y209.64
G1 X131.487 Y211.87 E.09693
G1 X131.487 Y211.337
G1 X133.505 Y209.319 E.08769
G1 X133.361 Y208.93
G1 X131.487 Y210.804 E.08143
G1 X131.487 Y210.27
G1 X133.31 Y208.448 E.07921
G1 X133.477 Y207.747
G1 X131.487 Y209.737 E.08649
; WIPE_START
M204 S6000
G1 X132.901 Y208.323 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.506 Y209.518 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X160.852 Y185.171 E1.05797
G1 X160.852 Y184.638
G1 X136.83 Y208.661 E1.0439
G1 X136.797 Y208.16
G1 X160.852 Y184.105 E1.04534
G1 X160.852 Y183.571
G1 X136.667 Y207.757 E1.05099
G1 X136.466 Y207.424
G1 X160.852 Y183.038 E1.05969
G1 X160.852 Y182.505
G1 X136.207 Y207.151 E1.07097
G1 X135.89 Y206.934
G1 X160.852 Y181.972 E1.08475
G1 X160.852 Y181.438
G1 X135.502 Y206.789 E1.10161
G1 X135.017 Y206.741
G1 X160.852 Y180.905 E1.12269
G1 X160.852 Y180.372
G1 X134.314 Y206.91 E1.15322
; WIPE_START
M204 S6000
G1 X135.728 Y205.496 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.487 Y209.204 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X160.852 Y179.839 E1.27606
G1 X160.852 Y179.305
G1 X131.487 Y208.671 E1.27606
G1 X131.487 Y208.137
G1 X160.852 Y178.772 E1.27606
G1 X160.852 Y178.239
G1 X131.487 Y207.604 E1.27606
G1 X131.487 Y207.071
G1 X160.852 Y177.706 E1.27606
G1 X160.852 Y177.172
G1 X131.487 Y206.538 E1.27606
G1 X131.487 Y206.004
G1 X160.852 Y176.639 E1.27606
G1 X160.852 Y176.106
G1 X131.487 Y205.471 E1.27606
G1 X131.487 Y204.938
G1 X160.852 Y175.573 E1.27606
G1 X160.852 Y175.039
G1 X131.487 Y204.405 E1.27606
G1 X131.487 Y203.871
G1 X160.852 Y174.506 E1.27606
G1 X160.852 Y173.973
G1 X131.487 Y203.338 E1.27606
G1 X131.487 Y202.805
G1 X160.852 Y173.44 E1.27606
G1 X160.852 Y172.906
G1 X131.487 Y202.272 E1.27606
G1 X131.487 Y201.738
G1 X160.852 Y172.373 E1.27606
G1 X160.852 Y171.84
G1 X131.487 Y201.205 E1.27606
G1 X131.487 Y200.672
G1 X160.852 Y171.306 E1.27606
G1 X160.852 Y170.773
G1 X131.487 Y200.138 E1.27606
G1 X131.487 Y199.605
G1 X160.852 Y170.24 E1.27606
G1 X160.852 Y169.707
G1 X131.487 Y199.072 E1.27606
G1 X131.487 Y198.539
G1 X160.852 Y169.173 E1.27606
G1 X160.852 Y168.64
G1 X131.487 Y198.005 E1.27606
G1 X131.487 Y197.472
G1 X160.852 Y168.107 E1.27606
G1 X160.852 Y167.574
G1 X131.487 Y196.939 E1.27606
G1 X131.487 Y196.406
G1 X160.852 Y167.04 E1.27606
G1 X160.852 Y166.507
G1 X131.487 Y195.872 E1.27606
G1 X131.487 Y195.339
G1 X160.852 Y165.974 E1.27606
G1 X160.852 Y165.441
G1 X131.487 Y194.806 E1.27606
G1 X131.487 Y194.273
G1 X160.852 Y164.907 E1.27606
G1 X160.852 Y164.374
G1 X131.487 Y193.739 E1.27606
G1 X131.487 Y193.206
G1 X160.852 Y163.841 E1.27606
G1 X160.852 Y163.308
G1 X131.487 Y192.673 E1.27606
G1 X131.487 Y192.14
G1 X160.852 Y162.774 E1.27606
G1 X160.852 Y162.241
G1 X131.487 Y191.606 E1.27606
M73 P72 R9
G1 X131.487 Y191.073
G1 X160.852 Y161.708 E1.27606
G1 X160.852 Y161.175
G1 X131.487 Y190.54 E1.27606
G1 X131.487 Y190.007
G1 X160.852 Y160.641 E1.27606
G1 X160.852 Y160.108
G1 X131.487 Y189.473 E1.27606
G1 X131.487 Y188.94
G1 X160.852 Y159.575 E1.27606
G1 X160.852 Y159.042
G1 X131.487 Y188.407 E1.27606
G1 X131.487 Y187.874
G1 X160.852 Y158.508 E1.27606
G1 X160.852 Y157.975
G1 X131.487 Y187.34 E1.27606
G1 X131.487 Y186.807
G1 X160.852 Y157.442 E1.27606
G1 X160.852 Y156.909
G1 X131.487 Y186.274 E1.27606
G1 X131.487 Y185.741
G1 X160.852 Y156.375 E1.27606
G1 X160.852 Y155.842
G1 X131.487 Y185.207 E1.27606
G1 X131.487 Y184.674
G1 X160.852 Y155.309 E1.27606
G1 X160.852 Y154.776
G1 X131.487 Y184.141 E1.27606
G1 X131.487 Y183.607
G1 X160.852 Y154.242 E1.27606
G1 X160.852 Y153.709
G1 X131.487 Y183.074 E1.27606
G1 X131.487 Y182.541
G1 X160.852 Y153.176 E1.27606
G1 X160.852 Y152.642
G1 X131.487 Y182.008 E1.27606
G1 X131.487 Y181.474
G1 X160.852 Y152.109 E1.27606
M73 P72 R8
G1 X160.852 Y151.576
G1 X131.487 Y180.941 E1.27606
G1 X131.487 Y180.408
G1 X160.852 Y151.043 E1.27606
G1 X160.852 Y150.509
G1 X131.487 Y179.875 E1.27606
G1 X131.487 Y179.341
G1 X160.852 Y149.976 E1.27606
G1 X160.852 Y149.443
G1 X131.487 Y178.808 E1.27606
G1 X131.487 Y178.275
G1 X160.852 Y148.91 E1.27606
G1 X160.852 Y148.376
G1 X131.487 Y177.742 E1.27606
G1 X131.487 Y177.208
G1 X160.852 Y147.843 E1.27606
G1 X160.852 Y147.31
G1 X131.487 Y176.675 E1.27606
G1 X131.487 Y176.142
G1 X160.852 Y146.777 E1.27606
G1 X160.852 Y146.243
G1 X131.487 Y175.609 E1.27606
G1 X131.487 Y175.075
G1 X160.852 Y145.71 E1.27606
G1 X160.852 Y145.177
G1 X131.487 Y174.542 E1.27606
G1 X131.487 Y174.009
G1 X160.852 Y144.644 E1.27606
G1 X160.852 Y144.11
G1 X131.487 Y173.476 E1.27606
G1 X131.487 Y172.942
G1 X160.852 Y143.577 E1.27606
G1 X160.852 Y143.044
G1 X131.487 Y172.409 E1.27606
G1 X131.487 Y171.876
G1 X160.852 Y142.511 E1.27606
G1 X160.852 Y141.977
G1 X131.487 Y171.343 E1.27606
G1 X131.487 Y170.809
G1 X160.852 Y141.444 E1.27606
G1 X160.852 Y140.911
G1 X131.487 Y170.276 E1.27606
G1 X131.487 Y169.743
G1 X160.852 Y140.378 E1.27606
G1 X160.852 Y139.844
G1 X131.487 Y169.21 E1.27606
G1 X131.487 Y168.676
G1 X160.852 Y139.311 E1.27606
G1 X160.852 Y138.778
G1 X131.487 Y168.143 E1.27606
G1 X131.487 Y167.61
G1 X160.852 Y138.245 E1.27606
G1 X160.852 Y137.711
G1 X131.487 Y167.077 E1.27606
G1 X131.487 Y166.543
G1 X160.852 Y137.178 E1.27606
G1 X160.852 Y136.645
G1 X131.487 Y166.01 E1.27606
G1 X131.487 Y165.477
G1 X160.852 Y136.112 E1.27606
G1 X160.852 Y135.578
G1 X131.487 Y164.943 E1.27606
G1 X131.487 Y164.41
G1 X160.852 Y135.045 E1.27606
G1 X160.852 Y134.512
G1 X131.487 Y163.877 E1.27606
G1 X131.487 Y163.344
G1 X160.852 Y133.978 E1.27606
G1 X160.852 Y133.445
G1 X131.487 Y162.81 E1.27606
G1 X131.487 Y162.277
G1 X160.852 Y132.912 E1.27606
G1 X160.852 Y132.379
G1 X131.487 Y161.744 E1.27606
G1 X131.487 Y161.211
G1 X160.852 Y131.845 E1.27606
G1 X160.852 Y131.312
G1 X131.487 Y160.677 E1.27606
G1 X131.487 Y160.144
G1 X160.852 Y130.779 E1.27606
G1 X160.852 Y130.246
G1 X131.487 Y159.611 E1.27606
M73 P73 R8
G1 X131.487 Y159.078
G1 X160.852 Y129.712 E1.27606
G1 X160.852 Y129.179
G1 X131.487 Y158.544 E1.27606
G1 X131.487 Y158.011
G1 X160.852 Y128.646 E1.27606
G1 X160.852 Y128.113
G1 X131.487 Y157.478 E1.27606
G1 X131.487 Y156.945
G1 X160.852 Y127.579 E1.27606
G1 X160.852 Y127.046
G1 X158.683 Y129.216 E.09427
G1 X158.83 Y128.536
G1 X160.852 Y126.513 E.0879
G1 X160.852 Y125.98
G1 X158.776 Y128.056 E.09025
G1 X158.629 Y127.669
G1 X160.852 Y125.446 E.0966
G1 X160.852 Y124.913
G1 X158.413 Y127.352 E.10599
G1 X158.138 Y127.095
G1 X160.852 Y124.38 E.11797
G1 X160.852 Y123.847
G1 X157.802 Y126.897 E.13255
G1 X157.395 Y126.77
G1 X160.852 Y123.313 E.15023
G1 X160.852 Y122.78
G1 X156.888 Y126.744 E.17226
G1 X155.992 Y127.108
G1 X160.852 Y122.247 E.21123
; WIPE_START
M204 S6000
G1 X159.438 Y123.661 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X157.795 Y130.103 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X131.487 Y156.411 E1.1432
G1 X131.487 Y155.878
G1 X157.106 Y130.26 E1.11325
G1 X156.624 Y130.208
G1 X131.487 Y155.345 E1.0923
G1 X131.487 Y154.812
G1 X156.24 Y130.059 E1.07562
G1 X155.924 Y129.841
G1 X131.487 Y154.278 E1.06191
G1 X131.487 Y153.745
G1 X155.666 Y129.566 E1.05071
G1 X155.468 Y129.231
G1 X131.487 Y153.212 E1.04209
G1 X131.487 Y152.679
G1 X155.34 Y128.826 E1.03653
G1 X155.31 Y128.322
G1 X131.487 Y152.145 E1.03523
G1 X131.487 Y151.612
G1 X155.649 Y127.451 E1.04993
; WIPE_START
M204 S6000
G1 X154.234 Y128.865 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X159.418 Y123.263 Z2 F42000
G1 X160.852 Y121.714 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X131.487 Y151.079 E1.27606
G1 X131.487 Y150.546
G1 X160.852 Y121.18 E1.27606
G1 X160.852 Y120.647
G1 X131.487 Y150.012 E1.27606
G1 X131.487 Y149.479
G1 X160.852 Y120.114 E1.27606
G1 X160.852 Y119.581
G1 X131.487 Y148.946 E1.27606
G1 X131.487 Y148.413
G1 X160.852 Y119.047 E1.27606
G1 X160.852 Y118.514
G1 X131.487 Y147.879 E1.27606
G1 X131.487 Y147.346
G1 X160.852 Y117.981 E1.27606
G1 X160.852 Y117.447
G1 X131.487 Y146.813 E1.27606
G1 X131.487 Y146.279
G1 X160.852 Y116.914 E1.27606
G1 X160.852 Y116.381
G1 X131.487 Y145.746 E1.27606
G1 X131.487 Y145.213
G1 X160.852 Y115.848 E1.27606
G1 X160.852 Y115.314
G1 X131.487 Y144.68 E1.27606
G1 X131.487 Y144.146
G1 X160.852 Y114.781 E1.27606
G1 X160.852 Y114.248
G1 X131.487 Y143.613 E1.27606
G1 X131.487 Y143.08
G1 X160.852 Y113.715 E1.27606
G1 X160.852 Y113.181
G1 X131.487 Y142.547 E1.27606
G1 X131.487 Y142.013
G1 X160.852 Y112.648 E1.27606
G1 X160.852 Y112.115
G1 X131.487 Y141.48 E1.27606
G1 X131.487 Y140.947
G1 X160.852 Y111.582 E1.27606
G1 X160.852 Y111.048
G1 X131.487 Y140.414 E1.27606
G1 X131.487 Y139.88
G1 X160.852 Y110.515 E1.27606
G1 X160.852 Y109.982
G1 X131.487 Y139.347 E1.27606
G1 X131.487 Y138.814
G1 X160.852 Y109.449 E1.27606
G1 X160.852 Y108.915
G1 X131.487 Y138.281 E1.27606
G1 X131.487 Y137.747
G1 X160.852 Y108.382 E1.27606
G1 X160.852 Y107.849
G1 X131.487 Y137.214 E1.27606
G1 X131.487 Y136.681
G1 X160.852 Y107.316 E1.27606
G1 X160.852 Y106.782
G1 X131.487 Y136.148 E1.27606
G1 X131.487 Y135.614
G1 X160.852 Y106.249 E1.27606
G1 X160.852 Y105.716
G1 X131.487 Y135.081 E1.27606
G1 X131.487 Y134.548
G1 X160.852 Y105.183 E1.27606
G1 X160.852 Y104.649
G1 X131.487 Y134.015 E1.27606
G1 X131.487 Y133.481
G1 X160.852 Y104.116 E1.27606
G1 X160.852 Y103.583
G1 X131.487 Y132.948 E1.27606
G1 X131.487 Y132.415
G1 X160.852 Y103.05 E1.27606
G1 X160.852 Y102.516
G1 X131.487 Y131.882 E1.27606
G1 X131.487 Y131.348
G1 X160.852 Y101.983 E1.27606
G1 X160.852 Y101.45
G1 X131.487 Y130.815 E1.27606
G1 X131.487 Y130.282
G1 X160.852 Y100.917 E1.27606
G1 X160.852 Y100.383
G1 X147.346 Y113.89 E.58693
G1 X147.61 Y113.093
G1 X160.852 Y99.85 E.57546
M73 P74 R8
G1 X160.852 Y99.317
G1 X147.572 Y112.597 E.5771
G1 X147.438 Y112.198
G1 X160.852 Y98.783 E.58291
G1 X160.852 Y98.25
G1 X147.235 Y111.868 E.59174
G1 X146.973 Y111.597
G1 X160.852 Y97.717 E.60315
G1 X160.852 Y97.184
G1 X146.652 Y111.384 E.61708
G1 X146.258 Y111.245
G1 X160.852 Y96.65 E.6342
G1 X160.852 Y96.117
G1 X145.768 Y111.202 E.65549
G1 X145.043 Y111.393
G1 X160.852 Y95.584 E.68699
; WIPE_START
M204 S6000
G1 X159.438 Y96.998 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X154.957 Y103.177 Z2 F42000
G1 X146.768 Y114.468 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X131.487 Y129.748 E.66401
G1 X131.487 Y129.215
G1 X145.985 Y114.717 E.63002
G1 X145.486 Y114.683
G1 X131.487 Y128.682 E.60833
G1 X131.487 Y128.149
G1 X145.085 Y114.551 E.59091
G1 X144.755 Y114.348
G1 X131.487 Y127.615 E.57654
G1 X131.487 Y127.082
G1 X144.486 Y114.084 E.56485
G1 X144.277 Y113.759
G1 X131.487 Y126.549 E.55577
G1 X131.487 Y126.016
G1 X144.137 Y113.366 E.54967
G1 X144.085 Y112.885
G1 X131.487 Y125.482 E.54743
G1 X131.487 Y124.949
G1 X144.276 Y112.16 E.55573
; WIPE_START
M204 S6000
G1 X142.862 Y113.575 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X148.179 Y108.099 Z2 F42000
G1 X160.852 Y95.051 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X131.487 Y124.416 E1.27606
G1 X131.087 Y124.283
G1 X160.852 Y94.517 E1.29344
G1 X160.852 Y93.984
G1 X130.554 Y124.283 E1.31661
G1 X130.021 Y124.283
G1 X160.852 Y93.451 E1.33979
G1 X160.852 Y92.918
G1 X129.487 Y124.283 E1.36296
G1 X128.954 Y124.283
G1 X160.852 Y92.384 E1.38613
G1 X160.852 Y91.851
G1 X128.421 Y124.283 E1.4093
G1 X127.888 Y124.283
G1 X160.852 Y91.318 E1.43248
G1 X160.852 Y90.785
G1 X127.354 Y124.283 E1.45565
G1 X126.821 Y124.283
G1 X160.852 Y90.251 E1.47882
G1 X160.852 Y89.718
G1 X126.288 Y124.283 E1.502
G1 X125.755 Y124.283
G1 X160.852 Y89.185 E1.52517
G1 X160.852 Y88.652
G1 X125.221 Y124.283 E1.54834
G1 X124.688 Y124.283
G1 X160.852 Y88.118 E1.57151
G1 X160.852 Y87.585
G1 X124.155 Y124.283 E1.59469
G1 X123.622 Y124.283
G1 X160.852 Y87.052 E1.61786
G1 X160.852 Y86.519
G1 X123.088 Y124.283 E1.64103
G1 X122.555 Y124.283
G1 X160.852 Y85.985 E1.6642
G1 X160.852 Y85.452
G1 X122.022 Y124.283 E1.68738
G1 X121.489 Y124.283
G1 X160.852 Y84.919 E1.71055
G1 X160.852 Y84.386
G1 X120.955 Y124.283 E1.73372
G1 X120.422 Y124.283
G1 X160.852 Y83.852 E1.75689
G1 X160.852 Y83.319
G1 X119.889 Y124.283 E1.78007
G1 X119.356 Y124.283
G1 X160.852 Y82.786 E1.80324
G1 X160.852 Y82.253
G1 X118.822 Y124.283 E1.82641
G1 X118.289 Y124.283
G1 X160.852 Y81.719 E1.84959
G1 X160.852 Y81.186
G1 X117.756 Y124.283 E1.87276
G1 X117.223 Y124.283
G1 X160.852 Y80.653 E1.89593
G1 X160.555 Y80.417
G1 X116.689 Y124.283 E1.90616
G1 X116.156 Y124.283
G1 X160.021 Y80.417 E1.90616
G1 X159.488 Y80.417
G1 X115.623 Y124.283 E1.90616
G1 X115.09 Y124.283
G1 X158.955 Y80.417 E1.90616
G1 X158.422 Y80.417
G1 X114.556 Y124.283 E1.90616
G1 X114.023 Y124.283
G1 X157.888 Y80.417 E1.90616
G1 X157.355 Y80.417
G1 X113.49 Y124.283 E1.90616
G1 X112.956 Y124.283
G1 X156.822 Y80.417 E1.90616
G1 X156.288 Y80.417
G1 X112.423 Y124.283 E1.90616
G1 X111.89 Y124.283
G1 X155.755 Y80.417 E1.90616
G1 X155.222 Y80.417
G1 X111.357 Y124.283 E1.90616
G1 X110.823 Y124.283
G1 X154.689 Y80.417 E1.90616
G1 X154.155 Y80.417
G1 X110.29 Y124.283 E1.90616
G1 X109.757 Y124.283
G1 X153.622 Y80.417 E1.90616
G1 X153.089 Y80.417
G1 X109.224 Y124.283 E1.90616
G1 X108.69 Y124.283
G1 X152.556 Y80.417 E1.90616
G1 X152.022 Y80.417
G1 X108.157 Y124.283 E1.90616
M73 P75 R8
G1 X107.624 Y124.283
G1 X151.489 Y80.417 E1.90616
G1 X150.956 Y80.417
G1 X107.091 Y124.283 E1.90616
G1 X106.557 Y124.283
G1 X150.423 Y80.417 E1.90616
G1 X149.889 Y80.417
G1 X147.599 Y82.707 E.09951
G1 X147.586 Y82.187
G1 X149.356 Y80.417 E.07692
G1 X148.823 Y80.417
G1 X147.463 Y81.777 E.05908
G1 X147.269 Y81.438
G1 X148.29 Y80.417 E.04434
G1 X147.756 Y80.417
G1 X147.015 Y81.158 E.0322
G1 X146.828 Y80.812
G1 X147.223 Y80.417 E.01716
; WIPE_START
M204 S6000
G1 X146.828 Y80.812 E-.21227
G1 X147.015 Y81.158 E-.14951
G1 X147.756 Y80.417 E-.39822
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X146.072 Y84.234 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X106.024 Y124.283 E1.74029
G1 X105.491 Y124.283
G1 X145.558 Y84.216 E1.74111
G1 X145.146 Y84.094
G1 X104.958 Y124.283 E1.74638
G1 X104.424 Y124.283
G1 X144.806 Y83.901 E1.75478
G1 X144.526 Y83.647
G1 X103.891 Y124.283 E1.7658
G1 X103.358 Y124.283
M73 P75 R7
G1 X144.304 Y83.337 E1.7793
G1 X144.151 Y82.957
G1 X102.825 Y124.283 E1.79582
G1 X102.291 Y124.283
G1 X144.087 Y82.487 E1.81621
G1 X144.215 Y81.826
G1 X101.758 Y124.283 E1.84497
G1 X101.225 Y124.283
G1 X110.885 Y114.622 E.4198
G1 X110.253 Y114.721
G1 X100.692 Y124.283 E.41548
G1 X100.158 Y124.283
G1 X109.788 Y114.653 E.41844
G1 X109.417 Y114.491
G1 X99.625 Y124.283 E.42549
G1 X99.092 Y124.283
G1 X109.108 Y114.266 E.43527
G1 X108.858 Y113.984
G1 X98.559 Y124.283 E.44755
G1 X98.025 Y124.283
G1 X108.667 Y113.641 E.46243
G1 X108.548 Y113.226
G1 X100.762 Y121.013 E.33835
G1 X100.83 Y120.412
G1 X108.55 Y112.691 E.3355
; WIPE_START
M204 S6000
G1 X107.136 Y114.105 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X111.946 Y113.561 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X144.714 Y80.793 E1.42393
G1 X144.557 Y80.417
G1 X112.05 Y112.924 E1.41259
G1 X111.984 Y112.457
G1 X144.024 Y80.417 E1.39229
G1 X143.49 Y80.417
G1 X111.823 Y112.085 E1.3761
G1 X111.597 Y111.777
G1 X142.957 Y80.417 E1.36273
G1 X142.424 Y80.417
G1 X111.314 Y111.527 E1.35185
G1 X110.971 Y111.337
G1 X141.891 Y80.417 E1.3436
G1 X141.357 Y80.417
G1 X110.555 Y111.22 E1.33851
G1 X110.026 Y111.215
G1 X140.824 Y80.417 E1.3383
G1 X140.291 Y80.417
G1 X100.751 Y119.957 E1.7182
G1 X100.582 Y119.593
G1 X139.758 Y80.417 E1.70238
G1 X139.224 Y80.417
G1 X100.351 Y119.291 E1.68924
G1 X100.062 Y119.046
G1 X138.691 Y80.417 E1.6786
G1 X138.158 Y80.417
G1 X99.713 Y118.862 E1.6706
G1 X99.29 Y118.752
G1 X137.624 Y80.417 E1.66582
G1 X137.091 Y80.417
G1 X98.738 Y118.771 E1.66663
; WIPE_START
M204 S6000
G1 X100.152 Y117.356 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.588 Y122.187 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X97.492 Y124.283 E.09107
G1 X96.959 Y124.283
G1 X98.979 Y122.263 E.08778
G1 X98.53 Y122.179
G1 X96.426 Y124.283 E.09143
G1 X95.892 Y124.283
G1 X98.165 Y122.01 E.09874
G1 X97.862 Y121.78
G1 X95.487 Y124.154 E.10318
G1 X95.487 Y123.621
G1 X97.616 Y121.492 E.09252
G1 X97.431 Y121.144
G1 X95.487 Y123.088 E.08448
G1 X95.487 Y122.555
G1 X97.319 Y120.722 E.07962
G1 X97.34 Y120.169
G1 X95.487 Y122.021 E.08051
G1 X95.487 Y121.488
G1 X136.558 Y80.417 E1.78472
G1 X136.025 Y80.417
G1 X95.487 Y120.955 E1.76155
G1 X95.487 Y120.422
M73 P76 R7
G1 X135.491 Y80.417 E1.73838
G1 X134.958 Y80.417
G1 X95.487 Y119.888 E1.71521
G1 X95.487 Y119.355
G1 X134.425 Y80.417 E1.69203
G1 X133.892 Y80.417
G1 X95.487 Y118.822 E1.66886
G1 X95.487 Y118.289
G1 X133.358 Y80.417 E1.64569
G1 X132.825 Y80.417
G1 X95.487 Y117.755 E1.62251
G1 X95.487 Y117.222
G1 X132.292 Y80.417 E1.59934
G1 X131.759 Y80.417
G1 X95.487 Y116.689 E1.57617
G1 X95.487 Y116.156
G1 X131.225 Y80.417 E1.553
G1 X130.692 Y80.417
G1 X95.487 Y115.622 E1.52982
G1 X95.487 Y115.089
G1 X130.159 Y80.417 E1.50665
G1 X129.626 Y80.417
G1 X95.487 Y114.556 E1.48348
G1 X95.487 Y114.023
G1 X129.092 Y80.417 E1.46031
G1 X128.559 Y80.417
G1 X95.487 Y113.489 E1.43713
G1 X95.487 Y112.956
G1 X128.026 Y80.417 E1.41396
G1 X127.493 Y80.417
G1 X95.487 Y112.423 E1.39079
G1 X95.487 Y111.889
G1 X126.959 Y80.417 E1.36762
G1 X126.426 Y80.417
G1 X95.487 Y111.356 E1.34444
G1 X95.487 Y110.823
G1 X125.893 Y80.417 E1.32127
G1 X125.36 Y80.417
G1 X95.487 Y110.29 E1.2981
G1 X95.487 Y109.756
G1 X124.826 Y80.417 E1.27493
G1 X124.293 Y80.417
G1 X95.487 Y109.223 E1.25175
G1 X95.487 Y108.69
G1 X123.76 Y80.417 E1.22858
G1 X123.227 Y80.417
G1 X95.487 Y108.157 E1.20541
G1 X95.487 Y107.623
G1 X122.852 Y80.258 E1.18915
G1 X122.852 Y79.725
G1 X95.487 Y107.09 E1.18915
G1 X95.487 Y106.557
G1 X122.852 Y79.192 E1.18915
G1 X122.852 Y78.658
G1 X95.487 Y106.024 E1.18915
G1 X95.487 Y105.49
G1 X122.852 Y78.125 E1.18915
G1 X122.852 Y77.592
G1 X95.487 Y104.957 E1.18915
G1 X95.487 Y104.424
G1 X122.852 Y77.059 E1.18915
G1 X122.852 Y76.525
G1 X95.487 Y103.891 E1.18915
G1 X95.487 Y103.357
G1 X122.852 Y75.992 E1.18915
G1 X122.852 Y75.459
G1 X95.487 Y102.824 E1.18915
G1 X95.487 Y102.291
G1 X122.852 Y74.926 E1.18915
G1 X122.852 Y74.392
G1 X95.487 Y101.758 E1.18915
G1 X95.487 Y101.224
G1 X122.852 Y73.859 E1.18915
G1 X122.852 Y73.326
G1 X95.487 Y100.691 E1.18915
G1 X95.487 Y100.158
G1 X122.852 Y72.793 E1.18915
G1 X122.852 Y72.259
G1 X111.885 Y83.227 E.4766
G1 X112.05 Y82.529
G1 X122.852 Y71.726 E.46943
G1 X122.852 Y71.193
G1 X111.998 Y82.047 E.47168
G1 X111.853 Y81.659
G1 X122.852 Y70.66 E.47796
G1 X122.852 Y70.126
G1 X111.64 Y81.339 E.48723
; WIPE_START
M204 S6000
G1 X113.054 Y79.924 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X111.039 Y84.073 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X95.487 Y99.625 E.67581
G1 X95.487 Y99.091
G1 X110.339 Y84.239 E.6454
G1 X109.855 Y84.19
G1 X95.487 Y98.558 E.62435
G1 X95.487 Y98.025
G1 X109.468 Y84.044 E.60753
G1 X109.151 Y83.828
G1 X95.487 Y97.492 E.59376
G1 X95.487 Y96.958
G1 X108.892 Y83.554 E.5825
G1 X108.692 Y83.22
G1 X95.487 Y96.425 E.57381
G1 X95.487 Y95.892
G1 X108.562 Y82.817 E.56818
G1 X108.535 Y82.31
G1 X95.487 Y95.359 E.567
G1 X95.487 Y94.825
G1 X108.848 Y81.465 E.58058
; WIPE_START
M204 S6000
G1 X107.434 Y82.879 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X114.58 Y80.199 Z2 F42000
G1 X141.56 Y70.083 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X142.152 Y69.49 E.02574
G1 X142.152 Y68.957
G1 X141.027 Y70.083 E.04891
G1 X140.494 Y70.083
G1 X142.152 Y68.424 E.07208
G1 X142.152 Y67.891
G1 X139.96 Y70.083 E.09526
G1 X139.427 Y70.083
G1 X142.152 Y67.357 E.11843
G1 X142.152 Y66.824
G1 X138.894 Y70.083 E.1416
G1 X138.361 Y70.083
G1 X142.152 Y66.291 E.16477
G1 X142.152 Y65.758
G1 X137.827 Y70.083 E.18795
G1 X137.294 Y70.083
G1 X142.152 Y65.224 E.21112
G1 X141.926 Y64.917
G1 X136.761 Y70.083 E.22446
G1 X136.228 Y70.083
G1 X141.393 Y64.917 E.22446
G1 X140.86 Y64.917
G1 X135.694 Y70.083 E.22446
G1 X135.161 Y70.083
G1 X140.326 Y64.917 E.22446
M73 P77 R7
G1 X139.793 Y64.917
G1 X134.628 Y70.083 E.22446
G1 X134.095 Y70.083
G1 X139.26 Y64.917 E.22446
G1 X138.727 Y64.917
G1 X133.561 Y70.083 E.22445
G1 X133.028 Y70.083
G1 X138.193 Y64.917 E.22445
G1 X138.152 Y64.425
G1 X132.495 Y70.083 E.24585
G1 X131.962 Y70.083
G1 X138.152 Y63.892 E.26903
G1 X138.152 Y63.358
G1 X131.428 Y70.083 E.2922
G1 X130.895 Y70.083
G1 X138.152 Y62.825 E.31537
G1 X138.152 Y62.292
G1 X130.362 Y70.083 E.33854
G1 X129.828 Y70.083
G1 X138.152 Y61.759 E.36172
G1 X138.152 Y61.225
G1 X129.295 Y70.083 E.38489
G1 X128.762 Y70.083
G1 X138.152 Y60.692 E.40806
G1 X138.152 Y60.159
G1 X128.229 Y70.083 E.43123
G1 X127.695 Y70.083
G1 X138.152 Y59.626 E.45441
G1 X138.152 Y59.092
G1 X127.162 Y70.083 E.47758
G1 X126.629 Y70.083
G1 X138.152 Y58.559 E.50075
G1 X138.152 Y58.026
G1 X126.096 Y70.083 E.52393
G1 X125.562 Y70.083
G1 X138.152 Y57.493 E.5471
G1 X138.152 Y56.959
G1 X125.029 Y70.083 E.57027
G1 X124.496 Y70.083
G1 X138.152 Y56.426 E.59344
G1 X138.152 Y55.893
G1 X123.963 Y70.083 E.61662
G1 X123.429 Y70.083
G1 X138.152 Y55.36 E.63979
G1 X138.152 Y54.826
G1 X122.896 Y70.083 E.66296
; WIPE_START
M204 S6000
G1 X124.31 Y68.668 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X118.801 Y73.951 Z2 F42000
G1 X111.366 Y81.08 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X138.152 Y54.293 E1.16402
G1 X138.152 Y53.76
G1 X111.032 Y80.881 E1.17853
G1 X110.627 Y80.752
G1 X138.152 Y53.227 E1.19613
G1 X138.152 Y52.693
G1 X110.122 Y80.724 E1.21806
G1 X109.258 Y81.054
G1 X138.152 Y52.16 E1.25559
G1 X138.152 Y51.627
G1 X95.487 Y94.292 E1.85401
G1 X95.487 Y93.759
G1 X138.152 Y51.093 E1.85401
G1 X138.152 Y50.56
G1 X95.487 Y93.225 E1.85401
G1 X95.487 Y92.692
G1 X138.152 Y50.027 E1.85401
G1 X138.152 Y49.494
G1 X95.487 Y92.159 E1.85401
G1 X95.487 Y91.626
G1 X138.152 Y48.96 E1.85401
; WIPE_START
M204 S6000
G1 X136.738 Y50.375 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.152 Y48.16 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X141.73 Y48.583 E.01836
G1 X141.197 Y48.583
G1 X142.152 Y47.627 E.04154
G1 X142.152 Y47.093
G1 X140.663 Y48.583 E.06471
G1 X140.13 Y48.583
G1 X142.152 Y46.56 E.08788
G1 X142.152 Y46.027
G1 X139.597 Y48.583 E.11105
G1 X139.064 Y48.583
G1 X142.152 Y45.494 E.13423
G1 X142.152 Y44.96
G1 X138.53 Y48.583 E.1574
; WIPE_START
M204 S6000
G1 X139.945 Y47.168 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X142.152 Y44.427 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X95.487 Y91.092 E2.02783
G1 X95.487 Y90.559
G1 X142.129 Y43.917 E2.02681
G1 X141.596 Y43.917
G1 X95.487 Y90.026 E2.00364
G1 X95.487 Y89.493
G1 X141.063 Y43.917 E1.98047
G1 X140.529 Y43.917
G1 X95.487 Y88.959 E1.9573
G1 X95.487 Y88.426
G1 X139.996 Y43.917 E1.93412
G1 X139.463 Y43.917
G1 X95.487 Y87.893 E1.91095
G1 X95.487 Y87.36
G1 X138.929 Y43.917 E1.88778
G1 X138.396 Y43.917
G1 X95.487 Y86.826 E1.86461
G1 X95.487 Y86.293
G1 X137.863 Y43.917 E1.84143
G1 X137.33 Y43.917
G1 X95.487 Y85.76 E1.81826
G1 X95.487 Y85.227
G1 X136.796 Y43.917 E1.79509
G1 X136.263 Y43.917
G1 X95.487 Y84.693 E1.77191
G1 X95.487 Y84.16
G1 X135.73 Y43.917 E1.74874
G1 X135.197 Y43.917
G1 X95.487 Y83.627 E1.72557
G1 X95.487 Y83.094
G1 X134.663 Y43.917 E1.7024
G1 X134.13 Y43.917
G1 X95.487 Y82.56 E1.67922
G1 X95.487 Y82.027
G1 X133.597 Y43.917 E1.65605
G1 X133.064 Y43.917
G1 X95.487 Y81.494 E1.63288
G1 X95.487 Y80.961
G1 X132.53 Y43.917 E1.60971
G1 X131.997 Y43.917
G1 X100.663 Y75.252 E1.36163
G1 X100.83 Y74.552
G1 X131.464 Y43.917 E1.3312
G1 X130.931 Y43.917
G1 X100.778 Y74.07 E1.31026
G1 X100.634 Y73.681
G1 X130.397 Y43.917 E1.29335
G1 X129.864 Y43.917
G1 X100.421 Y73.36 E1.27942
G1 X100.147 Y73.101
G1 X129.331 Y43.917 E1.26817
G1 X128.798 Y43.917
G1 X99.814 Y72.901 E1.25949
G1 X99.409 Y72.773
G1 X128.264 Y43.917 E1.25391
G1 X127.731 Y43.917
G1 X98.905 Y72.744 E1.25264
G1 X98.048 Y73.067
G1 X127.198 Y43.917 E1.26669
; WIPE_START
M204 S6000
G1 X125.784 Y45.332 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X120.861 Y51.164 Z2 F42000
G1 X99.816 Y76.098 Z2
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X95.487 Y80.427 E.18812
G1 X95.487 Y79.894
G1 X99.122 Y76.259 E.15795
G1 X98.637 Y76.211
G1 X95.487 Y79.361 E.13688
G1 X95.487 Y78.828
G1 X98.25 Y76.065 E.12004
G1 X97.932 Y75.849
G1 X95.487 Y78.294 E.10626
M73 P78 R7
G1 X95.487 Y77.761
G1 X97.673 Y75.575 E.09498
G1 X97.473 Y75.242
G1 X95.487 Y77.228 E.08628
G1 X95.487 Y76.695
G1 X97.343 Y74.839 E.08064
G1 X97.315 Y74.334
G1 X95.487 Y76.161 E.07942
G1 X95.487 Y75.628
G1 X97.624 Y73.492 E.09283
; WIPE_START
M204 S6000
G1 X96.209 Y74.906 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.487 Y75.095 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S2000
G1 X126.665 Y43.917 E1.35481
G1 X126.131 Y43.917
G1 X95.487 Y74.561 E1.33163
G1 X95.487 Y74.028
G1 X125.598 Y43.917 E1.30846
G1 X125.065 Y43.917
G1 X95.487 Y73.495 E1.28529
G1 X95.487 Y72.962
G1 X124.532 Y43.917 E1.26212
G1 X123.998 Y43.917
G1 X95.487 Y72.428 E1.23894
G1 X95.487 Y71.895
G1 X123.465 Y43.917 E1.21577
G1 X122.932 Y43.917
G1 X95.487 Y71.362 E1.1926
G1 X95.487 Y70.829
G1 X122.399 Y43.917 E1.16943
G1 X121.865 Y43.917
G1 X95.487 Y70.295 E1.14625
G1 X95.487 Y69.762
G1 X121.332 Y43.917 E1.12308
G1 X120.799 Y43.917
G1 X95.487 Y69.229 E1.09991
G1 X95.487 Y68.696
G1 X120.265 Y43.917 E1.07674
G1 X119.732 Y43.917
G1 X95.487 Y68.162 E1.05356
G1 X95.487 Y67.629
G1 X119.199 Y43.917 E1.03039
G1 X118.666 Y43.917
G1 X95.487 Y67.096 E1.00722
G1 X95.487 Y66.563
G1 X118.132 Y43.917 E.98405
G1 X117.599 Y43.917
G1 X95.487 Y66.029 E.96087
G1 X95.487 Y65.496
G1 X117.066 Y43.917 E.9377
G1 X116.533 Y43.917
G1 X95.487 Y64.963 E.91453
G1 X95.487 Y64.43
G1 X115.999 Y43.917 E.89135
G1 X115.466 Y43.917
G1 X95.487 Y63.896 E.86818
G1 X95.487 Y63.363
G1 X114.933 Y43.917 E.84501
G1 X114.4 Y43.917
G1 X95.487 Y62.83 E.82184
G1 X95.487 Y62.297
G1 X113.866 Y43.917 E.79866
G1 X113.333 Y43.917
G1 X95.487 Y61.763 E.77549
G1 X95.487 Y61.23
G1 X112.8 Y43.917 E.75232
G1 X112.267 Y43.917
G1 X95.487 Y60.697 E.72915
G1 X95.487 Y60.164
G1 X111.733 Y43.917 E.70597
G1 X111.2 Y43.917
G1 X95.487 Y59.63 E.6828
G1 X95.487 Y59.097
G1 X110.667 Y43.917 E.65963
G1 X110.134 Y43.917
G1 X95.487 Y58.564 E.63646
G1 X95.487 Y58.03
G1 X109.6 Y43.917 E.61328
M73 P78 R6
G1 X109.067 Y43.917
G1 X95.487 Y57.497 E.59011
G1 X95.487 Y56.964
G1 X108.534 Y43.917 E.56694
G1 X108.001 Y43.917
G1 X95.487 Y56.431 E.54377
G1 X95.487 Y55.897
G1 X107.467 Y43.917 E.52059
G1 X106.934 Y43.917
G1 X95.487 Y55.364 E.49742
G1 X95.487 Y54.831
G1 X106.401 Y43.917 E.47425
G1 X105.868 Y43.917
G1 X95.487 Y54.298 E.45107
G1 X95.487 Y53.764
G1 X105.334 Y43.917 E.4279
G1 X104.801 Y43.917
G1 X95.487 Y53.231 E.40473
G1 X95.487 Y52.698
G1 X104.268 Y43.917 E.38156
G1 X103.734 Y43.917
G1 X95.487 Y52.165 E.35838
G1 X95.487 Y51.631
G1 X103.201 Y43.917 E.33521
G1 X102.668 Y43.917
G1 X95.487 Y51.098 E.31204
G1 X95.487 Y50.565
G1 X102.135 Y43.917 E.28887
G1 X101.601 Y43.917
G1 X95.487 Y50.032 E.26569
G1 X95.487 Y49.498
G1 X101.068 Y43.917 E.24252
G1 X100.535 Y43.917
G1 X95.487 Y48.965 E.21935
G1 X95.487 Y48.432
G1 X100.002 Y43.917 E.19618
G1 X99.468 Y43.917
G1 X95.487 Y47.899 E.173
G1 X95.487 Y47.365
G1 X98.935 Y43.917 E.14983
G1 X98.402 Y43.917
G1 X95.487 Y46.832 E.12666
G1 X95.487 Y46.299
G1 X97.869 Y43.917 E.10349
G1 X97.335 Y43.917
G1 X95.487 Y45.766 E.08031
G1 X95.487 Y45.232
G1 X96.802 Y43.917 E.05714
G1 X96.269 Y43.917
G1 X95.487 Y44.699 E.03397
; WIPE_START
M204 S6000
G1 X96.269 Y43.917 E-.42007
G1 X96.802 Y43.917 E-.20264
G1 X96.547 Y44.173 E-.13729
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X98.342 Y51.591 Z2 F42000
G1 X136.567 Y209.578 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.225664
G1 F15000
M204 S6000
G3 X136.216 Y209.943 I-4.497 J-3.971 E.00753
G1 X136.072 Y209.929 E.00216
; WIPE_START
G1 X136.216 Y209.943 E-.16945
G1 X136.567 Y209.578 E-.59055
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X134.252 Y206.848 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.20838
G1 F15000
M204 S6000
G1 X134.149 Y206.921 E.0017
; LINE_WIDTH: 0.186726
G1 X134.016 Y207.033 E.00203
; LINE_WIDTH: 0.150622
G1 X133.884 Y207.146 E.00152
G2 X133.683 Y207.349 I18.214 J18.167 E.00251
; LINE_WIDTH: 0.164523
G1 X133.574 Y207.482 E.0017
; LINE_WIDTH: 0.197109
G1 X133.464 Y207.614 E.00215
G1 X133.484 Y207.753 E.00177
; WIPE_START
G1 X133.464 Y207.614 E-.34323
G1 X133.574 Y207.482 E-.41677
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X135.912 Y200.216 Z2 F42000
G1 X158.748 Y129.28 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.199077
G1 F15000
M204 S6000
G1 X158.628 Y129.432 E.00246
; LINE_WIDTH: 0.147071
G1 X158.509 Y129.583 E.00164
G3 X158.254 Y129.848 I-26.106 J-24.881 E.00312
; LINE_WIDTH: 0.146388
G1 X158.121 Y129.961 E.00147
; LINE_WIDTH: 0.175942
G3 X157.976 Y130.084 I-1.3 J-1.395 E.00206
; LINE_WIDTH: 0.203036
G1 X157.857 Y130.165 E.00188
; WIPE_START
G1 X157.976 Y130.084 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X157.315 Y126.69 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.0914045
G1 F15000
M204 S6000
G1 X157.148 Y126.751 E.0007
; WIPE_START
G1 X157.315 Y126.69 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X155.931 Y127.047 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.236148
G1 F15000
M204 S6000
G1 X155.856 Y127.111 E.00154
G2 X155.587 Y127.389 I2.658 J2.842 E.0061
; WIPE_START
G1 X155.856 Y127.111 E-.60646
G1 X155.931 Y127.047 E-.15354
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X157.378 Y130.237 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.128638
G1 F15000
M204 S6000
G1 X157.18 Y130.334 E.00154
; WIPE_START
G1 X157.378 Y130.237 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X153.393 Y123.727 Z2 F42000
G1 X147.406 Y113.95 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.21299
G1 F15000
M204 S6000
G3 X146.828 Y114.528 I-3.034 J-2.456 E.01135
; WIPE_START
G1 X147.246 Y114.142 E-.52834
G1 X147.406 Y113.95 E-.23166
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X147.653 Y112.679 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.0942646
G1 F15000
M204 S6000
G1 X147.596 Y112.839 E.00071
; WIPE_START
G1 X147.653 Y112.679 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X145.051 Y111.401 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.178181
G1 F15000
M204 S6000
G1 X144.932 Y111.386 E.00132
; LINE_WIDTH: 0.19177
G1 X144.91 Y111.384 E.00027
G1 X144.657 Y111.599 E.00403
; LINE_WIDTH: 0.169936
G2 X144.397 Y111.868 I19.626 J19.157 E.00387
; LINE_WIDTH: 0.202126
G1 X144.215 Y112.1 E.00382
; WIPE_START
G1 X144.397 Y111.868 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X143.409 Y104.3 Z2 F42000
G1 X138.277 Y65.001 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.11492
G1 F15000
M204 S6000
G1 X138.396 Y64.933 E.0008
; LINE_WIDTH: 0.0958358
M73 P79 R6
G1 X138.389 Y64.916 E.00008
; LINE_WIDTH: 0.0645855
G1 X138.383 Y64.899 E.00003
; WIPE_START
G1 X138.389 Y64.916 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X131.146 Y67.323 Z2 F42000
G1 X122.849 Y70.08 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.104694
G1 F15000
M204 S6000
G1 X122.741 Y69.971 E.00077
; WIPE_START
G1 X122.849 Y70.08 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X129.693 Y73.459 Z2 F42000
G1 X144.889 Y80.961 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.115632
G1 F15000
M204 S6000
G1 X144.674 Y81.143 E.00167
G2 X144.423 Y81.404 I35.219 J34.163 E.00214
; LINE_WIDTH: 0.138485
G1 X144.315 Y81.542 E.00137
; LINE_WIDTH: 0.192183
G2 X144.197 Y81.692 I1.514 J1.303 E.00232
G1 X144.23 Y81.84 E.00184
; WIPE_START
G1 X144.197 Y81.692 E-.33593
G1 X144.315 Y81.542 E-.42407
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X136.777 Y80.339 Z2 F42000
G1 X97.38 Y74.052 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.0889676
G1 F15000
M204 S6000
G1 X97.353 Y74.061 E.00011
G1 X97.242 Y74.261 E.00086
; WIPE_START
G1 X97.353 Y74.061 E-.67498
G1 X97.38 Y74.052 E-.08502
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.988 Y73.007 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.226901
G1 F15000
M204 S6000
G2 X97.625 Y73.358 I1.647 J2.065 E.00759
; LINE_WIDTH: 0.219252
G1 X97.625 Y73.378 E.00028
; LINE_WIDTH: 0.171794
G1 X97.632 Y73.5 E.00129
; WIPE_START
G1 X97.625 Y73.378 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X100.656 Y75.245 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.200045
G1 F15000
M204 S6000
G1 X100.676 Y75.385 E.00181
; LINE_WIDTH: 0.196074
G1 X100.565 Y75.519 E.00218
; LINE_WIDTH: 0.153243
G1 X100.453 Y75.654 E.00157
G3 X100.19 Y75.914 I-22.8 J-22.825 E.00332
; LINE_WIDTH: 0.168028
G1 X100.07 Y76.011 E.00158
; LINE_WIDTH: 0.19889
G1 X99.95 Y76.108 E.00197
G1 X99.911 Y76.104 E.0005
; LINE_WIDTH: 0.160226
G1 X99.807 Y76.089 E.001
; WIPE_START
G1 X99.911 Y76.104 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X106.217 Y80.403 Z2 F42000
G1 X108.586 Y82.018 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.0908438
G1 F15000
M204 S6000
G2 X108.461 Y82.236 I1.989 J1.288 E.00098
; WIPE_START
G1 X108.586 Y82.018 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X109.198 Y80.994 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.22843
G1 F15000
M204 S6000
G2 X108.784 Y81.4 I1.902 J2.354 E.00879
; WIPE_START
G1 X109.198 Y80.994 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X111.876 Y83.219 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.203744
G1 F15000
M204 S6000
G1 X111.896 Y83.364 E.00193
; LINE_WIDTH: 0.194237
G1 X111.785 Y83.498 E.00214
; LINE_WIDTH: 0.150247
G1 X111.674 Y83.632 E.00152
G3 X111.473 Y83.835 I-18.922 J-18.505 E.00251
; LINE_WIDTH: 0.156346
G1 X111.341 Y83.947 E.00159
; LINE_WIDTH: 0.194214
G3 X111.101 Y84.135 I-1.113 J-1.177 E.00376
; WIPE_START
G1 X111.341 Y83.947 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X111.547 Y91.577 Z2 F42000
G1 X112.126 Y113 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.10143
G1 F15000
M204 S6000
G3 X112.038 Y113.18 I-1.829 J-.78 E.00095
M204 S10000
G1 X112.009 Y113.623 F42000
; LINE_WIDTH: 0.196513
G1 F15000
M204 S6000
G1 X111.943 Y113.721 E.00147
; LINE_WIDTH: 0.166496
G1 X111.871 Y113.827 E.00129
; LINE_WIDTH: 0.134828
G1 X111.757 Y113.964 E.00133
; LINE_WIDTH: 0.103724
G1 X111.644 Y114.101 E.00088
M204 S10000
G1 X111.46 Y114.282 F42000
; LINE_WIDTH: 0.0885996
G1 F15000
M204 S6000
G1 X111.396 Y114.346 E.00034
; LINE_WIDTH: 0.102058
G1 X111.291 Y114.432 E.00065
; LINE_WIDTH: 0.128278
G1 X111.181 Y114.523 E.001
; LINE_WIDTH: 0.160214
G1 X111.064 Y114.603 E.00135
; LINE_WIDTH: 0.195624
G1 X110.947 Y114.684 E.00176
; WIPE_START
G1 X111.064 Y114.603 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X108.546 Y113.201 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.110084
G1 F15000
M204 S6000
G3 X108.466 Y113.042 I1.702 J-.95 E.00098
M204 S10000
G1 X108.627 Y112.361 F42000
; LINE_WIDTH: 0.161823
G1 F15000
M204 S6000
G2 X108.484 Y112.625 I2.663 J1.617 E.00291
; WIPE_START
G1 X108.627 Y112.361 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.188 Y116.458 Z2 F42000
G1 X98.666 Y118.699 Z2
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.118951
G1 F15000
M204 S6000
G2 X98.394 Y118.875 I1.598 J2.773 E.00201
M204 S10000
G1 X99.267 Y118.751 F42000
; LINE_WIDTH: 0.111852
G1 F15000
M204 S6000
G2 X99.103 Y118.672 I-.858 J1.577 E.00102
; WIPE_START
G1 X99.267 Y118.751 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X100.832 Y121.083 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; LINE_WIDTH: 0.141069
G1 F15000
M204 S6000
G1 X100.686 Y121.286 E.002
; LINE_WIDTH: 0.126766
G1 X100.612 Y121.381 E.00082
; LINE_WIDTH: 0.101036
G1 X100.538 Y121.475 E.00057
M204 S10000
G1 X100.037 Y121.974 F42000
; LINE_WIDTH: 0.0947912
G1 F15000
M204 S6000
G1 X99.957 Y122.042 E.00045
; LINE_WIDTH: 0.119366
G1 X99.856 Y122.112 E.00077
; LINE_WIDTH: 0.153745
G1 X99.754 Y122.182 E.00111
; LINE_WIDTH: 0.188125
G1 X99.653 Y122.252 E.00146
; OBJECT_ID: 124
; WIPE_START
G1 X99.754 Y122.182 E-.76
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 80
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G1 X101.105 Y129.694 Z2 F42000
G1 X106.723 Y160.935 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X106.753 Y161.239 E.00941
G3 X105.061 Y159.705 I-1.559 J.019 E.22226
G1 X105.205 Y159.699 E.00442
G3 X106.706 Y160.878 I-.011 J1.559 E.06313
; WIPE_START
M204 S6000
G1 X106.753 Y161.239 E-.13833
G1 X106.73 Y161.549 E-.11797
G1 X106.642 Y161.847 E-.11794
G1 X106.497 Y162.122 E-.11813
G1 X106.3 Y162.362 E-.118
G1 X106.06 Y162.559 E-.11812
G1 X105.986 Y162.598 E-.0315
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.156 Y163.547 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X104.715 Y163.498 E.01362
G3 X105.225 Y158.969 I.474 J-2.24 E.20743
G1 X105.324 Y158.973 E.00305
G3 X105.216 Y163.548 I-.135 J2.286 E.21606
M204 S10000
G1 X105.184 Y163.183 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381161
G1 F15000
M204 S6000
G1 X105.173 Y163.183 E.0003
G3 X103.272 Y161.291 I.024 J-1.924 E.08177
G1 X103.272 Y161.275 E.00046
G3 X103.279 Y161.1 I3.484 J.043 E.00483
G3 X105.555 Y163.15 I1.918 J.159 E.23563
G1 X105.244 Y163.178 E.00861
; OBJECT_ID: 102
; WIPE_START
G1 X105.173 Y163.183 E-.02694
G1 X104.792 Y163.141 E-.14565
G1 X104.427 Y163.023 E-.1457
G1 X104.094 Y162.837 E-.14488
G1 X103.808 Y162.592 E-.14326
G1 X103.567 Y162.283 E-.149
G1 X103.561 Y162.272 E-.00456
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.054 Y154.655 Z2 F42000
G1 X104.067 Y154.458 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X104.097 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22226
G1 X102.549 Y153.222 E.00442
G3 X104.05 Y154.402 I-.011 J1.559 E.06313
; WIPE_START
M204 S6000
G1 X104.097 Y154.763 E-.13833
G1 X104.074 Y155.072 E-.11797
G1 X103.987 Y155.37 E-.11794
G1 X103.841 Y155.645 E-.11813
G1 X103.645 Y155.885 E-.118
G1 X103.404 Y156.082 E-.11812
G1 X103.331 Y156.121 E-.0315
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.5 Y157.07 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X102.06 Y157.021 E.01362
G3 X102.57 Y152.492 I.474 J-2.24 E.20743
G1 X102.669 Y152.496 E.00305
G3 X102.56 Y157.071 I-.135 J2.286 E.21606
M204 S10000
G1 X102.528 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381161
G1 F15000
M204 S6000
G1 X102.517 Y156.706 E.0003
G3 X100.617 Y154.815 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.484 J.043 E.00483
G3 X102.899 Y156.673 I1.918 J.159 E.23563
G1 X102.588 Y156.701 E.00861
; OBJECT_ID: 91
; WIPE_START
G1 X102.517 Y156.706 E-.02694
G1 X102.136 Y156.664 E-.14565
G1 X101.771 Y156.547 E-.1457
G1 X101.439 Y156.36 E-.14488
G1 X101.152 Y156.115 E-.14326
G1 X100.911 Y155.806 E-.149
G1 X100.906 Y155.795 E-.00456
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.179 Z2 F42000
G1 X101.411 Y147.981 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X101.441 Y148.286 E.00941
G3 X99.75 Y146.751 I-1.559 J.019 E.22226
G1 X99.893 Y146.745 E.00442
G3 X101.395 Y147.925 I-.011 J1.559 E.06313
; WIPE_START
M204 S6000
G1 X101.441 Y148.286 E-.13833
G1 X101.419 Y148.596 E-.11797
G1 X101.331 Y148.893 E-.11794
G1 X101.186 Y149.168 E-.11813
G1 X100.989 Y149.409 E-.118
G1 X100.748 Y149.605 E-.11812
G1 X100.675 Y149.644 E-.0315
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.845 Y150.594 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X99.404 Y150.545 E.01362
G3 X99.914 Y146.016 I.474 J-2.24 E.20743
G1 X100.013 Y146.019 E.00305
G3 X99.904 Y150.594 I-.135 J2.286 E.21606
M204 S10000
G1 X99.873 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381161
G1 F15000
M204 S6000
G1 X99.862 Y150.23 E.0003
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.484 J.043 E.00483
G3 X100.243 Y150.196 I1.918 J.159 E.23563
G1 X99.932 Y150.224 E.00861
; OBJECT_ID: 113
; WIPE_START
G1 X99.862 Y150.23 E-.02694
G1 X99.481 Y150.188 E-.14565
G1 X99.116 Y150.07 E-.1457
G1 X98.783 Y149.883 E-.14488
G1 X98.497 Y149.638 E-.14326
G1 X98.255 Y149.329 E-.149
G1 X98.25 Y149.319 E-.00456
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.702 Z2 F42000
G1 X98.756 Y141.504 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F12000
M204 S5000
G1 X98.786 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22226
G1 X97.238 Y140.269 E.00442
G3 X98.739 Y141.448 I-.011 J1.559 E.06313
; WIPE_START
M204 S6000
G1 X98.786 Y141.809 E-.13833
G1 X98.763 Y142.119 E-.11797
G1 X98.675 Y142.417 E-.11794
G1 X98.53 Y142.691 E-.11813
G1 X98.333 Y142.932 E-.118
G1 X98.093 Y143.129 E-.11812
G1 X98.02 Y143.167 E-.0315
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.189 Y144.117 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F12000
M204 S5000
G1 X96.748 Y144.068 E.01362
G3 X97.259 Y139.539 I.474 J-2.24 E.20743
G1 X97.358 Y139.543 E.00305
G3 X97.249 Y144.118 I-.135 J2.286 E.21606
M204 S10000
G1 X97.217 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381161
G1 F15000
M204 S6000
G1 X97.206 Y143.753 E.0003
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.484 J.043 E.00483
G3 X97.588 Y143.719 I1.918 J.159 E.23563
G1 X97.277 Y143.747 E.00861
; CHANGE_LAYER
; Z_HEIGHT: 1.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02694
G1 X96.825 Y143.711 E-.14565
G1 X96.46 Y143.593 E-.1457
G1 X96.128 Y143.407 E-.14488
G1 X95.841 Y143.162 E-.14326
G1 X95.6 Y142.853 E-.149
G1 X95.594 Y142.842 E-.00456
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 9/60
; update layer progress
M73 L9
M991 S0 P8 ;notify layer change
M106 S201.45
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z2 I-1.037 J.638 P1  F42000
G1 X106.723 Y160.935 Z2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.752 Y161.239 E.00941
G3 X105.061 Y159.705 I-1.559 J.019 E.22227
G1 X105.203 Y159.699 E.00438
G3 X106.705 Y160.879 I-.01 J1.559 E.06317
; WIPE_START
G1 F12000
M204 S6000
G1 X106.752 Y161.239 E-.13816
G1 X106.751 Y161.395 E-.05908
G1 X106.693 Y161.7 E-.11803
G1 X106.576 Y161.988 E-.11806
G1 X106.405 Y162.247 E-.11805
G1 X106.185 Y162.467 E-.11814
G1 X105.986 Y162.598 E-.09048
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.158 Y163.547 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.715 Y163.498 E.0137
G3 X105.225 Y158.969 I.473 J-2.24 E.2075
G1 X105.322 Y158.973 E.00298
G3 X105.218 Y163.548 I-.134 J2.286 E.21597
; WIPE_START
G1 F12000
M204 S6000
G1 X104.715 Y163.498 E-.19208
G1 X104.281 Y163.358 E-.17334
G1 X103.883 Y163.135 E-.17326
G1 X103.538 Y162.837 E-.17338
G1 X103.46 Y162.737 E-.04794
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 9 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer9 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.737 Y162.499 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2326
M204 S6000
G1 X103.621 Y162.365 E.00489
G3 X103.272 Y161.291 I1.575 J-1.106 E.03157
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.495 J.043 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.776 Y162.545 E.00396
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.621 Y162.365 E-.09023
G1 X103.432 Y162.029 E-.14635
G1 X103.315 Y161.664 E-.14569
G1 X103.272 Y161.291 E-.14253
G1 X103.272 Y161.274 E-.00638
G1 X103.278 Y161.1 E-.06653
G1 X103.35 Y160.714 E-.14885
G1 X103.364 Y160.682 E-.01343
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.097 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22227
G1 X102.548 Y153.222 E.00438
G3 X104.05 Y154.402 I-.01 J1.559 E.06317
; WIPE_START
G1 F12000
M204 S6000
G1 X104.097 Y154.763 E-.13816
G1 X104.096 Y154.918 E-.05908
G1 X104.038 Y155.223 E-.11803
G1 X103.921 Y155.511 E-.11806
G1 X103.749 Y155.77 E-.11805
G1 X103.529 Y155.99 E-.11814
G1 X103.331 Y156.122 E-.09048
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.503 Y157.071 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.059 Y157.022 E.0137
G3 X102.57 Y152.492 I.473 J-2.24 E.2075
G1 X102.667 Y152.496 E.00298
G3 X102.563 Y157.071 I-.134 J2.286 E.21597
M204 S10000
G1 X102.531 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2326
M204 S6000
G1 X102.517 Y156.706 E.00037
G3 X100.617 Y154.815 I.024 J-1.924 E.08176
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.495 J.043 E.00483
G3 X102.899 Y156.673 I1.918 J.159 E.23561
G1 X102.59 Y156.701 E.00854
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.02789
G1 X102.206 Y156.677 E-.11875
G1 X101.853 Y156.58 E-.13936
G1 X101.517 Y156.412 E-.14244
G1 X101.214 Y156.177 E-.14578
G1 X100.965 Y155.888 E-.14489
G1 X100.913 Y155.794 E-.04088
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.177 Z2.2 F42000
G1 X101.411 Y147.981 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.441 Y148.286 E.00941
G3 X99.75 Y146.751 I-1.559 J.019 E.22227
G1 X99.892 Y146.746 E.00438
G3 X101.394 Y147.925 I-.01 J1.559 E.06317
; WIPE_START
G1 F12000
M204 S6000
G1 X101.441 Y148.286 E-.13816
G1 X101.44 Y148.441 E-.05908
G1 X101.382 Y148.747 E-.11803
G1 X101.265 Y149.034 E-.11806
G1 X101.093 Y149.293 E-.11805
G1 X100.874 Y149.513 E-.11814
G1 X100.675 Y149.645 E-.09048
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.847 Y150.594 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.404 Y150.545 E.0137
G3 X99.914 Y146.016 I.473 J-2.24 E.2075
G1 X100.011 Y146.019 E.00298
G3 X99.907 Y150.594 I-.134 J2.286 E.21597
M204 S10000
G1 X99.875 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2326
M204 S6000
G1 X99.862 Y150.23 E.00037
G3 X97.961 Y148.338 I.024 J-1.924 E.08176
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.495 J.043 E.00483
G3 X100.243 Y150.196 I1.918 J.159 E.23561
G1 X99.935 Y150.224 E.00854
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.02789
G1 X99.55 Y150.201 E-.11875
G1 X99.197 Y150.103 E-.13936
G1 X98.862 Y149.936 E-.14244
G1 X98.559 Y149.7 E-.14578
G1 X98.31 Y149.411 E-.14489
G1 X98.257 Y149.317 E-.04088
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.701 Z2.2 F42000
G1 X98.756 Y141.505 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.785 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22227
G1 X97.237 Y140.269 E.00438
G3 X98.739 Y141.449 I-.01 J1.559 E.06317
; WIPE_START
G1 F12000
M204 S6000
G1 X98.785 Y141.809 E-.13816
G1 X98.784 Y141.965 E-.05908
G1 X98.727 Y142.27 E-.11803
G1 X98.61 Y142.558 E-.11806
G1 X98.438 Y142.817 E-.11805
G1 X98.218 Y143.036 E-.11814
G1 X98.02 Y143.168 E-.09048
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.191 Y144.117 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.748 Y144.068 E.0137
G3 X97.259 Y139.539 I.473 J-2.24 E.2075
G1 X97.356 Y139.543 E.00298
G3 X97.251 Y144.117 I-.134 J2.286 E.21597
M204 S10000
G1 X97.219 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2326
M204 S6000
G1 X97.206 Y143.753 E.00037
G3 X95.305 Y141.861 I.024 J-1.924 E.08176
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.495 J.043 E.00483
G3 X97.588 Y143.719 I1.918 J.159 E.23561
G1 X97.279 Y143.747 E.00854
; CHANGE_LAYER
; Z_HEIGHT: 2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02789
G1 X96.895 Y143.724 E-.11875
G1 X96.541 Y143.626 E-.13936
G1 X96.206 Y143.459 E-.14244
G1 X95.903 Y143.223 E-.14578
G1 X95.654 Y142.935 E-.14489
G1 X95.602 Y142.841 E-.04088
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 10/60
; update layer progress
M73 L10
M991 S0 P9 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z2.2 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z2.2
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.752 Y161.239 E.00941
G3 X105.061 Y159.705 I-1.559 J.019 E.22228
G1 X105.202 Y159.699 E.00435
G3 X106.705 Y160.879 I-.009 J1.559 E.06321
; WIPE_START
G1 F12000
M204 S6000
G1 X106.752 Y161.239 E-.13805
G1 X106.751 Y161.395 E-.05908
G1 X106.693 Y161.7 E-.11805
G1 X106.576 Y161.988 E-.11799
G1 X106.405 Y162.247 E-.1181
G1 X106.185 Y162.467 E-.11812
G1 X105.986 Y162.598 E-.09062
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.16 Y163.548 Z2.4 F42000
G1 Z2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.715 Y163.498 E.01377
G3 X105.225 Y158.969 I.473 J-2.24 E.20755
G1 X105.32 Y158.973 E.00292
G3 X105.22 Y163.548 I-.133 J2.286 E.21591
; WIPE_START
G1 F12000
M204 S6000
G1 X104.715 Y163.498 E-.19296
G1 X104.281 Y163.358 E-.17331
G1 X103.883 Y163.135 E-.17329
G1 X103.538 Y162.837 E-.17329
G1 X103.462 Y162.739 E-.04715
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 10 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer10 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.738 Y162.501 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.005
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.515 J.043 E.00482
G3 X103.872 Y162.655 I1.918 J.159 E.28581
G1 X103.778 Y162.546 E.00396
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09169
G1 X103.432 Y162.029 E-.14565
G1 X103.315 Y161.664 E-.14581
G1 X103.272 Y161.291 E-.14253
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.0665
G1 X103.35 Y160.715 E-.14882
G1 X103.363 Y160.684 E-.01265
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.096 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22228
G1 X102.546 Y153.222 E.00435
G3 X104.05 Y154.402 I-.009 J1.559 E.06321
; WIPE_START
G1 F12000
M204 S6000
G1 X104.096 Y154.763 E-.13805
G1 X104.096 Y154.918 E-.05908
G1 X104.038 Y155.223 E-.11805
G1 X103.921 Y155.511 E-.11799
G1 X103.749 Y155.77 E-.1181
G1 X103.529 Y155.99 E-.11812
G1 X103.33 Y156.122 E-.09062
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.505 Y157.071 Z2.4 F42000
G1 Z2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.059 Y157.022 E.01377
G3 X102.57 Y152.492 I.473 J-2.24 E.20755
G1 X102.665 Y152.496 E.00292
G3 X102.565 Y157.071 I-.133 J2.286 E.21591
M204 S10000
G1 X102.533 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2326
M204 S6000
G1 X102.517 Y156.706 E.00043
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.515 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23561
G1 X102.593 Y156.7 E.00848
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.02873
G1 X102.136 Y156.664 E-.14564
G1 X101.836 Y156.573 E-.11928
G1 X101.517 Y156.412 E-.13565
G1 X101.216 Y156.178 E-.145
G1 X100.964 Y155.887 E-.14631
G1 X100.914 Y155.796 E-.0394
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.179 Z2.4 F42000
G1 X101.411 Y147.981 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.441 Y148.286 E.00941
G3 X99.75 Y146.751 I-1.559 J.019 E.22228
G1 X99.891 Y146.746 E.00435
G3 X101.394 Y147.926 I-.009 J1.559 E.06321
; WIPE_START
G1 F12000
M204 S6000
G1 X101.441 Y148.286 E-.13805
G1 X101.44 Y148.442 E-.05908
G1 X101.382 Y148.747 E-.11805
G1 X101.265 Y149.034 E-.11799
G1 X101.093 Y149.293 E-.1181
G1 X100.874 Y149.513 E-.11812
G1 X100.675 Y149.645 E-.09062
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.849 Y150.594 Z2.4 F42000
G1 Z2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.404 Y150.545 E.01377
G3 X99.914 Y146.016 I.473 J-2.24 E.20755
G1 X100.009 Y146.019 E.00292
G3 X99.909 Y150.594 I-.133 J2.286 E.21591
M204 S10000
G1 X99.877 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2326
M204 S6000
G1 X99.862 Y150.23 E.00043
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.515 J.043 E.00482
G3 X100.243 Y150.196 I1.918 J.159 E.23561
G1 X99.937 Y150.224 E.00848
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.02873
G1 X99.481 Y150.188 E-.14564
G1 X99.18 Y150.096 E-.11928
G1 X98.862 Y149.936 E-.13565
G1 X98.56 Y149.702 E-.145
G1 X98.309 Y149.41 E-.14631
G1 X98.258 Y149.319 E-.0394
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.702 Z2.4 F42000
G1 X98.756 Y141.505 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.785 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22228
G1 X97.235 Y140.269 E.00435
G3 X98.738 Y141.449 I-.009 J1.559 E.06321
; WIPE_START
G1 F12000
M204 S6000
G1 X98.785 Y141.809 E-.13805
G1 X98.784 Y141.965 E-.05908
G1 X98.727 Y142.27 E-.11805
G1 X98.61 Y142.558 E-.11799
G1 X98.438 Y142.817 E-.1181
G1 X98.218 Y143.036 E-.11812
G1 X98.019 Y143.168 E-.09062
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.194 Y144.118 Z2.4 F42000
G1 Z2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.748 Y144.068 E.01377
M73 P80 R6
G3 X97.259 Y139.539 I.473 J-2.24 E.20755
G1 X97.354 Y139.543 E.00292
G3 X97.254 Y144.117 I-.133 J2.286 E.21591
M204 S10000
G1 X97.222 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2326
M204 S6000
G1 X97.206 Y143.753 E.00043
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.515 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23561
G1 X97.281 Y143.747 E.00848
; CHANGE_LAYER
; Z_HEIGHT: 2.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02873
G1 X96.825 Y143.711 E-.14564
G1 X96.525 Y143.619 E-.11928
G1 X96.206 Y143.459 E-.13565
G1 X95.905 Y143.225 E-.145
G1 X95.653 Y142.933 E-.14631
G1 X95.603 Y142.843 E-.0394
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 11/60
; update layer progress
M73 L11
M991 S0 P10 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z2.4 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z2.4
G1 Z2.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.752 Y161.239 E.0094
G3 X105.061 Y159.705 I-1.559 J.019 E.22228
G1 X105.201 Y159.699 E.00431
G3 X106.705 Y160.879 I-.008 J1.559 E.06325
; WIPE_START
G1 F12000
M204 S6000
G1 X106.752 Y161.239 E-.13797
G1 X106.751 Y161.395 E-.05908
G1 X106.693 Y161.7 E-.11801
G1 X106.576 Y161.988 E-.11808
G1 X106.405 Y162.247 E-.11803
G1 X106.185 Y162.466 E-.11807
G1 X105.986 Y162.598 E-.09076
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.163 Y163.548 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.715 Y163.499 E.01384
G3 X105.225 Y158.969 I.472 J-2.24 E.2076
G1 X105.318 Y158.973 E.00286
G3 X105.222 Y163.547 I-.132 J2.286 E.21586
; WIPE_START
G1 F12000
M204 S6000
G1 X104.715 Y163.499 E-.19376
G1 X104.281 Y163.358 E-.17331
G1 X103.884 Y163.135 E-.17319
G1 X103.538 Y162.837 E-.17339
G1 X103.463 Y162.741 E-.04636
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 11 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer11 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.74 Y162.502 F42000
G1 Z2.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.00506
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.511 J.043 E.00482
G3 X103.872 Y162.655 I1.918 J.159 E.28581
G1 X103.779 Y162.548 E.0039
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09262
G1 X103.432 Y162.029 E-.14563
G1 X103.315 Y161.664 E-.1456
G1 X103.272 Y161.291 E-.1426
G1 X103.272 Y161.274 E-.00638
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.1489
G1 X103.362 Y160.686 E-.01179
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.096 Y154.763 E.0094
G3 X102.405 Y153.228 I-1.559 J.019 E.22228
G1 X102.545 Y153.222 E.00431
G3 X104.05 Y154.403 I-.008 J1.559 E.06325
; WIPE_START
G1 F12000
M204 S6000
G1 X104.096 Y154.763 E-.13797
G1 X104.096 Y154.918 E-.05908
G1 X104.038 Y155.223 E-.11801
G1 X103.921 Y155.511 E-.11808
G1 X103.749 Y155.77 E-.11803
G1 X103.529 Y155.99 E-.11807
G1 X103.33 Y156.122 E-.09076
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.507 Y157.071 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.059 Y157.022 E.01384
G3 X102.57 Y152.492 I.472 J-2.24 E.2076
G1 X102.663 Y152.496 E.00286
G3 X102.567 Y157.071 I-.132 J2.286 E.21586
M204 S10000
G1 X102.535 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2326
M204 S6000
G1 X102.517 Y156.706 E.00049
G3 X100.617 Y154.815 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.511 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23561
G1 X102.595 Y156.7 E.00842
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.02949
G1 X102.136 Y156.664 E-.1457
G1 X101.848 Y156.578 E-.1143
G1 X101.517 Y156.412 E-.14063
G1 X101.216 Y156.178 E-.14503
G1 X100.964 Y155.886 E-.14637
G1 X100.915 Y155.798 E-.03848
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.181 Z2.6 F42000
G1 X101.411 Y147.981 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.44 Y148.286 E.0094
G3 X99.75 Y146.751 I-1.559 J.019 E.22228
G1 X99.89 Y146.746 E.00431
G3 X101.394 Y147.926 I-.008 J1.559 E.06325
; WIPE_START
G1 F12000
M204 S6000
G1 X101.44 Y148.286 E-.13797
G1 X101.44 Y148.442 E-.05908
G1 X101.382 Y148.747 E-.11801
G1 X101.265 Y149.034 E-.11808
G1 X101.093 Y149.293 E-.11803
G1 X100.874 Y149.513 E-.11807
G1 X100.675 Y149.645 E-.09076
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.851 Y150.595 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.404 Y150.545 E.01384
G3 X99.914 Y146.016 I.472 J-2.24 E.2076
G1 X100.007 Y146.019 E.00286
G3 X99.911 Y150.594 I-.132 J2.286 E.21586
M204 S10000
G1 X99.879 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2326
M204 S6000
G1 X99.862 Y150.23 E.00049
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.511 J.043 E.00482
G3 X100.243 Y150.196 I1.918 J.159 E.23561
G1 X99.939 Y150.223 E.00842
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.02949
G1 X99.481 Y150.187 E-.1457
G1 X99.192 Y150.101 E-.1143
G1 X98.861 Y149.936 E-.14063
G1 X98.56 Y149.701 E-.14503
G1 X98.309 Y149.41 E-.14637
G1 X98.259 Y149.321 E-.03848
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.704 Z2.6 F42000
G1 X98.756 Y141.505 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.785 Y141.809 E.0094
G3 X97.094 Y140.274 I-1.559 J.019 E.22228
G1 X97.234 Y140.269 E.00431
G3 X98.738 Y141.449 I-.008 J1.559 E.06325
; WIPE_START
G1 F12000
M204 S6000
G1 X98.785 Y141.809 E-.13797
G1 X98.784 Y141.965 E-.05908
G1 X98.727 Y142.27 E-.11801
G1 X98.61 Y142.558 E-.11808
G1 X98.438 Y142.817 E-.11803
G1 X98.218 Y143.036 E-.11807
G1 X98.019 Y143.168 E-.09076
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.196 Y144.118 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.748 Y144.068 E.01384
G3 X97.259 Y139.539 I.472 J-2.24 E.2076
G1 X97.352 Y139.542 E.00286
G3 X97.256 Y144.117 I-.132 J2.286 E.21586
M204 S10000
G1 X97.224 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2326
M204 S6000
G1 X97.206 Y143.753 E.00049
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.511 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23561
G1 X97.283 Y143.747 E.00842
; CHANGE_LAYER
; Z_HEIGHT: 2.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02949
G1 X96.825 Y143.711 E-.1457
G1 X96.537 Y143.624 E-.1143
G1 X96.206 Y143.459 E-.14063
G1 X95.904 Y143.225 E-.14503
G1 X95.653 Y142.933 E-.14637
G1 X95.604 Y142.845 E-.03848
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 12/60
; update layer progress
M73 L12
M991 S0 P11 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z2.6 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z2.6
G1 Z2.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.752 Y161.239 E.00941
G3 X105.061 Y159.705 I-1.559 J.019 E.22229
G1 X105.2 Y159.699 E.00427
G3 X106.705 Y160.879 I-.007 J1.559 E.06328
; WIPE_START
G1 F12000
M204 S6000
G1 X106.752 Y161.239 E-.13795
G1 X106.73 Y161.549 E-.11791
G1 X106.642 Y161.847 E-.11807
G1 X106.497 Y162.122 E-.11799
G1 X106.404 Y162.247 E-.05919
G1 X106.185 Y162.466 E-.11802
G1 X105.986 Y162.599 E-.09088
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.165 Y163.548 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.715 Y163.499 E.0139
G3 X105.225 Y158.969 I.47 J-2.241 E.20767
G1 X105.316 Y158.972 E.0028
G3 X105.225 Y163.547 I-.131 J2.286 E.21579
; WIPE_START
G1 F12000
M204 S6000
G1 X104.715 Y163.499 E-.19443
G1 X104.281 Y163.358 E-.17338
G1 X103.883 Y163.135 E-.17333
G1 X103.538 Y162.837 E-.17331
G1 X103.464 Y162.743 E-.04555
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 12 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer12 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.741 Y162.504 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.00511
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.517 J.044 E.00483
G3 X103.872 Y162.655 I1.918 J.159 E.2858
G1 X103.78 Y162.549 E.00384
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.0933
G1 X103.432 Y162.029 E-.14575
G1 X103.315 Y161.664 E-.14571
G1 X103.272 Y161.291 E-.14251
G1 X103.272 Y161.274 E-.00637
G1 X103.279 Y161.099 E-.06656
G1 X103.35 Y160.714 E-.14883
G1 X103.361 Y160.688 E-.01096
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.096 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22229
G1 X102.544 Y153.222 E.00427
G3 X104.049 Y154.403 I-.007 J1.559 E.06328
; WIPE_START
G1 F12000
M204 S6000
G1 X104.096 Y154.763 E-.13795
G1 X104.074 Y155.072 E-.11791
G1 X103.986 Y155.37 E-.11807
G1 X103.841 Y155.645 E-.11799
G1 X103.749 Y155.77 E-.05919
G1 X103.529 Y155.99 E-.11802
G1 X103.33 Y156.122 E-.09088
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.509 Y157.071 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.06 Y157.022 E.0139
G3 X102.57 Y152.492 I.47 J-2.241 E.20767
G1 X102.661 Y152.496 E.0028
G3 X102.569 Y157.071 I-.131 J2.286 E.21579
M204 S10000
G1 X102.537 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2326
M204 S6000
G1 X102.517 Y156.706 E.00054
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.517 J.044 E.00483
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.597 Y156.7 E.00837
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.0303
G1 X102.202 Y156.677 E-.12029
G1 X101.861 Y156.583 E-.13454
G1 X101.517 Y156.412 E-.14578
G1 X101.216 Y156.178 E-.14497
G1 X100.964 Y155.887 E-.1463
G1 X100.916 Y155.8 E-.0378
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.399 Y148.183 Z2.8 F42000
G1 X101.411 Y147.981 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.44 Y148.286 E.00941
G3 X99.75 Y146.751 I-1.559 J.019 E.22229
G1 X99.888 Y146.746 E.00427
G3 X101.394 Y147.926 I-.007 J1.559 E.06328
; WIPE_START
G1 F12000
M204 S6000
G1 X101.44 Y148.286 E-.13795
G1 X101.419 Y148.596 E-.11791
G1 X101.331 Y148.894 E-.11807
G1 X101.186 Y149.168 E-.11799
G1 X101.093 Y149.293 E-.05919
G1 X100.874 Y149.513 E-.11802
G1 X100.674 Y149.645 E-.09088
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.854 Y150.595 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.404 Y150.545 E.0139
G3 X99.914 Y146.016 I.47 J-2.241 E.20767
G1 X100.005 Y146.019 E.0028
G3 X99.913 Y150.594 I-.131 J2.286 E.21579
M204 S10000
G1 X99.881 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2326
M204 S6000
G1 X99.862 Y150.23 E.00054
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.517 J.044 E.00483
G3 X100.243 Y150.196 I1.918 J.159 E.2356
G1 X99.941 Y150.223 E.00837
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.0303
G1 X99.546 Y150.2 E-.12029
G1 X99.205 Y150.106 E-.13454
G1 X98.861 Y149.936 E-.14578
G1 X98.56 Y149.702 E-.14497
G1 X98.309 Y149.41 E-.1463
G1 X98.26 Y149.323 E-.0378
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.706 Z2.8 F42000
G1 X98.756 Y141.505 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.785 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22229
G1 X97.233 Y140.269 E.00427
G3 X98.738 Y141.449 I-.007 J1.559 E.06328
; WIPE_START
G1 F12000
M204 S6000
G1 X98.785 Y141.809 E-.13795
G1 X98.763 Y142.119 E-.11791
G1 X98.675 Y142.417 E-.11807
G1 X98.53 Y142.691 E-.11799
G1 X98.438 Y142.817 E-.05919
G1 X98.218 Y143.036 E-.11802
G1 X98.019 Y143.169 E-.09088
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.198 Y144.118 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.748 Y144.069 E.0139
G3 X97.259 Y139.539 I.47 J-2.241 E.20767
G1 X97.35 Y139.542 E.0028
G3 X97.258 Y144.117 I-.131 J2.286 E.21579
M204 S10000
G1 X97.226 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2326
M204 S6000
G1 X97.206 Y143.753 E.00054
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.517 J.044 E.00483
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.286 Y143.747 E.00837
; CHANGE_LAYER
; Z_HEIGHT: 2.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.0303
G1 X96.891 Y143.723 E-.12029
G1 X96.549 Y143.63 E-.13454
G1 X96.206 Y143.459 E-.14578
G1 X95.905 Y143.225 E-.14497
G1 X95.653 Y142.933 E-.1463
G1 X95.605 Y142.846 E-.0378
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 13/60
; update layer progress
M73 L13
M991 S0 P12 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z2.8 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z2.8
G1 Z2.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X106.751 Y161.239 E.00941
G3 X105.061 Y159.705 I-1.559 J.019 E.22229
G1 X105.198 Y159.699 E.00424
G3 X106.705 Y160.88 I-.006 J1.559 E.06332
; WIPE_START
G1 F12000
M204 S6000
G1 X106.751 Y161.239 E-.13789
G1 X106.73 Y161.549 E-.1179
G1 X106.642 Y161.847 E-.11804
G1 X106.497 Y162.122 E-.11807
G1 X106.3 Y162.362 E-.118
G1 X106.06 Y162.559 E-.11807
G1 X105.987 Y162.602 E-.03202
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.167 Y163.548 Z3 F42000
G1 Z2.6
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X104.716 Y163.496 E.01396
G3 X105.111 Y158.971 I.476 J-2.238 E.20371
G3 X105.314 Y158.972 I.082 J2.04 E.00625
G3 X105.225 Y163.546 I-.123 J2.285 E.21608
; WIPE_START
G1 F12000
M204 S6000
G1 X104.716 Y163.496 E-.19459
G1 X104.387 Y163.401 E-.12998
G1 X103.978 Y163.198 E-.17336
G1 X103.619 Y162.918 E-.17315
G1 X103.465 Y162.741 E-.08891
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 13 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer13 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.751 Y162.519 F42000
G1 Z2.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2325
M204 S6000
G1 X103.566 Y162.281 E.0083
G3 X103.272 Y161.291 I1.631 J-1.022 E.0288
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.514 J.043 E.00483
G3 X103.808 Y162.592 I1.918 J.159 E.28827
G1 X103.788 Y162.566 E.0009
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.566 Y162.281 E-.13728
G1 X103.408 Y161.968 E-.13321
G1 X103.315 Y161.663 E-.12099
G1 X103.272 Y161.291 E-.14239
G1 X103.272 Y161.274 E-.00637
G1 X103.279 Y161.099 E-.06655
G1 X103.35 Y160.714 E-.14884
G1 X103.355 Y160.704 E-.00438
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z3 F42000
G1 Z2.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X104.096 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22229
G1 X102.543 Y153.222 E.00424
G3 X104.049 Y154.403 I-.006 J1.559 E.06332
; WIPE_START
G1 F12000
M204 S6000
G1 X104.096 Y154.763 E-.13789
G1 X104.074 Y155.072 E-.1179
G1 X103.986 Y155.37 E-.11804
G1 X103.841 Y155.645 E-.11807
G1 X103.645 Y155.885 E-.118
G1 X103.404 Y156.082 E-.11807
G1 X103.332 Y156.125 E-.03202
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.511 Y157.072 Z3 F42000
G1 Z2.6
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X102.06 Y157.019 E.01396
G3 X102.455 Y152.494 I.476 J-2.238 E.20371
G3 X102.659 Y152.496 I.082 J2.04 E.00625
G3 X102.57 Y157.069 I-.123 J2.285 E.21608
M204 S10000
G1 X102.538 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
M73 P81 R6
G1 F2325
M204 S6000
G1 X102.517 Y156.706 E.00057
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.514 J.043 E.00483
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.598 Y156.7 E.00835
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03059
G1 X102.136 Y156.664 E-.14564
G1 X101.771 Y156.547 E-.1457
G1 X101.437 Y156.359 E-.14566
G1 X101.152 Y156.115 E-.14252
G1 X100.91 Y155.804 E-.14976
G1 X100.91 Y155.804 E-.00013
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.187 Z3 F42000
G1 X101.411 Y147.981 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X101.44 Y148.286 E.00941
G3 X99.749 Y146.751 I-1.559 J.019 E.22229
G1 X99.887 Y146.746 E.00424
G3 X101.394 Y147.926 I-.006 J1.559 E.06332
; WIPE_START
G1 F12000
M204 S6000
G1 X101.44 Y148.286 E-.13789
G1 X101.419 Y148.596 E-.1179
G1 X101.331 Y148.894 E-.11804
G1 X101.186 Y149.168 E-.11807
G1 X100.989 Y149.409 E-.118
G1 X100.749 Y149.605 E-.11807
G1 X100.676 Y149.648 E-.03202
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.856 Y150.595 Z3 F42000
G1 Z2.6
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X99.404 Y150.542 E.01396
G3 X99.8 Y146.017 I.476 J-2.238 E.20371
G3 X100.003 Y146.019 I.082 J2.04 E.00625
G3 X99.914 Y150.592 I-.123 J2.285 E.21608
M204 S10000
G1 X99.882 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2325
M204 S6000
G1 X99.862 Y150.23 E.00057
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.514 J.043 E.00483
G3 X100.244 Y150.196 I1.918 J.159 E.2356
G1 X99.942 Y150.223 E.00835
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03059
G1 X99.481 Y150.188 E-.14564
G1 X99.116 Y150.07 E-.1457
G1 X98.781 Y149.882 E-.14566
G1 X98.497 Y149.638 E-.14252
G1 X98.254 Y149.328 E-.14976
G1 X98.254 Y149.327 E-.00013
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.71 Z3 F42000
G1 X98.756 Y141.505 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X98.785 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22229
G1 X97.232 Y140.269 E.00424
G3 X98.738 Y141.449 I-.006 J1.559 E.06332
; WIPE_START
G1 F12000
M204 S6000
G1 X98.785 Y141.809 E-.13789
G1 X98.763 Y142.119 E-.1179
G1 X98.675 Y142.417 E-.11804
G1 X98.53 Y142.692 E-.11807
G1 X98.333 Y142.932 E-.118
G1 X98.093 Y143.129 E-.11807
G1 X98.021 Y143.172 E-.03202
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.2 Y144.118 Z3 F42000
G1 Z2.6
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X96.749 Y144.066 E.01396
G3 X97.144 Y139.54 I.476 J-2.238 E.20371
G3 X97.348 Y139.542 I.082 J2.04 E.00625
G3 X97.258 Y144.115 I-.123 J2.285 E.21608
M204 S10000
G1 X97.227 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2325
M204 S6000
G1 X97.206 Y143.753 E.00057
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.514 J.043 E.00483
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.286 Y143.747 E.00835
; CHANGE_LAYER
; Z_HEIGHT: 2.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03059
G1 X96.825 Y143.711 E-.14564
G1 X96.46 Y143.593 E-.1457
G1 X96.126 Y143.406 E-.14566
G1 X95.841 Y143.162 E-.14252
G1 X95.599 Y142.851 E-.14976
G1 X95.599 Y142.851 E-.00013
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 14/60
; update layer progress
M73 L14
M991 S0 P13 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z3 I-1.037 J.638 P1  F42000
G1 X106.723 Y160.935 Z3
G1 Z2.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.751 Y161.239 E.0094
G3 X105.061 Y159.705 I-1.559 J.019 E.2223
G1 X105.197 Y159.699 E.0042
G3 X106.705 Y160.88 I-.005 J1.559 E.06336
; WIPE_START
G1 F12000
M204 S6000
G1 X106.751 Y161.239 E-.13772
G1 X106.73 Y161.549 E-.11792
G1 X106.642 Y161.847 E-.11799
G1 X106.576 Y161.988 E-.05907
G1 X106.404 Y162.247 E-.11815
G1 X106.185 Y162.466 E-.11802
G1 X105.985 Y162.599 E-.09112
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.17 Y163.548 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.546 E.0001
G3 X105.111 Y158.971 I.023 J-2.288 E.21775
G3 X105.313 Y158.972 I.082 J2.022 E.00619
G3 X105.622 Y163.505 I-.122 J2.285 E.20384
G1 X105.23 Y163.543 E.01211
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.546 E-.0233
G1 X104.827 Y163.519 E-.12999
G1 X104.387 Y163.401 E-.17322
G1 X103.978 Y163.198 E-.17341
G1 X103.619 Y162.918 E-.17317
G1 X103.469 Y162.745 E-.08691
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 14 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer14 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.736 Y162.516 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2316
M204 S6000
G3 X103.285 Y161.483 I1.461 J-1.253 E.03154
G1 X103.272 Y161.274 E.00575
G3 X103.776 Y162.561 I1.924 J-.011 E.29428
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.518 Y162.201 E-.16839
G1 X103.364 Y161.849 E-.14562
G1 X103.285 Y161.483 E-.14258
G1 X103.272 Y161.274 E-.07926
G1 X103.305 Y160.901 E-.14245
G1 X103.366 Y160.695 E-.08172
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.095 Y154.763 E.0094
G3 X102.405 Y153.228 I-1.559 J.019 E.2223
G1 X102.542 Y153.222 E.0042
G3 X104.049 Y154.403 I-.005 J1.559 E.06336
; WIPE_START
G1 F12000
M204 S6000
G1 X104.095 Y154.763 E-.13772
G1 X104.074 Y155.072 E-.11792
G1 X103.986 Y155.37 E-.11799
G1 X103.921 Y155.511 E-.05907
G1 X103.749 Y155.77 E-.11815
G1 X103.529 Y155.99 E-.11802
G1 X103.329 Y156.122 E-.09112
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.514 Y157.072 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.069 E.0001
G3 X102.455 Y152.494 I.023 J-2.288 E.21775
G3 X102.657 Y152.496 I.082 J2.022 E.00619
G3 X102.966 Y157.028 I-.122 J2.285 E.20384
G1 X102.574 Y157.066 E.01211
M204 S10000
G1 X102.578 Y156.699 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2316
M204 S6000
G1 X102.337 Y156.7 E.00664
G3 X100.629 Y155.006 I.204 J-1.913 E.07161
G1 X100.617 Y154.798 E.00575
G3 X102.71 Y156.704 I1.924 J-.011 E.24556
G1 X102.638 Y156.701 E.00198
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.337 Y156.7 E-.11427
G1 X102.034 Y156.639 E-.11728
G1 X101.685 Y156.506 E-.14225
G1 X101.36 Y156.302 E-.14568
G1 X101.082 Y156.038 E-.1457
G1 X100.939 Y155.834 E-.09481
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.215 Z3.2 F42000
G1 X101.411 Y147.981 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.44 Y148.286 E.0094
G3 X99.749 Y146.751 I-1.559 J.019 E.2223
G1 X99.886 Y146.746 E.0042
G3 X101.393 Y147.927 I-.005 J1.559 E.06336
; WIPE_START
G1 F12000
M204 S6000
G1 X101.44 Y148.286 E-.13772
G1 X101.419 Y148.596 E-.11792
G1 X101.331 Y148.893 E-.11799
G1 X101.265 Y149.034 E-.05907
G1 X101.093 Y149.293 E-.11815
G1 X100.874 Y149.513 E-.11802
G1 X100.674 Y149.646 E-.09112
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.859 Y150.595 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.592 E.0001
G3 X99.8 Y146.017 I.023 J-2.288 E.21775
G3 X100.001 Y146.019 I.082 J2.022 E.00619
G3 X100.311 Y150.552 I-.122 J2.285 E.20384
G1 X99.918 Y150.589 E.01211
M204 S10000
G1 X99.922 Y150.222 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2316
M204 S6000
G1 X99.681 Y150.223 E.00664
G3 X97.974 Y148.529 I.204 J-1.913 E.07161
G1 X97.961 Y148.321 E.00575
G3 X100.054 Y150.227 I1.924 J-.011 E.24556
G1 X99.982 Y150.224 E.00198
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.681 Y150.223 E-.11427
G1 X99.379 Y150.162 E-.11728
G1 X99.029 Y150.029 E-.14225
G1 X98.704 Y149.825 E-.14568
G1 X98.426 Y149.561 E-.1457
G1 X98.283 Y149.357 E-.09481
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.738 Z3.2 F42000
G1 X98.756 Y141.505 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.784 Y141.809 E.0094
G3 X97.094 Y140.274 I-1.559 J.019 E.2223
G1 X97.23 Y140.269 E.0042
G3 X98.738 Y141.45 I-.005 J1.559 E.06336
; WIPE_START
G1 F12000
M204 S6000
G1 X98.784 Y141.809 E-.13772
G1 X98.763 Y142.119 E-.11792
G1 X98.675 Y142.417 E-.11799
G1 X98.61 Y142.558 E-.05907
G1 X98.438 Y142.817 E-.11815
G1 X98.218 Y143.036 E-.11802
G1 X98.018 Y143.169 E-.09112
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.203 Y144.118 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.116 E.0001
G3 X97.144 Y139.54 I.023 J-2.288 E.21775
G3 X97.346 Y139.542 I.082 J2.022 E.00619
G3 X97.655 Y144.075 I-.122 J2.285 E.20384
G1 X97.263 Y144.113 E.01211
M204 S10000
G1 X97.267 Y143.745 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2316
M204 S6000
G1 X97.026 Y143.747 E.00664
G3 X95.318 Y142.052 I.204 J-1.913 E.07161
G1 X95.306 Y141.844 E.00575
G3 X97.398 Y143.75 I1.924 J-.011 E.24556
G1 X97.326 Y143.747 E.00198
; CHANGE_LAYER
; Z_HEIGHT: 3
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.026 Y143.747 E-.11427
G1 X96.723 Y143.686 E-.11728
G1 X96.373 Y143.553 E-.14225
G1 X96.049 Y143.349 E-.14568
G1 X95.771 Y143.084 E-.1457
G1 X95.628 Y142.88 E-.09481
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 15/60
; update layer progress
M73 L15
M991 S0 P14 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z3.2 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z3.2
G1 Z3
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X106.751 Y161.239 E.0094
G3 X105.061 Y159.705 I-1.559 J.019 E.2223
G1 X105.196 Y159.699 E.00417
G3 X106.704 Y160.88 I-.004 J1.559 E.06339
; WIPE_START
M73 P81 R5
G1 F12000
M204 S6000
G1 X106.751 Y161.239 E-.13766
G1 X106.73 Y161.549 E-.11787
G1 X106.642 Y161.847 E-.11799
G1 X106.576 Y161.988 E-.0592
G1 X106.404 Y162.247 E-.11806
G1 X106.185 Y162.467 E-.11809
G1 X105.985 Y162.599 E-.09113
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.172 Y163.548 Z3.4 F42000
G1 Z3
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X105.168 Y163.546 E.00013
G3 X105.111 Y158.971 I.022 J-2.288 E.21777
G3 X105.311 Y158.972 I.082 J2.004 E.00613
G3 X105.509 Y163.524 I-.12 J2.285 E.20739
G1 X105.231 Y163.544 E.00856
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.546 E-.02393
G1 X104.827 Y163.519 E-.12997
G1 X104.387 Y163.401 E-.17327
G1 X103.979 Y163.198 E-.17333
G1 X103.619 Y162.918 E-.17323
G1 X103.47 Y162.746 E-.08626
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 15 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer15 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.746 Y162.508 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2315
M204 S6000
G1 X103.62 Y162.363 E.0053
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.502 J.043 E.00483
G3 X103.872 Y162.655 I1.918 J.159 E.2858
G1 X103.785 Y162.554 E.00365
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09587
G1 X103.433 Y162.028 E-.14568
G1 X103.315 Y161.664 E-.14566
G1 X103.272 Y161.291 E-.14258
G1 X103.272 Y161.274 E-.00637
G1 X103.279 Y161.099 E-.06655
G1 X103.35 Y160.715 E-.14872
G1 X103.359 Y160.694 E-.00859
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z3.4 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X104.095 Y154.763 E.0094
G3 X102.405 Y153.228 I-1.559 J.019 E.2223
G1 X102.54 Y153.222 E.00417
G3 X104.049 Y154.403 I-.004 J1.559 E.06339
; WIPE_START
G1 F12000
M204 S6000
G1 X104.095 Y154.763 E-.13766
G1 X104.074 Y155.072 E-.11787
G1 X103.987 Y155.37 E-.11799
G1 X103.921 Y155.511 E-.0592
G1 X103.749 Y155.77 E-.11806
G1 X103.529 Y155.99 E-.11809
G1 X103.329 Y156.122 E-.09113
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.516 Y157.072 Z3.4 F42000
G1 Z3
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X102.513 Y157.069 E.00013
G3 X102.455 Y152.494 I.022 J-2.288 E.21777
G3 X102.655 Y152.496 I.082 J2.004 E.00613
G3 X102.854 Y157.047 I-.12 J2.285 E.20739
G1 X102.576 Y157.067 E.00856
M204 S10000
G1 X102.544 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2315
M204 S6000
G1 X102.517 Y156.706 E.00074
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.502 J.043 E.00483
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.604 Y156.699 E.00817
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03298
G1 X102.137 Y156.664 E-.14553
G1 X101.771 Y156.547 E-.14586
G1 X101.437 Y156.359 E-.14574
G1 X101.216 Y156.177 E-.10849
G1 X100.965 Y155.886 E-.14619
G1 X100.92 Y155.805 E-.03521
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.188 Z3.4 F42000
G1 X101.411 Y147.981 Z3.4
G1 Z3
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X101.44 Y148.286 E.0094
G3 X99.749 Y146.751 I-1.559 J.019 E.2223
G1 X99.885 Y146.746 E.00417
G3 X101.393 Y147.927 I-.004 J1.559 E.06339
; WIPE_START
G1 F12000
M204 S6000
G1 X101.44 Y148.286 E-.13766
G1 X101.419 Y148.596 E-.11787
G1 X101.331 Y148.893 E-.11799
G1 X101.265 Y149.035 E-.0592
G1 X101.093 Y149.293 E-.11806
G1 X100.874 Y149.513 E-.11809
G1 X100.674 Y149.646 E-.09113
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.86 Y150.595 Z3.4 F42000
G1 Z3
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X99.857 Y150.592 E.00013
G3 X99.8 Y146.017 I.022 J-2.288 E.21777
G3 X99.999 Y146.019 I.082 J2.004 E.00613
G3 X100.198 Y150.57 I-.12 J2.285 E.20739
G1 X99.92 Y150.591 E.00856
M204 S10000
G1 X99.888 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2315
M204 S6000
G1 X99.862 Y150.23 E.00074
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.502 J.043 E.00483
G3 X100.244 Y150.196 I1.918 J.159 E.2356
G1 X99.948 Y150.223 E.00817
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03298
G1 X99.481 Y150.188 E-.14553
G1 X99.116 Y150.07 E-.14586
G1 X98.781 Y149.882 E-.14574
G1 X98.561 Y149.701 E-.10849
G1 X98.31 Y149.409 E-.14619
G1 X98.264 Y149.328 E-.03521
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.711 Z3.4 F42000
G1 X98.756 Y141.505 Z3.4
G1 Z3
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X98.784 Y141.809 E.0094
G3 X97.094 Y140.274 I-1.559 J.019 E.2223
G1 X97.229 Y140.269 E.00417
G3 X98.738 Y141.45 I-.004 J1.559 E.06339
; WIPE_START
G1 F12000
M204 S6000
G1 X98.784 Y141.809 E-.13766
G1 X98.763 Y142.119 E-.11787
G1 X98.675 Y142.417 E-.11799
G1 X98.609 Y142.558 E-.0592
G1 X98.438 Y142.817 E-.11806
G1 X98.218 Y143.036 E-.11809
G1 X98.018 Y143.169 E-.09113
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.205 Y144.118 Z3.4 F42000
G1 Z3
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X97.202 Y144.116 E.00013
G3 X97.144 Y139.54 I.022 J-2.288 E.21777
G3 X97.344 Y139.542 I.082 J2.004 E.00613
G3 X97.542 Y144.093 I-.12 J2.285 E.20739
G1 X97.265 Y144.114 E.00856
M204 S10000
G1 X97.233 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2315
M204 S6000
G1 X97.206 Y143.753 E.00074
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.502 J.043 E.00483
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.293 Y143.746 E.00817
; CHANGE_LAYER
; Z_HEIGHT: 3.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03298
G1 X96.825 Y143.711 E-.14553
G1 X96.46 Y143.593 E-.14586
G1 X96.126 Y143.406 E-.14574
G1 X95.905 Y143.224 E-.10849
G1 X95.654 Y142.933 E-.14619
G1 X95.609 Y142.852 E-.03521
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 16/60
; update layer progress
M73 L16
M991 S0 P15 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z3.4 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z3.4
G1 Z3.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X106.751 Y161.239 E.0094
G3 X105.061 Y159.705 I-1.559 J.019 E.22231
G1 X105.195 Y159.699 E.00413
G3 X106.704 Y160.88 I-.003 J1.559 E.06343
; WIPE_START
G1 F12000
M204 S6000
G1 X106.751 Y161.239 E-.13757
G1 X106.73 Y161.549 E-.11788
G1 X106.642 Y161.847 E-.118
G1 X106.576 Y161.988 E-.05915
G1 X106.405 Y162.247 E-.11804
G1 X106.185 Y162.467 E-.11816
G1 X105.985 Y162.599 E-.09121
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.173 Y163.548 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X105.168 Y163.546 E.00017
G3 X105.111 Y158.971 I.022 J-2.288 E.21779
G3 X105.308 Y158.972 I.082 J1.984 E.00607
G3 X105.622 Y163.505 I-.118 J2.285 E.20393
G1 X105.233 Y163.542 E.012
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.546 E-.02463
G1 X104.827 Y163.519 E-.13
G1 X104.387 Y163.401 E-.17323
G1 X103.979 Y163.198 E-.17334
G1 X103.619 Y162.918 E-.17323
G1 X103.472 Y162.747 E-.08557
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 16 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer16 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.747 Y162.51 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381122
G1 F2315
M204 S6000
G1 X103.62 Y162.363 E.00535
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.519 J.043 E.00482
G3 X103.872 Y162.655 I1.918 J.159 E.28581
G1 X103.786 Y162.556 E.0036
; OBJECT_ID: 102
; WIPE_START
M73 P82 R5
G1 F15000
G1 X103.62 Y162.363 E-.09662
G1 X103.432 Y162.029 E-.14559
G1 X103.315 Y161.664 E-.14571
G1 X103.272 Y161.291 E-.14257
G1 X103.272 Y161.274 E-.00638
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.715 E-.14886
G1 X103.358 Y160.696 E-.00778
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X104.095 Y154.763 E.0094
G3 X102.405 Y153.228 I-1.559 J.019 E.22231
G1 X102.539 Y153.222 E.00413
G3 X104.049 Y154.404 I-.003 J1.559 E.06343
; WIPE_START
G1 F12000
M204 S6000
G1 X104.095 Y154.763 E-.13757
G1 X104.074 Y155.072 E-.11788
G1 X103.986 Y155.37 E-.118
G1 X103.921 Y155.511 E-.05915
G1 X103.749 Y155.77 E-.11804
G1 X103.529 Y155.99 E-.11816
G1 X103.329 Y156.123 E-.09121
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.518 Y157.071 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X102.513 Y157.069 E.00017
G3 X102.456 Y152.494 I.022 J-2.288 E.21779
G3 X102.653 Y152.495 I.082 J1.984 E.00607
G3 X102.966 Y157.028 I-.118 J2.285 E.20393
G1 X102.577 Y157.066 E.012
M204 S10000
G1 X102.546 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381122
G1 F2315
M204 S6000
G1 X102.517 Y156.706 E.00079
G3 X100.617 Y154.815 I.024 J-1.924 E.08176
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.519 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23561
G1 X102.606 Y156.699 E.00812
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03371
G1 X102.136 Y156.664 E-.14572
G1 X101.779 Y156.55 E-.14236
G1 X101.466 Y156.378 E-.13584
G1 X101.216 Y156.178 E-.12169
G1 X100.964 Y155.886 E-.14633
G1 X100.92 Y155.808 E-.03435
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.19 Z3.6 F42000
G1 X101.411 Y147.981 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X101.439 Y148.286 E.0094
G3 X99.749 Y146.751 I-1.559 J.019 E.22231
G1 X99.884 Y146.746 E.00413
G3 X101.393 Y147.927 I-.003 J1.559 E.06343
; WIPE_START
G1 F12000
M204 S6000
G1 X101.439 Y148.286 E-.13757
G1 X101.419 Y148.596 E-.11788
G1 X101.331 Y148.893 E-.118
G1 X101.265 Y149.034 E-.05915
G1 X101.093 Y149.293 E-.11804
G1 X100.873 Y149.513 E-.11816
G1 X100.673 Y149.646 E-.09121
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.862 Y150.595 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X99.857 Y150.592 E.00017
G3 X99.8 Y146.017 I.022 J-2.288 E.21779
G3 X99.997 Y146.019 I.082 J1.984 E.00607
G3 X100.311 Y150.551 I-.118 J2.285 E.20393
G1 X99.922 Y150.589 E.012
M204 S10000
G1 X99.89 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381122
G1 F2315
M204 S6000
G1 X99.862 Y150.23 E.00079
G3 X97.961 Y148.338 I.024 J-1.924 E.08176
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.519 J.043 E.00482
G3 X100.243 Y150.196 I1.918 J.159 E.23561
G1 X99.95 Y150.223 E.00812
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03371
G1 X99.48 Y150.187 E-.14572
G1 X99.124 Y150.073 E-.14236
G1 X98.81 Y149.901 E-.13584
G1 X98.56 Y149.701 E-.12169
G1 X98.309 Y149.41 E-.14633
G1 X98.264 Y149.331 E-.03435
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.713 Z3.6 F42000
G1 X98.756 Y141.505 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X98.784 Y141.809 E.0094
G3 X97.094 Y140.274 I-1.559 J.019 E.22231
G1 X97.228 Y140.269 E.00413
G3 X98.737 Y141.45 I-.003 J1.559 E.06343
; WIPE_START
G1 F12000
M204 S6000
G1 X98.784 Y141.809 E-.13757
G1 X98.763 Y142.119 E-.11788
G1 X98.675 Y142.417 E-.118
G1 X98.61 Y142.558 E-.05915
G1 X98.438 Y142.817 E-.11804
G1 X98.218 Y143.036 E-.11816
G1 X98.018 Y143.169 E-.09121
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.207 Y144.118 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X97.202 Y144.116 E.00017
G3 X97.144 Y139.54 I.022 J-2.288 E.21779
G3 X97.342 Y139.542 I.082 J1.984 E.00607
G3 X97.655 Y144.075 I-.118 J2.285 E.20393
G1 X97.266 Y144.112 E.012
M204 S10000
G1 X97.235 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381122
G1 F2315
M204 S6000
G1 X97.206 Y143.753 E.00079
G3 X95.305 Y141.861 I.024 J-1.924 E.08176
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.519 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23561
G1 X97.294 Y143.746 E.00812
; CHANGE_LAYER
; Z_HEIGHT: 3.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03371
G1 X96.825 Y143.711 E-.14572
G1 X96.468 Y143.596 E-.14236
G1 X96.155 Y143.425 E-.13584
G1 X95.904 Y143.225 E-.12169
G1 X95.653 Y142.933 E-.14633
G1 X95.609 Y142.854 E-.03435
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 17/60
; update layer progress
M73 L17
M991 S0 P16 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z3.6 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z3.6
G1 Z3.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X106.75 Y161.239 E.0094
G3 X105.061 Y159.705 I-1.559 J.019 E.22231
G1 X105.194 Y159.699 E.00409
G3 X106.704 Y160.881 I-.002 J1.559 E.06346
; WIPE_START
G1 F12000
M204 S6000
G1 X106.75 Y161.239 E-.13751
G1 X106.73 Y161.549 E-.1179
G1 X106.642 Y161.847 E-.11797
G1 X106.497 Y162.122 E-.11813
G1 X106.3 Y162.362 E-.11799
G1 X106.185 Y162.466 E-.05916
G1 X105.985 Y162.599 E-.09135
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.175 Y163.548 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X105.168 Y163.546 E.00021
G3 X105.111 Y158.971 I.022 J-2.288 E.21781
G3 X105.306 Y158.972 I.082 J1.961 E.006
G3 X105.622 Y163.505 I-.117 J2.285 E.20397
G1 X105.235 Y163.542 E.01195
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.546 E-.02523
G1 X104.827 Y163.519 E-.12999
G1 X104.387 Y163.401 E-.17322
G1 X103.979 Y163.198 E-.17336
G1 X103.619 Y162.918 E-.17323
G1 X103.473 Y162.749 E-.08497
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 17 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer17 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.748 Y162.512 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2315
M204 S6000
G1 X103.621 Y162.365 E.00534
G3 X103.272 Y161.291 I1.575 J-1.106 E.03157
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.509 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.787 Y162.557 E.00351
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.621 Y162.365 E-.0965
G1 X103.432 Y162.029 E-.14639
G1 X103.315 Y161.664 E-.14577
G1 X103.272 Y161.291 E-.14248
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.14888
G1 X103.357 Y160.697 E-.00712
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X104.095 Y154.763 E.0094
G3 X102.405 Y153.228 I-1.559 J.019 E.22231
G1 X102.538 Y153.222 E.00409
G3 X104.048 Y154.404 I-.002 J1.559 E.06346
; WIPE_START
G1 F12000
M204 S6000
G1 X104.095 Y154.763 E-.13751
G1 X104.074 Y155.072 E-.1179
G1 X103.987 Y155.37 E-.11797
G1 X103.841 Y155.645 E-.11813
G1 X103.645 Y155.885 E-.11799
G1 X103.529 Y155.99 E-.05916
G1 X103.329 Y156.123 E-.09135
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.519 Y157.071 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X102.513 Y157.069 E.00021
G3 X102.456 Y152.494 I.022 J-2.288 E.21781
G3 X102.651 Y152.495 I.082 J1.961 E.006
G3 X102.966 Y157.028 I-.117 J2.285 E.20397
G1 X102.579 Y157.066 E.01195
M204 S10000
G1 X102.547 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2315
M204 S6000
G1 X102.517 Y156.706 E.00083
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.509 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23561
G1 X102.607 Y156.699 E.00808
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.0343
G1 X102.196 Y156.675 E-.12277
G1 X101.853 Y156.58 E-.1353
G1 X101.517 Y156.412 E-.14256
G1 X101.214 Y156.177 E-.1457
G1 X100.965 Y155.888 E-.14488
G1 X100.921 Y155.809 E-.03449
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.191 Z3.8 F42000
G1 X101.411 Y147.981 Z3.8
G1 Z3.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X101.439 Y148.286 E.0094
G3 X99.749 Y146.751 I-1.559 J.019 E.22231
G1 X99.882 Y146.746 E.00409
G3 X101.393 Y147.927 I-.002 J1.559 E.06346
; WIPE_START
G1 F12000
M204 S6000
G1 X101.439 Y148.286 E-.13751
G1 X101.419 Y148.596 E-.1179
G1 X101.331 Y148.893 E-.11797
G1 X101.186 Y149.168 E-.11813
G1 X100.989 Y149.409 E-.11799
G1 X100.874 Y149.513 E-.05916
G1 X100.673 Y149.646 E-.09135
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.864 Y150.595 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X99.857 Y150.592 E.00021
G3 X99.8 Y146.017 I.022 J-2.288 E.21781
G3 X99.995 Y146.019 I.082 J1.961 E.006
G3 X100.311 Y150.551 I-.117 J2.285 E.20397
G1 X99.923 Y150.589 E.01195
M204 S10000
G1 X99.892 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2315
M204 S6000
G1 X99.862 Y150.23 E.00083
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.509 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.23561
G1 X99.952 Y150.222 E.00808
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.0343
G1 X99.54 Y150.199 E-.12277
G1 X99.197 Y150.103 E-.1353
G1 X98.861 Y149.935 E-.14256
G1 X98.559 Y149.7 E-.1457
G1 X98.31 Y149.411 E-.14488
G1 X98.265 Y149.332 E-.03449
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.715 Z3.8 F42000
G1 X98.756 Y141.505 Z3.8
G1 Z3.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X98.784 Y141.809 E.0094
G3 X97.094 Y140.274 I-1.559 J.019 E.22231
G1 X97.227 Y140.269 E.00409
G3 X98.737 Y141.45 I-.002 J1.559 E.06346
; WIPE_START
G1 F12000
M204 S6000
G1 X98.784 Y141.809 E-.13751
G1 X98.763 Y142.119 E-.1179
G1 X98.675 Y142.417 E-.11797
G1 X98.53 Y142.692 E-.11813
G1 X98.333 Y142.932 E-.11799
G1 X98.218 Y143.036 E-.05916
G1 X98.018 Y143.169 E-.09135
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.208 Y144.118 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X97.202 Y144.116 E.00021
G3 X97.144 Y139.54 I.022 J-2.288 E.21781
G3 X97.34 Y139.542 I.082 J1.961 E.006
G3 X97.655 Y144.075 I-.117 J2.285 E.20397
G1 X97.268 Y144.112 E.01195
M204 S10000
G1 X97.236 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2315
M204 S6000
G1 X97.206 Y143.753 E.00083
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.509 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23561
G1 X97.296 Y143.746 E.00808
; CHANGE_LAYER
; Z_HEIGHT: 3.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.0343
G1 X96.884 Y143.722 E-.12277
G1 X96.541 Y143.626 E-.1353
G1 X96.206 Y143.459 E-.14256
G1 X95.903 Y143.223 E-.1457
G1 X95.654 Y142.935 E-.14488
G1 X95.61 Y142.855 E-.03449
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 18/60
; update layer progress
M73 L18
M991 S0 P17 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z3.8 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z3.8
G1 Z3.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X106.75 Y161.239 E.00941
G3 X105.06 Y159.705 I-1.559 J.019 E.22232
G1 X105.192 Y159.699 E.00406
G3 X106.704 Y160.881 I-.001 J1.559 E.0635
; WIPE_START
G1 F12000
M204 S6000
G1 X106.75 Y161.239 E-.13748
G1 X106.73 Y161.549 E-.11788
G1 X106.642 Y161.847 E-.11802
G1 X106.576 Y161.988 E-.0591
G1 X106.404 Y162.247 E-.11811
G1 X106.185 Y162.466 E-.11804
G1 X105.984 Y162.599 E-.09137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.176 Y163.548 Z4 F42000
G1 Z3.6
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X105.168 Y163.546 E.00025
G3 X105.111 Y158.971 I.021 J-2.288 E.21783
G3 X105.304 Y158.972 I.081 J1.942 E.00594
G3 X105.622 Y163.505 I-.115 J2.285 E.20401
G1 X105.236 Y163.542 E.01192
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.546 E-.02577
G1 X104.828 Y163.519 E-.12993
G1 X104.387 Y163.401 E-.1733
G1 X103.978 Y163.198 E-.17337
G1 X103.619 Y162.918 E-.17322
G1 X103.474 Y162.75 E-.08441
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 18 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer18 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.749 Y162.513 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2315
M204 S6000
G1 X103.621 Y162.364 E.00539
G3 X103.272 Y161.291 I1.575 J-1.106 E.03157
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.509 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.788 Y162.558 E.00347
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.621 Y162.364 E-.09713
G1 X103.432 Y162.029 E-.14636
G1 X103.315 Y161.664 E-.1456
G1 X103.272 Y161.291 E-.1426
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06647
G1 X103.35 Y160.715 E-.14886
G1 X103.357 Y160.698 E-.00661
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X104.095 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22232
G1 X102.537 Y153.222 E.00406
G3 X104.048 Y154.404 I-.001 J1.559 E.0635
; WIPE_START
G1 F12000
M204 S6000
G1 X104.095 Y154.763 E-.13748
G1 X104.074 Y155.072 E-.11788
G1 X103.986 Y155.37 E-.11802
G1 X103.921 Y155.511 E-.0591
G1 X103.749 Y155.77 E-.11811
G1 X103.529 Y155.99 E-.11804
G1 X103.329 Y156.123 E-.09137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.521 Y157.071 Z4 F42000
G1 Z3.6
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X102.513 Y157.069 E.00025
G3 X102.456 Y152.494 I.021 J-2.288 E.21783
G3 X102.649 Y152.495 I.081 J1.942 E.00594
G3 X102.966 Y157.028 I-.115 J2.285 E.20401
G1 X102.58 Y157.065 E.01192
M204 S10000
G1 X102.549 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2315
M204 S6000
G1 X102.517 Y156.706 E.00087
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.509 J.043 E.00482
G3 X102.9 Y156.673 I1.918 J.159 E.23559
G1 X102.609 Y156.699 E.00805
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03484
G1 X102.136 Y156.664 E-.14568
G1 X101.826 Y156.569 E-.12326
G1 X101.517 Y156.412 E-.13166
G1 X101.214 Y156.177 E-.14571
G1 X100.965 Y155.888 E-.14499
G1 X100.922 Y155.81 E-.03386
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.193 Z4 F42000
G1 X101.411 Y147.981 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X101.439 Y148.286 E.00941
G3 X99.749 Y146.751 I-1.559 J.019 E.22232
G1 X99.881 Y146.746 E.00406
G3 X101.393 Y147.927 I-.001 J1.559 E.0635
; WIPE_START
G1 F12000
M204 S6000
G1 X101.439 Y148.286 E-.13748
G1 X101.419 Y148.596 E-.11788
G1 X101.331 Y148.893 E-.11802
G1 X101.265 Y149.034 E-.0591
G1 X101.093 Y149.293 E-.11811
G1 X100.874 Y149.513 E-.11804
G1 X100.673 Y149.646 E-.09137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.865 Y150.594 Z4 F42000
G1 Z3.6
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X99.857 Y150.592 E.00025
G3 X99.8 Y146.017 I.021 J-2.288 E.21783
G3 X99.993 Y146.019 I.081 J1.942 E.00594
G3 X100.311 Y150.551 I-.115 J2.285 E.20401
G1 X99.925 Y150.589 E.01192
M204 S10000
G1 X99.893 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2315
M204 S6000
G1 X99.862 Y150.23 E.00087
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.509 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.23559
G1 X99.953 Y150.222 E.00805
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03484
G1 X99.481 Y150.187 E-.14568
G1 X99.171 Y150.092 E-.12326
G1 X98.861 Y149.936 E-.13166
G1 X98.559 Y149.7 E-.14571
G1 X98.31 Y149.411 E-.14499
G1 X98.266 Y149.333 E-.03386
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.716 Z4 F42000
M73 P83 R5
G1 X98.756 Y141.504 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X98.783 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22232
G1 X97.226 Y140.269 E.00406
G3 X98.737 Y141.451 I-.001 J1.559 E.0635
; WIPE_START
G1 F12000
M204 S6000
G1 X98.783 Y141.809 E-.13748
G1 X98.763 Y142.119 E-.11788
G1 X98.675 Y142.417 E-.11802
G1 X98.61 Y142.558 E-.0591
G1 X98.438 Y142.817 E-.11811
G1 X98.218 Y143.036 E-.11804
G1 X98.018 Y143.169 E-.09137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.21 Y144.118 Z4 F42000
G1 Z3.6
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X97.202 Y144.116 E.00025
G3 X97.144 Y139.54 I.021 J-2.288 E.21783
G3 X97.338 Y139.542 I.081 J1.942 E.00594
G3 X97.655 Y144.074 I-.115 J2.285 E.20401
G1 X97.269 Y144.112 E.01192
M204 S10000
G1 X97.238 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381121
G1 F2315
M204 S6000
G1 X97.206 Y143.753 E.00087
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.509 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23559
G1 X97.297 Y143.746 E.00805
; CHANGE_LAYER
; Z_HEIGHT: 3.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03484
G1 X96.825 Y143.711 E-.14568
G1 X96.515 Y143.615 E-.12326
G1 X96.206 Y143.459 E-.13166
G1 X95.903 Y143.224 E-.14571
G1 X95.654 Y142.934 E-.14499
G1 X95.611 Y142.857 E-.03386
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 19/60
; update layer progress
M73 L19
M991 S0 P18 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z4 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.935 Z4
G1 Z3.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X106.75 Y161.239 E.00941
G3 X105.06 Y159.705 I-1.559 J.019 E.22232
G1 X105.191 Y159.699 E.00402
G3 X106.704 Y160.881 I0 J1.559 E.06354
; WIPE_START
G1 F12000
M204 S6000
G1 X106.75 Y161.239 E-.13742
G1 X106.73 Y161.549 E-.11788
G1 X106.642 Y161.847 E-.11798
G1 X106.576 Y161.988 E-.05913
G1 X106.404 Y162.247 E-.11811
G1 X106.185 Y162.466 E-.11804
G1 X105.984 Y162.6 E-.09143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.178 Y163.548 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X105.168 Y163.546 E.00029
G3 X105.111 Y158.971 I.021 J-2.288 E.21785
G3 X105.302 Y158.972 I.081 J1.921 E.00588
G3 X105.622 Y163.505 I-.113 J2.286 E.20406
G1 X105.237 Y163.542 E.01187
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.546 E-.02626
G1 X104.827 Y163.519 E-.13
G1 X104.387 Y163.401 E-.17326
G1 X103.979 Y163.198 E-.17328
G1 X103.619 Y162.918 E-.17326
G1 X103.474 Y162.751 E-.08394
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 19 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer19 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.75 Y162.514 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2315
M204 S6000
G1 X103.62 Y162.363 E.00548
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.51 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.789 Y162.559 E.00343
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09835
G1 X103.432 Y162.029 E-.14558
G1 X103.315 Y161.664 E-.14572
G1 X103.272 Y161.291 E-.14257
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.0665
G1 X103.35 Y160.714 E-.14893
G1 X103.356 Y160.7 E-.00599
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X104.095 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22232
G1 X102.536 Y153.222 E.00402
G3 X104.048 Y154.404 I0 J1.559 E.06354
; WIPE_START
G1 F12000
M204 S6000
G1 X104.095 Y154.763 E-.13742
G1 X104.074 Y155.072 E-.11788
G1 X103.986 Y155.37 E-.11798
G1 X103.921 Y155.511 E-.05913
G1 X103.749 Y155.77 E-.11811
G1 X103.529 Y155.99 E-.11804
G1 X103.329 Y156.123 E-.09143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.522 Y157.071 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X102.513 Y157.069 E.00029
G3 X102.456 Y152.494 I.021 J-2.288 E.21785
G3 X102.647 Y152.495 I.081 J1.921 E.00588
G3 X102.966 Y157.028 I-.113 J2.286 E.20406
G1 X102.582 Y157.065 E.01187
M204 S10000
G1 X102.55 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2315
M204 S6000
G1 X102.517 Y156.706 E.00091
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.51 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.61 Y156.699 E.008
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03535
G1 X102.136 Y156.664 E-.14572
G1 X101.825 Y156.568 E-.12372
G1 X101.517 Y156.412 E-.13115
G1 X101.214 Y156.177 E-.14566
G1 X100.964 Y155.886 E-.14573
G1 X100.922 Y155.811 E-.03268
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.194 Z4.2 F42000
G1 X101.411 Y147.981 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X101.439 Y148.286 E.00941
G3 X99.749 Y146.751 I-1.559 J.019 E.22232
G1 X99.88 Y146.746 E.00402
G3 X101.393 Y147.927 I0 J1.559 E.06354
; WIPE_START
G1 F12000
M204 S6000
G1 X101.439 Y148.286 E-.13742
G1 X101.419 Y148.596 E-.11788
G1 X101.331 Y148.893 E-.11798
G1 X101.265 Y149.034 E-.05913
G1 X101.093 Y149.293 E-.11811
G1 X100.874 Y149.513 E-.11804
G1 X100.673 Y149.646 E-.09143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.866 Y150.594 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X99.857 Y150.592 E.00029
G3 X99.8 Y146.017 I.021 J-2.288 E.21785
G3 X99.991 Y146.019 I.081 J1.921 E.00588
G3 X100.311 Y150.551 I-.113 J2.286 E.20406
G1 X99.926 Y150.589 E.01187
M204 S10000
G1 X99.895 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2315
M204 S6000
G1 X99.862 Y150.23 E.00091
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.51 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.2356
G1 X99.954 Y150.222 E.008
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03535
G1 X99.48 Y150.187 E-.14572
G1 X99.169 Y150.092 E-.12372
G1 X98.862 Y149.936 E-.13115
G1 X98.559 Y149.7 E-.14566
G1 X98.309 Y149.41 E-.14573
G1 X98.267 Y149.335 E-.03268
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.743 Y141.717 Z4.2 F42000
G1 X98.756 Y141.504 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X98.783 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22232
G1 X97.224 Y140.269 E.00402
G3 X98.737 Y141.451 I0 J1.559 E.06354
; WIPE_START
G1 F12000
M204 S6000
G1 X98.783 Y141.809 E-.13742
G1 X98.763 Y142.119 E-.11788
G1 X98.675 Y142.417 E-.11798
G1 X98.61 Y142.558 E-.05913
G1 X98.438 Y142.817 E-.11811
G1 X98.218 Y143.036 E-.11804
G1 X98.018 Y143.169 E-.09143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.211 Y144.118 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X97.202 Y144.116 E.00029
G3 X97.144 Y139.54 I.021 J-2.288 E.21785
G3 X97.335 Y139.542 I.081 J1.921 E.00588
G3 X97.655 Y144.074 I-.113 J2.286 E.20406
G1 X97.271 Y144.112 E.01187
M204 S10000
G1 X97.239 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2315
M204 S6000
G1 X97.206 Y143.753 E.00091
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.51 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.299 Y143.745 E.008
; CHANGE_LAYER
; Z_HEIGHT: 4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03535
G1 X96.825 Y143.711 E-.14572
G1 X96.514 Y143.615 E-.12372
G1 X96.206 Y143.459 E-.13115
G1 X95.903 Y143.224 E-.14566
G1 X95.653 Y142.933 E-.14573
G1 X95.611 Y142.858 E-.03268
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 20/60
; update layer progress
M73 L20
M991 S0 P19 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z4.2 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.934 Z4.2
G1 Z4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X106.75 Y161.239 E.00941
G3 X105.06 Y159.705 I-1.559 J.019 E.22232
G1 X105.19 Y159.699 E.00399
G3 X106.704 Y160.881 I.001 J1.559 E.06357
; WIPE_START
G1 F12000
M204 S6000
G1 X106.75 Y161.239 E-.13738
G1 X106.73 Y161.549 E-.11788
G1 X106.642 Y161.847 E-.11799
G1 X106.576 Y161.988 E-.05913
G1 X106.404 Y162.247 E-.1181
G1 X106.185 Y162.466 E-.11803
G1 X105.984 Y162.6 E-.0915
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.179 Y163.548 Z4.4 F42000
G1 Z4
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X105.168 Y163.546 E.00033
G3 X105.111 Y158.971 I.021 J-2.288 E.21786
G3 X105.3 Y158.972 I.081 J1.903 E.00582
G3 X105.622 Y163.505 I-.111 J2.286 E.2041
G1 X105.239 Y163.542 E.01183
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.546 E-.02674
G1 X104.715 Y163.498 E-.17309
G1 X104.281 Y163.358 E-.17339
G1 X103.883 Y163.135 E-.17328
G1 X103.538 Y162.837 E-.17324
G1 X103.473 Y162.754 E-.04026
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 20 start: 91,102,113,124
M624 HgAAAAAAAAA=
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


; object ids of this layer20 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.75 Y162.515 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2315
M204 S6000
G1 X103.62 Y162.363 E.0055
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.507 J.043 E.00482
G3 X103.871 Y162.655 I1.918 J.159 E.28581
G1 X103.79 Y162.56 E.00345
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09863
G1 X103.432 Y162.029 E-.14577
G1 X103.315 Y161.664 E-.14564
G1 X103.272 Y161.291 E-.14258
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06646
G1 X103.35 Y160.715 E-.14884
G1 X103.356 Y160.701 E-.00571
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X104.094 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22232
G1 X102.534 Y153.222 E.00399
G3 X104.048 Y154.404 I.001 J1.559 E.06357
; WIPE_START
G1 F12000
M204 S6000
G1 X104.094 Y154.763 E-.13738
G1 X104.074 Y155.072 E-.11788
G1 X103.986 Y155.37 E-.11799
G1 X103.921 Y155.511 E-.05913
G1 X103.749 Y155.77 E-.1181
G1 X103.529 Y155.99 E-.11803
G1 X103.329 Y156.123 E-.0915
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.523 Y157.071 Z4.4 F42000
G1 Z4
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X102.513 Y157.069 E.00033
G3 X102.456 Y152.494 I.021 J-2.288 E.21786
G3 X102.645 Y152.495 I.081 J1.903 E.00582
G3 X102.966 Y157.028 I-.111 J2.286 E.2041
G1 X102.583 Y157.065 E.01183
M204 S10000
G1 X102.551 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2315
M204 S6000
G1 X102.517 Y156.706 E.00094
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.507 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.611 Y156.699 E.00797
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03581
G1 X102.137 Y156.664 E-.14555
G1 X101.779 Y156.55 E-.14251
G1 X101.448 Y156.366 E-.14385
G1 X101.216 Y156.178 E-.11375
G1 X100.964 Y155.887 E-.14621
G1 X100.923 Y155.812 E-.03231
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.195 Z4.4 F42000
G1 X101.411 Y147.981 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X101.439 Y148.286 E.00941
G3 X99.749 Y146.751 I-1.559 J.019 E.22232
G1 X99.879 Y146.746 E.00399
G3 X101.393 Y147.928 I.001 J1.559 E.06357
; WIPE_START
G1 F12000
M204 S6000
G1 X101.439 Y148.286 E-.13738
G1 X101.419 Y148.596 E-.11788
G1 X101.331 Y148.893 E-.11799
G1 X101.265 Y149.034 E-.05913
G1 X101.093 Y149.293 E-.1181
G1 X100.874 Y149.513 E-.11803
G1 X100.673 Y149.646 E-.0915
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.868 Y150.594 Z4.4 F42000
G1 Z4
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X99.857 Y150.592 E.00033
G3 X99.8 Y146.017 I.021 J-2.288 E.21786
G3 X99.989 Y146.018 I.081 J1.903 E.00582
G3 X100.311 Y150.551 I-.111 J2.286 E.2041
G1 X99.927 Y150.588 E.01183
M204 S10000
G1 X99.896 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2315
M204 S6000
G1 X99.862 Y150.23 E.00094
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.507 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.2356
G1 X99.956 Y150.222 E.00797
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03581
G1 X99.481 Y150.188 E-.14555
G1 X99.124 Y150.073 E-.14251
G1 X98.793 Y149.89 E-.14385
G1 X98.56 Y149.701 E-.11375
G1 X98.309 Y149.41 E-.14621
G1 X98.267 Y149.336 E-.03231
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.718 Z4.4 F42000
G1 X98.756 Y141.504 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X98.783 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22232
G1 X97.223 Y140.269 E.00399
G3 X98.737 Y141.451 I.001 J1.559 E.06357
; WIPE_START
G1 F12000
M204 S6000
G1 X98.783 Y141.809 E-.13738
G1 X98.763 Y142.119 E-.11788
G1 X98.675 Y142.417 E-.11799
G1 X98.61 Y142.558 E-.05913
G1 X98.438 Y142.817 E-.1181
G1 X98.218 Y143.036 E-.11803
G1 X98.017 Y143.169 E-.0915
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.212 Y144.118 Z4.4 F42000
G1 Z4
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X97.202 Y144.116 E.00033
G3 X97.144 Y139.54 I.021 J-2.288 E.21786
G3 X97.334 Y139.542 I.081 J1.903 E.00582
G3 X97.655 Y144.074 I-.111 J2.286 E.2041
G1 X97.272 Y144.112 E.01183
M204 S10000
G1 X97.24 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2315
M204 S6000
G1 X97.206 Y143.753 E.00094
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.507 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.3 Y143.745 E.00797
; CHANGE_LAYER
; Z_HEIGHT: 4.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03581
G1 X96.825 Y143.711 E-.14555
G1 X96.468 Y143.596 E-.14251
G1 X96.137 Y143.413 E-.14385
G1 X95.904 Y143.225 E-.11375
G1 X95.653 Y142.933 E-.14621
G1 X95.612 Y142.859 E-.03231
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 21/60
; update layer progress
M73 L21
M991 S0 P20 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z4.4 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.934 Z4.4
G1 Z4.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.75 Y161.239 E.00941
G3 X105.06 Y159.705 I-1.559 J.019 E.22233
G1 X105.189 Y159.699 E.00395
G3 X106.704 Y160.881 I.002 J1.559 E.06361
; WIPE_START
G1 F12000
M204 S6000
G1 X106.75 Y161.239 E-.13729
G1 X106.751 Y161.395 E-.059
G1 X106.693 Y161.7 E-.11808
G1 X106.576 Y161.988 E-.11808
G1 X106.405 Y162.247 E-.11805
G1 X106.185 Y162.466 E-.11808
G1 X105.984 Y162.599 E-.09142
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.18 Y163.548 Z4.6 F42000
G1 Z4.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00035
G3 X105.109 Y158.971 I.02 J-2.289 E.21795
G1 X105.301 Y158.972 E.00591
G3 X105.622 Y163.507 I-.113 J2.287 E.20412
G1 X105.24 Y163.542 E.01181
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.02716
G1 X104.715 Y163.498 E-.17328
G1 X104.387 Y163.401 E-.13003
G1 X103.979 Y163.198 E-.17324
G1 X103.62 Y162.919 E-.17253
G1 X103.476 Y162.752 E-.08375
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 21 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.6
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
            G0 Z4.6 F4000
            G39.3 S1
            G0 Z4.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer21 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.751 Y162.515 F42000
G1 Z4.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381113
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00553
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.507 J.043 E.00482
G3 X103.874 Y162.657 I1.918 J.159 E.28569
G1 X103.79 Y162.56 E.00354
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09903
G1 X103.432 Y162.029 E-.1457
G1 X103.315 Y161.664 E-.14571
G1 X103.272 Y161.291 E-.1425
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06648
G1 X103.35 Y160.715 E-.14884
G1 X103.356 Y160.701 E-.00538
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z4.6 F42000
G1 Z4.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.094 Y154.763 E.00941
G3 X102.405 Y153.228 I-1.559 J.019 E.22233
G1 X102.533 Y153.222 E.00395
G3 X104.048 Y154.404 I.002 J1.559 E.06361
; WIPE_START
G1 F12000
M204 S6000
G1 X104.094 Y154.763 E-.13729
G1 X104.096 Y154.918 E-.059
G1 X104.038 Y155.223 E-.11808
G1 X103.921 Y155.511 E-.11808
G1 X103.749 Y155.77 E-.11805
G1 X103.529 Y155.99 E-.11808
G1 X103.329 Y156.123 E-.09142
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.524 Y157.071 Z4.6 F42000
G1 Z4.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00035
G3 X102.453 Y152.494 I.02 J-2.289 E.21795
G1 X102.646 Y152.495 E.00591
G3 X102.967 Y157.03 I-.113 J2.287 E.20412
G1 X102.584 Y157.065 E.01181
M204 S10000
G1 X102.552 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381113
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00097
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.507 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23559
G1 X102.612 Y156.699 E.00795
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03617
G1 X102.136 Y156.664 E-.14567
G1 X101.833 Y156.572 E-.1205
G1 X101.517 Y156.412 E-.13435
G1 X101.219 Y156.181 E-.14358
G1 X100.964 Y155.886 E-.14783
M73 P84 R5
G1 X100.923 Y155.813 E-.03189
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.196 Z4.6 F42000
G1 X101.411 Y147.981 Z4.6
G1 Z4.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.439 Y148.286 E.00941
G3 X99.749 Y146.751 I-1.559 J.019 E.22233
G1 X99.878 Y146.746 E.00395
G3 X101.392 Y147.928 I.002 J1.559 E.06361
; WIPE_START
G1 F12000
M204 S6000
G1 X101.439 Y148.286 E-.13729
G1 X101.44 Y148.441 E-.059
G1 X101.382 Y148.747 E-.11808
G1 X101.265 Y149.034 E-.11808
G1 X101.093 Y149.293 E-.11805
G1 X100.874 Y149.513 E-.11808
G1 X100.673 Y149.646 E-.09142
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.869 Y150.594 Z4.6 F42000
G1 Z4.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00035
G3 X99.798 Y146.017 I.02 J-2.289 E.21795
G1 X99.99 Y146.019 E.00591
G3 X100.311 Y150.553 I-.113 J2.287 E.20412
G1 X99.928 Y150.589 E.01181
M204 S10000
G1 X99.897 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381113
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00097
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.507 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.23559
G1 X99.957 Y150.222 E.00795
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03617
G1 X99.481 Y150.187 E-.14567
G1 X99.177 Y150.095 E-.1205
G1 X98.862 Y149.936 E-.13435
G1 X98.563 Y149.704 E-.14358
G1 X98.309 Y149.41 E-.14783
G1 X98.268 Y149.337 E-.03189
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.719 Z4.6 F42000
G1 X98.756 Y141.504 Z4.6
G1 Z4.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.783 Y141.809 E.00941
G3 X97.094 Y140.274 I-1.559 J.019 E.22233
G1 X97.222 Y140.269 E.00395
G3 X98.737 Y141.451 I.002 J1.559 E.06361
; WIPE_START
G1 F12000
M204 S6000
G1 X98.783 Y141.809 E-.13729
G1 X98.784 Y141.965 E-.059
G1 X98.727 Y142.27 E-.11808
G1 X98.61 Y142.558 E-.11808
G1 X98.438 Y142.817 E-.11805
G1 X98.218 Y143.036 E-.11808
G1 X98.018 Y143.169 E-.09142
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.213 Y144.117 Z4.6 F42000
G1 Z4.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00035
G3 X97.142 Y139.541 I.02 J-2.289 E.21795
G1 X97.335 Y139.542 E.00591
G3 X97.656 Y144.077 I-.113 J2.287 E.20412
G1 X97.273 Y144.112 E.01181
M204 S10000
G1 X97.241 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381113
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00097
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.507 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23559
G1 X97.301 Y143.745 E.00795
; CHANGE_LAYER
; Z_HEIGHT: 4.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03617
G1 X96.825 Y143.711 E-.14567
G1 X96.522 Y143.618 E-.1205
G1 X96.206 Y143.459 E-.13435
G1 X95.907 Y143.227 E-.14358
G1 X95.653 Y142.933 E-.14783
G1 X95.612 Y142.86 E-.03189
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 22/60
; update layer progress
M73 L22
M991 S0 P21 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z4.6 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.934 Z4.6
G1 Z4.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.75 Y161.239 E.00942
G3 X105.06 Y159.705 I-1.559 J.019 E.22233
G1 X105.188 Y159.699 E.00391
G3 X106.703 Y160.881 I.003 J1.559 E.06364
; WIPE_START
G1 F12000
M204 S6000
G1 X106.75 Y161.239 E-.13727
G1 X106.73 Y161.549 E-.11787
G1 X106.642 Y161.847 E-.118
G1 X106.497 Y162.122 E-.11809
G1 X106.3 Y162.362 E-.11807
G1 X106.185 Y162.467 E-.05915
G1 X105.984 Y162.6 E-.09156
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.18 Y163.548 Z4.8 F42000
G1 Z4.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00037
G3 X105.109 Y158.971 I.02 J-2.289 E.21796
G1 X105.299 Y158.972 E.00585
G3 X105.622 Y163.507 I-.111 J2.287 E.20418
G1 X105.24 Y163.542 E.01179
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.02737
G1 X104.827 Y163.519 E-.13006
G1 X104.387 Y163.401 E-.17328
G1 X103.979 Y163.198 E-.17329
G1 X103.62 Y162.919 E-.17248
G1 X103.477 Y162.753 E-.08352
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 22 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.8
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
            G0 Z4.8 F4000
            G39.3 S1
            G0 Z4.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer22 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.751 Y162.515 F42000
G1 Z4.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00555
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.504 J.043 E.00482
G3 X103.874 Y162.657 I1.918 J.159 E.28569
G1 X103.791 Y162.561 E.00352
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09931
G1 X103.432 Y162.029 E-.14557
G1 X103.315 Y161.664 E-.1457
G1 X103.272 Y161.291 E-.14258
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.14889
G1 X103.355 Y160.702 E-.00509
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.458 Z4.8 F42000
G1 Z4.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.094 Y154.763 E.00942
G3 X102.405 Y153.228 I-1.559 J.019 E.22233
G1 X102.532 Y153.222 E.00391
G3 X104.048 Y154.404 I.003 J1.559 E.06364
; WIPE_START
G1 F12000
M204 S6000
G1 X104.094 Y154.763 E-.13727
G1 X104.074 Y155.072 E-.11787
G1 X103.986 Y155.37 E-.118
G1 X103.841 Y155.645 E-.11809
G1 X103.645 Y155.885 E-.11807
G1 X103.529 Y155.99 E-.05915
G1 X103.328 Y156.123 E-.09156
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.525 Y157.071 Z4.8 F42000
G1 Z4.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00037
G3 X102.453 Y152.494 I.02 J-2.289 E.21796
G1 X102.644 Y152.495 E.00585
G3 X102.967 Y157.03 I-.111 J2.287 E.20418
G1 X102.585 Y157.065 E.01179
M204 S10000
G1 X102.553 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00099
G3 X100.617 Y154.814 I.024 J-1.924 E.08176
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.504 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.613 Y156.699 E.00793
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03639
G1 X102.136 Y156.664 E-.14573
G1 X101.821 Y156.567 E-.12521
G1 X101.517 Y156.412 E-.12964
G1 X101.219 Y156.181 E-.14356
G1 X100.964 Y155.886 E-.14785
G1 X100.924 Y155.814 E-.03162
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.196 Z4.8 F42000
G1 X101.411 Y147.981 Z4.8
G1 Z4.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00942
G3 X99.749 Y146.751 I-1.559 J.019 E.22233
G1 X99.876 Y146.746 E.00391
G3 X101.392 Y147.928 I.003 J1.559 E.06364
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13727
G1 X101.419 Y148.596 E-.11787
G1 X101.331 Y148.893 E-.118
G1 X101.186 Y149.168 E-.11809
G1 X100.989 Y149.409 E-.11807
G1 X100.874 Y149.513 E-.05915
G1 X100.673 Y149.646 E-.09156
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.869 Y150.594 Z4.8 F42000
G1 Z4.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00037
G3 X99.798 Y146.017 I.02 J-2.289 E.21796
G1 X99.988 Y146.019 E.00585
G3 X100.311 Y150.553 I-.111 J2.287 E.20418
G1 X99.929 Y150.589 E.01179
M204 S10000
G1 X99.897 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00099
G3 X97.961 Y148.338 I.024 J-1.924 E.08176
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.504 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.2356
G1 X99.957 Y150.222 E.00793
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03639
G1 X99.48 Y150.187 E-.14573
G1 X99.166 Y150.09 E-.12521
G1 X98.862 Y149.936 E-.12964
G1 X98.563 Y149.704 E-.14356
G1 X98.309 Y149.41 E-.14785
G1 X98.268 Y149.337 E-.03162
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.719 Z4.8 F42000
G1 X98.756 Y141.504 Z4.8
G1 Z4.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.783 Y141.809 E.00942
G3 X97.094 Y140.274 I-1.559 J.019 E.22233
G1 X97.221 Y140.269 E.00391
G3 X98.737 Y141.451 I.003 J1.559 E.06364
; WIPE_START
G1 F12000
M204 S6000
G1 X98.783 Y141.809 E-.13727
G1 X98.763 Y142.119 E-.11787
G1 X98.675 Y142.417 E-.118
G1 X98.53 Y142.691 E-.11809
G1 X98.333 Y142.932 E-.11807
G1 X98.218 Y143.036 E-.05915
G1 X98.017 Y143.17 E-.09156
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.214 Y144.117 Z4.8 F42000
G1 Z4.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00037
G3 X97.142 Y139.541 I.02 J-2.289 E.21796
G1 X97.333 Y139.542 E.00585
G3 X97.655 Y144.077 I-.111 J2.287 E.20418
G1 X97.273 Y144.112 E.01179
M204 S10000
G1 X97.242 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00099
G3 X95.305 Y141.861 I.024 J-1.924 E.08176
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.504 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.301 Y143.745 E.00793
; CHANGE_LAYER
; Z_HEIGHT: 4.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03639
G1 X96.825 Y143.711 E-.14573
G1 X96.51 Y143.613 E-.12521
G1 X96.206 Y143.459 E-.12964
G1 X95.907 Y143.227 E-.14356
G1 X95.653 Y142.933 E-.14785
G1 X95.612 Y142.86 E-.03162
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 23/60
; update layer progress
M73 L23
M991 S0 P22 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z4.8 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.934 Z4.8
G1 Z4.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.75 Y161.239 E.00942
G3 X105.06 Y159.705 I-1.559 J.019 E.22233
G1 X105.186 Y159.699 E.00388
G3 X106.703 Y160.881 I.004 J1.559 E.06368
; WIPE_START
G1 F12000
M204 S6000
G1 X106.75 Y161.239 E-.13727
G1 X106.73 Y161.549 E-.11787
G1 X106.642 Y161.847 E-.11795
G1 X106.576 Y161.988 E-.05921
G1 X106.405 Y162.247 E-.11801
G1 X106.185 Y162.466 E-.1181
G1 X105.984 Y162.6 E-.0916
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.181 Y163.548 Z5 F42000
G1 Z4.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00038
G3 X105.109 Y158.971 I.02 J-2.289 E.21798
G1 X105.297 Y158.972 E.00579
G3 X105.622 Y163.507 I-.109 J2.287 E.20423
G1 X105.241 Y163.542 E.01177
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.02755
G1 X104.828 Y163.519 E-.12999
G1 X104.387 Y163.401 E-.17331
G1 X103.979 Y163.198 E-.17331
G1 X103.62 Y162.919 E-.17252
G1 X103.477 Y162.753 E-.08332
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 23 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5
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
            G0 Z5 F4000
            G39.3 S1
            G0 Z5 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer23 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.752 Y162.516 F42000
G1 Z4.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00556
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
M73 P84 R4
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.501 J.043 E.00482
G3 X103.874 Y162.657 I1.918 J.159 E.2857
G1 X103.791 Y162.561 E.0035
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09941
G1 X103.432 Y162.029 E-.14572
G1 X103.315 Y161.664 E-.14566
G1 X103.272 Y161.291 E-.14255
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06648
G1 X103.35 Y160.715 E-.14885
G1 X103.355 Y160.702 E-.00496
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.457 Z5 F42000
G1 Z4.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.094 Y154.763 E.00942
G3 X102.405 Y153.228 I-1.559 J.019 E.22233
G1 X102.531 Y153.222 E.00388
G3 X104.048 Y154.404 I.004 J1.559 E.06368
; WIPE_START
G1 F12000
M204 S6000
G1 X104.094 Y154.763 E-.13727
G1 X104.074 Y155.072 E-.11787
G1 X103.987 Y155.37 E-.11795
G1 X103.921 Y155.511 E-.05921
G1 X103.749 Y155.77 E-.11801
G1 X103.529 Y155.99 E-.1181
G1 X103.328 Y156.123 E-.0916
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.525 Y157.071 Z5 F42000
G1 Z4.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00038
G3 X102.453 Y152.494 I.02 J-2.289 E.21798
G1 X102.642 Y152.495 E.00579
G3 X102.967 Y157.03 I-.109 J2.287 E.20423
G1 X102.585 Y157.065 E.01177
M204 S10000
G1 X102.553 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.001
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.501 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.613 Y156.699 E.00791
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03656
G1 X102.188 Y156.674 E-.12579
G1 X101.86 Y156.583 E-.12911
G1 X101.517 Y156.412 E-.14567
G1 X101.218 Y156.181 E-.14372
G1 X100.964 Y155.887 E-.14764
G1 X100.924 Y155.814 E-.03151
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.196 Z5 F42000
G1 X101.411 Y147.981 Z5
G1 Z4.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00942
G3 X99.749 Y146.751 I-1.559 J.019 E.22233
G1 X99.875 Y146.746 E.00388
G3 X101.392 Y147.928 I.004 J1.559 E.06368
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13727
G1 X101.419 Y148.596 E-.11787
G1 X101.331 Y148.893 E-.11795
G1 X101.265 Y149.035 E-.05921
G1 X101.093 Y149.293 E-.11801
G1 X100.874 Y149.513 E-.1181
G1 X100.673 Y149.646 E-.0916
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.87 Y150.594 Z5 F42000
G1 Z4.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00038
G3 X99.798 Y146.017 I.02 J-2.289 E.21798
G1 X99.986 Y146.018 E.00579
G3 X100.311 Y150.553 I-.109 J2.287 E.20423
G1 X99.929 Y150.589 E.01177
M204 S10000
G1 X99.898 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.001
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.501 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.2356
G1 X99.958 Y150.222 E.00791
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03656
G1 X99.532 Y150.197 E-.12579
G1 X99.205 Y150.106 E-.12911
G1 X98.862 Y149.936 E-.14567
G1 X98.563 Y149.704 E-.14372
G1 X98.309 Y149.41 E-.14764
G1 X98.268 Y149.337 E-.03151
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.72 Z5 F42000
G1 X98.756 Y141.504 Z5
G1 Z4.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.783 Y141.809 E.00942
G3 X97.094 Y140.274 I-1.559 J.019 E.22233
G1 X97.22 Y140.269 E.00388
G3 X98.737 Y141.451 I.004 J1.559 E.06368
; WIPE_START
G1 F12000
M204 S6000
G1 X98.783 Y141.809 E-.13727
G1 X98.763 Y142.119 E-.11787
G1 X98.675 Y142.417 E-.11795
G1 X98.609 Y142.558 E-.05921
G1 X98.438 Y142.817 E-.11801
G1 X98.218 Y143.036 E-.1181
G1 X98.017 Y143.17 E-.0916
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.214 Y144.117 Z5 F42000
G1 Z4.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00038
G3 X97.142 Y139.541 I.02 J-2.289 E.21798
G1 X97.331 Y139.542 E.00579
G3 X97.655 Y144.077 I-.109 J2.287 E.20423
G1 X97.274 Y144.112 E.01177
M204 S10000
G1 X97.242 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.001
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.501 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.302 Y143.745 E.00791
; CHANGE_LAYER
; Z_HEIGHT: 4.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03656
G1 X96.877 Y143.72 E-.12579
G1 X96.549 Y143.629 E-.12911
G1 X96.206 Y143.459 E-.14567
G1 X95.907 Y143.227 E-.14372
G1 X95.653 Y142.933 E-.14764
G1 X95.613 Y142.861 E-.03151
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 24/60
; update layer progress
M73 L24
M991 S0 P23 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z5 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.934 Z5
G1 Z4.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.24 E.00942
G3 X105.06 Y159.705 I-1.559 J.019 E.22234
G1 X105.185 Y159.699 E.00384
G3 X106.703 Y160.881 I.005 J1.559 E.06371
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.24 E-.13719
G1 X106.751 Y161.395 E-.059
G1 X106.693 Y161.7 E-.11806
G1 X106.576 Y161.988 E-.11818
G1 X106.404 Y162.247 E-.11802
G1 X106.185 Y162.466 E-.11802
G1 X105.984 Y162.6 E-.09153
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.181 Y163.547 Z5.2 F42000
G1 Z4.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00039
G3 X105.109 Y158.971 I.019 J-2.289 E.21799
G1 X105.295 Y158.972 E.00573
G3 X105.622 Y163.507 I-.108 J2.287 E.20427
G1 X105.241 Y163.542 E.01177
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.02765
G1 X104.827 Y163.519 E-.13002
G1 X104.387 Y163.401 E-.17331
M73 P85 R4
G1 X103.978 Y163.198 E-.17334
G1 X103.62 Y162.919 E-.17245
G1 X103.477 Y162.753 E-.08324
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 24 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5.2
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
            G0 Z5.2 F4000
            G39.3 S1
            G0 Z5.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer24 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.752 Y162.516 F42000
G1 Z4.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00558
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.495 J.043 E.00482
G3 X103.874 Y162.657 I1.918 J.159 E.2857
G1 X103.791 Y162.561 E.00349
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09969
G1 X103.432 Y162.029 E-.14564
G1 X103.315 Y161.664 E-.14572
G1 X103.272 Y161.291 E-.14242
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.14893
G1 X103.355 Y160.703 E-.00475
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.457 Z5.2 F42000
G1 Z4.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.094 Y154.763 E.00942
G3 X102.405 Y153.228 I-1.559 J.019 E.22234
G1 X102.53 Y153.222 E.00384
G3 X104.048 Y154.405 I.005 J1.559 E.06371
; WIPE_START
G1 F12000
M204 S6000
G1 X104.094 Y154.763 E-.13719
G1 X104.096 Y154.918 E-.059
G1 X104.038 Y155.223 E-.11806
G1 X103.921 Y155.511 E-.11818
G1 X103.749 Y155.77 E-.11802
G1 X103.529 Y155.99 E-.11802
G1 X103.329 Y156.123 E-.09153
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.526 Y157.071 Z5.2 F42000
G1 Z4.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00039
G3 X102.454 Y152.494 I.019 J-2.289 E.21799
G1 X102.64 Y152.495 E.00573
G3 X102.967 Y157.03 I-.108 J2.287 E.20427
G1 X102.585 Y157.065 E.01177
M204 S10000
G1 X102.554 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.001
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.495 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.613 Y156.699 E.00791
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03665
G1 X102.136 Y156.664 E-.14567
G1 X101.779 Y156.55 E-.14247
G1 X101.506 Y156.405 E-.11771
G1 X101.218 Y156.181 E-.13841
G1 X100.964 Y155.886 E-.14784
G1 X100.924 Y155.814 E-.03126
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.197 Z5.2 F42000
G1 X101.411 Y147.981 Z5.2
G1 Z4.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00942
G3 X99.749 Y146.751 I-1.559 J.019 E.22234
G1 X99.874 Y146.746 E.00384
G3 X101.392 Y147.928 I.005 J1.559 E.06371
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13719
G1 X101.44 Y148.441 E-.059
G1 X101.382 Y148.747 E-.11806
G1 X101.265 Y149.035 E-.11818
G1 X101.093 Y149.293 E-.11802
G1 X100.874 Y149.513 E-.11802
G1 X100.673 Y149.646 E-.09153
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.87 Y150.594 Z5.2 F42000
G1 Z4.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00039
G3 X99.798 Y146.017 I.019 J-2.289 E.21799
G1 X99.984 Y146.018 E.00573
G3 X100.311 Y150.553 I-.108 J2.287 E.20427
G1 X99.93 Y150.589 E.01177
M204 S10000
G1 X99.898 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.001
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.495 J.043 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.2356
G1 X99.958 Y150.222 E.00791
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03665
G1 X99.481 Y150.187 E-.14567
G1 X99.124 Y150.073 E-.14247
G1 X98.85 Y149.928 E-.11771
G1 X98.563 Y149.704 E-.13841
G1 X98.309 Y149.409 E-.14784
G1 X98.268 Y149.338 E-.03126
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.72 Z5.2 F42000
G1 X98.756 Y141.504 Z5.2
G1 Z4.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00942
G3 X97.093 Y140.274 I-1.559 J.019 E.22234
G1 X97.218 Y140.269 E.00384
G3 X98.736 Y141.451 I.005 J1.559 E.06371
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13719
G1 X98.784 Y141.965 E-.059
G1 X98.727 Y142.27 E-.11806
G1 X98.609 Y142.558 E-.11818
G1 X98.438 Y142.817 E-.11802
G1 X98.218 Y143.036 E-.11802
G1 X98.017 Y143.169 E-.09153
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.214 Y144.117 Z5.2 F42000
G1 Z4.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00039
G3 X97.142 Y139.541 I.019 J-2.289 E.21799
G1 X97.329 Y139.542 E.00573
G3 X97.655 Y144.076 I-.108 J2.287 E.20427
G1 X97.274 Y144.112 E.01177
M204 S10000
G1 X97.242 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.001
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.495 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.302 Y143.745 E.00791
; CHANGE_LAYER
; Z_HEIGHT: 5
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03665
G1 X96.825 Y143.711 E-.14567
G1 X96.468 Y143.596 E-.14247
G1 X96.194 Y143.451 E-.11771
G1 X95.907 Y143.227 E-.13841
G1 X95.653 Y142.933 E-.14784
G1 X95.613 Y142.861 E-.03126
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 25/60
; update layer progress
M73 L25
M991 S0 P24 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z5.2 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.934 Z5.2
G1 Z5
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X106.749 Y161.239 E.00943
G3 X105.06 Y159.705 I-1.559 J.019 E.22234
G1 X105.184 Y159.699 E.00381
G3 X106.703 Y160.881 I.006 J1.559 E.06375
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.239 E-.13723
G1 X106.751 Y161.395 E-.059
G1 X106.693 Y161.7 E-.1181
G1 X106.576 Y161.988 E-.11809
G1 X106.405 Y162.247 E-.11801
G1 X106.185 Y162.466 E-.1181
G1 X105.984 Y162.6 E-.09147
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.181 Y163.548 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X105.168 Y163.546 E.0004
G3 X105.109 Y158.971 I.019 J-2.288 E.2179
G1 X105.293 Y158.972 E.00566
G3 X105.509 Y163.523 I-.106 J2.286 E.20772
G1 X105.241 Y163.543 E.00826
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.546 E-.02762
G1 X104.715 Y163.498 E-.17319
G1 X104.281 Y163.358 E-.17328
G1 X103.883 Y163.135 E-.17328
G1 X103.618 Y162.918 E-.13009
G1 X103.477 Y162.753 E-.08254
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 25 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5.4
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
            G0 Z5.4 F4000
            G39.3 S1
            G0 Z5.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer25 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.752 Y162.517 F42000
G1 Z5
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381137
G1 F2315
M204 S6000
G1 X103.62 Y162.363 E.00558
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.494 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28588
G1 X103.791 Y162.562 E.00333
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09971
G1 X103.432 Y162.028 E-.14575
G1 X103.315 Y161.664 E-.14556
G1 X103.272 Y161.291 E-.14254
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06647
G1 X103.35 Y160.714 E-.14893
G1 X103.355 Y160.703 E-.00465
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.457 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X104.094 Y154.763 E.00943
G3 X102.405 Y153.228 I-1.559 J.019 E.22234
G1 X102.528 Y153.222 E.00381
G3 X104.048 Y154.405 I.006 J1.559 E.06375
; WIPE_START
G1 F12000
M204 S6000
G1 X104.094 Y154.763 E-.13723
G1 X104.096 Y154.918 E-.059
G1 X104.038 Y155.223 E-.1181
G1 X103.921 Y155.511 E-.11809
G1 X103.749 Y155.77 E-.11801
G1 X103.529 Y155.99 E-.1181
G1 X103.329 Y156.123 E-.09147
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.526 Y157.071 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X102.513 Y157.069 E.0004
G3 X102.454 Y152.494 I.019 J-2.288 E.2179
G1 X102.638 Y152.495 E.00566
G3 X102.854 Y157.046 I-.106 J2.286 E.20772
G1 X102.585 Y157.067 E.00826
M204 S10000
G1 X102.554 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381137
G1 F2315
M204 S6000
G1 X102.517 Y156.706 E.00101
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.494 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.23562
G1 X102.613 Y156.699 E.0079
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03668
G1 X102.185 Y156.673 E-.1268
G1 X101.853 Y156.58 E-.13127
G1 X101.517 Y156.412 E-.14258
G1 X101.214 Y156.177 E-.1457
G1 X100.964 Y155.886 E-.14565
G1 X100.924 Y155.814 E-.03133
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.197 Z5.4 F42000
G1 X101.411 Y147.98 Z5.4
G1 Z5
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X101.438 Y148.286 E.00943
G3 X99.749 Y146.751 I-1.559 J.019 E.22234
G1 X99.873 Y146.746 E.00381
G3 X101.392 Y147.928 I.006 J1.559 E.06375
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13723
G1 X101.44 Y148.441 E-.059
G1 X101.382 Y148.747 E-.1181
G1 X101.265 Y149.035 E-.11809
G1 X101.093 Y149.293 E-.11801
G1 X100.874 Y149.513 E-.1181
G1 X100.673 Y149.646 E-.09147
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.87 Y150.594 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X99.857 Y150.592 E.0004
G3 X99.798 Y146.017 I.019 J-2.288 E.2179
G1 X99.982 Y146.018 E.00566
G3 X100.198 Y150.57 I-.106 J2.286 E.20772
G1 X99.93 Y150.59 E.00826
M204 S10000
G1 X99.898 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381137
G1 F2315
M204 S6000
G1 X99.862 Y150.23 E.00101
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.494 J.043 E.00482
G3 X100.243 Y150.196 I1.918 J.159 E.23562
G1 X99.958 Y150.222 E.0079
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03668
G1 X99.53 Y150.197 E-.1268
G1 X99.197 Y150.103 E-.13127
G1 X98.861 Y149.935 E-.14258
G1 X98.559 Y149.7 E-.1457
G1 X98.309 Y149.41 E-.14565
G1 X98.268 Y149.338 E-.03133
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.72 Z5.4 F42000
G1 X98.756 Y141.504 Z5.4
G1 Z5
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X98.783 Y141.809 E.00943
G3 X97.093 Y140.274 I-1.559 J.019 E.22234
G1 X97.217 Y140.269 E.00381
G3 X98.736 Y141.451 I.006 J1.559 E.06375
; WIPE_START
G1 F12000
M204 S6000
G1 X98.783 Y141.809 E-.13723
G1 X98.784 Y141.965 E-.059
G1 X98.727 Y142.27 E-.1181
G1 X98.609 Y142.558 E-.11809
G1 X98.438 Y142.817 E-.11801
G1 X98.218 Y143.036 E-.1181
G1 X98.017 Y143.169 E-.09147
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.214 Y144.118 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X97.202 Y144.116 E.0004
G3 X97.142 Y139.54 I.019 J-2.288 E.2179
G1 X97.327 Y139.542 E.00566
G3 X97.542 Y144.093 I-.106 J2.286 E.20772
G1 X97.274 Y144.113 E.00826
M204 S10000
G1 X97.243 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381137
G1 F2315
M204 S6000
G1 X97.206 Y143.753 E.00101
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.494 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.23562
G1 X97.302 Y143.745 E.0079
; CHANGE_LAYER
; Z_HEIGHT: 5.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03668
G1 X96.874 Y143.72 E-.1268
G1 X96.541 Y143.626 E-.13127
G1 X96.206 Y143.459 E-.14258
G1 X95.903 Y143.223 E-.1457
G1 X95.653 Y142.933 E-.14565
G1 X95.613 Y142.861 E-.03133
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 26/60
; update layer progress
M73 L26
M991 S0 P25 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z5.4 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.934 Z5.4
G1 Z5.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.239 E.00944
G3 X105.06 Y159.705 I-1.559 J.019 E.22234
G1 X105.183 Y159.699 E.00377
G3 X106.703 Y160.882 I.007 J1.559 E.06378
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.239 E-.13715
G1 X106.73 Y161.549 E-.11786
G1 X106.642 Y161.847 E-.11798
G1 X106.576 Y161.988 E-.0591
G1 X106.405 Y162.247 E-.11809
G1 X106.185 Y162.467 E-.11814
G1 X105.984 Y162.6 E-.09168
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.181 Y163.548 Z5.6 F42000
G1 Z5.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00038
G3 X105.109 Y158.971 I.019 J-2.289 E.21803
G1 X105.291 Y158.972 E.0056
G3 X105.622 Y163.507 I-.104 J2.287 E.20436
G1 X105.241 Y163.542 E.01177
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.02755
G1 X104.827 Y163.519 E-.13004
G1 X104.387 Y163.401 E-.17326
G1 X103.978 Y163.198 E-.17337
G1 X103.62 Y162.919 E-.17255
G1 X103.477 Y162.753 E-.08324
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 26 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5.6
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
            G0 Z5.6 F4000
            G39.3 S1
            G0 Z5.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer26 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.752 Y162.516 F42000
G1 Z5.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381112
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00557
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.51 J.043 E.00482
G3 X103.874 Y162.657 I1.918 J.159 E.28571
G1 X103.791 Y162.561 E.00349
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09955
G1 X103.432 Y162.029 E-.14552
G1 X103.315 Y161.664 E-.14577
G1 X103.272 Y161.291 E-.14253
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.14889
G1 X103.355 Y160.703 E-.00489
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.457 Z5.6 F42000
G1 Z5.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.094 Y154.763 E.00944
G3 X102.405 Y153.228 I-1.559 J.019 E.22234
G1 X102.527 Y153.223 E.00377
G3 X104.047 Y154.405 I.007 J1.559 E.06378
; WIPE_START
G1 F12000
M204 S6000
G1 X104.094 Y154.763 E-.13715
G1 X104.074 Y155.072 E-.11786
G1 X103.986 Y155.37 E-.11798
G1 X103.921 Y155.511 E-.0591
G1 X103.749 Y155.77 E-.11809
G1 X103.529 Y155.99 E-.11814
G1 X103.328 Y156.123 E-.09168
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.525 Y157.071 Z5.6 F42000
G1 Z5.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00038
G3 X102.454 Y152.494 I.019 J-2.289 E.21803
G1 X102.636 Y152.495 E.0056
G3 X102.967 Y157.03 I-.104 J2.287 E.20436
G1 X102.585 Y157.065 E.01177
M204 S10000
G1 X102.553 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381112
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.001
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.51 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.613 Y156.699 E.00791
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03655
G1 X102.184 Y156.673 E-.12731
G1 X101.86 Y156.583 E-.12759
G1 X101.517 Y156.412 E-.14569
G1 X101.218 Y156.18 E-.14376
G1 X100.964 Y155.886 E-.14769
G1 X100.924 Y155.814 E-.03141
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.196 Z5.6 F42000
G1 X101.411 Y147.98 Z5.6
G1 Z5.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00944
G3 X99.749 Y146.751 I-1.559 J.019 E.22234
G1 X99.872 Y146.746 E.00377
G3 X101.392 Y147.928 I.007 J1.559 E.06378
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13715
G1 X101.419 Y148.596 E-.11786
G1 X101.331 Y148.893 E-.11798
G1 X101.265 Y149.034 E-.0591
G1 X101.093 Y149.293 E-.11809
G1 X100.874 Y149.513 E-.11814
G1 X100.672 Y149.647 E-.09168
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.87 Y150.594 Z5.6 F42000
G1 Z5.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00038
G3 X99.798 Y146.017 I.019 J-2.289 E.21803
G1 X99.98 Y146.018 E.0056
G3 X100.311 Y150.553 I-.104 J2.287 E.20436
G1 X99.929 Y150.589 E.01177
M204 S10000
G1 X99.898 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381112
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.001
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
M73 P86 R4
G3 X97.967 Y148.146 I3.51 J.043 E.00482
G3 X100.243 Y150.196 I1.918 J.159 E.2356
G1 X99.958 Y150.222 E.00791
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03655
G1 X99.528 Y150.196 E-.12731
G1 X99.205 Y150.106 E-.12759
G1 X98.862 Y149.936 E-.14569
G1 X98.563 Y149.704 E-.14376
G1 X98.309 Y149.41 E-.14769
G1 X98.268 Y149.337 E-.03141
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.72 Z5.6 F42000
G1 X98.756 Y141.503 Z5.6
G1 Z5.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00944
G3 X97.093 Y140.274 I-1.559 J.019 E.22234
G1 X97.216 Y140.269 E.00377
G3 X98.736 Y141.451 I.007 J1.559 E.06378
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13715
G1 X98.763 Y142.119 E-.11786
G1 X98.675 Y142.417 E-.11798
G1 X98.61 Y142.558 E-.0591
G1 X98.438 Y142.817 E-.11809
G1 X98.218 Y143.036 E-.11814
G1 X98.017 Y143.17 E-.09168
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.214 Y144.117 Z5.6 F42000
G1 Z5.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00038
G3 X97.142 Y139.54 I.019 J-2.289 E.21803
G1 X97.325 Y139.542 E.0056
G3 X97.655 Y144.076 I-.104 J2.287 E.20436
G1 X97.274 Y144.112 E.01177
M204 S10000
G1 X97.242 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381112
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.001
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.51 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.302 Y143.745 E.00791
; CHANGE_LAYER
; Z_HEIGHT: 5.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03655
G1 X96.873 Y143.72 E-.12731
G1 X96.549 Y143.629 E-.12759
G1 X96.206 Y143.459 E-.14569
G1 X95.907 Y143.227 E-.14376
G1 X95.653 Y142.933 E-.14769
G1 X95.613 Y142.861 E-.03141
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 27/60
; update layer progress
M73 L27
M991 S0 P26 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z5.6 I-1.037 J.637 P1  F42000
G1 X106.723 Y160.933 Z5.6
G1 Z5.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.239 E.00944
G3 X105.06 Y159.705 I-1.559 J.019 E.22234
G1 X105.182 Y159.699 E.00373
G3 X106.703 Y160.882 I.008 J1.559 E.06382
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.239 E-.13714
G1 X106.751 Y161.395 E-.059
G1 X106.693 Y161.7 E-.11805
G1 X106.576 Y161.988 E-.1181
G1 X106.404 Y162.247 E-.1181
G1 X106.185 Y162.467 E-.1181
G1 X105.984 Y162.6 E-.09149
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.18 Y163.548 Z5.8 F42000
G1 Z5.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00037
G3 X105.109 Y158.971 I.019 J-2.289 E.21803
G1 X105.289 Y158.972 E.00554
G3 X105.622 Y163.506 I-.102 J2.287 E.20441
G1 X105.24 Y163.542 E.01179
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.0274
G1 X104.715 Y163.498 E-.17331
G1 X104.387 Y163.401 E-.13003
G1 X103.978 Y163.198 E-.17334
G1 X103.62 Y162.919 E-.1725
G1 X103.477 Y162.753 E-.08342
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 27 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5.8
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
            G0 Z5.8 F4000
            G39.3 S1
            G0 Z5.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer27 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.752 Y162.516 F42000
G1 Z5.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00555
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.508 J.043 E.00482
G3 X103.874 Y162.657 I1.918 J.159 E.28572
G1 X103.791 Y162.561 E.00349
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09933
G1 X103.432 Y162.029 E-.14562
G1 X103.315 Y161.664 E-.14571
G1 X103.272 Y161.291 E-.14255
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06647
G1 X103.35 Y160.714 E-.14894
G1 X103.355 Y160.702 E-.00501
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.457 Z5.8 F42000
G1 Z5.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.093 Y154.763 E.00944
G3 X102.405 Y153.228 I-1.559 J.019 E.22234
G1 X102.526 Y153.223 E.00373
G3 X104.047 Y154.405 I.008 J1.559 E.06382
; WIPE_START
G1 F12000
M204 S6000
G1 X104.093 Y154.763 E-.13714
G1 X104.096 Y154.918 E-.059
G1 X104.038 Y155.223 E-.11805
G1 X103.921 Y155.511 E-.1181
G1 X103.749 Y155.77 E-.1181
G1 X103.529 Y155.99 E-.1181
G1 X103.328 Y156.123 E-.09149
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.525 Y157.071 Z5.8 F42000
G1 Z5.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00037
G3 X102.454 Y152.494 I.019 J-2.289 E.21803
G1 X102.634 Y152.495 E.00554
G3 X102.967 Y157.03 I-.102 J2.287 E.20441
G1 X102.585 Y157.065 E.01179
M204 S10000
G1 X102.553 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00099
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.508 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.613 Y156.699 E.00792
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03642
G1 X102.136 Y156.664 E-.14567
G1 X101.779 Y156.55 E-.14243
G1 X101.445 Y156.365 E-.14517
G1 X101.218 Y156.18 E-.11123
G1 X100.964 Y155.886 E-.14747
G1 X100.924 Y155.814 E-.03161
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.196 Z5.8 F42000
G1 X101.411 Y147.98 Z5.8
G1 Z5.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00944
G3 X99.749 Y146.751 I-1.559 J.019 E.22234
G1 X99.87 Y146.746 E.00373
G3 X101.392 Y147.928 I.008 J1.559 E.06382
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13714
G1 X101.44 Y148.441 E-.059
G1 X101.382 Y148.747 E-.11805
G1 X101.265 Y149.034 E-.1181
G1 X101.093 Y149.293 E-.1181
G1 X100.873 Y149.513 E-.1181
G1 X100.673 Y149.646 E-.09149
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.869 Y150.594 Z5.8 F42000
G1 Z5.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00037
G3 X99.798 Y146.017 I.019 J-2.289 E.21803
G1 X99.978 Y146.018 E.00554
G3 X100.311 Y150.553 I-.102 J2.287 E.20441
G1 X99.929 Y150.589 E.01179
M204 S10000
G1 X99.897 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00099
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.508 J.043 E.00482
G3 X100.243 Y150.196 I1.918 J.159 E.2356
G1 X99.957 Y150.222 E.00792
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03642
G1 X99.481 Y150.187 E-.14567
G1 X99.124 Y150.073 E-.14243
G1 X98.79 Y149.888 E-.14517
G1 X98.562 Y149.703 E-.11123
G1 X98.309 Y149.41 E-.14747
G1 X98.268 Y149.337 E-.03161
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.719 Z5.8 F42000
G1 X98.756 Y141.503 Z5.8
G1 Z5.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00944
G3 X97.093 Y140.274 I-1.559 J.019 E.22234
G1 X97.215 Y140.269 E.00373
G3 X98.736 Y141.451 I.008 J1.559 E.06382
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13714
G1 X98.784 Y141.965 E-.059
G1 X98.727 Y142.27 E-.11805
G1 X98.61 Y142.558 E-.1181
G1 X98.438 Y142.817 E-.1181
G1 X98.218 Y143.036 E-.1181
G1 X98.017 Y143.17 E-.09149
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.214 Y144.117 Z5.8 F42000
G1 Z5.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00037
G3 X97.142 Y139.54 I.019 J-2.289 E.21803
G1 X97.323 Y139.541 E.00554
G3 X97.655 Y144.076 I-.102 J2.287 E.20441
G1 X97.273 Y144.112 E.01179
M204 S10000
G1 X97.242 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00099
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.508 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.302 Y143.745 E.00792
; CHANGE_LAYER
; Z_HEIGHT: 5.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03642
G1 X96.825 Y143.711 E-.14567
G1 X96.468 Y143.596 E-.14243
G1 X96.134 Y143.411 E-.14517
G1 X95.907 Y143.227 E-.11123
G1 X95.653 Y142.933 E-.14747
G1 X95.612 Y142.86 E-.03161
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 28/60
; update layer progress
M73 L28
M991 S0 P27 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z5.8 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.933 Z5.8
G1 Z5.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.239 E.00945
G3 X105.06 Y159.705 I-1.559 J.019 E.22234
G1 X105.18 Y159.699 E.0037
G3 X106.703 Y160.881 I.01 J1.559 E.06385
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.239 E-.13719
G1 X106.751 Y161.395 E-.05899
G1 X106.693 Y161.7 E-.11807
G1 X106.576 Y161.988 E-.1181
G1 X106.405 Y162.247 E-.11805
G1 X106.185 Y162.466 E-.11808
G1 X105.984 Y162.6 E-.09152
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.179 Y163.548 Z6 F42000
G1 Z5.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00034
G3 X105.109 Y158.971 I.019 J-2.289 E.21804
G1 X105.287 Y158.972 E.00547
G3 X105.622 Y163.506 I-.1 J2.287 E.20447
G1 X105.239 Y163.542 E.01182
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.02701
G1 X104.827 Y163.519 E-.13004
G1 X104.387 Y163.401 E-.17326
G1 X103.979 Y163.198 E-.1733
G1 X103.619 Y162.918 E-.17328
G1 X103.476 Y162.752 E-.08311
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 28 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z6
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
            G0 Z6 F4000
            G39.3 S1
            G0 Z6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer28 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.751 Y162.515 F42000
G1 Z5.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00554
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.523 J.044 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28585
G1 X103.79 Y162.561 E.00337
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09923
G1 X103.437 Y162.036 E-.14248
G1 X103.315 Y161.664 E-.1487
G1 X103.272 Y161.291 E-.14256
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06648
G1 X103.35 Y160.714 E-.14897
G1 X103.356 Y160.702 E-.00521
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.456 Z6 F42000
G1 Z5.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.093 Y154.763 E.00945
G3 X102.405 Y153.228 I-1.559 J.019 E.22234
G1 X102.525 Y153.223 E.0037
G3 X104.047 Y154.405 I.01 J1.559 E.06385
; WIPE_START
G1 F12000
M204 S6000
G1 X104.093 Y154.763 E-.13719
G1 X104.096 Y154.918 E-.05899
G1 X104.038 Y155.223 E-.11807
G1 X103.921 Y155.511 E-.1181
G1 X103.749 Y155.77 E-.11805
G1 X103.529 Y155.99 E-.11808
G1 X103.329 Y156.123 E-.09152
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.524 Y157.071 Z6 F42000
G1 Z5.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00034
G3 X102.454 Y152.494 I.019 J-2.289 E.21804
G1 X102.632 Y152.495 E.00547
G3 X102.967 Y157.03 I-.1 J2.287 E.20447
G1 X102.584 Y157.065 E.01182
M204 S10000
G1 X102.552 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00096
G3 X100.617 Y154.814 I.024 J-1.924 E.08176
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.523 J.044 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.612 Y156.699 E.00795
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03601
G1 X102.137 Y156.664 E-.14556
G1 X101.784 Y156.552 E-.14066
G1 X101.517 Y156.412 E-.11439
G1 X101.214 Y156.177 E-.1457
G1 X100.964 Y155.886 E-.14573
G1 X100.923 Y155.813 E-.03194
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.195 Z6 F42000
G1 X101.411 Y147.98 Z6
G1 Z5.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00945
G3 X99.749 Y146.751 I-1.559 J.019 E.22234
G1 X99.869 Y146.746 E.0037
G3 X101.392 Y147.928 I.01 J1.559 E.06385
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13719
G1 X101.44 Y148.441 E-.05899
G1 X101.382 Y148.747 E-.11807
G1 X101.265 Y149.034 E-.1181
G1 X101.093 Y149.293 E-.11805
G1 X100.874 Y149.513 E-.11808
G1 X100.673 Y149.646 E-.09152
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.868 Y150.594 Z6 F42000
G1 Z5.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00034
G3 X99.798 Y146.017 I.019 J-2.289 E.21804
G1 X99.976 Y146.018 E.00547
G3 X100.311 Y150.553 I-.1 J2.287 E.20447
G1 X99.928 Y150.589 E.01182
M204 S10000
G1 X99.896 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00096
G3 X97.961 Y148.338 I.024 J-1.924 E.08176
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.523 J.044 E.00482
G3 X100.244 Y150.196 I1.918 J.159 E.2356
G1 X99.956 Y150.222 E.00795
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03601
G1 X99.481 Y150.188 E-.14556
G1 X99.128 Y150.075 E-.14066
G1 X98.862 Y149.936 E-.11439
G1 X98.559 Y149.7 E-.1457
G1 X98.309 Y149.41 E-.14573
G1 X98.268 Y149.336 E-.03194
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.719 Z6 F42000
G1 X98.756 Y141.503 Z6
G1 Z5.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00945
G3 X97.093 Y140.274 I-1.559 J.019 E.22234
G1 X97.214 Y140.269 E.0037
G3 X98.736 Y141.451 I.01 J1.559 E.06385
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13719
G1 X98.784 Y141.965 E-.05899
G1 X98.727 Y142.27 E-.11807
G1 X98.61 Y142.558 E-.1181
G1 X98.438 Y142.817 E-.11805
G1 X98.218 Y143.036 E-.11808
G1 X98.017 Y143.169 E-.09152
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.213 Y144.117 Z6 F42000
G1 Z5.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00034
G3 X97.142 Y139.54 I.019 J-2.289 E.21804
G1 X97.321 Y139.541 E.00547
G3 X97.655 Y144.076 I-.1 J2.287 E.20447
G1 X97.272 Y144.112 E.01182
M204 S10000
G1 X97.241 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00096
G3 X95.305 Y141.861 I.024 J-1.924 E.08176
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.523 J.044 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.301 Y143.745 E.00795
; CHANGE_LAYER
; Z_HEIGHT: 5.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03601
G1 X96.825 Y143.711 E-.14556
G1 X96.473 Y143.598 E-.14066
G1 X96.206 Y143.459 E-.11439
G1 X95.903 Y143.224 E-.1457
G1 X95.653 Y142.933 E-.14573
G1 X95.612 Y142.86 E-.03194
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 29/60
; update layer progress
M73 L29
M991 S0 P28 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z6 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.933 Z6
G1 Z5.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.24 E.00946
G3 X105.06 Y159.705 I-1.559 J.019 E.22234
G1 X105.179 Y159.699 E.00366
G3 X106.703 Y160.882 I.011 J1.559 E.06389
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.24 E-.13713
G1 X106.73 Y161.549 E-.11785
G1 X106.642 Y161.847 E-.11798
G1 X106.576 Y161.988 E-.0591
G1 X106.404 Y162.247 E-.11814
G1 X106.185 Y162.467 E-.11809
G1 X105.984 Y162.6 E-.09172
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.178 Y163.548 Z6.2 F42000
G1 Z5.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00031
G3 X105.109 Y158.971 I.018 J-2.289 E.21806
G1 X105.285 Y158.971 E.00541
G3 X105.622 Y163.506 I-.099 J2.287 E.20451
G1 X105.238 Y163.542 E.01185
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.02663
G1 X104.715 Y163.498 E-.1733
G1 X104.387 Y163.401 E-.13007
G1 X103.979 Y163.198 E-.17322
G1 X103.618 Y162.918 E-.17332
G1 X103.475 Y162.751 E-.08346
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z6.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 29 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z6.2
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
            G0 Z6.2 F4000
            G39.3 S1
            G0 Z6.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer29 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.75 Y162.515 F42000
G1 Z5.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.0055
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.508 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.79 Y162.56 E.0034
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09864
G1 X103.434 Y162.033 E-.14393
G1 X103.315 Y161.664 E-.14752
G1 X103.272 Y161.291 E-.14254
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.14895
G1 X103.356 Y160.701 E-.00556
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.456 Z6.2 F42000
G1 Z5.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.093 Y154.763 E.00946
G3 X102.405 Y153.228 I-1.559 J.019 E.22234
G1 X102.524 Y153.223 E.00366
G3 X104.047 Y154.405 I.011 J1.559 E.06389
; WIPE_START
G1 F12000
M204 S6000
G1 X104.093 Y154.763 E-.13713
G1 X104.074 Y155.072 E-.11785
G1 X103.986 Y155.37 E-.11798
G1 X103.921 Y155.511 E-.0591
G1 X103.749 Y155.77 E-.11814
G1 X103.529 Y155.99 E-.11809
G1 X103.328 Y156.123 E-.09172
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.523 Y157.071 Z6.2 F42000
G1 Z5.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00031
G3 X102.454 Y152.494 I.018 J-2.289 E.21806
G1 X102.63 Y152.495 E.00541
G3 X102.967 Y157.03 I-.099 J2.287 E.20451
G1 X102.583 Y157.065 E.01185
M204 S10000
G1 X102.551 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00093
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.508 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.611 Y156.699 E.00798
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03564
G1 X102.149 Y156.667 E-.14056
G1 X101.86 Y156.583 E-.11441
G1 X101.517 Y156.412 E-.14564
G1 X101.214 Y156.177 E-.14575
G1 X100.964 Y155.887 E-.1455
G1 X100.923 Y155.812 E-.0325
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.194 Z6.2 F42000
M73 P87 R4
G1 X101.411 Y147.979 Z6.2
G1 Z5.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00946
G3 X99.749 Y146.751 I-1.559 J.019 E.22234
G1 X99.868 Y146.746 E.00366
G3 X101.392 Y147.928 I.011 J1.559 E.06389
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13713
G1 X101.419 Y148.596 E-.11785
G1 X101.331 Y148.893 E-.11798
G1 X101.265 Y149.034 E-.0591
G1 X101.093 Y149.293 E-.11814
G1 X100.874 Y149.513 E-.11809
G1 X100.672 Y149.647 E-.09172
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.867 Y150.594 Z6.2 F42000
G1 Z5.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00031
G3 X99.798 Y146.017 I.018 J-2.289 E.21806
G1 X99.974 Y146.018 E.00541
G3 X100.311 Y150.553 I-.099 J2.287 E.20451
G1 X99.927 Y150.589 E.01185
M204 S10000
G1 X99.895 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00093
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.508 J.043 E.00482
G3 X100.243 Y150.196 I1.918 J.159 E.2356
G1 X99.955 Y150.222 E.00798
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03564
G1 X99.494 Y150.19 E-.14056
G1 X99.205 Y150.106 E-.11441
G1 X98.862 Y149.936 E-.14564
G1 X98.559 Y149.7 E-.14575
G1 X98.309 Y149.41 E-.1455
G1 X98.267 Y149.335 E-.0325
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.718 Z6.2 F42000
G1 X98.756 Y141.503 Z6.2
G1 Z5.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00946
G3 X97.093 Y140.274 I-1.559 J.019 E.22234
G1 X97.212 Y140.269 E.00366
G3 X98.736 Y141.451 I.011 J1.559 E.06389
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13713
G1 X98.763 Y142.119 E-.11785
G1 X98.675 Y142.417 E-.11798
G1 X98.61 Y142.558 E-.0591
G1 X98.438 Y142.817 E-.11814
G1 X98.218 Y143.036 E-.11809
G1 X98.017 Y143.17 E-.09172
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.212 Y144.118 Z6.2 F42000
G1 Z5.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00031
G3 X97.143 Y139.54 I.018 J-2.289 E.21806
G1 X97.319 Y139.541 E.00541
G3 X97.655 Y144.076 I-.099 J2.287 E.20451
G1 X97.271 Y144.112 E.01185
M204 S10000
G1 X97.24 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00093
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.508 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.3 Y143.745 E.00798
; CHANGE_LAYER
; Z_HEIGHT: 6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03564
G1 X96.838 Y143.713 E-.14056
G1 X96.549 Y143.629 E-.11441
G1 X96.206 Y143.459 E-.14564
G1 X95.903 Y143.223 E-.14575
G1 X95.653 Y142.933 E-.1455
G1 X95.611 Y142.859 E-.0325
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 30/60
; update layer progress
M73 L30
M991 S0 P29 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z6.2 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.932 Z6.2
G1 Z6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.239 E.00947
G3 X105.06 Y159.705 I-1.559 J.019 E.22234
G1 X105.178 Y159.699 E.00363
G3 X106.703 Y160.881 I.012 J1.559 E.06392
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.239 E-.13719
G1 X106.73 Y161.549 E-.11783
G1 X106.642 Y161.847 E-.118
G1 X106.576 Y161.988 E-.05921
G1 X106.405 Y162.247 E-.11798
G1 X106.185 Y162.466 E-.11808
G1 X105.984 Y162.6 E-.09171
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.177 Y163.548 Z6.4 F42000
G1 Z6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00026
G3 X105.11 Y158.971 I.018 J-2.289 E.21809
G1 X105.283 Y158.971 E.00534
G3 X105.622 Y163.506 I-.097 J2.287 E.20456
G1 X105.237 Y163.542 E.0119
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.026
G1 X104.827 Y163.519 E-.13005
G1 X104.387 Y163.401 E-.17325
G1 X103.979 Y163.198 E-.17334
G1 X103.62 Y162.919 E-.17261
G1 X103.474 Y162.75 E-.08475
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z6.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 30 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z6.4
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
            G0 Z6.4 F4000
            G39.3 S1
            G0 Z6.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer30 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.749 Y162.513 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381108
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00545
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.507 J.043 E.00482
G3 X103.874 Y162.657 I1.918 J.159 E.28572
G1 X103.788 Y162.558 E.00359
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09793
G1 X103.432 Y162.029 E-.14564
G1 X103.315 Y161.664 E-.14567
G1 X103.272 Y161.291 E-.1426
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06646
G1 X103.35 Y160.714 E-.14897
G1 X103.357 Y160.699 E-.00637
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.456 Z6.4 F42000
G1 Z6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.093 Y154.763 E.00947
G3 X102.404 Y153.228 I-1.559 J.019 E.22234
G1 X102.522 Y153.223 E.00363
G3 X104.047 Y154.405 I.012 J1.559 E.06392
; WIPE_START
G1 F12000
M204 S6000
G1 X104.093 Y154.763 E-.13719
G1 X104.074 Y155.072 E-.11783
G1 X103.986 Y155.37 E-.118
G1 X103.921 Y155.511 E-.05921
G1 X103.749 Y155.77 E-.11798
G1 X103.529 Y155.99 E-.11808
G1 X103.328 Y156.123 E-.09171
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.521 Y157.071 Z6.4 F42000
G1 Z6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00026
G3 X102.454 Y152.494 I.018 J-2.289 E.21809
G1 X102.628 Y152.495 E.00534
G3 X102.967 Y157.03 I-.097 J2.287 E.20456
G1 X102.581 Y157.066 E.0119
M204 S10000
G1 X102.549 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381108
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00089
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.507 J.043 E.00482
G3 X102.899 Y156.673 I1.918 J.159 E.2356
G1 X102.609 Y156.699 E.00802
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03501
G1 X102.15 Y156.667 E-.14054
G1 X101.86 Y156.583 E-.11445
G1 X101.517 Y156.412 E-.14569
G1 X101.218 Y156.18 E-.1438
G1 X100.964 Y155.886 E-.14748
G1 X100.922 Y155.811 E-.03302
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.193 Z6.4 F42000
G1 X101.411 Y147.979 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00947
G3 X99.749 Y146.751 I-1.559 J.019 E.22234
G1 X99.867 Y146.746 E.00363
G3 X101.392 Y147.928 I.012 J1.559 E.06392
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13719
G1 X101.419 Y148.596 E-.11783
G1 X101.331 Y148.893 E-.118
G1 X101.265 Y149.035 E-.05921
G1 X101.093 Y149.293 E-.11798
G1 X100.874 Y149.513 E-.11808
G1 X100.673 Y149.646 E-.09171
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.866 Y150.594 Z6.4 F42000
G1 Z6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00026
G3 X99.798 Y146.017 I.018 J-2.289 E.21809
G1 X99.972 Y146.018 E.00534
G3 X100.311 Y150.553 I-.097 J2.287 E.20456
G1 X99.925 Y150.589 E.0119
M204 S10000
G1 X99.894 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381108
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00089
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.507 J.043 E.00482
G3 X100.243 Y150.196 I1.918 J.159 E.2356
G1 X99.953 Y150.222 E.00802
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03501
G1 X99.494 Y150.19 E-.14054
G1 X99.205 Y150.106 E-.11445
G1 X98.861 Y149.935 E-.14569
G1 X98.562 Y149.703 E-.1438
G1 X98.309 Y149.41 E-.14748
G1 X98.266 Y149.334 E-.03302
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.716 Z6.4 F42000
G1 X98.756 Y141.502 Z6.4
G1 Z6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00947
G3 X97.093 Y140.274 I-1.559 J.019 E.22234
G1 X97.211 Y140.269 E.00363
G3 X98.736 Y141.451 I.012 J1.559 E.06392
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13719
G1 X98.763 Y142.119 E-.11783
G1 X98.675 Y142.417 E-.118
G1 X98.609 Y142.558 E-.05921
G1 X98.438 Y142.817 E-.11798
G1 X98.218 Y143.036 E-.11808
G1 X98.017 Y143.17 E-.09171
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.21 Y144.118 Z6.4 F42000
G1 Z6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00026
G3 X97.143 Y139.54 I.018 J-2.289 E.21809
G1 X97.317 Y139.541 E.00534
G3 X97.655 Y144.076 I-.097 J2.287 E.20456
G1 X97.27 Y144.112 E.0119
M204 S10000
G1 X97.238 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381108
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00089
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.507 J.043 E.00482
G3 X97.588 Y143.719 I1.918 J.159 E.2356
G1 X97.298 Y143.746 E.00802
; CHANGE_LAYER
; Z_HEIGHT: 6.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03501
G1 X96.838 Y143.713 E-.14054
G1 X96.549 Y143.629 E-.11445
G1 X96.206 Y143.459 E-.14569
G1 X95.907 Y143.227 E-.1438
G1 X95.653 Y142.933 E-.14748
G1 X95.611 Y142.857 E-.03302
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 31/60
; update layer progress
M73 L31
M991 S0 P30 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z6.4 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.932 Z6.4
G1 Z6.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.239 E.00948
G3 X105.06 Y159.705 I-1.559 J.019 E.22238
G1 X105.177 Y159.699 E.00359
G3 X106.703 Y160.882 I.013 J1.559 E.06396
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.239 E-.13713
G1 X106.73 Y161.549 E-.11786
G1 X106.642 Y161.847 E-.11801
G1 X106.497 Y162.122 E-.11808
G1 X106.327 Y162.333 E-.10308
G1 X106.123 Y162.514 E-.10357
G1 X105.982 Y162.598 E-.06226
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.175 Y163.548 Z6.6 F42000
G1 Z6.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.0002
G3 X105.11 Y158.971 I.018 J-2.289 E.21806
G1 X105.281 Y158.971 E.00528
G3 X105.567 Y163.516 I-.095 J2.287 E.20632
G1 X105.235 Y163.543 E.01024
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.0253
G1 X104.827 Y163.519 E-.13003
G1 X104.387 Y163.401 E-.17325
G1 X103.978 Y163.198 E-.17335
G1 X103.618 Y162.918 E-.17327
G1 X103.473 Y162.749 E-.08479
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z6.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 31 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z6.6
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
            G0 Z6.6 F4000
            G39.3 S1
            G0 Z6.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer31 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.748 Y162.512 F42000
G1 Z6.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.0054
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.51 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28585
G1 X103.787 Y162.557 E.00349
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09732
G1 X103.432 Y162.029 E-.14567
G1 X103.315 Y161.664 E-.14576
G1 X103.272 Y161.291 E-.14256
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.1489
G1 X103.357 Y160.697 E-.00692
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.455 Z6.6 F42000
G1 Z6.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.093 Y154.763 E.00948
G3 X102.404 Y153.228 I-1.559 J.019 E.22238
G1 X102.521 Y153.223 E.00359
G3 X104.047 Y154.405 I.013 J1.559 E.06396
; WIPE_START
G1 F12000
M204 S6000
G1 X104.093 Y154.763 E-.13713
G1 X104.074 Y155.072 E-.11786
G1 X103.986 Y155.37 E-.11801
M73 P87 R3
G1 X103.841 Y155.645 E-.11808
G1 X103.672 Y155.857 E-.10308
G1 X103.468 Y156.038 E-.10357
G1 X103.327 Y156.121 E-.06226
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.519 Y157.071 Z6.6 F42000
G1 Z6.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.0002
G3 X102.454 Y152.494 I.018 J-2.289 E.21806
G1 X102.626 Y152.495 E.00528
G3 X102.911 Y157.039 I-.095 J2.287 E.20632
G1 X102.579 Y157.066 E.01024
M204 S10000
G1 X102.552 Y156.703 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00095
G3 X100.617 Y154.814 I.024 J-1.924 E.08176
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.51 J.043 E.00482
G3 X102.853 Y156.681 I1.918 J.159 E.2369
G1 X102.612 Y156.699 E.00666
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03595
G1 X102.231 Y156.682 E-.10926
G1 X101.86 Y156.583 E-.14565
G1 X101.517 Y156.412 E-.1458
G1 X101.214 Y156.177 E-.14566
G1 X100.964 Y155.887 E-.14552
G1 X100.923 Y155.813 E-.03215
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.195 Z6.6 F42000
G1 X101.411 Y147.979 Z6.6
G1 Z6.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00948
G3 X99.749 Y146.751 I-1.559 J.019 E.22238
G1 X99.866 Y146.746 E.00359
G3 X101.391 Y147.928 I.013 J1.559 E.06396
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13713
G1 X101.419 Y148.596 E-.11786
G1 X101.331 Y148.894 E-.11801
G1 X101.186 Y149.168 E-.11808
G1 X101.016 Y149.38 E-.10308
G1 X100.812 Y149.561 E-.10357
G1 X100.671 Y149.644 E-.06226
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.864 Y150.595 Z6.6 F42000
G1 Z6.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.594 E.0002
G3 X99.798 Y146.017 I.018 J-2.289 E.21806
G1 X99.97 Y146.018 E.00528
G3 X100.256 Y150.562 I-.095 J2.287 E.20632
G1 X99.924 Y150.59 E.01024
M204 S10000
G1 X99.896 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00095
G3 X97.961 Y148.338 I.024 J-1.924 E.08176
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.51 J.043 E.00482
G3 X100.197 Y150.204 I1.918 J.159 E.2369
G1 X99.956 Y150.222 E.00666
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03595
G1 X99.575 Y150.205 E-.10926
G1 X99.205 Y150.106 E-.14565
G1 X98.861 Y149.935 E-.1458
G1 X98.559 Y149.7 E-.14566
G1 X98.309 Y149.41 E-.14552
G1 X98.267 Y149.336 E-.03215
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.718 Z6.6 F42000
G1 X98.756 Y141.502 Z6.6
G1 Z6.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00948
G3 X97.093 Y140.274 I-1.559 J.019 E.22238
G1 X97.21 Y140.269 E.00359
G3 X98.736 Y141.451 I.013 J1.559 E.06396
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13713
G1 X98.763 Y142.119 E-.11786
G1 X98.675 Y142.417 E-.11801
G1 X98.53 Y142.692 E-.11808
G1 X98.361 Y142.903 E-.10308
G1 X98.157 Y143.084 E-.10357
G1 X98.016 Y143.168 E-.06226
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.208 Y144.118 Z6.6 F42000
G1 Z6.2
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.117 E.0002
G3 X97.143 Y139.54 I.018 J-2.289 E.21806
G1 X97.315 Y139.541 E.00528
G3 X97.6 Y144.086 I-.095 J2.287 E.20632
G1 X97.268 Y144.113 E.01024
M204 S10000
G1 X97.241 Y143.75 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00095
G3 X95.305 Y141.861 I.024 J-1.924 E.08176
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.51 J.043 E.00482
G3 X97.542 Y143.728 I1.918 J.159 E.2369
G1 X97.3 Y143.746 E.00666
; CHANGE_LAYER
; Z_HEIGHT: 6.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03595
G1 X96.92 Y143.729 E-.10926
G1 X96.549 Y143.629 E-.14565
G1 X96.206 Y143.459 E-.1458
G1 X95.903 Y143.223 E-.14566
G1 X95.653 Y142.933 E-.14552
G1 X95.612 Y142.859 E-.03215
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 32/60
; update layer progress
M73 L32
M991 S0 P31 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z6.6 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.932 Z6.6
G1 Z6.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.239 E.00949
G3 X105.06 Y159.705 I-1.559 J.019 E.22238
G1 X105.176 Y159.699 E.00356
G3 X106.703 Y160.882 I.014 J1.559 E.06399
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.239 E-.13715
G1 X106.736 Y161.509 E-.10242
G1 X106.67 Y161.774 E-.10402
G1 X106.538 Y162.056 E-.11803
G1 X106.354 Y162.306 E-.11811
G1 X106.123 Y162.514 E-.11803
G1 X105.983 Y162.598 E-.06224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.173 Y163.548 Z6.8 F42000
G1 Z6.4
M73 P88 R3
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00014
G3 X105.11 Y158.971 I.018 J-2.289 E.21809
G1 X105.279 Y158.971 E.00521
G3 X105.622 Y163.506 I-.093 J2.288 E.20467
G1 X105.232 Y163.543 E.01203
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.02446
G1 X104.827 Y163.519 E-.13003
G1 X104.387 Y163.401 E-.17331
G1 X103.979 Y163.198 E-.17329
G1 X103.618 Y162.918 E-.17329
G1 X103.472 Y162.747 E-.08562
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z6.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 32 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z6.8
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
            G0 Z6.8 F4000
            G39.3 S1
            G0 Z6.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer32 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.747 Y162.51 F42000
G1 Z6.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38114
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00535
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.516 J.044 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.786 Y162.556 E.00356
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09655
G1 X103.432 Y162.029 E-.14571
G1 X103.315 Y161.664 E-.14581
G1 X103.272 Y161.291 E-.14241
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06656
G1 X103.35 Y160.714 E-.14881
G1 X103.358 Y160.695 E-.00776
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.455 Z6.8 F42000
G1 Z6.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.093 Y154.763 E.00949
G3 X102.404 Y153.228 I-1.559 J.019 E.22238
G1 X102.52 Y153.223 E.00356
G3 X104.047 Y154.405 I.014 J1.559 E.06399
; WIPE_START
G1 F12000
M204 S6000
G1 X104.093 Y154.763 E-.13715
G1 X104.081 Y155.032 E-.10242
G1 X104.014 Y155.297 E-.10402
G1 X103.883 Y155.579 E-.11803
G1 X103.698 Y155.829 E-.11811
G1 X103.468 Y156.037 E-.11803
G1 X103.327 Y156.121 E-.06224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.517 Y157.071 Z6.8 F42000
G1 Z6.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00014
G3 X102.454 Y152.494 I.018 J-2.289 E.21809
G1 X102.624 Y152.495 E.00521
G3 X102.967 Y157.03 I-.093 J2.288 E.20467
G1 X102.577 Y157.066 E.01203
M204 S10000
G1 X102.555 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38114
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00103
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.516 J.044 E.00483
G3 X102.813 Y156.687 I1.918 J.159 E.23804
G1 X102.614 Y156.7 E.00547
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03704
G1 X102.231 Y156.682 E-.10923
G1 X101.86 Y156.583 E-.14574
G1 X101.517 Y156.412 E-.14568
G1 X101.214 Y156.177 E-.14567
G1 X100.964 Y155.887 E-.14563
G1 X100.924 Y155.815 E-.03102
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.198 Z6.8 F42000
G1 X101.411 Y147.978 Z6.8
G1 Z6.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00949
G3 X99.749 Y146.751 I-1.559 J.019 E.22238
G1 X99.864 Y146.746 E.00356
G3 X101.392 Y147.928 I.014 J1.559 E.06399
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13715
G1 X101.425 Y148.555 E-.10242
G1 X101.358 Y148.821 E-.10402
G1 X101.227 Y149.102 E-.11803
G1 X101.043 Y149.352 E-.11811
G1 X100.812 Y149.561 E-.11803
G1 X100.671 Y149.644 E-.06224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.862 Y150.595 Z6.8 F42000
G1 Z6.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00014
G3 X99.798 Y146.017 I.018 J-2.289 E.21809
G1 X99.968 Y146.018 E.00521
G3 X100.311 Y150.553 I-.093 J2.288 E.20467
G1 X99.921 Y150.589 E.01203
M204 S10000
G1 X99.899 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38114
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00103
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.516 J.044 E.00483
G3 X100.157 Y150.21 I1.918 J.159 E.23804
G1 X99.959 Y150.223 E.00547
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03704
G1 X99.575 Y150.205 E-.10923
G1 X99.205 Y150.106 E-.14574
G1 X98.861 Y149.936 E-.14568
G1 X98.559 Y149.7 E-.14567
G1 X98.309 Y149.41 E-.14563
G1 X98.269 Y149.339 E-.03102
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.721 Z6.8 F42000
G1 X98.756 Y141.502 Z6.8
G1 Z6.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00949
G3 X97.093 Y140.275 I-1.559 J.019 E.22238
G1 X97.209 Y140.269 E.00356
G3 X98.736 Y141.451 I.014 J1.559 E.06399
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13715
G1 X98.77 Y142.079 E-.10242
G1 X98.703 Y142.344 E-.10402
G1 X98.572 Y142.626 E-.11803
G1 X98.387 Y142.876 E-.11811
G1 X98.157 Y143.084 E-.11803
G1 X98.016 Y143.168 E-.06224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.206 Y144.118 Z6.8 F42000
G1 Z6.4
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00014
G3 X97.143 Y139.54 I.018 J-2.289 E.21809
G1 X97.313 Y139.541 E.00521
G3 X97.655 Y144.076 I-.093 J2.288 E.20467
G1 X97.266 Y144.112 E.01203
M204 S10000
G1 X97.243 Y143.75 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38114
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00103
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.516 J.044 E.00483
G3 X97.501 Y143.734 I1.918 J.159 E.23804
G1 X97.303 Y143.746 E.00547
; CHANGE_LAYER
; Z_HEIGHT: 6.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03704
G1 X96.92 Y143.729 E-.10923
G1 X96.549 Y143.629 E-.14574
G1 X96.206 Y143.459 E-.14568
G1 X95.903 Y143.224 E-.14567
G1 X95.653 Y142.933 E-.14563
G1 X95.613 Y142.862 E-.03102
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 33/60
; update layer progress
M73 L33
M991 S0 P32 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z6.8 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.931 Z6.8
G1 Z6.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.24 E.00951
G3 X105.06 Y159.705 I-1.559 J.019 E.22236
G1 X105.174 Y159.699 E.00353
G3 X106.703 Y160.881 I.015 J1.559 E.06403
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.24 E-.13722
G1 X106.73 Y161.549 E-.11786
G1 X106.642 Y161.847 E-.11804
G1 X106.497 Y162.122 E-.11802
G1 X106.329 Y162.332 E-.10221
G1 X106.123 Y162.514 E-.10445
G1 X105.983 Y162.598 E-.0622
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.17 Y163.548 Z7 F42000
G1 Z6.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.168 Y163.548 E.00006
G3 X105.11 Y158.971 I.018 J-2.289 E.21811
G1 X105.277 Y158.971 E.00515
G3 X105.622 Y163.506 I-.091 J2.288 E.20471
G1 X105.23 Y163.543 E.01211
; WIPE_START
G1 F12000
M204 S6000
G1 X105.168 Y163.548 E-.0235
G1 X104.827 Y163.519 E-.13005
G1 X104.387 Y163.401 E-.17329
G1 X103.978 Y163.198 E-.17334
G1 X103.619 Y162.918 E-.17321
G1 X103.47 Y162.745 E-.08662
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z7 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 33 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z7
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
            G0 Z7 F4000
            G39.3 S1
            G0 Z7 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer33 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.745 Y162.508 F42000
G1 Z6.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00529
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.503 J.043 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.784 Y162.554 E.00363
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.0957
G1 X103.432 Y162.029 E-.1455
G1 X103.315 Y161.664 E-.14573
G1 X103.272 Y161.291 E-.14261
G1 X103.272 Y161.274 E-.00637
G1 X103.279 Y161.099 E-.06656
G1 X103.35 Y160.714 E-.14882
G1 X103.359 Y160.693 E-.0087
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.455 Z7 F42000
G1 Z6.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.093 Y154.763 E.00951
G3 X102.404 Y153.228 I-1.559 J.019 E.22236
G1 X102.519 Y153.223 E.00353
G3 X104.047 Y154.405 I.015 J1.559 E.06403
; WIPE_START
G1 F12000
M204 S6000
G1 X104.093 Y154.763 E-.13722
G1 X104.074 Y155.072 E-.11786
G1 X103.986 Y155.37 E-.11804
G1 X103.841 Y155.645 E-.11802
G1 X103.673 Y155.855 E-.10221
G1 X103.468 Y156.038 E-.10445
G1 X103.327 Y156.121 E-.0622
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.515 Y157.072 Z7 F42000
G1 Z6.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.513 Y157.071 E.00006
G3 X102.454 Y152.494 I.018 J-2.289 E.21811
G1 X102.622 Y152.494 E.00515
G3 X102.967 Y157.029 I-.091 J2.288 E.20471
G1 X102.574 Y157.066 E.01211
M204 S10000
G1 X102.553 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2316
M204 S6000
G1 X102.517 Y156.706 E.00099
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.503 J.043 E.00483
G3 X102.804 Y156.688 I1.918 J.159 E.23827
G1 X102.613 Y156.7 E.00528
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03647
G1 X102.231 Y156.682 E-.10931
G1 X101.86 Y156.583 E-.14567
G1 X101.517 Y156.412 E-.1457
G1 X101.214 Y156.177 E-.14561
G1 X100.964 Y155.886 E-.14577
G1 X100.924 Y155.814 E-.03147
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.196 Z7 F42000
G1 X101.411 Y147.978 Z7
G1 Z6.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00951
G3 X99.749 Y146.751 I-1.559 J.019 E.22236
G1 X99.863 Y146.746 E.00353
G3 X101.392 Y147.928 I.015 J1.559 E.06403
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13722
G1 X101.419 Y148.596 E-.11786
G1 X101.331 Y148.894 E-.11804
G1 X101.186 Y149.168 E-.11802
G1 X101.018 Y149.378 E-.10221
G1 X100.812 Y149.561 E-.10445
G1 X100.671 Y149.644 E-.0622
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.859 Y150.595 Z7 F42000
G1 Z6.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.857 Y150.595 E.00006
G3 X99.799 Y146.017 I.018 J-2.289 E.21811
G1 X99.966 Y146.018 E.00515
G3 X100.311 Y150.553 I-.091 J2.288 E.20471
G1 X99.919 Y150.589 E.01211
M204 S10000
G1 X99.898 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2316
M204 S6000
G1 X99.862 Y150.23 E.00099
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.503 J.043 E.00483
G3 X100.148 Y150.212 I1.918 J.159 E.23827
G1 X99.957 Y150.224 E.00528
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03647
G1 X99.575 Y150.205 E-.10931
G1 X99.205 Y150.106 E-.14567
G1 X98.861 Y149.935 E-.1457
G1 X98.559 Y149.7 E-.14561
G1 X98.309 Y149.41 E-.14577
G1 X98.268 Y149.337 E-.03147
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.72 Z7 F42000
G1 X98.755 Y141.501 Z7
G1 Z6.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00951
G3 X97.093 Y140.275 I-1.559 J.019 E.22236
G1 X97.208 Y140.269 E.00353
G3 X98.736 Y141.451 I.015 J1.559 E.06403
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13722
G1 X98.763 Y142.119 E-.11786
G1 X98.675 Y142.417 E-.11804
G1 X98.53 Y142.691 E-.11802
G1 X98.362 Y142.902 E-.10221
G1 X98.157 Y143.084 E-.10445
G1 X98.016 Y143.168 E-.0622
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.203 Y144.118 Z7 F42000
G1 Z6.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.202 Y144.118 E.00006
G3 X97.143 Y139.54 I.018 J-2.289 E.21811
G1 X97.311 Y139.541 E.00515
G3 X97.656 Y144.076 I-.091 J2.288 E.20471
G1 X97.263 Y144.113 E.01211
M204 S10000
G1 X97.242 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2316
M204 S6000
G1 X97.206 Y143.753 E.00099
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.503 J.043 E.00483
G3 X97.493 Y143.735 I1.918 J.159 E.23827
G1 X97.302 Y143.747 E.00528
; CHANGE_LAYER
; Z_HEIGHT: 6.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03647
G1 X96.919 Y143.729 E-.10931
G1 X96.549 Y143.629 E-.14567
G1 X96.206 Y143.459 E-.1457
G1 X95.903 Y143.224 E-.14561
G1 X95.653 Y142.933 E-.14577
G1 X95.613 Y142.861 E-.03147
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 34/60
; update layer progress
M73 L34
M991 S0 P33 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z7 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.931 Z7
G1 Z6.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.749 Y161.24 E.00952
G3 X105.06 Y159.705 I-1.559 J.019 E.22237
G1 X105.173 Y159.699 E.00349
G3 X106.703 Y160.881 I.016 J1.559 E.06407
; WIPE_START
G1 F12000
M204 S6000
G1 X106.749 Y161.24 E-.13718
G1 X106.73 Y161.549 E-.11776
G1 X106.642 Y161.847 E-.11813
G1 X106.52 Y162.085 E-.10171
G1 X106.354 Y162.306 E-.105
G1 X106.123 Y162.514 E-.11799
G1 X105.983 Y162.598 E-.06224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.167 Y163.549 Z7.2 F42000
G1 Z6.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X105.167 Y163.548 E.00003
G3 X105.11 Y158.971 I.019 J-2.289 E.21803
G1 X105.275 Y158.971 E.0051
G3 X105.511 Y163.524 I-.089 J2.287 E.20821
G1 X105.227 Y163.544 E.00875
; WIPE_START
G1 F12000
M204 S6000
G1 X105.167 Y163.548 E-.023
G1 X104.715 Y163.498 E-.17268
G1 X104.281 Y163.358 E-.17328
G1 X103.883 Y163.135 E-.17331
G1 X103.538 Y162.837 E-.17328
G1 X103.466 Y162.745 E-.04444
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z7.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 34 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z7.2
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
            G0 Z7.2 F4000
            G39.3 S1
            G0 Z7.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer34 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.743 Y162.506 F42000
G1 Z6.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381113
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.0052
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.502 J.043 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28585
G1 X103.782 Y162.552 E.0037
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09457
G1 X103.432 Y162.029 E-.14565
G1 X103.315 Y161.664 E-.14566
G1 X103.272 Y161.291 E-.14259
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06656
G1 X103.35 Y160.714 E-.14884
G1 X103.36 Y160.691 E-.00975
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.067 Y154.454 Z7.2 F42000
G1 Z6.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.093 Y154.763 E.00952
G3 X102.404 Y153.228 I-1.559 J.019 E.22237
G1 X102.518 Y153.223 E.00349
G3 X104.047 Y154.405 I.016 J1.559 E.06407
; WIPE_START
G1 F12000
M204 S6000
G1 X104.093 Y154.763 E-.13718
G1 X104.074 Y155.072 E-.11776
G1 X103.986 Y155.37 E-.11813
G1 X103.864 Y155.608 E-.10171
G1 X103.698 Y155.829 E-.105
G1 X103.468 Y156.037 E-.11799
G1 X103.327 Y156.121 E-.06224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.512 Y157.072 Z7.2 F42000
G1 Z6.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.511 Y157.071 E.00003
G3 X102.454 Y152.494 I.019 J-2.289 E.21803
G1 X102.62 Y152.494 E.0051
G3 X102.856 Y157.048 I-.089 J2.287 E.20821
G1 X102.572 Y157.068 E.00875
M204 S10000
G1 X102.55 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381113
G1 F2316
M204 S6000
G1 X102.513 Y156.706 E.00103
G3 X100.617 Y154.814 I.028 J-1.924 E.08165
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.502 J.043 E.00483
G3 X102.809 Y156.688 I1.918 J.159 E.23811
G1 X102.61 Y156.7 E.0055
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.513 Y156.706 E-.03698
G1 X102.222 Y156.681 E-.11083
G1 X101.852 Y156.58 E-.14576
G1 X101.517 Y156.412 E-.14242
G1 X101.214 Y156.177 E-.14574
G1 X100.964 Y155.886 E-.14561
G1 X100.922 Y155.811 E-.03267
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.194 Z7.2 F42000
G1 X101.411 Y147.977 Z7.2
G1 Z6.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.438 Y148.286 E.00952
G3 X99.749 Y146.751 I-1.559 J.019 E.22237
G1 X99.862 Y146.746 E.00349
G3 X101.392 Y147.928 I.016 J1.559 E.06407
; WIPE_START
G1 F12000
M204 S6000
G1 X101.438 Y148.286 E-.13718
G1 X101.419 Y148.595 E-.11776
G1 X101.331 Y148.894 E-.11813
G1 X101.209 Y149.132 E-.10171
G1 X101.042 Y149.352 E-.105
G1 X100.812 Y149.561 E-.11799
G1 X100.671 Y149.644 E-.06224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.856 Y150.595 Z7.2 F42000
G1 Z6.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.856 Y150.594 E.00003
G3 X99.798 Y146.017 I.019 J-2.289 E.21803
G1 X99.964 Y146.018 E.0051
M73 P89 R3
G3 X100.2 Y150.571 I-.089 J2.287 E.20821
G1 X99.916 Y150.591 E.00875
M204 S10000
G1 X99.895 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381113
G1 F2316
M204 S6000
G1 X99.857 Y150.23 E.00103
G3 X97.961 Y148.338 I.028 J-1.924 E.08165
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.502 J.043 E.00483
G3 X100.154 Y150.211 I1.918 J.159 E.23811
G1 X99.954 Y150.223 E.0055
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.857 Y150.23 E-.03698
G1 X99.567 Y150.204 E-.11083
G1 X99.197 Y150.103 E-.14576
G1 X98.861 Y149.936 E-.14242
G1 X98.559 Y149.7 E-.14574
G1 X98.309 Y149.41 E-.14561
G1 X98.267 Y149.335 E-.03267
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.717 Z7.2 F42000
G1 X98.755 Y141.501 Z7.2
G1 Z6.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.782 Y141.809 E.00952
G3 X97.093 Y140.275 I-1.559 J.019 E.22237
G1 X97.206 Y140.269 E.00349
G3 X98.736 Y141.451 I.016 J1.559 E.06407
; WIPE_START
G1 F12000
M204 S6000
G1 X98.782 Y141.809 E-.13718
G1 X98.763 Y142.119 E-.11776
G1 X98.675 Y142.417 E-.11813
G1 X98.553 Y142.655 E-.10171
G1 X98.387 Y142.876 E-.105
G1 X98.157 Y143.084 E-.11799
G1 X98.016 Y143.168 E-.06224
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.201 Y144.118 Z7.2 F42000
G1 Z6.8
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X97.2 Y144.117 E.00003
G3 X97.143 Y139.54 I.019 J-2.289 E.21803
G1 X97.309 Y139.541 E.0051
G3 X97.545 Y144.094 I-.089 J2.287 E.20821
G1 X97.26 Y144.114 E.00875
M204 S10000
G1 X97.239 Y143.75 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381113
G1 F2316
M204 S6000
G1 X97.202 Y143.753 E.00103
G3 X95.305 Y141.861 I.028 J-1.924 E.08165
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.502 J.043 E.00483
G3 X97.498 Y143.734 I1.918 J.159 E.23811
G1 X97.299 Y143.747 E.0055
; CHANGE_LAYER
; Z_HEIGHT: 7
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.202 Y143.753 E-.03698
G1 X96.911 Y143.727 E-.11083
G1 X96.541 Y143.626 E-.14576
G1 X96.206 Y143.459 E-.14242
G1 X95.903 Y143.223 E-.14574
G1 X95.653 Y142.933 E-.14561
G1 X95.611 Y142.858 E-.03267
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 35/60
; update layer progress
M73 L35
M991 S0 P34 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z7.2 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.93 Z7.2
G1 Z7
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.715 Y160.932 E.00024
G3 X105.06 Y159.705 I-1.525 J.326 E.23188
G1 X105.172 Y159.699 E.00346
G3 X106.62 Y160.638 I.018 J1.559 E.05619
G1 X106.702 Y160.873 E.00766
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.02291
G1 X106.757 Y161.239 E-.11783
G1 X106.73 Y161.549 E-.11811
G1 X106.658 Y161.805 E-.10125
G1 X106.538 Y162.056 E-.10539
G1 X106.354 Y162.306 E-.11806
G1 X106.123 Y162.514 E-.11808
G1 X105.991 Y162.593 E-.05837
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.165 Y163.548 Z7.4 F42000
G1 Z7
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.827 Y163.52 E.01041
G3 X105.11 Y158.971 I.359 J-2.261 E.20758
G1 X105.273 Y158.971 E.00503
G3 X105.225 Y163.548 I-.087 J2.288 E.21714
; WIPE_START
G1 F12000
M204 S6000
G1 X104.827 Y163.52 E-.15144
G1 X104.387 Y163.401 E-.17331
G1 X103.978 Y163.198 E-.17338
G1 X103.619 Y162.918 E-.17321
G1 X103.466 Y162.741 E-.08867
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z7.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 35 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z7.4
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
            G0 Z7.4 F4000
            G39.3 S1
            G0 Z7.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer35 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.741 Y162.504 F42000
G1 Z7
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381138
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.00513
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.534 J.044 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.781 Y162.55 E.00378
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09352
G1 X103.432 Y162.029 E-.1458
G1 X103.315 Y161.664 E-.14558
G1 X103.272 Y161.291 E-.14258
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06657
G1 X103.35 Y160.714 E-.14879
G1 X103.361 Y160.688 E-.01078
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.066 Y154.453 Z7.4 F42000
G1 Z7
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.059 Y154.456 E.00024
G3 X102.404 Y153.228 I-1.525 J.326 E.23188
G1 X102.516 Y153.223 E.00346
G3 X103.965 Y154.161 I.018 J1.559 E.05619
G1 X104.047 Y154.396 E.00766
; WIPE_START
G1 F12000
M204 S6000
G1 X104.059 Y154.456 E-.02291
G1 X104.101 Y154.763 E-.11783
G1 X104.074 Y155.072 E-.11811
G1 X104.002 Y155.329 E-.10125
G1 X103.883 Y155.579 E-.10539
G1 X103.698 Y155.829 E-.11806
G1 X103.468 Y156.038 E-.11808
G1 X103.336 Y156.116 E-.05837
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.509 Y157.072 Z7.4 F42000
G1 Z7
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.172 Y157.043 E.01041
G3 X102.454 Y152.494 I.359 J-2.261 E.20758
G1 X102.618 Y152.494 E.00503
G3 X102.569 Y157.071 I-.087 J2.288 E.21714
M204 S10000
G1 X102.547 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381138
G1 F2326
M204 S6000
G1 X102.517 Y156.706 E.00081
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.534 J.044 E.00483
G3 X102.813 Y156.687 I1.918 J.159 E.23803
G1 X102.607 Y156.7 E.00569
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.034
G1 X102.231 Y156.682 E-.10925
G1 X101.861 Y156.583 E-.14565
G1 X101.517 Y156.412 E-.14584
G1 X101.214 Y156.177 E-.14555
G1 X100.964 Y155.887 E-.14564
G1 X100.921 Y155.808 E-.03407
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.191 Z7.4 F42000
G1 X101.411 Y147.976 Z7.4
G1 Z7
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.403 Y147.979 E.00024
G3 X99.748 Y146.751 I-1.525 J.326 E.23188
G1 X99.861 Y146.746 E.00346
G3 X101.309 Y147.684 I.018 J1.559 E.05619
G1 X101.391 Y147.92 E.00766
; WIPE_START
G1 F12000
M204 S6000
G1 X101.403 Y147.979 E-.02291
G1 X101.446 Y148.286 E-.11783
G1 X101.419 Y148.596 E-.11811
G1 X101.346 Y148.852 E-.10125
G1 X101.227 Y149.102 E-.10539
G1 X101.043 Y149.352 E-.11806
G1 X100.812 Y149.561 E-.11808
G1 X100.68 Y149.639 E-.05837
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.854 Y150.595 Z7.4 F42000
G1 Z7
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.516 Y150.566 E.01041
G3 X99.798 Y146.017 I.359 J-2.261 E.20758
G1 X99.962 Y146.018 E.00503
G3 X99.914 Y150.594 I-.087 J2.288 E.21714
M204 S10000
G1 X99.891 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381138
G1 F2326
M204 S6000
G1 X99.862 Y150.23 E.00081
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.534 J.044 E.00483
G3 X100.157 Y150.21 I1.918 J.159 E.23803
G1 X99.951 Y150.224 E.00569
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.034
G1 X99.575 Y150.205 E-.10925
G1 X99.205 Y150.106 E-.14565
G1 X98.861 Y149.935 E-.14584
G1 X98.559 Y149.7 E-.14555
G1 X98.309 Y149.41 E-.14564
G1 X98.265 Y149.332 E-.03407
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.714 Z7.4 F42000
G1 X98.755 Y141.5 Z7.4
G1 Z7
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.748 Y141.502 E.00024
G3 X97.093 Y140.275 I-1.525 J.326 E.23188
G1 X97.205 Y140.269 E.00346
G3 X98.653 Y141.208 I.018 J1.559 E.05619
G1 X98.735 Y141.443 E.00766
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02291
G1 X98.79 Y141.809 E-.11783
G1 X98.763 Y142.119 E-.11811
G1 X98.691 Y142.375 E-.10125
G1 X98.571 Y142.626 E-.10539
G1 X98.387 Y142.876 E-.11806
G1 X98.157 Y143.084 E-.11808
G1 X98.024 Y143.163 E-.05837
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.198 Y144.118 Z7.4 F42000
G1 Z7
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.86 Y144.09 E.01041
G3 X97.143 Y139.54 I.359 J-2.261 E.20758
G1 X97.307 Y139.541 E.00503
G3 X97.258 Y144.118 I-.087 J2.288 E.21714
M204 S10000
G1 X97.235 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381138
G1 F2326
M204 S6000
G1 X97.206 Y143.753 E.00081
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.534 J.044 E.00483
G3 X97.501 Y143.734 I1.918 J.159 E.23803
G1 X97.295 Y143.747 E.00569
; CHANGE_LAYER
; Z_HEIGHT: 7.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.034
G1 X96.92 Y143.729 E-.10925
G1 X96.549 Y143.629 E-.14565
G1 X96.206 Y143.459 E-.14584
G1 X95.903 Y143.224 E-.14555
G1 X95.653 Y142.933 E-.14564
G1 X95.609 Y142.855 E-.03407
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 36/60
; update layer progress
M73 L36
M991 S0 P35 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z7.4 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.929 Z7.4
G1 Z7.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.714 Y160.932 E.00024
G3 X105.06 Y159.705 I-1.525 J.326 E.23188
G1 X105.171 Y159.699 E.00342
G3 X106.62 Y160.638 I.019 J1.559 E.05622
G1 X106.702 Y160.873 E.00765
; WIPE_START
G1 F12000
M204 S6000
G1 X106.714 Y160.932 E-.02307
G1 X106.757 Y161.239 E-.11786
G1 X106.737 Y161.504 E-.10083
G1 X106.67 Y161.774 E-.10588
G1 X106.538 Y162.056 E-.11802
G1 X106.354 Y162.306 E-.11814
G1 X106.124 Y162.514 E-.11791
G1 X105.992 Y162.592 E-.05829
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.161 Y163.548 Z7.6 F42000
G1 Z7.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.715 Y163.499 E.0138
G3 X105.11 Y158.971 I.471 J-2.24 E.20405
G1 X105.271 Y158.971 E.00497
G3 X105.221 Y163.547 I-.085 J2.288 E.21727
; WIPE_START
G1 F12000
M204 S6000
G1 X104.715 Y163.499 E-.19329
G1 X104.281 Y163.358 E-.17331
G1 X103.883 Y163.135 E-.17327
G1 X103.618 Y162.918 E-.13009
G1 X103.464 Y162.738 E-.09004
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z7.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 36 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z7.6
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
            G0 Z7.6 F4000
            G39.3 S1
            G0 Z7.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer36 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.739 Y162.502 F42000
G1 Z7.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.00503
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.509 J.043 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28585
G1 X103.778 Y162.547 E.00387
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09212
G1 X103.432 Y162.029 E-.1457
G1 X103.315 Y161.664 E-.14568
G1 X103.272 Y161.291 E-.14259
G1 X103.272 Y161.274 E-.00637
G1 X103.279 Y161.099 E-.06655
G1 X103.35 Y160.715 E-.14877
G1 X103.362 Y160.685 E-.01222
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.066 Y154.453 Z7.6 F42000
G1 Z7.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.059 Y154.455 E.00024
G3 X102.404 Y153.228 I-1.525 J.326 E.23188
G1 X102.515 Y153.223 E.00342
G3 X103.964 Y154.161 I.019 J1.559 E.05622
G1 X104.046 Y154.396 E.00765
; WIPE_START
G1 F12000
M204 S6000
G1 X104.059 Y154.455 E-.02307
G1 X104.101 Y154.763 E-.11786
G1 X104.082 Y155.027 E-.10083
G1 X104.014 Y155.298 E-.10588
G1 X103.883 Y155.579 E-.11802
G1 X103.698 Y155.829 E-.11814
G1 X103.468 Y156.037 E-.11791
G1 X103.336 Y156.116 E-.05829
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.506 Y157.071 Z7.6 F42000
G1 Z7.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.059 Y157.022 E.0138
G3 X102.454 Y152.494 I.471 J-2.24 E.20405
G1 X102.616 Y152.494 E.00497
G3 X102.566 Y157.071 I-.085 J2.288 E.21727
M204 S10000
G1 X102.534 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2326
M204 S6000
G1 X102.517 Y156.706 E.00045
G3 X100.617 Y154.814 I.024 J-1.924 E.08176
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.509 J.043 E.00483
G3 X102.899 Y156.673 I1.918 J.159 E.23559
G1 X102.593 Y156.699 E.00846
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.02906
G1 X102.231 Y156.682 E-.10932
G1 X101.86 Y156.583 E-.1457
G1 X101.517 Y156.412 E-.14554
G1 X101.214 Y156.177 E-.14579
G1 X100.964 Y155.887 E-.14557
G1 X100.914 Y155.797 E-.03902
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.18 Z7.6 F42000
G1 X101.411 Y147.976 Z7.6
G1 Z7.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.403 Y147.979 E.00024
G3 X99.748 Y146.751 I-1.525 J.326 E.23188
G1 X99.86 Y146.746 E.00342
G3 X101.309 Y147.684 I.019 J1.559 E.05622
G1 X101.391 Y147.919 E.00765
; WIPE_START
G1 F12000
M204 S6000
G1 X101.403 Y147.979 E-.02307
G1 X101.446 Y148.286 E-.11786
G1 X101.426 Y148.551 E-.10083
G1 X101.358 Y148.821 E-.10588
G1 X101.227 Y149.102 E-.11802
G1 X101.042 Y149.352 E-.11814
G1 X100.812 Y149.561 E-.11791
G1 X100.68 Y149.639 E-.05829
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.85 Y150.594 Z7.6 F42000
G1 Z7.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.404 Y150.545 E.0138
G3 X99.798 Y146.017 I.471 J-2.24 E.20405
G1 X99.96 Y146.017 E.00497
G3 X99.91 Y150.594 I-.085 J2.288 E.21727
M204 S10000
G1 X99.878 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2326
M204 S6000
G1 X99.862 Y150.23 E.00045
G3 X97.961 Y148.338 I.024 J-1.924 E.08176
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.509 J.043 E.00483
G3 X100.244 Y150.196 I1.918 J.159 E.23559
G1 X99.938 Y150.223 E.00846
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.02906
G1 X99.575 Y150.205 E-.10932
G1 X99.205 Y150.106 E-.1457
G1 X98.862 Y149.936 E-.14554
G1 X98.559 Y149.7 E-.14579
G1 X98.309 Y149.41 E-.14557
G1 X98.259 Y149.32 E-.03902
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.703 Z7.6 F42000
G1 X98.755 Y141.499 Z7.6
G1 Z7.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.748 Y141.502 E.00024
G3 X97.093 Y140.275 I-1.525 J.326 E.23188
G1 X97.204 Y140.269 E.00342
G3 X98.653 Y141.208 I.019 J1.559 E.05622
G1 X98.735 Y141.443 E.00765
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02307
G1 X98.79 Y141.809 E-.11786
G1 X98.77 Y142.074 E-.10083
G1 X98.703 Y142.344 E-.10588
G1 X98.571 Y142.626 E-.11802
G1 X98.387 Y142.876 E-.11814
G1 X98.157 Y143.084 E-.11791
G1 X98.025 Y143.162 E-.05829
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.195 Y144.118 Z7.6 F42000
G1 Z7.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.748 Y144.069 E.0138
G3 X97.143 Y139.54 I.471 J-2.24 E.20405
G1 X97.305 Y139.541 E.00497
G3 X97.254 Y144.117 I-.085 J2.288 E.21727
M204 S10000
G1 X97.222 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38111
G1 F2326
M204 S6000
G1 X97.206 Y143.753 E.00045
G3 X95.305 Y141.861 I.024 J-1.924 E.08176
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.509 J.043 E.00483
G3 X97.588 Y143.719 I1.918 J.159 E.23559
G1 X97.282 Y143.746 E.00846
; CHANGE_LAYER
; Z_HEIGHT: 7.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02906
G1 X96.919 Y143.729 E-.10932
G1 X96.549 Y143.629 E-.1457
G1 X96.206 Y143.459 E-.14554
G1 X95.903 Y143.223 E-.14579
G1 X95.653 Y142.933 E-.14557
G1 X95.603 Y142.844 E-.03902
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 37/60
; update layer progress
M73 L37
M991 S0 P36 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z7.6 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.929 Z7.6
G1 Z7.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X106.715 Y160.932 E.00024
G3 X105.06 Y159.705 I-1.525 J.326 E.23188
G1 X105.17 Y159.699 E.00339
G3 X106.62 Y160.638 I.02 J1.559 E.05627
G1 X106.702 Y160.872 E.00763
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.02327
G1 X106.757 Y161.239 E-.11786
G1 X106.737 Y161.503 E-.10037
G1 X106.67 Y161.774 E-.10627
G1 X106.538 Y162.056 E-.11809
G1 X106.354 Y162.306 E-.11808
G1 X106.123 Y162.514 E-.11808
G1 X105.992 Y162.592 E-.05798
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.158 Y163.547 Z7.8 F42000
G1 Z7.4
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X104.715 Y163.499 E.01369
G3 X105.11 Y158.971 I.471 J-2.24 E.20407
G1 X105.269 Y158.971 E.00491
G3 X105.218 Y163.548 I-.083 J2.288 E.21748
; WIPE_START
G1 F12000
M204 S6000
G1 X104.715 Y163.499 E-.19192
G1 X104.281 Y163.358 E-.17329
G1 X103.883 Y163.135 E-.17333
G1 X103.619 Y162.918 E-.13004
G1 X103.462 Y162.736 E-.09143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z7.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 37 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z7.8
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
            G0 Z7.8 F4000
            G39.3 S1
            G0 Z7.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer37 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.737 Y162.499 F42000
G1 Z7.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381138
G1 F2325
M204 S6000
G1 X103.62 Y162.363 E.00494
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.497 J.043 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.776 Y162.544 E.00397
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.09094
G1 X103.432 Y162.029 E-.14555
G1 X103.315 Y161.664 E-.14565
G1 X103.272 Y161.291 E-.1426
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06657
G1 X103.35 Y160.714 E-.14884
G1 X103.364 Y160.681 E-.01347
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.066 Y154.452 Z7.8 F42000
G1 Z7.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X104.059 Y154.455 E.00024
G3 X102.404 Y153.228 I-1.525 J.326 E.23188
G1 X102.514 Y153.223 E.00339
G3 X103.965 Y154.161 I.02 J1.559 E.05627
G1 X104.046 Y154.396 E.00763
; WIPE_START
G1 F12000
M204 S6000
G1 X104.059 Y154.455 E-.02327
G1 X104.101 Y154.763 E-.11786
G1 X104.082 Y155.026 E-.10037
G1 X104.014 Y155.297 E-.10627
G1 X103.883 Y155.579 E-.11809
G1 X103.698 Y155.829 E-.11808
G1 X103.468 Y156.038 E-.11808
G1 X103.337 Y156.115 E-.05798
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.502 Y157.071 Z7.8 F42000
G1 Z7.4
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X102.059 Y157.022 E.01369
G3 X102.454 Y152.494 I.471 J-2.24 E.20407
G1 X102.614 Y152.494 E.00491
G3 X102.562 Y157.071 I-.083 J2.288 E.21748
M204 S10000
G1 X102.541 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381138
G1 F2325
M204 S6000
G1 X102.517 Y156.706 E.00064
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
M73 P90 R3
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.497 J.043 E.00483
G3 X102.804 Y156.688 I1.918 J.159 E.23827
G1 X102.6 Y156.701 E.00562
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.03166
G1 X102.223 Y156.681 E-.11244
G1 X101.852 Y156.58 E-.14573
G1 X101.517 Y156.412 E-.14248
G1 X101.214 Y156.177 E-.14567
G1 X100.964 Y155.886 E-.14576
G1 X100.917 Y155.803 E-.03628
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.186 Z7.8 F42000
G1 X101.41 Y147.975 Z7.8
G1 Z7.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X101.403 Y147.979 E.00024
G3 X99.748 Y146.751 I-1.525 J.326 E.23188
G1 X99.858 Y146.746 E.00339
G3 X101.309 Y147.684 I.02 J1.559 E.05627
G1 X101.391 Y147.919 E.00763
; WIPE_START
G1 F12000
M204 S6000
G1 X101.403 Y147.979 E-.02327
G1 X101.446 Y148.286 E-.11786
G1 X101.426 Y148.549 E-.10037
G1 X101.358 Y148.821 E-.10627
G1 X101.227 Y149.102 E-.11809
G1 X101.043 Y149.352 E-.11808
G1 X100.812 Y149.561 E-.11808
G1 X100.681 Y149.639 E-.05798
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.846 Y150.594 Z7.8 F42000
G1 Z7.4
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X99.404 Y150.546 E.01369
G3 X99.799 Y146.017 I.471 J-2.24 E.20407
G1 X99.958 Y146.017 E.00491
G3 X99.906 Y150.594 I-.083 J2.288 E.21748
M204 S10000
G1 X99.885 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381138
G1 F2325
M204 S6000
G1 X99.862 Y150.23 E.00064
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.497 J.043 E.00483
G3 X100.148 Y150.212 I1.918 J.159 E.23827
G1 X99.945 Y150.224 E.00562
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.03166
G1 X99.567 Y150.204 E-.11244
G1 X99.197 Y150.103 E-.14573
G1 X98.861 Y149.936 E-.14248
G1 X98.559 Y149.7 E-.14567
G1 X98.309 Y149.41 E-.14576
G1 X98.262 Y149.326 E-.03628
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.709 Z7.8 F42000
G1 X98.755 Y141.499 Z7.8
G1 Z7.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X98.748 Y141.502 E.00024
G3 X97.093 Y140.275 I-1.525 J.326 E.23188
G1 X97.203 Y140.269 E.00339
G3 X98.653 Y141.208 I.02 J1.559 E.05627
G1 X98.735 Y141.442 E.00763
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02327
G1 X98.79 Y141.809 E-.11786
G1 X98.771 Y142.073 E-.10037
G1 X98.703 Y142.344 E-.10627
G1 X98.571 Y142.626 E-.11809
G1 X98.387 Y142.876 E-.11808
G1 X98.157 Y143.084 E-.11808
G1 X98.025 Y143.162 E-.05798
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.191 Y144.117 Z7.8 F42000
G1 Z7.4
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X96.748 Y144.069 E.01369
G3 X97.143 Y139.54 I.471 J-2.24 E.20407
G1 X97.303 Y139.541 E.00491
G3 X97.251 Y144.118 I-.083 J2.288 E.21748
M204 S10000
G1 X97.229 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381138
G1 F2325
M204 S6000
G1 X97.206 Y143.753 E.00064
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.497 J.043 E.00483
G3 X97.493 Y143.735 I1.918 J.159 E.23827
G1 X97.289 Y143.748 E.00562
; CHANGE_LAYER
; Z_HEIGHT: 7.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.03166
G1 X96.911 Y143.727 E-.11244
G1 X96.541 Y143.626 E-.14573
G1 X96.206 Y143.459 E-.14248
G1 X95.903 Y143.224 E-.14567
G1 X95.653 Y142.933 E-.14576
G1 X95.606 Y142.85 E-.03628
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 38/60
; update layer progress
M73 L38
M991 S0 P37 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z7.8 I-1.037 J.637 P1  F42000
G1 X106.722 Y160.928 Z7.8
G1 Z7.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X106.715 Y160.932 E.00024
G3 X105.06 Y159.705 I-1.525 J.326 E.23187
G1 X105.168 Y159.699 E.00335
G3 X106.62 Y160.638 I.022 J1.559 E.05631
G1 X106.702 Y160.872 E.00761
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.02348
G1 X106.757 Y161.239 E-.11785
G1 X106.73 Y161.549 E-.1181
G1 X106.642 Y161.847 E-.11804
G1 X106.522 Y162.081 E-.09992
G1 X106.354 Y162.306 E-.10675
G1 X106.123 Y162.514 E-.11808
G1 X105.993 Y162.592 E-.05779
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.154 Y163.547 Z8 F42000
G1 Z7.6
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X104.827 Y163.52 E.01008
G3 X105.11 Y158.971 I.359 J-2.261 E.20759
G1 X105.267 Y158.971 E.00484
G3 X105.214 Y163.548 I-.081 J2.288 E.21764
; WIPE_START
G1 F12000
M204 S6000
G1 X104.827 Y163.52 E-.14738
G1 X104.387 Y163.401 E-.17328
G1 X103.979 Y163.198 E-.17329
G1 X103.619 Y162.918 E-.17334
G1 X103.459 Y162.733 E-.09271
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 38 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z8
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
            G0 Z8 F4000
            G39.3 S1
            G0 Z8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer38 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.735 Y162.496 F42000
G1 Z7.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2325
M204 S6000
G1 X103.62 Y162.363 E.00485
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.515 J.044 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.774 Y162.542 E.00406
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.08962
G1 X103.432 Y162.029 E-.14558
G1 X103.315 Y161.664 E-.14575
G1 X103.272 Y161.291 E-.14252
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06658
G1 X103.35 Y160.714 E-.14879
G1 X103.365 Y160.678 E-.0148
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.066 Y154.452 Z8 F42000
G1 Z7.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X104.059 Y154.455 E.00024
G3 X102.404 Y153.228 I-1.525 J.326 E.23187
G1 X102.513 Y153.223 E.00335
G3 X103.965 Y154.161 I.022 J1.559 E.05631
G1 X104.046 Y154.395 E.00761
; WIPE_START
G1 F12000
M204 S6000
G1 X104.059 Y154.455 E-.02348
G1 X104.101 Y154.763 E-.11785
G1 X104.074 Y155.072 E-.1181
G1 X103.986 Y155.37 E-.11804
G1 X103.867 Y155.604 E-.09992
G1 X103.698 Y155.829 E-.10675
G1 X103.468 Y156.038 E-.11808
G1 X103.337 Y156.115 E-.05779
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.499 Y157.071 Z8 F42000
G1 Z7.6
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X102.172 Y157.043 E.01008
G3 X102.454 Y152.494 I.359 J-2.261 E.20759
G1 X102.612 Y152.494 E.00484
G3 X102.559 Y157.071 I-.081 J2.288 E.21764
M204 S10000
G1 X102.536 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2325
M204 S6000
G1 X102.517 Y156.706 E.00052
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.515 J.044 E.00483
G3 X102.813 Y156.687 I1.918 J.159 E.23803
G1 X102.596 Y156.701 E.00598
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.02994
G1 X102.231 Y156.682 E-.10928
G1 X101.861 Y156.583 E-.14563
G1 X101.517 Y156.412 E-.14565
G1 X101.214 Y156.177 E-.14584
G1 X100.964 Y155.886 E-.14566
G1 X100.915 Y155.799 E-.038
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.182 Z8 F42000
G1 X101.41 Y147.975 Z8
G1 Z7.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X101.404 Y147.979 E.00024
G3 X99.748 Y146.751 I-1.525 J.326 E.23187
G1 X99.857 Y146.746 E.00335
G3 X101.309 Y147.684 I.022 J1.559 E.05631
G1 X101.391 Y147.918 E.00761
; WIPE_START
G1 F12000
M204 S6000
G1 X101.404 Y147.979 E-.02348
G1 X101.446 Y148.286 E-.11785
G1 X101.419 Y148.596 E-.1181
G1 X101.331 Y148.894 E-.11804
G1 X101.211 Y149.128 E-.09992
G1 X101.043 Y149.352 E-.10675
G1 X100.812 Y149.561 E-.11808
G1 X100.681 Y149.638 E-.05779
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.843 Y150.594 Z8 F42000
G1 Z7.6
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X99.516 Y150.566 E.01008
G3 X99.799 Y146.017 I.359 J-2.261 E.20759
G1 X99.956 Y146.017 E.00484
G3 X99.903 Y150.595 I-.081 J2.288 E.21764
M204 S10000
G1 X99.88 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2325
M204 S6000
G1 X99.862 Y150.23 E.00052
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.515 J.044 E.00483
G3 X100.157 Y150.21 I1.918 J.159 E.23803
G1 X99.94 Y150.224 E.00598
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.02994
G1 X99.575 Y150.205 E-.10928
G1 X99.205 Y150.106 E-.14563
G1 X98.862 Y149.936 E-.14565
G1 X98.559 Y149.7 E-.14584
G1 X98.309 Y149.41 E-.14566
G1 X98.26 Y149.322 E-.038
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.705 Z8 F42000
G1 X98.755 Y141.498 Z8
G1 Z7.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X98.748 Y141.502 E.00024
G3 X97.093 Y140.275 I-1.525 J.326 E.23187
G1 X97.202 Y140.269 E.00335
G3 X98.654 Y141.208 I.022 J1.559 E.05631
G1 X98.735 Y141.442 E.00761
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02348
G1 X98.79 Y141.809 E-.11785
G1 X98.763 Y142.119 E-.1181
G1 X98.675 Y142.417 E-.11804
G1 X98.555 Y142.651 E-.09992
G1 X98.387 Y142.876 E-.10675
G1 X98.157 Y143.084 E-.11808
G1 X98.026 Y143.162 E-.05779
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.187 Y144.117 Z8 F42000
G1 Z7.6
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X96.861 Y144.09 E.01008
G3 X97.143 Y139.54 I.359 J-2.261 E.20759
G1 X97.301 Y139.541 E.00484
G3 X97.247 Y144.118 I-.081 J2.288 E.21764
M204 S10000
G1 X97.225 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2325
M204 S6000
G1 X97.206 Y143.753 E.00052
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.515 J.044 E.00483
G3 X97.501 Y143.734 I1.918 J.159 E.23803
G1 X97.285 Y143.748 E.00598
; CHANGE_LAYER
; Z_HEIGHT: 7.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02994
G1 X96.92 Y143.729 E-.10928
G1 X96.549 Y143.63 E-.14563
G1 X96.206 Y143.459 E-.14565
G1 X95.903 Y143.223 E-.14584
G1 X95.653 Y142.933 E-.14566
G1 X95.604 Y142.846 E-.038
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 39/60
; update layer progress
M73 L39
M991 S0 P38 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z8 I-1.037 J.637 P1  F42000
G1 X106.721 Y160.928 Z8
G1 Z7.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X106.715 Y160.932 E.00024
G3 X105.059 Y159.705 I-1.525 J.326 E.23187
G1 X105.167 Y159.699 E.00331
G3 X106.62 Y160.638 I.023 J1.559 E.05634
G1 X106.702 Y160.871 E.0076
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.02369
G1 X106.757 Y161.239 E-.11785
G1 X106.738 Y161.5 E-.09947
G1 X106.67 Y161.774 E-.1072
G1 X106.538 Y162.056 E-.11805
G1 X106.354 Y162.306 E-.11808
G1 X106.123 Y162.514 E-.1181
G1 X105.993 Y162.592 E-.05756
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.15 Y163.546 Z8.2 F42000
G1 Z7.8
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X104.715 Y163.499 E.01344
G3 X105.11 Y158.971 I.471 J-2.24 E.20408
G1 X105.265 Y158.971 E.00478
G3 X105.209 Y163.548 I-.079 J2.288 E.21784
; WIPE_START
G1 F12000
M204 S6000
G1 X104.715 Y163.499 E-.18888
G1 X104.387 Y163.401 E-.13009
G1 X103.978 Y163.198 E-.17333
G1 X103.619 Y162.918 E-.17321
G1 X103.456 Y162.73 E-.09449
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z8.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 39 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z8.2
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
            G0 Z8.2 F4000
            G39.3 S1
            G0 Z8.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer39 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.731 Y162.493 F42000
G1 Z7.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2325
M204 S6000
G1 X103.62 Y162.363 E.00471
G3 X103.272 Y161.291 I1.576 J-1.104 E.03153
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.502 J.043 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.771 Y162.538 E.0042
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.08768
G1 X103.432 Y162.029 E-.14575
G1 X103.315 Y161.664 E-.14564
G1 X103.272 Y161.291 E-.14261
G1 X103.272 Y161.274 E-.00637
G1 X103.279 Y161.099 E-.06655
G1 X103.35 Y160.715 E-.14874
G1 X103.367 Y160.674 E-.01665
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.066 Y154.451 Z8.2 F42000
G1 Z7.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X104.059 Y154.455 E.00024
G3 X102.404 Y153.228 I-1.525 J.326 E.23187
G1 X102.512 Y153.223 E.00331
G3 X103.965 Y154.161 I.023 J1.559 E.05634
G1 X104.046 Y154.395 E.0076
; WIPE_START
G1 F12000
M204 S6000
G1 X104.059 Y154.455 E-.02369
G1 X104.101 Y154.763 E-.11785
G1 X104.082 Y155.024 E-.09947
G1 X104.014 Y155.297 E-.1072
G1 X103.883 Y155.579 E-.11805
G1 X103.698 Y155.829 E-.11808
G1 X103.468 Y156.038 E-.1181
G1 X103.337 Y156.115 E-.05756
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.494 Y157.07 Z8.2 F42000
G1 Z7.8
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X102.059 Y157.022 E.01344
G3 X102.454 Y152.494 I.471 J-2.24 E.20408
G1 X102.61 Y152.494 E.00478
G3 X102.554 Y157.071 I-.079 J2.288 E.21784
M204 S10000
G1 X102.532 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2325
M204 S6000
G1 X102.517 Y156.706 E.00042
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.502 J.043 E.00483
G3 X102.804 Y156.688 I1.918 J.159 E.23826
G1 X102.592 Y156.701 E.00585
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.02858
G1 X102.231 Y156.682 E-.10931
G1 X101.86 Y156.583 E-.14567
G1 X101.517 Y156.412 E-.14571
G1 X101.214 Y156.177 E-.14565
G1 X100.964 Y155.887 E-.14557
G1 X100.914 Y155.796 E-.03951
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.179 Z8.2 F42000
G1 X101.41 Y147.974 Z8.2
G1 Z7.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X101.403 Y147.979 E.00024
G3 X99.748 Y146.751 I-1.525 J.326 E.23187
G1 X99.856 Y146.746 E.00331
G3 X101.309 Y147.684 I.023 J1.559 E.05634
G1 X101.39 Y147.918 E.0076
; WIPE_START
G1 F12000
M204 S6000
G1 X101.403 Y147.979 E-.02369
G1 X101.446 Y148.286 E-.11785
G1 X101.427 Y148.547 E-.09947
G1 X101.358 Y148.821 E-.1072
G1 X101.227 Y149.102 E-.11805
M73 P90 R2
G1 X101.043 Y149.352 E-.11808
G1 X100.812 Y149.561 E-.1181
G1 X100.682 Y149.638 E-.05756
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.838 Y150.593 Z8.2 F42000
G1 Z7.8
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X99.404 Y150.546 E.01344
G3 X99.799 Y146.017 I.471 J-2.24 E.20408
G1 X99.954 Y146.017 E.00478
G3 X99.898 Y150.595 I-.079 J2.288 E.21784
M204 S10000
G1 X99.877 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2325
M204 S6000
G1 X99.862 Y150.23 E.00042
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.502 J.043 E.00483
G3 X100.149 Y150.212 I1.918 J.159 E.23826
G1 X99.937 Y150.225 E.00585
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.02858
G1 X99.575 Y150.205 E-.10931
G1 X99.205 Y150.106 E-.14567
G1 X98.861 Y149.935 E-.14571
G1 X98.559 Y149.7 E-.14565
G1 X98.309 Y149.41 E-.14557
G1 X98.258 Y149.319 E-.03951
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.702 Z8.2 F42000
G1 X98.755 Y141.498 Z8.2
G1 Z7.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2325
M204 S5000
G1 X98.748 Y141.502 E.00024
G3 X97.093 Y140.275 I-1.525 J.326 E.23187
G1 X97.2 Y140.269 E.00331
G3 X98.653 Y141.208 I.023 J1.559 E.05634
G1 X98.735 Y141.441 E.0076
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02369
G1 X98.79 Y141.809 E-.11785
G1 X98.771 Y142.07 E-.09947
G1 X98.703 Y142.344 E-.1072
G1 X98.571 Y142.626 E-.11805
G1 X98.387 Y142.876 E-.11808
G1 X98.156 Y143.084 E-.1181
G1 X98.026 Y143.162 E-.05756
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.183 Y144.116 Z8.2 F42000
G1 Z7.8
G1 E.8 F1800
G1 F2325
M204 S5000
G1 X96.748 Y144.069 E.01344
G3 X97.143 Y139.54 I.471 J-2.24 E.20408
G1 X97.299 Y139.541 E.00478
G3 X97.243 Y144.118 I-.079 J2.288 E.21784
M204 S10000
G1 X97.221 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2325
M204 S6000
G1 X97.206 Y143.753 E.00042
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.502 J.043 E.00483
G3 X97.493 Y143.735 I1.918 J.159 E.23826
G1 X97.281 Y143.748 E.00585
; CHANGE_LAYER
; Z_HEIGHT: 8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.02858
G1 X96.919 Y143.729 E-.10931
G1 X96.549 Y143.629 E-.14567
G1 X96.206 Y143.459 E-.14571
G1 X95.903 Y143.224 E-.14565
M73 P91 R2
G1 X95.653 Y142.933 E-.14557
G1 X95.602 Y142.843 E-.0395
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 40/60
; update layer progress
M73 L40
M991 S0 P39 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z8.2 I-1.037 J.637 P1  F42000
G1 X106.721 Y160.927 Z8.2
G1 Z8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.715 Y160.932 E.00024
G3 X105.059 Y159.705 I-1.525 J.326 E.23186
G1 X105.166 Y159.699 E.00328
G3 X106.621 Y160.638 I.024 J1.559 E.05638
G1 X106.701 Y160.871 E.00758
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.0239
G1 X106.757 Y161.239 E-.11784
G1 X106.73 Y161.549 E-.1181
G1 X106.642 Y161.846 E-.11754
G1 X106.538 Y162.056 E-.0893
G1 X106.354 Y162.306 E-.11788
G1 X106.123 Y162.514 E-.11805
G1 X105.994 Y162.591 E-.0574
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.145 Y163.547 Z8.4 F42000
G1 Z8
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.827 Y163.519 E.00981
G3 X105.11 Y158.971 I.359 J-2.261 E.20756
G1 X105.263 Y158.971 E.00472
G3 X105.205 Y163.548 I-.077 J2.288 E.21802
; WIPE_START
G1 F12000
M204 S6000
G1 X104.827 Y163.519 E-.14403
G1 X104.387 Y163.401 E-.1733
G1 X103.979 Y163.198 E-.17333
G1 X103.619 Y162.918 E-.17325
G1 X103.454 Y162.726 E-.09608
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z8.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 40 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z8.4
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
            G0 Z8.4 F4000
            G39.3 S1
            G0 Z8.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer40 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.729 Y162.49 F42000
G1 Z8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.0046
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.519 J.044 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28585
G1 X103.768 Y162.535 E.00431
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.08619
G1 X103.432 Y162.029 E-.14563
G1 X103.315 Y161.664 E-.14569
G1 X103.272 Y161.291 E-.14257
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06657
G1 X103.35 Y160.715 E-.14875
G1 X103.368 Y160.67 E-.01822
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.066 Y154.451 Z8.4 F42000
G1 Z8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.059 Y154.455 E.00024
G3 X102.404 Y153.228 I-1.525 J.326 E.23186
G1 X102.51 Y153.223 E.00328
G3 X103.965 Y154.161 I.024 J1.559 E.05638
G1 X104.046 Y154.394 E.00758
; WIPE_START
G1 F12000
M204 S6000
G1 X104.059 Y154.455 E-.0239
G1 X104.101 Y154.763 E-.11784
G1 X104.074 Y155.072 E-.1181
G1 X103.987 Y155.369 E-.11754
G1 X103.882 Y155.579 E-.0893
G1 X103.698 Y155.829 E-.11788
G1 X103.468 Y156.037 E-.11805
G1 X103.338 Y156.115 E-.0574
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.49 Y157.07 Z8.4 F42000
G1 Z8
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.172 Y157.043 E.00981
G3 X102.454 Y152.494 I.359 J-2.261 E.20756
G1 X102.608 Y152.494 E.00472
G3 X102.55 Y157.071 I-.077 J2.288 E.21802
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2326
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.519 J.044 E.00483
G3 X102.577 Y156.706 I1.918 J.159 E.24452
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13193
G1 X101.86 Y156.583 E-.14566
G1 X101.517 Y156.412 E-.1457
G1 X101.214 Y156.177 E-.14577
G1 X100.964 Y155.886 E-.14562
G1 X100.906 Y155.782 E-.04533
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.398 Y148.166 Z8.4 F42000
G1 X101.41 Y147.974 Z8.4
G1 Z8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.404 Y147.979 E.00024
G3 X99.748 Y146.751 I-1.525 J.326 E.23186
G1 X99.855 Y146.746 E.00328
G3 X101.309 Y147.684 I.024 J1.559 E.05638
G1 X101.39 Y147.917 E.00758
; WIPE_START
G1 F12000
M204 S6000
G1 X101.404 Y147.979 E-.0239
G1 X101.446 Y148.286 E-.11784
G1 X101.419 Y148.596 E-.1181
G1 X101.331 Y148.892 E-.11754
G1 X101.227 Y149.103 E-.0893
G1 X101.043 Y149.352 E-.11788
G1 X100.812 Y149.561 E-.11805
G1 X100.682 Y149.638 E-.0574
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.834 Y150.593 Z8.4 F42000
G1 Z8
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.516 Y150.566 E.00981
G3 X99.799 Y146.017 I.359 J-2.261 E.20756
G1 X99.952 Y146.017 E.00472
G3 X99.894 Y150.594 I-.077 J2.288 E.21802
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2326
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.519 J.044 E.00483
G3 X99.922 Y150.229 I1.918 J.159 E.24452
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13193
G1 X99.205 Y150.106 E-.14566
G1 X98.862 Y149.936 E-.1457
G1 X98.559 Y149.7 E-.14577
G1 X98.309 Y149.41 E-.14562
G1 X98.25 Y149.306 E-.04533
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.689 Z8.4 F42000
G1 X98.754 Y141.497 Z8.4
G1 Z8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.748 Y141.502 E.00024
G3 X97.093 Y140.275 I-1.525 J.326 E.23186
G1 X97.199 Y140.269 E.00328
G3 X98.654 Y141.208 I.024 J1.559 E.05638
G1 X98.735 Y141.441 E.00758
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.0239
G1 X98.79 Y141.809 E-.11784
G1 X98.763 Y142.119 E-.1181
G1 X98.676 Y142.416 E-.11754
G1 X98.571 Y142.626 E-.0893
G1 X98.387 Y142.876 E-.11788
G1 X98.157 Y143.084 E-.11805
G1 X98.027 Y143.161 E-.0574
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.179 Y144.116 Z8.4 F42000
G1 Z8
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.861 Y144.089 E.00981
G3 X97.143 Y139.54 I.359 J-2.261 E.20756
G1 X97.297 Y139.54 E.00472
G3 X97.239 Y144.117 I-.077 J2.288 E.21802
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2326
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.519 J.044 E.00483
G3 X97.266 Y143.753 I1.918 J.159 E.24452
; CHANGE_LAYER
; Z_HEIGHT: 8.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.729 E-.13193
G1 X96.549 Y143.629 E-.14566
G1 X96.206 Y143.459 E-.1457
G1 X95.903 Y143.223 E-.14577
G1 X95.653 Y142.933 E-.14562
G1 X95.595 Y142.829 E-.04533
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 41/60
; update layer progress
M73 L41
M991 S0 P40 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z8.4 I-1.037 J.637 P1  F42000
G1 X106.721 Y160.927 Z8.4
G1 Z8.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X106.715 Y160.932 E.00025
G3 X105.059 Y159.705 I-1.525 J.326 E.23186
G1 X105.165 Y159.699 E.00324
G3 X106.621 Y160.638 I.025 J1.559 E.05642
G1 X106.701 Y160.87 E.00756
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.02413
G1 X106.757 Y161.239 E-.11782
G1 X106.73 Y161.549 E-.11813
G1 X106.642 Y161.847 E-.11803
G1 X106.497 Y162.122 E-.11804
G1 X106.336 Y162.325 E-.09855
G1 X106.123 Y162.514 E-.10808
G1 X105.994 Y162.591 E-.05722
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.139 Y163.541 Z8.6 F42000
G1 Z8.2
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X105.054 Y163.541 E.0026
G3 X105.261 Y158.971 I.151 J-2.283 E.218
G1 X105.455 Y158.984 E.00597
G3 X105.51 Y163.526 I-.25 J2.275 E.20379
G1 X105.199 Y163.539 E.00956
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.541 E-.05497
G1 X104.604 Y163.471 E-.17311
G1 X104.178 Y163.309 E-.17333
G1 X103.792 Y163.067 E-.17325
G1 X103.461 Y162.752 E-.17334
G1 X103.443 Y162.727 E-.01201
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z8.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 41 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z8.6
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
            G0 Z8.6 F4000
            G39.3 S1
            G0 Z8.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer41 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.724 Y162.484 F42000
G1 Z8.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381139
G1 F2315
M204 S6000
G1 X103.62 Y162.363 E.00441
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.483 J.042 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.764 Y162.53 E.0045
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.0836
G1 X103.432 Y162.029 E-.14565
G1 X103.315 Y161.664 E-.14572
G1 X103.272 Y161.291 E-.14253
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06657
G1 X103.35 Y160.714 E-.14881
G1 X103.371 Y160.664 E-.02075
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.065 Y154.45 Z8.6 F42000
G1 Z8.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X104.059 Y154.455 E.00025
G3 X102.404 Y153.228 I-1.525 J.326 E.23186
G1 X102.509 Y153.223 E.00324
G3 X103.965 Y154.161 I.025 J1.559 E.05642
G1 X104.046 Y154.393 E.00756
; WIPE_START
G1 F12000
M204 S6000
G1 X104.059 Y154.455 E-.02413
G1 X104.101 Y154.763 E-.11782
G1 X104.074 Y155.072 E-.11813
G1 X103.986 Y155.37 E-.11803
G1 X103.841 Y155.645 E-.11804
G1 X103.68 Y155.848 E-.09855
G1 X103.468 Y156.037 E-.10808
G1 X103.338 Y156.114 E-.05722
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.483 Y157.064 Z8.6 F42000
G1 Z8.2
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X102.399 Y157.065 E.0026
G3 X102.606 Y152.494 I.151 J-2.283 E.218
G1 X102.8 Y152.507 E.00597
G3 X102.854 Y157.049 I-.25 J2.275 E.20379
G1 X102.543 Y157.062 E.00956
M204 S10000
G1 X102.522 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381139
G1 F2315
M204 S6000
G1 X102.517 Y156.706 E.00015
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.483 J.042 E.00483
G3 X102.804 Y156.688 I1.918 J.159 E.23826
G1 X102.582 Y156.702 E.00613
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.517 Y156.706 E-.0248
G1 X102.231 Y156.682 E-.10926
G1 X101.861 Y156.583 E-.14563
G1 X101.517 Y156.412 E-.14571
G1 X101.214 Y156.177 E-.14569
G1 X100.964 Y155.886 E-.1457
G1 X100.909 Y155.787 E-.04321
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.17 Z8.6 F42000
G1 X101.41 Y147.973 Z8.6
G1 Z8.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X101.404 Y147.979 E.00025
G3 X99.748 Y146.751 I-1.525 J.326 E.23186
G1 X99.854 Y146.746 E.00324
G3 X101.309 Y147.684 I.025 J1.559 E.05642
G1 X101.39 Y147.917 E.00756
; WIPE_START
G1 F12000
M204 S6000
G1 X101.404 Y147.979 E-.02413
G1 X101.446 Y148.286 E-.11782
G1 X101.419 Y148.596 E-.11813
G1 X101.331 Y148.894 E-.11803
G1 X101.186 Y149.168 E-.11804
G1 X101.024 Y149.371 E-.09855
G1 X100.812 Y149.561 E-.10808
G1 X100.683 Y149.638 E-.05722
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.828 Y150.588 Z8.6 F42000
G1 Z8.2
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X99.743 Y150.588 E.0026
G3 X99.95 Y146.017 I.151 J-2.283 E.218
G1 X100.144 Y146.03 E.00597
G3 X100.199 Y150.573 I-.25 J2.275 E.20379
G1 X99.888 Y150.585 E.00956
M204 S10000
G1 X99.867 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381139
G1 F2315
M204 S6000
G1 X99.862 Y150.23 E.00015
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.483 J.042 E.00483
G3 X100.149 Y150.212 I1.918 J.159 E.23826
G1 X99.927 Y150.225 E.00613
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.862 Y150.23 E-.0248
G1 X99.575 Y150.205 E-.10926
G1 X99.205 Y150.106 E-.14563
G1 X98.862 Y149.936 E-.14571
G1 X98.559 Y149.7 E-.14569
G1 X98.309 Y149.41 E-.1457
G1 X98.253 Y149.311 E-.04321
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.742 Y141.694 Z8.6 F42000
G1 X98.754 Y141.497 Z8.6
G1 Z8.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2315
M204 S5000
G1 X98.748 Y141.502 E.00025
G3 X97.093 Y140.275 I-1.525 J.326 E.23186
G1 X97.198 Y140.269 E.00324
G3 X98.654 Y141.208 I.025 J1.559 E.05642
G1 X98.735 Y141.44 E.00756
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02413
G1 X98.79 Y141.809 E-.11782
G1 X98.763 Y142.119 E-.11813
G1 X98.675 Y142.417 E-.11803
G1 X98.53 Y142.691 E-.11804
G1 X98.369 Y142.895 E-.09855
G1 X98.157 Y143.084 E-.10808
G1 X98.027 Y143.161 E-.05722
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.172 Y144.111 Z8.6 F42000
G1 Z8.2
G1 E.8 F1800
G1 F2315
M204 S5000
G1 X97.088 Y144.111 E.0026
G3 X97.295 Y139.54 I.151 J-2.283 E.218
G1 X97.488 Y139.553 E.00597
G3 X97.543 Y144.096 I-.25 J2.275 E.20379
G1 X97.232 Y144.109 E.00956
M204 S10000
G1 X97.211 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381139
G1 F2315
M204 S6000
G1 X97.206 Y143.753 E.00015
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.483 J.042 E.00483
G3 X97.493 Y143.735 I1.918 J.159 E.23826
G1 X97.271 Y143.749 E.00613
; CHANGE_LAYER
; Z_HEIGHT: 8.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X97.206 Y143.753 E-.0248
G1 X96.92 Y143.729 E-.10926
G1 X96.549 Y143.63 E-.14563
G1 X96.206 Y143.459 E-.14571
G1 X95.903 Y143.224 E-.14569
G1 X95.653 Y142.933 E-.1457
G1 X95.598 Y142.834 E-.04321
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 42/60
; update layer progress
M73 L42
M991 S0 P41 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z8.6 I-1.037 J.637 P1  F42000
G1 X106.721 Y160.926 Z8.6
G1 Z8.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.715 Y160.932 E.00025
G3 X105.059 Y159.705 I-1.525 J.326 E.23185
G1 X105.164 Y159.699 E.00321
G3 X106.621 Y160.638 I.027 J1.559 E.05646
G1 X106.701 Y160.87 E.00755
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.02433
G1 X106.757 Y161.237 E-.11685
G1 X106.742 Y161.472 E-.08955
G1 X106.67 Y161.774 E-.11812
G1 X106.538 Y162.056 E-.11802
G1 X106.354 Y162.306 E-.11812
G1 X106.123 Y162.514 E-.11806
G1 X105.995 Y162.591 E-.05695
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.136 Y163.545 Z8.8 F42000
G1 Z8.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.716 Y163.495 E.01301
G3 X105.108 Y158.971 I.481 J-2.237 E.2033
G1 X105.342 Y158.974 E.00718
G3 X105.196 Y163.546 I-.145 J2.284 E.21647
; WIPE_START
G1 F12000
M204 S6000
G1 X104.716 Y163.495 E-.18352
G1 X104.387 Y163.401 E-.12992
G1 X103.978 Y163.198 E-.17342
G1 X103.618 Y162.918 E-.17326
G1 X103.447 Y162.719 E-.09989
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z8.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 42 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z8.8
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
            G0 Z8.8 F4000
            G39.3 S1
            G0 Z8.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer42 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.722 Y162.482 F42000
G1 Z8.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381114
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.00432
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.504 J.043 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28588
G1 X103.761 Y162.527 E.00459
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.08234
G1 X103.432 Y162.029 E-.1457
G1 X103.315 Y161.664 E-.14568
G1 X103.272 Y161.291 E-.14251
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06656
G1 X103.35 Y160.714 E-.14884
G1 X103.372 Y160.661 E-.02199
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.065 Y154.45 Z8.8 F42000
G1 Z8.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.059 Y154.455 E.00025
G3 X102.404 Y153.228 I-1.525 J.326 E.23185
G1 X102.508 Y153.223 E.00321
G3 X103.965 Y154.161 I.027 J1.559 E.05646
G1 X104.046 Y154.393 E.00755
; WIPE_START
G1 F12000
M204 S6000
G1 X104.059 Y154.455 E-.02433
G1 X104.101 Y154.76 E-.11685
G1 X104.087 Y154.995 E-.08955
G1 X104.014 Y155.297 E-.11812
G1 X103.883 Y155.579 E-.11802
G1 X103.698 Y155.829 E-.11812
G1 X103.468 Y156.037 E-.11806
G1 X103.339 Y156.114 E-.05695
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.481 Y157.068 Z8.8 F42000
G1 Z8.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.06 Y157.018 E.01301
G3 X102.453 Y152.494 I.481 J-2.237 E.2033
G1 X102.687 Y152.497 E.00718
G3 X102.54 Y157.069 I-.145 J2.284 E.21647
M204 S10000
G1 X102.517 Y156.707 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381114
G1 F2326
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.925 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.504 J.043 E.00483
G3 X102.577 Y156.706 I1.918 J.159 E.24455
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13199
G1 X101.861 Y156.583 E-.14556
G1 X101.517 Y156.412 E-.14576
G1 X101.214 Y156.177 E-.14578
G1 X100.964 Y155.886 E-.14562
G1 X100.906 Y155.782 E-.04529
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.166 Z8.8 F42000
G1 X101.41 Y147.973 Z8.8
G1 Z8.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.404 Y147.979 E.00025
G3 X99.748 Y146.751 I-1.525 J.326 E.23185
G1 X99.852 Y146.746 E.00321
G3 X101.309 Y147.684 I.027 J1.559 E.05646
G1 X101.39 Y147.916 E.00755
; WIPE_START
G1 F12000
M204 S6000
G1 X101.404 Y147.979 E-.02433
G1 X101.446 Y148.283 E-.11685
G1 X101.431 Y148.519 E-.08955
G1 X101.358 Y148.821 E-.11812
G1 X101.227 Y149.102 E-.11802
G1 X101.043 Y149.352 E-.11812
G1 X100.812 Y149.561 E-.11806
G1 X100.683 Y149.637 E-.05695
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.825 Y150.592 Z8.8 F42000
G1 Z8.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.405 Y150.541 E.01301
G3 X99.797 Y146.017 I.481 J-2.237 E.2033
G1 X100.031 Y146.02 E.00718
G3 X99.885 Y150.592 I-.145 J2.284 E.21647
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381114
G1 F2326
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.925 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.504 J.043 E.00483
G3 X99.922 Y150.23 I1.918 J.159 E.24455
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13199
G1 X99.205 Y150.106 E-.14556
G1 X98.862 Y149.936 E-.14576
G1 X98.559 Y149.7 E-.14578
G1 X98.309 Y149.41 E-.14562
G1 X98.25 Y149.306 E-.04529
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
M73 P92 R2
G1 X98.742 Y141.689 Z8.8 F42000
G1 X98.754 Y141.496 Z8.8
G1 Z8.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.748 Y141.502 E.00025
G3 X97.093 Y140.275 I-1.525 J.326 E.23185
G1 X97.197 Y140.269 E.00321
G3 X98.654 Y141.207 I.027 J1.559 E.05646
G1 X98.734 Y141.439 E.00755
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02433
G1 X98.79 Y141.807 E-.11685
G1 X98.776 Y142.042 E-.08955
G1 X98.703 Y142.344 E-.11812
G1 X98.572 Y142.626 E-.11802
G1 X98.387 Y142.876 E-.11812
G1 X98.157 Y143.084 E-.11806
G1 X98.028 Y143.161 E-.05695
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.169 Y144.115 Z8.8 F42000
G1 Z8.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.749 Y144.065 E.01301
G3 X97.142 Y139.541 I.481 J-2.237 E.2033
G1 X97.375 Y139.543 E.00718
G3 X97.229 Y144.116 I-.145 J2.284 E.21647
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381114
G1 F2326
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.925 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.504 J.043 E.00483
G3 X97.266 Y143.753 I1.918 J.159 E.24455
; CHANGE_LAYER
; Z_HEIGHT: 8.6
; LAYER_HEIGHT: 0.200001
; WIPE_START
G1 F15000
G1 X96.919 Y143.729 E-.13199
G1 X96.549 Y143.63 E-.14556
G1 X96.206 Y143.459 E-.14576
G1 X95.903 Y143.223 E-.14578
G1 X95.653 Y142.933 E-.14562
G1 X95.595 Y142.829 E-.04528
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 43/60
; update layer progress
M73 L43
M991 S0 P42 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z8.8 I-1.037 J.637 P1  F42000
G1 X106.721 Y160.926 Z8.8
G1 Z8.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X106.715 Y160.932 E.00025
G3 X105.059 Y159.705 I-1.525 J.326 E.23185
G1 X105.162 Y159.699 E.00317
G3 X106.621 Y160.638 I.028 J1.559 E.05651
G1 X106.701 Y160.869 E.00753
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.02452
G1 X106.757 Y161.239 E-.11786
G1 X106.73 Y161.549 E-.11812
G1 X106.642 Y161.847 E-.11797
G1 X106.497 Y162.122 E-.11807
G1 X106.337 Y162.323 E-.09768
G1 X106.124 Y162.514 E-.10894
G1 X105.995 Y162.591 E-.05683
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.131 Y163.544 Z9 F42000
G1 Z8.6
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X104.716 Y163.495 E.01286
G3 X105.108 Y158.971 I.481 J-2.237 E.2033
G1 X105.342 Y158.974 E.00718
G3 X105.191 Y163.546 I-.145 J2.284 E.21662
; WIPE_START
G1 F12000
M204 S6000
G1 X104.716 Y163.495 E-.18176
G1 X104.387 Y163.401 E-.12995
G1 X103.979 Y163.198 E-.17327
G1 X103.619 Y162.918 E-.17327
G1 X103.444 Y162.715 E-.10174
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z9 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 43 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z9
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
            G0 Z9 F4000
            G39.3 S1
            G0 Z9 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer43 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.719 Y162.478 F42000
G1 Z8.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381135
G1 F2327
M204 S6000
G1 X103.62 Y162.363 E.00419
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.518 J.044 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.758 Y162.524 E.00472
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.08054
G1 X103.432 Y162.029 E-.14562
G1 X103.315 Y161.664 E-.14565
G1 X103.272 Y161.291 E-.14263
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06655
G1 X103.35 Y160.714 E-.14879
G1 X103.374 Y160.656 E-.02385
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.065 Y154.449 Z9 F42000
G1 Z8.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X104.06 Y154.455 E.00025
G3 X102.404 Y153.228 I-1.525 J.326 E.23185
G1 X102.507 Y153.223 E.00317
G3 X103.965 Y154.161 I.028 J1.559 E.05651
G1 X104.045 Y154.392 E.00753
; WIPE_START
G1 F12000
M204 S6000
G1 X104.06 Y154.455 E-.02452
G1 X104.101 Y154.763 E-.11786
G1 X104.074 Y155.072 E-.11812
G1 X103.986 Y155.37 E-.11797
G1 X103.841 Y155.645 E-.11807
G1 X103.682 Y155.846 E-.09768
G1 X103.468 Y156.037 E-.10894
G1 X103.339 Y156.114 E-.05683
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.476 Y157.068 Z9 F42000
G1 Z8.6
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X102.06 Y157.018 E.01286
G3 X102.453 Y152.494 I.481 J-2.237 E.2033
G1 X102.687 Y152.497 E.00718
G3 X102.536 Y157.069 I-.145 J2.284 E.21662
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381135
G1 F2327
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.518 J.044 E.00483
G3 X102.577 Y156.706 I1.918 J.159 E.24454
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13198
G1 X101.86 Y156.583 E-.14568
G1 X101.517 Y156.412 E-.14569
G1 X101.214 Y156.177 E-.1457
G1 X100.964 Y155.886 E-.14569
G1 X100.906 Y155.782 E-.04526
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.166 Z9 F42000
G1 X101.409 Y147.972 Z9
G1 Z8.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X101.404 Y147.979 E.00025
G3 X99.748 Y146.751 I-1.525 J.326 E.23185
G1 X99.851 Y146.746 E.00317
G3 X101.31 Y147.684 I.028 J1.559 E.05651
G1 X101.39 Y147.916 E.00753
; WIPE_START
G1 F12000
M204 S6000
G1 X101.404 Y147.979 E-.02452
G1 X101.446 Y148.286 E-.11786
G1 X101.419 Y148.596 E-.11812
G1 X101.331 Y148.893 E-.11797
G1 X101.186 Y149.168 E-.11807
G1 X101.026 Y149.37 E-.09768
G1 X100.812 Y149.561 E-.10894
G1 X100.684 Y149.637 E-.05683
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.82 Y150.591 Z9 F42000
G1 Z8.6
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X99.405 Y150.541 E.01286
G3 X99.797 Y146.017 I.481 J-2.237 E.2033
G1 X100.031 Y146.02 E.00718
G3 X99.88 Y150.592 I-.145 J2.284 E.21662
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381135
G1 F2327
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.518 J.044 E.00483
G3 X99.922 Y150.229 I1.918 J.159 E.24454
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13198
G1 X99.205 Y150.106 E-.14568
G1 X98.861 Y149.936 E-.14569
G1 X98.559 Y149.7 E-.1457
G1 X98.309 Y149.41 E-.14569
G1 X98.25 Y149.306 E-.04526
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.741 Y141.689 Z9 F42000
G1 X98.754 Y141.496 Z9
G1 Z8.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X98.748 Y141.502 E.00025
G3 X97.093 Y140.275 I-1.525 J.326 E.23185
G1 X97.196 Y140.269 E.00317
G3 X98.654 Y141.208 I.028 J1.559 E.05651
G1 X98.734 Y141.439 E.00753
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02452
G1 X98.79 Y141.809 E-.11786
G1 X98.763 Y142.119 E-.11812
G1 X98.675 Y142.417 E-.11797
G1 X98.53 Y142.691 E-.11807
G1 X98.37 Y142.893 E-.09768
G1 X98.157 Y143.084 E-.10894
G1 X98.028 Y143.16 E-.05683
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.165 Y144.114 Z9 F42000
G1 Z8.6
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X96.749 Y144.065 E.01286
G3 X97.142 Y139.541 I.481 J-2.237 E.2033
G1 X97.375 Y139.543 E.00718
G3 X97.224 Y144.116 I-.145 J2.284 E.21662
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381135
G1 F2327
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.518 J.044 E.00483
G3 X97.266 Y143.753 I1.918 J.159 E.24454
; CHANGE_LAYER
; Z_HEIGHT: 8.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.729 E-.13198
G1 X96.549 Y143.629 E-.14568
G1 X96.206 Y143.459 E-.14569
G1 X95.903 Y143.224 E-.1457
G1 X95.653 Y142.933 E-.14569
G1 X95.595 Y142.829 E-.04526
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 44/60
; update layer progress
M73 L44
M991 S0 P43 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z9 I-1.037 J.637 P1  F42000
G1 X106.72 Y160.925 Z9
G1 Z8.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X106.715 Y160.932 E.00026
G3 X105.059 Y159.705 I-1.525 J.326 E.23184
G1 X105.161 Y159.699 E.00314
G3 X106.621 Y160.638 I.029 J1.559 E.05654
G1 X106.701 Y160.869 E.00751
; WIPE_START
G1 F12000
M204 S6000
G1 X106.715 Y160.932 E-.02473
G1 X106.757 Y161.239 E-.11786
G1 X106.73 Y161.549 E-.11803
G1 X106.642 Y161.847 E-.11806
G1 X106.497 Y162.122 E-.11813
G1 X106.338 Y162.322 E-.09717
G1 X106.123 Y162.514 E-.10948
G1 X105.995 Y162.59 E-.05654
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.127 Y163.544 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X104.715 Y163.497 E.01274
G3 X105.109 Y158.971 I.482 J-2.238 E.20339
G1 X105.342 Y158.974 E.00718
G3 X105.187 Y163.548 I-.145 J2.285 E.21685
; WIPE_START
G1 F12000
M204 S6000
G1 X104.715 Y163.497 E-.18033
G1 X104.387 Y163.401 E-.12991
G1 X103.978 Y163.198 E-.17335
G1 X103.619 Y162.918 E-.17323
G1 X103.441 Y162.712 E-.10318
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z9.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 44 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z9.2
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
            G0 Z9.2 F4000
            G39.3 S1
            G0 Z9.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer44 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.717 Y162.475 F42000
G1 Z8.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381109
G1 F2327
M204 S6000
G1 X103.62 Y162.363 E.00408
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.502 J.043 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28585
G1 X103.756 Y162.521 E.00482
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.07899
G1 X103.432 Y162.029 E-.14569
G1 X103.315 Y161.664 E-.14576
G1 X103.272 Y161.291 E-.14253
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06657
G1 X103.35 Y160.714 E-.14883
G1 X103.375 Y160.653 E-.02525
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.065 Y154.449 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X104.06 Y154.455 E.00026
G3 X102.404 Y153.228 I-1.525 J.326 E.23184
G1 X102.506 Y153.223 E.00314
G3 X103.965 Y154.161 I.029 J1.559 E.05654
G1 X104.045 Y154.392 E.00751
; WIPE_START
G1 F12000
M204 S6000
G1 X104.06 Y154.455 E-.02473
G1 X104.101 Y154.763 E-.11786
G1 X104.074 Y155.072 E-.11803
G1 X103.986 Y155.37 E-.11806
G1 X103.841 Y155.645 E-.11813
G1 X103.682 Y155.845 E-.09717
G1 X103.468 Y156.038 E-.10948
G1 X103.34 Y156.114 E-.05654
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.471 Y157.067 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X102.059 Y157.02 E.01274
G3 X102.453 Y152.494 I.482 J-2.238 E.20339
G1 X102.687 Y152.497 E.00718
G3 X102.531 Y157.071 I-.145 J2.285 E.21685
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381109
G1 F2327
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.502 J.043 E.00483
G3 X102.577 Y156.706 I1.918 J.159 E.24452
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13195
G1 X101.861 Y156.583 E-.14567
G1 X101.517 Y156.412 E-.14574
G1 X101.214 Y156.177 E-.14575
G1 X100.964 Y155.887 E-.14553
G1 X100.906 Y155.782 E-.04537
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.166 Z9.2 F42000
G1 X101.409 Y147.972 Z9.2
G1 Z8.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X101.404 Y147.979 E.00026
G3 X99.748 Y146.751 I-1.525 J.326 E.23184
G1 X99.85 Y146.746 E.00314
G3 X101.31 Y147.684 I.029 J1.559 E.05654
G1 X101.39 Y147.915 E.00751
; WIPE_START
G1 F12000
M204 S6000
G1 X101.404 Y147.979 E-.02473
G1 X101.446 Y148.286 E-.11786
G1 X101.419 Y148.595 E-.11803
G1 X101.331 Y148.893 E-.11806
G1 X101.186 Y149.168 E-.11813
G1 X101.027 Y149.369 E-.09717
G1 X100.812 Y149.561 E-.10948
G1 X100.684 Y149.637 E-.05654
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.816 Y150.591 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X99.404 Y150.543 E.01274
G3 X99.797 Y146.017 I.482 J-2.238 E.20339
G1 X100.031 Y146.02 E.00718
G3 X99.876 Y150.595 I-.145 J2.285 E.21685
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381109
G1 F2327
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.502 J.043 E.00483
G3 X99.922 Y150.229 I1.918 J.159 E.24452
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13195
G1 X99.205 Y150.106 E-.14567
G1 X98.861 Y149.936 E-.14574
G1 X98.559 Y149.7 E-.14575
G1 X98.309 Y149.41 E-.14553
G1 X98.25 Y149.306 E-.04537
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.741 Y141.689 Z9.2 F42000
G1 X98.754 Y141.495 Z9.2
G1 Z8.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X98.748 Y141.502 E.00026
G3 X97.092 Y140.275 I-1.525 J.326 E.23184
G1 X97.194 Y140.269 E.00314
G3 X98.654 Y141.208 I.029 J1.559 E.05654
G1 X98.734 Y141.438 E.00751
; WIPE_START
G1 F12000
M204 S6000
G1 X98.748 Y141.502 E-.02473
G1 X98.79 Y141.809 E-.11786
G1 X98.763 Y142.119 E-.11803
G1 X98.675 Y142.417 E-.11806
G1 X98.53 Y142.692 E-.11813
G1 X98.371 Y142.892 E-.09717
G1 X98.157 Y143.084 E-.10948
G1 X98.029 Y143.16 E-.05654
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.16 Y144.114 Z9.2 F42000
G1 Z8.8
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X96.748 Y144.067 E.01274
G3 X97.142 Y139.541 I.482 J-2.238 E.20339
G1 X97.375 Y139.543 E.00718
G3 X97.22 Y144.118 I-.145 J2.285 E.21685
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381109
G1 F2327
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.502 J.043 E.00483
G3 X97.266 Y143.753 I1.918 J.159 E.24452
; CHANGE_LAYER
; Z_HEIGHT: 9
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.729 E-.13195
G1 X96.549 Y143.63 E-.14567
G1 X96.206 Y143.459 E-.14574
G1 X95.903 Y143.223 E-.14575
G1 X95.653 Y142.933 E-.14553
G1 X95.595 Y142.829 E-.04537
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 45/60
; update layer progress
M73 L45
M991 S0 P44 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z9.2 I-1.037 J.637 P1  F42000
G1 X106.72 Y160.925 Z9.2
G1 Z9
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.716 Y160.932 E.00027
G3 X105.059 Y159.705 I-1.525 J.326 E.23184
G1 X105.16 Y159.7 E.0031
G3 X106.621 Y160.637 I.031 J1.559 E.05658
G1 X106.701 Y160.868 E.0075
; WIPE_START
G1 F12000
M204 S6000
G1 X106.716 Y160.932 E-.02494
G1 X106.757 Y161.239 E-.11787
G1 X106.73 Y161.549 E-.1181
G1 X106.642 Y161.847 E-.11807
G1 X106.497 Y162.122 E-.11803
G1 X106.339 Y162.321 E-.09674
G1 X106.123 Y162.514 E-.1099
G1 X105.996 Y162.59 E-.05635
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.122 Y163.543 Z9.4 F42000
G1 Z9
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.716 Y163.495 E.01256
G3 X105.109 Y158.971 I.481 J-2.237 E.20331
G1 X105.342 Y158.974 E.00718
G3 X105.181 Y163.546 I-.145 J2.284 E.21692
; WIPE_START
G1 F12000
M204 S6000
G1 X104.716 Y163.495 E-.17803
G1 X104.387 Y163.401 E-.12995
G1 X103.979 Y163.198 E-.17322
G1 X103.619 Y162.918 E-.17332
G1 X103.438 Y162.708 E-.10548
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z9.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 45 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z9.4
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
            G0 Z9.4 F4000
            G39.3 S1
            G0 Z9.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer45 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.713 Y162.471 F42000
G1 Z9
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.00391
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.52 J.044 E.00483
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.752 Y162.516 E.00499
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.07671
G1 X103.432 Y162.029 E-.14565
G1 X103.315 Y161.664 E-.14579
G1 X103.272 Y161.291 E-.14253
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.06656
G1 X103.35 Y160.714 E-.1488
G1 X103.378 Y160.647 E-.02758
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.065 Y154.448 Z9.4 F42000
G1 Z9
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.06 Y154.455 E.00027
G3 X102.404 Y153.228 I-1.525 J.326 E.23184
G1 X102.504 Y153.223 E.0031
G3 X103.965 Y154.161 I.031 J1.559 E.05658
G1 X104.045 Y154.391 E.0075
; WIPE_START
G1 F12000
M204 S6000
G1 X104.06 Y154.455 E-.02494
G1 X104.101 Y154.763 E-.11787
G1 X104.074 Y155.072 E-.1181
G1 X103.986 Y155.37 E-.11807
G1 X103.841 Y155.645 E-.11803
G1 X103.683 Y155.845 E-.09674
G1 X103.468 Y156.037 E-.1099
M73 P93 R2
G1 X103.34 Y156.113 E-.05635
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.466 Y157.067 Z9.4 F42000
G1 Z9
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.06 Y157.018 E.01256
G3 X102.453 Y152.494 I.481 J-2.237 E.20331
G1 X102.687 Y152.497 E.00718
G3 X102.526 Y157.069 I-.145 J2.284 E.21692
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2326
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.52 J.044 E.00483
G3 X102.577 Y156.706 I1.918 J.159 E.24454
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13195
G1 X101.86 Y156.583 E-.14571
G1 X101.517 Y156.412 E-.1456
G1 X101.214 Y156.177 E-.14579
G1 X100.964 Y155.887 E-.1456
G1 X100.906 Y155.782 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.397 Y148.166 Z9.4 F42000
G1 X101.409 Y147.971 Z9.4
G1 Z9
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.404 Y147.979 E.00027
G3 X99.748 Y146.751 I-1.525 J.326 E.23184
G1 X99.849 Y146.746 E.0031
G3 X101.31 Y147.684 I.031 J1.559 E.05658
G1 X101.39 Y147.915 E.0075
; WIPE_START
G1 F12000
M204 S6000
G1 X101.404 Y147.979 E-.02494
G1 X101.446 Y148.286 E-.11787
G1 X101.419 Y148.596 E-.1181
G1 X101.331 Y148.894 E-.11807
G1 X101.186 Y149.168 E-.11803
G1 X101.028 Y149.368 E-.09674
G1 X100.812 Y149.561 E-.1099
G1 X100.685 Y149.636 E-.05635
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.81 Y150.59 Z9.4 F42000
G1 Z9
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.405 Y150.541 E.01256
G3 X99.797 Y146.017 I.481 J-2.237 E.20331
G1 X100.031 Y146.02 E.00718
G3 X99.87 Y150.592 I-.145 J2.284 E.21692
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2326
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.52 J.044 E.00483
G3 X99.922 Y150.229 I1.918 J.159 E.24454
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13195
G1 X99.205 Y150.106 E-.14571
G1 X98.862 Y149.936 E-.1456
G1 X98.559 Y149.7 E-.14579
G1 X98.309 Y149.41 E-.1456
G1 X98.25 Y149.306 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.741 Y141.689 Z9.4 F42000
G1 X98.754 Y141.495 Z9.4
G1 Z9
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.749 Y141.502 E.00027
G3 X97.092 Y140.275 I-1.525 J.326 E.23184
G1 X97.193 Y140.269 E.0031
G3 X98.654 Y141.207 I.031 J1.559 E.05658
G1 X98.734 Y141.438 E.0075
; WIPE_START
G1 F12000
M204 S6000
G1 X98.749 Y141.502 E-.02494
G1 X98.79 Y141.809 E-.11787
G1 X98.763 Y142.119 E-.1181
G1 X98.675 Y142.417 E-.11807
G1 X98.53 Y142.691 E-.11803
G1 X98.372 Y142.891 E-.09674
G1 X98.157 Y143.084 E-.1099
G1 X98.029 Y143.16 E-.05635
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.155 Y144.113 Z9.4 F42000
G1 Z9
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.749 Y144.065 E.01256
G3 X97.142 Y139.541 I.481 J-2.237 E.20331
G1 X97.375 Y139.543 E.00718
G3 X97.215 Y144.116 I-.145 J2.284 E.21692
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381136
G1 F2326
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.52 J.044 E.00483
G3 X97.266 Y143.753 I1.918 J.159 E.24454
; CHANGE_LAYER
; Z_HEIGHT: 9.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.729 E-.13195
G1 X96.549 Y143.629 E-.14571
G1 X96.206 Y143.459 E-.1456
G1 X95.903 Y143.224 E-.14579
G1 X95.653 Y142.933 E-.1456
G1 X95.595 Y142.829 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 46/60
; update layer progress
M73 L46
M991 S0 P45 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z9.4 I-1.037 J.637 P1  F42000
G1 X106.72 Y160.924 Z9.4
G1 Z9.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.716 Y160.932 E.00028
G3 X105.059 Y159.705 I-1.525 J.326 E.23183
G1 X105.159 Y159.7 E.00307
G3 X106.621 Y160.638 I.032 J1.559 E.05662
G1 X106.701 Y160.868 E.00748
; WIPE_START
G1 F12000
M204 S6000
G1 X106.716 Y160.932 E-.02516
G1 X106.757 Y161.239 E-.11785
G1 X106.73 Y161.549 E-.11804
G1 X106.642 Y161.847 E-.11809
G1 X106.537 Y162.058 E-.08959
G1 X106.354 Y162.306 E-.11711
G1 X106.123 Y162.514 E-.11807
G1 X105.996 Y162.59 E-.05608
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.117 Y163.543 Z9.6 F42000
G1 Z9.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.716 Y163.495 E.01243
G3 X105.109 Y158.971 I.481 J-2.237 E.2033
G1 X105.342 Y158.974 E.00718
G3 X105.177 Y163.546 I-.145 J2.284 E.21705
; WIPE_START
G1 F12000
M204 S6000
G1 X104.716 Y163.495 E-.17644
G1 X104.281 Y163.358 E-.17319
G1 X103.883 Y163.135 E-.17327
G1 X103.619 Y162.918 E-.12999
G1 X103.435 Y162.704 E-.10712
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z9.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 46 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z9.6
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
            G0 Z9.6 F4000
            G39.3 S1
            G0 Z9.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer46 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.71 Y162.468 F42000
G1 Z9.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.0038
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.509 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28585
G1 X103.749 Y162.513 E.00512
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.07522
G1 X103.432 Y162.029 E-.14563
G1 X103.315 Y161.664 E-.14561
G1 X103.272 Y161.291 E-.14258
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.14888
G1 X103.379 Y160.643 E-.02922
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.065 Y154.448 Z9.6 F42000
G1 Z9.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.06 Y154.455 E.00028
G3 X102.404 Y153.228 I-1.525 J.326 E.23183
G1 X102.503 Y153.223 E.00307
G3 X103.966 Y154.161 I.032 J1.559 E.05662
G1 X104.045 Y154.391 E.00748
; WIPE_START
G1 F12000
M204 S6000
G1 X104.06 Y154.455 E-.02516
G1 X104.101 Y154.763 E-.11785
G1 X104.074 Y155.072 E-.11804
G1 X103.986 Y155.37 E-.11809
G1 X103.881 Y155.581 E-.08959
G1 X103.698 Y155.829 E-.11711
G1 X103.468 Y156.038 E-.11807
G1 X103.341 Y156.113 E-.05608
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.462 Y157.066 Z9.6 F42000
G1 Z9.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.06 Y157.018 E.01243
G3 X102.453 Y152.494 I.481 J-2.237 E.2033
G1 X102.687 Y152.497 E.00718
G3 X102.522 Y157.069 I-.145 J2.284 E.21705
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2326
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.509 J.043 E.00482
G3 X102.577 Y156.706 I1.918 J.159 E.24453
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.222 Y156.681 E-.13515
G1 X101.853 Y156.58 E-.14566
G1 X101.517 Y156.412 E-.14249
G1 X101.214 Y156.177 E-.14567
G1 X100.964 Y155.886 E-.14579
G1 X100.906 Y155.782 E-.04524
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.396 Y148.166 Z9.6 F42000
G1 X101.409 Y147.971 Z9.6
G1 Z9.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.404 Y147.979 E.00028
G3 X99.748 Y146.751 I-1.525 J.326 E.23183
G1 X99.848 Y146.746 E.00307
G3 X101.31 Y147.684 I.032 J1.559 E.05662
G1 X101.389 Y147.914 E.00748
; WIPE_START
G1 F12000
M204 S6000
G1 X101.404 Y147.979 E-.02516
G1 X101.446 Y148.286 E-.11785
G1 X101.419 Y148.595 E-.11804
G1 X101.331 Y148.893 E-.11809
G1 X101.226 Y149.104 E-.08959
G1 X101.043 Y149.352 E-.11711
G1 X100.812 Y149.561 E-.11807
G1 X100.685 Y149.636 E-.05608
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.806 Y150.589 Z9.6 F42000
G1 Z9.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.404 Y150.541 E.01243
G3 X99.797 Y146.017 I.481 J-2.237 E.2033
G1 X100.031 Y146.02 E.00718
G3 X99.866 Y150.592 I-.145 J2.284 E.21705
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2326
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.509 J.043 E.00482
G3 X99.922 Y150.229 I1.918 J.159 E.24453
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.567 Y150.204 E-.13515
G1 X99.197 Y150.103 E-.14566
G1 X98.862 Y149.936 E-.14249
G1 X98.559 Y149.7 E-.14567
G1 X98.309 Y149.41 E-.14579
G1 X98.25 Y149.306 E-.04524
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.741 Y141.689 Z9.6 F42000
G1 X98.753 Y141.494 Z9.6
G1 Z9.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.749 Y141.502 E.00028
G3 X97.092 Y140.275 I-1.525 J.326 E.23183
G1 X97.192 Y140.269 E.00307
G3 X98.654 Y141.207 I.032 J1.559 E.05662
G1 X98.734 Y141.437 E.00748
; WIPE_START
G1 F12000
M204 S6000
G1 X98.749 Y141.502 E-.02516
G1 X98.79 Y141.809 E-.11785
G1 X98.763 Y142.119 E-.11804
G1 X98.675 Y142.417 E-.11809
G1 X98.57 Y142.628 E-.08959
G1 X98.387 Y142.876 E-.11711
G1 X98.157 Y143.084 E-.11807
G1 X98.03 Y143.159 E-.05608
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.15 Y144.113 Z9.6 F42000
G1 Z9.2
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.749 Y144.065 E.01243
G3 X97.142 Y139.541 I.481 J-2.237 E.2033
G1 X97.375 Y139.543 E.00718
G3 X97.21 Y144.116 I-.145 J2.284 E.21705
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381111
G1 F2326
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.509 J.043 E.00482
G3 X97.266 Y143.753 I1.918 J.159 E.24453
; CHANGE_LAYER
; Z_HEIGHT: 9.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.911 Y143.727 E-.13515
G1 X96.541 Y143.626 E-.14566
G1 X96.206 Y143.459 E-.14249
G1 X95.903 Y143.224 E-.14567
G1 X95.653 Y142.933 E-.14579
G1 X95.595 Y142.829 E-.04524
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 47/60
; update layer progress
M73 L47
M991 S0 P46 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z9.6 I-1.037 J.637 P1  F42000
G1 X106.72 Y160.924 Z9.6
G1 Z9.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.716 Y160.932 E.00029
G3 X105.059 Y159.705 I-1.525 J.326 E.23182
G1 X105.158 Y159.7 E.00303
G3 X106.621 Y160.637 I.034 J1.559 E.05666
G1 X106.7 Y160.867 E.00747
; WIPE_START
G1 F12000
M204 S6000
G1 X106.716 Y160.932 E-.0254
G1 X106.757 Y161.239 E-.11784
G1 X106.73 Y161.549 E-.11809
G1 X106.642 Y161.847 E-.11808
G1 X106.497 Y162.122 E-.11806
G1 X106.3 Y162.362 E-.11804
G1 X106.06 Y162.559 E-.11812
G1 X105.999 Y162.592 E-.02636
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.111 Y163.542 Z9.8 F42000
G1 Z9.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.716 Y163.495 E.01224
G3 X105.11 Y158.971 I.481 J-2.237 E.20335
G3 X105.34 Y158.973 I.08 J2.812 E.00705
G3 X105.171 Y163.546 I-.143 J2.284 E.21733
; WIPE_START
G1 F12000
M204 S6000
G1 X104.716 Y163.495 E-.17419
G1 X104.387 Y163.401 E-.12986
G1 X103.979 Y163.198 E-.1733
G1 X103.619 Y162.918 E-.17333
G1 X103.431 Y162.7 E-.10931
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z9.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 47 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z9.8
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
            G0 Z9.8 F4000
            G39.3 S1
            G0 Z9.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer47 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.706 Y162.463 F42000
G1 Z9.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381116
G1 F2326
M204 S6000
G1 X103.62 Y162.363 E.00363
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.511 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28585
G1 X103.745 Y162.509 E.00528
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.07285
G1 X103.432 Y162.029 E-.14578
G1 X103.315 Y161.664 E-.14563
G1 X103.272 Y161.291 E-.14256
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.0665
G1 X103.35 Y160.714 E-.14893
G1 X103.381 Y160.638 E-.03138
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.064 Y154.447 Z9.8 F42000
G1 Z9.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.06 Y154.455 E.00029
G3 X102.404 Y153.228 I-1.525 J.326 E.23182
G1 X102.502 Y153.223 E.00303
G3 X103.966 Y154.16 I.034 J1.559 E.05666
G1 X104.045 Y154.39 E.00747
; WIPE_START
G1 F12000
M204 S6000
G1 X104.06 Y154.455 E-.0254
G1 X104.101 Y154.763 E-.11784
G1 X104.074 Y155.072 E-.11809
G1 X103.986 Y155.37 E-.11808
G1 X103.841 Y155.645 E-.11806
G1 X103.645 Y155.885 E-.11804
G1 X103.404 Y156.082 E-.11812
G1 X103.343 Y156.116 E-.02636
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.456 Y157.065 Z9.8 F42000
G1 Z9.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X102.06 Y157.018 E.01224
G3 X102.455 Y152.494 I.481 J-2.237 E.20335
G3 X102.684 Y152.497 I.08 J2.812 E.00705
G3 X102.516 Y157.069 I-.143 J2.284 E.21733
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381116
G1 F2326
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.511 J.043 E.00482
G3 X102.577 Y156.706 I1.918 J.159 E.24453
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.1319
G1 X101.861 Y156.583 E-.14562
G1 X101.517 Y156.412 E-.14573
G1 X101.214 Y156.177 E-.14571
G1 X100.964 Y155.887 E-.14563
G1 X100.906 Y155.782 E-.04541
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.396 Y148.166 Z9.8 F42000
G1 X101.409 Y147.97 Z9.8
G1 Z9.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.405 Y147.979 E.00029
G3 X99.748 Y146.751 I-1.525 J.326 E.23182
G1 X99.846 Y146.746 E.00303
G3 X101.31 Y147.684 I.034 J1.559 E.05666
G1 X101.389 Y147.914 E.00747
; WIPE_START
G1 F12000
M204 S6000
G1 X101.405 Y147.979 E-.0254
G1 X101.446 Y148.286 E-.11784
G1 X101.419 Y148.596 E-.11809
G1 X101.331 Y148.894 E-.11808
G1 X101.186 Y149.168 E-.11806
G1 X100.989 Y149.409 E-.11804
G1 X100.748 Y149.605 E-.11812
G1 X100.688 Y149.639 E-.02636
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.8 Y150.589 Z9.8 F42000
G1 Z9.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.405 Y150.541 E.01224
G3 X99.799 Y146.017 I.481 J-2.237 E.20335
G3 X100.028 Y146.02 I.08 J2.812 E.00705
G3 X99.86 Y150.592 I-.143 J2.284 E.21733
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381116
G1 F2326
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.511 J.043 E.00482
G3 X99.922 Y150.229 I1.918 J.159 E.24453
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.1319
G1 X99.205 Y150.106 E-.14562
G1 X98.862 Y149.936 E-.14573
G1 X98.559 Y149.7 E-.14571
G1 X98.309 Y149.41 E-.14563
G1 X98.25 Y149.306 E-.04541
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.741 Y141.689 Z9.8 F42000
G1 X98.753 Y141.494 Z9.8
G1 Z9.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.749 Y141.502 E.00029
G3 X97.092 Y140.275 I-1.525 J.326 E.23182
G1 X97.191 Y140.269 E.00303
G3 X98.655 Y141.207 I.034 J1.559 E.05666
M73 P93 R1
G1 X98.734 Y141.437 E.00747
; WIPE_START
G1 F12000
M204 S6000
G1 X98.749 Y141.502 E-.0254
G1 X98.79 Y141.809 E-.11784
G1 X98.763 Y142.119 E-.11809
G1 X98.675 Y142.417 E-.11808
G1 X98.53 Y142.692 E-.11806
G1 X98.333 Y142.932 E-.11804
G1 X98.093 Y143.129 E-.11812
G1 X98.032 Y143.162 E-.02636
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.145 Y144.112 Z9.8 F42000
G1 Z9.4
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.749 Y144.065 E.01224
G3 X97.144 Y139.54 I.481 J-2.237 E.20335
G3 X97.373 Y139.543 I.08 J2.812 E.00705
G3 X97.204 Y144.116 I-.143 J2.284 E.21733
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381116
G1 F2326
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.511 J.043 E.00482
G3 X97.266 Y143.753 I1.918 J.159 E.24453
; CHANGE_LAYER
; Z_HEIGHT: 9.6
; LAYER_HEIGHT: 0.200001
; WIPE_START
G1 F15000
M73 P94 R1
G1 X96.92 Y143.729 E-.1319
G1 X96.549 Y143.63 E-.14562
G1 X96.206 Y143.459 E-.14573
G1 X95.903 Y143.224 E-.14571
G1 X95.653 Y142.933 E-.14563
G1 X95.595 Y142.829 E-.04541
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 48/60
; update layer progress
M73 L48
M991 S0 P47 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z9.8 I-1.037 J.637 P1  F42000
G1 X106.72 Y160.923 Z9.8
G1 Z9.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X106.716 Y160.932 E.00029
G3 X105.059 Y159.705 I-1.525 J.326 E.23181
G1 X105.156 Y159.7 E.003
G3 X106.622 Y160.637 I.035 J1.559 E.05671
G1 X106.7 Y160.866 E.00744
; WIPE_START
G1 F12000
M204 S6000
G1 X106.716 Y160.932 E-.02561
G1 X106.757 Y161.239 E-.11778
G1 X106.73 Y161.549 E-.11819
G1 X106.663 Y161.791 E-.09532
G1 X106.538 Y162.056 E-.11127
G1 X106.354 Y162.306 E-.11816
G1 X106.123 Y162.514 E-.11799
G1 X105.997 Y162.589 E-.05567
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.106 Y163.542 Z10 F42000
G1 Z9.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X104.716 Y163.495 E.01209
G3 X105.11 Y158.971 I.481 J-2.237 E.20334
G3 X105.34 Y158.973 I.081 J2.775 E.00705
G3 X105.168 Y163.546 I-.142 J2.284 E.21742
G1 X105.166 Y163.546 E.00007
; WIPE_START
G1 F12000
M204 S6000
G1 X104.716 Y163.495 E-.17224
G1 X104.281 Y163.358 E-.17309
G1 X103.884 Y163.135 E-.17325
G1 X103.619 Y162.918 E-.13014
G1 X103.428 Y162.696 E-.11128
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z10 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 48 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z10
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
            G0 Z10 F4000
            G39.3 S1
            G0 Z10 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer48 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.703 Y162.459 F42000
G1 Z9.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381118
G1 F2316
M204 S6000
G1 X103.62 Y162.363 E.00349
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.493 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.742 Y162.505 E.00541
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.0709
G1 X103.432 Y162.029 E-.14574
G1 X103.315 Y161.664 E-.14568
G1 X103.272 Y161.291 E-.14255
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06647
G1 X103.35 Y160.715 E-.14886
G1 X103.383 Y160.633 E-.03342
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.064 Y154.446 Z10 F42000
G1 Z9.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X104.061 Y154.455 E.00029
G3 X102.403 Y153.228 I-1.525 J.326 E.23181
G1 X102.501 Y153.223 E.003
G3 X103.966 Y154.161 I.035 J1.559 E.05671
G1 X104.045 Y154.39 E.00744
; WIPE_START
G1 F12000
M204 S6000
G1 X104.061 Y154.455 E-.02561
G1 X104.101 Y154.762 E-.11778
G1 X104.074 Y155.072 E-.11819
G1 X104.008 Y155.314 E-.09532
G1 X103.883 Y155.579 E-.11127
G1 X103.698 Y155.829 E-.11816
G1 X103.468 Y156.037 E-.11799
G1 X103.342 Y156.112 E-.05567
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.451 Y157.065 Z10 F42000
G1 Z9.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X102.06 Y157.018 E.01209
G3 X102.455 Y152.494 I.481 J-2.237 E.20334
G3 X102.684 Y152.497 I.081 J2.775 E.00705
G3 X102.513 Y157.069 I-.142 J2.284 E.21742
G1 X102.511 Y157.069 E.00007
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381118
G1 F2316
M204 S6000
G3 X100.617 Y154.814 I.023 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.493 J.043 E.00482
G3 X102.577 Y156.706 I1.918 J.159 E.24453
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13203
G1 X101.86 Y156.583 E-.14572
G1 X101.517 Y156.412 E-.1456
G1 X101.214 Y156.177 E-.14571
G1 X100.964 Y155.887 E-.14559
G1 X100.906 Y155.783 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.396 Y148.166 Z10 F42000
G1 X101.409 Y147.97 Z10
G1 Z9.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X101.405 Y147.979 E.00029
G3 X99.748 Y146.751 I-1.525 J.326 E.23181
G1 X99.845 Y146.746 E.003
G3 X101.31 Y147.684 I.035 J1.559 E.05671
G1 X101.389 Y147.913 E.00744
; WIPE_START
G1 F12000
M204 S6000
G1 X101.405 Y147.979 E-.02561
G1 X101.446 Y148.286 E-.11778
G1 X101.419 Y148.596 E-.11819
G1 X101.352 Y148.837 E-.09532
G1 X101.227 Y149.102 E-.11127
G1 X101.042 Y149.352 E-.11816
G1 X100.812 Y149.561 E-.11799
G1 X100.686 Y149.636 E-.05567
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.795 Y150.588 Z10 F42000
G1 Z9.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X99.405 Y150.541 E.01209
G3 X99.799 Y146.017 I.481 J-2.237 E.20334
G3 X100.028 Y146.02 I.081 J2.775 E.00705
G3 X99.857 Y150.592 I-.142 J2.284 E.21742
G1 X99.855 Y150.592 E.00007
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381118
G1 F2316
M204 S6000
G3 X97.961 Y148.338 I.023 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.493 J.043 E.00482
G3 X99.922 Y150.229 I1.918 J.159 E.24453
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13203
G1 X99.205 Y150.106 E-.14572
G1 X98.862 Y149.936 E-.1456
G1 X98.559 Y149.7 E-.14571
G1 X98.309 Y149.41 E-.14559
G1 X98.25 Y149.306 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.689 Z10 F42000
G1 X98.753 Y141.493 Z10
G1 Z9.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2316
M204 S5000
G1 X98.749 Y141.502 E.00029
G3 X97.092 Y140.275 I-1.525 J.326 E.23181
G1 X97.19 Y140.269 E.003
G3 X98.655 Y141.207 I.035 J1.559 E.05671
G1 X98.734 Y141.436 E.00744
; WIPE_START
G1 F12000
M204 S6000
G1 X98.749 Y141.502 E-.02561
G1 X98.79 Y141.809 E-.11778
G1 X98.763 Y142.119 E-.11819
G1 X98.696 Y142.361 E-.09532
G1 X98.572 Y142.626 E-.11127
G1 X98.387 Y142.876 E-.11816
G1 X98.157 Y143.084 E-.11799
G1 X98.031 Y143.159 E-.05567
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.139 Y144.111 Z10 F42000
G1 Z9.6
G1 E.8 F1800
G1 F2316
M204 S5000
G1 X96.749 Y144.065 E.01209
G3 X97.143 Y139.54 I.481 J-2.237 E.20334
G3 X97.373 Y139.543 I.081 J2.775 E.00705
G3 X97.202 Y144.116 I-.142 J2.284 E.21742
G1 X97.199 Y144.115 E.00007
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381118
G1 F2316
M204 S6000
G3 X95.305 Y141.861 I.023 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.493 J.043 E.00482
G3 X97.266 Y143.753 I1.918 J.159 E.24453
; CHANGE_LAYER
; Z_HEIGHT: 9.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.919 Y143.729 E-.13203
G1 X96.549 Y143.629 E-.14572
G1 X96.206 Y143.459 E-.1456
G1 X95.903 Y143.224 E-.14571
G1 X95.653 Y142.933 E-.14559
G1 X95.595 Y142.829 E-.04535
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 49/60
; update layer progress
M73 L49
M991 S0 P48 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z10 I-1.037 J.637 P1  F42000
G1 X106.72 Y160.923 Z10
G1 Z9.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.716 Y160.932 E.0003
G3 X105.059 Y159.705 I-1.525 J.326 E.2318
G1 X105.155 Y159.7 E.00296
G3 X106.622 Y160.637 I.037 J1.559 E.05675
G1 X106.7 Y160.866 E.00743
; WIPE_START
G1 F12000
M204 S6000
G1 X106.716 Y160.932 E-.02584
G1 X106.757 Y161.239 E-.11778
G1 X106.73 Y161.549 E-.11813
G1 X106.664 Y161.79 E-.0949
G1 X106.538 Y162.056 E-.11182
G1 X106.354 Y162.306 E-.11804
G1 X106.123 Y162.514 E-.11808
G1 X105.998 Y162.589 E-.05542
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.099 Y163.543 Z10.2 F42000
G1 Z9.8
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.543 E.00139
G3 X105.248 Y158.97 I.154 J-2.284 E.2175
G1 X105.34 Y158.973 E.00281
G3 X105.51 Y163.529 I-.131 J2.286 E.20767
G1 X105.159 Y163.541 E.01078
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.543 E-.03997
G1 X104.604 Y163.471 E-.17317
G1 X104.178 Y163.309 E-.17336
G1 X103.792 Y163.067 E-.17321
G1 X103.461 Y162.753 E-.17325
G1 X103.419 Y162.695 E-.02705
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z10.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 49 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z10.2
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
            G0 Z10.2 F4000
            G39.3 S1
            G0 Z10.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer49 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.699 Y162.455 F42000
G1 Z9.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00333
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.51 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.738 Y162.5 E.00558
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.06867
G1 X103.432 Y162.029 E-.14575
G1 X103.315 Y161.664 E-.14566
G1 X103.272 Y161.291 E-.14251
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.0665
G1 X103.35 Y160.714 E-.14888
G1 X103.386 Y160.628 E-.03565
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.064 Y154.446 Z10.2 F42000
G1 Z9.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.061 Y154.455 E.0003
G3 X102.403 Y153.228 I-1.525 J.326 E.2318
G1 X102.5 Y153.223 E.00296
G3 X103.966 Y154.16 I.037 J1.559 E.05675
G1 X104.045 Y154.389 E.00743
; WIPE_START
G1 F12000
M204 S6000
G1 X104.061 Y154.455 E-.02584
G1 X104.101 Y154.762 E-.11778
G1 X104.074 Y155.072 E-.11813
G1 X104.008 Y155.313 E-.0949
G1 X103.883 Y155.579 E-.11182
G1 X103.698 Y155.829 E-.11804
G1 X103.468 Y156.038 E-.11808
G1 X103.342 Y156.112 E-.05542
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.444 Y157.066 Z10.2 F42000
G1 Z9.8
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00139
G3 X102.593 Y152.493 I.154 J-2.284 E.2175
G1 X102.684 Y152.497 E.00281
G3 X102.855 Y157.052 I-.131 J2.286 E.20767
G1 X102.504 Y157.064 E.01078
M204 S10000
G1 X102.514 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2317
M204 S6000
G3 X100.617 Y154.815 I.027 J-1.924 E.08167
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.51 J.043 E.00482
G3 X102.574 Y156.706 I1.918 J.159 E.24463
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13069
G1 X101.86 Y156.583 E-.14569
G1 X101.517 Y156.412 E-.14575
G1 X101.214 Y156.177 E-.14562
G1 X100.964 Y155.887 E-.14562
G1 X100.904 Y155.779 E-.04664
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.396 Y148.163 Z10.2 F42000
G1 X101.408 Y147.969 Z10.2
G1 Z9.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.405 Y147.979 E.0003
G3 X99.748 Y146.751 I-1.525 J.326 E.2318
G1 X99.844 Y146.746 E.00296
G3 X101.311 Y147.684 I.037 J1.559 E.05675
G1 X101.389 Y147.912 E.00743
; WIPE_START
G1 F12000
M204 S6000
G1 X101.405 Y147.979 E-.02584
G1 X101.446 Y148.286 E-.11778
G1 X101.419 Y148.595 E-.11813
G1 X101.352 Y148.836 E-.0949
G1 X101.227 Y149.102 E-.11182
G1 X101.043 Y149.352 E-.11804
G1 X100.812 Y149.561 E-.11808
G1 X100.687 Y149.635 E-.05542
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.788 Y150.589 Z10.2 F42000
G1 Z9.8
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00139
G3 X99.937 Y146.017 I.154 J-2.284 E.2175
G1 X100.028 Y146.02 E.00281
G3 X100.199 Y150.575 I-.131 J2.286 E.20767
G1 X99.848 Y150.587 E.01078
M204 S10000
G1 X99.858 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2317
M204 S6000
G3 X97.961 Y148.338 I.027 J-1.924 E.08167
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.51 J.043 E.00482
G3 X99.918 Y150.23 I1.918 J.159 E.24463
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13069
G1 X99.205 Y150.106 E-.14569
G1 X98.861 Y149.935 E-.14575
G1 X98.559 Y149.7 E-.14562
G1 X98.309 Y149.41 E-.14562
G1 X98.249 Y149.303 E-.04664
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.686 Z10.2 F42000
G1 X98.753 Y141.493 Z10.2
G1 Z9.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.75 Y141.502 E.0003
G3 X97.092 Y140.275 I-1.525 J.326 E.2318
G1 X97.188 Y140.269 E.00296
G3 X98.655 Y141.207 I.037 J1.559 E.05675
G1 X98.733 Y141.436 E.00743
; WIPE_START
G1 F12000
M204 S6000
G1 X98.75 Y141.502 E-.02584
G1 X98.79 Y141.809 E-.11778
G1 X98.763 Y142.119 E-.11813
G1 X98.697 Y142.36 E-.0949
G1 X98.571 Y142.626 E-.11182
G1 X98.387 Y142.876 E-.11804
G1 X98.157 Y143.084 E-.11808
G1 X98.031 Y143.159 E-.05542
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.133 Y144.112 Z10.2 F42000
G1 Z9.8
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.087 Y144.113 E.00139
G3 X97.281 Y139.54 I.154 J-2.284 E.2175
G1 X97.373 Y139.543 E.00281
G3 X97.543 Y144.098 I-.131 J2.286 E.20767
G1 X97.193 Y144.11 E.01078
M204 S10000
G1 X97.203 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381119
G1 F2317
M204 S6000
G3 X95.305 Y141.861 I.027 J-1.924 E.08167
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.51 J.043 E.00482
G3 X97.263 Y143.753 I1.918 J.159 E.24463
; CHANGE_LAYER
; Z_HEIGHT: 10
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.729 E-.13069
G1 X96.549 Y143.629 E-.14569
G1 X96.206 Y143.459 E-.14575
G1 X95.903 Y143.224 E-.14562
G1 X95.653 Y142.933 E-.14562
G1 X95.593 Y142.826 E-.04664
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 50/60
; update layer progress
M73 L50
M991 S0 P49 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z10.2 I-1.037 J.637 P1  F42000
G1 X106.719 Y160.922 Z10.2
G1 Z10
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.717 Y160.932 E.00031
G3 X105.059 Y159.705 I-1.525 J.327 E.23179
G1 X105.154 Y159.7 E.00292
G3 X106.622 Y160.637 I.038 J1.559 E.05679
G1 X106.7 Y160.865 E.00742
; WIPE_START
G1 F12000
M204 S6000
G1 X106.717 Y160.932 E-.02601
G1 X106.757 Y161.239 E-.1179
G1 X106.73 Y161.549 E-.1181
G1 X106.642 Y161.847 E-.118
G1 X106.497 Y162.122 E-.1181
G1 X106.343 Y162.317 E-.09446
G1 X106.123 Y162.514 E-.11219
G1 X105.998 Y162.588 E-.05524
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.094 Y163.543 Z10.4 F42000
G1 Z10
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.543 E.00123
G3 X105.246 Y158.97 I.153 J-2.284 E.21751
G1 X105.34 Y158.973 E.00287
G3 X105.51 Y163.528 I-.132 J2.286 E.20761
G1 X105.154 Y163.541 E.01093
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.543 E-.03806
G1 X104.604 Y163.471 E-.17323
G1 X104.178 Y163.309 E-.17324
G1 X103.792 Y163.067 E-.17329
G1 X103.538 Y162.837 E-.13008
G1 X103.421 Y162.687 E-.0721
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z10.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 50 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z10.4
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
            G0 Z10.4 F4000
            G39.3 S1
            G0 Z10.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer50 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.696 Y162.451 F42000
G1 Z10
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381139
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.0032
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.492 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28588
G1 X103.735 Y162.497 E.00571
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.06693
G1 X103.432 Y162.029 E-.14578
G1 X103.315 Y161.664 E-.14553
G1 X103.272 Y161.291 E-.1426
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06647
G1 X103.35 Y160.714 E-.14888
G1 X103.387 Y160.623 E-.03743
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.064 Y154.445 Z10.4 F42000
G1 Z10
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.061 Y154.455 E.00031
G3 X102.403 Y153.228 I-1.525 J.327 E.23179
G1 X102.498 Y153.223 E.00292
G3 X103.967 Y154.16 I.038 J1.559 E.05679
G1 X104.044 Y154.389 E.00742
; WIPE_START
G1 F12000
M204 S6000
G1 X104.061 Y154.455 E-.02601
G1 X104.101 Y154.763 E-.1179
G1 X104.074 Y155.072 E-.1181
G1 X103.986 Y155.37 E-.118
G1 X103.841 Y155.645 E-.1181
G1 X103.687 Y155.84 E-.09446
G1 X103.468 Y156.037 E-.11219
G1 X103.343 Y156.112 E-.05524
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.439 Y157.066 Z10.4 F42000
G1 Z10
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00123
G3 X102.591 Y152.493 I.153 J-2.284 E.21751
G1 X102.684 Y152.497 E.00287
G3 X102.854 Y157.052 I-.132 J2.286 E.20761
G1 X102.499 Y157.064 E.01093
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381139
G1 F2317
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.492 J.043 E.00482
G3 X102.577 Y156.706 I1.918 J.159 E.24455
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13198
G1 X101.861 Y156.583 E-.14563
G1 X101.517 Y156.412 E-.14563
G1 X101.214 Y156.177 E-.14581
G1 X100.964 Y155.886 E-.14564
G1 X100.906 Y155.782 E-.04532
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.396 Y148.166 Z10.4 F42000
G1 X101.408 Y147.969 Z10.4
G1 Z10
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.406 Y147.978 E.00031
G3 X99.748 Y146.751 I-1.525 J.327 E.23179
G1 X99.843 Y146.746 E.00292
G3 X101.311 Y147.684 I.038 J1.559 E.05679
G1 X101.389 Y147.912 E.00742
; WIPE_START
G1 F12000
M204 S6000
G1 X101.406 Y147.978 E-.02601
G1 X101.446 Y148.286 E-.1179
G1 X101.419 Y148.596 E-.1181
G1 X101.331 Y148.893 E-.118
G1 X101.186 Y149.168 E-.1181
G1 X101.032 Y149.363 E-.09446
G1 X100.812 Y149.561 E-.11219
G1 X100.687 Y149.635 E-.05524
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.783 Y150.589 Z10.4 F42000
G1 Z10
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00123
G3 X99.935 Y146.016 I.153 J-2.284 E.21751
G1 X100.028 Y146.02 E.00287
G3 X100.199 Y150.575 I-.132 J2.286 E.20761
G1 X99.843 Y150.587 E.01093
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381139
G1 F2317
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.492 J.043 E.00482
G3 X99.922 Y150.229 I1.918 J.159 E.24455
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13198
G1 X99.205 Y150.106 E-.14563
G1 X98.862 Y149.936 E-.14563
G1 X98.559 Y149.7 E-.14581
G1 X98.309 Y149.41 E-.14564
G1 X98.25 Y149.306 E-.04532
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.689 Z10.4 F42000
G1 X98.753 Y141.492 Z10.4
M73 P95 R1
G1 Z10
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.75 Y141.502 E.00031
G3 X97.092 Y140.275 I-1.525 J.327 E.23179
G1 X97.187 Y140.269 E.00292
G3 X98.655 Y141.207 I.038 J1.559 E.05679
G1 X98.733 Y141.435 E.00742
; WIPE_START
G1 F12000
M204 S6000
G1 X98.75 Y141.502 E-.02601
G1 X98.79 Y141.809 E-.1179
G1 X98.763 Y142.119 E-.1181
G1 X98.675 Y142.417 E-.118
G1 X98.53 Y142.691 E-.1181
G1 X98.376 Y142.887 E-.09446
G1 X98.157 Y143.084 E-.11219
G1 X98.032 Y143.158 E-.05524
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.128 Y144.113 Z10.4 F42000
G1 Z10
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.087 Y144.113 E.00123
G3 X97.279 Y139.54 I.153 J-2.284 E.21751
G1 X97.373 Y139.543 E.00287
G3 X97.543 Y144.098 I-.132 J2.286 E.20761
G1 X97.187 Y144.111 E.01093
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381139
G1 F2317
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.492 J.043 E.00482
G3 X97.266 Y143.753 I1.918 J.159 E.24455
; CHANGE_LAYER
; Z_HEIGHT: 10.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.729 E-.13198
G1 X96.549 Y143.63 E-.14563
G1 X96.206 Y143.459 E-.14563
G1 X95.903 Y143.224 E-.14581
G1 X95.653 Y142.933 E-.14564
G1 X95.595 Y142.829 E-.04531
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 51/60
; update layer progress
M73 L51
M991 S0 P50 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z10.4 I-1.037 J.637 P1  F42000
G1 X106.719 Y160.922 Z10.4
G1 Z10.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.717 Y160.932 E.00032
G3 X105.059 Y159.705 I-1.525 J.327 E.23179
G1 X105.153 Y159.7 E.00289
G3 X106.622 Y160.637 I.039 J1.559 E.05683
G1 X106.7 Y160.865 E.0074
; WIPE_START
G1 F12000
M204 S6000
G1 X106.717 Y160.932 E-.02618
G1 X106.757 Y161.239 E-.11794
G1 X106.73 Y161.549 E-.11804
G1 X106.642 Y161.847 E-.11806
G1 X106.497 Y162.122 E-.1181
G1 X106.3 Y162.362 E-.11803
G1 X106.06 Y162.559 E-.11807
G1 X106.001 Y162.591 E-.02559
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.089 Y163.543 Z10.6 F42000
G1 Z10.2
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.543 E.00108
G3 X105.244 Y158.97 I.152 J-2.284 E.21749
G1 X105.34 Y158.973 E.00293
G3 X105.51 Y163.528 I-.133 J2.286 E.20757
G1 X105.149 Y163.541 E.01109
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.543 E-.03614
G1 X104.604 Y163.471 E-.17314
G1 X104.281 Y163.358 E-.13021
G1 X103.884 Y163.135 E-.17313
G1 X103.538 Y162.837 E-.17337
G1 X103.418 Y162.683 E-.07401
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z10.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 51 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z10.6
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
            G0 Z10.6 F4000
            G39.3 S1
            G0 Z10.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer51 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.692 Y162.447 F42000
G1 Z10.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381141
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00307
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.5 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28587
G1 X103.732 Y162.493 E.00585
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.06509
G1 X103.432 Y162.029 E-.14554
G1 X103.315 Y161.664 E-.14572
G1 X103.272 Y161.291 E-.14258
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.0665
G1 X103.35 Y160.714 E-.14888
G1 X103.389 Y160.619 E-.03932
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.064 Y154.445 Z10.6 F42000
G1 Z10.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.061 Y154.455 E.00032
G3 X102.403 Y153.228 I-1.525 J.327 E.23179
G1 X102.497 Y153.223 E.00289
G3 X103.967 Y154.16 I.039 J1.559 E.05683
G1 X104.044 Y154.388 E.0074
; WIPE_START
G1 F12000
M204 S6000
G1 X104.061 Y154.455 E-.02618
G1 X104.101 Y154.763 E-.11794
G1 X104.074 Y155.072 E-.11804
G1 X103.986 Y155.37 E-.11806
G1 X103.841 Y155.645 E-.1181
G1 X103.645 Y155.885 E-.11803
G1 X103.404 Y156.082 E-.11807
G1 X103.345 Y156.115 E-.02559
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.434 Y157.066 Z10.6 F42000
G1 Z10.2
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00108
G3 X102.589 Y152.493 I.152 J-2.284 E.21749
G1 X102.684 Y152.497 E.00293
G3 X102.854 Y157.052 I-.133 J2.286 E.20757
G1 X102.494 Y157.064 E.01109
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381141
G1 F2317
M204 S6000
G3 X100.617 Y154.814 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.5 J.043 E.00482
G3 X102.577 Y156.706 I1.918 J.159 E.24455
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.222 Y156.681 E-.1351
G1 X101.852 Y156.58 E-.14573
G1 X101.517 Y156.412 E-.1425
G1 X101.214 Y156.177 E-.14559
G1 X100.964 Y155.886 E-.14577
G1 X100.906 Y155.782 E-.04532
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.166 Z10.6 F42000
G1 X101.408 Y147.968 Z10.6
G1 Z10.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.406 Y147.978 E.00032
G3 X99.748 Y146.751 I-1.525 J.327 E.23179
G1 X99.842 Y146.746 E.00289
G3 X101.311 Y147.684 I.039 J1.559 E.05683
G1 X101.389 Y147.911 E.0074
; WIPE_START
G1 F12000
M204 S6000
G1 X101.406 Y147.978 E-.02618
G1 X101.446 Y148.286 E-.11794
G1 X101.419 Y148.595 E-.11804
G1 X101.331 Y148.893 E-.11806
G1 X101.186 Y149.168 E-.1181
G1 X100.989 Y149.409 E-.11803
G1 X100.749 Y149.605 E-.11807
G1 X100.69 Y149.638 E-.02559
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.778 Y150.59 Z10.6 F42000
G1 Z10.2
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00108
G3 X99.933 Y146.016 I.152 J-2.284 E.21749
G1 X100.028 Y146.02 E.00293
G3 X100.199 Y150.575 I-.133 J2.286 E.20757
G1 X99.838 Y150.587 E.01109
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381141
G1 F2317
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.5 J.043 E.00482
G3 X99.921 Y150.229 I1.918 J.159 E.24455
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.567 Y150.204 E-.1351
G1 X99.197 Y150.103 E-.14573
G1 X98.861 Y149.935 E-.1425
G1 X98.559 Y149.7 E-.14559
G1 X98.309 Y149.41 E-.14577
G1 X98.25 Y149.306 E-.04532
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.689 Z10.6 F42000
G1 X98.753 Y141.491 Z10.6
G1 Z10.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.75 Y141.501 E.00032
G3 X97.092 Y140.275 I-1.525 J.327 E.23179
G1 X97.186 Y140.269 E.00289
G3 X98.655 Y141.207 I.039 J1.559 E.05683
G1 X98.733 Y141.435 E.0074
; WIPE_START
G1 F12000
M204 S6000
G1 X98.75 Y141.501 E-.02618
G1 X98.79 Y141.809 E-.11794
G1 X98.763 Y142.119 E-.11804
G1 X98.675 Y142.417 E-.11806
G1 X98.53 Y142.691 E-.1181
G1 X98.333 Y142.932 E-.11803
G1 X98.093 Y143.129 E-.11807
G1 X98.034 Y143.161 E-.02559
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.122 Y144.113 Z10.6 F42000
G1 Z10.2
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.087 Y144.113 E.00108
G3 X97.278 Y139.54 I.152 J-2.284 E.21749
G1 X97.373 Y139.543 E.00293
G3 X97.543 Y144.098 I-.133 J2.286 E.20757
G1 X97.182 Y144.111 E.01109
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381141
G1 F2317
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.5 J.043 E.00482
G3 X97.266 Y143.753 I1.918 J.159 E.24455
; CHANGE_LAYER
; Z_HEIGHT: 10.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.911 Y143.727 E-.1351
G1 X96.541 Y143.626 E-.14573
G1 X96.206 Y143.459 E-.1425
G1 X95.903 Y143.224 E-.14559
G1 X95.653 Y142.933 E-.14577
G1 X95.595 Y142.829 E-.04531
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 52/60
; update layer progress
M73 L52
M991 S0 P51 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z10.6 I-1.037 J.637 P1  F42000
G1 X106.719 Y160.921 Z10.6
G1 Z10.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.717 Y160.932 E.00033
G3 X105.059 Y159.705 I-1.525 J.327 E.23177
G1 X105.152 Y159.7 E.00285
G3 X106.623 Y160.637 I.041 J1.559 E.05688
G1 X106.7 Y160.864 E.00738
; WIPE_START
G1 F12000
M204 S6000
G1 X106.717 Y160.932 E-.02642
G1 X106.757 Y161.239 E-.11792
G1 X106.73 Y161.549 E-.11809
G1 X106.665 Y161.786 E-.09348
G1 X106.538 Y162.056 E-.11312
G1 X106.354 Y162.306 E-.11812
G1 X106.123 Y162.514 E-.11802
G1 X105.999 Y162.588 E-.05482
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.084 Y163.543 Z10.8 F42000
G1 Z10.4
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.543 E.00093
G3 X105.242 Y158.97 I.151 J-2.284 E.2175
G1 X105.34 Y158.973 E.00299
G3 X105.51 Y163.528 I-.134 J2.286 E.20749
G1 X105.144 Y163.541 E.01125
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.543 E-.03424
G1 X104.604 Y163.471 E-.17319
G1 X104.178 Y163.309 E-.17329
G1 X103.792 Y163.067 E-.17325
G1 X103.461 Y162.753 E-.17323
G1 X103.41 Y162.683 E-.0328
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z10.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 52 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z10.8
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
            G0 Z10.8 F4000
            G39.3 S1
            G0 Z10.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer52 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.689 Y162.443 F42000
G1 Z10.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00292
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.518 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.728 Y162.489 E.00599
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.063
G1 X103.432 Y162.029 E-.1456
G1 X103.315 Y161.664 E-.14565
G1 X103.272 Y161.291 E-.14263
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06647
G1 X103.35 Y160.714 E-.14895
G1 X103.391 Y160.614 E-.04133
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.064 Y154.444 Z10.8 F42000
G1 Z10.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.062 Y154.455 E.00033
G3 X102.403 Y153.228 I-1.525 J.327 E.23177
G1 X102.496 Y153.223 E.00285
G3 X103.967 Y154.16 I.041 J1.559 E.05688
G1 X104.044 Y154.388 E.00738
; WIPE_START
G1 F12000
M204 S6000
G1 X104.062 Y154.455 E-.02642
G1 X104.101 Y154.763 E-.11792
G1 X104.074 Y155.072 E-.11809
G1 X104.009 Y155.31 E-.09348
G1 X103.883 Y155.579 E-.11312
G1 X103.698 Y155.829 E-.11812
G1 X103.468 Y156.037 E-.11802
G1 X103.344 Y156.111 E-.05482
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.429 Y157.066 Z10.8 F42000
G1 Z10.4
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00093
G3 X102.587 Y152.493 I.151 J-2.284 E.2175
G1 X102.684 Y152.497 E.00299
G3 X102.854 Y157.051 I-.134 J2.286 E.20749
G1 X102.489 Y157.064 E.01125
M204 S10000
G1 X102.517 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2317
M204 S6000
G3 X100.617 Y154.815 I.024 J-1.924 E.08177
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.518 J.043 E.00482
G3 X102.577 Y156.706 I1.918 J.159 E.24454
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.13198
G1 X101.86 Y156.583 E-.14567
G1 X101.517 Y156.412 E-.14576
G1 X101.214 Y156.177 E-.14562
G1 X100.964 Y155.886 E-.14569
G1 X100.906 Y155.782 E-.04528
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.166 Z10.8 F42000
G1 X101.408 Y147.968 Z10.8
G1 Z10.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.406 Y147.978 E.00033
G3 X99.748 Y146.751 I-1.525 J.327 E.23177
G1 X99.84 Y146.746 E.00285
G3 X101.311 Y147.683 I.041 J1.559 E.05688
G1 X101.389 Y147.911 E.00738
; WIPE_START
G1 F12000
M204 S6000
G1 X101.406 Y147.978 E-.02642
G1 X101.446 Y148.286 E-.11792
G1 X101.419 Y148.596 E-.11809
G1 X101.354 Y148.833 E-.09348
G1 X101.227 Y149.102 E-.11312
G1 X101.043 Y149.352 E-.11812
G1 X100.812 Y149.561 E-.11802
G1 X100.688 Y149.634 E-.05482
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.773 Y150.59 Z10.8 F42000
G1 Z10.4
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00093
G3 X99.931 Y146.016 I.151 J-2.284 E.2175
G1 X100.028 Y146.02 E.00299
G3 X100.199 Y150.575 I-.134 J2.286 E.20749
G1 X99.833 Y150.588 E.01125
M204 S10000
G1 X99.862 Y150.23 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2317
M204 S6000
G3 X97.961 Y148.338 I.024 J-1.924 E.08177
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.518 J.043 E.00482
G3 X99.922 Y150.229 I1.918 J.159 E.24454
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13198
G1 X99.205 Y150.106 E-.14567
G1 X98.861 Y149.935 E-.14576
G1 X98.559 Y149.7 E-.14562
G1 X98.309 Y149.41 E-.14569
G1 X98.25 Y149.306 E-.04528
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.689 Z10.8 F42000
G1 X98.752 Y141.491 Z10.8
G1 Z10.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.75 Y141.502 E.00033
G3 X97.092 Y140.275 I-1.525 J.327 E.23177
G1 X97.185 Y140.269 E.00285
G3 X98.656 Y141.207 I.041 J1.559 E.05688
G1 X98.733 Y141.434 E.00738
; WIPE_START
G1 F12000
M204 S6000
G1 X98.75 Y141.502 E-.02642
G1 X98.79 Y141.809 E-.11792
G1 X98.763 Y142.119 E-.11809
G1 X98.698 Y142.356 E-.09348
G1 X98.572 Y142.626 E-.11312
G1 X98.387 Y142.876 E-.11812
G1 X98.157 Y143.084 E-.11802
G1 X98.033 Y143.158 E-.05482
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.117 Y144.113 Z10.8 F42000
G1 Z10.4
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.087 Y144.113 E.00093
G3 X97.276 Y139.54 I.151 J-2.284 E.2175
G1 X97.373 Y139.543 E.00299
G3 X97.543 Y144.098 I-.134 J2.286 E.20749
G1 X97.177 Y144.111 E.01125
M204 S10000
G1 X97.206 Y143.753 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38112
G1 F2317
M204 S6000
G3 X95.305 Y141.861 I.024 J-1.924 E.08177
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.67 I3.518 J.043 E.00482
G3 X97.266 Y143.753 I1.918 J.159 E.24454
; CHANGE_LAYER
; Z_HEIGHT: 10.6
; LAYER_HEIGHT: 0.200001
; WIPE_START
G1 F15000
G1 X96.92 Y143.729 E-.13198
G1 X96.549 Y143.629 E-.14567
G1 X96.206 Y143.459 E-.14576
G1 X95.903 Y143.224 E-.14562
G1 X95.653 Y142.933 E-.14569
G1 X95.595 Y142.829 E-.04528
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 53/60
; update layer progress
M73 L53
M991 S0 P52 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z10.8 I-1.037 J.637 P1  F42000
G1 X106.719 Y160.921 Z10.8
G1 Z10.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.718 Y160.932 E.00034
G3 X105.059 Y159.705 I-1.525 J.327 E.23175
G1 X105.15 Y159.7 E.00282
G3 X106.623 Y160.637 I.043 J1.559 E.05692
G1 X106.7 Y160.864 E.00737
; WIPE_START
G1 F12000
M204 S6000
G1 X106.718 Y160.932 E-.02671
G1 X106.757 Y161.239 E-.11782
G1 X106.741 Y161.484 E-.09314
G1 X106.67 Y161.774 E-.11363
G1 X106.538 Y162.056 E-.11802
G1 X106.354 Y162.306 E-.11812
G1 X106.123 Y162.514 E-.11807
G1 X106 Y162.588 E-.05451
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.079 Y163.544 Z11 F42000
G1 Z10.6
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.543 E.00076
G3 X105.24 Y158.97 I.15 J-2.285 E.2175
G1 X105.34 Y158.973 E.00305
G3 X105.397 Y163.54 I-.135 J2.285 E.21094
G1 X105.139 Y163.543 E.00791
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.543 E-.03224
G1 X104.604 Y163.471 E-.17316
G1 X104.178 Y163.309 E-.17333
G1 X103.791 Y163.067 E-.17334
G1 X103.461 Y162.753 E-.17327
G1 X103.409 Y162.678 E-.03466
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z11 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 53 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z11
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
            G0 Z11 F4000
            G39.3 S1
            G0 Z11 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer53 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.686 Y162.44 F42000
G1 Z10.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381141
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00278
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.525 J.044 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28588
G1 X103.725 Y162.485 E.00613
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.06107
G1 X103.432 Y162.029 E-.14558
G1 X103.315 Y161.664 E-.14578
G1 X103.272 Y161.291 E-.14255
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.14887
G1 X103.393 Y160.609 E-.04329
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.063 Y154.444 Z11 F42000
G1 Z10.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
M73 P96 R1
G1 X104.062 Y154.455 E.00034
G3 X102.403 Y153.228 I-1.525 J.327 E.23175
G1 X102.495 Y153.223 E.00282
G3 X103.967 Y154.16 I.043 J1.559 E.05692
G1 X104.044 Y154.387 E.00737
; WIPE_START
G1 F12000
M204 S6000
G1 X104.062 Y154.455 E-.02671
G1 X104.101 Y154.762 E-.11782
G1 X104.085 Y155.007 E-.09314
G1 X104.014 Y155.298 E-.11363
G1 X103.883 Y155.579 E-.11802
G1 X103.698 Y155.829 E-.11812
G1 X103.468 Y156.038 E-.11807
G1 X103.344 Y156.111 E-.05451
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.423 Y157.067 Z11 F42000
G1 Z10.6
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00076
G3 X102.585 Y152.493 I.15 J-2.285 E.2175
G1 X102.684 Y152.497 E.00305
G3 X102.741 Y157.064 I-.135 J2.285 E.21094
G1 X102.483 Y157.067 E.00791
M204 S10000
G1 X102.514 Y156.706 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381141
G1 F2317
M204 S6000
G1 X102.231 Y156.681 E.00782
G3 X100.617 Y154.814 I.31 J-1.899 E.07384
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.525 J.044 E.00482
G3 X102.574 Y156.706 I1.918 J.159 E.24466
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.681 E-.13052
G1 X101.861 Y156.583 E-.14565
G1 X101.517 Y156.412 E-.1458
G1 X101.214 Y156.177 E-.14564
G1 X100.964 Y155.886 E-.14564
G1 X100.904 Y155.779 E-.04674
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.163 Z11 F42000
G1 X101.408 Y147.967 Z11
G1 Z10.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.407 Y147.978 E.00034
G3 X99.748 Y146.751 I-1.525 J.327 E.23175
G1 X99.839 Y146.746 E.00282
G3 X101.312 Y147.683 I.043 J1.559 E.05692
G1 X101.389 Y147.91 E.00737
; WIPE_START
G1 F12000
M204 S6000
G1 X101.407 Y147.978 E-.02671
G1 X101.446 Y148.286 E-.11782
G1 X101.429 Y148.53 E-.09314
G1 X101.358 Y148.821 E-.11363
G1 X101.227 Y149.102 E-.11802
G1 X101.043 Y149.352 E-.11812
G1 X100.812 Y149.561 E-.11807
G1 X100.689 Y149.634 E-.05451
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.768 Y150.591 Z11 F42000
G1 Z10.6
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00076
G3 X99.929 Y146.016 I.15 J-2.285 E.2175
G1 X100.028 Y146.02 E.00305
G3 X100.085 Y150.587 I-.135 J2.285 E.21094
G1 X99.828 Y150.59 E.00791
M204 S10000
G1 X99.858 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381141
G1 F2317
M204 S6000
G1 X99.575 Y150.205 E.00782
G3 X97.961 Y148.338 I.31 J-1.899 E.07384
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.525 J.044 E.00482
G3 X99.918 Y150.229 I1.918 J.159 E.24466
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.13052
G1 X99.205 Y150.106 E-.14565
G1 X98.861 Y149.935 E-.1458
G1 X98.559 Y149.7 E-.14564
G1 X98.309 Y149.41 E-.14564
G1 X98.249 Y149.302 E-.04674
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.686 Z11 F42000
G1 X98.752 Y141.49 Z11
G1 Z10.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.751 Y141.502 E.00034
G3 X97.092 Y140.275 I-1.525 J.327 E.23175
G1 X97.184 Y140.269 E.00282
G3 X98.656 Y141.206 I.043 J1.559 E.05692
G1 X98.733 Y141.434 E.00737
; WIPE_START
G1 F12000
M204 S6000
G1 X98.751 Y141.502 E-.02671
G1 X98.79 Y141.809 E-.11782
G1 X98.774 Y142.054 E-.09314
G1 X98.703 Y142.344 E-.11363
G1 X98.572 Y142.626 E-.11802
G1 X98.387 Y142.876 E-.11812
G1 X98.157 Y143.084 E-.11807
G1 X98.033 Y143.157 E-.05451
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.112 Y144.114 Z11 F42000
G1 Z10.6
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.087 Y144.113 E.00076
G3 X97.274 Y139.54 I.15 J-2.285 E.2175
G1 X97.373 Y139.543 E.00305
G3 X97.43 Y144.11 I-.135 J2.285 E.21094
G1 X97.172 Y144.113 E.00791
M204 S10000
G1 X97.202 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381141
G1 F2317
M204 S6000
G1 X96.92 Y143.728 E.00782
G3 X95.305 Y141.861 I.31 J-1.899 E.07384
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.525 J.044 E.00482
G3 X97.262 Y143.753 I1.918 J.159 E.24466
; CHANGE_LAYER
; Z_HEIGHT: 10.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.728 E-.13052
G1 X96.549 Y143.629 E-.14565
G1 X96.206 Y143.459 E-.1458
G1 X95.903 Y143.224 E-.14564
G1 X95.653 Y142.933 E-.14564
G1 X95.593 Y142.826 E-.04674
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 54/60
; update layer progress
M73 L54
M991 S0 P53 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z11 I-1.037 J.637 P1  F42000
G1 X106.719 Y160.92 Z11
G1 Z10.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.718 Y160.932 E.00035
G3 X105.059 Y159.705 I-1.525 J.327 E.23174
G1 X105.149 Y159.7 E.00278
G3 X106.623 Y160.636 I.044 J1.559 E.05697
G1 X106.7 Y160.863 E.00736
; WIPE_START
G1 F12000
M204 S6000
G1 X106.718 Y160.932 E-.02684
G1 X106.757 Y161.239 E-.11785
G1 X106.73 Y161.549 E-.11812
G1 X106.642 Y161.847 E-.11811
G1 X106.497 Y162.122 E-.11805
G1 X106.3 Y162.362 E-.11801
G1 X106.06 Y162.559 E-.11811
G1 X106.002 Y162.591 E-.02491
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.075 Y163.544 Z11.2 F42000
G1 Z10.8
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.543 E.00063
G3 X105.238 Y158.97 I.149 J-2.285 E.21749
G1 X105.34 Y158.973 E.00312
G3 X105.51 Y163.528 I-.136 J2.285 E.20738
G1 X105.135 Y163.541 E.01154
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.543 E-.03054
G1 X104.604 Y163.471 E-.17325
G1 X104.178 Y163.309 E-.17324
G1 X103.792 Y163.067 E-.17328
G1 X103.461 Y162.752 E-.17334
G1 X103.406 Y162.674 E-.03635
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z11.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 54 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z11.2
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
            G0 Z11.2 F4000
            G39.3 S1
            G0 Z11.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer54 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.683 Y162.436 F42000
G1 Z10.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381118
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00266
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.511 J.043 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28586
G1 X103.722 Y162.482 E.00626
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.05941
G1 X103.433 Y162.029 E-.14552
G1 X103.315 Y161.664 E-.14585
G1 X103.272 Y161.291 E-.1425
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06645
G1 X103.35 Y160.714 E-.14891
G1 X103.395 Y160.605 E-.04499
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.063 Y154.443 Z11.2 F42000
G1 Z10.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.062 Y154.455 E.00035
G3 X102.403 Y153.228 I-1.525 J.327 E.23174
G1 X102.493 Y153.223 E.00278
G3 X103.968 Y154.16 I.044 J1.559 E.05697
G1 X104.044 Y154.387 E.00736
; WIPE_START
G1 F12000
M204 S6000
G1 X104.062 Y154.455 E-.02684
G1 X104.101 Y154.763 E-.11785
G1 X104.074 Y155.072 E-.11812
G1 X103.986 Y155.37 E-.11811
G1 X103.841 Y155.645 E-.11805
G1 X103.645 Y155.885 E-.11801
G1 X103.404 Y156.082 E-.11811
G1 X103.347 Y156.114 E-.02491
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.419 Y157.067 Z11.2 F42000
G1 Z10.8
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00063
G3 X102.583 Y152.493 I.149 J-2.285 E.21749
G1 X102.684 Y152.497 E.00312
G3 X102.854 Y157.051 I-.136 J2.285 E.20738
G1 X102.479 Y157.065 E.01154
M204 S10000
G1 X102.509 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381118
G1 F2317
M204 S6000
G1 X102.231 Y156.681 E.00769
G3 X100.617 Y154.814 I.31 J-1.899 E.07384
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.511 J.043 E.00482
G3 X102.569 Y156.706 I1.918 J.159 E.24477
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.681 E-.1288
G1 X101.861 Y156.583 E-.14553
G1 X101.517 Y156.412 E-.14591
G1 X101.214 Y156.177 E-.14556
G1 X100.964 Y155.886 E-.14573
G1 X100.902 Y155.775 E-.04847
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.159 Z11.2 F42000
G1 X101.408 Y147.967 Z11.2
G1 Z10.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.407 Y147.978 E.00035
G3 X99.747 Y146.751 I-1.525 J.327 E.23174
G1 X99.838 Y146.746 E.00278
G3 X101.312 Y147.683 I.044 J1.559 E.05697
G1 X101.388 Y147.91 E.00736
; WIPE_START
G1 F12000
M204 S6000
G1 X101.407 Y147.978 E-.02684
G1 X101.446 Y148.286 E-.11785
G1 X101.419 Y148.595 E-.11812
G1 X101.331 Y148.894 E-.11811
G1 X101.186 Y149.168 E-.11805
G1 X100.989 Y149.409 E-.11801
G1 X100.748 Y149.605 E-.11811
G1 X100.691 Y149.637 E-.02491
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.763 Y150.59 Z11.2 F42000
G1 Z10.8
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00063
G3 X99.927 Y146.016 I.149 J-2.285 E.21749
G1 X100.028 Y146.02 E.00312
G3 X100.199 Y150.574 I-.136 J2.285 E.20738
G1 X99.823 Y150.588 E.01154
M204 S10000
G1 X99.853 Y150.229 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381118
G1 F2317
M204 S6000
G1 X99.575 Y150.205 E.00769
G3 X97.961 Y148.338 I.31 J-1.899 E.07384
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.511 J.043 E.00482
G3 X99.913 Y150.23 I1.918 J.159 E.24477
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.1288
G1 X99.205 Y150.106 E-.14553
G1 X98.861 Y149.935 E-.14591
G1 X98.559 Y149.7 E-.14556
G1 X98.309 Y149.41 E-.14573
G1 X98.246 Y149.298 E-.04847
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.682 Z11.2 F42000
G1 X98.752 Y141.49 Z11.2
G1 Z10.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.751 Y141.501 E.00035
G3 X97.092 Y140.275 I-1.525 J.327 E.23174
G1 X97.182 Y140.269 E.00278
G3 X98.656 Y141.206 I.044 J1.559 E.05697
G1 X98.733 Y141.433 E.00736
; WIPE_START
G1 F12000
M204 S6000
G1 X98.751 Y141.501 E-.02684
G1 X98.79 Y141.809 E-.11785
G1 X98.763 Y142.119 E-.11812
G1 X98.675 Y142.417 E-.11811
G1 X98.53 Y142.692 E-.11805
G1 X98.333 Y142.932 E-.11801
G1 X98.093 Y143.129 E-.11811
G1 X98.036 Y143.16 E-.02491
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.108 Y144.113 Z11.2 F42000
G1 Z10.8
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.087 Y144.113 E.00063
G3 X97.272 Y139.539 I.149 J-2.285 E.21749
G1 X97.373 Y139.543 E.00312
G3 X97.543 Y144.098 I-.136 J2.285 E.20738
G1 X97.168 Y144.111 E.01154
M204 S10000
G1 X97.198 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381118
G1 F2317
M204 S6000
G1 X96.92 Y143.728 E.00769
G3 X95.305 Y141.861 I.31 J-1.899 E.07384
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.67 I3.511 J.043 E.00482
G3 X97.258 Y143.753 I1.918 J.159 E.24477
; CHANGE_LAYER
; Z_HEIGHT: 11
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.728 E-.1288
G1 X96.55 Y143.63 E-.14553
G1 X96.206 Y143.459 E-.14591
G1 X95.903 Y143.224 E-.14556
G1 X95.653 Y142.933 E-.14573
G1 X95.591 Y142.822 E-.04847
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 55/60
; update layer progress
M73 L55
M991 S0 P54 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z11.2 I-1.037 J.637 P1  F42000
G1 X106.719 Y160.92 Z11.2
G1 Z11
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.718 Y160.931 E.00036
G3 X105.059 Y159.705 I-1.525 J.327 E.23173
G1 X105.148 Y159.7 E.00275
G3 X106.624 Y160.636 I.046 J1.559 E.05702
G1 X106.7 Y160.863 E.00734
; WIPE_START
G1 F12000
M204 S6000
G1 X106.718 Y160.931 E-.027
G1 X106.757 Y161.239 E-.11796
G1 X106.73 Y161.549 E-.11809
G1 X106.666 Y161.783 E-.0921
G1 X106.538 Y162.056 E-.11452
G1 X106.354 Y162.306 E-.11811
G1 X106.123 Y162.514 E-.11804
G1 X106.001 Y162.587 E-.05416
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.07 Y163.544 Z11.4 F42000
G1 Z11
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.544 E.00048
G3 X105.236 Y158.97 I.148 J-2.285 E.21751
G1 X105.34 Y158.973 E.00318
G3 X105.51 Y163.528 I-.137 J2.285 E.20731
G1 X105.13 Y163.542 E.01168
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.544 E-.02869
G1 X104.604 Y163.471 E-.17326
G1 X104.178 Y163.31 E-.17329
G1 X103.883 Y163.135 E-.13011
G1 X103.538 Y162.837 E-.17327
G1 X103.406 Y162.668 E-.08137
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z11.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 55 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z11.4
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
            G0 Z11.4 F4000
            G39.3 S1
            G0 Z11.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer55 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.68 Y162.433 F42000
G1 Z11
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381142
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00253
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.524 J.044 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.28588
G1 X103.719 Y162.478 E.00638
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.05762
G1 X103.432 Y162.029 E-.14569
G1 X103.315 Y161.664 E-.14569
G1 X103.272 Y161.291 E-.14259
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06647
G1 X103.35 Y160.714 E-.14887
G1 X103.397 Y160.601 E-.0467
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.063 Y154.443 Z11.4 F42000
G1 Z11
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.063 Y154.455 E.00036
G3 X102.403 Y153.228 I-1.525 J.327 E.23173
G1 X102.492 Y153.223 E.00275
G3 X103.968 Y154.16 I.046 J1.559 E.05702
G1 X104.044 Y154.386 E.00734
; WIPE_START
G1 F12000
M204 S6000
G1 X104.063 Y154.455 E-.027
G1 X104.101 Y154.763 E-.11796
G1 X104.074 Y155.072 E-.11809
G1 X104.011 Y155.306 E-.0921
G1 X103.883 Y155.579 E-.11452
G1 X103.698 Y155.829 E-.11811
G1 X103.468 Y156.038 E-.11804
G1 X103.345 Y156.11 E-.05416
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.414 Y157.067 Z11.4 F42000
G1 Z11
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00048
G3 X102.581 Y152.493 I.148 J-2.285 E.21751
G1 X102.684 Y152.497 E.00318
G3 X102.854 Y157.051 I-.137 J2.285 E.20731
G1 X102.474 Y157.065 E.01168
M204 S10000
G1 X102.504 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381142
G1 F2317
M204 S6000
G1 X102.231 Y156.681 E.00756
G3 X100.617 Y154.814 I.31 J-1.899 E.07385
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.524 J.044 E.00482
G3 X102.564 Y156.706 I1.918 J.159 E.24491
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.681 E-.12694
G1 X101.86 Y156.583 E-.14576
G1 X101.517 Y156.412 E-.14567
G1 X101.214 Y156.177 E-.14574
G1 X100.964 Y155.887 E-.14557
G1 X100.9 Y155.771 E-.05032
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.155 Z11.4 F42000
G1 X101.407 Y147.966 Z11.4
G1 Z11
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.407 Y147.978 E.00036
G3 X99.747 Y146.751 I-1.525 J.327 E.23173
G1 X99.837 Y146.746 E.00275
G3 X101.312 Y147.683 I.046 J1.559 E.05702
G1 X101.388 Y147.909 E.00734
; WIPE_START
G1 F12000
M204 S6000
G1 X101.407 Y147.978 E-.027
G1 X101.446 Y148.286 E-.11796
G1 X101.419 Y148.596 E-.11809
G1 X101.355 Y148.829 E-.0921
G1 X101.227 Y149.102 E-.11452
G1 X101.043 Y149.352 E-.11811
G1 X100.812 Y149.561 E-.11804
G1 X100.69 Y149.634 E-.05416
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.759 Y150.59 Z11.4 F42000
G1 Z11
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00048
G3 X99.925 Y146.016 I.148 J-2.285 E.21751
G1 X100.028 Y146.02 E.00318
G3 X100.199 Y150.574 I-.137 J2.285 E.20731
G1 X99.819 Y150.588 E.01168
M204 S10000
G1 X99.849 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381142
G1 F2317
M204 S6000
G1 X99.575 Y150.205 E.00756
G3 X97.961 Y148.338 I.31 J-1.899 E.07385
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.524 J.044 E.00482
G3 X99.909 Y150.23 I1.918 J.159 E.24491
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.12694
G1 X99.205 Y150.106 E-.14576
G1 X98.862 Y149.936 E-.14567
G1 X98.559 Y149.7 E-.14574
G1 X98.309 Y149.41 E-.14557
G1 X98.244 Y149.294 E-.05032
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.678 Z11.4 F42000
G1 X98.752 Y141.49 Z11.4
G1 Z11
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.752 Y141.501 E.00036
G3 X97.092 Y140.275 I-1.525 J.327 E.23173
G1 X97.181 Y140.269 E.00275
G3 X98.657 Y141.206 I.046 J1.559 E.05702
G1 X98.733 Y141.433 E.00734
; WIPE_START
G1 F12000
M204 S6000
G1 X98.752 Y141.501 E-.027
G1 X98.79 Y141.809 E-.11796
G1 X98.763 Y142.119 E-.11809
G1 X98.699 Y142.353 E-.0921
G1 X98.571 Y142.626 E-.11452
G1 X98.387 Y142.876 E-.11811
G1 X98.157 Y143.084 E-.11804
G1 X98.034 Y143.157 E-.05416
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.103 Y144.114 Z11.4 F42000
G1 Z11
M73 P96 R0
G1 E.8 F1800
M73 P97 R0
G1 F2317
M204 S5000
G1 X97.088 Y144.113 E.00048
G3 X97.27 Y139.539 I.148 J-2.285 E.21751
G1 X97.373 Y139.543 E.00318
G3 X97.543 Y144.097 I-.137 J2.285 E.20731
G1 X97.163 Y144.111 E.01168
M204 S10000
G1 X97.193 Y143.752 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381142
G1 F2317
M204 S6000
G1 X96.92 Y143.728 E.00756
G3 X95.305 Y141.861 I.31 J-1.899 E.07385
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.524 J.044 E.00482
G3 X97.253 Y143.753 I1.918 J.159 E.24491
; CHANGE_LAYER
; Z_HEIGHT: 11.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.728 E-.12694
G1 X96.549 Y143.629 E-.14576
G1 X96.206 Y143.459 E-.14567
G1 X95.903 Y143.223 E-.14574
G1 X95.653 Y142.933 E-.14557
G1 X95.588 Y142.818 E-.05032
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 56/60
; update layer progress
M73 L56
M991 S0 P55 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z11.4 I-1.037 J.637 P1  F42000
G1 X106.719 Y160.919 Z11.4
G1 Z11.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.719 Y160.931 E.00037
G3 X105.059 Y159.705 I-1.525 J.327 E.23172
G1 X105.147 Y159.7 E.00271
G3 X106.624 Y160.636 I.048 J1.559 E.05707
G1 X106.7 Y160.862 E.00732
; WIPE_START
G1 F12000
M204 S6000
G1 X106.719 Y160.931 E-.02722
G1 X106.757 Y161.239 E-.11796
G1 X106.73 Y161.549 E-.11807
G1 X106.667 Y161.782 E-.09167
G1 X106.538 Y162.056 E-.11495
G1 X106.354 Y162.306 E-.11815
G1 X106.123 Y162.514 E-.11806
G1 X106.001 Y162.587 E-.05392
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.065 Y163.544 Z11.6 F42000
G1 Z11.2
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.544 E.00034
G3 X105.234 Y158.969 I.147 J-2.285 E.21751
G1 X105.34 Y158.973 E.00324
G3 X105.51 Y163.527 I-.138 J2.285 E.20726
G1 X105.125 Y163.542 E.01182
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.544 E-.02696
G1 X104.604 Y163.471 E-.17324
G1 X104.281 Y163.358 E-.1302
G1 X103.883 Y163.135 E-.17319
G1 X103.538 Y162.837 E-.17331
G1 X103.404 Y162.665 E-.0831
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z11.6 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 56 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z11.6
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
            G0 Z11.6 F4000
            G39.3 S1
            G0 Z11.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer56 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.677 Y162.429 F42000
G1 Z11.2
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.38116
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00242
G3 X103.272 Y161.291 I1.576 J-1.104 E.03151
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.519 J.044 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.2859
G1 X103.716 Y162.475 E.00651
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.0561
G1 X103.432 Y162.029 E-.1456
G1 X103.315 Y161.664 E-.1456
G1 X103.272 Y161.291 E-.14258
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06639
G1 X103.35 Y160.714 E-.14902
G1 X103.398 Y160.596 E-.04834
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.063 Y154.443 Z11.6 F42000
G1 Z11.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.063 Y154.455 E.00037
G3 X102.403 Y153.228 I-1.525 J.327 E.23172
G1 X102.491 Y153.223 E.00271
G3 X103.968 Y154.16 I.048 J1.559 E.05707
G1 X104.044 Y154.386 E.00732
; WIPE_START
G1 F12000
M204 S6000
G1 X104.063 Y154.455 E-.02722
G1 X104.101 Y154.763 E-.11796
G1 X104.074 Y155.072 E-.11807
G1 X104.011 Y155.305 E-.09167
G1 X103.883 Y155.579 E-.11495
G1 X103.698 Y155.829 E-.11815
G1 X103.468 Y156.038 E-.11806
G1 X103.346 Y156.11 E-.05392
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.41 Y157.067 Z11.6 F42000
G1 Z11.2
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00034
G3 X102.579 Y152.493 I.147 J-2.285 E.21751
G1 X102.684 Y152.497 E.00324
G3 X102.854 Y157.051 I-.138 J2.285 E.20726
G1 X102.47 Y157.065 E.01182
M204 S10000
G1 X102.5 Y156.705 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38116
G1 F2317
M204 S6000
G1 X102.231 Y156.681 E.00744
G3 X100.617 Y154.814 I.31 J-1.899 E.07385
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.519 J.044 E.00482
G3 X102.56 Y156.707 I1.918 J.159 E.24505
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.681 E-.12536
G1 X101.86 Y156.583 E-.14567
G1 X101.517 Y156.412 E-.14577
G1 X101.214 Y156.177 E-.14556
G1 X100.964 Y155.886 E-.14582
G1 X100.897 Y155.767 E-.05183
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.151 Z11.6 F42000
G1 X101.407 Y147.966 Z11.6
G1 Z11.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.408 Y147.978 E.00037
G3 X99.747 Y146.751 I-1.525 J.327 E.23172
G1 X99.835 Y146.746 E.00271
G3 X101.313 Y147.683 I.048 J1.559 E.05707
G1 X101.388 Y147.909 E.00732
; WIPE_START
G1 F12000
M204 S6000
G1 X101.408 Y147.978 E-.02722
G1 X101.446 Y148.286 E-.11796
G1 X101.419 Y148.595 E-.11807
G1 X101.355 Y148.828 E-.09167
G1 X101.227 Y149.102 E-.11495
G1 X101.042 Y149.352 E-.11815
G1 X100.812 Y149.561 E-.11806
G1 X100.69 Y149.633 E-.05392
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.754 Y150.591 Z11.6 F42000
G1 Z11.2
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00034
G3 X99.923 Y146.016 I.147 J-2.285 E.21751
G1 X100.028 Y146.02 E.00324
G3 X100.199 Y150.574 I-.138 J2.285 E.20726
G1 X99.814 Y150.588 E.01182
M204 S10000
G1 X99.844 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38116
G1 F2317
M204 S6000
G1 X99.575 Y150.205 E.00744
G3 X97.961 Y148.338 I.31 J-1.899 E.07385
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.519 J.044 E.00482
G3 X99.904 Y150.23 I1.918 J.159 E.24505
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.12536
G1 X99.205 Y150.106 E-.14567
G1 X98.861 Y149.935 E-.14577
G1 X98.559 Y149.7 E-.14556
G1 X98.309 Y149.409 E-.14582
G1 X98.242 Y149.29 E-.05183
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.674 Z11.6 F42000
G1 X98.752 Y141.489 Z11.6
G1 Z11.2
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.752 Y141.501 E.00037
G3 X97.092 Y140.275 I-1.525 J.327 E.23172
G1 X97.18 Y140.27 E.00271
G3 X98.657 Y141.206 I.048 J1.559 E.05707
G1 X98.733 Y141.432 E.00732
; WIPE_START
G1 F12000
M204 S6000
G1 X98.752 Y141.501 E-.02722
G1 X98.79 Y141.809 E-.11796
G1 X98.763 Y142.119 E-.11807
G1 X98.7 Y142.352 E-.09167
G1 X98.572 Y142.626 E-.11495
G1 X98.387 Y142.876 E-.11815
G1 X98.157 Y143.084 E-.11806
G1 X98.035 Y143.157 E-.05392
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.099 Y144.114 Z11.6 F42000
G1 Z11.2
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.088 Y144.113 E.00034
G3 X97.268 Y139.539 I.147 J-2.285 E.21751
G1 X97.373 Y139.543 E.00324
G3 X97.543 Y144.097 I-.138 J2.285 E.20726
G1 X97.159 Y144.112 E.01182
M204 S10000
G1 X97.189 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.38116
G1 F2317
M204 S6000
G1 X96.92 Y143.728 E.00744
G3 X95.305 Y141.861 I.31 J-1.899 E.07385
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.67 I3.519 J.044 E.00482
G3 X97.249 Y143.753 I1.918 J.159 E.24505
; CHANGE_LAYER
; Z_HEIGHT: 11.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.728 E-.12536
G1 X96.549 Y143.629 E-.14567
G1 X96.206 Y143.459 E-.14577
G1 X95.903 Y143.224 E-.14556
G1 X95.653 Y142.933 E-.14582
G1 X95.586 Y142.814 E-.05182
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 57/60
; update layer progress
M73 L57
M991 S0 P56 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z11.6 I-1.037 J.637 P1  F42000
G1 X106.718 Y160.919 Z11.6
G1 Z11.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.719 Y160.931 E.00038
G3 X105.058 Y159.705 I-1.525 J.327 E.2317
G1 X105.145 Y159.7 E.00268
G3 X106.625 Y160.636 I.049 J1.558 E.05711
G1 X106.7 Y160.862 E.00732
; WIPE_START
G1 F12000
M204 S6000
G1 X106.719 Y160.931 E-.02738
G1 X106.757 Y161.239 E-.11793
G1 X106.73 Y161.549 E-.11817
G1 X106.642 Y161.847 E-.118
G1 X106.497 Y162.121 E-.11802
G1 X106.349 Y162.311 E-.09129
G1 X106.124 Y162.514 E-.11537
G1 X106.002 Y162.586 E-.05384
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.061 Y163.544 Z11.8 F42000
G1 Z11.4
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.544 E.00021
G3 X105.232 Y158.969 I.146 J-2.285 E.2175
G1 X105.34 Y158.973 E.0033
G3 X105.51 Y163.527 I-.139 J2.285 E.20719
G1 X105.121 Y163.542 E.01196
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.544 E-.02538
G1 X104.604 Y163.471 E-.17317
G1 X104.178 Y163.309 E-.17331
G1 X103.792 Y163.067 E-.17327
G1 X103.461 Y162.753 E-.1733
G1 X103.396 Y162.665 E-.04156
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z11.8 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 57 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z11.8
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
            G0 Z11.8 F4000
            G39.3 S1
            G0 Z11.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer57 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.674 Y162.426 F42000
G1 Z11.4
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381161
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00227
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.538 J.044 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.2859
G1 X103.713 Y162.471 E.00663
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.05411
G1 X103.432 Y162.029 E-.14567
G1 X103.315 Y161.664 E-.14581
G1 X103.272 Y161.291 E-.14245
G1 X103.272 Y161.274 E-.00637
G1 X103.278 Y161.1 E-.06649
G1 X103.35 Y160.714 E-.14895
G1 X103.4 Y160.592 E-.05016
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.063 Y154.442 Z11.8 F42000
G1 Z11.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.064 Y154.454 E.00038
G3 X102.403 Y153.228 I-1.525 J.327 E.2317
G1 X102.49 Y153.223 E.00268
G3 X103.969 Y154.159 I.049 J1.558 E.05711
G1 X104.044 Y154.385 E.00732
; WIPE_START
G1 F12000
M204 S6000
G1 X104.064 Y154.454 E-.02738
G1 X104.101 Y154.763 E-.11793
G1 X104.074 Y155.072 E-.11817
G1 X103.986 Y155.37 E-.118
G1 X103.841 Y155.645 E-.11802
G1 X103.693 Y155.834 E-.09129
G1 X103.468 Y156.037 E-.11537
G1 X103.346 Y156.11 E-.05384
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.405 Y157.067 Z11.8 F42000
G1 Z11.4
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00021
G3 X102.577 Y152.493 I.146 J-2.285 E.2175
G1 X102.684 Y152.497 E.0033
G3 X102.854 Y157.05 I-.139 J2.285 E.20719
G1 X102.465 Y157.065 E.01196
M204 S10000
G1 X102.496 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381161
G1 F2317
M204 S6000
G1 X102.231 Y156.681 E.00732
G3 X100.617 Y154.815 I.31 J-1.899 E.07385
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.538 J.044 E.00482
G3 X102.555 Y156.706 I1.918 J.159 E.24517
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.681 E-.12365
G1 X101.861 Y156.583 E-.14566
G1 X101.517 Y156.412 E-.14568
G1 X101.214 Y156.177 E-.14575
G1 X100.964 Y155.887 E-.14562
G1 X100.895 Y155.763 E-.05364
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.147 Z11.8 F42000
G1 X101.407 Y147.965 Z11.8
G1 Z11.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.408 Y147.978 E.00038
G3 X99.747 Y146.751 I-1.525 J.327 E.2317
G1 X99.834 Y146.746 E.00268
G3 X101.313 Y147.683 I.049 J1.558 E.05711
G1 X101.388 Y147.908 E.00732
; WIPE_START
G1 F12000
M204 S6000
G1 X101.408 Y147.978 E-.02738
G1 X101.446 Y148.286 E-.11793
G1 X101.419 Y148.596 E-.11817
G1 X101.331 Y148.893 E-.118
G1 X101.186 Y149.168 E-.11802
G1 X101.038 Y149.357 E-.09129
G1 X100.812 Y149.561 E-.11537
G1 X100.691 Y149.633 E-.05384
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.75 Y150.591 Z11.8 F42000
G1 Z11.4
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00021
G3 X99.921 Y146.016 I.146 J-2.285 E.2175
G1 X100.028 Y146.02 E.0033
G3 X100.199 Y150.574 I-.139 J2.285 E.20719
G1 X99.81 Y150.588 E.01196
M204 S10000
G1 X99.84 Y150.228 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381161
G1 F2317
M204 S6000
G1 X99.575 Y150.205 E.00732
G3 X97.961 Y148.338 I.31 J-1.899 E.07385
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.538 J.044 E.00482
G3 X99.9 Y150.23 I1.918 J.159 E.24517
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.12365
G1 X99.205 Y150.106 E-.14566
G1 X98.862 Y149.936 E-.14568
G1 X98.559 Y149.7 E-.14575
G1 X98.309 Y149.41 E-.14562
G1 X98.24 Y149.287 E-.05364
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.671 Z11.8 F42000
G1 X98.752 Y141.489 Z11.8
G1 Z11.4
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.753 Y141.501 E.00038
G3 X97.092 Y140.275 I-1.525 J.327 E.2317
G1 X97.179 Y140.27 E.00268
G3 X98.658 Y141.206 I.049 J1.558 E.05711
G1 X98.733 Y141.432 E.00732
; WIPE_START
G1 F12000
M204 S6000
G1 X98.753 Y141.501 E-.02738
G1 X98.79 Y141.809 E-.11793
G1 X98.763 Y142.119 E-.11817
G1 X98.675 Y142.417 E-.118
G1 X98.53 Y142.691 E-.11802
G1 X98.382 Y142.881 E-.09129
G1 X98.157 Y143.084 E-.11537
G1 X98.035 Y143.156 E-.05384
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.094 Y144.114 Z11.8 F42000
G1 Z11.4
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.087 Y144.113 E.00021
G3 X97.265 Y139.539 I.146 J-2.285 E.2175
G1 X97.373 Y139.543 E.0033
G3 X97.543 Y144.097 I-.139 J2.285 E.20719
G1 X97.154 Y144.112 E.01196
M204 S10000
G1 X97.184 Y143.751 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381161
G1 F2317
M204 S6000
G1 X96.92 Y143.728 E.00732
G3 X95.305 Y141.861 I.31 J-1.899 E.07385
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.538 J.044 E.00482
G3 X97.244 Y143.753 I1.918 J.159 E.24517
; CHANGE_LAYER
; Z_HEIGHT: 11.6
; LAYER_HEIGHT: 0.200001
; WIPE_START
G1 F15000
G1 X96.92 Y143.728 E-.12365
G1 X96.549 Y143.629 E-.14566
G1 X96.206 Y143.459 E-.14568
G1 X95.903 Y143.224 E-.14575
G1 X95.653 Y142.933 E-.14562
G1 X95.584 Y142.81 E-.05364
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 58/60
; update layer progress
M73 L58
M991 S0 P57 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z11.8 I-1.037 J.637 P1  F42000
G1 X106.718 Y160.918 Z11.8
G1 Z11.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X106.72 Y160.931 E.0004
G3 X105.058 Y159.705 I-1.525 J.327 E.23167
G1 X105.144 Y159.7 E.00264
G3 X106.625 Y160.636 I.051 J1.558 E.05717
G1 X106.699 Y160.861 E.00729
; WIPE_START
G1 F12000
M204 S6000
G1 X106.72 Y160.931 E-.02767
G1 X106.757 Y161.234 E-.11592
G1 X106.742 Y161.475 E-.09179
G1 X106.669 Y161.777 E-.11802
G1 X106.538 Y162.056 E-.11698
G1 X106.354 Y162.306 E-.11809
G1 X106.123 Y162.514 E-.11804
G1 X106.002 Y162.586 E-.05349
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.057 Y163.544 Z12 F42000
G1 Z11.6
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X105.054 Y163.544 E.00008
G3 X105.23 Y158.969 I.145 J-2.285 E.21751
G1 X105.34 Y158.973 E.00336
G3 X105.51 Y163.527 I-.14 J2.285 E.20713
G1 X105.117 Y163.542 E.01208
; WIPE_START
G1 F12000
M204 S6000
G1 X105.054 Y163.544 E-.02378
G1 X104.604 Y163.471 E-.17326
G1 X104.178 Y163.309 E-.17324
G1 X103.791 Y163.067 E-.17335
G1 X103.461 Y162.752 E-.17326
G1 X103.394 Y162.661 E-.04311
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z12 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 58 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z12
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
            G0 Z12 F4000
            G39.3 S1
            G0 Z12 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer58 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.671 Y162.423 F42000
G1 Z11.6
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381165
G1 F2317
M204 S6000
G1 X103.62 Y162.363 E.00216
G3 X103.272 Y161.291 I1.576 J-1.104 E.03152
G1 X103.272 Y161.274 E.00046
G3 X103.278 Y161.1 I3.508 J.044 E.00481
G3 X103.87 Y162.653 I1.918 J.159 E.28592
G1 X103.71 Y162.468 E.00675
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.05263
G1 X103.432 Y162.029 E-.14565
G1 X103.315 Y161.664 E-.14565
G1 X103.272 Y161.291 E-.14257
G1 X103.272 Y161.274 E-.00638
G1 X103.278 Y161.1 E-.06638
G1 X103.35 Y160.714 E-.14894
G1 X103.402 Y160.588 E-.05181
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.063 Y154.442 Z12 F42000
G1 Z11.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X104.065 Y154.454 E.0004
G3 X102.403 Y153.228 I-1.525 J.327 E.23167
G1 X102.489 Y153.223 E.00264
G3 X103.97 Y154.159 I.051 J1.558 E.05717
G1 X104.044 Y154.385 E.00729
; WIPE_START
G1 F12000
M204 S6000
G1 X104.065 Y154.454 E-.02767
G1 X104.101 Y154.757 E-.11592
G1 X104.086 Y154.998 E-.09179
G1 X104.013 Y155.3 E-.11802
G1 X103.883 Y155.579 E-.11698
G1 X103.698 Y155.829 E-.11809
G1 X103.468 Y156.038 E-.11804
G1 X103.347 Y156.109 E-.05349
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.401 Y157.068 Z12 F42000
G1 Z11.6
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X102.399 Y157.067 E.00008
G3 X102.575 Y152.493 I.145 J-2.285 E.21751
G1 X102.684 Y152.497 E.00336
G3 X102.854 Y157.05 I-.14 J2.285 E.20713
G1 X102.461 Y157.065 E.01208
M204 S10000
G1 X102.491 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381165
G1 F2317
M204 S6000
G1 X102.231 Y156.682 E.00721
G3 X100.617 Y154.814 I.31 J-1.899 E.07385
G1 X100.616 Y154.798 E.00046
G3 X100.623 Y154.623 I3.508 J.044 E.00481
G3 X102.551 Y156.707 I1.918 J.159 E.24531
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.682 E-.12213
G1 X101.86 Y156.583 E-.14576
G1 X101.517 Y156.412 E-.14555
G1 X101.214 Y156.177 E-.14572
G1 X100.964 Y155.886 E-.14573
G1 X100.893 Y155.76 E-.05512
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.144 Z12 F42000
G1 X101.407 Y147.965 Z12
G1 Z11.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X101.409 Y147.978 E.0004
G3 X99.747 Y146.751 I-1.525 J.327 E.23167
G1 X99.833 Y146.746 E.00264
G3 X101.314 Y147.682 I.051 J1.558 E.05717
G1 X101.388 Y147.908 E.00729
; WIPE_START
G1 F12000
M204 S6000
G1 X101.409 Y147.978 E-.02767
G1 X101.446 Y148.281 E-.11592
G1 X101.431 Y148.522 E-.09179
G1 X101.357 Y148.823 E-.11802
G1 X101.227 Y149.102 E-.11698
G1 X101.043 Y149.352 E-.11809
G1 X100.812 Y149.561 E-.11804
G1 X100.691 Y149.633 E-.05349
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.746 Y150.591 Z12 F42000
G1 Z11.6
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X99.743 Y150.59 E.00008
G3 X99.919 Y146.016 I.145 J-2.285 E.21751
G1 X100.028 Y146.02 E.00336
G3 X100.199 Y150.574 I-.14 J2.285 E.20713
G1 X99.806 Y150.589 E.01208
M204 S10000
G1 X99.836 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381165
G1 F2317
M204 S6000
G1 X99.575 Y150.205 E.00721
M73 P98 R0
G3 X97.961 Y148.338 I.31 J-1.899 E.07385
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.508 J.044 E.00481
G3 X99.896 Y150.23 I1.918 J.159 E.24531
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.12213
G1 X99.205 Y150.106 E-.14576
G1 X98.862 Y149.936 E-.14555
G1 X98.559 Y149.7 E-.14572
G1 X98.309 Y149.41 E-.14573
G1 X98.238 Y149.283 E-.05512
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.667 Z12 F42000
G1 X98.751 Y141.488 Z12
G1 Z11.6
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2317
M204 S5000
G1 X98.753 Y141.501 E.0004
G3 X97.092 Y140.275 I-1.525 J.327 E.23167
G1 X97.177 Y140.27 E.00264
G3 X98.658 Y141.206 I.051 J1.558 E.05717
G1 X98.733 Y141.431 E.00729
; WIPE_START
G1 F12000
M204 S6000
G1 X98.753 Y141.501 E-.02767
G1 X98.79 Y141.804 E-.11592
G1 X98.775 Y142.045 E-.09179
G1 X98.702 Y142.347 E-.11802
G1 X98.571 Y142.626 E-.11698
G1 X98.387 Y142.876 E-.11809
G1 X98.157 Y143.084 E-.11804
G1 X98.036 Y143.156 E-.05349
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.09 Y144.114 Z12 F42000
G1 Z11.6
G1 E.8 F1800
G1 F2317
M204 S5000
G1 X97.087 Y144.113 E.00008
G3 X97.263 Y139.539 I.145 J-2.285 E.21751
G1 X97.373 Y139.543 E.00336
G3 X97.543 Y144.097 I-.14 J2.285 E.20713
G1 X97.15 Y144.112 E.01208
M204 S10000
G1 X97.18 Y143.75 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381165
G1 F2317
M204 S6000
G1 X96.92 Y143.728 E.00721
G3 X95.305 Y141.861 I.31 J-1.899 E.07385
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.67 I3.508 J.044 E.00481
G3 X97.24 Y143.753 I1.918 J.159 E.24531
; CHANGE_LAYER
; Z_HEIGHT: 11.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.728 E-.12213
G1 X96.549 Y143.629 E-.14576
G1 X96.206 Y143.459 E-.14555
G1 X95.903 Y143.224 E-.14572
G1 X95.653 Y142.933 E-.14573
G1 X95.582 Y142.806 E-.05512
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 59/60
; update layer progress
M73 L59
M991 S0 P58 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z12 I-1.037 J.637 P1  F42000
G1 X106.718 Y160.918 Z12
G1 Z11.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X106.721 Y160.931 E.0004
G3 X105.058 Y159.705 I-1.525 J.327 E.23166
G1 X105.143 Y159.7 E.0026
G3 X106.626 Y160.636 I.053 J1.558 E.05722
G1 X106.699 Y160.861 E.00728
; WIPE_START
G1 F12000
M204 S6000
G1 X106.721 Y160.931 E-.02772
G1 X106.757 Y161.239 E-.11804
G1 X106.73 Y161.549 E-.11821
G1 X106.643 Y161.844 E-.11693
G1 X106.538 Y162.056 E-.0896
G1 X106.353 Y162.306 E-.11833
G1 X106.124 Y162.514 E-.11774
G1 X106.003 Y162.586 E-.05342
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.052 Y163.544 Z12.2 F42000
G1 Z11.8
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X104.604 Y163.47 E.01395
G3 X105.228 Y158.969 I.594 J-2.211 E.20348
G1 X105.34 Y158.973 E.00342
G3 X105.112 Y163.546 I-.141 J2.285 E.21932
; WIPE_START
G1 F12000
M204 S6000
G1 X104.604 Y163.47 E-.19509
G1 X104.178 Y163.309 E-.17321
G1 X103.791 Y163.067 E-.17334
G1 X103.461 Y162.752 E-.17326
G1 X103.393 Y162.655 E-.04509
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z12.2 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 59 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z12.2
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
            G0 Z12.2 F4000
            G39.3 S1
            G0 Z12.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer59 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.668 Y162.419 F42000
G1 Z11.8
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F2327
M204 S6000
G1 X103.62 Y162.363 E.00202
G3 X103.272 Y161.291 I1.576 J-1.104 E.03153
G1 X103.272 Y161.274 E.00046
G3 X103.279 Y161.099 I3.516 J.044 E.00482
G3 X103.87 Y162.653 I1.918 J.159 E.2859
G1 X103.707 Y162.464 E.00688
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.62 Y162.363 E-.05063
G1 X103.432 Y162.029 E-.14569
G1 X103.315 Y161.664 E-.14571
G1 X103.272 Y161.291 E-.14269
G1 X103.272 Y161.274 E-.00638
G1 X103.279 Y161.099 E-.0664
G1 X103.35 Y160.714 E-.14887
G1 X103.404 Y160.584 E-.05363
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.063 Y154.441 Z12.2 F42000
G1 Z11.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X104.065 Y154.454 E.0004
G3 X102.403 Y153.228 I-1.525 J.327 E.23166
G1 X102.487 Y153.223 E.0026
G3 X103.97 Y154.159 I.053 J1.558 E.05722
G1 X104.044 Y154.384 E.00728
; WIPE_START
G1 F12000
M204 S6000
G1 X104.065 Y154.454 E-.02772
G1 X104.101 Y154.763 E-.11804
G1 X104.074 Y155.073 E-.11821
G1 X103.987 Y155.368 E-.11693
G1 X103.883 Y155.579 E-.0896
G1 X103.698 Y155.83 E-.11833
G1 X103.468 Y156.037 E-.11774
G1 X103.347 Y156.109 E-.05342
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.397 Y157.067 Z12.2 F42000
G1 Z11.8
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X101.949 Y156.993 E.01395
G3 X102.573 Y152.492 I.594 J-2.211 E.20348
G1 X102.684 Y152.497 E.00342
G3 X102.456 Y157.07 I-.141 J2.285 E.21932
M204 S10000
G1 X102.487 Y156.704 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F2327
M204 S6000
G1 X102.231 Y156.681 E.00709
G3 X100.617 Y154.814 I.31 J-1.899 E.07386
G1 X100.616 Y154.797 E.00046
G3 X100.623 Y154.623 I3.516 J.044 E.00482
G3 X102.547 Y156.707 I1.918 J.159 E.2454
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.231 Y156.681 E-.12045
G1 X101.861 Y156.583 E-.14554
G1 X101.517 Y156.412 E-.14582
G1 X101.214 Y156.177 E-.14579
G1 X100.964 Y155.887 E-.14551
G1 X100.891 Y155.756 E-.05689
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.395 Y148.14 Z12.2 F42000
G1 X101.407 Y147.965 Z12.2
G1 Z11.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X101.409 Y147.977 E.0004
G3 X99.747 Y146.751 I-1.525 J.327 E.23166
G1 X99.832 Y146.746 E.0026
G3 X101.314 Y147.682 I.053 J1.558 E.05722
G1 X101.388 Y147.908 E.00728
; WIPE_START
G1 F12000
M204 S6000
G1 X101.409 Y147.977 E-.02772
G1 X101.446 Y148.286 E-.11804
G1 X101.419 Y148.596 E-.11821
G1 X101.332 Y148.891 E-.11693
G1 X101.227 Y149.102 E-.0896
G1 X101.042 Y149.353 E-.11833
G1 X100.812 Y149.561 E-.11774
G1 X100.691 Y149.632 E-.05342
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.741 Y150.591 Z12.2 F42000
G1 Z11.8
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X99.293 Y150.516 E.01395
G3 X99.917 Y146.016 I.594 J-2.211 E.20348
G1 X100.028 Y146.02 E.00342
G3 X99.801 Y150.593 I-.141 J2.285 E.21932
M204 S10000
G1 X99.831 Y150.227 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F2327
M204 S6000
G1 X99.575 Y150.205 E.00709
G3 X97.961 Y148.337 I.31 J-1.899 E.07386
G1 X97.961 Y148.321 E.00046
G3 X97.967 Y148.146 I3.516 J.044 E.00482
G3 X99.891 Y150.23 I1.918 J.159 E.2454
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.575 Y150.205 E-.12045
G1 X99.205 Y150.106 E-.14554
G1 X98.861 Y149.936 E-.14582
G1 X98.559 Y149.7 E-.14579
G1 X98.309 Y149.41 E-.14551
G1 X98.236 Y149.279 E-.05689
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.74 Y141.663 Z12.2 F42000
G1 X98.751 Y141.488 Z12.2
G1 Z11.8
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2327
M204 S5000
G1 X98.754 Y141.501 E.0004
G3 X97.091 Y140.275 I-1.525 J.327 E.23166
G1 X97.176 Y140.27 E.0026
G3 X98.659 Y141.206 I.053 J1.558 E.05722
G1 X98.733 Y141.431 E.00728
; WIPE_START
G1 F12000
M204 S6000
G1 X98.754 Y141.501 E-.02772
G1 X98.79 Y141.809 E-.11804
G1 X98.763 Y142.119 E-.11821
G1 X98.676 Y142.414 E-.11693
G1 X98.572 Y142.626 E-.0896
G1 X98.387 Y142.876 E-.11833
G1 X98.157 Y143.084 E-.11774
G1 X98.036 Y143.156 E-.05342
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.086 Y144.114 Z12.2 F42000
G1 Z11.8
G1 E.8 F1800
G1 F2327
M204 S5000
G1 X96.638 Y144.04 E.01395
G3 X97.261 Y139.539 I.594 J-2.211 E.20348
G1 X97.373 Y139.543 E.00342
G3 X97.145 Y144.116 I-.141 J2.285 E.21932
M204 S10000
G1 X97.176 Y143.75 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381159
G1 F2327
M204 S6000
G1 X96.92 Y143.728 E.00709
G3 X95.305 Y141.861 I.31 J-1.899 E.07386
G1 X95.305 Y141.844 E.00046
G3 X95.312 Y141.669 I3.516 J.044 E.00482
G3 X97.236 Y143.753 I1.918 J.159 E.2454
; CHANGE_LAYER
; Z_HEIGHT: 12
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F15000
G1 X96.92 Y143.728 E-.12045
G1 X96.55 Y143.63 E-.14554
G1 X96.206 Y143.459 E-.14582
G1 X95.903 Y143.223 E-.14579
G1 X95.653 Y142.933 E-.14551
G1 X95.58 Y142.803 E-.05689
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 113
M625
; layer num/total_layer_count: 60/60
; update layer progress
M73 L60
M991 S0 P59 ;notify layer change
; OBJECT_ID: 124
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
M204 S10000
G17
G3 Z12.2 I-1.037 J.637 P1  F42000
G1 X106.709 Y160.908 Z12.2
G1 Z12
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X106.747 Y161.084 E.00554
G3 X104.983 Y159.713 I-1.55 J.174 E.22455
G1 X105.138 Y159.7 E.00478
G3 X106.681 Y160.78 I.059 J1.558 E.06215
G1 X106.696 Y160.849 E.00216
; WIPE_START
G1 F12000
M204 S6000
G1 X106.747 Y161.084 E-.09134
G1 X106.751 Y161.395 E-.11798
G1 X106.693 Y161.7 E-.11807
G1 X106.576 Y161.988 E-.11808
G1 X106.405 Y162.247 E-.11798
G1 X106.185 Y162.467 E-.11819
G1 X106.013 Y162.581 E-.07836
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.049 Y163.543 Z12.4 F42000
G1 Z12
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X104.605 Y163.47 E.01383
G3 X105.226 Y158.969 I.593 J-2.212 E.20348
G1 X105.34 Y158.973 E.00348
G3 X105.108 Y163.546 I-.142 J2.285 E.21938
; WIPE_START
G1 F12000
M204 S6000
G1 X104.605 Y163.47 E-.19361
G1 X104.178 Y163.309 E-.17332
G1 X103.792 Y163.067 E-.17329
G1 X103.461 Y162.753 E-.17327
G1 X103.391 Y162.652 E-.04651
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z12.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 124
M625
; object ids of layer 60 start: 91,102,113,124
M624 HgAAAAAAAAA=
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z12.4
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
            G0 Z12.4 F4000
            G39.3 S1
            G0 Z12.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END


; object ids of this layer60 end: 91,102,113,124
M625
; start printing object, unique label id: 124
M624 EAAAAAAAAAA=
G1 X103.679 Y162.428 F42000
G1 Z12
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.381162
G1 F2326
M204 S6000
G1 X103.567 Y162.283 E.00506
G3 X103.273 Y161.195 I1.63 J-1.024 E.03152
G1 X103.273 Y161.187 E.00022
G3 X103.289 Y161.004 I4.887 J.329 E.00505
G3 X103.803 Y162.586 I1.908 J.254 E.28597
G1 X103.716 Y162.475 E.00386
; OBJECT_ID: 102
; WIPE_START
G1 F15000
G1 X103.567 Y162.283 E-.09255
G1 X103.396 Y161.94 E-.14578
G1 X103.297 Y161.57 E-.14553
G1 X103.273 Y161.195 E-.14262
G1 X103.273 Y161.187 E-.00309
G1 X103.289 Y161.004 E-.06959
G1 X103.38 Y160.623 E-.14903
G1 X103.393 Y160.595 E-.01179
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 124
M625
; start printing object, unique label id: 102
M624 BAAAAAAAAAA=
M204 S10000
G1 X104.054 Y154.431 Z12.4 F42000
G1 Z12
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X104.091 Y154.608 E.00554
G3 X102.328 Y153.237 I-1.55 J.174 E.22455
G1 X102.483 Y153.223 E.00478
G3 X104.026 Y154.304 I.059 J1.558 E.06215
G1 X104.041 Y154.373 E.00216
; WIPE_START
G1 F12000
M204 S6000
G1 X104.091 Y154.608 E-.09134
G1 X104.096 Y154.918 E-.11798
G1 X104.038 Y155.223 E-.11807
G1 X103.921 Y155.511 E-.11808
G1 X103.749 Y155.77 E-.11798
G1 X103.529 Y155.99 E-.11819
G1 X103.357 Y156.104 E-.07836
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.393 Y157.067 Z12.4 F42000
G1 Z12
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X101.949 Y156.993 E.01383
G3 X102.571 Y152.492 I.593 J-2.212 E.20348
G1 X102.684 Y152.497 E.00348
G3 X102.453 Y157.07 I-.142 J2.285 E.21938
M204 S10000
G1 X102.44 Y156.703 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381162
G1 F2326
M204 S6000
G1 X102.421 Y156.703 E.00051
G3 X100.617 Y154.718 I.12 J-1.921 E.08179
G1 X100.617 Y154.71 E.00022
G3 X100.633 Y154.528 I4.887 J.329 E.00505
G3 X102.791 Y156.691 I1.908 J.254 E.2361
G1 X102.5 Y156.701 E.00802
; OBJECT_ID: 91
; WIPE_START
G1 F15000
G1 X102.421 Y156.703 E-.02989
G1 X102.043 Y156.642 E-.14558
G1 X101.759 Y156.541 E-.11448
G1 X101.437 Y156.359 E-.14066
G1 X101.147 Y156.109 E-.14546
G1 X100.911 Y155.806 E-.14583
G1 X100.867 Y155.717 E-.03809
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 102
M625
; start printing object, unique label id: 91
M624 AgAAAAAAAAA=
M204 S10000
G1 X101.388 Y148.102 Z12.4 F42000
G1 X101.398 Y147.954 Z12.4
G1 Z12
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X101.435 Y148.131 E.00554
G3 X99.672 Y146.76 I-1.55 J.174 E.22455
G1 X99.827 Y146.746 E.00478
G3 X101.37 Y147.827 I.059 J1.558 E.06215
G1 X101.385 Y147.896 E.00216
; WIPE_START
G1 F12000
M204 S6000
G1 X101.435 Y148.131 E-.09134
G1 X101.44 Y148.441 E-.11798
G1 X101.382 Y148.747 E-.11807
G1 X101.265 Y149.034 E-.11808
G1 X101.093 Y149.293 E-.11798
G1 X100.874 Y149.513 E-.11819
G1 X100.702 Y149.627 E-.07836
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.737 Y150.59 Z12.4 F42000
G1 Z12
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X99.293 Y150.517 E.01383
G3 X99.915 Y146.016 I.593 J-2.212 E.20348
G1 X100.028 Y146.02 E.00348
G3 X99.797 Y150.593 I-.142 J2.285 E.21938
M204 S10000
G1 X99.784 Y150.226 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381162
G1 F2326
M204 S6000
G1 X99.766 Y150.226 E.00051
G3 X97.962 Y148.242 I.12 J-1.921 E.08179
G1 X97.962 Y148.233 E.00022
G3 X97.978 Y148.051 I4.887 J.329 E.00505
G3 X100.135 Y150.214 I1.908 J.254 E.2361
G1 X99.844 Y150.224 E.00802
; OBJECT_ID: 113
; WIPE_START
G1 F15000
G1 X99.766 Y150.226 E-.02989
G1 X99.388 Y150.165 E-.14558
G1 X99.104 Y150.064 E-.11448
G1 X98.781 Y149.882 E-.14066
G1 X98.491 Y149.633 E-.14546
G1 X98.256 Y149.33 E-.14583
G1 X98.211 Y149.24 E-.03809
; WIPE_END
G1 E-.04 F1800
; stop printing object, unique label id: 91
M625
; start printing object, unique label id: 113
M624 CAAAAAAAAAA=
M204 S10000
G1 X98.732 Y141.625 Z12.4 F42000
G1 X98.743 Y141.478 Z12.4
G1 Z12
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.42
G1 F2326
M204 S5000
G1 X98.78 Y141.654 E.00554
G3 X97.017 Y140.283 I-1.55 J.174 E.22455
G1 X97.172 Y140.27 E.00478
G3 X98.715 Y141.35 I.059 J1.558 E.06215
G1 X98.73 Y141.419 E.00216
; WIPE_START
G1 F12000
M204 S6000
G1 X98.78 Y141.654 E-.09134
G1 X98.784 Y141.965 E-.11798
G1 X98.727 Y142.27 E-.11807
G1 X98.61 Y142.558 E-.11808
G1 X98.438 Y142.816 E-.11798
G1 X98.218 Y143.036 E-.11819
G1 X98.046 Y143.15 E-.07836
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.082 Y144.113 Z12.4 F42000
G1 Z12
G1 E.8 F1800
G1 F2326
M204 S5000
G1 X96.638 Y144.04 E.01383
G3 X97.259 Y139.539 I.593 J-2.212 E.20348
G1 X97.373 Y139.543 E.00348
G3 X97.142 Y144.116 I-.142 J2.285 E.21938
M204 S10000
G1 X97.129 Y143.749 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.381162
G1 F2326
M204 S6000
G1 X97.11 Y143.75 E.00051
G3 X95.306 Y141.765 I.12 J-1.921 E.08179
G1 X95.306 Y141.757 E.00022
G3 X95.322 Y141.574 I4.887 J.329 E.00505
G3 X97.48 Y143.737 I1.908 J.254 E.2361
G1 X97.189 Y143.747 E.00802
; close powerlost recovery
M1003 S0
; WIPE_START
G1 F15000
G1 X97.11 Y143.75 E-.02989
G1 X96.732 Y143.688 E-.14558
G1 X96.448 Y143.588 E-.11448
G1 X96.126 Y143.406 E-.14066
G1 X95.836 Y143.156 E-.14546
G1 X95.6 Y142.853 E-.14583
G1 X95.555 Y142.763 E-.03809
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z12.4 I1.217 J0 P1  F42000
; stop printing object, unique label id: 113
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
G1 Z12.4 F900 ; lower z a little
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

    G1 Z112 F600
    G1 Z110

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

