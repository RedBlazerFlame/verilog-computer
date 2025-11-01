`timescale 1ns / 1ps
`include "alu.v"
`include "call_stack.v"
`include "data_memory.v"
`include "instruction_memory.v"
`include "program_counter.v"
`include "register_file.v"

/*
Note to self.

TODO
1. For each input that's not just a direct connection, create a reg for it.
2. Determine the state transitions of the computer. Input these state transitions below
3. Test the code with a sample fibonacci program written in machine code
4. Write an assembler in python
*/
// A single-threaded computer with 1kb of RAM operating at a clock speed of 500MHz
// Why am I still doing this? T_T
module computer #(parameter WORD_SIZE = 64, DATA_ADDR_SIZE = 8, INSTRUCTION_ADDR_SIZE = 10, STACK_PTR_WIDTH = 6, REG_ADDR_SIZE = 4, CLOCK_HALF_PERIOD = 1, INSTRUCTION_SIZE = 16) (output [WORD_SIZE - 1:0] comp_output, output clk_out);
    /*
    module alu #(parameter WORD_SIZE = 64) (input [WORD_SIZE - 1: 0] d1, input[WORD_SIZE - 1: 0] d2, input [3: 0] opcode, output [WORD_SIZE - 1: 0] out, output iszero, output iscarry);
    module data_memory #(parameter WORD_SIZE = 64, DATA_ADDR_SIZE = 8) (input clk, input [DATA_ADDR_SIZE - 1 : 0] addr, input [WORD_SIZE - 1 : 0] data, input write, input en, output [WORD_SIZE - 1 : 0] out, output [WORD_SIZE - 1 : 0] data_out);
    module call_stack #(parameter INSTRUCTION_ADDR_SIZE=10, parameter STACK_PTR_WIDTH=6) (input clk, input [INSTRUCTION_ADDR_SIZE - 1: 0] addr, input push, input en, output [INSTRUCTION_ADDR_SIZE - 1: 0] out);
    module instruction_memory #(parameter INSTRUCTION_SIZE = 16, INSTRUCTION_ADDR_SIZE = 10) (input [INSTRUCTION_ADDR_SIZE - 1 : 0] addr, output [INSTRUCTION_SIZE - 1 : 0] out);
    module program_counter #(parameter INSTRUCTION_SIZE=16) (input clk, input [INSTRUCTION_SIZE - 1: 0] addr, output [INSTRUCTION_SIZE - 1 : 0] out);
    module register_file #(parameter WORD_SIZE = 64, REG_ADDR_SIZE = 4) (input clk, input en, input [REG_ADDR_SIZE - 1 : 0] write, input [REG_ADDR_SIZE - 1 : 0] r1, input [REG_ADDR_SIZE - 1 : 0] r2, input [WORD_SIZE - 1 : 0] data, output [WORD_SIZE - 1 : 0] out1, output [WORD_SIZE - 1 : 0] out2);
    */

    // Initializing the CPU
    initial begin
        alu_inp_2_reg = 1'b0;
        alu_inp_opcode_reg = 1'b0;
        d_mem_addr_reg = 1'b0;
        d_mem_data_reg = 1'b0;
        d_mem_write_reg = 1'b0;
        d_mem_en_reg = 1'b0;
        call_stack_addr_reg = 1'b0;
        call_stack_push_reg = 1'b0;
        call_stack_en_reg = 1'b0;
        pc_addr_reg = 1'b0;
        regfile_en_reg = 1'b0;
        regfile_write_reg = 1'b0;
        regfile_data_inp_reg = 1'b0;
        iszero_flag = 1'b0;
        iscarry_flag = 1'b0;
    end

    // Dumping Vars
    initial begin
        $dumpfile("computer.vcd");
        $dumpvars(0, computer);
    end

    // Generating the Clock
    reg clk;
    reg clken;
    initial begin
        clk = 1'b1;
        clken = 1'b1;
        
        forever begin
            if(clken)
                #(CLOCK_HALF_PERIOD) clk = ~clk;
            else
            begin
                #(CLOCK_HALF_PERIOD) clk = 1'b0;
                $finish;
            end
        end
    end

    // Defining Connections
    /// ALU Ports
    wire [WORD_SIZE - 1: 0] alu_inp_1;
    wire [WORD_SIZE - 1: 0] alu_inp_2;
    wire [3: 0] alu_inp_opcode;
    wire [WORD_SIZE - 1: 0] alu_out_res;
    wire alu_out_iszero;
    wire alu_out_iscarry;

    alu ALU (.d1(alu_inp_1), .d2(alu_inp_2), .opcode(alu_inp_opcode), .out(alu_out_res), .iszero(alu_out_iszero), .iscarry(alu_out_iscarry));

    //// ALU Inputs
    // reg [WORD_SIZE - 1: 0] alu_inp_1_reg;
    reg [WORD_SIZE - 1: 0] alu_inp_2_reg;
    reg [3: 0] alu_inp_opcode_reg;

    /// Data Memory Ports
    wire [DATA_ADDR_SIZE - 1 : 0] d_mem_addr;
    wire [WORD_SIZE - 1 : 0] d_mem_data;
    wire d_mem_write;
    wire d_mem_en;
    wire [WORD_SIZE - 1 : 0] d_mem_out_read;

    data_memory DATA_MEMORY (.clk(clk), .addr(d_mem_addr), .data(d_mem_data), .write(d_mem_write), .en(d_mem_en), .out(d_mem_out_read), .data_out(comp_output));
    
    //// Date Memory Inputs
    reg [DATA_ADDR_SIZE - 1 : 0] d_mem_addr_reg;
    reg [WORD_SIZE - 1 : 0] d_mem_data_reg;
    reg d_mem_write_reg;
    reg d_mem_en_reg;

    /// Call Stack Ports
    wire [INSTRUCTION_ADDR_SIZE - 1: 0] call_stack_addr;
    wire call_stack_push;
    wire call_stack_en;
    wire [INSTRUCTION_ADDR_SIZE - 1: 0] call_stack_out;
    call_stack CALL_STACK (.clk(clk), .addr(call_stack_addr), .push(push), .en(call_stack_en), .out(call_stack_out));
    
    //// Call Stack Inputs
    reg [INSTRUCTION_ADDR_SIZE - 1: 0] call_stack_addr_reg;
    reg call_stack_push_reg;
    reg call_stack_en_reg;

    /// Instruction Memory Ports
    wire [INSTRUCTION_ADDR_SIZE - 1 : 0] inst_mem_addr; // Already wired
    wire [INSTRUCTION_SIZE - 1 : 0] cur_inst; // ! Very important variable
    instruction_memory INSTRUCTION_MEMORY (.addr(inst_mem_addr), .out(cur_inst));
    
    /// Program Counter Ports
    wire [INSTRUCTION_SIZE - 1: 0] pc_addr;
    wire [INSTRUCTION_SIZE - 1: 0] pc_out;
    program_counter PROGRAM_COUNTER (.clk(clk), .addr(pc_addr), .out(pc_out));

    wire [INSTRUCTION_SIZE - 1: 0] pc_out_p1;
    assign pc_out_p1 = pc_out + 1'b1;

    //// Program Counter Inputs
    reg [INSTRUCTION_SIZE - 1: 0] pc_addr_reg;
    
    /// Register File Ports
    wire regfile_en;
    wire [REG_ADDR_SIZE - 1 : 0] regfile_write;
    wire [REG_ADDR_SIZE - 1 : 0] regfile_r1; // Already wired
    wire [REG_ADDR_SIZE - 1 : 0] regfile_r2; // Already wired
    wire [WORD_SIZE - 1 : 0] regfile_data_inp;
    wire [WORD_SIZE - 1 : 0] regfile_out1;
    wire [WORD_SIZE - 1 : 0] regfile_out2;
    register_file REGISTER_FILE (.clk(clk), .en(regfile_en), .write(regfile_write), .r1(regfile_r1), .r2(regfile_r2), .data(regfile_data_inp), .out1(regfile_out1), .out2(regfile_out2));

    //// Register File Inputs
    reg regfile_en_reg;
    reg [REG_ADDR_SIZE - 1 : 0] regfile_write_reg;
    reg [WORD_SIZE - 1 : 0] regfile_data_inp_reg;

    /// Assigning Registers
    // assign alu_inp_1 = alu_inp_1_reg;
    assign alu_inp_2 = alu_inp_2_reg;
    assign alu_inp_opcode = alu_inp_opcode_reg;
    assign d_mem_addr = d_mem_addr_reg;
    assign d_mem_data = d_mem_data_reg;
    assign d_mem_write = d_mem_write_reg;
    assign d_mem_en = d_mem_en_reg;
    assign call_stack_addr = call_stack_addr_reg;
    assign call_stack_push = call_stack_push_reg;
    assign call_stack_en = call_stack_en_reg;
    assign regfile_en = regfile_en_reg;
    assign regfile_write = regfile_write_reg;
    assign regfile_data_inp = regfile_data_inp_reg;

    assign pc_addr = pc_addr_reg;

    /// Permanent Connections
    assign alu_inp_1 = regfile_out1;
    assign inst_mem_addr = pc_out;
    assign regfile_r1 = cur_inst[11:8];
    assign regfile_r2 = cur_inst[7:4];

    wire [3:0] cur_inst_code;
    assign cur_inst_code = cur_inst[15:12];

    // Ports for the iscarry and iszero ALU flags
    reg iszero_flag;
    reg iscarry_flag;

    // Combinational Block
    always@ * begin
        case(cur_inst_code)
            4'b0000: // NOP
            begin
                pc_addr_reg = pc_out_p1;

                d_mem_en_reg = 1'b0;
                call_stack_en_reg = 1'b0;
                regfile_en_reg = 1'b0;
            end
            4'b0001: // HLT
            begin
                pc_addr_reg = pc_out_p1;

                d_mem_en_reg = 1'b0;
                call_stack_en_reg = 1'b0;
                regfile_en_reg = 1'b0;
            end
            4'b0010: // ADD
            begin
                pc_addr_reg = pc_out_p1;

                alu_inp_2_reg = regfile_out2;
                alu_inp_opcode_reg = 4'b0000;

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;

                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[3:0];
                regfile_data_inp_reg = alu_out_res;
            end
            4'b0011: // SUB
            begin
                pc_addr_reg = pc_out_p1;

                alu_inp_2_reg = regfile_out2;
                alu_inp_opcode_reg = 4'b0001;

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;


                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[3:0];
                regfile_data_inp_reg = alu_out_res;
            end
            4'b0100: // NOR
            begin
                pc_addr_reg = pc_out_p1;

                alu_inp_2_reg = regfile_out2;
                alu_inp_opcode_reg = 4'b0110;

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;


                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[3:0];
                regfile_data_inp_reg = alu_out_res;
            end
            4'b0101: // AND
            begin
                pc_addr_reg = pc_out_p1;

                alu_inp_2_reg = regfile_out2;
                alu_inp_opcode_reg = 4'b0100;

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;


                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[3:0];
                regfile_data_inp_reg = alu_out_res;
            end
            4'b0110: // XOR
            begin
                pc_addr_reg = pc_out_p1;

                alu_inp_2_reg = regfile_out2;
                alu_inp_opcode_reg = 4'b0101;

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;


                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[3:0];
                regfile_data_inp_reg = alu_out_res;
            end
            4'b0111: // RSH
            begin
                pc_addr_reg = pc_out_p1;

                alu_inp_2_reg = regfile_out2;
                alu_inp_opcode_reg = 4'b1010;

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;


                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[3:0];
                regfile_data_inp_reg = alu_out_res;
            end
            4'b1000: // LDI
            begin
                
                pc_addr_reg = pc_out_p1;

                d_mem_en_reg = 1'b0;
                call_stack_en_reg = 1'b0;


                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[11:8];
                regfile_data_inp_reg = {56'd0, cur_inst[7:0]};
            end
            // 4'b1001: // ! DEFUNCT ADI
            // begin
            //     pc_addr_reg = pc_out_p1;

            //     alu_inp_2_reg = {56'd0, cur_inst[7:0]};
            //     alu_inp_opcode_reg = 4'd0000;

            //     d_mem_en_reg = 1'd0;
                
            //     call_stack_en_reg = 1'd0;


            //     regfile_en_reg = 1'b1;
            //     regfile_write_reg = cur_inst[11:8];
            //     regfile_data_inp_reg = alu_out_res;
            // end
            4'b1001: // MUL
            begin
                pc_addr_reg = pc_out_p1;

                alu_inp_2_reg = regfile_out2;
                alu_inp_opcode_reg = 4'b0010;

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;

                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[3:0];
                regfile_data_inp_reg = alu_out_res;
            end
            4'b1010: // JMP
            begin
                pc_addr_reg = cur_inst[9:0];

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;
                
                regfile_en_reg = 1'b0;
            end
            4'b1011: // BRH
            begin
                /*
                00 - not zero, 01 - zero, 10 - not carry, 11 - carry
                */
                if(cur_inst[11]) // check carry
                begin
                    pc_addr_reg = cur_inst[10] == iscarry_flag ? cur_inst[9:0] : pc_out_p1;
                end
                else // check carry
                begin
                    pc_addr_reg = cur_inst[10] == iszero_flag ? cur_inst[9:0] : pc_out_p1;
                end

                d_mem_en_reg = 1'd0;
                
                call_stack_en_reg = 1'd0;

                regfile_en_reg = 1'b0;
            end
            4'b1100: // CAL
            begin
                pc_addr_reg = cur_inst[9:0];

                d_mem_en_reg = 1'd0;
                
                call_stack_addr_reg = pc_out_p1;
                call_stack_push_reg = 1'b1;
                call_stack_en_reg = 1'b1;
                
                regfile_en_reg = 1'b0;
            end
            4'b1101: // RET
            begin
                pc_addr_reg = call_stack_out;

                d_mem_en_reg = 1'd0;
                
                call_stack_addr_reg = 1'b0;
                call_stack_push_reg = 1'b0;
                call_stack_en_reg = 1'b1;
                
                regfile_en_reg = 1'b0;
            end
            4'b1110: // LOD
            begin
                pc_addr_reg = pc_out_p1;

                d_mem_addr_reg = regfile_out1[DATA_ADDR_SIZE - 1:0] + {4'b0, cur_inst[3:0]};
                d_mem_data_reg = 1'b0;
                d_mem_write_reg = 1'b0;
                d_mem_en_reg = 1'b1;

                call_stack_en_reg = 1'b0;


                regfile_en_reg = 1'b1;
                regfile_write_reg = cur_inst[7:4];
                regfile_data_inp_reg = d_mem_out_read;
            end
            4'b1111: // STR
            begin
                pc_addr_reg = pc_out_p1;

                d_mem_addr_reg = regfile_out1[DATA_ADDR_SIZE - 1:0] + {4'b0, cur_inst[3:0]};
                d_mem_data_reg = regfile_out2;
                d_mem_write_reg = 1'b1;
                d_mem_en_reg = 1'b1;
                
                call_stack_en_reg = 1'b0;


                regfile_en_reg = 1'b1;
                regfile_write_reg = 1'b0;
                regfile_data_inp_reg = 1'b0;
            end
        endcase
    end

    // Synchronous Block
    // ! TODO move iszero/iscarry into combinational section
    always@ (posedge clk) begin
        case(cur_inst_code)
            4'b0000: // NOP
            begin
                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
            end
            4'b0001: // HLT
            begin
                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
                
                clken <= 1'b0;
            end
            4'b0010: // ADD
            begin
                iszero_flag <= alu_out_iszero;
                iscarry_flag <= alu_out_iscarry;
            end
            4'b0011: // SUB
            begin
                iszero_flag <= alu_out_iszero;
                iscarry_flag <= alu_out_iscarry;
            end
            4'b0100: // NOR
            begin
                iszero_flag <= alu_out_iszero;
                iscarry_flag <= alu_out_iscarry;
            end
            4'b0101: // AND
            begin
                iszero_flag <= alu_out_iszero;
                iscarry_flag <= alu_out_iscarry;
            end
            4'b0110: // XOR
            begin
                iszero_flag <= alu_out_iszero;
                iscarry_flag <= alu_out_iscarry;
            end
            4'b0111: // RSH
            begin
                iszero_flag <= alu_out_iszero;
                iscarry_flag <= alu_out_iscarry;
            end
            4'b1000: // LDI
            begin

                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
            end
            // 4'b1001: // !DEFUNCT ADI
            // begin
            //     iszero_flag <= alu_out_iszero;
            //     iscarry_flag <= alu_out_iscarry;
            // end
            4'b1001: // MUL
            begin
                iszero_flag <= alu_out_iszero;
                iscarry_flag <= alu_out_iscarry;
            end
            4'b1010: // JMP
            begin
                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
            end
            4'b1011: // BRH
            begin
                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
            end
            4'b1100: // CAL
            begin
                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
            end
            4'b1101: // RET
            begin
                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
            end
            4'b1110: // LOD
            begin
                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
            end
            4'b1111: // STR
            begin
                iszero_flag <= 1'b0;
                iscarry_flag <= 1'b0;
            end
        endcase
    end

    // Connecting to External Ports
    assign clk_out = clk;
endmodule