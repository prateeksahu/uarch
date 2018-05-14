///////////////////////////////////////////////////////////////////////
////                   LOAD STORE QUEUES                         //////
////    Contains: A load queue, a store queue, structures for co-//////
////    ncatenating the memory response across cycles.           //////
////    Both the queues have a depth of 8 each.                  //////
////    Note: 1. ICache loads are prioritized over DCache loads. //////
////    2. Load& store requests to the memory are alternated with//////
////    each other.                                              //////
////    3. There is no forwarding from the store buffer to any part////
////    of the processor.                                        //////
///////////////////////////////////////////////////////////////////////

module queues (
	input clk,
	input rst,
	
	//Load request from I$.
	input [14:0] ic_addr,
	input ic_req_vld,
	output ic_read,
	
	//Load request from D$.
	input [14:0] dc_addr,
	input dc_req_vld,
	output dc_read,
	
	//Store request from D$.
	input [14:0] wb_addr,
	input [63:0] wb_data,
	input wb_req_vld,
	output wb_read,
	
	//Miss response from memory.
	input [54:0] mem_transaction,
	
	output load_queue_full,
	output store_queue_full,
	
	//Miss return data to I$.
	output [32*8-1:0] ic_ret,
	output [14:0] ic_ret_addr,
	output ic_ret_vld,
	
	//Miss return data to D$.
	output [63:0] dc_ret,
	output [14:0] dc_ret_addr,
	output dc_ret_vld,
	
	//Load/Stores requests on the bus.
	output [54:0] bus_transaction,
	input bus_gnt
);
	wire ic_wr,dc_wr,w1,w2,wack,wresp,w3;
	wire sq_v,lq_v,sq_push,lq_push;
	wire [15:0] lq_o,lq_in;
	wire [79:0] sq_o,sq_in;
	
	//Assign the push signals to the collection buffers.
	and2$	icw(ic_wr,mem_transaction[54],mem_transaction[32]);
	
	nor2$	nw(w1,mem_transaction[32],mem_transaction[33]);
	and2$	dcw(dc_wr,w1,mem_transaction[54]);

	//Assign the queue push signals.
	or2$	ow1(lq_push,ic_req_vld,dc_req_vld);
	
	assign sq_push = wb_req_vld;
	
	//Arbitrate between load requests from I- & D- caches.
	assign ic_read = ic_req_vld;
	inv1$	i1(w3,ic_req_vld);
	and2$	a1(dc_read,dc_req_vld,w3);
	assign wb_read = wb_req_vld;
	
	//Assign the queue inputs.
	mux2n #(16) ml({1'b0,dc_addr},{1'b1,ic_addr},ic_req_vld,lq_in);
	assign sq_in = {1'b0,wb_addr,wb_data};
	
	//Assign the queue pop signals.
	or2$	ow(wresp,ic_ret_vld,dc_ret_vld);
	inv1$	iw(w2,mem_transaction[32]);
	and3$	aw(wack,w2,mem_transaction[33],mem_transaction[54]);


	//Arbitrate between load & store queues for control of the bus.
	wire [54:0] ld_tr,st_tr;
	wire [31:0] st_data;
	wire lq_ptr_inc;
	
	//Create an FSM for sending data on the bus. Loads & stores alternate, with a higher priority to loads.
	parameter [1:0] IDLE = 2'b00;
	parameter [1:0] ST1 = 2'b01;
	parameter [1:0] ST2 = 2'b10;
	parameter [1:0] ST3 = 2'b11;
	
	wire [1:0] curr,next;
	wire [1:0] idle_n1,idle_n,st2_n;
	wire wx,sel;
	
	mux4n #(2) 	ms1(IDLE,ST1,IDLE,ST2,{lq_v,sq_v},idle_n1);
	mux2n #(2) 	ms2(IDLE,idle_n1,bus_gnt,idle_n),
				ms3(ST2,ST3,bus_gnt,st2_n);
	mux4n #(2)  ms4(idle_n,IDLE,st2_n,IDLE,curr,next);
	
	dffn #(2)	df1(next,clk,rst,curr);
	
	//ptr_inc_st = (curr == ST1 || curr == ST3).= curr[1].
	//ptr_inc_ld = (curr == IDLE & ld.v & bus_gnt)
	mux2n #(32) ms5(sq_o[31:0],sq_o[63:32],curr[0],st_data);
	nor2$		no1(wx,curr[0],curr[1]);
	and2$		an1(sel,wx,lq_v);
	and2$		an2(lq_ptr_inc,sel,bus_gnt);
	
	mux2n #(55)	ms6(st_tr,ld_tr,sel,bus_transaction);
	
	//Construct the bus transaction & send.		
	assign ld_tr[31:0] = 32'b0;
	assign ld_tr[32] = lq_o[15];
	assign ld_tr[33] = 1'b0;
	assign ld_tr[35:34] = 2'b11;
	assign ld_tr[37:36] = 2'b10;
	assign ld_tr[52:38] = lq_o[14:0];
	assign ld_tr[53] = 1'b1;
	assign ld_tr[54] = lq_v;
	
	assign st_tr[31:0] = st_data;
	assign st_tr[32] = 1'b0;
	assign st_tr[33] = 1'b0;
	assign st_tr[35:34] = 2'b11;
	assign st_tr[37:36] = 2'b10;
	assign st_tr[52:38] = sq_o[78:64];
	assign st_tr[53] = 1'b0;
	assign st_tr[54] = sq_v;
	
	//Instantiate the modules.
	buf8_allread #(32) icache_resp(clk,rst,mem_transaction[31:0],ic_wr,ic_ret,ic_ret_vld);
	buf2_fullread #(32) dcache_resp(clk,rst,mem_transaction[31:0],dc_wr,dc_ret,dc_ret_vld);
	
	fifo8_1r1w #(16) load_queue(clk,rst,lq_push,lq_in,wresp,lq_ptr_inc,lq_o,lq_v,load_queue_full);
	fifo8_1r1w #(80) store_queue(clk,rst,sq_push,sq_in,wack,curr[0],sq_o,sq_v,store_queue_full);
endmodule