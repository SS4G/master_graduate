module Shift_Ram(
    rst_n,
    clk,
    we,
    din,
    wr_addr,
    rd_addr,
    dout
);

parameter DEPTH = 16;
parameter DATA_WIDTH = 16; 
parameter LENGTH = 25;//行缓冲的word数 

input rst_n;
input clk;
input we;

input  [DATA_WIDTH-1:0] din;
input  [7:0] wr_addr;
input  [7:0] rd_addr;
output [DATA_WIDTH*LENGTH-1:0] dout;

reg [DATA_WIDTH*LENGTH-1:0] mem [DEPTH-1:0];
assign dout = mem[rd_addr];

integer p;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        for (p = 0; p < DEPTH; p = p + 1)
        begin
            mem[p] <= 0;
        end 
    end
    else
    begin
        if (we)
        begin 
            mem[wr_addr] <= {din, mem[wr_addr][DATA_WIDTH*LENGTH-1: DATA_WIDTH]}; 
        end   
    end
end 
endmodule 