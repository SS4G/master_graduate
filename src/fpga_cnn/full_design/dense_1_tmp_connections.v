parameter MUL_KERNAL_NUM = 4;
parameter DATA_WIDTH = 16; //数据宽度
parameter ADDR_WIDTH = 16; //通用地址宽度16位
parameter 

parameter BIAS_LENGTH = 255;

localparam RST_IDLE         = 16'h0000; //复位后的第一个状态 从rom中花一个周期读取bias 进入IDLE状态
localparam RST_IDLE2        = 16'h0004; //复位后的第一个状态 将bias放入bias寄存器 进入IDLE状态
localparam IDLE             = 16'h0010; //正常IDLE状态 等待layerenable指令 
localparam CALC_CONV        = 16'h0002; //计算31*31 卷积 
localparam CALC_CONV_END    = 16'h0020; //计算卷积完成 等待复位到pool的 rd_en

localparam INNER_PRODUCT_KERNAL_NUM = 4; //以当前分配到的计算核心 计算一行 需要多少次迭代
localparam NEXT_INNER_PRODUCT_KERNAL_NUM = 2; //下一层分配到的计算核心 

localparam DATA_BUF_DEPTH = 4; //每个深度中的内容是 INNER_PRODUCT_KERNAL_NUM*25 word
localparam BIAS_DATA_ADDR = 255; //bias data 放在最后几行中

input rst_n;
input clk;
input layer_enable;


input wr_en;
input [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] wr_data;
input [ADDR_WIDTH-1: 0] wr_addr;
input wr_en;

output reg rd_en;

//输出到下一层的信号
output reg output_next_dense_en;
output reg [ADDR_WIDTH-1: 0] output_next_dense_addr; 
output reg [NEXT_INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] output_next_dense_data; 

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

// relu 相关信号
wire [DATA_WIDTH-1:0] relu_in;
wire [DATA_WIDTH-1:0] relu_out;
