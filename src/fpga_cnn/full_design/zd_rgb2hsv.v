module MaxSig(
    sigR,
    sigG,
    sigB,
    max_sig,
    maxIsR,
    maxIsG,
    maxIsB,
);
input  [7:0] sigR;
input  [7:0] sigG;
input  [7:0] sigB;
output [7:0] max_sig;
output maxIsR;
output maxIsG;
output maxIsB;

wire [7:0] max_rg;

assign max_rg = sigR > sigG ? sigR : sigG;
assign max_sig = max_rg > sigB ? max_rg : sigB;
assign maxIsR = max_sig == sigR;
assign maxIsG = max_sig == sigG;
assign maxIsB = max_sig == sigB;

endmodule

module MinSig(
    sigR,
    sigG,
    sigB,
    min_sig,
    minIsR,
    minIsG,
    minIsB,
);
input  [7:0] sigR;
input  [7:0] sigG;
input  [7:0] sigB;
output [7:0] min_sig;
output minIsR;
output minIsG;
output minIsB;

wire [7:0] min_rg;

assign min_rg = sigR < sigG ? sigR : sigG;
assign min_sig = min_rg < sigB ? min_rg : sigB;
assign minIsR = min_sig == sigR;
assign minIsG = min_sig == sigG;
assign minIsB = min_sig == sigB;

endmodule

module RGB2HSV(
    rst_n,
    clk,
    din_r,
    din_g,
    din_b,
    dout_h,
    dout_s,
    dout_v
);
input rst_n;
input clk;
input [7: 0] din_r;
input [7: 0] din_g;
input [7: 0] din_b;

output reg [7: 0] dout_h;
output [7: 0] dout_s;
output [7: 0] dout_v;

wire [7:0] c_max;
wire [7:0] c_min;

reg [8: 0] h_up_r; //计算H时选择的分子 (G-B) (B-R) (R-G) 等 

reg [7: 0] dout_h_r; //加上颜色偏移的h
reg [15 : 0] h_up_r_30_r; 
wire [7: 0] cmin;
wire [7: 0] cmax;
wire [7: 0] delta;  //max - min
wire max_is_r;
wire max_is_g;
wire max_is_b;

assign delta = c_max - cmin;
assign dout_h_w = delta == 0 ? 0 : h_up_r_30_r / delta;

//assign dout_h = dout_h_r;
assign dout_s = cmax == 0 ? 0 : delta * 255; 
assign dout_v = cmax;

MaxSig Max_inst(
    .sigR(din_r),
    .sigG(din_g),
    .sigB(din_b),
    .max_sig(cmax),
    .maxIsR(max_is_r),
    .maxIsG(max_is_g),
    .maxIsB(max_is_b)
);

MinSig Min_inst(
    .sigR(din_r),
    .sigG(din_g),
    .sigB(din_b),
    .min_sig(cmin)
);

//计算h使用的除法器 dividend (G-B)*30 divisor delta

always @(din_r, din_g, din_b, max_is_r, max_is_g, max_is_b) 
begin
    if (max_is_r)
        h_up_r = din_g - din_b;
    else if (max_is_g)
        h_up_r = din_b - din_r;
    else
        h_up_r = din_r - din_g;
end

always @(max_is_r, max_is_g, max_is_b)
begin
    if (max_is_r)
        dout_h_r = dout_h_w;
    else if (max_is_g)
        dout_h_r = dout_h_w + 60;
    else if (max_is_b)
        dout_h_r = dout_h_w + 120;
    else
        dout_h_r = 0; 
end

always @(posedge clk)
begin
    if (!rst_n)
    begin
        h_up_r_30_r<=0;
        dout_h <= 0;
    end
    else
    begin 
       h_up_r_30_r <=  h_up_r * 30;
       dout_h <= dout_h_r;
    end
end

endmodule