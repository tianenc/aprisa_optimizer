proc checkNegativeValue {args} {
    foreach sublist $args {
        set value [lindex $sublist 1]
        if {$value < 0} {
            return 1
        }
    }
    return 0
}

proc site_unify {} {
    set def_site [get_property [current_module ] default_site ]
    set def_site_h [get_property [get_sites $def_site] height]
    set lib_cells_non_def_site [get_lib_cells * -filter_by "cell_class==std&&site!=$def_site"]
    set mh_lib_cells_non_def_site [get_lib_cells * -filter_by "cell_class==std&&site!=$def_site&&height>$def_site_h"]

    set lib_cells_my {}
    foreach_in_oblist lc $mh_lib_cells_non_def_site {
        set lib_pins [get_lib_pins -relate_to $lc -filter_by "function==POWER"]
        set bbox_list [get_property [get_lib_phys_pins -relate_to $lib_pins] bbox]
        if {[checkNegativeValue {*}$bbox_list]} {
            lappend lib_cells_my $lc
        }
    }

    set_param db allow_any_lib_attr_change true
    set_property $lib_cells_non_def_site site $def_site
    set_property $lib_cells_my site_orient MY
    set_param db allow_any_lib_attr_change false
}

#site_unify 

