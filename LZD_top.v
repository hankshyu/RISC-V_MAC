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
                .base_data_i(data_i[(72 - i*8) -: 8]),
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
        .group_data_i(lv1_zeros[1:0]),
        .group_zero_o(lv2_zeros[0])
    );

    LZD_Group #(2) lzd_grouplv2_1(
        .group_data_i(lv1_zeros[3:2]),
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
        else begin //1 appears in 72 : 9
            if(lv2_zeros[0])begin // 1 appears in 40 : 9
                if(lv1_zeros[2])begin // 1 appears in 24 : 9
                    if(base_zeros[6])begin // 1 appears in 16 : 9
                        
                        if(data_i[16]) shift_num_o = 56;
                        else if(data_i[15]) shift_num_o = 57;
                        else if(data_i[14]) shift_num_o = 58;
                        else if(data_i[13]) shift_num_o = 59;
                        else if(data_i[12]) shift_num_o = 60;
                        else if(data_i[11]) shift_num_o = 61;
                        else if(data_i[10]) shift_num_o = 62;
                        else  shift_num_o = 63; //data_i[9]
                    end
                    else begin // 1 appears in 24 : 17
                        
                        if(data_i[24]) shift_num_o = 48;
                        else if(data_i[23]) shift_num_o = 49;
                        else if(data_i[22]) shift_num_o = 50;
                        else if(data_i[21]) shift_num_o = 51;
                        else if(data_i[20]) shift_num_o = 52;
                        else if(data_i[19]) shift_num_o = 53;
                        else if(data_i[18]) shift_num_o = 54;
                        else  shift_num_o = 55; // data_i[17]
                    end
                end
                else begin // 1 appears in 40 : 25
                    if(base_zeros[4])begin // 1 appears in 32 : 25
                        
                        if(data_i[32]) shift_num_o = 40;
                        else if(data_i[31]) shift_num_o = 41;
                        else if(data_i[30]) shift_num_o = 42;
                        else if(data_i[29]) shift_num_o = 43;
                        else if(data_i[28]) shift_num_o = 44;
                        else if(data_i[27]) shift_num_o = 45;
                        else if(data_i[26]) shift_num_o = 46;
                        else  shift_num_o = 47; //data_i[25]
                    end
                    else begin // 1 appears in 40 : 33
                        
                        if(data_i[40]) shift_num_o = 32;
                        else if(data_i[39]) shift_num_o = 33;
                        else if(data_i[38]) shift_num_o = 34;
                        else if(data_i[37]) shift_num_o = 35;
                        else if(data_i[36]) shift_num_o = 36;
                        else if(data_i[35]) shift_num_o = 37;
                        else if(data_i[34]) shift_num_o = 38;
                        else  shift_num_o = 39; // data_i[33]
                    end
                end
            end
            else begin //1 in 72 : 41
                if(lv1_zeros[0])begin  //1 appears in 56 : 41
                    if(base_zeros[2])begin // 1 appears in 48 : 41
                        
                        if(data_i[48]) shift_num_o = 24;
                        else if(data_i[47]) shift_num_o = 25;
                        else if(data_i[46]) shift_num_o = 26;
                        else if(data_i[45]) shift_num_o = 27;
                        else if(data_i[44]) shift_num_o = 28;
                        else if(data_i[43]) shift_num_o = 29;
                        else if(data_i[42]) shift_num_o = 30;
                        else shift_num_o = 31; // data_i[41]
                    end
                    else begin // 1 appears in 56 : 49
                        
                        if(data_i[56]) shift_num_o = 16;
                        else if(data_i[55]) shift_num_o = 17;
                        else if(data_i[54]) shift_num_o = 18;
                        else if(data_i[53]) shift_num_o = 19;
                        else if(data_i[52]) shift_num_o = 20;
                        else if(data_i[51]) shift_num_o = 21;
                        else if(data_i[50]) shift_num_o = 22;
                        else shift_num_o = 23; // data_i[49]
                    end
                    
                end
                else begin // 1 appears in 72 : 57
                    if(base_zeros[0])begin // 1 appears in 64 : 57
                        
                        if(data_i[64]) shift_num_o = 8;
                        else if(data_i[63]) shift_num_o = 9;
                        else if(data_i[62]) shift_num_o = 10;
                        else if(data_i[61]) shift_num_o = 11;
                        else if(data_i[60]) shift_num_o = 12;
                        else if(data_i[59]) shift_num_o = 13;
                        else if(data_i[58]) shift_num_o = 14;
                        else shift_num_o = 15; // data_i[57]
                    end
                    else begin // 1 appears in 72 : 65

                        if(data_i[72]) shift_num_o = 0;
                        else if(data_i[71]) shift_num_o = 1;
                        else if(data_i[70]) shift_num_o = 2;
                        else if(data_i[69]) shift_num_o = 3;
                        else if(data_i[68]) shift_num_o = 4;
                        else if(data_i[67]) shift_num_o = 5;
                        else if(data_i[66]) shift_num_o = 6;
                        else shift_num_o = 7; // data_i[65]
                        
                    end
                end
            end
        end
    end



endmodule
