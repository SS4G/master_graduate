module DataBufPort5(
   clk,
   din,
   dout0,
   dout1,
   dout2,
   dout3,
   dout4,
   dout5,
   dout6,
   wr_addr,
   rd_addr0,
   rd_addr1,
   rd_addr2,
   rd_addr3,
   rd_addr4,
   rd_addr5,
   rd_addr6,
   we
);


input clk;
input [15:0] din;
output [15:0] dout0;
output [15:0] dout1;
output [15:0] dout2;
output [15:0] dout3;
output [15:0] dout4;
output [15:0] dout5;
output [15:0] dout6;
input [12:0] wr_addr;
input [12:0] rd_addr0;
input [12:0] rd_addr1;
input [12:0] rd_addr2;
input [12:0] rd_addr3;
input [12:0] rd_addr4;
input [12:0] rd_addr5;
input [12:0] rd_addr6;
input  we;
/*
blk_mem_gen_0 your_instance_name (
  .clka(clk),    // input wire clka
  .wea(0),      // input wire [0 : 0] wea
  .addra(rd_addr),  // input wire [12 : 0] addra
  .dina(0),    // input wire [15 : 0] dina
  .douta(dou),  // output wire [15 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(1),      // input wire enb
  .web(we),      // input wire [0 : 0] web
  .addrb(wr_addr),  // input wire [12 : 0] addrb
  .dinb(din),    // input wire [15 : 0] dinb
  .doutb()  // output wire [15 : 0] doutb
);*/

reg [15:0] mem [399:0];
assign dout0 = mem[rd_addr0];
assign dout1 = mem[rd_addr1];
assign dout2 = mem[rd_addr2];
assign dout3 = mem[rd_addr3];
assign dout4 = mem[rd_addr4];
assign dout5 = mem[rd_addr5];
assign dout6 = mem[rd_addr6];
always @(posedge clk)
begin
     if (we)
         mem[wr_addr] <= din;
end
endmodule
/*module DataBuf(
    rst_n,
    clk,
    rd_addr_NP,
    rd_data_NP, //输出端口为n个端�? 入卷积核的输出是25个端�?
    wr_addr_1P,
    wr_data_1P,
    wr_en
);

parameter DEPTH = 1024;
parameter WIDTH = 16;
parameter ADDR_WIDTH = 32; //本项目中全部使用32位地�?
parameter OUT_PORT_NUM = 5; //输入地址和输出地�?各有多少

input rst_n;
input clk;
input wr_en;
input [ADDR_WIDTH-1:0] wr_addr_1P;
input [WIDTH-1:0] wr_data_1P;
input [OUT_PORT_NUM*ADDR_WIDTH-1:0] rd_addr_NP;
output [OUT_PORT_NUM*WIDTH-1:0] rd_data_NP;

reg [WIDTH-1:0] mem [DEPTH-1:0];
wire [ADDR_WIDTH-1:0] debug_addr0 = rd_addr_NP[1*ADDR_WIDTH-1: 0*ADDR_WIDTH];

generate
genvar i;
    for(i = 0; i < OUT_PORT_NUM; i = i + 1)
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
    else if (wr_en)
    begin 
        mem[wr_addr_1P] <= wr_data_1P;
    end
end
endmodule*/