`timescale 1ns / 1ps

module program_counter #(parameter INSTRUCTION_SIZE=16) (input clk, input [INSTRUCTION_SIZE - 1: 0] addr, output [INSTRUCTION_SIZE - 1 : 0] out);
    reg [INSTRUCTION_SIZE - 1 : 0] outreg;
    initial begin
        outreg = 1'b0;
    end

    always @ (posedge clk)
    begin
        outreg <= addr;
    end
    assign out = outreg;
endmodule