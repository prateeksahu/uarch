module lsq #(parameter WIDTH = 96)(
    input clk,
    input rst,
    //Interface with processor.
    //Input path:
    input [WIDTH-1:0] i_data_ic,
    input i_vld_ic,
	output o_ic_rd,
    input [WIDTH-1:0] i_data_dc,
    input i_vld_dc,
    output o_dc_rd,
    
    //Output path:
    output o_vld_ic,
    output [14:0] o_addr_ic,
    output [255:0] o_data_ic,
    output o_vld_dc,
    output o_uc_dc,
    output [14:0] o_addr_dc,
    output [63:0] o_data_dc,
    input i_dc_rd,
    
    //Interface with memory.
    output [63:0] o_bus,
    output o_bus_vld,
    input bus_gnt,
    input [63:0] i_bus,
    
    //For interrupt.
    output interrupt,
	output [31:0] interrupt_vec,
    
    //For stall.
    output lsq_full);
    
    wire [WIDTH-1:0] i_dataq;
    wire i_vldq;
    
	wire lfn,dvn;
	inv1$	iv1(lfn,lsq_full),
			iv2(dvn,i_vld_dc);
			
    and2$    n1(o_dc_rd,lfn,i_vld_dc);
	and3$	 n2(o_ic_rd,i_vld_ic,lfn,dvn);
	
    mux2n #(WIDTH)    m1(i_data_ic,i_data_dc,i_vld_dc,i_dataq);
    or2$    o1(i_vldq,i_vld_ic,i_vld_dc);
    
	and2$	ax(interrupt,i_bus[63],i_bus[59]);
    //assign interrupt = i_bus[63] & i_bus[59];
    assign interrupt_vec = i_bus[31:0];
	
    queue_8 #(WIDTH) queue(clk,rst,i_dataq,i_vldq,~bus_gnt,o_bus_vld,o_bus,lsq_full);
    
    wire i_vld_c1,i_vld_c2;
    wire w1,w2,w3,w4;
    inv1$    i1(w1,i_bus[55]);
    inv1$    i2(w3,i_bus[53]);
    and2$    a1(w2,i_bus[56],w1);    //dst = 10 (processor).
    or2$    o2(w4,i_bus[54],w3);    //dst == DCache.
    and4$    a2(i_vld_c2,w3,w2,i_bus[59],~i_bus[63]); //dst == DCache & vld & ~interrupt.
    and4$    a3(i_vld_c1,~w3,w2,i_bus[59], ~i_bus[63]);
    
    icache_collect ic_st(clk,rst,i_vld_c1,i_bus[51],i_bus[31:0],i_bus[46:32],o_vld_ic,o_data_ic,o_addr_ic);
    
    dcache_collect dc_st(clk,rst,i_vld_c2,i_bus[51],i_bus[52],i_bus[31:0],i_bus[46:32],o_vld_dc,o_uc_dc,o_data_dc,o_addr_dc,i_dc_rd);
endmodule