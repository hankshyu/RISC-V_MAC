`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2022 03:24:24 PM
// Design Name: 
// Module Name: LZD_top
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


module LZD_top #(
  parameter X_LEN = 74
) (
    input  [X_LEN - 1 : 0] data_i,

    output [$clog2(X_LEN)-1:0] shift_num_o,
    output allzero_o );
    
    wire [7:0] base_zeros;
    generate
        genvar i;
        for(i = 0; i < 8; i = i+1)begin
            LZD_Base #(8) lzd_base(
                .base_data_i(data_i[72 - i*8 +: 8]),
                .zero_i(base_zeros[i])
            );
        end
    endgenerate





endmodule
