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
    parameter PARM_PP = (PARM_MANT/2) + 1; //booth's algorithm produces at most CEILING( (n+1))/2 )  partial products

    //Modified Booth's Recording Table
    // Multiplier   
    //| Bit i + 1   |   Bit i   |   Bit i - 1   |   Multiplicand selected   |
    //|     0       |    0      |       0       |   0 x Multiplicand        |
    //|     0       |    0      |       1       |  +1 x Multiplicand        |
    //|     0       |    1      |       0       |  +1 x Multiplicand        |
    //|     0       |    1      |       1       |  +2 x Multiplicand        |
    //|     1       |    0      |       0       |  -2 x Multiplicand        |
    //|     1       |    0      |       1       |  -1 x Multiplicand        |
    //|     1       |    1      |       0       |  -1 x Multiplicand        |
    //|     1       |    1      |       1       |   0 x Multiplicand        |
    

    wire [PARM_MANT + 3 : 0] mant_B_Padding = {2'd0, MantB_i, 1'd0};

    wire [PARM_PP - 1 : 0] mul1x; // mul1x_o = bit (i) ^ bit(i - 1)
    wire [PARM_PP - 1 : 0] mul2x; // mul2x_o = (pattern == 3'b011 || pattern_i == 3'b100);
    wire [PARM_PP - 1 : 0] mulsign; // mulsign_o = bit (i + 1)
    
    
    generate
        genvar j;
        for (j = 0; j < 13; j = j+1) begin
            assign mul1x[j] =  mant_B_Padding[j*2] ^ mant_B_Padding[j*2 + 1];
            assign mul2x[j] =   ((~mant_B_Padding[j*2]) & (~mant_B_Padding[j*2 + 1]) & (mant_B_Padding[j*2 + 2])) ||
                                ((mant_B_Padding[j*2]) & (mant_B_Padding[j*2+1]) & (~mant_B_Padding[j*2+2]));
            assign mulsign[j] = mant_B_Padding[j*2 + 2];
        end
    endgenerate

    
    // Partial product is differentiate by 0x 1x 2x here
    reg [PARM_MANT + 1 : 0] booth_PP_tmp [PARM_PP - 1: 0];
    wire [PARM_MANT + 1 : 0] booth_PP [PARM_PP - 1: 0];
    
    integer idx;
    always @(*) begin
        for (idx = 0; idx < PARM_PP; idx = idx + 1) begin
            if(mul1x[idx]) booth_PP_tmp[idx] = MantA_i;
            else if(mul2x[idx]) booth_PP_tmp[idx] = MantA_i << 1;
            else booth_PP_tmp[idx] = 0;
            
        end
    end
    
    //bit flip if it's negative due to booth's algorithm, we calculate 2's complement by bitwise invert and add 1 to the next row.
    generate
        genvar k;
        for(k = 0; k < PARM_PP; k = k + 1)begin
            assign booth_PP[k] = (mulsign[k])? ~booth_PP_tmp[k] : booth_PP_tmp[k];
        end
    endgenerate 


    //by adding the "1 triagle" in the left up. It's under the assumption that it's an unsigned Multiplication.
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
