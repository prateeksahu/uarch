module page_boundary
	(
	input	[31:0]	pc_out,
	
	output	[0:0]	page_bound,
	output	[3:0] 	fetch_width
	);

	wire	[0:0]	bound1;
	wire	[0:0]	bound2;
	
	comp_eq4		c0(pc_out[11:8], 4'hF, bound1);
	mag_comp8$		c1(pc_out[7:0], 8'hF8, bound2, );
	and2n	#(1)	pb(bound1, bound2, page_bound);
	
	wire	[7:0]	t_width;
	wire	[3:0]	neg_pc3;
	
	invn	#(4)	i0(pc_out[3:0], neg_pc3);
	// Subtract lower bits of PC from FF to find the fetch width
	add_8b			a0(t_width, , {4'hF, neg_pc3}, 8'h10, 1'b1);
	assign	fetch_width	= t_width[3:0];
	
endmodule

module fetch
	(
	input	[0:0]	CLK,
	input 	[0:0]	reset,
	//From icache
	input	[63:0]	cache_line,
	input	[14:0]	cache_addr_ret,
	input	[0:0]	cache_line_valid_in,	//Ready
	//From TLB
	input	[43:0]	tlb_trans,
	input	[0:0]	tlb_hit,
	//From branch predictor
	input	[31:0]	bpred_target,
	input	[0:0]	bpred_taken,
	input	[0:0]	bpred_hit,
	//From decode1
	input	[0:0]	dec1_stall_n,
	//From decode2
	input	[0:0]	replay_inst,
	input	[31:0]	replay_EIP,
	//From exec
	input	[31:0]	ex_branch_neip,
	input	[31:0]	ex_branch_target,
	input	[0:0]	ex_branch_taken,
	input	[0:0]	ex_branch_mispred,
	input	[0:0]	ex_branch_valid,
	//From regn
	input	[15:0]	cs_in,
	//From WB
	input	[0:0]	cs_inv,
	input	[31:0]	cs_neip,
	
	
	//To icache
	output	[31:0]	fetch_addr,
	output	[0:0]	fetch_addr_valid,
	//To TLB
	output	[31:0]	tlb_addr,
	output	[0:0]	tlb_access,
	//To branch predictor
	output	[31:0]	bpred_pc_out,
	output	[31:0]	update_bpred_pc,
	output	[31:0]	update_bpred_target,
	output	[0:0]	update_bpred_taken,
	output	[0:0]	update_bpred_mispred,
	output	[0:0]	update_bpred_valid,
	//To decode1
	output	[63:0]	fetch_bytes,
	output	[255:0]	fetch_pcs,
	output	[0:0]	fetch_not_ready,
	output	[3:0]	fetch_width,
	output	[0:0]	page_bound,
	output	[3:0]	br_fetch_id,
	output	[31:0]	fetch_bpred_tgt,
	output	[0:0]	fetch_bpred_taken,
	output	[0:0]	fetch_ex_br_taken
	);

	/*
	wire	[0:0]	reset_sp;

	assign	reset_sp = reset & (~cs_inv) & (~ex_branch_mispred);
	*/
	//PC
	wire	[31:0]	pc_in;
	wire	[31:0]	pc_out;
	wire	[31:0]	pc_out_reg;
	wire	[0:0]	pc_en;
	regn	#(32)	pc(pc_in, CLK, reset, pc_en, pc_out_reg);
	
	//pc+8
	wire	[31:0]	pc_in_inc_0;
	wire	[31:0]	pc_in_inc_1;
	wire	[31:0]	pc_in_inc;
	add_32b			ad0(pc_in_inc_0, , pc_out_reg, 32'd8, 1'b0, );
	
	assign	fetch_pcs[31:0]	= pc_out_reg;
	add_32b			adp1(fetch_pcs[63:32], , pc_out_reg, 32'd1, 1'b0, );
	add_32b			adp2(fetch_pcs[95:64], , pc_out_reg, 32'd2, 1'b0, );
	add_32b			adp3(fetch_pcs[127:96], , pc_out_reg, 32'd3, 1'b0, );
	add_32b			adp4(fetch_pcs[159:128], , pc_out_reg, 32'd4, 1'b0, );
	add_32b			adp5(fetch_pcs[191:160], , pc_out_reg, 32'd5, 1'b0, );
	add_32b			adp6(fetch_pcs[223:192], , pc_out_reg, 32'd6, 1'b0, );
	add_32b			adp7(fetch_pcs[255:224], , pc_out_reg, 32'd7, 1'b0, );

	//Add CS segment
	wire	[15:0]	fetch_hb;
	wire	[15:0]	cs_out;
	
	assign	cs_out 	= cs_in;
	add_16b			adf(fetch_hb, , , pc_out_reg[31:16], cs_out, 1'b0);
	assign	pc_out	= {fetch_hb, pc_out_reg[15:0]};
	
	
	//Translation. Page offset is 12 bits. 
	//One entry is pre_tlb_valid, cacheable, VPN, PPN, valid, present, r/w
	wire	[43:0]	trans_in;
	wire	[43:0]	trans_out;
	wire	[0:0]	trans_en;
	wire	[0:0]	pre_tlb_hit;
	wire	[0:0]	pre_tlb_hit_t;
	wire	[0:0]	pre_tlb_hit_n;
	wire	[0:0]	trans_hit;
	wire	[0:0]	inst_excp_n;
	
	//Pre-TLB access
	regn	#(44)	tr(trans_in, CLK, reset, trans_en, trans_out);
	comp_eq20		cp(trans_out[42:23], pc_out[31:12], pre_tlb_hit_t);
	and2n	#(1)	av(pre_tlb_hit_t, trans_out[2], pre_tlb_hit);
	invn	#(1)	ai(pre_tlb_hit, pre_tlb_hit_n);
	
	//Access TLB when pre_tlb_hit is 0
	assign 	tlb_access	= pre_tlb_hit_n;
	
	assign tlb_addr	= pc_out;
	assign trans_in	= tlb_trans;
	assign trans_en	= tlb_hit;
	
	//If on page boundary, 
	page_boundary	pb(pc_out, page_bound, fetch_width);
	
	add_32b			apb(pc_in_inc_1, , pc_out, {28'h0, fetch_width}, 1'b0, );
	mux2n	#(32)	mpb(pc_in_inc_0, pc_in_inc_1, page_bound, pc_in_inc);
	
	//Cache line valid is checked against address sent to make sure we
	//aren't reading an invalidated request
	wire	[0:0]	invalidated_req;
	comp_eq16	invc({1'b0, fetch_addr[14:0]}, {1'b0, cache_addr_ret}, invalidated_req);
	and2n	#(1)	invd(invalidated_req, cache_line_valid_in, cache_line_valid);

	//pc enable
	
	//Can remove excp_n for now
	wire	[0:0]	ex_br_sel;
	wire	[0:0]	pc_en_t;
	and4n	#(1)	a0(cache_line_valid, dec1_stall_n, trans_hit, inst_excp_n, pc_en_t);
	or4n	#(1)	gh0(pc_en_t, ex_br_sel, cs_inv, replay_inst, pc_en);	
	//Cache access
	or2n	#(1)	oi(pre_tlb_hit, tlb_hit, trans_hit);
	mux2n	#(32)	mq({trans_out[22:3], pc_out[11:0]}, {tlb_trans[22:3], pc_out[11:0]}, tlb_hit, fetch_addr); 
	
	//Update bpred_hit. Eip used as an approx. for pc of the fetched line with the branch
	//Branch is taken only if there was a mis-prediction
	
	//Any number added greater that is greater than 0 casues a replay. To
	//prevent too many sure occurences, the sel pointer is decremented
	//every replay to prevent futher phantom branches, and is promoted to
	//4 immediately after every misprediction.

	wire	[2:0]	br_ptr_in;
	wire	[2:0]	br_ptr;
	wire	[3:0]	br_ptr_dec;
	wire	[2:0]	br_ptr_sel;
	wire	[0:0]	reset_n;

	invn	#(1)	rbp3(reset, reset_n);

	regn	#(3)	rpb0(br_ptr_in, CLK, reset, 1'b1, br_ptr);

	add_4b		dec_br(br_ptr_dec, , {1'b0, br_ptr}, 4'b1110, 1'b1);
	
	mux5n	#(3)	rbp1(br_ptr, br_ptr_dec[2:0], 3'd4, 3'd4, 3'd4, {reset_n, ex_branch_mispred, replay_inst}, br_ptr_in);	

	mux5n	#(32)	rbp2(fetch_pcs[31:0], fetch_pcs[63:32], fetch_pcs[95:64], fetch_pcs[127:96], fetch_pcs[191:160], br_ptr, bpred_pc_out);
	//assign 	bpred_pc_out		= fetch_pcs[159:128];
	assign	update_bpred_pc		= ex_branch_neip;
	assign	update_bpred_taken	= ex_branch_taken;
	assign	update_bpred_target = ex_branch_target;
	assign	update_bpred_mispred= ex_branch_mispred;
	assign  update_bpred_valid	= ex_branch_valid;
	
	
	and2n	#(1)	bpb(ex_branch_taken, ex_branch_valid, fetch_ex_br_taken);
	
	
	wire	[0:0]	br_invalidate;
	and2n	#(1)	inv_b(ex_branch_mispred, ex_branch_valid, br_invalidate);
	
	//For branch taken and correctly predicted, generate ID to br_invalidate trailing bits
	
	wire	[3:0]	br_fetch_id_in;
	add_4b			abb(br_fetch_id_in, , br_fetch_id, 4'd1, 1'b0);
	regn	#(4)	bpp(br_fetch_id_in, CLK, reset, pc_en, br_fetch_id);
	
	
	//PC input selection
	
	//Select the exec branch if prediction was incorrect.
	wire	[31:0]	ex_branch_target_act;
	and2n	#(1)	ap1(ex_branch_mispred, ex_branch_valid, ex_br_sel);
	mux2n	#(32)	mj0(ex_branch_neip, ex_branch_target, fetch_ex_br_taken, ex_branch_target_act);
	
	//pc input 
	wire	[31:0]	pc_in_nr;
	wire	[31:0]	other_pcs;
	wire	[0:0]	bpred_sel;
	
	assign	fetch_bpred_tgt		= bpred_target;
	assign	fetch_bpred_taken	= bpred_sel;
	
	and2n	#(1)	aa(bpred_hit, bpred_taken, bpred_sel);
	
	mux2n	#(32)	m2(pc_in_inc, bpred_target, bpred_sel, pc_in_nr);
	mux2n	#(32)	m3(pc_in_nr, replay_EIP, replay_inst, other_pcs);
	
	mux3n	#(32)	m0(other_pcs, ex_branch_target_act, cs_neip, {cs_inv, ex_br_sel}, pc_in);
	
	
	//Exception handling
	wire	[31:0]	cs_lim;
	
	wire	[0:0] 	inst_pf_excp;
	wire	[0:0] 	inst_gp_excp;
	wire	[0:0] 	inst_excp;
	
	//SEGMENT LIMIT-3!
	assign 	cs_lim		= 32'h4FFF;
	
	mag_comp32		cm2(pc_out_reg, cs_lim, inst_gp_excp, );
	
	wire	[0:0]	trans_hit_n;
	invn	#(1)	ine(trans_hit, trans_hit_n);
	assign 	inst_pf_excp = trans_hit_n;	
	or2n	#(1)	aea(inst_gp_excp, inst_pf_excp, inst_excp);
	
	//Pick the bytes from caches or inst_excp
	wire	[63:0]	inst_excp_bytes;
	wire	[0:0]	inst_excp_n_brx;
	wire	[0:0]	ex_br_sel_n;
	invn	#(1)	brs(ex_br_sel, ex_br_sel_n);
	//Ex branch has highest priority!
	and2n	#(1)	ds3(inst_excp, ex_br_sel_n, inst_excp_n_brx);
	invn	#(1)	fg0(inst_excp, inst_excp_n);
	
	wire	[63:0]	gp_excp_bytes;
	wire	[63:0]	pf_excp_bytes;
	
	wire	[63:0]	cache_line_bige;
	/*
	assign	cache_line_bige [7:0]	= cache_line[63:56];
	assign	cache_line_bige [15:8]	= cache_line[55:48];
	assign	cache_line_bige [23:16]	= cache_line[47:40];
	assign	cache_line_bige [31:24]	= cache_line[39:32];
	assign	cache_line_bige [39:32]	= cache_line[31:24];
	assign	cache_line_bige [47:40]	= cache_line[23:16];
	assign	cache_line_bige [55:48]	= cache_line[15:8];
	assign	cache_line_bige [63:56]	= cache_line[7:0];
	*/
	
	and2n	#(8)	cb0(cache_line[7:0], {8{cache_line_valid}}, cache_line_bige[7:0]);
	and2n	#(8)	cb1(cache_line[15:8], {8{cache_line_valid}}, cache_line_bige[15:8]);
	and2n	#(8)	cb2(cache_line[23:16], {8{cache_line_valid}}, cache_line_bige[23:16]);
	and2n	#(8)	cb3(cache_line[31:24], {8{cache_line_valid}}, cache_line_bige[31:24]);
	and2n	#(8)	cb4(cache_line[39:32], {8{cache_line_valid}}, cache_line_bige[39:32]);
	and2n	#(8)	cb5(cache_line[47:40], {8{cache_line_valid}}, cache_line_bige[47:40]);
	and2n	#(8)	cb6(cache_line[55:48], {8{cache_line_valid}}, cache_line_bige[55:48]);
	and2n	#(8)	cb7(cache_line[63:56], {8{cache_line_valid}}, cache_line_bige[63:56]);
	
	
	mux2n	#(64)	mm3(pf_excp_bytes, gp_excp_bytes, inst_gp_excp, inst_excp_bytes);
	mux2n	#(64)	mm0(cache_line_bige, inst_excp_bytes, inst_excp_n_brx, fetch_bytes);
	
	
	//Fetch ready
	wire	[0:0]	fetch_bytes_inv;
	nor2n	#(1)	avc(cache_line_valid, inst_excp, fetch_bytes_inv);
	or4n	#(1)	ofn(fetch_bytes_inv, br_invalidate, replay_inst, cs_inv, fetch_not_ready);
	
	//Cache access. Best not to give off spurious accesses!
	wire	[0:0]	br_invalidate_n;
	wire	[0:0]	replay_inst_n;
	invn	#(1)	fg1(br_invalidate, br_invalidate_n);
	invn	#(1)	fg2(replay_inst, replay_inst_n);
	
	wire	[0:0]	fetch_addr_valid_t;
	and3n	#(1)	aq(trans_hit, inst_excp_n, replay_inst_n, fetch_addr_valid_t);
	//TODO: Is this needed?
	and2n	#(1)	ar(fetch_addr_valid_t, reset, fetch_addr_valid);
	
	
	//For now, the handers are a single instruction byte followed by NOPs
	assign 	gp_excp_bytes	= 64'h90909090909090CC;
	assign 	pf_excp_bytes	= 64'h90909090909090DD;
	
endmodule
