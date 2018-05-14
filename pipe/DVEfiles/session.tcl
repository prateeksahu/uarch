# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Mon May 7 20:09:05 2018
# Designs open: 1
#   V1: /home/ecelrc/students/psahu/382N/uarch/pipe/testbench/test_pipe.dump.vpd
# Toplevel windows open: 1
# 	TopLevel.1
#   Source.1: test_pipe
#   Group count = 1
#   Group wb signal count = 126
# End_DVE_Session_Save_Info

# DVE version: K-2015.09-SP1_Full64
# DVE build date: Nov 24 2015 21:15:24


#<Session mode="Full" path="/home/ecelrc/students/psahu/382N/uarch/pipe/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{8 31} {1918 1033}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_hide_toolbar -toolbar {Simulator}
gui_hide_toolbar -toolbar {Interactive Rewind}
gui_hide_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 155]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 155
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 154} {height 753} {dock_state left} {dock_on_new_line true} {child_hier_colhier 151} {child_hier_coltype 54} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 105]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 105
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 753
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 105} {height 753} {dock_state left} {dock_on_new_line true} {child_data_colvariable 140} {child_data_colvalue 100} {child_data_coltype 40} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 175]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1860
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 175
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1910} {height 174} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}

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


set _session_group_2 wb
gui_sg_create "$_session_group_2"
set wb "$_session_group_2"

gui_sg_addsignal -group "$_session_group_2" { test_pipe.be.wb.gpr_data test_pipe.be.wb.segr_data test_pipe.be.wb.xmm_data test_pipe.be.wb.mem_data test_pipe.be.wb.gpr_dr test_pipe.be.wb.seg_dr test_pipe.be.wb.xmm_dr test_pipe.be.wb.mem_addr test_pipe.be.wb.grpWen test_pipe.be.wb.segWen test_pipe.be.wb.xmmWen test_pipe.be.wb.EIP test_pipe.be.wb.EFlag test_pipe.be.wb.mem_size test_pipe.be.wb.opSize test_pipe.be.wb.i_v test_pipe.be.wb.memWen test_pipe.be.wb.cachable test_pipe.be.wb.wrV test_pipe.be.wb.v test_pipe.be.wb.stall test_pipe.be.wb.wbR test_pipe.be.wb.o_inv test_pipe.be.wb.memWrV1 test_pipe.be.wb.memWrV2 test_pipe.be.wb.i_cachable test_pipe.be.wb.i_CS test_pipe.be.wb.i_data1 test_pipe.be.wb.i_data2 test_pipe.be.wb.i_EIP test_pipe.be.wb.i_nEIP test_pipe.be.wb.i_PA1 test_pipe.be.wb.i_PA2 test_pipe.be.wb.i_PA3 test_pipe.be.wb.i_PA4 test_pipe.be.wb.i_size1 test_pipe.be.wb.i_size2 test_pipe.be.wb.i_eflags test_pipe.be.wb.i_opSize test_pipe.be.wb.i_dr1 test_pipe.be.wb.i_dr2 test_pipe.be.wb.i_drSeg test_pipe.be.wb.i_spill test_pipe.be.wb.i_Dflag test_pipe.be.wb.clk test_pipe.be.wb.rst test_pipe.be.wb.istall test_pipe.be.wb.empty test_pipe.be.wb.dr1Wen test_pipe.be.wb.dr2Wen test_pipe.be.wb.segDWen test_pipe.be.wb.xmmOp test_pipe.be.wb.uOpNo test_pipe.be.wb.aluOp test_pipe.be.wb.r1Ren test_pipe.be.wb.r2Ren test_pipe.be.wb.segR1Ren test_pipe.be.wb.segR2Ren test_pipe.be.wb.memRen test_pipe.be.wb.passAB test_pipe.be.wb.lastuop test_pipe.be.wb.isJMP test_pipe.be.wb.isCALL test_pipe.be.wb.isPUSH test_pipe.be.wb.isPOP test_pipe.be.wb.isEXCH test_pipe.be.wb.isCMPE test_pipe.be.wb.isSIMD test_pipe.be.wb.isSAT test_pipe.be.wb.isSHUF test_pipe.be.wb.isDAA test_pipe.be.wb.isRET test_pipe.be.wb.flags_mod test_pipe.be.wb.flags_cmp test_pipe.be.wb.flags_used test_pipe.be.wb.isCMPS test_pipe.be.wb.interrupt test_pipe.be.wb.t1 test_pipe.be.wb.t2 test_pipe.be.wb.tstall test_pipe.be.wb.dr1w test_pipe.be.wb.dr2w test_pipe.be.wb.tworeg test_pipe.be.wb.zz test_pipe.be.wb.ntwomem test_pipe.be.wb.zo test_pipe.be.wb.oo test_pipe.be.wb.n_spill test_pipe.be.wb.n_memWen test_pipe.be.wb.cst test_pipe.be.wb.next test_pipe.be.wb.nst test_pipe.be.wb.drWen test_pipe.be.wb.grpWen_t test_pipe.be.wb.segWen_t test_pipe.be.wb.eq test_pipe.be.wb.sp1size test_pipe.be.wb.sp2size test_pipe.be.wb.spl1size test_pipe.be.wb.spl2size test_pipe.be.wb.ret1size test_pipe.be.wb.ret2size test_pipe.be.wb.data test_pipe.be.wb.st1Data test_pipe.be.wb.st2Data test_pipe.be.wb.st3Data test_pipe.be.wb.st4Data test_pipe.be.wb.data16 test_pipe.be.wb.uop0 test_pipe.be.wb.st1Sel test_pipe.be.wb.st2Sel test_pipe.be.wb.st3Sel test_pipe.be.wb.st4Sel test_pipe.be.wb.sel16 test_pipe.be.wb.t_PA1 test_pipe.be.wb.t_PA2 test_pipe.be.wb.t_PA3 test_pipe.be.wb.t_PA4 test_pipe.be.wb.data116 test_pipe.be.wb.data216 test_pipe.be.wb.wrVt test_pipe.be.wb.t3 test_pipe.be.wb.IDLE test_pipe.be.wb.TWOR test_pipe.be.wb.TWOM test_pipe.be.wb.TWOM_SP }
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
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
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
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
#</Session>

