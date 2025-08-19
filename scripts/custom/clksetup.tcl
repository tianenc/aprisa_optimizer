#
# Siemens Floorplan Out
# Job Timestamp: 0606.0253.39
# Version: rd
# Date Created: Tue Jun  6 04:29:19 2023
# Project: fp.proj (saved @ Mon Jun  5 23:38:11 2023)
#

# Output Command: export_setup clk_setup.tcl -clock

#
# Module: rcc_vfuvfx
#

set _ap_curr_mod [get_module rcc_vfuvfx]

clear_setup -clock

set_wide_width_rule M6_M8_1.0x_wid \
            -width { {6 0.0380} {7 0.0380} {8 0.0380 } }

set_wide_width_rule M6_M11_2.0x_wid \
            -width { {6 0.0760 } {7 0.0760 } {8 0.0760} {9 0.0760} {10 0.0760} {11 0.0760} }

set_wide_width_rule M12_M15_2.0x_wid \
            -width { {12 0.124} {13 0.124} {14 0.124} {15 0.124 }}

set_wide_spacing M6_M8_2.0x_spc \
            -spacing { {6 0.0760} {7 0.0760} {8 0.0760} }

set_wide_spacing M6_M11_2.0x_spc \
            -spacing { {6 0.0760} {7 0.0760} {8 0.0760} {9 0.0760 } {10 0.0760} {11 0.0760} }

set_wide_spacing M12_M15_2.0x_spc \
            -spacing { {12 0.1280} {13 0.1280} {14 0.1280 } {15 0.1280 }}

set_shield_rule M6_M8_2.0x_shield \
            -shield { 6 7 8 } \
            -snap_shield_on_track \
            -wrong_way_shield_limit  32

set_shield_rule M6_M11_2.0x_shield  \
            -shield { 6 7 8 9 10 11 } \
            -snap_shield_on_track \
            -wrong_way_shield_limit  32

set_shield_rule M12_M15_2.0x_shield \
            -shield { 12 13 14 15 } \
            -snap_shield_on_track \
            -wrong_way_shield_limit  32

#
# clock route rules
#

set_clock_route_rule _clock_2x_spc_built_in  \
            -default \
            -spacing_or_shield { \
                        _2.0x_spc_built_in \
            } \
            -metals { \
                        { 3 18 } \
            }

set_clock_route_rule cts_spec_route_leaf \
            -spacing_or_shield { \
                        M6_M8_2.0x_spc  \
            } \
            -width { \
                        M6_M8_1.0x_wid \
            } \
            -metals { \
                        { 6 11 } \
            }

set_clock_route_rule cts_spec_route_branch \
            -spacing_or_shield {  \
                        M6_M11_2.0x_spc  \
            } \
            -width { \
                        M6_M11_2.0x_wid \
            } \
            -metals { \
                        { 6 11 } \
            }

set_clock_route_rule cts_spec_route_trunk \
            -spacing_or_shield { \
                        M12_M15_2.0x_spc  \
            } \
            -width { \
                        M12_M15_2.0x_wid \
            } \
            -metals { \
                        { 12 15 } \
            }

set buffer_clk { }

set_clock_buffer_rule buf_rule \
            -tree_buffer $buffer_clk

#
# clock tree spec
#
set_clock_tree_spec -root {} \
-trunk_route_rule  cts_spec_route_trunk \
-leaf_route_rule cts_spec_route_leaf  \
-route_rule cts_spec_route_branch \
-buffer_rule buf_rule
