module Dense2_layer(
    clk,
    rst_n,
    layer_en_i,
    output_buf_en_o,
    
    data_to_calc_o,
    data_from_calc_i,
    
    data_from_buf_i,
    data_to_buf_o,
    
    data_to_buf_addr_o,
    data_from_buf_addr_o
);

parameter WIDTH = 16;

parameter IDLE = 0;
parameter FINISHED = 1;
parameter RUNNING = 2;
parameter READY = 3;

input  clk;
input  rst_n;
input  layer_en_i;
output reg output_buf_en_o;

output [16 * 51-1: 0] data_to_calc_o; //{VecA, VecB, Bias}
input  [15: 0] data_from_calc_i;

input  [16 * 5 - 1: 0] data_from_buf_i;
output reg [15: 0] data_to_buf_o;

output [31:0] data_to_buf_addr_o;
output [32*5-1:0] data_from_buf_addr_o;

reg [31:0] anchor_rom_addr_r;
reg [7:0] kernal_idx_r; //选择对应Kernalk
reg [1:0] pool_idx_r; //插入pool的地址计数器
reg addr_gen_en_r; //地址生成使能
reg addr_gen_puase_r; //地址生成暂停 该信号为低时保持端口上原有的数据
wire [31 * 25 - 1: 0] addr_out_25P_w; //addr_gen输出的数据
wire [31: 0] rom_anchor_out_w;

reg  [16 * 25 - 1: 0] data_25_buffer_r; //缓存25个word数据的buf 每个时钟周期存入5个
wire [15: 0] current_bias_out_w;
wire [16*25-1: 0] current_kernel_out_w;

reg  [15: 0] pool_buf_r [3:0];
wire [15: 0] pool_out_w; 

reg [15: 0] main_state_r;
reg [31: 0] kernel_cnt;
reg data_sent_to_calc;
reg data_from_calc_valid;
reg [16*5-1:0] img_data_window_buf_r [4:0];//
reg data_valid_shift_reg [10:0];

reg [31:0] data_window_read_cnt;

AddrGen addr_inst(
    .rst_n(rst_n),
    .clk(clk),
    .en(addr_gen_en_r),//
    .pause(addr_gen_puase_r),//
    .addr_out_25P(addr_out_25P_w),//
    .anchor_addr_in(rom_anchor_out_w)//
    //.rom_addr_out(anchor_rom_addr)
);

C1_bias bias_inst (
    .clka(clk),    // input wire clka
    .addra(kernal_idx_r),  // input wire [2 : 0] addra
    .douta(current_bias_out_w)   // output wire [15 : 0] douta
);

C1_kernal kernal_inst (
    .clka(clk),    // input wire clka
    .addra(kernal_idx_r),  // input wire [2 : 0] addra
    .douta(current_kernel_out_w)   // output wire [399 : 0] douta
);

c1s2_layer_anchor_rom anchor_inst(
  .clka(clk),    // input wire clka
  .addra(anchor_rom_addr_r),  // input wire [9 : 0] addra
  .douta(rom_anchor_out_w)  // output wire [15 : 0] douta
);

MaxValue4P #(.WIDTH(16))pool_inst(
    .in4P({pool_buf_r[0], pool_buf_r[1], pool_buf_r[2], pool_buf_r[3]}),
    .max_out(pool_out_w)
);

assign data_from_buf_addr_o = addr_out_25P_w;
assign data_to_calc_o = {current_kernel_out_w, data_25_buffer_r, current_bias_out_w};

//计算延迟
always @(posedge clk)
begin
    data_valid_shift_reg[0] <= data_sent_to_calc; 
    data_valid_shift_reg[1] <= data_valid_shift_reg[0]; 
    data_valid_shift_reg[2] <= data_valid_shift_reg[1]; 
    data_valid_shift_reg[3] <= data_valid_shift_reg[2]; 
    data_valid_shift_reg[4] <= data_valid_shift_reg[3]; 
    data_valid_shift_reg[5] <= data_valid_shift_reg[4]; 
    data_from_calc_valid <= data_valid_shift_reg[5];
end


always @(posedge clk)
begin
        case (main_state_r)
        IDLE:
        begin
            if (layer_en_i)
            begin
                addr_gen_en_r <= 1;
                output_buf_en_o <= 1;  
                kernal_idx_r <= 0;
                main_state_r <= READY;    
                anchor_rom_addr_r <= 0;
            end 
            else
            begin
                addr_gen_en_r <= 0;
                output_buf_en_o <= 0;   
            end
        end 
        RUNNING:
        begin
            anchor_rom_addr_r <= anchor_rom_addr_r + 1;
            if (data_window_read_cnt <= 5)
            begin
                img_data_window_buf_r[data_window_read_cnt] <= data_from_buf_i;
                data_window_read_cnt <= data_window_read_cnt + 1;
            end 
            else
            begin
                data_25_buffer_r <= {img_data_window_buf_r[0], img_data_window_buf_r[1], img_data_window_buf_r[2], img_data_window_buf_r[3], img_data_window_buf_r[4]};
                data_window_read_cnt <= 0;
            end 
        end 
        FINISHED:
        begin
        
        end 
        default:;
        endcase
end

reg [31:0] data_to_buf_addr_offset_r;//一个kernel内的 输出偏移地址

assign data_to_buf_addr_o = kernal_idx_r << 10 + data_to_buf_addr_offset_r;

always @(posedge clk)
begin
        if (data_from_calc_valid)
        begin
            pool_buf_r[pool_idx_r] <= data_from_calc_i;
            pool_idx_r <= pool_idx_r + 1;
            if (pool_idx_r == 2'd3)
            begin
               data_to_buf_o <= pool_out_w;
            end 
        end
end 
endmodule 












