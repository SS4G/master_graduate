//offset = x*X_SZIE+y
module ConstAddrMap(
    x,
    y,
    offset
);
    parameter PORT_NUM = 25;
    parameter ADDR_WIDTH = 16;
    parameter X_SIZE = 25;
    parameter Y_SIZE = 30;
    
    input [PORT_NUM*ADDR_WIDTH-1:0] x;
    input [PORT_NUM*ADDR_WIDTH-1:0] y;
    output [PORT_NUM*ADDR_WIDTH-1:0] offset;
    
    wire [15:0] x_start [X_SIZE-1:0];
    
    generate
    genvar i, j;
    for(i = 0;i < X_SIZE; i = i + 1)
    begin 
        assign x_start[i] = i * X_SIZE;
    end
    endgenerate 
     
    
    generate
    genvar k;
    for(k = 0; k < PORT_NUM; k = k + 1)
    begin 
        assign offset[(k+1)*ADDR_WIDTH-1:k*ADDR_WIDTH] = x_start[x[(k+1)*ADDR_WIDTH-1: k*ADDR_WIDTH]] + y;
       // assign offset[(k+1)*ADDR_WIDTH-1:k*ADDR_WIDTH] = 0;
        //assign offset[(k+1)*16-1:k*16] = x_start[x[(k+1)*16-1: k*16]] + y;
    end
    endgenerate
    //assign offset[(00+1)*ADDR_WIDTH-1:00*ADDR_WIDTH] = x_start[x[(00+1)*ADDR_WIDTH-1: 00*ADDR_WIDTH]] + y;
    //assign offset[(01+1)*ADDR_WIDTH-1:01*ADDR_WIDTH] = x_start[x[(01+1)*ADDR_WIDTH-1: 01*ADDR_WIDTH]] + y;
    //assign offset[(02+1)*ADDR_WIDTH-1:02*ADDR_WIDTH] = x_start[x[(02+1)*ADDR_WIDTH-1: 02*ADDR_WIDTH]] + y;
    //assign offset[(03+1)*ADDR_WIDTH-1:03*ADDR_WIDTH] = x_start[x[(03+1)*ADDR_WIDTH-1: 03*ADDR_WIDTH]] + y;
    //assign offset[(04+1)*ADDR_WIDTH-1:04*ADDR_WIDTH] = x_start[x[(04+1)*ADDR_WIDTH-1: 04*ADDR_WIDTH]] + y;
    //assign offset[(05+1)*ADDR_WIDTH-1:05*ADDR_WIDTH] = x_start[x[(05+1)*ADDR_WIDTH-1: 05*ADDR_WIDTH]] + y;
    //assign offset[(06+1)*ADDR_WIDTH-1:06*ADDR_WIDTH] = x_start[x[(06+1)*ADDR_WIDTH-1: 06*ADDR_WIDTH]] + y;
    //assign offset[(07+1)*ADDR_WIDTH-1:07*ADDR_WIDTH] = x_start[x[(07+1)*ADDR_WIDTH-1: 07*ADDR_WIDTH]] + y;
    //assign offset[(08+1)*ADDR_WIDTH-1:08*ADDR_WIDTH] = x_start[x[(08+1)*ADDR_WIDTH-1: 08*ADDR_WIDTH]] + y;
    //assign offset[(09+1)*ADDR_WIDTH-1:09*ADDR_WIDTH] = x_start[x[(09+1)*ADDR_WIDTH-1: 09*ADDR_WIDTH]] + y;
    //assign offset[(10+1)*ADDR_WIDTH-1:10*ADDR_WIDTH] = x_start[x[(10+1)*ADDR_WIDTH-1: 10*ADDR_WIDTH]] + y;
    //assign offset[(11+1)*ADDR_WIDTH-1:11*ADDR_WIDTH] = x_start[x[(11+1)*ADDR_WIDTH-1: 11*ADDR_WIDTH]] + y;
    //assign offset[(12+1)*ADDR_WIDTH-1:12*ADDR_WIDTH] = x_start[x[(12+1)*ADDR_WIDTH-1: 12*ADDR_WIDTH]] + y;
    //assign offset[(13+1)*ADDR_WIDTH-1:13*ADDR_WIDTH] = x_start[x[(13+1)*ADDR_WIDTH-1: 13*ADDR_WIDTH]] + y;
    //assign offset[(14+1)*ADDR_WIDTH-1:14*ADDR_WIDTH] = x_start[x[(14+1)*ADDR_WIDTH-1: 14*ADDR_WIDTH]] + y;
    //assign offset[(15+1)*ADDR_WIDTH-1:15*ADDR_WIDTH] = x_start[x[(15+1)*ADDR_WIDTH-1: 15*ADDR_WIDTH]] + y;
    //assign offset[(16+1)*ADDR_WIDTH-1:16*ADDR_WIDTH] = x_start[x[(16+1)*ADDR_WIDTH-1: 16*ADDR_WIDTH]] + y;
    //assign offset[(17+1)*ADDR_WIDTH-1:17*ADDR_WIDTH] = x_start[x[(17+1)*ADDR_WIDTH-1: 17*ADDR_WIDTH]] + y;
    //assign offset[(18+1)*ADDR_WIDTH-1:18*ADDR_WIDTH] = x_start[x[(18+1)*ADDR_WIDTH-1: 18*ADDR_WIDTH]] + y;
    //assign offset[(19+1)*ADDR_WIDTH-1:19*ADDR_WIDTH] = x_start[x[(19+1)*ADDR_WIDTH-1: 19*ADDR_WIDTH]] + y;
    //assign offset[(20+1)*ADDR_WIDTH-1:20*ADDR_WIDTH] = x_start[x[(20+1)*ADDR_WIDTH-1: 20*ADDR_WIDTH]] + y;
    //assign offset[(21+1)*ADDR_WIDTH-1:21*ADDR_WIDTH] = x_start[x[(21+1)*ADDR_WIDTH-1: 21*ADDR_WIDTH]] + y;
    //assign offset[(22+1)*ADDR_WIDTH-1:22*ADDR_WIDTH] = x_start[x[(22+1)*ADDR_WIDTH-1: 22*ADDR_WIDTH]] + y;
    //assign offset[(23+1)*ADDR_WIDTH-1:23*ADDR_WIDTH] = x_start[x[(23+1)*ADDR_WIDTH-1: 23*ADDR_WIDTH]] + y;
    //assign offset[(24+1)*ADDR_WIDTH-1:24*ADDR_WIDTH] = x_start[x[(24+1)*ADDR_WIDTH-1: 24*ADDR_WIDTH]] + y;
    
endmodule 