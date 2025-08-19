load_project default/db/export.proj
source ./scripts/export_html.tcl
export_html -scenario [lindex [current_mcmm] 0] -input scripts/html_inputs.txt
exit
