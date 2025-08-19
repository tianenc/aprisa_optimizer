
proc route_info_gui {dir} {
	set flr [open  ${dir}/route_info.rpt w]
        set length_list [run get_property [run get_nets * -flat] full_wire_length]
        set length 0  
        foreach l $length_list {
                set length [ expr {$length + $l}]
        }
        puts $flr "wire_length == $length"

        set via_n [run sizeof_oblist [run get_shapes -filter_by "object_class==via"]]
        puts $flr "via_count == $via_n"

        close $flr
}
proc mbit_for_formality_gui {file_name} {
        set fp [open $file_name w]
        set mbit_registers [run get_cells -hierarchical *ATmbit* -filter_by "is_flip_flop==true"]
        foreach mbit_reg $mbit_registers {
                set reg_name [run get_name_of_object $mbit_reg]
                set reg_name_s [string map {_mbit_ " "} $reg_name]
                set reg_name_l [split $reg_name_s " "]
                set i 0
                set length [llength $reg_name_l]
                
                set base_name [run get_property $mbit_reg base_name]
                set cmd "set design_name \[string map \{\/${base_name} \"\"\} \$reg_name\]"
                eval $cmd
                set cmd "set reg_name_wo_design \[string map \{${design_name}\/ \"\"\} \$reg_name\]"
                eval $cmd
               
                set group_elements {}
                set group_elements_s ""
                set design_of_elements {}
                while { $i < $length } {
                        set orig_inst [run get_sequential_instance_bitmap -instance $mbit_reg -bit $i -type ORIGINAL_INSTANCE]
                        lappend group_elements $orig_inst
                       
                        set orig_inst_list [split $orig_inst "/"]
                        set design_name [join [lreplace $orig_inst_list [expr [llength $orig_inst_list] -1] [expr [llength $orig_inst_list] -1]] "/"]
                        lappend design_of_elements $design_name
                        set cmd "run set reg_name_l_e \[string map \{${design_name}\/ \"\"\} \$orig_inst\]"
                        eval $cmd
                        set group_elements_s "$group_elements_s $reg_name_l_e 1"
                        set i [expr $i+1]
                }
              
                set design_name_s [run get_name_of_object [run get_module -relate [run get_cells [lsort -u $design_of_elements]]]]
                set length_design [llength $design_name_s]
                if {$length_design > 1} {
                        run echo "ERROR:cross hierarchy mbit opt with [run get_name_of_object $mbit_reg]"
                }
                puts $fp "guide_multibit \\"
                puts $fp "  \-design \{ $design_name_s \} \\"
                puts $fp "  \-type \{ svfMultibitTypeBank \} \\"
                puts $fp "  \-groups \\"
                puts $fp "   \{ \{ $group_elements_s $reg_name_wo_design $length\} \}"
                puts $fp ""
        }
        close $fp
}

proc create_formality_user_map_gui {file_name} {
        global module
        set fp [open $file_name w]

        set mbit_registers [run get_cells -hierarchical *ATmbit* -filter_by "is_flip_flop==true"]
        foreach mbit_reg $mbit_registers {
                set reg_name [run get_name_of_object $mbit_reg]
                set reg_name_s [regsub "_ATmbit_.*"  $reg_name  ""]
                set reg_name_s [string map {_mbit_ " "} $reg_name_s]
                set last_slash_index [string last {/} $reg_name_s]
                set reg_name_s [string replace $reg_name_s $last_slash_index  $last_slash_index " "]
                set reg_name_l [split $reg_name_s " "]
                set i 0
                set length [llength $reg_name_l]
                for {set i 1} {$i < $length } {incr i} {
                        puts $fp "set_user_match r:/WORK/${module}/[lindex $reg_name_l 0]/[lindex $reg_name_l $i] {i:/WORK/${module}/${reg_name}/\\*dff.00.[expr $i-1]\\*} -type cell -noninverted"
                        run echo "$reg_name\n$reg_name_s\n****"
                }
        }
        close $fp
}

proc report_clk_cells_gui  {dir stage} {
	set FP [open "$dir/$stage.clkcells.rpt" w]
	set clock [run sizeof_oblist [run get_cells *ATct* -hier -leaf -filter_by "is_icg == false"]]
	set clock_ar 0
	foreach cl [run get_cells *ATct* -hier -leaf -filter_by "is_icg == false"] {
       	 	set ar [run get_property [run get_cells $cl] area]
        	set clock_ar [expr $clock_ar + $ar]
	}
	
	set cts_buf [run get_name_of_object [run get_lib_cells * -filter_by "is_buffer==true&&is_clock_driver==true"]]
	set cts_inv [run get_name_of_object [run get_lib_cells * -filter_by "is_inverter==true&&is_clock_driver==true"]]
	set buf_count 0 
	set inv_count 0
	set buf_area 0
	set inv_area 0
	set buf_str ""
	set inv_str ""
	set hld_count 0
	set hld_str ""
	foreach buf $cts_buf {
		set count [run sizeof_oblist [run get_cells *ATct* -hierarchical -filter_by "master_name==$buf&&is_icg==false" -silent]]
		set area [run get_property [run get_lib_cells $buf ] area_size]
		set buf_area [expr $buf_area +[expr $count*$area]]
		set buf_count [expr $buf_count+$count]
		append buf_str "\t$buf : $count\n"
	
	}
	foreach inv $cts_inv {
		set count [run sizeof_oblist [run get_cells *ATct* -hierarchical -filter_by "master_name==$inv&&is_icg==false" -silent]]
		set area [run get_property [run get_lib_cells $inv ] area_size]
		set inv_area [expr $inv_area +[expr $count*$area]]
		set inv_count [expr $inv_count+$count]
		append inv_str "\t$inv : $count\n"
	
	}
 	set clock_icg [sizeof_oblist [get_cells *ATct* -hierarchical -filter_by "is_clock_gating_cell==true" -silent]]
	puts $FP "Clock Cells : $clock"
	puts $FP "Clock Cells area : $clock_ar"
	puts $FP "Clock Buffers : $buf_count"
	puts $FP "Clock Buffer area : $buf_area"
	puts $FP "$buf_str"
	puts $FP "Clock Inverters:$inv_count"
	puts $FP "Clock Inverter area : $inv_area"
	puts $FP "$inv_str"
	puts $FP "Clock ICG: $clock_icg"

	if {$stage=="route" || $stage=="cts_opt"} {
		set hld_count [run sizeof_oblist [run get_cells *AThold* -hierarchical -silent]]
		if {$hld_count>0} {
		set hld_cells [lsort -unique [run get_property [run get_cells *AThold* -hierarchical -silent] master_name]]
		foreach hld $hld_cells {
			set count [run sizeof_oblist [run get_cells *AThold* -hierarchical -filter_by "master_name==$hld" -silent]]
			#set hld_count [expr $hld_count+$count]
			append hld_str "\t$hld : $count\n"
		}
	}
	puts $FP "Hold Cells : $hld_count"
	puts $FP $hld_str
	}
	close $FP
}
proc report_mbit_gui {dir stage} {
set fl_mbit [open  $dir/$stage.mbit_cell.rpt w]
set mbit [run sizeof_oblist [run get_cells -relate_to [run get_lib_cells -filter_by "is_flip_flop == true" * ]]]
if { $mbit != 0 } {
        set 1bit [run sizeof_oblist [run get_cells -relate_to [run get_lib_cells -filter_by "is_flip_flop == true && number_of_bits == 1" * ]]]
        set 2bit [run sizeof_oblist [run get_cells -relate_to [run get_lib_cells -filter_by "is_flip_flop == true && number_of_bits == 2" * ]]]
        set 4bit [run sizeof_oblist [run get_cells -relate_to [run get_lib_cells -filter_by "is_flip_flop == true && number_of_bits ==  4" * ]]]
        set 6bit [run sizeof_oblist [run get_cells -relate_to [run get_lib_cells -filter_by "is_flip_flop == true && number_of_bits ==  6" * ]]]	
        set 8bit [run sizeof_oblist [run get_cells -relate_to [run get_lib_cells -filter_by "is_flip_flop == true && number_of_bits ==  8" * ]]]
       puts $fl_mbit "## MBIT SUMMARY ##"
       puts $fl_mbit "1bit_cell: $1bit"
       puts $fl_mbit "2bit_cell: $2bit"
       puts $fl_mbit "4bit_cell: $4bit"
       puts $fl_mbit "6bit_cell: $6bit"
       puts $fl_mbit "8bit_cell: $8bit"
}

puts $fl_mbit "total_cells: $mbit"

set total_bits [expr [run sizeof_oblist [run get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==1"]] + \
        2*[run sizeof_oblist [run get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==2"]] + \
        4*[run sizeof_oblist [run get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==4"]] + \
        6*[run sizeof_oblist [run get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==6"]] + \	
        8*[run sizeof_oblist [run get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==8"]] ]

set percentage [expr double($total_bits - [run sizeof_oblist [run get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==1"]])*100/double($total_bits)]

puts $fl_mbit "total_bits: $total_bits"
puts $fl_mbit "mbit_conv: $percentage"
close $fl_mbit
}

proc reports_export {input rpts_dir} {
	set FP [open "$input" r]
	set stages {place cts cts_opt route}
	while {[gets $FP data]>=0} {
		set L [split $data ","]
		set block_name [lindex $L 0]
		set dirs [lreplace $L 0 0]
		set rpts_dirs  "$rpts_dir reports_qor"
		foreach rpts_dir $rpts_dirs {
		foreach dir $dirs {
			foreach stage $stages { 
				set f_name $stage
				append f_name "_time_full.rpt"
				if {[file exists $dir/$rpts_dir/$f_name] } {
					if {[file isdirectory $dir/rpts]==0} {
        					exec mkdir $dir/rpts
					}
					catch {exec cp $dir/$rpts_dir/${stage}_time_full.rpt $dir/rpts/$stage.timing.summary}
					catch {exec cp $dir/$rpts_dir/${stage}_time_full.sum $dir/rpts/$stage.max.qor.rpt}
					catch {exec cp $dir/$rpts_dir/${stage}_time_full_min.sum $dir/rpts/$stage.min.qor.rpt}
					catch {exec cp $dir/$rpts_dir/${stage}_power.rpt $dir/rpts/$stage.power.rpt}
					catch {exec cp $dir/$rpts_dir/${stage}_drv.rpt $dir/rpts/$stage.trans.rpt}
					catch {exec cp $dir/$rpts_dir/${stage}_drv.rpt $dir/rpts/$stage.cap.rpt}
					catch {exec cp $dir/$rpts_dir/${stage}_max_tran.rpt $dir/rpts/$stage.trans.rpt}
					catch {exec cp $dir/$rpts_dir/${stage}_max_cap.rpt $dir/rpts/$stage.cap.rpt}
					catch {exec cp $dir/$rpts_dir/${stage}_place.rpt $dir/rpts/$stage.placement.rpt}
					catch {exec cp $dir/$rpts_dir/${stage}.cellDensity.gif $dir/rpts/$stage.cellDensity.gif}
					catch {exec cp $dir/$rpts_dir/${stage}.congestion.gif $dir/rpts/$stage.congestion.gif}
					catch {exec cp $dir/$rpts_dir/${stage}.moduleView.gif $dir/rpts/$stage.moduleView.gif}
					catch {exec cp $dir/$rpts_dir/${stage}.pinDensity.gif $dir/rpts/$stage.pinDensity.gif}
					catch {exec cp $dir/$rpts_dir/${stage}.setup.gif $dir/rpts/$stage.setup.gif}
					if {$stage=="place"} {
						catch {exec cp $dir/$rpts_dir/mbit_cell.rpt $dir/rpts/$stage.mbit_cell.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_tmr.rpt $dir/rpts/$stage.tmr.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_congestion.rpt $dir/rpts/$stage.congestion.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_push_pull.rpt $dir/rpts/$stage.push_pull.rpt}
					}	
					if {$stage=="cts"} {
						catch {exec cp $dir/$rpts_dir/cts_skew.rpt $dir/rpts/cts.skew.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}.clkcells.rpt $dir/rpts/$stage.clkcells.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_clk_drv_full.rpt $dir/rpts/$stage.designrules.full.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_clk_drv.rpt $dir/rpts/$stage.designrules.rpt}
					}
					if {$stage=="cts_opt"} {
						catch {exec cp $dir/$rpts_dir/${stage}.clkcells.rpt $dir/rpts/$stage.clkcells.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_congestion.rpt $dir/rpts/$stage.congestion.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_tmr.rpt $dir/rpts/$stage.tmr.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_clk_drv_full.rpt $dir/rpts/$stage.designrules.full.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_clk_drv.rpt $dir/rpts/$stage.designrules.rpt}
					}
					if {$stage=="route"} {
						catch {exec cp $dir/$rpts_dir/${stage}_drc.rpt $dir/rpts/$stage.drc.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_congestion.rpt $dir/rpts/$stage.congestion.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_report_drc.rpt $dir/rpts/$stage.drc.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_congestion.rpt $dir/rpts/$stage.congestion.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}.clkcells.rpt $dir/rpts/$stage.clkcells.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_info.rpt $dir/rpts/$stage.info.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_clk_drv_full.rpt $dir/rpts/$stage.designrules.full.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_clk_drv.rpt $dir/rpts/$stage.designrules.rpt}
					}
					
					
 				} 
			}
		}
		}
	}

	close $FP
}


proc reports_copy {input} {
	set FP [open "$input" r]
	set stages {place cts cts_opt route}
	while {[gets $FP data]>=0} {
		set L [split $data ","]
		set block_name [lindex $L 0]
		set dirs [lreplace $L 0 0]
		set fgen_stages {place cts cts_opt route}
		foreach dir $dirs {
			foreach st $fgen_stages {
				if {$st=="place"} {
					set st1 "place"
				} elseif {$st=="cts_opt"} {
					set st1 "cts_opt"
				} elseif {$st=="route"} {
					set st1 "route"
				} elseif {$st=="cts"} {
					set st1 "cts"
				}
				catch {exec mv $dir/rpts/${st}_trans.rpt $dir/rpts/$st1.trans.rpt }
				catch {exec mv $dir/rpts/${st}_tmr.rpt $dir/rpts/$st1.tmr.rpt }
				catch {exec mv $dir/rpts/${st}_timing.summary $dir/rpts/$st1.timing.summary }
				catch {exec mv $dir/rpts/${st}_setup.gif $dir/rpts/$st1.setup.gif }
				catch {exec mv $dir/rpts/${st}_power.rpt $dir/rpts/$st1.power.rpt }
				catch {exec mv $dir/rpts/${st}_placement.rpt $dir/rpts/$st1.placement.rpt }
				catch {exec mv $dir/rpts/${st}_pinDensity.gif $dir/rpts/$st1.pinDensity.gif }
				catch {exec mv $dir/rpts/${st}_moduleView.gif $dir/rpts/$st1.moduleView.gif }
				catch {exec mv $dir/rpts/${st}_min.qor.rpt $dir/rpts/$st1.min.qor.rpt }
				catch {exec mv $dir/rpts/${st}_max.qor.rpt $dir/rpts/$st1.max.qor.rpt }
				catch {exec mv $dir/rpts/${st}_drv.rpt $dir/rpts/$st1.drv.rpt }
				catch {exec mv $dir/rpts/${st}_congestion.rpt $dir/rpts/$st1.congestion.rpt }
				catch {exec mv $dir/rpts/${st}_congestion.gif $dir/rpts/$st1.congestion.gif }
				catch {exec mv $dir/rpts/${st}_clkcells.rpt $dir/rpts/$st1.clkcells.rpt }
				catch {exec mv $dir/rpts/${st}_cellDensity.gif $dir/rpts/$st1.cellDensity.gif }
				catch {exec mv $dir/rpts/${st}_cap.rpt $dir/rpts/$st1.cap.rpt }
				catch {exec mv $dir/rpts/${st}_designrules.rpt $dir/rpts/$st1.designrules.rpt }
				catch {exec mv $dir/rpts/${st}_clockdrv.rpt $dir/rpts/$st1.clockdrv.rpt }
				catch {exec mv $dir/rpts/${st}_via.rpt $dir/rpts/$st1.via.rpt }
				catch {exec cp $dir/rpts/${st}_vars.tcl $dir/rpts/$st1.vars.tcl }
				catch {exec mv $dir/rpts/${st}_skew.rpt $dir/rpts/$st1.skew.rpt }
				catch {exec mv $dir/rpts/${st}_push_pull.rpt $dir/rpts/$st1.push_pull.rpt }
				catch {exec cp $dir/rpts/${st}_params.tcl $dir/rpts/$st1.params.tcl }
				catch {exec mv $dir/rpts/${st}.mbit_cell.rpt $dir/rpts/$st1.mbit_cell.rpt }
				catch {exec mv $dir/rpts/${st}_drc.rpt $dir/rpts/$st1.drc.rpt }
					
			}
			foreach stage $stages { 
				if {[file exists $dir/rpts/$stage.tim.rpt]} {
					catch {exec mv $dir/rpts/$stage.tim.rpt $dir/rpts/$stage.timing.summary}
 				} 
				if {[file exists $dir/rpts/$stage.place.rpt]} {
					catch {exec mv $dir/rpts/$stage.place.rpt $dir/rpts/$stage.placement.rpt}
				}
				if {[file exists $dir/rpts/$stage.route.rpt]} {
					catch {exec mv $dir/rpts/$stage.route.rpt $dir/rpts/$stage.drc.rpt}
				}
			}
		}
	}

	close $FP
}

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
					set inp1 [catch {glob -type {d l} $dir/db/*$st1*.proj}]
					if {$inp1==0} {	
					set latest 0
					set proj ""
					foreach file [glob -type {d l} $dir/db/*$st1*proj] {
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
						run purge_project
						run load_proj $proj
						if {$project=="client"} { 
							run set_param lpe clock_min_arnoldi 0.001
						}
						my_results_gui $dir/rpts $st $mcmm
						run purge_project
							

					}
					}
					
				}
			}
		}
		close $FP
	} else { puts "$f_name file doesn't exists" }
}

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
			

					set inp1 [catch {glob -type {d l} $dir/db/*$st1*.proj}]
					set rpt [expr $f1+$f2+$f3+$f4]
					
					if {$rpt>=1 && $inp1==0} {
						#puts "stage:$st"
						
						set latest 0
						foreach file [glob -type {d l} $dir/db/*$st1*proj] {
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
							run purge_project
							run load_proj $proj
							if {$project=="client"} { 
								run set_param lpe clock_min_arnoldi 0.001
							}
							if {$f1==1} {
								my_results_gui $dir/rpts $st $mcmm
								run purge_project
							}
							if {$f1==0 && $f2==1} {
								puts "generating GIF reports for $proj"
								gif_reports_gui $dir/rpts $st
								run purge_project
							}
							if {$f1==0 && $f3>=1} {
                                                                report_clk_cells_gui $dir/rpts $st
                                                        }
							if {$f1==0 && $f4==1} {
								run report_skew_group_constraint  -design_rules > $dir/rpts/$st.designrules.rpt
							}
						}
					}
				}
			}
		}
		close $FP
	} else { puts "$f_name file doesn't exists" }
}
proc hh:mm:ss {secs} {
        set h [expr {$secs/3600}]
        incr secs [expr {$h*-3600}]
        set m [expr {$secs/60}]
        set s [expr {$secs%60}]
        set tim [format "%02.2d:%02.2d:%02.2d" $h $m $s]
	return $tim
}
proc runtime {log stage} {
	if  {[file exists $log]} {
		set f1 [open "$log" r]
	        set tim 0
	        while {[gets $f1 data] >= 0} {
			set timing 0
			if {$stage=="place"} {
				if {[regexp {Place_optimize} $data] && [regexp {Finish} $data]} {
					set timing 1
				}
			}
			if {$stage=="cts"} {
				if {[regexp {Synthesize_skew_group} $data] && [regexp {Finish} $data]} {
                                        set timing 1
                                }
			}
			if {$stage=="cts_opt"} {
                                if {[regexp {Post_cts_opt} $data] && [regexp {Finish} $data]} {
                                        set timing 1
                                }
                        }
			if {$stage=="route"} {
                                if {[regexp {Droute_opt} $data] && [regexp {Finish} $data]} {
                                        set timing 1
                                }
                        }
			
			 if {$timing==1} {
		          set k [regexp {([0-9]+):([0-9]+):([0-9]+);} $data match hour min sec]
			  set hour [expr [scan $hour "%d"]]
		          set min [expr [scan $min "%d"]]
		          set sec [expr [scan $sec "%d"]]
		          set tim [expr $tim + ($hour*60*60) + ($min*60) + $sec]
	       		}
        	}
        set total [hh:mm:ss $tim]
        return $total
  }
 

}
proc summary_csv {f_name scn sg} {
set FP [open "$f_name" r]
if {[file isdirectory .csv_reports]==0} {
	exec mkdir .csv_reports
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
		set file_name [string tolower $block_name]
		set k [split $dir "/"]
		set dir_name [lindex $k [expr [llength $k]-1]]
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
					set tmp_all [catch {run exec grep "ALL" $dir/rpts/$st.timing.summary}]
					if {$tmp_all==0} {
						set reg_all "ALL"
					} else {		
						set reg_all "WNS"
					}
        				while {[gets $FP1 data1]>=0} {

			                	if {[regexp "$reg_all" $data1 ] && [regexp {WNS} $data1]} {
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
				set inp [catch {exec grep " max_transition" $dir/rpts/$st.trans.rpt }]
				if {$inp==0} {
			  	      set TRAN [split [exec egrep " max_transition|Scenario" $dir/rpts/$st.trans.rpt] "\n"]
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
				        set CAP [split [exec egrep "Scenario| max_capacitance" $dir/rpts/$st.cap.rpt] "\n"] 
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
				set inp1 [catch {glob -type {f l} $dir/rpts/$st.designrules.full.rpt}]

				set Fout [open ".csv_reports/$name.power_drv.csv" a]	
				if {$inp==0 && $inp1==0} {
					set F_read [open "$dir/rpts/$st.designrules.rpt" r]
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
					set F_read [open "$dir/rpts/$st.designrules.full.rpt" r]
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
				} elseif {$inp==0 && $inp1==1} {
					set F_read [open "$dir/rpts/$st.designrules.rpt" r]
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
				if {$inp==0} {
					#set scn_tmp [exec grep "Scenario" $dir/rpts/cts.skew.rpt]
					#set scn [lindex $scn_tmp 2]	
					set Fout [open ".csv_reports/$name.miscellaneous.csv" w]	
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
								#puts "$max_lat,$Sinks"
							} elseif {$Sinks==$sink_num && $Max_Latency<=$max_lat && [regexp {scan_clk} $skew_group]==0 } {
								set Max_Latency $max_lat
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
				set inp1 [catch {glob -type {f l} $dir/rpts/$st.mvt.rpt }]
				set ulvt "NA"
				set lvt "NA"
				set hvt "NA"
				if {$inp1==0} {
					set Fmvt [open "$dir/rpts/$st.mvt.rpt" r]
					while {[gets $Fmvt data]>=0} {
						if {[regexp "Vt" $data] && [llength $data]>=3} {
							if {[regexp "Low" $data]} {
								set k [regexp {[(]+([0-9]+[.]+[0-9]+)%[)]+} $data match sub]
								set ulvt $sub
							} elseif {[regexp "Normal" $data]} {
								set k [regexp {[(]+([0-9]+[.]+[0-9]+)%[)]+} $data match sub]
								set lvt $sub
							} elseif {[regexp "High" $data]} {
								set k [regexp {[(]+([0-9]+[.]+[0-9]+)%[)]+} $data match sub]
								set hvt $sub
							}	
						}
					}
				}
				puts $Fout "ULVT%,$ulvt"
				puts $OUT "ULVT%,$ulvt"
				puts $Fout "LVT%,$lvt"
				puts $OUT "LVT%,$lvt"				
				puts $Fout "HVT%,$hvt"
				puts $OUT "HVT%,$hvt"
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
					if {$elem!="hold_cells"} {
						puts $Fout "$elem,NA"
						puts $OUT "$elem,NA"
					} else {
						if {$st=="cts_opt" || $st=="route"} {
							puts $Fout "$elem,NA" 
							puts $OUT "$elem,NA"
						}	
					}
				}
				puts $Fout "ULVT%,NA"
				puts $OUT "ULVT%,NA"
				puts $Fout "LVT%,NA"
				puts $OUT "LVT%,NA"				
				puts $Fout "HVT%,NA"
				puts $OUT "HVT%,NA"	
				close $Fout
			}
		        
			if {$st!="cts"} {
					set Fout [open ".csv_reports/$name.miscellaneous.csv" w]
					
					if {$st=="cts_opt" || $st=="place"} {
						set inp [catch {glob -type {f l} $dir/rpts/$st.tmr.rpt }]
						if {$inp==0} {
						set tmp_TMR [exec grep "Total" $dir/rpts/$st.tmr.rpt]
						set k [regexp {[0-9]+} $tmp_TMR TMR]
						puts $Fout  "TMR,$TMR"
						puts $OUT "TMR,$TMR"
						} else {
							puts $Fout "TMR,NA"
							puts $OUT "TMR,NA"
						}
					}
					if {$st=="place"} {
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
							set tmp [exec grep "mbit_conv" $dir/rpts/$st.mbit_cell.rpt]
							set k [regexp {[-]*[0-9]+[.]*[0-9]*$} $tmp mbit_conv]
							puts $Fout "Mbit_Conv,$mbit_conv"
							puts $OUT "Mbit_Conv,$mbit_conv"
						} else {		
							puts $Fout "FF_Push/Pull,NA"
							puts $OUT "FF_Push/Pull,NA"
							puts $Fout "FF_pull_avg,NA"
							puts $OUT "FF_pull_avg,NA"
							puts $Fout "Mbit_Conv,NA"
							puts $OUT "Mbit_Conv,NA"
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
						set inp [catch {glob -type {f l} $dir/rpts/${st}.drc.rpt }]
						if {$inp==0} {
							if {[catch {exec grep "via_count" $dir/rpts/$st.info.rpt}]==0} {
								set tmp [exec grep "via_count" $dir/rpts/$st.info.rpt]
								set k [regexp {[0-9]+} $tmp vias] 
							} else {
								set tmp [exec grep "Total via count" $dir/rpts/${st}.drc.rpt]
								set k [regexp {[0-9]+} $tmp vias]
							}
							puts $Fout "Totalvias,$vias"
							puts $OUT "Totalvias,$vias"
		
							if {[catch {exec grep ": short" $dir/rpts/${st}.drc.rpt}]==0} {
								set tmp [exec grep ": short" $dir/rpts/${st}.drc.rpt]
								set k [regexp {[0-9]+} $tmp short]
								puts $Fout "Shorts,$short"
								puts $OUT "Shorts,$short"
							} else {
								puts $Fout "Shorts,0"
								puts $OUT "Shorts,0"
							}
							set tmp [exec grep ": Total DRC" $dir/rpts/${st}.drc.rpt]
							set k [regexp {[0-9]+} $tmp DRC]
							puts $Fout "DRC,$DRC"
							puts $OUT "DRC,$DRC"
							if {[catch {exec grep ": Total Antenna" $dir/rpts/${st}.drc.rpt}]==0} {
								set tmp [exec grep ": Total Antenna" $dir/rpts/${st}.drc.rpt]
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
				if {$inp==0 && $st!="place"} {
				set Fclk [open "$dir/rpts/$st.clkcells.rpt" r]
				set clock_cells "NA"
				set clock_cells_area "NA"
				set clock_buffers "NA"
				set clock_inverters "NA"
                                while {[gets $Fclk data]>=0} {
                                        if {[regexp "Clock Cells :" $data]} {
                                                set k [regexp {[0-9]+} $data match]
                                                set clock_cells $match
                                                #puts $Fout "clock_cells,$match"
                                        } elseif {[regexp "Clock Cells area :" $data]} {
                                                set k [regexp {[0-9]+} $data match]
                                                set clock_cells_area $match
                                                #puts $Fout "clock_cells_area,$match"
                                        } elseif {[regexp "Clock Buffers :" $data]} {
                                                set k [regexp {[0-9]+} $data match]
                                                set clock_buffers $match
                                                #puts $Fout "clock_buffers,$match"
                                        } elseif {[regexp "Clock Inverters:" $data]} {
                                                set k [regexp {[0-9]+} $data match]
                                                set clock_inverters $match
                                                #puts $Fout "clock_inverters,$match"
                                        } elseif {[regexp "Hold Cells :" $data]} {
						set k [regexp {[0-9]+} $data match]
                                                set hold_cells $match
                                                #puts $Fout "hold_cells,$match"
							
					}
                                }
				puts $OUT "clock_cells,$clock_cells"
                                puts $Fout "clock_cells,$clock_cells"
				puts $OUT "clock_cells_area,$clock_cells_area"
                                puts $Fout "clock_cells_area,$clock_cells_area"
				puts $OUT "clock_buffers,$clock_buffers"
                                puts $Fout "clock_buffers,$clock_buffers"
				puts $OUT "clock_inverters,$clock_inverters"
                                puts $Fout "clock_inverters,$clock_inverters"
				if {$st=="cts_opt" || $st=="route"} {
					puts $OUT "hold_cells,$hold_cells"
	                                puts $Fout "hold_cells,$hold_cells"
				}
                                close $Fclk
				close $Fout	
				
				} elseif {$st!="place"} {
					puts $OUT "clock_cells,NA"
					puts $OUT "clock_cells_area,NA"
					puts $OUT "clock_buffers,NA"
					puts $OUT "clock_inverters,NA"
					puts $Fout "clock_cells,NA"
					puts $Fout "clock_cells_area,NA"
					puts $Fout "clock_buffers,NA"
					puts $Fout "clock_inverters,NA"
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
					set run_time [runtime $log $st]	
					puts $Fout "run_time,$run_time"
					puts $OUT "run_time,$run_time"
				
				} else {
					puts $Fout "run_time,NA"
					puts $OUT "run_time,NA"
				}
				close $Fout
	
		close $OUT	
		}		
	}
	
}
close $FP
}



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
                set dir_name [lindex $k [expr [llength $k]-1]]
                set dir_name [string map {. _} $dir_name]
		append file_name "_$dir_name"
                
                foreach st $stage {
			set gifs {cellDensity.gif congestion.gif pinDensity.gif moduleView.gif setup.gif}
			foreach gif $gifs {
				set inp [catch {glob -type f $dir/rpts/$st.$gif}]
				if {$inp==0} {
					set name $file_name
					append name "_$st" "_$gif"
					exec cp $dir/rpts/$st.$gif .csv_reports/$name
          			} else {
					set name $file_name
                                        append name "_$st" "_$gif"
					set cmd "convert -size 512x512  xc:white .csv_reports/$name"
					eval exec $cmd
				}
			}
                        set name $file_name
			set name1 $file_name
                        set inp [catch {glob -type f $dir/rpts/$st.max.qor.rpt}]
                        if {$inp==0} {
                                append name "_$st" "_detailed_setup_timing"
                                set Fout [open ".csv_reports/$name.csv" w]
				#puts $Fout "$st Setup Timing Summary "
				puts $Fout "Scenario,Pathgroup,WNS,TNS,NOP"
				set FP1 [open "$dir/rpts/$st.max.qor.rpt" r]
				set min_wns 0 
				set tot_tns 0
				set tot_nop 0		
				set tmp ""
				while {[gets $FP1 data]>=0} { 
					if {[regexp {Summary} $data]} {
						set scn [lindex $data 4]
						append tmp "$scn"
					} elseif {[regexp {Group} $data]} {
						set PG [lindex $data 9]
						set nop [lindex $data 8]
						set tns [lindex $data 4]
						set wns [lindex $data 3]
						set min_wns [expr min($min_wns,$wns)]
						set tot_tns [expr $tot_tns+$tns]
						set tot_nop [expr $tot_nop+$nop]
						append tmp ",$PG,$wns,$tns,$nop\n"
					}
				}
				#string trimright $tmp "\n"
				append tmp "Total QOR,,$min_wns,[format "%.2f" $tot_tns],$tot_nop"
				puts $Fout $tmp
				close $FP1
				close $Fout
				#puts $Fout "$st Hold Timing Summary"
				if {$st!="place"} {
				set FP2 [open "$dir/rpts/$st.min.qor.rpt" r]
				append name1 "_$st" "_detailed_hold_timing"
                                set Fout [open ".csv_reports/$name1.csv" w]
				set min_wns 0 
				set tot_tns 0
				set tot_nop 0		
				set tmp ""
				while {[gets $FP2 data]>=0} { 
					if {[regexp {Summary} $data]} {
						set scn [lindex $data 4]
						append tmp "$scn"
					} elseif {[regexp {Group} $data]} {
						set PG [lindex $data 9]
						set nop [lindex $data 8]
						set tns [lindex $data 4]
						set wns [lindex $data 3]
						set min_wns [expr min($min_wns,$wns)]
						set tot_tns [expr $tot_tns+$tns]
						set tot_nop [expr $tot_nop+$nop]
						append tmp ",$PG,$wns,$tns,$nop\n"
					}
				}
				#string trimright $tmp "\n"
				append tmp "Total QOR,$min_wns,[format "%.2f" $tot_tns],$tot_nop"
				puts $Fout $tmp
				close $FP2

				close $Fout 
				}
			} else {
				append name "_$st" "_detailed_setup_timing"
				append name1 "_$st" "_detailed_hold_timing"
				run echo "Report not Available" > .csv_reports/$name.csv
 				run echo "Report not Available" > .csv_reports/$name1.csv
			}
			set name $file_name
                        set inp [catch {glob -type f $dir/rpts/$st.power.rpt}]
			if {$inp==0} {
				append name "_$st" "_detailed_power"
				#puts $name	
				set Fout [open ".csv_reports/$name.csv" w]
				set FP3 [open "$dir/rpts/$st.power.rpt" r]
				set tmp ""
				puts $Fout "Scenario,Group Type,Leakage,Toggling,Internal,Set_Pow,Sub_total"
				while {[gets $FP3 data]>=0} {
					if {[regexp {Scenario} $data]} {
						set scn [lindex $data 3]
						append tmp $scn	
						#puts $Fout "Power Summary for $scn"
					} elseif {[regexp {<(.+)>} $data match sub1]} {
						append tmp ",$sub1"
						foreach elem $data {
							set k [regexp {[0-9]+.[0-9]+} $elem match]
							#puts $elem
							if {$k==1} { 
								append tmp ",$match"
							}

						}
						append tmp "\n"
						
					}
				}
				puts $Fout $tmp
				close $FP3
				close $Fout

				
			} else {
				append name "_$st" "_detailed_power"
				run echo "Report not Available" > .csv_reports/$name.csv
			}
			set name $file_name
			set inp [catch {exec grep " max_transition" $dir/rpts/$st.trans.rpt}]
			if {$inp==0} {
				append name "_$st" "_detailed_drv"
				set tmp ""
				set Fout [open ".csv_reports/$name.csv" w]
				#puts $Fout "Max transition violations"
				puts $Fout "Scenario,tran Cost,tran violations,cap cost,cap violations"
				set TRANS [split [exec egrep " max_transition" $dir/rpts/$st.trans.rpt] "\n"]
				set CAPS [split [exec egrep " max_capacitance" $dir/rpts/$st.cap.rpt] "\n"]
				set scns [split [exec egrep "Scenario" $dir/rpts/$st.trans.rpt] "\n"]
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
			} else {
				append name "_$st" "_detailed_drv"
				run echo "Report not Available" > .csv_reports/$name.csv
			}	
			
			set inp [catch {glob -type f $dir/rpts/$st.skew.rpt}]
			set name $file_name
			set tmp ""
			if {$inp==0 && $st=="cts"} {
				set FP6 [open "$dir/rpts/$st.skew.rpt" r]
				append name "_$st" "_detailed_skew"
				set Fout [open ".csv_reports/$name.csv" w]
				puts $Fout "Scenario,Skew Group,Max Latency,Min Latency,Skew,Total Skew"
				while {[gets $FP6 data]>=0} {
					if {[regexp {Scenario} $data]} {
						set scn [lindex $data 2]
						append tmp $scn
					} elseif {[regexp {Skew Group} $data]} {
						set sg [lindex $data 3]
						append tmp ",$sg"
					} elseif {[regexp {Max Latency} $data]} {
						set k [regexp {[0-9]+.[0-9]+} $data Max_L]
						append tmp ",$Max_L"
					} elseif {[regexp {Min Latency} $data]} {
						set k [regexp {[0-9]+.[0-9]+} $data Min_L]
						append tmp ",$Min_L"
					} elseif {[regexp {^ Skew} $data]} {
						set k [regexp {[0-9]+.[0-9]+} $data skew]
						append tmp ",$skew"
					}  elseif {[regexp {Total Skew} $data]} {
						set k [regexp {[0-9]+.[0-9]+} $data t_skew]
						append tmp ",$t_skew\n"
					}

				}
				puts $Fout $tmp
				close $Fout
				close $FP6
			 }
			 if {$inp==1 && $st=="cts"} {
				append name "_$st" "_detailed_skew"
				run echo "Report not available" >  .csv_reports/$name.csv
			 }
				
			
		}
	}
}
close $FP
}
proc w_areas {f_name scn} { 
	set f1 [open "$f_name" r]
	set f2 [open ".csv_reports/work_areas.tcl" w]
	puts $f2 "set scn $scn"
	while {[gets $f1 data]>=0} {
		set L [split $data ","]
		set block [string tolower [lindex $L 0]]
		set dirs [lreplace $L 0 0 ]
		set dirs1 ""
		foreach dir $dirs {
			set k [split $dir "/"]
			lappend dirs1 [ string map {. _} [lindex $k [expr [llength $k]-1]]]
			set wa [ string map {. _} [lindex $k [expr [llength $k]-1]]]
			puts $f2 "set full_path(${block}_$wa) $dir"
		}
		puts $f2 "set work_areas($block) {$dirs1}"
	}
	close $f1
	close $f2
}
proc gui_phy_reports {dir stage} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: Start proc gui_phy_reports"


	open_layout ; hide_gui
	layout_options -size_filter 0
	layout_options -all_layer_view 0
	foreach_in_oblist layer [get_tf_layers *] {
 		echo "[get_name_of_object $layer]"
 		set cmd "layout_options -layer_view\([get_name_of_object $layer]\) 0"
 		eval $cmd
	}
	set rptdir $dir

	set step $stage
	show_congestion_map -type place  >  $rptdir/${step}.congestion.rpt
	export_layout $rptdir/${step}.congestion.png -format png
	show_congestion_map -hide 

	show_density_map -color(5) #ff000000ff00 -color(4) #990000009900 -color(3) #ff00ff000000 -color(2) orange -color(1) red
	export_layout $rptdir/${step}.cellDensity.png -format png
	show_density_map -hide

	show_pin_density_map -color(5) #ff000000ff00 -color(4) #990000009900 -color(3) #ff00ff000000 -color(2) orange -color(1) red
	export_layout $rptdir/${step}.pinDensity.png -format png
	show_pin_density_map -hide

	browse_module --interactive  -auto_color true
	export_layout $rptdir/${step}.moduleView.png -format png
	set_cell_color -child -clear [get_modules [current_module]]
	if {[regexp (route|filler|export_db) $stage]} {
		browse_drc --interactive
		browse_drc select -checker router
		export_layout $rptdir/${step}.drc.png -format png	
	}

	layout_options -size_filter 1.0 
	close_window
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	puts "INFO {$date}: End proc gui_phy_reports"

}

proc gui_timing_report  {dir stage} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: Start proc gui_timing_reports"


	open_layout ; hide_gui
	layout_options -size_filter 0
	layout_options -all_layer_view 0
	foreach_in_oblist layer [get_tf_layers *] {
 		echo "[get_name_of_object $layer]"
 		set cmd "layout_options -layer_view\([get_name_of_object $layer]\) 0"
 		eval $cmd
	}
	set rptdir $dir

	set step $stage

	if {![regexp (build_db|mcmm_setup) $stage]} {
		set get_ta_paths [get_ta_paths -only_slack_less_than 0 -path_group REG2REG -number_of_worst_paths  1  -max_number_of_paths 5  -no_hierarchical_pins ]
  		if {[sizeof_oblist $get_ta_paths] > 0} {
  			set i 0
			foreach_in_oblist ta_path $get_ta_paths {
    				set start_point [get_property $ta_path start]
    				set end_point [get_property $ta_path end]
    				set slack [get_property $ta_path worst_slack]
    				if {$i==0} {
     					highlight $ta_path -color red
    				}
    				if {$i==1} {
     					highlight $ta_path -color orange 
    				}
    				if {$i==2} {
     					highlight $ta_path -color yellow 
    				}
    				if {$i==3} {
     					highlight $ta_path -color green 
    				}
    				if {$i==4} {
     					highlight $ta_path -color blue 
    				}
    				echo "$start_point, $end_point, $slack"
    				incr i
  			}
  			export_layout $rptdir/${step}.setup.png -format png
  			foreach_in_oblist ta_path $get_ta_paths {
    				highlight $ta_path -remove
  			}
		} else {
			export_layout $rptdir/${step}.setup.png -format png
		}
	}
	layout_options -size_filter 1.0 
	close_window
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	puts "INFO {$date}: End proc gui_timing_reports"

}

proc report_clk_cells  {dir stage} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	puts "INFO {$date}: Start proc report_clk_cells"
	set FP [open "$dir/$stage.clkcells.rpt" w]
	set clock_all 0
	set clock_all_area 0
	set clock_ib [sizeof_oblist [get_cells *ATct* -hier -leaf -filter_by "is_icg == false"]]
	incr clock_all  $clock_ib
	set clock_ib_ar 0
	set clock_ib_ar [ iter_oblist [get_cells *ATct* -hier -leaf -filter_by "is_icg == false && is_sequential_cell==false"] -sum_prop area] 
	set cts_buf [get_name_of_object [get_lib_cells * -filter_by "is_buffer==true"]]
	set cts_inv [get_name_of_object [get_lib_cells * -filter_by "is_inverter==true"]]
	set buf_count 0 
	set inv_count 0
	set buf_area 0
	set inv_area 0
	set buf_str ""
	set inv_str ""
	set hold_count 0
	set hld_str ""
	set cl_str ""
	foreach buf $cts_buf {
		set count [sizeof_oblist [get_cells *ATct* -hierarchical -filter_by "master_name==$buf&&is_icg==false" -silent]]
		if {$count>0} {
			set area [ get_property [get_lib_cells $buf ] area_size]
			set buf_area [expr $buf_area +[expr $count*$area]]
			set buf_count [expr $buf_count+$count]
			append buf_str "\t$buf : $count\n"
		}
	}
	foreach inv $cts_inv {
		set count [sizeof_oblist [get_cells *ATct* -hierarchical -filter_by "master_name==$inv&&is_icg==false" -silent]]
		if {$count>0} {
			set area [ get_property [get_lib_cells $inv ] area_size]
			set inv_area [expr $inv_area +[expr $count*$area]]
			set inv_count [expr $inv_count+$count]
			append inv_str "\t$inv : $count\n"
		}
	
	}
	set all [get_skew_group_pins [get_skew_groups *]]
	set only_sink [get_skew_group_pins -sink_only [get_skew_groups *]]
	set buf_inv_cell [get_cells -relate_to [get_lib_cells * -filter_by {is_buffer==true||is_inverter==true}]]
	set cl_cells [purge_from_oblist [get_cells -relate_to [purge_from_oblist $all $only_sink] -filter_by {is_flip_flop==false && is_sequential==false && full_hier_name!~*ATc*} -silent] $buf_inv_cell]
	set cl_lib_cells [lsort -u [get_property [get_cells $cl_cells] master_name]]
	set cl_str ""
	foreach cl_lib $cl_lib_cells {
		set count [sizeof_oblist [get_cells "$cl_cells" -hierarchical -filter_by "master_name==$cl_lib" -silent]]
		if {$count>0} {
			append cl_str "\t$cl_lib : $count\n"
		}
	
	}

	set clock_logic [sizeof_oblist [purge_from_oblist [get_cells -relate_to [purge_from_oblist $all $only_sink] -filter_by {is_flip_flop==false && is_sequential==false && full_hier_name!~*ATc*} -silent] $buf_inv_cell]]
	set cl_area [iter_oblist [get_cells $cl_cells] -sum_prop area]
	set icg_all [get_cells -relate_to [purge_from_oblist $all $only_sink] -filter_by "is_icg==true" -silent]
	set icg_lib_cells [get_property [get_cells $icg_all] master_name]
	set icg_count [sizeof_oblist [get_cells -relate_to [purge_from_oblist $all $only_sink] -filter_by "is_icg==true" -silent]]
	set icg_area  [ iter_oblist [get_cells $icg_all] -sum_prop area]
	set icg_str ""
	foreach icg_lib $icg_lib_cells {
		set count [sizeof_oblist [get_cells "$icg_all" -hierarchical -filter_by "master_name==$icg_lib" -silent]]
		if {$count>0} {
			append icg_str "\t$icg_lib : $count\n"
		}
	
	}
	incr clock_all $clock_logic
	incr clock_all $icg_count
	set clock_all_area [expr  $cl_area+$icg_area+$clock_ib_ar]
	puts $FP "Clock Cells : $clock_all"
	puts $FP "Clock Cells area : $clock_all_area"
	puts $FP "Clock Buf+Inv Cells : $clock_ib"
	puts $FP "Clock Buf+Inv Cells area : $clock_ib_ar"
	puts $FP "Clock Buffers : $buf_count"
	puts $FP "Clock Buffer area : $buf_area"
	puts $FP "$buf_str"
	puts $FP "Clock Inverters:$inv_count"
	puts $FP "Clock Inverter area : $inv_area"
	puts $FP "$inv_str"
	puts $FP "Clock Logic: $clock_logic"
	puts $FP "Clock Logic Area: $cl_area"
	puts $FP "$cl_str"
	puts $FP "Clock ICG: $icg_count"
	puts $FP "Clock ICG Area : $icg_area"
	puts $FP "$icg_str"

	close $FP
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	puts "INFO {$date}: End proc report_clk_cells"
}
proc report_hld_cells  {dir stage} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	puts "INFO {$date}: Start proc report_hld_cells"
	set FP [open "$dir/$stage.hldcells.rpt" w]

	set hold_cells [ get_cells *AThold* -hierarchical -silent ]
	set hold_count [ sizeof_oblist [ get_cells *AThold* -hierarchical -silent  ] ]
	set std_cell  [ get_cells * -hierarchical    -filter_by "cell_class == std && is_filler ==f"]
	set std_count [ sizeof_oblist [ get_cells * -hierarchical    -filter_by "cell_class == std && is_filler ==f"]]
	                         
	set tot_hold_area [ iter_oblist [get_cells $hold_cells]  -sum_prop area  ]
	set tot_std_area [ iter_oblist [get_cells $std_cell] -sum_prop area  ]
	set holdTOstd_area [  format %.2f [ expr $tot_hold_area * 100 / $tot_std_area ]]

	if {$hold_count>0} {
	set hld_cells [lsort -unique [get_property [get_cells *AThold* -hierarchical -silent] master_name]]
	foreach hld $hld_cells {
		set count [sizeof_oblist [get_cells *AThold* -hierarchical -filter_by "master_name==$hld" -silent]]
		#set hld_count [expr $hld_count+$count]
		append hld_str "\t$hld : $count\n"
	}
	puts $FP "Hold Cells : $hold_count"
	puts $FP "Std cell count : $std_count"
	puts $FP "Hold cell Area : $tot_hold_area"
	puts $FP "Std cell Area : $tot_std_area"
	puts $FP "Percentage of hold area : $holdTOstd_area%"
	puts $FP $hld_str
	}
	close $FP
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	puts "INFO {$date}: End proc report_hld_cells"
}
proc route_info {dir} {
        set flr [open  ${dir}/route_info.rpt w]
        set length_list [get_property [get_nets * -flat] full_wire_length]
        set length 0  
        foreach l $length_list {
                set length [ expr {$length + $l}]
        }
        puts $flr "wire_length == $length"

        set via_n [sizeof_oblist [get_shapes -filter_by "object_class==via"]]
        puts $flr "via_count == $via_n"

        close $flr
}
proc mbit_for_formality {file_name} {
        set fp [open $file_name w]
        set mbit_registers [get_cells -hierarchical *ATmbit* -filter_by "is_flip_flop==true"]
        foreach_in_oblist mbit_reg $mbit_registers {
                set reg_name [get_name_of_object $mbit_reg]
                set reg_name_s [string map {_mbit_ " "} $reg_name]
                set reg_name_l [split $reg_name_s " "]
                set i 0
                set length [llength $reg_name_l]
                
                set base_name [get_property $mbit_reg base_name]
                set cmd "set design_name \[string map \{\/${base_name} \"\"\} \$reg_name\]"
                eval $cmd
                set cmd "set reg_name_wo_design \[string map \{${design_name}\/ \"\"\} \$reg_name\]"
                eval $cmd
               
                set group_elements {}
                set group_elements_s ""
                set design_of_elements {}
                while { $i < $length } {
                        set orig_inst [get_sequential_instance_bitmap -instance $mbit_reg -bit $i -type ORIGINAL_INSTANCE]
                        lappend group_elements $orig_inst
                       
                        set orig_inst_list [split $orig_inst "/"]
                        set design_name [join [lreplace $orig_inst_list [expr [llength $orig_inst_list] -1] [expr [llength $orig_inst_list] -1]] "/"]
                        lappend design_of_elements $design_name
                        set cmd "set reg_name_l_e \[string map \{${design_name}\/ \"\"\} \$orig_inst\]"
                        eval $cmd
                        set group_elements_s "$group_elements_s $reg_name_l_e 1"
                        set i [expr $i+1]
                }
              
                set design_name_s [get_name_of_object [get_module -relate [get_cells [lsort -u $design_of_elements]]]]
                set length_design [llength $design_name_s]
                if {$length_design > 1} {
                        echo "ERROR:cross hierarchy mbit opt with [get_name_of_object $mbit_reg]"
                }
                puts $fp "guide_multibit \\"
                puts $fp "  \-design \{ $design_name_s \} \\"
                puts $fp "  \-type \{ svfMultibitTypeBank \} \\"
                puts $fp "  \-groups \\"
                puts $fp "   \{ \{ $group_elements_s $reg_name_wo_design $length\} \}"
                puts $fp ""
        }
        close $fp
}

proc create_formality_user_map {file_name} {
        global module
        set fp [open $file_name w]

        set mbit_registers [get_cells -hierarchical *ATmbit* -filter_by "is_flip_flop==true"]
        foreach_in_oblist mbit_reg $mbit_registers {
                set reg_name [get_name_of_object $mbit_reg]
                set reg_name_s [regsub "_ATmbit_.*"  $reg_name  ""]
                set reg_name_s [string map {_mbit_ " "} $reg_name_s]
                set last_slash_index [string last {/} $reg_name_s]
                set reg_name_s [string replace $reg_name_s $last_slash_index  $last_slash_index " "]
                set reg_name_l [split $reg_name_s " "]
                set i 0
                set length [llength $reg_name_l]
                for {set i 1} {$i < $length } {incr i} {
                        puts $fp "set_user_match r:/WORK/${module}/[lindex $reg_name_l 0]/[lindex $reg_name_l $i] {i:/WORK/${module}/${reg_name}/\\*dff.00.[expr $i-1]\\*} -type cell -noninverted"
                        echo "$reg_name\n$reg_name_s\n****"
                }
        }
        close $fp
}
proc report_mbit {dir stage} {
set fl_mbit [open  $dir/$stage.mbit_cell.rpt w]
set mbit [sizeof_oblist [get_cells -relate_to [get_lib_cells -filter_by "is_flip_flop == true" * ]]]
if { $mbit != 0 } {
        set 1bit [sizeof_oblist [get_cells -relate_to [get_lib_cells -filter_by "is_flip_flop == true && number_of_bits == 1" * ]]]
        set 2bit [sizeof_oblist [get_cells -relate_to [get_lib_cells -filter_by "is_flip_flop == true && number_of_bits == 2" * ]]]
        set 4bit [sizeof_oblist [get_cells -relate_to [get_lib_cells -filter_by "is_flip_flop == true && number_of_bits ==  4" * ]]]
        set 8bit [sizeof_oblist [get_cells -relate_to [get_lib_cells -filter_by "is_flip_flop == true && number_of_bits ==  8" * ]]]

       puts $fl_mbit "1bit_cell == $1bit"
       puts $fl_mbit "2bit_cell == $2bit"
       puts $fl_mbit "4bit_cell == $4bit"
       puts $fl_mbit "8bit_cell == $8bit"
}

puts $fl_mbit "total_cells == $mbit"

set total_bits [expr [sizeof_oblist [get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==1"]] + \
        2*[sizeof_oblist [get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==2"]] + \
        4*[sizeof_oblist [get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==4"]] + \
        8*[sizeof_oblist [get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==8"]] ]

set percentage [expr double($total_bits - [sizeof_oblist [get_cells -hierarchical * -filter_by "is_flip_flop==true && number_of_bits==1"]])*100/double($total_bits)]

puts $fl_mbit "total_bits == $total_bits"
puts $fl_mbit "mbit_conv == $percentage"
close $fl_mbit
}

proc vt_detail {SAVERPT PHASE} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: Start proc vt_detail"
        set tech [get_tech]
	puts "## tech: $tech"
        if {[regexp "SEC_14|TSMC N7|TSMC N5|TSMC N4" $tech] } {
		set scns [current_mcmm ] 
                set Fo [open "$SAVERPT/${PHASE}.vt_detail.rpt" "w"] 
                if {[regexp "SEC_14" $tech]} {
                        set vt_list {hm sln14 sln16 aln14 aln16 ln14 ln16 lt16 nn14 nn16 nt16 ht16 n nn nt others}
                }
                if {[regexp "TSMC N7" $tech]} {
                        set vt_list {hm ln11 ln8 lt11 lt8 nn11 nn8 nt8 others}
                }
		if {[regexp "TSMC N5|TSMC N4" $tech]} {
			puts "match"
                        set vt_list { lnw6 ln6 ulnw6 uln6 others}
                }
		foreach scn $scns {
			set_working_scenario $scn
			puts $Fo "Working Scenario: $scn\n"
                	puts $Fo "+----------+-------------+-------------+-------------+---------------+"
                	puts $Fo [format "| %8s | %11s | %11s | %11s | %13s |" "Vt Type" "Vt Count" "Area (um)" "Percent (%)" "leakage (mW)" ]
                	puts $Fo "+----------+-------------+-------------+-------------+---------------+"
                	set Tot_count [sizeof_oblist [ get_cells -relate_to [get_lib_cells *] -silent -filter_by "is_filler_cell==false && cell_class==std"]]
                	set Tot_area [format "%.2f" [ iter_oblist [get_cells -relate_to [get_lib_cells *] -silent -filter_by "is_filler_cell==false && cell_class==std"] -sum_prop area_size]]
                	set tot_c 0
                	set tot_a 0
                	set tot_per 0
			set tot_lkg 0
                	set cell_list {}

                	foreach vt_type $vt_list {
                        	if {$vt_type!="others" && $vt_type !="hm"} {
                                	set cells [get_cells -relate_to [get_lib_cells -silent " *_${vt_type}_*  *_${vt_type} " -filter_by "base_name_id !~ hm_*"] -silent -filter_by "is_filler_cell==false && cell_class==std" ]
                                	lappend cell_list $cells
                        	} elseif {$vt_type=="hm"} {
                               	 	set cells [get_cells -relate_to [get_lib_cells -silent * -filter_by "base_name_id=~ ${vt_type}_*"] -silent -filter_by "is_filler_cell==false && cell_class==std" ]
                                	lappend cell_list $cells
                        	} else {
                                	set other_cells [purge_from_oblist  [get_cells  -relate_to [get_lib_cells *] -silent -filter_by "is_filler_cell==false && cell_class==std"] [get_cells $cell_list]  ]
                                	set cells $other_cells
                                	set others_count [sizeof_oblist $other_cells]
                        	}
                        	set vt_count [sizeof_oblist $cells]
                        	set tot_c [expr $tot_c + $vt_count]
                        	set vt_area [format "%.2f" [iter_oblist $cells -sum_prop area_size]]
                        	set tot_a [expr $tot_a + $vt_area]
                        	set vt_percentage [expr [expr $vt_area/$Tot_area]*100]
                        	set tot_per [expr $tot_per + $vt_percentage]
                        	set vt_lkg [iter_oblist $cells -sum_prop leakage_power]
				set tot_lkg [expr $vt_lkg + $tot_lkg]
                        	puts $Fo [format "| %8s | %11d | %11.2f | %11.2f | %13.6f |" $vt_type $vt_count $vt_area $vt_percentage $vt_lkg ]
                
                	}
			puts "total leakage:$tot_lkg"
               		puts $Fo "+----------+-------------+-------------+-------------+---------------+"
                	puts $Fo [format "| %8s | %11d | %11.2f | %11.2f | %13.6f |" "Total" $tot_c $tot_a $tot_per $tot_lkg]
                	puts $Fo "+----------+-------------+-------------+-------------+---------------+"
 	

		        if {$others_count>0} {
                        	puts $Fo "Other Lib Cells: [lsort -uniq [get_property [get_cells $other_cells] master_name]]"
                	}
			puts $Fo "\n" 	
		}
                puts [sizeof_oblist [get_cells $cell_list]]
                puts "$Tot_count, $tot_c"
                puts "$Tot_area, $tot_a"
		
      
                close $Fo
	}
	set_working_scenario {}
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: End proc vt_detail"
}

proc LongNets {SAVERPT PHASE} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: Start proc LongNets"
	set unplace_count [sizeof_oblist [ get_cells * -hier -filter_by "place_status==unplaced" -silent]]
	if {$unplace_count==0  } {
		set Fo [open "$SAVERPT/${PHASE}.longnets.rpt" w]
		if {![regexp (route|filler|export_db) $PHASE]} {
			set net_count_200um [sizeof_oblist [get_nets * -hierarchical -silent -filter_by "steiner_length>=200 && steiner_length<300"]]
			set net_count_300um [sizeof_oblist [get_nets * -hierarchical -silent -filter_by "steiner_length>=300 && steiner_length<500"]]
			set net_count_500um [sizeof_oblist [get_nets * -hierarchical -silent -filter_by "steiner_length>=500 && steiner_length<1000"]]
			set net_count_1000um [sizeof_oblist [get_nets * -hierarchical -silent -filter_by "steiner_length>=1000"]]
		} else {
			set net_count_200um [sizeof_oblist [get_nets * -hierarchical -silent -filter_by "wire_length>=200 && wire_length<300"]]
			set net_count_300um [sizeof_oblist [get_nets * -hierarchical -silent -filter_by "wire_length>=300 && wire_length<500"]]
			set net_count_500um [sizeof_oblist [get_nets * -hierarchical -silent -filter_by "wire_length>=500 && wire_length<1000"]]
			set net_count_1000um [sizeof_oblist [get_nets * -hierarchical -silent -filter_by "wire_length>=1000"]]
		}
		puts $Fo "###############################################################"
		puts $Fo "###                    LONG NETS                            ###"
		puts $Fo "###############################################################"

		puts $Fo "Nets with length greater than 200.0um (200-300um) $net_count_200um"
		puts $Fo "Nets with length greater than 300.0um (300-500um) $net_count_300um"
		puts $Fo "Nets with length greater than 500.0um (500-1000um) $net_count_500um"
		puts $Fo "Nets with length greater than 1000.0um (>1000um) $net_count_200um"
		close $Fo
	}
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: End proc LongNets"
}
proc histogram {infile {step 8}  {min_val 8}  {max_val 100} } {

	set fl [open "$infile" r]
	set list_1 {}
	while {[gets $fl data]>=0} {
		if {[regexp "^[0-9]+ " $data]} {
			lappend list_1 [lindex $data 0]
		}
	}
	if {[llength $list_1]>0} {
		set outfile [string map {".rpt" ".hist.rpt" } $infile]
		set fo [open "$outfile" "w"]
	
		set list {}
		set val_p {}
		set val_n {}
		#puts "list_1: $list_1"

		set step [expr double($step)] ; 
		set max_val [expr double($max_val)] ; 
		set min_val [expr double($min_val)] ;


		for {set j 0 ; set i 0} {$i <= $max_val} {incr j} {
			set i [format "%.4f" $i]
			set k [expr {$i + $step}]
			set k [format "%.4f" $k]
			lappend list "$i to $k"
			#puts $i
			lappend val_p $i
			set i [expr {$i + $step}]
		}

		for {set j 0 ; set i 0} {$i >= $min_val} {incr j} {
       			set i [format "%.4f" $i]
        		set k [expr {$i + $step}]
        		set k [format "%.4f" $k]
        		lappend list "$k to $i"
			#puts $i
			lappend val_n $i
			set i [expr {$i - $step}]
		}

		puts $fo "+-------------------------------+---------------+"
		puts $fo "|\t RANGE \t\t\t|\t COUNT\t|"
		puts $fo "+-------------------------------+---------------+"

		set p [llength $val_p]

		for {set x $p} {$x > 0} {incr x -1 } {
			set count 0
			if {$x == $p} { 
				foreach index $list_1 {
			
					if {$index >= [lindex $val_p [expr $x -1]]} {incr count }
				}
				puts $fo "|\t   >= [lindex $val_p [expr $x -1]] \t\t|\t $count \t|"
			} else { 
				set t [expr {$x - 1}]
				foreach index $list_1 {
					if {$index < [lindex $val_p $x] && $index > [lindex $val_p $t]} {incr count}
				}
				puts $fo "|\t   [lindex $val_p $x] -> [lindex $val_p $t] \t|\t $count \t|"
			} 
		}

		set n [llength $val_n]
		puts $val_n
		for {set x 0} {$x < $n} {incr x} {
        		set count 0
        		if {$x == [expr $n -1]} {
                		foreach index $list_1 {
                        		if {$index <= [lindex $val_n $x]} {incr count }
                		}
                		puts $fo "|\t [lindex $val_n $x] <=  \t\t|\t $count \t|"
        		} else {
                		set t [expr {$x + 1}]
                		foreach index $list_1 {
                        		if {$index < [lindex $val_n $x] && $index > [lindex $val_n $t]} {incr count}
                		}
                		puts $fo "|\t [lindex $val_n $x] -> [lindex $val_n $t] \t|\t $count \t|"
        		}
		}
		puts $fo "+-------------------------------+---------------+"
		close $fo
	}
	close $fl
}

proc clamp_fanout {dir stage} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: Start proc clamp_fanout"
	set_param db full_hier_search true	
	set FP1 [open "$dir/${stage}_clamp.sig.rpt" "w"]
	set FP2 [open "$dir/${stage}_clamp.clk.rpt" "w"]
	report_ta_constraint -max_transition_constraint -pins [get_pins -silent -relate_to [get_cells -silent -relate_to [get_lib_cells * -filter "is_zero_pin_isolation_cell==true" -silent ] -filter "full_hier_name=~ *clamp*" ] -filter "base_name_id==z"] > $dir/${stage}.clamp_trans.rpt
	report_ta_constraint -max_transition_constraint -pins [get_pins -silent -relate_to [get_cells -silent -relate_to [get_lib_cells * -filter "is_zero_pin_isolation_cell==true" -silent ] -filter "full_hier_name=~ *clamp*" ] -filter "base_name_id==z"] -clock_net_only >> $dir/${stage}.clamp_trans.rpt
	set FP3 [open "$dir/${stage}.clamp_trans.rpt" ]
	set scn 0 
	while {[gets $FP3 data]>=0 } {
		if {[regexp "^Working Scenario:" $data]} {
			incr scn
		}
		if {$scn==1 && [regexp "^ +[0-9]+\.[0-9]+ " $data] && [llength $data]==4} {
			set trans([lindex $data 3]) [lindex $data 1]
			
		}
		if {$scn>1} {
			break
		}
	}
	close $FP3
	puts $FP1 "#trans fanout driver"
	puts $FP2 "#trans fanout driver"
	set clamp_pins  [get_name_of_object [get_pins -silent -relate_to [get_cells -silent -relate_to [get_lib_cells * -filter "is_zero_pin_isolation_cell==true" -silent ] -filter "full_hier_name=~ *clamp*" ] -filter "base_name_id==z"]]
	foreach pin $clamp_pins {
		if {[info exists trans($pin)]} {
			set tran $trans($pin)
		} else {
			set tran "-"
		}
        	set type [get_property [get_nets -relate_to [get_pins $pin] -flat ] usage]
        	if {$type=="signal" } {
                	set fo [sizeof_oblist [get_all_fanouts -from_objects $pin -level_limit 1 -skip_hier_pins -connectivity_only]]

                	puts $FP1 "[format " %5s %5d " "$tran" "[expr $fo-1]"  ] $pin"
        	} else {
			set fo [sizeof_oblist [get_all_fanouts -from_objects $pin -level_limit 1 -skip_hier_pins -connectivity_only]]
                	puts $FP2 "[format " %5s %5d " "$tran" "[expr $fo-1]"  ] $pin"

		}
		
	}
	close $FP1
	close $FP2
	histogram $dir/${stage}_clamp.sig.rpt 
	histogram $dir/${stage}_clamp.clk.rpt 

	set_param db full_hier_search false

	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: End proc clamp_fanout"
}

proc misc_data {SAVERPT STAGE} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: Start proc misc_data"
	set FP [open "$SAVERPT/${STAGE}.misc.rpt" "w"]
	set tot_area 0 
	set hard_blk_area 0 
	set non_hard_blk_area 0

	foreach_in_oblist pg [get_place_guides -silent] {
		set area 0 
		set i 0 
		set region [get_property  $pg  region]
		set type [get_property  $pg  function]
		set max_density [get_property  $pg  max_density]
		while {$i < [llength $region]} {
			set width [expr [lindex $region $i 0] - [lindex $region $i 2]] 
			set length [expr [lindex $region $i 1 ] - [lindex $region $i 3]]
			set area [expr $area + [expr abs([expr $width*$length])]]
			incr i 
		}
		if {$max_density==0 && $type=="density"} {
			set hard_blk_area [expr $hard_blk_area + $area]
		} else {
			set non_hard_blk_area [expr $non_hard_blk_area + $area]
		}
		set tot_area [expr $tot_area + $area]
	}
	set macros [sizeof_oblist [get_cells * -hierarchical -filter_by "cell_class==macro" -silent  ]]
	puts $FP "Width: [get_property [current_design] width]"
	puts $FP "Height: [get_property [current_design] height]"
	puts $FP "Total Blockage Area: $tot_area"
	puts $FP "Total Hard Blockage Area: $hard_blk_area"
	puts $FP "Total Non Hard Blockage Area: $non_hard_blk_area"
	set dont_touch_cell [sizeof_oblist [get_cells * -silent -hierarchical -filter_by "dont_touch_in_opt==true"]]
	set dont_touch_net [sizeof_oblist [get_nets * -silent -hierarchical -filter_by "dont_touch_in_opt==true"]]
	set dont_route [sizeof_oblist [get_nets * -silent -hierarchical -filter_by "dont_route==true"]]
	set fixed_cells [sizeof_oblist [get_cells * -hierarchical -silent -filter_by "place_status==fixed"]]
	set ports [sizeof_oblist [get_ports *]]
	set sp_nets [sizeof_oblist [get_nets * -hierarchical -filter_by "is_global_net==true" -flat -silent]]
	set nets_routed [sizeof_oblist [get_nets * -hierarchical -filter_by "wire_length>0" -silent ]]
	if {$nets_routed>0} {
		set max_wl [lindex [lsort -decreasing  [get_property [get_nets * -hierarchical ] wire_length]] 0]
	} else {
		set max_wl "NA"
	}
	puts $FP "Dont Modify Cells: $dont_touch_cell"
	puts $FP "Dont Modify Nets: $dont_touch_net"
	puts $FP "Dont Route Nets: $dont_route"
	puts $FP "Max Wire Length: $max_wl "
	puts $FP "Fixed Cells: $fixed_cells"
	puts $FP "Ports: $ports"
	puts $FP "Macros: $macros"
	puts $FP "Special Nets: $sp_nets"
	close $FP
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: End proc misc_data"
}

proc plgrp_util {SAVERPT PHASE} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: Start proc plgrp_util"
        set FP [open "$SAVERPT/${PHASE}.placegroup.rpt" "w"]
        set chk 0
        if { [sizeof_oblist [get_misc_objects -class place_group -silent]] > 0} {
                puts $FP  "+--------------+-------------------------"                   
                puts $FP [format "| %12s | %s"  "Utilization" "Place Group"]
                puts $FP "+--------------+-------------------------"
                foreach PG [get_name_of_object [get_misc_objects -class place_group -silent]  ] { 
                        set PG_util [expr [get_property [get_place_groups $PG] utilization] *100]
                        if {$PG_util>100 || $PG_util==0} {
                                set chk 1
                                puts "ERROR: place group $PG has utilization $PG_util"
                        }
                        puts $FP [format "| %12s | %s"  "$PG_util%" $PG]
                         
                }
                puts $FP "+--------------+-------------------------"
                
        }
        close $FP
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: End proc plgrp_util"
        return $chk
}
proc leakagae_detail {SAVERPT PHASE} {
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: Start proc leakage_detail"
	set Fo [open "$SAVERPT/${PHASE}.leakage.rpt" "w"]
	puts $Fo "+-----------------+----------------------+----------------------+------------+"
	puts $Fo [format "| %15s | %20s | %20s | %10s |" " TYPE " " COUNT "  " AREA " " LEAKAGE "]
	puts $Fo "+-----------------+----------------------+----------------------+------------+"
	set type {ao_stdCell cm_stdCell memory memory_Logic non_ao_stdCell TOTAL}
	foreach elem $type {
		if {$elem == "TOTAL"} {
			set cells  [get_cells * -hier -silent -filter "cell_class==std||cell_class==macro"]
		} elseif {$elem == "ao_stdCell"} {
			set cells [get_cells * -hier -silent -filter "cell_class==std && master_name=~*ao*"]
		} elseif {$elem == "cm_stdCell"} {
			set cells [get_cells * -hier -silent -filter "cell_class==std && master_name=~*cm*"]	
		} elseif {$elem == "memory"} {
			set cells [get_cells * -hier -silent -filter "is_memory==true"]
			set mem_count [sizeof_oblist [get_cells $cells -silent]]
		} elseif {$elem == "memory_Logic"} {
			if {$mem_count==0} {
				set cells ""
			} else {
				set cells [get_cells -relate_to [get_all_fanouts -from [get_pins -relate_to [get_cells * -hier -silent -filter_by "is_memory==true"] -silent -filter_by "function==SIGNAL && direction==out"] -connectivity_only -level_limit 1 ] -filter_by "cell_class==std"]
				set cells [combine_oblist  $cells [get_cells -silent -relate_to [get_all_fanins -to  [get_pins -relate_to [get_cells * -hier -silent -filter_by "is_memory==true"] -silent -filter_by "function==SIGNAL && direction==in"] -connectivity_only -level_limit 1 ] -filter_by "cell_class==std"]]
			}
		}  elseif {$elem == "non_ao_stdCell"} {
			set cells [get_cells * -hier -silent -filter "cell_class==std && master_name!~*ao*"]
		}
		set count [sizeof_oblist [get_cells $cells -silent]]
		if {$count>0} {
			set area [iter_oblist [get_cells $cells ] -sum_prop area ]
			set leakage [iter_oblist [get_cells $cells] -sum_prop leakage ]
		} else {
			set area 0 
			set leakage 0 
		}
		puts $Fo [format "| %15s | %20s | %20.2f | %10.2f |" $elem $count $area $leakage]
	}
	puts $Fo "+-----------------+----------------------+----------------------+------------+"

	close $Fo
	set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
	echo "INFO {$date}: End proc leakage_detail"

}

proc gen_summary {dir stage} {
	set stp_en [catch {glob $dir/$stage.max.qor.rpt.*}]
	if {$stp_en==0} {
		set stp_files [glob $dir/$stage.max.qor.rpt.*]
		set FP [open "$dir/${stage}.max.qor.rpt" "w"]
		set i 1
		foreach s_file $stp_files {
			set FP1 [open "$s_file"]
			while {[gets $FP1 data]>=0} {
				if {[regexp {^[*]+} $data]} {
					set i 1
				}
				if {$i==1} {
					puts $FP $data
				}
			}
			close $FP1
			set i 0
		}
		close $FP
	}

	set hld_en [catch {glob $dir/$stage.min.qor.rpt.*}]
	if {$hld_en==0} {
		set hld_files [glob $dir/$stage.min.qor.rpt.*]
		set FP [open "$dir/${stage}.min.qor.rpt" "w"]
		set i 1
		foreach h_file $hld_files {
			set FP1 [open "$h_file"]
			while {[gets $FP1 data]>=0} {
				if {[regexp {^[*]+} $data]} {
					set i 1
				}
				if {$i==1} {
					puts $FP $data
				}
			}
			close $FP1
			set i 0
		}
		close $FP
	}
	set skew_en [catch {glob $dir/$stage.skew.rpt.*}]
	if {$skew_en==0} {
		set skew_files [glob $dir/$stage.skew.rpt.*]
		set i 1
		foreach skew_file $skew_files {
			if {$i==1} {
				exec cat $skew_file > $dir/$stage.skew.rpt
				incr i
			} else {
				exec egrep -v "^#" $skew_file >> $dir/$stage.skew.rpt
			}
		}
	}
	set drv_en [catch {glob $dir/$stage.drv.rpt.*}]
	if {$drv_en==0} {
		set drv_files [glob $dir/$stage.drv.rpt.*]
		set i 1
		foreach drv_file $drv_files {
			if {$i==1} {
				exec cat $drv_file > $dir/$stage.drv.rpt
				incr i
			} else {
				exec egrep -v "^#" $drv_file >> $dir/$stage.drv.rpt
			}
		}
	}
	set clkdrv_en [catch {glob $dir/$stage.clockdrv.rpt.*}]
	if {$clkdrv_en==0} {
		set ckdrv_files [glob $dir/$stage.clockdrv.rpt.*]
		set i 1
		foreach ckdrv_file $ckdrv_files {
			if {$i==1} {
				exec cat $ckdrv_file > $dir/$stage.clockdrv.rpt
				incr i
			} else {
				exec egrep -v "^#" $ckdrv_file >> $dir/$stage.clockdrv.rpt
			}
		}
	}
	set designrules_en [catch {glob $dir/$stage.designrules.rpt.*}]
	if {$designrules_en==0} {
		set DR_files [glob $dir/$stage.designrules.rpt.*]
		set i 1
		foreach DR_file $DR_files {
			if {$i==1} {
				exec cat $DR_file > $dir/$stage.designrules.rpt
				incr i
			} else {
				exec egrep -v "^#" $DR_file >> $dir/$stage.designrules.rpt
			}
		}
	}
}

proc ta_report {} {
  global  SAVERPT 
  global PHASE

  compute_timing > $SAVERPT/${PHASE}.timing.summary
  report_ta_constraint -summary > $SAVERPT/${PHASE}.drv.rpt
  report_ta_constraint -show_all_violators > $SAVERPT/${PHASE}.drv.full.rpt
  report_ta -summary > $SAVERPT/${PHASE}.max.qor.rpt
  report_ta -from [all_registers -clock_pins ] -to [all_registers -data_pins ] -max_number_of_paths 100 -only_slack_less_than 0 -sort_by_slack -skip_hier_pins -show_derate -show_input_pins -show_nets -show_transition -show_capacitance  -dont_split_line -path_report_format full_clock_expanded >  $SAVERPT/${PHASE}.stp.rpt

  gui_timing_report $SAVERPT $PHASE
  if {![regexp (build_db|mcmm_setup|place) $PHASE]} {
	report_ta -type_of_delay min -summary > $SAVERPT/${PHASE}.min.qor.rpt
	report_ta -from [all_registers -clock_pins ] -to [all_registers -data_pins ] -max_number_of_paths 100 -only_slack_less_than 0 -sort_by_slack -skip_hier_pins -show_derate -show_input_pins -show_nets -show_transition -show_capacitance  -dont_split_line -path_report_format full_clock_expanded -type_of_delay min >  $SAVERPT/${PHASE}.hld.rpt
  	report_ta_constraint -clock_net_only > $SAVERPT/${PHASE}.clockdrv.rpt
	report_ta_constraint -clock_net_only -show_all_violators > $SAVERPT/${PHASE}.clockdrv.full.rpt     
	report_ta_constraint -max_transition_constraint  -pins [all_registers -clock_pins ] > $SAVERPT/${PHASE}.clockleaf.tran.rpt 
	report_ta_constraint -max_capacitance_constraint  -pins [all_registers -clock_pins ] > $SAVERPT/${PHASE}.clockleaf.cap.rpt 
	report_ta_constraint -min_period_constraint -min_pulse_width_constraint > $SAVERPT/${PHASE}.glitch.rpt
	report_ta_constraint -min_period_constraint -min_pulse_width_constraint -show_all_violators > $SAVERPT/${PHASE}.glitch.full.rpt
	report_ta_constraint -delay_noise_constraint   > $SAVERPT/${PHASE}.noise.rpt
	report_ta_constraint -delay_noise_constraint -show_all_violators > $SAVERPT/${PHASE}.noise.full.rpt
   }

}

proc my_results {dir stage {mcmm "saved"} } {
  set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
  echo "INFO {$date}: Start proc my_results"
  if {$mcmm=="every"} {
    current_mcmm -every
    puts " generating reports considering all scenarios"
  }
  if {$mcmm=="saved"} {
    puts "genarating reports considering saved scenarios in project"
  }
  global SAVERPT
  global PHASE
  set SAVERPT $dir
  set PHASE $stage

  if { [file exists scripts/flow_design_settings.tcl] } {
    source scripts/flow_design_settings.tcl
    if { $use_flow_params_for_reports && [file exists $SAVERPT/${PHASE}_params.tcl] } {
      source $SAVERPT/${PHASE}_params.tcl
    }
  }

  set mcmm_mode [get_param ta mcmm_mode]
#  set_param ta mcmm_mode multithreaded
  set_param ta mcmm_mode hyperthreaded
  set_error_report_limit PinNoLoc 10 -log
  set_error_report_limit PinNoLoc 10
  
  catch {report_scan > $SAVERPT/${PHASE}.scan.rpt}
  echo [license current ] > $SAVERPT/${PHASE}.license.rpt
  report_placement > $SAVERPT/${PHASE}.placement.rpt
  report_timing_route_rule >  $SAVERPT/${PHASE}.tmr.rpt
  report_placement -check > $SAVERPT/$PHASE.place_check.rpt
  misc_data $SAVERPT $PHASE
  leakagae_detail $SAVERPT $PHASE
  check_power_domain >  $SAVERPT/${PHASE}.chk_pd.rpt
  check_netlist > $SAVERPT/${PHASE}.sanity.rpt
  gui_phy_reports $SAVERPT $PHASE

  set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
  echo "INFO {$date}: Start DRC reports"

  if {[regexp (route|filler|pm_fix|export_db) $PHASE]} {
    report_violation > $SAVERPT/${PHASE}.drc.rpt
    verify_layout -open -short -signal_net_only > $SAVERPT/${PHASE}.verify_la_sig.rpt
    verify_layout -open -short -pg_net_only > $SAVERPT/${PHASE}.verify_la.pg.rpt
    report_route -via > $SAVERPT/${PHASE}.via.rpt
    report_route -supply_tie_resistance > $SAVERPT/${PHASE}.supply_res.rpt
    if { [sizeof_oblist [get_nets * -hierarchical -filter_by {usage == clock || is_clock_net == true && shield_rule != ""} -quiet]] } {
	    report_route -shield >  $SAVERPT/${PHASE}.shield.rpt
    }

	}
  set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
  echo "INFO {$date}: End DRC reports"

	if {[regexp (filler|export_db|pm_fix) $PHASE]} {
		report_placement -check -post_fill_check > $SAVERPT/${PHASE}.filler_gap.rpt
	}	

  set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
  echo "INFO {$date}: Start group_path"
  purge_group_path -all 
  set scns [current_mcmm]
  foreach scn [current_mcm] {
	  set_working_scenario $scn 
	  group_path -name INPUT -from [all_inputs ] -to [all_registers -data_pins ]
	  group_path -name OUTPUT -from [all_registers -clock_pins ] -to [all_outputs ]
	  group_path -name IN2OUT -from [all_inputs ] -to [all_outputs ]
	  group_path -name REG2REG -from [all_registers -clock_pins ] -to [all_registers -data_pins ]
	  group_path  -name MEM2MEM -from [get_pins -relate_to [get_cells * -hierarchical -quiet -filter_by "cell_class==macro"] -quiet -filter_by "function==CLOCK"] -to [get_pins -relate_to [get_cells * -hierarchical -quiet -filter_by "cell_class==macro"] -quiet -filter_by "function==SIGNAL"]
	  group_path -name MEM2REG -from [get_pins -relate_to [get_cells * -hierarchical -quiet -filter_by "cell_class==macro"] -quiet -filter_by "function==CLOCK"] -to [all_registers -data_pins ]
	  group_path -name REG2MEM -from [all_registers -clock_pins ] -to [get_pins -relate_to [get_cells * -hierarchical -quiet -filter_by "cell_class==macro"] -quiet -filter_by "function==SIGNAL"]
	  group_path -name REG2ICG -from [all_registers -clock_pins ] -to [get_pins -relate_to [get_cells * -hierarchical -quiet -filter_by "is_icg==true"] -quiet -filter_by "function==SIGNAL"]

  }
  set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
  echo "INFO {$date}: End group_path"

  set_working_scenario {}
  current_mcmm $scns -worst_leakage {}
  if {[regexp (cts) $PHASE]} {
	set_param ta propagated_clocks 1
	set_param ta port_prop_clock_latency true
  }

  rusage -timer Timing_report -reset
  batch_report_ta -proc ta_report >  $SAVERPT/${PHASE}.timing.summary
  rusage -timer Timing_report -reset

  gen_summary $SAVERPT $PHASE
  if {[regexp (cts|route) $PHASE]} {
	report_skew_group_constraint -design_rules > $SAVERPT/${PHASE}.designrules.rpt
	report_skew_group_constraint -all_violators > $SAVERPT/${PHASE}.designrules.full.rpt
    # --- MODIFICATION START ---
    # Check if the unique report path variable exists (set in cts.tcl).
    # If so, use it for the report name to avoid the race condition.
    # Otherwise, fall back to the default report name.
	if {[info exists ::unique_skew_report_path]} {
		report_skew_group_summary -all > $::unique_skew_report_path
	} else {
		report_skew_group_summary -all > $SAVERPT/${PHASE}.skew.rpt
	}
    # --- MODIFICATION END ---

  	report_clk_cells $SAVERPT $PHASE
  	report_hld_cells $SAVERPT $PHASE
  }
  report_mvt -exclude_filler_cell >  $SAVERPT/${PHASE}.mvt.rpt
  report_mbit $SAVERPT $PHASE
  if {[regexp "place" $PHASE]} {
       report_latency_offset > $SAVERPT/${PHASE}.push_pull.rpt
  }

  report_power_analysis > $SAVERPT/${PHASE}.power.rpt
  set_param ta mcmm_mode $mcmm_mode
  echo "Enabled scenarios: [current_mcmm]" > $SAVERPT/${PHASE}.mcmm.rpt
  current_mcmm -every
  echo "All scenarios: [current_mcmm] " >> $SAVERPT/${PHASE}.mcmm.rpt
  set date [clock format [clock scan [date] ] -format {%Y-%m-%d %H:%M:%S}]
  echo "INFO {$date}: End proc my_results"

}
