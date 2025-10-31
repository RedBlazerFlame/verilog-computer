`timescale 1ns / 1ps

module instruction_memory #(parameter INSTRUCTION_SIZE = 16, INSTRUCTION_ADDR_SIZE = 10) (input [INSTRUCTION_ADDR_SIZE - 1 : 0] addr, output [INSTRUCTION_SIZE - 1 : 0] out);
    reg [INSTRUCTION_SIZE - 1 : 0] mem [0:(1 << INSTRUCTION_ADDR_SIZE) - 1];
    reg [INSTRUCTION_SIZE - 1 : 0] outreg;
    
    initial begin
        outreg = 1'b0;

        for(integer i = 0; i < (1 << INSTRUCTION_ADDR_SIZE); i = i + 1) begin
            mem[i] = 1'b0;
        end

        /*================
        MACHINE CODE START
        ================*/

        /*
        Computes the nth fibonacci number
        LDI r1 1
        LDI r2 1
        LDI r4 4
        LDI r6 1
        ADD r1 r2 r3
        ADD r2 r0 r1
        ADD r3 r0 r2
        STR r0 r3 0
        SUB r4 r6 r4
        SUB r4 r0 r5
        BRH notzero 5
        HLT
        */

        mem[10'd0] = 16'b0;
        mem[10'd1] = 16'b1000_0001_00000001;
        mem[10'd2] = 16'b1000_0010_00000001;
        mem[10'd3] = 16'b1000_0100_00000110;
        mem[10'd4] = 16'b1000_0110_00000001;
        mem[10'd5] = 16'b0010_0001_0010_0011;
        mem[10'd6] = 16'b0010_0010_0000_0001;
        mem[10'd7] = 16'b0010_0011_0000_0010;
        mem[10'd8] = 16'b1111_0000_0011_0000;
        mem[10'd9] = 16'b0011_0100_0110_0100;
        mem[10'd10] = 16'b0011_0100_0000_0101;
        mem[10'd11] = 16'b1011_00_0000000101;
        mem[10'd12] = 16'b0001_0000_0000_0000;

        /*==============
        MACHINE CODE END
        ==============*/
    end
    
    always @ *
    begin
        outreg = mem[addr];
    end

    assign out = outreg;
endmodule