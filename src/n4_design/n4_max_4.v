module MaxValue4P(
    in4P,
    max_out
);
parameter WIDTH = 8;
input [4*WIDTH - 1 : 0] in4P;
output [WIDTH - 1: 0] max_out;

wire [WIDTH - 1: 0] m0;
wire [WIDTH - 1: 0] m1;
 
assign m0 = in4P[WIDTH - 1: 0] > in4P[2*WIDTH - 1: WIDTH] ? in4P[WIDTH - 1: 0]: in4P[2*WIDTH - 1: WIDTH]; 
assign m1 = in4P[3*WIDTH - 1: 2*WIDTH] > in4P[4*WIDTH - 1: 3*WIDTH] ? in4P[3*WIDTH - 1: 2*WIDTH]: in4P[4*WIDTH - 1: 3*WIDTH]; 
assign max_out = m0 > m1 ? m0: m1;
endmodule