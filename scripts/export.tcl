	
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
	### Aprisa Export Stage								##
	### Version : $AP_BUILD		##
	######################################################################################
	"
	if { $AP_BUILD != "/google/gchips/tools/mentor/aprisa/09.19.06/bin/rhel7-64/AP" } {
	puts "WARNING: Run build different from the build used to generate script via flowgen. Incompatibility could cause errors."
	}
	###########################################
	### Working area setup ##
	############################################
	set ROOT    [pwd] 
	set PHASE    export
	source scripts/header.tcl
	source $SCRIPTS/proj_setup_variables.tcl
	rusage -timer AP_RUNTIME 
	###################
	### Load project  ##
	####################
	if {![llength [current_module]]} {
	load_project $SAVEDB/filler.proj
	}
	source $PARAMS/${PHASE}_params.tcl 
	if { $M0_ROUTING == 1 } { fill_track -mask 0 }
	verify_layout -drc -auto_insert_cutmetal
	#####################################
	### Source customization script    ##
	#####################################
	set STEP "pre"
	
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	
	###################
	### Verilog  ##
	####################
	set verilog_cmd "export_verilog $VERILOG_OUTPUT $VERILOG_OPTIONS -compress"
	eval $verilog_cmd
	###################
	### DEF  ##
	####################
	set def_cmd "export_def $DEF_OUTPUT $DEF_OPTIONS -compress"
	eval $def_cmd
	###################
	### GDS  ##
	####################
	set gds_cmd "export_gds $GDS_OUTPUT \
		-layer_map $GDS_LAYER_MAP \
		-boundary_layer $BNDY_LAYER \
		-boundary_datatype $BNDY_DATATYPE\
	$GDS_OPTIONS -compress"
	eval $gds_cmd
	#################################
	### Source customization script ##
	##################################
	set STEP "post"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	catch { exec cp [get_logfile_name] $SAVELOGS/${PHASE}.log }
	exit
	
