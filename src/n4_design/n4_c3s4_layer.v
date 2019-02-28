module C3S4_layer(

clk,
rst_n,

en,
work_finished,

rd_data_in_5P_0,
rd_data_in_5P_1,
rd_data_in_5P_2,
rd_data_in_5P_3,
rd_data_in_5P_4,
rd_data_in_5P_5,

rd_addr_out_5P,

wr_addr_out_1P,
wr_data_out_1P,

wr_out_en 
);

parameter FIN_ROM_ADDR = 25; //10x10
parameter KERNEL_NUM = 16;
parameter FEATURE_MAP_NUM = 6;
parameter RES_KERNEL_OFFSET = 25; //输出的featuremap对应的 内存段偏移
parameter OUTPUT_FIN_ROM_ADDR = 25; //5x5

//尽量使用局部状态机
parameter INIT = "INIT";
parameter IDLE = "IDLE";//31'h0; 
parameter RUNNING = "RUNNING";//31'h1; 
parameter STALL = "STALL";//31'h2; 
parameter FINISHED = "FINISHED";//31'h2; 

input  clk;
input  rst_n;

input  en;
output reg work_finished;

//读取缓存相关
input  [5*16-1:0] rd_data_in_5P_0;
input  [5*16-1:0] rd_data_in_5P_1;
input  [5*16-1:0] rd_data_in_5P_2;
input  [5*16-1:0] rd_data_in_5P_3;
input  [5*16-1:0] rd_data_in_5P_4;
input  [5*16-1:0] rd_data_in_5P_5;
output [5*32-1:0] rd_addr_out_5P;

//外部缓存输出
output [31: 0] wr_addr_out_1P;
output [15: 0] wr_data_out_1P;
output wr_out_en;


//reg [31:0] main_state;
reg [8*8-1:0] main_state;

//初始化RAM所用
reg init_en;
reg init_fin;
reg [7:0] kernel_ram_addr;        // input wire [8 : 0] a
wire [7:0] kernel_ram_addr_delayed;        // input wire [8 : 0] a
wire [25*16-1:0] kernel_ram_data;
reg [7:0] kernel_init_idx; //原始 kernel 使用的索引
reg [FEATURE_MAP_NUM-1: 0] kernel_inst_we;
wire [FEATURE_MAP_NUM-1: 0] kernel_inst_we_ready;
//
wire [5*16-1:0] rd_data_in_5P [FEATURE_MAP_NUM-1: 0];


//anchor rom 相关
reg  [31:0] anchor_perido_cnt;
reg  [31:0] anchor_rom_addr;
wire [31:0] anchor_addr;
reg  anchor_rom_en;
wire anchor_rom_output_valid;

//输出读取地址相关
wire [25*32 - 1 : 0] addr_out_25P_w;
wire [5*32-1: 0] addr_out_5P_w [FEATURE_MAP_NUM-1: 0];
reg  [3:0] addr_out_idx;

//读入数据相关
wire  rd_data_in_valid;
reg  [2:0] data_in_idx;

//25 word数据准备缓冲 以及数据分配逻辑
reg data_buf25_switch;
reg  [16*5-1:  0] data_buf25_0_r [FEATURE_MAP_NUM-1:0];
reg  [16*5-1:  0] data_buf25_1_r [FEATURE_MAP_NUM-1:0];
wire [16*25-1: 0] data_buf25_0_w;
wire [16*25-1: 0] data_buf25_1_w;
wire [16*25-1: 0] data_buf25;
reg  [16*25-1: 0] data_buf25_delay;
wire [15: 0] inner_product_out [FEATURE_MAP_NUM-1:0]; 
wire [15: 0] relu_out;
wire data_buf25_change;



//kernel bias_idx
wire [7:0] kernel_bias_idx [FEATURE_MAP_NUM-1:0]; //选择对应的kernel和bias
wire [16*25-1: 0] kernel_out [FEATURE_MAP_NUM-1:0];
wire [15: 0] bias_out;
wire [FEATURE_MAP_NUM-1:0] kernel_calculating_pulse;
wire kernel_calculating_delay_pulse; //和数据在计算元件中流动的速度一致
wire relu_out_valid;//同上

wire [15: 0] sum_0123;
wire [15: 0] sum_45;
reg [15: 0] sum0123_sync;
reg [15: 0] sum45_sync;
wire [15: 0] total_sum;

//pool buffers[]
reg  [7: 0]  pool_buffer_idx; //记录是哪个kernel的poolBuffer
reg  [7: 0]  pool_buffer_cnt [KERNEL_NUM-1:0]; //记录某个kernel的pool buffer中被填充了第几个数字
reg  [16 * 4 - 1: 0] pool_buffer_mem [KERNEL_NUM-1:0]; //暂时存储pool数据的 
wire [16 * KERNEL_NUM - 1: 0] pool_out;
wire [KERNEL_NUM-1: 0] pool_out_valid;//当对应pool输出有效值是 该位置位
//输出逻辑控制
reg wr_out_en_r;
wire [31 : 0] kernel_offset;
reg [7:0] pool_out_kernel_idx;
reg [31: 0] anchor_out_addr;
reg  output_flag;
reg st_flag;

assign wr_out_en = wr_out_en_r;
assign anchor_addr[31:16] = 0;
c3s4_layer_anchor_rom c3s4_anchor_rom (
  .clka(clk),    // input wire clka
  .addra(anchor_rom_addr),  // input wire [8 : 0] addra
  .douta(anchor_addr[15:0])  // output wire [15: 0] douta
);

//assign data_buf25_0_w = {data_buf25_0_r[4], data_buf25_0_r[3], data_buf25_0_r[2], data_buf25_0_r[1], data_buf25_0_r[0]};
//assign data_buf25_1_w = {data_buf25_1_r[4], data_buf25_1_r[3], data_buf25_1_r[2], data_buf25_1_r[1], data_buf25_1_r[0]};
//assign data_buf25 = data_buf25_switch == 0 ? data_buf25_0_w : data_buf25_1_w;

AddrGen #(.H_IMAGE_LEN(15), .V_IMAGE_LEN(15)) addr_gen_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(en),
    .pause(0),
    .addr_out_25P(addr_out_25P_w),
    .anchor_addr_in(anchor_addr)
);

//delay 6 cycles 
//inner_product and relu 

C3_bias C3_bias_inst(
  .clka(clk),    // input wire clka
  .addra(kernel_bias_idx[0]),  // input wire [2 : 0] addra
  .douta(bias_out)  // output wire [15 : 0] douta
);


C3_Kernal C3_Kernel_inst(
  .clka(clk),    // input wire clka
  .addra(kernel_init_idx),  // input wire [2 : 0] addra
  .douta(kernel_ram_data)  // output wire [399 : 0] douta
);

 
assign sum_0123 = (inner_product_out[0] + inner_product_out[1]) + (inner_product_out[2] + inner_product_out[3]);
assign sum_45 = (inner_product_out[4] + inner_product_out[5]);

assign total_sum = sum0123_sync + sum45_sync;
assign relu_out = total_sum[15] == 1'b1 ? 0 : total_sum;
always @(posedge clk)
begin
    sum0123_sync <= sum_0123;
    sum45_sync <= sum_45;
end 

    
//sub_inst_1
genvar sub_inst_idx;

assign rd_data_in_5P[0] = rd_data_in_5P_0;
assign rd_data_in_5P[1] = rd_data_in_5P_1;
assign rd_data_in_5P[2] = rd_data_in_5P_2;
assign rd_data_in_5P[3] = rd_data_in_5P_3;
assign rd_data_in_5P[4] = rd_data_in_5P_4;
assign rd_data_in_5P[5] = rd_data_in_5P_5;

assign rd_addr_out_5P = addr_out_5P_w[0];

generate
for (sub_inst_idx = 0; sub_inst_idx < FEATURE_MAP_NUM; sub_inst_idx = sub_inst_idx + 1)
begin 

C3_kernel_ram kernel_inst (
  .a(kernel_ram_addr_delayed),        // input wire [8 : 0] a
  .d(kernel_ram_data),        // input wire [399 : 0] d
  .clk(clk),    // input wire clk
  .we(kernel_inst_we[sub_inst_idx]),      // input wire we
  .dpra(kernel_bias_idx[sub_inst_idx]),  // input wire [8 : 0] dpra
  .dpo(kernel_out[sub_inst_idx])    // output wire [399 : 0] dpo
);

C3_sub_module C3_sub_inst(
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .anchor_rom_output_valid(anchor_rom_output_valid),
    .addr_out_25P_w(addr_out_25P_w),
    .bias_out(bias_out),
    .kernel_out(kernel_out[sub_inst_idx]),
    .rd_data_in_5P(rd_data_in_5P[sub_inst_idx]),
    .rd_addr_out_5P(addr_out_5P_w[sub_inst_idx]),
    
    .inner_product_out(inner_product_out[sub_inst_idx]),
    .kernel_bias_idx(kernel_bias_idx[sub_inst_idx]),
    .kernel_calculating_pulse(kernel_calculating_pulse[sub_inst_idx])
);
end 
endgenerate


//延迟信号和计算值流动的一致
Delay #(.WIDTH(1), .DELAY_CYCLE(7)) Delay_instx( 
    .clk(clk),
    .din(kernel_calculating_pulse[0]),
    .dout(kernel_calculating_delay_pulse)    
);


genvar pool_inst_idx;
generate
for (pool_inst_idx = 0; pool_inst_idx < KERNEL_NUM; pool_inst_idx = pool_inst_idx + 1)
begin 
MaxValue4P #(.WIDTH(16)) max_pool_inst(
    .in4P(pool_buffer_mem[pool_inst_idx]),
    .max_out(pool_out[16*(pool_inst_idx + 1) - 1: 16*pool_inst_idx])
);
end 
endgenerate

//选择对应Kernel的pool out
/*
MUX10_1 #(.WIDTH(16)) mux_inst(
    .select(pool_out_kernel_idx),
    .output_data(wr_data_out_1P),
    .in_00(pool_out[16*(0 + 1) - 1: 16*0]),
    .in_01(pool_out[16*(1 + 1) - 1: 16*1]),
    .in_02(pool_out[16*(2 + 1) - 1: 16*2]),
    .in_03(pool_out[16*(3 + 1) - 1: 16*3]),
    .in_04(pool_out[16*(4 + 1) - 1: 16*4]),
    .in_05(pool_out[16*(5 + 1) - 1: 16*5]),
    .in_06(0),
    .in_07(0),
    .in_08(0),
    .in_09(0)
);*/

MUX16_1 #(.WIDTH(16)) mux_16_inst(
.select(pool_out_kernel_idx),
.output_data(wr_data_out_1P),
.in_00(pool_out[16*( 0 + 1) - 1: 16* 0]),
.in_01(pool_out[16*( 1 + 1) - 1: 16* 1]),
.in_02(pool_out[16*( 2 + 1) - 1: 16* 2]),
.in_03(pool_out[16*( 3 + 1) - 1: 16* 3]),
.in_04(pool_out[16*( 4 + 1) - 1: 16* 4]),
.in_05(pool_out[16*( 5 + 1) - 1: 16* 5]),
.in_06(pool_out[16*( 6 + 1) - 1: 16* 6]),
.in_07(pool_out[16*( 7 + 1) - 1: 16* 7]),
.in_08(pool_out[16*( 8 + 1) - 1: 16* 8]),
.in_09(pool_out[16*( 9 + 1) - 1: 16* 9]),
.in_10(pool_out[16*(10 + 1) - 1: 16*10]),
.in_11(pool_out[16*(11 + 1) - 1: 16*11]),
.in_12(pool_out[16*(12 + 1) - 1: 16*12]),
.in_13(pool_out[16*(13 + 1) - 1: 16*13]),
.in_14(pool_out[16*(14 + 1) - 1: 16*14]),
.in_15(pool_out[16*(15 + 1) - 1: 16*15])
);


//anchor rom 控制块
always @(posedge clk)
begin
    if (anchor_rom_en)
    begin
        if (anchor_perido_cnt == KERNEL_NUM-1)
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
assign  anchor_rom_output_valid = anchor_perido_cnt == 1;

//pool 数据缓存逻辑
assign relu_out_ready = kernel_calculating_delay_pulse;
genvar pool_idx;
generate
for (pool_idx = 0; pool_idx < KERNEL_NUM; pool_idx = pool_idx + 1)
begin
    assign pool_out_valid[pool_idx] = pool_buffer_cnt[pool_idx] == 4;
end
endgenerate

integer k0;
integer k1;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        pool_buffer_idx <= 0;
        for (k0 = 0; k0 < KERNEL_NUM; k0 = k0 + 1)
        begin
            pool_buffer_mem[k0] <= 0;
            pool_buffer_cnt[k0] <= 0;
        end
    end 
    else
    begin
        if (!en)
        begin
            st_flag <= 0;
        end
        if (relu_out_ready) //在结果真正输出前一个周期做好准备
        begin
            pool_buffer_idx <= 0;
            st_flag <= 1;
        end 
        else
        begin
            pool_buffer_idx <= pool_buffer_idx + 1;
        end 
        pool_buffer_mem[pool_buffer_idx][15:0] <= relu_out;
        //使用移位的方式逐渐填充对应kernel的 pool buffer
        pool_buffer_mem[pool_buffer_idx][31: 16] <= pool_buffer_mem[pool_buffer_idx][15:0];
        pool_buffer_mem[pool_buffer_idx][47: 32] <= pool_buffer_mem[pool_buffer_idx][31:16];
        pool_buffer_mem[pool_buffer_idx][63: 48] <= pool_buffer_mem[pool_buffer_idx][47:32];
       
        if (st_flag)
        begin 
            if (pool_buffer_cnt[pool_buffer_idx] == 4)
            begin
                pool_buffer_cnt[pool_buffer_idx] <= 1;
            end
            else 
            begin
                pool_buffer_cnt[pool_buffer_idx] <= pool_buffer_cnt[pool_buffer_idx] + 1;
            end
        end
        else
        begin
            for (k1 = 0; k1 < KERNEL_NUM; k1 = k1 + 1)
            begin
                pool_buffer_cnt[k1] <= 0;
            end 
        end
    end 
end 


//输出控制逻辑
//genvar pool_out_inst_idx
assign kernel_offset = pool_out_kernel_idx * RES_KERNEL_OFFSET; //RES_KERNEL_OFFSET 是2的幂
assign wr_addr_out_1P = anchor_out_addr + kernel_offset; //anchor_out_addr 在二维图像上对应的一维坐标 kernel_offser 第三位在一维上对应的偏移
assign all_fin = anchor_out_addr == OUTPUT_FIN_ROM_ADDR;
always @(posedge clk or negedge rst_n)
begin 
    if (!rst_n)
    begin
        pool_out_kernel_idx <= 0;
        anchor_out_addr <= 0;
        wr_out_en_r <= 0;
        output_flag <= 0;
    end
    else
    begin
        if (en)
        begin 
            //pool_out_kernel_idx 处于012345 各一个周期
            if(pool_out_valid[0] && output_flag == 0)
            begin
                output_flag <= 1;
                wr_out_en_r <= 1;
                pool_out_kernel_idx <= 0;
            end 
            else if (output_flag && pool_out_kernel_idx == KERNEL_NUM - 1)
            begin
                output_flag <= 0;
                pool_out_kernel_idx <= 0;
                wr_out_en_r <= 0;
                anchor_out_addr <= anchor_out_addr + 1;
            end
            else if (output_flag)
            begin
                pool_out_kernel_idx <= pool_out_kernel_idx + 1;
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
       main_state <= INIT;
       anchor_rom_en <=0 ;
       work_finished <= 0;
       init_en <= 0;
   end
   else
   begin
       //状态转移与输出全部写在此处
       case (main_state)
       INIT:
       begin
           if (!init_fin)
           begin 
               init_en <= 1;
               main_state <= INIT;
           end
           else
           begin
               main_state <= IDLE;
           end
       end
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
              main_state <= STALL;
           end    
       end           
       STALL:
       begin
           if (all_fin)
               main_state <= FINISHED;
           else
               main_state <= STALL;
       end 
       FINISHED:
       begin 
           main_state <= IDLE;
           work_finished <= 1;
           anchor_rom_en <= 0;
       end
       default: main_state <= IDLE;
       endcase
   end 
end



//reg [8:0] kernel_ram_addr;        // input wire [8 : 0] a
//wire [25*16-1:0] kernel_ram_data;
//reg [7:0] kernel_init_idx; //原始 kernel 使用的索引
//reg [KERNEL_NUM-1: 0] kernel_inst_we;

assign kernel_inst_we_ready = {16'h0, 1 << (kernel_init_idx % 6)};

/*
ram_delay_5 delay_5_inst (
  .D(kernel_ram_addr),      // input wire [7 : 0] D
  .CLK(clk),  // input wire CLK
  .Q(kernel_ram_addr)      // output wire [7 : 0] Q
);
*/
Delay #(.WIDTH(8), .DELAY_CYCLE(6)) Delay_init_instx_6( 
    .clk(clk),
    .din(kernel_ram_addr),
    .dout(kernel_ram_addr_delayed)    
);

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        init_fin <= 0;
        kernel_init_idx <= 0;
        kernel_ram_addr <= 0;
        kernel_inst_we <= 0;
    end
    else
    begin
        if (init_en)
        begin
            if (kernel_init_idx < 16*6)
            begin
                kernel_init_idx <= kernel_init_idx + 1;
                if (kernel_init_idx % FEATURE_MAP_NUM == 0)
                begin
                    kernel_ram_addr <= kernel_ram_addr + 1;
                end
                kernel_inst_we <= kernel_inst_we_ready;
            end
            else 
            begin 
                init_fin <= 1;
                kernel_inst_we <= 0;
            end 
        end
    end
end 

wire [31:0] rd_addr_out0;
wire [31:0] rd_addr_out1;
wire [31:0] rd_addr_out2;
wire [31:0] rd_addr_out3;
wire [31:0] rd_addr_out4;


assign rd_addr_out0 = rd_addr_out_5P[(1 + 1)*32-1: 0*32];
assign rd_addr_out1 = rd_addr_out_5P[(2 + 1)*32-1: 1*32];
assign rd_addr_out2 = rd_addr_out_5P[(3 + 1)*32-1: 2*32];
assign rd_addr_out3 = rd_addr_out_5P[(4 + 1)*32-1: 3*32];
assign rd_addr_out4 = rd_addr_out_5P[(5 + 1)*32-1: 4*32];


endmodule 