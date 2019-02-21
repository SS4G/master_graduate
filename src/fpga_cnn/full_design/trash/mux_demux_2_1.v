//16选一选择器 默认数据位宽16
//delay 0 cycles
//#test_passed
module MUX2_1(
    select,
    output_data,
    in_00,
    in_01
);
parameter WIDTH = 16;
input  [7: 0] select;
output reg [WIDTH-1: 0] output_data;

input [WIDTH-1: 0] in_00;
input [WIDTH-1: 0] in_01;

always @(select,in_00,in_01)
begin 
    case (select)
    8'd0:  output_data = in_00;
    8'd1:  output_data = in_01;
    default: output_data = 32'h0;
    endcase 
end
endmodule 

module DEMUX2_1(
    select,
    in_data,
    out_00,
    out_01
);
parameter WIDTH = 16;
input  [7: 0] select;
input [WIDTH-1: 0] in_data;

output reg [WIDTH-1: 0] out_00;
output reg [WIDTH-1: 0] out_01;

always @(select,in_data)
begin 
    case (select)
    8'd0:   begin 
                out_00 = in_data;
                out_01 = 0;
            end
    8'd1:   begin
                out_01 = in_data;
                out_00 = 0;
            end 
    default: 
    begin 
        out_00 = 0;
        out_01 = 0;
    end
    endcase 
end
endmodule 