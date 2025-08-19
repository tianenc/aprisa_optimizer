


proc detailedReports {input} {
	global reports_path
	set reports_path ".csv_reports"
	global work_areas
	global full_path
	catch {unset work_areas}
	source .csv_reports/work_areas.tcl
	foreach block [array names work_areas] {
		#puts here 
		set was $work_areas($block)
        
		
		foreach wa $was {
			#puts $wa
			global html_str
        		set html_str ""
        		set F1 [open "/ads/indiatc1/reporting_scripts/html_scripts_v1/inp.html" r]
       			set html_str [read $F1]
        		close $F1
			append html_str "<h1><b>Detailed Report</b></h1>\n"
			set date [date]
			append html_str "<h3><b>Date created: $date</b></h2>\n"
			set run_path $full_path($wa)
			#puts $run_path
			append html_str "<br><font size=+0.9><b>Design: <font color=#0069b5>$block</font></b></font>\n"
			append html_str "<br><font size=+0.9><b>Project Path: <font color=#0069b5>$run_path</font></b></font>\n"
			foreach stage {place cts cts_opt route} {
				if {[catch {exec egrep "Standard utilization" ${reports_path}/${block}_${wa}_${stage}_det.csv}]==0} {

				append html_str "<p><font size=+2><b>[string totitle $stage:]</b></font></p>\n"
				set IN [open "${reports_path}/${block}_${wa}_${stage}_det.csv" r]
				append html_str [read $IN]
				close $IN
				if {$stage == "route" || $stage == "cts_opt" } {
					set report_tabs {setup hold drv power}
				}
				if {$stage == "place"} {
					set report_tabs {setup drv power }
				}
				if {$stage == "cts"} {
					set report_tabs {skew drv power}
				}
			foreach report_tab $report_tabs {
				
				append html_str "<p><font size=+1><b>[string totitle $report_tab:]</b></font></p>\n"

				if {$report_tab == "setup" || $report_tab == "hold" } {
					set file_name "${reports_path}/${block}_${wa}_${stage}_detailed_${report_tab}_timing.csv"
					set IN1 [open $file_name r]
					append html_str "<table  id=\"t01\">\n"
                       			set row 1
					set scn_all_pg 0
        				while { [gets $IN1 data] >= 0 } {
						set column_list [split $data ","] 
						#puts "$column_list"
						if {$row==1} {
							append html_str "<tr>\n"
						}
						set col 1
						set en_b ""
						set en_be ""
						if {[llength $column_list]==4} {
							append html_str "\t</tr><tr style=\"visibility: collapse;\">\n"
							set col 2
						} elseif {[lindex $column_list 1]==" " && [regexp "Total QOR" $data]==0} {
							if {$scn_all_pg>0} {
								append html_str "</tr></tbody>\n"
							}
							append html_str "<tbody><tr>\n"
							incr scn_all_pg
						} elseif {[regexp "Total QOR" $data]} {
							append html_str "</tr></tbody>\n"
							append html_str "<tbody><tr>\n"
							set en_b "<b>"
							set en_be "</b>"
							set col 2
						}
						foreach cell $column_list {
							if {$row == 1} {
								append html_str "\t <th><b>$cell</th></b>\n"	
							}
							if {$row > 1} {
									if {$col==1} {
										append html_str "\t<td><label><input type=\"checkbox\"onClick=\"toggleRowGroup(this)\">$cell</label><br></td>\n"
										incr col
									} else {
										append html_str "\t <td>$en_b $cell $en_be</td>\n"
									}
								
							}
						}
						if {$row==1} {
							append html_str "</tr>\n"
						}

						#append html_str "\t</tr>\n"
						incr row 
						
        				}
					append html_str "</tr></tbody>\n"
					close $IN1
					append html_str "</table>\n"
				}
      
				if {$report_tab == "drv" } {
					set file_name "${reports_path}/${block}_${wa}_${stage}_detailed_${report_tab}.csv"
					set IN1 [open $file_name r]
					set row 1 
					append html_str "<table  id=\"t01\">\n"
					while { [gets $IN1 data] >= 0 } {
						set column_list [split $data ","] 
						#puts "$column_list"
						append html_str "\t<tr>\n"
						set en_b ""
						set en_be ""
						if {[regexp "Total" $data]} {
							set en_b "<b>"
							set en_be "</b>"
						}
						foreach cell $column_list {
							if {$row== 1} {
								append html_str "\t <th><b>$cell</th></b>\n"
							}
          						if {$row>1} {
           							append html_str "\t <td>$en_b $cell $en_be</td>\n"
         						}
         					}
					append html_str "\t</tr>\n"
					incr row
        				}
        				close $IN1
					append html_str "</table>\n"
       				}
      				if {$report_tab == "power" } {
         				set file_name "${reports_path}/${block}_${wa}_${stage}_detailed_${report_tab}.csv"
        				set IN1 [open $file_name r]
        				set row 1
					set scn_sum 0
					append html_str "<table  id=\"t01\">\n"
       			 		while { [gets $IN1 data] >= 0 } {
         					set column_list [split $data ","] 
         					#puts "$column_list"
         					if {$row==1} {
							append html_str "\t<tr>\n"
						}
						set col 1			
						if {[llength $column_list]==6} {
                                                        append html_str "\t</tr><tr style=\"visibility: collapse;\">\n"
                                                        set col 2
                                                } elseif {[regexp ", ," $data]} {
                                                        if {$scn_sum>0} {
                                                                append html_str "</tr></tbody>\n"
                                                        }
                                                        append html_str "<tbody><tr>\n"
                                                        incr scn_sum
                                                }
						foreach cell $column_list {
                                                        if {$row == 1} {
                                                                append html_str "\t <th><b>$cell</th></b>\n"    
                                                        }
                                                        if {$row > 1} {
                                                                        if {$col==1} {
                                                                                append html_str "\t<td><label><input type=\"checkbox\"onClick=\"toggleRowGroup(this)\">$cell</label><br></td>\n"
                                                                                incr col
                                                                        } else {
                                                                                append html_str "\t <td>$cell</td>\n"
                                                                        }
                                                                
                                                        }
                                                }
                                                if {$row==1} {
                                                        append html_str "</tr>\n"
                                                }

                                                #append html_str "\t</tr>\n"
                                                incr row
        				}
					append html_str "</tr></tbody>\n"
        				close $IN1
					append html_str "</table>\n"
       				}
				if {$report_tab == "skew" } {
					set f_skew [ open "$reports_path/${block}_${wa}_${stage}.skew.csv" r]
					append html_str [read $f_skew]
					close $f_skew
					set file_name "${reports_path}/${block}_${wa}_${stage}_detailed_${report_tab}.csv"
					set IN1 [open $file_name r]
					set row 1
					append html_str "<table  id=\"t01\">\n"
					while { [gets $IN1 data] >= 0 } {
						set column_list [split $data ","] 
         					#puts "$column_list"
         					append html_str "\t<tr>\n"
         					foreach cell $column_list {
          						if {$row==1} {
           							append html_str "\t <th><b>$cell</th></b>\n"
          						}
          						if {$row>1 } {
           							append html_str "\t <td>$cell</td>\n"
          						}
         					}
						append html_str "\t</tr>\n"
         					incr row
        				}
					append html_str "</table>\n"
       					close $IN1
      				}

       				

			}
		}
		}
	append html_str "</body>\n"
	append html_str "</html>\n"
	set inp_file "${input}_$wa"
	dumphtml $inp_file
	}

}
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





proc dumphtml {inp_file} {
	global html_str
	set FP [open "$inp_file.html" w]
	puts $FP $html_str
	close $FP
	
}




