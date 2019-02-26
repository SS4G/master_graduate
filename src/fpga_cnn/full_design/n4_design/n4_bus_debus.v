module debus_1to26(
    com_bus_in,
    sep_bus_out00,
    sep_bus_out01,
    sep_bus_out02,
    sep_bus_out03,
    sep_bus_out04,
    sep_bus_out05,
    sep_bus_out06,
    sep_bus_out07,
    sep_bus_out08,
    sep_bus_out09,
    sep_bus_out10,
    sep_bus_out11,
    sep_bus_out12,
    sep_bus_out13,
    sep_bus_out14,
    sep_bus_out15,
    sep_bus_out16,
    sep_bus_out17,
    sep_bus_out18,
    sep_bus_out19,
    sep_bus_out20,
    sep_bus_out21,
    sep_bus_out22,
    sep_bus_out23,
    sep_bus_out24,
    sep_bus_out25
);
parameter WIDTH = 16;

input [WIDTH*26-1: 0] com_bus_in;

output [WIDTH-1:0] sep_bus_out00;
output [WIDTH-1:0] sep_bus_out01;
output [WIDTH-1:0] sep_bus_out02;
output [WIDTH-1:0] sep_bus_out03;
output [WIDTH-1:0] sep_bus_out04;
output [WIDTH-1:0] sep_bus_out05;
output [WIDTH-1:0] sep_bus_out06;
output [WIDTH-1:0] sep_bus_out07;
output [WIDTH-1:0] sep_bus_out08;
output [WIDTH-1:0] sep_bus_out09;
output [WIDTH-1:0] sep_bus_out10;
output [WIDTH-1:0] sep_bus_out11;
output [WIDTH-1:0] sep_bus_out12;
output [WIDTH-1:0] sep_bus_out13;
output [WIDTH-1:0] sep_bus_out14;
output [WIDTH-1:0] sep_bus_out15;
output [WIDTH-1:0] sep_bus_out16;
output [WIDTH-1:0] sep_bus_out17;
output [WIDTH-1:0] sep_bus_out18;
output [WIDTH-1:0] sep_bus_out19;
output [WIDTH-1:0] sep_bus_out20;
output [WIDTH-1:0] sep_bus_out21;
output [WIDTH-1:0] sep_bus_out22;
output [WIDTH-1:0] sep_bus_out23;
output [WIDTH-1:0] sep_bus_out24;
output [WIDTH-1:0] sep_bus_out25;

assign sep_bus_out00 = com_bus_in[01*WIDTH-1:00*WIDTH];
assign sep_bus_out01 = com_bus_in[02*WIDTH-1:01*WIDTH];
assign sep_bus_out02 = com_bus_in[03*WIDTH-1:02*WIDTH];
assign sep_bus_out03 = com_bus_in[04*WIDTH-1:03*WIDTH];
assign sep_bus_out04 = com_bus_in[05*WIDTH-1:04*WIDTH];
assign sep_bus_out05 = com_bus_in[06*WIDTH-1:05*WIDTH];
assign sep_bus_out06 = com_bus_in[07*WIDTH-1:06*WIDTH];
assign sep_bus_out07 = com_bus_in[08*WIDTH-1:07*WIDTH];
assign sep_bus_out08 = com_bus_in[09*WIDTH-1:08*WIDTH];
assign sep_bus_out09 = com_bus_in[10*WIDTH-1:09*WIDTH];
assign sep_bus_out10 = com_bus_in[11*WIDTH-1:10*WIDTH];
assign sep_bus_out11 = com_bus_in[12*WIDTH-1:11*WIDTH];
assign sep_bus_out12 = com_bus_in[13*WIDTH-1:12*WIDTH];
assign sep_bus_out13 = com_bus_in[14*WIDTH-1:13*WIDTH];
assign sep_bus_out14 = com_bus_in[15*WIDTH-1:14*WIDTH];
assign sep_bus_out15 = com_bus_in[16*WIDTH-1:15*WIDTH];
assign sep_bus_out16 = com_bus_in[17*WIDTH-1:16*WIDTH];
assign sep_bus_out17 = com_bus_in[18*WIDTH-1:17*WIDTH];
assign sep_bus_out18 = com_bus_in[19*WIDTH-1:18*WIDTH];
assign sep_bus_out19 = com_bus_in[20*WIDTH-1:19*WIDTH];
assign sep_bus_out20 = com_bus_in[21*WIDTH-1:20*WIDTH];
assign sep_bus_out21 = com_bus_in[22*WIDTH-1:21*WIDTH];
assign sep_bus_out22 = com_bus_in[23*WIDTH-1:22*WIDTH];
assign sep_bus_out23 = com_bus_in[24*WIDTH-1:23*WIDTH];
assign sep_bus_out24 = com_bus_in[25*WIDTH-1:24*WIDTH];
assign sep_bus_out25 = com_bus_in[26*WIDTH-1:25*WIDTH];
endmodule 

module bus_26to1(
    com_bus_out,
    sep_bus_in00,
    sep_bus_in01,
    sep_bus_in02,
    sep_bus_in03,
    sep_bus_in04,
    sep_bus_in05,
    sep_bus_in06,
    sep_bus_in07,
    sep_bus_in08,
    sep_bus_in09,
    sep_bus_in10,
    sep_bus_in11,
    sep_bus_in12,
    sep_bus_in13,
    sep_bus_in14,
    sep_bus_in15,
    sep_bus_in16,
    sep_bus_in17,
    sep_bus_in18,
    sep_bus_in19,
    sep_bus_in20,
    sep_bus_in21,
    sep_bus_in22,
    sep_bus_in23,
    sep_bus_in24,
    sep_bus_in25
);
parameter WIDTH = 16;

output [WIDTH*26-1: 0] com_bus_out;

input [WIDTH-1:0] sep_bus_in00;
input [WIDTH-1:0] sep_bus_in01;
input [WIDTH-1:0] sep_bus_in02;
input [WIDTH-1:0] sep_bus_in03;
input [WIDTH-1:0] sep_bus_in04;
input [WIDTH-1:0] sep_bus_in05;
input [WIDTH-1:0] sep_bus_in06;
input [WIDTH-1:0] sep_bus_in07;
input [WIDTH-1:0] sep_bus_in08;
input [WIDTH-1:0] sep_bus_in09;
input [WIDTH-1:0] sep_bus_in10;
input [WIDTH-1:0] sep_bus_in11;
input [WIDTH-1:0] sep_bus_in12;
input [WIDTH-1:0] sep_bus_in13;
input [WIDTH-1:0] sep_bus_in14;
input [WIDTH-1:0] sep_bus_in15;
input [WIDTH-1:0] sep_bus_in16;
input [WIDTH-1:0] sep_bus_in17;
input [WIDTH-1:0] sep_bus_in18;
input [WIDTH-1:0] sep_bus_in19;
input [WIDTH-1:0] sep_bus_in20;
input [WIDTH-1:0] sep_bus_in21;
input [WIDTH-1:0] sep_bus_in22;
input [WIDTH-1:0] sep_bus_in23;
input [WIDTH-1:0] sep_bus_in24;
input [WIDTH-1:0] sep_bus_in25;

assign  com_bus_out[01*WIDTH-1:00*WIDTH]= sep_bus_in00;
assign  com_bus_out[02*WIDTH-1:01*WIDTH]= sep_bus_in01;
assign  com_bus_out[03*WIDTH-1:02*WIDTH]= sep_bus_in02;
assign  com_bus_out[04*WIDTH-1:03*WIDTH]= sep_bus_in03;
assign  com_bus_out[05*WIDTH-1:04*WIDTH]= sep_bus_in04;
assign  com_bus_out[06*WIDTH-1:05*WIDTH]= sep_bus_in05;
assign  com_bus_out[07*WIDTH-1:06*WIDTH]= sep_bus_in06;
assign  com_bus_out[08*WIDTH-1:07*WIDTH]= sep_bus_in07;
assign  com_bus_out[09*WIDTH-1:08*WIDTH]= sep_bus_in08;
assign  com_bus_out[10*WIDTH-1:09*WIDTH]= sep_bus_in09;
assign  com_bus_out[11*WIDTH-1:10*WIDTH]= sep_bus_in10;
assign  com_bus_out[12*WIDTH-1:11*WIDTH]= sep_bus_in11;
assign  com_bus_out[13*WIDTH-1:12*WIDTH]= sep_bus_in12;
assign  com_bus_out[14*WIDTH-1:13*WIDTH]= sep_bus_in13;
assign  com_bus_out[15*WIDTH-1:14*WIDTH]= sep_bus_in14;
assign  com_bus_out[16*WIDTH-1:15*WIDTH]= sep_bus_in15;
assign  com_bus_out[17*WIDTH-1:16*WIDTH]= sep_bus_in16;
assign  com_bus_out[18*WIDTH-1:17*WIDTH]= sep_bus_in17;
assign  com_bus_out[19*WIDTH-1:18*WIDTH]= sep_bus_in18;
assign  com_bus_out[20*WIDTH-1:19*WIDTH]= sep_bus_in19;
assign  com_bus_out[21*WIDTH-1:20*WIDTH]= sep_bus_in20;
assign  com_bus_out[22*WIDTH-1:21*WIDTH]= sep_bus_in21;
assign  com_bus_out[23*WIDTH-1:22*WIDTH]= sep_bus_in22;
assign  com_bus_out[24*WIDTH-1:23*WIDTH]= sep_bus_in23;
assign  com_bus_out[25*WIDTH-1:24*WIDTH]= sep_bus_in24;
assign  com_bus_out[26*WIDTH-1:25*WIDTH]= sep_bus_in25;
endmodule 
