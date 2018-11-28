`timescale 10ns/10ns
module double_databuf_tb;
integer i,j,k;
reg rst_n;
reg clk;
reg [31:0] cnt;
reg [15:0] wr_addr;
reg [7:0] wr_data;
reg [15:0] rd_addr [3:0];
reg wr_en;
reg rd_en;
wire [7:0] rd_data [3:0];

wire [16 * 4 - 1:0] rd_addr_bus;
wire [8 * 4 - 1:0] rd_data_bus;

wire [7:0] output_port [3: 0];

debus_1to26 #(.WIDTH(8)) DUT1_26(
    .com_bus_in(rd_data_bus),
    .sep_bus_out00(rd_data[00]),
    .sep_bus_out01(rd_data[01]),
    .sep_bus_out02(rd_data[02]),
    .sep_bus_out03(rd_data[03])
);

bus_26to1 #(.WIDTH(16)) DUT26_1(
    .com_bus_out(rd_addr_bus),
    .sep_bus_in00(rd_addr[00]),
    .sep_bus_in01(rd_addr[01]),
    .sep_bus_in02(rd_addr[02]),
    .sep_bus_in03(rd_addr[03]),
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

DoubleDataBuf #(
.DEPTH(32),
.WIDTH(8),
.ADDR_WIDTH(16), 
.PORT_NUM(4)
) DUT(
    .rst_n(rst_n),
    .clk(clk),
    .rd_addr_NP(rd_addr_bus),
    .rd_data_NP(rd_data_bus), //输出端口为n个端口 入卷积核的输出是25个端口
    .wr_addr_1P(wr_addr),
    .wr_data_1P(wr_data),
    .wr_en(wr_en),
    .rd_en(rd_en)
);

initial
begin
    clk = 0;
    rst_n = 0;
    wr_en = 0;
    wr_data = 1;
    wr_addr = 0;
    rd_en = 0;
    
    rd_addr[00] = 0;
    rd_addr[01] = 0;
    rd_addr[02] = 0;
    rd_addr[03] = 0;
    #100;
    rst_n = 1;
    
    wr_en = 1;
    for (i = 0; i < 5; i=i+1)
    begin
        @(posedge clk) 
        wr_addr = wr_addr + 1;
        wr_data = wr_data + 2;
        $display("inst1 %d %d", wr_addr, wr_data);
    end 
    #50;
    wr_en = 0;
    
    #103;
    rd_en = 1;
    rd_addr[00] = 1;
    rd_addr[01] = 2;
    rd_addr[02] = 3;
    rd_addr[03] = 4;
    
    #100;
    rd_en = 0;
    
    #100;
    
    wr_en = 1;
    wr_addr = 6;
    for (i = 0; i < 5; i=i+1)
    begin
        @(posedge clk) 
        wr_addr = wr_addr + 1;
        wr_data = wr_data + 2;
        $display("inst0 %d %d", wr_addr, wr_data);
    end 
    #50;
    wr_en = 0;
    
    #200;
    rd_en = 1;
    rd_addr[00] = 7;
    rd_addr[01] = 8;
    rd_addr[02] = 9;
    rd_addr[03] = 10;
    # 200;
    rd_en = 0;
    
    //-----------------------------------
    #100;
    wr_en = 1;
    wr_addr = 11;
    for (i = 0; i < 5; i = i + 1)
    begin
        @(posedge clk) 
        wr_addr = wr_addr + 1;
        wr_data = wr_data + 2;
        $display("inst1 %d %d", wr_addr, wr_data);
    end 
    #50;
    wr_en = 0;
    
    #200;
    rd_en = 1;
    rd_addr[00] = 12;
    rd_addr[01] = 13;
    rd_addr[02] = 14;
    rd_addr[03] = 15;
    # 200;
    rd_en = 0;
    
    
        #100;
    wr_en = 1;
    wr_addr = 11;
    for (i = 0; i < 5; i = i + 1)
    begin
        @(posedge clk) 
        wr_addr = wr_addr + 1;
        wr_data = wr_data + 2;
        $display("inst0 %d %d", wr_addr, wr_data);
    end 
    #50;
    wr_en = 0;
    
    #200;
    rd_en = 1;
    rd_addr[00] = 12;
    rd_addr[01] = 13;
    rd_addr[02] = 14;
    rd_addr[03] = 15;
    # 200;
    rd_en = 0;
    #10000;
    $finish;
end 

always #5 clk = ~clk;

/*always @(posedge clk)
begin 
    if (!rst_n)
    begin 
        wr_data <= 0;
        wr_addr <= 0;
        cnt <= 0;
    end 
    else
    begin 
        if (wr_addr < 5)
        begin 
            wr_en <= 1;
            cnt <= cnt + 1;
            wr_data <= cnt + 3;
            wr_addr <= wr_addr + 1;
        end
    end 
end */
endmodule 


