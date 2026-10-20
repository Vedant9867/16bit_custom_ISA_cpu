`timescale 1ns / 1ps

module right_shift(
    input [15:0] A,
    input [3:0] S,
    output [15:0] B
    );
    wire [15:0] w0,w1,w2;
    mux2_1_16bit mux0(A,{1'b0,A[15:1]},S[0],w0);
    mux2_1_16bit mux1(w0,{{2{1'b0}},w0[15:2]},S[1],w1);
    mux2_1_16bit mux2(w1,{{4{1'b0}},w1[15:4]},S[2],w2);
    mux2_1_16bit mux3(w2,{{8{1'b0}},w2[15:8]},S[3],B);
    

endmodule
