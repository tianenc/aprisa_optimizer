proc summary_csv {f_name} {
set FP [open "$f_name" r]
if {[file isdirectory .csv_reports]==0} {
	exec mkdir .csv_reports
} else {
	catch { exec rm -rf .csv_reports }
	catch {exec mkdir .csv_reports }
}

#set list_place {TMR FF_Push/Pull FF_pull_avg Mbit_Conv H/V_Overflow Wirelength run_time}
set list_cts { Min_Latency Max_Latency Skew Avg_Skew Total_skew}
#set list_cts_opt {TMR H/V_Overflow Wirelength run_time}
#set list_route {H/V_Overflow Wirelength Totalvias DRC Shorts ANT run_time}
set stage {place cts cts_opt route}
while {[gets $FP data]>=0} {
	set L [split $data ","]
	set block_name [lindex $L 0]
	set dirs [lreplace $L 0 0]
	foreach dir $dirs {
		set file_name [string tolower $block_name]
		set k [split $dir "/"]
		set dir_name [lindex $k end-1]
		set dir_name [string map {. _} $dir_name]
		append file_name "_$dir_name"
		set dir_name [lindex $k end]
		set dir_name [string map {. _} $dir_name]
		append file_name "_$dir_name"

		#puts $file_name
		foreach st $stage {
			set name $file_name
			append name "_$st"
			#puts $name
			set inp [catch {glob -type {f l} $dir/rpts/$st.placement.rpt }]
			set OUT [open ".csv_reports/${name}_det.csv" w]
			if {$inp==0} {
				set tmp_util [exec grep "std-cell utilization" $dir/rpts/$st.placement.rpt]
                                set k [regexp {[0-9]+.[0-9]+} $tmp_util std_util]
				puts $OUT "<p><b>Standard utilization:</b> $std_util"
				
				
			
			}
			set inp [catch {glob -type {f l} $dir/rpts/$st.congestion.rpt }]
                        if {$inp==0} { 
                              set tmp [exec grep "Hor Overflow" $dir/rpts/${st}.congestion.rpt]
                       	      set k [regexp {([0-9]+[.]*[0-9]*)%} $tmp match H_Oflow]
                              set tmp [exec grep "Ver Overflow" $dir/rpts/${st}.congestion.rpt]
                              set k [regexp {([0-9]+[.]*[0-9]*)%} $tmp match V_Oflow]
			      #puts $OUT "<br><b>Congestion:</b>"
                              puts $OUT "<br><b>H_Overflow:</b> $H_Oflow%"
                              puts $OUT "<br><b>V_Overflow:</b> $V_Oflow%"
		       	}

			if {$st=="route"} {
			set inp [catch {glob -type {f l} $dir/rpts/${st}.drc.rpt }]
                        if {$inp==0} {              
                                if {[catch {exec grep "short" $dir/rpts/${st}.drc.rpt}]==0} {
                                        set tmp [exec grep "short" $dir/rpts/${st}.drc.rpt]
                                        set k [regexp {[0-9]+} $tmp short]
                                        puts $OUT "<br><b>Shorts:</b> $short"
                                } else {
                                        puts $OUT "<br><b>Shorts:</b>0"
                                }
                                if  {[catch {exec grep "Total DRC" $dir/rpts/${st}.drc.rpt}]==0} {
					set tmp [exec grep "Total DRC" $dir/rpts/${st}.drc.rpt]
	                                set k [regexp {[0-9]+} $tmp DRC]
        	                        puts $OUT "<br><b>DRC: </b>$DRC"
				} elseif {[catch {exec grep "Total violations" $dir/rpts/${st}.drc.rpt}]==0} {
					set tmp [exec grep "Total violations" $dir/rpts/${st}.drc.rpt]
	                                set k [regexp {[0-9]+} $tmp DRC]
					if {[catch {exec grep "antenna" $dir/rpts/${st}.drc.rpt}]==0} {
						set tmp  [grep "antenna" $dir/rpts/${st}.drc.rpt]								
						set k [regexp {antenna\s+:\s+(\d+)} $tmp match ANT ]
						set DRC [expr $DRC-$ANT]
					}

        	                        puts $OUT "<br><b>DRC: </b>$DRC"

				}
                                if {[catch {exec grep "Total Antenna" $dir/rpts/${st}.drc.rpt}]==0} {
                                        set tmp [exec grep "Total Antenna" $dir/rpts/${st}.drc.rpt]
                                        set k [regexp {[0-9]+} $tmp ANT]   
                                        puts $OUT "<br><b>ANT: </b>$ANT"
                                } elseif {[catch {exec grep "antenna" $dir/rpts/${st}.drc.rpt}]==0} {
                                        set tmp [exec grep "antenna" $dir/rpts/${st}.drc.rpt]
                                        set k [regexp {[0-9]+} $tmp ANT]   
                                        puts $OUT "<br><b>ANT: </b>$ANT"
				} else {
                                        puts $OUT "<br><b>ANT:</b> 0"
                                }       
                        }
			}
			set latest 0
			set log_inp [catch {glob -type {f l} $dir/log*/$st*.log}]
                        if {$log_inp==0} {
                                        foreach file [glob -type {f l} $dir/log*/$st*.log] {
                                                set m_time [file mtime $file]
                                                if {$m_time > $latest} {
                                                        set latest $m_time
                                                        set log $file
                                                }
                                        }
                                        if {$st=="cts" && [catch {glob -type {f l} $dir/log*/$st.log}]==0} {
                                                set log [glob -type {f l} $dir/log*/$st.log]
                                        }
                                        source /ads/indiatc1/reporting_scripts/html_scripts_v1/runtime.tcl
                                        set run_time [runtime $log $st] 
                                        puts $OUT "<br><b>Runtime:</b> $run_time</p>"
                                
                        }
			if {$st=="cts"} {
				set inp [catch {glob -type f $dir/rpts/$st.skew.rpt }]
				if {$inp==0} {
					#set scn_tmp [exec grep "Scenario" $dir/rpts/cts.skew.rpt]
					#set scn [lindex $scn_tmp 2]	
					set Fout [open ".csv_reports/$name.skew.csv" w]
					#puts "$name.skew.csv"	
					#puts $Fout "CTS Summary for $scn"
					#puts $Fout "Skew Group,Max Latency,Total Skew"
					set FP3 [open "$dir/rpts/cts.skew.rpt" r]
					#set tmp_cts ""
					set Min_latency 0
					set Max_Latency 0
					set Total_Skew 0
					set Avg_Skew 0
					set Skew 0	
					set Sinks 0
					set avg_en [catch {exec grep "AvgSkew" $dir/rpts/cts.skew.rpt}]
					while {[gets $FP3 data]>=0} {
						if {[regexp {Scenario} $data]} {
							set scn1 [lindex $data 2]
						} elseif {[regexp {Skew Group} $data]} {
							set skew_group [lindex $data 3]
							#append tmp_cts "$skew_group"
						} elseif {[regexp {Sink Number} $data] } {
							set k [regexp {[0-9]+} $data sink_num]
						} elseif {[regexp {Max Latency} $data]} {
							set k [regexp {[0-9]+.[0-9]+} $data max_lat]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								#puts "$skew_group,$max_lat"
								set Max_Latency $max_lat
								set dom_scn $scn1
								set main_clk $skew_group
							} elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0 } {
								set dom_scn $scn1
								set Max_Latency $max_lat
								set main_clk $skew_group
							}
							#append tmp_cts ",$max_latency"
						}  elseif {[regexp {Min Latency} $data]} {
							set k [regexp {[0-9]+.[0-9]+} $data min_lat]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								#puts "$skew_group,$Sinks,$sink_num"
								set Min_Latency $min_lat
							} elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0} {
								set Min_Latency $min_lat
							}
						} elseif {[regexp {Total Skew} $data] } {
							set tot_skew [lindex $data 3]
							#set Total_Skew [expr $Total_Skew+$tot_skew]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								set Total_Skew $tot_skew
							} elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0} {
								set Total_Skew $tot_skew
							}

							#append tmp_cts ",$total_skew\n"
						} elseif {[regexp {^ Skew  } $data]} {
							set tmp [regexp {[0-9]+[.]*[0-9]*} $data skew]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								set Skew $skew
								if {$avg_en==1} {
									set Sinks $sink_num
								}
							}  elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0} {
								set Skew $skew
								if {$avg_en==1} {
									set Sinks $sink_num
								}

							}

	
							#set Skew [lindex [lsort -real "$match $Skew"] end]
						} elseif {[regexp {AvgSkew} $data] } {
							#puts $data
							set tmp [regexp {[0-9]+[.]*[0-9]*} $data avg_skew]
							#set Total_Skew [expr $Total_Skew+$tot_skew]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								set Avg_Skew $avg_skew
								set Sinks $sink_num
							} elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0} {
								set Avg_Skew $avg_skew
							}
						}

					}
					
					puts $Fout "<p><b>Dominant Scenario:</b> $dom_scn"
					puts $Fout "<br><b>Skew Group:</b> $main_clk"
					puts $Fout "<br><b>Min Latency:</b> $Min_Latency"
					puts $Fout "<br><b>Max Latency:</b> $Max_Latency"	
					puts $Fout "<br><b>Skew:</b> $Skew"
					if {$avg_en==0} {
						puts $Fout "<br><b>Avg Skew:</b> $Avg_Skew"
					}
					#puts $Fout "<br><b>Total Skew:</b> $Total_Skew</p>"
					close $Fout	
					
				} 
			}
				

							                                      
		close $OUT
		}		
	}
	
}
close $FP
}
