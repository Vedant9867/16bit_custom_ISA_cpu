`timescale 1ns / 1ps

module left_shift(
    input [15:0] A,
    input [3:0] S,
    output [15:0] B
    );
    wire [15:0] w0,w1,w2;
    mux2_1_16bit mux0(A,{A[14:0],1'b0},S[0],w0);
    mux2_1_16bit mux1(w0,{w0[13:0],{2{1'b0}}},S[1],w1);
    mux2_1_16bit mux2(w1,{w1[11:0],{4{1'b0}}},S[2],w2);
    mux2_1_16bit mux3(w2,{w2[7:0],{8{1'b0}}},S[3],B);
endmodule
