module div_test_tb;
reg clk;
wire [31:0] dout_data;
wire dout_valid;
wire [15:0] data_h;
wire [15:0] data_l;



always #2 clk = ~clk;

reg [15:0] divisor;
reg [15:0] dividend;

assign data_h = dout_data[31:16]; //商
assign data_l = dout_data[15:0]; //余数

integer_diver_16_11 your_instance_name (
  //.aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(1'b1),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata(divisor),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(1'b1),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(dividend),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(dout_valid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout_data)            // output wire [31 : 0] m_axis_dout_tdata
);

initial
begin
    clk = 0;
    #100;
    dividend = 100;
    divisor = 50;
    
    # 20;
    dividend = 120;
    divisor = 3;
    
    # 20;
    dividend = 100;
    divisor = 3;
     
    # 20;
    dividend = 7;
    divisor = 4;
     
    # 100;
    $finish;
end
endmodule