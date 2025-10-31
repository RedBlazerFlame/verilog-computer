`timescale 1ns / 1ps

module call_stack #(parameter INSTRUCTION_ADDR_SIZE=10, parameter STACK_PTR_WIDTH=6) (input clk, input [INSTRUCTION_ADDR_SIZE - 1: 0] addr, input push, input en, output [INSTRUCTION_ADDR_SIZE - 1: 0] out);
    reg [INSTRUCTION_ADDR_SIZE - 1:0] stack[(1 << STACK_PTR_WIDTH) - 1:0];
    reg [STACK_PTR_WIDTH - 1:0] stackptr;

    assign out = stack[stackptr];

    initial begin
        stackptr = 6'b0;
        for(integer i = 0; i < (1 << STACK_PTR_WIDTH); i = i + 1) begin
            stack[i] = 1'b0;
        end
    end

    always @ (posedge clk)
    begin
        if(en)
        begin
            if(push)
            begin
                stack[stackptr + 1'b1] <= addr;
                stackptr <= stackptr + 1'b1;
            end
            else
            begin
                stackptr <= stackptr - 1'b1;
            end
        end
    end
endmodule