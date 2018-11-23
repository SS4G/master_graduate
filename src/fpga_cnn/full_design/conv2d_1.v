module Conv2D_1(
    clk,
    rst_n,
    wr_img_enable,
    
    img_data_wr,
    img_data_in,
    
    pool_1_out
);
/*
    step1 写 img dataBuf
    step2 生成地址 
    step3 计算卷积和
    step4 写入外部pool dataBuf
*/

parameter DATA_WIDTH = 16;
parameter KERNAL_NUM = 6;
parameter ADDR_WIDTH = 16;
parameter KERNAL_WIDTH = 5;
parameter KERNAL_HEIGHT = 5;
parameter KERNAL_ENEMENT_SZIE = KERNAL_HEIGHT * KERNAL_WIDTH;

parameter FEATURE_MAP_WIDTH = 35;
parameter FEATURE_MAP_HEIGHT = 35;
parameter FEATURE_MAP_ENEMENT_SZIE = FEATURE_MAP_WIDTH * FEATURE_MAP_HEIGHT;

localparam IDLE = 16'h0000;
localparam READ_BIAS = 16'h0001;
localparam WR_IMAGE_DATA = 16'h0008;
localparam CALC_CONV = 16'h0002;
localparam WR_POOL = 16'h0004;

input clk;
input rst_n;
input conv_en; //卷积层工作使能 该信后之后 bias数据放在存储器中

input img_data_wr;
input [DATA_WIDTH-1:0] img_data_in;

output [DATA_WIDTH*KERNAL_NUM-1: 0] pool_1_out_bus; 写入pool缓冲区数据总线

output pool_1_out_en; //通知外部 准备写入pool 缓冲区
output wr_img_en; //允许外部向图片缓冲区中写入


wire [7:0] addr_depth;
wire [DATA_WIDTH*KERNAL_ENEMENT_SZIE-1:0] img_addr_bus; //从databuf中取图片的地址
wire [DATA_WIDTH*KERNAL_ENEMENT_SZIE-1:0] img_data_bus; //从databuf中取图片的地址
wire [DATA_WIDTH*KERNAL_ENEMENT_SZIE-1:0] kernal_data_bus; //从rom中取kernal数据的总线
reg [KERNAL_NUM*DATA_WIDTH-1:0] bias_data; //
reg rom_addr;

reg [15:0] state;
reg [7:0] state_cnt;
reg [7:0] img_read_cnt;

ConvAddressGen_3D_25P(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .pause(0),
    .out_depth(addr_depth),
    .out_offset_NP(img_addr_bus)
);

DataBuf #(
.DEPTH(FEATURE_MAP_ENEMENT_SZIE),
.WIDTH(DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH), //本项目中全部使用32位地址
.PORT_NUM(KERNAL_ENEMENT_SZIE) //输入地址和输出地址各有多少
) 
data_buf_img(
    .rst_n(rst_n),
    .clk(clk),
    .rd_addr_NP(img_addr_bus),
    .rd_data_NP(img_data_bus), //输出端口为n个端口 入卷积核的输出是25个端口
    .wr_addr_1P(img_data_wr),
    .wr_data_1P(img_data_in)
);

generate 
genvar j;
for (j = 0; j < KERNAL_NUM; j = j + 1)
begin
    ConvKernal inst(
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .bias(bias_data[DATA_WIDTH*(j+1)-1:DATA_WIDTH*j]),
        .data_25P(img_data_bus),
        .kernal_25P(kernal_data_bus[DATA_WIDTH*KERNAL_ENEMENT_SZIE*(j+1)-1: DATA_WIDTH*KERNAL_ENEMENT_SZIE*j]),
        .relu_out(pool_1_out_bus[DATA_WIDTH*(j+1)-1:DATA_WIDTH*j])
    );
end 
endgenerate 

rom_conv1_kerbia_param keral_bias_inst (
  .clka(clk),    // input wire clka
  .addra(rom_addr),  // input wire [0 : 0] addra 0输出kernal的数据 1输出bias的数据
  .douta(kernal_data_bus)  // output wire [2399 : 0] douta 
);

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        state <= IDLE;
        state_cnt <= 0;
    end
    else
    begin
        case state
        IDLE:   begin
                    if (img_data_wr)
                    begin 
                        state <= 
                    end 
                end        
        
        endcase
    end 
end
endmodule 