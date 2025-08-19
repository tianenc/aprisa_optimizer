proc generate_reports {f_name project mcmm} {
	if {[file exists $f_name]} {
		set FP [open "$f_name" r]
		while {[gets $FP data]>=0} {	
			set L [split $data ","]
			set dirs [lreplace $L 0 0]
			set stage {place cts cts_opt route}
			foreach dir $dirs {
				foreach st $stage {
					set st1 $st
					if {$st=="cts"} {
					 	if {[catch {glob -type {d l} $dir/db/clock.proj}]==0} {
							set st1 "clock"
						}
					}
					if {$st=="cts_opt"} {
					 	if {[catch {glob -type {d l} $dir/db/clock*.proj}]==0} {
							set st1 "clockopt"
						}
					}

		

					#puts "stage:$st"
			
					set latest 0
					foreach file [glob -type {d l} $dir/db/$st1*proj] {
						 set m_time [file mtime $file]
				 		if {$m_time > $latest} {
							set latest $m_time
							set proj $file
						}

					}
					if {$st=="cts"} {
						set proj "$dir/db/$st1.proj"
					}
				
					#set proj [lindex $k 0]
					set tmp [split $proj "/"]
					set proj_name [lindex $tmp [expr [llength $tmp]-1]]
					if {[regexp {[0-9]+} $proj_name]!=1} {
						puts  "generating reports for $proj"
						purge_project
						load_proj $proj
						if {$project=="amazon"} { 
							set_param lpe clock_min_arnoldi 0.001
						}
						source /ads/indiatc1/reporting_scripts/html_scripts_v1/exp_results_new.tcl
						my_results $dir/rpts $st $mcmm
						purge_project
							

					}
					
				}
			}
		}
		close $FP
	} else { puts "$f_name file doesn't exists" }
}

