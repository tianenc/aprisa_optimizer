set ENABLE_MCMM_STAGE init

set HIER_CHILD 0
set HIER_PARENT 0

set IR_DRIVEN 0
set SKEW_OPT 0
set CPU_DESIGN 0

set TIMING_EFFORT high  ;  #changes can be done based on design needs
set POWER_EFFORT medium ;  #changes can be done based on design needs
set CONG_EFFORT high  ;  #changes can be done based on design needs
set ROUTE_EFFORT high ;  #changes can be done based on design needs
set AREA_EFFORT medium ;  #changes can be done based on design needs

set EXTRA_CONG_EFFORT 0

set effort_cmd " "
if {$TIMING_EFFORT != "medium"} {
    if {$PHASE == "route"} {
	lappend effort_cmd " -optimize_effort $TIMING_EFFORT"
    } else {
	lappend effort_cmd " -timing_effort $TIMING_EFFORT"
    }
}

if {$POWER_EFFORT != "medium"} {
	lappend effort_cmd " -power_effort $POWER_EFFORT"
}

if {$CONG_EFFORT != "medium"} {
	lappend effort_cmd " -congestion_effort $CONG_EFFORT"
}

if {$PHASE != "route" && $AREA_EFFORT != "medium"} {
	lappend effort_cmd " -area_effort $AREA_EFFORT"
}

if {$PHASE == "route" && $ROUTE_EFFORT != "medium"} {
	lappend effort_cmd " -route_effort $ROUTE_EFFORT"
}


set PLACE_INCREMENTAL 0
set PLACE_OPT_PHASE_OPTIONS ""
set CTS_PHASE_OPTIONS ""
set CTS_OPT_PHASE_OPTIONS ""
set ROUTE_OPT_PHASE_OPTIONS ""
set BUILD_CLOCK_TREE 0
set HTREE_CTS 0
set MULTI_POINT_CTS 0
set PLACE_OPT_EXTRA_OPTIONS " "
set CTS_EXTRA_OPTIONS " "
set CTS_OPT_EXTRA_OPTIONS " "
set ROUTE_OPT_EXTRA_OPTIONS "-fix_antenna -fix_em -optimize_via -opt_via_effort MEDIUM -max_repair_loop 5"

if { $CPU_DESIGN } {
    append ROUTE_OPT_EXTRA_OPTIONS " -fix_si -si_route_loop 2"
}
    

#cts_opt incremental options
set POST_CTS_PLACE_OPT		0
set CTS_OPT_EXTRA_SETUP_ITER	0
set CTS_OPT_EXTRA_HOLD_ITER 	0

#route incremental options
set ROUTE_EXTRA_DRV	    0
set ROUTE_EXTRA_SETUP_ITER  0
set ROUTE_EXTRA_HOLD_ITER   0
set OPTIMIZE_VIA	    0
set IPO_RESIZE		    0
set PBA_OPT		    0

set DECLONE_ICG 0;  #ENABLE for standalone declone of ICG
set CLONE_ICG_AT_PLACE 1; #ENABLE for declone & clone of ICG during placeopt
set CLONE_ICG_AT_CTS 1; #ENABLE for declone & clone of ICG during CTS
set MBIT_FLOW 0 ; #ENABLE for MBIT flow

set AF_PARALLEL_REPORTING 0
set use_flow_params_for_reports 0

set AF_HYPERTHREADED_TIMING_ANALYSIS 0
set AF_HYPERTHREAD_COUNT 4


