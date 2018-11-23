//在三维图像上一次性产生25 个地址 供
//先行后列的方式根据图像生成锚点 供地址生成器使用
//
module ConvAddressGen_3D_25P(
    clk,
    rst_n,
    enable,
    pause,
    out_depth,
    out_offset_NP
);
//define the size of input data
parameter ADDR_WIDTH = 16;

parameter DATA_HEIGHT = 35;
parameter DATA_WIDTH = 35;
parameter DATA_DEPTH = 1;

parameter KERNAL_HEIGHT = 5;
parameter KERNAL_WIDTH = 5;
parameter PORT_NUM = KERNAL_HEIGHT * KERNAL_WIDTH;

localparam ANCHOR_WIDTH_BOUNDARY = DATA_WIDTH - KERNAL_WIDTH + 1;
localparam ANCHOR_HEIGHT_BOUNDARY =  DATA_HEIGHT - KERNAL_HEIGHT + 1;
localparam ELEMENT_SIZE_2D = ANCHOR_WIDTH_BOUNDARY*ANCHOR_HEIGHT_BOUNDARY; 

input clk;
input rst_n;
input enable;
input pause;
/*
    output order
    [ 0(Anchor),  1,  2,  3,  4],
    [ 5,  6,  7,  8,  9],
    [10, 11, 12, 13, 14],
    [15, 16, 17, 18, 19],
    [20, 21, 22, 23, 24]
*/
output reg [7: 0] out_depth;
output [PORT_NUM*ADDR_WIDTH-1: 0] offset_NP;

wire [ADDR_WIDTH-1: 0] out_height_NP [ELEMENT_SIZE_2D-1:0];
wire [ADDR_WIDTH-1: 0] out_width_NP [ELEMENT_SIZE_2D-1:0];

wire [31:0] anchor_height;
wire [31:0] anchor_width;
reg [31:0] cnt;

ConvAnchorGen_2D #(
.ANCHOR_WIDTH_BOUNDARY(ANCHOR_WIDTH_BOUNDARY),
.ANCHOR_HEIGHT_BOUNDARY(ANCHOR_HEIGHT_BOUNDARY)
) anchor_inst1(
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable), //工作使能信号 1->0 复位内部状态
    .pause(pause), //工作暂停信号 0-1> 暂停迭代 保存内部状态
    .anchor_height(anchor_height),
    .anchor_width(anchor_width)
);

generate
genvar j;
    for(j=0;j < ELEMENT_SIZE_2D;j = j + 1)
    begin 
        ConstAddrMap #(    
            .PORT_NUM(1),
            .ADDR_WIDTH(16),
            .X_SIZE(35),
            .Y_SIZE(35))
        addr_map_inst(
            .x(out_width_NP[i]),
            .y(out_height_NP[i]),
            .offset(offset_NP[(i+1)*ADDR_WIDTH-1:i*ADDR_WIDTH])
        );
    end
endgenerate
        
generate
genvar i;
    for(i=0;i < ELEMENT_SIZE_2D;i = i + 1)
    begin 
        assign out_height_NP[i] = anchor_height + i / 5;
        assign out_width_NP[i] = anchor_width + i % 5;
    end
endgenerate

always @(posedge clk or negedge rst_n) 
begin 
    if (!rst_n)
    begin 
        out_depth <= 0;
        cnt <= 0;
    end 
    else
    begin
        if (!enable)
        begin 
            cnt <= 0;
        end 
        else if (!pause)
        begin
            if (cnt < ELEMENT_SIZE_2D - 1)
            begin
                cnt <= cnt + 1;
            end 
            else
            begin
                cnt <= 0;
                out_depth <= (out_depth >= DATA_DEPTH - 1) ? 0: out_depth + 1;
            end       
        end
    end 
end 
endmodule 
