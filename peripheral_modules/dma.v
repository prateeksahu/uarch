/////////////////////////////////////////////////////////////////////////////////
///// Bus Description:     bus[31:0] := data                                ///// 
/////                      bus[46:32] := addr                               /////
/////                      bus[49:47] := size                               /////
/////                      bus[50] := start                                 /////
/////                      bus[51] := _1st                                  /////
/////                      bus[52] := cacheable                             /////
/////                      bus[54:53] := rdwr                               /////
/////                      bus[56:55] := dst                                /////
/////                      bus[58:57] := src                                /////
/////                      bus[59] := vld                                   /////
/////                      bus[62:60] := reqCycles                          /////
/////                      bus[63] := interrupt                             /////
/////////////////////////////////////////////////////////////////////////////////

module dma #(parameter [31:0] INTV = 32'd14,
             parameter [14:0] MEM_ADDR1 = 15'h7000,
             parameter [14:0] MEM_ADDR2 = 15'h7004,
             parameter [14:0] MEM_ADDR3 = 15'h7008,
             parameter [14:0] MEM_ADDR4 = 15'h7010)(
    input clk,
    input rst,
    //Input from bus to DMA.
    input [63:0] i_bus,
    //Output from DMA to bus.
    output o_vld,
    output [63:0] o_bus,
    input bus_gnt);
    
    wire dma_read1,dma_read2,dma_read3;
    
    assign dma_read1 = (i_bus[46:32] ===  MEM_ADDR1) && (i_bus[56:55] === 2'b11) && (i_bus[58:57] === 2'b10) && i_bus[54] && i_bus[51];
    assign dma_read2 = (i_bus[46:32] ===  MEM_ADDR2) && (i_bus[56:55] === 2'b11) && (i_bus[58:57] === 2'b10) && i_bus[54] && i_bus[51];
    assign dma_read3 = (i_bus[46:32] ===  MEM_ADDR3) && (i_bus[56:55] === 2'b11) && (i_bus[58:57] === 2'b10) && i_bus[54] && i_bus[51];
    assign dma_read4 = (i_bus[46:32] ===  MEM_ADDR4) && (i_bus[56:55] === 2'b11) && (i_bus[58:57] === 2'b10) && i_bus[54] && i_bus[51];
    
    reg [31:0] srcaddr,dstaddr;
    reg [11:0] size;
    reg start;
    always @(posedge clk) begin
        if(~rst) begin
            srcaddr <= 32'b0;
            dstaddr <= 32'b0;
            size <= 12'b0;
            start <= 1'b0;
        end
        else begin
            if(dma_read1)
                srcaddr <= i_bus[31:0];
            if(dma_read2)
                dstaddr <= i_bus[31:0];
            if(dma_read3)
                size <= i_bus[11:0];
            if(dma_read4) begin
                start <= 1'b0;
                #750
                @(posedge clk)
                #0.2
                start <= 1'b1;
            end
        end
    end
    
    wire [3:0] rem,rem1,rem2;
    wire [11:0] addr1;
    wire [31:0] byten;
    
    reg [14:0] dstaddr_t;
    reg [11:0] cnt;
    reg [31:0] data_int;
    reg [2:0] ds_t;
    reg half;
    
    reg done,done_t;
    assign rem = 4'h8 - {1'b0,dstaddr[2:0]};
    assign rem1 = rem - 4'h1;
    assign rem2 = size - 4'h1;
    assign addr1 = dstaddr_t[14:3] + 12'b1;
    
    always @(posedge clk) begin
        if(~rst) begin
            cnt <= 12'b0;
            ds_t <= 3'h0;
            done <= 1'b0;
            done_t <= 1'b0;
        end
        else begin
            if(done_t & o_vld & (~bus_gnt))
                done_t <= 1'b0;
            else if(dma_read4) begin
                dstaddr_t <= dstaddr;
                cnt <= size;
                ds_t <= (rem > size) ? rem2:rem1 ;
                data_int <= 32'b0;
                done <= 1'b0;
            end
            else if(o_vld & (~bus_gnt) & (half) & (~done)) begin
                dstaddr_t <= {addr1,3'b0};
                cnt <= cnt - 1 - ds_t;
                ds_t <= ((cnt-ds_t) > 8) ? 3'h7 : (cnt-ds_t-1);
                data_int <= data_int + 32'b1;
                done <= (cnt <= 8);
                done_t <= (cnt <= 8);
            end
        end
    end
    
    always @(posedge clk) begin
        if(~rst)    half <= 1'b0;
        else if(o_vld & (~bus_gnt)) begin
            half <= ~half;
        end
    end
    
    //assign #0.2 o_vld = ((start & (~done)) | done_t);
    assign o_vld = ((start & (~done))|done_t);
    
    assign o_bus[31:0] = done ? INTV : data_int;
    assign o_bus[46:32] = dstaddr_t;
    assign o_bus[49:47] = ds_t;
    assign o_bus[50] = 1'b1;
    assign o_bus[51] = ~half;
    assign o_bus[52] = 1'b0;
    assign o_bus[54:53] = 2'b10;
    assign o_bus[56:55] = done ? 2'b10 : 2'b11;
    assign o_bus[58:57] = 2'b01;
    assign o_bus[59] = 1'b1;
    assign o_bus[62:60] = done ? 3'b0 : 3'b1;
    assign o_bus[63] = done ? 1'b1: 1'b0;

endmodule
    
