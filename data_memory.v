`timescale 1ns / 1ps

// A dual-read memory file where each entry is 64 bits
// A synchronous, sequential circuit that activates on the positive edge of the clock
module data_memory #(parameter WORD_SIZE = 64, DATA_ADDR_SIZE = 8) (input clk, input [DATA_ADDR_SIZE - 1 : 0] addr, input [WORD_SIZE - 1 : 0] data, input write, input en, output [WORD_SIZE - 1 : 0] out, output [WORD_SIZE - 1 : 0] data_out);
    reg [WORD_SIZE - 1 : 0] mem [0:(1 << DATA_ADDR_SIZE) - 1];
    reg [WORD_SIZE - 1 : 0] outreg;

    assign data_out = mem[1'b0];

    initial begin
        outreg = 1'b0;
        for(integer i = 0; i < (1 << DATA_ADDR_SIZE); i = i + 1) begin
            mem[i] = 1'b0;
        end
    end
    
    always @(posedge clk)
    begin
        if(en)
        begin
            if(write)
                mem[addr] <= data;
            outreg <= mem[addr];
        end
        else
        begin
            outreg <= 1'b0;
        end
    end

    assign out = outreg;
endmodule