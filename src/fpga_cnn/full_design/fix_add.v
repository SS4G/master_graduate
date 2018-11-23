//fix point adder 
//delay 1 clock cycles
module FixAdd(
    rst_n,
    clk,
	inA,
	inB,
	outSum
);
    parameter WIDTH = 16;      //total width for fixpoint
	
    input rst_n;
    input clk;	
	input  [WIDTH-1:0] inA;
	input  [WIDTH-1:0] inB;
	output [WIDTH-1:0] outSum;
	 
	adder_32 add_inst (
		.A(inA),      // input wire [31 : 0] A
		.B(inB),      // input wire [31 : 0] B
		.CLK(clk),  // input wire CLK
		.S(outSum)      // output wire [31 : 0] S
	);
endmodule




