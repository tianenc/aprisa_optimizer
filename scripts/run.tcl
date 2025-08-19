#! /bin/csh
set run_dir =(/usr/local/google/gcpu/collab/ment-collab/prj-pd/rajivdarji/ecore_lsu_wrapper/BASE.041024)
set log_dir =  (${run_dir}/logs)
set ap = (/usr/local/google/gcpu/tools/siemens/aprisa/AP_23.R3/bin/rhel7-64/AP.040824 -log_dir ${log_dir})

#${ap} -8 scripts/init.tcl -log init.log -sum_log init.sum
#${ap} -8 scripts/fp.tcl -log fp.log -sum_log fp.sum

${ap} -8 scripts/place.tcl -log place.log -sum_log place.sum
${ap} -8 scripts/cts.tcl -log cts.log -sum_log cts.sum
${ap} -8 scripts/cts_opt.tcl -log cts_opt.log -sum_log cts_opt.sum
${ap} -16 scripts/route.tcl -log route.log -sum_log route.sum
${ap} -8 scripts/filler.tcl -log filler.log -sum_log filler.sum
${ap} -8 scripts/export.tcl -log export.log -sum_log export.sum

#${ap} scripts/generate_html.tcl

#exec python scripts/standalone_summary.py /usr/local/google/gcpu/orion/prj-pd/rajivdarji/test_0/default

