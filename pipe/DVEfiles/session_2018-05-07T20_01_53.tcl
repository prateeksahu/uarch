# Begin_DVE_Session_Save_Info
# DVE reload session
# Saved on Mon May 7 20:01:53 2018
# Designs open: 1
#   V1: /home/ecelrc/students/psahu/382N/uarch/pipe/testbench/test_pipe.dump.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: test_pipe
#   Wave.1: 126 signals
#   Group count = 1
#   Group wb signal count = 126
# End_DVE_Session_Save_Info

# DVE version: K-2015.09-SP1_Full64
# DVE build date: Nov 24 2015 21:15:24


#<Session mode="Reload" path="/home/ecelrc/students/psahu/382N/uarch/pipe/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Reload
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all
gui_clear_window -type Wave
gui_clear_window -type List

# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

set TopLevel.1 TopLevel.1

# Docked window settings
set HSPane.1 HSPane.1
set Hier.1 Hier.1
set DLPane.1 DLPane.1
set Data.1 Data.1
set Console.1 Console.1
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 Source.1
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

set TopLevel.2 TopLevel.2

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 Wave.1
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 539} {child_wave_right 1315} {child_wave_colname 267} {child_wave_colvalue 267} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings


#</WindowLayout>

#<Database>

# DVE Open design session: 

if { ![gui_is_db_opened -db {/home/ecelrc/students/psahu/382N/uarch/pipe/testbench/test_pipe.dump.vpd}] } {
	gui_open_db -design V1 -file /home/ecelrc/students/psahu/382N/uarch/pipe/testbench/test_pipe.dump.vpd -nosource
}
gui_set_precision 10ps
gui_set_time_units 10ps
#</Database>

# DVE Global setting session: 


# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {test_pipe.be.wb}


set _session_group_1 wb
gui_sg_create "$_session_group_1"
set wb "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { test_pipe.be.wb.gpr_data test_pipe.be.wb.segr_data test_pipe.be.wb.xmm_data test_pipe.be.wb.mem_data test_pipe.be.wb.gpr_dr test_pipe.be.wb.seg_dr test_pipe.be.wb.xmm_dr test_pipe.be.wb.mem_addr test_pipe.be.wb.grpWen test_pipe.be.wb.segWen test_pipe.be.wb.xmmWen test_pipe.be.wb.EIP test_pipe.be.wb.EFlag test_pipe.be.wb.mem_size test_pipe.be.wb.opSize test_pipe.be.wb.i_v test_pipe.be.wb.memWen test_pipe.be.wb.cachable test_pipe.be.wb.wrV test_pipe.be.wb.v test_pipe.be.wb.stall test_pipe.be.wb.wbR test_pipe.be.wb.o_inv test_pipe.be.wb.memWrV1 test_pipe.be.wb.memWrV2 test_pipe.be.wb.i_cachable test_pipe.be.wb.i_CS test_pipe.be.wb.i_data1 test_pipe.be.wb.i_data2 test_pipe.be.wb.i_EIP test_pipe.be.wb.i_nEIP test_pipe.be.wb.i_PA1 test_pipe.be.wb.i_PA2 test_pipe.be.wb.i_PA3 test_pipe.be.wb.i_PA4 test_pipe.be.wb.i_size1 test_pipe.be.wb.i_size2 test_pipe.be.wb.i_eflags test_pipe.be.wb.i_opSize test_pipe.be.wb.i_dr1 test_pipe.be.wb.i_dr2 test_pipe.be.wb.i_drSeg test_pipe.be.wb.i_spill test_pipe.be.wb.i_Dflag test_pipe.be.wb.clk test_pipe.be.wb.rst test_pipe.be.wb.istall test_pipe.be.wb.empty test_pipe.be.wb.dr1Wen test_pipe.be.wb.dr2Wen test_pipe.be.wb.segDWen test_pipe.be.wb.xmmOp test_pipe.be.wb.uOpNo test_pipe.be.wb.aluOp test_pipe.be.wb.r1Ren test_pipe.be.wb.r2Ren test_pipe.be.wb.segR1Ren test_pipe.be.wb.segR2Ren test_pipe.be.wb.memRen test_pipe.be.wb.passAB test_pipe.be.wb.lastuop test_pipe.be.wb.isJMP test_pipe.be.wb.isCALL test_pipe.be.wb.isPUSH test_pipe.be.wb.isPOP test_pipe.be.wb.isEXCH test_pipe.be.wb.isCMPE test_pipe.be.wb.isSIMD test_pipe.be.wb.isSAT test_pipe.be.wb.isSHUF test_pipe.be.wb.isDAA test_pipe.be.wb.isRET test_pipe.be.wb.flags_mod test_pipe.be.wb.flags_cmp test_pipe.be.wb.flags_used test_pipe.be.wb.isCMPS test_pipe.be.wb.interrupt test_pipe.be.wb.t1 test_pipe.be.wb.t2 test_pipe.be.wb.tstall test_pipe.be.wb.dr1w test_pipe.be.wb.dr2w test_pipe.be.wb.tworeg test_pipe.be.wb.zz test_pipe.be.wb.ntwomem test_pipe.be.wb.zo test_pipe.be.wb.oo test_pipe.be.wb.n_spill test_pipe.be.wb.n_memWen test_pipe.be.wb.cst test_pipe.be.wb.next test_pipe.be.wb.nst test_pipe.be.wb.drWen test_pipe.be.wb.grpWen_t test_pipe.be.wb.segWen_t test_pipe.be.wb.eq test_pipe.be.wb.sp1size test_pipe.be.wb.sp2size test_pipe.be.wb.spl1size test_pipe.be.wb.spl2size test_pipe.be.wb.ret1size test_pipe.be.wb.ret2size test_pipe.be.wb.data test_pipe.be.wb.st1Data test_pipe.be.wb.st2Data test_pipe.be.wb.st3Data test_pipe.be.wb.st4Data test_pipe.be.wb.data16 test_pipe.be.wb.uop0 test_pipe.be.wb.st1Sel test_pipe.be.wb.st2Sel test_pipe.be.wb.st3Sel test_pipe.be.wb.st4Sel test_pipe.be.wb.sel16 test_pipe.be.wb.t_PA1 test_pipe.be.wb.t_PA2 test_pipe.be.wb.t_PA3 test_pipe.be.wb.t_PA4 test_pipe.be.wb.data116 test_pipe.be.wb.data216 test_pipe.be.wb.wrVt test_pipe.be.wb.t3 test_pipe.be.wb.IDLE test_pipe.be.wb.TWOR test_pipe.be.wb.TWOM test_pipe.be.wb.TWOM_SP }
gui_set_radix -radix {decimal} -signals {V1:test_pipe.be.wb.IDLE}
gui_set_radix -radix {unsigned} -signals {V1:test_pipe.be.wb.IDLE}
gui_set_radix -radix {decimal} -signals {V1:test_pipe.be.wb.TWOR}
gui_set_radix -radix {unsigned} -signals {V1:test_pipe.be.wb.TWOR}
gui_set_radix -radix {decimal} -signals {V1:test_pipe.be.wb.TWOM}
gui_set_radix -radix {unsigned} -signals {V1:test_pipe.be.wb.TWOM}
gui_set_radix -radix {decimal} -signals {V1:test_pipe.be.wb.TWOM_SP}
gui_set_radix -radix {unsigned} -signals {V1:test_pipe.be.wb.TWOM_SP}

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 969288



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*} -force
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_expand -id ${Hier.1} test_pipe}
catch {gui_list_expand -id ${Hier.1} test_pipe.be}
catch {gui_list_select -id ${Hier.1} {test_pipe.be.wb}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {test_pipe.be.wb}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active test_pipe /home/ecelrc/students/psahu/382N/uarch/pipe/testbench/./../test_pipe.v
gui_view_scroll -id ${Source.1} -vertical -set 0
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_wv_zoom_timerange -id ${Wave.1} 859074 1004575
gui_list_add_group -id ${Wave.1} -after {New Group} {wb}
gui_list_select -id ${Wave.1} {test_pipe.be.wb.i_EIP }
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group wb  -position in

gui_marker_move -id ${Wave.1} {C1} 969288
gui_view_scroll -id ${Wave.1} -vertical -set 225
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

