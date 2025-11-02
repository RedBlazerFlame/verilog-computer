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
        MUL r1 r2 r5
        STR r0 r5 0
        HLT
        */

        mem[10'd0] = 16'h8101;
        mem[10'd1] = 16'h8201;
        mem[10'd2] = 16'h8440;
        mem[10'd3] = 16'h2123;
        mem[10'd4] = 16'h2201;
        mem[10'd5] = 16'h2302;
        mem[10'd6] = 16'hf030;
        mem[10'd7] = 16'h8f01;
        mem[10'd8] = 16'h34f4;
        mem[10'd9] = 16'h340f;
        mem[10'd10] = 16'hb003;
        mem[10'd11] = 16'h9125;
        mem[10'd12] = 16'h8f01;
        mem[10'd13] = 16'h25f5;
        mem[10'd14] = 16'hf050;
        mem[10'd15] = 16'h1000;

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