module ConstAddrMap(
    x,
    y,
    offset
);
    parameter PORT_NUM = 25;
    parameter ADDR_WIDTH = 32;
    parameter X_SIZE = 25;
    parameter Y_SIZE = 30;
    
    input [PORT_NUM*ADDR_WIDTH-1:0] x;
    input [PORT_NUM*ADDR_WIDTH-1:0] y;
    output [PORT_NUM*ADDR_WIDTH-1:0] offset;
    
    wire [31:0] mem [X_SIZE-1:0][Y_SIZE-1:0];

    
    generate
    genvar i, j;
    for(i = 0;i < X_SIZE; i = i + 1)
    begin 
        for (j = 0;j < Y_SIZE; j = j + 1)
        begin
            assign mem[i][j] = i * X_SIZE + j;
        end
    end
    endgenerate 
     
    
    generate
    genvar k;
    for(k = 0; k < PORT_NUM; k = k + 1)
    begin 
        assign offset[(k+1)*ADDR_WIDTH-1:k*ADDR_WIDTH] = mem[x[(k+1)*ADDR_WIDTH-1:k*ADDR_WIDTH]][y[(k+1)*ADDR_WIDTH-1:k*ADDR_WIDTH]];
    end
    endgenerate 
endmodule 