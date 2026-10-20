`timescale 1ns / 1ps


////////////////////RIGHT ROTATOR//////////////////////////////////////////////////////////////


module rotator16bit(
    input [15:0] A,
    input [3:0] S,
    output [15:0] Out
    );
    wire [15:0] w0,w1,w2;
    mux2_1_16bit mux0(A,{A[0],A[15:1]},S[0],w0);
    mux2_1_16bit mux1(w0,{w0[1:0],w0[15:2]},S[1],w1);
    mux2_1_16bit mux2(w1,{w1[3:0],w1[15:4]},S[2],w2);
    mux2_1_16bit mux3(w2,{w2[7:0],w2[15:8]},S[3],Out);
    
endmodule
