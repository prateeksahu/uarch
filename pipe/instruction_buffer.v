// Instruction buffer: size = 24 bytes

module	i_buffer
	(
	input 	[0:0]	CLK,
	input	[0:0]	reset,
	
	//1 bit valid (msb)
	//Bits: 7:0 	inst byte
	//Bits: 77:8	pc
	//Bit : 78		valid potentially. Used the empty pointer only for now
	input	[77:0]	b0,
	input	[77:0]	b1,
	input	[77:0]	b2,
	input	[77:0]	b3,
	input	[77:0]	b4,
	input	[77:0]	b5,
	input	[77:0]	b6,
	input	[77:0]	b7,
	
	input	[3:0]	dec_size_in,
	input	[0:0]	dec2_stall,
	input	[0:0]	fetch_not_ready,
	input	[3:0]	fetch_width,
	input	[0:0]	page_bound,
	
	input	[0:0]	bytes_cleanup,
	input	[3:0]	cleanup_id,
	input	[0:0]	datapath_inv,
	input	[0:0]	d2_inv,
	
	output	[7:0]	decode_b0,
	output	[7:0]	decode_b1,
	output	[7:0]	decode_b2,
	output	[7:0]	decode_b3,
	output	[7:0]	decode_b4,
	output	[7:0]	decode_b5,
	output	[7:0]	decode_b6,
	output	[7:0]	decode_b7,
	output	[7:0]	decode_b8,
	output	[7:0]	decode_b9,
	output	[7:0]	decode_b10,
	output	[7:0]	decode_b11,
	output	[7:0]	decode_b12,
	
	output	[31:0]	eip,
	
	output 	[0:0]	dec1_stall,
	output	[0:0]	dec1_not_ready,
	output	[3:0]	br_fetch_id,
	output	[31:0]	bpred_tgt,
	output	[0:0]	bpred_taken,
	output	[0:0]	ex_br_taken
	);
	
	wire	[77:0]	reg_in		[23:0];
	wire	[0:0]	reg_en;
	wire	[77:0]	reg_out		[24:0];
	wire	[77:0]	reg_out_m	[31:0];
	
	wire	[0:0]	ptr_dec;
	wire	[0:0]	ptr_inc;
	
	
	wire	[0:0]	datapath_inv_n, d2_inv_n;

	//and3n	#(1)	rstf(reset_in, datapath_inv_n, d2_inv_n, reset);

	or2n	#(1)	ght(ptr_dec, ptr_inc, reg_en);
	//Register instantiations. Can use dff since feedback is easier to design here (than using enables)
	genvar	i;
	generate 
			for(i=0; i<24; i=i+1) begin:	regs
					regn	#(78)	r(reg_in[i], CLK, reset, reg_en, reg_out[i]);
			end
	endgenerate
	
	assign	eip			= reg_out[0][39:8];
	
	//Fetch id corresponds to the fetch ID of the last byte!
	mux12n	#(4)	mr0(reg_out[0][43:40], reg_out[1][43:40], reg_out[2][43:40], reg_out[3][43:40], reg_out[4][43:40], reg_out[5][43:40], reg_out[6][43:40], reg_out[7][43:40], reg_out[8][43:40], reg_out[9][43:40], reg_out[10][43:40], reg_out[11][43:40], dec_size_in, br_fetch_id);
	
	mux12n	#(32)	mr1(reg_out[0][75:44], reg_out[1][75:44], reg_out[2][75:44], reg_out[3][75:44], reg_out[4][75:44], reg_out[5][75:44], reg_out[6][75:44], reg_out[7][75:44], reg_out[8][75:44], reg_out[9][75:44], reg_out[10][75:44], reg_out[11][75:44], dec_size_in, bpred_tgt);
	
	mux12n	#(1)	mr2(reg_out[0][76], reg_out[1][76], reg_out[2][76], reg_out[3][76], reg_out[4][76], reg_out[5][76], reg_out[6][76], reg_out[7][76], reg_out[8][76], reg_out[9][76], reg_out[10][76], reg_out[11][76], dec_size_in, bpred_taken);
	
	mux12n	#(1)	mr3(reg_out[0][77], reg_out[1][77], reg_out[2][77], reg_out[3][77], reg_out[4][77], reg_out[5][77], reg_out[6][77], reg_out[7][77], reg_out[8][77], reg_out[9][77], reg_out[10][77], reg_out[11][77], dec_size_in, ex_br_taken);
	
	//Last one is a proxy value for input to the 24th register (only has external input)
	assign 	reg_out[24]		= 78'b0;
	
	wire	[4:0]	ptr_in;
	wire	[4:0]	ptr_out;
	wire	[0:0]	ptr_en;
	
	
	wire	[0:0]	ptr_reset;
	wire	[0:0]	ptr_reset_n;
	invn	#(1)	tt0(datapath_inv, datapath_inv_n);
	invn	#(1)	tt1(d2_inv, d2_inv_n);
	or2n	#(1)	orst1(datapath_inv, d2_inv, ptr_reset);
	nor2n	#(1)	orst2(datapath_inv, d2_inv, ptr_reset_n);
	
	//Empty pointer
	//TODO: Used 8 bit module. Need 5 bit adders, mag_comps
	
	nand3n	#(1)	ptren(fetch_not_ready, dec2_stall, ptr_reset_n, ptr_en);
	regn	#(5)	reg_ptr(ptr_in, CLK, reset, ptr_en, ptr_out);	
	
	//Check whether there are enough bytes for decode
	wire	[7:0]	ptr_temp0;
	wire	[7:0]	ptr_temp1;
	wire	[7:0]	ptr_temp2;
	wire	[4:0]	dec_size_n;
	
	wire	[0:0]	not_e_bytes;
	
	//On a cleanup, the size is decided by a priority decoder. Everything is as regular fetch, except the instruction is invalid
	
	wire	[2:0]	cleanup_size;
	wire	[0:0]	cleanup_valid;
	wire	[7:0]	pr_dec;
	assign	pr_dec[0]	= 1'b1;
	comp_eq4		c_pr0(reg_out[0][43:40], cleanup_id, pr_dec[1]);
	comp_eq4		c_pr1(reg_out[1][43:40], cleanup_id, pr_dec[2]);
	comp_eq4		c_pr2(reg_out[2][43:40], cleanup_id, pr_dec[3]);
	comp_eq4		c_pr3(reg_out[3][43:40], cleanup_id, pr_dec[4]);
	comp_eq4		c_pr4(reg_out[4][43:40], cleanup_id, pr_dec[5]);
	comp_eq4		c_pr5(reg_out[5][43:40], cleanup_id, pr_dec[6]);
	comp_eq4		c_pr6(reg_out[6][43:40], cleanup_id, pr_dec[7]);
	comp_eq4		c_pr7(reg_out[7][43:40], cleanup_id,);
	pencoder8_3v$	pen_0(1'b0, pr_dec, cleanup_size, cleanup_valid);
	
	wire	[0:0]	size_sel;
	wire	[3:0]	dec_size;
	and2n	#(1)	ssel(cleanup_valid, bytes_cleanup, size_sel);
	mux2n	#(4)	m_cl(dec_size_in, {1'b0, cleanup_size}, size_sel, dec_size);
	
	//Don't decrement if calculated ptr is negative or there's a stall in later stages
	wire	[0:0]	size_sign;
	wire	[7:0]	ptr_out_plus;
	invn	#(5)	size_n({1'b0, dec_size}, dec_size_n);	 
	assign 	size_sign 	= dec_size_n[4];
	//TODO: Ask for optimization here, will cut cycle time to 9ns
	add_8b			ad0(ptr_temp0, , {3'b0, ptr_out}, {size_sign, size_sign, size_sign, dec_size_n}, 1'b1);
	
	
	//Add +8 first here
	wire	[7:0]	ptr_temp3;
	wire	[7:0]	ptr_temp4;
	wire	[7:0]	ptr_temp3_fw;
	wire	[7:0]	ptr_temp3_pb;
	add_8b			adf(ptr_temp3_fw, , {3'b0, ptr_out}, 8'd8, 1'b0);
	add_8b			apg(ptr_temp3_pb, , {3'b0, ptr_out}, {4'h0, fetch_width}, 1'b0);
	mux2n	#(8)	mph(ptr_temp3_fw, ptr_temp3_pb, page_bound, ptr_out_plus);
	add_8b			adg(ptr_temp3, , ptr_out_plus, {size_sign, size_sign, size_sign, dec_size_n}, 1'b1);
	mux2n	#(8)	mss(ptr_out_plus, ptr_temp3, ptr_dec, ptr_temp4);
	
	//Mag comp
	wire	[0:0]	not_e_bytes_t;
	wire	[0:0]	ac_zero;
	mag_comp8$	ccm0({4'b0, dec_size}, {3'b0, ptr_out}, not_e_bytes_t, );
	comp_eq4	ccm1(dec_size, 4'b0, ac_zero);
       	or2n	#(1)	ccm2(ac_zero, not_e_bytes_t, not_e_bytes);	
	
	wire	[0:0]	full;
	wire	[0:0]	full1;
	wire	[0:0]	full2;	
	wire	[0:0]	full_n;
	
	
	nor2n	#(1)	nr0(dec2_stall, not_e_bytes, ptr_dec);
	mux2n	#(8)	ms0({3'b0, ptr_out}, ptr_temp0, ptr_dec, ptr_temp1);
	mag_comp8$		cm1({3'b0, ptr_out}, 8'd16, full1, );
	mag_comp8$		cm2(ptr_temp0, 8'd16, full2, );
	mux2n	#(1)	mkh(full1, full2, ptr_dec, full);
	invn	#(1)	khj(full, full_n);
	
	//Don't add if fetch isn't ready or there isn't enough space
	//TODO: Can add variable number if fetch provides number of bytes 
	//8 bit comp
	wire	[7:0]	ptr_temp2_fw;
	wire	[7:0]	ptr_temp2_pb;
	
	add_8b			ad1(ptr_temp2_fw, , ptr_temp1, 8'd8, 1'b0);
	add_8b			apb(ptr_temp2_pb, , ptr_temp1, {4'h0, fetch_width}, 1'b0);
	mux2n	#(8)	mpb(ptr_temp2_fw, ptr_temp2_pb, page_bound, ptr_temp2);
		
	wire	[7:0]	ptr_in_temp_1;
	wire	[7:0]	ptr_in_temp_2;
	
	//mag_comp8$		cm1(ptr_temp1, 8'd17, , full_n);
	//mag_comp8$		cm2(ptr_temp1, 8'd16, full, );
	nor2n	#(1)	nr1(fetch_not_ready, full, ptr_inc);
	
	
	//try
	mux4n	#(8)	mstp({3'b0, ptr_out}, ptr_temp0, ptr_out_plus, ptr_temp3, {ptr_inc, ptr_dec}, ptr_in_temp_1);
	
	//mux2n	#(8)	ms1(ptr_temp1, ptr_temp4, ptr_inc, ptr_in_temp);
	mux2n	#(8)	msinv(ptr_in_temp_1, 8'b0, ptr_reset, ptr_in_temp_2);
	assign 	ptr_in = ptr_in_temp_2[4:0];
	
	//Send a stall when we cannot add more bytes
	//Now negation of full
	assign 	dec1_stall 	= full_n;
	
	wire	[0:0]	t0;
	
	or3n	#(1)	oonr(not_e_bytes, size_sel, datapath_inv, t0);
	or3n	#(1)	oons(t0, d2_inv, bytes_cleanup, dec1_not_ready);
	
	//Fetched bytes are muxed with the actual output of the registers. These are selected if the register output is invalid
	wire	[77:0]	ib_f_byte	[31:0];
	
	
	//Fetched bytes to be read in in each buffer are any one of the 8 based on what the current ptr value is
	/*-------------------------------------------------------------------------------------------------------------------------*/
	assign 	ib_f_byte[0]	= b0;
	
	mux2n	#(78)	m0(b1, b0, ptr_out[0], ib_f_byte[1]);
	mux3n	#(78)	m1(b2, b1, b0, ptr_out[1:0], ib_f_byte[2]);
	mux4n	#(78)	m2(b3, b2, b1, b0, ptr_out[1:0], ib_f_byte[3]);
	mux5n	#(78)	m3(b4, b3, b2, b1, b0, ptr_out[2:0], ib_f_byte[4]);
	mux6n	#(78)	m4(b5, b4, b3, b2, b1, b0, ptr_out[2:0], ib_f_byte[5]);
	mux7n	#(78)	m5(b6, b5, b4, b3, b2, b1, b0, ptr_out[2:0], ib_f_byte[6]);
	mux8n	#(78)	m6(b7, b6, b5, b4, b3, b2, b1, b0, ptr_out[2:0], ib_f_byte[7]);
	mux8n	#(78)	m7(b0, b7, b6, b5, b4, b3, b2, b1, ptr_out[2:0], ib_f_byte[8]);
	mux8n	#(78)	m8(b1, b0, b7, b6, b5, b4, b3, b2, ptr_out[2:0], ib_f_byte[9]);
	mux8n	#(78)	m9(b2, b1, b0, b7, b6, b5, b4, b3, ptr_out[2:0], ib_f_byte[10]);
	mux8n	#(78)	ma(b3, b2, b1, b0, b7, b6, b5, b4, ptr_out[2:0], ib_f_byte[11]);
	mux8n	#(78)	mb(b4, b3, b2, b1, b0, b7, b6, b5, ptr_out[2:0], ib_f_byte[12]);
	mux8n	#(78)	mc(b5, b4, b3, b2, b1, b0, b7, b6, ptr_out[2:0], ib_f_byte[13]);
	mux8n	#(78)	md(b6, b5, b4, b3, b2, b1, b0, b7, ptr_out[2:0], ib_f_byte[14]);
	mux8n	#(78)	me(b7, b6, b5, b4, b3, b2, b1, b0, ptr_out[2:0], ib_f_byte[15]);
	mux8n	#(78)	mf(b0, b7, b6, b5, b4, b3, b2, b1, ptr_out[2:0], ib_f_byte[16]);
	mux8n	#(78)	mg(b1, b0, b7, b6, b5, b4, b3, b2, ptr_out[2:0], ib_f_byte[17]);
	mux8n	#(78)	mh(b2, b1, b0, b7, b6, b5, b4, b3, ptr_out[2:0], ib_f_byte[18]);
	mux8n	#(78)	mi(b3, b2, b1, b0, b7, b6, b5, b4, ptr_out[2:0], ib_f_byte[19]);
	mux8n	#(78)	mj(b4, b3, b2, b1, b0, b7, b6, b5, ptr_out[2:0], ib_f_byte[20]);
	mux8n	#(78)	mk(b5, b4, b3, b2, b1, b0, b7, b6, ptr_out[2:0], ib_f_byte[21]);
	mux8n	#(78)	ml(b6, b5, b4, b3, b2, b1, b0, b7, ptr_out[2:0], ib_f_byte[22]);
	mux8n	#(78)	mm(b7, b6, b5, b4, b3, b2, b1, b0, ptr_out[2:0], ib_f_byte[23]);
	//Added
	//Can reduce rest, but requires weird indexing
	mux8n	#(78)	mn(b0, b7, b6, b5, b4, b3, b2, b1, ptr_out[2:0], ib_f_byte[24]);
	mux8n	#(78)	mo(b1, b0, b7, b6, b5, b4, b3, b2, ptr_out[2:0], ib_f_byte[25]);
	mux8n	#(78)	mp(b2, b1, b0, b7, b6, b5, b4, b3, ptr_out[2:0], ib_f_byte[26]);
	mux8n	#(78)	mq(b3, b2, b1, b0, b7, b6, b5, b4, ptr_out[2:0], ib_f_byte[27]);
	mux8n	#(78)	mr(b4, b3, b2, b1, b0, b7, b6, b5, ptr_out[2:0], ib_f_byte[28]);
	mux8n	#(78)	ms(b5, b4, b3, b2, b1, b0, b7, b6, ptr_out[2:0], ib_f_byte[29]);
	
	mux2n	#(78)	mt(b6, b7, ptr_out[0:0], ib_f_byte[30]);
	assign 	ib_f_byte[31]	= b7;
	
	//Last few muxes need not be this big, but makes the select signal easier! 
	//This one is always b7! Change if you want to be able to add variable number of bytes
	/*-------------------------------------------------------------------------------------------------------------------------*/
	
	// Mag compare wrt i used for select
	wire	[7:0]	cmp_val[23:0];
	wire	[0:0]	cmp_res1[23:0];
	wire	[0:0]	cmp_res2[23:0];
					
	generate 
			for(i=0; i<24; i=i+1) begin:	muxinv
					assign 	cmp_val[i]	= i;
					mag_comp8$		mag({3'b0, ptr_out}, cmp_val[i], cmp_res1[i], cmp_res2[i]);
					//nor2n	#(1)	(cmp_res1[i], cmp_res2[i], cmp_resa[i]);
					//or2n	#(1)	(cmp_res1[i], cmp_resa[i], cmp_resb[i]);
					mux2n	#(78)	min(ib_f_byte[i], reg_out[i], cmp_res1[i], reg_out_m[i]);
			end
	endgenerate
	
	generate 
			for(i=24; i<32; i=i+1) begin:	muxinv2
					assign	reg_out_m[i] 	= ib_f_byte[i];
			end
	endgenerate
	
	//Shift muxes. Max shift is 13
	
	//If not enough bytes OR stall from ahead, the select is 0. This allows fetch bytes to still be written in
	wire	[3:0]	dec_size_sel;
	mux2n	#(4)	mx(4'b0, dec_size, ptr_dec, dec_size_sel);
	
	generate 
			for(i=0; i<19; i=i+1) begin:	mux_in
					mux14n	#(78)	min(reg_out_m[i], reg_out_m[i+1], reg_out_m[i+2], reg_out_m[i+3], reg_out_m[i+4], reg_out_m[i+5], reg_out_m[i+6], reg_out_m[i+7], reg_out_m[i+8], reg_out_m[i+9], reg_out_m[i+10], reg_out_m[i+11], reg_out_m[i+12], reg_out_m[i+13], dec_size_sel, reg_in[i]);
			end
	endgenerate
	mux13n	#(78)	mm0(reg_out_m[19], reg_out_m[20], reg_out_m[21], reg_out_m[22], reg_out_m[23], reg_out_m[24], reg_out_m[25], reg_out_m[26], reg_out_m[27], reg_out_m[28], reg_out_m[29], reg_out_m[30], reg_out_m[31], dec_size_sel, reg_in[19]);
	mux12n	#(78)	mm1(reg_out_m[20], reg_out_m[21], reg_out_m[22], reg_out_m[23], reg_out_m[24], reg_out_m[25], reg_out_m[26], reg_out_m[27], reg_out_m[28], reg_out_m[29], reg_out_m[30], reg_out_m[31], dec_size_sel, reg_in[20]);
	mux11n	#(78)	mm2(reg_out_m[21], reg_out_m[22], reg_out_m[23], reg_out_m[24], reg_out_m[25], reg_out_m[26], reg_out_m[27], reg_out_m[28], reg_out_m[29], reg_out_m[30], reg_out_m[31], dec_size_sel, reg_in[21]);
	mux10n	#(78)	mm3(reg_out_m[22], reg_out_m[23], reg_out_m[24], reg_out_m[25], reg_out_m[26], reg_out_m[27], reg_out_m[28], reg_out_m[29], reg_out_m[30], reg_out_m[31], dec_size_sel, reg_in[22]);
	mux9n	#(78)	mm4(reg_out_m[23], reg_out_m[24], reg_out_m[25], reg_out_m[26], reg_out_m[27], reg_out_m[28], reg_out_m[29], reg_out_m[30], reg_out_m[31], dec_size_sel, reg_in[23]);
	
	assign	decode_b0	= reg_out[0][7:0];
	assign	decode_b1	= reg_out[1][7:0];
	assign	decode_b2	= reg_out[2][7:0];
	assign	decode_b3	= reg_out[3][7:0];
	assign	decode_b4	= reg_out[4][7:0];
	assign	decode_b5	= reg_out[5][7:0];
	assign	decode_b6	= reg_out[6][7:0];
	assign	decode_b7	= reg_out[7][7:0];
	assign	decode_b8	= reg_out[8][7:0];
	assign	decode_b9	= reg_out[9][7:0];
	assign	decode_b10	= reg_out[10][7:0];
	assign	decode_b11	= reg_out[11][7:0];
	assign	decode_b12	= reg_out[12][7:0];
	
	
endmodule
	
