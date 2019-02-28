module Den1_Src_buf(
    rst    
); 

parameter DEPTH = 16;
parameter DATA_WIDTH = 16;
parameter LENGTH = 25;

input  clk;
input  rst_n;
input  we;
input  wr_addr;
input  rd_addr;
input  [DATA_WIDTH-1:0] din;
input  [7:0] wr_addr;
input  [7:0] rd_addr;
output [DATA_WIDTH*LENGTH-1:0] dout;

reg [DATA_WIDTH*LENGTH-1:0] mem [DEPTH-1:0];
assign dout = mem[rd_addr];


Shift_Ram #(.DEPTH(16), DATA_WIDTH(16), .LENGTH(25)) Den1_src_buf(
    .rst_n(rst_n),
    .clk(clk),
    .we(),
    .din(),
    .wr_addr(),
    .rd_addr(),
    .dout()
);

endmodule 