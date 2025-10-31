`include "register_file.v"

module register_file_tb;

parameter WORD_SIZE = 64, REG_ADDR_SIZE = 4;
parameter CLOCK_HALF_PERIOD = 10;

reg clk;

reg en;
reg [REG_ADDR_SIZE - 1 : 0] write;
reg [REG_ADDR_SIZE - 1 : 0] r1;
reg [REG_ADDR_SIZE - 1 : 0] r2;
reg [WORD_SIZE - 1 : 0] data;
wire [WORD_SIZE - 1 : 0] out1;
wire [WORD_SIZE - 1 : 0] out2;


register_file #(.WORD_SIZE(WORD_SIZE), .REG_ADDR_SIZE(REG_ADDR_SIZE)) uut (.clk(clk), .en(en), .write(write), .r1(r1), .r2(r2), .data(data), .out1(out1), .out2(out2));

initial begin
    $dumpfile("register_file_tb.vcd");
    $dumpvars(0, register_file_tb);
end

initial begin
    clk <= 1'b0;

    for (integer i = 0; i < 20; i = i + 1) begin
        #(CLOCK_HALF_PERIOD) clk <= ~clk;
    end
end

initial begin
    en = 1'b1;
    write = 4'b0001; r1 = 4'b0001; r2 = 4'b0010; data = 64'd67; #20;
    write = 4'b0010; r1 = 4'b0001; r2 = 4'b0010; data = 64'd41; #20;
    write = 4'b0000; r1 = 4'b0001; r2 = 4'b0010; data = 64'd42; #20;
    write = 4'b1111; r1 = 4'b0001; r2 = 4'b0000; data = 64'd21; #25;
    write = 4'b1111; r1 = 4'b1111; r2 = 4'b0010; data = 64'd22; #15;
end

endmodule