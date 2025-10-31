`include "data_memory.v"

module data_memory_tb;

parameter WORD_SIZE = 64, DATA_ADDR_SIZE = 8;
parameter CLOCK_HALF_PERIOD = 10;
reg clk;

reg en;
reg write;
reg [DATA_ADDR_SIZE - 1 : 0] addr;
reg [WORD_SIZE - 1 : 0] data;
wire [WORD_SIZE - 1 : 0] out;
wire [WORD_SIZE - 1 : 0] data_out;


data_memory #(.WORD_SIZE(WORD_SIZE), .DATA_ADDR_SIZE(DATA_ADDR_SIZE)) uut (.clk(clk), .en(en), .write(write), .addr(addr), .data(data), .out(out), .data_out(data_out));

initial begin
    $dumpfile("data_memory_tb.vcd");
    $dumpvars(0, data_memory_tb);
end

initial begin
    clk <= 1'b0;

    for (integer i = 0; i < 20; i = i + 1) begin
        #(CLOCK_HALF_PERIOD) clk <= ~clk;
    end
end

initial begin
    en = 1'b1;
    write = 1'b1; addr = 4'b0000; data = 64'd67; #20;
    write = 1'b0; addr = 4'b0000; data = 64'd67; #20;
    write = 1'b1; addr = 8'b11111111; data = 64'd41; #20;
    write = 1'b0; addr = 8'b11111111; data = 64'd41; #20;
    write = 1'b0; addr = 8'b00000000; data = 64'd41; #20;
    en = 1'b0;
    write = 1'b1; addr = 8'b00000000; data = 64'd41; #20;
    write = 1'b1; addr = 8'b00000000; data = 64'd41; #20;
    en = 1'b1;
    write = 1'b0; addr = 8'b00000000; data = 64'd41; #20;
    write = 1'b0; addr = 8'b11111111; data = 64'd41; #20;
end

endmodule