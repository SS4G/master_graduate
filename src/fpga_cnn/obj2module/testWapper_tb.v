`timescale 1ns / 1ps
module TestWarpper_tb;

reg rst_n;
reg clk = 1'b0;
reg begin_wr;

wire [7:0] output_signal;
wire out_en;


initial
begin
rst_n = 1;
clk = 0;
cnt = 0;
in = 0;
#30 rst_n = 0;
#30 rst_n = 1;
# 1000 begin_wr = 1'b1;
# 1000 begin_wr = 1'b0;
# 1000;
end

always #10 clk = ~clk; 

always @(posedge clk)
begin
    cnt <= cnt + 1;
end

TestWapper DUT(
    .clk(clk),
	.rst_n(rst_n),
	.begin_wr(begin_wr),
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
