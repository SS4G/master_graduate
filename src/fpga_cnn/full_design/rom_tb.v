`timescale 1ns/1ns;
module rom_tb;
 
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
reg [15:0] data_in;

dataBuf_1024 your_instance_name (
  .clka(clk),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [10 : 0] addra
  .dina(data_in),    // input wire [15 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(addrb),  // input wire [10 : 0] addrb
  .doutb(doutb)  // output wire [15 : 0] doutb
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
endmodule 