module C1S2_layer(

clk,
rst_n,

en,
work_finished,

rd_data_in_5P,
rd_addr_out_5P,

wr_addr_out_1P,
wr_data_out_1P,

wr_out_en 
);

parameter FIN_ROM_ADDR = 900;
parameter KERNEL_NUM = 6;

//尽量使用局部状态机
parameter IDLE = "IDLE";//31'h0; 
parameter RUNNING = "RUNNING";//31'h1; 
parameter FINISHED = "FINISHED";//31'h2; 

input  clk;
input  rst_n;

input  en;
output reg work_finished;

//读取缓存相关
input  [5*16-1:0] rd_data_in_5P;
output [5*32-1:0] rd_addr_out_5P;

//外部缓存输出
output reg [31: 0] wr_addr_out_1P;
output reg [15: 0] wr_data_out_1P;
output reg wr_out_en;


//reg [31:0] main_state;
reg [8*8-1:0] main_state;

//anchor rom 相关
reg  [31:0] anchor_perido_cnt;
reg  [31:0] anchor_rom_addr;
wire [31:0] anchor_addr;
reg  anchor_rom_en;
wire anchor_rom_output_valid;

//输出读取地址相关
wire [25*32 - 1 : 0] addr_out_25P_w;
reg  [5*32-1: 0] addr_out_5P_r [4: 0];
reg  [3:0] addr_out_idx;

//读入数据相关
reg  data_in_ready;
reg  [2:0] data_in_idx;

//25 word数据准备缓冲 以及数据分配逻辑
reg data_buf25_switch;
reg  [16*5-1:  0] data_buf25_0_r [4:0];
reg  [16*5-1:  0] data_buf25_1_r [4:0];
wire [16*25-1: 0] data_buf25_0_w;
wire [16*25-1: 0] data_buf25_1_w;
wire [16*25-1: 0] data_buf25;
wire [15: 0] inner_product_out; 
wire [15: 0] relu_out;
reg  data_buf25_ready;

//kernel bias_idx
reg [7:0] kernel_bias_idx; //选择对应的kernel和bias
wire [16*25-1: 0] kernel_out;
wire [15: 0] bias_out;
reg kernel_calculating;
wire kernel_calculating_delay; //和数据在计算元件中流动的速度一致
wire relu_out_valid;//同上

//pool buffers[]
reg  [7: 0]  pool_buffer_idx; //记录是哪个kernel的poolBuffer
reg  [7: 0]  pool_buffer_cnt [3:0]; //记录某个kernel的pool buffer中被填充了第几个数字
reg  [16 * 4 - 1: 0] pool_buffer_mem [3:0]; //暂时存储pool数据的 
wire [16*KERNEL_NUM-1: 0] pool_out;
reg  pool_out_valid;

//输出逻辑控制
reg wr_out_en_r;
wire [31 : 0] kernel_offset;
reg [3:0] pool_out_kernel_idx;

assign wr_out_en = wr_out_en_r;
assign anchor_addr[31:16] = 0;
c1s2_layer_anchor_rom c1s2_anchor_rom (
  .clka(clk),    // input wire clka
  .addra(anchor_rom_addr),  // input wire [9 : 0] addra
  .douta(anchor_addr)  // output wire [15 : 0] douta
);

assign data_buf25_0_w = {data_buf25_0_r[4], data_buf25_0_r[3], data_buf25_0_r[2], data_buf25_0_r[1], data_buf25_0_r[0]};
assign data_buf25_1_w = {data_buf25_1_r[4], data_buf25_1_r[3], data_buf25_1_r[2], data_buf25_1_r[1], data_buf25_1_r[0]};

assign data_buf25 = data_buf25_switch == 0 ? data_buf25_0_w : data_buf25_1_w;

AddrGen #(.H_IMAGE_LEN(35), .V_IMAGE_LEN(35)) addr_gen_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(en),
    .pause(0),
    .addr_out_25P(addr_out_25P_w),
    .anchor_addr_in(anchor_addr)
);

//delay 6 cycles 
//inner_product and relu 
assign relu_out = inner_product_out[15] == 0 ? inner_product_out : 0;
InnerProduct_25P inner_product_inst(
    .clk(clk),
    .bias(bias_out),
    .in_vecA_25P(kernel_out),
    .in_vecB_25P(data_buf25),
    .out_1P(inner_product_out)
);

C1_bias C1_bias_inst (
  .clka(clk),    // input wire clka
  .addra(kernel_bias_idx),  // input wire [2 : 0] addra
  .douta(bias_out)  // output wire [15 : 0] douta
);

C1_kernal C1_Kernel_inst(
  .clka(clk),    // input wire clka
  .addra(kernel_bias_idx),  // input wire [2 : 0] addra
  .douta(kernel_out)  // output wire [399 : 0] douta
);

//延迟信号和计算值流动的一致
Delay #(.WIDTH(16), .DELAY_CYCLE(6)) Delay_instx( 
    .clk(clk),
    .din(kernel_calculating),
    .dout(kernel_calculating_delay)    
);


genvar pool_inst_idx;
generate
for (pool_inst_idx = 0; pool_inst_idx < KERNEL_NUM; pool_inst_idx = pool_inst_idx + 1)
MaxValue4P #(.WIDTH(16)) max_pool_inst(
    .in4P(pool_buffer_mem[pool_inst_idx]),
    .max_out(pool_out[16*(pool_inst_idx + 1) - 1: 16*pool_inst_idx])
);
endgenerate

//选择对应Kernel的pool out
MUX10_1 #(.WIDTH(16)) mux_inst(
    .select(pool_out_kernel_idx),
    .output_data(wr_addr_out_1P),
    .in_00(pool_out[16*(1 + 1) - 1: 16*0]),
    .in_01(pool_out[16*(2 + 1) - 1: 16*1]),
    .in_02(pool_out[16*(3 + 1) - 1: 16*2]),
    .in_03(pool_out[16*(4 + 1) - 1: 16*3]),
    .in_04(pool_out[16*(5 + 1) - 1: 16*4]),
    .in_05(pool_out[16*(6 + 1) - 1: 16*5]),
    .in_06(0),
    .in_07(0),
    .in_08(0),
    .in_09(0)
);

//anchor rom 控制块
always @(posedge clk)
begin
    if (anchor_rom_en)
    begin
        if (anchor_perido_cnt == 5)
        begin
           anchor_perido_cnt <= 0;
           anchor_rom_addr <= anchor_rom_addr + 1;
        end
        else
        begin
           anchor_perido_cnt <= anchor_perido_cnt + 1;        
        end
    end
    else
    begin
        anchor_perido_cnt <= 0;
        anchor_rom_addr <= 0;
    end 
end

//读取地址分发
assign anchor_rom_output_valid = anchor_perido_cnt == 1;
assign  rd_addr_out_5P = addr_out_5P_r[addr_out_idx];
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin 
    
    end
    else
    begin 
        if (anchor_rom_output_valid)
        begin
            addr_out_idx <= 0;
            {addr_out_5P_r[4], addr_out_5P_r[3], addr_out_5P_r[2], addr_out_5P_r[1], addr_out_5P_r[0]} <= addr_out_25P_w;
            data_in_ready <= 1; //只出现一个时钟周期
        end
        else
        begin
            if (addr_out_idx == 4)
            begin
                addr_out_idx <= 0;
                data_in_ready <= 0;
            end
            else
            begin 
                addr_out_idx <= addr_out_idx + 1;
            end
        end
    end 
end

//读取数据拼装逻辑 将1x5的读取数据拼装成5x5的数据
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
       data_in_idx <= 0;
       data_buf25_ready <= 0;
       data_buf25_switch <= 0;
    end
    else
    begin
        if (data_in_ready)
        begin
           if (data_buf25_switch)
           begin
                data_buf25_1_r[data_in_idx] <= rd_data_in_5P;
                data_in_idx <= data_in_idx + 1;
           end
           else
           begin
                data_buf25_0_r[data_in_idx] <= rd_data_in_5P;
                data_in_idx <= data_in_idx + 1;
           end
           
           if (data_in_idx == 4)
           begin
               data_buf25_ready <= 1;
               data_buf25_switch <= ~data_buf25_switch; //翻转数据选择
           end
        end
        else
            data_in_idx <= 0;
    end
end

//kernel bias 切换逻辑
//kernel_calculating 为高表示 数据下个周期已经进入到了加法器和乘法器中 
//kernel_calculating 变低表示当前数据总线上的数据是无效的
always @(posedge clk or negedge rst_n)
begin 
    if(!rst_n)
    begin
        kernel_calculating <= 0;
        kernel_bias_idx <= 0;
    end
    else
    begin
        if(data_buf25_ready && kernel_calculating == 0)
        begin
            kernel_calculating <= 1;
        end 
        
        if (kernel_calculating)
        begin
            kernel_bias_idx <= kernel_bias_idx + 1;
            if (kernel_bias_idx == KERNEL_NUM-1)
                kernel_calculating <= 0;
        end        
    end 
end

//pool 数据缓存逻辑
assign relu_out_valid = kernel_calculating_delay;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        pool_buffer_idx <= 0;
        pool_out_valid <= 0;
        integer k0;
        for (k0 = 0; k0 < KERNEL_NUM; k0 = k0 + 1)
        begin
            pool_buffer_mem[k0] <= 0;
            pool_buffer_cnt[k0] <= 0;
        end
    end 
    else
    begin
        if (relu_out_valid)
        begin
            pool_buffer_mem[pool_buffer_idx][15:0] <= relu_out;
            //使用移位的方式逐渐填充对应kernel的 pool buffer
            pool_buffer_mem[pool_buffer_idx][31: 16] <= pool_buffer_mem[pool_buffer_idx][15:0];
            pool_buffer_mem[pool_buffer_idx][47: 32] <= pool_buffer_mem[pool_buffer_idx][31:16];
            pool_buffer_mem[pool_buffer_idx][63: 48] <= pool_buffer_mem[pool_buffer_idx][47:32];
            pool_buffer_cnt[pool_buffer_idx] <= pool_buffer_cnt[pool_buffer_idx] + 1;
            pool_buffer_idx <= pool_buffer_idx + 1;
            
            if (pool_buffer_cnt[0] == 4)
            begin
                pool_out_valid <= 1;
            end
            else if (pool_buffer_cnt[KERNEL_NUM - 1] == 4)
            begin
                pool_out_valid <= 0;
            end
        end 
        else
        begin
            pool_buffer_idx <= 0;
            integer k0;
            for (k0 = 0; k0 < KERNEL_NUM; k0 = k0 + 1)
            begin
                pool_buffer_mem[k0] <= 0;
            end
        begin
    end 
end 


//输出控制逻辑
//genvar pool_out_inst_idx
assign kernel_offset = pool_out_idx * RES_KERNEL_OFFSET; //RES_KERNEL_OFFSET 是2的幂
always @(posedge clk or negedge rst_n)
begin 
    if (!rst_n)
    begin
        
    end
    else
    begin
        if (en)
        begin 
            if(pool_out_valid)
            begin
                wr_out_en <= 1;
                wr_addr_out_1P <= anchor_out_addr + kernel_offset; //anchor_out_addr 在二维图像上对应的一维坐标 kernel_offser 第三位在一维上对应的偏移
                if (pool_out_kernel_idx == KERNEL_NUM-1)
                begin
                    anchor_out_addr <= anchor_out_addr + 1;
                    pool_out_kernel_idx <= 0;
                end
                else
                begin
                    pool_out_kernel_idx <= pool_out_kernel_idx + 1;
                end
            end 
            else
            begin
                wr_out_en <= 0;
                pool_out_kernel_idx <= 0;
            end 
        end
        else
        begin
            anchor_out_addr <= 0;
        end 
    end
end 

//main_state
always @(posedge clk or negedge rst_n)
begin
   if(!rst_n)
   begin
       wr_out_en_r <= 0;
       main_state <= IDLE;
       anchor_rom_en <=0 ;
   end
   else
   begin
       //状态转移与输出全部写在此处
       case (main_state)
       IDLE:
       begin
           if (en)
           begin
              main_state <= RUNNING;
              anchor_rom_en <= 1;
           end
           else
           begin 
              main_state <= IDLE;
           end
           work_finished <= 0;
       end
       RUNNING:
       begin 
           if (anchor_rom_addr < FIN_ROM_ADDR)
           begin
              main_state <= RUNNING;
           end
           else
           begin
              main_state <= FINISHED;
           end    
       end           
       FINISHED:
       begin 
           main_state <= IDLE;
           wr_out_en_r <= 0;
           work_finished <= 1;
           anchor_rom_en <= 0;
       end
       default: main_state <= IDLE;
       endcase
   end 
end
endmodule 