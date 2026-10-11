`timescale 1ns / 1ps


module Program_counter(
    input clck,
    input RST,
    input HLT,
    input jump_signal,
    input [15:0]Pc_target,
    output reg[15:0] PC
    );
    wire[15:0] Pc_inc;
    wire[15:0] Pc_nxt;
    Cska_adder16_bit incrementer(
      .A(PC),
      .B(16'd1),
      .Cin(1'b0),
      .Sum(Pc_inc),
      .Cout(),
      .Cin_msb()
    );
    assign Pc_nxt = jump_signal ? Pc_target : Pc_inc;
    //pc register design
    always @(posedge clck) begin
        if(RST)//RST would be one for first cycle and then 0 for next 
          PC<= 16'd0;
        else if(HLT)
          PC<= PC;  
        else
          PC<= Pc_nxt;
    end
endmodule
