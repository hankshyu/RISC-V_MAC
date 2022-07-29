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
  parameter X_LEN = 74,
  parameter PARM_SHIFTZERO = $clog2(X_LEN)
) (
    input  [X_LEN - 1 : 0] data_i,

    output reg [PARM_SHIFTZERO - 1 : 0] shift_num_o,
    output allzero_o );
    
    
    wire [7:0] base_zeros;
    generate
        genvar i;
        for(i = 0; i < 8; i = i+1)begin
            LZD_Base #(8) lzd_base(
                .base_data_i(data_i[72 - i*8 +: 8]),
                .zero_o(base_zeros[i])
            );
        end
    endgenerate
    
    wire [3:0] lv1_zeros;
    generate
        genvar j;
        for (j = 0; j < 4; j = j+1) begin
            LZD_Group #(2) lzd_grouplv1(
                .group_data_i(base_zeros[j*2 +:2]),
                .group_zero_o(lv1_zeros[j])
            );
        end
    endgenerate

    wire [1:0] lv2_zeros;
    LZD_Group #(2) lzd_grouplv2_0(
        .group_data_i(lv1_zeros[0 : 1]),
        .group_zero_o(lv2_zeros[0])
    );

    LZD_Group #(2) lzd_grouplv2_1(
        .group_data_i(lv1_zeros[2 : 3]),
        .group_zero_o(lv2_zeros[1])
    );
    
    wire lv3_zeros;
    LZD_Group #(2) lzd_grouplv3(
        .group_data_i(lv2_zeros),
        .group_zero_o(lv3_zeros)
    );

    wire left_zero = (data_i[8:0] == 9'd0);
    

    //output logic
    assign allzero_o = lv3_zeros & left_zero;

    always @(*) begin
        if(lv3_zeros)begin
            if(data_i[8])  shift_num_o = 64;
            else if(data_i[7]) shift_num_o = 65;
            else if(data_i[6]) shift_num_o = 66;
            else if(data_i[5]) shift_num_o = 67;
            else if(data_i[4]) shift_num_o = 68;
            else if(data_i[3]) shift_num_o = 69;
            else if(data_i[2]) shift_num_o = 70;
            else if(data_i[1]) shift_num_o = 71;
            else if(data_i[0]) shift_num_o = 72;
            else shift_num_o = {PARM_SHIFTZERO{1'b1}}; //when all zero 
        end
        else begin
            
        end
    end



endmodule
