`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2022 11:01:59 PM
// Design Name: 
// Module Name: ZeroDetector_Group
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


module ZeroDetector_Group #(
    parameter XLEN = 2
) (
    input [XLEN - 1 : 0] group_data_i,
    output group_zero_o );

    assign group_zero_o = &group_data_i;
    
endmodule