module C1S2_layer(

clk,
rst_n,

en,
work_finished,

rd_data_in_5P,
rd_addr_out_5P,

wr_addr_out_1P,
wr_data_out_1P
 
);

parameter FIN_ROM_ADDR = 900;
parameter KERNEL_NUM = 6;

//尽量使用局部状态机
parameter IDLE = 31'h0; 
parameter RUNNING = 31'h0; 
parameter FIN = 31'h0; 

input  clk;
input  rst_n;

input  en;
output work_finished;

//读取缓存相关
input  [5*16-1:0] rd_data_in_5P;
output [5*32-1:0] rd_addr_out_5P;

//外部缓存输出
output [31: 0] wr_addr_out_1P;
output [15: 0] wr_data_out_1P;
output wr_out_en;


reg [31:0] main_state;

reg  [31:0] anchor_perido_cnt;
reg  [31:0] anchor_rom_addr;
wire [31:0] anchor_addr;

wire [5 * 32 - 1: 0] rd_addr_5P;
wire [25*32 - 1 : 0] addr_out_25P_w;
reg  [25*32 - 1 : 0] addr_out_25P_r;

//25 word数据准备缓冲 以及数据分配逻辑
reg data_buf25_switch;
reg  [16*25-1: 0] data_buf25_0;
reg  [16*25-1: 0] data_buf25_1;
wire [16*25-1: 0] data_buf25;
wire [15: 0] inner_product_out; 
wire [15: 0] relu_out;

//kernel bias_idx
reg [7:0] kernel_bias_idx; //选择对应的kernel和bias
wire [16*25-1: 0] kernel_out;
wire [15: 0] bias_out;

//pool buffers[]
reg  [7: 0]  pool_buffer_idx; //记录是哪个kernel的poolBuffer
reg  [7: 0]  pool_buffer_cnt [3:0]; //记录某个kernel的pool buffer中被填充了第几个数字
reg  [16 * 4 - 1: 0] pool_buffer_mem [3:0]; //暂时存储pool数据的 
wire [16*KERNEL_NUM-1: 0] pool_out;

//输出逻辑控制

c1s2_layer_anchor_rom c1s2_anchor_rom (
  .clka(clk),    // input wire clka
  .addra(anchor_rom_addr),  // input wire [9 : 0] addra
  .douta(anchor_addr)  // output wire [15 : 0] douta
);

assign rd_addr_out_5P = rd_addr_5P;
assign data_buf25 = data_buf25_switch == 0 ? data_buf25_0 : data_buf25_1;
AddrGen #(.H_IMAGE_LEN(35), .V_IMAGE_LEN(35)) addr_gen_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(en),
    .pause(0),
    .addr_out_25P(addr_out_25P_w),
    .anchor_addr_in(anchor_addr),
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

Delay #(.WIDTH(16), .DELAY_CYCLE(5)) Delay_instx( 
    .clk(),
    .din(),
    .dout()    
);


genvar pool_inst_idx;
generate
for (pool_inst_idx = 0; pool_inst_idx < KERNEL_NUM; pool_inst_idx = pool_inst_idx + 1)
MaxValue4P #(.WIDTH(16)) max_inst(
    .in4P(pool_buffer_mem[pool_inst_idx]),
    .max_out(pool_out[16*(pool_inst_idx + 1):16*pool_inst_idx])
);
endgenerate

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
else 

//读取地址分发
always @(posedge clk)
begin
     addr_out_25P_r <= addr_out_25P_w;
end

//main_state
always @(posedge clk or negedge rst_n)
begin
   if(!rst_n)
   begin
       wr_out_en <= 0;
       main_state <= IDLE;
   end
   else
   begin
       //状态转移与输出全部写在此处
       case (main_state)
       IDLE:
           if (en)
              main_state <= RUNNING;
              anchor_rom_en <= 1;
           else
              main_state <= IDLE;
       RUNNING:
           if (anchor_rom_addr <= FIN_ROM_ADDR)
           begin
              main_state <= RUNNING;
           end
           else
           begin
              main_state <= FINISHED;
           end           
       FINISHED:
           main_state <= IDLE;
           wr_out_en <= 0;
       default:
       endcase
   end 
end
endmodule 