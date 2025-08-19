	namespace eval route_opt {
	variable route_opt_cmd ""}
	set_param db save_all_params true
	set_param route allow_cell_off_grid true
	set_param route avoid_double_via_lead 1
	set_param opt power_opt true
	set_param opt check_clock_drv 1
	set_param opt post_route_clock_drc_opt 1
	set_param opt post_route_opt_dont_worsen_drv auto
	set_param opt post_route_area_opt 1
	set_param opt post_route_power_opt 1
	set_param lpe signoff_model  s_200
	set_param lpe inter_layer_coupling 1
	set_param lpe extract_via_cap 1   
	set_param lpe effort 2   
	set_param ta si_xtalk_model 1
	set_param opt target_setup_slack 0
	set lower_pin_min_mask [lindex [lsort -decreasing [get_property [get_lib_pins -relate_to [get_lib_cells *]] max_metal]] 0]
	set_param db std_cell_lower_pin_conn_min_mask $lower_pin_min_mask
	set_param opt dont_create_assign true
	set_param opt hold_opt_effort MEDIUM
	set_param opt target_hold_slack 0
	set_param opt power_opt_effort MEDIUM
	set_param opt area_opt_effort MEDIUM
	set_param place use_metal_1_tracks 1
	set_param place use_vth_min_spacing_rules 1
	set_param place avoid_cut0_violation true
	set_param route m1_bottom_ground_pm 1
	set_param route antenna_exclude_pin_area true
	set_param lpe use_silicon_width 1
	set_param px certification 1
	set_param place use_filler1_adjacent_rule 4
	set_param place dp_max_pin_density 1.000
	set_param dp check_vt_point_touch 0
	set_param ta crpr_threshold_in_ps 2.000
	if { $M0_ROUTING == 0 } {
	set_param db no_routing_on_m0 0
	set_param route enable_cm0_routing 0
	set_param route dont_use_m0_wire true
	}
