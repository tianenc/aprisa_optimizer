
   ########################################################
    set ROOT    [pwd] 
    set PHASE    fp
    source scripts/header.tcl

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
    ### Aprisa Floorplan Stage								##
    ### Version : $AP_BUILD		##
    ######################################################################################

    "

    if { $AP_BUILD != "/google/gchips/tools/mentor/aprisa/09.19.06/bin/rhel7-64/AP" } {
	puts "WARNING: Run build different from the build used to generate script via flowgen. Incompatibility could cause errors."
    }

    source $SCRIPTS/proj_setup_variables.tcl
    source $CUSTOM_SCRIPT/set_site.tcl

    set_error_level IllDefVia fatal

    rusage -timer AP_RUNTIME 
    load_project $SAVEDB/init.proj
    import_def $FP_FILE -routing
    connect_power_domain_supply -create_module_port
    
  init_floorplan -hybrid_row_sites "coreW48M143H117 coreW48M143H169"  -boundary keep -max_route_metal 13 -core_to_top 1.2285 -core_to_bottom 1.2285 -core_to_left 1.2 -core_to_right 1.2 
    if { [file exists $SCRIPTS/power_mesh.tcl] } { source $SCRIPTS/power_mesh.tcl }
    save_project default/check_fp.proj

    if { $HYBRID_ROWS == 0 } { site_unify }
    route -reset_shape_photo_mask
    verify_layout -drc
    save_project $SAVEDB/fp.proj
    catch { exec cp [get_logfile_name] $SAVELOGS/${PHASE}.log }
    exit
