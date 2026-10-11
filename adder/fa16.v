`timescale 1ns / 1ps

module fa1bit(
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout
    );
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | ( Cin & A);
    
endmodule
