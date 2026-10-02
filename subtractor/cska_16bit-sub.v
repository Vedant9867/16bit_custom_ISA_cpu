`timescale 1ns / 1ps


module cska_16bit_sub(
    input [15:0] A,
    input [15:0] B,
    input Bin,
    output [15:0] Diff,
    output Bin_msb,
    output Bout
    );
    wire [15:0]w;
    assign w = ~B;
    wire Cin;
    assign Cin = ~Bin;// A - B = A + ~B + 1
//A - B - Bin = A + ~B + 1 - Bin
//            = A + ~B + (1 - Bin)
//            = A + ~B + ~Bin        (for a single bit, 1 - Bin = ~Bin)
    wire cout,cin_msb;
    Cska_adder16_bit cska1(A,w,Cin,Diff,cout,cin_msb);
    assign Bout = ~cout; // when doing subtraction uding 2s complement final bout = ~cout of addition
    assign Bin_msb = ~cin_msb; 
endmodule
