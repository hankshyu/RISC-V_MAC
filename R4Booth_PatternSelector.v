`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2022 05:35:06 PM
// Design Name: 
// Module Name: R4Booth_PatternSelector
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


module R4Booth_PatternSelector(
        input [1:0] ba_i,
        input sel_1x_i,
        input sel_2x_i,
        input sel_sign_i,
        output boothbit_o);
        
        
        wire zerosit;
        assign zerosit = ~((sel_1x_i&&ba_i[1]) | (sel_2x_i&&ba_i[0]));
        assign boothbit_o = ~((zerosit)^(sel_sign_i));



endmodule
