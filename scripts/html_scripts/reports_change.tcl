#! /usr/bin/tclsh

proc reports_copy {input} {
	set FP [open "$input" r]
	set stages {place cts cts_opt route}
	while {[gets $FP data]>=0} {
		set L [split $data ","]
		set block_name [lindex $L 0]
		set dirs [lreplace $L 0 0]
		set fgen_stages {place_opt cts post_cts_opt route_opt}
		foreach dir $dirs {
			foreach st $fgen_stages {
				if {$st=="place_opt"} {
					set st1 "place"
				} elseif {$st=="post_cts_opt"} {
					set st1 "cts_opt"
				} elseif {$st=="route_opt"} {
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
				#catch {exec mv $dir/rpts/route_info.rpt $dir/rpts/rpts/route_info.rpt }
				catch {exec mv $dir/rpts/${st}_push_pull.rpt $dir/rpts/$st1.push_pull.rpt }
				#catch {exec cp $dir/rpts/place.port_place_check.rpt $dir/rpts/rpts/place.port_place_check.rpt }
				catch {exec cp $dir/rpts/${st}_params.tcl $dir/rpts/$st1.params.tcl }
				catch {exec mv $dir/rpts/${st}.mbit_cell.rpt $dir/rpts/$st1.mbit_cell.rpt }
				catch {exec mv $dir/rpts/${st}_drc.rpt $dir/rpts/$st1.drc.rpt }
				#catch {exec mv $dir/rpts/${st}.mbit_cell.rpt $dir/rpts/rpts/$st1.mbit_cell.rpt }
				catch {exec mv $dir/rpts/${st1}.tim.rpt $dir/rpts/${st1}.timing.summary}
				catch {exec mv $dir/rpts/${st1}.place.rpt $dir/rpts/${st1}.placement.rpt}
				catch {exec mv $dir/rpts/$st1.route.rpt $dir/rpts/$st1.drc.rpt}
				catch {exec mv $dir/rpts/${st1}_info.rpt $dir/rpts/$st1.info.rpt}
				
				catch {exec cp $dir/rpts/${st}.trans.rpt $dir/rpts/$st1.trans.rpt }
				catch {exec cp $dir/rpts/${st}.tmr.rpt $dir/rpts/$st1.tmr.rpt }
				catch {exec cp $dir/rpts/${st}.timing.summary $dir/rpts/$st1.timing.summary }
				catch {exec cp $dir/rpts/${st}.setup.gif $dir/rpts/$st1.setup.gif }
				catch {exec cp $dir/rpts/${st}.power.rpt $dir/rpts/$st1.power.rpt }
				catch {exec cp $dir/rpts/${st}.placement.rpt $dir/rpts/$st1.placement.rpt }
				catch {exec cp $dir/rpts/${st}.pinDensity.gif $dir/rpts/$st1.pinDensity.gif }
				catch {exec cp $dir/rpts/${st}.moduleView.gif $dir/rpts/$st1.moduleView.gif }
				catch {exec cp $dir/rpts/${st}.min.qor.rpt $dir/rpts/$st1.min.qor.rpt }
				catch {exec cp $dir/rpts/${st}.max.qor.rpt $dir/rpts/$st1.max.qor.rpt }
				catch {exec cp $dir/rpts/${st}.drv.rpt $dir/rpts/$st1.drv.rpt }
				catch {exec cp $dir/rpts/${st}.congestion.rpt $dir/rpts/$st1.congestion.rpt }
				catch {exec cp $dir/rpts/${st}.congestion.gif $dir/rpts/$st1.congestion.gif }
				catch {exec cp $dir/rpts/${st}.clkcells.rpt $dir/rpts/$st1.clkcells.rpt }
				catch {exec cp $dir/rpts/${st}.cellDensity.gif $dir/rpts/$st1.cellDensity.gif }
				catch {exec cp $dir/rpts/${st}.cap.rpt $dir/rpts/$st1.cap.rpt }
				catch {exec cp $dir/rpts/${st}.designrules.rpt $dir/rpts/$st1.designrules.rpt }
				catch {exec cp $dir/rpts/${st}.clockdrv.rpt $dir/rpts/$st1.clockdrv.rpt }
				catch {exec cp $dir/rpts/${st}.via.rpt $dir/rpts/$st1.via.rpt }
				catch {exec cp $dir/rpts/${st}.vars.tcl $dir/rpts/$st1.vars.tcl }
				catch {exec cp $dir/rpts/${st}.skew.rpt $dir/rpts/$st1.skew.rpt }
				#catch {exec cp $dir/rpts/route_info.rpt $dir/rpts/rpts/route_info.rpt }
				catch {exec cp $dir/rpts/${st}.push_pull.rpt $dir/rpts/$st1.push_pull.rpt }
				#catch {exec cp $dir/rpts/place.port_place_check.rpt $dir/rpts/rpts/place.port_place_check.rpt }
				catch {exec cp $dir/rpts/${st}.params.tcl $dir/rpts/$st1.params.tcl }
				catch {exec cp $dir/rpts/${st}.mbit_cell.rpt $dir/rpts/$st1.mbit_cell.rpt }
				catch {exec cp $dir/rpts/${st}.drc.rpt $dir/rpts/$st1.drc.rpt }
				#catch {exec cp $dir/rpts/${st}.mbit_cell.rpt $dir/rpts/rpts/$st1.mbit_cell.rpt }
				catch {exec cp $dir/rpts/${st1}.tim.rpt $dir/rpts/${st1}.timing.summary}
				catch {exec cp $dir/rpts/${st1}.place.rpt $dir/rpts/${st1}.placement.rpt}
				catch {exec cp $dir/rpts/$st1.route.rpt $dir/rpts/$st1.drc.rpt}
				catch {exec cp $dir/rpts/${st1}_info.rpt $dir/rpts/$st1.info.rpt}
				set inp [catch {glob -type f $dir/rpts/$st1.drv.rpt* }]
				if {$inp==1} {
					catch {exec cat $dir/rpts/${st1}.trans.rpt > $dir/rpts/$st1.drv.rpt}
					catch {exec cat $dir/rpts/${st1}.cap.rpt >> $dir/rpts/$st1.drv.rpt}
				}
					
			}
		}
	}

	close $FP
}

