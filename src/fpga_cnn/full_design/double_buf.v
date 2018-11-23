module DoubleDataBUF(

);
parameter DEPTH = 32;
parameter WIDTH = 16;
parameter ADDR_WIDTH = 16; 
parameter PORT_NUM = 25; 

input rst_n;
input clk;
input [PORT_NUM*ADDR_WIDTH-1:0] rd_addr_NP;
input [PORT_NUM*WIDTH-1:0] rd_data_NP;
input rd_en;
input wr_en;

input [ADDR_WIDTH-1:0] wr_addr_1P;
input [WIDTH-1:0] wr_data_1P;

reg last_wr;
reg [1:0] data_buf_cnt; //表示第几个里面有数据

always @(posedge clk or negedge rst_n)
begin 
    if (!rst_n)
    begin
        last_wr_en <= 0;
        data_buf_cnt <= 0;
    end 
end 

DataBuf #(
.DEPTH(DEPTH),
.WIDTH(WIDTH),
.ADDR_WIDTH(ADDR_WIDTH), //本项目中全部使用32位地址
.PORT_NUM(PORT_NUM) //输入地址和输出地址各有多少
) 
data_buf inst_0(
    .rst_n(rst_n),
    .clk(clk),
    .rd_addr_NP(img_addr_bus),
    .rd_data_NP(img_data_bus), //输出端口为n个端口 入卷积核的输出是25个端口
    .wr_addr_1P(img_data_wr),
    .wr_data_1P(img_data_in)
);

DataBuf #(
.DEPTH(DEPTH),
.WIDTH(WIDTH),
.ADDR_WIDTH(ADDR_WIDTH), //本项目中全部使用32位地址
.PORT_NUM(PORT_NUM) //输入地址和输出地址各有多少
) 
data_buf inst_1(
    .rst_n(rst_n),
    .clk(clk),
    .rd_addr_NP(img_addr_bus),
    .rd_data_NP(img_data_bus), //输出端口为n个端口 入卷积核的输出是25个端口
    .wr_addr_1P(img_data_wr),
    .wr_data_1P(img_data_in)
);



endmodule 