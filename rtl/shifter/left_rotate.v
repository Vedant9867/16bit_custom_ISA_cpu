`timescale 1ns / 1ps
// left rotate 16 bit

module left_rotate(
    input [15:0] A,
    input [3:0] S,
    output [15:0] Out
    );
    
    wire [15:0] w0,w1,w2;
    mux2_1_16bit mux0(A,{A[14:0],A[15]},S[0],w0);
    mux2_1_16bit mux1(w0,{w0[13:0],w0[15:14]},S[1],w1);
    mux2_1_16bit mux2(w1,{w1[11:0],w1[15:12]},S[2],w2);
    mux2_1_16bit mux3(w2,{w2[7:0],w2[15:8]},S[3],Out);
    
endmodule

