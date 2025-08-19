proc rpts_existence {f_name project mcmm gif} {
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
					set f1 [catch {glob -type f $dir/rpts/$st.power.rpt}]
					set f2 [catch {glob -type f $dir/rpts/$st.congestion.gif}]
					set f2 [expr $f2*$gif]				
					set f3 0
					set f4 0 
                                        if {$st!="place"} {
                                                set f3 [catch {glob -type f $dir/rpts/$st.clkcells.rpt}]
						set f4 [catch {glob -type f $dir/rpts/$st.designrules.rpt}]
                                        }
			

					set inp1 [catch {glob -type {d l} $dir/db/$st1*.proj}]
					set rpt [expr $f1+$f2+$f3+$f4]
					
					if {$rpt>=1 && $inp1==0} {
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
							if {$f1==1} {
								source /ads/indiatc1/reporting_scripts/html_scripts_v1/exp_results_new.tcl
								my_results $dir/rpts $st $mcmm
								purge_project
							}
							if {$f1==0 && $f2==1} {
								puts "generating GIF reports for $proj"
								source /ads/indiatc1/reporting_scripts/html_scripts_v1/dump_gif.tcl
								gif_reports $dir/rpts $st
								purge_project
							}
							if {$f1==0 && $f3>=1} {
                                                                source /ads/indiatc1/reporting_scripts/html_scripts_v1/report_clk_cells.tcl
                                                                report_clk_cells $dir/rpts $st
                                                        }
							if {$f1==0 && $f4==1} {
								report_skew_group_constraint  -design_rules > $dir/rpts/$st.designrules.rpt
							}
						}
					}
				}
			}
		}
		close $FP
	} else { puts "$f_name file doesn't exists" }
}

