//add tree with 26 port 32 bits
//delay 5 clock cycles
//#test_passed
module AddTree_26p(
    rst_n,
	clk,
	in_25P,//25 个同样位宽的端口
	in_bias, //一个单独的端口
	out
);   
    parameter WIDTH = 16;
    input rst_n;
	input clk;
    
	output [WIDTH-1:0] out;
    
    input [WIDTH*25-1:0] in_25P;
    input [WIDTH-1:0]    in_bias;
    
    wire [WIDTH-1:0] in_00;
	wire [WIDTH-1:0] in_01;
	wire [WIDTH-1:0] in_02;
	wire [WIDTH-1:0] in_03;
	wire [WIDTH-1:0] in_04;
	wire [WIDTH-1:0] in_05;
	wire [WIDTH-1:0] in_06;
	wire [WIDTH-1:0] in_07;
	wire [WIDTH-1:0] in_08;
	wire [WIDTH-1:0] in_09;
	wire [WIDTH-1:0] in_10;
	wire [WIDTH-1:0] in_11;
	wire [WIDTH-1:0] in_12;
	wire [WIDTH-1:0] in_13;
	wire [WIDTH-1:0] in_14;
	wire [WIDTH-1:0] in_15;
	wire [WIDTH-1:0] in_16;
	wire [WIDTH-1:0] in_17;
	wire [WIDTH-1:0] in_18;
	wire [WIDTH-1:0] in_19;
	wire [WIDTH-1:0] in_20;
	wire [WIDTH-1:0] in_21;
	wire [WIDTH-1:0] in_22;
	wire [WIDTH-1:0] in_23;
	wire [WIDTH-1:0] in_24;
	
	wire [WIDTH-1:0] tmp_out_00_00;
	wire [WIDTH-1:0] tmp_out_00_10;
	wire [WIDTH-1:0] tmp_out_00_11;
	wire [WIDTH-1:0] tmp_out_00_12;
	wire [WIDTH-1:0] tmp_out_00_13;
	wire [WIDTH-1:0] tmp_out_00_14;
	wire [WIDTH-1:0] tmp_out_00_15;
	wire [WIDTH-1:0] tmp_out_00_16;
	wire [WIDTH-1:0] tmp_out_00_17;
	wire [WIDTH-1:0] tmp_out_00_18;
	wire [WIDTH-1:0] tmp_out_00_19;
	wire [WIDTH-1:0] tmp_out_00_01;
	wire [WIDTH-1:0] tmp_out_00_20;
	wire [WIDTH-1:0] tmp_out_00_21;
	wire [WIDTH-1:0] tmp_out_00_22;
	wire [WIDTH-1:0] tmp_out_00_23;
	wire [WIDTH-1:0] tmp_out_00_24;
	wire [WIDTH-1:0] tmp_out_00_25;
	wire [WIDTH-1:0] tmp_out_00_02;
	wire [WIDTH-1:0] tmp_out_00_03;
	wire [WIDTH-1:0] tmp_out_00_04;
	wire [WIDTH-1:0] tmp_out_00_05;
	wire [WIDTH-1:0] tmp_out_00_06;
	wire [WIDTH-1:0] tmp_out_00_07;
	wire [WIDTH-1:0] tmp_out_00_08;
	wire [WIDTH-1:0] tmp_out_00_09;
	wire [WIDTH-1:0] tmp_out_01_00;
	wire [WIDTH-1:0] tmp_out_01_10;
	wire [WIDTH-1:0] tmp_out_01_11;
	wire [WIDTH-1:0] tmp_out_01_12;
	wire [WIDTH-1:0] tmp_out_01_01;
	wire [WIDTH-1:0] tmp_out_01_02;
	wire [WIDTH-1:0] tmp_out_01_03;
	wire [WIDTH-1:0] tmp_out_01_04;
	wire [WIDTH-1:0] tmp_out_01_05;
	wire [WIDTH-1:0] tmp_out_01_06;
	wire [WIDTH-1:0] tmp_out_01_07;
	wire [WIDTH-1:0] tmp_out_01_08;
	wire [WIDTH-1:0] tmp_out_01_09;
	wire [WIDTH-1:0] tmp_out_02_00;
	wire [WIDTH-1:0] tmp_out_02_01;
	wire [WIDTH-1:0] tmp_out_02_02;
	wire [WIDTH-1:0] tmp_out_02_03;
	wire [WIDTH-1:0] tmp_out_02_04;
	wire [WIDTH-1:0] tmp_out_02_05;
	wire [WIDTH-1:0] tmp_out_02_06;
	wire [WIDTH-1:0] tmp_out_03_00;
	wire [WIDTH-1:0] tmp_out_03_01;
	wire [WIDTH-1:0] tmp_out_03_02;
	wire [WIDTH-1:0] tmp_out_03_03;
	wire [WIDTH-1:0] tmp_out_04_00;
	wire [WIDTH-1:0] tmp_out_04_01;
	wire [WIDTH-1:0] tmp_out_05_00;
	
	
    debus_1to26 debus(
    .com_bus_in(in_25P),
    .sep_bus_out00(in_00),
    .sep_bus_out01(in_01),
    .sep_bus_out02(in_02),
    .sep_bus_out03(in_03),
    .sep_bus_out04(in_04),
    .sep_bus_out05(in_05),
    .sep_bus_out06(in_06),
    .sep_bus_out07(in_07),
    .sep_bus_out08(in_08),
    .sep_bus_out09(in_09),
    .sep_bus_out10(in_10),
    .sep_bus_out11(in_11),
    .sep_bus_out12(in_12),
    .sep_bus_out13(in_13),
    .sep_bus_out14(in_14),
    .sep_bus_out15(in_15),
    .sep_bus_out16(in_16),
    .sep_bus_out17(in_17),
    .sep_bus_out18(in_18),
    .sep_bus_out19(in_19),
    .sep_bus_out20(in_20),
    .sep_bus_out21(in_21),
    .sep_bus_out22(in_22),
    .sep_bus_out23(in_23),
    .sep_bus_out24(in_24),
    .sep_bus_out25()
);
    
    
	assign tmp_out_00_00 = in_00;
	assign tmp_out_00_01 = in_01;
	assign tmp_out_00_02 = in_02;
	assign tmp_out_00_03 = in_03;
	assign tmp_out_00_04 = in_04;
	assign tmp_out_00_05 = in_05;
	assign tmp_out_00_06 = in_06;
	assign tmp_out_00_07 = in_07;
	assign tmp_out_00_08 = in_08;
	assign tmp_out_00_09 = in_09;
	assign tmp_out_00_10 = in_10;
	assign tmp_out_00_11 = in_11;
	assign tmp_out_00_12 = in_12;
	assign tmp_out_00_13 = in_13;
	assign tmp_out_00_14 = in_14;
	assign tmp_out_00_15 = in_15;
	assign tmp_out_00_16 = in_16;
	assign tmp_out_00_17 = in_17;
	assign tmp_out_00_18 = in_18;
	assign tmp_out_00_19 = in_19;
	assign tmp_out_00_20 = in_20;
	assign tmp_out_00_21 = in_21;
	assign tmp_out_00_22 = in_22;
	assign tmp_out_00_23 = in_23;
	assign tmp_out_00_24 = in_24;
	assign tmp_out_00_25 = in_bias;

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_00(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_00),
    	.inB(tmp_out_00_01),
    	.outSum(tmp_out_01_00)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_01(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_02),
    	.inB(tmp_out_00_03),
    	.outSum(tmp_out_01_01)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_02(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_04),
    	.inB(tmp_out_00_05),
    	.outSum(tmp_out_01_02)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_03(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_06),
    	.inB(tmp_out_00_07),
    	.outSum(tmp_out_01_03)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_04(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_08),
    	.inB(tmp_out_00_09),
    	.outSum(tmp_out_01_04)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_05(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_10),
    	.inB(tmp_out_00_11),
    	.outSum(tmp_out_01_05)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_06(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_12),
    	.inB(tmp_out_00_13),
    	.outSum(tmp_out_01_06)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_07(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_14),
    	.inB(tmp_out_00_15),
    	.outSum(tmp_out_01_07)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_08(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_16),
    	.inB(tmp_out_00_17),
    	.outSum(tmp_out_01_08)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_09(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_18),
    	.inB(tmp_out_00_19),
    	.outSum(tmp_out_01_09)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_10(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_20),
    	.inB(tmp_out_00_21),
    	.outSum(tmp_out_01_10)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_11(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_22),
    	.inB(tmp_out_00_23),
    	.outSum(tmp_out_01_11)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_01_12(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_00_24),
    	.inB(tmp_out_00_25),
    	.outSum(tmp_out_01_12)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_02_00(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_01_00),
    	.inB(tmp_out_01_01),
    	.outSum(tmp_out_02_00)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_02_01(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_01_02),
    	.inB(tmp_out_01_03),
    	.outSum(tmp_out_02_01)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_02_02(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_01_04),
    	.inB(tmp_out_01_05),
    	.outSum(tmp_out_02_02)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_02_03(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_01_06),
    	.inB(tmp_out_01_07),
    	.outSum(tmp_out_02_03)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_02_04(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_01_08),
    	.inB(tmp_out_01_09),
    	.outSum(tmp_out_02_04)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_02_05(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_01_10),
    	.inB(tmp_out_01_11),
    	.outSum(tmp_out_02_05)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_02_06(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_01_12),
    	.inB(64'h0),
    	.outSum(tmp_out_02_06)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_03_00(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_02_00),
    	.inB(tmp_out_02_01),
    	.outSum(tmp_out_03_00)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_03_01(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_02_02),
    	.inB(tmp_out_02_03),
    	.outSum(tmp_out_03_01)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_03_02(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_02_04),
    	.inB(tmp_out_02_05),
    	.outSum(tmp_out_03_02)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_03_03(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_02_06),
    	.inB(64'h0),
    	.outSum(tmp_out_03_03)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_04_00(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_03_00),
    	.inB(tmp_out_03_01),
    	.outSum(tmp_out_04_00)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_04_01(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_03_02),
    	.inB(tmp_out_03_03),
    	.outSum(tmp_out_04_01)
    );
    

    FixAdd #(.WIDTH(WIDTH)) fix_add_inst_05_00(
        .rst_n(rst_n),
        .clk(clk),
    	.inA(tmp_out_04_00),
    	.inB(tmp_out_04_01),
    	.outSum(tmp_out_05_00)
    );
       
	assign out = tmp_out_05_00;
	
endmodule 