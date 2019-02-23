/*外部将DataBuf当做是1K 大小来看待 
实际上由于 可以同时读写 实际上有2k的空间
通过内部的状态寄存器 ping_pong 来控制真正读写的地址
*/
module PingPongDataBuf_6K_5P(
    rst_n,
    clk,
    we,
    rd_addr_5P,
    din,
    dout,
    wr_addr,
);

parameter PORT_NUM = 5;
parameter DATA_WIDTH = 16;
parameter HALF_ADDR = 1024*3;
parameter ADDR_WIDTH = 14;

input  rst_n;
input  clk;
input  we;
input  [32*PORT_NUM - 1: 0] rd_addr_5P;
input  [DATA_WIDTH-1: 0]    din;
input  [31: 0]   wr_addr;
output [DATA_WIDTH*PORT_NUM - 1: 0]  dout;

wire [DATA_WIDTH*PORT_NUM - 1: 0]  dout_w;
wire [DATA_WIDTH-1:0]          din_w;

reg ping_pong_r;
reg last_we_r;
wire [10: 0] wr_addr_w;
wire [14 * PORT_NUM - 1: 0] rd_addr_5P_w;

assign wr_addr_w = ping_pong_r? wr_addr_w + HALF_ADDR: wr_addr; 
genvar j;
generate 
    for (j = 0; j < PORT_NUM ;j = j + 1)
    begin
        assign rd_addr_5P_w[ADDR_WIDTH * (j + 1) - 1: ADDR_WIDTH * j] =  rd_addr_5P[32*j + ADDR_WIDTH - 1: 32*j] == ping_pong_r? rd_addr_5P[32*j + ADDR_WIDTH - 1: 32*j]: rd_addr_5P[32*j + ADDR_WIDTH - 1: 32*j] + HALF_ADDR; 
    end
endgenerate

genvar i;
generate 
    for (i = 0; i < PORT_NUM; i = i + 1)
    begin
        //port b in 
        //port a out
        blk_16b_12K data_buf (
          .clka(clk),    // input wire clka
          .wea(1'b0),      // input wire [0 : 0] wea
          .addra(rd_addr_5P_w[11 * (i + 1) - 1: 11 * i]),  // input wire [10 : 0] addra
          .dina(0),    // input wire [7 : 0] dina
          .douta(dout_w[DATA_WIDTH * (i + 1) - 1: DATA_WIDTH * i]),  // output wire [7 : 0] douta
          .clkb(clk),    // input wire clkb
          .web(we),      // input wire [0 : 0] web
          .addrb(wr_addr_w),  // input wire [10 : 0] addrb
          .dinb(din),    // input wire [7 : 0] dinb
          .doutb()  // output wire [7 : 0] doutb
        );
    end
endgenerate

assign dout = dout_w;
always @(posedge clk or negedge rst_n)
begin
     if(!rst_n)
     begin
         ping_pong_r <= 0;
         last_we_r <= 0;
     end
     else
     begin
         if (last_we_r == 1 && we == 0)
             ping_pong_r <= ~ping_pong_r; //reverse pingpong @ negedge of we
         last_we_r <= we;
     end     
end
endmodule