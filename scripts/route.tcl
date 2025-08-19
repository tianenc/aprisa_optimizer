	
	######################################################################################
	### Copyright Mentor, A Siemens Business						##
	### All Rights Reserved								##
	### Version : /google/gchips/tools/mentor/aprisa/09.19.06/bin/rhel7-64/AP		##
	###											##
	### THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY					##
	### INFORMATION WHICH ARE THE PROPERTY OF MENTOR					##
	### GRAPHICS CORPORATION OR ITS LICENSORS AND IS					##
	### SUBJECT TO LICENSE TERMS.							##
	######################################################################################
	set AP_BUILD [info nameofexecutable]
	puts "
	######################################################################################
	### Aprisa Route_opt Stage								##
	### Version : $AP_BUILD		##
	######################################################################################
	"
	if { $AP_BUILD != "/google/gchips/tools/mentor/aprisa/09.19.06/bin/rhel7-64/AP" } {
	puts "WARNING: Run build different from the build used to generate script via flowgen. Incompatibility could cause errors."
	}
	###########################################
	### Working area setup ##
	############################################
	set ROOT     [pwd] 
	set PHASE    route
	source scripts/header.tcl
	source $SCRIPTS/proj_setup_variables.tcl
	rusage -timer AP_RUNTIME
	set PROJECT ${LOADDB}/cts_opt.proj
	###################
	### Load project  ##
	####################
	if {![llength [current_module]]} {
	load_project $PROJECT
	}
	#############################
	### Set effective scenario  ##
	##############################
	set mcmm_str "current_mcmm"
	if { $ROUTE_EFFECTIVE_SCENARIO != "" } {
	append mcmm_str " {$ROUTE_EFFECTIVE_SCENARIO}"
	} else {
	append mcmm_str " -every" 
	}
	if { $LEAKAGE_SCENARIO != "" } {
	append mcmm_str " -worst_leakage $LEAKAGE_SCENARIO"
	}
	eval $mcmm_str
	source $SCRIPTS/flow_design_settings.tcl
	############ Source params and variables ######
	catch {source $LOADDATA/place_opt_vars.tcl}
	catch {source $LOADDATA/cts_vars.tcl}
	catch {source $LOADDATA/post_cts_opt_vars.tcl} 
	source $PARAMS/${PHASE}_params.tcl
	############ Delete routing ###################
	#    delete_route -g -d
	#######################################################
	### Define clock cell list and unset property ##
	#######################################################
	set_property [get_lib_cells $CLK_BUF_LIST] is_clock_driver true
	set_property [get_lib_cells $CLK_BUF_LIST] dont_use_in_opt false
	set_property [get_lib_cells $CLK_BUF_LIST] dont_touch_in_opt false
	
	###########################################Hold Fix Buffers###############################################
	#######################################################
	### Setting property of hold buffers and delay cells ##
	#######################################################
	
	set_property [get_lib_cells $HOLD_BUF_LIST]  dont_use_in_opt 0
	set_property [get_lib_cells $HOLD_BUF_LIST]  is_hold_fix_buffer 1
	set_property [get_lib_cells $HOLD_BUF_LIST] is_hold_buffer_allowed_for_setup_fix 1
	set_property [get_lib_cells $HOLD_DLY_BUF_LIST]  dont_use_in_opt 0
	set_property [get_lib_cells $HOLD_DLY_BUF_LIST]  is_hold_fix_buffer 1
	set_property [get_lib_cells $HOLD_DLY_BUF_LIST] is_hold_buffer_allowed_for_setup_fix 0
	#####################end hold params######
	#####################################
	### Source customization script    ##
	#####################################
	set STEP "pre"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	rusage -timer ROUTE_OPT
	set route_opt_cmd "route_optimize"
	for {set i 0} {$i<[llength $effort_cmd]} {incr i} {
	append route_opt_cmd [lindex $effort_cmd $i]
	}
	append route_opt_cmd " $ROUTE_OPT_EXTRA_OPTIONS"
	eval $route_opt_cmd
	rusage -reset -timer ROUTE_OPT
	#######################
	### Shielding ##
	#######################
	if { [sizeof_oblist [get_nets * -hierarchical -filter_by {usage == clock || is_clock_net == true && shield_rule != ""} -quiet]] } {
	shield
	}
	#################################
	### Source customization script ##
	##################################
	set STEP "post"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	#######################
	### Save the project ##
	#######################
	save_project $SAVEDB/${PHASE}.proj
	#########################
	### Generate reports   ##
	#########################
	if {$AF_PARALLEL_REPORTING} {
	exec xterm -T parallel_report -e "setenv LOAD_PROJ $SAVEDB/$PHASE.proj ; setenv PHASE $PHASE ; $AP_BUILD -log_dir $SAVELOGS $SCRIPTS/parallel_report.tcl -log rpt_${PHASE}.log ; exit" &
	} else {
	source scripts/reports_gen_procs.tcl
	my_results $SAVERPT $PHASE saved
#	exec python $SCRIPTS/generate_stage_summary.py $LOADREVISION $PHASE cts_opt $SAVELOGS/${PHASE}.log [lindex [current_mcmm] 0]
	rusage -reset -timer AP_RUNTIME
	}
	#########################
	### Source end script  ##
	#########################
	##################save stuff ############################
	set FILE [open $SAVEDATA/route_opt_vars.tcl w]
	puts $FILE  "namespace eval route_opt {variable dummy 0}"
	foreach route_opt_var [info vars route_opt::*] {
	puts $FILE "set $route_opt_var \{[set $route_opt_var]\}"
	}
	close $FILE
	#############
	exec cp $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl $SAVEDATA/flowgen_custom_inputs.tcl 
	exec cp $PARAMS/${PHASE}_params.tcl $SAVEDATA/${PHASE}_params.tcl
	if { $use_flow_params_for_reports } { report_param -all > $SAVERPT/${PHASE}_params.tcl }
	catch { exec cp [get_logfile_name] $SAVELOGS/${PHASE}.log }
	exit
	
