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

	
	output	[0:0]	dec2_stall,
	output	[0:0]	bytes_cleanup,
	output	[3:0]	cleanup_id,
	output	[0:0]	replay_inst,
	
	
	//Pipeline read reg
	output	[59:0]	i_CS,			output	[31:0]	i_imm,		output	[31:0]	i_disp,
	output	[1:0]  	i_immSize,		output	[1:0]	i_dispSize,	output	[0:0]	i_SIB,
	output	[1:0]	i_scale,		output	[0:0]	i_baseRen,	output	[0:0]	i_idxRen,
	output	[31:0]	i_nEIP,			output	[31:0]	i_EIP,		output	[31:0]	i_bp_tgt,
	output 	[7:0]  	i_imm8,			output	[1:0]	i_opSize,	output	[2:0]	i_sr1,
	output	[2:0]  	i_sr2,			output	[2:0]	i_base,		output	[2:0]	i_idx,  
	output	[2:0]  	i_segR1,		output 	[2:0]  	i_segR2,	output	[0:0]	i_bp_taken,
	output  [0:0]   i_indir_addr,	output	[0:0]	i_Dflag,    output	[3:0]  	i_br_fetch_id,
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
	
	
	// Valid
	wire	[0:0]	valid;
	wire	[0:0]	reg_en;
	wire	[0:0]	valid_out;		
	
	invn	#(1)	ii(dec1_not_ready, valid);
	wire	[0:0]	dec2_stall_n;
	invn	#(1)	ij(dec2_stall, dec2_stall_n);
	
	and2n	#(1)	rdy(valid, dec2_stall_n, reg_en);
	wire	[0:0]	rr_stall_n;
	invn	#(1)	ik(rr_stall, rr_stall_n);
	and2n	#(1)	dec(valid_out, rr_stall_n, dec2_en);
	
	regn	#(1)	r00(valid, CLK, reset, reg_en, valid_out);
	
	// Registers
	regn	#(1)	r01(has_prefix1, CLK, reset, reg_en, has_prefix1_out);
	regn	#(1)	r02(has_prefix2, CLK, reset, reg_en, has_prefix2_out);
	regn	#(1)	r03(has_prefix3, CLK, reset, reg_en, has_prefix3_out);
	regn	#(1)	r04(has_imm8, CLK, reset, reg_en, has_imm8_out);
	regn	#(1)	r05(has_imm16, CLK, reset, reg_en, has_imm16_out);
	regn	#(1)	r06(has_imm32, CLK, reset, reg_en, has_imm32_out);
	regn	#(1)	r07(has_disp8, CLK, reset, reg_en, has_disp8_out);
	regn	#(1)	r08(has_disp32, CLK, reset, reg_en, has_disp32_out);
	regn	#(1)	ro0(has_op2, CLK, reset, reg_en, has_op2_out);
	regn	#(1)	ro1(has_modrm, CLK, reset, reg_en, has_modrm_out);
	regn	#(1)	ro2(has_sib, CLK, reset, reg_en, has_sib_out);
	
	regn	#(4)	r09(size, CLK, reset, reg_en, size_out);
	
	regn	#(8)	r0a(prefix2_byte, CLK, reset, reg_en, prefix2_byte_out);
	regn	#(8)	r0b(opcode1_byte, CLK, reset, reg_en, opcode1_byte_out);
	regn	#(8)	r0c(opcode2_byte, CLK, reset, reg_en, opcode2_byte_out);
	regn	#(8)	r0d(modrm_byte, CLK, reset, reg_en, modrm_byte_out);
	regn	#(8)	r0e(sib_byte, CLK, reset, reg_en, sib_byte_out);
	
	regn	#(8)	r0f(b0, CLK, reset, reg_en, b0_out);
	regn	#(8)	r0g(b1, CLK, reset, reg_en, b1_out);
	regn	#(8)	r0h(b2, CLK, reset, reg_en, b2_out);
	regn	#(8)	r0i(b3, CLK, reset, reg_en, b3_out);
	regn	#(8)	r0j(b4, CLK, reset, reg_en, b4_out);
	regn	#(8)	r0k(b5, CLK, reset, reg_en, b5_out);
	regn	#(8)	r0l(b6, CLK, reset, reg_en, b6_out);
	regn	#(8)	r0m(b7, CLK, reset, reg_en, b7_out);
	regn	#(8)	r0n(b8, CLK, reset, reg_en, b8_out);
	regn	#(8)	r0o(b9, CLK, reset, reg_en, b9_out);
	regn	#(8)	r0p(b10, CLK, reset, reg_en, b10_out);
	regn	#(8)	r0q(b11, CLK, reset, reg_en, b11_out);
	regn	#(8)	r0r(b12, CLK, reset, reg_en, b12_out);
	
	regn	#(32)	r0s(eip, CLK, reset, reg_en, eip_out);
	regn	#(4)	r0t(br_fetch_id, CLK, reset, reg_en, br_fetch_id_out);
	regn	#(32)	r0u(bpred_tgt, CLK, reset, reg_en, bpred_tgt_out);
	regn	#(1)	r0v(bpred_taken, CLK, reset, reg_en, bpred_taken_out);
	wire	[0:0]	ex_br_taken_out;
	regn	#(1)	r0w(ex_br_taken, CLK, reset, reg_en, ex_br_taken_out);
	
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
	
	regn	#(4)	brc(br_sid_in, CLK, reset, br_sid_en, br_sid);
	regn	#(1)	prt(pred_taken, CLK, reset, 1'b1, pred_taken_out);
	
	and3n	#(1)	aab(bpred_taken_out, ex_br_taken_out_n, op_br_n, pred_taken);
	wire	[0:0]	bytes_cleanup_t;
	or2n	#(1)	ocl(bpred_taken_out, ex_br_taken_out, bytes_cleanup_t);
	and2n	#(1)	oc2(bytes_cleanup_t, valid_out, bytes_cleanup);
	
	assign 	cleanup_id	= br_fetch_id_out;
	assign	br_sid_in	= br_fetch_id_out;
	
	and2n	#(1)	aac(pred_taken, dec2_en, br_sid_en);
	
	wire	[0:0]	same_fetch;
	wire	[0:0]	same_fetch_n;
	comp_eq4		idc(br_sid, br_fetch_id_out, same_fetch);
	invn	#(1)	sfn(same_fetch, same_fetch_n);
	
	and3n	#(1)	rpl(pred_taken_out, same_fetch_n, valid_out, replay_inst);
	
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
	mux2n	#(32)	mm3(imm_reg, {16'h0, imm_reg[31:16]}, op_fptr_16, i_imm);
	mux4n	#(32)	mm4(disp_reg, {16'h0, imm_reg[15:0]}, {16'h0, imm_ext}, {16'h0, imm_reg[15:0]}, {op_fptr, op_fptr_16}, i_disp);
	
	/*------------------------------------------------------------------*/
	
	//Imm/Disp Sizes
	//00-Inv, 01-8, 10-16, 11-32
	wire	[1:0]	i_immSize_t;
	or2n	#(1)	os0(has_imm16_out, has_imm32_out, i_immSize_t[1]);
	or2n	#(1)	os1(has_imm8_out, has_imm32_out, i_immSize_t[0]);
	mux2n	#(2)	mos0(i_immSize_t, 2'b10, op_fptr_16, i_immSize);
	
	wire	[1:0]	i_dispSize_t;
	assign	i_dispSize_t[1]	= has_disp32_out;
	or2n	#(1)	os2(has_disp8_out, has_disp32_out, i_dispSize_t[0]);
	mux2n	#(2)	mos1(i_dispSize_t, 2'b10, op_fptr, i_dispSize);
	
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
	add_32b			ad1(i_nEIP, , eip_out, {28'd0, size}, 1'b0, );
	assign	i_EIP			= eip_out;
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
	and2n	#(1)	mrm3(has_modrm_out, has_mod_disp, i_indir_addr);
	
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
	enc8	cseg_v({seg_CS, seg_DS, seg_ES, seg_SS, seg_FS, seg_GS, 1'b0, 1'b0}, sreg1_pre);
	
	mux2n	#(3)	sreg1_sel(3'b001, sreg1_pre, has_prefix2_out, i_segR1);
	
	//Sreg2
	wire	[2:0]	sreg_rm;
	wire	[2:0]	sreg_ds;
	wire	[2:0]	sreg_es;
	wire	[2:0]	sreg_ss;
	wire	[2:0]	sreg_fs;
	wire	[2:0]	sreg_gs;
	wire	[2:0]	sreg_cs;
	wire	[2:0]	sreg_res;
	wire	[2:0]	sreg2_sel;
	
	assign	sreg_rm	= modrm_byte_out[2:0];
	assign	sreg_ds	= 3'b001;
	assign	sreg_es	= 3'b010;
	assign	sreg_ss	= 3'b011;
	assign	sreg_fs	= 3'b100;
	assign	sreg_gs	= 3'b101;
	assign	sreg_cs = 3'b000;
	assign	sreg_res= 3'b111;
	
	mux8n	#(3)	msreg(sreg_rm, sreg_ds, sreg_es, sreg_ss, sreg_fs, sreg_gs, sreg_cs, sreg_res, sreg2_sel, i_segR2);
	
	/*------------------------------------------------------------------*/
	
	//DFLAG register
	wire	[0:0]	df_in;
	wire	[0:0]	df_en;
	wire	[0:0]	df_out;
	wire	[0:0]	inst_cld;
	wire	[0:0]	inst_std;
	
	comp_eq8		cld(opcode1_byte_out, 8'hFC, inst_cld);
	comp_eq8		cle(opcode1_byte_out, 8'hFD, inst_std);
	
	wire	[0:0]	df_inst;
	or2n	#(1)	odf(inst_cld, inst_std, df_inst);
	and2n	#(1)	adf(df_inst, dec2_en, df_en);
	
	assign	df_in	= inst_std;
	
	regn	#(1)	dfl(df_in, CLK, reset, df_en, df_out); 
	mux2n	#(1)	sdf(df_out, df_in, inst_std, i_Dflag);
	
	/*------------------------------------------------------------------*/
	
	//Control store
	wire	[127:0]	control_bits;
	wire	[7:0]	uop_ptr;
	
	wire	[0:0]	novr_r1Ren_uop0;
	wire	[0:0]	novr_r1Ren_uop1;
	wire	[0:0]	op_jmp_reg;
	wire	[0:0]	op_movq_reg;
	wire	[0:0]	op_pop_reg;
	wire	[0:0]	op_push_reg;
	
	control_store	cs(opcode1_byte_out, opcode2_byte_out, has_op2_out, modrm_byte_out[5:3], modrm_byte_out[7:6], uop_ptr, control_bits, op_br, op_fptr, op_fptr_s, novr_r1Ren_uop0, novr_r1Ren_uop1, op_jmp_reg, op_movq_reg, op_pop_reg, op_push_reg);
	
	
	
	/*------------------------------------------------------------------*/
	
	//Multiple uops
	wire	[7:0]	ptr_in_inc;
	wire	[7:0]	ptr_in;
	wire	[7:0]	ptr_out;
	
	regn	#(8)	ureg(ptr_in, CLK, reset, dec2_en, ptr_out);
	assign 	uop_ptr	= ptr_out;
	
	wire	[0:0]	is_last_uop;
	wire	[0:0]	is_last_uop_n;
	assign	is_last_uop	= control_bits[30];
	invn	#(1)	iis(is_last_uop, is_last_uop_n);
	
	add_8b			adr0(ptr_in_inc, , ptr_out, 8'd1, 1'b0); 
	mux2n	#(8)	mmp0(8'h0, ptr_in_inc, is_last_uop_n, ptr_in);
	//Stalling
	or2n	#(1)	st0(is_last_uop_n, rr_stall, dec2_stall);
	
	/*------------------------------------------------------------------*/
	
	wire	[0:0]	uop_ptr0;
	wire	[0:0]	uop_ptr1;
	
	
	//r1Ren logic
	
	wire	[0:0]	mod_sib_disp_n;
	wire	[0:0]	r1Ren_mod;
	nor2n	#(1)	orrp(i_indir_addr, has_sib_out, mod_sib_disp_n);
	and2n	#(1)	arrp(control_bits[55], mod_sib_disp_n, r1Ren_mod); 
	
	
	
	comp_eq8		cov0(ptr_out, 8'h0, uop_ptr0);
	comp_eq8		cov1(ptr_out, 8'h1, uop_ptr1);
	
	wire	[0:0]	novr_r1Ren_uop0_t;
	wire	[0:0]	novr_r1Ren_uop1_t;
	wire	[0:0]	r1Ren_novr;
	and2n	#(1)	aaf0(novr_r1Ren_uop0, uop_ptr0, novr_r1Ren_uop0_t);
	and2n	#(1)	aaf1(novr_r1Ren_uop1, uop_ptr1, novr_r1Ren_uop1_t);
	or2n	#(1)	oof0(novr_r1Ren_uop0_t, novr_r1Ren_uop1_t, r1Ren_novr);
	
	//Other reg
	
	wire	[0:0]	regular_ovr;
	mux2n	#(1)	ovrr(r1Ren_mod, control_bits[55], r1Ren_novr, regular_ovr);
	mux2n	#(1)	ovrs(regular_ovr, 1'b0, op_jmp_reg, i_CS[55]);
	
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
	mux2n	#(1)	mmrs0(seg1Ren_f, 1'b1, seg1Ren_ovr, i_CS[50]);
	
	//memRen logic
	and2n	#(1)	arr1(control_bits[45], modrm_reg_n, memRen_f);
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
	and2n	#(1)	arr5(control_bits[40], modrm_reg_n, memWen_t);
	mux2n	#(1)	arr6(memWen_t, 1'b1, op_push_reg, i_CS[40]);
	
	//passAB
	mux2n	#(1)	arr7(control_bits[31], 1'b0, op_movq_reg, i_CS[31]);
	
	assign	i_v			= valid_out; 
	
	/*------------------------------------------------------------------*/
	
	//From control_store
	assign	sr1_sel		= control_bits[58:56];
	assign	sr2_sel		= control_bits[54:52];
	
	assign	sreg2_sel	= control_bits[49:47];
	//TODO: Ignore has_op2_out if cannot override, may not have such a case
	
	wire	[0:0]	has_prefix2_out_n8;
	nand2n	#(1)	ia2(has_prefix2_out, control_bits[39], has_prefix2_out_n8);
	assign 	i_opSize	= {control_bits[39], has_prefix2_out_n8};
	
	assign	i_CS[59:56]	= control_bits[59:56];
	assign	i_CS[49:46]	= control_bits[49:46];
	assign	i_CS[43]	= control_bits[43];
	assign	i_CS[41]	= control_bits[41];
	assign	i_CS[39:32]	= control_bits[39:32];
	assign	i_CS[30:0]	= control_bits[30:0];
	
	
endmodule