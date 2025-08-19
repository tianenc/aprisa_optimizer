set_param ta propagated_clocks false
set_param ta unset_ideal_clock_net 1
set_param ta set_ideal_clock_net 0

set_param cts move_gating true
set_param cts move_gating_effort_level high
set_param cts clone_gating f
set_param cts clone_gating_force f

set_param ta ignore_max_fanout_drv true 
set_param cts spec_max_trans_error_margin .1

clear_setup -clock
purge_skew_groups

set_clock_tree_spec -clear [get_cts_root]

set_skew_group_analysis_type bc_wc

derive_skew_groups

foreach scn [current_mcmm] {
   set_working_scenario $scn
   set_param ta port_prop_clock_latency false
   set_param ta propagated_clocks false
   set_param ta enable_crpr 0
  }
current_mcmm -every

synthesize_skew_group [get_skew_group *] -build
