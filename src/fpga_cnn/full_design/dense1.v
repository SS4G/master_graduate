/** 该层完成 400->120 的向量变换 即 一个长度为400的 向量 乘一个 400 * 120的参数矩阵 最后得到一个120的向量
*   规定的数据存储方式 长度400的向量 该层分配4个 加法乘法核心每次计算25个乘加 所以 400向量存储为 16bit*25*4 每行 存储4行 
*   参数存储为 16bit*25*4 每行 即需要四个周期 计算完成一行的乘法和加法 然后迭代到下一次 
*   
*
*
*/

module Dense_1(
    rst_n,
    clk,
    layer_enable,

    wr_en,
    wr_data,
    wr_addr,

    rd_en,

    output_next_dense_wr_en,
    output_next_dense_addr,
    output_next_dense_data 
);

parameter MUL_KERNAL_NUM = 4;
parameter DATA_WIDTH = 16; //数据宽度
parameter ADDR_WIDTH = 16; //通用地址宽度16位
parameter DENSE_1_CALC_CYCLE = 480;

parameter BIAS_LENGTH = 255;

localparam RST_IDLE         = 16'h0000; //复位后的第一个状态 从rom中花一个周期读取bias 进入IDLE状态
localparam RST_IDLE2        = 16'h0040; //复位后的第一个状态 将bias放入bias寄存器 进入IDLE状态
localparam IDLE             = 16'h0010; //正常IDLE状态 等待layerenable指令 
localparam CALC_CONV        = 16'h0002; //计算31*31 卷积 
localparam CALC_CONV_END    = 16'h0020; //计算卷积完成 等待复位到pool的 rd_en

localparam INNER_PRODUCT_KERNAL_NUM = 4; //以当前分配到的计算核心 计算一行 需要多少次迭代
localparam NEXT_INNER_PRODUCT_KERNAL_NUM = 2; //下一层分配到的计算核心 
localparam OFFSET_EACH_LINE = 4;
localparam OFFSET_EACH_LINE_SHIFT_BIT = 4;

localparam DATA_BUF_DEPTH = 4; //每个深度中的内容是 INNER_PRODUCT_KERNAL_NUM*25 word
localparam BIAS_DATA_ADDR = 255; //bias data 放在最后几行中

input rst_n;
input clk;
input layer_enable;

input wr_en;
input [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH*25-1: 0] wr_data;
input [ADDR_WIDTH-1: 0] wr_addr;

output reg rd_en;

//输出到下一层的信号
output reg output_next_dense_wr_en;
output reg [ADDR_WIDTH-1: 0] output_next_dense_addr; 
output reg [NEXT_INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] output_next_dense_data; 

//modifi here 

//外部输入的向量数据 
wire [ADDR_WIDTH-1: 0] in_vec_addr; 
wire [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH*25-1: 0] in_vec_data;
reg [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH*25-1: 0] in_vec_data_delay;

//该层的权重参数 
wire [ADDR_WIDTH-1:0] param_addr;
wire [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH*25-1: 0] param_data;

//该层的偏置参数 
wire  [ADDR_WIDTH-1:0] bias_addr;
wire [DATA_WIDTH-1: 0] bias_data;

//一次计算中四个卷积核产生的4个内积的并列结果
wire [INNER_PRODUCT_KERNAL_NUM*DATA_WIDTH-1: 0] inner_product_sum;

//移位寄存器控制信号 
reg part_add_pause;
reg relu_add_pause;
reg part_add_en;

//行列计数信号
reg [15:0] offset_cnt; //同一行内计算的偏移 每次4个卷积核计算一次 算一次偏移
reg [15:0] line_cnt; //行偏移 计算当前计算到了矩阵的哪一行


// 一次内积的四个结果的求和 
wire [DATA_WIDTH-1:0] part_add_out;

// 一次内积的四个结果的求和的移位暂存结果
wire [DATA_WIDTH-1:0] part_add_out0;
wire [DATA_WIDTH-1:0] part_add_out1;
wire [DATA_WIDTH-1:0] part_add_out2;
wire [DATA_WIDTH-1:0] part_add_out3;

wire [DATA_WIDTH-1:0] relu_sum0;
wire [DATA_WIDTH-1:0] relu_sum1;



// relu 相关信号
wire [DATA_WIDTH-1:0] relu_in;
wire [DATA_WIDTH-1:0] relu_out;

reg [15:0] state;
reg [15:0] state_cnt;

//存储长度为400的16bit向量 
DoubleDataBuf #(
.DEPTH(DATA_BUF_DEPTH),
.WIDTH(INNER_PRODUCT_KERNAL_NUM*25*DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH),
.OUT_PORT_NUM(1)
) dens1_data(
    .rst_n(rst_n),
    .clk(clk),

    .rd_en(rd_en), 
    .rd_addr_NP(in_vec_addr),
    .rd_data_NP(in_vec_data),

    .wr_en(wr_en),
    .wr_addr_1P(wr_addr),
    .wr_data_1P(wr_data),

    .data_fill_cnt()
);

dense_1_params dense_1_param (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(param_addr),  // input wire [8 : 0] addra
  .douta(param_data)  // output wire [1599 : 0] douta
);



dense_1_bias dense1_bias (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(bias_addr),  // input wire [6 : 0] addra
  .douta(bias_data)  // output wire [15 : 0] douta
);

//一行计算未完成的的部分结果
ShiftReg4 shift_inst_part_add(
    .rst_n(rst_n),
    .clk(clk),
    .in(part_add_out),
    .out0(part_add_out0),
    .out1(part_add_out1),
    .out2(part_add_out2),
    .out3(part_add_out3),
    .pause(part_add_pause),
    .en(part_add_en)   
);

//多行计算已经relu完成的结果 准备插入到下一级 dense中 
ShiftReg4 shift_inst_relu_add(
    .rst_n(rst_n),
    .clk(clk),
    .in(relu_out),
    .out0(relu_sum0),
    .out1(relu_sum1),
    //.out2(relu_sum2),
    //.out3(relu_sum3),
    .pause(relu_add_pause),
    .en(relu_sum_en)   
);

//***不同的dense层该处可能不同 需要修改一下 
assign relu_in = part_add_out0 + part_add_out1 + part_add_out2 + part_add_out3 + bias_data;
assign relu_out = relu_in[DATA_WIDTH-1] == 1'b1 ? 0 : relu_in;
//一次移动计算的结果
assign part_add_out = (inner_product_sum[(0+1)*DATA_WIDTH-1: 0*DATA_WIDTH] + inner_product_sum[(1+1)*DATA_WIDTH-1: 1*DATA_WIDTH]) + (inner_product_sum[(2+1)*DATA_WIDTH-1: 2*DATA_WIDTH] + inner_product_sum[(3+1)*DATA_WIDTH-1: 3*DATA_WIDTH]);

assign output_dense_data = {relu_sum1, relu_sum0};

//计算应该取到的
assign param_addr = (line_cnt << OFFSET_EACH_LINE_SHIFT_BIT) + offset_cnt;
assign in_vec_addr = offset_cnt;
assign bias_addr = line_cnt;

generate 
genvar i; 
    for (i = 0; i < INNER_PRODUCT_KERNAL_NUM; i = i + 1)
    begin
        InnerProduct_25P innerinst(
            .clk(clk),
            .bias(0),
            .in_vecA_25P(in_vec_data_delay[(i+1)*DATA_WIDTH*25-1: i*DATA_WIDTH*25]),
            .in_vecB_25P(param_data[(i+1)*DATA_WIDTH*25-1: i*DATA_WIDTH*25]),
            .out_1P(inner_product_sum[(i+1)*DATA_WIDTH-1: i*DATA_WIDTH])
        ); 
    end 
endgenerate 

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        in_vec_data_delay <= 0;
    end
    else
    begin
        in_vec_data_delay <= in_vec_data;
    end
end 

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        state_cnt <= 0;
        rd_en <= 0;
        output_next_dense_wr_en  <=0;
        output_next_dense_addr<=0; 
        output_next_dense_data<=0; 
        part_add_pause <=0;
        relu_add_pause <=0;
        part_add_en<=0;
        offset_cnt<=0;
        line_cnt<=0;
    end
    else
    begin
        case(state)
        IDLE:begin 
            state_cnt <= IDLE;
            rd_en <= 0;
            output_next_dense_wr_en  <=0;
            output_next_dense_addr<=0; 
            output_next_dense_data<=0; 
            part_add_pause <=0;
            relu_add_pause <=0;
            part_add_en<=0;
            offset_cnt<=0;
            line_cnt<=0;
        end
        CALC_CONV:begin 
            state_cnt <= state_cnt + 1;
            if (offset_cnt < OFFSET_EACH_LINE - 1)
            begin
                offset_cnt <= offset_cnt + 1;
            end 
            else
            begin
                offset_cnt <= 0;
                line_cnt <= line_cnt + 1;
            end 
        end
        CALC_CONV_END:begin 
            rd_en <= 0;
            end 
        default:;        
        endcase
    end 
end

//state transform
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        state <= RST_IDLE;
    end
    else
    begin
        case(state)
        IDLE:
            if (layer_enable)
                state <= CALC_CONV;
        CALC_CONV:
            if (state_cnt >= DENSE_1_CALC_CYCLE)
                state <= CALC_CONV_END;
        CALC_CONV_END:
            state <= IDLE;
        default:state <= IDLE;
        endcase
    end 
end
endmodule 