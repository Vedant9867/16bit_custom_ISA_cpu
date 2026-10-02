`timescale 1ns / 1ps
module dff(//d flipflop
input D,
input enable_signal,
input clck,
output reg Q
);
always @(posedge clck)begin
if(enable_signal)
 Q <= D;
end
endmodule

module register_16bit(
input [15:0]data,
input clck,
input wr_signal,
output [15:0] q 
);
genvar i;
generate

for(i = 0; i<16; i= i+1) begin:dff16_inst
        dff instances(
        .D(data[i]),
        .clck(clck),
        .enable_signal(wr_signal),
        .Q(q[i])
        );
        
   end
endgenerate
endmodule
module register_file(
    input [3:0] rd_ad1,
    input [3:0] rd_ad2,
    input clck,
    input [3:0] wr_ad,
    input [15:0] wr_data,
    input wr_signal,
    output [15:0] rd_data1,
    output [15:0] rd_data2
    );
wire [15:0] register_en;
genvar i;
generate
for(i = 0; i<16; i= i+1) begin:register_enable
assign register_en[i] = wr_signal && (wr_ad == i);
end
endgenerate

wire [15:0] registers_out[0:15];

genvar j;
generate

for(j = 0; j<16;j=j+1) begin:register_instances
register_16bit Rn(
.data(wr_data),
.clck(clck),
.wr_signal(register_en[j]),
.q(registers_out[j])
);
// register write function is over what about read
//register read 

// this will read the reg data from given address in the opcode sent to alu for calculation alu gives output and that output will be stored in the destination register theough write function

end
endgenerate
assign rd_data1 = registers_out[rd_ad1];
assign rd_data2 = registers_out[rd_ad2];
endmodule