#Set preserve properties on selected cells
#set_property [get_cells cell*] preserve 1

#Set dont_use_in_opt properties on selected lib_cells
#set_property [get_lib_cells cell*] dont_use_in_opt 1

#source $CUSTOM_SCRIPT/dont_use.tcl
#set_property [ get_lib_cells $dontuse_list ] dont_use_in_opt 1
#puts "dont use list"

#Set dont_touch_in_opt properties on selected lib_cells
#set_property [get_lib_cells cell*] dont_touch_in_opt 1

#Set dont_touch_in_opt properties on selected nets
#set_property [get_nets net*] dont_touch_in_opt 1
