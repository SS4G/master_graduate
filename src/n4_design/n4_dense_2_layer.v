module Dense2_layer(
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
output reg [31:0] wr_addr_out;
output reg [15:0] wr_data_out;
output reg wr_en_out;
    
parameter ROW_NUM_OFFSET = 5; //每个ROW对应多少个OFFSET
parameter OFFSET_LENGTH = 25;
parameter BIAS_DEPTH = 84;
parameter KERNEL_DEPTH = 84;
parameter INNER_DELAY = 6;
parameter ADDER_TREE_DELAY = 6;

    
//外部数据的索引
reg [7:0] din_row_offset; //一行看做是400的长度 每个段25个数据 offset用来表示行中对应的段
reg [7:0] din_row_idx; //行的偏移

//params 的索引
reg [15:0] kernel_row_offset; //一行看做是400的长度 每个段25个数据 offset用来表示行中对应的段
reg [15:0] kernel_row_idx; //行的偏移

//bias 索引
reg   [7:0] bias_row_idx; 
wire  [25*16-1:0] kernel_out;
wire  [16-1:0] bias_out;

//长度25word的 移位寄存器
reg  [16*25-1:0] row_res_buf; //暂存每行部分结果的移位寄存器
reg  row_res_buf_valid;     //当前移位寄存器移位完成 为后续加法器指导
wire [15:0] inner_product_out;


//控制寄存器
reg inner_row_valid;
wire inner_row_valid_delayed;
wire adder_tree_out_valid;
wire [15:0] kernel_addr;

//输出控制寄存器
reg [31:0] wr_cnt;

reg [31:0] wr_addr_out_r;

wire [15:0] total_sum;
wire [15:0] relu_out;

dense_2_bias dense_2_bias_inst (
  .clka(clk),    // input wire clka
  .addra(bias_row_idx),  // input wire [6 : 0] addra
  .douta(bias_out)  // output wire [15 : 0] douta
);

assign rd_addr_out_1P = din_row_offset;
assign kernel_addr = kernel_row_idx*16 + kernel_row_offset;

dense_2_params dense_2_params_inst (
  .clka(clk),    // input wire clka
  .addra(kernel_addr),  // input wire [9 : 0] addra
  .douta(kernel_out)  // output wire [399 : 0] douta
);

InnerProduct_25P inner_product_inst(
    .clk(clk),
    .bias(bias_out),
    .in_vecA_25P(kernel_out),
    .in_vecB_25P(rd_data_in_25P),
    .out_1P(inner_product_out)
);


Delay #(.WIDTH(1), .DELAY_CYCLE(INNER_DELAY)) Delay_instx_inner( 
    .clk(clk),
    .din(inner_row_valid),
    .dout(inner_row_valid_delayed)    
);


Delay #(.WIDTH(1), .DELAY_CYCLE(ADDER_TREE_DELAY)) Delay_instx_adder( 
    .clk(clk),
    .din(inner_row_valid_delayed),
    .dout(adder_tree_out_valid)    
);


AddTree_26p adder_tree_inst(
	.clk(clk),
	.in_25P(row_res_buf),//25 个同样位宽的端口
	.in_bias(0), //一个单独的端口
	.out(total_sum)
);   

//relu function
assign relu_out = total_sum[15] == 1'b1 ? 0 : total_sum;
assign work_finished = wr_cnt == BIAS_DEPTH;
//输出逻辑
always @(posedge clk)
begin
     if(en)
     begin 
         row_res_buf <= {inner_product_out, row_res_buf[16*25-1:16]};
         if (adder_tree_out_valid)
         begin
             wr_cnt <= wr_cnt + 1;
             wr_addr_out <= wr_addr_out_r;
             wr_addr_out_r <= wr_addr_out_r + 1;
             wr_data_out <= relu_out;
             wr_en_out <= 1;
             
         end
         else
         begin
             wr_en_out <= 0;
         end 
     end
     else
     begin
         wr_cnt <= 0;
         wr_addr_out <= 0;
         wr_addr_out_r <= 0;
         wr_en_out <= 0;
         row_res_buf <= 0;
     end 
end 

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
            if (din_row_offset == ROW_NUM_OFFSET - 1)
            begin
                din_row_offset <= 0;
                inner_row_valid <= 1;
            end 
            else
            begin
                din_row_offset <= din_row_offset + 1;
                inner_row_valid <= 0;
            end
            
            if (kernel_row_offset ==  ROW_NUM_OFFSET - 1)
            begin
                kernel_row_offset <= 0;
                if (kernel_row_idx == KERNEL_DEPTH - 1)
                begin
                    kernel_row_idx <= kernel_row_idx;
                    bias_row_idx <= bias_row_idx;
                end
                else
                begin 
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
            kernel_row_idx <= 0;
            kernel_row_offset <= 0;
            din_row_idx <= 0;
            din_row_offset <= 0;
            bias_row_idx <= 0;
            inner_row_valid <= 0;
        end
    end
end 
endmodule