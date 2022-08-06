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

    reg clk;
    reg [25-1 : 0] label;
    reg [32-1 : 0] a;
    reg [32-1 : 0] b;
    reg [32-1 : 0] c;

    wire [31:0] my_result;
    wire my_OF, my_UF, my_NX, my_NV;

    reg [1 : 0] ob_rm;
    reg [2 : 0] my_rm;
    wire [31:0] ob_result;
    wire ob_OF, ob_UF, ob_NX, ob_IV;


    shortreal sa, sb, sc, sans;
    wire [31 : 0] sans_wire;
    
    always @(*) sans = sa + (sb * sc);
    assign sans_wire = $shortrealtobits(sans);
    

    // always @(*)begin
    //     if(label <= 13)begin
            
    //         a = $shortrealtobits(sa);
    //         b = $shortrealtobits(sb);
    //         c = $shortrealtobits(sc);
    //     end
    // end
    
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
    .NV_o(my_NV)
    );

    // fmac uut_ob
    // (
    // //Inputs
    // .Operand_a_DI(a),
    // .Operand_b_DI(b),
    // .Operand_c_DI(c),
    // .RM_SI(ob_rm),    //Rounding Mode

    // .Result_DO(ob_result),

    // .Exp_OF_SO(ob_OF),
    // .Exp_UF_SO(ob_UF),
    // .Flag_NX_SO(ob_NX),
    // .Flag_IV_SO(ob_IV)
    // );

    task showresult;
        begin
            $write("%03d %8h(%13e) + %8h(%13e) x %8h(%13e) = %8h(%13e)\t",label,a,$bitstoshortreal(a),b,$bitstoshortreal(b),c,$bitstoshortreal(c),my_result,$bitstoshortreal(my_result));
            if(my_NV) $write("NV (Invalid)");
            if(my_OF) $write("OF (Overflw)");
            if(my_UF) $write("UF (Underfw)");
            if(my_NX) $write("NX (Inexact)");
            $display(";");
        end
        
    endtask 

    task automatic testtype(input string tt);
        begin
            $display("=============================================================================================================================================");
            $display("******* %s",tt);
            $display("=============================================================================================================================================");
        end

    endtask //automatic

    task automatic testlabel(input string lb);
        $display("");
        $display("%s",lb);
    endtask //automatic

    always @(posedge clk) begin
        # 1;
        showresult();
    end

    initial begin

        @(posedge clk)
        label = 1;
        ob_rm = 2'b00;
        my_rm = 3'b000;
        $display("RISC-V Multiply-accumulate Testbench");
        testtype("Invalid Operation Test");
        $display("a) computational operation on a NaN");
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
        b = 32'h7f800000; //+Inf
        c = 32'h7fc00000; //NaN
        @(posedge clk)
        a = 32'hff800000; //-Inf
        b = 32'h7f800000; //+Inf
        c = 32'h7fc00000; //NaN
        
        @(posedge clk)
        testlabel("b,c) multiplication 0 x Inf / Inf x 0, or fusedMultiplyAdd(0, Inf, c), if c is Nan, invalid exception(defined as NV)");
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

        //Infinites
        @(posedge clk) //result seems incorrect....
        $display("");
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
        testlabel("a)Zero + Zero x Zero");
        a = 32'h00000000; //+0.0
        b = 32'h00000000; //+0.0
        c = 32'h00000000; //+0.0
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'h80000000; //-0
        c = 32'h00000000; //+0
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h80000000; //-0
        c = 32'h80000000; //-0
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'h00000000; //+0
        c = 32'h80000000; //-0
        
        @(posedge clk)
        testlabel("b) Zero + Something");
        a = 32'h00000000; //+0
        b = 32'hc288ae14; //-68.339996337890625
        c = 32'h421a851f; //38.630001068115234375
        @(posedge clk)
        a = 32'h80000000; //-0
        b = 32'hc288ae14; //-68.339996337890625
        c = 32'h421a851f; //38.630001068115234375
        @(posedge clk) //incorrect(Flag incorrect)
        a = 32'h00000000; //+0
        b = 32'hfe580000; //-7.17783117724e+37
        c = 32'h86d80000; //-8.12501695288e-35
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hfe580000; //-7.17783117724e+37
        c = 32'h06d80000; //+8.12501695288e-35
        @(posedge clk)
        a = 32'h00000000; //+0
        b = 32'hfe580000; //-7.17783117724e+37
        c = 32'h06d80000; //+8.12501695288e-35


        @(posedge clk)
        testlabel("c) Something + Zero");
        a = 32'hc288ae14; //-68.339996337890625
        b = 32'h00000000; //+0
        c = 32'h421a851f; //38.630001068115234375
        @(posedge clk)
        a = 32'hc288ae14; //-68.339996337890625
        b = 32'h80000000; //-0
        c = 32'h421a851f; //38.630001068115234375
        
        @(posedge clk) // This leads to incorrect result...
        a = 32'h004889a0; //6.66152627087e-39 (denormalized)
        b = 32'h7cdab59f; //9.08483542861e+36
        c = 32'h00000000; //-0



        
        @(posedge clk)
        $display("");
        a = 32'h0000_0000; //0
        b = 32'h05b00000;  //1.65509604596E-35
        c = 32'h81b00000; //-6.46521892952e-38
        @(posedge clk)
        a = 32'h6fc191e0; //1.19813917899e+29
        b = 32'h7c5094ec;  //4.33207296417e+36
        c = 32'h7ede1465; // 1.47597254762e+38

        @(posedge clk)
        a = 32'h00538000;  //7.66826392919e-39
        b = 32'h3f800000; //1
        c = 32'h80178000; //-2.15813415971e-39
        
        @(posedge clk) //Start Testing Rounding mode... 1011
        my_rm = 0;
        ob_rm = 0;
        a = 32'h37b00000;  //2.09808349609e-05
        b = 32'h3f800000; //1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 1;
        ob_rm = 1;
        a = 32'h37b00000;  //2.09808349609e-05
        b = 32'h3f800000; //1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 2;
        ob_rm = 2;
        a = 32'h37b00000;  //2.09808349609e-05
        b = 32'h3f800000; //1
        c = 32'h43ffffff; //511.999969482
        
        @(posedge clk) 
        my_rm = 3;
        ob_rm = 3;
        a = 32'h37b00000;  //2.09808349609e-05
        b = 32'h3f800000; //1
        c = 32'h43ffffff; //511.999969482

        
        @(posedge clk) //Start Testing Rounding mode (negative)1011
        my_rm = 0;
        ob_rm = 0;
        a = 32'hb7b00000;  //-2.09808349609e-05
        b = 32'hbf800000; //-1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 1;
        ob_rm = 1;
        a = 32'hb7b00000;  //-2.09808349609e-05
        b = 32'hbf800000;  //-1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 2;
        ob_rm = 2;
        a = 32'hb7b00000;  //-2.09808349609e-05
        b = 32'hbf800000; //-1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 3;
        ob_rm = 3;
        a = 32'hb7b00000;  //-2.09808349609e-05
        b = 32'hbf800000; //-1
        c = 32'h43ffffff; //511.999969482

        @(posedge clk) //Start Testing Rounding mode... 1_1000
        my_rm = 0;
        ob_rm = 0;
        a = 32'h37800000;  //1.52587890625e-05
        b = 32'h3f800000; //1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 1;
        ob_rm = 1;
        a = 32'h37800000;  //1.52587890625e-05
        b = 32'h3f800000; //1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 2;
        ob_rm = 2;
        a = 32'h37800000;  //1.52587890625e-05
        b = 32'h3f800000; //1
        c = 32'h43ffffff; //511.999969482
        
        @(posedge clk) 
        my_rm = 3;
        ob_rm = 3;
        a = 32'h37800000;  //1.52587890625e-05
        b = 32'h3f800000; //1
        c = 32'h43ffffff; //511.999969482

        @(posedge clk) //Start Testing Rounding mode... (negative)1_1000
        my_rm = 0;
        ob_rm = 0;
        a = 32'hb7800000;  //1.52587890625e-05
        b = 32'hbf800000; //1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 1;
        ob_rm = 1;
        a = 32'hb7800000;  //1.52587890625e-05
        b = 32'hbf800000; //1
        c = 32'h43ffffff; //511.999969482
        @(posedge clk) 
        my_rm = 2;
        ob_rm = 2;
        a = 32'hb7800000;  //1.52587890625e-05
        b = 32'hbf800000; //1
        c = 32'h43ffffff; //511.999969482
        
        @(posedge clk) 
        my_rm = 3;
        ob_rm = 3;
        a = 32'hb7800000;  //1.52587890625e-05
        b = 32'hbf800000; //1
        c = 32'h43ffffff; //511.999969482

        @(posedge clk) //Start Testing Rounding mode...0_1000
        my_rm = 0;
        ob_rm = 0;
        a = 32'h37800000;  //1.52587890625e-05
        b = 32'h3f800000; //1
        c = 32'h43fffff0; //511.999969482
        @(posedge clk) 
        my_rm = 1;
        ob_rm = 1;
        a = 32'h37800000;  //1.52587890625e-05
        b = 32'h3f800000; //1
        c = 32'h43fffff0; //511.999969482
        @(posedge clk) 
        my_rm = 2;
        ob_rm = 2;
        a = 32'h37800000;  //1.52587890625e-05
        b = 32'h3f800000; //1
        c = 32'h43fffff0; //511.999969482
        
        @(posedge clk) 
        my_rm = 3;
        ob_rm = 3;
        a = 32'h37800000;  //1.52587890625e-05
        b = 32'h3f800000; //1
        c = 32'h43fffff0; //511.999969482

        @(posedge clk) //Start Testing Rounding mode... (negative)0_1000
        my_rm = 0;
        ob_rm = 0;
        a = 32'hb7800000;  //1.52587890625e-05
        b = 32'hbf800000; //1
        c = 32'h43fffff0; //511.999969482
        @(posedge clk) 
        my_rm = 1;
        ob_rm = 1;
        a = 32'hb7800000;  //1.52587890625e-05
        b = 32'hbf800000; //1
        c = 32'h43fffff0; //511.999969482
        @(posedge clk) 
        my_rm = 2;
        ob_rm = 2;
        a = 32'hb7800000;  //1.52587890625e-05
        b = 32'hbf800000; //1
        c = 32'h43fffff0; //511.999969482
        
        @(posedge clk) 
        my_rm = 3;
        ob_rm = 3;
        a = 32'hb7800000;  //1.52587890625e-05
        b = 32'hbf800000; //1
        c = 32'h43fffff0; //511.999969482


        @(posedge clk) //test for overflow
        //ans = a + b*c
        @(posedge clk)
        $finish;

    end


endmodule
        
        // @(posedge clk)
        // sa = 1.0;
        // sb = 1.0;
        // sc = 1.0;
        
        // @(posedge clk)
        // sa = -13.25;
        // sb = -6.75;
        // sc = 4.5;
        // @(posedge clk)
        // sa = 13.3064317703; // 0x4154e725
        // sb = -9.30493545532;  //0xc114e104
        // sc = 74.439453125;  //0x5294e100

        // @(posedge clk)
        // sa = 22.7350006103515625; // 0x41b5e148
        // sb = 0.00150000001303851604461669921875;  //0x3ac49ba6
        // sc = 0.0000700000018696300685405731201171875;  //0x3892ccf7

        // @(posedge clk)
        // sa = 1290.0980224609375; // 0x44a14323
        // sb = 11456.025390625;  //0x4633001a
        // sc = 0.334500014781951904296875;  //0x3eab4396

        // @(posedge clk)
        // sa = -37.299999237060546875; // 0x42153333
        // sb = -0.0052000000141561031341552734375;  //0xbbaa64c3
        // sc = -0.10999999940395355224609375;  //0x3de147ae

        // @(posedge clk)
        // sa = -37.299999237060546875; // 0x42153333
        // sb = -0.0052000000141561031341552734375;  //0xbbaa64c3
        // sc = -0.10999999940395355224609375;  //0x3de147ae
        // @(posedge clk)
        // sa = -10000.23046875; // 461c40ec
        // sb = -12345.8701171875;  //0xc640e77b
        // sc = 99.94000244140625;  //0x42c7e148
        // @(posedge clk)
        // sa = -123456792; // 0xcceb79a3
        // sb = -9999.337890625;  //0x461c3d5a
        // sc = 0.2249999940395355224609375; //0x3e666666
        // @(posedge clk)
        // sa = 99999.34375; // 0x47c34fac
        // sb = 0.0045599997974932193756103515625;  //0x3b956c0d
        // sc = -983847.3125; //c9703275
        // @(posedge clk)
        // sa = 0.00002339999991818331182003021240234375; //0xb7c44b1e
        // sb = 1167.800048828125;  //0x4491f99a
        // sc = -993.8975830078125; //0xc4787972
        // @(posedge clk)
        // sa = -5.1E-7; //0xb508e6ef
        // sb = -3.6999999418474427415048921830020844936370849609375E-12;  //ac822ea3
        // sc = -34568976; //0xcc03dec4
        // @(posedge clk)//label = 13
        // sa = -5.1E-7; //0xb508e6ef
        // sb = -3.6999999418474427415048921830020844936370849609375E-12;  //ac822ea3
        // sc = -34568976; //0xcc03dec4