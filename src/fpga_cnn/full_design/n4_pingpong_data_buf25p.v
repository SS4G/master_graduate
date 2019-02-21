/*外部将DataBuf当做是1K 大小来看待 
实际上由于 可以同时读写 实际上有2k的空间
通过内部的状态寄存器 ping_pong 来控制真正读写的地址
*/
module PingPongDataBuf_1K(
    rst_n,
    clk,
    we,
    rd_addr_25P,
    din,
    dout,
    wr_addr,

);

input  rst_n;
input  clk;
input  we;
input  [32*25 - 1: 0] rd_addr_25P;
input  [7: 0]        din;
input  [31: 0]        wr_addr;
output [8*25 - 1: 0]  dout;

wire [8*25 - 1: 0]  dout_w;
wire [7:0]          din_w;

reg ping_pong_r;
reg last_we_r;
wire [10: 0] wr_addr_w;
wire [10: 0] rd_addr_w [24: 0];

assign wr_addr_w = ping_pong_r? wr_addr_w + 1024: wr_addr; 
genvar j;
generate 
    for (j = 0; j < 25 ;j= j+1)
    begin
        assign rd_addr_w[32*j + 10: 32*j] = ping_pong_r? rd_addr_25P[32*j + 10: 32*j]: rd_addr_25P[32*j + 10: 32*j] + 1024; 
    end
endgenerate


genvar i;
generate 
    for (i = 0; i < 25 ;i= i+1)
    begin
        //port b in 
        //port a out
        blk_mem_8b data_buf (
          .clka(clk),    // input wire clka
          .wea(1'b0),      // input wire [0 : 0] wea
          .addra(rd_addr_w[32*i + 10: 32*i]),  // input wire [10 : 0] addra
          .dina(0),    // input wire [7 : 0] dina
          .douta(dout_w[8*(i+1) - 1: 8*i]),  // output wire [7 : 0] douta
          .clkb(clk),    // input wire clkb
          .web(we),      // input wire [0 : 0] web
          .addrb(wr_addr_w),  // input wire [10 : 0] addrb
          .dinb(din),    // input wire [7 : 0] dinb
          .doutb()  // output wire [7 : 0] doutb
        );
    end
endgenerate



always @(posedge clk or negedge rst_n)
begin
     if(!rst_n)
     begin
         ping_pong_r <= 0;
     end
     else
     begin
         last_we_r <= we;
         if (last_we_r == 1 &&we == 0)
             ping_pong_r <= ~ping_pong_r; //reverse pingpong @ negedge of we
     end     
end
endmodule