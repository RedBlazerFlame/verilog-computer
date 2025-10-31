`include "alu.v"

module alu_tb;

parameter ALU_TEST_WORD_SIZE = 64;

reg [ALU_TEST_WORD_SIZE - 1:0] d1;
reg [ALU_TEST_WORD_SIZE - 1:0] d2;
reg [3:0] op;
wire [ALU_TEST_WORD_SIZE - 1:0] out;
wire iszero;
wire iscarry;

alu #(.WORD_SIZE(ALU_TEST_WORD_SIZE)) uut (d1, d2, op, out, iszero, iscarry);

initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);
end

initial begin
    d1 = 64'd6; d2 = 64'd7; op = 4'b0000; #10;
    d1 = 64'd6; d2 = 64'd7; op = 4'b0001; #10;
    d1 = 64'd6; d2 = (~(64'd7)) + 64'd1; op = 4'b0000; #10;
    d1 = 64'd7; d2 = 64'd6; op = 4'b0001; #10;
    d1 = 64'd6; d2 = 64'd7; op = 4'b0010; #10;
    d1 = 64'b1011011; d2 = 64'b1100111; op = 4'b0100; #10; // AND, returns 67
    d1 = 64'b100001; d2 = 64'b1001; op = 4'b0011; #10; // OR, returns 41
    d1 = 64'b100001; d2 = 64'b1001; op = 4'b1111; #10; // INVALID, returns 33
    d1 = 64'b1100; d2 = 64'd2; op = 4'b1001; #10; // LEFT SHIFT, returns 48
    d1 = 64'b1100; d2 = 64'd2; op = 4'b1010; #10; // RIGHT SHIFT, returns 3
    d1 = 64'hFFFFFFFFFFFFFFFF; d2 = 64'h1; op = 4'b0000; #10;
end

endmodule