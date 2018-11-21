//fix point multiplier
//delay ? clock cycles
module FixMul(
    rst_n,
    clk,
	inA,
	inB,
	outP
);
    parameter WIDTH = 16;      //total width for fixpoint
	parameter POINT_WIDTH = 8'h8; //width of point part
	
	input rst_n;
	input clk;
	
	input  [WIDTH-1:0] inA;
	input  [WIDTH-1:0] inB;
	output [WIDTH-1:0] outP;
	 
	wire [WIDTH-1:0] mul_out; 
	
	wire [POINT_WIDTH-1:0] const_ones;
	wire [POINT_WIDTH-1:0] const_zeros;
	
	mul_32 mul_inst (
		.CLK(clk),  // input wire CLK
		.A(inA),      // input wire [31 : 0] A
		.B(inB),      // input wire [31 : 0] B
		.P(mul_out)      // output wire [63 : 0] P
	);
	
	assign const_ones = 64'h8000_0000_0000_0000 - 1;
	assign const_zeros = 64'h0;
	
	assign outP = mul_out[2 * WIDTH-1] == 1'b0 ? {const_zeros, mul_out[WIDTH-1:POINT_WIDTH]}: {const_ones, mul_out[WIDTH-1:POINT_WIDTH]};
endmodule 