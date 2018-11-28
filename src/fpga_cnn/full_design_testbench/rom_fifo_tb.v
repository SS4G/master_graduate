`timescale 1ns/1ns;
module rom_fifo_tb;

reg clk;
reg rst_n;
reg rom_addr;
wire [2399:0] kernal_out;
reg [15:0] cnt;
reg wr_en;
reg rd_en;
wire full;
wire empty;
wire [15:0] dout;
wire [3:0] data_count;

rom_conv1_kerbia_param keral_bias_inst(
  .clka(clk),    // input wire clka
  .addra(rom_addr),  // input wire [0 : 0] addra 0输出kernal的数据 1输出bias的数据
  .douta(kernal_out)  // output wire [2399 : 0] douta 
);


fifo_for_addr_16b DUT_FIFO (
  .clk(clk),                  // input wire clk
  .rst(~rst),                  // input wire rst 
  .din(cnt),                  // input wire [15 : 0] din
  .wr_en(wr_en),              // input wire wr_en
  .rd_en(rd_en),              // input wire rd_en
  .dout(dout),                // output wire [15 : 0] dout
  .full(full),                // output wire full
  .empty(empty),              // output wire empty
  //.data_count(data_count),    // output wire [3 : 0] data_count
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);

initial
begin
    clk = 0;
    rst_n = 0;
    # 100;
    rst_n = 1;
    rom_addr = 0;
    # 101;
    rom_addr = 1;
    # 50;
    rom_addr = 0;
    # 50;
    rom_addr = 1;
    #1000;
    $finish;
end 

initial
begin
    wr_en = 0;
    rd_en = 0;
    #100;
    
    wr_en = 1;
    #50;
    rd_en = 1;
    #50;
    wr_en = 0;
    
    #1000;
    $finish;
end 

always #5 clk = ~clk;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cnt <= 6;
    end 
    else
    begin
        cnt <= cnt+2;
    end 
end 
endmodule 