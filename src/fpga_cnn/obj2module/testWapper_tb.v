`timescale 1ns / 1ps
module TestWarpper_tb;

reg rst_n;
reg clk = 1'b0;
reg [3:0] cnt;
wire [7:0] output_signal;
wire out_en;

wire [31:0] add_output;
wire [63:0] mul_output;

reg [31:0] a;
reg [31:0] b;

initial
begin
neg_num = -1;
rst_n = 1;
clk = 0;
cnt = 0;
in = 0;
#30 rst_n = 0;
#30 rst_n = 1;
a = 11;
b = -15;
end

always #10 clk = ~clk; 

always @(posedge clk)
begin
    cnt <= cnt + 1;
end

TestWapper DUT(
    .clk(),
	.rst_n(),
	.begin_wr(),
	.a_0(8'h0),
	.a_1(8'h1),
	.a_2(8'h2),
	.a_3(8'h3),
	.a_4(8'h4),
	.a_5(8'h5),
	.a_6(8'h6),
	.a_7(8'h7),
	.dout(output_signal),
	.outen(out_en)
);

endmodule 
