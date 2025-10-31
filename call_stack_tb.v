`include "call_stack.v"

module call_stack_tb;

parameter INSTRUCTION_ADDR_SIZE = 10, STACK_PTR_WIDTH = 6;
parameter CLOCK_HALF_PERIOD = 10;
reg clk;

reg [INSTRUCTION_ADDR_SIZE - 1 : 0] addr;
reg en;
reg push;
wire [INSTRUCTION_ADDR_SIZE - 1 : 0] out;

call_stack #(.INSTRUCTION_ADDR_SIZE(INSTRUCTION_ADDR_SIZE), .STACK_PTR_WIDTH(STACK_PTR_WIDTH)) uut (.clk(clk), .addr(addr), .en(en), .push(push), .out(out));

initial begin
    $dumpfile("call_stack_tb.vcd");
    $dumpvars(0, call_stack_tb);
end

initial begin
    clk <= 1'b0;

    for (integer i = 0; i < 20; i = i + 1) begin
        #(CLOCK_HALF_PERIOD) clk <= ~clk;
    end
end

initial begin
    en = 1'b1;
    push = 1'b1; addr = 10'd67; #20;

    push = 1'b1; addr = 10'd41; #20;

    en = 1'b0;
    push = 1'b1; addr = 10'd42; #20;

    en = 1'b1;
    push = 1'b0; addr = 10'd42; #20;

    push = 1'b1; addr = 10'd21; #20;

    push = 1'b0; addr = 10'd21; #20;

    push = 1'b0; addr = 10'd21; #20;
end

endmodule