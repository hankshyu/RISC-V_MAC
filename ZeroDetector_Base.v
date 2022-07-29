`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2022 11:01:59 PM
// Design Name: 
// Module Name: ZeroDetector_Base
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


module ZeroDetector_Base #(
    parameter XLEN = 8
) (
    input [XLEN - 1: 0] base_data_i,
    output zero_o );

    assign zero_o = (base_data_i == 8'd0);
    
endmodule