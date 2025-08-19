	namespace eval place_opt {variable place_opt_cmd ""}
	namespace eval cts       {variable cts ""}   
	set_param db save_all_params true
	set_param ta port_prop_clock_latency true
	set_param ta propagated_clocks true
	set_param ta unset_ideal_clock_net 1
	set_param ta set_ideal_clock_net 0
	set_param ta enable_crpr 1
	set_param cts extra_spacing_on_port_net true
	set_param cts use_liberty_max_clock_tree_only true ; # use this param if min/max latency has big different from .lib -> after to CTS QoR
	set_param cts dont_create_assign true 
	if {$CLONE_ICG_AT_CTS} {
	set_param cts use_auto_clone_icg true
	set_param cts clone_gating true
	set_param cts clone_gating_force true
	set_param cts slack_aware_clone_gating true
	set_param cts move_gating_effort_level high
	set_param cts clone_gating_trans_target [expr ($MAX_CLK_TRAN/1000.0) * 2]
	set_param cts clone_gating_max_trans [expr ($MAX_CLK_TRAN/1000.0) * 3]
	set_param cts clone_gating_max_cap $MAX_CAP
	set_param cts clone_gating_max_fanout $MAX_FANOUT
	}
