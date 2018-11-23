//在二维图像上产生锚点的 横纵向步长可调
//先行后列的方式根据图像生成锚点 供地址生成器使用
//
//delay ? cycles
module AnchorGen_2D(
    clk,
    rst_n,
    enable, //工作使能信号 1->0 复位内部状态
    pause, //工作暂停信号 0-1> 暂停迭代 保存内部状态
    anchor_height,
    anchor_width
);

parameter ANCHOR_WIDTH_BOUNDARY = 31;
parameter ANCHOR_HEIGHT_BOUNDARY =  31;
parameter ANCHOR_HEIGHT_STEP = 1;
parameter ANCHOR_WIDTH_STEP = 1;

input clk;
input rst_n;
input enable; //工作使能信号 1->0 复位内部状态
input pause; //工作暂停信号 0-1> 暂停迭代 保存内部状态
output reg [31:0] anchor_height;
output reg [31:0] anchor_width;

//offset update 按照1尺度更新偏移坐标
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        anchor_height <= 0;
        anchor_width <= 0;
    end
    else
    begin
        if (!enable)
        begin
            anchor_height <= 0;
            anchor_width <= 0;
        end
        else   
        begin
            if (!pause)
            begin
                if (anchor_width < ANCHOR_WIDTH_BOUNDARY - ANCHOR_WIDTH_STEP)
                    anchor_width <= anchor_width  + ANCHOR_WIDTH_STEP;
                else 
                begin
                    anchor_width <= 0;
                    if (anchor_height < ANCHOR_HEIGHT_BOUNDARY - ANCHOR_HEIGHT_STEP)
                        anchor_height <= anchor_height + ANCHOR_HEIGHT_STEP;
                    else
                        anchor_height <= 0;
                end 
            end            
        end         
    end
end

endmodule