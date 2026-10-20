# Re-creates a Vivado project (in build/, which is git-ignored) from the repo files.
#     vivado -mode batch -source scripts/create_project.tcl      (or: source it in the Vivado Tcl console)
set root [file normalize [file join [file dirname [info script]] ..]]
create_project -force hv_project [file join $root build hv_project] -part xc7k70tfbv676-1

set files {}
set fp [open [file join $root rtl filelist.f]]
foreach line [split [read $fp] "\n"] {
    set line [string trim $line]
    if {$line eq "" || [string index $line 0] eq "#"} continue
    lappend files [file join $root $line]
}
close $fp
add_files -norecurse $files
add_files -norecurse [file join $root mem program.mem]
add_files -fileset constrs_1 -norecurse [file join $root constraints cpu.xdc]
add_files -fileset sim_1 -norecurse [list [file join $root tb tb_cpu_branch.v] [file join $root tb tb_booth.v]]
set_property top cpu_datapath [current_fileset]
set_property top datapath_branch_tb [get_filesets sim_1]
update_compile_order -fileset sources_1
