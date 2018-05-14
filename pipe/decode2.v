module decode2
	(
	input	[0:0]	CLK,
	input	[0:0]	reset,
	
	input	[0:0]	has_prefix1,
	input	[0:0]	has_prefix2,
	input	[0:0]	has_prefix3,
	input	[0:0]	has_imm8,
	input	[0:0]	has_imm16,
	input	[0:0]	has_imm32,
	input	[0:0]	has_disp8,
	input	[0:0]	has_disp32,
	input	[0:0]	has_op2,
	input	[0:0]	has_modrm, 
	input	[0:0]	has_sib, 
	
	
	input	[3:0]	size,
	
	input	[7:0]	prefix2_byte,
	input	[7:0]	opcode1_byte,
	input	[7:0]	opcode2_byte,
	input	[7:0]	modrm_byte,
	input	[7:0]	sib_byte,
	
	input	[7:0]	b0,
	input	[7:0]	b1,
	input	[7:0]	b2,
	input	[7:0]	b3,
	input	[7:0]	b4,
	input	[7:0]	b5,
	input	[7:0]	b6,
	input	[7:0]	b7,
	input	[7:0]	b8,
	input	[7:0]	b9,
	input	[7:0]	b10,
	input	[7:0]	b11,
	input	[7:0]	b12,
	
	input	[31:0]	eip,
	input	[0:0]	dec1_not_ready,
	input	[3:0]	br_fetch_id,
	input	[31:0]	bpred_tgt,
	input	[0:0]	bpred_taken,
	input	[0:0]	ex_br_taken,
	
	input	[0:0]	rr_stall,
	
	//From tlb st
	input	[0:0]	data_gp_excp_in,
	input	[0:0]	data_pf_excp_in,
	input	[31:0]	data_excp_eip,
	//From extern 
	input	[31:0]	intr_vec,
	input	[0:0]	intr_in,

	input	[0:0]	datapath_inv_in,
	input	[0:0]	ex_inv,
	input	[0:0]	cs_inv,
	input	[0:0]	other_inv_in,

	//Misc
	input	[0:0]	pipe_clean, 
	input	[0:0]	excp_dflag,
	input	[0:0]	ex_dflag,
	input	[0:0]	cs_dflag,
	input	[0:0]	repne_term,

	output	[0:0]	dec2_stall,
	output	[0:0]	bytes_cleanup,
	output	[3:0]	cleanup_id,
	output	[0:0]	replay_inst,
	output	[31:0]	replay_eip,
	
			
	//Pipeline read reg
	output	[61:0]	i_CS,			output	[31:0]	i_imm,		output	[31:0]	i_disp,
	output	[1:0]  	i_immSize,		output	[1:0]	i_dispSize,	output	[0:0]	i_SIB,
	output	[1:0]	i_scale,		output	[0:0]	i_baseRen,	output	[0:0]	i_idxRen,
	output	[31:0]	i_nEIP,			output	[31:0]	i_EIP,		output	[31:0]	i_bp_tgt,
	output 	[7:0]  	i_imm8,			output	[1:0]	i_opSize,	output	[2:0]	i_sr1,
	output	[2:0]  	i_sr2,			output	[2:0]	i_base,		output	[2:0]	i_idx,  
	output	[2:0]  	i_segR1,		output 	[2:0]  	i_segR2,	output	[0:0]	i_bp_taken,
	output  [0:0]   i_indir,	output	[0:0]	i_Dflag,    output	[3:0]  	i_br_fetch_id,
	output	[0:0]	i_v
	);

	wire	[0:0]	has_prefix1_out;
	wire	[0:0]	has_prefix2_out;
	wire	[0:0]	has_prefix3_out;
	wire	[0:0]	has_imm8_out;
	wire	[0:0]	has_imm16_out;
	wire	[0:0]	has_imm32_out;
	wire	[0:0]	has_disp8_out;
	wire	[0:0]	has_disp32_out;
	wire	[0:0]	has_op2_out;
	wire	[0:0]	has_modrm_out;
	wire	[0:0]	has_sib_out;
	
	wire	[3:0]	size_out;
	
	wire	[7:0]	prefix2_byte_out;
	wire	[7:0]	opcode1_byte_out;
	wire	[7:0]	opcode2_byte_out;
	wire	[7:0]	modrm_byte_out;
	wire	[7:0]	sib_byte_out;
	
	wire	[7:0]	b0_out;
	wire	[7:0]	b1_out;
	wire	[7:0]	b2_out;
	wire	[7:0]	b3_out;
	wire	[7:0]	b4_out;
	wire	[7:0]	b5_out;
	wire	[7:0]	b6_out;
	wire	[7:0]	b7_out;
	wire	[7:0]	b8_out;
	wire	[7:0]	b9_out;
	wire	[7:0]	b10_out;
	wire	[7:0]	b11_out;
	wire	[7:0]	b12_out;
	
	wire	[31:0]	eip_out;
	wire	[31:0]	bpred_tgt_out;
	wire	[0:0]	bpred_taken_out;
	wire	[3:0]	br_fetch_id_out;
	
	wire	[0:0]	has_prefix1_t;
	wire	[0:0]	has_prefix2_t;
	wire	[0:0]	has_prefix3_t;
	wire	[0:0]	has_imm8_t;
	wire	[0:0]	has_imm16_t;
	wire	[0:0]	has_imm32_t;
	wire	[0:0]	has_disp8_t;
	wire	[0:0]	has_disp32_t;
	wire	[0:0]	has_op2_t;
	wire	[0:0]	has_modrm_t;
	wire	[0:0]	has_sib_t;
	
	wire	[7:0]	prefix2_byte_t;
	wire	[7:0]	opcode2_byte_t;
	wire	[7:0]	modrm_byte_t;
	wire	[7:0]	sib_byte_t;
	
	wire	[7:0]	b0_t;
	wire	[7:0]	b1_t;
	wire	[7:0]	b2_t;
	wire	[7:0]	b3_t;
	wire	[7:0]	b4_t;
	wire	[7:0]	b5_t;
	wire	[7:0]	b6_t;
	wire	[7:0]	b7_t;
	wire	[7:0]	b8_t;
	wire	[7:0]	b9_t;
	wire	[7:0]	b10_t;
	wire	[7:0]	b11_t;
	wire	[7:0]	b12_t;
	
	wire	[31:0]	eip_t;
	wire	[31:0]	bpred_tgt_t;
	wire	[0:0]	bpred_taken_t;
	wire	[3:0]	br_fetch_id_t;
	/*
	wire	[0:0]	reset;	
	assign	reset = reset_in & (~ex_inv) & (~cs_inv);
	*/
	// Valid
	
	wire	[0:0]	data_gp_excp;
	wire	[0:0]	data_pf_excp;
	wire	[0:0]	data_gp_excp_n;
	
	assign	data_gp_excp = data_gp_excp_in;
	invn	#(1)	fet(data_gp_excp, data_gp_excp_n);

	and2n	#(1)	fer(data_pf_excp_in, (data_gp_excp_n), data_pf_excp);

	// datapath_inv now also contain replayed inst
	wire	[0:0]	datapath_inv;
	wire	[0:0]	datapath_inv_n;
	or3n	#(1)	dpi0(datapath_inv_in, repne_term, replay_inst, datapath_inv);
	nor3n	#(1)	dpi1(datapath_inv_in, repne_term, replay_inst, datapath_inv_n);

	wire	[0:0]	other_inv;
	or2n	#(1)	dffg(other_inv_in, repne_term, other_inv);
	
	wire	[0:0]	valid;
	wire	[0:0]	reg_en;
	wire	[0:0]	reg_en_op1;
	wire	[0:0]	valid_out;		
	wire	[0:0]	data_excp;
	
	//Valid if earlier one is valid or a non-excp invalidate arrives 
	nor2n	#(1)	ii(dec1_not_ready, datapath_inv, valid);
	wire	[0:0]	dec2_stall_n;
	wire	[0:0]	dec2_stall_no_hlt_n;
	invn	#(1)	ij(dec2_stall, dec2_stall_n);

	//Write into latch if no stall and valid	
	and2n	#(1)	rdy1(valid, dec2_stall_n, reg_en);

	//Write into opcode/valid 
	assign 	reg_en_op1	= dec2_stall_no_hlt_n;
	wire	[0:0]	rr_stall_n;
	invn	#(1)	ik(rr_stall, rr_stall_n);
	and2n	#(1)	dec(valid_out, rr_stall_n, dec2_en);

	//Valid in is 1 if data_excp! TODO: RESET all other times
	wire	[0:0]	valid_in_t;
	or2n	#(1)	rff(valid, data_excp_or_intr, valid_in_t);
	
	mux2n	#(1)	ffd(valid_in_t,	1'b0, (other_inv), valid_in);
	wire	[0:0]	valid_en;
	or2n	#(1)	r99(dec2_stall_no_hlt_n, other_inv, valid_en);	
	regn	#(1)	r00(valid_in, CLK, reset, valid_en, valid_out);
	//Reset latches on an invadation
	wire	[0:0]	reset_latch;
	wire	[0:0]	reset_latch_other;
	wire	[0:0]	reset_latch_n;
	wire	[0:0]	other_inv_n;
	invn	#(1)	rstk(other_inv, other_inv_n);
	nand2n	#(1)	rstl(reset, datapath_inv_n, reset_latch);		
	and2n	#(1)	rstm(reset, datapath_inv_n, reset_latch_n);		
	nand2n	#(1)	rstn(reset, other_inv_n, reset_latch_other);		

	// Registers
	
	mux2n	#(1)	rl0(has_prefix1, 1'b0, reset_latch, has_prefix1_t);
	regn	#(1)	r01(has_prefix1_t, CLK, reset, reg_en, has_prefix1_out);
	mux2n	#(1)	rl1(has_prefix2, 1'b0, reset_latch, has_prefix2_t);
	regn	#(1)	r02(has_prefix2_t, CLK, reset, reg_en, has_prefix2_out);
	mux2n	#(1)	rl2(has_prefix3, 1'b0, reset_latch, has_prefix3_t);
	regn	#(1)	r03(has_prefix3_t, CLK, reset, reg_en, has_prefix3_out);
	mux2n	#(1)	rl3(has_imm8, 1'b0, reset_latch, has_imm8_t);
	regn	#(1)	r04(has_imm8_t, CLK, reset, reg_en, has_imm8_out);
	mux2n	#(1)	rl4(has_imm16, 1'b0, reset_latch, has_imm16_t);
	regn	#(1)	r05(has_imm16_t, CLK, reset, reg_en, has_imm16_out);
	mux2n	#(1)	rl5(has_imm32, 1'b0, reset_latch, has_imm32_t);
	regn	#(1)	r06(has_imm32_t, CLK, reset, reg_en, has_imm32_out);
	mux2n	#(1)	rl6(has_disp8, 1'b0, reset_latch, has_disp8_t);
	regn	#(1)	r07(has_disp8_t, CLK, reset, reg_en, has_disp8_out);
	mux2n	#(1)	rl7(has_disp32, 1'b0, reset_latch, has_disp32_t);
	regn	#(1)	r08(has_disp32_t, CLK, reset, reg_en, has_disp32_out);
	mux2n	#(1)	rl8(has_op2, 1'b0, reset_latch, has_op2_t);
	regn	#(1)	ro0(has_op2_t, CLK, reset, reg_en, has_op2_out);
	mux2n	#(1)	rl9(has_modrm, 1'b0, reset_latch, has_modrm_t);
	regn	#(1)	ro1(has_modrm_t, CLK, reset, reg_en, has_modrm_out);
	mux2n	#(1)	rla(has_sib, 1'b0, reset_latch, has_sib_t);
	regn	#(1)	ro2(has_sib_t, CLK, reset, reg_en, has_sib_out);
	
	wire	[3:0]	size_t;
	//Reset problem
	and2n	#(4)	ress(size, {4{reset_latch_n}}, size_t);
	regn	#(4)	r09(size_t, CLK, reset, reg_en, size_out);
	
	mux2n	#(8)	rlb(prefix2_byte, 8'b0, reset_latch, prefix2_byte_t);
	regn	#(8)	r0a(prefix2_byte_t, CLK, reset, reg_en, prefix2_byte_out);
	//Special reset to prevent HALT
	
	
	wire	[0:0]	sp_reset;
	wire	[7:0]	opcode1_byte_rst;
	wire	[0:0]	op_halt;
	wire	[0:0]	op_halt_t;
	
	and2n	#(1)	fgh(op_halt_t, valid_out, op_halt);
	
	//If data_excp is 1, store other_op into opcode1_byte
	wire	[7:0]	other_op;
	mux8n	#(8)	spr(opcode1_byte, other_op, 8'h90, 8'h90, 8'hF4, other_op, 8'h90, 8'h90, {op_halt, other_inv, data_excp_or_intr}, opcode1_byte_rst);
	regn	#(8)	r0b(opcode1_byte_rst, CLK, reset, reg_en_op1, opcode1_byte_out);
	
	mux2n	#(8)	rlc(opcode2_byte, 8'b0, reset_latch, opcode2_byte_t);
	regn	#(8)	r0c(opcode2_byte_t, CLK, reset, reg_en, opcode2_byte_out);
	mux2n	#(8)	rld(modrm_byte, 8'b0, reset_latch, modrm_byte_t);
	regn	#(8)	r0d(modrm_byte_t, CLK, reset, reg_en, modrm_byte_out);
	mux2n	#(8)	rle(sib_byte, 8'b0, reset_latch, sib_byte_t);
	regn	#(8)	r0e(sib_byte_t, CLK, reset, reg_en, sib_byte_out);
	
	mux2n	#(8)	rlf(b0, 8'b0, reset_latch, b0_t);
	regn	#(8)	r0f(b0_t, CLK, reset, reg_en, b0_out);
	mux2n	#(8)	rlg(b1, 8'b0, reset_latch, b1_t);
	regn	#(8)	r0g(b1_t, CLK, reset, reg_en, b1_out);
	mux2n	#(8)	rlh(b2, 8'b0, reset_latch, b2_t);
	regn	#(8)	r0h(b2_t, CLK, reset, reg_en, b2_out);
	mux2n	#(8)	rli(b3, 8'b0, reset_latch, b3_t);
	regn	#(8)	r0i(b3_t, CLK, reset, reg_en, b3_out);
	mux2n	#(8)	rlj(b4, 8'b0, reset_latch, b4_t);
	regn	#(8)	r0j(b4_t, CLK, reset, reg_en, b4_out);
	mux2n	#(8)	rlk(b5, 8'b0, reset_latch, b5_t);
	regn	#(8)	r0k(b5_t, CLK, reset, reg_en, b5_out);
	mux2n	#(8)	rll(b6, 8'b0, reset_latch, b6_t);
	regn	#(8)	r0l(b6_t, CLK, reset, reg_en, b6_out);
	mux2n	#(8)	rlm(b7, 8'b0, reset_latch, b7_t);
	regn	#(8)	r0m(b7_t, CLK, reset, reg_en, b7_out);
	mux2n	#(8)	rln(b8, 8'b0, reset_latch, b8_t);
	regn	#(8)	r0n(b8_t, CLK, reset, reg_en, b8_out);
	mux2n	#(8)	rlo(b9, 8'b0, reset_latch, b9_t);
	regn	#(8)	r0o(b9_t, CLK, reset, reg_en, b9_out);
	mux2n	#(8)	rlp(b10, 8'b0, reset_latch, b10_t);
	regn	#(8)	r0p(b10_t, CLK, reset, reg_en, b10_out);
	mux2n	#(8)	rlq(b11, 8'b0, reset_latch, b11_t);
	regn	#(8)	r0q(b11_t, CLK, reset, reg_en, b11_out);
	mux2n	#(8)	rlr(b12, 8'b0, reset_latch, b12_t);
	regn	#(8)	r0r(b12_t, CLK, reset, reg_en, b12_out);

	/*
	wire	[31:0]	eip_z;
	and2n	#(32)	ez(eip, {32{valid}}, eip_z);
	*/
       //Maybe not needed at all! (reseting the eip latch)
        wire	[31:0]	rst_pc;
	wire	[0:0]	other_pc;
	wire	[0:0]	intr_op;	
	or2n	#(1)	ghk(reset_latch_other, intr_op, other_pc);
       	mux2n	#(32)	ghj(32'b0, eip, intr_op, rst_pc); 
	mux3n	#(32)	rls(eip, data_excp_eip, rst_pc, {other_pc, data_excp}, eip_t);
	regn	#(32)	r0s(eip_t, CLK, reset, reg_en_op1, eip_out);

	mux2n	#(4)	rlt(br_fetch_id, 4'b0, reset_latch, br_fetch_id_t);
	regn	#(4)	r0t(br_fetch_id_t, CLK, reset, reg_en, br_fetch_id_out);
	mux2n	#(32)	rlu(bpred_tgt, 32'b0, reset_latch, bpred_tgt_t);
	regn	#(32)	r0u(bpred_tgt_t, CLK, reset, reg_en, bpred_tgt_out);
	mux2n	#(1)	rlv(bpred_taken, 1'b0, reset_latch, bpred_taken_t);
	regn	#(1)	r0v(bpred_taken_t, CLK, reset, reg_en, bpred_taken_out);
	wire	[0:0]	ex_br_taken_out;
	mux2n	#(1)	rlw(ex_br_taken, 1'b0, reset_latch, ex_br_taken_t);
	regn	#(1)	r0w(ex_br_taken_t, CLK, reset, reg_en, ex_br_taken_out);
	
	/*------------------------------------------------------------------*/
	
	//Branches. We do two things here: 
	// 	(a) Cleanup extra bits if branch is taken (whether an exec branch or a pred one)
	//	(b) Set bit on seen branch pred w/o branch inst and wait for BR. If a BR doesn't arrive before ID changes, invalidate current instruction, and everything before it
	
	wire	[3:0]	br_sid_in;
	wire	[0:0]	br_sid_en;
	wire	[3:0]	br_sid;
	wire	[0:0]	op_br;
	wire	[0:0]	op_br_n;
	wire	[0:0]	ex_br_taken_out_n;
	
	invn	#(1)	tr0(op_br, op_br_n);
	invn	#(1)	tr1(ex_br_taken_out, ex_br_taken_out_n);
	
	wire	[0:0]	pred_taken;
	wire	[0:0]	pred_taken_out;
	wire	[3:0]	br_sid_in_t;
	wire	[0:0]	pred_taken_t;	

	mux2n	#(4)	brs0(br_sid_in, 4'b0, datapath_inv, br_sid_in_t);	
	mux2n	#(1)	brs1(pred_taken, 1'b0, datapath_inv, pred_taken_t);	
	regn	#(4)	brc(br_sid_in_t, CLK, reset, br_sid_en, br_sid);
	regn	#(32)	bre(eip_t, CLK, reset, br_sid_en, replay_eip);
	regn	#(1)	prt(pred_taken_t, CLK, reset, reg_en, pred_taken_out);
	
	and4n	#(1)	aab(valid_out, bpred_taken_out, ex_br_taken_out_n, op_br_n, pred_taken);
	wire	[0:0]	bytes_cleanup_t;
	or2n	#(1)	ocl(bpred_taken_out, ex_br_taken_out, bytes_cleanup_t);
	and3n	#(1)	oc2(bytes_cleanup_t, valid_out, op_br, bytes_cleanup);
	
	assign 	cleanup_id	= br_fetch_id_out;
	assign	br_sid_in	= br_fetch_id_out;
	
	and2n	#(1)	aac(pred_taken, reg_en, br_sid_en);
	
	wire	[0:0]	same_fetch;
	wire	[0:0]	same_fetch_n;
	comp_eq4		idc(br_sid, br_fetch_id_out, same_fetch);
	invn	#(1)	sfn(same_fetch, same_fetch_n);
	
	and3n	#(1)	rpl(pred_taken_out, same_fetch_n, valid_out, replay_inst);
	
	
	/*------------------------------------------------------------------*/

	//Interrupt register
	//When an interrupt occurs, stall the pipline till the pipe is clean.
	//Then issue the interrupt uops and de-assert the stall and 
	//interrupt signals

	wire	[0:0]	intr_in_t;
	wire	[31:0]	intrv_t;
	wire	[0:0]	intr_clear;
	wire	[0:0]	intr_latch;

	wire	[0:0]	intr_in_m;
	wire	[31:0]	intrv_m;
	wire	[31:0]	intrv_latch;

	mux2n	#(1)	int0(intr_in_m, 1'b0, intr_clear, intr_in_t);
	or2n	#(1)	int2(intr_in, intr_latch, intr_in_m);
	regn	#(1)	int1(intr_in_t, CLK, reset, 1'b1, intr_latch);

	mux2n	#(32)	int6(intr_vec, intrv_latch, intr_latch, intrv_m);

	mux2n	#(32)	int3(intrv_m, 32'b0, intr_clear, intrv_t);
	regn	#(32)	int5(intrv_t, CLK, reset, 1'b1, intrv_latch);
	
	wire	[0:0]	intr_op_n;
	invn	#(1)	ilatn(intr_op, intr_op_n);

	and3n	#(1)	int22(intr_op, valid_out, rr_stall_n, intr_clear); 

	/*------------------------------------------------------------------*/
	
	//Interrupt/Exception handling
	
	
	
	wire	[0:0]	intr1;
	wire	[0:0]	intr2;
	wire	[0:0]	intr1_t;
	wire	[0:0]	intr2_t;
	wire	[0:0]	pipe_clean_n;
	
	comp_eq32	cm0(intrv_latch, 32'hF, intr1_t);
	comp_eq32	cm1(intrv_latch, 32'd2, intr2_t);

	wire	[0:0]	dec1_not_ready_n;
	invn	#(1)	ck0(dec1_not_ready, dec1_not_ready_n);

	and4n	#(1)	cl0(intr1_t, intr_latch, pipe_clean_n, dec1_not_ready_n, intr1);
	and4n	#(1)	cl1(intr2_t, intr_latch, pipe_clean_n, dec1_not_ready_n,intr2);

	invn	#(1)	pcl(pipe_clean, pipe_clean_n);
	or2n	#(1)	da1(intr1, intr2, intr_op);
	
	wire	[7:0]	intr1_op;
	wire	[7:0]	intr2_op;
	wire	[7:0]	gp_op;
	wire	[7:0]	pf_op;
	assign	intr1_op	=	8'hAA;
	assign	intr2_op	=	8'hEE;
	assign	gp_op		=	8'hCC;
	assign	pf_op		=	8'hDD;
	
	wire	[7:0]	intr1_op_t;
	wire	[7:0]	intr2_op_t;
	wire	[7:0]	gp_op_t;
	wire	[7:0]	pf_op_t;
	nand2n	#(8)	y0(intr1_op, {8{intr1}}, intr1_op_t);
	nand2n	#(8)	y1(intr2_op, {8{intr2}}, intr2_op_t);
	nand2n	#(8)	y2(gp_op, {8{data_gp_excp}}, gp_op_t);
	nand2n	#(8)	y3(pf_op, {8{data_pf_excp}}, pf_op_t);
	nand4n	#(8)	y4(intr1_op_t, intr2_op_t, gp_op_t, pf_op_t, other_op);
	
	wire	[0:0]	data_excp_n;
	wire	[0:0]	data_excp_or_intr_n;
	or2n	#(1)	y5(data_pf_excp, data_gp_excp, data_excp);
	nor2n	#(1)	yy9(data_pf_excp, data_gp_excp, data_excp_n);
	or4n	#(1)	y7(data_pf_excp, data_gp_excp, intr1, intr2, data_excp_or_intr);
	nor4n	#(1)	yy8(data_pf_excp, data_gp_excp, intr1, intr2, data_excp_or_intr_n);

	wire	[3:0]	sto;
	wire	[0:0]	data_excp_or_intr_op;
	comp_eq8	eo0(intr1_op, opcode1_byte_out, sto[0]);
	comp_eq8	eo1(intr2_op, opcode1_byte_out, sto[1]);
	comp_eq8	eo2(gp_op, opcode1_byte_out, sto[2]);
	comp_eq8	eo3(pf_op, opcode1_byte_out, sto[3]);
	or4n	#(1)	eo4(sto[0], sto[1], sto[2], sto[3], data_excp_or_intr_op);


	/*------------------------------------------------------------------*/
	
	
	wire	[3:0]	imm_sel;
	wire	[3:0]	imm_diff;
	wire	[3:0]	disp_sel;
	wire	[3:0]	disp_diff;
	
	//Calculate the disp/imm offset based on size and disp/imm size
	wire	[0:0]	has_imm32_out_n;
	wire	[0:0]	has_imm16_out_n;
	wire	[0:0]	has_imm8_out_n;
	invn	#(1)	i0(has_imm32_out, has_imm32_out_n);
	invn	#(1)	ih(has_imm16_out, has_imm16_out_n);
	invn	#(1)	i1(has_imm8_out, has_imm8_out_n);
	//Some minterms
	wire	[0:0]	min0;	//b&&!e
	wire	[0:0]	min1;	//b&&d
	wire	[0:0]	min2;	//a&&e
	wire	[0:0]	min3;	//b&&c
	wire	[0:0]	min4;	//a&&c
	wire	[0:0]	min5;	//a&&d
	wire	[0:0]	min6;	//a&&!c
	and2n	#(1)	a0(has_disp32_out, has_imm32_out_n, min0);
	and2n	#(1)	a1(has_disp32_out, has_imm16_out, min1);
	and2n	#(1)	a2(has_disp8_out, has_imm32_out, min2);
	and2n	#(1)	a3(has_disp32_out, has_imm8_out, min3);
	and2n	#(1)	a4(has_disp8_out, has_imm8_out, min4);
	and2n	#(1)	a5(has_disp8_out, has_imm16_out, min5);
	and2n	#(1)	a6(has_disp8_out, has_imm8_out_n, min6);
	//d3, d2, d1, d0
	and2n	#(1)	a7(has_disp32_out, has_imm32_out, disp_diff[3]);
	or4n	#(1)	o0(min0, min1, min2, min3, disp_diff[2]);
	or3n	#(1)	o1(min4, min1, min5, disp_diff[1]);
	or4n	#(1)	o2(min6, min5, min2, min3, disp_diff[0]);
	//i3, i2, i1, i0
	assign	imm_diff[3]	= 1'b0;
	assign 	imm_diff[2]	= has_imm32_out;
	assign 	imm_diff[1]	= has_imm16_out;
	assign 	imm_diff[0]	= has_imm8_out;
	//Subtract from size to get the byte positions
	wire	[3:0]	imm_diff_n;
	wire	[3:0]	disp_diff_n;
	
	wire	[7:0]	imm_sel_l;
	wire	[7:0]	disp_sel_l;
	
	invn	#(4)	i2(imm_diff, imm_diff_n);
	invn	#(4)	i3(disp_diff, disp_diff_n);
	add_8b			s0(imm_sel_l, , {4'b0, size_out}, {4'hF, imm_diff_n}, 1'b1);
	add_8b			s1(disp_sel_l, , {4'b0, size_out}, {4'hF, disp_diff_n}, 1'b1);	
	assign	imm_sel		= imm_sel_l[3:0];
	assign	disp_sel	= disp_sel_l[3:0];
	
	//Imm/Disp val
	
	wire	[31:0]	imm_reg;
	wire	[31:0]	disp_reg;
	
	mux10n	#(32)	mm0({b0_out, b1_out, b2_out, b3_out}, {b1_out, b2_out, b3_out, b4_out}, {b2_out, b3_out, b4_out, b5_out}, {b3_out, b4_out, b5_out, b6_out}, {b4_out, b5_out, b6_out, b7_out}, {b5_out, b6_out, b7_out, b8_out}, {b6_out, b7_out, b8_out, b9_out}, {b7_out, b8_out, b9_out, b10_out}, {b8_out, b9_out, b10_out, b11_out}, {b9_out, b10_out, b11_out, b12_out}, imm_sel[3:0], imm_reg); 
	mux10n	#(32)	mm1({b0_out, b1_out, b2_out, b3_out}, {b1_out, b2_out, b3_out, b4_out}, {b2_out, b3_out, b4_out, b5_out}, {b3_out, b4_out, b5_out, b6_out}, {b4_out, b5_out, b6_out, b7_out}, {b5_out, b6_out, b7_out, b8_out}, {b6_out, b7_out, b8_out, b9_out}, {b7_out, b8_out, b9_out, b10_out}, {b8_out, b9_out, b10_out, b11_out}, {b9_out, b10_out, b11_out, b12_out}, disp_sel[3:0], disp_reg); 
	
	//For far pointers
	wire	[0:0]	op_fptr;
	wire	[0:0]	op_fptr_s;
	wire	[0:0]	op_fptr_16;
	and2n	#(1)	afptr(op_fptr_s, has_prefix1_out, op_fptr_16);
	
	wire	[15:0]	imm_ext;
	mux8n	#(16)	mm2({b4_out, b5_out}, {b5_out, b6_out}, {b6_out, b7_out}, {b7_out, b8_out}, {b8_out, b9_out}, {b9_out, b10_out}, {b10_out, b11_out}, {b11_out, b12_out}, imm_sel[2
	:0], imm_ext);

	//Imm is shifted for near ptr. Selector in disp field
	wire	[31:0]	i_imm_t;
	wire	[31:0]	i_imm_n1;
	wire	[0:0]	op_imm_1;
	wire	[31:0]	i_disp_t;
	mux2n	#(32)	mm3(imm_reg, {16'h0, imm_reg[31:16]}, op_fptr_16, i_imm_t);
	assign	i_imm_n1	= {i_imm_t[7:0], i_imm_t[15:8], i_imm_t[23:16], i_imm_t[31:24]};
	mux2n	#(32)	mm5(i_imm_n1, 32'h1, op_imm_1, i_imm);
	
	mux4n	#(32)	mm4(disp_reg, {imm_reg[15:0], 16'h0}, {imm_ext, 16'h0}, {imm_reg[15:0], 16'h0}, {op_fptr, op_fptr_16}, i_disp_t);

	//IDTR here. disp sends TR/ISR addr
	wire	[31:0]	idtr_base;
	wire	[31:0]	idtr_vec;
	wire	[31:0]	pf_vec;
	wire	[31:0]	gp_vec;
	wire	[31:0]	intr1_vec;
	wire	[31:0]	intr2_vec;
	wire	[31:0]	idtr_addr;
	wire	[0:0]	op_excp;

	assign	idtr_base	= 32'h2000;
	//Vec lf 3
	assign	gp_vec		= 32'h68;
	assign 	pf_vec		= 32'h70;
	assign	intr1_vec	= 32'h78;
	assign	intr2_vec	= 32'h80;


	wire	[31:0]	intr1_vec_t;
	wire	[31:0]	intr2_vec_t;
	wire	[31:0]	gp_vec_t;
	wire	[31:0]	pf_vec_t;

	wire	[0:0]	intr1_at_o;
	wire	[0:0]	intr2_at_o;
	wire	[0:0]	gp_excp_at_o;
	wire	[0:0]	pf_excp_at_o;

	comp_eq8	cy0(opcode1_byte_out, 8'hAA, intr1_at_o);
	comp_eq8	cy1(opcode1_byte_out, 8'hEE, intr2_at_o);
	comp_eq8	cy2(opcode1_byte_out, 8'hCC, gp_excp_at_o);
	comp_eq8	cy3(opcode1_byte_out, 8'hDD, pf_excp_at_o);

	nand2n	#(32)	yy0(intr1_vec, {32{intr1_at_o}}, intr1_vec_t);
	nand2n	#(32)	yy1(intr2_vec, {32{intr2_at_o}}, intr2_vec_t);
	nand2n	#(32)	yy2(gp_vec, {32{gp_excp_at_o}}, gp_vec_t);
	nand2n	#(32)	yy3(pf_vec, {32{pf_excp_at_o}}, pf_vec_t);
	nand4n	#(32)	yy4(intr1_vec_t, intr2_vec_t, gp_vec_t, pf_vec_t, idtr_vec);

	add_32b		yyh(idtr_addr, , idtr_base, idtr_vec, 1'b0, ); 

	wire	[31:0]	i_disp_nid;
	assign	i_disp_nid	= {i_disp_t[7:0], i_disp_t[15:8], i_disp_t[23:16], i_disp_t[31:24]};

	wire	[127:0]	control_bits;
	wire	[0:0]	uop_ptr0;
	wire	[0:0]	uop_ptr1;
	wire	[0:0]	simd_ovr;
	wire	[31:0]	disp_plus_4;
	and2n	#(1)	md0(uop_ptr0, control_bits[23], simd_ovr);

	wire 	[0:0]	no_disp;
	wire 	[31:0]	i_disp_nid_t;
	nor4n	#(1)	fgh1(has_disp32_out, has_disp8_out, op_fptr, op_fptr_16, no_disp);

	mux2n	#(32)	mdf(i_disp_nid, 32'd0, no_disp, i_disp_nid_t);

	inc4_32b	md1(disp_plus_4, , i_disp_nid_t); 

	mux3n	#(32)	idm(i_disp_nid_t, disp_plus_4, idtr_addr, {op_excp, simd_ovr}, i_disp);
	/*------------------------------------------------------------------*/
	
	//Imm/Disp Sizes
	//00-Inv, 01-8, 10-16, 11-32
	wire	[1:0]	i_immSize_t;
	or2n	#(1)	os0(has_imm16_out, has_imm32_out, i_immSize_t[1]);
	or2n	#(1)	os1(has_imm8_out, has_imm32_out, i_immSize_t[0]);
	mux3n	#(2)	mos0(i_immSize_t, 2'b10, 2'b11, {op_imm_1, op_fptr_16}, i_immSize);
	
	wire	[1:0]	i_dispSize_t;
	assign	i_dispSize_t[1]	= has_disp32_out;
	or2n	#(1)	os2(has_disp8_out, has_disp32_out, i_dispSize_t[0]);

	wire	[0:0]	no_disp_23;
	and2n	#(1)	mos2(no_disp, control_bits[23], no_disp_23);

	mux3n	#(2)	mos1(i_dispSize_t, 2'b10, 2'b1, {no_disp_23, op_fptr}, i_dispSize);
	
	/*------------------------------------------------------------------*/
	
	//SIB
	assign	i_SIB		= has_sib_out;
	assign 	i_baseRen	= has_sib_out;
	assign 	i_idxRen	= has_sib_out;
	assign	i_scale		= sib_byte_out[7:6];
	assign 	i_idx		= sib_byte_out[5:3];
	assign 	i_base		= sib_byte_out[2:0];
	
	/*------------------------------------------------------------------*/
	
	//EIP and branch stuff
	wire	[31:0]	eip_out_t;
	wire	[31:0]	i_nEIP_t;
	mux2n	#(32)	y8(eip_out, data_excp_eip, data_excp, eip_out_t);
	add_32b			ad1(i_nEIP_t, , eip_out_t, {28'd0, size_out}, 1'b0, );
	//Send EIP in nEIP if exception or interrupt  
	mux2n	#(32)	y9(i_nEIP_t, eip_out_t, data_excp_or_intr_op, i_nEIP);	
	assign	i_EIP			= eip_out_t;
	assign	i_bp_tgt		= bpred_tgt_out;
	assign	i_imm8			= i_imm[7:0];
	assign	i_bp_taken		= bpred_taken_out;
	assign	i_br_fetch_id	= br_fetch_id_out;
	
	/*------------------------------------------------------------------*/
	
	//Indir
	wire	[0:0]	mod_00;
	wire	[0:0]	modrm_bit1_n;
	wire	[0:0]	has_mod_disp;
	nor2n	#(1)	mrm0(modrm_byte_out[7], modrm_byte_out[6], mod_00);
	invn	#(1)	mrm1(modrm_byte_out[1], modrm_bit1_n);
	and4n	#(1)	mrm2(mod_00, modrm_byte_out[0], modrm_bit1_n, modrm_byte_out[2], has_mod_disp);
	nand2n	#(1)	mrm3(has_modrm_out, has_mod_disp, i_indir_addr);
	
	wire	[0:0]	op_call;
	wire	[0:0]	last_excp;
	wire	[0:0]	is_last_uop;
	wire	[0:0]	i_indir_t;
	nand2n	#(1)	mrm4(op_excp, is_last_uop, last_excp);
	and2n	#(1)	mrm5(i_indir_addr, last_excp, i_indir_t);

	wire	[0:0]	call_ptr0;
	and2n	#(1)	mrm7(op_call, uop_ptr0, call_ptr0);
	mux2n	#(1)	mrm6(i_indir_t, 1'b1, call_ptr0, i_indir);
	
	/*------------------------------------------------------------------*/
	
	//SR1 and SR2 sel
	wire	[2:0]	sr_reg;
	wire	[2:0]	sr_rm;
	wire	[2:0]	sr_offset;
	wire	[2:0]	sr_acc;
	wire	[2:0]	sr_ccx;
	wire	[2:0]	sr_esi;
	wire	[2:0]	sr_edi;
	wire	[2:0]	sr_esp;
	wire	[2:0]	sr1_sel;
	wire	[2:0]	sr2_sel;
	
	assign 	sr_acc		= 3'b000;
	assign 	sr_ccx		= 3'b001;
	assign 	sr_esi		= 3'b110;
	assign 	sr_edi		= 3'b111;
	assign	sr_rm		= modrm_byte_out[2:0];
	assign	sr_reg		= modrm_byte_out[5:3];
	assign	sr_offset	= opcode1_byte_out[2:0];
	assign	sr_esp		= 3'b100;
	
	mux8n	#(3)	msr0(sr_acc, sr_ccx, sr_esi, sr_edi, sr_rm, sr_reg, sr_offset, sr_esp, sr1_sel, i_sr1);
	mux8n	#(3)	msr1(sr_acc, sr_ccx, sr_esi, sr_edi, sr_rm, sr_reg, sr_offset, sr_esp, sr2_sel, i_sr2);
	
	/*------------------------------------------------------------------*/
	
	//Sreg1. Default DS, otherwise the others
	//TODO: SP needs to be added for EBP+ addressing
	wire	[0:0]	seg_CS;
	wire	[0:0]	seg_SS;
	wire	[0:0]	seg_DS;
	wire	[0:0]	seg_ES;
	wire	[0:0]	seg_FS;
	wire	[0:0]	seg_GS;
	comp_eq8	cseg0(prefix2_byte_out, 8'h2E, seg_CS);
	comp_eq8	cseg1(prefix2_byte_out, 8'h3E, seg_DS);
	comp_eq8	cseg2(prefix2_byte_out, 8'h26, seg_ES);
	comp_eq8	cseg3(prefix2_byte_out, 8'h36, seg_SS);
	comp_eq8	cseg4(prefix2_byte_out, 8'h64, seg_FS);
	comp_eq8	cseg5(prefix2_byte_out, 8'h65, seg_GS);
	
	wire	[2:0]	sreg1_pre; 
	wire	[7:0]	pre_in;
	assign 	pre_in	= {1'b0, 1'b0, seg_GS, seg_FS, seg_DS, seg_SS, seg_CS, seg_ES}; 
	pencoder8_3v$ 	efd(1'b0, pre_in, sreg1_pre,);

	//EBP addressing
	wire	[0:0]	mod_01_101;
	wire	[0:0]	mod_10_101;
	wire	[0:0]	sib_101;
	wire	[0:0]	rm_101;
	wire	[0:0]	mod_01;
	wire	[0:0]	mod_10;
	wire	[0:0]	def_stack_1;
	wire	[0:0]	def_stack_2;
	wire	[0:0]	b_100;

	comp_eq2	bpc0(modrm_byte_out[7:6], 2'b01, mod_01);
	comp_eq2	bpc1(modrm_byte_out[7:6], 2'b10, mod_10);
	comp_eq3	bpc2(modrm_byte_out[2:0], 3'b101, rm_101);
	comp_eq3	bpc3(sib_byte_out[2:0], 3'b100, b_100); 

	and3n	#(1)	bpa0(mod_01, rm_101, has_modrm_out, mod_01_101);
	and3n	#(1)	bpa1(mod_10, rm_101, has_modrm_out, mod_10_101);
	and2n	#(1)	bpa2(has_sib_out, rm_101, sib_101);
	or4n	#(1)	bpo1(mod_01_101, mod_10_101, sib_101, control_bits[61], def_stack_1); 
	and2n	#(1)	ghp(has_sib_out, b_100, def_stack_2); 

	//Stack SS override
	
	wire	[0:0]	def_stack;
	or2n	#(1)	gho(def_stack_1, def_stack_2, def_stack);

	mux5n	#(3)	sreg1_sel(3'b011, sreg1_pre, 3'b010, 3'b010, 3'b000, {is_repne_l, (def_stack), has_prefix2_out}, i_segR1);
	
	//Sreg2
	wire	[2:0]	sreg_reg;
	wire	[2:0]	sreg_ds;
	wire	[2:0]	sreg_es;
	wire	[2:0]	sreg_ss;
	wire	[2:0]	sreg_fs;
	wire	[2:0]	sreg_gs;
	wire	[2:0]	sreg_cs;
	wire	[2:0]	sreg_res;
	wire	[2:0]	sreg2_sel;
	
	assign	sreg_reg= modrm_byte_out[5:3];
	assign	sreg_ds	= 3'b011;
	assign	sreg_es	= 3'b000;
	assign	sreg_ss	= 3'b010;
	assign	sreg_fs	= 3'b100;
	assign	sreg_gs	= 3'b101;
	assign	sreg_cs = 3'b001;
	assign	sreg_res= 3'b001;
	
	mux8n	#(3)	msreg(sreg_reg, sreg_es, sreg_cs, sreg_ss, sreg_ds, sreg_fs, sreg_gs, sreg_res, sreg2_sel, i_segR2);
	
	/*------------------------------------------------------------------*/
	
	//DFLAG register
	wire	[0:0]	df_in;
	wire	[0:0]	df_en;
	wire	[0:0]	df_in_t;
	wire	[0:0]	df_en_t;
	wire	[0:0]	df_out;
	wire	[0:0]	inst_cld;
	wire	[0:0]	inst_std;
	
	comp_eq8		cld(opcode1_byte_out, 8'hFC, inst_cld);
	comp_eq8		cle(opcode1_byte_out, 8'hFD, inst_std);
	
	wire	[0:0]	df_inst;
	or2n	#(1)	odf(inst_cld, inst_std, df_inst);
	and2n	#(1)	adf(df_inst, dec2_en, df_en_t);
	or2n	#(1)	bdf(df_en_t, datapath_inv, df_en);
	
	assign	df_in	= inst_std;
	//TODO: DF forwarding
	regn	#(1)	dfl(df_in_t, CLK, reset, df_en, df_out);

	mux5n	#(1)	df2(df_in, excp_dflag, ex_dflag, ex_dflag, cs_dflag, {cs_inv, ex_inv, data_excp}, df_in_t);

	mux2n	#(1)	sdf(df_out, df_in_t, inst_std, i_Dflag);
	
	/*------------------------------------------------------------------*/
	
	//Control store
	wire	[7:0]	uop_ptr;
	
	wire	[0:0]	novr_r1Ren_uop0;
	wire	[0:0]	novr_r1Ren_uop1;
	wire	[0:0]	op_jmp_reg;
	wire	[0:0]	op_movq_reg;
	wire	[0:0]	op_pop_reg;
	wire	[0:0]	op_push_reg;
	wire	[0:0]	seg_pop;
	wire 	[0:0] 	op_ret_imm;
	/*	
	wire	[7:0]	cs_opcode;
	
	wire	[7:0]	t0,t1;
	nand2n	#(8)	gf0(other_op, {8{data_excp_or_intr}}, t0);
	nand2n	#(8)	gf1(opcode1_byte_out, {8{data_excp_or_intr_n}}, t1);
	nand2n	#(8)	gf2(t0, t1, cs_opcode);
	
	//mux2n	#(8)	y6(opcode1_byte_out, other_op, data_excp_or_intr, cs_opcode);
	*/
	control_store	cs(opcode1_byte_out, opcode2_byte_out, has_op2_out, modrm_byte_out[5:3], modrm_byte_out[7:6], has_prefix3_out, uop_ptr, control_bits, op_br, op_fptr, op_fptr_s, novr_r1Ren_uop0, novr_r1Ren_uop1, op_jmp_reg, op_movq_reg, op_pop_reg, op_push_reg, op_halt_t, op_imm_1, op_excp, seg_pop, op_call, op_ret_imm);
	
	
	
	/*------------------------------------------------------------------*/
	
	//Multiple uops
	wire	[7:0]	ptr_in_inc;
	wire	[7:0]	ptr_in;
	wire	[7:0]	ptr_in_t;
	wire	[7:0]	ptr_out;
	wire	[0:0]	op_halt_n;
	wire	[0:0]	uop_ptr_rst;
	wire	[0:0]	uop_ptr_rst_n;
	
	wire	[0:0]	is_repne;
	wire	[0:0]	is_repne_m;
	wire	[0:0]	is_repne_l;

	mux3n	#(8)	umux(ptr_in, 8'b0, 8'b0, {reset_latch, is_repne_l} , ptr_in_t);
	or2n	#(1)	umux2(dec2_en, uop_ptr_rst_n, dec2_en_act);	
	regn	#(8)	ureg(ptr_in_t, CLK, reset, dec2_en_act, ptr_out);
	assign 	uop_ptr	= ptr_out;
	
	wire	[0:0]	is_last_uop_n;
	or3n	#(1)	iif(control_bits[30], valid_out_n, datapath_inv, is_last_uop);
	invn	#(1)	iis(is_last_uop, is_last_uop_n);

	
	and2n	#(1)	iprf0(is_repne, uop_ptr2, is_repne_l);
	and2n	#(1)	iprf1(is_repne, uop_ptr1, is_repne_m);
		
	
	
	add_8b			adr0(ptr_in_inc, , ptr_out, 8'd1, 1'b0);
	invn	#(1)	ivbn(valid_out, valid_out_n);
	wire	[0:0]	last_uop_no_stall;
	and2n	#(1)	ghl(is_last_uop, rr_stall_n, last_uop_no_stall);
       	nor3n	#(1)	mbn(last_uop_no_stall, datapath_inv, valid_out_n,  uop_ptr_rst);	
	or3n	#(1)	mbn1(last_uop_no_stall, datapath_inv, valid_out_n,  uop_ptr_rst_n);	
	
	mux2n	#(8)	mmp0(8'h0, ptr_in_inc, uop_ptr_rst, ptr_in);
	
	/*------------------------------------------------------------------*/
	
	//Stalling
	or4n	#(1)	st0(is_last_uop_n, rr_stall, op_halt, repne_term, dec2_stall);
	wire	[0:0]	rr_stall_excp;
	wire	[0:0]	repne_term_n;
	invn	#(1)	stg(repne_term, repne_term_n);
	and4n	#(1)	stv(rr_stall, data_excp_or_intr_n, intr_op_n, repne_term_n, rr_stall_excp);
	nor2n	#(1)	stt(is_last_uop_n, rr_stall_excp, dec2_stall_no_hlt_n);
	
	
	//REPNE
	and3n	#(1)	kl(has_prefix3_out, valid_out, repne_term_n, is_repne);

	
	
	/*------------------------------------------------------------------*/
	
	
	//r1Ren logic
	
	wire	[0:0]	mod_sib_disp_n;
	wire	[0:0]	r1Ren_mod;
	wire	[0:0]	i_indir_addr_n;
	invn	#(1)	ojk(i_indir_addr, i_indir_addr_n);
	nor2n	#(1)	orrp(i_indir_addr_n, has_sib_out, mod_sib_disp_n);
	and2n	#(1)	arrp(control_bits[55], mod_sib_disp_n, r1Ren_mod); 
	
	
	
	comp_eq8		cov0(ptr_out, 8'h0, uop_ptr0);
	comp_eq8		cov1(ptr_out, 8'h1, uop_ptr1);
	comp_eq8		cov2(ptr_out, 8'h2, uop_ptr2);
	
	wire	[0:0]	novr_r1Ren_uop0_t;
	wire	[0:0]	novr_r1Ren_uop1_t;
	wire	[0:0]	r1Ren_novr;
	and2n	#(1)	aaf0(novr_r1Ren_uop0, uop_ptr0, novr_r1Ren_uop0_t);
	and2n	#(1)	aaf1(novr_r1Ren_uop1, uop_ptr1, novr_r1Ren_uop1_t);
	or2n	#(1)	oof0(novr_r1Ren_uop0_t, novr_r1Ren_uop1_t, r1Ren_novr);
	
	//Other reg
	
	wire	[0:0]	regular_ovr;
	mux2n	#(1)	ovrr(r1Ren_mod, control_bits[55], r1Ren_novr, regular_ovr);
	mux2n	#(1)	ovrs(regular_ovr, regular_ovr, op_jmp_reg, i_CS[55]);
	
	//r2sel
	mux2n	#(3)	ovr0(control_bits[54:52], 3'b100, op_jmp_reg, i_CS[54:52]);
	//r2Ren
	mux2n	#(1)	ovr1(control_bits[51], 1'b1, op_jmp_reg, i_CS[51]);
	
	
	//seg1Ren logic 
	//Zeros are zeros, 1 flipped if has modrm and register op
	wire	[0:0]	modrm_reg_n;
	wire	[0:0]	modrm_reg;
	wire	[0:0]	seg1Ren_f;
	wire	[0:0]	memRen_f;
	nand3n	#(1)	hrr0(modrm_byte_out[7], modrm_byte_out[6], has_modrm_out, modrm_reg_n);
	invn	#(1)	hrr1(modrm_reg_n, modrm_reg);
	and2n	#(1)	arr0(control_bits[50], modrm_reg_n, seg1Ren_f);
	wire	[0:0]	seg1Ren_ovr;
	or2n	#(1)	sro0(op_pop_reg, op_push_reg, seg1Ren_ovr);
	mux3n	#(1)	mmrs0(seg1Ren_f, 1'b1, control_bits[50], {op_excp, seg1Ren_ovr}, i_CS[50]);
	
	//memRen logic
	wire	[0:0]	memRen_f_t;
	and2n	#(1)	arr1(control_bits[45], modrm_reg_n, memRen_f_t);
	mux2n	#(1)	arrd(memRen_f_t, control_bits[45], op_excp, memRen_f);
	mux2n	#(1)	mmr0(memRen_f, 1'b1, op_pop_reg, i_CS[45]);
	
	//dr1Wen
	wire	[0:0]	dr1Wen_ovr;
	or2n	#(1)	arr2(control_bits[44], modrm_reg, dr1Wen_ovr);
	mux2n	#(1)	mrr1(control_bits[44], dr1Wen_ovr, control_bits[43], i_CS[44]);
	
	//dr2Wen
	wire	[0:0]	op1_86;
	wire	[0:0]	op1_87;
	wire	[0:0]	op1_86_reg;
	wire	[0:0]	op1_87_reg;
	comp_eq8		com0(opcode1_byte_out, 8'h86, op1_86);
	comp_eq8		com1(opcode1_byte_out, 8'h87, op1_87);
	and2n	#(1)	arr3(op1_86, modrm_reg, op1_86_reg);
	and2n	#(1)	arrk(op1_87, modrm_reg, op1_87_reg);
	or3n	#(1)	arr4(op1_86_reg, op1_87_reg, control_bits[42], i_CS[42]);
	
	//memWen
	wire	[0:0]	memWen_t;
	wire	[0:0]	memWen_t_t;	
	and2n	#(1)	arr5(control_bits[40], modrm_reg_n, memWen_t_t);
	mux4n	#(1)	arr6(memWen_t_t, control_bits[40], 1'b1, control_bits[40], {op_push_reg, op_excp} , i_CS[40]);
	
	//passAB
	mux2n	#(1)	arr7(control_bits[31], 1'b0, op_movq_reg, i_CS[31]);
	
	
	and4n	#(1)	arr8(valid_out, datapath_inv_n, op_halt_n, rr_stall_n, i_v);
	
	/*------------------------------------------------------------------*/
	
	//From control_store
	assign	sr1_sel		= control_bits[58:56];
	assign	sr2_sel		= control_bits[54:52];
	
	assign	sreg2_sel	= control_bits[49:47];
	//TODO: Ignore has_op2_out if cannot override, may not have such a case
	
	wire	[0:0]	has_prefix1_out_n8;
	wire	[1:0]	i_opSize_t;
	nand2n	#(1)	ia2(has_prefix1_out, control_bits[39], has_prefix1_out_n8);
	assign 	i_opSize_t	= {control_bits[39], has_prefix1_out_n8};
	mux2n	#(2)	iop_sel(i_opSize_t, i_opSize_t, seg_pop, i_opSize);

	assign 	i_CS[61]	= op_ret_imm;
	assign	i_CS[60:56]	= control_bits[60:56];
	assign	i_CS[49:46]	= control_bits[49:46];
	assign	i_CS[43]	= control_bits[43];
	assign	i_CS[41]	= control_bits[41];
	assign	i_CS[39:32]	= control_bits[39:32];
	assign	i_CS[30:0]	= control_bits[30:0];
	
	/*------------------------------------------------------------------*/
	// HALT!!!!
	
	invn	#(1)	hlt(op_halt, op_halt_n);
	
	/*------------------------------------------------------------------*/
	
endmodule
