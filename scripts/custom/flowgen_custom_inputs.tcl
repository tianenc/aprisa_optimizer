puts "PHASE = $PHASE and STEP = $STEP"

if { $PHASE == {init} } {
  if { $STEP == {pre} } {
    #do this just before init

  }

  if { $STEP == {post} } {
    #do this after init

  }
}
 
if { $PHASE == {place} } {
  if { $STEP == {pre} } {
    #do this just before place_opt
    clear_setup -place_group
    group_path -name Inputs -from [ all_inputs ] 
    group_path -name Outputs -to [ all_outputs  ]
    set_clock_latency -source 0 [get_ports {sclk}]
    puts "group_path mods done"
    source scripts/N3E_params.tcl
    source scripts/vt_stamping.tcl
    #source /google/gchips/workspace/collab-mentor/tpe/user/pavankumarram/rapidsw/testrun3/dontuse.tcl
    #swap_vt -from_vt_level 3 -to_vt_level 4
    #swap_vt -from_vt_level 2 -to_vt_level 3
    #swap_vt -from_vt_level 1 -to_vt_level 2
    #set_property [get_lib_cells * -filter vth_level==1] dont_use_in_opt 1
    set_param db no_routing_on_m0 false
    #source cellswap.tcl
#    set_property [get_lib_cells * -filter full_hier_name=~*D0P5*] dont_use_in_opt 1
  }

  if { $STEP == {post} } {
    #do this after place_opt
  }
} 

if { $PHASE == {cts} } {
  if { $STEP == {pre} } {
    #do this just before cts
    source scripts/N3E_params.tcl
    set_param db no_routing_on_m0 false
  }

  if { $STEP == {post} } {
    #do this after cts
  }
} 

if { $PHASE == {cts_opt} } {
  if { $STEP == {pre} } {
    #do this just before cts_opt
    source scripts/N3E_params.tcl
    set_param db no_routing_on_m0 false

  }

  if { $STEP == {post} } {
    #do this after cts_opt

  }
} 

if { $PHASE == {route} } {
  if { $STEP == {pre} } {
    #do this just before route_opt
    source scripts/N3E_params.tcl
    set_param db no_routing_on_m0 false
    set_param route save_snapshot true
	 #source corr_params.tcl

  }

  if { $STEP == {post} } {
    #do this after route_opt

  }
}

if { $PHASE == {filler} } {
  if { $STEP == {pre} } {
    #do this just before dcap and filler insertion

  }

  if { $STEP == {post} } {
    #do this after filler insertion

  }
}

if { $PHASE == {export} } {
  if { $STEP == {pre} } {
    #do this just before export

  }

  if { $STEP == {post} } {
    #do this after export

  }
}

