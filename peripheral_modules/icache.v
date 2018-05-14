///////////////////////////////////////////////////////////////
////               DIRECT MAPPED ICACHE                    ////
//// Contains 8 CLs, each 32B in size. Verified.           ////
//// Returns data in the same cycle  in which the last tra-////
//// nsaction is sent by the bus. So, tristate switching   ////
//// delay is added on the logic delay in the cache to give////
//// the output data. Change if required.                  ////
///////////////////////////////////////////////////////////////

module icache(
    input clk,
    input rst,
    
    //READ PATH (with FETCH stage).
    input [14:0] r_addr,
    input r_vld,
	input page_spill,
    output r_read,
    output r_data_vld,
    output [63:0] r_data,
	output [14:0] addr_out,
    
    //Input from memory.
    input [255:0] mem_data,
    input mem_vld,
    input [14:0] mem_addr,
    
    //Output to lsq.
    output req_vld,
	input req_rd,
    output [14:0] req_addr);    
    
    wire [14:0] cache_addr;
    wire cache_vld,i_hit; 
    wire [255:0] cache_data;
    
    icache_store store(
    .clk        (clk),
    .rst        (rst),
    .addr       (cache_addr),
    .rdvld      (cache_vld),
    .wrdata     (mem_data),
    .wrvld      (mem_vld),
    .hit        (i_hit),
    .rddata     (cache_data));
    
    //FSM & control.
    //Variable declaration.
    wire w2,w3,w4,split,split_n,split_x;
    wire [1:0] valid,vldin;
    wire [2:0] sp_in,sl;
    wire w6,w7;
    wire [1:0] idle_n,idle_n1,req_n,wait_n,next,curr;
    wire miss;
    
    wire [255:0] data,data_shf;
    wire [63:0] data_shf_lsb,data_shf_p1,data_shf_p2;
    wire [14:0] addr;
    wire [2:0] spl;
    
    wire vx;
    wire vren;
    wire [14:0] addrin,addro;
    wire [63:0] regin,regd;   
    wire [63:0] wx1,wx2;
    wire wo1,wo2,wo3,wo4,wo5;
    
    parameter [1:0] IDLE = 2'b0;
    parameter [1:0] REQ = 2'b1;
    parameter [1:0] WAIT = 2'b10;
    
    //Calculate split & split_loc.
    //r_read = r_vld & (!mem_vld).
	wire isIDLE,ishit;
	wire [14:0] ad_ff;
	nor2$	n1(isIDLE,curr[1],curr[0]);
    inv1$    i1(w2,mem_vld);
    and3$    out1(r_read,r_vld,w2,isIDLE);
    
	regn #(15) ad_st(r_addr,clk,rst,isIDLE,ad_ff);
	and2$	n2(ishit,isIDLE,i_hit);
	mux2n #(15) mx_st(ad_ff,r_addr,ishit,addr_out);
	
    //w3 = &(rdaddr[4:2]), w4 = |(rdaddr[1:0])
    //split = w3&w2. split_n = !split. split_x = split & read.
	wire psn;
	inv1$	 ik1(psn,page_spill);
    and2$    a2(w3,r_addr[4],r_addr[3]);
    or3$     o3(w4,r_addr[2],r_addr[1],r_addr[0]);
    and3$    a3(split,w3,w4,psn);
    inv1$    i3(split_n,split);
    and2$     a4(split_x,split,r_read);
    
    //sp_in = How many bytes come from the second CL (or LSBs of the addr).
	and2n #(3) a7(cache_addr[2:0],{3{split}},sp_in);
	
    //FSM.
	wire [1:0] st_i,st_r;
	mux4n #(2) mj1(IDLE,IDLE,WAIT,REQ,{req_rd,split_x},st_i);
	mux2n #(2) mj2(REQ,WAIT,req_rd,st_r);
    mux4n #(2) m3(st_i,st_i,IDLE,REQ,{i_hit,split_x},idle_n1),
               m4(st_r,st_r,WAIT,IDLE,{i_hit,valid[0]},req_n);
			   
    mux2n #(2) ma1(IDLE,idle_n1,r_read,idle_n);
    or2$       o4(w6,valid[0],valid[1]);
    and2$      a6(w7,w6,mem_vld);
    
    mux2n #(2) m5(WAIT,IDLE,w7,wait_n);
    mux3n #(2) m6(idle_n,req_n,wait_n,curr,next);
    
    dffn #(2) df(next,clk,rst,curr);

	//
	
    //Send cache requests based on state.
    //Send req if (curr == REQ | (curr == IDLE & r_read)).
    //Address sent to cache is read address only if cache is read.
    wire isREQ,wint;
    inv1$    req1(wint,curr[1]);
    and2$    areq(isREQ,wint,curr[0]);
    or2$    oreq(cache_vld,isREQ,r_read);
    
    wire [14:0] rdaddr;
    mux2n #(15) areq1(addro,r_addr,r_read,rdaddr);
    mux4n #(15) mreq(rdaddr,rdaddr,mem_addr,rdaddr,{mem_vld,cache_vld},cache_addr);
    
    //Send memory requests if cache misses.
    //mem_req = (cache_vld & !i_hit & !WAIT).
	wire e;
	comp_eq2n cx1(curr,WAIT,e);
    assign req_addr = cache_addr;
    inv1$    nw4(miss,i_hit);
    and3$     nw1(req_vld,miss,cache_vld,e);
    
    //Shift data based on 1st/2nd half.
    //Do a left shift to shift required bits to the LSB locations.
    bshfrlogic_5b #(8) shf(.in(cache_data),.shf_val(cache_addr[4:0]),.o(data_shf));
    assign data_shf_lsb = data_shf[63:0];
    
    //If IDLE (i.e. r_read),use the sp_in just calculated, otherwise take the split_loc (sl) from the register to zero out the required bits.
    mux2n #(3)  m10(sl,sp_in,r_read,spl);
    mux8n #(64) m9(data_shf_lsb,{8'b0,data_shf_lsb[55:0]},{16'b0,data_shf_lsb[47:0]},{24'b0,data_shf_lsb[39:0]},{32'b0,data_shf_lsb[31:0]},
					{40'b0,data_shf_lsb[23:0]},{48'b0,data_shf_lsb[15:0]},{56'b0,data_shf_lsb[7:0]},spl,data_shf_p1);
    
    mux8n #(64) m11(64'b0,{cache_data[7:0],56'b0},{cache_data[15:0],48'b0},{cache_data[23:0],40'b0},{cache_data[31:0],32'b0},
					{cache_data[39:0],24'b0},{cache_data[47:0],16'b0},{cache_data[55:0],8'b0},spl,data_shf_p2);
    
    //Choose either of the above to write into the storage.
    //If(r_read) choose p1.
    //else if(valid[0])    choose p2, else choose p1. => (!r_read & v0) -> p2. !(r_read | (!v0)) -> p2.
    wire [63:0] in;
    wire v0_n;
    inv1$    ivld(v0_n,valid[0]);
    
    //If r_read & IDLE, write 0's or data (if hit) to the entire register. This "resets" the register.
    //Else, or it with the register contents.
    wire [63:0] sel_data;
    mux4n #(64) msel(64'b0,data_shf_lsb,64'b0,data_shf_p1,{split,i_hit},sel_data);
    mux4n #(64) msel1(wx1,sel_data,wx2,sel_data,{valid[0],r_read},regin);
    
    or2n #(64) o5(regd,data_shf_p1,wx1),
               o6(regd,data_shf_p2,wx2);
    
    //Calculate address of the 2nd half, if required.
    wire [15:0] addr_temp;
    inc_16b inc1(addr_temp,,{6'b0,r_addr[14:5]});
    assign addrin = {addr_temp[9:0],5'b0};
    
    //Update the valid bits based on state.
    //In WAIT state, the possible transitions are :00->01,01->11,10->11,11->11.
    or2$    orv(vx,valid[0],valid[1]);
    mux3n #(2) mx2({split_n,i_hit},{i_hit,valid[0]},{vx,1'b1},curr,vldin);
    
    //Generate write condition for the arrays.
    or3$    o7(wren,i_hit,r_read,mem_vld);
    
    //Declare the temp storage.
    regn #(2) vld_reg(vldin,clk,rst,wren,valid);
    regn #(3) split_loc_reg(sp_in,clk,rst,r_read,sl);
    regn #(64) data_reg(regin,clk,rst,wren,regd);
    regn #(15) addr_reg(addrin,clk,rst,r_read,addro);
    
    //Assign outputs.
    assign r_data = regin;
    
    //wo1 = (next == IDLE), wo3 = (curr != IDLE).
    //data rdy = (wo1 & (wo3 | (r_read & split_n & hit))).
    nor2$    no1(wo1,next[0],next[1]);
    or2$     no3(wo3,curr[0],curr[1]);
    and3$    no4(wo4,split_n,r_read,i_hit);
    or2$     no5(wo5,wo4,wo3);
    and2$    no6(r_data_vld,wo5,wo1);
endmodule
