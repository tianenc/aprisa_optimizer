




proc compare {inp_file scn} {
	global reports_path
	set reports_path ".csv_reports"
	global work_areas
	global full_path
	catch {unset work_areas}
	source .csv_reports/work_areas.tcl
	global work_areas
	global reports_path
	foreach blk [array names work_areas] {
		set block $blk
		set was $work_areas($block)
	}
	set goldenrun [lindex $was 0]

	#puts $new_was
	set new_was [uniqueList $was]
	set stages {place cts cts_opt route}
	global csv_str
	global html_str
	set html_str ""
	set F1 [open "/ads/indiatc1/reporting_scripts/html_scripts_v1/inp.html" r]
	set html_str [read $F1]
	close $F1
	set csv_str ""
	append html_str "<h1><b>Comparison Report</b></h1>\n"
	set date [date]
	append html_str "<h3><b>Date created: $date</b></h2>\n"
	set run_path $full_path($goldenrun)
	append html_str "<br><font size=+0.9><b>Design: <font color=#0069b5>$blk</font></b></font>\n"
	append html_str "<br><font size=+0.9><b>Dominant Scenario: <font color=#0069b5>$scn</font></b></font>\n"
	append html_str "<br><font size=+0.9><b>Base run: <font color=#0069b5>$run_path</font></b></font>\n"
	
	set cmp_was [lreplace $new_was 0 0 ]
	if {[llength $new_was]>=2} {
		append html_str "<p><b>Compare runs:</b>\n"
	}
	foreach	cmp_wa $cmp_was {
		set cmp_runpath $full_path($cmp_wa)
		append html_str "<br><font size=+0.9><b><font color=#0069b5>$cmp_runpath</font></b></font>\n"
	}
	if {[llength $new_was]>=2} {
		append html_str "</p>\n"
	}	
	 foreach stage $stages {
		append html_str "<p><font size=+2><b>[string totitle $stage:]</b></font></p>\n"
		append csv_str "$stage\n"
		foreach fname {setup hold power_drv cell_count cell_areas miscellaneous} {
    			set i 0
    			set indexes {}
    			set values {}
	
	
			set FNAME [split [string totitle  $fname] "_"]
                	if {[regexp "Misc" $FNAME]==0} {
                       		append html_str "<p><font size=+1><b>$FNAME Summary:</b></font></p>\n"
				append csv_str "$FNAME Summary\n"
               		} else {
                       	 	append html_str "<p><font size=+1><b>$FNAME:</b></font></p>\n"  
				append csv_str "$FNAME\n"  
                	}

		
			append html_str "<table  id=\"t01\">\n"
			append html_str "\t<tr>\n"

    			foreach wa $was { 
     				set file_name "${reports_path}/${block}_${wa}_${stage}.$fname.csv"
    				set IN [open $file_name r]
     				if {$i==0} {
      					lappend indexes "Work_Area"
    				}
     				set values_c [list $wa] 
     				while { [gets $IN data] >= 0 } {
      					set column_list [split $data ","] 
     		 			if {$i ==0} {
       						lappend indexes [lindex $column_list 0] 
      					}
      					lappend values_c [lindex $column_list 1]
     				}
     				lappend values $values_c
     				set i [expr $i + 1]
     				close $IN
    			}
    			set row 0
    			set col 0
    			foreach index $indexes {

     				append csv_str $index ","
     				set str [string map {- _} $index]
     				append html_str "\t <th><b>[join $str _]</th></b>\n"

     				set column_arr($col) [join $index "_"]
		
     				set col [expr $col + 1]
    			}
    			append html_str "\t</tr>\n"
    			set csv_str [string range $csv_str 0 end-1]
    			append csv_str "\n"
    			set row 1
    			set col 0
    			foreach values_c  $values {
     				append html_str "\t<tr>\n"
     				foreach val $values_c {
     					set array_val($row)($col) $val
     					set color 0
    		 			append csv_str $val ","
     					#global thres
     					global arr
     					set cmd "set idx \$\{column_arr\($col\)\}"
     					eval $cmd

     			if {$row>1 && [regexp {[0-9]+:[0-9]+:[0-9]+} $val]} {
				set tmp [regexp {([0-9]+):([0-9]+):([0-9]+)} $val match hour min sec]
				set hour [expr [scan $hour "%d"]]
				set min [expr [scan $min "%d"]]
				set sec [expr [scan $sec "%d"]]

				set rtime [expr [expr $hour*60*60] + [expr $min*60] + [expr $sec]]
				set cmd "set def_val \$\{array_val\(1\)\($col\)\}"
			eval $cmd
			if {[regexp {[0-9]+:[0-9]+:[0-9]+} $def_val]} {
				set tmp [regexp {([0-9]+):([0-9]+):([0-9]+)} $def_val match hour1 min1 sec1]
				set hour1 [expr [scan $hour1 "%d"]]
				set min1 [expr [scan $min1 "%d"]]
				set sec1 [expr [scan $sec1 "%d"]]
				set def_rtime [expr [expr $hour1*60*60] + [expr $min1*60] + [expr $sec1]]
			} else {
	 			set def_rtime 0
			}

			set th 0.05

			set min_val [expr $def_rtime-[expr $th*$def_rtime]]
			set min_val [expr abs($min_val)]
			set max_val [expr $def_rtime+[expr $th*$def_rtime]]
			set max_val [expr abs($max_val)]

			

			if {$rtime<=$def_rtime} {
				append html_str "\t <td style=\"background:chartreuse\">$val</td>\n"
			} elseif {$rtime>$def_rtime && $rtime<=$max_val && $def_rtime!="0"} {
				append html_str "\t <td style=\"background:yellow\">$val</td>\n"

			} elseif {$rtime>$max_val && $def_rtime!="0"} {
                		append html_str "\t <td style=\"background:orangered\">$val</td>\n"
			} else  {		
				append html_str "\t <td>$val</td>\n"
			}
			set color 1
    		}
     #set cmd "set index_val \$\{array_val\(0\)\($col\)"
     #eval $cmd
     #puts  "$index_val"
     #puts $idx
     if {$row>1 && [regexp {[0-9]+[.]*[0-9]*/[0-9]+[.]*[0-9]*} $val]} {
	set k [regexp {([0-9]+[.]*[0-9]*)/([0-9]+[.]*[0-9]*)} $val match val1 val2]
	set tot_val [expr $val1+$val2]
	if {[info exists array_val(1)($col)]} {
			set cmd "set def_val \$\{array_val\(1\)\($col\)\}"
			eval $cmd
			set def $def_val
	}
	
	if {[regexp {NA} $def]==0} {
			set k [regexp {([0-9]+[.]*[0-9]*)/([0-9]+[.]*[0-9]*)} $def match def_val1 def_val2]
			set def_tot_val [expr $def_val1+$def_val2]
			set def_val $def_tot_val
			set th 0.05
			set min_val [expr $def_val-[expr $th*$def_val]]
			set min_val [expr abs($min_val)]
			set max_val [expr $def_val+[expr $th*$def_val]]
			set max_val [expr abs($max_val)]
	}


	if {$tot_val<=$def_val && $def!="NA"} {
				append html_str "\t <td style=\"background:chartreuse\">$val</td>\n"
			} elseif {$tot_val>$max_val && $def!="NA"} { 
				append html_str "\t <td style=\"background:orangered\">$val</td>\n"
			
			} elseif {$tot_val>$def_val && $tot_val<=$max_val && $def!="NA"} {
				append html_str "\t <td style=\"background:yellow\">$val</td>\n"
							
			} else {	
				append html_str "\t <td>$val</td>\n"
			}
	set color 1
	
     }
     if {$row>1 && [regexp {^[-]*[0-9]+[.]*[0-9]*$} $val ] } {
		set abs_val [expr abs($val)]
		#puts "abs_val:$abs_val"
		set k 0
		if {[info exists array_val(1)($col)]} {
			set cmd "set def_val \$\{array_val\(1\)\($col\)\}"
			eval $cmd
			set def $def_val
		} 
		if {$def_val=="-" && [regexp {^[-]} $val]} {
			set k 1
		}
		if {$def_val=="-" || $def_val == "NA"} {
			set def_val 0.001
		}
		if {[regexp {[0-9]+} $def_val]} {
			set def_val [expr abs($def_val)]
			set th 0.05

			set min_val [expr $def_val-[expr $th*$def_val]]
			set min_val [expr abs($min_val)]
			set max_val [expr $def_val+[expr $th*$def_val]]
			set max_val [expr abs($max_val)]

			
		}
		if {$idx!="Mbit_Conv" && $idx!="Totalvias"} {
			if {$abs_val<=$def_val && $k==0 && $def!="NA"} {
				append html_str "\t <td style=\"background:chartreuse\">$val</td>\n"
			} elseif {$abs_val>$max_val && $def!="NA"} { 
				append html_str "\t <td style=\"background:orangered\">$val</td>\n"
			
			} elseif {$abs_val>$def_val && $abs_val<=$max_val && $def!="NA" || $k==1} {
				append html_str "\t <td style=\"background:yellow\">$val</td>\n"
							
			} else {	
				append html_str "\t <td>$val</td>\n"
			}
		} else {
			if {$abs_val>=$def_val && $k==0 && $def!="NA"} {
				append html_str "\t <td style=\"background:chartreuse\">$val</td>\n"
			} elseif {$abs_val<$min_val && $def!="NA"} { 
				append html_str "\t <td style=\"background:orangered\">$val</td>\n"
			
			} elseif {$abs_val<$def_val && $abs_val>=$min_val && $def!="NA" || $k==1} {
				append html_str "\t <td style=\"background:yellow\">$val</td>\n"
							
			} else {	
				append html_str "\t <td>$val</td>\n"	
			}
		}
		set color 1
	}
	if {$color==0} {
	        append html_str "\t <td>$val</td>\n"
     }
     set col [expr $col + 1]
     }
     set row [expr $row + 1]
     set col 0
     append html_str "\t</tr>\n"
     set csv_str [string range $csv_str 0 end-1]
     append csv_str "\n"
    }
    #append html_str "\t</tr>\n"	
    append html_str "</table>\n"
    set csv_str [string range $csv_str 0 end-1]
    append csv_str "\n"
  }
  }
  append html_str "</body>\n"
  append html_str "</html>\n"
  dumphtml $inp_file
  exportcsv $inp_file
}

proc uniqueList {list} {
  set new {}
  foreach item $list {
    if {[lsearch $new $item] < 0} {
      lappend new $item
    }
  }
  return $new
}

	

proc exportcsv {inp_file} {
	global csv_str
	set FP [open "$inp_file.csv" w]
	puts $FP $csv_str
	close $FP
	
}
proc dumphtml {inp_file} {
	global html_str
	set FP [open "$inp_file.html" w]
	puts $FP $html_str
	close $FP
	
}




