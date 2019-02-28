module Src_buf_5P(
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
input [15:0] wr_data;
input [7:0] wr_addr;
input we;

genvar p;
generate 
    for (p = 0; p < 5; p = p + 1)
    begin
        //port b in 
        //port a out
        blk_mem_16b_256B data_buf (
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


module C3_Src_buf(
clk,
rd_addr_5P_0,
rd_addr_5P_1,
rd_addr_5P_2,
rd_addr_5P_3,
rd_addr_5P_4,
rd_addr_5P_5,

rd_data_5P_0,
rd_data_5P_1,
rd_data_5P_2,
rd_data_5P_3,
rd_data_5P_4,
rd_data_5P_5,

wr_data,
wr_addr,
we
);

input clk;
input [32*5-1:0] rd_addr_5P_0;
input [32*5-1:0] rd_addr_5P_1;
input [32*5-1:0] rd_addr_5P_2;
input [32*5-1:0] rd_addr_5P_3;
input [32*5-1:0] rd_addr_5P_4;
input [32*5-1:0] rd_addr_5P_5;

output [16*5-1:0] rd_data_5P_0;
output [16*5-1:0] rd_data_5P_1;
output [16*5-1:0] rd_data_5P_2;
output [16*5-1:0] rd_data_5P_3;
output [16*5-1:0] rd_data_5P_4;
output [16*5-1:0] rd_data_5P_5;

input [15:0] wr_data;
input [31:0] wr_addr;
input we;

wire [7:0] buf_idx = wr_addr[15:8];
wire we_0;
wire we_1;
wire we_2;
wire we_3;
wire we_4;
wire we_5;

wire [7:0] wr_addr_0; 
wire [7:0] wr_addr_1; 
wire [7:0] wr_addr_2; 
wire [7:0] wr_addr_3; 
wire [7:0] wr_addr_4; 
wire [7:0] wr_addr_5; 

wire [15:0] wr_data_0; 
wire [15:0] wr_data_1; 
wire [15:0] wr_data_2; 
wire [15:0] wr_data_3; 
wire [15:0] wr_data_4; 
wire [15:0] wr_data_5; 

DEMUX1_10 #(.WIDTH(16)) demux_data_inst(
    .select(buf_idx),
    .in_data(wr_data),
    .out_00(wr_data_0),
    .out_01(wr_data_1),
    .out_02(wr_data_2),
    .out_03(wr_data_3),
    .out_04(wr_data_4),
    .out_05(wr_data_5),
    .out_06(),
    .out_07(),
    .out_08(),
    .out_09()
);

DEMUX1_10 #(.WIDTH(8)) demux_addr_inst(
    .select(buf_idx),
    .in_data(wr_addr[7:0]),
    .out_00(wr_addr_0),
    .out_01(wr_addr_1),
    .out_02(wr_addr_2),
    .out_03(wr_addr_3),
    .out_04(wr_addr_4),
    .out_05(wr_addr_5),
    .out_06(),
    .out_07(),
    .out_08(),
    .out_09()
);

DEMUX1_10 #(.WIDTH(1)) demux_we_inst(
    .select(buf_idx),
    .in_data(we),
    .out_00(we_0),
    .out_01(we_1),
    .out_02(we_2),
    .out_03(we_3),
    .out_04(we_4),
    .out_05(we_5),
    .out_06(),
    .out_07(),
    .out_08(),
    .out_09()
);

Src_buf_5P src_buf_0(
    .clk(clk),
    .rd_addr_5P( rd_addr_5P_0),
    .rd_data_5P( rd_data_5P_0),
    .wr_data(       wr_data_0),
    .wr_addr(       wr_addr_0),
    .we(                 we_0)
);

Src_buf_5P src_buf_1(
    .clk(clk),
    .rd_addr_5P( rd_addr_5P_1),
    .rd_data_5P( rd_data_5P_1),
    .wr_data(       wr_data_1),
    .wr_addr(       wr_addr_1),
    .we(                 we_1)
);

Src_buf_5P src_buf_2(
    .clk(clk),
    .rd_addr_5P( rd_addr_5P_2),
    .rd_data_5P( rd_data_5P_2),
    .wr_data(       wr_data_2),
    .wr_addr(       wr_addr_2),
    .we(                 we_2)
);

Src_buf_5P src_buf_3(
    .clk(clk),
    .rd_addr_5P( rd_addr_5P_3),
    .rd_data_5P( rd_data_5P_3),
    .wr_data(       wr_data_3),
    .wr_addr(       wr_addr_3),
    .we(                 we_3)
);

Src_buf_5P src_buf_4(
    .clk(clk),
    .rd_addr_5P( rd_addr_5P_4),
    .rd_data_5P( rd_data_5P_4),
    .wr_data(       wr_data_4),
    .wr_addr(       wr_addr_4),
    .we(                 we_4)
);

Src_buf_5P src_buf_5(
    .clk(clk),
    .rd_addr_5P( rd_addr_5P_5),
    .rd_data_5P( rd_data_5P_5),
    .wr_data(       wr_data_5),
    .wr_addr(       wr_addr_5),
    .we(                 we_5)
);

endmodule