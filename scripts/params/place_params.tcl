	namespace eval place_opt {variable place_opt_cmd ""}
	source scripts/proj_setup_variables.tcl
	set_param db save_all_params true
	set_param db max_read_liberty_thread 16
	set_param ta propagated_clocks false
	set_param ta unset_ideal_clock_net 0
	set_param ta set_ideal_clock_net 1    
	set_param place cluster_leaf_icg_sink 1
	set_param ta enable_crpr true 
	set_param route allow_cell_off_grid true
	set_param place hard_user_padding true
	set_param place clock_net_width  5
	set_param route avoid_double_via_lead 1
	set_param opt area_opt true
	set_param opt power_opt true
	set_param place min_clock_mask 6
	set_param ta si_xtalk_model 1
	set_param place clock_cell_spacing 2
	set_param place clock_cell_width_space $X_CLOCK_CELL_SPACING
	set_param place clock_cell_height_space $Y_CLOCK_CELL_SPACING
	set_param place clock_cell_mode 1
	set_param place layer_aware_cong_map 1
	set_param opt dont_create_assign true 
	set_param ta enable_aocv t
	set_param ta timing_lvf_enable_analysis true
	set_param place use_metal_1_tracks 1
	set_param place use_vth_min_spacing_rules 1
	set_param place avoid_cut0_violation true
	set_param route m1_bottom_ground_pm 1
	set_param ta crpr_threshold_in_ps 2.000
	if { $HYBRID_ROWS } {
	set_param place use_hybrid_rows 1
	set_param place use_hybrid_row_fp_rule 1
	set_param place hybrid_rows_swap_mode 1
	set_param place hybrid_rows_vt_level_swap_mode 1
	}
	if { $M0_ROUTING == 0 } {
	set_param db no_routing_on_m0 0
	set_param route enable_cm0_routing 0
	set_param route dont_use_m0_wire true
	}
	set_param opt place_opt_slack_margin 0.020
	set_param opt power_opt_effort MEDIUM
	set_param opt area_opt_effort MEDIUM
