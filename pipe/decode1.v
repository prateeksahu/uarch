//Written as a single module to avoid a large number of ports

module	decode1
	(
	input 	[0:0]	CLK,
	input	[0:0]	reset,
	
	//1 bit valid (msb)
	input	[77:0]	b0_in,
	input	[77:0]	b1_in,
	input	[77:0]	b2_in,
	input	[77:0]	b3_in,
	input	[77:0]	b4_in,
	input	[77:0]	b5_in,
	input	[77:0]	b6_in,
	input	[77:0]	b7_in,
	
	input	[0:0]	dec2_stall,
	input	[0:0]	fetch_not_ready,
	input	[3:0]	fetch_width,
	input	[0:0]	page_bound,
	
	input	[0:0]	bytes_cleanup,
	input	[3:0]	cleanup_id,
	input	[0:0]	datapath_inv,
	input	[0:0]	d2_inv,
	
	
	output	[0:0]	has_prefix1,
	output	[0:0]	has_prefix2,
	output	[0:0]	has_prefix3,
	output	[0:0]	has_op2,
	output	[0:0]	has_imm8,
	output	[0:0]	has_imm16,
	output	[0:0]	has_imm32,
	output	[0:0]	has_modrm,
	output	[0:0]	has_sib,
	output	[0:0]	has_disp8,
	output	[0:0]	has_disp32,
	
	output	[3:0]	inst_size,
	
	output	[7:0]	prefix2_byte,
	output	[7:0]	opcode1_byte,
	output	[7:0]	opcode2_byte,
	output	[7:0]	modrm_byte,
	output	[7:0]	sib_byte,
	
	output	[7:0]	b0,
	output	[7:0]	b1,
	output	[7:0]	b2,
	output	[7:0]	b3,
	output	[7:0]	b4,
	output	[7:0]	b5,
	output	[7:0]	b6,
	output	[7:0]	b7,
	output	[7:0]	b8,
	output	[7:0]	b9,
	output	[7:0]	b10,
	output	[7:0]	b11,
	output	[7:0]	b12,
	
	output	[31:0]	eip,
	
	output 	[0:0]	dec1_stall,
	output	[0:0]	dec1_not_ready,
	output	[3:0]	br_fetch_id_out,
	output	[31:0]	bpred_tgt,
	output	[0:0]	bpred_taken,
	output	[0:0]	ex_br_taken
	);
	
	wire	[0:0]	num_prefix0;
	wire	[0:0]	num_prefix1;
	wire	[0:0]	num_prefix2;
	wire	[0:0]	num_prefix3;
	
	
	//Instruction buffer
	i_buffer	inst_buff(CLK, reset, b0_in, b1_in, b2_in, b3_in, b4_in, b5_in, b6_in, b7_in, inst_size, dec2_stall, fetch_not_ready, fetch_width, page_bound, bytes_cleanup, cleanup_id, datapath_inv, d2_inv, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, eip, dec1_stall, dec1_not_ready, br_fetch_id_out, bpred_tgt, bpred_taken, ex_br_taken); 
	
	//Size calculation
	has_pre		hp(b0, b1, b2, b3, has_prefix1, has_prefix2, has_prefix3, num_prefix0, num_prefix1, num_prefix2, num_prefix3, prefix2_byte, opcode1_byte);
	
	op_op2		o2(b0, b1, b2, b3, b4, num_prefix0, num_prefix1, num_prefix2, num_prefix3, has_op2, opcode2_byte);

	op_imm8		il(opcode1_byte, opcode2_byte, has_imm8);
	
	op_imm16_32	ih(opcode1_byte, opcode2_byte, has_prefix1, has_imm16, has_imm32);
	
	op_modrm	om(b0, b1, b2, b3, b4, b5, num_prefix0, num_prefix1, num_prefix2, num_prefix3, has_op2, has_modrm, modrm_byte, sib_byte);
	
	fn_modrm	fm(modrm_byte, has_sib, has_disp8, has_disp32);
	
	wire	[3:0]	inst_size_t;
	size		sz(has_prefix1, has_prefix2, has_prefix3, has_op2, has_modrm, has_sib, has_disp8, has_disp32, has_imm8, has_imm16, has_imm32, inst_size_t);

	//HACK
	wire	[0:0]	oC2;
	wire	[0:0]	oCA;
	wire	[0:0]	far_ret;

	comp_eq8	ret16(b0, 8'hC2, oC2);
	comp_eq8	ret16f(b0, 8'hCA, oCA);
	or2n	#(1)	ref(oC2, oCA, far_ret);

	mux2n	#(4)	fdg(inst_size_t, 4'd3, far_ret, inst_size);
	
endmodule


	
