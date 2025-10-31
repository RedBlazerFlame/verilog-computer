`timescale 1ns / 1ps

// A dual-read register file where each entry is 64 bits
// A synchronous, sequential circuit that activates on the positive edge of the clock
module register_file #(parameter WORD_SIZE = 64, REG_ADDR_SIZE = 4) (input clk, input en, input [REG_ADDR_SIZE - 1 : 0] write, input [REG_ADDR_SIZE - 1 : 0] r1, input [REG_ADDR_SIZE - 1 : 0] r2, input [WORD_SIZE - 1 : 0] data, output [WORD_SIZE - 1 : 0] out1, output [WORD_SIZE - 1 : 0] out2);
    reg [WORD_SIZE - 1 : 0] mem [0:(1 << REG_ADDR_SIZE) - 1];
    reg [WORD_SIZE - 1 : 0] out1reg;
    reg [WORD_SIZE - 1 : 0] out2reg;

    initial begin
        for(integer i = 0; i < (1 << REG_ADDR_SIZE); i = i + 1) begin
            mem[i] = 1'b0;
        end
        out1reg = 1'b0;
        out2reg = 1'b0;
    end
    
    always @(posedge clk)
    begin
        if(en)
        begin
            if(write > 1'b0)
                mem[write] <= data;
            mem[1'b0] <= 1'b0;
            out1reg <= mem[r1];
            out2reg <= mem[r2];
        end
        else
        begin
            out1reg <= 1'b0;
            out2reg <= 1'b0;
        end
    end

    assign out1 = out1reg;
    assign out2 = out2reg;
endmodule