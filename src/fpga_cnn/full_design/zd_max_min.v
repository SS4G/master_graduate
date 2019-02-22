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


module MaxValue25P(
    in25P,
    max_out
);
parameter WIDTH = 8;
 
input [8 * 25 - 1: 0] in25P;
output [7: 0] max_out;

wire [WIDTH - 1: 0] m0;
wire [WIDTH - 1: 0] m1;
wire [WIDTH - 1: 0] m2;
wire [WIDTH - 1: 0] m3;
wire [WIDTH - 1: 0] m4;
wire [WIDTH - 1: 0] m5;
wire [WIDTH - 1: 0] mm6;
wire [WIDTH - 1: 0] mm7;

MaxValue4P M0_inst(
    .in4P(in25P[4*WIDTH-1: 0*WIDTH]),
    .max_out(m0)
);

MaxValue4P M1_inst(
    .in4P(in25P[8*WIDTH-1: 4*WIDTH]),
    .max_out(m1)
);

MaxValue4P M2_inst(
    .in4P(in25P[16*WIDTH-1: 8*WIDTH]),
    .max_out(m2)
);

MaxValue4P M3_inst(
    .in4P(in25P[20*WIDTH-1: 16*WIDTH]),
    .max_out(m3)
);

MaxValue4P M4_inst(
    .in4P(in25P[24*WIDTH-1: 20*WIDTH]),
    .max_out(m4)
);

MaxValue4P M5_inst(
    .in4P(in25P[24*WIDTH-1: 20*WIDTH]),
    .max_out(m5)
);

MaxValue4P M6_inst(
    .in4P({m0, m1, m2, m3}),
    .max_out(mm6)
);

assign mm7 = m5 > in25P[25*WIDTH-1: 24*WIDTH] ? m5 : in25P[25*WIDTH-1: 24*WIDTH];
assign max_out = mm7 > mm6 ? mm7 : mm6; 

endmodule

module MinValue4P(
    in4P,
    min_out
);
parameter WIDTH = 8;
input [4*WIDTH - 1 : 0] in4P;
output [WIDTH - 1: 0] min_out;

wire [WIDTH - 1: 0] m0;
wire [WIDTH - 1: 0] m1;
 
assign m0 = in4P[WIDTH - 1: 0] < in4P[2*WIDTH - 1: WIDTH] ? in4P[WIDTH - 1: 0]: in4P[2*WIDTH - 1: WIDTH]; 
assign m1 = in4P[3*WIDTH - 1: 2*WIDTH] < in4P[4*WIDTH - 1: 3*WIDTH] ? in4P[3*WIDTH - 1: 2*WIDTH]: in4P[4*WIDTH - 1: 3*WIDTH]; 
assign min_out = m0 > m1 ? m0: m1;
endmodule


module MinValue25P(
    in25P,
    min_out
);
parameter WIDTH = 8;
 
input [8 * 25 - 1: 0] in25P;
output [7: 0] min_out;

wire [WIDTH - 1: 0] m0;
wire [WIDTH - 1: 0] m1;
wire [WIDTH - 1: 0] m2;
wire [WIDTH - 1: 0] m3;
wire [WIDTH - 1: 0] m4;
wire [WIDTH - 1: 0] m5;
wire [WIDTH - 1: 0] mm6;
wire [WIDTH - 1: 0] mm7;

MinValue4P M0_inst(
    .in4P(in25P[4*WIDTH-1: 0*WIDTH]),
    .min_out(m0)
);

MinValue4P M1_inst(
    .in4P(in25P[8*WIDTH-1: 4*WIDTH]),
    .min_out(m1)
);

MinValue4P M2_inst(
    .in4P(in25P[16*WIDTH-1: 8*WIDTH]),
    .min_out(m2)
);

MinValue4P M3_inst(
    .in4P(in25P[20*WIDTH-1: 16*WIDTH]),
    .min_out(m3)
);

MinValue4P M4_inst(
    .in4P(in25P[24*WIDTH-1: 20*WIDTH]),
    .min_out(m4)
);

MinValue4P M5_inst(
    .in4P(in25P[24*WIDTH-1: 20*WIDTH]),
    .min_out(m5)
);

MinValue4P M6_inst(
    .in4P({m0, m1, m2, m3}),
    .min_out(mm6)
);

assign mm7 = m5 < in25P[25*WIDTH-1: 24*WIDTH] ? m5 : in25P[25*WIDTH-1: 24*WIDTH];
assign max_out = mm7 < mm6 ? mm7 : mm6; 

endmodule

module Blur25P(
    in25P,
    blur_out
);
parameter WIDTH = 8;
input [25*WIDTH - 1 : 0] in25P;
output [WIDTH - 1: 0] blur_out;


wire [31:0] p00 = in25P[WIDTH * 01 - 1 : WIDTH * 00];
wire [31:0] p01 = in25P[WIDTH * 02 - 1 : WIDTH * 01];
wire [31:0] p02 = in25P[WIDTH * 03 - 1 : WIDTH * 02];
wire [31:0] p03 = in25P[WIDTH * 04 - 1 : WIDTH * 03];
wire [31:0] p04 = in25P[WIDTH * 05 - 1 : WIDTH * 04];
wire [31:0] p05 = in25P[WIDTH * 06 - 1 : WIDTH * 05];
wire [31:0] p06 = in25P[WIDTH * 07 - 1 : WIDTH * 06];
wire [31:0] p07 = in25P[WIDTH * 08 - 1 : WIDTH * 07];
wire [31:0] p08 = in25P[WIDTH * 09 - 1 : WIDTH * 08];
wire [31:0] p09 = in25P[WIDTH * 10 - 1 : WIDTH * 09];
wire [31:0] p10 = in25P[WIDTH * 11 - 1 : WIDTH * 10];
wire [31:0] p11 = in25P[WIDTH * 12 - 1 : WIDTH * 11];
wire [31:0] p12 = in25P[WIDTH * 13 - 1 : WIDTH * 12];
wire [31:0] p13 = in25P[WIDTH * 14 - 1 : WIDTH * 13];
wire [31:0] p14 = in25P[WIDTH * 15 - 1 : WIDTH * 14];
wire [31:0] p15 = in25P[WIDTH * 16 - 1 : WIDTH * 15];
wire [31:0] p16 = in25P[WIDTH * 17 - 1 : WIDTH * 16];
wire [31:0] p17 = in25P[WIDTH * 18 - 1 : WIDTH * 17];
wire [31:0] p18 = in25P[WIDTH * 19 - 1 : WIDTH * 18];
wire [31:0] p19 = in25P[WIDTH * 20 - 1 : WIDTH * 19];
wire [31:0] p20 = in25P[WIDTH * 21 - 1 : WIDTH * 20];
wire [31:0] p21 = in25P[WIDTH * 22 - 1 : WIDTH * 21];
wire [31:0] p22 = in25P[WIDTH * 23 - 1 : WIDTH * 22];
wire [31:0] p23 = in25P[WIDTH * 24 - 1 : WIDTH * 23];
wire [31:0] p24 = in25P[WIDTH * 25 - 1 : WIDTH * 24];
wire [31:0] m1;
wire [31:0] m2;
wire [31:0] m0;
 
assign p00 = in25P[WIDTH * 01 - 1 : WIDTH * 00];
assign p01 = in25P[WIDTH * 02 - 1 : WIDTH * 01];
assign p02 = in25P[WIDTH * 03 - 1 : WIDTH * 02];
assign p03 = in25P[WIDTH * 04 - 1 : WIDTH * 03];
assign p04 = in25P[WIDTH * 05 - 1 : WIDTH * 04];
assign p05 = in25P[WIDTH * 06 - 1 : WIDTH * 05];
assign p06 = in25P[WIDTH * 07 - 1 : WIDTH * 06];
assign p07 = in25P[WIDTH * 08 - 1 : WIDTH * 07];
assign p08 = in25P[WIDTH * 09 - 1 : WIDTH * 08];
assign p09 = in25P[WIDTH * 10 - 1 : WIDTH * 09];
assign p10 = in25P[WIDTH * 11 - 1 : WIDTH * 10];
assign p11 = in25P[WIDTH * 12 - 1 : WIDTH * 11];
assign p12 = in25P[WIDTH * 13 - 1 : WIDTH * 12];
assign p13 = in25P[WIDTH * 14 - 1 : WIDTH * 13];
assign p14 = in25P[WIDTH * 15 - 1 : WIDTH * 14];
assign p15 = in25P[WIDTH * 16 - 1 : WIDTH * 15];
assign p16 = in25P[WIDTH * 17 - 1 : WIDTH * 16];
assign p17 = in25P[WIDTH * 18 - 1 : WIDTH * 17];
assign p18 = in25P[WIDTH * 19 - 1 : WIDTH * 18];
assign p19 = in25P[WIDTH * 20 - 1 : WIDTH * 19];
assign p20 = in25P[WIDTH * 21 - 1 : WIDTH * 20];
assign p21 = in25P[WIDTH * 22 - 1 : WIDTH * 21];
assign p22 = in25P[WIDTH * 23 - 1 : WIDTH * 22];
assign p23 = in25P[WIDTH * 24 - 1 : WIDTH * 23];
assign p24 = in25P[WIDTH * 25 - 1 : WIDTH * 24];
 
 
assign m0 = ((p00 + p01) + (p02 + p03)) + ((p04 + p05) + (p06 + p07));
assign m1 = ((p08 + p09) + (p10 + p11)) + ((p12 + p13) + (p14 + p15));
assign m2 = ((p16 + p17) + (p18 + p19)) + ((p20 + p21) + (p22 + p23));
assign blur_out = ((m0 + m1) + (m2 + p24)) / 25;
 
endmodule

