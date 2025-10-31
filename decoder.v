`timescale 1ns / 1ps


module decoder #(parameter BITS = 2) (input [BITS - 1: 0] to_dec, output [(1 << BITS) - 1 : 0] encoded);
    assign encoded = 1'b1 << to_dec;
endmodule