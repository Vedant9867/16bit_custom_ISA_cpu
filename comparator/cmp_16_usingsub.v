`timescale 1ns / 1ps


module cmp_16_usingsub(
    input [15:0] A,
    input [15:0] B,
    input is_signed,
    
    output BGT,   // Branch if Greater Than
    output BLT,   // Branch if Less Than
    output BEQ,   // Branch if Equal
    output Bout, // we are not configuring C or carry flag from this comparator
    // will do that from ALUs adder and subtractor simply
    output Z,N, V //flags
    );
    wire [15:0] diff_out;
    wire bout_out;
    wire bin_msb_out;
     cska_16bit_sub subtractor_inst (
        .A(A),
        .B(B),
        .Bin(1'b0),//not required borrow here
        .Diff(diff_out),
        .Bin_msb(bin_msb_out), 
        .Bout(bout_out)
    );
    
   assign Z = (diff_out == 16'h0000);   
   assign Bout= bout_out;                 // Turn adder Cout into Borrow-Out
   assign N = diff_out[15];             // Sign bit of the result
   assign V = bin_msb_out ^ bout_out;   // signed overflow flag
   wire unsigned_LT  = Bout;
   wire unsigned_GT = ~(Bout|Z);
   wire signed_LT = N ^ V;
   wire signed_GT = ~(signed_LT | Z);
   
   // branch instruction  and signed unsigned select logic
   // we will get is_signed signal from instruction decode-stage
   assign BLT = is_signed ? signed_LT : unsigned_LT;
   assign BGT = is_signed ? signed_GT : unsigned_GT;
   assign BEQ = Z; 

endmodule
