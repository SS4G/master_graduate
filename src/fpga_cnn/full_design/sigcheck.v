input rst_n;
input clk;
input wr_en;
input [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] wr_data;
input [ADDR_WIDTH-1: 0] wr_addr;
input wr_en;

output reg rd_en;
output reg [ADDR_WIDTH-1: 0] output_dense_addr; 
output  [NEXT_INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] output_dense_data; 

//modifi here 
reg [15: 0] params_rom_addr;
reg [ADDR_WIDTH-1: 0] param_addr;

//外部输入的向量数据 
reg [ADDR_WIDTH-1: 0] input_vec_addr; 
wire [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] input_vec_data;

//该层的权重参数 
reg  [ADDR_WIDTH-1:0] param_addr;
wire [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] param_data;

//该层的偏置参数 
reg  [ADDR_WIDTH-1:0] bias_addr;
wire [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] bias_data;

//一次计算中四个卷积核产生的4个内积的并列结果
wire [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] inner_product_sum;

//移位寄存器控制信号 
reg part_add_pause;
reg relu_add_pause;
reg part_add_en;
reg relu_add_en;

// 一次内积的四个结果的求和 
wire [DATA_WIDTH-1:0] part_add_out;

// 一次内积的四个结果的求和的移位暂存结果
wire [DATA_WIDTH-1:0] part_add_out0;
wire [DATA_WIDTH-1:0] part_add_out1;
wire [DATA_WIDTH-1:0] part_add_out2;
wire [DATA_WIDTH-1:0] part_add_out3;

// 
wire [DATA_WIDTH-1:0] relu_in;
wire [DATA_WIDTH-1:0] relu_out;
wire [NEXT_INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1:0] output_dense_data;


