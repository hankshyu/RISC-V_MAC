`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2022 04:52:54 PM
// Design Name: 
// Module Name: MAC32_top_tb
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

module MAC32_top_tb;

    parameter PARM_RM_RNE           = 3'b000;
    parameter PARM_RM_RTZ           = 3'b001;
    parameter PARM_RM_RDN           = 3'b010;
    parameter PARM_RM_RUP           = 3'b011;
    parameter PARM_RM_RMM           = 3'b100;

    reg clk;
    reg [25-1 : 0] label;
    reg [32-1 : 0] a;
    reg [32-1 : 0] b;
    reg [32-1 : 0] c;

    wire [31:0] my_result;
    wire my_OF, my_UF, my_NX, my_NV;
    wire [3:0] dbg_tail;

    reg [2 : 0] my_rm;//rounding mode


    shortreal sa, sb, sc, sans;
    wire [31 : 0] sans_wire;
    
    always @(*) sans = sa + (sb * sc);
    assign sans_wire = $shortrealtobits(sans);
    
    initial clk = 0;
    always # 5 clk = ~clk;

    initial label = 0;
    always @(posedge clk ) label = label + 1;
    MAC32_top uut_me
    (
    //Inputs
    .Rounding_mode_i(my_rm),
    .A_i(a),
    .B_i(b),
    .C_i(c),

    .Result_o(my_result),
    .OF_o(my_OF),
    .UF_o(my_UF),
    .NX_o(my_NX),
    .NV_o(my_NV),
    .dbg_tail_o(dbg_tail)
    );


    task print(input string str);
        $display("%s",str);
    endtask

    task printblank();
        print("");
    endtask
    
    task testtype(input string tt);
        begin
            printblank();
            print("=============================================================================================================================================");
            $display("******* %s",tt);
            print("=============================================================================================================================================");
        end

    endtask

    task testlabel(input string lb);
        printblank();
        $display("%s",lb);
    endtask 


    task printRoundingInfo();

        print("> Rounding Mode: RNE - Round to Nearest, ties to Even");
        print("> Rounding Mode: RTZ - Round towards Zero");
        print("> Rounding Mode: RDN - Round Down    (towards -INFINITY)");
        print("> Rounding Mode: RUP - Round UP      (towards +INFINITY)");
        print("> Rounding Mode: RMM - Round to Nearest, ties Max Magnitude");

    endtask

    task StartText();
        
        printblank();
        printblank();
        printblank();
        print("RISC-V Multiply-accumulate Testbench");

    endtask

    task EndTest();

        printblank();
        print("RISC-V Multiply-accumulate Testbench ends sucessfully!!");
        $finish;

    endtask


    reg showrgs; //show 
    task showresult;
        begin
            $write("%03d ",label);
            if(my_rm == 3'b000) $write("[RNE]");
            if(my_rm == 3'b001) $write("[RTZ]");
            if(my_rm == 3'b010) $write("[RDN]");
            if(my_rm == 3'b011) $write("[RUP]");
            if(my_rm == 3'b100) $write("[RMM]");
            $write(" %8h(%13e) + %8h(%13e) x %8h(%13e) = %8h(%13e)\t",a,$bitstoshortreal(a),b,$bitstoshortreal(b),c,$bitstoshortreal(c),my_result,$bitstoshortreal(my_result));
            if(showrgs) $write(" [%b.%b] ",dbg_tail[3],dbg_tail[2:0]);

            if(my_NV) $write("  NV(Invalid)");
            if(my_OF) $write("  OF(Overflw)");
            if(my_UF) $write("  UF(Underfw)");
            if(my_NX) $write("  NX(Inexact)");
            
            if(my_NV|my_OF|my_UF|my_NX) printblank();
            else $display("  ;");

        end
        
    endtask 

    parameter [31:0]SIGN_INVERT_MASK = 32'h80000000;
    function  [31:0] sign_inv;
        input [31 : 0] num_o;

        return num_o ^ SIGN_INVERT_MASK;

    endfunction
    
    task FullSignTest(input logic [31:0] a_in, input logic [31:0] b_in, input logic [31:0] c_in);
        
        // (+, +, +)
        a = a_in;
        b = b_in;
        c = c_in;
        @(posedge clk)
        // (+, -, +)
        b = sign_inv(b_in);
        @(posedge clk)
        // (+, +, 1)
        b = b_in;
        c = sign_inv(c_in);
        @(posedge clk)
        // (+, -, -)
        b = sign_inv(b_in);
        c = sign_inv(c_in);
        @(posedge clk)
        // (-, +, +)
        a = sign_inv(a_in);
        b = b_in;
        c = c_in;
        @(posedge clk)
        // (-, -, +)
        b = sign_inv(b_in);
        @(posedge clk)
        // (-, +, -)
        b = b_in;
        c = sign_inv(c_in);
        @(posedge clk)
        // (-, -, -)
        b = sign_inv(b_in);
        c = sign_inv(c_in);

    endtask 


    task RoundingTest(input logic [31:0] a_in, input logic [31:0] b_in, input logic [31:0] c_in);
    integer k;
        begin
            for (k = 0; k < 5; k++) begin
                my_rm  = k;

                a = a_in;
                b = b_in;
                c = c_in;
                @(posedge clk)
                ;
            end
        end
        
    endtask


    always @(posedge clk) begin
        # 1;
        showresult();
    end
    integer idx;
    initial begin
        showrgs = 0;
        @(posedge clk)
        label = 1;
        my_rm = PARM_RM_RTZ; // use RTZ

        testtype("Invalid Operation Test");
        testlabel("a) computational operation on a NaN");
        a = 32'h7fc00000; //NaN
        b = 32'hac822ea3; //-3.69999994185e-12
        c = 32'hcc03dec4; //-34568976.0
        @(posedge clk)
        a = 32'hb508e6ef; //-5.1000000667e-07
        b = 32'h7fc00000; //NaN
        c = 32'hcc03dec4; //-34568976.0 
        @(posedge clk)
        a = 32'hb508e6ef; //-5.1000000667e-07
        b = 32'hac822ea3; //-3.69999994185e-12
        c = 32'h7fc00000; //NaN
        @(posedge clk)
        a = 32'h00000000; //0
        b = 32'h7fc00000; //NaN
        c = 32'h7f800000; //+Inf
        @(posedge clk)
        a = 32'hff800000; //-Inf
        b = 32'h7f800000; //+Inf
        c = 32'h7fc00000; //NaN
        
        @(posedge clk)
        testlabel("b,c) multiplication 0 x Inf / Inf x 0, or fusedMultiplyAdd(0, Inf, c)");
        a = 32'hb508e6ef; //-5.1000000667e-07
        b = 32'h00000000; //0
        c = 32'h7f800000; //+Inf
        @(posedge clk)
        a = 32'hcc03dec4; //-34568976.0
        b = 32'h00000000; //0
        c = 32'hff800000; //-Inf
        @(posedge clk)
        a = 32'hb508e6ef; //-5.1000000667e-07
        b = 32'h7f800000; //+Inf
        c = 32'h00000000; //0
        @(posedge clk)
        a = 32'hcc03dec4; //-34568976.0
        b = 32'hff800000; //-Inf
        c = 32'h00000000; //0
        @(posedge clk)
        a = 32'hff800000; //-Inf
        b = 32'h7f800000; //+Inf
        c = 32'h00000000; //0
        @(posedge clk)
        a = 32'hff800000; //-Inf
        b = 32'h00000000; //0
        c = 32'hff800000; //-Inf

        @(posedge clk)
        testlabel("d) magnitude subtraction of infinities Inf - Inf/ -Inf + Inf");
        a = 32'hff800000; // - Inf
        b = 32'h3f800000; //1
        c = 32'h7f800000; // + Inf
        @(posedge clk)
        a = 32'h7f800000; // + Inf       
        b = 32'hff800000; // - Inf
        c = 32'h3f800000; //1
        @(posedge clk)
        a = 32'h7f800000; // + Inf       
        b = 32'hc04889a0; //-3.13339996337890625
        c = 32'h7f800000; // + Inf  
        @(posedge clk)
        a = 32'hff800000; // - Inf
        b = 32'hfc5094ec; // -4.33207296417e+36
        c = 32'hff800000; // - Inf
        @(posedge clk)
        a = 32'hff800000; // - Inf
        b = 32'hff800000; // - Inf
        c = 32'hff800000; // - Inf

        //Infinites
        @(posedge clk) //result seems incorrect....
        testtype("Dancing with Infinities (Operations on infinite operands are usually exact and therefore signal no exceptions)");
        testlabel("a) + Infinity");
        a = 32'h00000000; //0
        b = 32'hff800000; // - Inf
        c = 32'hff800000; // - Inf
        @(posedge clk)
        a = 32'h43ffffff; //511.999969482
        b = 32'h7f800000; // + Inf
        c = 32'h404889a0; //3.13339996337890625
        @(posedge clk)
        a = 32'hc04889a0; //-3.13339996337890625
        b = 32'h004889a0; //6.66152627087e-39 (denormalized)
        c = 32'h7f800000; // + Inf
        @(posedge clk)
        a = 32'hc04889a0; //-3.13339996337890625
        b = 32'h37b00000; //2.09808349609e-05
        c = 32'h7f800000; // + Inf
        @(posedge clk)
        a = 32'h37b00000; //2.09808349609e-05
        b = 32'hff800000; // - Inf
        c = 32'hc04889a0; //-3.13339996338
        @(posedge clk)
        a = 32'h804e89b8; //-7.21257287898e-39 (denormalized)
        b = 32'hff800000; // - Inf
        c = 32'h804e89a0; //-7.212539e-39 (denormalized)
        @(posedge clk)
        a = 32'h7f80_0000; // + Inf
        b = 32'hff80_0000; // - Inf
        c = 32'hff80_0000; // - Inf


        @(posedge clk)
        testlabel("b) - Infinity");
        a = 32'h00000000; //0
        b = 32'h7f800000; // + Inf
        c = 32'hff800000; // - Inf
        @(posedge clk)
        a = 32'hc288ae14; //-68.339996337890625
        b = 32'hc04889a0; //-3.13339996337890625
        c = 32'h7f800000; // + Inf
        @(posedge clk)
        a = 32'h37b00000; //2.09808349609e-05
        b = 32'hff800000; // - Inf
        c = 32'h41bab852; //23.340000152587890625
        @(posedge clk)
        a = 32'h05b00000;  //1.65509604596E-35
        b = 32'h7f800000; // + Inf
        c = 32'h804889a0; //-6.66152627087e-39 (denormalized)
        @(posedge clk)
        a = 32'h804e89b8; //-7.21257287898e-39 (denormalized)
        b = 32'h7f800000; // + Inf
        c = 32'h804e89a0; //-7.212539e-39 (denormalized)
        @(posedge clk)
        a = 32'h7dc889a0;  //3.33200236265e+37
        b = 32'h7df889a0; // 4.12953916012e+37
        c = 32'hff800000; // - Inf
        @(posedge clk)
        a = 32'hff80_0000; // - Inf
        b = 32'h7f80_0000; // + Inf
        c = 32'hff80_0000; // - Inf

        //Overflow and Underflows.....
        @(posedge clk)
        testtype("Coke Zero");
        testlabel("a) 0 + 0 x 0, lots of zeros");
        FullSignTest(32'h00000000, 32'h00000000, 32'h00000000);
        
        @(posedge clk)
        testlabel("b) sth + 0 = sth");
        a = 32'h4425f1ec; //663.780029296875
        b = 32'h45197e5d; //2455.8976
        c = 32'h00000000; //+0
        @(posedge clk)
        a = 32'h7735f1ed; //3.69028347337e+33
        b = 32'h80000000; //-0
        c = 32'h81b476e9; //-6.629218494e-38
        @(posedge clk)
        a = 32'h7735f1ed; //3.69028347337e+33
        b = 32'h00000000; //+0
        c = 32'h81b476e9; //-6.629218494e-38
        @(posedge clk)
        a = 32'h81b476e9; //-6.629218494e-38
        b = 32'h7735f1ed; //3.69028347337e+33
        c = 32'h80000000; //-0
        @(posedge clk)
        a = 32'h7735f1ed; //3.69028347337e+33
        b = 32'h01b476e9; //6.629218494e-38
        c = 32'h00000000; //+0
        @(posedge clk)
        a = 32'h81b476e9; //-6.629218494e-38
        b = 32'h73b476e9; //2.85957403269e+31
        c = 32'h80000000; //-0
        @(posedge clk)
        a = 32'h81b476e9; //-6.629218494e-38
        b = 32'h73b476e9; //2.85957403269e+31
        c = 32'h00000000; //+0
        @(posedge clk)
        a = 32'h00017669; //1.34313056507e-40 (denormalized)
        b = 32'h80217669; //-3.07304893356e-39 (denormalized)
        c = 32'h00000000; //+0
        @(posedge clk)
        b = 32'h00217669; //3.07304893356e-39 (denormalized)
        c = 32'h80000000; //-0
        a = 32'h80017669; //-1.34313056507e-40 (denormalized)
        @(posedge clk)
        a = 32'h00217669; //3.07304893356e-39 (denormalized)
        b = 32'h80000000; //-0
        c = 32'h00000000; //+0


        @(posedge clk)
        testlabel("c) Zero + Something & Result is Inexact");
        a = 32'h00000000; //+0
        b = 32'hc288ae14; //-68.339996337890625
        c = 32'h421a851f; //38.630001068115234375
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hc288ae14; //-68.339996337890625
        c = 32'h421a851f; //38.630001068115234375
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h4c5c0000; //57671680
        c = 32'h4de60c29; //482444576
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hcde60c29; //-482444576
        c = 32'h4c5c0000; //57671680
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h00023c21; //2.05241179577e-40(denormalized)
        c = 32'h77611cc1; //4.56582027998e+33
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hedfe3327; //-9.83387898546e+27
        c = 32'hd0fe3327; //-34118121472.0
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hedfe3327; //-9.83387898546e+27
        c = 32'hd0fe3327; //-34118121472.0
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h50f29abf; //32561821696.0
        c = 32'h9aec1ea5; //-9.76568211917e-23
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h25b136b7; //3.07416817451e-16
        c = 32'h9aec1ea5; //-9.76568211917e-23

        @(posedge clk);
        printblank();
        a = 32'h00000000; //+0
        b = 32'h0007ffc0; //7.3450460306e-40 (denormalized 13 x 1s)
        c = 32'h7f7ff000; //3.40199290171e+38 (mantissa left is all 1)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h8007ffc0; //-7.34325236857e-40 (denormalized 13 x 1s)
        c = 32'h7f7ff000; //3.40199290171e+38 (mantissa left is all 1)

        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h0007ffc0; //7.3450460306e-40 (denormalized 13 x 1s)
        c = 32'hff7ff000; //-3.40199290171e+38 (mantissa left is all 1)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h8007ffc0; //-7.34325236857e-40 (denormalized 13 x 1s)
        c = 32'hff7ff000; //-3.40199290171e+38 (mantissa left is all 1)
        @(posedge clk);
        a = 32'h80000000; //+0
        b = 32'h0007ffc0; //7.3450460306e-40 (denormalized 13 x 1s)
        c = 32'h7f7ff000; //3.40199290171e+38 (mantissa left is all 1)
        @(posedge clk)
        a = 32'h80000000; //+0
        b = 32'h8007ffc0; //-7.34325236857e-40 (denormalized 13 x 1s)
        c = 32'h7f7ff000; //3.40199290171e+38 (mantissa left is all 1)

        @(posedge clk)
        a = 32'h80000000; //+0
        b = 32'h0007ffc0; //7.3450460306e-40 (denormalized 13 x 1s)
        c = 32'hff7ff000; //-3.40199290171e+38 (mantissa left is all 1)
        @(posedge clk)
        a = 32'h80000000; //+0
        b = 32'h8007ffc0; //-7.34325236857e-40 (denormalized 13 x 1s)
        c = 32'hff7ff000; //-3.40199290171e+38 (mantissa left is all 1)


        @(posedge clk) //NX Flag = 0
        testlabel("d) Zero + Something & Result is Exact");
        a = 32'h00000000; //+0
        b = 32'hfe580000; //-7.17783117724e+37
        c = 32'h86ec0000; //-8.87733333741e-35
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hfe580000; //-7.17783117724e+37
        c = 32'h06ec0000; //8.87733333741e-35
        
        @(posedge clk)
        printblank();
        a = 32'h00000000; //+0
        b = 32'h58fff000; //2.25125005787e+15
        c = 32'h4efff000; //2146959360.0
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h58fff000; //2.25125005787e+15
        c = 32'hcefff000; //-2146959360.0
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hd8fff000; //-2.25125005787e+15
        c = 32'h4efff000; //2146959360.0
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hd8fff000; //-2.25125005787e+15
        c = 32'hcefff000; //-2146959360.0
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h58fff000; //2.25125005787e+15
        c = 32'h4efff000; //2146959360.0
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h58fff000; //2.25125005787e+15
        c = 32'hcefff000; //-2146959360.0
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hd8fff000; //-2.25125005787e+15
        c = 32'h4efff000; //2146959360.0
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hd8fff000; //-2.25125005787e+15
        c = 32'hcefff000; //-2146959360.0
        
        @(posedge clk)
        printblank();
        a = 32'h00000000; //+0
        b = 32'h7efff000; //1.70099645086e+38(mantissa left is all 1)
        c = 32'h02fff000; //3.76066356767e-37(mantissa left is all 1)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hfefff000; //-1.70099645086e+38(mantissa left is all 1)
        c = 32'h02fff000; //3.76066356767e-37(mantissa left is all 1)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h7efff000; //1.70099645086e+38(mantissa left is all 1)
        c = 32'h82fff000; //-3.76066356767e-37(mantissa left is all 1)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hfefff000; //-1.70099645086e+38(mantissa left is all 1)
        c = 32'h82fff000; //-3.76066356767e-37(mantissa left is all 1) 
        @(posedge clk)         
        a = 32'h80000000; //-0
        b = 32'h7efff000; //1.70099645086e+38(mantissa left is all 1)
        c = 32'h02fff000; //3.76066356767e-37(mantissa left is all 1)
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hfefff000; //-1.70099645086e+38(mantissa left is all 1)
        c = 32'h02fff000; //3.76066356767e-37(mantissa left is all 1)
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h7efff000; //1.70099645086e+38(mantissa left is all 1)
        c = 32'h82fff000; //-3.76066356767e-37(mantissa left is all 1)
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hfefff000; //-1.70099645086e+38(mantissa left is all 1)
        c = 32'h82fff000; //-3.76066356767e-37(mantissa left is all 1)  

        @(posedge clk);
        printblank();
        a = 32'h00000000; //+0
        b = 32'h0007ff00; //7.34325236857e-40
        c = 32'h7f7ff000; //3.40199290171e+38(mantissa left is all 1)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h8007ff00; //-7.34325236857e-40
        c = 32'h7f7ff000; //3.40199290171e+38(mantissa left is all 1)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h0007ff00; //7.34325236857e-40
        c = 32'hff7ff000; //-3.40199290171e+38(mantissa left is all 1)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h8007ff00; //-7.34325236857e-40
        c = 32'hff7ff000; //-3.40199290171e+38(mantissa left is all 1)
        @(posedge clk);
        a = 32'h80000000; //+0
        b = 32'h0007ff00; //7.34325236857e-40
        c = 32'h7f7ff000; //3.40199290171e+38(mantissa left is all 1)
        @(posedge clk)
        a = 32'h80000000; //+0
        b = 32'h8007ff00; //-7.34325236857e-40
        c = 32'h7f7ff000; //3.40199290171e+38(mantissa left is all 1)
        @(posedge clk)
        a = 32'h80000000; //+0
        b = 32'h0007ff00; //7.34325236857e-40
        c = 32'hff7ff000; //-3.40199290171e+38(mantissa left is all 1)
        @(posedge clk)
        a = 32'h80000000; //+0
        b = 32'h8007ff00; //-7.34325236857e-40
        c = 32'hff7ff000; //-3.40199290171e+38(mantissa left is all 1)

        //Overflow (IEEE 754-2008)
        // The overflow exception shall be signaled if and only if the destination format’s largest finite number is
        // exceeded in magnitude by what would have been the rounded floating-point result (see 4) were the exponent
        // range unbounded. The default result shall be determined by the rounding-direction attribute and the sign of
        // the intermediate result as follows:
        // a) roundTiesToEven and roundTiesToAway carry all overflows to ∞ with the sign of the intermediate
        // result.
        // b) roundTowardZero carries all overflows to the format’s largest finite number with the sign of the
        // intermediate result.
        // c) roundTowardNegative carries positive overflows to the format’s largest finite number, and carries
        // negative overflows to −∞.
        // d) roundTowardPositive carries negative overflows to the format’s most negative finite number, and
        // carries positive overflows to +∞.
        // In addition, under default exception handling for overflow, the overflow flag shall be raised and the inexact
        // exception shall be signaled.

        @(posedge clk)
        showrgs = 1;
        testtype("Rounding Test");
        printRoundingInfo();
        
        testlabel("a) Overflows ");
        print("#1. + Overflow");
        RoundingTest(32'h00000000, 32'h4e7fffff, 32'h71c00000);
        //a = 32'h00000000; //+0
        //b = 32'h4e7fffff; //268435440.0(Mant full * 2 ^ 29)
        //c = 32'h71c00000; //1.90147590034e+30(1.1 x 2^100)
        print("#2. - Overflow");
        RoundingTest(32'h00000000, 32'h4e7fffff, 32'hf1c00000);
        //a = 32'h00000000; //+0
        //b = 32'h4e7fffff; //268435440.0(Mant full * 2 ^ 29)
        //c = 32'hf1c00000; //-1.90147590034e+30(1.1 x 2^100)
        

        testlabel("b.1) 0.0xx");
        print("#1. + 0.000");
        RoundingTest(32'h00000000, 32'h3dfc0000, 32'h42400000);
        //a = 32'h00000000; //+0
        //b = 3dfc0000; 0.123046875 (2^ -4, 1.11111)
        //c = 42400000; 48.0 (2^5, 1.1)
        print("#2. - 0.000");
        RoundingTest(32'h80000000, 32'h3dfc0000, 32'hc2400000);
        //a = 32'h80000000; //-0
        //b = 3dfc0000; 0.123046875 (2^ -4, 1.11111)
        //c = c2400000; -48.0 (2^5, 1.1)

        print("#3. + 0.001");
        RoundingTest(32'h27e00120, 32'h3dfc0000, 32'h42400000);
        //a = 27e00120; 6.21737091065e-15(2^-48)
        //b = 3dfc0000; 0.123046875 (2^ -4, 1.11111)
        //c = 42400000; 48.0 (2^5, 1.1)
        print("#4. - 0.001");
        RoundingTest(32'ha7e00120, 32'h3dfc0000, 32'hc2400000);
        //a = a7e00120; -6.21737091065e-15(2^-48)
        //b = 3dfc0000; 0.123046875 (2^ -4, 1.11111)
        //c = c2400000; -48.0 (2^5, 1.1)

        print("#5. + 0.010");
        RoundingTest(32'h1f800000, 32'h2c70000e, 32'h3f800000);
        //a = 1f800000; // 5.42101150866e-20 (2^-64, 1.00..000)
        //b = 2c70000e; // 3.41060816741e-12 (2^-39, 1.11100...001110)
        //c = 3f800000; // +1
        print("#6. - 0.010");
        RoundingTest(32'h9f800000, 32'hac70000e, 32'h3f800000);
        //a = 9f800000; // -5.42101150866e-20 (2^-64, 1.00..000)
        //b = ac70000e; // -3.41060816741e-12(2^-39, 1.11100...001110)
        //c = 3f800000; // +1
        
        print("#7. + 0.011");
        RoundingTest(32'h1f800001, 32'h2c70000e, 32'h3f800000);
        //a = 1f800001; // 5.42101150866e-20 (2^-64, 1.00..001)
        //b = 2c70000e; // 3.41060816741e-12 (2^-39, 1.11100...001110)
        //c = 3f800000; // +1
        print("#8. - 0.011");
        RoundingTest(32'h9f800001, 32'hac70000e, 32'h3f800000);
        //a = 9f800001; // -5.42101150866e-20 (2^-64, 1.00..001)
        //b = ac70000e; // -3.41060816741e-12(2^-39, 1.11100...001110)
        //c = 3f800000; // +1
        

        testlabel("b.2) 1.0xx");
        print("#1. + 1.000");
        RoundingTest(32'h3f000000, 32'h41800000, 32'h47fffffe);
        //a = 3f000000 //0.5(2 ^ -1 , 1.0)
        //b = 41800000 //16(2^4, 1.0)
        //c = 47fffffe //131071.984375(2^16 1.11..110)
        print("#2. - 1.000");
        RoundingTest(32'hbf000000, 32'h41800000, 32'hc7fffffe);
        //a = bf000000 //0.5(2 ^ -1 , 1.0)
        //b = 41800000 //16(2^4, 1.0)
        //c = c7fffffe //131071.984375(2^16 1.11..110)

        print("#3. + 1.001");
        RoundingTest(32'h1ea9800c, 32'h48000001, 32'h44080000);
        //a = 32'h1ea9800c; //1.7946529957e-20
        //b = 32'h48000001; //131072.015625(2 ^ 17 1.___1)
        //c = 32'h44080000; //139264.0(2^9 1.0001)
        print("#4. - 1.001"); 
        RoundingTest(32'h1ea9800c, 32'hc8000001, 32'h44080000);
        //a = 32'h1ea9800c; //1.7946529957e-20
        //b = 32'hc8000001; //-131072.015625(2 ^ 17 1.___1)
        //c = 32'h44080000; //139264.0(2^9 1.0001)

        print("#5. + 1.010");
        RoundingTest(32'h1f800000, 32'h2c70000f, 32'h3f800000);
        //a = 1f800000; // 5.42101150866e-20 (2^-64, 1.00..000)
        //b = 2c70000f; // 3.41060816741e-12 (2^-39, 1.11100...001111)
        //c = 3f800000; // +1
        print("#6. - 1.010");
        RoundingTest(32'h9f800000, 32'hac70000f, 32'h3f800000);
        //a = 9f800000; // -5.42101150866e-20 (2^-64, 1.00..000)
        //b = ac70000f; // -3.41060816741e-12(2^-39, 1.11100...001111)
        //c = 3f800000; // +1
        
        print("#7. + 1.011");
        RoundingTest(32'h1f800001, 32'h2c70000f, 32'h3f800000);
        //a = 1f800001; // 5.42101150866e-20 (2^-64, 1.00..001)
        //b = 2c70000f; // 3.41060816741e-12 (2^-39, 1.11100...001111)
        //c = 3f800000; // +1
        print("#8. - 1.011");
        RoundingTest(32'h9f800001, 32'hac70000f, 32'h3f800000);
        //a = 9f800001; // -5.42101150866e-20 (2^-64, 1.00..001)
        //b = ac70000f; // -3.41060816741e-12(2^-39, 1.11100...001111)
        //c = 3f800000; // +1


        testlabel("c.1) 0.101 ~ 0.111");
        print("#1. + 0.101");
        RoundingTest(32'h3c000000, 32'h45800003, 32'h43400000);
        //a = 3c000000; // 0.0078125 (2^-7 ,1.0)
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = 43400000; // 192.0 (2^7 1.1)
        print("#2. - 0.101");
        RoundingTest(32'hbc000000, 32'h45800003, 32'hc3400000);
        //a = bc000000; // -0.0078125 (2^-7 ,1.0)
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = c3400000; // -192.0 (2^7 1.1)

        print("#3. + 0.110");
        RoundingTest(32'h3c800000, 32'h45800003, 32'h43400000);
        //a = 3c800000; // 0.0078125 (2^-6 ,1.0)
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = 43400000; // 192.0 (2^7 1.1)
        print("#4. - 0.110");
        RoundingTest(32'hbc800000, 32'h45800003, 32'hc3400000);
        //a = bc800000; // -0.0078125 (2^-7 ,1.0)
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = c3400000; // -192.0 (2^7 1.1)

        print("#5. + 0.111");
        RoundingTest(32'h3c800001, 32'h45800003, 32'h43400000);
        //a = 3c800001; // 0.0078125 (2^-6 ,1.0..01)
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = 43400000; // 192.0 (2^7 1.1)
        print("#6. - 0.111");
        RoundingTest(32'hbc800001, 32'h45800003, 32'hc3400000);
        //a = bc800001; // -0.0078125 (2^-7 ,1.0...01)
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = c3400000; // -192.0 (2^7 1.1)


        testlabel("c.2) 1.1xx");
        print("#1. + 1.101");
        RoundingTest(32'h38d00000, 32'hac70000f, 32'h3f800000);
        //a = 38d00000; // 9.91821289062e-05 (2^-14, 1.101)
        //b = ac70000f; // -57344.0117188 (2^15, 1.110...0011)
        //c = 3f800000; // +1
        print("#2. - 1.101");
        RoundingTest(32'hb8d00000, 32'hac70000f, 32'hbf800000);
        //a = b8d00000; // -9.91821289062e-05 (2^-14, 1.101)
        //b = ac70000f; // -57344.0117188 (2^15, 1.110...0011)
        //c = bf800000; // -1

        print("#1. + 1.110");
        RoundingTest(32'h47c00000, 32'h45800000, 32'h4da00005);
        //a = 47c00000; // 98304.0 (2^16, 1.1)
        //c = 45800000; // 4096 (2^12, 1.0)
        //b = 4da00005; // 335544480.0 (2^28, 1.010...0101)
        print("#2. - 1.110");
        RoundingTest(32'hc7c00000, 32'hc5800000, 32'h4da00005);
        //a = c7c00000; // -98304.0 (2^16, 1.1)
        //c = c5800000; // -4096 (2^12, 1.0)
        //b = 4da00005; // 335544480.0 (2^28, 1.010...0101)

        print("#5. + 1.111");
        RoundingTest(32'h3ad00000, 32'h2c70000f, 32'h5a000000);
        //a = 3ad00000; // 0.0015869140625 (2^-10, 1.101)
        //b = 2c70000f; // 57344.0117188 (2^-39, 1.110...0011)
        //c = 5a000000; //9.00719925474e+15; // (2^53)
        print("#6. - 1.111");
        RoundingTest(32'hbad00000, 32'h2c70000f, 32'hda000000);
        //a = bad00000; // -0.0015869140625 (2^-10, 1.101)
        //b = 2c70000f; // 57344.0117188 (2^-39, 1.110...0011)
        //c = da000000; // -9.00719925474e+15; // (2^53)


        testlabel("d.1) 0.100");
        print("#1. + 0.100");
        RoundingTest(32'h00000000, 32'h45800003, 32'h43400000);
        //a = 00000000; // 0
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = 43400000; // 192.0 (2^7 1.1)
        print("#2. - 0.100");
        RoundingTest(32'h00000000, 32'h45800003, 32'hc3400000);
        //a = 00000000; // 0
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = c3400000; // -192.0 (2^7 1.1)

        print("#3. + 0.100");
        RoundingTest(32'h5e400000, 32'h69f8000f, 32'h3f800000);
        //a = 5e400000; //1.15292150461e+18 (2^61, 1.1)
        //b = 69f8000f; // 3.74767349957e+25 (2^84, 1.111100..001111)
        //c = 3f800000; // +1
        print("#4. - 0.100");
        RoundingTest(32'hde400000, 32'he9f8000f, 32'h3f800000);
        //a = de400000; //-1.15292150461e+18 (2^61, 1.1)
        //b = e9f8000f; // -3.74767349957e+25 (2^84, 1.111100..001111)
        //c = 3f800000; // +1


        testlabel("d.2) 1.100");
        print("#1. + 1.100");
        RoundingTest(32'h3d800000, 32'h45800003, 32'h43400000);
        //a = 3d800000; // 0.625(2^-4)
        //b = 45800003; // 4096.00146484 (2^12, 1.0...0011)
        //c = 43400000; // 192.0 (2^7 1.1)
        print("#2. - 1.100");
        RoundingTest(32'hbd800000, 32'hc5800003, 32'h43400000);
        //a = bd800000; // -0.625(2^-4)
        //b = c5800003; // -4096.00146484 (2^12, 1.0...0011)
        //c = 43400000; // 192.0 (2^7 1.1)
        
        print("#3. + 1.100");
        RoundingTest(32'h5d800000, 32'h69f8000f, 32'h3f800000);
        //a = 5d800000; //1.15292150461e+18 (2^60, 1.0)
        //b = 69f8000f; // 3.74767349957e+25 (2^84, 1.111100..001111)
        //c = 3f800000; // +1
        print("#4. - 1.100");
        RoundingTest(32'hdd800000, 32'h69f8000f, 32'hbf800000);
        //a = dd800000; // -1.15292150461e+18 (2^60, 1.0)
        //b = 69f8000f; // 3.74767349957e+25 (2^84, 1.111100..001111)
        //c = bf800000; // -1

        testtype("Overflows, It's too much... to much to hold (Not done yet, still errrrrorrrr)");
        testlabel("a) Overflow happens at Multiplication step");
        showrgs = 0;
        my_rm = PARM_RM_RTZ;
        a = 32'h00000000; //+0
        b = 32'h7445ecd1; //6.27249565725e+31 (Exp : 2^105)
        c = 32'h7cf526d7; //1.01832039677e+37 (Exp : 2^122)
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h7445ecd1; //6.27249565725e+31 (Exp : 2^105)
        c = 32'hfcf526d7; //-1.01832039677e+37(Exp : 2^122)
        @(posedge clk) 
        a = 32'h80000000; //-0
        b = 32'h64b57000; //2.6775449023e+22 (Exp : 2^74)
        c = 32'h6cb73000; //1.77168078865e+27(Exp : 2^90)
        @(posedge clk) 
        a = 32'h80000000; //-0
        b = 32'he4b57000; //-2.6775449023e+22 (Exp : 2^74)
        c = 32'h6cb73000; //1.77168078865e+27(Exp : 2^90) 
        
        @(posedge clk)
        printblank();
        a = 32'h00000000; //+0
        b = 32'h4d7fffff; //268435440.0(Mant full * 2^27) 
        c = 32'h71c00000; //1.90147590034e+30(1.1 x 2^100)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h4d7fffff; //268435440.0(Mant full * 2^27) 
        c = 32'hf1c00000; //-1.90147590034e+30(1.1 x 2^100)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h4dffffff; //268435440.0(Mant full * 2 ^ 28)
        c = 32'h71c00000; //1.90147590034e+30(1.1 x 2^100)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hcdffffff; //-268435440.0(Mant full * 2 ^ 28)
        c = 32'h71c00000; //1.90147590034e+30(1.1 x 2^100)

        
        @(posedge clk)
        printblank();
        a = 32'h80000000; // -0
        b = 32'h6c800001; // 1.23794018686e+27 (2^90 1.00..001)
        c = 32'h52800000; // 1.37438953472e+11 (2^38 1.0)

        @(posedge clk)
        a = 32'h80000000; // -0
        b = 32'h6c800001; // 1.23794018686e+27 (2^90 1.00..001)
        c = 32'hd2800000; // -1.37438953472e+11 (2^38 1.0)
        @(posedge clk)
        a = 32'h80000000; // -0
        b = 32'h6c800001; // 1.23794018686e+27 (2^90 1.00..001)
        c = 32'h53000000; // 1.37438953472e+11 (2^39 1.0)
        @(posedge clk)
        a = 32'h80000000; // -0
        b = 32'hec800001; // -1.23794018686e+27 (2^90 1.00..001)
        c = 32'h53000000; // 1.37438953472e+11 (2^39 1.0)
        
        @(posedge clk)
        printblank();
        a = 32'h00000000; //+0
        b = 32'hcd7fffff; //-268435440.0 (2^27 Mant full)
        c = 32'h71ffffff; //2.53530104934e+30 ( 2^100 Mant full)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h4d7fffff; //268435440.0 (2^27 Mant full)
        c = 32'h727fffff; //2.53530104934e+30 ( 2^101 Mant full)


        
        @(posedge clk)
        testlabel("b) Overflow happens at Addition step");
        print("Overflow is absorbed due to Rounding");
        a = 32'h3f800000; //1
        b = 32'h7f7fffff; //3.40282346639e+38 (+MAX)
        c = 32'h3f800000; //1
        @(posedge clk)
        a = 32'hbf800000; //-1
        b = 32'hff7fffff; //-3.40282346639e+38 (-MAX)
        c = 32'h3f800000; //1


        @(posedge clk)
        my_rm = PARM_RM_RUP;
        print("This is phony Overflow");
        a = 32'h00000000; //+0
        b = 32'h7f7fffff; //3.40282346639e+38 (+MAX)
        c = 32'h3f800000; //1
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hff7fffff; //-3.40282346639e+38 (-MAX)
        c = 32'h3f800000; //1

        @(posedge clk)
        a = 32'h7d600000; //9.30459597049e+36 (2 ^ 123 1.11)
        b = 32'h3f800000; //1
        c = 32'h7f71ffff; //8.04182886744e+37 (2 ^ 127 1.11100011..11)
        @(posedge clk)
        a = 32'hfd600000; //-9.30459597049e+36 (2 ^ 123 1.11)
        b = 32'hbf800000; //-1
        c = 32'h7f71ffff; //8.04182886744e+37 (2 ^ 127 1.11100011..11)
        

        @(posedge clk)
        print("Overflow happens due to RUP Rounding");
        a = 32'h3f800000; //1
        b = 32'h7f7fffff; //3.40282346639e+38 (+MAX)
        c = 32'h3f800000; //1
        @(posedge clk)
        my_rm=PARM_RM_RDN;
        a = 32'hbf800000; //-1
        b = 32'hff7fffff; //-3.40282346639e+38 (-MAX)
        c = 32'h3f800000; //1


        @(posedge clk)
        print("Overflow happens due to pure addition");
        my_rm = PARM_RM_RTZ;
        a = 32'h7d700000; //9.30459597049e+36 (2 ^ 123 1.111)
        b = 32'h3f800000; //1
        c = 32'h7f71ffff; //8.04182886744e+37 (2 ^ 127 1.11100011..11)
        @(posedge clk)
        a = 32'hfd700000; //-9.30459597049e+36 (2 ^ 123 1.111)
        b = 32'hbf800000; //-1
        c = 32'h7f71ffff; //8.04182886744e+37 (2 ^ 127 1.11100011..11)


        @(posedge clk)
        testlabel("Overflow happens due to Multiplication and Addition");
        print("Add to +MAX or -MAX");
        my_rm = PARM_RM_RTZ;
        a = 32'h7d8cbb78; //2.33831641014e+37
        b = 32'h6cf31480; //2.35092626143e+27(2 ^ 90)
        c = 32'h51fb1480; //1.34797590528e+11(2^ 36)
        @(posedge clk)
        a = 32'hfd8cbb78; //-2.33831641014e+37
        b = 32'h6cf31480; //2.35092626143e+27(2 ^ 90)
        c = 32'hd1fb1480; //-1.34797590528e+11(2^ 36)
        
        @(posedge clk)
        a = 32'h7e41e24c; //6.44290009349e+37(2^125)
        b = 32'h71e91657; //2.30838446407e+30(2 ^ 100)
        c = 32'h4ce3ede8; //119500608.0(2^ 26)
        @(posedge clk)
        a = 32'hfe41e24c; //-6.44290009349e+37(2^125)
        b = 32'hf1e91657; //-2.30838446407e+30(2 ^ 100)
        c = 32'h4ce3ede8; //119500608.0(2^ 26)

        @(posedge clk)
        a = 32'h7f3ffffe; //8.50705613066e+37 (2 ^ 127)
        b = 32'h4a800001; //4194304.5(2 ^ 22 1.0000...001)
        c = 32'h73800001; //2.02824120215e+31 ( 2^ 104 1.00...01)
        @(posedge clk)
        a = 32'hff3ffffe; //-8.50705613066e+37 (2 ^ 127)
        b = 32'h4a800001; //4194304.5(2 ^ 22 1.0000...001)
        c = 32'hf3800001; //-2.02824120215e+31 ( 2^ 104 1.00...01)        
        
        @(posedge clk)
        print("just overflow");
        a = 32'h7d8cbb7c; //2.33831742427e+37
        b = 32'h6cf31480; //2.35092626143e+27(2 ^ 90)
        c = 32'h51fb1480; //1.34797590528e+11(2^ 36)
        @(posedge clk)
        a = 32'hfd8cbb7c; //-2.33831742427e+37
        b = 32'hecf31480; //-2.35092626143e+27(2 ^ 90)
        c = 32'h51fb1480; //1.34797590528e+11(2^ 36)
        
        @(posedge clk)
        a = 32'h7e61e24c; //7.50628249012e+37(2^125)
        b = 32'h71e91657; //2.30838446407e+30(2 ^ 100)
        c = 32'h4ce3ede8; //119500608.0(2^ 26)
        @(posedge clk)
        a = 32'hfe61e24c; //-7.50628249012e+37(2^125)
        b = 32'hf1e91657; //-2.30838446407e+30(2 ^ 100)
        c = 32'h4ce3ede8; //119500608.0(2^ 26)

        @(posedge clk)
        a = 32'h7f3fffff; //2.55211754908e+38 (2 ^ 127)
        b = 32'h4a800001; //4194304.5(2 ^ 22 1.0000...001)
        c = 32'h73800001; //2.02824120215e+31 ( 2^ 104 1.00...01)
        @(posedge clk)
        a = 32'hff3fffff; //-2.55211754908e+38 (2 ^ 127)
        b = 32'h4a800001; //4194304.5(2 ^ 22 1.0000...001)
        c = 32'hf3800001; //-2.02824120215e+31 ( 2^ 104 1.00...01)   



        @(posedge clk)
        testtype("Denormalized Numbers, also under control");
        testlabel("a) Pure Addition of dernormalized numbers");
        a = 32'h00290003; // DN (0.010100100..00011)
        b = 32'h00560002; // DN (0.101011000..00010)
        c = 32'h3f800000; //+1
        @(posedge clk)
        a = 32'h80290003; // DN (-0.010100100..00011)
        b = 32'h3f800000; //+1
        c = 32'h80560002; // DN (-0.101011000..00010)

        @(posedge clk)
        a = 32'h0008e000; // DN (0.0001000111)
        b = 32'h00058000; // DN (0.0000101100)
        c = 32'hbf800000; //-1
        @(posedge clk)
        a = 32'h8008e000; // DN (-0.0001000111)
        b = 32'hbf800000; //-1
        c = 32'h80058000; // DN (-0.0000101100)

        @(posedge clk)
        a = 32'h00150002; //DN ( 0.001010100..010)
        b = 32'h006a0002; //DN ( 0.1101010....010)
        c = 32'h3f800000; //+1
        @(posedge clk)
        a = 32'h80150002; //DN (-0.001010100..010)
        b = 32'h806a0002; //DN (-0.1101010....010)
        c = 32'h3f800000; //+1
        
        @(posedge clk)
        print("This would become normalized number");
        a = 32'h007fffff; //DN ( 0.111...111)
        b = 32'h00000001; //DN ( 0.000...001)
        c = 32'h3f800000; //+1
        @(posedge clk)
        a = 32'h807fffff; //DN (-0.111...111)
        b = 32'h00000001; //DN ( 0.000...001)
        c = 32'hbf800000; //-1

        @(posedge clk)
        a = 32'h007fffff; //DN ( 0.111...111)
        b = 32'h00000002; //DN ( 0.000...010)
        c = 32'h3f800000; //+1
        @(posedge clk)
        a = 32'h807fffff; //DN (-0.111...111)
        b = 32'h80000002; //DN (-0.000...010)
        c = 32'h3f800000; //+1

        @(posedge clk)
        a = 32'h007fffff; //DN ( 0.111...111)
        b = 32'h807fffff; //DN (-0.111...111)
        c = 32'hbf800000; //-1
        @(posedge clk)
        a = 32'h807fffff; //DN (-0.111...111)
        b = 32'h007fffff; //DN ( 0.111...111)
        c = 32'hbf800000; //-1

        @(posedge clk)
        print("This is exactly zero ...");
        a = 32'h80150002; //DN (-0.001010100..001)
        b = 32'h80150002; //DN (-0.001010100..001)
        c = 32'hbf800000; //-1

        @(posedge clk)
        testlabel("b) Additions between Denormalized and Normalized Numbers");
        a = 32'h00b40000; //(2 ^ -126 1.01101)
        b = 32'h00480000; // DN(0.1001)
        c = 32'h3f800000; //+1
        @(posedge clk)
        a = 32'h80b40000; //(-2 ^ -126 1.01101)
        b = 32'h80480000; // DN(-0.1001)
        c = 32'h3f800000; //+1

        @(posedge clk)
        a = 32'h00b40000; //(2 ^ -126 1.01101)
        b = 32'h00380000; //DN (0.0111)
        c = 32'hbf800000; //-1
        @(posedge clk)
        a = 32'h80b40000; //(-2 ^ -126 1.01101)
        b = 32'h80380000; //DN (-0.0111)
        c = 32'hbf800000; //-1

        @(posedge clk)
        a = 32'h00800000; //1.17549435082e-38(MIN)(2 ^ -126 1.0)
        b = 32'h00000001; //DN ( 0.00..01)
        c = 32'hbf800000; //-1
        @(posedge clk)
        a = 32'h80800000; //-1.17549435082e-38(MIN)(2 ^ -126 1.0)
        b = 32'h80000001; //DN (-0.00..01)
        c = 32'hbf800000; //-1

        @(posedge clk)
        testlabel("c) Denormalized Numbers happens in Multiplication");
        print("Normal x Normal = denormal");
        a = 32'h00000000; //+0
        b = 32'h0dffe000; // 1.57695143846e-30 ( 2^-100 1.1111111111)
        c = 32'h31ffe000; // 7.44694261812e-09 ( 2^-28  1.1111111111)
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h8dffe000; // -1.57695143846e-30 ( -2^-100 1.1111111111)
        c = 32'h31ffe000; // 7.44694261812e-09 ( 2^-28  1.1111111111)
        
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h8dfff000; //(2^ -100 1.11111111111)
        c = 32'hb1fff000; //(2 ^ -28 1.11111111111)
        @(posedge clk)
        a = 32'h00000000; //0
        b = 32'h0dfff000; //(2^ -100 1.11111111111)
        c = 32'hb1fff000; //(2 ^ -28 1.11111111111)

        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h00998003; //1.40967528641e-38 (2^-126 1.0011001100..0011)
        c = 32'h3a800000; //0.0009765625 (2^-10 1.0)
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h00998003; //1.40967528641e-38 (2^-126 1.0011001100..0011)
        c = 32'hba800000; //-0.0009765625 (-2^-10 1.0)

        @(posedge clk)
        print("Normal x Denormal = denormal");
        a = 32'h00000000; //0
        b = 32'h01d00000; //7.64071328034e-38 (2^ -124, 1.101)
        c = 32'h3d100000; //0.03515625 (2^-5 1.001)
        @(posedge clk)
        a = 32'h00000000; //0
        b = 32'h81d00000; //-7.64071328034e-38 (2^ -124, 1.101)
        c = 32'h3d100000; //0.03515625 (2^-5 1.001)
        @(posedge clk)
        a = 32'h00000000; //0
        b = 32'h01d00000; //7.64071328034e-38 (2^ -124, 1.101)
        c = 32'hbd100000; //-0.03515625 (2^-5 1.001)
        @(posedge clk)
        a = 32'h00000000; //0
        b = 32'h81d00000; //-7.64071328034e-38 (2^ -124, 1.101)
        c = 32'hbd100000; //-0.03515625 (2^-5 1.001)

        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h01d00000; //7.64071328034e-38 (2^ -124, 1.101)
        c = 32'h3d100000; //0.03515625 (2^-5 1.001)
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h81d00000; //-7.64071328034e-38 (2^ -124, 1.101)
        c = 32'h3d100000; //0.03515625 (2^-5 1.001)
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h01d00000; //7.64071328034e-38 (2^ -124, 1.101)
        c = 32'hbd100000; //-0.03515625 (2^-5 1.001)
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h81d00000; //-7.64071328034e-38 (2^ -124, 1.101)
        c = 32'hbd100000; //-0.03515625 (2^-5 1.001)

        @(posedge clk)
        printblank();
        a = 32'h00000000; // 0;
        b = 32'h3f7fe000; // 0.99951171875 (2^-1 1.1111_1111_11)
        c = 32'h007ff800; // 1.1752073649e-38 DN(0.1111_1111_1111)
        @(posedge clk)
        a = 32'h00000000; // 0;
        b = 32'hbf7fe000; // -0.99951171875 (2^-1 1.1111_1111_11)
        c = 32'h007ff800; // 1.1752073649e-38 DN(0.1111_1111_1111)
        @(posedge clk)
        a = 32'h00000000; // 0;
        b = 32'h3f7fe000; // 0.99951171875 (2^-1 1.1111_1111_11)
        c = 32'h807ff800; // -1.1752073649e-38 DN(0.1111_1111_1111)
        @(posedge clk)
        a = 32'h00000000; // 0;
        b = 32'hbf7fe000; // -0.99951171875 (2^-1 1.1111_1111_11)
        c = 32'h807ff800; // -1.1752073649e-38 DN(0.1111_1111_1111)
        @(posedge clk)
        a = 32'h80000000; // -0;
        b = 32'h3f7fe000; // 0.99951171875 (2^-1 1.1111_1111_11)
        c = 32'h007ff800; // 1.1752073649e-38 DN(0.1111_1111_1111)
        @(posedge clk)
        a = 32'h80000000; // -0;
        b = 32'hbf7fe000; // -0.99951171875 (2^-1 1.1111_1111_11)
        c = 32'h007ff800; // 1.1752073649e-38 DN(0.1111_1111_1111)
        @(posedge clk)
        a = 32'h80000000; // -0;
        b = 32'h3f7fe000; // 0.99951171875 (2^-1 1.1111_1111_11)
        c = 32'h807ff800; // -1.1752073649e-38 DN(0.1111_1111_1111)
        @(posedge clk)
        a = 32'h80000000; // -0;
        b = 32'hbf7fe000; // -0.99951171875 (2^-1 1.1111_1111_11)
        c = 32'h807ff800; // -1.1752073649e-38 DN(0.1111_1111_1111)

        @(posedge clk)
        testlabel("d) Denormalize happens Everywhere ><");
        a = 32'h83489000; //-5.89400214342e-37 (-2^-121 1.10010001001);
        b = 32'h08d72000; // 1.29473649777e-33 ( 2^-110 1.1010111001)
        c = 32'h39eee000; // 0.000455617904663 ( 2^-12  1.1101110111)
        @(posedge clk)
        a = 32'h03489000; // 5.89400214342e-37 (-2^-121 1.10010001001);
        b = 32'h88d72000; //-1.29473649777e-33 ( 2^-110 1.1010111001)
        c = 32'h39eee000; // 0.000455617904663 ( 2^-12  1.1101110111)

        @(posedge clk)
        a = 32'h804f4a43; // -7.28164428159e-39 (DN)
        b = 32'h0da57f81; // 1.01996055552e-30 (2^-100)
        c = 32'h31f54c95; // 7.13914483086e-09 (2^-28)
        @(posedge clk)
        a = 32'h004f4a43; // 7.28164428159e-39 (DN)
        b = 32'h0da57f81; // 1.01996055552e-30 (2^-100)
        c = 32'hb1f54c95; // -7.13914483086e-09 (2^-28)

        @(posedge clk)
        testtype("Underflow, Too Little, too late");
        a = 32'h804f4a44; // -7.28164568289e-39(DN)
        b = 32'h0da57f81; // 1.01996055552e-30 (2^-100)
        c = 32'h31f54c95; // 7.13914483086e-09 (2^-28)
        @(posedge clk)
        a = 32'h004f4a44; // -7.28164568289e-39(DN)
        b = 32'h0da57f81; // 1.01996055552e-30 (2^-100)
        c = 32'hb1f54c95; // 7.13914483086e-09 (2^-28)

        @(posedge clk)
        a = 32'h800ade92; // -9.9819814548e-40(DN)
        b = 32'h12e5739d; // 1.44804326579e-27 (w^-90)
        c = 32'h2b420863; // 7.05887071017e-10 (2^-41)
        @(posedge clk)
        a = 32'h000ade92; // 9.9819814548e-40(DN)
        b = 32'h12e5739d; // 1.44804326579e-27 (w^-90)
        c = 32'hab420863; // -7.05887071017e-10 (2^-41)

        @(posedge clk)
        print("These testcases should not trigger underflow");
        a = 32'hc67ea4ff; // -16297.2490234
        b = 32'h438ade92; // 277.738830566(2^8)
        c = 32'h426ab69b; // 58.678325653076171875
        @(posedge clk)
        a = 32'h467ea4ff; // -16297.2490234
        b = 32'hc38ade92; // 277.738830566(2^8)
        c = 32'h426ab69b; // 58.678325653076171875

        @(posedge clk)
        a = 32'ha7399e80; //-2.57598304666e-15 ( 2^-49)
        b = 32'h3b6d0000; //0.00361633300781    ( 2^-9 1.1101101)
        c = 32'h2b488000; //7.123190926e-13     (2^-41 1.10010001)
        @(posedge clk)
        a = 32'h27399e80; //2.57598304666e-15 ( 2^-49)
        b = 32'h3b6d0000; //0.00361633300781    ( 2^-9 1.1101101)
        c = 32'hab488000; //-7.123190926e-13     (2^-41 1.10010001)

        @(posedge clk)
        a = 32'ha7399e00; //-2.57595594161e-15 ( 2^-49)
        b = 32'hbb6d0000; //-0.00361633300781    ( 2^-9 1.1101101)
        c = 32'hab488000; //-7.123190926e-13     (2^-41 1.10010001)
        @(posedge clk)
        a = 32'h27399e00; //2.57595594161e-15 ( 2^-49)
        b = 32'hbb6d0000; //-0.00361633300781    ( 2^-9 1.1101101)
        c = 32'h2b488000; //7.123190926e-13     (2^-41 1.10010001)

        @(posedge clk)
        EndTest();

    end


endmodule