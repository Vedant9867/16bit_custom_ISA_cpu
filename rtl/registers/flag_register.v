`timescale 1ns / 1ps

module flag_register(
    input [6:0] flag_in,//Z,C,N,V,GT,LT,EQ
    input clck,
    input wr_signal,
    output [6:0] flag_out
);

genvar i;
generate
for(i = 0; i < 7; i = i + 1) begin: flag_dff
    dff flag_instance(
        .D(flag_in[i]),
        .clck(clck),
        .enable_signal(wr_signal),
        .Q(flag_out[i])
    );
end
endgenerate

endmodule