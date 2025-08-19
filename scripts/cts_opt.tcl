	
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
	### Aprisa Post_cts_opt Stage								##
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
	set PHASE    cts_opt
	source scripts/header.tcl
	source $SCRIPTS/proj_setup_variables.tcl
	rusage -timer AP_RUNTIME 
	set PROJECT $LOADDB/cts.proj
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
	if { $CTS_OPT_EFFECTIVE_SCENARIO != "" } {
	append mcmm_str " {$CTS_OPT_EFFECTIVE_SCENARIO}"
	} else {
	append mcmm_str " -every" 
	}
	if { $LEAKAGE_SCENARIO != "" } {
	append mcmm_str " -worst_leakage $LEAKAGE_SCENARIO"
	}
	eval $mcmm_str
	############ source params and variables ######
	source $SCRIPTS/flow_design_settings.tcl 
	catch {source $LOADDATA/place_opt_vars.tcl}
	catch {source $LOADDATA/cts_vars.tcl}
	source $PARAMS/cts_opt_params.tcl
	
	############ delete routing ###################
	#   delete_route -g -d
	
	#######################################################
	### Setting property of hold buffers and delay cells ##
	#######################################################
	set_property [get_lib_cells $HOLD_BUF_LIST]  dont_use_in_opt 0
	set_property [get_lib_cells $HOLD_BUF_LIST]  dont_touch_in_opt 0
	set_property [get_lib_cells $HOLD_BUF_LIST]  is_hold_fix_buffer 1
	set_property [get_lib_cells $HOLD_BUF_LIST]  is_hold_buffer_allowed_for_setup 1
	set_property [get_lib_cells $HOLD_DLY_BUF_LIST]  dont_use_in_opt 0
	set_property [get_lib_cells $HOLD_DLY_BUF_LIST]  dont_touch_in_opt 0
	set_property [get_lib_cells $HOLD_DLY_BUF_LIST]  is_hold_fix_buffer 1
	set_property [get_lib_cells $HOLD_DLY_BUF_LIST]  is_hold_buffer_allowed_for_setup 0
	#####################################
	### Source customization script    ##
	#####################################
	set STEP "pre"
	
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	
	#####################################
	### Run post_cts_opt command    ##
	#####################################
	
	rusage -timer POST_CTS_OPT
	set cts_opt_cmd "post_cts_opt -si_driven"
	for {set i 0} {$i<[llength $effort_cmd]} {incr i} {
	append cts_opt_cmd [lindex $effort_cmd $i]
	}
	append cts_opt_cmd " $CTS_OPT_EXTRA_OPTIONS"
	eval $cts_opt_cmd
	rusage -reset -timer POST_CTS_OPT
	
	########################
	### Tie cell addition ##
	########################
	
	foreach net [get_name_of_object [ get_nets * -hierarchical -flat -filter_by "is_global_net == true && usage == power"]] {
	add_tie_cell -lib_cell $TIE_HIGH_LIST -net $net -tie_ports
	}
	foreach net [get_name_of_object [ get_nets * -hierarchical -flat -filter_by "is_global_net == true && usage == ground"]] {
	add_tie_cell -lib_cell $TIE_LOW_LIST -net $net -tie_ports
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
#	exec python $SCRIPTS/generate_stage_summary.py $LOADREVISION $PHASE cts $SAVELOGS/${PHASE}.log [lindex [current_mcmm] 0]
	rusage -reset -timer AP_RUNTIME
	}
	#########################
	### Source end script  ##
	#########################
	
	##################save stuff ############################
	set FILE [open $SAVEDATA/post_cts_opt_vars.tcl w]
	puts $FILE  "namespace eval post_cts_opt {variable dummy 0}"
	foreach post_cts_opt_var [info vars post_cts_opt::*] {
	puts $FILE "set $post_cts_opt_var \{[set $post_cts_opt_var]\}"
	}
	close $FILE
	####################    
	exec cp $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl $SAVEDATA/flowgen_custom_inputs.tcl
	exec cp $PARAMS/${PHASE}_params.tcl $SAVEDATA/${PHASE}_params.tcl   
	if { $use_flow_params_for_reports } { report_param -all > $SAVERPT/${PHASE}_params.tcl }
	catch { exec cp [get_logfile_name] $SAVELOGS/${PHASE}.log }
	exit
	
