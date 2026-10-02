`timescale 1ns / 1ps

module booth_multiplier_16bit(
    input  [15:0] A,
    input  [15:0] B,
    input  is_signed,
    output [31:0] out
);
    integer i;
    //signed
    reg [33:0] p;
    reg [16:0] M;
    //unsigned
    reg [34:0] p1;
    reg [16:0] M1;
    
    always @(*) begin
        p  = 34'b0;
        p1 = 35'b0;
        M = 17'b0; 
        M1 = 17'b0;
        if (is_signed)begin
            M = {A[15], A};           
        // initialize values as AC = 0, Q = B, Q(-1) = 0
        p = {17'b0, B, 1'b0};
//Plain 16-bit signed Booth does work for most inputs,
// but it breaks for A = -32768.
// The first step computes 0 - (-32768) = +32768, which doesn't fit in 16-bit signed, 
//so the accumulator's sign bit goes wrong before the shift. Your 17-bit M and accumulator
// are what fix this corner case, so keep them
        for (i = 0; i < 16; i = i + 1) begin
            case (p[1:0])//qn and q(-1)

                2'b01:p[33:17] = p[33:17] + M;
                2'b10: p[33:17] = p[33:17] - M;
                default: ;                  
            endcase            
            p = {p[33], p[33:1]};
        end
    end
    else begin//for unsigned no extra sign biit in accumulator
        M1 = {1'b0,A};
        p1 = {17'b0,1'b0, B, 1'b0};

        for (i = 0; i < 17; i = i + 1) begin
           case (p1[1:0])
              2'b01: p1[34:18] = p1[34:18] + M1;
              2'b10: p1[34:18] = p1[34:18] - M1;
                default: ;
           endcase
                // Arithmetic right shift
           p1 = {p1[34], p1[34:1]};    
        end
      end
    end  
    // Final result=[AC,Q]
     assign out = is_signed ? p[32:1] : p1[32:1];
endmodule