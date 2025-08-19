foreach lib_cell [get_property [get_lib_cell * -filter "cell_class == std"] base_name_id] {
    #############Set libcell Vth###############
    if { [regexp (.*)BWP7D5T16P96CPDULVT$ $lib_cell] } {
	set_property [get_lib_cell $lib_cell] vth_level 1
	puts "setting property for $lib_cell vth_level 1 "
    }

    if { [regexp (.*)BWP7D5T16P96CPDLVT$ $lib_cell] } {
	set_property [get_lib_cell $lib_cell] vth_level 2
	puts "setting property for $lib_cell vth_level 2 "
    }

    if { [regexp (.*)BWP7D5T16P96CPD$ $lib_cell] } {
	set_property [get_lib_cell $lib_cell] vth_level 3
	puts "setting property for $lib_cell vth_level 3 "
    }

    if { [regexp (.*)BWP7D5T16P96CPD$ $lib_cell] } {
	set_property [get_lib_cell $lib_cell] vth_level 4
	puts "setting property for $lib_cell vth_level 4 "
    }

}

   
		######if Clone ICG during place_opt######   
		set_property [get_lib_cell $AF_ICG_LIST] is_clock_driver 1
		set_property [get_lib_cell $AF_ICG_LIST] dont_use_in_opt  false  
  	        ################################end clone icg############################

