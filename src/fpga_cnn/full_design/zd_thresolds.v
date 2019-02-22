module HSV_Threshold(
    dinH,
    dinS,
    dinV,
    dout
);

input  [7: 0] dinH;
input  [7: 0] dinS;
input  [7: 0] dinV;
output [7: 0] dout;

parameter H_UPPER = 100;
parameter H_LOWER = 100;

parameter S_UPPER = 100;
parameter S_LOWER = 100;

parameter V_UPPER = 100;
parameter V_LOWER = 100;

assign dout = (dinH <= H_UPPER && dinH > H_LOWER) ? 8'd255: 0;

endmodule

module BinaryThreshold( 
    din,
    dout
);
input  [7: 0] din;
output [7: 0] dout;

parameter THRESHOLD = 10;
assign dout = din >= THRESHOLD ? 8'd255: 0;

endmodule