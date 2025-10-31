`include "instruction_memory.v"

module instruction_memory_tb;
parameter INSTRUCTION_SIZE = 16, INSTRUCTION_ADDR_SIZE = 10;

reg [INSTRUCTION_ADDR_SIZE - 1 : 0] addr;
wire [INSTRUCTION_SIZE - 1 : 0] out;

instruction_memory #(.INSTRUCTION_SIZE(INSTRUCTION_SIZE), .INSTRUCTION_ADDR_SIZE(INSTRUCTION_ADDR_SIZE)) uut(.addr(addr), .out(out));

initial begin
    $dumpfile("instruction_memory_tb.vcd");
    $dumpvars(0, instruction_memory_tb);
end

initial begin
    addr = 10'd0; #10;
    addr = 10'd1; #10;
    addr = 10'd2; #10;
    addr = 10'd30; #10;
    addr = 10'd46; #10;
    addr = 10'd1023; #10;
end

endmodule