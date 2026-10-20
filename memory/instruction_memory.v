`timescale 1ns / 1ps


module instruction_memory(
    input [15:0] memadr_instr,
    output [15:0] instruction
    );
    reg [15:0] memory [0:255];//this is memory of 256 instructions
    initial $readmemh("program.mem", memory);
    assign instruction = memory[memadr_instr[7:0]];
endmodule
