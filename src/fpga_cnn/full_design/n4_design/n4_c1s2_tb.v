module n4_c1s2_tb;
reg  clk;
reg  we;
reg  layer_c1s2_en;
reg  [31:0] wr_addr;
reg  [15:0] din;
reg  [32*5-1:0] rd_addr_5P_r;
wire [32*5-1:0] rd_addr_5P_w;
wire [15:0] wr_data_out_1P;
wire [31:0] wr_addr_out_1P;
wire [15:0] dout_w [4:0];
wire [31:0] a0;
wire [31:0] a1;
wire [31:0] a2;
wire [31:0] a3;
wire [31:0] a4;
wire [31:0] a5;


always #5 clk = ~clk;

integer i,j,k;

initial 
begin
    rst_n = 0;
    din = 999;
    we = 0;
    wr_addr =0;
    clk = 0;
    rd_addr_5P_r =0;
    #100;
    we = 1;
    #3;
    for (i = 0; i < 6*1024; i = i + 1)
    begin
        @(posedge clk)
        din <= i + 10000;
        wr_addr <= i;
    end
    #1;
    we = 0;
    #1000;
    /*
    for (i = 0; i < 6*1024; i = i + 1)
    begin
        @(posedge clk)
        //din <= i + 10000;
        #5;
        for (j = 0; j < 5; j = j + 1)
        begin
            rd_addr_5P_r[32*(0 + 1):0*32] <= i + 0;
            rd_addr_5P_r[32*(1 + 1):1*32] <= i + 1;
            rd_addr_5P_r[32*(2 + 1):2*32] <= i + 2;
            rd_addr_5P_r[32*(3 + 1):3*32] <= i + 3;
            rd_addr_5P_r[32*(4 + 1):4*32] <= i + 4;
        end
    end*/
end 

assign a0 = rd_addr_5P_r[32*(0 + 1):0*32];
assign a1 = rd_addr_5P_r[32*(1 + 1):1*32];
assign a2 = rd_addr_5P_r[32*(2 + 1):2*32];
assign a3 = rd_addr_5P_r[32*(3 + 1):3*32];
assign a4 = rd_addr_5P_r[32*(4 + 1):4*32];

genvar p;
generate 
    for (p = 0; p < 5; p = p + 1)
    begin
        //port b in 
        //port a out
        blk_mem_16b_6K data_buf (
          .clka(clk),    // input wire clka
          .wea(1'b0),      // input wire [0 : 0] wea
          .addra(rd_addr_5P_w[32 * (p + 1): 32 * p]),  // input wire [10 : 0] addra
          .dina(0),    // input wire [7 : 0] dina
          .douta(dout_w[p]),  // output wire [7 : 0] douta
          .clkb(clk),    // input wire clkb
          .web(we),      // input wire [0 : 0] web
          .addrb(wr_addr),  // input wire [10 : 0] addrb
          .dinb(din),    // input wire [7 : 0] dinb
          .doutb()  // output wire [7 : 0] doutb
        );
    end
endgenerate

C1S2_layer DUT(

.clk(clk),
.rst_n(rst_n),

.en(layer_c1s2_en),
.work_finished(work_fin_sig),

.rd_data_in_5P({dout_w[4], dout_w[3], dout_w[2], dout_w[1], dout_w[0]}),
.rd_addr_out_5P(rd_addr_5P_w),

.wr_addr_out_1P(wr_addr_out_1P),
.wr_data_out_1P(wr_data_out_1P)
 
);


endmodule 