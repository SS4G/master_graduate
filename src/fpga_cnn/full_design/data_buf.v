module DataBuf(
    rst_n,
    clk,
    rd_addr_NP,
    rd_data_NP, //输出端口为n个端口 入卷积核的输出是25个端口
    wr_addr_1P,
    wr_data_1P,
    wr_en
);

parameter DEPTH = 1024;
parameter WIDTH = 16;
parameter ADDR_WIDTH = 32; //本项目中全部使用32位地址
parameter PORT_NUM = 25; //输入地址和输出地址各有多少

input rst_n;
input clk;
input wr_en;
input [ADDR_WIDTH-1:0] wr_addr_1P;
input [WIDTH-1:0] wr_data_1P;
output [PORT_NUM*ADDR_WIDTH-1:0] rd_addr_NP;
output [PORT_NUM*WIDTH-1:0] rd_data_NP;



reg [WIDTH-1:0] mem [DEPTH-1:0];
wire [ADDR_WIDTH-1:0] debug_addr0 = rd_addr_NP[1*ADDR_WIDTH-1: 0*ADDR_WIDTH];


generate
genvar i;
    for(i = 0; i < PORT_NUM; i = i + 1)
    begin 
        assign rd_data_NP[(i+1)*WIDTH-1: i*WIDTH] = mem[rd_addr_NP[(i+1)*ADDR_WIDTH-1: i*ADDR_WIDTH]];
        //assign rd_data_NP[(i+1)*WIDTH-1: i*WIDTH] = mem[3];
    end
endgenerate

integer j;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        for(j = 0; j < DEPTH; j = j + 1)
        begin 
            mem[j] <= 0;
        end
    end
    else
    begin 
        mem[wr_addr_1P] <= wr_data_1P;
    end
end
endmodule