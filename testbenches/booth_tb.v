`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2026 00:27:31
// Design Name: 
// Module Name: booth_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module tb_booth;
    reg  [15:0] A, B;
    reg         is_signed;
    wire [31:0] out;
    reg  [31:0] expected;
    integer errors, i;

    booth_multiplier_16bit dut (.A(A), .B(B), .is_signed(is_signed), .out(out));

    task check(input [15:0] a, input [15:0] b, input s);
    begin
        A = a; B = b; is_signed = s;
        #10;
        if (s) expected = $signed(a) * $signed(b);
        else   expected = a * b;
        if (out !== expected) begin
            $display("FAIL s=%b A=%h B=%h got=%h exp=%h", s, a, b, out, expected);
            errors = errors + 1;
        end
    end
    endtask

    initial begin
    $display("TB started at %0t", $time);
        errors = 0;
        // directed corner cases
        check(16'h0000, 16'h0000, 0);
        check(16'hFFFF, 16'hFFFF, 0);   // max unsigned
        check(16'hFFFF, 16'h0001, 0);
        check(16'h8000, 16'h8000, 1);   // most negative x most negative
        check(16'h8000, 16'hFFFF, 1);   // -32768 x -1
        check(16'h7FFF, 16'h7FFF, 1);   // max positive
        check(16'h0001, 16'hFFFF, 1);   // x -1

        // random
        for (i = 0; i < 100000; i = i + 1) begin
            check($urandom, $urandom, 0);
            check($urandom, $urandom, 1);
        end

        if (errors == 0) $display("ALL PASSED");
        else             $display("%0d FAILURES", errors);
        $finish;
    end

endmodule
