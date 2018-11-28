/************************************************************
*总体设计的思想是将神经网络的多个层次串联起来  然后在总体层次上根据上一层的结果情况 
*来触发下一层的执行
*每一层的数据流的起始是 一个DoubleDataBuf(可以作为一边写一边读的缓冲区)
*当这个DataBuf已经准备好来自于上一层的数据时 并且全局信号允许当前模块开始一次执行(防止后面的模块执行过慢导致数据堆积)时
*step1 全局控制状态机发送该层的触发信号 layer_enable
*step2 开始从自己这一层的输入DoubleDataBuf中读取数据将数据开始在自己内部的流程中执行 每一层自己保证自己的数据在内部不会出现拥塞
*step3 读取完成输入层的数据后 给出rd_en信号的下降沿 保证DoubleDataBuf中的状态切换 并向借此向全局状态机表示处理完毕的信息
*step4 数据在每一层处理完成后写入到下一层的DoubleDataBuf中 这个写入过程 需要由全局状态机保证安全性 不应该出现冲掉下一级未读数据的问题 
*************************************************************/
module CNN_TopDesign(
    clk,
    rst_n,
    work_enable,
    img_data_wr_ready,
    img_data_wr_en,
    img_data_addr,
    
    cnn_output
);
    parameter DATA_WIDTH = 16;
    parameter ADDR_WIDTH = 16;
    parameter WR_PORT_NUM = 1;
        
    input clk;
    input rst_n;
    input work_enable;
    input img_data_wr_en;
    input img_data_addr;
    input  [DATA_WIDTH-1:0] img_data_in;
    output [DATA_WIDTH-1: 0] cnn_output;
    output img_data_wr_ready;
    
    reg conv_2d_1_layer_enable;
    wire [DATA_WIDTH*6-1:0] conv2d1_2_pool1_bus; //conv2d_1 -> pool_1
    wire conv2d1_2_pool1_bus_wr_en;
    wire conv_2d_1_rd_en;
    
    //conv_2d_1 layer
    Conv2D_1 conv2d_1_inst(
        .clk(clk),
        .rst_n(rst_n),
        
        //conv2d_1 使能
        .layer_enable(conv_2d_1_layer_enable),
        
        //conv2d_1 数据输入信号
        .img_data_wr_en(img_data_wr_en),
        .img_data_in(img_data_in),
        .img_data_addr(img_data_addr),
        
        //conv2d_1 数据读取完成反馈
        .img_data_rd_en(conv_2d_1_rd_en),
        
        //输出到池化层的数据信号
        .pool_1_out_bus(conv2d1_2_pool1_bus),
        .pool_1_out_wr_en(conv2d1_2_pool1_bus_wr_en)
    );


endmodule