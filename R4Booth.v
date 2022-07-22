`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2022 10:59:09 AM
// Design Name: 
// Module Name: R4Booth
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Breaking down 24bit * 24 bit into 13 partial products, using Radix-4 Booth's Algorithm
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module R4Booth #(
    parameter PARM_MANT = 23
) (
    input [PARM_MANT : 0] MantA_i, // input is {hidden_bit, mantissa} = 1 + 23 = 24 bits
    input [PARM_MANT : 0] MantB_i,

    output [2*PARM_MANT + 2 : 0] pp_00_o, //output range is 24*2 +1(if x2 multiplicand) = 49 bits
    output [2*PARM_MANT + 2 : 0] pp_01_o,
    output [2*PARM_MANT + 2 : 0] pp_02_o,
    output [2*PARM_MANT + 2 : 0] pp_03_o,
    output [2*PARM_MANT + 2 : 0] pp_04_o,
    output [2*PARM_MANT + 2 : 0] pp_05_o,
    output [2*PARM_MANT + 2 : 0] pp_06_o,
    output [2*PARM_MANT + 2 : 0] pp_07_o,
    output [2*PARM_MANT + 2 : 0] pp_08_o,
    output [2*PARM_MANT + 2 : 0] pp_09_o,
    output [2*PARM_MANT + 2 : 0] pp_10_o,
    output [2*PARM_MANT + 2 : 0] pp_11_o,
    output [2*PARM_MANT + 2 : 0] pp_12_o
);
    localparam PARM_PP = 13;
    //left shift b by 2 bits(radix-4 booth algorithm)
    wire [PARM_MANT + 5 : 0] mant_BExt = {2'd0, MantB_i, 2'd0};

    wire [PARM_PP - 1 : 0] mul1x;
    wire [PARM_PP - 1 : 0] mul2x;
    wire [PARM_PP - 1 : 0] mulsign;
    
    generate
        genvar m;
        for(m = 1; m < (PARM_PP+1); m = m+1)begin
            R4Booth_BitPairRecorder R4Booth_BPR(
                .pattern_i(),
                .mul1x_o(),
                .mul2x_o(),
                .mulsign_o()
            );
        end
    endgenerate

    
endmodule
