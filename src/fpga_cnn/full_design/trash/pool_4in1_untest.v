module Pool_4in1(
    in00,
    in01,
    in02,
    in03,
    out_max    
);
parameter DATA_WIDTH = 16;

input [DATA_WIDTH-1: 0] in00;
input [DATA_WIDTH-1: 0] in01;
input [DATA_WIDTH-1: 0] in02;
input [DATA_WIDTH-1: 0] in03;
input [DATA_WIDTH-1: 0] out_max;

wire [DATA_WIDTH-1: 0] tmp0;
wire [DATA_WIDTH-1: 0] tmp1;

assign tmp0 = in00 > in01 ? in00 : in01;   
assign tmp1 = in02 > in03 ? in02 : in03;   
assign out_max = tmp0 > tmp1? tmp0 : tmp1; 
endmodule 