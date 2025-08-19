proc w_areas {f_name} { 
	set f1 [open "$f_name" r]
	set f2 [open ".csv_reports/work_areas.tcl" w]
	while {[gets $f1 data]>=0} {
		set L [split $data ","]
		set block [string tolower [lindex $L 0]]
		set dirs [lreplace $L 0 0 ]
		set dirs1 ""
		foreach dir $dirs {
			set k [split $dir "/"]
			set tmp_dir ""
			append tmp_dir [string map {. _} [lindex $k end-1] ]
			append tmp_dir "_"
			append tmp_dir [ string map {. _} [lindex $k end ]]
			lappend dirs1 $tmp_dir
			set wa $tmp_dir
			puts $f2 "set full_path($wa) $dir"
		}
		puts $f2 "set work_areas($block) {$dirs1}"
	}
	close $f1
	close $f2
}
