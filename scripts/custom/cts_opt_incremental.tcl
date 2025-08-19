if { $POST_CTS_PLACE_OPT } {
    rusage -timer POST_CTS_OPT_PLACE

    set wns [get_timing_qor -internal -setup wns]
    ##########if internal setup timing not met run with opt extra effort true######################
    if { $wns < 0 } {

	###########################Start place_opt post_cts################################################
	# dont_touch, fixed = true : is_flip_flop, is_multibit_flip_flop, is_latch, is_clock_gating_integrated, is_sequential
	set FILE [open $SAVEDATA/reset_flop_net_status.tcl w]
	foreach cell [get_cells * -h -l  -filter_by "is_sequential_cell == 1"] {
	    puts $FILE "set_property \[get_cell $cell \] dont_touch_in_opt   [get_property $cell dont_touch_in_opt]"
	    puts $FILE "set_property \[get_cell $cell \] place_status [get_property $cell place_status]"
	}
	puts $FILE "####clock nets####"
	foreach net [get_net * -h -filter_by "usage == clock"] {
	    puts $FILE "set_property \[get_net $net \] dont_touch_in_opt [get_property $net dont_touch_in_opt]"
	}      
	close $FILE
	#############################################################################

	set_property [get_cells -h -l * -filter_by "is_sequential_cell == true"] dont_touch_in_opt true
	set_property [get_cells -h -l * -filter_by "is_sequential_cell == true"] place_status fixed
	set_property [get_nets -h -filter_by "usage == clock"] dont_touch_in_opt true

	#####provides no benefit for fast flow
	place_opt -place_initial incremental -timing_effort high -area_effort medium  -si_driven -post_cts

	source $SAVEDATA/reset_flop_net_status.tcl
	save_proj $SAVEDB/post_cts_opt_basic_setup_hold_prop_place_opt.proj
	###########################End place_opt post_cts####################################################
    }   

    rusage -reset -timer POST_CTS_OPT_PLACE
}

if { $CTS_OPT_EXTRA_SETUP_ITER } {
    rusage -timer POST_CTS_OPT_EXTRA_SETUP

    #########################run extra effort opt######################
    set wns [get_timing_qor -internal -setup wns]
    ##########if internal setup timing not met run with opt extra effort true######################
    if { $wns < 0 } {
	set_param opt skew_opt_on_std_cell true
	set_param opt skew_opt_on_macro_cell true
	set_param opt skew_opt_on_icg true

	### Aggressive skew_opt params ####
	set_param opt skew_opt_effort high
	set_param opt skew_opt_extra_effort 3
	set_param opt aggressive_skew_opt_target .050
  
	set_param opt skew_opt_level 6
	set_param opt skew_opt_max_path_group 5
	set_param opt skew_opt_all_path_max_count 100
	set_param opt skew_opt_flop_limit 25000
	set_param opt skew_opt_on_tns true
	set_param opt skew_opt_resize_icg true
	set_param cts skew_opt_ignore_drv true

	set num_fep [get_timing_qor -internal -setup fep]
	set num_tep [sizeof_oblist [get_pin -relate_to [get_cell * -h -l -filter_by "is_sequential_cell == 1 && is_spare_cell == 0"] \
	-filter_by "direction_of_signal == in  && is_clock==0  && worst_setup_slack != 1e+20"]]
	set percent_fep [expr $num_fep * 1.0 / $num_tep * 1.0]

	###############################Fix setup##############################################        
	set  phase  {}
	if { $percent_fep < .01 } {
	    ####High runtime penalty, use when small nuber of fep
	    ####on timing tough design. Trys to fix all violations
	    ####use with place_opt -timing_effort high or place_opt -phase wns
	    set_param opt extra_effort 1
	    set phase "-phase {wns}"                 
	} else {
	    ####lower runtime penalty than opt extra_effort, set to high use when timing tough large number fep
	    ####use with post_cts_opt -timing_effort high or place_opt -phase tns
	    set_param opt tns_opt_effort high
	    set_param opt extra_effort 0
	    ###remove skew fro time being causes huge tns jump
	    #set post_cts_opt::cmd "$post_cts_opt::cmd -phase {skew tns wns}"
	    set phase "-phase {tns wns}"   
	};#end if else	   

	set cmd "post_cts_opt -propagated_clock -port_prop_clock_latency \
	-timing_effort high -si_driven \
	$phase"
	eval $cmd
	save_proj  $SAVEDB/post_cts_opt_setup_extra_effort.proj
    }

    rusage -reset -timer POST_CTS_OPT_EXTRA_SETUP

	#compute_timing
	#report_timing_analysis -show_derate -type_of_delay max -show_transition   > $SAVERPT/${PHASE}_extra_effort_setupfix.max.ta
	#report_timing_analysis -show_derate -type_of_delay min -show_transition   > $SAVERPT/${PHASE}_extra_effort_setupfix.min.ta
	#report_timing_analysis   -path_report_format full_clock_expanded -type_of_delay max -prefix $SAVERPT/${PHASE}_extra_effort_setupfix.full_clock.max.ta
	# report_timing_analysis   -path_report_format full_clock_expanded -type_of_delay min -prefix $SAVERPT/${PHASE}_extra_effort_setupfix.full_clock.min.ta
	# report_timing_analysis -summary  -type_of_delay max >  $SAVERPT/${PHASE}_extra_effort_setupfix.max.ta.sum
	# report_timing_analysis -summary  -type_of_delay min >  $SAVERPT/${PHASE}_extra_effort_setupfix.min.ta.sum
}

if { $CTS_OPT_EXTRA_HOLD_ITER } {
    rusage -timer POST_CTS_OPT_EXTRA_HOLD

    ########################check if hold needs extra opt#######################
    set wns [get_timing_qor -internal -hold wns]
    if { $wns  < 0 } {
	set_param opt hold_opt_effort high 
	set cmd "post_cts_opt -propagated_clock -port_prop_clock_latency \
		-timing_effort high -si_driven \
		-phase {hold}"
	eval $cmd	       
	save_proj $SAVEDB/post_cts_opt_extra_effort_hold.proj
    }

    rusage -reset -timer POST_CTS_OPT_EXTRA_HOLD
}

if { $CTS_OPT_EXTRA_SETUP_ITER || $CTS_OPT_EXTRA_HOLD_ITER } {
    ######### Restore Params #########
    source $PARAMS/cts_opt_params.tcl
}
