
module mem_subsystem #(
        parameter [32:0] DELAY_IO1 = 32'd800000,
        parameter [31:0] INTV_IO1 = 32'd13,
        parameter [31:0] INTV_IO2 = 32'd14,
        parameter [14:0] MM_ADDR_IO1 = 15'h7000,
        parameter [14:0] MEM_ADDR1_DMA = 15'h7008,
        parameter [14:0] MEM_ADDR2_DMA = 15'h700a,
        parameter [14:0] MEM_ADDR3_DMA = 15'h700f,
        parameter [14:0] MEM_ADDR4_DMA = 15'h7010)(
    input                 clk,
    input                 rst,
    
    //Inputs from ICache
    input [14:0]         ic_addr,
    input                 ic_vld,
    input                 ic_page_spill,
    
    //Inputs from DCache.
    input               tlb_cacheable,
    input [14:0]         dc_rdaddr,
    input                 dc_rdvld,
    
    //Inputs from writeback.
    input                 wb_cacheable,
    input [14:0]         wb_addr,
    input [1:0]         wb_datasize,
    input [31:0]         wb_data,
    input                 wb_vld,
    
    //Output to ICache.
    output                 ic_read,
    output                 ic_data_vld,
    output [63:0]         ic_data,
    output [14:0]         ic_addrout,
    
    //Output to DCache.
    output                 dc_r_read,
    output [31:0]         dc_rddata,
    output [14:0]         dc_addrout,
    output                 dc_data_vld,
    
    //Output to WB.
    output                 wb_read,
    
    //Interrupt outputs.
    output              interrupt,
    output [31:0]       intv
    );
    
    wire [63:0] i_io1,i_io2,i_proc,i_mem,bus;
    wire io1_vld,io2_vld,proc_vld,mem_vld;
    wire io1_gnt,io2_gnt,proc_gnt,mem_gnt;
    wire mem_stall;
    wire [95:0] i_data_dc,i_data_ic;
    wire i_vld_dc,i_vld_ic,o_ic_rd,o_dc_rd,o_vld_dc,o_vld_ic,o_uc_dc,i_dc_rd;
    wire [14:0] o_addr_dc,o_addr_ic;
    wire [255:0] o_data_ic;
    wire [63:0] o_data_dc;
    
    lsq lsq_inst(clk,rst,i_data_ic,i_vld_ic,o_ic_rd,i_data_dc,i_vld_dc,o_dc_rd,
        o_vld_ic,o_addr_ic,o_data_ic,o_vld_dc,o_uc_dc,o_addr_dc,o_data_dc,i_dc_rd,
        i_proc,proc_vld,proc_gnt,bus,interrupt,intv,lsq_full);
    
    bus_ctrl bus_inst(clk,rst,i_io1,i_io2,i_proc,i_mem,io1_vld,io2_vld,proc_vld,mem_vld,
                    mem_stall,io1_gnt,io2_gnt,proc_gnt,mem_gnt,bus);
    
    wire [14:0] ic_addr_t;
    icache    ic_inst(clk,rst,ic_addr,ic_vld,ic_page_spill,ic_read,ic_data_vld,ic_data,ic_addrout,
        o_data_ic,o_vld_ic,o_addr_ic,i_vld_ic,o_ic_rd,ic_addr_t);   
    
    assign i_data_ic[63:0] = 64'h0;
    assign i_data_ic[78:64] = ic_addr_t;
    assign i_data_ic[81:79] = 3'h7;
    assign i_data_ic[82] = 1'b0;
    assign i_data_ic[83] = 1'b1;
    assign i_data_ic[84] = 1'b0;
    assign i_data_ic[86:85] = 2'b01;
    assign i_data_ic[88:87] = 2'h3;
    assign i_data_ic[90:89] = 2'h2;
    assign i_data_ic[91] = 1'b1;
    assign i_data_ic[94:92] = 3'b0;
    assign i_data_ic[95] = 1'b0;

    wire [14:0] wd_addr;
    wire wd_rdwr,wd_cacheable,wd_reqCycles;
    wire [2:0] wd_size;
    wire [63:0] wd_data;
    
    dcache    dc_inst(clk,rst,tlb_cacheable,dc_rdaddr,dc_rdvld,dc_r_read,dc_rddata,dc_addrout,dc_data_vld,
        wb_cacheable,wb_addr,wb_datasize,wb_data,wb_vld,wb_read,o_addr_dc,o_data_dc,o_uc_dc,o_vld_dc,i_dc_rd,
        i_vld_dc,o_dc_rd,wd_rdwr,wd_cacheable,wd_addr,wd_data,wd_reqCycles,wd_size,lsq_full);
        
    assign i_data_dc[63:0] = wd_data;
    assign i_data_dc[78:64] = wd_addr;
    assign i_data_dc[81:79] = wd_size;
    assign i_data_dc[82] = 1'b0;
    assign i_data_dc[83] = 1'b1;
    assign i_data_dc[84] = wd_cacheable;
    assign i_data_dc[86:85] = {wd_rdwr,1'b0};
    assign i_data_dc[88:87] = 2'h3;
    assign i_data_dc[90:89] = 2'h2;
    assign i_data_dc[91] = 1'b1;
    assign i_data_dc[94:92] = {2'b0,wd_reqCycles};
    assign i_data_dc[95] = 1'b0;

    memory #(64) mem_inst(clk,rst,bus,mem_vld,i_mem,mem_gnt,mem_stall);
    
    simple_io #(DELAY_IO1,INTV_IO1,MM_ADDR_IO1) io1(clk,rst,i_io1,io1_vld,io1_gnt); 
    
    dma #(INTV_IO2,MEM_ADDR1_DMA,MEM_ADDR2_DMA,MEM_ADDR3_DMA,MEM_ADDR4_DMA) io2(clk,rst,bus,io2_vld,i_io2,io2_gnt);
    
endmodule
