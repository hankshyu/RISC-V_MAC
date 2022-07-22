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
    parameter PARM_PP = 13;

    //left shift b by 2 bits(radix-4 booth algorithm)
    wire [PARM_MANT + 5 : 0] mant_BExt = {3'd0, MantB_i, 2'd0};

    wire [PARM_PP - 1 : 0] mul1x;
    wire [PARM_PP - 1 : 0] mul2x;
    wire [PARM_PP - 1 : 0] mulsign;
    
    generate
        genvar m;
        for(m = 0; m < PARM_PP; m = m+1)begin
            R4Booth_BitPairRecorder R4Booth_BPR(
                .pattern_i(mant_BExt[(2*m+1) +: 3]),
                .mul1x_o(mul1x[m]),
                .mul2x_o(mul2x[m]),
                .mulsign_o(mulsign[m])
            );
        end
    endgenerate

    wire [PARM_MANT + 2 : 0] mant_AExt = {1'b0,MantA_i,1'b0};
    wire [PARM_MANT + 1 : 0] booth_PP [PARM_PP - 1: 0];



    generate
        genvar n,p;
        for(n = 0; n < 13 ; n = n+1)begin
            for(p = 0; p < PARM_MANT + 2 ; p = p+1)begin
                R4Booth_PatternSelector R4Booth_PatternSelector(
                    .ba_i(mant_AExt[p+1 : p]),
                    .sel_1x_i(mul1x[n]),
                    .sel_2x_i(mul2x[n]),
                    .sel_sign_i(mulsign[n]),
                    .boothbit_o(booth_PP[n][p])
                );
            end
        end
    endgenerate


    assign pp_00_o = {21'd0, ~mulsign[ 0],{2{mulsign[0]}},booth_PP[0]}; 
    assign pp_01_o = {21'd1, ~mulsign[ 1], booth_PP[ 1], 1'b0, mulsign[ 0]};
    assign pp_02_o = {19'd1, ~mulsign[ 2], booth_PP[ 2], 1'b0, mulsign[ 1],  2'd0};
    assign pp_03_o = {17'd1, ~mulsign[ 3], booth_PP[ 3], 1'b0, mulsign[ 2],  4'd0};
    assign pp_04_o = {15'd1, ~mulsign[ 4], booth_PP[ 4], 1'b0, mulsign[ 3],  6'd0};
    assign pp_05_o = {13'd1, ~mulsign[ 5], booth_PP[ 5], 1'b0, mulsign[ 4],  8'd0};
    assign pp_06_o = {11'd1, ~mulsign[ 6], booth_PP[ 6], 1'b0, mulsign[ 5], 10'd0};
    assign pp_07_o = { 9'd1, ~mulsign[ 7], booth_PP[ 7], 1'b0, mulsign[ 6], 12'd0};
    assign pp_08_o = { 7'd1, ~mulsign[ 8], booth_PP[ 8], 1'b0, mulsign[ 7], 14'd0};
    assign pp_09_o = { 5'd1, ~mulsign[ 9], booth_PP[ 9], 1'b0, mulsign[ 8], 16'd0};
    assign pp_10_o = { 3'd1, ~mulsign[10], booth_PP[10], 1'b0, mulsign[ 9], 18'd0};
    assign pp_11_o = { 1'd1, ~mulsign[11], booth_PP[11], 1'b0, mulsign[10], 20'd0};
    assign pp_12_o = {booth_PP[12], 1'b0, mulsign[11], 22'd0};
endmodule
