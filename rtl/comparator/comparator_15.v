`timescale 1ns / 1ps
module comparator_4_bit(
// WHEN DOING THIS OPERATION SGT MEANS HERE THAT A>B NOT B>A
   input [3:0]x,
   input [3:0]y,
   output gt,
   output eq
 );
 wire [3:0] g,e;
 assign g[3:0] = x[3:0] & (~y[3:0]);
 assign e[3:0] = x[3:0] ~^ y[3:0];
 assign gt = g[3] | (e[3] & (g[2] | (e[2] & (g[1] | (e[1] & g[0])))));
 assign eq = &e; // this is the reduction operator , &g performs all bit and of the vector;
 
endmodule
module compararto_15(
    input [15:0] A,
    input [15:0] B,
    output SGT,
    output SLT,
    output SEQ,
    output UEQ,
    output UGT,
    output ULT
    );
    wire [3:0] gti,eqi;
    comparator_4_bit cmp1(.x(A[15:12]),.y(B[15:12]),.gt(gti[3]),.eq(eqi[3]));
    comparator_4_bit cmp2(.x(A[11:8]),.y(B[11:8]),.gt(gti[2]),.eq(eqi[2]));
    comparator_4_bit cmp3(.x(A[7:4]),.y(B[7:4]),.gt(gti[1]),.eq(eqi[1]));
    comparator_4_bit cmp4(.x(A[3:0]),.y(B[3:0]),.gt(gti[0]),.eq(eqi[0])); 
    assign UGT = gti[3] | (eqi[3] & (gti[2] | (eqi[2] & (gti[1] | (eqi[1] & gti[0])))));
    assign UEQ = &eqi;
    nor(ULT,UEQ,UGT);//use of gate primitive
    assign SEQ = UEQ;
    assign SGT = (~A[15] & B[15]) | ((A[15] ~^ B[15]) & UGT);
    nor(SLT,SGT,SEQ);
    
endmodule
