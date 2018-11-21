`timescale 1ns/1ns
module addTree_tb;
reg rst_n;
reg clk;
reg [15:0] test_data [25:0];
integer i, j, k;
integer start;
reg[15:0] tmp;
wire [15:0] out;
integer cnt;

AddTree_26p DUT(
    .rst_n(rst_n),
	.clk(clk),
	.in_00(test_data[00]),
	.in_01(test_data[01]),
	.in_02(test_data[02]),
	.in_03(test_data[03]),
	.in_04(test_data[04]),
	.in_05(test_data[05]),
	.in_06(test_data[06]),
	.in_07(test_data[07]),
	.in_08(test_data[08]),
	.in_09(test_data[09]),
	.in_10(test_data[10]),
	.in_11(test_data[11]),
	.in_12(test_data[12]),
	.in_13(test_data[13]),
	.in_14(test_data[14]),
	.in_15(test_data[15]),
	.in_16(test_data[16]),
	.in_17(test_data[17]),
	.in_18(test_data[18]),
	.in_19(test_data[19]),
	.in_20(test_data[20]),
	.in_21(test_data[21]),
	.in_22(test_data[22]),
	.in_23(test_data[23]),
	.in_24(test_data[24]),
	.in_25(test_data[25]), 
	.out(out)
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