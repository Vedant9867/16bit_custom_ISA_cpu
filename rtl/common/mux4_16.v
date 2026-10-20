`timescale 1ns / 1ps


module mux1_16(
    input [15:0] A,
    output reg B,
    input [3:0] Sel
    );
  always @(*) begin
    case(Sel)
            4'b0000: B <= A[0];
            4'b0001: B <= A[1];
            4'b0010: B <= A[2];
            4'b0011: B <= A[3];
            4'b0100: B <= A[4];
            4'b0101: B <= A[5];
            4'b0110: B <= A[6];
            4'b0111: B <= A[7];
            4'b1000: B <= A[8];
            4'b1001: B <= A[9];
            4'b1010: B <= A[10];
            4'b1011: B <= A[11];
            4'b1100: B <= A[12];
            4'b1101: B <= A[13];
            4'b1110: B <= A[14];
            4'b1111: B <= A[15];
        
    
   endcase
  end
endmodule
