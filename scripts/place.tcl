	
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
	### Aprisa Place_opt Stage								##
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
	set PHASE    place
	source scripts/header.tcl
	source $SCRIPTS/proj_setup_variables.tcl
	source $SCRIPTS/flow_design_settings.tcl
	rusage -timer AP_RUNTIME 
	
	###################
	### Load project  ##
	####################
	if {![llength [current_module]]} {
        load_project /usr/local/google/gcpu/collab/ment-collab/prj-pd/rajivdarji/ecore_lsu_wrapper/golden_032224.R1/default/db/fp.proj
        #load_project $SAVEDB/fp.proj
       # load_project /usr/local/google/gcpu/collab/ment-collab/prj-pd/rajivdarji/ecore_lsu_wrapper/R1.030524/default/db/fp.proj
	}
	#PA1add_route_guide -function no_pg -metals { 2 4 5 7 9 11 12 } -cells [get_cells * -filter_by ref_lib_cell==HDR68XSINTCWGOLD1BWP143M286H3P48CPDSVT -hierarchical] -min_spacing 0.285
	#PA1delete_route -route_type stripe
	#PA1delete_route -route_type std_rail
	#PA1source /google/gchips/workspace/collab-mentor/tpe/user/pavankumarram/rapidsw/testrun7/paramroute_fin3.tcl
	#PA1complete_param_route
	#PA1connect_param_route -nets VSS -min_conn_mask 0 -max_conn_mask 13
	#PA1connect_param_route -nets VDD -min_conn_mask 0 -max_conn_mask 1 -param_route M1_VDD_stripe
	#PA1import_def /google/gchips/workspace/collab-mentor/tpe/user/muralinagaraj/n3runs/repo4.6/run/main/pnr/floorplan/outs/rapidsw.pg.def.gz
	#PA1route -clear_auto_gen_route_guide
	#PA1source color_shift.tcl
	#PA1return
	################
	### MCMM setup ##
	#################
	#############################
	#### pre placement checks   ##
	##############################
	verify_phys_pin > $SAVERPT/place.port_place_check.rpt
	set overlap_count 0
	set unplace_count 0
	catch {set overlap_count [exec grep -c "ERROR:PhysPinVio" $SAVERPT/place.port_place_check.rpt]}
	catch {set unplace_count [exec grep -c "WARNING:PortNoPhysPin" $SAVERPT/place.port_place_check.rpt]}
	if {$overlap_count > 0 || $unplace_count > 0} {
	echo "overlap ports or unplaced ports exist in design please check"
	# return
	}
	
	#############################
	### Set effective scenario  ##
	##############################
	
	set mcmm_str "current_mcmm"
	if { $PLACE_EFFECTIVE_SCENARIO != "" } {
	append mcmm_str " {$PLACE_EFFECTIVE_SCENARIO}"
	} else {
	append mcmm_str " -every" 
	}
	if { $LEAKAGE_SCENARIO != "" } {
	append mcmm_str " -worst_leakage $LEAKAGE_SCENARIO"
	}
	eval $mcmm_str
	###########################################
	### Source pre-defined tech param rule     ##
	#############################################
	
	######################
	### Import scan-def ##
	######################
	
	if {$AF_SCAN_DEF != "" && [file exists $AF_SCAN_DEF]} {
	import_def $AF_SCAN_DEF
	}
	
	##################################   
	### Set don't touch cells/nets   ##
	###################################  
	
	catch {source $CUSTOM_SCRIPT/opt_custom_inputs.tcl}
	check_project -fix_conflict_name -fix_hier_net -remove_assign -fix_dup_name
	
	source $PARAMS/place_params.tcl
	source $SCRIPTS/property_setting/place_settings.tcl
	
	####################################
	### Generate neighbor rule        ##
	####################################
	
	clear_setup -place_rule
	#generate_neighbor_rules -new_auto_rule { 0 15 }
	generate_neighbor_rules -pin_to_pin_min_spacing 1 -keep_lef_neighbor_rule -vertical_abutment -fat_enclosure -fat_wire -auto_rule {0 15} -min_spacing 1 -via1_space -dense_edge
	export_setup -place_rule neighbor_rules.tcl
	source neighbor_rules.tcl
	###################################
	### Specify clock buffers to use ## 
	################################### 
	
	set_property [get_lib_cells $CLK_BUF_LIST] is_clock_driver true
	set_property [get_lib_cells $CLK_BUF_LIST] dont_use_in_opt false
	set_property [get_lib_cells $CLK_BUF_LIST] dont_touch_in_opt false
	
	#########################
	### Define clock setup ##
	#########################
	source $CUSTOM_SCRIPT/clock_rule.tcl
	derive_skew_groups
	source $CUSTOM_SCRIPT/clock_constraints.tcl 
	#########################
	### Export clock setup ##
	#########################
	export_setup -clock $SAVEDATA/check_sg.setup
	export_skew_group $SAVEDATA/check.sg
	#####################################
	### Source customization script    ##
	#####################################
	set STEP "pre"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
        save_project before_place.proj
	#################################################
	### Run place_opt -place_initial command       ##
	#################################################
	rusage -timer INITIAL_PLACE_OPT 
	for {set i 0} {$i<[llength $effort_cmd]} {incr i} {
	append effort_cmds [lindex $effort_cmd $i]
	}
	set place_opt::place_opt_cmd "place_opt -place_initial full -si_driven $effort_cmds $PLACE_OPT_EXTRA_OPTIONS"
	eval $place_opt::place_opt_cmd
	rusage -reset -timer INITIAL_PLACE_OPT 
	#################################
	### Source customization script ##
	################################## 
	set STEP "post"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	save_project $SAVEDB/${PHASE}.proj
	#########################
	### Generate reports   ##
	#########################
	if {$AF_PARALLEL_REPORTING} {
	exec xterm -T parallel_report -e "setenv LOAD_PROJ $SAVEDB/$PHASE.proj ; setenv PHASE $PHASE ; $AP_BUILD -log_dir $SAVELOGS $SCRIPTS/parallel_report.tcl -log rpt_${PHASE}.log ; exit" &
	} else {
	source $SCRIPTS/reports_gen_procs.tcl
	my_results $SAVERPT $PHASE saved
#	exec python $SCRIPTS/generate_stage_summary.py $LOADREVISION $PHASE init $SAVELOGS/${PHASE}.log [lindex [current_mcmm] 0]
	rusage -reset -timer AP_RUNTIME
	}
	#########################
	### Source end script  ##
	#########################
	##################save stuff ############################
	set FILE [open $SAVEDATA/place_opt_vars.tcl w]
	puts $FILE  "namespace eval place_opt {variable dummy 0}"
	foreach place_opt_var [info vars place_opt::*] {
	puts $FILE "set $place_opt_var \{[set $place_opt_var]\}"
	}
	close $FILE
	################################# 
	exec cp $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl $SAVEDATA/flowgen_custom_inputs.tcl
	exec cp $PARAMS/${PHASE}_params.tcl $SAVEDATA/${PHASE}_params.tcl
	if { $use_flow_params_for_reports } { report_param -all > $SAVERPT/${PHASE}_params.tcl }
	catch { exec cp [get_logfile_name] $SAVELOGS/${PHASE}.log }
	exit
	
