module test_pipe;

	//Global Signals
	reg	[0:0]	CLK;
	reg	[0:0]	reset;

	
			
	//Signals for interrupt.
	wire interrupt;
	wire [31:0] intv;
	
	
	//D2 to RR
	wire [0:0]  rr_stall;	wire [61:0] i_CS;		wire [31:0] i_imm;		wire [31:0] i_disp;
	wire [1:0] 	i_immSize;	wire [1:0] 	i_dispSize;	wire [0:0]	i_SIB;		wire [1:0]  i_scale;    
	wire [0:0]  i_baseRen;	wire [0:0]  i_idxRen;	wire [31:0] i_nEIP;		wire [31:0] i_EIP;       
	wire [31:0] i_bp_tgt;	wire [15:0] i_currCS;	wire [7:0]  i_imm8;		wire [1:0]  i_opSize;
	wire [2:0]  i_sr1;		wire [2:0]  i_sr2;		wire [2:0]  i_base;		wire [2:0]  i_idx;       
	wire [2:0]  i_segR1;	wire [2:0]  i_segR2;	wire [0:0]  i_bp_taken;	wire [0:0]  i_indir_addr;     
	wire [0:0]  i_Dflag;	wire [0:0]  i_v;		wire [3:0]  i_br_fetch_id;
	
	//TLB
	wire [43:0]	inst_tlb_trans, dataTlbTrans;
	wire [0:0]	inst_tlb_hit, pagefault;
	wire [31:0]	inst_tlb_addr, dataTlbAddr;
	wire [0:0]	inst_tlb_access;
	reg	 [351:0]tlb_init;
	
	//D-Cache wires
	wire [31:0] cacheWrData, cacheRdData;
	wire [14:0] cacheWrAddr, cacheRdAddr, cacheAddrOut;
	wire [2:0]  cacheWrSize;
	wire cacheWrV, cacheRdV, cacheDataV, cacheWrAck, cacheRdAck, dataTlbV;
	
	tlb	mtlb(
		inst_tlb_addr, 		inst_tlb_access,		inst_tlb_trans,			inst_tlb_hit,
		dataTlbAddr,		dataTlbV,				dataTlbTrans,			pagefault,
		tlb_init
		);
	
	//I-CACHE
	wire [63:0]	icache_line;
	wire [14:0]	icache_ret_addr;
	wire [0:0]	icache_line_valid;
	wire [14:0]	fetch_addr;
	wire [0:0]	fetch_addr_valid;
	wire [0:0]	ipage_bound;
	
	wire [31:0] data_excp_eip, ex_branch_neip, cs_neip, ex_branch_target;
	wire [15:0] cs_in;
	wire [0:0]  data_pf_excp, data_gp_excp, ex_branch_taken, ex_branch_mispred, ex_branch_valid, cs_inv;
	wire [0:0] pipe_clean, excp_dflag, ex_dflag, cs_dflag, repne_term;
	
	front_end	front(
		CLK, 				reset,			intv, 		interrupt, 			icache_line,		icache_ret_addr, 
		icache_line_valid, 		rr_stall, 		inst_tlb_trans,		inst_tlb_hit, 		data_gp_excp, 		
		data_pf_excp, 			data_excp_eip, 		ex_branch_neip,		ex_branch_target,	ex_branch_taken, 	
		ex_branch_mispred,		ex_branch_valid,	cs_in,			cs_inv, 		cs_neip,
		pipe_clean, 			excp_dflag,		ex_dflag, 		cs_dflag, 		repne_term,

		fetch_addr,			fetch_addr_valid, 	ipage_bound, 		inst_tlb_addr, 		inst_tlb_access, 
		i_CS, 				i_imm, 				i_disp, 			i_immSize, 			i_dispSize,
		i_SIB, 				i_scale, 			i_baseRen, 			i_idxRen, 			i_nEIP,
		i_EIP,				i_bp_tgt, 			i_imm8, 			i_opSize, 			
		i_sr1,				i_sr2, 				i_base, 			i_idx, 				i_segR1, 			
		i_segR2,			i_bp_taken, 		i_indir_addr, 		i_Dflag, 			i_v, 				
		i_br_fetch_id
		);

	wire mp_cachable,wb_cachable;
	backend be(wb_cachable, mp_cachable, cacheWrData, cacheWrAddr, cacheWrSize, cacheWrV, cacheRdAddr, cacheRdV, 
			dataTlbAddr, dataTlbV, data_gp_excp, data_pf_excp, data_excp_eip, ex_branch_neip, cs_neip, 
			cs_inv, ex_branch_mispred, rr_stall, cs_in, ex_branch_taken, ex_branch_valid, ex_branch_target, pipe_clean, excp_dflag, ex_dflag, cs_dflag, repne_term,
			i_CS, i_imm, i_disp, i_immSize, i_dispSize, i_SIB, i_scale, i_baseRen, i_idxRen, i_nEIP, 
			i_EIP, i_bp_tgt,  i_imm8, i_opSize, i_sr1, i_sr2, i_base, i_idx, i_segR1, i_segR2,	i_bp_taken, 
			i_indir_addr, i_Dflag, i_br_fetch_id, i_v, CLK, reset, dataTlbTrans, pagefault, cacheRdData, 
			cacheDataV, cacheWrAck, cacheRdAck, cacheAddrOut);

	//Memory!
	
	
	mem_subsystem	#(32'd800000,32'd14,32'd15,15'h7000,15'h1000,15'h1004,15'h1008,15'h100a) mem_sys(
		CLK, 		reset,			fetch_addr,		fetch_addr_valid, 	ipage_bound, mp_cachable,
		cacheRdAddr,	cacheRdV, 		wb_cachable, cacheWrAddr, 		cacheWrSize[1:0], 	cacheWrData, 	
		cacheWrV,		,		icache_line_valid, 	icache_line,		icache_ret_addr,  		
		cacheRdAck,	cacheRdData,	cacheAddrOut,				cacheDataV, 	cacheWrAck, interrupt, intv
		);

	always
	begin
		#7 CLK = !CLK;
	end
	
	integer f;
	always@ (posedge CLK)
	begin
		if(i_v)
		begin
			//$fwrite(f, "%b\n", i_CS);
		end
	end

	integer reg_val;
	always@ (posedge CLK)
	begin
		if(be.wb.i_v==1'b1)
		begin
			$fwrite(f, "EIP:\t0%x\n", be.wb.EIP);
			$fwrite(f, "EFLAGS\n");
			$fwrite(f, "CF: %b ", be.wb.EFlag[0]);
			$fwrite(f, "PF: %b ", be.wb.EFlag[1]);
			$fwrite(f, "AF: %b ", be.wb.EFlag[2]);
			$fwrite(f, "ZF: %b ", be.wb.EFlag[3]);
			$fwrite(f, "SF: %b ", be.wb.EFlag[4]);
			$fwrite(f, "OF: %b\n", be.wb.EFlag[5]);
			$fwrite(f, "\n");

			if(be.wb.grpWen)
			begin
				reg_val = be.wb.gpr_dr;
				if(be.wb.opSize==2'b11)
				begin
					if(reg_val==0)	$fwrite(f, "EAX:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==1)	$fwrite(f, "ECX:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==2)	$fwrite(f, "EDX:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==3)	$fwrite(f, "EBX:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==4)	$fwrite(f, "ESP:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==5)	$fwrite(f, "EBP:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==6)	$fwrite(f, "ESI:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==7)	$fwrite(f, "EDI:\t0x%x\n", be.wb.gpr_data);
				end
				if(be.wb.opSize==2'b10)
				begin
					if(reg_val==0)	$fwrite(f, "AX:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==1)	$fwrite(f, "CX:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==2)	$fwrite(f, "DX:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==3)	$fwrite(f, "BX:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==4)	$fwrite(f, "SP:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==5)	$fwrite(f, "BP:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==6)	$fwrite(f, "SI:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==7)	$fwrite(f, "DI:\t0x%x\n", be.wb.gpr_data);
				end
				if(be.wb.opSize==2'b01)
				begin
					if(reg_val==0)	$fwrite(f, "AL:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==1)	$fwrite(f, "CL:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==2)	$fwrite(f, "DL:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==3)	$fwrite(f, "BL:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==4)	$fwrite(f, "AH:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==5)	$fwrite(f, "CH:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==6)	$fwrite(f, "DH:\t0x%x\n", be.wb.gpr_data);
					if(reg_val==7)	$fwrite(f, "BH:\t0x%x\n", be.wb.gpr_data);
				end
			end
			if(be.wb.segWen)
			begin
				if(be.wb.seg_dr==0)	$fwrite(f, "ES:\t0x%x\n", be.wb.segr_data);
				if(be.wb.seg_dr==1)	$fwrite(f, "CS:\t0x%x\n", be.wb.segr_data);
				if(be.wb.seg_dr==2)	$fwrite(f, "SS:\t0x%x\n", be.wb.segr_data);
				if(be.wb.seg_dr==3)	$fwrite(f, "DS:\t0x%x\n", be.wb.segr_data);
				if(be.wb.seg_dr==4)	$fwrite(f, "FS:\t0x%x\n", be.wb.segr_data);
				if(be.wb.seg_dr==5)	$fwrite(f, "GS:\t0x%x\n", be.wb.segr_data);
				
			end
			if(be.wb.xmmWen)	$fwrite(f, "Wrote %x to xmm %x\n", be.wb.xmm_data, be.wb.xmm_dr);
			if(be.wb.memWen)
			begin
				$fwrite(f, "Wrote %x to mem %x\n", be.wb.mem_data, be.wb.mem_addr);
				$fwrite(f, "Size:%x\n", be.wb.mem_size);
			end

			$fwrite(f, "------------------------------------------\n");
				
		end
	end

	initial begin
	
		f = $fopen("arch_out", "w");
		CLK = 1;
		reset = 0;

		//Initialize Control Store
		$readmemb("./../cs_bits.mem", front.d2.cs.rm.rm0h.mem);
		$readmemb("./../cs_files/cs0_l.mem", front.d2.cs.rm.rm0l.mem);
		$readmemb("./../cs_bits.mem", front.d2.cs.rm.rm1h.mem);
		$readmemb("./../cs_files/cs1_l.mem", front.d2.cs.rm.rm1l.mem);
		$readmemb("./../cs_bits.mem", front.d2.cs.rm.rm2h.mem);
		$readmemb("./../cs_files/cs2_l.mem", front.d2.cs.rm.rm2l.mem);
		$readmemb("./../cs_bits.mem", front.d2.cs.rm.rm3h.mem);
		$readmemb("./../cs_files/cs3_l.mem", front.d2.cs.rm.rm3l.mem);
		$readmemb("./../cs_bits.mem", front.d2.cs.rm.rm4h.mem);
		$readmemb("./../cs_files/cs4_l.mem", front.d2.cs.rm.rm4l.mem);
		$readmemb("./../cs_bits.mem", front.d2.cs.rm.rm5h.mem);
		$readmemb("./../cs_files/cs5_l.mem", front.d2.cs.rm.rm5l.mem);
		$readmemb("./../cs_bits.mem", front.d2.cs.rm.rm6h.mem);
		$readmemb("./../cs_files/cs6_l.mem", front.d2.cs.rm.rm6l.mem);
		$readmemb("./../cs_bits.mem", front.d2.cs.rm.rm7h.mem);
		$readmemb("./../cs_files/cs7_l.mem", front.d2.cs.rm.rm7l.mem);
		
		//Initialize Segment registers to 0
		$readmemh("./../segr.mem", be.globalRF.SEGR[1].REG.mem_array);
		$readmemh("./../segr.mem", be.globalRF.SEGR[0].REG.mem_array);

		//Initialize Segment Limit
		$readmemh("./../limit2.mem", be.globalRF.LIMIT[2].REG.mem_array);
		$readmemh("./../limit1.mem", be.globalRF.LIMIT[1].REG.mem_array);
		$readmemh("./../limit0.mem", be.globalRF.LIMIT[0].REG.mem_array);
		
		//Initialize memory
		$readmemh("./../mem_files/mem_map0.mem", mem_sys.mem_inst.l[0].bank.page[0].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map1.mem", mem_sys.mem_inst.l[0].bank.page[0].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map2.mem", mem_sys.mem_inst.l[0].bank.page[0].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map3.mem", mem_sys.mem_inst.l[0].bank.page[0].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map4.mem", mem_sys.mem_inst.l[0].bank.page[0].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map5.mem", mem_sys.mem_inst.l[0].bank.page[0].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map6.mem", mem_sys.mem_inst.l[0].bank.page[0].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map7.mem", mem_sys.mem_inst.l[0].bank.page[0].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map8.mem", mem_sys.mem_inst.l[1].bank.page[0].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map9.mem", mem_sys.mem_inst.l[1].bank.page[0].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map10.mem", mem_sys.mem_inst.l[1].bank.page[0].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map11.mem", mem_sys.mem_inst.l[1].bank.page[0].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map12.mem", mem_sys.mem_inst.l[1].bank.page[0].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map13.mem", mem_sys.mem_inst.l[1].bank.page[0].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map14.mem", mem_sys.mem_inst.l[1].bank.page[0].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map15.mem", mem_sys.mem_inst.l[1].bank.page[0].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map16.mem", mem_sys.mem_inst.l[2].bank.page[0].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map17.mem", mem_sys.mem_inst.l[2].bank.page[0].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map18.mem", mem_sys.mem_inst.l[2].bank.page[0].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map19.mem", mem_sys.mem_inst.l[2].bank.page[0].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map20.mem", mem_sys.mem_inst.l[2].bank.page[0].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map21.mem", mem_sys.mem_inst.l[2].bank.page[0].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map22.mem", mem_sys.mem_inst.l[2].bank.page[0].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map23.mem", mem_sys.mem_inst.l[2].bank.page[0].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map24.mem", mem_sys.mem_inst.l[3].bank.page[0].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map25.mem", mem_sys.mem_inst.l[3].bank.page[0].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map26.mem", mem_sys.mem_inst.l[3].bank.page[0].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map27.mem", mem_sys.mem_inst.l[3].bank.page[0].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map28.mem", mem_sys.mem_inst.l[3].bank.page[0].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map29.mem", mem_sys.mem_inst.l[3].bank.page[0].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map30.mem", mem_sys.mem_inst.l[3].bank.page[0].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map31.mem", mem_sys.mem_inst.l[3].bank.page[0].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map32.mem", mem_sys.mem_inst.l[0].bank.page[1].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map33.mem", mem_sys.mem_inst.l[0].bank.page[1].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map34.mem", mem_sys.mem_inst.l[0].bank.page[1].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map35.mem", mem_sys.mem_inst.l[0].bank.page[1].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map36.mem", mem_sys.mem_inst.l[0].bank.page[1].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map37.mem", mem_sys.mem_inst.l[0].bank.page[1].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map38.mem", mem_sys.mem_inst.l[0].bank.page[1].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map39.mem", mem_sys.mem_inst.l[0].bank.page[1].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map40.mem", mem_sys.mem_inst.l[1].bank.page[1].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map41.mem", mem_sys.mem_inst.l[1].bank.page[1].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map42.mem", mem_sys.mem_inst.l[1].bank.page[1].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map43.mem", mem_sys.mem_inst.l[1].bank.page[1].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map44.mem", mem_sys.mem_inst.l[1].bank.page[1].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map45.mem", mem_sys.mem_inst.l[1].bank.page[1].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map46.mem", mem_sys.mem_inst.l[1].bank.page[1].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map47.mem", mem_sys.mem_inst.l[1].bank.page[1].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map48.mem", mem_sys.mem_inst.l[2].bank.page[1].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map49.mem", mem_sys.mem_inst.l[2].bank.page[1].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map50.mem", mem_sys.mem_inst.l[2].bank.page[1].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map51.mem", mem_sys.mem_inst.l[2].bank.page[1].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map52.mem", mem_sys.mem_inst.l[2].bank.page[1].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map53.mem", mem_sys.mem_inst.l[2].bank.page[1].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map54.mem", mem_sys.mem_inst.l[2].bank.page[1].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map55.mem", mem_sys.mem_inst.l[2].bank.page[1].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map56.mem", mem_sys.mem_inst.l[3].bank.page[1].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map57.mem", mem_sys.mem_inst.l[3].bank.page[1].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map58.mem", mem_sys.mem_inst.l[3].bank.page[1].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map59.mem", mem_sys.mem_inst.l[3].bank.page[1].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map60.mem", mem_sys.mem_inst.l[3].bank.page[1].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map61.mem", mem_sys.mem_inst.l[3].bank.page[1].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map62.mem", mem_sys.mem_inst.l[3].bank.page[1].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map63.mem", mem_sys.mem_inst.l[3].bank.page[1].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map64.mem", mem_sys.mem_inst.l[0].bank.page[2].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map65.mem", mem_sys.mem_inst.l[0].bank.page[2].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map66.mem", mem_sys.mem_inst.l[0].bank.page[2].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map67.mem", mem_sys.mem_inst.l[0].bank.page[2].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map68.mem", mem_sys.mem_inst.l[0].bank.page[2].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map69.mem", mem_sys.mem_inst.l[0].bank.page[2].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map70.mem", mem_sys.mem_inst.l[0].bank.page[2].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map71.mem", mem_sys.mem_inst.l[0].bank.page[2].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map72.mem", mem_sys.mem_inst.l[1].bank.page[2].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map73.mem", mem_sys.mem_inst.l[1].bank.page[2].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map74.mem", mem_sys.mem_inst.l[1].bank.page[2].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map75.mem", mem_sys.mem_inst.l[1].bank.page[2].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map76.mem", mem_sys.mem_inst.l[1].bank.page[2].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map77.mem", mem_sys.mem_inst.l[1].bank.page[2].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map78.mem", mem_sys.mem_inst.l[1].bank.page[2].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map79.mem", mem_sys.mem_inst.l[1].bank.page[2].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map80.mem", mem_sys.mem_inst.l[2].bank.page[2].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map81.mem", mem_sys.mem_inst.l[2].bank.page[2].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map82.mem", mem_sys.mem_inst.l[2].bank.page[2].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map83.mem", mem_sys.mem_inst.l[2].bank.page[2].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map84.mem", mem_sys.mem_inst.l[2].bank.page[2].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map85.mem", mem_sys.mem_inst.l[2].bank.page[2].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map86.mem", mem_sys.mem_inst.l[2].bank.page[2].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map87.mem", mem_sys.mem_inst.l[2].bank.page[2].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map88.mem", mem_sys.mem_inst.l[3].bank.page[2].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map89.mem", mem_sys.mem_inst.l[3].bank.page[2].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map90.mem", mem_sys.mem_inst.l[3].bank.page[2].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map91.mem", mem_sys.mem_inst.l[3].bank.page[2].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map92.mem", mem_sys.mem_inst.l[3].bank.page[2].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map93.mem", mem_sys.mem_inst.l[3].bank.page[2].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map94.mem", mem_sys.mem_inst.l[3].bank.page[2].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map95.mem", mem_sys.mem_inst.l[3].bank.page[2].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map96.mem", mem_sys.mem_inst.l[0].bank.page[3].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map97.mem", mem_sys.mem_inst.l[0].bank.page[3].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map98.mem", mem_sys.mem_inst.l[0].bank.page[3].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map99.mem", mem_sys.mem_inst.l[0].bank.page[3].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map100.mem", mem_sys.mem_inst.l[0].bank.page[3].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map101.mem", mem_sys.mem_inst.l[0].bank.page[3].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map102.mem", mem_sys.mem_inst.l[0].bank.page[3].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map103.mem", mem_sys.mem_inst.l[0].bank.page[3].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map104.mem", mem_sys.mem_inst.l[1].bank.page[3].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map105.mem", mem_sys.mem_inst.l[1].bank.page[3].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map106.mem", mem_sys.mem_inst.l[1].bank.page[3].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map107.mem", mem_sys.mem_inst.l[1].bank.page[3].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map108.mem", mem_sys.mem_inst.l[1].bank.page[3].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map109.mem", mem_sys.mem_inst.l[1].bank.page[3].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map110.mem", mem_sys.mem_inst.l[1].bank.page[3].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map111.mem", mem_sys.mem_inst.l[1].bank.page[3].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map112.mem", mem_sys.mem_inst.l[2].bank.page[3].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map113.mem", mem_sys.mem_inst.l[2].bank.page[3].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map114.mem", mem_sys.mem_inst.l[2].bank.page[3].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map115.mem", mem_sys.mem_inst.l[2].bank.page[3].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map116.mem", mem_sys.mem_inst.l[2].bank.page[3].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map117.mem", mem_sys.mem_inst.l[2].bank.page[3].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map118.mem", mem_sys.mem_inst.l[2].bank.page[3].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map119.mem", mem_sys.mem_inst.l[2].bank.page[3].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map120.mem", mem_sys.mem_inst.l[3].bank.page[3].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map121.mem", mem_sys.mem_inst.l[3].bank.page[3].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map122.mem", mem_sys.mem_inst.l[3].bank.page[3].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map123.mem", mem_sys.mem_inst.l[3].bank.page[3].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map124.mem", mem_sys.mem_inst.l[3].bank.page[3].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map125.mem", mem_sys.mem_inst.l[3].bank.page[3].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map126.mem", mem_sys.mem_inst.l[3].bank.page[3].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map127.mem", mem_sys.mem_inst.l[3].bank.page[3].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map128.mem", mem_sys.mem_inst.l[0].bank.page[4].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map129.mem", mem_sys.mem_inst.l[0].bank.page[4].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map130.mem", mem_sys.mem_inst.l[0].bank.page[4].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map131.mem", mem_sys.mem_inst.l[0].bank.page[4].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map132.mem", mem_sys.mem_inst.l[0].bank.page[4].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map133.mem", mem_sys.mem_inst.l[0].bank.page[4].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map134.mem", mem_sys.mem_inst.l[0].bank.page[4].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map135.mem", mem_sys.mem_inst.l[0].bank.page[4].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map136.mem", mem_sys.mem_inst.l[1].bank.page[4].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map137.mem", mem_sys.mem_inst.l[1].bank.page[4].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map138.mem", mem_sys.mem_inst.l[1].bank.page[4].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map139.mem", mem_sys.mem_inst.l[1].bank.page[4].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map140.mem", mem_sys.mem_inst.l[1].bank.page[4].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map141.mem", mem_sys.mem_inst.l[1].bank.page[4].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map142.mem", mem_sys.mem_inst.l[1].bank.page[4].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map143.mem", mem_sys.mem_inst.l[1].bank.page[4].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map144.mem", mem_sys.mem_inst.l[2].bank.page[4].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map145.mem", mem_sys.mem_inst.l[2].bank.page[4].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map146.mem", mem_sys.mem_inst.l[2].bank.page[4].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map147.mem", mem_sys.mem_inst.l[2].bank.page[4].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map148.mem", mem_sys.mem_inst.l[2].bank.page[4].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map149.mem", mem_sys.mem_inst.l[2].bank.page[4].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map150.mem", mem_sys.mem_inst.l[2].bank.page[4].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map151.mem", mem_sys.mem_inst.l[2].bank.page[4].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map152.mem", mem_sys.mem_inst.l[3].bank.page[4].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map153.mem", mem_sys.mem_inst.l[3].bank.page[4].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map154.mem", mem_sys.mem_inst.l[3].bank.page[4].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map155.mem", mem_sys.mem_inst.l[3].bank.page[4].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map156.mem", mem_sys.mem_inst.l[3].bank.page[4].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map157.mem", mem_sys.mem_inst.l[3].bank.page[4].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map158.mem", mem_sys.mem_inst.l[3].bank.page[4].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map159.mem", mem_sys.mem_inst.l[3].bank.page[4].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map160.mem", mem_sys.mem_inst.l[0].bank.page[5].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map161.mem", mem_sys.mem_inst.l[0].bank.page[5].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map162.mem", mem_sys.mem_inst.l[0].bank.page[5].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map163.mem", mem_sys.mem_inst.l[0].bank.page[5].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map164.mem", mem_sys.mem_inst.l[0].bank.page[5].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map165.mem", mem_sys.mem_inst.l[0].bank.page[5].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map166.mem", mem_sys.mem_inst.l[0].bank.page[5].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map167.mem", mem_sys.mem_inst.l[0].bank.page[5].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map168.mem", mem_sys.mem_inst.l[1].bank.page[5].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map169.mem", mem_sys.mem_inst.l[1].bank.page[5].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map170.mem", mem_sys.mem_inst.l[1].bank.page[5].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map171.mem", mem_sys.mem_inst.l[1].bank.page[5].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map172.mem", mem_sys.mem_inst.l[1].bank.page[5].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map173.mem", mem_sys.mem_inst.l[1].bank.page[5].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map174.mem", mem_sys.mem_inst.l[1].bank.page[5].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map175.mem", mem_sys.mem_inst.l[1].bank.page[5].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map176.mem", mem_sys.mem_inst.l[2].bank.page[5].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map177.mem", mem_sys.mem_inst.l[2].bank.page[5].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map178.mem", mem_sys.mem_inst.l[2].bank.page[5].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map179.mem", mem_sys.mem_inst.l[2].bank.page[5].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map180.mem", mem_sys.mem_inst.l[2].bank.page[5].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map181.mem", mem_sys.mem_inst.l[2].bank.page[5].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map182.mem", mem_sys.mem_inst.l[2].bank.page[5].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map183.mem", mem_sys.mem_inst.l[2].bank.page[5].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map184.mem", mem_sys.mem_inst.l[3].bank.page[5].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map185.mem", mem_sys.mem_inst.l[3].bank.page[5].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map186.mem", mem_sys.mem_inst.l[3].bank.page[5].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map187.mem", mem_sys.mem_inst.l[3].bank.page[5].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map188.mem", mem_sys.mem_inst.l[3].bank.page[5].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map189.mem", mem_sys.mem_inst.l[3].bank.page[5].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map190.mem", mem_sys.mem_inst.l[3].bank.page[5].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map191.mem", mem_sys.mem_inst.l[3].bank.page[5].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map192.mem", mem_sys.mem_inst.l[0].bank.page[6].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map193.mem", mem_sys.mem_inst.l[0].bank.page[6].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map194.mem", mem_sys.mem_inst.l[0].bank.page[6].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map195.mem", mem_sys.mem_inst.l[0].bank.page[6].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map196.mem", mem_sys.mem_inst.l[0].bank.page[6].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map197.mem", mem_sys.mem_inst.l[0].bank.page[6].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map198.mem", mem_sys.mem_inst.l[0].bank.page[6].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map199.mem", mem_sys.mem_inst.l[0].bank.page[6].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map200.mem", mem_sys.mem_inst.l[1].bank.page[6].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map201.mem", mem_sys.mem_inst.l[1].bank.page[6].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map202.mem", mem_sys.mem_inst.l[1].bank.page[6].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map203.mem", mem_sys.mem_inst.l[1].bank.page[6].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map204.mem", mem_sys.mem_inst.l[1].bank.page[6].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map205.mem", mem_sys.mem_inst.l[1].bank.page[6].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map206.mem", mem_sys.mem_inst.l[1].bank.page[6].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map207.mem", mem_sys.mem_inst.l[1].bank.page[6].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map208.mem", mem_sys.mem_inst.l[2].bank.page[6].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map209.mem", mem_sys.mem_inst.l[2].bank.page[6].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map210.mem", mem_sys.mem_inst.l[2].bank.page[6].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map211.mem", mem_sys.mem_inst.l[2].bank.page[6].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map212.mem", mem_sys.mem_inst.l[2].bank.page[6].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map213.mem", mem_sys.mem_inst.l[2].bank.page[6].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map214.mem", mem_sys.mem_inst.l[2].bank.page[6].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map215.mem", mem_sys.mem_inst.l[2].bank.page[6].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map216.mem", mem_sys.mem_inst.l[3].bank.page[6].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map217.mem", mem_sys.mem_inst.l[3].bank.page[6].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map218.mem", mem_sys.mem_inst.l[3].bank.page[6].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map219.mem", mem_sys.mem_inst.l[3].bank.page[6].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map220.mem", mem_sys.mem_inst.l[3].bank.page[6].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map221.mem", mem_sys.mem_inst.l[3].bank.page[6].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map222.mem", mem_sys.mem_inst.l[3].bank.page[6].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map223.mem", mem_sys.mem_inst.l[3].bank.page[6].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map224.mem", mem_sys.mem_inst.l[0].bank.page[7].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map225.mem", mem_sys.mem_inst.l[0].bank.page[7].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map226.mem", mem_sys.mem_inst.l[0].bank.page[7].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map227.mem", mem_sys.mem_inst.l[0].bank.page[7].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map228.mem", mem_sys.mem_inst.l[0].bank.page[7].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map229.mem", mem_sys.mem_inst.l[0].bank.page[7].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map230.mem", mem_sys.mem_inst.l[0].bank.page[7].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map231.mem", mem_sys.mem_inst.l[0].bank.page[7].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map232.mem", mem_sys.mem_inst.l[1].bank.page[7].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map233.mem", mem_sys.mem_inst.l[1].bank.page[7].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map234.mem", mem_sys.mem_inst.l[1].bank.page[7].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map235.mem", mem_sys.mem_inst.l[1].bank.page[7].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map236.mem", mem_sys.mem_inst.l[1].bank.page[7].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map237.mem", mem_sys.mem_inst.l[1].bank.page[7].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map238.mem", mem_sys.mem_inst.l[1].bank.page[7].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map239.mem", mem_sys.mem_inst.l[1].bank.page[7].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map240.mem", mem_sys.mem_inst.l[2].bank.page[7].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map241.mem", mem_sys.mem_inst.l[2].bank.page[7].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map242.mem", mem_sys.mem_inst.l[2].bank.page[7].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map243.mem", mem_sys.mem_inst.l[2].bank.page[7].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map244.mem", mem_sys.mem_inst.l[2].bank.page[7].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map245.mem", mem_sys.mem_inst.l[2].bank.page[7].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map246.mem", mem_sys.mem_inst.l[2].bank.page[7].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map247.mem", mem_sys.mem_inst.l[2].bank.page[7].chip[7].c.mem);
		$readmemh("./../mem_files/mem_map248.mem", mem_sys.mem_inst.l[3].bank.page[7].chip[0].c.mem);
		$readmemh("./../mem_files/mem_map249.mem", mem_sys.mem_inst.l[3].bank.page[7].chip[1].c.mem);
		$readmemh("./../mem_files/mem_map250.mem", mem_sys.mem_inst.l[3].bank.page[7].chip[2].c.mem);
		$readmemh("./../mem_files/mem_map251.mem", mem_sys.mem_inst.l[3].bank.page[7].chip[3].c.mem);
		$readmemh("./../mem_files/mem_map252.mem", mem_sys.mem_inst.l[3].bank.page[7].chip[4].c.mem);
		$readmemh("./../mem_files/mem_map253.mem", mem_sys.mem_inst.l[3].bank.page[7].chip[5].c.mem);
		$readmemh("./../mem_files/mem_map254.mem", mem_sys.mem_inst.l[3].bank.page[7].chip[6].c.mem);
		$readmemh("./../mem_files/mem_map255.mem", mem_sys.mem_inst.l[3].bank.page[7].chip[7].c.mem);
		
		
		tlb_init			= {
							{1'b1, 20'h0,20'h0,1'b1,1'b1,1'b0}, 
							{1'b1, 20'h2000,20'h2,1'b1,1'b1,1'b1}, 
							{1'b1, 20'h4000,20'h5,1'b1,1'b1,1'b1}, 
							{1'b1, 20'hb000,20'h4,1'b1,1'b1,1'b1}, 
							{1'b1, 20'hc000,20'h7,1'b1,1'b1,1'b1}, 
							{1'b1, 20'ha000,20'h5,1'b1,1'b1,1'b1}, 
							{1'b0, 20'h8000,20'h1,1'b1,1'b1,1'b1}, 
							{1'b1, 20'h8001,20'h3,1'b1,1'b1,1'b1}};
	
		#45
		reset 				= 1;

		#100000
		$finish;
		
	end
	
	initial
    begin
	 $vcdplusfile("test_pipe.dump.vpd");
	 $vcdpluson(0, test_pipe); 
    end // initial begin
		
endmodule
