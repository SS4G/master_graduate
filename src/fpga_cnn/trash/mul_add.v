module SignedFixPointAddMul(
    clk,
    rst_n,
    a,
    b,
    add_out,
    mul_out
);
    parameter WIDTH=32;
    parameter POINT_WIDTH = 16;
    input [WIDTH - 1: 0] a;
    input [WIDTH - 1: 0] b;
    output [WIDTH - 1: 0] adda_out;
    output [WIDTH * 2 - 1: 0] mul_out;
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            begin

            end
        else
            begin

            end
    end
endmodule