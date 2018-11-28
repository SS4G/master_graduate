`timescale 1ns/1ns
module addTree_tb;
reg rst_n;
reg clk;
reg [15:0] test_data [25:0];
integer i, j, k;
integer start;
reg[15:0] tmp;
wire [15:0] out;
wire [25*16-1:0] data_mid;
integer cnt;



bus_26to1 DUT26_1(
    .com_bus_out(data_mid),
    .sep_bus_in00(test_data[00]),
    .sep_bus_in01(test_data[01]),
    .sep_bus_in02(test_data[02]),
    .sep_bus_in03(test_data[03]),
    .sep_bus_in04(test_data[04]),
    .sep_bus_in05(test_data[05]),
    .sep_bus_in06(test_data[06]),
    .sep_bus_in07(test_data[07]),
    .sep_bus_in08(test_data[08]),
    .sep_bus_in09(test_data[09]),
    .sep_bus_in10(test_data[10]),
    .sep_bus_in11(test_data[11]),
    .sep_bus_in12(test_data[12]),
    .sep_bus_in13(test_data[13]),
    .sep_bus_in14(test_data[14]),
    .sep_bus_in15(test_data[15]),
    .sep_bus_in16(test_data[16]),
    .sep_bus_in17(test_data[17]),
    .sep_bus_in18(test_data[18]),
    .sep_bus_in19(test_data[19]),
    .sep_bus_in20(test_data[20]),
    .sep_bus_in21(test_data[21]),
    .sep_bus_in22(test_data[22]),
    .sep_bus_in23(test_data[23]),
    .sep_bus_in24(test_data[24]),
    .sep_bus_in25(0)
);

AddTree_26p DUT(
    .rst_n(rst_n),
	.clk(clk),
	.in_25P(data_mid),
	.in_bias(test_data[25]),  
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
    
    #200;
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