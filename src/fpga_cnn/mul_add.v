module SignedFixPointAddMul(
    clk,
    rst_n,
    a,
    b,
    add_out,
    mul_out
);
    parameter WIDTH=32;
    parameter POINT_WIDTH = 16;
    
	
	input clk;
	input rst_n;
	input [WIDTH - 1: 0] a;
    input [WIDTH - 1: 0] b;
    output [WIDTH - 1: 0] add_out;
    output [WIDTH * 2 - 1: 0] mul_out;
	
	c_addsub_0 add_inst (
		.A(a),      // input wire [31 : 0] A
		.B(b),      // input wire [31 : 0] B
		.CLK(clk),  // input wire CLK
		.CE(rst_n),    // input wire CE
		.S(add_out)      // output wire [31 : 0] S
	);
	
	mult_gen_0 mul_inst (
		.CLK(clk),  // input wire CLK
		.A(a),      // input wire [31 : 0] A
		.B(b),      // input wire [31 : 0] B
		.P(mul_out)      // output wire [63 : 0] P
	);
	
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
			;
        end
        else
        begin
            ;
        end
    end
endmodule