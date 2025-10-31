`timescale 1ns / 1ps

module alu #(parameter WORD_SIZE = 64) (input [WORD_SIZE - 1: 0] d1, input[WORD_SIZE - 1: 0] d2, input [3: 0] opcode, output [WORD_SIZE - 1: 0] out, output iszero, output iscarry);
    reg [WORD_SIZE - 1 : 0] outreg;
    reg carryreg;
    wire [WORD_SIZE - 1 : 0] d2_twoscomp;

    assign d2_twoscomp = (~d2) + 1;
    
    always @ *
    begin
        case(opcode)
            4'b0000:
            begin
                {carryreg, outreg} = d1 + d2;
            end
            4'b0001:
            begin
                {carryreg, outreg} = d1 + d2_twoscomp;
            end
            4'b0010:
            begin
                outreg = d1 * d2;
                carryreg = 1'b0;
            end
            4'b0011: 
            begin
                outreg = d1 | d2;
                carryreg = 1'b0;
            end
            4'b0100: 
            begin
                outreg = d1 & d2;
                carryreg = 1'b0;
            end
            4'b0101: 
            begin
                outreg = d1 ^ d2;
                carryreg = 1'b0;
            end
            4'b0110: 
            begin
                outreg = d1 ~| d2;
                carryreg = 1'b0;
            end
            4'b0111: 
            begin
                outreg = d1 ~& d2;
                carryreg = 1'b0;
            end
            4'b1000: 
            begin
                outreg = d1 ~^ d2;
                carryreg = 1'b0;
            end
            4'b1001: 
            begin
                outreg = d1 << d2;
                carryreg = 1'b0;
            end
            4'b1010: 
            begin
                outreg = d1 >> d2;
                carryreg = 1'b0;
            end
            default: 
            begin
                outreg = d1;
                carryreg = 1'b0;
            end
        endcase
    end

    assign out = outreg;
    assign iszero = (outreg == 1'b0);
    assign iscarry = carryreg;
endmodule