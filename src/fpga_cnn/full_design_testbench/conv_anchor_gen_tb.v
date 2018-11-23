`timescale 10ns/10ns
module ConvAnchorGen_2D_tb;
reg rst_n;
reg clk;

integer i, j, k;
integer start;
integer out_file;

reg [15:0] tmp;
reg en;

wire [15:0] out;
integer cnt;

wire [31:0] height_out;
wire [31:0] width_out; 

initial
begin
    clk = 0;
    rst_n = 0;  
    cnt = 0;    
    en = 0;
    
    #100;
    rst_n = 1;
    
    #30;
    en = 1;
     
    #30000;
    $finish;
end 

always
begin
    #5 clk = ~clk;
end 

always @(posedge clk)
begin
    cnt <= cnt + 1;
end 
 
ConvAnchorGen_2D DUT(
    .clk(clk),
    .rst_n(rst_n),
    .enable(en), //工作使能信号 1->0 复位内部状�??
    .pause(0), //工作暂停信号 0-1> 暂停迭代 保存内部状�??
    .anchor_height(height_out),
    .anchor_width(width_out)
);

initial
begin
    out_file = $fopen("D:\\workspace\\explain_cnn\\master_graduate\\src\\fpga_cnn\\full_design_testbench\\conv2d_anchor_file.txt", "w");
end

always @(height_out, width_out)
begin 
    $fwrite(out_file, "%d,%d\n", $signed(width_out), $signed(height_out));
end

endmodule