//计算一个卷积核的值 delay 6 cycles
module ConvKernal(
    clk,
    bias,
    data_25P,
    kernal_25P,
    relu_out
);

parameter DATA_WIDTH = 16;
parameter DELAY_CYCLES = 7;

input clk;
input [DATA_WIDTH-1: 0] bias;
input [25*DATA_WIDTH-1: 0] data_25P;
input [25*DATA_WIDTH-1: 0] kernal_25P;

output [DATA_WIDTH-1: 0] relu_out;

reg [3:0] delay_cnt; 
reg fifo_wr_en;
reg fifo_rd_en;

wire [DATA_WIDTH-1:0] relu_in;
wire [25*DATA_WIDTH-1: 0] mul_out;
wire [25*DATA_WIDTH-1: 0] add_in;
wire debug_fifo_full;


InnerProduct_25P inner_product(
    .clk(clk),
    .bias(bias),
    .in_vecA_25P(data_25P),
    .in_vecB_25P(kernal_25P),
    .out_1P(relu_in)
);
//有符号数的比较可能会有问题 ?? 待定
assign relu_out = relu_in[DATA_WIDTH-1] == 1'b1 ? 0 : relu_in;
//assign relu_out = relu_in;

endmodule 