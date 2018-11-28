//16选一选择器 默认数据位宽16
//delay 0 cycles
//#test_passed
module MUX16_1(
    select,
    output_data,
    in_00,
    in_01,
    in_02,
    in_03,
    in_04,
    in_05,
    in_06,
    in_07,
    in_08,
    in_09,
    in_10,
    in_11,
    in_12,
    in_13,
    in_14,
    in_15
);
parameter WIDTH = 16;
input  [7: 0] select;
output reg [WIDTH-1: 0] output_data;

input [WIDTH-1: 0] in_00;
input [WIDTH-1: 0] in_01;
input [WIDTH-1: 0] in_02;
input [WIDTH-1: 0] in_03;
input [WIDTH-1: 0] in_04;
input [WIDTH-1: 0] in_05;
input [WIDTH-1: 0] in_06;
input [WIDTH-1: 0] in_07;
input [WIDTH-1: 0] in_08;
input [WIDTH-1: 0] in_09;
input [WIDTH-1: 0] in_10;
input [WIDTH-1: 0] in_11;
input [WIDTH-1: 0] in_12;
input [WIDTH-1: 0] in_13;
input [WIDTH-1: 0] in_14;
input [WIDTH-1: 0] in_15;

always @(select,in_00,in_01,in_02,in_03,in_04,in_05,in_06,in_07,in_08,in_09,in_10,in_11,in_12,in_13,in_14,in_15)
begin 
    case (select)
    8'd0:  output_data = in_00;
    8'd1:  output_data = in_01;
    8'd2:  output_data = in_02;
    8'd3:  output_data = in_03;
    8'd4:  output_data = in_04;
    8'd5:  output_data = in_05;
    8'd6:  output_data = in_06;
    8'd7:  output_data = in_07;
    8'd8:  output_data = in_08;
    8'd9:  output_data = in_09;
    8'd10: output_data = in_10;
    8'd11: output_data = in_11;
    8'd12: output_data = in_12;
    8'd13: output_data = in_13;
    8'd14: output_data = in_14;
    8'd15: output_data = in_15;
    default: output_data = 32'hffff_ffff;
    endcase 
end
endmodule 