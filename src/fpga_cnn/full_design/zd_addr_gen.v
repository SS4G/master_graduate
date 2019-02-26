module AddrGen(
    rst_n,
    clk,
    en,
    addr_out_25P,
    anchor_addr,
);

input rst_n;
input clk;
input en;
output [31: 0] anchor_addr;
output [32 * 25 - 1: 0] addr_out_25P;

parameter H_WINDOW_LEN = 5; //窗口横向长度
parameter V_WINDOW_LEN = 5; //窗口纵向长度
parameter H_IMAGE_LEN = 30; //图像横向长()
parameter V_IMAGE_LEN = 30;

reg [31:0]  clk_cnt;
wire [32 * 25 - 1: 0] addr_out_25P_w;

genvar h_offset;   // 相对与锚点的横向偏移
genvar v_offset;   // 相对于锚点的纵向偏移
generate 
for (v_offset = 0; v_offset < V_WINDOW_LEN ; v_offset = v_offset + 1) 
begin
    for (h_offset = 0; h_offset < H_WINDOW_LEN; h_offset = h_offset + 1) 
    begin
        assign addr_out_25P_w[32 * (h_offset * H_WINDOW_LEN + v_offset + 1) - 1: 32 * (h_offset * H_WINDOW_LEN + v_offset)] = anchor_addr + h_offset + v_offset * H_IMAGE_LEN;
        assign addr_out_25P[32 * (h_offset * H_WINDOW_LEN + v_offset + 1) - 1: 32 * (h_offset * H_WINDOW_LEN + v_offset)] = addr_out_25P_w[32 * (h_offset * H_WINDOW_LEN + v_offset + 1) - 1: 32 * (h_offset * H_WINDOW_LEN + v_offset)] > 20 ? addr_out_25P_w[32 * (h_offset * H_WINDOW_LEN + v_offset + 1) - 1: 32 * (h_offset * H_WINDOW_LEN + v_offset)] : 0 ;
    end 
end
endgenerate 

//1KB actually 30x30 = 900
//不同的时钟周期输出不同的锚点坐标 
//依靠内部的coefile制定锚点
//通过不同的coefile配置 生成不同的路径

N4AnchorRom all_anchor_rom_inst (
  .clka(clk),    // input wire clka
  .addra(clk_cnt),  // input wire [9 : 0] addra
  .douta(anchor_addr)  // output wire [15 : 0] douta
);

always @(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
    begin
        clk_cnt <= 0;
    end
    else
    begin
        if (en)
        begin
            if(clk_cnt >= (H_IMAGE_LEN - H_WINDOW_LEN + 1) * (V_IMAGE_LEN - V_WINDOW_LEN + 1) - 1)
                clk_cnt <= 0;
            else
                clk_cnt <= clk_cnt + 1;
        end
        else 
            clk_cnt <= 0;
    end
end
endmodule 
