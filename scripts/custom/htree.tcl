
set_param cts h_tree_orientation horizontal
set anchor_lib 
set_property [get_lib_cells $anchor_lib ] dont_touch false
set_property [get_lib_cells $anchor_lib ] dont_use_in_opt false
set_property [get_lib_cells $anchor_lib ] dont_touch_in_opt false
set_property [get_lib_cells $anchor_lib ] is_clock_driver true
set H_root 
set level 
set area [get_property [current_module] bbox] 

set_clock_route_rule htree_rule \
	-default -module [current_module] \
         -spacing_or_shield " \
                                 _1.0x_shield_spc_built_in \
         " \
        -width " \
                                   _2.0x_wid_2x_via_built_in \
         " \
        -metals " \
	 { 12 14 } \
	 "
update_skew_group -full
set_working_scenario [lindex current_mcmm 0]

generate_htree $H_root -module [current_module] -level $level -lib_cells $anchor_lib -route_rule htree_rule -area $area -fix_drv -balance_anchor_load

update_skew_group -full
set_working_scenario {}
set_property [get_lib_cells $anchor_lib ] dont_use_in_opt true
set fanin_nets [get_nets -relate_to [get_all_fanins -to_objects [get_pins -relate_to [get_cells AThtree_h*anchor*ATcto_* ] -filter_by "direction_of_signal == in"]]]
set clkrootnet [get_nets -relate_to $H_root]
set_property [get_nets $fanin_nets ] wide_width_rule _2.0x_wid_2x_via_built_in
set_property [get_nets $fanin_nets ] dont_touch_in_opt true
set_param db custom_clock_route_as_mesh false 
route -g -d -repair -effort high -nets $fanin_nets 
set_property [get_shapes -relate_to $fanin_nets -filter_by "route_type != custom"] route_type custom 
set_property [get_nets $fanin_nets ] dont_route true 
set_property [get_nets $fanin_nets ] dont_touch_in_opt true
set_property [get_nets $clkrootnet ] dont_route false 
set_property [get_nets $clkrootnet ] dont_touch_in_opt false 
extract_parasitic -clear 
extract_parasitic 

