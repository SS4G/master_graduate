`timescale 1ns/1ns
module addTree_tb;
reg rst_n;
reg clk;
reg [15:0] test_data_A [24:0];
reg [15:0] test_data_B [24:0];
integer i, j, k;
integer start;
reg[15:0] tmp;
wire [15:0] out;
integer cnt;

MulVec_25p DUT(
    .rst_n(rst_n),
	.clk(clk),
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
		test_data[i] = i;
		tmp = tmp + test_data[i];
	end 
        
    #100;
        
        
	if (tmp != out)
		$display("wrong answer");
	else
		$display("right answer");
    
    tmp = 0;
    for(i = 0; i < 26; i=i+1) 
	begin
		test_data[i] = -i;
		tmp = tmp + test_data[i];
	end 
    
    tmp = 0;
    for(i = 0; i < 26; i=i+1) 
	begin
        if(i < 13) 
            test_data[i] = -i;
        else
            test_data[i] = i;
		tmp = tmp + test_data[i];
	end 
end
endmodule 