proc detailed_csv {f_name} {
set FP [open "$f_name" r]
if {[file isdirectory .csv_reports]==0} {
        exec mkdir .csv_reports
}
set stage {place cts cts_opt route}
while {[gets $FP data]>=0} {
        set L [split $data ","]
        set block_name [lindex $L 0]
        set dirs [lreplace $L 0 0]

        foreach dir $dirs {
                set file_name [string tolower $block_name]
                set k [split $dir "/"]
		set dir_name [string map {. _} [lindex $k end-1]]
		append file_name "_$dir_name"
		set dir_name [string map {. _} [lindex $k end]]
		append file_name "_$dir_name"
                foreach st $stage {
                        set name $file_name
			set name1 $file_name
			#puts "$dir/rpts/$st.max.qor.rpt"
                        set inp [catch {exec egrep "Timing Summary" $dir/rpts/$st.max.qor.rpt}]
			#puts "$inp,$dir/rpts/$st.max.qor.rpt"
                        if {$inp==0 && $st!="cts"} {
				#puts "$dir/rpts/$st.max.qor.rpt"
                                append name "_$st" "_detailed_setup_timing"
                                set Fout [open ".csv_reports/$name.csv" w]
				#puts $Fout "$st Setup Timing Summary "
				puts $Fout "Scenario,Pathgroup,WNS,TNS,NOP"
				set FP1 [open "$dir/rpts/$st.max.qor.rpt" r]
				set min_wns 0 
				set tot_tns 0
				set tot_nop 0		
				set tmp ""
				set i 0
				while {[gets $FP1 data]>=0} { 
					if {[regexp {Summary} $data]} {
						if {$i==1} {
							append tmp "$prev_scn, ,[format "%.3f" $scn_wns],[format "%.3f" $scn_tns],$scn_nop\n"
							append tmp $pg_tmp
						}
						set pg_tmp ""
						set scn [lindex $data 4]
						set scn_wns 0
						set scn_tns 0 
						set scn_nop 0
						set i 0
					} elseif {[regexp {Group} $data]} {
						set PG [lindex $data 9]
						set nop [lindex $data 8]
						set tns [lindex $data 4]
						set wns [lindex $data 3]
						set scn_wns [expr min($scn_wns,$wns)]
						#puts "$scn_tns,$tns"
						set scn_tns [expr $scn_tns+$tns]
						set scn_nop [expr $scn_nop+$nop]
						set min_wns [expr min($min_wns,$wns)]
						set tot_tns [expr $tot_tns+$tns]
						set tot_nop [expr $tot_nop+$nop]
						append pg_tmp "$PG,[format "%.3f" $wns],[format "%.3f" $tns],$nop\n"
						set prev_scn $scn
						set i 1
					}
				}
				append tmp "$prev_scn, ,[format "%.3f" $scn_wns],[format "%.3f" $scn_tns],$scn_nop\n"
				append tmp $pg_tmp
				#string trimright $tmp "\n"
				append tmp "Total QOR, ,[format "%.3f" $min_wns],[format "%.3f" $tot_tns],$tot_nop"
				puts $Fout $tmp
				close $FP1
				close $Fout
				#puts $Fout "$st Hold Timing Summary"
				if {$st!="place" && $st!="cts"} {
				set FP2 [open "$dir/rpts/$st.min.qor.rpt" r]
				append name1 "_$st" "_detailed_hold_timing"
					
                                set Fout [open ".csv_reports/$name1.csv" w]
				puts $Fout "Scenario,Pathgroup,WNS,TNS,NOP"
				set min_wns 0 
				set tot_tns 0
				set tot_nop 0		
				set tmp ""
				while {[gets $FP2 data]>=0} { 
					if {[regexp {Summary} $data]} {
						if {$i==1} {
							append tmp "$prev_scn, ,[format "%.3f" $scn_wns],[format "%.3f" $scn_tns],$scn_nop\n"
							append tmp $pg_tmp
						}
						set pg_tmp ""
						set scn [lindex $data 4]
						set scn_wns 0
						set scn_tns 0 
						set scn_nop 0
						set i 0
					} elseif {[regexp {Group} $data]} {
						set PG [lindex $data 9]
						set nop [lindex $data 8]
						set tns [lindex $data 4]
						set wns [lindex $data 3]
						set scn_wns [expr min($scn_wns,$wns)]
						set scn_tns [expr $scn_tns+$tns]
						set scn_nop [expr $scn_nop+$nop]
						set min_wns [expr min($min_wns,$wns)]
						set tot_tns [expr $tot_tns+$tns]
						set tot_nop [expr $tot_nop+$nop]
						append pg_tmp "$PG,[format "%.3f" $wns],[format "%.3f" $tns],$nop\n"
						set prev_scn $scn
						set i 1
					}
				}
				append tmp "$prev_scn, ,[format "%.3f" $scn_wns],[format "%.3f" $scn_tns],$scn_nop\n"
				append tmp $pg_tmp
				#string trimright $tmp "\n"
				append tmp "Total QOR, ,[format "%.3f" $min_wns],[format "%.3f" $tot_tns],$tot_nop"
				#string trimright $tmp "\n"
				puts $Fout $tmp
				close $FP2

				close $Fout 
				}
			} 
			set name $file_name
                        set inp [catch {glob -type f $dir/rpts/$st.power.rpt}]
			if {$inp==0} {
				append name "_$st" "_detailed_power"
				#puts $name	
				set Fout [open ".csv_reports/$name.csv" w]
				set FP3 [open "$dir/rpts/$st.power.rpt" r]
				set tmp ""
				set scn_tmp ""
				set sub_tmp ""
				puts $Fout "Scenario,Type,Leakage,Toggling,Internal,Set_Pow,Sub_total"
				while {[gets $FP3 data]>=0} {
					if {[regexp {Scenario} $data]} {
						set scn [lindex $data 3]
						append tmp $scn_tmp
						append tmp $sub_tmp
						set scn_tmp $scn
						set sub_tmp ""	
						#puts $Fout "Power Summary for $scn"
					} elseif {[regexp {<} $data ] && [regexp {>} $data ] } {
						#puts $data
						set k [regexp {<(.+)>} $data match sub]
							if {[regexp {Sum} $data] && $k==1} {		
								append scn_tmp ", "
								#puts $sub
							} elseif {$k==1} {
								append sub_tmp "$sub"	
								#puts $sub		
							}
						foreach elem $data {
							set k [regexp {[0-9]+.[0-9]+} $elem match]
							#puts $elem
							if {[regexp {Sum} $data] && $k==1} {		
								append scn_tmp ",$match"
							} elseif {$k==1} { 
								append sub_tmp ",$match"
							}

						}	
						if {[regexp {Sum} $data]} {
							append scn_tmp "\n"
						} else {
							append sub_tmp "\n"
						}
					}
				}
				append tmp $scn_tmp
				append tmp $sub_tmp
				puts $Fout $tmp
				close $FP3
				close $Fout

				
			} 
			set name $file_name
			set inp [catch {glob -type f $dir/rpts/$st.drv.rpt}]
			if {$inp==0} {
				append name "_$st" "_detailed_drv"
				set tmp ""
				set Fout [open ".csv_reports/$name.csv" w]
				#puts $Fout "Max transition violations"
				puts $Fout "Scenario,tran Cost,tran violations,cap cost,cap violations"
				set TRANS [split [exec egrep " max_transition" $dir/rpts/$st.drv.rpt] "\n"]
				set CAPS [split [exec egrep " max_capacitance" $dir/rpts/$st.drv.rpt] "\n"]
				set scns [split [exec egrep "Scenario" $dir/rpts/$st.drv.rpt] "\n"]
				set max_tran 0 
				set tot_tran 0
				set max_cap 0
				set tot_cap 0 
				foreach scn $scns tran $TRANS cap $CAPS {
					set tran_cost [lindex $tran 2]
					set cap_cost [lindex $cap 2]
					set tran_vios [lindex $tran 4]
					set cap_vios [lindex $cap 4]
					set max_tran [expr max($max_tran,$tran_cost)]
					set max_cap [expr max($max_cap,$cap_cost)]
					set tot_tran [expr $tot_tran+$tran_vios]
					set tot_cap [expr $tot_cap+$cap_vios]
					append tmp "[lindex $scn 2],$tran_cost,$tran_vios,$cap_cost,$cap_vios\n"
					#puts "[lindex $scn 2],$tran_cost,$cap_cost"
				}

				append tmp "Total Violations,$max_tran,$tot_tran,$max_cap,$tot_cap"
				puts $Fout $tmp
				close $Fout
			} 	
			
			set inp [catch {glob -type f $dir/rpts/$st.skew.rpt}]
			set name $file_name
			set tmp ""
			if {$inp==0 && $st=="cts"} {
				set FP6 [open "$dir/rpts/$st.skew.rpt" r]
				append name "_$st" "_detailed_skew"
				set Fout [open ".csv_reports/$name.csv" w]
				puts $Fout "Scenario,Skew Group,Sinks,Max Latency,Min Latency,Skew,AvgSkew"
				set prev_scn ""
				while {[gets $FP6 data]>=0} { 
					if {[regexp {Scenario} $data]} {
						set scn [lindex $data 2]
						#append tmp $scn
					} elseif {[regexp {Skew Group} $data]} {
						set sg [lindex $data 3]
							#append tmp " ,$sg" 

					} elseif {[regexp {Sink Num} $data]} {
						set k [regexp {[0-9]+} $data sink_num]
						#append tmp ",$sink_num"

					} elseif {[regexp {Max Latency} $data]} {
						set k [regexp {[0-9]+.[0-9]+} $data Max_L]
						#append tmp ",$Max_L"
					} elseif {[regexp {Min Latency} $data]} {
						set k [regexp {[0-9]+.[0-9]+} $data Min_L]
						#append tmp ",$Min_L"
					} elseif {[regexp {^ Skew} $data]} {
						set k [regexp {[0-9]+.[0-9]+} $data skew]
						#append tmp ",$skew"
					}  elseif {[regexp {AvgSkew} $data]} {
						set k [regexp {[0-9]+.[0-9]+} $data avg_skew]
						#append tmp ",$t_skew\n"
						if {$scn==$prev_scn} {
							append tmp " ,$sg,$sink_num,$Max_L,$Min_L,$skew,$avg_skew\n"
						} else {
							append tmp "$scn,$sg,$sink_num,$Max_L,$Min_L,$skew,$avg_skew\n"
						}
	
						set prev_scn $scn
					}

				}
				puts $Fout $tmp
				close $Fout
				close $FP6
			 }
			 
				
			
		}
	}
}
close $FP
}
