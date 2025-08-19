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

# --- MODIFICATION START ---
# Check for a trial_number argument passed from the Optuna script.
# The 'argv' variable holds command-line arguments passed to the script.
if {[llength $argv] > 0 && [string is integer [lindex $argv 0]]} {
    set trial_number [lindex $argv 0]
    # Set a global variable for the unique report path so report_gen_procs.tcl can access it.
    set ::unique_skew_report_path "reports/cts_trial_${trial_number}.skew.rpt"
    puts "INFO: Optuna trial number '${trial_number}' detected. Setting unique report path to '${::unique_skew_report_path}'"
}
# --- MODIFICATION END ---

load_project test.proj

set AP_BUILD [info nameofexecutable]
puts "
######################################################################################
### Aprisa CTS Stage								##
### Version : $AP_BUILD		##
######################################################################################
"
if { $AP_BUILD != "/google/gchips/tools/mentor/aprisa/09.19.06/bin/rhel7-64/AP" } {
puts "WARNING: Run build different from the build used to generate script via flowgen. Incompatibility could cause errors."
}
############################################
### Working area setup ##
############################################

set ROOT    [pwd] 
set PHASE   cts
source scripts/header.tcl
rusage -timer AP_RUNTIME 
source $SCRIPTS/proj_setup_variables.tcl
source scripts/flow_design_settings.tcl
set PROJECT $LOADDB/place.proj
####################
### Load project  ##
####################
if {![llength [current_module]]} {
load_project $PROJECT
}

################
### MCMM setup ##
#################
#############################
### Set effective scenario  ##
##############################

set mcmm_str "current_mcmm"
if { $CTS_EFFECTIVE_SCENARIO != "" } {
append mcmm_str " {$CTS_EFFECTIVE_SCENARIO}"
} else {
append mcmm_str " -every" 
}
if { $LEAKAGE_SCENARIO != "" } {
append mcmm_str " -worst_leakage $LEAKAGE_SCENARIO"
}
eval $mcmm_str
source $SCRIPTS/flow_design_settings.tcl
source $PARAMS/cts_params.tcl

##################################################
### Set Don't touch/use property on clock cells ##
##################################################
set_property [get_lib_cells $CLK_BUF_LIST] is_clock_driver true
set_property [get_lib_cells $CLK_BUF_LIST] dont_use_in_opt false
set_property [get_lib_cells $CLK_BUF_LIST] dont_touch_in_opt false

#####################
### Clock setup   ##
#####################

source scripts/custom/clock_rule.tcl
derive_skew_groups
# --- MODIFICATION START ---
# This block now uses the trial_number to source a unique constraints file.
if {[info exists trial_number]} {
    set constraints_file_path "scripts/custom/clock_constraints_${trial_number}.tcl"
    if {[file exists $constraints_file_path]} {
        source $constraints_file_path
    } else {
        puts "WARNING: Clock constraints file not found at: $constraints_file_path. Using default."
        source scripts/custom/clock_constraints.tcl
    }
} else {
    source scripts/custom/clock_constraints.tcl
}
# --- MODIFICATION END ---
#########################
### Export clock setup ##
#########################

export_skew_group $SAVEDATA/check.sg
export_setup -clock $SAVEDATA/check_sg.setup
#####################################
### Source customization script   ##
#####################################
set STEP "pre"

source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl

if { $MULTI_POINT_CTS == 1 } {
source $CUSTOM_SCRIPT/multi_point_cts.tcl
}
if { $HTREE_CTS == 1 } {
source  $CUSTOM_SCRIPT/htree.tcl
}
set cts_cmd "synthesize_skew_group {[get_skew_group *]} $CTS_EXTRA_OPTIONS"
if { $BUILD_CLOCK_TREE } {
append cts_cmd "-reoptimize"
} else {
append cts_cmd "-delete_first"
}


############################
### Synthesize skew group ##
############################ 
rusage -timer SYNTHESIZE_SKEW_GROUP
eval $cts_cmd

rusage -reset -timer SYNTHESIZE_SKEW_GROUP

#################################
### Source customization script ##
###############################
set STEP "post"
source  $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl

####################
### save project  ##
####################
save_proj $SAVEDB/$PHASE.proj

#########################
### Generate reports   ##
#########################

if {$AF_PARALLEL_REPORTING} {
exec xterm -T parallel_report -e "setenv LOAD_PROJ $SAVEDB/$PHASE.proj ; setenv PHASE $PHASE ; $AP_BUILD -log_dir $SAVELOGS $SCRIPTS/parallel_report.tcl -log rpt_${PHASE}.log ; exit" &
} else {
source scripts/reports_gen_procs.tcl
my_results $SAVERPT $PHASE saved
#	exec python $SCRIPTS/generate_stage_summary.py $LOADREVISION $PHASE place $SAVELOGS/${PHASE}.log [lindex [current_mcmm] 0]
rusage -reset -timer AP_RUNTIME
}
#########################
### Source end script  ##
#########################

##################save stuff ############################
set FILE [open $SAVEDATA/cts_vars.tcl w]
puts $FILE  "namespace eval cts {variable dummy 0}"
foreach cts_var [info vars cts::*] {
puts $FILE "set $cts_var \{[set $cts_var]\}"
}
close $FILE
##############
exec cp $CUSTOM_SCRIPT/flowgen_custom_inputs.tcl $SAVEDATA/flowgen_custom_inputs.tcl 
exec cp $PARAMS/${PHASE}_params.tcl $SAVEDATA/${PHASE}_params.tcl
if { $use_flow_params_for_reports } { report_param -all > $SAVERPT/${PHASE}_params.tcl }
catch { exec cp [get_logfile_name] $SAVELOGS/${PHASE}.log }
exit