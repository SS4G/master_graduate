//delay 6 cycles 
module InnerProduct_25P(
    clk,
    bias,
    in_vecA_25P,
    in_vecB_25P,
    out_1P
);

parameter DATA_WIDTH = 16;

input clk;
input [DATA_WIDTH-1: 0] bias;
input [25*DATA_WIDTH-1: 0] in_vecA_25P;
input [25*DATA_WIDTH-1: 0] in_vecB_25P;

output [DATA_WIDTH-1:0] out_1P;

wire [25*DATA_WIDTH-1: 0] mul_out;

AddTree_26p add_tree_inst (
	.clk(clk),
	.in_25P(mul_out),//25 个同样位宽的端口
	.in_bias(bias), //一个单独的端口
	.out(out_1P)
);

MulVec_25p Mul_Vec_inst(
	.clk(clk),
	.inA_25P(in_vecA_25P),
	.inB_25P(in_vecB_25P),
	.outP_25P(mul_out)
);  

endmodule 