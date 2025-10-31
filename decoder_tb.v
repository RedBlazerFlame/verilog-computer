`include "decoder.v"

module decoder_tb;

reg [1:0] a;
wire [3:0] b;

decoder #(.BITS(2)) uut (a, b);

reg [3:0] a2;
wire [15:0] b2;
decoder #(.BITS(4)) uut2 (a2, b2);

initial begin
    $dumpfile("decoder_tb.vcd");
    $dumpvars(0, decoder_tb);
end

initial begin
    a = 2'd0; #10;
    a = 2'd1; #10;
    a = 2'd2; #10;
    a = 2'd3; #10;

    a2 = 4'd0; #10;
    a2 = 4'd2; #10;
    a2 = 4'd5; #10;
    a2 = 4'd15; #10;
end

endmodule