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
	input	[0:0]	cache_line_valid,	//Ready
	//From TLB
	input	[43:0]	tlb_trans,
	input	[0:0]	tlb_hit,
	//From branch predictor
	input	[31:0]	bpred_target,
	input	[0:0]	bpred_taken,
	input	[0:0]	bpred_hit,
	//From decode1
	input	[0:0]	dec1_stall,
	//From decode2
	input	[0:0]	replay_inst,
	input	[31:0]	replay_EIP,
	//From tlb st
	input	[0:0]	data_gp_excp,
	input	[0:0]	data_pf_excp,
	input	[31:0]	data_excp_eip,
	//From exec
	input	[31:0]	ex_branch_eip,
	input	[31:0]	ex_branch_target,
	input	[0:0]	ex_branch_taken,
	input	[0:0]	ex_branch_mispred,
	input	[0:0]	ex_branch_valid,
	//From regn
	input	[15:0]	cs_in,
	input	[0:0]	cs_en,
	//From ext
	input	[7:0]	intr_vec,
	
	
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
	
	//Send data excp pc if an exception occurred in the datapath
	wire	[0:0] 	data_excp;
	wire	[31:0]	fetch_pc_out;
	
	mux2n	#(32)	fpo(pc_out_reg, data_excp_eip, data_excp, fetch_pc_out);	
	
	assign	fetch_pcs[31:0]	= fetch_pc_out;
	add_32b			adp1(fetch_pcs[63:32], , fetch_pc_out, 32'd1, 1'b0, );
	add_32b			adp2(fetch_pcs[95:64], , fetch_pc_out, 32'd2, 1'b0, );
	add_32b			adp3(fetch_pcs[127:96], , fetch_pc_out, 32'd3, 1'b0, );
	add_32b			adp4(fetch_pcs[159:128], , fetch_pc_out, 32'd4, 1'b0, );
	add_32b			adp5(fetch_pcs[191:160], , fetch_pc_out, 32'd5, 1'b0, );
	add_32b			adp6(fetch_pcs[223:192], , fetch_pc_out, 32'd6, 1'b0, );
	add_32b			adp7(fetch_pcs[255:224], , fetch_pc_out, 32'd7, 1'b0, );

	//Add CS segment
	wire	[15:0]	fetch_hb;
	wire	[15:0]	cs_out;
	
	add_16b			adf(fetch_hb, , , fetch_pc_out[31:16], cs_out, 1'b0);
	assign	pc_out	= {fetch_hb, fetch_pc_out};
	
	
	//Translation. Page offset is 12 bits. 
	//One entry is pre_tlb_valid, cacheable, VPN, PPN, valid, present, r/w
	wire	[43:0]	trans_in;
	wire	[43:0]	trans_out;
	wire	[0:0]	trans_en;
	wire	[0:0]	pre_tlb_hit;
	wire	[0:0]	pre_tlb_hit_t;
	wire	[0:0]	pre_tlb_hit_n;
	wire	[0:0]	trans_hit;
	wire	[0:0]	intr_excp_n;
	
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
	
	//pc enable
	//invn	#(1)	sti(dec1_stall, dec1_stall_n);
	
	//Can remove intr_excp_n for now
	and4n	#(1)	a0(cache_line_valid, dec1_stall, trans_hit, intr_excp_n, pc_en);
	
	//Cache access
	or2n	#(1)	oi(pre_tlb_hit, tlb_hit, trans_hit);
	and2n	#(1)	aq(trans_hit, intr_excp_n, fetch_addr_valid);
	mux2n	#(32)	mq({trans_out[22:3], pc_out[11:0]}, {tlb_trans[22:3], pc_out[11:0]}, tlb_hit, fetch_addr); 
	
	//Update bpred_hit. Eip used as an approx. for pc of the fetched line with the branch
	//Branch is taken only if there was a mis-prediction
	assign 	bpred_pc_out		= pc_out_reg;
	assign	update_bpred_pc		= ex_branch_eip;
	assign	update_bpred_taken	= ex_branch_taken;
	assign	update_bpred_target = ex_branch_target;
	assign	update_bpred_mispred= ex_branch_mispred;
	assign  update_bpred_valid	= ex_branch_valid;
	
	wire	[0:0]	ex_branch_valid_n;
	invn	#(1)	bpi(ex_branch_valid, ex_branch_valid_n);
	assign	fetch_bpred_tgt		= bpred_target;
	and2n	#(1)	bpb(ex_branch_taken, ex_branch_valid, fetch_ex_br_taken);
	and2n	#(1)	bpa(bpred_hit, bpred_taken, fetch_bpred_taken);
	
	//FIFO for in-flight branches here
	//Entry: valid, prediction, EIP
	wire	[32:0]	branch_buff_in;
	wire	[32:0]	branch_buff_out;
	wire	[0:0]	branch_buff_wr;
	wire	[0:0]	branch_buff_rd;
	
	wire	[0:0]	correct_pred;
	wire	[0:0]	invalidate;
	
	
	//Buffer contains pred, eip
	/*
	fifo8	#(34)	bbf(branch_buff_in, branch_buff_wr, branch_buff_rd, CLK, reset,  branch_buff_out);
	
	assign 	branch_buff_in = {bpred_taken, bpred_target};
	and2n	#(1)	anp0(bpred_hit, pc_en, branch_buff_wr);
	and3n	#(1)	anp1(ex_branch_taken, ex_branch_valid, pc_en, branch_buff_rd);
	
	xor2$			xo(incorrect_pred, branch_buff_out[32], ex_branch_taken);
	xnor2$			xn(correct_pred, branch_buff_out[32], ex_branch_taken);
	
	*/	
	and2n	#(1)	inv_b(ex_branch_mispred, ex_branch_valid, invalidate);
	
	//For branch taken and correctly predicted, generate ID to invalidate trailing bits
	
	wire	[3:0]	br_fetch_id_in;
	add_4b			abb(br_fetch_id_in, , br_fetch_id, 4'd1, 1'b0);
	regn	#(4)	bpp(br_fetch_id_in, CLK, reset, pc_en, br_fetch_id);
	
	//Select the exec branch if prediction was incorrect.
	wire	[0:0]	br_sel;
	and2n	#(1)	ap1(ex_branch_mispred, ex_branch_valid, br_sel);
	
	//pc input 
	wire	[31:0]	branch_target;
	wire	[31:0]	pc_inc_data_excp;
	wire	[0:0]	pc_sel;
	wire	[0:0]	bpred_sel;
	
	and2n	#(1)	aa(bpred_hit, bpred_taken, bpred_sel);
	or2n	#(1)	on(br_sel, bpred_sel, pc_sel);
	
	mux2n	#(32)	m0(bpred_target, ex_branch_target, br_sel, branch_target);
	mux2n	#(32)	m1(pc_in_inc, data_excp_eip, data_excp, pc_inc_data_excp);
	
	wire	[31:0]	pc_in_nr;
	mux2n	#(32)	m2(pc_inc_data_excp, branch_target, pc_sel, pc_in_nr);
	mux2n	#(32)	m3(pc_in_nr, replay_EIP, replay_inst, pc_in);
	
	//Interrupt handling
	wire	[0:0]	intr;
	wire	[0:0]	intr1;
	wire	[0:0]	intr2;
	
	comp_eq8		cm0(intr_vec, 8'd1, intr1);
	comp_eq8		cm1(intr_vec, 8'd2, intr2);
	and2n	#(1)	da1(intr1, intr2, intr);
	
	
	//Exception handling
	wire	[31:0]	cs_lim;
	
	wire	[0:0] 	inst_pf_excp;
	wire	[0:0] 	inst_gp_excp;
	wire	[0:0] 	inst_excp;
	wire	[0:0] 	excp;
	
	regn	#(16)	cs(cs_in, CLK, reset, cs_en, cs_out);
	//SEGMENT LIMIT-3!
	assign 	cs_lim		= 32'h7FFC;
	
	mag_comp32		cm2(pc_out_reg, cs_lim, inst_gp_excp, );
	
	wire	[0:0]	trans_hit_n;
	invn	#(1)	ine(trans_hit, trans_hit_n);
	assign 	inst_pf_excp = trans_hit_n;	
	or2n	#(1)	aea(inst_gp_excp, inst_pf_excp, inst_excp);
	
	or2n	#(1)	ds0(data_gp_excp, data_pf_excp, data_excp);
	or2n	#(1)	ds1(data_excp, inst_excp, excp);
	
	//Signal indicating any kind of interrupt or exception
	wire	[0:0]	intr_excp;
	or3n	#(1)	ds2(inst_excp, data_excp, intr, intr_excp);
	invn	#(1)	in0(intr_excp, intr_excp_n);
	
	//Pick the bytes from intr/excp caches
	wire	[63:0]	intr_excp_bytes;
	wire	[0:0]	inst_excp_n_brx;
	wire	[0:0]	br_sel_n;
	invn	#(1)	brs(br_sel, br_sel_n);
	//Ex branch has highest priority!
	and2n	#(1)	ds3(inst_excp, br_sel_n, inst_excp_n_brx);
	
	wire	[63:0]	gp_excp_bytes;
	wire	[63:0]	pf_excp_bytes;
	wire	[0:0]	gp_excp;
	wire	[63:0]	excp_bytes;
	wire	[63:0]	intr_bytes;
	wire	[63:0]	intr1_bytes;
	wire	[63:0]	intr2_bytes;	
	
	or2n	#(1)	oe0(data_gp_excp, inst_gp_excp, gp_excp);
	
	wire	[63:0]	cache_line_bige;
	assign	cache_line_bige [7:0]	= cache_line[63:56];
	assign	cache_line_bige [15:8]	= cache_line[55:48];
	assign	cache_line_bige [23:16]	= cache_line[47:40];
	assign	cache_line_bige [31:24]	= cache_line[39:32];
	assign	cache_line_bige [39:32]	= cache_line[31:24];
	assign	cache_line_bige [47:40]	= cache_line[23:16];
	assign	cache_line_bige [55:48]	= cache_line[15:8];
	assign	cache_line_bige [63:56]	= cache_line[7:0];
	
	mux2n	#(64)	mm0(cache_line_bige, intr_excp_bytes, inst_excp_n_brx, fetch_bytes);
	mux2n	#(64)	mm1(intr_bytes, excp_bytes, excp, intr_excp_bytes);
	mux2n	#(64)	mm2(intr1_bytes, intr2_bytes, intr2, intr_bytes);
	mux2n	#(64)	mm3(pf_excp_bytes, gp_excp_bytes, gp_excp, excp_bytes);
	
	//Fetch ready
	wire	[0:0]	fetch_bytes_inv;
	nor2n	#(1)	avc(cache_line_valid, intr_excp, fetch_bytes_inv);
	or2n	#(1)	ofn(fetch_bytes_inv, invalidate, fetch_not_ready);
	
	//For now, the handers are a single instruction byte followed by NOPs
	assign 	intr1_bytes	= 64'h90909090909090AA;
	assign 	intr2_bytes	= 64'h90909090909090BB;
	assign 	gp_excp_bytes	= 64'h90909090909090CC;
	assign 	pf_excp_bytes	= 64'h90909090909090DD;
	
endmodule