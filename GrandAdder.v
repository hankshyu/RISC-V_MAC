`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2022 07:51:44 PM
// Design Name: 
// Module Name: GrandAdder
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

module GrandAdder #(
    parameter PARM_EXP  = 8,
    parameter PARM_MANT = 23
) (
   input [2*PARM_MANT + 1 : 0]      CSA_sum_i,  // The sum of the former unit  
   input [2*PARM_MANT + 1 : 0]      CSA_carry_i,  // The carry-out of the former unit
   input                            Sub_Sign_i,
   input [2 : 0]                    Sign_cor_i,//strange name
   input                            Exp_mv_sign_i,
   input                            Mv_halt_i,
   input [PARM_MANT + 3 : 0]        BH_i, //strange name
   input                            Sign_aligned_i,
   input [PARM_EXP + 1 : 0]         Exp_mv_neg_i, 
   
   input                            B_Inf_i,
   input                            C_Inf_i,
   input                            B_Zero_i,
   input                            C_Zero_i, 
   input                            B_NaN_i,
   input                            C_Nan_i,
   

   output reg [3*PARM_MANT + 4 : 0] PosSum_o,
   output                           Sign_o,
   output [3*PARM_MANT + 4 : 0]     A_LZA_o,
   output [3*PARM_MANT + 4 : 0]     B_LZA_o,
   output                           Minus_sticky_bit_o,
   output                           Sign_change_o);


////////////////////////////////////////////////////////////////////////////////////  
//                  LSBs                                                          //
////////////////////////////////////////////////////////////////////////////////////

    wire Carry_postcor = (Exp_mv_sign_i)? 0 : (~(|Sign_cor_i) ^ CSA_carry_i[2*PARM_MANT + 1]);

    wire Carry_uninv_ls;
    wire [2*PARM_MANT+1 : 0] Sum_uninv_ld;

    assign {Carry_uninv_ls, Sum_uninv_ld} =  CSA_sum_i + {Carry_postcor, CSA_carry_i[2*PARM_MANT : 0], Sub_Sign_i};

    wire Carry_inv_ls;
    wire [2*PARM_MANT+2 : 0] Sum_inv_ld;

    assign {Carry_inv_ls, Sum_inv_ld} = 2 + {1'b1, ~CSA_sum_i, 1'b1} + {~Carry_postcor, ~CSA_carry_i[2*PARM_MANT : 0], ~Sub_Sign_i, 1'b1};
    //to is added, dont pick if Sub_SI = 0 

////////////////////////////////////////////////////////////////////////////////////
//                  MSBs                                                          //
////////////////////////////////////////////////////////////////////////////////////
    //incrementer

    wire [PARM_MANT + 3 : 0]sum_uninv_hd;
    wire [PARM_MANT + 3 : 0]sum_inv_hd;

    assign {Carryout_uninv_hs, sum_uninv_hd} = (Carry_uninv_ls)? BH_i + 1 : BH_i;
    assign {Carryout_inv_hs, sum_inv_hd} = (Carry_inv_ls)? ~BH_i : ~BH_i - 1;

    wire minus_or_mantbc = ~(B_Inf_i | C_Inf_i | B_Zero_i | C_Zero_i | B_NaN_i | C_Nan_i);

    wire [3*PARM_MANT + 4 : 0] sub_minus = {{BH_i[PARM_MANT+2 : 0], 1'b0} - minus_or_mantbc, 47'd0};
   
    //outputlogic
    
    always @(*) begin
        if(Mv_halt_i)
            PosSum_o = {{26'd0}, Sum_uninv_ld};
        else if(Exp_mv_sign_i)
            PosSum_o = Sub_Sign_i? sub_minus : {BH_i[PARM_MANT+2 : 0], 48'd0};
        else if(sum_uninv_hd[PARM_MANT + 3])
            PosSum_o = {sum_inv_hd[PARM_MANT + 2 : 0], Sum_inv_ld[2*PARM_MANT + 2 : 1]};
        else
            PosSum_o = {sum_uninv_hd[PARM_MANT + 2 : 0], Sum_uninv_ld};
    end

    assign sign_o = Exp_mv_sign_i? Sign_aligned_i: (sum_uninv_hd[PARM_MANT + 3] ^ Sign_aligned_i);
    assign Sign_change_o = sum_uninv_hd[PARM_MANT + 3];


////////////////////////////////////////////////////////////////////////////////////
//                  Sticky_bit                                                    //
////////////////////////////////////////////////////////////////////////////////////
// for Sign_amt_DI=1'b1, if is difficult to compute combined with other cases. 
// When addition,   | (b*c) ; when substruction, | (b*c) for rounding excption trunction. 

   assign Minus_sticky_bit_o = Exp_mv_sign_i && (minus_or_mantbc);

/////////////////////////////////////////////////////////////////////////////////////
//                  to LZA                                                         //
/////////////////////////////////////////////////////////////////////////////////////

   assign A_LZA_DO = PosSum_o;
   assign B_LZA_DO = 74'd0 ;

endmodule