module TestInner(
    clk,
	rsta,
	beginwr,
	in_data0,
	out_data,
	out_en
);
input 	clk;
input 	rsta;
input 	beginwr; 
input   in_data;
output  [7:0] out_data;
output  out_en;

reg [7:0] state_reg;
reg [7:0] addr_reg;

parameter IDLE = 8'h0;
parameter WR_ST = 8'h1;
parameter RD_ST = 8'h2;
parameter RD_END = 8'h4;


blk_mem_gen_0 my_blk(
  .clka(clka),            // input wire clka
  .rsta(1'b1),            // input wire rsta
  .wea(beginwr_ram),      // input wire [0 : 0] wea
  .addra(addra),          // input wire [9 : 0] addra
  .dina(dina),            // input wire [7 : 0] dina
  .douta(douta),          // output wire [7 : 0] douta
  .rsta_busy(rsta_busy)   // output wire rsta_busy
);

// output by state and other output  *nest condition*
assign out_en = (state_reg == RD_ST) || (state_reg == RD_END);
assign out_data = douta;
assign beginwr_ram = (state_reg == WR_ST);

always @(posedge clk or negedge rsta)
begin 
    //state trans form by other signals output
    if (!rsta)
	begin 
        state_reg <= 0;	
		addr_reg <= 0;
	end
	else 
	begin
	    case (state_reg)
		IDLE:begin 
		    if (beginwr == 1'b1)
			begin
			    state_reg <= WR_ST;
			end
			else 
			    state_reg <= IDLE;
		WR_ST:begin 
		    addr_reg <= addr_reg + 1;
			if (addr_reg == 8'h7)
			begin 
			    state_reg <= RD_ST;
				addr_reg <= 8'h0;
			end
			else
			    state_reg <= WR_ST;
		end
		RD_ST:begin 
		    addr_reg <= addr_reg + 1;
			if (addr_reg == 8'h7)
			begin 
			    state_reg <= RD_ST;
				addr_reg <= 8'h0;
			end
			else
			    state_reg <= RD_END;
		end
		RD_END:begin 
		    state_reg <= IDLE;
		end
	    default:begin end
		endcase
	end
end
endmodule

module TestWapper(
    clk,
	rst_n,
	begin_wr,
    sel,
	a_0;
	a_1;
	a_2;
	a_3;
	a_4;
	a_5;
	a_6;
	a_7;
	dout;
	outen
);
input clk;
input rst_n;
input begin_wr;

input [7:0] sel;
input [7:0] a_0;
input [7:0] a_1;
input [7:0] a_2;
input [7:0] a_3;
input [7:0] a_4;
input [7:0] a_5;
input [7:0] a_6;
input [7:0] a_7;
output [7:0] dout;
output outen;

wire [7:0] data_sel;

TestInner inner(
    .clk(clk),
	.rsta(rst_n),
	.beginwr(begin_wr),
	.in_data0(data_sel),
	.out_data(a_8),
	.out_en(dout)
);


assign data_sel = if 

endmodule