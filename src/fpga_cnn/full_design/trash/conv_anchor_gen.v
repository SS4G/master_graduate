
//在二维图像上产生锚点的
//按照池化的方式来产生数据 可以和池化一起做成流水线
module ConvAnchorGen_2D(
    clk,
    rst_n,
    enable, //工作使能信号 1->0 复位内部状态
    pause, //工作暂停信号 0-1> 暂停迭代 保存内部状态
    anchor_height,
    anchor_width
);

parameter DATA_HEIGHT = 35;
parameter DATA_WIDTH = 35;
parameter KERNAL_WIDTH = 5;
parameter KERNAL_HEIGHT = 5;
parameter POOL_WIDTH = 2;
parameter POOL_HEIGHT = 2;

localparam ANCHOR_WIDTH_BOUNDARY = DATA_WIDTH - KERNAL_WIDTH + 1;
localparam ANCHOR_HEIGHT_BOUNDARY =  DATA_HEIGHT - KERNAL_HEIGHT + 1;


input clk;
input rst_n;
input enable; //工作使能信号 1->0 复位内部状态
input pause; //工作暂停信号 0-1> 暂停迭代 保存内部状态
output [31:0] anchor_height;
output [31:0] anchor_width;

wire idx_update_en; //以更新池化尺度更新指示
wire next_add_width_offset;//下次更新width_offset 指示
wire next_add_height_offset;//下次更新height_offset 指示
wire update_idx_at_pool_size; 

reg [31:0] width_idx;
reg [31:0] height_idx;
reg [31:0] width_offset;
reg [31:0] height_offset;

//按照 pool 尺寸更新基准坐标



assign anchor_height = height_idx + height_offset;
assign anchor_width = width_idx + width_offset;

assign idx_update_en = update_idx_at_pool_size || update_idx_at_boundary;

//内部偏移已经扫描完一个池化部分 需要正常更新 idx
assign update_idx_at_pool_size = ((height_offset == (POOL_HEIGHT - 1)) && (width_offset == (POOL_WIDTH - 1))); 

//内部偏移下一步将会越界 需要提前更新idx
assign update_idx_at_boundary = (next_add_width_offset && anchor_width == ANCHOR_WIDTH_BOUNDARY - 1) || (next_add_height_offset && anchor_height == ANCHOR_HEIGHT_BOUNDARY - 1); 

assign next_add_width_offset = (!next_add_height_offset) && width_offset < POOL_WIDTH - 1;
assign next_add_height_offset = height_offset < POOL_HEIGHT - 1;


//offset update 按照1尺度更新偏移坐标
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        width_offset <= 0;
        height_offset <= 0;
    end
    else
    begin
        if (!enable)
        begin
            width_offset <= 0;
            height_offset <= 0;
        end
        else   
        begin
            if (!pause)
            begin
                if (!idx_update_en) //没有遇到越界 需要更新池化尺度的时候
                begin
                    if (height_offset < POOL_HEIGHT - 1)
                        height_offset <= height_offset + 1;
                    else 
                    begin
                        height_offset <= 0;
                        if (width_offset < POOL_WIDTH - 1)
                            width_offset <= width_offset + 1;
                        else
                            width_offset <= 0;
                    end 
                end 
                else //更新偏移过程中可能的越界
                begin
                    width_offset <= 0;
                    height_offset <= 0;
                end
            end            
        end         
    end
end


//anchor update
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        width_idx <= 0;
        height_idx <= 0;
    end
    else
    begin
        if (!enable)
        begin
            width_idx <= 0;
            height_idx <= 0;
        end
        else   
        begin
            if (!pause && idx_update_en)
            begin
                if (width_idx < ANCHOR_WIDTH_BOUNDARY - 1)
                    width_idx <= width_idx + POOL_WIDTH;
                else
                begin
                    width_idx <= 0;
                    if (height_idx < ANCHOR_HEIGHT_BOUNDARY - 1)
                    begin
                        height_idx <= height_idx + POOL_HEIGHT;
                        width_idx <= 0;
                    end
                    else
                        height_idx <= 0;
                end
            end            
        end         
    end
end
endmodule