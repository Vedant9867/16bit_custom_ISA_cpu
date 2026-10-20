`timescale 1ns / 1ps


module cpu_datapath(
input clck,
input reset,
output [15:0] pc_out,
output [15:0] instr_out,
output [15:0] alu_result_out,
output [6:0]  flags_out 
    );
    localparam BRANCH_RELATIVE = 1;
    wire [15:0] pc;
    wire [15:0] instruction;
    wire        B_operand;        // 1 = use immediate as second operand
    wire        wr_signal;        // register write enable
    wire        use_carry_flg;
    wire [2:0]  shift_type;
    wire [3:0]  alu_op;
    wire [3:0]  extract_imm;
    wire        branching;
    wire [7:0]  offset;
    wire        flag_write;
    wire        flag_source;
    wire        cmp_signed;
    wire        mul_signed;
    wire        mul_hi_wr;        // MUL/MULS R1,R2: second write port enable (product high half -> R2)
    wire        mem_read;         // not used by data_memory yet (async read), kept for later
    wire        mem_write;
    wire        mem_to_reg;
    wire        halt_pc;
    wire        reset_pc;
    wire [3:0]  rd_ad1 = instruction[7:4];   // R1
    wire [3:0]  rd_ad2 = instruction[3:0];   // R2
    wire [3:0]  wr_ad  = instruction[7:4];   // destination is always R1
    wire [15:0] rd_data1, rd_data2;
    wire [15:0] wr_data;
     // flags (registered, from previous flag-writing instruction)
    wire [6:0]  flag_out;
    wire [6:0]  flags_next;
    wire        fl_Z = flag_out[6];
    wire        fl_C = flag_out[5];
    wire        fl_N = flag_out[4];
    wire        fl_V = flag_out[3];
    wire        fl_GT = flag_out[2];
    wire        fl_LT = flag_out[1];
    wire        fl_EQ = flag_out[0];
    // ALU
    wire [31:0] alu_y;
    wire [15:0] alu_result = alu_y[15:0];    // low half: goes to R1 (port 1); alu_y[31:16] goes to R2 (port 2) for MUL/MULS

    // data memory
    wire [15:0] mem_read_data;
    wire [15:0] store_data = B_operand ? {12'b0, extract_imm} : rd_data2;  // STR / STRI

    wire [15:0] pc_target = BRANCH_RELATIVE ? (pc + {{8{offset[7]}}, offset})
                                            : {8'b0, offset};
                                            
     Program_counter pc_unit(
        .clck(clck),
        .RST(reset | reset_pc),
        .HLT(halt_pc),
        .jump_signal(branching),
        .Pc_target(pc_target),
        .PC(pc)
    );

    instruction_memory imem(
        .memadr_instr(pc),
        .instruction(instruction)
    );

   
    // Branch conditions must use the REGISTERED flags (set by an earlier CMP/ALU
    // instruction), not the ALU's live outputs for the branch instruction itself.
    control_unit cu(
        .instruction(instruction),
        .Z(fl_Z), .N(fl_N), .C(fl_C), .V(fl_V),
        .EQ(fl_EQ), .GT(fl_GT), .LT(fl_LT),
        .B_operand(B_operand),
        .wr_signal(wr_signal),
        .use_carry_flg(use_carry_flg),
        .shift_type(shift_type),
        .alu_op(alu_op),
        .extract_imm(extract_imm),
        .branching(branching),
        .offset(offset),
        .flag_write(flag_write),
        .flag_source(flag_source),
        .cmp_signed(cmp_signed),
        .mul_signed(mul_signed),
        .mul_hi_wr(mul_hi_wr),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .halt_pc(halt_pc),
        .reset_pc(reset_pc)
    );

    register_file rf(
        .rd_ad1(rd_ad1),
        .rd_ad2(rd_ad2),
        .clck(clck),
        .wr_ad(wr_ad),
        .wr_data(wr_data),
        .wr_signal(wr_signal),
        .wr_ad2(instruction[3:0]),   // R2 field
        .wr_data2(alu_y[31:16]),    // product high half
        .wr_signal2(mul_hi_wr),
        .rd_data1(rd_data1),
        .rd_data2(rd_data2)
    );

  
    Alu_16_bit alu(
        .A(rd_data1),
        .B(rd_data2),
        .imm(extract_imm),
        .carry_in(fl_C),
        .ALU_op(alu_op),
        .Shift_type(shift_type),
        .B_select_imm(B_operand),
        .use_carry_in(use_carry_flg),
        .mul_signed(mul_signed),
        .flag_source(flag_source),
        .cmp_signed(cmp_signed),
        .Y(alu_y),
        .carry_out(),
        .overflow(),
        .zero(),
        .sign(),
        .GT(), .LT(), .EQ(),
        .Z(), .N(), .V(),
        .flags_next(flags_next)
    );

    flag_register flags(
        .flag_in(flags_next),
        .clck(clck),
        .wr_signal(flag_write),
        .flag_out(flag_out)
    );
    data_memory dmem(
        .clck(clck),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(store_data),
        .read_data(mem_read_data)
    );

    assign wr_data = mem_to_reg ? mem_read_data : alu_result;

 
    assign pc_out         = pc;
    assign instr_out      = instruction;
    assign alu_result_out = alu_result;
    assign flags_out      = flag_out;
                                        
                                            
endmodule
