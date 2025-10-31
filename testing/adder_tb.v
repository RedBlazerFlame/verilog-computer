`include "adder.v"

module tb_adder;

reg [3:0] a, b;
wire [3:0] out;

adder uut (a, b, out);

initial begin
    $dumpfile("adder_tb.vcd");
    $dumpvars(0, tb_adder);
end

initial begin
    a = 4'd1; b = 4'd1; #10;
    a = 4'd2; b = 4'd3; #10;
    a = 4'd6; b = 4'd7; #10;
    a = 4'd9; b = 4'd10; #10;
end

endmodule