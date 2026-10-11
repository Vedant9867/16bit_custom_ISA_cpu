`timescale 1ns / 1ps

// datapath_branch_tb.v -- branch / loop testbench for the single-cycle CPU
//
// Branch convention used here:  target = (address of the branch) + signed offset
//   offset = label_address - branch_address, stored as the low 8 bits (two's complement)
//
// If your datapath uses different instance names, change only these two macros.
// The DUT also needs the debug port pc_out (or change the port list below).

`define IMEM(i) dut.imem.memory[i]
`define REG(n)  dut.rf.registers_out[n]

module datapath_branch_tb;
  reg clk = 0, rst = 1;
  wire [15:0] pc, ins, y; wire [6:0] fl;
  cpu_datapath dut(.clck(clk), .reset(rst), .pc_out(pc), .instr_out(ins),
               .alu_result_out(y), .flags_out(fl));
  always #5 clk = ~clk;

  integer i, err = 0, cycles = 0;
  always @(posedge clk) if (!rst) cycles <= cycles + 1;

  task chk(input [255:0] name, input [15:0] got, input [15:0] exp);
    if (got !== exp) begin err = err + 1; $display("FAIL %0s got=%h exp=%h", name, got, exp); end
    else $display("ok   %0s = %h", name, got);
  endtask

  initial begin
    for (i = 0; i < 256; i = i + 1) `IMEM(i) = 16'h0000;

    // ---- test 1: backward BNZ loop, runs 4 times -> R2 = 4 * 3 = 12 ----------
    `IMEM(0)  = 16'h1114; //  0: MOVI R1,4
    `IMEM(1)  = 16'h1120; //  1: MOVI R2,0
    `IMEM(2)  = 16'h1133; //  2: MOVI R3,3
    `IMEM(3)  = 16'h4023; //  3: loop: ADD  R2,R3
    `IMEM(4)  = 16'hE810; //  4:       DEC1 R1        (sets Z)
    `IMEM(5)  = 16'h22FE; //  5:       BNZ  loop      offset = 3-5 = -2 = 0xFE

    // ---- test 2: tightest loop, offset -1 (0xFF = all ones, sign-extension edge) ----
    `IMEM(6)  = 16'h11A3; //  6: MOVI R10,3
    `IMEM(7)  = 16'hE8A0; //  7: again: DEC1 R10
    `IMEM(8)  = 16'h22FF; //  8:        BNZ again     offset = 7-8 = -1 = 0xFF

    // ---- test 3: unconditional jumps, forward then BACKWARD ----------------------
    `IMEM(9)  = 16'h2003; //  9: JMP +3   -> 12
    `IMEM(10) = 16'h1197; // 10: MOVI R9,7            (reached by the backward jump)
    `IMEM(11) = 16'h2003; // 11: JMP +3   -> 14       (skips 12 and 13)
    `IMEM(12) = 16'h20FE; // 12: JMP -2   -> 10       (backward)
    `IMEM(13) = 16'h119F; // 13: MOVI R9,15           (must never run)

    // ---- test 4: BEQ taken (forward) and not taken ------------------------------
    `IMEM(14) = 16'h2E22; // 14: CMP R2,R2            -> EQ = 1
    `IMEM(15) = 16'h2802; // 15: BEQ +2   -> 17       taken
    `IMEM(16) = 16'h11BF; // 16: MOVI R11,15          (must be skipped)
    `IMEM(17) = 16'h2E23; // 17: CMP R2,R3            12 vs 3 -> EQ = 0
    `IMEM(18) = 16'h2802; // 18: BEQ +2   -> 20       NOT taken, falls through
    `IMEM(19) = 16'h11C5; // 19: MOVI R12,5           (must run)
    `IMEM(20) = 16'hF000; // 20: HALT

    #22 rst = 0;

    begin : run
      repeat (300) begin
        @(posedge clk);
        if (pc == 16'd20) disable run;
      end
      err = err + 1; $display("FAIL timeout, PC=%0d", pc);
    end
    @(posedge clk); #1;

    chk("R1  (loop counter)",  `REG(1),  16'd0);
    chk("R2  (loop sum)",      `REG(2),  16'd12);
    chk("R3",                  `REG(3),  16'd3);
    chk("R10 (tight loop)",    `REG(10), 16'd0);
    chk("R9  (backward JMP)",  `REG(9),  16'd7);
    chk("R11 (BEQ taken)",     `REG(11), 16'd0);
    chk("R12 (BEQ not taken)", `REG(12), 16'd5);
    chk("PC at HALT",          pc,       16'd20);
    $display("cycles after reset = %0d", cycles);
    $display("errors=%0d", err); $finish;
  end
endmodule
