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
    .we(blur_buf_wr_en),
    .rd_addr_25P(blur_buf_rd_addr_25P_w),
    .din(hsv_threshold_out_r),
    .dout(blur_out_w),
    .wr_addr(achor_addr_r)
);

PingPongDataBuf_1K DilateSrcBuf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(wr_buf_en),
    .rd_addr_25P(dilate_buf_rd_addr_25P_w),
    .din(binary_out_buf_w),
    .dout(dilate_in_w),
    .wr_addr(achor_addr_r)
);

PingPongDataBuf_1K ErodeBuf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .we(wr_buf_en),
    .rd_addr_25P(erode_buf_rd_addr_25P_w),
    .din(dilate_out_r),
    .dout(erode_in_w),
    .wr_addr(achor_addr_r)
);

AddrGen addr_gen_4_blur_buf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(blur_addr_gen_en_r),
    .addr_out_25P(blur_buf_rd_addr_25P_w)
);

AddrGen addr_gen_4_dilate_buf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(dilate_addr_gen_en_r),
    .addr_out_25P(dilate_buf_rd_addr_25P_w)
);

AddrGen addr_gen_4_erode_buf_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(erode_addr_gen_en_r),
    .addr_out_25P(erode_buf_rd_addr_25P_w)
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

//clock blk

reg clk_pulse;
reg [31:0] clock_cnt_r;
reg [31:0] dst_write_pulse_r;
reg [] write_pulse_fifo_r [5:0]
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

reg [31: 0] blur_wr_running_timer;
reg [31: 0] dligate_wr_start_timer;
reg [31: 0] erode_wr_start_timer;
reg [31: 0] dst_fifo_wr_start_timer;

reg [31: 0] blur_wr_wait_timer;
reg [31: 0] dligate_wr_wait_timer;
reg [31: 0] erode_wr_wait_timer;
reg [31: 0] dst_fifo_wr_wait_timer;

reg blur_wr_wait_flag;
reg dligate_wr_wait_flag;
reg erode_wr_wait_flag;
reg dst_fifo_wr_wait_flag;

reg blur_wr_running_flag;
reg dligate_wr_running_flag;
reg erode_wr_running_flag;
reg dst_fifo_wr_running_flag;

assign fifo_read_idle = (!src_fifo_rd_en && src_fifo_data_count < IMG_SIZE) || (fifo_read_idle_timer <= IDLE_CYCLE);
assign fifo_read_ready = !src_fifo_rd_en && clk_pulse && src_fifo_data_count >= IMG_SIZE && !dst_fifo_full;
assign fifo_read_running = src_fifo_rd_en && fifo_read_cnt_r < IMG_SIZE;
assign fifo_read_finished = src_fifo_rd_en && fifo_read_cnt_r >= IMG_SIZE;


//每个部分都有两套系统 一套waiting系统用于监控上一阶段的写入 另一套对本套进行运算 写入下一级

always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
    begin
        
    end
    else
    begin
        //在时间片起始处 1fifo 没有在读取 
        if (fifo_read_idle)
        begin
            if (fifo_read_idle_timer >= IDLE_CYCLE)
                fifo_read_idle_timer <= fifo_read_idle_timer;
            else
                fifo_read_idle_timer <= fifo_read_idle_timer + 1;        
        end
        
        if(fifo_read_ready)
        begin
            src_fifo_rd_en <= 1;
            src_fifo_rd_cnt_r <= 0;
            blur_addr_gen_en_r <= 1;
            blur_buf_wr_en <= 1;
        end 
        else if (fifo_read_running)
        begin
            src_fifo_rd_cnt_r <= src_fifo_rd_cnt_r + 1; 
        end
        else if (fifo_read_finished)
        begin
            src_fifo_rd_cnt_r <= 0;
            src_fifo_rd_en <= 0;
        end        
        
       
        
        
    end
end 

//blur process block
//idle->triggered->waiting->finished->idle
assign blur_idle = !blur_wr_wait_flag && !blur_wr_running_flag;
assign blur_waiting_ready = fifo_read_ready;
assign blur_waiting = blur_wr_wait_flag && blur_wr_wait_timer < BLUR_WAIT_CYCLE;
assign blur_waiting_finished = blur_wr_wait_flag && blur_wr_wait_timer == BLUR_WAIT_CYCLE;

//idle->triggered(blur_waiting_finished)
assign blur_running = blur_wr_running_flag && blur_wr_running_timer < BLUR_STRAT_CYCLE;
assign blur_running_finished = blur_wr_running_flag && blur_wr_running_timer == BLUR_STRAT_CYCLE;

always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
    begin
        
    end
    else
    begin
       //非互斥信号
        if (fifo_read_ready)
            blur_wr_wait_flag <= 1;
        else if (blur_waiting)
            blur_wr_wait_timer <= blur_wr_wait_timer + 1;
        else if (blur_waiting_finished)
        begin
            blur_wr_wait_flag <= 0;
            blur_wr_wait_timer <= 0;
        end
        
        //waiting 和running区分开
      
        
        if (blur_waiting_finished)
        begin
            blur_wr_running_flag <= 1;
            blur_addr_gen_en_r <= 1;
            blur_wr_running_timer <= 0;
        end
        else if (blur_running)
        begin
            blur_wr_running_timer <= blur_wr_running_timer + 1;      
        end
        else if(blur_running_finished)
        begin
            blur_wr_running_timer <= 0;
        end
    end
end 



endmodule