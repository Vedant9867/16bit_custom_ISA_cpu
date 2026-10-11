`timescale 1ns / 1ps
module mux2_1_1bit(
    input A,
    input B,
    input S,
    output reg Out
    );
  always @(*) begin
    case(S)
    1'b0: Out = A;
    1'b1: Out = B;
    endcase;
  end
endmodule
