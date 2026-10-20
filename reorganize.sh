#!/usr/bin/env bash
# reorganize.sh -- restructure custom_cpu_hv into rtl/ tb/ mem/ constraints/ scripts/ reports/ docs/
#
# Run from the repository ROOT (Git Bash on Windows is fine):
#     cd /d/custom_cpu_hv
#     bash reorganize.sh
#
# * Uses `git mv`, so file history and your uncommitted local edits move with the files.
# * Does NOT commit or push. Review with `git status`, then commit yourself.
# * Module contents are untouched; only locations / file names change.
set -euo pipefail

[ -d .git ] || { echo "Run this from the repository root (the folder that contains .git)"; exit 1; }
[ -f cpu_datapath/cpu_datapath.v ] || { echo "Looks already reorganized (or wrong folder)."; exit 1; }

# ---- helpers -----------------------------------------------------------------------------
# mv_to <old> <new> : git mv if tracked, plain mv otherwise; creates the target folder
mv_to() {
  local old="$1" new="$2"
  [ -e "$old" ] || { echo "skip (missing): $old"; return 0; }
  mkdir -p "$(dirname "$new")"
  if git ls-files --error-unmatch "$old" >/dev/null 2>&1; then git mv "$old" "$new"; else mv "$old" "$new"; fi
}
# rm_file <path> : git rm if tracked, plain rm otherwise
rm_file() {
  local f="$1"
  [ -e "$f" ] || return 0
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then git rm -q -f "$f"; else rm -f "$f"; fi
}

# ---- 1. remove duplicate / empty files --------------------------------------------------
# The same four modules (fa1bit, mux2_1_1bit, mux2_1_16bit, mux1_16) were defined in 2-3 places,
# which breaks any tool that reads every .v file together. Canonical copies are kept below.
# (useful_modules/bit16_2_1mux.v differed: it used non-blocking '<=' in combinational logic.)
rm_file useful_modules/fa16.v
rm_file useful_modules/mux2_1_1bit.v
rm_file useful_modules/mux4_16.v
rm_file useful_modules/bit16_2_1mux.v
rm_file rotate_shift/fa16.v                 # identical to adder/fa16.v
rm_file rotate_shift/rotateleft_carry.v     # empty file

# ---- 2. RTL -----------------------------------------------------------------------------
mv_to cpu_datapath/cpu_datapath.v           rtl/core/cpu_datapath.v
mv_to Program_Counter/Program_counter.v     rtl/core/program_counter.v
mv_to control_unit/control_unit.v           rtl/control/control_unit.v
mv_to Alu_16_bit/ALU_16BIT.v                rtl/alu/alu_16bit.v

mv_to adder/Cska_adder16_bit.v              rtl/arithmetic/cska_adder_16bit.v
mv_to adder/fa16.v                          rtl/arithmetic/full_adder_1bit.v
mv_to subtractor/cska_16bit-sub.v           rtl/arithmetic/cska_subtractor_16bit.v
mv_to booth_multiplier/booth_multiplier_16bit.v rtl/arithmetic/booth_multiplier_16bit.v

mv_to comparator/cmp_16_usingsub.v          rtl/comparator/cmp_16_usingsub.v
mv_to comparator/compararto_15.v            rtl/comparator/comparator_15.v   # not used by the datapath

mv_to rotate_shift/shifter_unit_combine.v   rtl/shifter/shifter_unit_combine.v
mv_to rotate_shift/left_rotate.v            rtl/shifter/left_rotate.v
mv_to rotate_shift/rotator16bit.v           rtl/shifter/right_rotate_16bit.v
mv_to rotate_shift/left_shift.v             rtl/shifter/left_shift.v
mv_to rotate_shift/right_shift.v            rtl/shifter/right_shift.v
mv_to rotate_shift/arithmetic_shuft16.v     rtl/shifter/arithmetic_shift16.v
mv_to rotate_shift/16_bit_barrel_shifter.v  rtl/shifter/barrel_shifter_16bit.v  # not used by the datapath

mv_to rotate_shift/mux2_1_1bit.v            rtl/common/mux2_1_1bit.v
mv_to rotate_shift/bit16_2_1mux.v           rtl/common/mux2_1_16bit.v
mv_to rotate_shift/mux4_16.v                rtl/common/mux4_16.v

mv_to REGISTERS/register_file.v             rtl/registers/register_file.v
mv_to REGISTERS/flag_register.v             rtl/registers/flag_register.v
mv_to memory/instruction_memory.v           rtl/memory/instruction_memory.v
mv_to memory/data_memory.v                  rtl/memory/data_memory.v

# ---- 3. testbenches ---------------------------------------------------------------------
mv_to testbenches/cpu_tb.v                  tb/tb_cpu_branch.v
mv_to testbenches/booth_tb.v                tb/tb_booth.v

# ---- 4. program memory ------------------------------------------------------------------
# keep the program you already made if there is one; otherwise create the branch/loop test program
mkdir -p mem
PM="$(find . -path ./.git -prune -o -name program.mem -print | grep -v '^./mem/program.mem$' | head -n1 || true)"
if [ -n "$PM" ]; then mv_to "$PM" mem/program.mem
elif [ ! -f mem/program.mem ]; then
cat > mem/program.mem <<'EOF'
1114 // 0:  MOVI R1,4
1120 // 1:  MOVI R2,0
1133 // 2:  MOVI R3,3
4023 // 3:  loop: ADD R2,R3
E810 // 4:  DEC1 R1
22FE // 5:  BNZ loop
11A3 // 6:  MOVI R10,3
E8A0 // 7:  again: DEC1 R10
22FF // 8:  BNZ again
2003 // 9:  JMP +3 -> 12
1197 // 10: MOVI R9,7
2003 // 11: JMP +3 -> 14
20FE // 12: JMP -2 -> 10
119F // 13: MOVI R9,15 (never runs)
2E22 // 14: CMP R2,R2
2802 // 15: BEQ +2 -> 17
11BF // 16: MOVI R11,15 (skipped)
2E23 // 17: CMP R2,R3
2802 // 18: BEQ +2 -> 20 (not taken)
11C5 // 19: MOVI R12,5
F000 // 20: HALT
EOF
fi

# ---- 5. docs: move the ISA out of the README --------------------------------------------
mkdir -p docs
if [ -f README.md ] && ! [ -f docs/ISA.md ]; then git mv README.md docs/ISA.md 2>/dev/null || mv README.md docs/ISA.md; fi

# ---- 6. reports: copy Vivado reports if they exist on this machine ----------------------
mkdir -p reports/synth
RUNS=/d/digital/hv_project/hv_project.runs/synth_1
[ -f "$RUNS/cpu_datapath.vds" ] && cp "$RUNS/cpu_datapath.vds" reports/synth/synth_log.txt
[ -f "$RUNS/cpu_datapath_utilization_synth.rpt" ] && cp "$RUNS/cpu_datapath_utilization_synth.rpt" reports/synth/utilization_synth.rpt
[ -f reports/synth/.gitkeep ] || : > reports/synth/.gitkeep

# ---- 7. file list used by every tool ----------------------------------------------------
cat > rtl/filelist.f <<'EOF'
# RTL source list -- every module is defined exactly once.  Paths are relative to the repo root.
rtl/common/mux2_1_1bit.v
rtl/common/mux2_1_16bit.v
rtl/common/mux4_16.v
rtl/arithmetic/full_adder_1bit.v
rtl/arithmetic/cska_adder_16bit.v
rtl/arithmetic/cska_subtractor_16bit.v
rtl/arithmetic/booth_multiplier_16bit.v
rtl/comparator/comparator_15.v
rtl/comparator/cmp_16_usingsub.v
rtl/shifter/left_rotate.v
rtl/shifter/right_rotate_16bit.v
rtl/shifter/left_shift.v
rtl/shifter/right_shift.v
rtl/shifter/arithmetic_shift16.v
rtl/shifter/barrel_shifter_16bit.v
rtl/shifter/shifter_unit_combine.v
rtl/alu/alu_16bit.v
rtl/registers/register_file.v
rtl/registers/flag_register.v
rtl/memory/instruction_memory.v
rtl/memory/data_memory.v
rtl/control/control_unit.v
rtl/core/program_counter.v
rtl/core/cpu_datapath.v
EOF

# ---- 8. constraints ---------------------------------------------------------------------
mkdir -p constraints
cat > constraints/cpu.xdc <<'EOF'
# 100 MHz clock target (10 ns).  Tighten/relax to find the real Fmax.
create_clock -period 10.000 -name clck [get_ports clck]
# Pin assignments are not set: this is a synthesis-only constraint set.
EOF

# ---- 9. scripts -------------------------------------------------------------------------
mkdir -p scripts
cat > scripts/synth.tcl <<'EOF'
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
EOF

cat > scripts/create_project.tcl <<'EOF'
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
EOF

# ---- 10. .gitignore ---------------------------------------------------------------------
cat > .gitignore <<'EOF'
# Vivado projects and generated files
build/
*.cache/
*.runs/
*.hw/
*.sim/
*.ip_user_files/
*.gen/
*.jou
*.log
*.str
*.pb
*.dcp
.Xil/
# Simulation output
*.vcd
*.wdb
*.vvp
xsim.dir/
# OS / editor
.DS_Store
Thumbs.db
EOF

# ---- 11. new top-level README -----------------------------------------------------------
cat > README.md <<'EOF'
# custom_cpu_hv — 16-bit single-cycle CPU in Verilog

A 16-bit single-cycle CPU: 16 general registers, 7-bit flag register, 256-word instruction and data
memories, ALU with carry-skip adder/subtractor, Booth multiplier, barrel shifter/rotator and comparator.
Instruction set: see [docs/ISA.md](docs/ISA.md).

## Repository layout

| Folder | Contents |
|---|---|
| `rtl/core` | `cpu_datapath` (top level), `program_counter` |
| `rtl/control` | `control_unit` (instruction decoder) |
| `rtl/alu` | `alu_16bit` |
| `rtl/arithmetic` | carry-skip adder and subtractor, full adder, Booth multiplier |
| `rtl/comparator` | comparator |
| `rtl/shifter` | shift / rotate units |
| `rtl/common` | shared 2:1 and 4:1 muxes |
| `rtl/registers` | register file, flag register |
| `rtl/memory` | instruction memory, data memory |
| `rtl/filelist.f` | list of all RTL files (each module defined once) |
| `tb/` | testbenches (`tb_cpu_branch`, `tb_booth`) |
| `mem/program.mem` | program loaded into instruction memory (`$readmemh`) |
| `constraints/` | Vivado `.xdc` (clock constraint) |
| `scripts/` | `synth.tcl` (batch synthesis), `create_project.tcl` (rebuild the Vivado project) |
| `reports/synth/` | synthesis reports |
| `docs/` | ISA reference |

`comparator_15.v` and `barrel_shifter_16bit.v` are not used by the current datapath.

## Simulate

Top: `datapath_branch_tb` in `tb/tb_cpu_branch.v`. With any simulator, compile the files in
`rtl/filelist.f` plus the testbench, e.g. with Icarus Verilog:

    iverilog -g2012 -o sim.vvp $(grep -v '^#' rtl/filelist.f) tb/tb_cpu_branch.v && vvp sim.vvp

Expected final state: R1=0, R2=12, R3=3, R9=7, R10=0, R11=0, R12=5, PC=20 (HALT).

## Synthesize (Vivado 2024.2, xc7k70tfbv676-1)

    vivado -mode batch -source scripts/synth.tcl

or build a project with `scripts/create_project.tcl`. Reports are written to `reports/synth/`.

### Synthesis results (`program.mem` = branch/loop test, 100 MHz clock target)

| Resource | Used |
|---|---|
| LUTs (logic) | ~1,600 (~4% of 41,000) |
| Flip-flops | 279 |
| CARRY4 | 168 |
| Distributed RAM | 16 × RAM256X1S (data memory) |
| DSP / BRAM | 0 / 0 |

0 errors, 0 critical warnings.  Full reports: `reports/synth/`.
EOF

# remove the now-empty old folders
find . -mindepth 1 -type d -empty -not -path './.git/*' -not -path './reports/*' -delete 2>/dev/null || true

# ---- 12. sanity checks on your local edits ----------------------------------------------
echo
grep -q 'readmemh' rtl/memory/instruction_memory.v || \
  echo 'WARNING: rtl/memory/instruction_memory.v has no $readmemh line; add:  initial $readmemh("program.mem", memory);'
grep -q '\.carry_out(carry_out)' rtl/alu/alu_16bit.v && \
  echo 'WARNING: alu_16bit.v connects the shifter to the ALU carry_out port directly (two drivers). Use a separate wire, e.g. shift_carry.'
echo "Done. Review with:  git status"
echo "Then:  git add -A && git commit -m 'Reorganize repo into rtl/tb/mem/scripts/reports/docs' && git push"
