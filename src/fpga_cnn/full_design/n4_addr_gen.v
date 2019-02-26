module AddrGen(
    rst_n,
    clk,
    en,
    pause,
    addr_out_25P,
    anchor_addr_in
);

input rst_n;
input clk;
input en;
input pause;
input  [31: 0] anchor_addr_in; //将外部Rom中记录的锚点输入

output [32 * 25 - 1: 0] addr_out_25P;

parameter H_WINDOW_LEN = 5; //窗口横向长度
parameter V_WINDOW_LEN = 5; //窗口纵向长度
parameter H_IMAGE_LEN = 35; //图像横向长()
parameter V_IMAGE_LEN = 35;

reg [31:0]  clk_cnt;

assign anchor_addr = anchor_addr_in;

genvar h_offset;   // 相对与锚点的横向偏移
genvar v_offset;   // 相对于锚点的纵向偏移
generate 
for (v_offset = 0; v_offset < V_WINDOW_LEN ; v_offset = v_offset + 1) 
begin
    for (h_offset = 0; h_offset < H_WINDOW_LEN; h_offset = h_offset + 1) 
    begin
        assign addr_out_25P[32 * (h_offset * H_WINDOW_LEN + v_offset + 1) - 1: 32 * (h_offset * H_WINDOW_LEN + v_offset)] = anchor_addr + h_offset + v_offset * H_IMAGE_LEN;
        //assign addr_out_25P[32 * 11 - 1, 32 * 10] = anchor_addr + h_offset + v_offset * H_IMAGE_LEN;
    end 
end
endgenerate 

//1KB actually 30x30 = 900
//不同的时钟周期输出不同的锚点坐标 
//依靠内部的coefile制定锚点
//通过不同的coefile配置 生成不同的路径

endmodule 
