module Dense1_layer(
    clk,
    rst_n,
    
    en,
    
    rd_addr_out_1P,
    rd_data_in_25P,
    wr_addr_out,
    wr_data_out,
    wr_en_out,
    
    work_finished
);

input clk;
input rst_n;
    
input en;
output work_finished;
    
input  [31:0] rd_addr_out_1P; //
input  [16*25-1:0] rd_data_in_25P;
output [31:0] wr_addr_out;
output [15:0] wr_data_out;
output wr_en_out;
    
parameter ROW_NUM_OFFSET = 16; //每个ROW对应多少个OFFSET
parameter OFFSET_LENGTH = 25;
parameter DIN_DEPTH = 16;
parameter BIAS_DEPTH = 120;
parameter KERNEL_DEPTH = 120*16;
    
//外部数据的索引
reg [7:0] din_row_offset; //一行看做是400的长度 每个段25个数据 offset用来表示行中对应的段
reg [7:0] din_row_idx; //行的偏移

//params 的索引
reg [7:0] kernel_row_offset; //一行看做是400的长度 每个段25个数据 offset用来表示行中对应的段
reg [7:0] kernel_row_idx; //行的偏移

//bias 索引
reg   [7:0] bias_row_idx; 
wire  [25*16-1:0] kernel_out;
wire  [16-1:0] bias_out;

//长度25word的 移位寄存器
reg  [16*25:0] row_res_buf; //暂存每行部分结果的移位寄存器
reg  row_res_buf_valid;     //当前移位寄存器移位完成 为后续加法器指导
reg  kernel_loop_fin;       //表明kernel中最后一组数据已经读出

//控制寄存器

dense_1_bias dense_1_bias_inst (
  .clka(clk),    // input wire clka
  .addra(bias_row_idx),  // input wire [6 : 0] addra
  .douta(bias_out)  // output wire [15 : 0] douta
);

assign rd_addr_out_1P = din_row_offset;

dense_1_params dense_1_params_inst (
  .clka(clk),    // input wire clka
  .addra(kernel_row_idx*25 + kernel_row_idx),  // input wire [9 : 0] addra
  .douta(douta)  // output wire [399 : 0] douta
);

InnerProduct_25P inner_product_inst(
    .clk(clk),
    .bias(bias_out),
    .in_vecA_25P(kernel_out),
    .in_vecB_25P(rd_data_in_25P),
    .out_1P(inner_product_out)
);

/*
Delay #(.WIDTH(1), .DELAY_CYCLE(7)) Delay_instx( 
    .clk(clk),
    .din(kernel_calculating_pulse[0]),
    .dout(kernel_calculating_delay_pulse)    
);

Delay #(.WIDTH(1), .DELAY_CYCLE(7)) Delay_instx( 
    .clk(clk),
    .din(kernel_calculating_pulse[0]),
    .dout(kernel_calculating_delay_pulse)    
);
*/

AddTree_26p(
	.clk(clk),
	.in_25P(row_res_buf),//25 个同样位宽的端口
	.in_bias(0), //一个单独的端口
	.out(wr_data_out)
);   

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        kernel_row_idx <= 0;
        kernel_row_offset <= 0;
        din_row_idx <= 0;
        din_row_offset <= 0;
        bias_row_idx <= 0;
    end
    else
    begin
        if (en)
        begin
            if (din_row_offset == OFFSET_LENGTH - 1)
            begin
               
            end 
            else
            begin
                din_row_offset <= din_row_offset + 1;
            end
            
            if (kernel_row_offset ==  OFFSET_LENGTH - 1)
            begin
                if (kernel_row_idx == KERNEL_DEPTH - 1)
                begin
                    kernel_row_idx <= 0;
                    kernel_loop_fin <= 1;
                    row_send <= 1;
                end
                else
                begin 
                    row_send <= 0;
                    kernel_row_idx <= kernel_row_idx + 1;
                    bias_row_idx <= bias_row_idx + 1;
                end 
            end 
            else
            begin
                kernel_row_offset <= kernel_row_offset + 1;
            end
        end 
        else
        begin
            kernel_loop_fin <= 0;
            kernel_row_idx <= 0;
            kernel_row_offset <= 0;
            din_row_idx <= 0;
            din_row_offset <= 0;
            bias_row_idx <= 0;
        end
    end
end 
endmodule