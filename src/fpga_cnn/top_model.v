`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/15 20:24:53
// Design Name: 
// Module Name: top_model
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top_model_szh(
    rst_n,
	clk,
    in,
    out
);
	
input rst_n;
input clk;
input [3:0] in;
output [3:0] out;

assign out[0] = in[0] && in[1] && in[2] && in[3];
assign out[1] = in[0] || in[1] || in[2] || in[3];

reg[31:0] cnt;
assign out[3:2] = cnt[22:21];

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) 
	begin
	    cnt <= 0;
	end 
    else
	begin
	    cnt <= cnt + 1;
	end 
end
endmodule
