module Delay(
    clk,
    din,
    dout    
);
parameter WIDTH = 16;
parameter DELAY_CYCLE = 6;
input clk;
input [WIDTH - 1: 0] din;
output [WIDTH - 1: 0] dout;
 
reg [WIDTH - 1: 0] delay_regs [DELAY_CYCLE - 1:0];
integer i;
assign dout = delay_regs[DELAY_CYCLE - 1];
always @(posedge clk)
begin
    delay_regs[0] <= din;
    for (i = 1; i < DELAY_CYCLE; i = i + 1)
    begin
        delay_regs[i] <= delay_regs[i - 1];
    end 
end 
endmodule 