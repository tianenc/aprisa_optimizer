#! /usr/bin/tclsh

proc reports_export {input rpts_dir} {
	set FP [open "$input" r]
	set stages {place cts cts_opt route}
	while {[gets $FP data]>=0} {
		set L [split $data ","]
		set block_name [lindex $L 0]
		set dirs [lreplace $L 0 0]
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
					}
					if {$stage=="cts_opt"} {
						catch {exec cp $dir/$rpts_dir/${stage}.clkcells.rpt $dir/rpts/$stage.clkcells.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_congestion.rpt $dir/rpts/$stage.congestion.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_tmr.rpt $dir/rpts/$stage.tmr.rpt}
					}
					if {$stage=="route"} {
						catch {exec cp $dir/$rpts_dir/${stage}_drc.rpt $dir/rpts/$stage.drc.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_congestion.rpt $dir/rpts/$stage.congestion.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_report_drc.rpt $dir/rpts/$stage.drc.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_congestion.rpt $dir/rpts/$stage.congestion.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}.clkcells.rpt $dir/rpts/$stage.clkcells.rpt}
						catch {exec cp $dir/$rpts_dir/${stage}_info.rpt $dir/rpts/$stage.info.rpt}
					}
					
					
 				} 
			}
		}
	}

	close $FP
}

