module ConstAddrMap_tb;
reg clk;
integer i;
reg [16:0] cnt;
reg [31:0] x_in [3:0];
reg [31:0] y_in [3:0];
wire [31:0] offset_out [3:0];

wire [26*32-1:0] x_bus;
wire [26*32-1:0] y_bus;
wire [4*32-1:0] offset_bus;


ConstAddrMap #(.PORT_NUM(4)) DUT(
    .x(x_bus),
    .y(y_bus),
    .offset(offset_bus)
);

debus_1to26 #(.WIDTH(32)) DUT1_26(
    .com_bus_in(offset_bus),
    .sep_bus_out00(offset_out[00]),
    .sep_bus_out01(offset_out[01]),
    .sep_bus_out02(offset_out[02]),
    .sep_bus_out03(offset_out[03])
);

bus_26to1 #(.WIDTH(32)) DUT26_1x(
    .com_bus_out(x_bus),
    .sep_bus_in00(x_in[00]),
    .sep_bus_in01(x_in[01]),
    .sep_bus_in02(x_in[02]),
    .sep_bus_in03(x_in[03]),
    .sep_bus_in04(0),
    .sep_bus_in05(0),
    .sep_bus_in06(0),
    .sep_bus_in07(0),
    .sep_bus_in08(0),
    .sep_bus_in09(0),
    .sep_bus_in10(0),
    .sep_bus_in11(0),
    .sep_bus_in12(0),
    .sep_bus_in13(0),
    .sep_bus_in14(0),
    .sep_bus_in15(0),
    .sep_bus_in16(0),
    .sep_bus_in17(0),
    .sep_bus_in18(0),
    .sep_bus_in19(0),
    .sep_bus_in20(0),
    .sep_bus_in21(0),
    .sep_bus_in22(0),
    .sep_bus_in23(0),
    .sep_bus_in24(0),
    .sep_bus_in25(0)
);


bus_26to1 #(.WIDTH(32)) DUT26_1y(
    .com_bus_out(y_bus),
    .sep_bus_in00(y_in[00]),
    .sep_bus_in01(y_in[01]),
    .sep_bus_in02(y_in[02]),
    .sep_bus_in03(y_in[03]),
    .sep_bus_in04(0),
    .sep_bus_in05(0),
    .sep_bus_in06(0),
    .sep_bus_in07(0),
    .sep_bus_in08(0),
    .sep_bus_in09(0),
    .sep_bus_in10(0),
    .sep_bus_in11(0),
    .sep_bus_in12(0),
    .sep_bus_in13(0),
    .sep_bus_in14(0),
    .sep_bus_in15(0),
    .sep_bus_in16(0),
    .sep_bus_in17(0),
    .sep_bus_in18(0),
    .sep_bus_in19(0),
    .sep_bus_in20(0),
    .sep_bus_in21(0),
    .sep_bus_in22(0),
    .sep_bus_in23(0),
    .sep_bus_in24(0),
    .sep_bus_in25(0)
);
initial 
begin 
    clk = 0;
    cnt = 0;
    for (i = 0; i < 26; i=i+1)
    begin
        x_in[i] = i;
        y_in[i] = 29 - i;
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