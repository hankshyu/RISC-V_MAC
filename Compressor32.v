`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2022 10:34:02 AM
// Design Name: 
// Module Name: Compressor32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This is a 3:2 compressor, a.k.a carry save adder.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Compressor32 #(
    parameter XLEN = 49
) (
    input [XLEN - 1 : 0] A_i,
    input [XLEN - 1 : 0] B_i,
    input [XLEN - 1 : 0] C_i,
    output [XLEN - 1 : 0] Sum_o,
    output [XLEN - 1 : 0] Carry_o
);
    generate
        genvar j;
        for(j = 0; j < XLEN; j = j+1)begin
            FullAdder FA(
                .augend_i(A_i[j]),
                .addend_i(B_i[j]),
                .carry_i(C_i[j]),
                .sum_o(Sum_o[j]),
                .carry_o(Carry_o[j])
            );
            
        end
    endgenerate

    
endmodule