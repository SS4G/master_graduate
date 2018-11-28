`timescale 10ns/10ns
module conv2d_tb;

integer i,j,k;

integer log_file;

reg clk;
reg rst_n;
reg conv_2d_1_layer_enable;
reg img_data_wr_en;
reg [15:0] img_data_in;
reg [15:0] img_data_addr;

wire conv_2d_1_rd_en;
wire conv2d1_2_pool1_bus_wr_en;

wire [15:0] conv2d1_2_pool1_data_bus;
wire [15:0] conv2d1_2_pool1_addr_bus;

wire [15:0] anchor_height;
wire [15:0] anchor_width;

wire [15:0] pool_1_out_addr;
//conv_2d_1 layer
Conv2D_1 conv2d_1_inst_dut(
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
    .pool_1_out_bus(conv2d1_2_pool1_data_bus),
    .pool_1_out_addr(conv2d1_2_pool1_addr_bus),
    .pool_1_out_wr_en(conv2d1_2_pool1_bus_wr_en)
);

initial
begin
    log_file = $fopen("D:\\workspace\\explain_cnn\\master_graduate\\src\\fpga_cnn\\full_design\\conv_2d.log", "w");
    rst_n = 0;
    conv_2d_1_layer_enable = 0;
    img_data_wr_en = 0;
    img_data_in = 0;
    img_data_addr = 0;
    clk = 0;
    #100;
    rst_n = 1;
    
    //开始像img buffer中写入数据 
    #105;
    img_data_wr_en = 1;
    
    # 8;
    for (i = 0; i < 35; i = i + 1)
    begin
        for (j = 0; j < 35; j = j + 1) 
        begin 
            @(posedge clk)
            img_data_addr = img_data_addr + 1;
            img_data_in = i*35 + j + 1;
        end 
    end 
    img_data_wr_en = 0;
    
    //使能conv2d_1 
    #100;
    conv_2d_1_layer_enable = 1;
    
    @(negedge conv_2d_1_rd_en)
    conv_2d_1_layer_enable = 0;
    //$display("conv calc finished!");
    
    
    #2000;
    
    img_data_wr_en = 0;
    img_data_in = 0;
    img_data_addr = 0;
    
    //开始像img buffer中写入数据 
    #303;
    img_data_wr_en = 1;
    
    # 8;
    for (i = 0; i < 35; i = i + 1)
    begin
        for (j = 0; j < 35; j = j + 1) 
        begin 
            @(posedge clk)
            img_data_addr = img_data_addr + 1;
            img_data_in = i*35 + j + 1;
        end 
    end 
    img_data_wr_en = 0;
    
    //使能conv2d_1 
    #100;
    conv_2d_1_layer_enable = 1;
    
    @(negedge conv_2d_1_rd_en)
    conv_2d_1_layer_enable = 0;
    //$display("conv calc finished!");
    
    # 1000;
    $finish;
end

always #10 clk = ~clk;

assign anchor_height = conv2d_1_inst_dut.conv_addr_gen_inst.anchor_height;
assign anchor_width = conv2d_1_inst_dut.conv_addr_gen_inst.anchor_width;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        
    end
    else
    begin
        if(conv2d1_2_pool1_bus_wr_en)
        begin
            //$display("addr %x %x", conv2d1_2_pool1_addr_bus, conv2d1_2_pool1_data_bus);
            $display("addr %d, %d", anchor_height, anchor_width);
            $fwrite(log_file, "addr %d, %d", anchor_height, anchor_width); 
        end 
    end 
end
endmodule