`timescale 1ns / 1ps


module bit16_barrel_shifter(
    input [15:0] A,
    input [3:0] B,
    output [15:0] Out
    );
    
   mux1_16 mux1({A[15],A[0:14]},B,Out[0]);
   mux1_16 mux2({A[14],A[15],A[0:13]},B,Out[1]); 
   mux1_16 mux3({A[13],A[14:15],A[0:12]},B,Out[2]);
   mux1_16 mux4({A[12],A[13:15],A[0:11]},B,Out[3]);
   mux1_16 mux5({A[11],A[12:15],A[0:10]},B,Out[4]);
   mux1_16 mux6({A[10],A[11:15],A[0:9]},B,Out[5]);
   mux1_16 mux7({A[9],A[10:15],A[0:8]},B,Out[6]);
   mux1_16 mux8({A[8],A[9:15],A[0:7]},B,Out[7]);
   mux1_16 mux9({A[7],A[8:15],A[0:6]},B,Out[8]);
   mux1_16 mux10({A[6],A[7:15],A[0:5]},B,Out[9]);
   mux1_16 mux11({A[5],A[6:15],A[0:4]},B,Out[10]);
   mux1_16 mux12({A[4],A[5:15],A[0:3]},B,Out[11]);
   mux1_16 mux13({A[3],A[4:15],A[0:2]},B,Out[12]);
   mux1_16 mux14({A[2],A[3:15],A[0:1]},B,Out[13]);
   mux1_16 mux15({A[1],A[2:15],A[0]},B,Out[14]);
   mux1_16 mux16({A[0],A[1:15]},B,Out[15]);
   
   
   
endmodule
