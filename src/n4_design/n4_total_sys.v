module Total_Sys(
    clk,
    rst_n,
    din,
    wr_addr,
    we,
    en,
    res
);

input  clk;
input  rst_n;
input  [15:0] din;
input  [31:0] wr_addr;
input  we;
input  en;

output [7: 0] res;

parameter IDLE = "IDLE";
parameter INPUT_RECIVING = "IN_RV";
parameter C1S2_RUNNING = "C1S2_R";
parameter C1S2_FIN = "C1S2_F";
parameter C3S4_RUNNING = "C3S4_R";
parameter C3S4_FIN = "C3S4_F";
parameter DEN1_RUNNING = "DEN1_R";
parameter DEN1_FIN = "DEN1_F";
parameter DEN2_RUNNING = "DEN2_R";
parameter DEN2_FIN = "DEN2_F";
parameter DEN3_RUNNING = "DEN3_R";
parameter DEN3_FIN = "DEN3_F";
parameter ALL_FIN = "ALL_F";

//总状态机变量
reg [10*8-1:0] sys_stats;
reg [31: 0]    stall_cnt;


reg c1s2_en;
wire c1s2_fin;
wire [32*5-1: 0] c1s2_buf_rd_addr_5P;
wire [16*5-1: 0] c1s2_buf_rd_data_5P;
wire [31: 0] c1s2_buf_wr_addr_1P;
wire [15: 0] c1s2_buf_wr_data_1P;
wire        c1s2_buf_wr_en;

reg  c3s4_en;
wire c3s4_fin;
wire [32*5-1: 0]    c3s4_buf_rd_addr_5P;
wire [16*5-1: 0]    c3s4_buf_rd_data_5P_0;
wire [16*5-1: 0]    c3s4_buf_rd_data_5P_1;
wire [16*5-1: 0]    c3s4_buf_rd_data_5P_2;
wire [16*5-1: 0]    c3s4_buf_rd_data_5P_3;
wire [16*5-1: 0]    c3s4_buf_rd_data_5P_4;
wire [16*5-1: 0]    c3s4_buf_rd_data_5P_5;

wire [31: 0]        c3s4_buf_wr_addr_1P;
wire [15: 0]        c3s4_buf_wr_data_1P;
wire                c3s4_buf_wr_en;


reg  den1_en;
wire den1_fin;
wire [31: 0]        den1_buf_rd_addr_1P;
wire [16*25-1: 0]   den1_buf_rd_data_25P;

wire [31: 0]        den1_buf_wr_addr_1P;
wire [15: 0]        den1_buf_wr_data_1P;
wire                den1_buf_wr_en;


C1_Src_buf C1_buf_inst(
.clk(clk),
.rd_addr_5P(c1s2_buf_rd_addr_5P),
.rd_data_5P(c1s2_buf_rd_data_5P),
.wr_data(din),
.wr_addr(wr_addr),
.we(we)
);

C1S2_layer C1S2_layer_inst(

.clk(clk),
.rst_n(rst_n),

.en(c1s2_en),
.work_finished(c1s2_fin),

.rd_data_in_5P(c1s2_buf_rd_data_5P),
.rd_addr_out_5P(c1s2_buf_rd_addr_5P),

.wr_addr_out_1P(c1s2_buf_wr_addr_1P),
.wr_data_out_1P(c1s2_buf_wr_data_1P),

.wr_out_en(c1s2_buf_wr_en)
);

C3_Src_buf C3_buf_inst(
.clk(clk),
.rd_addr_5P_0(c3s4_buf_rd_addr_5P),
.rd_addr_5P_1(c3s4_buf_rd_addr_5P),
.rd_addr_5P_2(c3s4_buf_rd_addr_5P),
.rd_addr_5P_3(c3s4_buf_rd_addr_5P),
.rd_addr_5P_4(c3s4_buf_rd_addr_5P),
.rd_addr_5P_5(c3s4_buf_rd_addr_5P),

.rd_data_5P_0(c3s4_buf_rd_data_5P_0),
.rd_data_5P_1(c3s4_buf_rd_data_5P_1),
.rd_data_5P_2(c3s4_buf_rd_data_5P_2),
.rd_data_5P_3(c3s4_buf_rd_data_5P_3),
.rd_data_5P_4(c3s4_buf_rd_data_5P_4),
.rd_data_5P_5(c3s4_buf_rd_data_5P_5),

.wr_data(c1s2_buf_wr_data_1P),
.wr_addr(c1s2_buf_wr_addr_1P),
.we(c1s2_buf_wr_en)
);


C3S4_layer C3S4_layer(

.clk(clk),
.rst_n(rst_n),

.en(c3s4_en),
.work_finished(c3s4_fin),

.rd_data_in_5P_0(c3s4_buf_rd_data_5P_0),
.rd_data_in_5P_1(c3s4_buf_rd_data_5P_1),
.rd_data_in_5P_2(c3s4_buf_rd_data_5P_2),
.rd_data_in_5P_3(c3s4_buf_rd_data_5P_3),
.rd_data_in_5P_4(c3s4_buf_rd_data_5P_4),
.rd_data_in_5P_5(c3s4_buf_rd_data_5P_5),

.rd_addr_out_5P(c3s4_buf_rd_addr_5P),

.wr_addr_out_1P(c3s4_buf_wr_addr_1P),
.wr_data_out_1P(c3s4_buf_wr_data_1P),

.wr_out_en(c3s4_buf_wr_en)
);


Shift_Ram #(.DEPTH(16), DATA_WIDTH(16), .LENGTH(25)) Den1_src_buf(
    .rst_n(rst_n),
    .clk(clk),
    .we(c3s4_buf_wr_en),
    .din(c3s4_buf_wr_data_1P),
    .wr_addr(c3s4_buf_wr_addr_1P / 25),
    .rd_addr(den1_buf_rd_addr_1P),
    .dout(den1_buf_rd_data_25P)
);

Dense1_layer den1_inst(
    .clk(clk),
    .rst_n(rst_n),
    
    .en(den1_en),
    
    .rd_addr_out_1P(den1_buf_rd_addr_1P),
    .rd_data_in_25P(den1_buf_rd_data_25P),

    .wr_addr_out(den1_buf_wr_addr_1P),
    .wr_data_out(den1_buf_wr_data_1P),
    .wr_en_out(den1_buf_wr_en),
    
    .work_finished(den1_fin)
);

/*
Shift_Ram #(.DEPTH(5), DATA_WIDTH(16), .LENGTH(25)) Den2_src_buf(
    .rst_n(rst_n),
    .clk(clk),
    .we(),
    .din(),
    .wr_addr(),
    .rd_addr(),
    .dout()
);

*/
reg we_sync;
wire negedge_we;
always @(posedge clk)
begin
    we_sync <= we;
end 

assign negedge_we = we == 0 && we_sync;

always @(posedge clk or negedge rst_n)
begin 
    if (!rst_n)
    begin
        sys_stats <= IDLE;
        c3s4_en <= 0;
        c1s2_en <= 0;
    end 
    else
    begin
        case(sys_stats)
        IDLE:
        begin
            if (en)
            begin
                sys_stats <= INPUT_RECIVING;
            end 
            else
            begin 
                sys_stats <= IDLE;
                c3s4_en <= 0;
                c1s2_en <= 0;
            end 
        end
        INPUT_RECIVING:
        begin
            if (en && negedge_we)
                sys_stats <= C1S2_RUNNING;
        end
        C1S2_RUNNING:
        begin
             if (en && !c1s2_fin)
             begin
                 c1s2_en <= 1;
             end 
             else if (c1s2_fin)
             begin
                 c1s2_en <= 0;
                 stall_cnt <= 0;
                 sys_stats <= C1S2_FIN;
             end 
        end
        C1S2_FIN:
        begin
            if (stall_cnt == 1000)
            begin 
                 stall_cnt <= 0;
                 sys_stats <= C3S4_RUNNING; 
            end 
            else
            begin
                 stall_cnt <= stall_cnt + 1;
            end
        end 
        C3S4_RUNNING:
        begin
             if (!c3s4_fin)
             begin
                 c3s4_en <= 1;
             end 
             else
             begin
                 c3s4_en <= 0;
                 stall_cnt <= 0;
                 sys_stats <= C3S4_FIN;
             end 
        end 
        C3S4_FIN:
        begin
            if (stall_cnt == 1000)
            begin 
                 stall_cnt <= 0;
                 $finish;
                 sys_stats <= IDLE; 
            end 
            else
            begin
                 stall_cnt <= stall_cnt + 1;
            end
        end
        
        default:;
        endcase
    end
end 
endmodule 








