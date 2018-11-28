module ShiftReg4(
    rst_n,
    clk,
    in,
    out0,
    out1,
    out2,
    out3,
    pause,
    en    
);

parameter WIDTH = 16;

input clk;
input rst_n;
input en;
input [WIDTH-1: 0] in;
input pause;

output reg [WIDTH-1: 0] out0;
output reg [WIDTH-1: 0] out1;
output reg [WIDTH-1: 0] out2;
output reg [WIDTH-1: 0] out3;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        out0 <= 0;
        out1 <= 0;
        out2 <= 0;
        out3 <= 0;
    end 
    else
    begin
        if (!en)
        begin
            out0 <= in;
            out1 <= out0;
            out2 <= out1;
            out3 <= out2;
        end 
        else if (!pause)
        begin
            out0 <= in;
            out1 <= out0;
            out2 <= out1;
            out3 <= out2;
        end 
    end    
end 
endmodule 
