//16选一选择器 默认数据位宽16
//delay 0 cycles
//#test_passed
module MUX10_1(
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
    in_09
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

always @(select,in_00, in_01, in_02, in_03, in_04, in_05, in_06, in_07, in_08, in_09)
begin 
    case (select)
    8'd00:  output_data = in_00;
    8'd01:  output_data = in_01;
    8'd02:  output_data = in_02;
    8'd03:  output_data = in_03;
    8'd04:  output_data = in_04;
    8'd05:  output_data = in_05;
    8'd06:  output_data = in_06;
    8'd07:  output_data = in_07;
    8'd08:  output_data = in_08;
    8'd09:  output_data = in_09;
    default: output_data = 32'h0;
    endcase 
end
endmodule 

module DEMUX1_10(
    select,
    in_data,
    out_00,
    out_01,
    out_02,
    out_03,
    out_04,
    out_05,
    out_06,
    out_07,
    out_08,
    out_09
);
parameter WIDTH = 16;
input  [7: 0] select;
input [WIDTH-1: 0] in_data;

output reg [WIDTH-1: 0] out_00;
output reg [WIDTH-1: 0] out_01;
output reg [WIDTH-1: 0] out_02;
output reg [WIDTH-1: 0] out_03;
output reg [WIDTH-1: 0] out_04;
output reg [WIDTH-1: 0] out_05;
output reg [WIDTH-1: 0] out_06;
output reg [WIDTH-1: 0] out_07;
output reg [WIDTH-1: 0] out_08;
output reg [WIDTH-1: 0] out_09;

always @(select,in_data)
begin 
    case (select)
    8'd0:   begin 
                out_00 = in_data;
                out_01 = 0;
                out_02 = 0;
                out_03 = 0;
                out_04 = 0;
                out_05 = 0;
                out_06 = 0;
                out_07 = 0;
                out_08 = 0;
                out_09 = 0;
            end
    8'd1:   begin 
                out_00 = 0;
                out_01 = in_data;
                out_02 = 0;
                out_03 = 0;
                out_04 = 0;
                out_05 = 0;
                out_06 = 0;
                out_07 = 0;
                out_08 = 0;
                out_09 = 0;
            end
    8'd2:   begin 
                out_00 = 0;
                out_01 = 0;
                out_02 = in_data;
                out_03 = 0;
                out_04 = 0;
                out_05 = 0;
                out_06 = 0;
                out_07 = 0;
                out_08 = 0;
                out_09 = 0;
            end        
     8'd3:   begin 
                out_00 = 0;
                out_01 = 0;
                out_02 = 0;
                out_03 = in_data;
                out_04 = 0;
                out_05 = 0;
                out_06 = 0;
                out_07 = 0;
                out_08 = 0;
                out_09 = 0;
            end
    8'd4:   begin 
                out_00 = 0;
                out_01 = 0;
                out_02 = 0;
                out_03 = 0;
                out_04 = in_data;
                out_05 = 0;
                out_06 = 0;
                out_07 = 0;
                out_08 = 0;
                out_09 = 0;
            end
    8'd5:   begin 
                out_00 = 0;
                out_01 = 0;
                out_02 = 0;
                out_03 = 0;
                out_04 = 0;
                out_05 = in_data;
                out_06 = 0;
                out_07 = 0;
                out_08 = 0;
                out_09 = 0;
            end    
    8'd6:   begin 
                out_00 = 0;
                out_01 = 0;
                out_02 = 0;
                out_03 = 0;
                out_04 = 0;
                out_05 = 0;
                out_06 = in_data;
                out_07 = 0;
                out_08 = 0;
                out_09 = 0;
            end
    8'd7:   begin 
                out_00 = 0;
                out_01 = 0;
                out_02 = 0;
                out_03 = 0;
                out_04 = 0;
                out_05 = 0;
                out_06 = 0;
                out_07 = in_data;
                out_08 = 0;
                out_09 = 0;
            end
    8'd8:   begin 
                out_00 = 0;
                out_01 = 0;
                out_02 = 0;
                out_03 = 0;
                out_04 = 0;
                out_05 = 0;
                out_06 = 0;
                out_07 = 0;
                out_08 = in_data;
                out_09 = 0;
            end        
     8'd9:   begin 
                out_00 = 0;
                out_01 = 0;
                out_02 = 0;
                out_03 = 0;
                out_04 = 0;
                out_05 = 0;
                out_06 = 0;
                out_07 = 0;
                out_08 = 0;
                out_09 = in_data;
            end
    default: 
    begin 
           out_00 = 0;
           out_01 = 0;
           out_02 = 0;
           out_03 = 0;
           out_04 = 0;
           out_05 = 0;
           out_06 = 0;
           out_07 = 0;
           out_08 = 0;
           out_09 = 0;
    end
    endcase 
end
endmodule 