proc lib_search_path {lib_paths} {
	set cmd {}
	foreach path $lib_paths {
		if {![catch {exec ls $path} f] } {
          		foreach a $f {
                		if {[regexp ".lib" $a]} {
                			set b [split $a "/"]
                			lappend cmd [lindex $b [expr {[llength $b] -1}] ]
                		}
                	}
        	}
        }
	return $cmd
}


proc lef_search_path {lef_paths} {
	set cmd {}
	foreach path $lef_paths {
		if {![catch {exec ls $path} f] } {
          		foreach a $f {
                		if {[regexp ".lef" $a]} {
                			set b [split $a "/"]
                			lappend cmd [lindex $b [expr {[llength $b] -1}] ]
                		}
                	}
        	}
        }
	return $cmd
}

