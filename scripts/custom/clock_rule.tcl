

set_wide_spacing_rule lsu_2.0x_spc_built_in \
        -spacing { { 6 0.0760 } { 7 0.0760 } { 8 0.0760 } { 9 0.0760 } { 10 0.0760 } { 11 0.0760 } { 12 0.1280 } { 13 0.1280 } }

set_wide_width_rule lsu_2.0x_wid_built_in \
        -width { { 6 0.0760 } { 7 0.0760 } { 8 0.0760 } { 9 0.0760 } { 10 0.0760 } { 11 0.0760 } { 12 0.1240 } { 13 0.1240 } }  

set_wide_spacing_rule lsu_3.0x_spc_built_in \
        -spacing { { 6 0.1140 } { 7 0.1140 } { 8 0.1140 } { 9 0.1140 } { 10 0.1140 } { 11 0.1140 } { 12 0.1920 } { 13 0.1920 } }

set_clock_route_rule cts_spec_route_leaf \
        -spacing_or_shield " \
                                 lsu_2.0x_spc_built_in \
         " \
        -metals " \
	 { 6 11 } \
	 "
         

set_clock_route_rule cts_spec_route_branch \
        -spacing_or_shield " \
                                 lsu_2.0x_spc_built_in \
         " \
        -width " \
                                 lsu_2.0x_wid_built_in \
         " \
        -metals " \
	 { 6 11 } \
	 "

set_clock_route_rule cts_spec_route_trunk \
         -spacing_or_shield " \
                                lsu_3.0x_spc_built_in \
         " \
        -width " \
                                lsu_2.0x_wid_built_in" \
        -metals " \
	 { 12 13 } \
	 "


set_clock_buffer_rule cts_spec_buf -default -tree_buffer [get_lib_cells $CLK_BUF_LIST]

set_clock_tree_spec -root  {} \
                    -route_rule cts_spec_route_branch \
                    -leaf_route_rule cts_spec_route_leaf \
		    -trunk_route_rule cts_spec_route_trunk \
		    -buffer_rule cts_spec_buf


