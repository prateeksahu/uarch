
// Check for prefix 1 (op size override)
module 	has_pre1	
	(
	input	[7:0]	b0,
	input	[7:0]	b1,
	input	[7:0]	b2,		
	
	output	[0:0]	b0_has_prefix,
	output	[0:0]	b1_has_prefix,
	output	[0:0]	b2_has_prefix
	);
	comp_eq8		c0(b0, 8'h66, b0_has_prefix);
	comp_eq8		c1(b1, 8'h66, b1_has_prefix);
	comp_eq8		c2(b2, 8'h66, b2_has_prefix);
		
endmodule	

/*-----------------------------------------------------------------------------------------------*/

// Check for prefix 2 (segR override)
module 	has_pre2	
	(
	input	[7:0]	b0,
	input	[7:0]	b1,
	input	[7:0]	b2,		
	
	output 	[0:0]	b0_has_prefix,
	output 	[0:0]	b1_has_prefix,
	output 	[0:0]	b2_has_prefix,
	output	[7:0]	prefix2_byte
	);
	//Delay = 0.7ns + 0.45 = 1.15ns 
	wire	[0:0]	b0_has_0prefix;
	wire	[0:0]	b1_has_0prefix;
	wire	[0:0]	b2_has_0prefix;
	wire	[0:0]	b0_has_1prefix;
	wire	[0:0]	b1_has_1prefix;
	wire	[0:0]	b2_has_1prefix;
	wire	[0:0]	b0_has_2prefix;
	wire	[0:0]	b1_has_2prefix;
	wire	[0:0]	b2_has_2prefix;
	wire	[0:0]	b0_has_3prefix;
	wire	[0:0]	b1_has_3prefix;
	wire	[0:0]	b2_has_3prefix;
	wire	[0:0]	b0_has_4prefix;
	wire	[0:0]	b1_has_4prefix;
	wire	[0:0]	b2_has_4prefix;
	wire	[0:0]	b0_has_5prefix;
	wire	[0:0]	b1_has_5prefix;
	wire	[0:0]	b2_has_5prefix;
	
	comp_eq8		c0(b0, 8'h2E, b0_has_0prefix);
	comp_eq8		c1(b1, 8'h2E, b1_has_0prefix);
	comp_eq8		c2(b2, 8'h2E, b2_has_0prefix);
	comp_eq8		c3(b0, 8'h36, b0_has_1prefix);
	comp_eq8		c4(b1, 8'h36, b1_has_1prefix);
	comp_eq8		c5(b2, 8'h36, b2_has_1prefix);
	comp_eq8		c6(b0, 8'h3E, b0_has_2prefix);
	comp_eq8		c7(b1, 8'h3E, b1_has_2prefix);
	comp_eq8		c8(b2, 8'h3E, b2_has_2prefix);
	comp_eq8		c9(b0, 8'h26, b0_has_3prefix);
	comp_eq8		ca(b1, 8'h26, b1_has_3prefix);
	comp_eq8		cb(b2, 8'h26, b2_has_3prefix);
	comp_eq8		cc(b0, 8'h64, b0_has_4prefix);
	comp_eq8		cd(b1, 8'h64, b1_has_4prefix);
	comp_eq8		ce(b2, 8'h64, b2_has_4prefix);
	comp_eq8		cf(b0, 8'h65, b0_has_5prefix);
	comp_eq8		cg(b1, 8'h65, b1_has_5prefix);
	comp_eq8		ch(b2, 8'h65, b2_has_5prefix);
	
	wire	[0:0]	b0_has_prefix_1;
	wire	[0:0]	b0_has_prefix_2;
	wire	[0:0]	b1_has_prefix_1;
	wire	[0:0]	b1_has_prefix_2;
	wire	[0:0]	b2_has_prefix_1;
	wire	[0:0]	b2_has_prefix_2;
	
	wire	[0:0]	b0_has_prefix_1_n;
	wire	[0:0]	b0_has_prefix_2_n;
	wire	[0:0]	b1_has_prefix_1_n;
	wire	[0:0]	b1_has_prefix_2_n;
	wire	[0:0]	b2_has_prefix_1_n;
	wire	[0:0]	b2_has_prefix_2_n;
	
	nor3n	#(1)	o0(b0_has_0prefix, b0_has_1prefix, b0_has_2prefix, b0_has_prefix_1_n);
	nor3n	#(1)	o1(b0_has_3prefix, b0_has_4prefix, b0_has_5prefix, b0_has_prefix_2_n);
	nor3n	#(1)	o2(b1_has_0prefix, b1_has_1prefix, b1_has_2prefix, b1_has_prefix_1_n);
	nor3n	#(1)	o3(b1_has_3prefix, b1_has_4prefix, b1_has_5prefix, b1_has_prefix_2_n);
	nor3n	#(1)	o4(b2_has_0prefix, b2_has_1prefix, b2_has_2prefix, b2_has_prefix_1_n);
	nor3n	#(1)	o5(b2_has_3prefix, b2_has_4prefix, b2_has_5prefix, b2_has_prefix_2_n);
	
	or3n	#(1)	oa0(b0_has_0prefix, b0_has_1prefix, b0_has_2prefix, b0_has_prefix_1);
	or3n	#(1)	oa1(b0_has_3prefix, b0_has_4prefix, b0_has_5prefix, b0_has_prefix_2);
	or3n	#(1)	oa2(b1_has_0prefix, b1_has_1prefix, b1_has_2prefix, b1_has_prefix_1);
	or3n	#(1)	oa3(b1_has_3prefix, b1_has_4prefix, b1_has_5prefix, b1_has_prefix_2);
	or3n	#(1)	oa4(b2_has_0prefix, b2_has_1prefix, b2_has_2prefix, b2_has_prefix_1);
	or3n	#(1)	oa5(b2_has_3prefix, b2_has_4prefix, b2_has_5prefix, b2_has_prefix_2);
	
	
	nand2n	#(1)	oo1(b0_has_prefix_1_n, b0_has_prefix_2_n, b0_has_prefix);
	nand2n	#(1)	oo2(b1_has_prefix_1_n, b1_has_prefix_2_n, b1_has_prefix);
	nand2n	#(1)	oo3(b2_has_prefix_1_n, b2_has_prefix_2_n, b2_has_prefix);
	
	wire	[7:0]	b0_has_prefix_2_val;
	wire	[7:0]	b1_has_prefix_2_val;
	wire	[7:0]	b2_has_prefix_2_val;
	
	//Prefix 2 byte
	assign	b0_has_prefix_2_val	= {8{b0_has_prefix_2}};
	assign	b1_has_prefix_2_val	= {8{b1_has_prefix_2}};
	assign	b2_has_prefix_2_val	= {8{b2_has_prefix_2}};

	wire	[7:0]	b0_val;
	wire	[7:0]	b1_val;
	wire	[7:0]	b2_val;
	
	and2n	#(8)	ad0(b0, b0_has_prefix_2_val, b0_val);
	and2n	#(8)	ad1(b1, b1_has_prefix_2_val, b1_val);
	and2n	#(8)	ad2(b2, b2_has_prefix_2_val, b2_val);
	
	or3n	#(8)	od0(b0_val, b1_val, b2_val, prefix2_byte);
	
endmodule

/*-----------------------------------------------------------------------------------------------*/

// Check for prefix 3 (REPNE)
module 	has_pre3	
	(
	input	[7:0]	b0,
	input	[7:0]	b1,
	input	[7:0]	b2,		
	
	output 	[0:0]	b0_has_prefix,
	output 	[0:0]	b1_has_prefix,
	output 	[0:0]	b2_has_prefix
	);

	comp_eq8		c0(b0, 8'hF2, b0_has_prefix);
	comp_eq8		c1(b1, 8'hF2, b1_has_prefix);
	comp_eq8		c2(b2, 8'hF2, b2_has_prefix);
	
endmodule	

/*-----------------------------------------------------------------------------------------------*/

// First 3 byte may contain invalid prefixes (if int_size is small)
// Prefix is valid only if earlier byte is a prefix
module	has_pre	(

	input	[7:0]	b0,
	input	[7:0]	b1,
	input	[7:0]	b2,
	input	[7:0]	b3,
	
	output	[0:0]	has_prefix1,
	output	[0:0]	has_prefix2,
	output	[0:0]	has_prefix3,
	
	output	[0:0]	num_prefix0,
	output	[0:0]	num_prefix1,
	output	[0:0]	num_prefix2,
	output	[0:0]	num_prefix3,
	
	// Extra signal for latching prefix 2 byte
	output	[7:0]	prefix2_byte,
	output	[7:0]	opcode1_byte
	);
	//Can save 1 inverter
	wire	[0:0]	b0_has_prefix_1_t;
	wire	[0:0]	b0_has_prefix_2_t;
	wire	[0:0]	b0_has_prefix_3_t;
	wire	[0:0]	b1_has_prefix_1_t;
	wire	[0:0]	b1_has_prefix_2_t;
	wire	[0:0]	b1_has_prefix_3_t;
	wire	[0:0]	b2_has_prefix_1_t;
	wire	[0:0]	b2_has_prefix_2_t;
	wire	[0:0]	b2_has_prefix_3_t;

	has_pre1		h0(b0, b1, b2, b0_has_prefix_1_t, b1_has_prefix_1_t, b2_has_prefix_1_t);
	has_pre2		h1(b0, b1, b2, b0_has_prefix_2_t, b1_has_prefix_2_t, b2_has_prefix_2_t, prefix2_byte);
	has_pre3		h2(b0, b1, b2, b0_has_prefix_3_t, b1_has_prefix_3_t, b2_has_prefix_3_t);
	
	//Check whether b0 and b1 have prefixes
	wire	[0:0]	b0_has_prefix;
	wire	[0:0]	b1_has_prefix_t;
	wire	[0:0]	b1_has_prefix;
	wire	[0:0]	b2_has_prefix_t;
	wire	[0:0]	b2_has_prefix;
	
	or3n	#(1)	o0(b0_has_prefix_1_t, b0_has_prefix_2_t, b0_has_prefix_3_t, b0_has_prefix);
	or3n	#(1)	o1(b1_has_prefix_1_t, b1_has_prefix_2_t, b1_has_prefix_3_t, b1_has_prefix_t);
	and2n	#(1)	a0(b0_has_prefix, b1_has_prefix_t, b1_has_prefix);
	or3n	#(1)	o2(b2_has_prefix_1_t, b2_has_prefix_2_t, b2_has_prefix_3_t, b2_has_prefix_t);
	and2n	#(1)	a1(b2_has_prefix_t, b1_has_prefix, b2_has_prefix);
	
	//Only propagate valid prefixes
	wire	[0:0]	b0_has_prefix_1;
	wire	[0:0]	b0_has_prefix_2;
	wire	[0:0]	b0_has_prefix_3;
	wire	[0:0]	b1_has_prefix_1;
	wire	[0:0]	b1_has_prefix_2;
	wire	[0:0]	b1_has_prefix_3;
	wire	[0:0]	b2_has_prefix_1;
	wire	[0:0]	b2_has_prefix_2;
	wire	[0:0]	b2_has_prefix_3;
	
	assign 	b0_has_prefix_1 = b0_has_prefix_1_t;
	assign 	b0_has_prefix_2 = b0_has_prefix_2_t;
	assign 	b0_has_prefix_3 = b0_has_prefix_3_t;
	
	and2n	#(1)	aa0(b1_has_prefix_1_t, b0_has_prefix, b1_has_prefix_1);
	and2n	#(1)	aa1(b1_has_prefix_2_t, b0_has_prefix, b1_has_prefix_2);
	and2n	#(1)	aa2(b1_has_prefix_3_t, b0_has_prefix, b1_has_prefix_3);
	
	and2n	#(1)	aa3(b2_has_prefix_1_t, b1_has_prefix, b2_has_prefix_1);
	and2n	#(1)	aa4(b2_has_prefix_2_t, b1_has_prefix, b2_has_prefix_2);
	and2n	#(1)	aa5(b2_has_prefix_3_t, b1_has_prefix, b2_has_prefix_3);
	
	or3n	#(1)	oo0(b0_has_prefix_1, b1_has_prefix_1, b2_has_prefix_1, has_prefix1);
	or3n	#(1)	oo1(b0_has_prefix_2, b1_has_prefix_2, b2_has_prefix_2, has_prefix2);
	or3n	#(1)	oo2(b0_has_prefix_3, b1_has_prefix_3, b2_has_prefix_3, has_prefix3);
	
	//Number of prefixes
	wire	[0:0]	b1_has_prefix_n;
	wire	[0:0]	b2_has_prefix_n;	
	
	invn	#(1)	n0(b0_has_prefix, num_prefix0);
	invn	#(1)	n1(b1_has_prefix, b1_has_prefix_n);
	invn	#(1)	n2(b2_has_prefix, b2_has_prefix_n);
	
	and2n	#(1)	aaa1(b0_has_prefix, b1_has_prefix_n, num_prefix1);
	and3n	#(1)	aaa2(b0_has_prefix, b1_has_prefix, b2_has_prefix_n, num_prefix2);
	and3n	#(1)	aaa3(b0_has_prefix, b1_has_prefix, b2_has_prefix, num_prefix3);
	
	//Opcode1 byte
	//Only byte can be op1 and others will be zero. Hence can do with less than a full mux
	wire	[7:0]	b0_is_op1_vec;
	wire	[7:0]	b1_is_op1_vec;
	wire	[7:0]	b2_is_op1_vec;
	wire	[7:0]	b3_is_op1_vec;
	
	assign 	b0_is_op1_vec = {8{num_prefix0}};
	assign 	b1_is_op1_vec = {8{num_prefix1}};
	assign 	b2_is_op1_vec = {8{num_prefix2}};
	assign 	b3_is_op1_vec = {8{num_prefix3}};
	
	wire	[7:0]		b0_val;
	wire	[7:0]		b1_val;
	wire	[7:0]		b2_val;
	wire	[7:0]		b3_val;
	
	nand2n	#(8)	an0(b0, b0_is_op1_vec, b0_val);
	nand2n	#(8)	an1(b1, b1_is_op1_vec, b1_val);
	nand2n	#(8)	an2(b2, b2_is_op1_vec, b2_val);
	nand2n	#(8)	an3(b3, b3_is_op1_vec, b3_val);
	
	nand4n 	#(8)	on0(b0_val, b1_val, b2_val, b3_val, opcode1_byte);
	
endmodule

/*-----------------------------------------------------------------------------------------------*/

module op_op2	(
	
	input	[7:0]	b0,
	input	[7:0]	b1,
	input	[7:0]	b2,
	input	[7:0]	b3,
	input	[7:0]	b4,
			
	input	[0:0] 	num_prefix0,
	input	[0:0] 	num_prefix1,				
	input	[0:0] 	num_prefix2,
	input	[0:0] 	num_prefix3,
			
	output 	[0:0]	has_op2,
	output	[7:0] 	opcode2_byte
	);
	
	wire	[0:0]	b1_is_op2;
	wire	[0:0]	b2_is_op2;
	wire	[0:0]	b3_is_op2;
	wire	[0:0]	b4_is_op2;
	
	wire	[0:0]	comp_b0;
	wire	[0:0]	comp_b1;
	wire	[0:0]	comp_b2;
	wire	[0:0]	comp_b3;
	
	comp_eq8		c0(b0, 8'h0F, comp_b0);
	comp_eq8		c1(b1, 8'h0F, comp_b1);
	comp_eq8		c2(b2, 8'h0F, comp_b2);
	comp_eq8		c3(b3, 8'h0F, comp_b3);
	
	and2n	#(1)	a0(num_prefix0, comp_b0, b1_is_op2);
	and2n	#(1)	a1(num_prefix1, comp_b1, b2_is_op2);
	and2n	#(1)	a2(num_prefix2, comp_b2, b3_is_op2);
	and2n	#(1)	a3(num_prefix3, comp_b3, b4_is_op2);
	
	or4n	#(1)	o0(b1_is_op2, b2_is_op2, b3_is_op2, b4_is_op2, has_op2);
	
	//Opcode2 byte
	wire	[7:0]	b1_is_op2_vec;
	wire	[7:0]	b2_is_op2_vec;
	wire	[7:0]	b3_is_op2_vec;
	wire	[7:0]	b4_is_op2_vec;

	assign 	b1_is_op2_vec = {8{b1_is_op2}};
	assign 	b2_is_op2_vec = {8{b2_is_op2}};
	assign 	b3_is_op2_vec = {8{b3_is_op2}};
	assign 	b4_is_op2_vec = {8{b4_is_op2}};
	
	wire	[7:0]		b1_val;
	wire	[7:0]		b2_val;
	wire	[7:0]		b3_val;
	wire	[7:0]		b4_val;
	
	nand2n	#(8)	aa0(b1, b1_is_op2_vec, b1_val);
	nand2n	#(8)	aa1(b2, b2_is_op2_vec, b2_val);
	nand2n	#(8)	aa2(b3, b3_is_op2_vec, b3_val);
	nand2n	#(8)	aa3(b4, b4_is_op2_vec, b4_val);
	
	nand4n 	#(8)	oo0(b1_val, b2_val, b3_val, b4_val, opcode2_byte);
	
endmodule				

/*-----------------------------------------------------------------------------------------------*/

module op_imm8	(
				
	input 	[7:0] 	opcode,
	input	[7:0]	op_ext,
				
	output	[0:0]	has_imm8
	);

	wire	[0:0]	op_add_al;
	wire	[0:0]	op_aor_8l;
	wire	[0:0]	op_aor_8h;
	wire	[0:0]	op_and_al;
	wire	[0:0]	op_mov_8r;
	wire	[0:0]	op_mov_8m;
	wire	[0:0]	op_orr_al;
	wire	[0:0]	op_pshufw;
	wire	[0:0]	op_push_8;
	wire	[0:0]	op_shf_8l;
	wire	[0:0]	op_shf_8h;
	wire	[0:0]	op_jnbe_r;		//rel series of immediate
	wire	[0:0]	op_jne_re;
	wire	[0:0]	op_jmp_re;
	
	comp_eq8		c0(opcode, 8'h04, op_add_al);
	comp_eq8		c1(opcode, 8'h80, op_aor_8l);
	comp_eq8		c2(opcode, 8'h83, op_aor_8h);
	comp_eq8		c4(opcode, 8'h24, op_and_al);
	comp_eq8		c5(opcode, 8'hC6, op_mov_8m);
	comp_eq8		c6(opcode, 8'h0C, op_orr_al);
	comp_eq8		c7(opcode, 8'h6A, op_push_8);
	comp_eq8		c8(opcode, 8'hC0, op_shf_8l);
	comp_eq8		c9(opcode, 8'hC1, op_shf_8h);
	comp_eq8		ca(opcode, 8'h77,	op_jnbe_r);
	comp_eq8		cb(opcode, 8'h75,	op_jne_re);
	comp_eq8		cc(opcode, 8'hEB,	op_jmp_re);
	
	//Added register to opcode
	wire	[0:0]	op_mov_8r_1;
	wire	[0:0]	op_mov_8r_2;
	
	comp_eq4		cc0(opcode[7:4], 4'hB, op_mov_8r_1);
	xnor2$			cc1(op_mov_8r_2, opcode[3], 1'b0);
	and2n	#(1)	aa0(op_mov_8r_1, op_mov_8r_2, op_mov_8r);

	//2 byte inst
	wire	[0:0]	op_pshufw_1;
	wire	[0:0]	op_pshufw_2;
	
	comp_eq8		cc2(opcode, 8'h0F, op_pshufw_1);
	comp_eq8		cc3(op_ext, 8'h70, op_pshufw_2);
	and2n	#(1)	aa1(op_pshufw_1, op_pshufw_2, op_pshufw);
	
	//Aggregate
	wire	[0:0]	has_imm8_1;
	wire	[0:0]	has_imm8_2;
	wire	[0:0]	has_imm8_3;
	wire	[0:0]	has_imm8_4;
	
	nor4n	#(1)	o0(op_add_al, op_aor_8l, op_aor_8h, op_jnbe_r, has_imm8_1);
	nor4n	#(1)	o1(op_and_al, op_mov_8r, op_mov_8m, op_jne_re, has_imm8_2);
	nor4n	#(1)	o2(op_orr_al, op_pshufw, op_push_8, op_jmp_re, has_imm8_3);
	nor2n	#(1)	o3(op_shf_8l, op_shf_8h, has_imm8_4);
	
	nand4n	#(1)	o4(has_imm8_1, has_imm8_2, has_imm8_3, has_imm8_4, has_imm8);
	
endmodule

/*-----------------------------------------------------------------------------------------------*/

module op_imm16_32	(
	
	input 	[7:0] 	opcode,
	input 	[7:0] 	op_ext,
	input	[0:0]	has_prefix1,
				
	output	[0:0]	has_imm16,			
	output	[0:0]	has_imm32
	);
	
	wire	[0:0]	op_add_ea;
	wire	[0:0]	op_aor_rm;
	wire	[0:0]	op_and_ea;
	wire	[0:0]	op_mov_hr;
	wire	[0:0]	op_mov_hm;
	wire	[0:0]	op_orr_ea;
	wire	[0:0]	op_push_h;
	wire	[0:0]	op_retn_h;		//RET supports only imm16
	wire	[0:0]	op_retf_h;
	wire	[0:0]	op_call_h;		//rel series for immediate
	wire	[0:0]	op_jnbe_r;
	wire	[0:0]	op_jne_re;
	wire	[0:0]	op_jmp_re;
	wire	[0:0]	op_call_p;		//ptr series for immediate
	wire	[0:0]	op_jmp_pt;
	
	comp_eq8		c0(opcode, 8'h05, op_add_ea);
	comp_eq8		c1(opcode, 8'h81, op_aor_rm);
	comp_eq8		c2(opcode, 8'h25, op_and_ea);
	comp_eq8		c3(opcode, 8'hC7, op_mov_hm);
	comp_eq8		c5(opcode, 8'h0D, op_orr_ea);
	comp_eq8		c6(opcode, 8'h68, op_push_h);
	comp_eq8		c7(opcode, 8'hC2, op_retn_h);
	comp_eq8		c8(opcode, 8'hCA, op_retf_h);
	comp_eq8		c9(opcode, 8'hE8, op_call_h);
	comp_eq8		ca(opcode, 8'hE9, op_jmp_re);
	comp_eq8		cb(opcode, 8'h9A, op_call_p);
	comp_eq8		cc(opcode, 8'hEA, op_jmp_pt);
	
	//Added register to opcode
	wire	[0:0]	op_mov_hr_1;
	wire	[0:0]	op_mov_hr_2;
	
	comp_eq4		cc0(opcode[7:4], 4'hB, op_mov_hr_1);
	xnor2$			cc1(op_mov_hr_2, opcode[3], 1'b1);
	and2n	#(1)	aa0(op_mov_hr_1, op_mov_hr_2, op_mov_hr);

	//2 byte inst
	wire	[0:0]	op_jnbe_r_1;
	wire	[0:0]	op_jnbe_r_2;
	wire	[0:0]	op_jne_re_1;
	wire	[0:0]	op_jne_re_2;

	comp_eq8		cc2(opcode, 8'h0F, op_jnbe_r_1);
	comp_eq8		cc3(op_ext, 8'h87, op_jnbe_r_2);
	and2n	#(1)	aa1(op_jnbe_r_1, op_jnbe_r_2, op_jnbe_r);	
	
	comp_eq8		cc4(opcode, 8'h0F, op_jne_re_1);
	comp_eq8		cc5(op_ext, 8'h85, op_jne_re_2);
	and2n	#(1)	aa2(op_jne_re_1, op_jne_re_2, op_jne_re);	
	
	//Prefix determines 16 bit mode in most cases. Exceptions: RET (only 16), CALL/JMP (full ptr)
	wire	[0:0]	is_op_32_tree1_1;
	wire	[0:0]	is_op_32_tree1_2;
	wire	[0:0]	is_op_32_tree1_3;
	wire	[0:0]	is_op_32_tree1_4;
	wire	[0:0]	has_imm32_pos;
	wire	[0:0]	has_imm32_reg;
	
	nor4n	#(1)	o0(op_add_ea, op_aor_rm, op_and_ea, op_mov_hr, is_op_32_tree1_1);
	nor4n	#(1)	o1(op_mov_hr, op_mov_hm, op_orr_ea, op_push_h, is_op_32_tree1_2);
	nor4n	#(1)	o2(op_call_h, op_jnbe_r, op_jne_re, op_jmp_re, is_op_32_tree1_3);
	nand3n	#(1)	o4(is_op_32_tree1_1, is_op_32_tree1_2, is_op_32_tree1_3, has_imm32_pos);
	
	wire	[0:0]	has_prefix1_n;
	invn	#(1)	n0(has_prefix1, has_prefix1_n);
	and2n	#(1)	n1(has_imm32_pos, has_prefix1_n, has_imm32_reg);
	
	//For Far pointers
	or2n	#(1)	o3(op_call_p, op_jmp_pt, is_op_32_tree1_4);
	or2n	#(1)	n2(has_imm32_reg, is_op_32_tree1_4, has_imm32);
	
	//OPTIMIZE 1 2-IN OR GATE BY REPLICATING TREE. Needed since RET always has a 16 bit immediate
	wire	[0:0]	op_ret_16;
	wire	[0:0]	op_oth_16;
	wire	[0:0]	has_imm16_1;
	
	and2n	#(1)	ooo1(has_imm32_pos, has_prefix1, op_oth_16);
	or3n	#(1)	aaa0(op_retn_h, op_retf_h, op_oth_16, has_imm16_1);
	
	//For Far pointers
	wire	[0:0]	has_32_off;
	wire	[0:0]	has_imm16_2;
	and2n	#(1)	jmp0(op_jmp_pt, has_prefix1_n, has_32_off);
	or2n 	#(1)	jmp1(op_call_p, has_32_off, has_imm16_2);
	or2n	#(1)	jmp2(has_imm16_1, has_imm16_2, has_imm16);
	
	
endmodule

/*-----------------------------------------------------------------------------------------------*/

// Delay = xnor2+and3+and2+and2
module modrm_byte	(

	input	[7:0]	opcode,
	input	[7:0]	op_ext,
	
	output	[0:0]	op_has_modrm
	);
	
	wire	[0:0]	op_1_80;
	wire	[0:0]	op_1_81;
	wire	[0:0]	op_1_83;
	wire	[0:0]	op_1_00;
	wire	[0:0]	op_1_01;
	wire	[0:0]	op_1_02;
	wire	[0:0]	op_1_03;
	wire	[0:0]	op_1_20;
	wire	[0:0]	op_1_21;
	wire	[0:0]	op_1_22;
	wire	[0:0]	op_1_23;
	wire	[0:0]	op_1_FF;	
	wire	[0:0]	op_2_42;
	wire	[0:0]	op_2_B0;
	wire	[0:0]	op_2_B1;
	wire	[0:0]	op_1_FE;
	wire	[0:0]	op_1_88;
	wire	[0:0]	op_1_89;
	wire	[0:0]	op_1_8A;
	wire	[0:0]	op_1_8B;
	wire	[0:0]	op_1_8C;
	wire	[0:0]	op_1_8E;
	wire	[0:0]	op_1_C6;
	wire	[0:0]	op_1_C7;
	wire	[0:0]	op_2_6F;
	wire	[0:0]	op_2_7F;
	wire	[0:0]	op_1_F6;
	wire	[0:0]	op_1_F7;
	wire	[0:0]	op_1_08;
	wire	[0:0]	op_1_09;
	wire	[0:0]	op_1_0A;
	wire	[0:0]	op_1_0B;
	wire	[0:0]	op_2_FD;
	wire	[0:0]	op_2_FE;
	wire	[0:0]	op_2_ED;
	wire	[0:0]	op_1_8F;
	wire	[0:0]	op_2_70;
	wire	[0:0]	op_1_D0;
	wire	[0:0]	op_1_D2;
	wire	[0:0]	op_1_C0;
	wire	[0:0]	op_1_D1;
	wire	[0:0]	op_1_D3;
	wire	[0:0]	op_1_C1;
	wire	[0:0]	op_1_86;
	wire	[0:0]	op_1_87;
	
	
	//List of comparators
	
	//1 byte inst
	comp_eq8		c0(opcode, 8'h80, op_1_80);
	comp_eq8		c1(opcode, 8'h81, op_1_81);
	comp_eq8		c2(opcode, 8'h83, op_1_83);
	comp_eq8		c3(opcode, 8'h00, op_1_00);
	comp_eq8		c4(opcode, 8'h01, op_1_01);
	comp_eq8		c5(opcode, 8'h02, op_1_02);
	comp_eq8		c6(opcode, 8'h03, op_1_03);
	comp_eq8		c7(opcode, 8'h20, op_1_20);
	comp_eq8		c8(opcode, 8'h21, op_1_21);
	comp_eq8		c9(opcode, 8'h22, op_1_22);
	comp_eq8		ca(opcode, 8'h23, op_1_23);
	comp_eq8		cb(opcode, 8'hFF, op_1_FF);
	comp_eq8		cc(opcode, 8'hFE, op_1_FE);
	comp_eq8		cd(opcode, 8'h88, op_1_88);
	comp_eq8		ce(opcode, 8'h89, op_1_89);
	comp_eq8		cf(opcode, 8'h8A, op_1_8A);
	comp_eq8		cg(opcode, 8'h8B, op_1_8B);
	comp_eq8		ch(opcode, 8'h8C, op_1_8C);
	comp_eq8		ci(opcode, 8'h8E, op_1_8E);
	comp_eq8		cj(opcode, 8'hC6, op_1_C6);
	comp_eq8		ck(opcode, 8'hC7, op_1_C7);
	comp_eq8		cl(opcode, 8'hF6, op_1_F6);
	comp_eq8		cm(opcode, 8'hF7, op_1_F7);
	comp_eq8		cn(opcode, 8'h08, op_1_08);
	comp_eq8		co(opcode, 8'h09, op_1_09);
	comp_eq8		cp(opcode, 8'h0A, op_1_0A);
	comp_eq8		cq(opcode, 8'h0B, op_1_0B);
	comp_eq8		cr(opcode, 8'h8F, op_1_8F);
	comp_eq8		cs(opcode, 8'hD0, op_1_D0);
	comp_eq8		ct(opcode, 8'hD2, op_1_D2);
	comp_eq8		cu(opcode, 8'hC0, op_1_C0);
	comp_eq8		cv(opcode, 8'hD1, op_1_D1);
	comp_eq8		cw(opcode, 8'hD3, op_1_D3);
	comp_eq8		cx(opcode, 8'hC1, op_1_C1);
	comp_eq8		cy(opcode, 8'h86, op_1_86);
	comp_eq8		cz(opcode, 8'h87, op_1_87);
	
	//2 byte inst
	wire	[0:0]	op_2_42_1;
	wire	[0:0]	op_2_42_2;
	wire	[0:0]	op_2_B0_1;
	wire	[0:0]	op_2_B0_2;
	wire	[0:0]	op_2_B1_1;
	wire	[0:0]	op_2_B1_2;
	wire	[0:0]	op_2_6F_1;
	wire	[0:0]	op_2_6F_2;
	wire	[0:0]	op_2_7F_1;
	wire	[0:0]	op_2_7F_2;
	wire	[0:0]	op_2_FD_1;
	wire	[0:0]	op_2_FD_2;
	wire	[0:0]	op_2_FE_1;
	wire	[0:0]	op_2_FE_2;
	wire	[0:0]	op_2_ED_1;
	wire	[0:0]	op_2_ED_2;
	wire	[0:0]	op_2_70_1;
	wire	[0:0]	op_2_70_2;
	
	comp_eq8		cc0(opcode, 8'h0F, op_2_42_1);
	comp_eq8		cc1(op_ext, 8'h42, op_2_42_2);
	and2n	#(1)	aa0(op_2_42_1, op_2_42_2, op_2_42);
	
	comp_eq8		cc2(opcode, 8'h0F, op_2_B0_1);
	comp_eq8		cc3(op_ext, 8'hB0, op_2_B0_2);
	and2n	#(1)	aa1(op_2_B0_1, op_2_B0_2, op_2_B0);
	
	comp_eq8		cc4(opcode, 8'h0F, op_2_B1_1);
	comp_eq8		cc5(op_ext, 8'hB1, op_2_B1_2);
	and2n	#(1)	aa2(op_2_B1_1, op_2_B1_2, op_2_B1);
	
	comp_eq8		cc6(opcode, 8'h0F, op_2_6F_1);
	comp_eq8		cc7(op_ext, 8'h6F, op_2_6F_2);
	and2n	#(1)	aa3(op_2_6F_1, op_2_6F_2, op_2_6F);
	
	comp_eq8		cc8(opcode, 8'h0F, op_2_7F_1);
	comp_eq8		cc9(op_ext, 8'h7F, op_2_7F_2);
	and2n	#(1)	aa4(op_2_7F_1, op_2_7F_2, op_2_7F);
	
	comp_eq8		cca(opcode, 8'h0F, op_2_FD_1);
	comp_eq8		ccb(op_ext, 8'hFD, op_2_FD_2);
	and2n	#(1)	aa5(op_2_FD_1, op_2_FD_2, op_2_FD);
	
	comp_eq8		ccc(opcode, 8'h0F, op_2_FE_1);
	comp_eq8		ccd(op_ext, 8'hFE, op_2_FE_2);
	and2n	#(1)	aa6(op_2_FE_1, op_2_FE_2, op_2_FE);
	
	comp_eq8		cce(opcode, 8'h0F, op_2_ED_1);
	comp_eq8		ccf(op_ext, 8'hED, op_2_ED_2);
	and2n	#(1)	aa7(op_2_ED_1, op_2_ED_2, op_2_ED);
	
	comp_eq8		ccg(opcode, 8'h0F, op_2_70_1);
	comp_eq8		cch(op_ext, 8'h70, op_2_70_2);
	and2n	#(1)	aa8(op_2_70_1, op_2_70_2, op_2_70);
	
	//Reduce using OR tree
	wire	[0:0]	int_a0;
	wire	[0:0]	int_a1;
	wire	[0:0]	int_a2;
	wire	[0:0]	int_a3;
	wire	[0:0]	int_a4;
	wire	[0:0]	int_a5;
	wire	[0:0]	int_a6;
	wire	[0:0]	int_a7;
	wire	[0:0]	int_a8;
	wire	[0:0]	int_a9;
	wire	[0:0]	int_a10;
	wire	[0:0]	int_a11;
	
	nor4n	#(1)	o0(op_1_80, op_1_81, op_1_83, op_1_00, int_a0);
	nor4n	#(1)	o1(op_1_01, op_1_02, op_1_03, op_1_20, int_a1);
	nor4n	#(1)	o2(op_1_21, op_1_22, op_1_23, op_1_FF, int_a2);
	nor4n	#(1)	o3(op_2_42, op_2_B0, op_2_B1, op_1_FE, int_a3);
	nor4n	#(1)	o4(op_1_88, op_1_89, op_1_8A, op_1_8B, int_a4);
	nor4n	#(1)	o5(op_1_8C, op_1_8E, op_1_C6, op_1_C7, int_a5);
	nor4n	#(1)	o6(op_2_6F, op_2_7F, op_1_F6, op_1_F7, int_a6);
	nor4n	#(1)	o7(op_1_08, op_1_09, op_1_0A, op_1_0B, int_a7);
	nor4n	#(1)	o8(op_2_FD, op_2_FE, op_2_ED, op_1_8F, int_a8);
	nor4n	#(1)	o9(op_2_70, op_1_D0, op_1_D2, op_1_C0, int_a9);
	nor4n	#(1)	oa(op_1_D1, op_1_D3, op_1_C1, op_1_86, int_a10);
	invn	#(1)	i0(op_1_87, int_a11);
	
	wire	[0:0]	int_b0;
	wire	[0:0]	int_b1;
	wire	[0:0]	int_b2;

	nand4n	#(1)	ob(int_a0, int_a1, int_a2, int_a3, int_b0);
	nand4n	#(1)	oc(int_a4, int_a5, int_a6, int_a7, int_b1);
	nand4n	#(1)	od(int_a8, int_a9, int_a10, int_a11, int_b2);
	or3n	#(1)	oe(int_b0, int_b1, int_b2, op_has_modrm);

endmodule

/*-----------------------------------------------------------------------------------------------*/

module op_modrm	(

	input	[7:0]	b0,
	input	[7:0]	b1,
	input	[7:0]	b2,
	input	[7:0]	b3,
	input	[7:0]	b4,
	input	[7:0]	b5,
	input	[0:0] 	num_prefix0,
	input	[0:0] 	num_prefix1,				
	input	[0:0] 	num_prefix2,
	input	[0:0] 	num_prefix3,
	input 	[0:0]	has_op2_byte,
				
	output	[0:0]	has_modrm,
	output	[7:0]	modrm_byte,
	output	[7:0]	sib_byte
	);
	
	wire	[0:0]	b1_is_modrm;
	wire	[0:0]	b2_is_modrm;
	wire	[0:0]	b3_is_modrm;
	wire	[0:0]	b4_is_modrm;
	
	wire	[0:0]	b0_has_modrm;
	wire	[0:0]	b1_has_modrm;
	wire	[0:0]	b2_has_modrm;
	wire	[0:0]	b3_has_modrm;
	wire	[0:0]	has_op2_byte_n;
	
	modrm_byte		orm0(b0, b1, b0_has_modrm);
	modrm_byte		orm1(b1, b2, b1_has_modrm);
	modrm_byte		orm2(b2, b3, b2_has_modrm);
	modrm_byte		orm3(b3, b4, b3_has_modrm);
	invn	#(1)	not0(has_op2_byte, has_op2_byte_n);
	
	//Based in has_opcode and num prefix, determine modrm byte
	//b1
	and2n	#(1)	a0(b0_has_modrm, has_op2_byte_n, b1_is_modrm);
	
	//b2
	wire	[0:0]	b2_is_modrm_1;
	wire	[0:0]	b2_is_modrm_2;
	
	nand3n	#(1)	a1(num_prefix1, b1_has_modrm, has_op2_byte_n, b2_is_modrm_1);
	nand2n	#(1)	a2(b0_has_modrm, has_op2_byte, b2_is_modrm_2);
	nand2n	#(1)	o0(b2_is_modrm_1, b2_is_modrm_2, b2_is_modrm);
	
	//b3
	wire	[0:0]	b3_is_modrm_1;
	wire	[0:0]	b3_is_modrm_2;
	
	nand3n	#(1)	a3(num_prefix2, b2_has_modrm, has_op2_byte_n, b3_is_modrm_1);
	nand3n	#(1)	a4(num_prefix1, b1_has_modrm, has_op2_byte, b3_is_modrm_2);
	nand2n	#(1)	o1(b3_is_modrm_1, b3_is_modrm_2, b3_is_modrm);
	
	//b4
	
	//Not possible for REPNE
	//and3n	#(1)	a1(num_prefix3, b3_has_modrm, has_op2_byte_n, b4_is_modrm_1);
	and3n	#(1)	a5(num_prefix2, b2_has_modrm, has_op2_byte, b4_is_modrm);
	
	//Further cases not possible since 3 prefixes never have associated modrm (CMPS)
	
	or4n	#(1)	o2(b1_is_modrm, b2_is_modrm, b3_is_modrm, b4_is_modrm, has_modrm);	

	wire	[7:0]	b1_is_modrm_vec;
	wire	[7:0]	b2_is_modrm_vec;
	wire	[7:0]	b3_is_modrm_vec;
	wire	[7:0]	b4_is_modrm_vec;

	assign 	b1_is_modrm_vec = {8{b1_is_modrm}};
	assign 	b2_is_modrm_vec = {8{b2_is_modrm}};
	assign 	b3_is_modrm_vec = {8{b3_is_modrm}};
	assign 	b4_is_modrm_vec = {8{b4_is_modrm}};
	
	wire	[7:0]		b1_valm;
	wire	[7:0]		b2_valm;
	wire	[7:0]		b3_valm;
	wire	[7:0]		b4_valm;
	
	nand2n	#(8)	aa0(b1, b1_is_modrm_vec, b1_valm);
	nand2n	#(8)	aa1(b2, b2_is_modrm_vec, b2_valm);
	nand2n	#(8)	aa2(b3, b3_is_modrm_vec, b3_valm);
	nand2n	#(8)	aa3(b4, b4_is_modrm_vec, b4_valm);
	
	nand4n 	#(8)	oo0(b1_valm, b2_valm, b3_valm, b4_valm, modrm_byte);
	
	//Also send SIB byte
	wire	[7:0]	b2_is_sib_vec;
	wire	[7:0]	b3_is_sib_vec;
	wire	[7:0]	b4_is_sib_vec;
	wire	[7:0]	b5_is_sib_vec;

	assign 	b2_is_sib_vec = {8{b1_is_modrm}};
	assign 	b3_is_sib_vec = {8{b2_is_modrm}};
	assign 	b4_is_sib_vec = {8{b3_is_modrm}};
	assign 	b5_is_sib_vec = {8{b4_is_modrm}};
	
	wire	[7:0]		b2_vals;
	wire	[7:0]		b3_vals;
	wire	[7:0]		b4_vals;
	wire	[7:0]		b5_vals;
	
	nand2n	#(8)	aa4(b2, b2_is_sib_vec, b2_vals);
	nand2n	#(8)	aa5(b3, b3_is_sib_vec, b3_vals);
	nand2n	#(8)	aa6(b4, b4_is_sib_vec, b4_vals);
	nand2n	#(8)	aa7(b5, b5_is_sib_vec, b5_vals);
	
	nand4n 	#(8)	oo1(b2_vals, b3_vals, b4_vals, b5_vals, sib_byte);
	
endmodule	

/*-----------------------------------------------------------------------------------------------*/

module 	fn_modrm	(

	input	[7:0]	modrm_byte,
				
	output	[0:0]	has_sib,
	output	[0:0]	has_disp8,
	output	[0:0]	has_disp32
	);
	
	//Check for SIB
	wire	[0:0]	not_reg;
	wire	[0:0]	sib_rm;
	comp_eq3		c0(modrm_byte[2:0], 3'b100, sib_rm);
	
	nand2n	#(1)	p0(modrm_byte[7], modrm_byte[6], not_reg); 
	and2n	#(1)	a0(sib_rm, not_reg, has_sib);
	
	//Check for dis8
	comp_eq2		c1(modrm_byte[7:6], 2'b01, has_disp8);
	
	//Check for disp32
	wire	[0:0]	only_disp_mod;
	wire	[0:0]	only_disp_rm;
	wire	[0:0]	only_disp;
	wire	[0:0]	mod_32;
	
	nor2n	#(1)	m0(modrm_byte[7], modrm_byte[6], only_disp_mod);
	comp_eq3		c2(modrm_byte[2:0], 3'b101, only_disp_rm);
	and2n	#(1)	a1(only_disp_mod, only_disp_rm, only_disp);
	
	comp_eq2		c3(modrm_byte[7:6], 2'b10, mod_32);
	
	or2n	#(1)	a2(only_disp, mod_32, has_disp32);

endmodule				

