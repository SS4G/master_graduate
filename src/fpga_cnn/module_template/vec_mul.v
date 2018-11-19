//#:module_define_template_begin 
//#:module_name VecMul
//#:module_params length,width,
module VecMul_${length}_${width}(
    rst_n,
    clk,
	//#:loop i in range(0,${length},1)
	inA_${i},
    inB_${i},
    out_${i},
    //#:loop_end	
	dummy
); 
    parameter WIDTH = ${width};
    input rst_n;
	input clk;
	
	//#:loop i in range(0,${length},1)
	input [WIDTH-1: 0] inA_${i};
	input [WIDTH-1: 0] inB_${i};
	output [WIDTH-1: 0] out_${i};
	//#:loop_end
	
	//Instantiate fix mul
	//#:loop i in range(0,${length},1)
	FixMul #(.WIDTH(${width}), .POINT_WIDTH(${glb_point_width})) fixAdder_${i}(
	   .rst_n(rst_n),
	   .clk(clk),
	   .inA(inA_${i}),
	   .inB(inB_${i}),
	   .outProduct(out_${i})
	   .dummy(1'b1)
	);
	//#:loop_end
endmodule
//#:module_define_template_end

//#:module_define_template_begin 
//#:module_name VecMul
//#:module_params length,width,
module AddTree(
    clk,
    rst_n,
    //#:loop i in range(0,${length},1)
	inA_${i},
    inB_${i},
    //#:loop_end
    out,
    dummy
);
    //#:var i=[]
	//#:loop 
	
	//
endmodule 



module InnerProduct(
    
);
    input clk;
	input rst;
    input [7:0]
	input calc_en
	
	
	c_addsub_0 add_inst (
		.A(a),      // input wire [31 : 0] A
		.B(b),      // input wire [31 : 0] B
		.CLK(clk),  // input wire CLK
		.CE(rst_n),    // input wire CE
		.S(add_out)      // output wire [31 : 0] S
	);
	
	mult_gen_0 mul_inst (
		.CLK(clk),  // input wire CLK
		.A(a),      // input wire [31 : 0] A
		.B(b),      // input wire [31 : 0] B
		.P(mul_out)      // output wire [63 : 0] P
	);
endmodule
