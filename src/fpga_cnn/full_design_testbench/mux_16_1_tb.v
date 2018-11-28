module MUX16_1_tb;
reg rst_n;
reg clk;
integer i, j, k;
integer start;
reg[15:0] tmp;
wire [15:0] out;
integer cnt;

reg [31:0] test_in [15:0];
wire [31:0] test_out;
reg [7:0] sel;  

initial
begin 
    #100;
    sel = 0;
    for(i = 0; i < 16; i=i+1)
    begin
        test_in[i] = i + 32'h7000_0000;
    end
    
    for(i = 0; i < 16 ; i=i+1)
    begin
        # 50;
        sel = i;
    end 
    
    #100;
end 

MUX16_1 #(.WIDTH(32)) DUT(
    .select(sel),
    .output_data(out),
    .in_00(test_in[00]),
    .in_01(test_in[01]),
    .in_02(test_in[02]),
    .in_03(test_in[03]),
    .in_04(test_in[04]),
    .in_05(test_in[05]),
    .in_06(test_in[06]),
    .in_07(test_in[07]),
    .in_08(test_in[08]),
    .in_09(test_in[09]),
    .in_10(test_in[10]),
    .in_11(test_in[11]),
    .in_12(test_in[12]),
    .in_13(test_in[13]),
    .in_14(test_in[14]),
    .in_15(test_in[15])
);
endmodule