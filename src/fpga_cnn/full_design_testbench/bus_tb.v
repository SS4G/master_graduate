module bus_debus_tb;
reg clk;
integer i;
reg [16:0] cnt;
reg [15:0] data_in [25:0];
wire [15:0] data_out [25:0];
wire [26*16-1:0] data_mid;

debus_1to26 DUT1_26(
    .com_bus_in(data_mid),
    .sep_bus_out00(data_out[00]),
    .sep_bus_out01(data_out[01]),
    .sep_bus_out02(data_out[02]),
    .sep_bus_out03(data_out[03]),
    .sep_bus_out04(data_out[04]),
    .sep_bus_out05(data_out[05]),
    .sep_bus_out06(data_out[06]),
    .sep_bus_out07(data_out[07]),
    .sep_bus_out08(data_out[08]),
    .sep_bus_out09(data_out[09]),
    .sep_bus_out10(data_out[10]),
    .sep_bus_out11(data_out[11]),
    .sep_bus_out12(data_out[12]),
    .sep_bus_out13(data_out[13]),
    .sep_bus_out14(data_out[14]),
    .sep_bus_out15(data_out[15]),
    .sep_bus_out16(data_out[16]),
    .sep_bus_out17(data_out[17]),
    .sep_bus_out18(data_out[18]),
    .sep_bus_out19(data_out[19]),
    .sep_bus_out20(data_out[20]),
    .sep_bus_out21(data_out[21]),
    .sep_bus_out22(data_out[22]),
    .sep_bus_out23(data_out[23]),
    .sep_bus_out24(data_out[24]),
    .sep_bus_out25(data_out[25])
);

bus_26to1 DUT26_1(
    .com_bus_out(data_mid),
    .sep_bus_in00(data_in[00]),
    .sep_bus_in01(data_in[01]),
    .sep_bus_in02(data_in[02]),
    .sep_bus_in03(data_in[03]),
    .sep_bus_in04(data_in[04]),
    .sep_bus_in05(data_in[05]),
    .sep_bus_in06(data_in[06]),
    .sep_bus_in07(data_in[07]),
    .sep_bus_in08(data_in[08]),
    .sep_bus_in09(data_in[09]),
    .sep_bus_in10(data_in[10]),
    .sep_bus_in11(data_in[11]),
    .sep_bus_in12(data_in[12]),
    .sep_bus_in13(data_in[13]),
    .sep_bus_in14(data_in[14]),
    .sep_bus_in15(data_in[15]),
    .sep_bus_in16(data_in[16]),
    .sep_bus_in17(data_in[17]),
    .sep_bus_in18(data_in[18]),
    .sep_bus_in19(data_in[19]),
    .sep_bus_in20(data_in[20]),
    .sep_bus_in21(data_in[21]),
    .sep_bus_in22(data_in[22]),
    .sep_bus_in23(data_in[23]),
    .sep_bus_in24(data_in[24]),
    .sep_bus_in25(data_in[25])
);
initial 
begin 
    clk = 0;
    cnt = 0;
    for (i = 0; i < 26; i=i+1)
    begin
        data_in[i] = i;
    end
    #10000;
    $finish;
end 
always #5 clk = ~clk;
always @(posedge clk)
begin
   cnt <= cnt+1;
end 

endmodule 