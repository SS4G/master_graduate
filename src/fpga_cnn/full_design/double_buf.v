//test_passed
//一个交替写入和读取的databuf 适用于不同层之间的流水线缓冲
//这个DataBuf 需要写读交替 先写后读 写一次读一次 读的是上次所写的内容
//写之前需要把数据准备好 同时wr_en 设置为高  写完之后 拉低wr_en
//读取之前需要设置 rd_en 为高 读取上次的内容 读取之后 拉低rd_en 这样才能使模块内部完成存储器的切换
module DoubleDataBuf(
    rst_n,
    clk,

    rd_en, 
    rd_addr_NP,
    rd_data_NP,

    wr_en,
    wr_addr_1P,
    wr_data_1P,

    data_fill_cnt
);

parameter DEPTH = 1000;
parameter WIDTH = 16;
parameter ADDR_WIDTH = 16; 
parameter OUT_PORT_NUM = 25; 

input rst_n;
input clk;

input rd_en; //外部读取使能信号 下降沿表明本次都完成
input [OUT_PORT_NUM*ADDR_WIDTH-1:0] rd_addr_NP;
output [OUT_PORT_NUM*WIDTH-1:0] rd_data_NP;

input wr_en; //外部写入使能信号 下降沿表示本次写入完成
input [ADDR_WIDTH-1:0] wr_addr_1P;
input [WIDTH-1:0] wr_data_1P;

output reg[1:0]  data_fill_cnt; //记录当前部件中有多少个databuf有 data

wire [OUT_PORT_NUM*ADDR_WIDTH-1:0] rd_addr_NP_0;
wire [OUT_PORT_NUM*ADDR_WIDTH-1:0] rd_addr_NP_1;
wire [OUT_PORT_NUM*WIDTH-1:0] rd_data_NP_0;
wire [OUT_PORT_NUM*WIDTH-1:0] rd_data_NP_1;

wire wr_en_0; //外部写入使能信号 下降沿表示本次写入完成
wire wr_en_1; //外部写入使能信号 下降沿表示本次写入完成
wire [ADDR_WIDTH-1:0] wr_addr_1P_0;
wire [ADDR_WIDTH-1:0] wr_addr_1P_1;
wire [WIDTH-1:0] wr_data_1P_0;
wire [WIDTH-1:0] wr_data_1P_1;

reg  last_wr_turn; //0 代表可以写入databuf 0
reg  last_rd_turn; //0 代表可以读取
reg  last_rd_en;
reg  last_wr_en;

MUX2_1 #(.WIDTH(OUT_PORT_NUM*WIDTH)) mux_rd_data(
    .select({7'd0, rd_sel}),
    .output_data(rd_data_NP),
    .in_00(rd_data_NP_0),
    .in_01(rd_data_NP_1)
);

DEMUX2_1 #(.WIDTH(OUT_PORT_NUM*ADDR_WIDTH)) demux_rd_addr(
    .select({7'd0, rd_sel}),
    .in_data(rd_addr_NP),
    .out_00(rd_addr_NP_0),
    .out_01(rd_addr_NP_1)
);

DEMUX2_1 #(.WIDTH(ADDR_WIDTH)) demux_wr_addr(
    .select({7'd0, wr_sel}),
    .in_data(wr_addr_1P),
    .out_00(wr_addr_1P_0),
    .out_01(wr_addr_1P_1)
);

DEMUX2_1 #(.WIDTH(WIDTH)) demux_wr_data(
    .select({7'd0, wr_sel}),
    .in_data(wr_data_1P),
    .out_00(wr_data_1P_0),
    .out_01(wr_data_1P_1)
);

DEMUX2_1 #(.WIDTH(1)) demux_wr_en(
    .select({7'd0, wr_sel}),
    .in_data(wr_en),
    .out_00(wr_en_0),
    .out_01(wr_en_1)
);

DataBuf #(
.DEPTH(DEPTH),
.WIDTH(WIDTH),
.ADDR_WIDTH(ADDR_WIDTH), //本项目中全部使用32位地址
.OUT_PORT_NUM(OUT_PORT_NUM) //输入地址和输出地址各有多少
) data_buf_inst_0(
    .rst_n(rst_n),
    .clk(clk),
    .rd_addr_NP(rd_addr_NP_0),
    .rd_data_NP(rd_data_NP_0), //输出端口为n个端口 入卷积核的输出是25个端口
    .wr_addr_1P(wr_addr_1P_0),
    .wr_data_1P(wr_data_1P_0),
    .wr_en(wr_en_0)
);

DataBuf #(
.DEPTH(DEPTH),
.WIDTH(WIDTH),
.ADDR_WIDTH(ADDR_WIDTH), //本项目中全部使用32位地址
.OUT_PORT_NUM(OUT_PORT_NUM) //输入地址和输出地址各有多少
) data_buf_inst_1(
    .rst_n(rst_n),
    .clk(clk),
    .rd_addr_NP(rd_addr_NP_1),
    .rd_data_NP(rd_data_NP_1), //输出端口为n个端口 入卷积核的输出是25个端口
    .wr_addr_1P(wr_addr_1P_1),
    .wr_data_1P(wr_data_1P_1),
    .wr_en(wr_en_1)
);

assign rd_sel = {7'd0, ~last_rd_turn}; 
assign wr_sel = {7'd0, ~last_wr_turn}; 
always @(posedge clk or negedge rst_n)
begin 
    if (!rst_n)
    begin
        data_fill_cnt <= 0;
        last_wr_turn <= 0;
        last_rd_turn <= 0;
    end 
    else
    begin
        if (last_rd_en > rd_en)
        begin
            last_rd_turn <= ~last_rd_turn;
        end 
        if (last_wr_en > wr_en)
        begin
            last_wr_turn <= ~last_wr_turn;
        end 
        if (!(last_rd_en > rd_en && last_wr_en > wr_en)) //非同时结束写入和读取
        begin
            if (last_rd_en > rd_en)
                data_fill_cnt <= data_fill_cnt > 0 ? data_fill_cnt - 1: 0;
            if (last_wr_en > wr_en)
                data_fill_cnt <= data_fill_cnt + 1;
        end
    end
end 

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        last_rd_en <= 0;
        last_wr_en <= 0;
    end
    else
    begin
        last_rd_en <= rd_en;
        last_wr_en <= wr_en;
    end 
end
endmodule 