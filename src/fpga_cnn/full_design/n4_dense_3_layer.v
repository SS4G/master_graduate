module Dense3_layer(
    clk,
    rst_n,
    layer_en_i,
    output_buf_en_o,
    
    data_to_calc_o,
    data_from_calc_i,
    
    data_from_buf_i,
    data_to_buf_o,
    
    data_to_buf_addr_o,
    data_from_buf_addr_o
);

parameter WIDTH = 16;

input  clk;
input  rst_n;
input  layer_en_i;
output output_buf_en_o;

output [16 * 51-1: 0] data_to_calc_o; //{VecA, VecB, Bias}
input  [15: 0] data_from_calc_i;

input  [16 * 5 - 1: 0] data_from_buf_i;
output [15: 0] data_to_buf_o;

output [31:0] data_to_buf_addr_o;
output [32*5-1:0] data_from_buf_addr_o;

reg [7:0] kernal_idx_r; //选择对应Kernalk

reg addr_gen_en_r; //地址生成使能
reg addr_gen_puase_r; //地址生成暂停 该信号为低时保持端口上原有的数据
wire [31 * 25 - 1: 0] addr_out_25P_w; //addr_gen输出的数据
wire [31: 0] rom_anchor_out_w;

reg  [16 * 25 - 1: 0] data_25_buffer_r; //缓存25个word数据的buf 每个时钟周期存入5个
wire [15: 0] current_bias_out_w;
wire [16*25-1: 0] current_kernel_out_w;

reg  [16*4-1: 0] pool_buf_r;
wire [15: 0] pool_out_w; 

AddrGen addr_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(addr_gen_en),//
    .pause(addr_gen_puase_r),//
    .addr_out_25P(addr_out_25P_w),//
    .anchor_addr_in(rom_anchor_out_w)//
    //.rom_addr_out(anchor_rom_addr)
);

C1_bias bias_inst (
    .clka(clk),    // input wire clka
    .addra(kernal_idx_r),  // input wire [2 : 0] addra
    .douta(current_bias_out_w)   // output wire [15 : 0] douta
);

C1_kernal kernal_inst (
    .clka(clk),    // input wire clka
    .addra(kernal_idx_r),  // input wire [2 : 0] addra
    .douta(current_kernel_out_w)   // output wire [399 : 0] douta
);

c1s2_layer_anchor_rom anchor_inst (
  .clka(clk),    // input wire clka
  .addra(anchor_rom_addr_r),  // input wire [9 : 0] addra
  .douta(rom_anchor_out_w)  // output wire [15 : 0] douta
);

MaxValue4P pool_inst(
    .in4P(pool_buf_r),
    .max_out(pool_out_w)
);


endmodule 