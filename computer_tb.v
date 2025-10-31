`include "computer.v"

module computer_tb;
    parameter WORD_SIZE = 64;
    wire [WORD_SIZE - 1:0] comp_output;
    wire clk;
    computer comp(.comp_output(comp_output), .clk_out(clk));
    
    initial begin
        $dumpfile("computer_tb.vcd");
        $dumpvars(0, computer_tb);
    end

    initial begin
        #(600) $finish;
    end
endmodule