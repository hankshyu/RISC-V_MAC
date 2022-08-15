`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Tzu-Han Hsu
// Create Date:     07/25/2022 10:34:02 AM
// Module Name:     Compressor42
// Project Name:    IEEE-754 & RISC-V Compatible Multiply-Accumulate Unit
// HDL(Version):    Verilog-2005
//
// Dependencies:    Compressor32.v
//
//////////////////////////////////////////////////////////////////////////////////
// Description:     Input 4 partial sums and outputs sum and carry
//                  One possible implementation is with 2 3-2 Compressors,
//                  Or could be mapped to a more efficient design
//
//////////////////////////////////////////////////////////////////////////////////
// Revision:
// 07/25/2022 - Compressor32 down32 module should take top_carry shift one bit to the left as input
// 07/25/2022 - hidden_carry_msb wire added, collect overflow bits to suppress sign extension
//
//////////////////////////////////////////////////////////////////////////////////


module Compressor42 #(
    parameter XLEN = 49
) (
    input [XLEN - 1 : 0] A_i,
    input [XLEN - 1 : 0] B_i,
    input [XLEN - 1 : 0] C_i,
    input [XLEN - 1 : 0] D_i,
    output [XLEN - 1 : 0] Sum_o,
    output [XLEN - 1 : 0] Carry_o,
    output hidden_carry_msb);

    wire [XLEN - 1: 0] top_sum;
    wire [XLEN - 1: 0] top_carry;

    Compressor32 top32(
        .A_i(A_i),
        .B_i(B_i),
        .C_i(C_i),
        .Sum_o(top_sum),
        .Carry_o(top_carry)
    );

    Compressor32 down32(
        .A_i(top_sum),
        .B_i({top_carry<<1}),
        .C_i(D_i),
        .Sum_o(Sum_o),
        .Carry_o(Carry_o)
    );

    assign hidden_carry_msb = top_carry[XLEN - 1];

endmodule