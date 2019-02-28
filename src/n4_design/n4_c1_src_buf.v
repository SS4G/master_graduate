//5个并行RAM
module C1_Src_buf(
clk,
rd_addr_5P,
rd_data_5P,
wr_data,
wr_addr,
we
);

input clk;
input  [32*5-1:0] rd_addr_5P;
output [16*5-1:0] rd_data_5P;
input  [15:0] wr_data;
input  [31:0] wr_addr;
input we;

genvar p;
generate 
    for (p = 0; p < 5; p = p + 1)
    begin
        //port b in 
        //port a out
        blk_mem_16b_6K data_buf (
          .clka(clk),    // input wire clka
          .wea(1'b0),      // input wire [0 : 0] wea
          .addra(rd_addr_5P[32 * (p + 1)-1: 32 * p]),  // input wire [10 : 0] addra
          .dina(0),    // input wire [7 : 0] dina
          .douta(rd_data_5P[16 * (p + 1)-1: 16 * p]),  // output wire [7 : 0] douta
          .clkb(clk),    // input wire clkb
          .web(we),      // input wire [0 : 0] web
          .addrb(wr_addr),  // input wire [10 : 0] addrb
          .dinb(wr_data),    // input wire [7 : 0] dinb
          .doutb()  // output wire [7 : 0] doutb
        );
    end
endgenerate
endmodule