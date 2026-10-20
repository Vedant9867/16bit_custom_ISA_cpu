`timescale 1ns / 1ps

module mux2_1_16bit(
    input [15:0] A,
    input [15:0] B,
    input S,
    output reg[15:0] Out
    );
    always @(*) begin
        case(S)
        1'b0: Out = A;
        1'b1: Out = B;
        endcase
    end
    
endmodule
