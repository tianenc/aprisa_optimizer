rusage -timer AP_Report
load_project $::env(LOAD_PROJ)
set PHASE $::env(PHASE)
if {[regexp place $PHASE]} {
set prev_stage init
} elseif {[regexp cts $PHASE]} {
set prev_stage place
} elseif {[regexp cts_opt $PHASE]} {
set prev_stage cts
} elseif {[regexp route $PHASE]} {
set prev_stage cts_opt
} elseif {[regexp filler $PHASE]} {
set prev_stage route
} else {
set prev_stage ""
}
set ROOT    [pwd]
source scripts/header.tcl
source $SCRIPTS/reports_gen_procs.tcl
my_results $SAVERPT $PHASE saved
exec python $SCRIPTS/generate_stage_summary.py $LOADREVISION $PHASE $prev_stage $SAVELOGS/${PHASE}.log [lindex [current_mcmm] 0]
rusage -timer AP_Report
exit
