// origin adder declare
// origin mul_inst

module FixMul(
    rst_n,
    clk,
	inA,
	inB,
	outP
);
    parameter WIDTH = 16;      //total width for fixpoint
	parameter POINT_WIDTH = 8; //width of point part
	parameter FILL_ONE = ((64'h1 << POINT_WIDTH) - 1)[POINT_WIDTH - 1:0];
	parameter FILL_ZERO	= 64'h0[POINT_WIDTH - 1:0];
	
	input  [WIDTH-1:0] inA;
	input  [WIDTH-1:0] inB;
	output [2*WIDTH-1:0] outP;
	input dummy;
	 
	wire [2*WIDTH-1:0] mul_out; 
	
	mul_32 mul_inst (
		.CLK(clk),  // input wire CLK
		.A(inA),      // input wire [31 : 0] A
		.B(inB),      // input wire [31 : 0] B
		.P(mul_out)      // output wire [63 : 0] P
	);
	assign outP = mul_out[2 * WIDTH-1] == 1'b0 ? {FILL_ZERO, mul_out[:POINT_WIDTH]}: {FILL_ONE, mul_out[:POINT_WIDTH]};
	
endmodule 




