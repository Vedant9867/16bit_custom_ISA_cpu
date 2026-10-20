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
