# This is a library of useful functions to include at the top of an SDC file.

proc walk_to_pin {type mainnode {depth 100}} {
	if { $type == "fanout" } {
		set edgename "-fanout_edges"
		set srcdst "-dst"
	} elseif { $type == "clock" } {
		set edgename "-clock_edges"
		set srcdst "-src"
	} elseif { $type == "fanin" } {
		set edgename "-synch_edges"
		set srcdst "-src"
	}
	set fanout [get_node_info $edgename $mainnode]
	foreach edge $fanout {
		set node [get_edge_info $srcdst $edge]
		if { [get_node_info -type $node] == "port" } {
			return $node
		}
		set node_type [get_node_info -type $node]
		if {$depth > 0 && ($node_type == "comb" || $node_type == "pin")} {
			#puts "walking down [get_node_info -name $node] [get_node_info -type $node]..."
			set res [walk_to_pin $type $node [expr {$depth - 1}]]
			if { $res != "" } {
				return $res
			}
		} else {
			#puts "ignoring node [get_node_info -name $node] of type [get_node_info -type $node]"
		}
	}
	return ""
}

# Like walk_to_pin, but searches out in a tree if the 
# pin drives multiple ports
proc walk_to_all_pins {type collection {depth 100}} {
	if { $type == "fanout" } {
		set edgename "-fanout_edges"
		set srcdst "-dst"
	} elseif { $type == "clock" } {
		set edgename "-clock_edges"
		set srcdst "-src"
	} elseif { $type == "fanin" } {
		set edgename "-synch_edges"
		set srcdst "-src"
	}
	set res [list]
	foreach_in_collection mainnode $collection {
		set fanout [get_node_info $edgename $mainnode]
		foreach edge $fanout {
			set node [get_edge_info $srcdst $edge]
			if { [get_node_info -type $node] == "port" } {
				lappend res $node
			}
			set node_type [get_node_info -type $node]
			if {$depth > 0 && ($node_type == "comb" || $node_type == "pin")} {
				#puts "walking down [get_node_info -name $node] [get_node_info -type $node]..."
				set r [walk_to_pin $type $node [expr {$depth - 1}]]
				set res [concat $res $r] 
			} else {
				#puts "ignoring node [get_node_info -name $node] of type [get_node_info -type $node]"
			}
		}
	}
	return $res
}


# (map walk_to_pin)
proc walk_to_pins { type collection {depth 100} } {
	set res [list]
	foreach_in_collection c $collection {
		set i [walk_to_pin $type $c $depth]
		if { $i == "" } {
			#puts "Node [get_node_info -name $c] was a dead end"
		} else {
			#puts "Got port for node [get_node_info -name $c]"
			lappend res $i
		}
	}
	#puts "walk_to_pins returning: $res"
	return $res
}

# (map get_node_info -name)
proc map_get_node_name {nodes} {
	set res [list]
	foreach n $nodes {
		lappend res [get_node_info -name $n]
	}
	return $res
}

proc get_all_dqs_pins { dqsgroups} { 
	set res [list]
	foreach dqsgroup $dqsgroups {
		lappend res [lindex $dqsgroup 0]
	}
	return $res
}

proc get_all_dq_pins { dqsgroups} { 
	set res [list]
	foreach dqsgroup $dqsgroups {
		set res [concat $res [lindex $dqsgroup 2]]
	}
	return $res
}

proc get_all_dm_pins { dqsgroups} { 
	set res [list]
	foreach dqsgroup $dqsgroups {
		set res [concat $res [lindex $dqsgroup 1]]
	}
	return $res
}


proc list_collection { col } {
	set res "("
	foreach_in_collection c $col {
		append res "[get_node_info -name $c]\n"
	}
	append res ")"
	return $res
}

proc sett_collection { vlist col } {
	set i 0
	set len [llength $vlist]
	foreach_in_collection c $col {
		if { $i < $len } {
			upvar 1 [lindex $vlist $i] x
			set x $c
			incr i
		} else {
			error "Too many items in collection ([expr {$i+1}]) for list $vlist"
		}
	}
	if { $i != $len } {
		error "Too Few items in collection ($i) for list $vlist"
	}
}

# For static deskew, get the frequency range of the given configuration
# Return triplet {mode min_freq max_freq}
proc get_deskew_freq_range {timing_params period} {
	set mode [list]
	# freq_range list should be sorted from low to high
	if {[lindex $timing_params 2] == "STATIC_DESKEW_8" || [lindex $timing_params 2] == "STATIC_DESKEW_10"}  {
		# These modes have more than 2 freq ranges
		set range_list [list LOW HIGH]
	} else {
		# Just 1 freq range
		set range_list [list [list]]
	}
	set freq_mode [list]
	foreach freq_range $range_list {
		if {[catch {get_micro_node_delay -micro MIN -parameters [concat $timing_params $freq_range]} min_freq] != 0 || $min_freq == "" ||
			[catch {get_micro_node_delay -micro MAX -parameters [concat $timing_params $freq_range]} max_freq] != 0 || $max_freq == ""} {
			# Invalid mode
		} else {
			set max_freq_period [expr 1000.0 / $min_freq]
			set min_freq_period [expr 1000.0 / $max_freq]
			lappend freq_mode [list $freq_range $min_freq $max_freq]
			if {$period >= $min_freq_period && $period <= $max_freq_period} {
				set mode [lindex $freq_mode end]
				break
			}
		}
	}
	if {$mode == [list] && $freq_mode != [list]} {
		if {$period < $min_freq_period} {
			# Fastest mode
			set mode [lindex $freq_mode end]
		} else {
			# Slowest mode
			set mode [lindex $freq_mode 0]
		}
	}
	return $mode
}
# Return a tuple of the tCCS value for a given device
proc get_tccs { mem_if_memtype dqs_list period args} {
	global TimeQuestInfo
	array set options [list "-write_deskew" "none" "-dll_length" 0 "-config_period" 0 "-ddr3_discrete" 0]
	foreach {option value} $args {
		if {[array names options -exact "$option"] != ""} {
			set options($option) $value
		} else {
			error "ERROR: Unknown get_tccs option $option (with value $value; args are $args)"
		}
	}

	set interface_type [get_io_interface_type $dqs_list]
	# The tCCS for a HYBRID interface is the same as a HPAD interface
	if {$interface_type == "VHPAD"} {
		set interface_type "HPAD"
	}
	set io_std [get_io_standard [lindex $dqs_list 0]]
  	set result [list 0 0]
	if {$interface_type != "" && $interface_type != "UNKNOWN" && $io_std != "" && $io_std != "UNKNOWN"} {
		package require ::quartus::ddr_timing_model

		set tccs_params [list IO $interface_type]
		
		if {$options(-ddr3_discrete) == 1} {
			lappend tccs_params NONLEVELED
		
		} elseif {$options(-write_deskew) == "static"} {
		
			if {$options(-dll_length) != 0} {
				lappend tccs_params STATIC_DESKEW_$options(-dll_length)
			} else {
				# No DLL length dependency
				lappend tccs_params STATIC_DESKEW
			}
		} elseif {$options(-write_deskew) == "dynamic"} {
			lappend tccs_params DYNAMIC_DESKEW
		}
		if {$options(-ddr3_discrete) == 0 && $options(-write_deskew) != "none"} {
			set mode [get_deskew_freq_range $tccs_params $period]
			set expected_mode [get_deskew_freq_range $tccs_params $options(-config_period)]
			if {$mode == [list]} {
				post_message -type critical_warning "Memory interface with period $period and write $options(-write_deskew) deskew does not fall in a supported frequency range"
			} elseif {$expected_mode != $mode || $period < [expr 1000.0/[lindex $mode 2]] || $period > [expr 1000.0/[lindex $mode 1]]} {
				post_message -type critical_warning "Memory interface with clock frequency [expr 1000.0/$period] MHz is operating outside the frequency range of the megafunction configuration (expected frequency range is from [lindex $expected_mode 1] MHz to [lindex $expected_mode 2] MHz).  The timing analysis will not be accurate."
			} elseif {[lindex $mode 0] != [list]} {
				lappend tccs_params [lindex $mode 0]
			}
		}
		if {[catch {get_io_standard_node_delay -dst TCCS_LEAD -io_standard $io_std -parameters $tccs_params} tccs_lead] != 0 || $tccs_lead == "" || $tccs_lead == 0 || \
				[catch {get_io_standard_node_delay -dst TCCS_LAG -io_standard $io_std -parameters $tccs_params} tccs_lag] != 0 || $tccs_lag == "" || $tccs_lag == 0 } {
			set family $TimeQuestInfo(family)
			error "Missing $family timing model for tCCS of $io_std $tccs_params"
		} else {
			return [list $tccs_lead $tccs_lag]
		}
	}
}

# Return a tuple of setup,hold time for read capture
proc get_tsw { mem_if_memtype dqs_list period args} {
	global TimeQuestInfo
	array set options [list "-read_deskew" "none" "-dll_length" 0 "-config_period" 0 "-ddr3_discrete" 0]
	foreach {option value} $args {
		if {[array names options -exact "$option"] != ""} {
			set options($option) $value
		} else {
			error "ERROR: Unknown get_tsw option $option (with value $value; args are $args)"
		}
	}

	set interface_type [get_io_interface_type $dqs_list]
	set io_std [get_io_standard [lindex $dqs_list 0]]

	if {$interface_type != "" && $interface_type != "UNKNOWN" && $io_std != "" && $io_std != "UNKNOWN"} {
		package require ::quartus::ddr_timing_model
		set family $TimeQuestInfo(family)
		# The tSW for HYBRID DLL-based interfaces is the worst case of
		# VPAD and HPAD interfaces. Non-DLL-based interfaces have their own
		# VHPAD spec
		if {$interface_type == "VHPAD" && $options(-dll_length) > 0} {
			set interface_type_list [list VPAD HPAD]
		} else {
			set interface_type_list [list $interface_type]
		}
		set max_tsw_setup -999999
		set max_tsw_hold -999999
		foreach interface_type $interface_type_list {
			set tsw_params [list IO $interface_type]
			
			if {$options(-ddr3_discrete) == 1} {
				lappend tsw_params NONLEVELED
				
			} elseif {$options(-read_deskew) == "static"} {
				if {$options(-dll_length) != 0} {
					lappend tsw_params STATIC_DESKEW_$options(-dll_length)
				} else {
					# No DLL length dependency
					lappend tsw_params STATIC_DESKEW
				}
			} elseif {$options(-read_deskew) == "dynamic"} {
				lappend tsw_params DYNAMIC_DESKEW
			}
			if {$options(-ddr3_discrete) == 0 && $options(-read_deskew) != "none"} {
				set mode [get_deskew_freq_range $tsw_params $period]
				if {$mode == [list]} {
					post_message -type critical_warning "Memory interface with period $period and read $options(-read_deskew) deskew does not fall in a supported frequency range"
				} elseif {[lindex $mode 0] != [list]} {
					lappend tsw_params [lindex $mode 0]
				}
			}

			if {[catch {get_io_standard_node_delay -dst TSU -io_standard $io_std -parameters $tsw_params} tsw_setup] != 0 || $tsw_setup == "" || $tsw_setup == 0 || \
					[catch {get_io_standard_node_delay -dst TH -io_standard $io_std -parameters $tsw_params} tsw_hold] != 0 || $tsw_hold == "" || $tsw_hold == 0 } {
				error "Missing $family timing model for tSW of $io_std $tsw_params"
			} else {
				# Derate tSW for DDR2 on VPAD in CIII Q240 parts
				# The tSW for HPADs and for other interface types on C8 devices
				# have a large guardband, so derating for them is not required
				if {[get_part_info -package -pin_count $TimeQuestInfo(part)] == "PQFP 240"} {
					if {[catch {get_io_standard_node_delay -dst TSU -io_standard $io_std -parameters [list IO $interface_type Q240_DERATING]} tsw_setup_derating] != 0 || $tsw_setup_derating == 0 || \
							[catch {get_io_standard_node_delay -dst TH -io_standard $io_std -parameters [list IO $interface_type Q240_DERATING]} tsw_hold_derating] != 0 || $tsw_hold_derating == 0} {
						set f "$io_std/$interface_type/$family"
						switch -glob $f {
							"SSTL_18*/VPAD/Cyclone III"  {
								set tsw_setup_derating 50
								set tsw_hold_derating 135
							}
							"SSTL_18*/VPAD/Cyclone IV E"  {
								set tsw_setup_derating 50
								set tsw_hold_derating 135
							}							
							default {
								set tsw_setup_derating 0
								set tsw_hold_derating 0
							}
						}
					}
					incr tsw_setup $tsw_setup_derating
					incr tsw_hold $tsw_hold_derating
				}
				if {$tsw_setup > $max_tsw_setup} {
					set max_tsw_setup $tsw_setup
				}
				if {$tsw_hold > $max_tsw_hold} {
					set max_tsw_hold $tsw_hold
				}
			}
			return [list $max_tsw_setup $max_tsw_hold]
		}
	}
}

# Return a pseudo x36 derating tuple of setup,hold time for read capture
proc get_qdr_tsw_derating { dqs_list } { 
	global TimeQuestInfo
	set io_std [get_io_standard [lindex $dqs_list 0]]
	set interface_type [get_io_interface_type [lindex $dqs_list 0]]

	if {[catch {get_io_standard_node_delay -dst TSU -io_standard $io_std -parameters [list IO $interface_type PSEUDOX36]} tsw_setup] != 0 || $tsw_setup == "" || \
			[catch {get_io_standard_node_delay -dst TH -io_standard $io_std -parameters [list IO $interface_type PSEUDOX36]} tsw_hold] != 0 || $tsw_hold == "" || $tsw_hold == 0 } {
		set family $TimeQuestInfo(family)
		error "Missing $family timing model for derated tSW of $io_std $interface_type"
	} else {
		set result [list $tsw_setup $tsw_hold]
	}
	return $result
}

# Return a pseudo x36 derating tuple of setup,hold time for write capture
proc get_qdr_tccs_derating { dqs_list } { 
	set io_std [get_io_standard [lindex $dqs_list 0]]
	set interface_type [get_io_interface_type [lindex $dqs_list 0]]

	if {[catch {get_io_standard_node_delay -dst TCCS_LEAD -io_standard $io_std -parameters [list IO $interface_type PSEUDOX36]} tccs_lead] != 0 || $tccs_lead == "" || $tccs_lead == 0 || \
			[catch {get_io_standard_node_delay -dst TCCS_LAG -io_standard $io_std -parameters [list IO $interface_type PSEUDOX36]} tccs_lag] != 0 || $tccs_lag == "" || $tccs_lag == 0 } {
		set family $TimeQuestInfo(family)
		error "Missing $family timing model for derated tCCS of $io_std $interface_type"
	} else {
		set result [list $tccs_lead $tccs_lag]
	}

	return $result
}

proc round_3dp { x } {
	return [expr { round($x * 1000) / 1000.0  } ]
}

proc min { a b } {
	if { $a == "" } { 
		return $b
	} elseif { $a < $b } {
		return $a
	} else {
		return $b
	}
}

proc max { a b } {
	if { $a == "" } { 
		return $b
	} elseif { $a > $b } {
		return $a
	} else {
		return $b
	}
}

proc wrap_to_period {period t} {
	return [expr {fmod(fmod($t,$period) + $period,$period)}]
}

proc get_clock_latency {period clockname risefall } {
	set countclocks 0
	if { $risefall != "rise" && $risefall != "fall" } {
		error "Internal error: get_clock_latency risefall was $risefall expected \"rise\" or \"fall\""
	}
	foreach_in_collection c [get_clocks $clockname] { 
		set clock $c
		incr countclocks
	}
	if { $countclocks == 1 } {
		if { $risefall == "rise" } {
			set edge_index 0
		} elseif { $risefall == "fall" } {
			set edge_index 1
		} else {
			error "Unreachable in get_clock_latency"
		}
	} else {
		error "Internal error: Found $countclocks matching $clockname. Expected 1 in get_clock_latency"
	}
	set waveform [get_clock_info -waveform $clock]
	if {[llength $waveform] != 2 } {
		error "Internal error: Waveform for clock $clockname is \"$waveform\""
	}
	set latency [lindex $waveform $edge_index]
	set res [wrap_to_period $period $latency]
	return $res
}

# Same as get_clock_latency, but returns the clock phase (0<=x<360) normalised instead
proc get_clock_phase {period clockname risefall } {
	set countclocks 0
	if { $risefall != "rise" && $risefall != "fall" } {
		error "Internal error: get_clock_phase risefall was $risefall expected \"rise\" or \"fall\""
	}
	foreach_in_collection c [get_clocks $clockname] { 
		set clock $c
		incr countclocks
	}
	if { $countclocks == 1 } {
		if { $risefall == "rise" } {
			set offset 0
		} elseif { $risefall == "fall" } {
			set offset 180
		} else {
			error "Unreachable in get_clock_phase"
		}
	} else {
		error "Internal error: Found $countclocks matching $clockname. Expected 1 in get_clock_phase"
	}
	set phase [get_clock_info -phase $clock]
	set res [expr {fmod(($phase+$offset+360),360)}]
	return $res
}


proc expr_debug { exp } {
	upvar expr_debug_e expr_debug_e
	set expr_debug_e $exp
	uplevel {
	puts "-----------------"
	puts "[regsub -all {[\n \t]+} $expr_debug_e " "]"
	puts "-----------------"
	puts [regsub -all {[\n \t]+} [subst $expr_debug_e] " "]
	puts "-----------------"
	set expr_debug_temp [expr $expr_debug_e]
	puts "=$expr_debug_temp" 
	puts "-----------------"
	return $expr_debug_temp
	}
}

# Return all the ck output clocks in the current design of a given type and 
# inversion
# type - either tDSS/tDQSS/ac_rise/ac_fall
# pn - either p/n
proc get_output_clocks {type pn} {
	global ck_output_clocks
	return $ck_output_clocks(${type}-${pn})
}

proc add_output_clock {type pn clockname} {
	global ck_output_clocks
	if { ! [info exists ck_output_clocks(${type}-${pn})] } {
		set ck_output_clocks(${type}-${pn}) [list]
	} 
	lappend ck_output_clocks(${type}-${pn}) $clockname
}

# ----------------------------------------------------------------
#
proc get_timequest_name {hier_name} {
#
# Description:  Convert the full hierarchy name into a TimeQuest name
#
# ----------------------------------------------------------------
	set sta_name ""
	for {set inst_start [string first ":" $hier_name]} {$inst_start != -1} {} {
		incr inst_start
		set inst_end [string first "|" $hier_name $inst_start]
		if {$inst_end == -1} {
			append sta_name [string range $hier_name $inst_start end]
			set inst_start -1
		} else {
			append sta_name [string range $hier_name $inst_start $inst_end]
			set inst_start [string first ":" $hier_name $inst_end]
		}
	}
	return $sta_name
}

# ----------------------------------------------------------------
#
proc get_core_instance_list {corename} {
#
# Description:  Get a list of all ALTMEMPHY instances in TimeQuest
#
# ----------------------------------------------------------------
	set full_instance_list [get_core_full_instance_list $corename]
	set instance_list [list]

	foreach inst $full_instance_list {
		set sta_name [get_timequest_name $inst]
		if {[lsearch $instance_list [escape_brackets $sta_name]] == -1} {
			lappend instance_list $sta_name
		}
	}
	return $instance_list
}

# ----------------------------------------------------------------
#
proc get_core_full_instance_list {corename} {
#
# Description:  Get a list of all ALTMEMPHY instances (full hierarchy names)
#               in TimeQuest
#
# ----------------------------------------------------------------
	set instance_list [list]

	# Look for a keeper (register) name
	# Try mem_clk[0] to determine core instances
	set search_list [list "*"]
	set found 0
	for {set i 0} {$found == 0 && $i != [llength $search_list]} {incr i} {
		set pattern [lindex $search_list $i]
		set instance_collection [get_keepers -nowarn "*|${corename}:*|$pattern"]
		if {[get_collection_size $instance_collection] == 0} {
			set instance_collection [get_keepers "${corename}:*|$pattern"]
		}
		if {[get_collection_size $instance_collection] > 0} {
			set found 1
		}
	}
	# regexp to extract the full hierarchy path of an instance name
	set inst_regexp {(^.*}
	append inst_regexp ${corename}
	append inst_regexp {:[A-Za-z0-9\.\\_\[\]\-\$():]+)\|}
	foreach_in_collection inst $instance_collection {
		set name [get_node_info -name $inst]
		if {[regexp -- $inst_regexp $name -> hier_name] == 1} {
			if {[lsearch $instance_list [escape_brackets $hier_name]] == -1} {
				lappend instance_list $hier_name
			}
		}
	}
	return $instance_list
}

# ----------------------------------------------------------------
#
proc traverse_fanin_up_to_depth { node_id match_command edge_type results_array_name depth} {
#
# Description: Recurses through the timing netlist starting from the given
#              node_id through edges of type edge_type to find nodes
#              satisfying match_command.
#              Recursion depth is bound to the specified depth.
#              Adds the resulting TDB node ids to the results_array.
#
# ----------------------------------------------------------------
	upvar 1 $results_array_name results

	if {$depth < 0} {
		error "Internal error: Bad timing netlist search depth"
	}
	set fanin_edges [get_node_info -${edge_type}_edges $node_id]
	set number_of_fanin_edges [llength $fanin_edges]
	for {set i 0} {$i != $number_of_fanin_edges} {incr i} {
		set fanin_edge [lindex $fanin_edges $i]
		set fanin_id [get_edge_info -src $fanin_edge]
		if {$match_command == "" || [eval $match_command $fanin_id] != 0} {
			set results($fanin_id) 1
		} elseif {$depth == 0} {
			# Max recursion depth
		} else {
			traverse_fanin_up_to_depth $fanin_id $match_command $edge_type results [expr "$depth - 1"]
		}
	}
}

# ----------------------------------------------------------------
#
proc is_node_type_pll_inclk { node_id } {
#
# Description: Given a node, tells whether or not it is a PLL clk
#
# ----------------------------------------------------------------
	set cell_id [get_node_info -cell $node_id]
	set atom_type [get_cell_info -atom_type $cell_id]
	if {$atom_type == "PLL"} {
		set node_name [get_node_info -name $node_id]
		set fanin_edges [get_node_info -clock_edges $node_id]
		# The inclk input should have a |inclk or |inclk[0] suffix
		if {([string match "*|inclk" $node_name] || [string match "*|inclk\\\[0\\\]" $node_name]) && [llength $fanin_edges] > 0} {
			set result 1
		} else {
			set result 0
		}
	} else {
		set result 0
	}

	return $result
}

# ----------------------------------------------------------------
#
proc is_node_type_pin { node_id } {
#
# Description: Given a node, tells whether or not it is a reg
#
# ----------------------------------------------------------------
	set node_type [get_node_info -type $node_id]
	if {$node_type == "port"} {
		set result 1
	} else {
		set result 0
	}
	return $result
}

# ----------------------------------------------------------------
#
proc get_input_clk_id { pll_output_node_id } {
#
# Description: Given a PLL clock output node, gets the PLL clock input node
#
# ----------------------------------------------------------------
	if {[is_node_type_pll_clk $pll_output_node_id]} {
		array set results_array [list]
		traverse_fanin_up_to_depth $pll_output_node_id is_node_type_pll_inclk clock results_array 1
		if {[array size results_array] == 1} {
			# Found PLL inclk, now find the input pin
			set pll_inclk_id [lindex [array names results_array] 0]
			array unset results_array
			# If fed by a pin, it should be fed by a dedicated input pin,
			# and not a global clock network.  Limit the search depth to
			# prevent finding pins fed by global clock (only allow io_ibuf pins)
			traverse_fanin_up_to_depth $pll_inclk_id is_node_type_pin clock results_array 3
			if {[array size results_array] == 1} {
				# Fed by a dedicated input pin
				set pin_id [lindex [array names results_array] 0]
				set result $pin_id
			} else {
				traverse_fanin_up_to_depth $pll_inclk_id is_node_type_pll_clk clock pll_clk_results_array 1
				if {[array size pll_clk_results_array] == 1} {
					# Fed by a neighboring PLL via cascade path.
					# Should be okay as long as that PLL has its input clock
					# fed by a dedicated input.  If there isn't, TimeQuest will give its own warning about undefined clocks.
					set source_pll_clk_id [lindex [array names pll_clk_results_array] 0]
					set source_pll_clk [get_node_info -name $source_pll_clk_id]
					if {[get_input_clk_id $source_pll_clk_id] != -1} {
						post_message -type info "Please ensure source clock is defined for PLL with output $source_pll_clk"
					} else {
						# Fed from core
						post_message -type critical_warning "PLL clock $source_pll_clk not driven by a dedicated clock pin.  To ensure minimum jitter on memory interface clock outputs, the PLL clock source should be a dedicated PLL input clock pin."
					}
					set result -1
				} else {
					# Fed from core
					post_message -type critical_warning "PLL clock [get_node_info -name $pll_output_node_id] not driven by a dedicated clock pin or neighboring PLL source.  To ensure minimum jitter on memory interface clock outputs, the PLL clock source should be a dedicated PLL input clock pin or an output of the neighboring PLL."
					set result -1
				}
			}
		} else {
			post_message -type critical_warning "Could not find PLL clock for [get_node_info -name $pll_output_node_id]"
			set result -1
		}
	} else {
		error "Internal error: get_input_clk_id only works on PLL output clocks"
	}
	return $result
}

# ----------------------------------------------------------------
#
proc is_node_type_pll_clk { node_id } {
#
# Description: Given a node, tells whether or not it is a PLL clk
#
# ----------------------------------------------------------------
	set cell_id [get_node_info -cell $node_id]
	set atom_type [get_cell_info -atom_type $cell_id]
	if {$atom_type == "PLL"} {
		set node_name [get_node_info -name $node_id]
		if {[string match "*|clk\\\[*\\\]" $node_name]} {
			set result 1
		} else {
			set result 0
		}
	} else {
		set result 0
	}

	return $result
}

# ----------------------------------------------------------------
#
proc get_pll_clock { dest_id_list node_type clock_id_name search_depth} {
#
# Description: Look for the PLL output clocking the given nodes
#
# ----------------------------------------------------------------
	if {$clock_id_name != ""} {
		upvar 1 $clock_id_name clock_id
	}
	set clock_id -1

	array set clk_array [list]
	foreach node_id $dest_id_list {
		traverse_fanin_up_to_depth $node_id is_node_type_pll_clk clock clk_array $search_depth
	}
	if {[array size clk_array] == 1} {
		set clock_id [lindex [array names clk_array] 0]
		set clk [get_node_info -name $clock_id]
	} elseif {[array size clk_array] > 1} {
		puts "Found more than 1 clock driving the $node_type"
		set clk ""
	} else {
		set clk ""
		#puts "Could not find $node_type clock"
	}

	return $clk
}

# ----------------------------------------------------------------
#
proc get_output_clock_id { ddio_output_pin_list pin_type msg_list_name {max_search_depth 13} } {
#
# Description: Look for the PLL output clocks of the given pins
#
# ----------------------------------------------------------------
	upvar 1 $msg_list_name msg_list
	set output_clock_id -1
	
	set output_id_list [list]
	set pin_collection [get_keepers $ddio_output_pin_list]
	if {[get_collection_size $pin_collection] == [llength $ddio_output_pin_list]} {
		foreach_in_collection id $pin_collection {
			lappend output_id_list $id
		}
	} elseif {[get_collection_size $pin_collection] == 0} {
		lappend msg_list "warning" "Could not find any $pin_type pins"
	} else {
		lappend msg_list "warning" "Could not find all $pin_type pins"
	}
	get_pll_clock $output_id_list $pin_type output_clock_id $max_search_depth
	return $output_clock_id
}

# ----------------------------------------------------------------
#
proc is_node_type_io_clock_divider_clkout { node_id } {
#
# Description: Given a node, tells whether or not it is a I/O clock divider clk
#
# ----------------------------------------------------------------
	set cell_id [get_node_info -cell $node_id]
	set atom_type [get_cell_info -atom_type $cell_id]
	if {$atom_type == "IO_CLOCK_DIVIDER"} {
		set node_name [get_node_info -name $node_id]
		set fanout_edges [get_node_info -fanout_edges $node_id]
		if {[string match "*|clkout" $node_name] && [llength $fanout_edges] > 0} {
			set result 1
		} else {
			set result 0
		}
	} else {
		set result 0
	}

	return $result
}

# ----------------------------------------------------------------
#
proc post_sdc_message {msg_type msg} {
#
# Description: Posts a message in TimeQuest, but not in Fitter
#              The SDC is read mutliple times during compilation, so we'll wait
#              until final TimeQuest timing analysis to display messages
#
# ----------------------------------------------------------------
	if { $::TimeQuestInfo(nameofexecutable) != "quartus_fit"} {
		post_message -type $msg_type $msg
	}
}

# ----------------------------------------------------------------
#
proc get_report_column { report_id str} {
#
# Description: Gets the report column index with the given header string
#
# ----------------------------------------------------------------
	set target_col [get_report_panel_column_index -id $report_id $str]
	if {$target_col == -1} {
		error "Cannot find $str column"
	}
	return $target_col
}

# ----------------------------------------------------------------
#
proc get_fitter_report_pin_info_from_report {target_pin info_type pin_report_id} {
#
# Description: Gets the report field for the given pin in the given report
#
# ----------------------------------------------------------------
	set pin_name_column [get_report_column $pin_report_id "Name"]
	set info_column [get_report_column $pin_report_id $info_type]
	set result ""

	if {$pin_name_column == 0 && 0} {
		set row_index [get_report_panel_row_index -id $pin_report_id $target_pin]
		if {$row_index != -1} {
			set row [get_report_panel_row -id $pin_report_id -row $row_index]
			set result [lindex $row $info_column]
		}
	} else {
		set report_rows [get_number_of_rows -id $pin_report_id]
		for {set row_index 1} {$row_index < $report_rows && $result == ""} {incr row_index} {
			set row [get_report_panel_row -id $pin_report_id -row $row_index]
			set pin [lindex $row $pin_name_column]
			if {$pin == $target_pin} {
				set result [lindex $row $info_column]
			}
		}
	}
	return $result
}

# ----------------------------------------------------------------
#
proc get_fitter_report_pin_info {target_pin info_type preferred_report_id {found_report_id_name ""}} {
#
# Description: Gets the report field for the given pin by searching through the
#              input, output and bidir pin reports
#
# ----------------------------------------------------------------
	if {$found_report_id_name != ""} {
		upvar 1 $found_report_id_name found_report_id
	}
	set found_report_id -1
	set result ""
	if {$preferred_report_id == -1} {
		set pin_report_list [list "Fitter||Resource Section||Bidir Pins" "Fitter||Resource Section||Input Pins" "Fitter||Resource Section||Output Pins"]
		for {set pin_report_index 0} {$pin_report_index != [llength $pin_report_list] && $result == ""} {incr pin_report_index} {
			set pin_report_id [get_report_panel_id [lindex $pin_report_list $pin_report_index]]
			if {$pin_report_id != -1} {
				set result [get_fitter_report_pin_info_from_report $target_pin $info_type $pin_report_id]
				if {$result != ""} {
					set found_report_id $pin_report_id
				}
			}
		}
	} else {
		set result [get_fitter_report_pin_info_from_report $target_pin $info_type $preferred_report_id]
		if {$result != ""} {
			set found_report_id $preferred_report_id
		}
	}
	return $result
}
# ----------------------------------------------------------------
#
proc get_io_interface_type {pin_list} {
#
# Description: Gets the type of pin that the given pins are placed on
#              either (HPAD, VPAD, VHPAD, "", or UNKNOWN).
#              "" is returned if pin_list is empty
#              UNKNOWN is returned if an error was encountered
#              This function assumes the fitter has already completed and the
#              compiler report has been loaded.
#
# ----------------------------------------------------------------
	set preferred_report_id -1
	set interface_type ""
	foreach target_pin $pin_list {
		set io_bank [get_fitter_report_pin_info $target_pin "I/O Bank" $preferred_report_id preferred_report_id]
		if {[regexp -- {^([0-9]+)[A-Z]*} $io_bank -> io_bank_number]} {
			if {$io_bank_number == 1 || $io_bank_number == 2 || $io_bank_number == 5 || $io_bank_number == 6} {
				# Row I/O
				if {$interface_type == ""} {
					set interface_type "HPAD"
				} elseif {$interface_type == "VPAD"} {
					set interface_type "VHPAD"
				}
			} elseif {$io_bank_number == 3 || $io_bank_number == 4 || $io_bank_number == 7 || $io_bank_number == 8} {
				if {$interface_type == ""} {
					set interface_type "VPAD"
				} elseif {$interface_type == "HPAD"} {
					set interface_type "VHPAD"
				}
			} else {
				post_message -type critical_warning "Unknown I/O bank $io_bank for pin $target_pin"
				# Asuume worst case performance (mixed HIO/VIO interface)
				set interface_type "VHPAD"
			}
		}
	}
	return $interface_type
}

# ----------------------------------------------------------------
#
proc get_io_standard {target_pin} {
#
# Description: Gets the I/O standard of the given memory interface pin
#              This function assumes the fitter has already completed and the
#              compiler report has been loaded.
#
# ----------------------------------------------------------------
	# Look through the pin report
	set io_std [get_fitter_report_pin_info $target_pin "I/O Standard" -1]
	if {$io_std == ""} {
		return "UNKNOWN"
	}
	set result ""
	switch  -exact -- $io_std {
        "SSTL-2 Class I" {set result "SSTL_2_I"}
		"Differential 2.5-V SSTL Class I" {set result "DIFF_SSTL_2_I"}
        "SSTL-2 Class II" {set result "SSTL_2_II"}
		"Differential 2.5-V SSTL Class II" {set result "DIFF_SSTL_2_II"}
        "SSTL-18 Class I" {set result "SSTL_18_I"}
		"Differential 1.8-V SSTL Class I" {set result "DIFF_SSTL_18_I"}
        "SSTL-18 Class II" {set result "SSTL_18_II"}
		"Differential 1.8-V SSTL Class II" {set result "DIFF_SSTL_18_II"}
        "SSTL-15 Class I" {set result "SSTL_15_I"}
		"Differential 1.5-V SSTL Class I" {set result "DIFF_SSTL_15_I"}
        "SSTL-15 Class II" {set result "SSTL_15_II"}
		"Differential 1.5-V SSTL Class II" {set result "DIFF_SSTL_15_II"}
        "1.8-V HSTL Class I" {set result "HSTL_18_I"}
		"Differential 1.8-V HSTL Class I" {set result "DIFF_HSTL_18_I"}
        "1.8-V HSTL Class II" {set result "HSTL_18_II"}
		"Differential 1.8-V HSTL Class II" {set result "DIFF_HSTL_18_II"}
        "1.5-V HSTL Class I" {set result "HSTL_I"}
		"Differential 1.5-V HSTL Class I" {set result "DIFF_HSTL"}
        "1.5-V HSTL Class II" {set result "HSTL_II"}
		"Differential 1.5-V HSTL Class II" {set result "DIFF_HSTL_II"}
		default {
			post_message -type error "Found unsupported Memory I/O standard $io_std on pin $target_pin"
			set result "UNKNOWN"
		}
	}
	return $result
}

# ----------------------------------------------------------------
#
proc get_input_oct_termination {target_pin} {
#
# Description: Tells whether or not the given memory interface pin uses OCT
#              This function assumes the fitter has already completed and the
#              compiler report has been loaded.
#
# ----------------------------------------------------------------
	# Look through the pin reports
	set pin_report_id [get_report_panel_id "Fitter||Resource Section||Bidir Pins"]
	# Look through the output and bidir pin reports
	if {$pin_report_id == -1} {
		set termination ""
	} else {
		set termination [get_fitter_report_pin_info $target_pin "Input Termination" $pin_report_id]
	}
	if {$termination == ""} {
		set pin_report_id [get_report_panel_id "Fitter||Resource Section||Input Pins"]
		set termination [get_fitter_report_pin_info $target_pin "Termination" $pin_report_id]
		if {$termination == ""} {
			return "UNKNOWN"
		}
	}
	set result "OCT_OFF"
	switch -exact -glob -- $termination {
		"Off" {set result "OCT_OFF"}
		"OCT*" {set result "OCT_ON"}
		"Parallel *" {set result "OCT_ON"}
		default {
			post_message -type critical_warning "Found unsupported memory pin input termination $termination on pin $target_pin"
			set result "UNKNOWN"
		}
	}
	return $result
}

# ----------------------------------------------------------------
#
proc get_output_oct_termination {target_pin} {
#
# Description: Tells whether or not the given memory interface pin uses OCT
#              This function assumes the fitter has already completed and the
#              compiler report has been loaded.
#
# ----------------------------------------------------------------
	set pin_report_id [get_report_panel_id "Fitter||Resource Section||Bidir Pins"]
	# Look through the output and bidir pin reports
	if {$pin_report_id == -1} {
		set termination ""
	} else {
		set termination [get_fitter_report_pin_info $target_pin "Output Termination" $pin_report_id]
	}
	if {$termination == ""} {
		set pin_report_id [get_report_panel_id "Fitter||Resource Section||Output Pins"]
		set termination [get_fitter_report_pin_info $target_pin "Termination" $pin_report_id]
		if {$termination == ""} {
			return "UNKNOWN"
		}
	}
	set result "OCT_OFF"
	switch -exact -glob -- $termination {
		"Off" {set result "OCT_OFF"}
		"OCT*" {set result "OCT_ON"}
		"Series *" {set result "OCT_ON"}
		default {
			post_message -type critical_warning "Found unsupported memory pin output termination $termination on pin $target_pin"
			set result "UNKNOWN"
		}
	}
	return $result
}



proc min_in_collection { col attribute } {
	set i 0
	set min 0
	foreach_in_collection path $col {
		if {$i == 0} {
			set min [get_path_info $path -${attribute}]
		} else {
			set temp [get_path_info $path -${attribute}]
			if {$temp < $min} {
				set min $temp
			} 
		}
		set i [expr $i + 1]
	}
	return $min
}

proc max_in_collection { col attribute } {
	set i 0
	set max 0
	foreach_in_collection path $col {
		if {$i == 0} {
			set max [get_path_info $path -${attribute}]
		} else {
			set temp [get_path_info $path -${attribute}]
			if {$temp > $max} {
				set max $temp
			} 
		}
		set i [expr $i + 1]
	}
	return $max
}

proc get_index_in_collection { col attribute index} {
	set i 0
	foreach_in_collection path $col {
		if {$i == $index} {
			set result [get_path_info $path -${attribute}]
		} 
		set i [expr $i + 1]
	}
	return $result
}



# ----------------------------------------------------------------
proc get_ddr_pins {instname pins_array_name} {
#
# ----------------------------------------------------------------
	upvar 1 $pins_array_name pins
	set corename "ram_phy"
	array unset pins_t

	set dqsgroups 2

	for {set i 0} {$i < $dqsgroups} {incr i} {
		set dqs ${instname}_alt_mem_phy_inst|dpio|dqs\[$i\].dqs_ddio_out|dataout
		set dq  ${instname}_alt_mem_phy_inst|dpio|dqs_group\[$i\].dq\[*\].dq_ddio_out|dataout
		set dm  ${instname}_alt_mem_phy_inst|dpio|dm\[$i\].dm_ddio_out|dataout

		set dqs_p [map_get_node_name [walk_to_pins fanout [get_pins -compatibility_mode $dqs]]]
		if { [llength $dqs_p] != 1} { post_sdc_message critical_warning "Could not find DQS pin number $i" } 

		set dqsn_p [list]

		set dm_p  [map_get_node_name [walk_to_pins fanout [get_pins -compatibility_mode $dm]]]
		if { [llength $dm_p] != 1} { post_sdc_message critical_warning "Could not find DM pin for DQS pin number $i" } 

		set dq_p  [map_get_node_name [walk_to_pins fanout [get_pins -compatibility_mode $dq]]]
		if { [llength $dq_p] != 8} { post_sdc_message critical_warning "Could not find correct number of DQ pins for DQS pin $i. Found [llength $dq_p] pins. Expecting 8." } 

		set dqsgroup [list [lindex $dqs_p 0] $dm_p [lsort $dq_p] [lindex $dqsn_p 0]]
		lappend pins_t(dqsgroup) $dqsgroup
	}

	set patterns [list]
lappend patterns addrcmd_2t ${instname}_alt_mem_phy_inst|*adc*|addr\[*\].addr_struct|half_rate.addr_pin|auto_generated|ddio_outa\[*\]|dataout
lappend patterns addrcmd_2t ${instname}_alt_mem_phy_inst|*adc*|ba\[*\].ba_struct|half_rate.addr_pin|auto_generated|ddio_outa\[*\]|dataout
lappend patterns addrcmd_2t ${instname}_alt_mem_phy_inst|*adc*|cas_n_struct|half_rate.addr_pin|auto_generated|ddio_outa\[*\]|dataout
lappend patterns addrcmd_2t ${instname}_alt_mem_phy_inst|*adc*|ras_n_struct|half_rate.addr_pin|auto_generated|ddio_outa\[*\]|dataout
lappend patterns addrcmd_2t ${instname}_alt_mem_phy_inst|*adc*|we_n_struct|half_rate.addr_pin|auto_generated|ddio_outa\[*\]|dataout
lappend patterns addrcmd    ${instname}_alt_mem_phy_inst|*adc*|cke\[*\].cke_struct|half_rate.addr_pin|auto_generated|ddio_outa\[0\]|dataout
lappend patterns addrcmd    ${instname}_alt_mem_phy_inst|*adc*|gen_odt.odt\[*\].odt_struct|half_rate.addr_pin|auto_generated|ddio_outa\[0\]|dataout
lappend patterns addrcmd    ${instname}_alt_mem_phy_inst|*adc*|cs_n\[*\].cs_n_struct|half_rate.addr_pin|auto_generated|ddio_outa\[0\]|dataout
lappend patterns ck_p ${instname}_alt_mem_phy_inst|clk|DDR_CLK_OUT\[*\].ddr_clk_out_p|auto_generated|ddio_outa\[*\]|dataout
lappend patterns ck_n ${instname}_alt_mem_phy_inst|clk|DDR_CLK_OUT\[*\].ddr_clk_out_n|auto_generated|ddio_outa\[*\]|dataout

	foreach {pin_type pattern} $patterns { 
		set ports [map_get_node_name [walk_to_pins fanout [get_pins -compatibility_mode $pattern]]]
		if {[llength $ports] == 0} {
			post_message -type critical_warning "Could not find pin of type $pin_type from pattern $pattern"
		} else {
			foreach port [lsort -unique $ports] {
				lappend pins_t($pin_type) $port
			}
		}
	}

	set outputFileName "ram_phy_autodetectedpins.tcl"
	set f [open $outputFileName w]

	foreach {k v} [array get pins_t] {
		foreach vi $v {
			ddr_pin $k  $vi pins
			puts $f "ddr_pin [list $k] [list $vi] pins"
		}
	}
	close $f
}

set ram_phy_use_high_performance_timing 1
if {[namespace which -variable ::override_ram_phy_use_high_performance_timing] != ""} {
	set ram_phy_use_high_performance_timing $::override_ram_phy_use_high_performance_timing
}
