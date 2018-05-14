module sat_addr_2b
	(
	input	[1:0]	in1,
	input	[1:0]	in2,
	output	[1:0]	out
	);
	
	wire	[0:0]	a0;
	wire	[0:0]	a1;
	wire	[0:0]	b0;
	wire	[0:0]	b1;
	wire	[0:0]	a0_n;
	wire	[0:0]	a1_n;
	wire	[0:0]	b0_n;
	wire	[0:0]	b1_n;
	
	assign	a1	= in1[1];
	assign	a0	= in1[0];
	assign	b1	= in2[1];
	assign	b0	= in2[0];
	
	invn	#(1)	i0(a0, a0_n);
	invn	#(1)	i1(a1, a1_n);
	invn	#(1)	i2(b0, b0_n);
	invn	#(1)	i3(b1, b1_n);
	
	wire	[0:0]	mt_s1_0;
	wire	[0:0]	mt_s1_1;
	wire	[0:0]	mt_s1_2;
	
	wire	[0:0]	mt_s0_0;
	wire	[0:0]	mt_s0_1;
	wire	[0:0]	mt_s0_2;
	wire	[0:0]	mt_s0_3;
	
	and3n	#(1)	aa0(a1, a0, b0, mt_s1_0);
	and3n	#(1)	aa1(a0, b1_n, b0, mt_s1_1);
	and2n	#(1)	aa2(a1, b1_n, mt_s1_2);
	or3n	#(1)	oo0(mt_s1_0, mt_s1_1, mt_s1_2, out[1]);
	
	and3n	#(1)	aa3(a0, b1_n, b0_n, mt_s0_0);
	and3n	#(1)	aa4(a1, a0_n, b0, mt_s0_1);
	and3n	#(1)	aa5(a0_n, b1_n, b0, mt_s0_2);
	and3n	#(1)	aa6(a1, b1_n, b0, mt_s0_3);
	or4n	#(1)	oo1(mt_s0_0, mt_s0_1, mt_s0_2, mt_s0_3, out[0]);
	
endmodule


module demux32n #(parameter N = 8)(
	input  [N-1:0] in,
	input  [4:0]   sel,
	output [N-1:0] o0,
	output [N-1:0] o1,
	output [N-1:0] o2,
	output [N-1:0] o3,
	output [N-1:0] o4,
	output [N-1:0] o5,
	output [N-1:0] o6,
	output [N-1:0] o7,
	output [N-1:0] o8,
	output [N-1:0] o9,
	output [N-1:0] o10,
	output [N-1:0] o11,
	output [N-1:0] o12,
	output [N-1:0] o13,
	output [N-1:0] o14,
	output [N-1:0] o15,
	output [N-1:0] o16,
	output [N-1:0] o17,
	output [N-1:0] o18,
	output [N-1:0] o19,
	output [N-1:0] o20,
	output [N-1:0] o21,
	output [N-1:0] o22,
	output [N-1:0] o23,
	output [N-1:0] o24,
	output [N-1:0] o25,
	output [N-1:0] o26,
	output [N-1:0] o27,
	output [N-1:0] o28,
	output [N-1:0] o29,
	output [N-1:0] o30,
	output [N-1:0] o31
	);

	wire [7:0] temp;	
	wire [31:0] temp_sel;
	
	wire [0:0] b0;	
	wire [0:0] b1;	
	wire [0:0] b0_n;	
	wire [0:0] b1_n;
	assign	b0 = sel[3];
	assign	b1 = sel[4];
	invn	#(1)	i0(b0, b0_n);
	invn	#(1)	i1(b1, b1_n);
	
	decoder3_8$	d0(sel[2:0], temp, );

	wire [7:0] t0;	
	wire [7:0] t1;	
	wire [7:0] t2;	
	wire [7:0] t3;	
	
	and3n	#(8)	aa0(temp, {8{b1_n}}, {8{b0_n}}, t0);
	and3n	#(8)	aa1(temp, {8{b1_n}}, {8{b0}}, t1);	
	and3n	#(8)	aa2(temp, {8{b1}}, {8{b0_n}}, t2);
	and3n	#(8)	aa3(temp, {8{b1}}, {8{b0}}, t3);

	
    	and2n	#(N)	a0({N{t0[0]}}, in, o0);
	and2n	#(N)	a1({N{t0[1]}}, in, o1);
	and2n	#(N)	a2({N{t0[2]}}, in, o2);
	and2n	#(N)	a3({N{t0[3]}}, in, o3);
	and2n	#(N)	a4({N{t0[4]}}, in, o4);
	and2n	#(N)	a5({N{t0[5]}}, in, o5);
	and2n	#(N)	a6({N{t0[6]}}, in, o6);
	and2n	#(N)	a7({N{t0[7]}}, in, o7);
	and2n	#(N)	a8({N{t1[0]}}, in, o8);
	and2n	#(N)	a9({N{t1[1]}}, in, o9);
	and2n	#(N)	aa({N{t1[2]}}, in, o10);
	and2n	#(N)	ab({N{t1[3]}}, in, o11);
	and2n	#(N)	ac({N{t1[4]}}, in, o12);
	and2n	#(N)	ad({N{t1[5]}}, in, o13);
	and2n	#(N)	ae({N{t1[6]}}, in, o14);
	and2n	#(N)	af({N{t1[7]}}, in, o15);
	and2n	#(N)	ag({N{t2[0]}}, in, o16);
	and2n	#(N)	ah({N{t2[1]}}, in, o17);
	and2n	#(N)	ai({N{t2[2]}}, in, o18);
	and2n	#(N)	aj({N{t2[3]}}, in, o19);
	and2n	#(N)	ak({N{t2[4]}}, in, o20);
	and2n	#(N)	al({N{t2[5]}}, in, o21);
	and2n	#(N)	am({N{t2[6]}}, in, o22);
	and2n	#(N)	an({N{t2[7]}}, in, o23);
	and2n	#(N)	ao({N{t3[0]}}, in, o24);
	and2n	#(N)	ap({N{t3[1]}}, in, o25);
	and2n	#(N)	aq({N{t3[2]}}, in, o26);
	and2n	#(N)	ar({N{t3[3]}}, in, o27);
	and2n	#(N)	as({N{t3[4]}}, in, o28);
	and2n	#(N)	at({N{t3[5]}}, in, o29);
	and2n	#(N)	au({N{t3[6]}}, in, o30);
	and2n	#(N)	av({N{t3[7]}}, in, o31);
	
endmodule
/*
module 	dec_mux32 #(parameter N = 8)
	(
   	input [N-1:0] in0,
    	input [N-1:0] in1,
    	input [N-1:0] in2,
    	input [N-1:0] in3,
    	input [N-1:0] in4,
    	input [N-1:0] in5,
    	input [N-1:0] in6,
    	input [N-1:0] in7,
    	input [N-1:0] in8,
    	input [N-1:0] in9,
    	input [N-1:0] in10,
    	input [N-1:0] in11,
    	input [N-1:0] in12,
    	input [N-1:0] in13,
    	input [N-1:0] in14,
    	input [N-1:0] in15,
    	input [N-1:0] in16,
    	input [N-1:0] in17,
    	input [N-1:0] in18,
    	input [N-1:0] in19,
    	input [N-1:0] in20,
    	input [N-1:0] in21,
    	input [N-1:0] in22,
    	input [N-1:0] in23,
    	input [N-1:0] in24,
    	input [N-1:0] in25,
    	input [N-1:0] in26,
    	input [N-1:0] in27,
    	input [N-1:0] in28,
    	input [N-1:0] in29,
    	input [N-1:0] in30,
    	input [N-1:0] in31,
    
    	input [31:0] sel,
    	output [N-1:0] out
	);

	wire	[N-1:0]	temp_a	[32];
	wire	[N-1:0]	temp_b	[8];
	wire	[N-1:0]	temp_c	[2];

	genvar i;
	generate
		for(i=0; i<32; i=i+1) begin: ands
			nand2n	#(N)	a({N{sel[i]}}, in[i], temp_a[0]); 		
		end
	endgenerate

	generate
		for(i=0; i<8; i=i+1) begin: ors
			nand4n	#(N)	o(temp_a[4*i+0], temp_a[4*i+0], temp_a[4*i+0], temp_a[4*i+0], temp_b[i]); 
		end
	endgenerate

	nor4n	#(N)	o0(temp_b[0], temp_b[1], temp_b[2], temp_b[3], temp_c[0]); 
	nor4n	#(N)	o1(temp_b[4], temp_b[5], temp_b[6], temp_b[7], temp_c[1]); 
	nand2n	#(N)	o2(temp_c[0], temp_c[1], out); 
	
endmodule
*/
module bpred
	(
	input	[0:0]	CLK,
	input	[0:0]	reset,
	
	//For prediction
	input	[31:0] 	pred_pc,
	
	//For update
	input	[31:0] 	update_neip,
	input	[31:0] 	update_target,
	input 	[0:0]	update_taken,
	input 	[0:0]	update_mispred,	
	input	[0:0]	update_valid,
	
	output	[31:0]	pred_target_curr,
	output	[0:0]	pred_taken_curr,
	output	[0:0]	pred_hit_curr
	);

	//BHSR
	wire	[0:0]	out0;
	wire	[0:0]	out1;
	wire	[0:0]	out2;
	wire	[0:0]	out3;
	wire	[0:0]	out4;
	wire	[0:0]	bhsr_en;
	
	regn	#(1)	bhsr0(update_taken, CLK, reset, bhsr_en, out0);
	regn	#(1)	bhsr1(out0, CLK, reset, bhsr_en, out1);
	regn	#(1)	bhsr2(out1, CLK, reset, bhsr_en, out2);
	//regn	#(1)	bhsr3(out2, CLK, reset, bhsr_en, out3);
	//regn	#(1)	bhsr4(out3, CLK, reset, bhsr_en, out4);
	
	//BHSR update
	assign	bhsr_en		= update_valid;
	
	/*------------------------------------------------------------------*/

	//PHT
	wire	[1:0]	pht_ctr_in	[31:0];
	wire	[1:0]	pht_ctr_out	[31:0];
	wire	[0:0]	pht_ctr_en	[31:0];
	wire	[1:0]	pht_ctr_inc	[31:0];
	wire	[1:0]	pht_ctr_dec	[31:0];
	wire	[0:0]	dir;
	
	genvar i;
	
    generate
		for(i=0; i<32; i=i+1) begin: pht_v
    
			regn	#(2)	pht(pht_ctr_in[i], CLK, reset, pht_ctr_en[i], pht_ctr_out[i]);
			
			sat_addr_2b		sati(pht_ctr_out[i], 2'b01, pht_ctr_inc[i]);
			sat_addr_2b		satd(pht_ctr_out[i], 2'b11, pht_ctr_dec[i]);
			
			mux2n	#(2)	mx(pht_ctr_dec[i], pht_ctr_inc[i], dir, pht_ctr_in[i]);
	
		end
	endgenerate

	/*------------------------------------------------------------------*/

	//PHT update
	wire	[0:0]	pht_en;
	wire	[4:0]	pht_update_addr;
	
	xor3n	#(5)	xn({out2, out1, out0, 1'b0, 1'b0}, update_neip[7:3], update_neip[12:8], pht_update_addr);
	
	and2n	#(1)	ax(update_mispred, update_valid, pht_en);
	
	demux32n	#(1)	dem(update_valid, pht_update_addr, pht_ctr_en[0], pht_ctr_en[1], pht_ctr_en[2], pht_ctr_en[3], pht_ctr_en[4], pht_ctr_en[5], pht_ctr_en[6], pht_ctr_en[7], pht_ctr_en[8], pht_ctr_en[9], pht_ctr_en[10], pht_ctr_en[11], pht_ctr_en[12], pht_ctr_en[13], pht_ctr_en[14], pht_ctr_en[15], pht_ctr_en[16], pht_ctr_en[17], pht_ctr_en[18], pht_ctr_en[19], pht_ctr_en[20], pht_ctr_en[21], pht_ctr_en[22], pht_ctr_en[23], pht_ctr_en[24], pht_ctr_en[25], pht_ctr_en[26], pht_ctr_en[27], pht_ctr_en[28], pht_ctr_en[29], pht_ctr_en[30], pht_ctr_en[31]);  
	
	assign	dir 	= update_taken;
	
	/*------------------------------------------------------------------*/

	//PHT read
	wire	[1:0]	match_pht;
	wire	[4:0]	pht_read_addr;

	//For now, xor with 10 bits of PC
	xor3n	#(5)	xo({out2, out1, out0, 1'b0, 1'b0}, pred_pc[7:3], pred_pc[12:8], pht_read_addr);
	
	
	mux32n	#(2)	mux(pht_ctr_out[0], pht_ctr_out[1], pht_ctr_out[2], pht_ctr_out[3], pht_ctr_out[4], pht_ctr_out[5], pht_ctr_out[6], pht_ctr_out[7], pht_ctr_out[8], pht_ctr_out[9], pht_ctr_out[10], pht_ctr_out[11], pht_ctr_out[12], pht_ctr_out[13], pht_ctr_out[14], pht_ctr_out[15], pht_ctr_out[16], pht_ctr_out[17], pht_ctr_out[18], pht_ctr_out[19], pht_ctr_out[20], pht_ctr_out[21], pht_ctr_out[22], pht_ctr_out[23], pht_ctr_out[24], pht_ctr_out[25], pht_ctr_out[26], pht_ctr_out[27], pht_ctr_out[28], pht_ctr_out[29], pht_ctr_out[30], pht_ctr_out[31], pht_read_addr, match_pht);  
	
	assign pred_taken_curr	= match_pht[1];
	
	/*------------------------------------------------------------------*/
	
	//BTB. Valid, eip, target
	wire	[64:0]	btb_in;
	wire	[64:0]	btb_out	[31:0];
	wire	[0:0]	btb_en	[31:0];
	
    generate
		for(i=0; i<32; i=i+1) begin: btb_v
    
			regn	#(65)	btb(btb_in, CLK, reset, btb_en[i], btb_out[i]);
		
		end
	endgenerate
	
	//BTB update
	wire	[4:0]	btb_update_addr;
	wire	[0:0] 	btb_wr_en;
	assign	btb_wr_en	= pht_en;
	
	demux32n	#(1)	dem2(update_valid, btb_update_addr, btb_en[0], btb_en[1], btb_en[2], btb_en[3], btb_en[4], btb_en[5], btb_en[6], btb_en[7], btb_en[8], btb_en[9], btb_en[10], btb_en[11], btb_en[12], btb_en[13], btb_en[14], btb_en[15], btb_en[16], btb_en[17], btb_en[18], btb_en[19], btb_en[20], btb_en[21], btb_en[22], btb_en[23], btb_en[24], btb_en[25], btb_en[26], btb_en[27], btb_en[28], btb_en[29], btb_en[30], btb_en[31]);  
	
	assign	btb_in	= {1'b1, update_neip, update_target};
	assign	btb_update_addr	= update_neip[7:3]; 
	
	/*------------------------------------------------------------------*/

	//BTB read
	wire	[4:0]	btb_read_addr;
	wire	[64:0]	match_btb;
	
	assign 	btb_read_addr	= pred_pc[7:3];
	
	mux32n	#(65)	mux2(btb_out[0], btb_out[1], btb_out[2], btb_out[3], btb_out[4], btb_out[5], btb_out[6], btb_out[7], btb_out[8], btb_out[9], btb_out[10], btb_out[11], btb_out[12], btb_out[13], btb_out[14], btb_out[15], btb_out[16], btb_out[17], btb_out[18], btb_out[19], btb_out[20], btb_out[21], btb_out[22], btb_out[23], btb_out[24], btb_out[25], btb_out[26], btb_out[27], btb_out[28], btb_out[29], btb_out[30], btb_out[31], btb_read_addr, match_btb);  
	 
	wire	[0:0] 	tag_match;
	assign	btb_read_addr	= pred_pc[7:3];
	
	comp_eq32	cc({match_btb[63:35], 3'b0}, {pred_pc[31:3], 3'b0}, tag_match);
	
	and2n	#(1)	aa0(tag_match, match_btb[64], pred_hit_curr);
	assign	pred_target_curr 	= match_btb[31:0];

	/*------------------------------------------------------------------*/

endmodule
