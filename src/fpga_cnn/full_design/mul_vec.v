//delay 1 cycles 
//#test_passed
module MulVec_25p(
    rst_n,
	clk,
	inA_25P,
	inB_25P,
	outP_25P
);  
    parameter WIDTH=16; //total fix point num width
	parameter POINT_WIDTH=8; //fix point num point part width 
	
    input [WIDTH*25-1: 0] inA_25P;
    input [WIDTH*25-1: 0] inB_25P;
    output [WIDTH*25-1: 0] outP_25P;
    
    input clk;
	input rst_n;
    
    wire [WIDTH-1:0] inA_00;
    wire [WIDTH-1:0] inA_01;
    wire [WIDTH-1:0] inA_02;
    wire [WIDTH-1:0] inA_03;
    wire [WIDTH-1:0] inA_04;
    wire [WIDTH-1:0] inA_05;
    wire [WIDTH-1:0] inA_06;
    wire [WIDTH-1:0] inA_07;
    wire [WIDTH-1:0] inA_08;
    wire [WIDTH-1:0] inA_09;
    wire [WIDTH-1:0] inA_10;
    wire [WIDTH-1:0] inA_11;
    wire [WIDTH-1:0] inA_12;
    wire [WIDTH-1:0] inA_13;
    wire [WIDTH-1:0] inA_14;
    wire [WIDTH-1:0] inA_15;
    wire [WIDTH-1:0] inA_16;
    wire [WIDTH-1:0] inA_17;
    wire [WIDTH-1:0] inA_18;
    wire [WIDTH-1:0] inA_19;
    wire [WIDTH-1:0] inA_20;
    wire [WIDTH-1:0] inA_21;
    wire [WIDTH-1:0] inA_22;
    wire [WIDTH-1:0] inA_23;
    wire [WIDTH-1:0] inA_24;
    
    wire [WIDTH-1:0] inB_00;
    wire [WIDTH-1:0] inB_01;
    wire [WIDTH-1:0] inB_02;
    wire [WIDTH-1:0] inB_03;
    wire [WIDTH-1:0] inB_04;
    wire [WIDTH-1:0] inB_05;
    wire [WIDTH-1:0] inB_06;
    wire [WIDTH-1:0] inB_07;
    wire [WIDTH-1:0] inB_08;
    wire [WIDTH-1:0] inB_09;
    wire [WIDTH-1:0] inB_10;
    wire [WIDTH-1:0] inB_11;
    wire [WIDTH-1:0] inB_12;
    wire [WIDTH-1:0] inB_13;
    wire [WIDTH-1:0] inB_14;
    wire [WIDTH-1:0] inB_15;
    wire [WIDTH-1:0] inB_16;
    wire [WIDTH-1:0] inB_17;
    wire [WIDTH-1:0] inB_18;
    wire [WIDTH-1:0] inB_19;
    wire [WIDTH-1:0] inB_20;
    wire [WIDTH-1:0] inB_21;
    wire [WIDTH-1:0] inB_22;
    wire [WIDTH-1:0] inB_23;
    wire [WIDTH-1:0] inB_24;
    
    wire [WIDTH-1:0] outP_00;
    wire [WIDTH-1:0] outP_01;
    wire [WIDTH-1:0] outP_02;
    wire [WIDTH-1:0] outP_03;
    wire [WIDTH-1:0] outP_04;
    wire [WIDTH-1:0] outP_05;
    wire [WIDTH-1:0] outP_06;
    wire [WIDTH-1:0] outP_07;
    wire [WIDTH-1:0] outP_08;
    wire [WIDTH-1:0] outP_09;
    wire [WIDTH-1:0] outP_10;
    wire [WIDTH-1:0] outP_11;
    wire [WIDTH-1:0] outP_12;
    wire [WIDTH-1:0] outP_13;
    wire [WIDTH-1:0] outP_14;
    wire [WIDTH-1:0] outP_15;
    wire [WIDTH-1:0] outP_16;
    wire [WIDTH-1:0] outP_17;
    wire [WIDTH-1:0] outP_18;
    wire [WIDTH-1:0] outP_19;
    wire [WIDTH-1:0] outP_20;
    wire [WIDTH-1:0] outP_21;
    wire [WIDTH-1:0] outP_22;
    wire [WIDTH-1:0] outP_23;
    wire [WIDTH-1:0] outP_24;
    
    bus_26to1 outP26_1_0(
        .com_bus_out(outP_25P),
        .sep_bus_in00(outP_00),
        .sep_bus_in01(outP_01),
        .sep_bus_in02(outP_02),
        .sep_bus_in03(outP_03),
        .sep_bus_in04(outP_04),
        .sep_bus_in05(outP_05),
        .sep_bus_in06(outP_06),
        .sep_bus_in07(outP_07),
        .sep_bus_in08(outP_08),
        .sep_bus_in09(outP_09),
        .sep_bus_in10(outP_10),
        .sep_bus_in11(outP_11),
        .sep_bus_in12(outP_12),
        .sep_bus_in13(outP_13),
        .sep_bus_in14(outP_14),
        .sep_bus_in15(outP_15),
        .sep_bus_in16(outP_16),
        .sep_bus_in17(outP_17),
        .sep_bus_in18(outP_18),
        .sep_bus_in19(outP_19),
        .sep_bus_in20(outP_20),
        .sep_bus_in21(outP_21),
        .sep_bus_in22(outP_22),
        .sep_bus_in23(outP_23),
        .sep_bus_in24(outP_24),
        .sep_bus_in25(0)
    );
    
    
    debus_1to26 inA1_26(
        .com_bus_in(inA_25P),
        .sep_bus_out00(inA_00),
        .sep_bus_out01(inA_01),
        .sep_bus_out02(inA_02),
        .sep_bus_out03(inA_03),
        .sep_bus_out04(inA_04),
        .sep_bus_out05(inA_05),
        .sep_bus_out06(inA_06),
        .sep_bus_out07(inA_07),
        .sep_bus_out08(inA_08),
        .sep_bus_out09(inA_09),
        .sep_bus_out10(inA_10),
        .sep_bus_out11(inA_11),
        .sep_bus_out12(inA_12),
        .sep_bus_out13(inA_13),
        .sep_bus_out14(inA_14),
        .sep_bus_out15(inA_15),
        .sep_bus_out16(inA_16),
        .sep_bus_out17(inA_17),
        .sep_bus_out18(inA_18),
        .sep_bus_out19(inA_19),
        .sep_bus_out20(inA_20),
        .sep_bus_out21(inA_21),
        .sep_bus_out22(inA_22),
        .sep_bus_out23(inA_23),
        .sep_bus_out24(inA_24),
        .sep_bus_out25()
    );

    
    debus_1to26 inB1_26(
        .com_bus_in(inB_25P),
        .sep_bus_out00(inB_00),
        .sep_bus_out01(inB_01),
        .sep_bus_out02(inB_02),
        .sep_bus_out03(inB_03),
        .sep_bus_out04(inB_04),
        .sep_bus_out05(inB_05),
        .sep_bus_out06(inB_06),
        .sep_bus_out07(inB_07),
        .sep_bus_out08(inB_08),
        .sep_bus_out09(inB_09),
        .sep_bus_out10(inB_10),
        .sep_bus_out11(inB_11),
        .sep_bus_out12(inB_12),
        .sep_bus_out13(inB_13),
        .sep_bus_out14(inB_14),
        .sep_bus_out15(inB_15),
        .sep_bus_out16(inB_16),
        .sep_bus_out17(inB_17),
        .sep_bus_out18(inB_18),
        .sep_bus_out19(inB_19),
        .sep_bus_out20(inB_20),
        .sep_bus_out21(inB_21),
        .sep_bus_out22(inB_22),
        .sep_bus_out23(inB_23),
        .sep_bus_out24(inB_24),
        .sep_bus_out25()
    );

    
    
    
    
    
    
    
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