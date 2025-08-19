proc summary_csv {f_name scn sg} {
set FP [open "$f_name" r]
if {[file isdirectory .csv_reports]==0} {
	exec mkdir .csv_reports
} else {
	catch { exec rm -rf .csv_reports }
	catch {exec mkdir .csv_reports }
}
set list_setup {design_stp_wns design_stp_tns design_stp_nop RR_stp_wns RR_stp_tns RR_stp_nop CG_stp_wns CG_stp_tns CG_stp_nop IG_stp_wns IG_stp_tns IG_stp_nop}
set list_hold {design_hold_wns design_hold_tns design_hold_nop RR_hold_wns RR_hold_tns RR_hold_nop CG_hold_wns CG_hold_tns CG_hold_nop IG_hold_wns IG_hold_tns IG_hold_nop}
set list_power_drv {leakage_power toggling_power internal_power total_power max_tran_cost max_tran_vios max_cap_cost max_cap_vios}
set list_area {std_cell_area combo_cell_area flip-flop_area inv_area buf_area ICG_cell_area }
set list_cells {std_cells flip-flop_cells buffer_cells inverter_cells ICG_cells standard_utilization}
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
		set tot_runtime 0
		set file_name [string tolower $block_name]
		set k [split $dir "/"]
		set dir_name [lindex $k end-1]
		append file_name "_" [string map {. _} $dir_name]
		set dir_name [lindex $k end]
		set dir_name [string map {. _} $dir_name]

		append file_name "_$dir_name"
		#puts $file_name
		foreach st $stage {
			set name $file_name
			append name "_$st"
			#puts $name
			set OUT [open ".csv_reports/$name.csv" w]
			set inp [catch {glob -type f $dir/rpts/$st.timing.summary }]
			if {$inp==0} {
				#append name "_$st"
				set Fs [open ".csv_reports/$name.setup.csv" w]
				set Fh [open ".csv_reports/$name.hold.csv" w]	
				#puts $Fout "Timing Summary"
				#puts $Fout "Metrics,,Setup,,,Hold,,"
				#puts $Fout "Pathgroup,WNS,TNS,NOP,WNS,TNS,NOP"
				set timing 0
				while {$timing<=1} {
					#puts "$timing"
					set FP1 [open "$dir/rpts/$st.timing.summary" r]
        				while {[gets $FP1 data1]>=0} {

						set tmp_all [catch {exec egrep "ALL|COMBINED" $dir/rpts/$st.timing.summary}]
						if {$tmp_all==0} {
							set reg_all {ALL|COMBINED}
						} else {		
							set reg_all "WNS"
						}
			                	if {[regexp $reg_all $data1 match] && [regexp {WNS} $data1] && ![regexp {Scan} $data1]} {
							#puts $match
                        				#puts "data;$data"
                        				set data1 [string map {[ " " ] " " } $data1 ]
							set tmp1 [regexp {WNS[ ]*[-]*[0-9]*[.]*[0-9]*[ ]*:[ ]*[-]*[0-9]*[.]*[0-9]*} $data1 wns_match]
							set wns_match [string map {: " " } $wns_match]
							#puts $wns_match
                        				set setup_wns [lindex $wns_match 1]
                        				set hold_wns [lindex $wns_match 2]
							set tmp1 [regexp {TNS[ ]*[-]*[0-9]*[.]*[0-9]*[ ]*:[ ]*[-]*[0-9]*[.][0-9]*} $data1 tns_match]
							set tns_match [string map {: " " } $tns_match]
							#puts $tns_match
			                       		set setup_tns [lindex $tns_match 1]
                        				set hold_tns [lindex $tns_match 2]
                        				
			                        	set setup_nop "NA"
                        				set hold_nop "NA"
			                        	set pathgrp "design"
        	                			if {[regexp {[A-Z]+WNS} $data1]} {
			                                	set tmp1 [regexp {FEP[ ]*[0-9]*[ ]*:[ ]*[0-9]*} $data1 nop_match]
								set nop_match [string map {: " " } $nop_match]
								#puts $nop_match
			                                	set setup_nop [lindex $nop_match 1]
                		                		set hold_nop [lindex $nop_match 2]
								#puts "$setup_nop,$hold_nop"
                                				set k [regexp {([A-Z]+)WNS} $data1 match pathgrp]	
                	        			}
							set tmp ""
							if {$timing==0} {
								if {$setup_wns!="-"} {
									append tmp $pathgrp "_stp_wns,[format "%.3f" $setup_wns]\n"
								} else { 
									append tmp $pathgrp "_stp_wns,$setup_wns\n"
								}
								if {$setup_tns!="-"} {
									append tmp $pathgrp "_stp_tns,[format "%.3f" $setup_tns]\n"
								} else {
									append tmp $pathgrp "_stp_tns,$setup_tns\n"	
								}
								append tmp $pathgrp "_stp_nop,$setup_nop"
								puts $Fs $tmp
								puts $OUT $tmp
							} else {
								if {$hold_wns!="-"} {
									append tmp $pathgrp "_hold_wns,[format "%.3f" $hold_wns]\n"
								} else { 
									append tmp $pathgrp "_hold_wns,$hold_wns\n"
								}
								if {$hold_tns!="-"} {
									append tmp $pathgrp "_hold_tns,[format "%.3f" $hold_tns]\n"
								} else {
									append tmp $pathgrp "_hold_tns,$hold_tns\n"	
								}
								append tmp $pathgrp "_hold_nop,$hold_nop"
								puts $Fh $tmp
								puts $OUT $tmp
							}

                        				#puts $Fout "$pathgrp,$setup_wns,$setup_tns,$setup_nop,$hold_wns,$hold_tns,$hold_nop"
                        		
        
                				}
        				}
					close $FP1
					incr timing
				}
				close $Fs
				close $Fh
			} else {
				set Fs [open ".csv_reports/$name.setup.csv" w]
				set Fh [open ".csv_reports/$name.hold.csv" w]
				foreach elem $list_setup {
					puts $Fs "$elem,NA"
					puts $OUT "$elem,NA"
				}


				foreach elem $list_hold {
					puts $Fh "$elem,NA"
					puts $OUT "$elem,NA"
				}
				close $Fs
				close $Fh
					
			}
			
			set inp [catch {glob -type f $dir/rpts/$st.power.rpt }]
			if {$inp==0} {
				set Fout [open ".csv_reports/$name.power_drv.csv" w]
				set FP2 [open "$dir/rpts/$st.power.rpt" r]
				#puts $Fout "Power Summary"
				#puts $Fout "lekage_power,toggling_power,internal_power,total_power"
        			while {[gets $FP2 data]>=0} {
					if {[regexp {Scenario} $data] && [lindex $data 3]!=""} {		
						if {[regexp "$scn" $data]} {
							set my_scn $scn
						} else {
							set my_scn ""
						}
					} elseif {[regexp {Sum} $data] && $my_scn==$scn} {
                       				 set leakage_power [lindex $data 2]
                  				 set toggling_power [lindex $data 3]
                  			     	 set internal_power [lindex $data 4]
                       				 set total_power [lindex $data 6]

                			}
       				 }
				#puts $Fout [join [format "%.2f %.2f %.2f %.2f" $lekage_power $toggling_power $internal_power $total_power] ","]
				puts $Fout "leakage_power,[format "%.2f" $leakage_power]"
				puts $OUT "leakage_power,[format "%.2f" $leakage_power]"
       				puts $Fout "toggling_power,[format "%.2f" $toggling_power]"
				puts $OUT "toggling_power,[format "%.2f" $toggling_power]"
			        puts $Fout "internal_power,[format "%.2f" $internal_power]"
				puts $OUT "internal_power,[format "%.2f" $internal_power]"
				puts $Fout "total_power,[format "%.2f" $total_power]"
			        puts $OUT "total_power,[format "%.2f" $total_power]"
				close $FP2
				#puts $Fout "\n"
				#puts $Fout "DRV Summary"
				set inp [catch {glob -type f $dir/rpts/$st.drv.rpt }]
				set inp1 [catch {glob -type f $dir/rpts/$st.drv.rpt.$scn }]
				if {$inp==0 || $inp1==0} {
					if {$inp==0} {
			  	      		set TRAN [split [exec egrep " max_transition|Scenario" $dir/rpts/$st.drv.rpt] "\n"]
				        	set CAP [split [exec egrep "Scenario| max_capacitance" $dir/rpts/$st.drv.rpt] "\n"] 
						
					} else {
			  	      		set TRAN [split [exec egrep " max_transition|Scenario" $dir/rpts/$st.drv.rpt.$scn] "\n"]
				        	set CAP [split [exec egrep "Scenario| max_capacitance" $dir/rpts/$st.drv.rpt.$scn] "\n"] 
						
					}
					#puts $Fout "DRV type,Violations"
				        foreach t $TRAN {
						if {[regexp "Scenario" $t]} {
							set my_scn [lindex $t 2]
						} 
						if {[regexp "max_transition" $t] && $my_scn==$scn} {
					        	set tran_cost [lindex $t 2]
						        set tran_violations [lindex $t 4]
						}

				        }
					puts $Fout "max_tran_cost,$tran_cost"
					puts $OUT "max_tran_cost,$tran_cost"
        				puts $Fout "max_tran_vios,$tran_violations"
					puts $OUT "max_tran_vios,$tran_violations"
				        foreach t $CAP {
						if {[regexp "Scenario" $t]} {
							set my_scn [lindex $t 2]
						}
						if {[regexp "max_capacitance" $t] && $my_scn==$scn} {
					        	set cap_cost [lindex $t 2]
						        set cap_violations [lindex $t 4]
						}
			      	  	}
					puts $Fout "max_cap_cost,$cap_cost"
					puts $OUT "max_cap_cost,$cap_cost"
				        puts $Fout "max_cap_vios,$cap_violations"
					puts $OUT "max_cap_vios,$cap_violations"
				} else {
					puts $Fout "max_tran_cost,NA"
					puts $OUT "max_tran_cost,NA"
        				puts $Fout "max_tran_vios,NA"
					puts $OUT "max_tran_vios,NA"		
					puts $Fout "max_cap_cost,NA"
					puts $OUT "max_cap_cost,NA"
				        puts $Fout "max_cap_vios,NA"
					puts $OUT "max_cap_vios,NA"
				}
				close $Fout
			} else {
				set Fout [open ".csv_reports/$name.power_drv.csv" w]
				foreach elem $list_power_drv {
					puts $Fout "$elem,NA"
					puts $OUT "$elem,NA"
				}
				
				close $Fout
			}
			if {$st!="place"} {
				set inp [catch {glob -type {f l} $dir/rpts/$st.designrules.rpt }]
				set inp1 [catch {glob -type {f l} $dir/rpts/$st.clockdrv.full.rpt}]
				set inp2 [catch {glob -type {f l} $dir/rpts/$st.designrules.rpt.$scn }]
				set inp3  [catch {glob -type {f l} $dir/rpts/$st.clockdrv.full.rpt.$scn }]
				set Fout [open ".csv_reports/$name.power_drv.csv" a]	
				if {($inp==0 && $inp1==0) || ($inp2==0 && $inp3==0)} {
					if {$inp==0} {
						set F_read [open "$dir/rpts/$st.designrules.rpt" r]
					} else {
						set F_read [open "$dir/rpts/$st.designrules.rpt.$scn" r]
					}
					while {[gets $F_read data]>=0} {
						if {[regexp {Scenario} $data]} {
							if {[regexp "$scn" $data]} {
								set my_scn $scn
							} else {
								set my_scn ""
							}
						
						} elseif {[regexp {Max Transition} $data] && $my_scn==$scn} {
							set k [regexp {[0-9]+[.]*[0-9]*} $data match]
							set tot_clk_tran $match
						} elseif {[regexp {Max Capacitance} $data] && $my_scn==$scn} {
							set k [regexp {[0-9]+[.]*[0-9]*} $data match]
							set tot_clk_cap $match
						} elseif {[regexp {Max Fanout Count} $data] && $my_scn==$scn} {
							set k [regexp {[0-9]+[.]*[0-9]*} $data match]
							set tot_clk_fanout $match
						}
					}
					close $F_read
					if {$inp1==0} {
						set F_read [open "$dir/rpts/$st.clockdrv.full.rpt" r]
					} else {
						set F_read [open "$dir/rpts/$st.clockdrv.full.rpt.$scn" r]

					}
					set en_tran 0
					set en_cap 0
					set en_fanout 0
					set max_tran 0 
					set max_cap 0
					set max_fanout 0
					while {[gets $F_read data]>=0} {
						if {[regexp {Scenario} $data]} {
							if {[regexp "$scn" $data]} {
								set my_scn $scn
							} else {
								set my_scn ""
							}
						}
						if {[regexp {max_transition} $data]} {
							set en_tran 1
							set en_cap 0
							set en_fanout 0
						}
						if {[regexp {max_capacitance} $data]} {
							set en_tran 0
							set en_cap 1
							set en_fanout 0
						}
						if {[regexp {max_fanout} $data]} {
							set en_tran 0
							set en_cap 0
							set en_fanout 1
						}
						if {$en_tran==1 && [regexp {[-][0-9]+[.]*[0-9]*} $data] && $my_scn==$scn} {
							set en [regexp {[-]+[0-9]+[.]*[0-9]*} $data match]	
							set max_tran $match
							set en_tran 0
						} elseif {$en_cap==1 && [regexp {[-][0-9]+[.]*[0-9]*} $data] && $my_scn==$scn} {
							set en [regexp {[-]+[0-9]+[.]*[0-9]*} $data match]	
							set max_cap $match
							set en_cap 0
						} elseif {$en_fanout==1 && [regexp {[-][0-9]+[.]*[0-9]*} $data] && $my_scn==$scn} {
							set en [regexp {[-]+[0-9]+[.]*[0-9]*} $data match]	
							set max_fanout $match
							set en_fanout 0
						}

					}
					close $F_read
			
					puts $OUT "tot_clk_tran/max_tran_vio,$tot_clk_tran/$max_tran"
					puts $OUT "tot_clk_cap/max_cap_vio,$tot_clk_cap/$max_cap"
					puts $OUT "tot_clk_fanout/max_fanout_vio,$tot_clk_fanout/$max_fanout"
					puts $Fout "tot_clk_tran/max_tran_vio,$tot_clk_tran/$max_tran"
					puts $Fout "tot_clk_cap/max_cap_vio,$tot_clk_cap/$max_cap"
					puts $Fout "tot_clk_fanout/max_fanout_vio,$tot_clk_fanout/$max_fanout"
					close $Fout
				} elseif {($inp==0 && $inp1==1) || ($inp2==0 && $inp3==1)} {
					if  {$inp==0} {
						set F_read [open "$dir/rpts/$st.designrules.rpt" r]
					} else {
						set F_read [open "$dir/rpts/$st.designrules.rpt.$scn" r]

					}
                                        while {[gets $F_read data]>=0} {
                                                if {[regexp {Scenario} $data]} {
                                                        if {[regexp "$scn" $data]} {
                                                                set my_scn $scn
                                                        } else {
                                                                set my_scn ""
                                                        }
                                                
                                                } elseif {[regexp {Max Transition} $data] && $my_scn==$scn} {
                                                        set k [regexp {[0-9]+[.]*[0-9]*} $data match]
                                                        set tot_clk_tran $match
                                                } elseif {[regexp {Max Capacitance} $data] && $my_scn==$scn} {
                                                        set k [regexp {[0-9]+[.]*[0-9]*} $data match]
                                                        set tot_clk_cap $match
                                                } elseif {[regexp {Max Fanout Count} $data] && $my_scn==$scn} {
							 set k [regexp {[0-9]+[.]*[0-9]*} $data match]
                                                        set tot_clk_fanout $match
                                                }
                                        }
                                        close $F_read
                                        puts $OUT "tot_clk_tran/max_tran,$tot_clk_tran/NA"
                                        puts $OUT "tot_clk_cap/max_cap,$tot_clk_cap/NA"
                                        puts $OUT "tot_clk_fanout/max_fanout,$tot_clk_fanout/NA"
                                        puts $Fout "tot_clk_tran/max_tran,$tot_clk_tran/NA"
                                        puts $Fout "tot_clk_cap/max_cap,$tot_clk_cap/NA"
                                        puts $Fout "tot_clk_fanout/max_fanout,$tot_clk_fanout/NA"
                                        close $Fout
					
				} else {
					puts $OUT "tot_clk_tran/max_tran,NA"
					puts $OUT "tot_clk_cap/max_cap,NA"
					puts $OUT "tot_clk_fanout/max_fanout,NA"
					puts $Fout "tot_clk_tran/max_tran,NA"
					puts $Fout "tot_clk_cap/max_cap,NA"
					puts $Fout "tot_clk_fanout/max_fanout,NA"
					close $Fout	
				}	
			}
			if {$st=="cts"} {
				set inp [catch {glob -type f $dir/rpts/$st.skew.rpt }]
				set inp1 [catch {glob -type f $dir/rpts/$st.skew.rpt.$scn }]

				if {$inp==0 || $inp1==0} {
					#set scn_tmp [exec grep "Scenario" $dir/rpts/cts.skew.rpt]
					#set scn [lindex $scn_tmp 2]	
					set Fout [open ".csv_reports/$name.miscellaneous.csv" w]	
					#puts $Fout "CTS Summary for $scn"
					#puts $Fout "Skew Group,Max Latency,Total Skew"
					if {$inp==0} {
						set FP3 [open "$dir/rpts/cts.skew.rpt" r]
					} else {
						set FP3 [open "$dir/rpts/cts.skew.rpt.$scn" r]
					}
					#set tmp_cts ""
					set Min_latency 0
					set Max_Latency 0
					set Total_Skew 0
					set Avg_Skew 0
					set Skew 0	
					set Sinks 0
					if {$sg=="-"} { 
					while {[gets $FP3 data]>=0} {
						if {[regexp {Scenario} $data]} {
							set scn1 [lindex $data 2]
						} elseif {[regexp {Skew Group} $data] && $scn1==$scn} {
							set skew_group [lindex $data 3]
							#append tmp_cts "$skew_group"
						} elseif {[regexp {Sink Number} $data] && $scn1==$scn } {
							set k [regexp {[0-9]+} $data sink_num]
							#puts "$skew_group,$sink_num"
						} elseif {[regexp {Max Latency} $data] && $scn1==$scn} {
							set k [regexp {[0-9]+.[0-9]+} $data max_lat]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								#puts "$skew_group,$max_lat"
								set Max_Latency $max_lat
								set sg "$skew_group"
								#puts "$max_lat,$Sinks"
							} elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0 } {
								set Max_Latency $max_lat
								set sg "$skew_group"								
								#puts "$max_lat"
							}
							#append tmp_cts ",$max_latency"
						}  elseif {[regexp {Min Latency} $data] && $scn1==$scn} {
							set k [regexp {[0-9]+.[0-9]+} $data min_lat]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								#puts "$skew_group,$Sinks,$sink_num"
								set Min_Latency $min_lat
							} elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0} {
								set Min_Latency $min_lat
							}
						} elseif {[regexp {Total Skew} $data] && $scn1==$scn} {
							set tot_skew [lindex $data 3]
							#set Total_Skew [expr $Total_Skew+$tot_skew]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								set Total_Skew $tot_skew
							} elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0} {
								set Total_Skew $tot_skew
							}

							#append tmp_cts ",$total_skew\n"
						} elseif {[regexp {^ Skew  } $data] && $scn1==$scn} {
							set tmp [regexp {[0-9]+[.]*[0-9]*} $data skew]
							if {$Sinks<$sink_num && [regexp {scan_clk} $skew_group]==0} {
								set Skew $skew
							}  elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0} {
								set Skew $skew
							}

	
							#set Skew [lindex [lsort -real "$match $Skew"] end]
						} elseif {[regexp {AvgSkew} $data] && $scn1==$scn} {
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
					} else {
						while {[gets $FP3 data]>=0} {
						if {[regexp {Scenario} $data]} {
                                                        set scn1 [lindex $data 2]
                                                } elseif {[regexp {Skew Group} $data] && $scn1==$scn} {
                                                        set skew_group [lindex $data 3]
                                                        #append tmp_cts "$skew_group"
                                                } elseif {[regexp {Max Latency} $data] && $scn1==$scn && $skew_group==$sg} {
                                                        set k [regexp {[0-9]+.[0-9]+} $data max_lat]
							set Max_Latency $max_lat
 						} elseif {[regexp {Min Latency} $data] && $scn1==$scn && $skew_group==$sg} {
                                                        set k [regexp {[0-9]+.[0-9]+} $data min_lat]
							set Min_Latency $min_lat
						} elseif {[regexp {Total Skew} $data] && $scn1==$scn && $skew_group==$sg} {
                                                        set Total_Skew [lindex $data 3]
	
						} elseif {[regexp {^ Skew  } $data] && $scn1==$scn && $skew_group==$sg} {
                                                        set tmp [regexp {[0-9]+[.]*[0-9]*} $data skew]
							set Skew $skew
						} elseif {[regexp {AvgSkew} $data] && $scn1==$scn && $skew_group==$sg} {
                                                        #puts $data
                                                        set tmp [regexp {[0-9]+[.]*[0-9]*} $data avg_skew]
							set Avg_Skew $avg_skew
						}
								
							
						}
					}
					set d1 [catch {glob -type f $dir/rpts/$st.designrules.rpt }]
					if {$Max_Latency!=0 && $Total_Skew==0} {
						if {$d1==0} {
							if {[catch {exec egrep "$sg|$scn|Total Skew" $dir/rpts/$st.designrules.rpt }] == 0} {
								set data [exec egrep "$sg|$scn|Total Skew" $dir/rpts/$st.designrules.rpt | grep -v "Source Pin" | tr '\n' ','  ]
								set k [regexp "Scenario *: *$scn, *Skew Group *: *$sg, *Total Skew *: *[0-9]+.[0-9]+" $data match]
								if {$k==1} {
									set tmp [regexp {[0-9]+[.]+[0-9]+} $match tot_skew]
									set Total_Skew $tot_skew
								}
								
							}
						}
					}				
					puts $Fout "Min_Latency,$Min_Latency"
					puts $OUT "Min_Latency,$Min_Latency"
					puts $Fout "Max_Latency,$Max_Latency"
					puts $OUT "Max_Latency,$Max_Latency"	
					puts $Fout "Skew,$Skew"
					puts $OUT "Skew,$Skew"
					puts $Fout "Avg_Skew,$Avg_Skew"
					puts $OUT "Avg_Skew,$Avg_Skew"
					puts $Fout "Total_skew,$Total_Skew"
					puts $OUT "Total_skew,$Total_Skew"
					close $Fout
	
					
				} else  {
					set Fout [open ".csv_reports/$name.miscellaneous.csv" w]
					foreach elem $list_cts {
						puts $Fout "$elem,NA"
						puts $OUT "$elem,NA"
					}
					close $Fout
				}
			}
				
			set inp [catch {glob -type {f l} $dir/rpts/$st.placement.rpt }]
			if {$inp==0} {
				set Fout [open ".csv_reports/$name.cell_areas.csv" w]			
				set vars [split "std cell area,combo cell area,flip-flop cell area,buf cell area,inv cell area,ICG cell area" ","]
				foreach var $vars {
					#puts $var
					if {[catch {exec grep "$var" $dir/rpts/$st.placement.rpt}]==0} {
						set tmp_area [exec grep "$var" $dir/rpts/$st.placement.rpt]
						set k [regexp {[0-9]+} $tmp_area area]
					} else {
						set area 0
					}
					set var [string map {" " _} $var]
					puts $Fout "$var,$area"
					puts $OUT "$var,$area"
				}
				close $Fout
				set Fout [open ".csv_reports/$name.cell_count.csv" w]
				set vars [split "std cells,flip-flop cells,buffer cells,inverter cells,ICG cells" ","]
				foreach var $vars {
					#puts $var
					if {[catch {exec grep "$var" $dir/rpts/$st.placement.rpt}]==0} {
						set tmp_cells [exec grep "$var" $dir/rpts/$st.placement.rpt]
						set k [regexp {[0-9]+} $tmp_cells count]
					} else {
						set count 0
					}
					puts $Fout  "[join $var "_"],$count"
					puts $OUT "[join $var "_"],$count"
				}
				
				set tmp_util [exec grep "std-cell utilization" $dir/rpts/$st.placement.rpt]
				set k [regexp {[0-9]+.[0-9]+} $tmp_util std_util]
				#puts $Fout "Standard cell area,$std_area"
				#puts $Fout "Standard cells,$std_cells"
				puts $Fout "standard_utilization,$std_util"
				puts $OUT "standard_utilization,$std_util"
				close $Fout
			} else {
				set Fout [open ".csv_reports/$name.cell_areas.csv" w]
				foreach elem $list_area {
					puts $Fout "$elem,NA"
					puts $OUT "$elem,NA"
				}
				close $Fout
				set Fout [open ".csv_reports/$name.cell_count.csv" w]
				foreach elem $list_cells {
					if {$st=="place" || $st=="cts" } {
						if {$elem!="hold_cells"} {
						puts $Fout "$elem,NA"
						puts $OUT "$elem,NA"
						}
					} else {
							puts $Fout "$elem,NA" 
							puts $OUT "$elem,NA"
					}
				}
				close $Fout
			}
		        
			if {$st!="cts"} {
					set Fout [open ".csv_reports/$name.miscellaneous.csv" w]
					
					if {$st=="cts_opt" || $st=="place"} {
						set inp [catch {glob -type {f l} $dir/rpts/$st.tmr.rpt }]
						if {$inp==0} {
							if {[file size $dir/rpts/$st.tmr.rpt]==0} {
								set TMR 0
							} else {
								set tmp_TMR [exec grep "Total" $dir/rpts/$st.tmr.rpt]
								set k [regexp {[0-9]+} $tmp_TMR TMR]		
							}

						puts $Fout  "TMR,$TMR"
						puts $OUT "TMR,$TMR"
						} else {
							puts $Fout "TMR,NA"
							puts $OUT "TMR,NA"
						}
					}
					if {$st=="place"} {
						set inp [catch {glob -type {f l} $dir/rpts/$st.mbit_cell.rpt}]
						if {$inp==0} {
							set tmp [exec grep "mbit_conv" $dir/rpts/$st.mbit_cell.rpt]
							set k [regexp {[-]*[0-9]+[.]*[0-9]*$} $tmp mbit_conv]
							puts $Fout "Mbit_Conv,$mbit_conv"
							puts $OUT "Mbit_Conv,$mbit_conv"

						} else {
							puts $Fout "Mbit_Conv,NA"
							puts $OUT "Mbit_Conv,NA"

						}
						set inp [catch {glob -type {f l} $dir/rpts/$st.push_pull.rpt }]
						if {$inp==0} {
							set tmp_push [exec grep "FF Push" $dir/rpts/$st.push_pull.rpt]
							set k [regexp {[0-9]+} $tmp_push FF_push] 
							set tmp_pull [exec grep "FF Pull" $dir/rpts/$st.push_pull.rpt]
							set k [regexp {[0-9]+} $tmp_pull FF_pull]
							set k [regexp {[-]*[0-9]+[.]*[0-9]*$} $tmp_pull FF_pull_avg]
							puts $Fout "FF_Push/Pull,$FF_push/$FF_pull"
							puts $OUT "FF_Push/Pull,$FF_push/$FF_pull"
							puts $Fout "FF_pull_avg,$FF_pull_avg"
							puts $OUT "FF_pull_avg,$FF_pull_avg"
						} else {		
							puts $Fout "FF_Push/Pull,NA"
							puts $OUT "FF_Push/Pull,NA"
							puts $Fout "FF_pull_avg,NA"
							puts $OUT "FF_pull_avg,NA"

						}
					}
					set inp [catch {glob -type {f l} $dir/rpts/$st.congestion.rpt }]
					if {$inp==0 } { 
						set tmp [exec grep "Hor Overflow" $dir/rpts/${st}.congestion.rpt]
						set k [regexp {([0-9]+[.]*[0-9]*)%} $tmp match H_Oflow]
						set tmp [exec grep "Ver Overflow" $dir/rpts/${st}.congestion.rpt]
						set k [regexp {([0-9]+[.]*[0-9]*)%} $tmp match V_Oflow]
						puts $Fout "H/V_Overflow,$H_Oflow/$V_Oflow"
						puts $OUT "H/V_Overflow,$H_Oflow/$V_Oflow"
					} else {
						puts $Fout "H/V_Overflow,NA"
						puts $OUT "H/V_Overflow,NA"
					}
					set inp [catch {glob -type {f l} $dir/rpts/${st}.placement.rpt }]
					if {$inp==0} {
						if {[catch {exec grep "wire_length" $dir/rpts/$st.info.rpt}]==0} {
							set tmp_WL [exec grep "wire_length" $dir/rpts/$st.info.rpt]
							set k [regexp {[0-9]+[.]*[0-9]*} $tmp_WL WL] 
						} else {
							set tmp_WL [exec grep "total" $dir/rpts/${st}.placement.rpt | grep steiner]
							set k [regexp {[0-9]+[.]*[0-9]*} $tmp_WL WL]
						}
						puts $Fout "Wirelength,$WL"
						puts $OUT "Wirelength,$WL"
					} else {
						puts $Fout "Wirelength,NA"
						puts $OUT "Wirelength,NA"
					}
					if {$st=="route"} {
						#set inp [catch {glob -type {f l} $dir/rpts/${st}.info.rpt}]
						#if {$inp==0} {
						#	set tmp [exec grep "via_count" $dir/rpts/${st}.info.rpt]
						#	set k [regexp {[0-9]+} $tmp via_count]
						#	puts $Fout "Totalvias,$via_count"
						#} else {
						#	puts $Fout "Totalvias,NA"
						#}
						set inp [catch {glob -type {f l} $dir/rpts/${st}.via.rpt }]
						if {$inp==0} {
							set f_via [open $dir/rpts/${st}.via.rpt ]
							set via_en 0
							while {[gets $f_via data]>=0} {
								if {![regexp "route_type" $data] && [regexp "Summary for all vias" $data] } {
									set via_en 1
								}
								if {[regexp {^\s+[0-9]+\.[0-9]+%} $data] && $via_en==1} {
									set vias [lindex $data end]
								}

							}
							close $f_via
						}
						set inp [catch {glob -type {f l} $dir/rpts/${st}.drc.rpt }]
						if {$inp==0} {
							if {[catch {exec grep "via_count" $dir/rpts/$st.info.rpt}]==0} {
								set tmp [exec grep "via_count" $dir/rpts/$st.info.rpt]
								set k [regexp {[0-9]+} $tmp vias] 
							} elseif {[catch {exec grep "Total via count" $dir/rpts/$st.drc.rpt}]==0} {
								set tmp [exec grep "Total via count" $dir/rpts/${st}.drc.rpt]
								set k [regexp {[0-9]+$} $tmp vias]
							}
							puts $Fout "Totalvias,$vias"
							puts $OUT "Totalvias,$vias"
		
							if {[catch {exec grep "short" $dir/rpts/${st}.drc.rpt}]==0} {
								set tmp [exec grep "short" $dir/rpts/${st}.drc.rpt]
								set k [regexp {[0-9]+} $tmp short]
								puts $Fout "Shorts,$short"
								puts $OUT "Shorts,$short"
							} else {
								puts $Fout "Shorts,0"
								puts $OUT "Shorts,0"
							}
							if {[catch {exec grep ": Total DRC" $dir/rpts/${st}.drc.rpt}]==0 } {
								set tmp  [grep ": Total DRC" $dir/rpts/${st}.drc.rpt]
								set k [regexp {[0-9]+} $tmp DRC]
								puts $Fout "DRC,$DRC"
								puts $OUT "DRC,$DRC"
							} elseif {[catch {exec grep "Total violations :" $dir/rpts/${st}.drc.rpt}]==0} {
								set tmp  [grep "Total violations" $dir/rpts/${st}.drc.rpt]								
								set k [regexp {Total violations\s+:\s+(\d+)} $tmp match DRC ]
								if {[catch {exec grep "antenna" $dir/rpts/${st}.drc.rpt}]==0} {
									set tmp  [grep "antenna" $dir/rpts/${st}.drc.rpt]								
									set k [regexp {antenna\s+:\s+(\d+)} $tmp match ANT ]
									set DRC [expr $DRC-$ANT]
								}
								puts $Fout "DRC,$DRC"
								puts $OUT "DRC,$DRC"
							}
							if {[catch {exec grep ": Total Antenna" $dir/rpts/${st}.drc.rpt}]==0} {
								set tmp [exec grep ": Total Antenna" $dir/rpts/${st}.drc.rpt]
								set k [regexp {[0-9]+} $tmp ANT]
								puts $Fout "ANT,$ANT"	
								puts $OUT "ANT,$ANT"
							} elseif {[catch {exec grep "antenna" $dir/rpts/${st}.drc.rpt}]==0} {
								set tmp [exec grep "antenna" $dir/rpts/${st}.drc.rpt]
								set k [regexp {[0-9]+} $tmp ANT]
								puts $Fout "ANT,$ANT"	
								puts $OUT "ANT,$ANT"
							} else {
								puts $Fout "ANT,0"
								puts $OUT "ANT,0"
							}	
						} else {
							puts $Fout "Totalvias,NA"
							puts $OUT "Totalvias,NA"
							puts $Fout "Shorts,NA"
							puts $OUT  "Shorts,NA"
							puts $Fout "DRC,NA" 
							puts $OUT "DRC,NA"
							puts $Fout "ANT,NA"
							puts $OUT "ANT,NA"
						}
					}
					close $Fout
				}
				set inp [catch {glob -type {f l} $dir/rpts/$st.clkcells.rpt}]
				set Fout [open ".csv_reports/$name.miscellaneous.csv" a]
				if {$inp==0 && $st!= "place"} {
					set clk_check [catch {exec grep "Clock Buf+Inv Cells" $dir/rpts/$st.clkcells.rpt  }	] 

					if {$clk_check==0} {
						set K [exec grep "Clock Buf+Inv Cells :" $dir/rpts/$st.clkcells.rpt]
						set tmp [regexp {[0-9]+} $K match]
						puts $OUT "clock_buf+inv,$match"
                                                puts $Fout "clock_buf+inv,$match"
						set K [exec grep "Clock Buf+Inv Cells area" $dir/rpts/$st.clkcells.rpt]
						set tmp [regexp {[0-9]+[.]*[0-9]*} $K match]							
						puts $OUT "clock_buf+inv_area,$match"
                                                puts $Fout "clock_buf+inv_area,$match"

					} elseif {[catch {exec egrep "Clock Cells :" $dir/rpts/$st.clkcells.rpt}]==0} {
						set K [exec egrep "Clock Cells :" $dir/rpts/$st.clkcells.rpt]							
						set tmp [regexp {[0-9]+} $K match]
						puts $OUT "clock_buf+inv,$match"
                                                puts $Fout "clock_buf+inv,$match"
						set K [exec egrep "Clock Cells area" $dir/rpts/$st.clkcells.rpt]												
						set tmp [regexp {[0-9]+[.]*[0-9]*} $K match]							
						puts $OUT "clock_buf+inv_area,$match"
                                                puts $Fout "clock_buf+inv_area,$match"

					}
				set Fclk [open "$dir/rpts/$st.clkcells.rpt" r]
                                while {[gets $Fclk data]>=0} {
                                        if {[regexp "Clock Buffers :" $data]} {
                                                set k [regexp {[0-9]+} $data match]
                                                puts $OUT "clock_buffers,$match"
                                                puts $Fout "clock_buffers,$match"
                                        } elseif {[regexp "Clock Inverters:" $data]} {
                                                set k [regexp {[0-9]+} $data match]
                                                puts $OUT "clock_inverters,$match"
                                                puts $Fout "clock_inverters,$match"
                                        } elseif {[regexp "Clock Logic:" $data]} {
                                                set k [regexp {[0-9]+} $data match]
                                                puts $OUT "clock_logic,$match"
                                                puts $Fout "clock_logic,$match"
                                        } elseif {[regexp "Clock ICG:" $data]} {
                                                set k [regexp {[0-9]+} $data match]
                                                puts $OUT "clock_ICG,$match"
                                                puts $Fout "clock_ICG,$match"
                                        }
                                }
				set icg_check [catch {exec egrep "Clock Logic:" $dir/rpts/$st.clkcells.rpt} ]
				if {$icg_check==1} {
					puts "$dir/rpts/$st.clkcells.rpt"
					puts $OUT "clock_logic,NA"
                                        puts $Fout "clock_logic,NA"
					puts $OUT "clock_ICG,NA"
                                        puts $Fout "clock_ICG,NA"

				}
				if {$st=="cts_opt"||$st=="route"} {
					set hld_check [catch {exec egrep "Hold Cells" $dir/rpts/$st.hldcells.rpt  }	] 
					if {$hld_check==0} {
						set K [exec egrep "Hold Cells" $dir/rpts/$st.hldcells.rpt]
						set tmp [regexp {[0-9]+} $K match]
						puts $OUT "hold_cells,$match"
                                                puts $Fout "hold_cells,$match"

					} else {
						puts $OUT "hold_cells,NA"
                                                puts $Fout "hold_cells,NA"

					}
				}
		                close $Fclk
				close $Fout
				} elseif {$st!="place"} {
					puts $OUT "clock_cells,NA"
					puts $OUT "clock_cells_area,NA"
					puts $OUT "clock_buffers,NA"
					puts $OUT "clock_inverters,NA"
					puts $OUT "clock_logic,NA"
					puts $OUT "clock_ICG,NA"

					puts $Fout "clock_cells,NA"
					puts $Fout "clock_cells_area,NA"
					puts $Fout "clock_buffers,NA"
					puts $Fout "clock_inverters,NA"
					puts $Fout "clock_logic,NA"
					puts $Fout "clock_ICG,NA"
					
					if {$st=="cts_opt" || $st=="route"} {
						puts $OUT "hold_cells,NA"
                                     	   	puts $Fout "hold_cells,NA"
					}
					close $Fout
				}
						
				
				set latest 0
				set Fout [open ".csv_reports/$name.miscellaneous.csv" a]
				set log_inp [catch {glob -type {f l} $dir/log*/$st*.log}]
				if {$log_inp==0} {
					if {$st!="cts"} {
						foreach file [glob -type {f l} $dir/log*/$st*.log] {
                                        		set m_time [file mtime $file]
                                                	if {$m_time > $latest} {
                                                		set latest $m_time
                                                        	set log $file
                                                	}
						}
					}
					if {$st=="cts" && [catch {glob -type {f l} $dir/log*/$st.log}]==0} {
						#puts [glob -type {f l} $dir/log*/$st.log] 
						foreach file [glob -type {f l} $dir/log*/$st.log] {
                                        		set m_time [file mtime $file]
                                                	if {$m_time > $latest} {
                                                		set latest $m_time
	                                                        set log $file
                                                	}
						}
					}
					source /ads/indiatc1/reporting_scripts/html_scripts_v1/runtime.tcl
					set run_time [runtime $log $st]
					set tot_runtime [addtime $tot_runtime $run_time]
					puts $Fout "run_time,$run_time"
					puts $OUT "run_time,$run_time"
					if {$st=="route"} {
						puts $Fout "tot_run_time,$tot_runtime"
						puts $OUT "tot_run_time,$tot_runtime"

					}
				
				} else {
					puts $Fout "run_time,NA"
					puts $OUT "run_time,NA"
					if {$st=="route" && $tot_runtime!=0} {
						puts $Fout "tot_run_time,$tot_runtime"
						puts $OUT "tot_run_time,$tot_runtime"

					} elseif {[regexp "route" $st]} {
						puts $Fout "tot_run_time,NA"
						puts $OUT "tot_run_time,NA"
					}

				}
				close $Fout
	
		close $OUT	
		}		
	}
	
}
close $FP
}
