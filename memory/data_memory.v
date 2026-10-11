module data_memory(
    input clck,
    input mem_write,
    input [15:0] address,
    input [15:0] write_data,
    output [15:0] read_data
);

reg [15:0] memory [0:255];

assign read_data = memory[address[7:0]];

always @(posedge clck) begin
    if(mem_write)
        memory[address[7:0]] <= write_data;
end

endmodule