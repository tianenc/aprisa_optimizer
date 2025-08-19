	
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
	### Aprisa Filler insertion Stage								##
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
	set PHASE    filler
	source scripts/header.tcl
	
	source $SCRIPTS/proj_setup_variables.tcl      
	source $PARAMS/filler_params.tcl
	rusage -timer AP_RUNTIME 
	
	###################
	### Load project  ##
	####################
	if {![llength [current_module]]} {
	load_project $SAVEDB/route.proj
	}
	#####################################
	### Source customization script    ##
	#####################################
	set STEP "pre"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	delete_object [get_cells * -hierarchical -filter_by {is_filler_cell==true&&place_status==placed}]
	###################
	### Dcap insertion  ##
	####################

        #set dcap_cmd "add_dcap_cell $DCAP_CELLS -power $AF_DEFAULT_POWER_NET -ground $AF_DEFAULT_GROUND_NET -avoid_vio"
	set dcap_cmd "add_dcap_cell $DCAP_CELLS -avoid_vio"
	eval $dcap_cmd
	###################
	### Filler insertion  ##
	####################
	if { $ALT_FILLER_CELLS != ""} {
	set_property [get_lib_cells $ALT_FILLER_CELLS] alt_filler1 1
	set_property [get_lib_cells $FILLER_CELLS] dont_abut_filler1 1
	} 

        #set filler_cmd "add_filler_cell -lib_cell $FILLER_CELLS -power $AF_DEFAULT_POWER_NET -ground $AF_DEFAULT_GROUND_NET -avoid_vio	
        set filler_cmd "add_filler_cell -lib_cell $FILLER_CELLS -avoid_vio"
	eval $filler_cmd
	connect_power_domain_supply
	report_placement -check -post_fill_check
	#################################
	### Source customization script ##
	################################## 
	set STEP "post"
	source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl
	save_project $SAVEDB/$PHASE.proj
	catch { exec cp [get_logfile_name] $SAVELOGS/${PHASE}.log }
	exit
	
