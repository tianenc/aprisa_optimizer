proc export_html {args} {
        process_proc_arguments -arguments $args ainfo
	if {[info exists ainfo(-reports_dir)]} {
		set rpts_dir $ainfo(-reports_dir)
	} else {
		set rpts_dir reports_qor
	} 
	if {[info exists ainfo(-scenario)]} {
		set scn $ainfo(-scenario)
	} elseif {[info exists ainfo(-detailed)]!=1} {
		puts "-scenario is must"
		return 0
	}
	if {[info exists ainfo(-saved_scenarios)]} {
                set mcmm "saved"
        } else {
		set mcmm "every"
        }
	if {[info exists ainfo(-input)]} {
		set input $ainfo(-input)		

	} else {
		if {[info exists ainfo(-base_run)]} {
			set base_run $ainfo(-base_run)
			set dir [pwd]	
			if {[catch {exec grep "^Design" $dir/rpts/place.placement.rpt}]==0} {
				set tmp [exec grep "^Design" $dir/rpts/place.placement.rpt]
				set design [lindex $tmp 2]
				set str  "$design,$base_run,$dir"
			} else {
				set str "design,$base_run,$dir"
			}
	
		} else {
			set dir [pwd]	
			if {[catch {exec grep "^Design" $dir/rpts/place.placement.rpt}]==0} {
				set tmp [exec grep "^Design" $dir/rpts/place.placement.rpt]
				set design [lindex $tmp 2]
				set str  "$design,$dir"
			} else {
				set str "design,$dir"
			}	
		}
		set Fin [open "input.txt" w]
		puts $Fin $str
		close $Fin

		set input "input.txt"
	#	if {[info exists ainfo(-file_name)]} {
        #      	  	set html_file $ainfo(-file_name)
        #	} else {	
	#		set html_file [lindex [split $str ","] 0]
	#	}
	}
	if {[file isdirectory .csv_reports]==0} {
		exec mkdir .csv_reports
	} else {
		catch { exec rm -rf .csv_reports }
		catch {exec mkdir .csv_reports }
	}
	if {[info exists ainfo(-skew_group)]} {
                set sg $ainfo(-skew_group)
        } else {
                set sg "-"
        } 	
	set INP [open "$input" r]
	while {[gets $INP data]>=0} { 
		set html_file [lindex [split $data ,] 0]
		set OUT [open "sub_inp.txt" w]
		puts $OUT $data
		close $OUT
		set sub_inp "sub_inp.txt"		
	if {[info exists ainfo(-amazon)]} {
		set project "amazon"
		source ./scripts/html_scripts/reports_export.tcl	
		reports_export $sub_inp $rpts_dir
	} else {
		set project "default"
	}
 	source ./scripts/html_scripts/reports_change.tcl
	reports_copy $sub_inp
	if {[info exists ainfo(-generate)]} {
		source ./scripts/html_scripts/generate_rpts.tcl
		generate_reports $sub_inp $project $mcmm
	} 	

	if {[info exists ainfo(-detailed)]} {
		set gif 0
		source ./scripts/html_scripts/rpts_existence.tcl
		rpts_existence $sub_inp $project $mcmm $gif
		source ./scripts/html_scripts/summary_det_csv.tcl
                summary_csv $sub_inp
		source ./scripts/html_scripts/detailed_csv_report.tcl
		detailed_csv $sub_inp 
		source ./scripts/html_scripts/work_areas.tcl
		w_areas $sub_inp
		source ./scripts/html_scripts/export_detail.tcl
		detailedReports $html_file
	} else {
		set gif 0
		source ./scripts/html_scripts/rpts_existence.tcl
		rpts_existence $sub_inp $project $mcmm $gif
		source ./scripts/html_scripts/summary_csv.tcl
		summary_csv $sub_inp $scn $sg
		source ./scripts/html_scripts/work_areas.tcl
		w_areas $sub_inp
		source ./scripts/html_scripts/export_comparison.tcl
		compare $html_file $scn
		
	}
	}
	close $INP
			
}
declare_proc_attributes export_html \
                 -help_info "exports summary comarison or detailed HTML files"  \
                 -declare_args {
			{-file_name "name for HTML file" html string optional}
			{-input "file having run dirs" inp string optional}
                        {-base_run "base run dir " base string optional }
			{-reports_dir "directory name having reports (default value: reports_qor)" rpts_dir string optional }
			{-amazon "enables if working environment is amazon" client boolean optional}
			{-scenario "dominant scenario for showing results in summary" scn string optional }
			{-generate "generates all reports" gen boolean optional}
			{-saved_scenarios "generates reports with scenarios saved in project" saved boolean optional}
			{-detailed "exports detailed HTML file" detail boolean optional}
			{-skew_group "mentioned skew group CTS parameters will be displayed in summary" sg string optional}
}
