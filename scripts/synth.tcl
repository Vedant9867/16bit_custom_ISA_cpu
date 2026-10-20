# Non-project Vivado synthesis.   Run from anywhere:
#     vivado -mode batch -source scripts/synth.tcl
# Results go to reports/synth/.
set root [file normalize [file join [file dirname [info script]] ..]]
set part xc7k70tfbv676-1
set top  cpu_datapath

set fp [open [file join $root rtl filelist.f]]
foreach line [split [read $fp] "\n"] {
    set line [string trim $line]
    if {$line eq "" || [string index $line 0] eq "#"} continue
    read_verilog [file join $root $line]
}
close $fp
read_xdc [file join $root constraints cpu.xdc]

# instruction_memory.v does $readmemh("program.mem"): resolve it from mem/
cd [file join $root mem]
synth_design -top $top -part $part
cd $root

file mkdir [file join $root reports synth]
report_utilization    -file [file join $root reports synth utilization_synth.rpt]
report_timing_summary -file [file join $root reports synth timing_synth.rpt]
