module ZedPipline(
   rst_n,
   s_rst_n,
   clk,
   src_fifo_rd_en,
   src_fifo_dout,
   src_fifo_empty,
   src_fifo_data_count,
   
   dst_fifo_wr_en,
   dst_fifo_din,
   dst_fifo_full
);

input rst_n;
input s_rst_n;
input clk;

output src_fifo_rd_en;
input [31:0] src_fifo_dout;
input src_fifo_empty;
input src_fifo_data_count;

   
output dst_fifo_wr_en;
output [7:0]dst_fifo_din;
input dst_fifo_full;

reg [7: 0] state;

//地址相关信号
reg achor_addr_r; //中心锚点的一维偏移地址
wire [32 * 25 - 1: 0] buf_rd_addr_25P_w;//读取25口信号
reg addr_gen_en_r;

//写缓冲区使能
reg  wr_buf_en;

//hsv 输出端相关信号
wire [7:0] h_sync_w;
wire [7:0] s_sync_w;
wire [7:0] v_sync_w;
reg [7:0] h_sync_r;
reg [7:0] s_sync_r;
reg [7:0] v_sync_r;

//inrange 输出相关
wire [7:0] hsv_threshold_out_w; //hsv -> hsv_sync_reg 
reg [7:0] hsv_threshold_out_r; //hsv_sync_reg -> blur_fifo

//blur 输入输出相关
wire [8*25 - 1: 0]  blur_in_w;  //blur_fifo -> blur_combine_logic
wire [7:0]          blur_out_w; //blur_combine_logic -> blur_sync_reg
reg [7:0]           blur_out_r; //blur_sync_logic -> binary_combine_logic

//binary threshold 
wire [7:0]          binary_out_buf_w; //binary_combine_logic -> dligate_fifo

//dligate 输出输出相关
wire [8*25 - 1: 0]  dilate_in_w;  //dligate_fifo -> dilate_combine_logic
wire [7:0]          dilate_out_w; //dilate_combine_logic -> dilate_sync_reg
reg [7:0]           dilate_out_r; //dilate_sync_reg -> erode_fifo

//erode  输出输出相关
wire [8*25 - 1: 0]  erode_in_w;  //erode_fifo -> erode_combine_logic
wire [7:0]          erode_out_w; //erode_combine_logic -> erode_sync_reg
reg [7:0]           erode_out_r; //erode_sync_reg -> dst_fifo_din

//总体输入输出相关
wire [7:0] r_w;
wire [7:0] g_w;
wire [7:0] b_w;

PingPongDataBuf_1K BlurSrcBuf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(wr_buf_en),
    .rd_addr_25P(buf_rd_addr_25P_w),
    .din(hsv_threshold_out_r),
    .dout(blur_out_w),
    .wr_addr(achor_addr_r)
);

PingPongDataBuf_1K DilateSrcBuf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(wr_buf_en),
    .rd_addr_25P(buf_rd_addr_25P_w),
    .din(binary_out_buf_w),
    .dout(dilate_in_w),
    .wr_addr(achor_addr_r)
);

PingPongDataBuf_1K ErodeBuf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(wr_buf_en),
    .rd_addr_25P(buf_rd_addr_25P_w),
    .din(dilate_out_r),
    .dout(erode_in_w),
    .wr_addr(achor_addr_r)
);

AddrGen addr_gen_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(addr_gen_en_r),
    .addr_out_25P(buf_rd_addr_25P_w)
);

RGB2HSV rgb2hsv_inst(
    .rst_n(rst_n),
    .clk(clk),
    .din_r(r_w),
    .din_g(g_w),
    .din_b(b_w),
    .dout_h(h_sync_w),
    .dout_s(h_sync_s),
    .dout_v(h_sync_v)
);

HSV_Threshold hsv_threshold_inst(
    .dinH(h_sync_r),
    .dinS(s_sync_r),
    .dinV(v_sync_r),
    .dout(hsv_threshold_out_w)
);

BinaryThreshold binary_inst( 
    .din(blur_out_r),
    .dout(binary_out_buf_w)
);

MinValue25P min_25P_inst(
    .in25P(erode_in_w),
    .min_out(erode_out_w)
);

MaxValue25P max_25P_inst(
    .in25P(dilate_in_w),
    .max_out(dilate_out_w)
);

Blur25P blur_25P_inst(
    .in25P(blur_in_w),
    .blur_out(blur_out_w)
);

assign r_w = src_fifo_dout[7:0];   //R通道
assign g_w = src_fifo_dout[15:8];  //G通道
assign b_w = src_fifo_dout[23:16]; //B通道

assign dst_fifo_din = erode_out_r;

//sync signal block
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n || !s_rst_n)
    begin
        hsv_threshold_out_r <= 0;
        blur_out_r <= 0;
        dilate_out_r <= 0;
        erode_out_r <= 0;
        state <= 0;
        h_sync_r <= 0;
        s_sync_r <= 0;
        v_sync_r <= 0;
    end
    else
    begin
        hsv_threshold_out_r <= hsv_threshold_out_w;
        blur_out_r <= blur_out_w;
        dilate_out_r <= dilate_out_w;
        erode_out_r <= erode_out_w;
        h_sync_r <= h_sync_w;
        s_sync_r <= s_sync_w;
        v_sync_r <= v_sync_w;
    end 
end


endmodule