module wb_buffer_d4(
    input                 clk,
    input                 rst,
    //Inputs from pipeline latch.
    input                 enqueue,
    input                 i_vld,
    input [31:0]          i_eip,
    input [14:0]          i_addr,
    input [31:0]          i_data,
    input [2:0]           i_size,
    input [31:0]          i_eip_cmp,
    input                 i_last_uop,
    //Entry corresponding to current rdptr.
    output                o_en_vld,
    output [14:0]         o_en_addr,
    output [31:0]         o_en_data,
    output [31:0]         o_en_eip,
    output [2:0]          o_en_size,
    //Outputs to WB logic.
    output [3:0]          o_alloc,
    output [32*4-1:0]     o_eip,
    output [15*4-1:0]     o_addr,
    output [3*4-1:0]      o_size,
    //Input from cache/mem.
    input                 read,
    output                empty,
    output                full);
    
    wire [3:0] alloc,vld;
    wire [31:0] data [3:0],eip [3:0];
    wire [14:0] addr [3:0];
    wire [2:0] size [3:0];
    wire [1:0] rdptr,wrptr;
    
    //Assign the outputs.
    wire [3:0] w1;
    and2n #(4)    a1(alloc,vld,w1);
    mux4n #(1)    m1(w1[0],w1[1],w1[2],w1[3],rdptr,o_en_vld);
    mux4n #(15)   m2(addr[0],addr[1],addr[2],addr[3],rdptr,o_en_addr);
    mux4n #(32)   m3(data[0],data[1],data[2],data[3],rdptr,o_en_data);
    mux4n #(32)   m4(eip[0],eip[1],eip[2],eip[3],rdptr,o_en_eip);
    mux4n #(3)    m5(size[0],size[1],size[2],size[3],rdptr,o_en_size);
    
    assign o_alloc = alloc;
    assign o_eip = {eip[3],eip[2],eip[1],eip[0]};
    assign o_addr = {addr[3],addr[2],addr[1],addr[0]};
    assign o_size = {size[3],size[2],size[1],size[0]};
    
    nor4$    n1(empty,alloc[0],alloc[1],alloc[2],alloc[3]);
    and4$    a2(full,alloc[0],alloc[1],alloc[2],alloc[3]);
    
    //Allocate the pointers.
    wire [1:0] wr_i1,rd_i1;
    
    mux4n #(2)  m6(2'h1,2'h2,2'h3,2'h0,wrptr,wr_i1),
                m7(2'h1,2'h2,2'h3,2'h0,rdptr,rd_i1);
    
    regn #(2)   r_wr(wr_i1,clk,rst,enqueue,wrptr),
                r_rd(rd_i1,clk,rst,read & o_en_vld,rdptr);  //TODO
                
    //Generate the write mask for eip,addr,data,size.
    wire [3:0] wmask0,wmask1,wmask_alloc,rmask0,rmask1;
    decoder2_4$ d1(wrptr,wmask0,),
                d2(rdptr,rmask0,);
    and2n #(4)  a3(wmask0,{4{enqueue}},wmask1),
                a4(rmask0,{4{read & o_en_vld}},rmask1);
    or2n #(4)   o1(wmask1,rmask1,wmask_alloc);
    
    //Generate write mask for valid.
    //Update valid if (1) last_uop & eq & enqueue (set to 1), (2) enqueue & (idx == wrptr) (set to i_vld) .
    wire [3:0] eq,vldin;
    wire [3:0] wmask_v1,wmask_v2;
    and3n #(4)   a5({4{i_last_uop}},{4{enqueue}},eq,wmask_v1);
    or2n #(4)    o2(wmask_v1,wmask1,wmask_v2);
    
    //Generate the updated input for valid.
    genvar i;
    generate
        for(i=0;i<4;i=i+1) begin : log
            mux2n #(1) m(i_vld,1'b1,i_last_uop,vldin[i]);
        end
    endgenerate
    
    //Declare the main storage element.
    generate    
        for(i=0;i<4;i=i+1) begin: store
            regn #(1) ralloc(wmask1[i],clk,rst,wmask_alloc[i],alloc[i]);
            regn #(1) rvld(vldin[i],clk,rst,wmask_v2[i],vld[i]);
            regn #(32) reip(i_eip,clk,rst,wmask1[i],eip[i]);
            regn #(15) raddr(i_addr,clk,rst,wmask1[i],addr[i]);
            regn #(32) rdata(i_data,clk,rst,wmask1[i],data[i]);
            regn #(3) rsize(i_size,clk,rst,wmask1[i],size[i]);
            
            comp_eq32    c(i_eip_cmp,eip[i],eq[i]);
        end
    endgenerate
    
    
endmodule
    