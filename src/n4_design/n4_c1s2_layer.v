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

parameter FIN_ROM_ADDR = 900; //30x30
parameter KERNEL_NUM = 6;
parameter RES_KERNEL_OFFSET = 256; //输出的featuremap对应的 内存段偏移
parameter OUTPUT_FIN_ROM_ADDR = 225; //15x15

//尽量使用局部状态机
parameter IDLE = "IDLE";//31'h0; 
parameter RUNNING = "RUNNING";//31'h1; 
parameter STALL = "STALL";//31'h2; 
parameter FINISHED = "FINISHED";//31'h2; 

input  clk;
input  rst_n;

input  en;
output reg work_finished;

//读取缓存相关
input  [5*16-1:0] rd_data_in_5P;
output [5*32-1:0] rd_addr_out_5P;

//外部缓存输出
output [31: 0] wr_addr_out_1P;
output [15: 0] wr_data_out_1P;
output wr_out_en;


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
wire  rd_data_in_valid;
reg  [2:0] data_in_idx;

//25 word数据准备缓冲 以及数据分配逻辑
reg data_buf25_switch;
reg  [16*5-1:  0] data_buf25_0_r [4:0];
reg  [16*5-1:  0] data_buf25_1_r [4:0];
wire [16*25-1: 0] data_buf25_0_w;
wire [16*25-1: 0] data_buf25_1_w;
wire [16*25-1: 0] data_buf25;
reg  [16*25-1: 0] data_buf25_delay;
wire [15: 0] inner_product_out; 
wire [15: 0] relu_out;
wire data_buf25_change;

//kernel bias_idx
reg [7:0] kernel_bias_idx; //选择对应的kernel和bias
wire [16*25-1: 0] kernel_out;
wire [15: 0] bias_out;
reg kernel_calculating_pulse;
wire kernel_calculating_delay_pulse; //和数据在计算元件中流动的速度一致
wire relu_out_valid;//同上

//pool buffers[]
reg  [7: 0]  pool_buffer_idx; //记录是哪个kernel的poolBuffer
reg  [7: 0]  pool_buffer_cnt [KERNEL_NUM-1:0]; //记录某个kernel的pool buffer中被填充了第几个数字
reg  [16 * 4 - 1: 0] pool_buffer_mem [KERNEL_NUM-1:0]; //暂时存储pool数据的 
wire [16 * KERNEL_NUM - 1: 0] pool_out;
wire  [KERNEL_NUM-1: 0] pool_out_valid;//当对应pool输出有效值是 该位置位
reg st_flag;
//输出逻辑控制
reg wr_out_en_r;
wire [31 : 0] kernel_offset;
reg [7:0] pool_out_kernel_idx;
reg [31: 0] anchor_out_addr;
reg  output_flag;


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
    .in_vecB_25P(data_buf25_delay),
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
    .din(kernel_calculating_pulse),
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
assign  anchor_rom_output_valid = anchor_perido_cnt == 1;
assign  rd_addr_out_5P = addr_out_idx != 5 ? addr_out_5P_r[addr_out_idx] : 'bz;
assign  data_buf25_change = addr_out_idx == 5; //表明下个周期将发生改变
assign  rd_data_in_valid = addr_out_idx != 0;
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin 
        //data_in_ready <= 0;
        //rd_data_in_valid <= 0;        
        addr_out_idx <= 0;
    end
    else
    begin 
        if (anchor_rom_output_valid)
        begin
            addr_out_idx <= 0;
            {addr_out_5P_r[4], addr_out_5P_r[3], addr_out_5P_r[2], addr_out_5P_r[1], addr_out_5P_r[0]} <= addr_out_25P_w;
        end
        else
        begin
            /*
            if (addr_out_idx == 0)
            begin
               rd_data_in_valid <= 1;
            end
            else if (addr_out_idx == 5)
            begin
               rd_data_in_valid <= 0;
            end       
            else*/
            addr_out_idx <= addr_out_idx + 1;
        end
    end 
end

//读取数据拼装逻辑 将1x5的读取数据拼装成5x5的数据
integer p1;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
       data_in_idx <= 0;
       data_buf25_switch <= 0;
       for (p1 = 0; p1 < 5; p1 = p1 + 1)
       begin
           data_buf25_1_r[p1] <= 96'hffffffff_ffffffff_ffffffff;
           data_buf25_0_r[p1] <= 96'hffffffff_ffffffff_ffffffff;
       end 
    end
    else
    begin
        if (rd_data_in_valid)
        begin
           if (!data_buf25_switch)
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
        kernel_bias_idx <= 0;
        kernel_calculating_pulse <= 0;
    end
    else
    begin
        if (data_buf25_change)// data_buf_数据将在该周期改变
        begin
            kernel_bias_idx <= 0;
        end     
        else
        begin
            kernel_bias_idx <= kernel_bias_idx + 1;
        end
        kernel_calculating_pulse <= data_buf25_change;     
        data_buf25_delay <= data_buf25;
    end 
end

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
                pool_buffer_cnt[pool_buffer_idx] <= 0;
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
       main_state <= IDLE;
       anchor_rom_en <=0 ;
       work_finished <= 0;
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


/*below is debug signal*/
wire [15:0] debug_kernel_out_00;
wire [15:0] debug_kernel_out_01;
wire [15:0] debug_kernel_out_02;
wire [15:0] debug_kernel_out_03;
wire [15:0] debug_kernel_out_04;
wire [15:0] debug_kernel_out_05;
wire [15:0] debug_kernel_out_06;
wire [15:0] debug_kernel_out_07;
wire [15:0] debug_kernel_out_08;
wire [15:0] debug_kernel_out_09;
wire [15:0] debug_kernel_out_10;
wire [15:0] debug_kernel_out_11;
wire [15:0] debug_kernel_out_12;
wire [15:0] debug_kernel_out_13;
wire [15:0] debug_kernel_out_14;
wire [15:0] debug_kernel_out_15;
wire [15:0] debug_kernel_out_16;
wire [15:0] debug_kernel_out_17;
wire [15:0] debug_kernel_out_18;
wire [15:0] debug_kernel_out_19;
wire [15:0] debug_kernel_out_20;
wire [15:0] debug_kernel_out_21;
wire [15:0] debug_kernel_out_22;
wire [15:0] debug_kernel_out_23;
wire [15:0] debug_kernel_out_24;
wire [15:0] debug_kernel_out_25;

debus_1to26 kernel_inst(
    .com_bus_in({16'h0, kernel_out}),
    .sep_bus_out00(debug_kernel_out_00),
    .sep_bus_out01(debug_kernel_out_01),
    .sep_bus_out02(debug_kernel_out_02),
    .sep_bus_out03(debug_kernel_out_03),
    .sep_bus_out04(debug_kernel_out_04),
    .sep_bus_out05(debug_kernel_out_05),
    .sep_bus_out06(debug_kernel_out_06),
    .sep_bus_out07(debug_kernel_out_07),
    .sep_bus_out08(debug_kernel_out_08),
    .sep_bus_out09(debug_kernel_out_09),
    .sep_bus_out10(debug_kernel_out_10),
    .sep_bus_out11(debug_kernel_out_11),
    .sep_bus_out12(debug_kernel_out_12),
    .sep_bus_out13(debug_kernel_out_13),
    .sep_bus_out14(debug_kernel_out_14),
    .sep_bus_out15(debug_kernel_out_15),
    .sep_bus_out16(debug_kernel_out_16),
    .sep_bus_out17(debug_kernel_out_17),
    .sep_bus_out18(debug_kernel_out_18),
    .sep_bus_out19(debug_kernel_out_19),
    .sep_bus_out20(debug_kernel_out_20),
    .sep_bus_out21(debug_kernel_out_21),
    .sep_bus_out22(debug_kernel_out_22),
    .sep_bus_out23(debug_kernel_out_23),
    .sep_bus_out24(debug_kernel_out_24),
    .sep_bus_out25(debug_kernel_out_25)
);


/*below is debug signal*/
wire [15:0] debug_data_buf25_delay_00;
wire [15:0] debug_data_buf25_delay_01;
wire [15:0] debug_data_buf25_delay_02;
wire [15:0] debug_data_buf25_delay_03;
wire [15:0] debug_data_buf25_delay_04;
wire [15:0] debug_data_buf25_delay_05;
wire [15:0] debug_data_buf25_delay_06;
wire [15:0] debug_data_buf25_delay_07;
wire [15:0] debug_data_buf25_delay_08;
wire [15:0] debug_data_buf25_delay_09;
wire [15:0] debug_data_buf25_delay_10;
wire [15:0] debug_data_buf25_delay_11;
wire [15:0] debug_data_buf25_delay_12;
wire [15:0] debug_data_buf25_delay_13;
wire [15:0] debug_data_buf25_delay_14;
wire [15:0] debug_data_buf25_delay_15;
wire [15:0] debug_data_buf25_delay_16;
wire [15:0] debug_data_buf25_delay_17;
wire [15:0] debug_data_buf25_delay_18;
wire [15:0] debug_data_buf25_delay_19;
wire [15:0] debug_data_buf25_delay_20;
wire [15:0] debug_data_buf25_delay_21;
wire [15:0] debug_data_buf25_delay_22;
wire [15:0] debug_data_buf25_delay_23;
wire [15:0] debug_data_buf25_delay_24;
wire [15:0] debug_data_buf25_delay_25;

debus_1to26 data_buf_25_debug_inst(
    .com_bus_in({16'h0, data_buf25_delay}),
    .sep_bus_out00(debug_data_buf25_delay_00),
    .sep_bus_out01(debug_data_buf25_delay_01),
    .sep_bus_out02(debug_data_buf25_delay_02),
    .sep_bus_out03(debug_data_buf25_delay_03),
    .sep_bus_out04(debug_data_buf25_delay_04),
    .sep_bus_out05(debug_data_buf25_delay_05),
    .sep_bus_out06(debug_data_buf25_delay_06),
    .sep_bus_out07(debug_data_buf25_delay_07),
    .sep_bus_out08(debug_data_buf25_delay_08),
    .sep_bus_out09(debug_data_buf25_delay_09),
    .sep_bus_out10(debug_data_buf25_delay_10),
    .sep_bus_out11(debug_data_buf25_delay_11),
    .sep_bus_out12(debug_data_buf25_delay_12),
    .sep_bus_out13(debug_data_buf25_delay_13),
    .sep_bus_out14(debug_data_buf25_delay_14),
    .sep_bus_out15(debug_data_buf25_delay_15),
    .sep_bus_out16(debug_data_buf25_delay_16),
    .sep_bus_out17(debug_data_buf25_delay_17),
    .sep_bus_out18(debug_data_buf25_delay_18),
    .sep_bus_out19(debug_data_buf25_delay_19),
    .sep_bus_out20(debug_data_buf25_delay_20),
    .sep_bus_out21(debug_data_buf25_delay_21),
    .sep_bus_out22(debug_data_buf25_delay_22),
    .sep_bus_out23(debug_data_buf25_delay_23),
    .sep_bus_out24(debug_data_buf25_delay_24),
    .sep_bus_out25(debug_data_buf25_delay_25)
);

endmodule 