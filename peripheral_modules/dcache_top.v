module dcache(
	input clk,
	input rst,
	
	//Interface with memory stage.
	input tlb_cacheable,
	input [14:0] rdaddr,
	input rdvld,
	output r_read,
	output [31:0] rddata,
	output [14:0] addrout,
	output data_vld,
	
	//Interface with writeback stage.
	input wb_cacheable,
	input [14:0] wb_addr,
	input [1:0] wb_datasize,
	input [31:0] wb_data,
	input wb_vld,
	output wb_read,
	
	//Interface with mem return data.
	input [14:0] mem_addr,
	input [63:0] mem_data,
	input mem_cacheable,
	input mem_vld,
	output mem_read,
	
	//Interface with lsq.
	output out_vld,
	input out_rd,
	output out_rdwr,
	output out_cacheable,
	output [14:0] out_addr,
	output [63:0] out_data,
	output reqCycles,
	output  [2:0] out_size,
	input lsq_full);
	
	//Declare cache storage.
	wire clk_dn,evict,curr_rd_v,curr_mem_v,curr_wb_v,rd_hit,wb_hit;
	wire rden_update,rden_cache,mem_wren,wb_wren,req_cacheable;
	
	wire [14:0] r_rdaddr,wb_wraddr,evict_addr;
	wire [63:0] wb_wrdata,evict_data;
	wire [31:0] r_rddata;
	wire [1:0] wb_size,hit_way_r,hit_way_w;
	wire rd_read;
	
	dcache_store stinst(clk,clk_dn,rst,rden_cache,mem_wren,wb_wren,r_rdaddr,mem_addr,mem_data,
				wb_wraddr,wb_wrdata,wb_size,evict,evict_addr,evict_data,r_rddata,hit_way_r,hit_way_w,rd_hit,wb_hit);
	
	
	//Multiplex between store & load requests. Stores get priority over loads.
	wire st_vld,ld_vld;
	wire [14:0] st_addr,ld_addr;
	wire [63:0] st_data;
	wire [2:0] st_size;
	wire wb_wrcacheable,st_cacheable,reqcycles_st;
	
	or2$	os1(out_vld,st_vld,ld_vld);
	mux2n #(15) mj1(ld_addr,st_addr,st_vld,out_addr);
	mux2n #(64) mj2(64'b0,st_data,st_vld,out_data);
	mux2n #(1)  mj3(1'b0,1'b1,st_vld,out_rdwr);
	mux2n #(3) mj4(3'b0,st_size,st_vld,out_size);
	mux2n #(1) mj5(req_cacheable,st_cacheable,st_vld,out_cacheable);
	mux2n #(1) mj6(1'b0,reqcycles_st,st_vld,reqCycles);
	
	//Store request: (1) based on evict, (2) writeback of a non-cacheable line. Only a memory response can evict a cache line.
	wire st_vld1,st_vld2,st_vld3,alloco,nca;
	inv1$	ncag(nca,wb_wrcacheable);
	and2$	ax1(st_vld1,curr_mem_v,evict);
	or2$	aj2(st_vld3,wb_vld,alloco);
	and2$	aj3(st_vld2,st_vld3,nca);
	or2$	aj4(st_vld,st_vld1,st_vld2);
	
	mux2n #(15) aj5(wb_wraddr,evict_addr,st_vld1,st_addr);
	mux2n #(64) aj6(wb_wrdata,evict_data,st_vld1,st_data);
	mux2n #(3) aj7({1'b0,wb_size},3'h7,st_vld1,st_size);
	mux2n #(1) aj8(wb_wrcacheable,1'b1,st_vld1,st_cacheable);
	mux2n #(1) aj9(1'b0,1'b1,st_vld1,reqcycles_st);
	//and2$	ax1(st_vld,curr_mem_v,evict);
	//assign st_addr = evict_addr;
	//assign st_data = evict_data;
	
	
	//Load request: out_vld = (rden_cache & (!rd_hit)) = nor((!rden),rd_hit). WB always hits in the cache.
	wire rd1;
	inv1$	ix1(rd1,rden_cache);
	nor2$	nx1(ld_vld,rd1,rd_hit);
	assign ld_addr = r_rdaddr;


	
	//Delay the clock to register hit, evict etc. at the correct time.
	wire [10:0] clk_d;
	or2$	oc1(clk_d[0],clk,1'b0),
			oc2(clk_d[1],clk_d[0],1'b0),
			oc3(clk_d[2],clk_d[1],1'b0),
			oc4(clk_d[3],clk_d[2],1'b0),
			oc5(clk_d[4],clk_d[3],1'b0),
			oc6(clk_d[5],clk_d[4],1'b0),
			oc7(clk_d[6],clk_d[5],1'b0),
			oc8(clk_d[7],clk_d[6],1'b0),
			oc9(clk_d[8],clk_d[7],1'b0),
			oc10(clk_d[9],clk_d[8],1'b0),
			oc11(clk_d[10],clk_d[9],1'b0);
	assign clk_dn = clk_d[4];
	
	
	//Declare storage for read requests.
	wire [31:0] mem_data_x;
	mux8n #(32) mj(mem_data[31:0],mem_data[39:8],mem_data[47:16],mem_data[55:24],mem_data[63:32],{8'b0,mem_data[63:40]},
					{16'b0,mem_data[63:48]},{24'b0,mem_data[63:56]},mem_addr[2:0],mem_data_x);
	
	dcache_mshr	mshr_inst(clk,rst,mem_vld,mem_addr,mem_data_x,rd_hit,r_rdaddr,r_rddata,rdvld,r_read,rdaddr,tlb_cacheable,
								data_vld,addrout,rddata,rd_read,rden_update,r_rdaddr,req_cacheable,mshr_full,lsq_full);

	//Declare registers for storing write request.
	wire wr,wr1,axx,w2,split_w4,split_w2,split_w,split_wi;
	wire [1:0] _sz,szo;
	wire [31:0] regin,regd;
	wire [14:0] addrin,addro;
	wire cac_wb;
	
	regn #(1) alloc_w(split_wi,clk,rst,wr1,alloco);
    regn #(32) data_w(regin,clk,rst,wr,regd);
    regn #(15) addr_w(addrin,clk,rst,wr,addro);
	regn #(2) size_w(_sz,clk,rst,wr,szo);
	regn #(1) cac_w(wb_cacheable,clk,rst,wr,cac_wb);
	
	//Generate signals for the write storage.
	wire [15:0] wad1;
	inc_16b inc(wad1,,{4'b0,wb_addr[14:3]});
	assign addrin = {wad1[11:0],3'b0};
	
	
	//Write storages when WB request is read. Alloc is also updated after the 2nd write.
	//inv1$	ixx(axx,alloco);
	//and2$	ai(wr,axx,wb_vld);
	//Second write happens when alloco (if cacheable), alloco & ~st_vld1, if(not cacheable).
	wire wr2,wr3;
	wire st_vldn;
	inv1$ stn(st_vldn,st_vld1);
	and2$	af6(wr3,alloco,st_vldn);
	mux2n #(1) ms2(wr3,alloco,cac_wb,wr2);
	or2$	oxx1(wr1,wr,wr3);
	
	
	//Generate WB split signal, which resets register after each write.
	or2$     o4(w2,wb_addr[1],wb_addr[0]);
    and2$    a4(split_w4,wb_addr[2],w2);
	and3$	 a5(split_w2,wb_addr[0],wb_addr[1],wb_addr[0]);
	mux3n #(1) mux1(1'b0,split_w2,split_w4,wb_datasize,split_w);
	mux2n #(1) mux8(1'b0,split_w,wr,split_wi);
	
	
	//Generate the datasize signal for the 1st half.
	wire [1:0] sz_2,sz_3,sz_4,sz1;
	mux2n #(2) mxa4(2'b1,2'b0,wb_wraddr[0],sz_2);
	mux4n #(2) mxa1(2'h2,2'h2,2'b1,2'b0,wb_wraddr[1:0],sz_3);
	mux4n #(2) mxa2(2'h3,2'h2,2'h1,2'h0,wb_wraddr[1:0],sz_4);
	mux8n #(2) mxa3(wb_datasize,wb_datasize,wb_datasize,wb_datasize,2'b0,sz_2,sz_3,sz_4,{split_w,wb_datasize},sz1);
	
	
	//Generate the datasize signal for writing into the storage.
	wire [1:0] sz_31,sz_41;
	mux4n #(2) mxa5(2'b0,2'b0,2'b0,2'b1,wb_addr[1:0],sz_31);
	mux4n #(2) mxa6(2'b0,2'b0,2'b1,2'h2,wb_addr[1:0],sz_41);
	mux4n #(2) mux4(2'b0,2'b0,sz_31,sz_41,wb_datasize,_sz);
	
	//Generate the shifted data for the 2nd write. Data never has to be shifted for the first write.
	wire [31:0] _4nd,_3rd,_2nd;
	mux4n #(32) mux5(32'b0,{24'b0,wb_data[31:24]},{16'b0,wb_data[31:16]},{8'b0,wb_data[31:8]},wb_wraddr[1:0],_4nd);
	mux4n #(32) mux9(32'b0,32'b0,{24'b0,wb_data[23:16]},{16'b0,wb_data[23:8]},wb_wraddr[1:0],_3rd);
	mux4n #(32) mux6(32'b0,32'b0,32'b0,{24'b0,wb_data[15:8]},wb_wraddr[1:0],_2nd);
	mux4n #(32) mux7(32'b0,_2nd,_3rd,_4nd,wb_datasize,regin);
	
	
	//Multiplex addr, data & size for the 1st & 2nd writes.
	mux2n #(2) mxx2(sz1,szo,alloco,wb_size);
	mux2n #(1) mxx4(wb_cacheable,cac_wb,alloco,wb_wrcacheable);
	mux2n #(15) mxx1(wb_addr,addro,alloco,wb_wraddr);	
	mux2n #(32) mxx3(wb_data,regd,alloco,wb_wrdata[31:0]);
	
	assign wb_wrdata[63:32] = 32'b0;
	
	
	//Arbitrate between requests based on bank conflicts.
	wire c11n,c12n,c13n;
	comp_eq2n c1(r_rdaddr[7:6],wb_wraddr[7:6],c11n),
			  c2(wb_wraddr[7:6],mem_addr[7:6],c12n),
			  c3(mem_addr[7:6],r_rdaddr[7:6],c13n);
	
	and2$	af3(curr_mem_v,mem_vld,mem_cacheable);
	//assign curr_mem_v =	mem_vld;
	
	assign curr_rd_v = rd_read;
	mux2n  #(1) ms1(curr_mem_v,c12n & curr_mem_v,curr_wb_v,mem_wren);
	
	wire wx1,wx2,wx3;
	and2$	x1(wx1,c13n,curr_rd_v),
			x2(wx2,c11n,curr_rd_v);
	and3$	x3(wx3,c11n,c13n,curr_rd_v);
	mux4n #(1) x4(curr_rd_v,wx1,wx2,wx3,{curr_wb_v,curr_mem_v},rden_cache);
	
	wire ws1,ws2;
	and2$	af1(ws1,wr,wb_cacheable),
			af2(ws2,alloco,cac_wb);
	//or2$	ow1(curr_wb_v,wr,alloco);
	or2$	ow1(curr_wb_v,ws1,ws2);
	assign wb_wren = curr_wb_v;
	
	//Assign "read" outputs.
	wire wv1,wv2,wv3,wv4,wv5;
	inv1$	iv1(wv1,curr_wb_v),
			iv2(wv2,alloco),
			iv3(wv4,ld_vld);
	and2$	are(mem_read,mem_vld,wv1);
	//assign mem_read = mem_wren;
	
	and3$	av1(wv3,ld_vld,out_rd,st_vldn);
	or2$	vo1(wv5,wv4,wv3);
	and2$	vo2(rden_update,rden_cache,wv5);
	//assign rden_update = rden_cache & ((~ld_vld) | (ld_vld & (~st_vld) & out_rd));
	
	wire wf1,wf2;
	and2$	af4(wf1,wb_vld,wv2);
	and3$	af5(wf2,wb_vld,st_vldn,wv2);
	mux2n #(1) mf1(wf2,wf1,wb_cacheable,wb_read);
	assign wr = wb_read;
	//assign wb_read = wr;
endmodule
