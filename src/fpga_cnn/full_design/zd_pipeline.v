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

parameter PROCESSS_DELAY_CYCLES = 3000;
parameter IMG_SIZE = 30 * 30;

parameter SRC_FIFO_RD_OFFSET    = 1000;
parameter BLUR_BUF_WE_OFFSET    = 1000;
parameter DLIGATE_BUF_WE_OFFSET = 1000;
parameter ERODE_BUF_WE_OFFSET   = 1000;
parameter DST_FIFO_WE_OFFSET    = 1000;

parameter BLUR_ADDR_GEN_OFFSET  = 1000;
parameter ERODE_ADDR_GEN_OFFSET = 1000;
parameter DLIATE_ADDR_GEN_OFFSET= 1000;

parameter D_SRC_FIFO_RD_OFFSET   = 1000;
parameter D_BLUR_BUF_WE_OFFSET   = 1000;
parameter D_DLIGATE_BUF_WE_OFFSET= 1000;
parameter D_ERODE_BUF_WE_OFFSET  = 1000;
parameter D_DST_FIFO_WE_OFFSET   = 1000;

parameter D_BLUR_ADDR_GEN_OFFSET  = 1000;
parameter D_ERODE_ADDR_GEN_OFFSET = 1000;
parameter D_DLIATE_ADDR_GEN_OFFSET= 1000;



input rst_n;
input s_rst_n;
input clk;

output reg src_fifo_rd_en;
input [31:0] src_fifo_dout;
input src_fifo_empty;
input src_fifo_data_count;

   
output reg dst_fifo_wr_en;
output [7:0] dst_fifo_din;
input dst_fifo_full;

//状态相关
reg [7: 0]  state_r;
reg [31: 0] output_clock_fifo_r [4: 0];
reg [31:0]  clock_cnt_r;

//地址相关信号
reg achor_addr_r; //中心锚点的一维偏移地址
wire [32 * 25 - 1: 0] buf_rd_addr_25P_w;//读取25口信号

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
wire [7:0]          binary_out_buf_w; //binary_combine_logic -> dilate_fifo

//dilate 输出输出相关
wire [8*25 - 1: 0]  dilate_in_w;  //dilate_fifo -> dilate_combine_logic
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

//地址生成相关
wire [7:0] blur_buf_anchor_addr;
wire [7:0] erode_buf_anchor_addr;
wire [7:0] dilate_buf_anchor_addr;

reg blur_addr_gen_en_r;
reg dilate_addr_gen_en_r;
reg erode_addr_gen_en_r;

reg blur_buf_wr_en;
reg dilate_buf_wr_en;
reg erode_buf_wr_en;

PingPongDataBuf_1K BlurSrcBuf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(blur_buf_wr_en),
    .rd_addr_25P(blur_buf_rd_addr_25P_w),
    .din(hsv_threshold_out_r),
    .dout(blur_in_w),
    .wr_addr(blur_buf_anchor_addr)
);

PingPongDataBuf_1K DliateSrcBuf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(dilate_buf_wr_en),
    .rd_addr_25P(dilate_buf_rd_addr_25P_w),
    .din(binary_out_buf_w),
    .dout(dilate_in_w),
    .wr_addr(dilate_buf_anchor_addr)
);

PingPongDataBuf_1K ErodeBuf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(erode_buf_wr_en),
    .rd_addr_25P(erode_buf_rd_addr_25P_w),
    .din(dilate_out_r),
    .dout(erode_in_w),
    .wr_addr(erode_buf_anchor_addr)
);

AddrGen addr_gen_4_blur_buf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(blur_addr_gen_en_r),
    .addr_out_25P(blur_buf_rd_addr_25P_w),
    .anchor_addr(blur_buf_anchor_addr)
);

AddrGen addr_gen_4_dilate_buf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(dilate_addr_gen_en_r),
    .addr_out_25P(dilate_buf_rd_addr_25P_w),
    .anchor_addr(dilate_buf_anchor_addr)
);

AddrGen addr_gen_4_erode_buf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(erode_addr_gen_en_r),
    .addr_out_25P(erode_buf_rd_addr_25P_w),
    .anchor_addr(erode_buf_anchor_addr)
);

RGB2HSV rgb2hsv_inst(
    .rst_n(rst_n),
    .clk(clk),
    .din_r(r_w),
    .din_g(g_w),
    .din_b(b_w),
    .dout_h(h_sync_w),
    .dout_s(s_sync_w),
    .dout_v(v_sync_w)
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

//clock blk

reg clk_pulse;
reg [31:0] clock_cnt_r;
reg [31:0] dst_write_pulse_r;

always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
    begin
        clock_cnt_r <= 0;  
        clk_pulse <= 0;        
    end
    else
    begin
        if (clock_cnt_r == ((32'd1024 << 10) - 1))
        begin
            clock_cnt_r <= 0;
            clk_pulse <= 1;
        end
        else
        begin 
            clk_pulse <= 0;
            clock_cnt_r <= clock_cnt_r + 1;
        end
    end
end

//fifo buf 读取 状态机写入控制
//操作所有 buf fifo 使能 地址生成 有关信号
reg [31:0] src_fifo_re_timer_fifo [7:0];
reg [31:0] blur_buf_we_timer_fifo [7:0];
reg [31:0] dilate_buf_we_timer_fifo [7:0];
reg [31:0] erode_buf_we_timer_fifo [7:0];
reg [31:0] dst_fifo_we_timer_fifo [7:0];

reg [2:0] src_fifo_re_timer_fifo_rd_idx;
reg [2:0] blur_buf_we_timer_fifo_rd_idx;
reg [2:0] dilate_buf_we_timer_fifo_rd_idx;
reg [2:0] erode_buf_we_timer_fifo_rd_idx;
reg [2:0] dst_fifo_we_timer_fifo_rd_idx;

reg [2:0] src_fifo_re_timer_fifo_wr_idx;
reg [2:0] blur_buf_we_timer_fifo_wr_idx;
reg [2:0] dilate_buf_we_timer_fifo_wr_idx;
reg [2:0] erode_buf_we_timer_fifo_wr_idx;
reg [2:0] dst_fifo_we_timer_fifo_wr_idx;

reg [31:0] blur_buf_addr_gen_en_fifo [7:0];
reg [31:0] dilate_buf_addr_gen_en_fifo [7:0];
reg [31:0] erode_buf_addr_gen_en_fifo [7:0];

reg [2:0] blur_buf_addr_gen_en_fifo_rd_idx;
reg [2:0] dilate_buf_addr_gen_en_fifo_rd_idx;
reg [2:0] erode_buf_addr_gen_en_fifo_rd_idx;

reg [2:0] blur_buf_addr_gen_en_fifo_wr_idx;
reg [2:0] dilate_buf_addr_gen_en_fifo_wr_idx;
reg [2:0] erode_buf_addr_gen_en_fifo_wr_idx;

//去使能信号相关
reg [31:0] d_src_fifo_re_timer_fifo [7:0];
reg [31:0] d_blur_buf_we_timer_fifo [7:0];
reg [31:0] d_dilate_buf_we_timer_fifo [7:0];
reg [31:0] d_erode_buf_we_timer_fifo [7:0];
reg [31:0] d_dst_fifo_we_timer_fifo [7:0];

reg [2:0] d_src_fifo_re_timer_fifo_rd_idx;
reg [2:0] d_blur_buf_we_timer_fifo_rd_idx;
reg [2:0] d_dilate_buf_we_timer_fifo_rd_idx;
reg [2:0] d_erode_buf_we_timer_fifo_rd_idx;
reg [2:0] d_dst_fifo_we_timer_fifo_rd_idx;

reg [2:0] d_src_fifo_re_timer_fifo_wr_idx;
reg [2:0] d_blur_buf_we_timer_fifo_wr_idx;
reg [2:0] d_dilate_buf_we_timer_fifo_wr_idx;
reg [2:0] d_erode_buf_we_timer_fifo_wr_idx;
reg [2:0] d_dst_fifo_we_timer_fifo_wr_idx;

reg [31:0] d_blur_buf_addr_gen_en_fifo [7:0];
reg [31:0] d_dilate_buf_addr_gen_en_fifo [7:0];
reg [31:0] d_erode_buf_addr_gen_en_fifo [7:0];

reg [2:0] d_blur_buf_addr_gen_en_fifo_rd_idx;
reg [2:0] d_dilate_buf_addr_gen_en_fifo_rd_idx;
reg [2:0] d_erode_buf_addr_gen_en_fifo_rd_idx;

reg [2:0] d_blur_buf_addr_gen_en_fifo_wr_idx;
reg [2:0] d_dilate_buf_addr_gen_en_fifo_wr_idx;
reg [2:0] d_erode_buf_addr_gen_en_fifo_wr_idx;

assign fifo_read_ready = !src_fifo_rd_en && clk_pulse && src_fifo_data_count >= IMG_SIZE && !dst_fifo_full;

always @(posedge clk) 
begin

    if (clk_pulse && fifo_read_ready)
    begin
        //在起始时 就要装载所有写入信号的偏移 加法自动溢出
        src_fifo_re_timer_fifo[src_fifo_re_timer_fifo_wr_idx]      <= clock_cnt_r + SRC_FIFO_RD_OFFSET;
        blur_buf_we_timer_fifo[blur_buf_we_timer_fifo_wr_idx]      <= clock_cnt_r + BLUR_BUF_WE_OFFSET;
        dilate_buf_we_timer_fifo[dilate_buf_we_timer_fifo_wr_idx] <= clock_cnt_r + DLIGATE_BUF_WE_OFFSET;
        erode_buf_we_timer_fifo[erode_buf_we_timer_fifo_wr_idx]    <= clock_cnt_r + ERODE_BUF_WE_OFFSET;
        dst_fifo_we_timer_fifo[dst_fifo_we_timer_fifo_wr_idx]      <= clock_cnt_r + DST_FIFO_WE_OFFSET;
        
        src_fifo_re_timer_fifo_wr_idx   <= src_fifo_re_timer_fifo_wr_idx   + 1;
        blur_buf_we_timer_fifo_wr_idx   <= blur_buf_we_timer_fifo_wr_idx   + 1;
        dilate_buf_we_timer_fifo_wr_idx <= dilate_buf_we_timer_fifo_wr_idx + 1;
        erode_buf_we_timer_fifo_wr_idx  <= erode_buf_we_timer_fifo_wr_idx  + 1;
        dst_fifo_we_timer_fifo_wr_idx   <= dst_fifo_we_timer_fifo_wr_idx   + 1;
        
        blur_buf_addr_gen_en_fifo[blur_buf_addr_gen_en_fifo_wr_idx]         <= clock_cnt_r + BLUR_ADDR_GEN_OFFSET;
        erode_buf_addr_gen_en_fifo[erode_buf_addr_gen_en_fifo_wr_idx]       <= clock_cnt_r + ERODE_ADDR_GEN_OFFSET;
        dilate_buf_addr_gen_en_fifo[dilate_buf_addr_gen_en_fifo_wr_idx]     <= clock_cnt_r + DLIATE_ADDR_GEN_OFFSET;
        
        d_src_fifo_re_timer_fifo[d_src_fifo_re_timer_fifo_wr_idx]      <= clock_cnt_r + D_SRC_FIFO_RD_OFFSET;
        d_blur_buf_we_timer_fifo[d_blur_buf_we_timer_fifo_wr_idx]      <= clock_cnt_r + D_BLUR_BUF_WE_OFFSET;
        d_dilate_buf_we_timer_fifo[d_dilate_buf_we_timer_fifo_wr_idx] <= clock_cnt_r + D_DLIGATE_BUF_WE_OFFSET;
        d_erode_buf_we_timer_fifo[d_erode_buf_we_timer_fifo_wr_idx]    <= clock_cnt_r + D_ERODE_BUF_WE_OFFSET;
        d_dst_fifo_we_timer_fifo[d_dst_fifo_we_timer_fifo_wr_idx]      <= clock_cnt_r + D_DST_FIFO_WE_OFFSET;
        
        d_src_fifo_re_timer_fifo_wr_idx   <= d_src_fifo_re_timer_fifo_wr_idx   + 1;
        d_blur_buf_we_timer_fifo_wr_idx   <= d_blur_buf_we_timer_fifo_wr_idx   + 1;
        d_dilate_buf_we_timer_fifo_wr_idx <= d_dilate_buf_we_timer_fifo_wr_idx + 1;
        d_erode_buf_we_timer_fifo_wr_idx  <= d_erode_buf_we_timer_fifo_wr_idx  + 1;
        d_dst_fifo_we_timer_fifo_wr_idx   <= d_dst_fifo_we_timer_fifo_wr_idx   + 1;
        
        d_blur_buf_addr_gen_en_fifo[d_blur_buf_addr_gen_en_fifo_wr_idx]         <= clock_cnt_r + D_BLUR_ADDR_GEN_OFFSET;
        d_erode_buf_addr_gen_en_fifo[d_erode_buf_addr_gen_en_fifo_wr_idx]       <= clock_cnt_r + D_ERODE_ADDR_GEN_OFFSET;
        d_dilate_buf_addr_gen_en_fifo[d_dilate_buf_addr_gen_en_fifo_wr_idx]     <= clock_cnt_r + D_DLIATE_ADDR_GEN_OFFSET;
        
    end
end

always @(posedge clk) 
begin
    if(!rst_n)
    begin
      
    end
    else
    begin
        if (clock_cnt_r == src_fifo_re_timer_fifo[src_fifo_re_timer_fifo_rd_idx])
        begin
            src_fifo_re_timer_fifo_rd_idx <= src_fifo_re_timer_fifo_rd_idx + 1;
            src_fifo_rd_en <= 1;
        end 
        else if (clock_cnt_r == d_src_fifo_re_timer_fifo[d_src_fifo_re_timer_fifo_rd_idx])
        begin
            d_src_fifo_re_timer_fifo_rd_idx <= d_src_fifo_re_timer_fifo_rd_idx + 1;
            src_fifo_rd_en <= 0;
        end 
        
        if (clock_cnt_r == blur_buf_we_timer_fifo[blur_buf_we_timer_fifo_rd_idx])
        begin
            blur_buf_we_timer_fifo_rd_idx <= blur_buf_we_timer_fifo_rd_idx + 1;
            blur_buf_wr_en <= 1;
        end 
        else if (clock_cnt_r == d_blur_buf_we_timer_fifo[d_blur_buf_we_timer_fifo_rd_idx])
        begin
            d_blur_buf_we_timer_fifo_rd_idx <= d_blur_buf_we_timer_fifo_rd_idx + 1;
            blur_buf_wr_en <= 0;
        end 
        
        if (clock_cnt_r == dilate_buf_we_timer_fifo[dilate_buf_we_timer_fifo_rd_idx])
        begin
            dilate_buf_we_timer_fifo_rd_idx <= dilate_buf_we_timer_fifo_rd_idx + 1;
            dilate_buf_wr_en <= 1;
        end 
        else if (clock_cnt_r == d_dilate_buf_we_timer_fifo[d_dilate_buf_we_timer_fifo_rd_idx])
        begin
            d_dilate_buf_we_timer_fifo_rd_idx <= d_dilate_buf_we_timer_fifo_rd_idx + 1;
            dilate_buf_wr_en <= 0;
        end 
        
        if (clock_cnt_r == erode_buf_we_timer_fifo[erode_buf_we_timer_fifo_rd_idx])
        begin
            erode_buf_we_timer_fifo_rd_idx <= erode_buf_we_timer_fifo_rd_idx + 1;
            erode_buf_wr_en <= 1;
        end 
        else if (clock_cnt_r == erode_buf_we_timer_fifo[erode_buf_we_timer_fifo_rd_idx])
        begin
            d_erode_buf_we_timer_fifo_rd_idx <= d_erode_buf_we_timer_fifo_rd_idx + 1;
            erode_buf_wr_en <= 0;
        end 
        
        if (clock_cnt_r == dst_fifo_we_timer_fifo[dst_fifo_we_timer_fifo_rd_idx])
        begin
            dst_fifo_we_timer_fifo_rd_idx <= dst_fifo_we_timer_fifo_rd_idx + 1;
            dst_fifo_wr_en <= 1;
        end 
        else if (clock_cnt_r == d_dst_fifo_we_timer_fifo[d_dst_fifo_we_timer_fifo_rd_idx])
        begin
            d_dst_fifo_we_timer_fifo_rd_idx <= d_dst_fifo_we_timer_fifo_rd_idx + 1;
            dst_fifo_wr_en <= 0;
        end 
        
        if (clock_cnt_r == blur_buf_addr_gen_en_fifo[blur_buf_addr_gen_en_fifo_rd_idx])
        begin
            blur_buf_addr_gen_en_fifo_rd_idx <= blur_buf_addr_gen_en_fifo_rd_idx + 1;
            blur_addr_gen_en_r <= 1;
        end 
        else if (clock_cnt_r == d_blur_buf_addr_gen_en_fifo[d_blur_buf_addr_gen_en_fifo_rd_idx])
        begin
            d_blur_buf_addr_gen_en_fifo_rd_idx <= d_blur_buf_addr_gen_en_fifo_rd_idx + 1;
            blur_addr_gen_en_r <= 0;
        end 
        
        if (clock_cnt_r == dilate_buf_addr_gen_en_fifo[dilate_buf_addr_gen_en_fifo_rd_idx])
        begin
            dilate_buf_addr_gen_en_fifo_rd_idx <= dilate_buf_addr_gen_en_fifo_rd_idx + 1;
            dilate_addr_gen_en_r <= 1;
        end 
        else if (clock_cnt_r == d_dilate_buf_addr_gen_en_fifo[d_dilate_buf_addr_gen_en_fifo_rd_idx])
        begin
            d_dilate_buf_addr_gen_en_fifo_rd_idx <= d_dilate_buf_addr_gen_en_fifo_rd_idx + 1;
            dilate_addr_gen_en_r <= 0;
        end 
        
        if (clock_cnt_r == erode_buf_addr_gen_en_fifo[erode_buf_addr_gen_en_fifo_rd_idx])
        begin
            erode_buf_addr_gen_en_fifo_rd_idx <= erode_buf_addr_gen_en_fifo_rd_idx + 1;
            erode_addr_gen_en_r <= 1;
        end 
        else if (clock_cnt_r == d_erode_buf_addr_gen_en_fifo[d_erode_buf_addr_gen_en_fifo_rd_idx])
        begin
            d_erode_buf_addr_gen_en_fifo_rd_idx <= d_erode_buf_addr_gen_en_fifo_rd_idx + 1;
            erode_addr_gen_en_r <= 0;
        end 
    end
end

endmodule