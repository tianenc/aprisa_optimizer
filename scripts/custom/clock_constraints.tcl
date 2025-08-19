
set max_fanout 32
set max_clock_skew 0.06084758484274811
set max_clock_tran 0.05934272512227637
set max_sink_tran 0.07161061395671824

set temp " -max_fanout $MAX_FANOUT"

foreach scn [current_mcmm] {
    set_working_scen $scn
    set_max_transition $max_clock_tran [get_clocks [all_clocks]] -clock_path
}

set_working_scenario {}
# The -max_cap parameter has been removed from this command
set cmd "set_skew_group_constraint -group {[get_skew_groups * ]} -max_skew $max_clock_skew -max_tran $max_clock_tran -max_sink_tran $max_sink_tran"

if {$temp != ""} {
    concat $cmd $temp
    eval $cmd
} else {
    eval $cmd
}
