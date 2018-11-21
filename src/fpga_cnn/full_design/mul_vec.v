module MulVec_25p(
    rst_n,
	clk,
	inA_00,
	inB_00,
	outP_00,
	inA_01,
	inB_01,
	outP_01,
	inA_02,
	inB_02,
	outP_02,
	inA_03,
	inB_03,
	outP_03,
	inA_04,
	inB_04,
	outP_04,
	inA_05,
	inB_05,
	outP_05,
	inA_06,
	inB_06,
	outP_06,
	inA_07,
	inB_07,
	outP_07,
	inA_08,
	inB_08,
	outP_08,
	inA_09,
	inB_09,
	outP_09,
	inA_10,
	inB_10,
	outP_10,
	inA_11,
	inB_11,
	outP_11,
	inA_12,
	inB_12,
	outP_12,
	inA_13,
	inB_13,
	outP_13,
	inA_14,
	inB_14,
	outP_14,
	inA_15,
	inB_15,
	outP_15,
	inA_16,
	inB_16,
	outP_16,
	inA_17,
	inB_17,
	outP_17,
	inA_18,
	inB_18,
	outP_18,
	inA_19,
	inB_19,
	outP_19,
	inA_20,
	inB_20,
	outP_20,
	inA_21,
	inB_21,
	outP_21,
	inA_22,
	inB_22,
	outP_22,
	inA_23,
	inB_23,
	outP_23,
	inA_24,
	inB_24,
	outP_24
);  
    parameter WIDTH=16; //total fix point num width
	parameter POINT_WIDTH=8; //fix point num point part width 
	
    input clk;
	input rst_n;
	input [WIDTH-1:0] inA_00;
	input [WIDTH-1:0] inB_00;
	output [2*WIDTH-1:0] outP_00;
	input [WIDTH-1:0] inA_01;
	input [WIDTH-1:0] inB_01;
	output [2*WIDTH-1:0] outP_01;
	input [WIDTH-1:0] inA_02;
	input [WIDTH-1:0] inB_02;
	output [2*WIDTH-1:0] outP_02;
	input [WIDTH-1:0] inA_03;
	input [WIDTH-1:0] inB_03;
	output [2*WIDTH-1:0] outP_03;
	input [WIDTH-1:0] inA_04;
	input [WIDTH-1:0] inB_04;
	output [2*WIDTH-1:0] outP_04;
	input [WIDTH-1:0] inA_05;
	input [WIDTH-1:0] inB_05;
	output [2*WIDTH-1:0] outP_05;
	input [WIDTH-1:0] inA_06;
	input [WIDTH-1:0] inB_06;
	output [2*WIDTH-1:0] outP_06;
	input [WIDTH-1:0] inA_07;
	input [WIDTH-1:0] inB_07;
	output [2*WIDTH-1:0] outP_07;
	input [WIDTH-1:0] inA_08;
	input [WIDTH-1:0] inB_08;
	output [2*WIDTH-1:0] outP_08;
	input [WIDTH-1:0] inA_09;
	input [WIDTH-1:0] inB_09;
	output [2*WIDTH-1:0] outP_09;
	input [WIDTH-1:0] inA_10;
	input [WIDTH-1:0] inB_10;
	output [2*WIDTH-1:0] outP_10;
	input [WIDTH-1:0] inA_11;
	input [WIDTH-1:0] inB_11;
	output [2*WIDTH-1:0] outP_11;
	input [WIDTH-1:0] inA_12;
	input [WIDTH-1:0] inB_12;
	output [2*WIDTH-1:0] outP_12;
	input [WIDTH-1:0] inA_13;
	input [WIDTH-1:0] inB_13;
	output [2*WIDTH-1:0] outP_13;
	input [WIDTH-1:0] inA_14;
	input [WIDTH-1:0] inB_14;
	output [2*WIDTH-1:0] outP_14;
	input [WIDTH-1:0] inA_15;
	input [WIDTH-1:0] inB_15;
	output [2*WIDTH-1:0] outP_15;
	input [WIDTH-1:0] inA_16;
	input [WIDTH-1:0] inB_16;
	output [2*WIDTH-1:0] outP_16;
	input [WIDTH-1:0] inA_17;
	input [WIDTH-1:0] inB_17;
	output [2*WIDTH-1:0] outP_17;
	input [WIDTH-1:0] inA_18;
	input [WIDTH-1:0] inB_18;
	output [2*WIDTH-1:0] outP_18;
	input [WIDTH-1:0] inA_19;
	input [WIDTH-1:0] inB_19;
	output [2*WIDTH-1:0] outP_19;
	input [WIDTH-1:0] inA_20;
	input [WIDTH-1:0] inB_20;
	output [2*WIDTH-1:0] outP_20;
	input [WIDTH-1:0] inA_21;
	input [WIDTH-1:0] inB_21;
	output [2*WIDTH-1:0] outP_21;
	input [WIDTH-1:0] inA_22;
	input [WIDTH-1:0] inB_22;
	output [2*WIDTH-1:0] outP_22;
	input [WIDTH-1:0] inA_23;
	input [WIDTH-1:0] inB_23;
	output [2*WIDTH-1:0] outP_23;
	input [WIDTH-1:0] inA_24;
	input [WIDTH-1:0] inB_24;
	output [2*WIDTH-1:0] outP_24;
    
	FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_00(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_00),
		.inB(inB_00),
		.outP(outP_00)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_01(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_01),
		.inB(inB_01),
		.outP(outP_01)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_02(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_02),
		.inB(inB_02),
		.outP(outP_02)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_03(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_03),
		.inB(inB_03),
		.outP(outP_03)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_04(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_04),
		.inB(inB_04),
		.outP(outP_04)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_05(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_05),
		.inB(inB_05),
		.outP(outP_05)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_06(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_06),
		.inB(inB_06),
		.outP(outP_06)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_07(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_07),
		.inB(inB_07),
		.outP(outP_07)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_08(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_08),
		.inB(inB_08),
		.outP(outP_08)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_09(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_09),
		.inB(inB_09),
		.outP(outP_09)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_10(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_10),
		.inB(inB_10),
		.outP(outP_10)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_11(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_11),
		.inB(inB_11),
		.outP(outP_11)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_12(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_12),
		.inB(inB_12),
		.outP(outP_12)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_13(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_13),
		.inB(inB_13),
		.outP(outP_13)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_14(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_14),
		.inB(inB_14),
		.outP(outP_14)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_15(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_15),
		.inB(inB_15),
		.outP(outP_15)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_16(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_16),
		.inB(inB_16),
		.outP(outP_16)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_17(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_17),
		.inB(inB_17),
		.outP(outP_17)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_18(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_18),
		.inB(inB_18),
		.outP(outP_18)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_19(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_19),
		.inB(inB_19),
		.outP(outP_19)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_20(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_20),
		.inB(inB_20),
		.outP(outP_20)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_21(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_21),
		.inB(inB_21),
		.outP(outP_21)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_22(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_22),
		.inB(inB_22),
		.outP(outP_22)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_23(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_23),
		.inB(inB_23),
		.outP(outP_23)
	);


	 FixMul #(.WIDTH(WIDTH), .POINT_WIDTH(POINT_WIDTH)) inst_24(
		.rst_n(rst_n),
		.clk(clk),
		.inA(inA_24),
		.inB(inB_24),
		.outP(outP_24)
	);

	
endmodule