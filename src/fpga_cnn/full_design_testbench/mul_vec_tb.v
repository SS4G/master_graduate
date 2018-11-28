`timescale 1ns/1ns
module MulVec_tb;
reg rst_n;
reg clk;
integer i, j, k;
integer start;
reg[15:0] tmp;
wire [15:0] out;
integer cnt;

reg [15:0] test_inA [24:0];
reg [15:0] test_inB [24:0];
wire [15:0] test_outP [24:0];
reg [15:0] std_outP [24:0];
wire [25*16-1:0] inA_25P;
wire [25*16-1:0] inB_25P;
wire [25*16-1:0] outP_25P;


MulVec_25p DUT(
    .rst_n(rst_n),
	.clk(clk),
    .inA_25P(inA_25P),
	.inB_25P(inB_25P),
	.outP_25P(outP_25P)
); 

debus_1to26 DUT1_26(
    .com_bus_in(outP_25P),
    .sep_bus_out00(test_outP[00]),
    .sep_bus_out01(test_outP[01]),
    .sep_bus_out02(test_outP[02]),
    .sep_bus_out03(test_outP[03]),
    .sep_bus_out04(test_outP[04]),
    .sep_bus_out05(test_outP[05]),
    .sep_bus_out06(test_outP[06]),
    .sep_bus_out07(test_outP[07]),
    .sep_bus_out08(test_outP[08]),
    .sep_bus_out09(test_outP[09]),
    .sep_bus_out10(test_outP[10]),
    .sep_bus_out11(test_outP[11]),
    .sep_bus_out12(test_outP[12]),
    .sep_bus_out13(test_outP[13]),
    .sep_bus_out14(test_outP[14]),
    .sep_bus_out15(test_outP[15]),
    .sep_bus_out16(test_outP[16]),
    .sep_bus_out17(test_outP[17]),
    .sep_bus_out18(test_outP[18]),
    .sep_bus_out19(test_outP[19]),
    .sep_bus_out20(test_outP[20]),
    .sep_bus_out21(test_outP[21]),
    .sep_bus_out22(test_outP[22]),
    .sep_bus_out23(test_outP[23]),
    .sep_bus_out24(test_outP[24]),
    .sep_bus_out25()
);

bus_26to1 inA26_1(
    .com_bus_out(inA_25P),
    .sep_bus_in00(test_inA[00]),
    .sep_bus_in01(test_inA[01]),
    .sep_bus_in02(test_inA[02]),
    .sep_bus_in03(test_inA[03]),
    .sep_bus_in04(test_inA[04]),
    .sep_bus_in05(test_inA[05]),
    .sep_bus_in06(test_inA[06]),
    .sep_bus_in07(test_inA[07]),
    .sep_bus_in08(test_inA[08]),
    .sep_bus_in09(test_inA[09]),
    .sep_bus_in10(test_inA[10]),
    .sep_bus_in11(test_inA[11]),
    .sep_bus_in12(test_inA[12]),
    .sep_bus_in13(test_inA[13]),
    .sep_bus_in14(test_inA[14]),
    .sep_bus_in15(test_inA[15]),
    .sep_bus_in16(test_inA[16]),
    .sep_bus_in17(test_inA[17]),
    .sep_bus_in18(test_inA[18]),
    .sep_bus_in19(test_inA[19]),
    .sep_bus_in20(test_inA[20]),
    .sep_bus_in21(test_inA[21]),
    .sep_bus_in22(test_inA[22]),
    .sep_bus_in23(test_inA[23]),
    .sep_bus_in24(test_inA[24]),
    .sep_bus_in25(0)
);

bus_26to1 inB26_1(
    .com_bus_out(inB_25P),
    .sep_bus_in00(test_inB[00]),
    .sep_bus_in01(test_inB[01]),
    .sep_bus_in02(test_inB[02]),
    .sep_bus_in03(test_inB[03]),
    .sep_bus_in04(test_inB[04]),
    .sep_bus_in05(test_inB[05]),
    .sep_bus_in06(test_inB[06]),
    .sep_bus_in07(test_inB[07]),
    .sep_bus_in08(test_inB[08]),
    .sep_bus_in09(test_inB[09]),
    .sep_bus_in10(test_inB[10]),
    .sep_bus_in11(test_inB[11]),
    .sep_bus_in12(test_inB[12]),
    .sep_bus_in13(test_inB[13]),
    .sep_bus_in14(test_inB[14]),
    .sep_bus_in15(test_inB[15]),
    .sep_bus_in16(test_inB[16]),
    .sep_bus_in17(test_inB[17]),
    .sep_bus_in18(test_inB[18]),
    .sep_bus_in19(test_inB[19]),
    .sep_bus_in20(test_inB[20]),
    .sep_bus_in21(test_inB[21]),
    .sep_bus_in22(test_inB[22]),
    .sep_bus_in23(test_inB[23]),
    .sep_bus_in24(test_inB[24]),
    .sep_bus_in25(0)
);


initial 
begin 
    clk = 0;
	rst_n = 0;
	start=0;
	cnt = 0;

	# 10;
	rst_n = 1;
	# 10
	start = 1;
end

always @(posedge clk)
begin 
	cnt = cnt+1;
end 
 
always 
begin
	#5
	if (rst_n > 0)
        clk = ~clk;
end 

initial
begin 
	#100;
	tmp = 0;
    
    for(i = 0; i < 26; i=i+1) 
	begin
		test_inA[i] = 16'h05_c0;
        test_inB[i] = 16'hf5_40;
	end 

        
    #100;
        

end
endmodule 