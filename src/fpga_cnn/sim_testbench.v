`timescale 10ns / 1ns
module logic_test;

reg [7:0] neg_num;
reg clk = 1'b0;
reg [3:0] cnt;
reg [3:0] in;
reg rst_n;
wire [3:0] output_signal;


initial
begin
neg_num = -1;
rst_n = 1;
clk = 0;
cnt = 0;
in = 0;
#30 rst_n = 0;
#30 rst_n = 1;
end

always #10 clk = ~clk; 

always @(posedge clk)
begin
    cnt <= cnt + 1;
end

//
top_model_szh DUT(
.rst_n(rst_n),
.clk(clk),
.in(in),
.out(output_signal)
);
endmodule 
