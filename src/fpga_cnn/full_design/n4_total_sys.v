module TotalSys(
    clk,
    rst_n,
    data_in_valid,
    data_in,
    data_out_en,
    data_out
); 

input clk;
input rst_n;
input data_in_valid;
input [63:0] data_in;
output data_out_en;
output [7:0] data_out;

reg layer_c1s2_en_r;
reg layer_c3s4_en_r;
reg layer_den1_en_r;
reg layer_den2_en_r;
reg layer_den3_en_r;

wire layer_buf_out_en_full_w;
wire layer_buf_out_en_c1s2_w;
wire layer_buf_out_en_c3s4_w;
wire layer_buf_out_en_den1_w;
wire layer_buf_out_en_den2_w;
wire layer_buf_out_en_den3_w;

wire [51*16-1 :0] data_to_calc_full_w;
wire [51*16-1 :0] data_to_calc_c1s2_w;
wire [51*16-1 :0] data_to_calc_c3s4_w;
wire [51*16-1 :0] data_to_calc_den1_w;
wire [51*16-1 :0] data_to_calc_den2_w;
wire [51*16-1 :0] data_to_calc_den3_w;

wire [15: 0] data_from_calc_full_w;
wire [15: 0] data_from_calc_c1s2_w;
wire [15: 0] data_from_calc_c3s4_w;
wire [15: 0] data_from_calc_den1_w;
wire [15: 0] data_from_calc_den2_w;
wire [15: 0] data_from_calc_den3_w;

wire [16*5-1:0] data_from_buf_full_w;
wire [16*5-1:0] data_from_buf_c1s2_w;
wire [16*5-1:0] data_from_buf_c3s4_w;
wire [16*5-1:0] data_from_buf_den1_w;
wire [16*5-1:0] data_from_buf_den2_w;
wire [16*5-1:0] data_from_buf_den3_w;

wire [15:0] data_to_buf_full_w;
wire [15:0] data_to_buf_c1s2_w;
wire [15:0] data_to_buf_c3s4_w;
wire [15:0] data_to_buf_den1_w;
wire [15:0] data_to_buf_den2_w;
wire [15:0] data_to_buf_den3_w;

    
wire [32*5-1:0] data_from_buf_addr_full_w;
wire [32*5-1:0] data_from_buf_addr_c1s2_w;
wire [32*5-1:0] data_from_buf_addr_c3s4_w;
wire [32*5-1:0] data_from_buf_addr_den1_w;
wire [32*5-1:0] data_from_buf_addr_den2_w;
wire [32*5-1:0] data_from_buf_addr_den3_w;

wire [31: 0] data_to_buf_addr_full_w;
wire [31: 0] data_to_buf_addr_c1s2_w;
wire [31: 0] data_to_buf_addr_c3s4_w;
wire [31: 0] data_to_buf_addr_den1_w;
wire [31: 0] data_to_buf_addr_den2_w;
wire [31: 0] data_to_buf_addr_den3_w;

reg [7: 0] select_r;

PingPongDataBuf_6K_5P data_buf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(layer_buf_out_en_full_w),
    .rd_addr_5P(data_from_buf_addr_full_w),
    .din(data_to_buf_full_w),
    .dout(data_from_buf_full_w),
    .wr_addr(data_to_buf_addr_full_w)
);

MUX10_1 #(.WIDTH(1)) mux_buf_out_en(
    .select(select_r),
    .output_data(layer_buf_out_en_full_w),
    .in_00(layer_buf_out_en_c1s2_w),
    .in_01(layer_buf_out_en_c3s4_w),
    .in_02(layer_buf_out_en_den1_w),
    .in_03(layer_buf_out_en_den2_w),
    .in_04(layer_buf_out_en_den3_w),
    .in_05(0),
    .in_06(0),
    .in_07(0),
    .in_08(0),
    .in_09(0)
);

MUX10_1  #(.WIDTH(51*16))mux_data_to_calc(
    .select(select_r),
    .output_data(data_to_calc_full_w),
    .in_00(data_to_calc_c1s2_w),
    .in_01(data_to_calc_c3s4_w),
    .in_02(data_to_calc_den1_w),
    .in_03(data_to_calc_den2_w),
    .in_04(data_to_calc_den3_w),
    .in_05(0),
    .in_06(0),
    .in_07(0),
    .in_08(0),
    .in_09(0)
);

MUX10_1  #(.WIDTH(16))mux_data_to_buf(
    .select(select_r),
    .output_data(data_to_buf_full_w),
    .in_00(data_to_buf_c1s2_w),
    .in_01(data_to_buf_c3s4_w),
    .in_02(data_to_buf_den1_w),
    .in_03(data_to_buf_den2_w),
    .in_04(data_to_buf_den3_w),
    .in_05(0),
    .in_06(0),
    .in_07(0),
    .in_08(0),
    .in_09(0)
);
//---
MUX10_1  #(.WIDTH(31)) data_from_buf_addr(
    .select(select_r),
    .output_data(data_from_buf_addr_full_w),
    .in_00(data_from_buf_addr_c1s2_w),
    .in_01(data_from_buf_addr_c3s4_w),
    .in_02(data_from_buf_addr_den1_w),
    .in_03(data_from_buf_addr_den2_w),
    .in_04(data_from_buf_addr_den3_w),
    .in_05(0),
    .in_06(0),
    .in_07(0),
    .in_08(0),
    .in_09(0)
);

MUX10_1  #(.WIDTH(16))mux_data_to_buf_addr(
    .select(select_r),
    .output_data(data_to_buf_addr_full_w),
    .in_00(data_to_buf_addr_c1s2_w),
    .in_01(data_to_buf_addr_c3s4_w),
    .in_02(data_to_buf_addr_den1_w),
    .in_03(data_to_buf_addr_den2_w),
    .in_04(data_to_buf_addr_den3_w),
    .in_05(0),
    .in_06(0),
    .in_07(0),
    .in_08(0),
    .in_09(0)
);


DEMUX1_10 #(.WIDTH(16))demux_data_from_calc(
    .select(select_r),
    .in_data(data_from_calc_full_w),
    .out_00(data_from_calc_c1s2_w),
    .out_01(data_from_calc_c3s4_w),
    .out_02(data_from_calc_den1_w),
    .out_03(data_from_calc_den2_w),
    .out_04(data_from_calc_den3_w),
    .out_05(),
    .out_06(),
    .out_07(),
    .out_08(),
    .out_09()
);

DEMUX1_10 #(.WIDTH(5*16))demux_data_from_buf(
    .select(select_r),
    .in_data(data_from_buf_full_w),
    .out_00(data_from_buf_c1s2_w),
    .out_01(data_from_buf_c3s4_w),
    .out_02(data_from_buf_den1_w),
    .out_03(data_from_buf_den2_w),
    .out_04(data_from_buf_den3_w),
    .out_05(),
    .out_06(),
    .out_07(),
    .out_08(),
    .out_09()
);


InnerProduct_25P inner_inst(
    .clk(clk),
    .bias(data_to_calc_full_w[15:0]),
    .in_vecA_25P(data_to_calc_full_w[51*16-1:26*16]),
    .in_vecB_25P(data_to_calc_full_w[26*16-1:1*16]),
    .out_1P(data_from_calc_full_w)
);

C1S2_layer c1s2_layer(
    .clk(clk),
    .rst_n(rst_n),
    .layer_en_i(layer_c1s2_en_r),
    .output_buf_en_o(layer_buf_out_en_c1s2_w),
    
    .data_to_calc_o(data_to_calc_c1s2_w),
    .data_from_calc_i(data_from_calc_c1s2_w),
    
    .data_from_buf_i(data_from_buf_c1s2_w),
    .data_to_buf_o(data_to_buf_c1s2_w),
    
    .data_to_buf_addr_o(data_to_buf_addr_c1s2_w),
    .data_from_buf_addr_o(data_from_buf_addr_c1s2_w)
);

C3S4_layer c3s4_layer(
    .clk(clk),
    .rst_n(rst_n),
    .layer_en_i(layer_c3s4_en_r),
    .output_buf_en_o(layer_buf_out_en_c3s4_w),
    
    .data_to_calc_o(data_to_calc_c3s4_w),
    .data_from_calc_i(data_from_calc_c3s4_w),
    
    .data_from_buf_i(data_from_buf_c3s4_w),
    .data_to_buf_o(data_to_buf_c3s4_w),
    
    .data_from_buf_addr_o(data_from_buf_addr_c3s4_w),
    .data_to_buf_addr_o(data_to_buf_addr_c3s4_w)
);

Dense1_layer den1_layer(
    .clk(clk),
    .rst_n(rst_n),
    .layer_en_i(layer_den1_en_r),
    .output_buf_en_o(layer_buf_out_en_den1_w),
    
    .data_to_calc_o(data_to_calc_den1_w),
    .data_from_calc_i(data_from_calc_den1_w),
    
    .data_from_buf_i(data_from_buf_den1_w),
    .data_to_buf_o(data_to_buf_den1_w),
    
    .data_from_buf_addr_o(data_from_buf_addr_den1_w),
    .data_to_buf_addr_o(data_to_buf_addr_den1_w)
);

Dense2_layer den2_layer(
    .clk(clk),
    .rst_n(rst_n),
    .layer_en_i(layer_den2_en_r),
    .output_buf_en_o(layer_buf_out_en_den2_w),
    
    .data_to_calc_o(data_to_calc_den2_w),
    .data_from_calc_i(data_from_calc_den2_w),
    
    .data_from_buf_i(data_from_buf_den2_w),
    .data_to_buf_o(data_to_buf_den2_w),
    
    .data_from_buf_addr_o(data_from_buf_addr_den2_w),
    .data_to_buf_addr_o(data_to_buf_addr_den2_w)
);

Dense3_layer den3_layer(
    .clk(clk),
    .rst_n(rst_n),
    .layer_en_i(layer_den3_en_r),
    .output_buf_en_o(layer_buf_out_en_den3_w),
    
    .data_to_calc_o(data_to_calc_den3_w),
    .data_from_calc_i(data_from_calc_den3_w),
    
    .data_from_buf_i(data_from_buf_den3_w),
    .data_to_buf_o(data_to_buf_den3_w),
    
    .data_from_buf_addr_o(data_from_buf_addr_den3_w),
    .data_to_buf_addr_o(data_to_buf_addr_den3_w)
);

endmodule