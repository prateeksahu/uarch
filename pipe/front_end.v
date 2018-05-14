module front_end
	(
	input	[0:0]	CLK, 
	input	[0:0]	reset,
	
	//From bus
	input	[31:0]	intr_vec,
	input	[0:0]	intr,

	//From icache
	input	[63:0]	cache_line,
	input	[14:0]	cache_ret_addr,
	input	[0:0]	cache_line_valid,
	
	//From RR_ST
	input	[0:0]	rr_stall,
	
	//From TLB
	input	[43:0]	tlb_trans, 
	input	[0:0]	tlb_hit,

	//From TLB_ST
	input	[0:0]	data_gp_excp, 
	input	[0:0]	data_pf_excp, 
	input	[31:0]	data_excp_eip, 
	
	//From EXEC_ST
	input	[31:0]	ex_branch_neip,
	input	[31:0]	ex_branch_target,
	input	[0:0]	ex_branch_taken,
	input	[0:0]	ex_branch_mispred,
	input	[0:0]	ex_branch_valid,
	
	//From REG_FILE
	input	[15:0]	cs_in,
	
	//FROM WB
	input	[0:0]	cs_inv,
	input	[31:0]	cs_neip,

	//Misc
	input	[0:0]	pipe_clean, 
	input	[0:0]	excp_dflag,
	input	[0:0]	ex_dflag,
	input	[0:0]	cs_dflag,
	input	[0:0]	repne_term,
	
	//To icache
	output	[14:0]	fetch_addr,
	output	[0:0]	fetch_addr_valid,
	output	[0:0]	page_bound,
	
	//To TLB 
	output [31:0]	tlb_addr,
	output [0:0]	tlb_access,
	
	//To RR_ST
	output [61:0] i_CS,        
	output [31:0] i_imm,       
	output [31:0] i_disp,
	output [1:0] i_immSize,       
	output [1:0] i_dispSize,	
	output [0:0]	i_SIB,
	output [1:0]  i_scale,    
	output [0:0]  i_baseRen,      
	output [0:0]  i_idxRen,        
	output [31:0] i_nEIP,      
	output [31:0] i_EIP,       
	output [31:0] i_bp_tgt,    
	output [7:0]  i_imm8,      
	output [1:0]  i_opSize,   
	output [2:0]  i_sr1,       
	output [2:0]  i_sr2,       
	output [2:0]  i_base,      
	output [2:0]  i_idx,       
	output [2:0]  i_segR1,     
	output [2:0]  i_segR2,     
	output [0:0]  i_bp_taken,  
	output [0:0]  i_indir_addr,     
	output [0:0]  i_Dflag,     
	output [0:0]  i_v,
	output [3:0]  i_br_fetch_id
	);
	
	
	
	//Fetch 
	wire	[31:0]	bpred_target;
	wire	[0:0]	bpred_taken;
	wire	[0:0]	bpred_hit;
	wire	[0:0]	dec1_stall;
	
	wire	[0:0]	replay_inst;
	wire	[31:0]	replay_eip;
	
	wire	[31:0]	fetch_addr_t;

	wire	[31:0]	bpred_pc_out;
	wire	[31:0]	update_bpred_pc;
	wire	[31:0]	update_bpred_target;
	wire	[0:0]	update_bpred_taken;
	wire	[0:0]	update_bpred_valid;

	wire	[63:0]	fetch_bytes;
	wire	[255:0]	fetch_pcs;
	wire	[0:0]	fetch_not_ready;
	wire	[3:0]	fetch_width;
	wire	[3:0]	br_fetch_id;
	wire	[31:0]	fetch_bpred_tgt;
	wire	[0:0]	fetch_bpred_taken;
	wire	[0:0]	fetch_ex_br_taken;
	
	//Only have 8 pages in memory!
	assign 	fetch_addr	= fetch_addr_t[14:0]; 
	
	
	//Decode1
	wire	[0:0]	has_prefix1;
	wire	[0:0]	has_prefix2;
	wire	[0:0]	has_prefix3;
	wire	[0:0]	has_op2;
	wire	[0:0]	has_imm8;
	wire	[0:0]	has_imm16;
	wire	[0:0]	has_imm32;
	wire	[0:0]	has_modrm;
	wire	[0:0]	has_sib;
	wire	[0:0]	has_disp8;
	wire	[0:0]	has_disp32;
	wire	[7:0]	prefix2_byte;
	wire	[7:0]	opcode1_byte;
	wire	[7:0]	opcode2_byte;
	wire	[7:0]	modrm_byte;
	wire	[7:0]	sib_byte;
	wire	[3:0]	size;
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
	
	wire	[0:0]	dec2_stall;
	wire	[31:0]	eip;
	wire	[31:0]	n_eip;
	wire	[0:0]	dec1_not_ready;
	wire	[3:0]	br_fetch_id_out;
	wire	[31:0]	d1_bpred_tgt;
	wire	[0:0]	d1_bpred_taken;
	wire	[0:0]	d1_ex_br_taken;
	
	
	wire	[0:0]	bytes_cleanup;
	wire	[3:0]	cleanup_id;	


	wire	[0:0]	datapath_inv;
	wire	[0:0]	other_inv;
	or4n	#(1)	dpinv(data_gp_excp, data_pf_excp, ex_branch_mispred, cs_inv, datapath_inv);
	or2n	#(1)	otinv(ex_branch_mispred, cs_inv, other_inv);
	
	fetch 			ft(	CLK, 
						reset, 
						cache_line,
					       	cache_ret_addr,	
						cache_line_valid,
						tlb_trans,
						tlb_hit,
						bpred_target,
						bpred_taken, 
						bpred_hit,
						dec1_stall,
						replay_inst,
						replay_eip,
						ex_branch_neip,
						ex_branch_target, 
						ex_branch_taken,
						ex_branch_mispred,						
						ex_branch_valid,
						cs_in,
						cs_inv,
						cs_neip,
	
						
						fetch_addr_t,
						fetch_addr_valid,
						tlb_addr, 
						tlb_access, 
						bpred_pc_out, 
						update_bpred_pc,
						update_bpred_target,
						update_bpred_taken,
						update_bpred_mispred,
						update_bpred_valid,
						fetch_bytes,
						fetch_pcs,
						fetch_not_ready,
						fetch_width,
						page_bound,
						br_fetch_id,
						fetch_bpred_tgt,
						fetch_bpred_taken,
						fetch_ex_br_taken
						);
						
	
						
						
	bpred 			br	(
						CLK,
						reset,
						bpred_pc_out,
						
						update_bpred_pc,
						update_bpred_target,
						update_bpred_taken,
						update_bpred_mispred,
						update_bpred_valid,
						
						bpred_target,
						bpred_taken,
						bpred_hit
						);
	
	
	decode1			d1(	CLK, 
						reset, 
						{fetch_ex_br_taken, fetch_bpred_taken, fetch_bpred_tgt, br_fetch_id, fetch_pcs[31:0], fetch_bytes[7:0]},
						{fetch_ex_br_taken, fetch_bpred_taken, fetch_bpred_tgt, br_fetch_id, fetch_pcs[63:32], fetch_bytes[15:8]},
						{fetch_ex_br_taken, fetch_bpred_taken, fetch_bpred_tgt, br_fetch_id, fetch_pcs[95:64], fetch_bytes[23:16]},
						{fetch_ex_br_taken, fetch_bpred_taken, fetch_bpred_tgt, br_fetch_id, fetch_pcs[127:96], fetch_bytes[31:24]},
						{fetch_ex_br_taken, fetch_bpred_taken, fetch_bpred_tgt, br_fetch_id, fetch_pcs[159:128], fetch_bytes[39:32]},
						{fetch_ex_br_taken, fetch_bpred_taken, fetch_bpred_tgt, br_fetch_id, fetch_pcs[191:160], fetch_bytes[47:40]},
						{fetch_ex_br_taken, fetch_bpred_taken, fetch_bpred_tgt, br_fetch_id, fetch_pcs[223:192], fetch_bytes[55:48]},
						{fetch_ex_br_taken, fetch_bpred_taken, fetch_bpred_tgt, br_fetch_id, fetch_pcs[255:224], fetch_bytes[63:56]},
						dec2_stall, 
						fetch_not_ready,
						fetch_width,
						page_bound,
						bytes_cleanup,
						cleanup_id,
						datapath_inv, 
						replay_inst,
						
						has_prefix1, 
						has_prefix2, 
						has_prefix3, 
						has_op2, 
						has_imm8, 
						has_imm16, 
						has_imm32, 
						has_modrm, 
						has_sib, 
						has_disp8, 
						has_disp32, 
						size,
						prefix2_byte, 
						opcode1_byte, 
						opcode2_byte, 
						modrm_byte, 
						sib_byte, 
						b0_out, 
						b1_out, 
						b2_out, 
						b3_out, 
						b4_out, 
						b5_out, 
						b6_out, 
						b7_out, 
						b8_out, 
						b9_out, 
						b10_out, 
						b11_out, 
						b12_out, 
						eip,
						dec1_stall, 
						dec1_not_ready,
						br_fetch_id_out,
						d1_bpred_tgt,
						d1_bpred_taken,
						d1_ex_br_taken
						);
	
	
						
	decode2			d2(	CLK,
						reset,
						
						has_prefix1,
						has_prefix2,
						has_prefix3,
						has_imm8,
						has_imm16,
						has_imm32,
						has_disp8,
						has_disp32,
						has_op2,
						has_modrm,
						has_sib,
						
						size,
						
						prefix2_byte,
						opcode1_byte,
						opcode2_byte,
						modrm_byte,
						sib_byte,
						
						b0_out,
						b1_out,
						b2_out,
						b3_out,
						b4_out,
						b5_out,
						b6_out,
						b7_out,
						b8_out,
						b9_out,
						b10_out,
						b11_out,
						b12_out,
						
						eip,
						dec1_not_ready,
						br_fetch_id_out,
						d1_bpred_tgt,
						d1_bpred_taken,
						d1_ex_br_taken,
						
						rr_stall,
						data_gp_excp,
						data_pf_excp,
						data_excp_eip,
						intr_vec,
						intr,
						datapath_inv,
						ex_branch_mispred,
						cs_inv,
						other_inv,

						pipe_clean,
						excp_dflag,
						ex_dflag,
						cs_dflag,
						repne_term,

						dec2_stall,
						bytes_cleanup,
						cleanup_id,
						replay_inst,
						replay_eip,
						
						//Pipeline read reg
						i_CS,			i_imm,		i_disp,      
						i_immSize,		i_dispSize, i_SIB,
						i_scale,		i_baseRen, 	i_idxRen,
						i_nEIP,			i_EIP,		i_bp_tgt,    
						i_imm8,			i_opSize,	i_sr1,
						i_sr2,			i_base,		i_idx,
						i_segR1,		i_segR2,	i_bp_taken,
						i_indir_addr,	i_Dflag,    i_br_fetch_id, 
						i_v 		  
						);
	
	
endmodule
