`timescale 1ns / 1ps
`timescale 1ns / 1ps

module Cska_adder_4bit(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cin_msb, 
    output Cout    
    );
    
    wire [3:0] P;
    wire [4:0] C_ripple; 
    
    assign C_ripple[0] = Cin;
    
    genvar i;
    generate
        for(i = 0; i < 4; i = i + 1) begin:fa4_instances
            fa1bit fa(A[i], B[i], C_ripple[i], Sum[i], C_ripple[i+1]); 
        end
    endgenerate

    
    assign Cin_msb = C_ripple[3]; 
    
    wire w;
    assign P = A ^ B;
    assign w = &P;
    
    
    mux2_1_1bit MUX(C_ripple[4], C_ripple[0], w, Cout);
  
endmodule


module Cska_adder16_bit(
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] Sum,
    output Cout,
    output Cin_msb // for relation of signed overflow; this maps to carry in to 15 bit or msb
    );
    
  wire [4:0]C;
   wire [3:0] internal_msb_carries; // Array to hold Cin_msb from each block
  assign C[0] = Cin;  
  genvar i;
  generate
      for(i = 0;i<4;i = i+1) begin:fa4_instances
    Cska_adder_4bit cska1(
                .A(A[4*i+3 : 4*i]),
                .B(B[4*i+3 : 4*i]),
                .Cin(C[i]),
                .Sum(Sum[4*i+3 : 4*i]),
                .Cin_msb(internal_msb_carries[i]),
                .Cout(C[i+1])); 
    end
  endgenerate
  assign Cout = C[4];
   // The carry-in to bit 15 is the internal MSB carry of the 4th block (index 3). we finally get the cin_msb req for overflow
  assign Cin_msb = internal_msb_carries[3]; 
  
endmodule

