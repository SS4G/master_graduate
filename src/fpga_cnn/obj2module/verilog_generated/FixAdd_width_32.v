module FixAdd_width_32(
inA,
inB,
clk,
outS,
dummy);


//input signals
input	[31:0]	inA;
input	[31:0]	inB;
input	clk;

//output signals
output	[31:0]	outS;

//inner signal define
output [31: 0] outS;
AddPrim_width_32 inst_0 (
.A(inA),
.B(inB),
.CLK(clk),
.S(outS),
.dummy(1'b1));












endmodule