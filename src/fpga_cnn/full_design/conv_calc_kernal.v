//计算一个卷积核以及
module ConvKernal(
    clk,
    rst_n,
    enable,
    bias,
    data_25P,
    kernal_25P,
    relu_out
);

parameter DATA_WIDTH = 16;
parameter DELAY_CYCLES = 7;

input clk;
input rst_n;
input enable;
input [DATA_WIDTH-1: 0] bias;
input [25*DATA_WIDTH-1: 0] data_25P;
input [25*DATA_WIDTH-1: 0] kernal_25P;

output relu_out;
output reg pool_buf_wr_en;

reg [3:0] delay_cnt; 
reg fifo_wr_en;
reg fifo_rd_en;

wire [DATA_WIDTH-1:0] relu_in;
wire [25*DATA_WIDTH-1: 0] mul_out;
wire [25*DATA_WIDTH-1: 0] add_in;
wire debug_fifo_full;



AddTree_26p add_tree_inst (
    .rst_n(rst_n),
	.clk(clk),
	.in_25P(add_in),//25 个同样位宽的端口
	.in_bias(bias), //一个单独的端口
	.out(relu_in)
);

MulVec_25p Mul_Vec_inst(
    .rst_n(rst_n),
	.clk(clk),
	.inA_25P(data_25P),
	.inB_25P(kernal_25P),
	.outP_25P(mul_out)
);  


fifo_16b data_fifo (
    .clk(clk),                  // input wire clk
    .rst(rst_n),                // input wire rst
    .din(din),                  // input wire [15 : 0] din
    .wr_en(fifo_wr_en),              // input wire wr_en
    .rd_en(rd_en),              // input wire rd_en
    .dout(add_in),                // output wire [15 : 0] dout
    .full(debug_fifo_full),                // output wire full
    .empty(),              // output wire empty
    .wr_rst_busy(),         // output wire wr_rst_busy
    .rd_rst_busy()  // output wire rd_rst_busy
);

//有符号数的比较可能会有问题 ?? 待定
assign relu_out = relu_in[DATA_WIDTH-1] == 1'b1 ? 0 : relu_in;

always @(posedge clk or negedge rst_n)
begin 
    if (!rst_n)
    begin
        fifo_wr_en <= 0;
        fifo_rd_en <= 0;
        delay_cnt <= 0;
    end 
    else
    begin
        if(enable)
        begin
            if(fifo_wr_en)
            begin
                delay_cnt <= delay_cnt+1;
            end
        end
        else
        begin 
            fifo_wr_en <= 0;
            fifo_rd_en <= 0;
            delay_cnt <= 0;
        end 
    end 
end 
endmodule 