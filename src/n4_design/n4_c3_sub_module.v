module C3_sub_module(
    clk,
    rst_n,
    en,
    anchor_rom_output_valid,
    addr_out_25P_w,
    rd_data_in_5P,
    bias_out,
    kernel_out,

    inner_product_out,
    kernel_bias_idx,
    kernel_calculating_pulse,
    rd_addr_out_5P
);

input clk;
input rst_n;
input en;
input anchor_rom_output_valid;
input [31*25-1:0] addr_out_25P_w;
input [16*5-1:0] rd_data_in_5P;
input [15: 0] bias_out;
input [16*25 - 1: 0] kernel_out;

output [15:0] inner_product_out;
output reg [7:0]  kernel_bias_idx;
output reg kernel_calculating_pulse;
output [32*5-1:0] rd_addr_out_5P;

parameter KERNEL_NUM = 16;


//输出读取地址相关
wire [25*32 - 1 : 0] addr_out_25P_w;
reg  [5*32-1: 0] addr_out_5P_r [4: 0];
reg  [5:0] addr_out_idx;

//读入数据相关
wire  rd_data_in_valid;
reg  [5:0] data_in_idx;

//25 word数据准备缓冲 以及数据分配逻辑
reg data_buf25_switch;
reg  [16*5-1:  0] data_buf25_0_r [4:0];
reg  [16*5-1:  0] data_buf25_1_r [4:0];
wire [16*25-1: 0] data_buf25_0_w;
wire [16*25-1: 0] data_buf25_1_w;
wire [16*25-1: 0] data_buf25;
reg  [16*25-1: 0] data_buf25_delay;
wire [15: 0] relu_out;
wire data_buf25_change;

//kernel bias_idx
wire relu_out_valid;//同上

InnerProduct_25P inner_product_inst(
    .clk(clk),
    .bias(bias_out),
    .in_vecA_25P(kernel_out),
    .in_vecB_25P(data_buf25_delay),
    .out_1P(inner_product_out)
);


//读取地址分发
assign  rd_addr_out_5P = addr_out_idx < 5 ? addr_out_5P_r[addr_out_idx] : 32'h0;
assign  data_buf25_change = addr_out_idx == 5 && en; //表明下个周期将发生改变
assign  rd_data_in_valid = addr_out_idx != 0;

assign data_buf25_0_w = {data_buf25_0_r[4], data_buf25_0_r[3], data_buf25_0_r[2], data_buf25_0_r[1], data_buf25_0_r[0]};
assign data_buf25_1_w = {data_buf25_1_r[4], data_buf25_1_r[3], data_buf25_1_r[2], data_buf25_1_r[1], data_buf25_1_r[0]};
assign data_buf25 = data_buf25_switch == 0 ? data_buf25_0_w : data_buf25_1_w;

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

endmodule