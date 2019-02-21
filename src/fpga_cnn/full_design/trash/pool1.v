module Pool_1(
    clk,
    rst_n,
    
    //conv2d_1 使能
    layer_enable,
    
    //conv2d_1 数据输入信号
    img_data_wr_en,
    img_data_in,
    img_data_addr,
    
    //conv2d_1 数据读取完成反馈
    img_data_rd_en,
    
    //输出到池化层的数据信号
    pool_1_out_bus,
    pool_1_out_addr,
    pool_1_out_wr_en
);

/*
    step1 写 img dataBuf
    step2 生成地址 
    step3 计算卷积和
    step4 写入外部pool dataBuf
*/

parameter DATA_WIDTH = 16; //数据宽度
parameter KERNAL_NUM = 6;  //kernal 数量 
parameter ADDR_WIDTH = 16; //通用地址宽度16位
parameter KERNAL_WIDTH = 2; 
parameter KERNAL_HEIGHT = 2;
parameter KERNAL_ENEMENT_SZIE = KERNAL_HEIGHT * KERNAL_WIDTH; //kernal 中的元素数量 

parameter FEATURE_MAP_WIDTH = 31; //上一级feature map输入 WIDTH
parameter FEATURE_MAP_HEIGHT = 31; //上一级feature map输入 HEIGHT
parameter FEATURE_MAP_ENEMENT_SZIE = FEATURE_MAP_WIDTH * FEATURE_MAP_HEIGHT; //上一级feature map 中的元素数量 
parameter ANCHOR_ENEMENT_SZIE = (FEATURE_MAP_WIDTH-KERNAL_WIDTH+1) * (FEATURE_MAP_HEIGHT-KERNAL_HEIGHT+1); //上一级feature map 中的元素数量 


//RST_IDLE(1) -> RST_IDLE2(2) -> IDLE(N) -> CALC_CONV(31*31) -> CALC_CONV_END(5) -> IDLE
/*
localparam RST_IDLE         = 16'h0000; //复位后的第一个状态 从rom中花一个周期读取bias 进入IDLE状态
localparam RST_IDLE2        = 16'h0000; //复位后的第一个状态 将bias放入bias寄存器 进入IDLE状态
localparam IDLE             = 16'h0010; //正常IDLE状态 等待layerenable指令 
localparam CALC_CONV        = 16'h0002; //计算31*31 卷积 
localparam CALC_CONV_END    = 16'h0020; //计算卷积完成 等待复位到pool的 rd_en
*/
localparam RST_IDLE         = "RST_1"; //复位后的第一个状态 从rom中花一个周期读取bias 进入IDLE状态
localparam RST_IDLE2        = "RST_2"; //复位后的第一个状态 将bias放入bias寄存器 进入IDLE状态
localparam IDLE             = "IDLE_"; //正常IDLE状态 等待layerenable指令 
localparam CALC_CONV        = "CCONV"; //计算31*31 卷积 
localparam CALC_CONV_END    = "CONVE"; //计算卷积完成 等待复位到pool的 rd_en


localparam  OUTPUT_DEALY_CNT = 6;

input clk;
input rst_n;
input layer_enable;
    
    //conv2d_1 数据输入信号
input img_data_wr_en;
input [DATA_WIDTH - 1: 0] img_data_in;
input [ADDR_WIDTH - 1: 0] img_data_addr;
    
    //conv2d_1 数据读取完成反馈
output reg img_data_rd_en;
    
    //输出到池化层的数据信号
output [KERNAL_NUM*DATA_WIDTH-1:0] pool_1_out_bus;
output reg pool_1_out_wr_en;
output reg [ADDR_WIDTH-1:0] pool_1_out_addr;

wire [7:0] addr_depth;
wire [DATA_WIDTH*KERNAL_ENEMENT_SZIE-1: 0] img_rd_addr_bus; //从databuf中取图片的地址
wire [DATA_WIDTH*KERNAL_ENEMENT_SZIE-1: 0] img_rd_data_bus; //从databuf中取图片的地址
wire [DATA_WIDTH*KERNAL_ENEMENT_SZIE*KERNAL_NUM-1: 0] kernal_data_bus; //从rom中取kernal数据的总线


reg [KERNAL_NUM*DATA_WIDTH-1:0] bias_data;  //bias data 存储
reg rom_addr; //kernal data bias data rom addr

reg [8*5-1:0] state; //main state
reg [15:0] state_cnt; // the cnt

reg conv_addr_gen_en;

//卷积地址生成器
ConvAddressGen_3D_NP conv_addr_gen_inst(
    .clk(clk),
    .rst_n(rst_n),  
    .enable(conv_addr_gen_en),
    .pause(0),
    .out_depth(addr_depth),
    .out_offset_NP(img_rd_addr_bus)
);

//输入数据池 存放原始35*35*1路标图片 
DoubleDataBuf #(
.DEPTH(FEATURE_MAP_ENEMENT_SZIE),
.WIDTH(DATA_WIDTH),
.ADDR_WIDTH(ADDR_WIDTH), //本项目中全部使用32位地址
.OUT_PORT_NUM(KERNAL_ENEMENT_SZIE) //输入地址和输出地址各有多少
) data_buf_img(
    .rst_n(rst_n),
    .clk(clk),
    .rd_en(img_data_rd_en),
    .rd_addr_NP(img_rd_addr_bus),
    .rd_data_NP(img_rd_data_bus), //输出端口为n个端口 入卷积核的输出是25个端口
    
    .wr_en(img_data_wr_en),
    .wr_addr_1P(img_data_addr),
    .wr_data_1P(img_data_in),
    
    .data_fill_cnt()
);


//第一层的 6个 5*5*1 卷积核
generate 
genvar j;
for (j = 0; j < KERNAL_NUM; j = j + 1)
begin
    ConvKernal inst(
        .clk(clk),
        .bias(bias_data[DATA_WIDTH*(j+1)-1:DATA_WIDTH*j]),
        .data_25P(img_rd_data_bus),
        .kernal_25P(kernal_data_bus[DATA_WIDTH*KERNAL_ENEMENT_SZIE*(j+1)-1: DATA_WIDTH*KERNAL_ENEMENT_SZIE*j]),
        .relu_out(pool_1_out_bus[DATA_WIDTH*(j+1)-1:DATA_WIDTH*j])
    );
end 
endgenerate 

//数据在第一个时钟的上升沿产生 
//bias 数据存储 
rom_conv1_kerbia_param keral_bias_inst(
  .clka(clk),    // input wire clka
  .addra(rom_addr),  // input wire [0 : 0] addra 0输出kernal的数据 1输出bias的数据
  .douta(kernal_data_bus)  // output wire [2399 : 0] douta 
);

//output 
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        state_cnt <= RST_IDLE;
        rom_addr <= 0;
        img_data_rd_en <= 0;
        pool_1_out_wr_en <= 0;
        pool_1_out_addr <= 0;
        conv_addr_gen_en <= 0;
        bias_data <= 0;
    end
    else
    begin
        case(state)
        RST_IDLE: begin
                    rom_addr <= 1'b1;       
                  end
        RST_IDLE2:begin
                    bias_data <= kernal_data_bus[DATA_WIDTH*KERNAL_NUM -1:0];
                    rom_addr <= 1'b0;                    
                  end 
        IDLE:begin 
            state_cnt <= 0;
            end
        CALC_CONV:begin 
            if (state_cnt < ANCHOR_ENEMENT_SZIE)
            begin
                conv_addr_gen_en <= 1;
                state_cnt <= state_cnt + 1;
                img_data_rd_en <= 1;
            end
            else
            begin 
                state_cnt <= 0;
                img_data_rd_en <= 0;
            end 
            
            if (state_cnt > OUTPUT_DEALY_CNT) //在数据开始输入卷积核后了N周期后数据开始产出
            begin
                pool_1_out_wr_en <= 1;
                pool_1_out_addr <= pool_1_out_addr + 1;
            end 
        end
        CALC_CONV_END:begin 
            if(state_cnt > OUTPUT_DEALY_CNT)  //在数据输入了N周期后数据开始产出
            begin 
                state_cnt <= 0;            
                pool_1_out_wr_en <= 0;
            end 
            else
            begin
                pool_1_out_addr <= pool_1_out_addr + 1;
            end 
            conv_addr_gen_en <= 0;
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
        RST_IDLE: state <= RST_IDLE2;
        RST_IDLE2: state <= IDLE;
        IDLE:
            if (layer_enable)
                state <= CALC_CONV;
        CALC_CONV:
            if (state_cnt >= ANCHOR_ENEMENT_SZIE)
                state <= CALC_CONV_END;
        CALC_CONV_END:
            if (!pool_1_out_wr_en)
                state <= IDLE;
        default:state <= RST_IDLE;
        endcase
    end 
end
endmodule 