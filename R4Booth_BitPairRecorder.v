`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2022 10:36:30 AM
// Design Name: 
// Module Name: R4Booth_BitPairRecorder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module R4Booth_BitPairRecorder(
    input [2:0] pattern_i,
    output mul1x_o,
    output mul2x_o,
    output mulsign_o);

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
    
    assign mul1x_o = (pattern_i[1] ^ pattern_i[0]);
    assign mul2x_o = (pattern_i == 3'b011 || pattern_i == 3'b100);
    assign mulsign_o = pattern_i[2];

endmodule
