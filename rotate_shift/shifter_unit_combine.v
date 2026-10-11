`timescale 1ns / 1ps

module shifter_unit_combine(
    input [15:0] data,
    input [15:0] shift_amt,
    input [2:0] shift_type,
    output [15:0] out,
    output carry_out
    );
    wire [15:0] lr_res,rr_res,rs_res,ls_res,as_res;
    left_rotate lr(.A(data),.S(shift_amt[3:0]),.Out(lr_res));
    rotator16bit rr(.A(data),.S(shift_amt[3:0]),.Out(rr_res));
    right_shift rs(.A(data),.S(shift_amt[3:0]),.B(rs_res));
    left_shift ls(.A(data),.S(shift_amt[3:0]),.B(ls_res));
    arithmetic_shift16 asr(.A(data),.S(shift_amt[3:0]),.B(as_res));
    reg [15:0] res;
    reg c_out;
  always @(*) begin
    c_out=1'b0;
    case (shift_type) // encodin 3:0 sub op 3 upper bit decodes shift type 
    // rs-000,ls-001,as-010,rr-011,lr-100 ; with immediate will be sub op lsb will be 1 
    3'b100: res = lr_res;//carry_out = 0 saem as default as in rotate nothing is lost
    3'b011: res = rr_res;// in rotate carry out =0
    3'b000: begin
        if(shift_amt>16'd15)begin
         res = 16'h0000;
         c_out= 1'b0;
         end
        else begin 
         res = rs_res;
         c_out = (shift_amt == 0) ? 1'b0 : data[shift_amt - 1];
        end
       end 
    3'b001: begin
        if(shift_amt > 16'd15)begin
         res = 16'h0000;
         c_out = 1'b0;
         end
        else begin
        res = ls_res;
        c_out = (shift_amt == 0) ? 1'b0 : data[16 - shift_amt];
        end 
       end
    3'b010: begin //arithmetic right shift
         if(|shift_amt[15:4])begin//reduction operator all bits should be 0 if any one then shift result is all 0s
            res= data[15]? 16'hFFFF:16'h0000;
            c_out = data[15];//as shift amount greater than 16 is just all bit as sign bit and so carry out will replicate sign bit only
         end
         else begin
            res= as_res;
            c_out = (shift_amt == 0) ? 1'b0 : data[shift_amt - 1];
            end
         end
    default: res = 16'h0000;    
    endcase
  end
    assign  out = res;
    assign carry_out = c_out;
endmodule
