module MulPrime2 (
      CLK,  // input wire CLK
      rst_n,
      A,      // input wire [31 : 0] A
      B,
      P      // output wire [63 : 0] P
);
input CLK;
input rst_n;
input [31:0] A;
input [31:0] B;
(* use_dsp48 = "no" *)output [63:0] P;
assign P = A * 32'h6786_ffff;
endmodule 