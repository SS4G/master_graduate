module pool1_tb;


integer i,j,k;

integer log_file;

reg clk;
reg rst_n;
reg pool_1_layer_enable;
reg conv_2d_wr_en;
reg [15:0] conv_2d_data_in;
reg [15:0] conv_2d_data_addr;

reg pool_1_rd_en;
wire pool1_bus_wr_en;

reg [15:0] pool1_data_bus;
reg [15:0] pool1_addr_bus;


wire [15:0] anchor_height;
wire [15:0] anchor_width;

wire [15:0] pool_1_out_addr;
//conv_2d_1 layer

initial
begin
    #100; 
    pool_1_rd_en = 0;
    @(posedge conv_2d_wr_en)
    # 100 pool_1_rd_en = 1;
    # 5000 pool_1_rd_en = 0;
    
end

initial
begin
    log_file = $fopen("D:\\workspace\\explain_cnn\\master_graduate\\src\\fpga_cnn\\full_design\\conv_2d.log", "w");
    rst_n = 0;
    pool_1_rd_en = 0;
    pool_1_layer_enable = 0;
    conv_2d_wr_en = 0;
    conv_2d_data_in = 0;
    conv_2d_data_addr = 0;
    pool1_data_bus = 0;
    pool1_addr_bus = 0;
    clk = 0;
    #100;
    rst_n = 1;
    
    //开始像img buffer中写入数据 
    #105;
    conv_2d_wr_en = 1;
    
    # 8;
    for (i = 0; i < 35; i = i + 1)
    begin
        for (j = 0; j < 35; j = j + 1) 
        begin 
            @(posedge clk)
            pool1_data_bus = pool1_data_bus + 1;
            pool1_addr_bus = pool1_addr_bus + 1;
        end 
    end 
    conv_2d_wr_en = 0;
    
    //使能conv2d_1 
    #100;
    pool_1_layer_enable = 1;
    
    @(negedge pool_1_rd_en)
    pool_1_layer_enable = 0;
    //$display("conv calc finished!");
    
    
    #2000;
    
    conv_2d_wr_en = 0;
    conv_2d_data_in = 0;
    conv_2d_data_addr = 0;
    
    //开始像img buffer中写入数据 
    #303;
    conv_2d_wr_en = 1;
    
    # 8;
    for (i = 0; i < 35; i = i + 1)
    begin
        for (j = 0; j < 35; j = j + 1) 
        begin 
            @(posedge clk)
            pool1_data_bus = pool1_data_bus + 1;
            pool1_addr_bus = pool1_addr_bus + 1;
        end 
    end 
    conv_2d_wr_en = 0;
    
    //使能conv2d_1 
    #100;
    pool_1_layer_enable = 1;
    
    @(negedge pool_1_rd_en)
    pool_1_layer_enable = 0;
    //$display("conv calc finished!");
    
    # 1000;
    $finish;
end

always #10 clk = ~clk;

endmodule 