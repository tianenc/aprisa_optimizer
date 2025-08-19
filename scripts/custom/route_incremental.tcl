if { $ROUTE_EXTRA_DRV } {
    ##################check drv###########################
    rusage -time report_timing_analysis

    report_ta_constraint -no_update -noenvironment -show_all_violators -max_transition_constraint -max_capacitance_constraint -max_fanout_constraint -dont_split_line -prefix $SAVERPT/route_opt_basic_drv
    rusage -reset -time report_timing_analysis

    rusage -time ROUTE_EXTRA_DRV
    set drv_need_fixing  0
    foreach drv_file [glob $SAVERPT/route_opt_basic_drv*] {
	set FILE [open $drv_file r]
	while { [gets $FILE line] >= 0 } {
	    if { [regexp {\s+(max_.*)} $line match drv_type] } {
		puts "Found drv_type $drv_type"
		gets $FILE line
		set drv_ctr 0	
		while { [gets $FILE line] >= 0 && [regexp -line {.} $line] } {
		    incr drv_ctr
		}
		puts "   $drv_type $drv_ctr"
		if { $drv_ctr > 10 } {
		    set drv_need_fixing  1
		}
	    }
	}
        close $FILE     
    }

    #################################fix drv############################################   
    if { $drv_need_fixing } {
	set  phase {}
	set_param opt drc_opt_effort high       
	rusage -timer ROUTE_OPT_EXTRA_DRV      
	set cmd "route_opt -si_effort hybrid -phase {drv eco_route}"
	eval $cmd
	rusage -reset  -timer ROUTE_OPT_EXTRA_DRV 
	save_proj  $SAVEDB/route_opt_drv_extra_effort.proj
    }
    rusage -time ROUTE_EXTRA_DRV
    #############################################################################
}

if { $ROUTE_EXTRA_SETUP_ITER } {
    rusage -timer ROUTE_OPT_EXTRA_SETUP

    #########################run extra effort opt######################
    set wns [get_timing_qor -internal -setup wns]
    ##########if internal setup timing not met run with opt extra effort true######################
    if { $wns < 0 } {

	set_param opt skew_opt_on_std_cell true
	set_param opt skew_opt_on_macro_cell true
	set_param opt skew_opt_on_icg true

	## Aggressive skew_opt params ####
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

	set_param opt no_worsen_hold wns_and_tns
	set num_fep [get_timing_qor -internal -setup fep]
	set num_tep [sizeof_oblist [get_pin -relate_to [get_cell * -h -l -filter_by "is_sequential_cell == 1 && is_spare_cell == 0"] \
	-filter_by "direction_of_signal == in  && is_clock==0  && worst_setup_slack != 1e+20"]]
	set percent_fep [expr $num_fep * 1.0 / $num_tep * 1.0]

	###############################Fix setup##############################################    
	set  phase  {}
	if { $percent_fep < .015 } {
	    ####High runtime penalty, use when small nuber of fep
	    ####on timing tough design. Trys to fix all violations
	    ####use with place_opt -timing_effort high or place_opt -phase wns
	    set_param opt extra_effort 1
	    set  phase "-phase {wns eco_route}"
	} else {
	    ####lower runtime penalty than opt extra_effort, set to high use when timing tough large number fep
	    ####use with place_opt -timing_effort high or place_opt -phase tns
	    set_param opt tns_opt_effort high
	    set  phase  "-phase { tns eco_route wns}"
	}

	set cmd "route_opt -si_effort hybrid $phase"
	eval $cmd
	save_proj  $SAVEDB/route_opt_setup_extra_effort.proj
    }

    rusage -reset -timer ROUTE_OPT_EXTRA_SETUP
    #############################################################################  
}

if { $ROUTE_EXTRA_HOLD_ITER } {
    rusage -timer ROUTE_OPT_EXTRA_HOLD

    ######################check hold############################
    set hold_tns  [get_timing_qor tns -hold -no_update]
    set hold_wns  [get_timing_qor wns -hold -no_update] 
    set hold_need_fixing 0
    if { $hold_wns < -.020 && $hold_tns < -.500 } {
	set hold_need_fixing 1
    }

    ##################################fix holds#############################
    if { $hold_need_fixing }  {
	set phase  {}
	set_param opt hold_opt 1          
	set_param opt hold_opt_effort high          
	set_param opt merge_hold_buffer 1

	set  phase  "$phase -phase {hold} "
	set cmd "route_opt -si_effort hybrid $phase"
	eval $cmd
	save_proj  $SAVEDB/route_opt_hold_extra_effort.proj
    }

    rusage -reset -timer ROUTE_OPT_EXTRA_HOLD
    #############################################################################
}

if { $OPTIMIZE_VIA } {
    optimize_via 
}

if { $IPO_RESIZE } {
   set_param opt io_master_flow_ignore_hold true
   ipo_resize -bottleneck_based -step_vt -bottleneck_effort high -reduce_power_too -fix_drv_too 
}

if { $ROUTE_EXTRA_DRV || $ROUTE_EXTRA_SETUP_ITER || $ROUTE_EXTRA_HOLD_ITER || $OPTIMIZE_VIA || $IPO_RESIZE} {
    route -verify 
    route -repair -loop 40 -fix_antenna 

    ######### Restore Params #########
    source $PARAMS/route_params.tcl
}

if { $PBA_OPT } {
    #############################PBA OPtimization#########################
    current_mcmm {}
    current_mcmm {}
    set pba_aocv 1
    set pba_socv 0
    set pba_lvf  1
    extract_parasitic -clear
    extract_parasitic
  
    foreach scn [current_mcmm] {
	set_working_scenario $scn
	set_param ta enable_aocv $pba_aocv -scenario
	set_param ta timing_socvm_enable_analysis $pba_socv -scenario     
	set_param ta timing_lvf_enable_analysis $pba_lvf -scenario
	if {$pba_lvf} {
	    set_param ta enable_pocv false
	}
    }
    set_working_scenario {}

    set_param ta enable_aocv $pba_aocv
    set_param ta timing_socvm_enable_analysis $pba_socv
    set_param ta timing_lvf_enable_analysis false $pba_lvf
    if {$pba_lvf} {
	set_param ta enable_pocv false
    }

    set_param opt pre_eco_route_force_timing_update true

    eco_opt -pba_mode gba_pba -phase { hold wns tns power wns tns } -fix_si -fix_antenna -optimize_via 

#    compute_timing -full >> scripts/route_opt.tcl
#    report_timing_analysis -pba_mode complete -show_derate -type_of_delay max -show_transition > $SAVERPT/${PHASE}_pba.max.ta >> scripts/route_opt.tcl
#    report_timing_analysis -pba_mode complete -show_derate -type_of_delay min -show_transition > $SAVERPT/${PHASE}_pba.min.ta >> scripts/route_opt.tcl
#    report_timing_analysis -pba_mode complete -path_report_format full_clock_expanded -type_of_delay max -show_input_pins -prefix $SAVERPT/${PHASE}_pba.full_clock.max.ta >> scripts/route_opt.tcl
#    report_timing_analysis -pba_mode complete -path_report_format full_clock_expanded -type_of_delay min -show_input_pins -prefix $SAVERPT/${PHASE}_pba.full_clock.min.ta >> scripts/route_opt.tcl
#    report_timing_analysis -pba_mode complete -summary  -type_of_delay max > $SAVERPT/${PHASE}_pba.max.ta.sum >> scripts/route_opt.tcl
#    report_timing_analysis -pba_mode complete -summary  -type_of_delay min > $SAVERPT/${PHASE}_pba.min.ta.sum >> scripts/route_opt.tcl
    save_project $SAVEDB/route_opt_pba_opt.proj
    current_mcmm -every 
}
