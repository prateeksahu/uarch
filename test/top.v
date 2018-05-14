module top();

reg clk;
reg rst;

reg [48:0] i_CS;
reg [31:0] i_imm;
reg [31:0] i_disp;      
reg [1:0]  i_immSize;
reg [1:0]  i_dispSize;
reg        i_isSIB;
reg [1:0]  i_scale;
reg        i_baseRen;
reg        i_idxRen;
reg [31:0] i_nEIP;
reg [31:0] i_EIP;      
reg [31:0] i_bp_tgt;
reg [7:0]  i_imm8;   
reg [1:0]  i_opSize;
reg [2:0]  i_sr1;
reg [2:0]  i_sr2;     
reg [2:0]  i_base;
reg [2:0]  i_idx;
reg [2:0]  i_segR1;     
reg [2:0]  i_segR2;
reg        i_bp_taken;
reg        i_indir;     
reg        i_Dflag;
reg [3:0]  i_bpFieldId;
reg        i_v;

reg [4:0] count;
wire rrstall;
initial
begin
	clk = 1'b0;
	rst = 1'b0;
	i_v = 1'b0;
	i_CS = 48'h0;
	count = 5'b0;
	i_EIP = 32'h3a; 
	#4
	rst = 1'b1;
	i_v = 1'b1;
	i_bpFieldId = 4'b0;
	i_Dflag = 1'b0;
	while( count < 32 )
	begin
		case (count)
		0 : begin
		    i_CS = 48'h3e020; i_imm = 32'h1; i_disp = 32'b0; i_immSize = 2'h3; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h2; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    1 : begin
	    	i_CS = 48'h3e020; i_imm = 32'h2; i_disp = 32'b0; i_immSize = 2'h3; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h1; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
	    	end
	    2 : begin
	    	i_CS = 48'h3e020; i_imm = 32'h4; i_disp = 32'b0; i_immSize = 2'h3; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h3; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
	    	end
	    3 : begin
	    	i_CS = 48'h3e020; i_imm = 32'h8; i_disp = 32'b0; i_immSize = 2'h3; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h5; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    4 : begin
	    	i_CS = 48'h3e020; i_imm = 32'h10; i_disp = 32'b0; i_immSize = 2'h3; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h7; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    5 : begin
	    	i_CS = 48'h3e020; i_imm = 32'h20; i_disp = 32'b0; i_immSize = 2'h3; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h4; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    6 : begin
	    	i_CS = 48'h3e020; i_imm = 32'h40; i_disp = 32'b0; i_immSize = 2'h3; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h0; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    7 : begin
	    	i_CS = 48'h3e020; i_imm = 32'h80; i_disp = 32'b0; i_immSize = 2'h3; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h6; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    8 : begin
	    	i_CS = 48'h2e081; i_imm = 32'h0; i_disp = 32'h0; i_immSize = 2'h0; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h1; i_sr2 = 3'h0; i_base = 3'h0; i_idx = 3'h0; i_segR1 = 3'b0; i_segR2 = 3'b1; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    9 : begin
	    	i_CS = 48'hfc0000028056; i_imm = 32'h0; i_disp = 32'h3; i_immSize = 2'h0; i_dispSize = 2'h0; i_isSIB = 1'b1; i_scale = 2'h2; i_baseRen = 1'b1; i_idxRen = 1'b1; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h0; i_sr2 = 3'h2; i_base = 3'h4; i_idx = 3'b0; i_segR1 = 3'b1; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b1;
		    end
	    10 : begin
	    	i_CS = 48'hfc0000028023; i_imm = 32'h0; i_disp = 32'h0; i_immSize = 2'h0; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h7; i_sr2 = 3'h0; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    11 : begin
	    	i_CS = 48'h23e0b5; i_imm = 32'h0; i_disp = 32'b0; i_immSize = 2'h0; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h2; i_sr2 = 3'h0; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b1; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b1;
		    end
	    12 : begin
	    	i_CS = 48'hfc002001e855; i_imm = 32'h0; i_disp = 32'b0; i_immSize = 2'h0; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h4; i_sr2 = 3'h0; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b1; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b1;
		    end
	    13 : begin
	    	i_CS = 48'hfc0020029075; i_imm = 32'h0; i_disp = 32'b0; i_immSize = 2'h0; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h3; i_sr2 = 3'h0; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b1;
		    end
	    14 : begin
	    	i_CS = 48'h3c01880; i_imm = 32'h4000; i_disp = 32'b0; i_immSize = 2'h0; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h2; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    15 : begin
	    	i_CS = 48'h3c01880; i_imm = 32'h8000; i_disp = 32'b0; i_immSize = 2'h0; i_dispSize = 2'h0; i_isSIB = 1'b0; i_scale = 2'b0; i_baseRen = 1'b0; i_idxRen = 1'b0; i_nEIP = i_EIP+2; i_bp_tgt = 32'h3c; i_imm8 = 8'b0; i_opSize = 2'b11; i_sr1 = 3'h2; i_sr2 = 3'h1; i_base = 3'b0; i_idx = 3'b0; i_segR1 = 3'b0; i_segR2 = 3'b0; i_bp_taken = 1'b1; i_indir = 1'b0;
		    end
	    endcase
	    #8
	    if(!rrstall) begin
	    	count = count + 1;
	    	i_EIP = i_nEIP;
	    end
	end
	    i_v = 1'b0;
end


always #4 clk = ~clk;

initial
      begin
	 $vcdplusfile("top.dump.vpd");
	 $vcdpluson(0, top); 
      end // initial begin


// Wire definitions ------------------------------------------------------------------------
wire [63:0] xmm_data; 

wire [52:0] wb_CS, wbo_CS;

wire [48:0] ex_CS, exo_CS, mp_CS, mpo_CS, tp_CS, tpo_CS, ag_CS, ago_CS;

wire [31:0] 
gpr_data, mem_data, EIP, EFlag, wb_data1, wb_data2, wb_EIP, wb_nEIP, wbo_data1, wbo_data2, wbo_EIP, wbo_nEIP, ex_op1, ex_op2, ex_nEIP, ex_EIP, ex_bp_tgt,  ex_br_tgt, eflags, exo_op1, exo_op2, exo_nEIP, exo_EIP, exo_bp_tgt, mp_src1, mp_src2, mp_nEIP, mp_EIP, mp_bp_tgt, dcache_data, mpo_src1, mpo_src2, mpo_nEIP, mpo_EIP, mpo_bp_tgt, addr_tlb, tp_virt_addr, tp_src1, tp_src2, tp_nEIP, tp_EIP, tp_bp_tgt, tpo_virt_addr, tp_segRc_lim, tpo_src1, tpo_src2, tpo_nEIP, tpo_EIP, tpo_bp_tgt, tpo_segRc_lim, ag_addr1, ag_addr2, ag_src1, ag_src2, ag_nEIP, ag_EIP, ag_bp_tgt, ago_addr1, ago_addr2, ago_src1, ago_src2, ago_nEIP, ago_EIP, ago_bp_tgt, src1, src2, xrc1, xrc2;

wire [25:0] tlbentry;

wire [19:0] limit, ago_limit, ag_limit;

wire [15:0] code_segment, segr_data, tp_segRc, tpo_segRc, ag_segRc1, ago_segRc1, segrc1, segrc2;

wire [14:0] mem_addr, wb_PA1, wb_PA2, wb_PA3, wb_PA4, wbo_PA1, wbo_PA2, wbo_PA3, wbo_PA4, ex_PA1, ex_PA2, exo_PA1, exo_PA2, mp_phys_addr, mpo_phys_addr, dcache_rreq;

wire [7:0] ex_imm8, exo_imm8, mp_imm8, mpo_imm8, tp_imm8, excp_id, tpo_imm8, ag_imm8, ago_imm8;

wire [5:0] wb_eflags, wbo_eflags; 

wire [2:0] src1_sel, src2_sel;

wire [2:0] gpr_dr, seg_dr, xmm_dr, wb_dr1, wb_dr2, wb_drSeg, wbo_dr1, wbo_dr2, wbo_drSeg, ex_dr1, ex_dr2, ex_drSeg, exo_dr1, exo_dr2, exo_drSeg, mp_dr1, mp_dr2, mp_drSeg, mpo_dr1, mpo_dr2, mpo_drSeg, tp_dr1, tp_dr2, tp_drSeg, tpo_dr1, tpo_dr2, tpo_drSeg, ag_dr1, ag_dr2, ag_drSeg, ago_dr1, ago_dr2, ago_drSeg, rf1, rf2, srf1, srf2;

wire [2:0] mem_size;

wire [1:0] opSize, wb_size1, wb_size2, wb_opSz, wb_spill, wbo_opSz, wbo_size1, wbo_size2, wbo_spill, ex_opSz, ex_size1, ex_size2, exo_opSz, exo_size1, exo_size2, mp_opSz, mp_reqSize, mpo_opSz, tp_opSz, mpo_reqSize, tpo_opSz, ag_opSz, ago_opSz, sz, segrc1_sel, segrc2_sel;

wire [3:0] wb_bpFieldId,  wbo_bpFieldId, ex_bpFieldId, exo_bpFieldId, mp_bpFieldId, mpo_bpFieldId, tp_bpFieldId, tpo_bpFieldId, ag_bpFieldId, ago_bpFieldId;

wire 
grpWen, segWen, xmmWen, v, wb_Dflag, wb_v, wbo_Dflag, wbo_v, b_tgt_v, bp_correct, ex_bp_taken, ex_Dflag, ex_spill, ex_v, ex_br_taken, ex_mispred, ex_br_valid, wbstall, exo_bp_taken, exo_Dflag, exo_spill, exo_v, mp_bp_taken, mp_Dflag, mp_spill, mp_false_of, mp_v, dcache_v, exstall, mpo_bp_taken, mpo_Dflag, mpo_spill, mpo_false_of, mpo_v, glb_inv, wb_inv, req_rvalid, tp_bp_taken, tp_Dflag, tp_v, memstall, pagefault, tpo_bp_taken, tpo_Dflag, tpo_v, agstall, ag_bp_taken, ag_indir, ag_Dflag, ag_v, tpstall, ago_bp_taken, ago_indir, ago_Dflag, ago_v, gprR1, gprR2, xmrR1, xmrR2, srfR1, srfR2, xmmReadMask, rdep;

//-------------------------------------------------------------------------------------
wire [31:0] cEIP;
registers globalRF(clk, rst, 
gprR1, rf1, sz, src1,
gprR2, rf2, sz, src2, 
srfR1, srf1, segrc1,
srfR2, srf2, segrc2,
xmrR1, rf1, xmmReadMask, xrc1,
xmrR2, rf2, xmmReadMask, xrc2,
cEIP, eflags,
grpWen, gpr_dr, opSize, gpr_data,
segWen, seg_dr, segr_data,
xmmWen, xmm_dr, 1'b1, xmm_data,
v, EIP,
v, 32'hffffffff, EFlag,
code_segment
);

dependency_checker regdep(rf1, rf2, srf1, srf2, gprR1, gprR2, xmrR1, xmrR2, srfR1, srfR2, xmmReadMask, ag_dr1, ag_dr2, ag_drSeg, ag_CS[5], ag_CS[6], ag_CS[7], ag_CS[10], ag_v, tp_dr1, tp_dr2, tp_drSeg, tp_CS[5], tp_CS[6], tp_CS[7], tp_CS[10], tp_v, mp_dr1, mp_dr2, mp_drSeg, mp_CS[5], mp_CS[6], mp_CS[7], mp_CS[10], mp_v, ex_dr1, ex_dr2, ex_drSeg, ex_CS[5], ex_CS[6], ex_CS[7], ex_CS[10], ex_v, wb_dr1, wb_dr2, wb_drSeg, wb_CS[6:5], wb_CS[8:7], wb_CS[10:9], wb_CS[14], wb_v, rdep, src1_sel, src2_sel, segrc1_sel, segrc2_sel);

reg_read r(ago_CS, ago_addr1, ago_addr2, ago_src1, ago_src2, ago_nEIP, ago_EIP, ago_bp_tgt, ago_segRc1, ago_limit, ago_imm8, ago_opSz, ago_dr1, ago_dr2, ago_drSeg, ago_bp_taken, ago_indir, ago_Dflag, ago_bpFieldId, ago_v, rf1, rf2, srf1, srf2, gprR1, gprR2, xmrR1, xmrR2, srfR1, srfR2, xmmReadMask, rrstall, sz,
i_CS, i_imm, i_disp, i_immSize, i_dispSize, i_isSIB, i_scale, i_baseRen, i_idxRen, i_nEIP, i_EIP, i_bp_tgt, i_imm8, i_opSize,i_sr1, i_sr2, i_base, i_idx, 
i_segR1, i_segR2, i_bp_taken, i_indir, i_Dflag, i_bpFieldId, i_v, src1, src2, xrc1, xrc2, segrc1, segrc2, 20'h100, clk, rst, src1_sel[1:0], src2_sel[1:0], segrc1_sel, segrc2_sel, wb_data1, wb_data2, rdep, agstall);

AG A(ag_CS, ag_addr1, ag_addr2, ag_src1, ag_src2, ag_nEIP, ag_EIP, ag_bp_tgt, ag_segRc1, 
ag_limit, ag_imm8, ag_opSz, ag_dr1, ag_dr2, ag_drSeg, ag_bp_taken, ag_indir, ag_Dflag, ag_bpFieldId, ag_v, {ago_CS, ago_addr1, 
ago_addr2, ago_src1, ago_src2, ago_nEIP, ago_EIP, ago_bp_tgt, ago_segRc1, ago_limit, 
ago_imm8, ago_opSz, ago_dr1, ago_dr2, ago_drSeg, ago_bp_taken, ago_indir, ago_Dflag, ago_bpFieldId, ago_v}, clk, rst, agstall);

addr_gen a(tpo_CS, tpo_virt_addr, tpo_src1, tpo_src2, tpo_nEIP, tpo_EIP, tpo_bp_tgt, 
tpo_segRc, tpo_segRc_lim, tpo_imm8, tpo_opSz, tpo_dr1, tpo_dr2, tpo_drSeg, tpo_bp_taken, tpo_Dflag, tpo_bpFieldId, tpo_v, agstall,
ag_CS, ag_addr1, ag_addr2, ag_src1, ag_src2, ag_nEIP, ag_EIP, ag_bp_tgt, ag_segRc1, 
ag_limit, ag_imm8, ag_opSz, ag_dr1, ag_dr2, ag_drSeg, ag_bp_taken, ag_indir, ag_Dflag, ag_bpFieldId, ag_v, tpstall);

TP T(tp_CS, tp_virt_addr, tp_src1, tp_src2, tp_nEIP, tp_EIP, tp_bp_tgt, tp_segRc, 
tp_segRc_lim, tp_imm8, tp_opSz, tp_dr1, tp_dr2, tp_drSeg, tp_bp_taken, tp_Dflag, tp_bpFieldId, tp_v, {tpo_CS, tpo_virt_addr, tpo_src1, 
tpo_src2, tpo_nEIP, tpo_EIP, tpo_bp_tgt, tpo_segRc, tpo_segRc_lim, tpo_imm8, tpo_opSz, tpo_dr1, tpo_dr2, tpo_drSeg, 
tpo_bp_taken, tpo_Dflag, tpo_bpFieldId, tpo_v}, clk, rst, tpstall);

tlb_pipe tp(mpo_CS, mpo_phys_addr, mpo_src1, mpo_src2, mpo_nEIP, mpo_EIP, mpo_bp_tgt, 
mpo_imm8, mpo_opSz, mpo_dr1, mpo_dr2, mpo_drSeg, mpo_bp_taken, mpo_Dflag, mpo_reqSize, mpo_spill, mpo_false_of, mpo_bpFieldId, 
mpo_v, tpstall, dcache_rreq, addr_tlb, excp_id, glb_inv, wb_inv, req_rvalid,
tp_CS, tp_virt_addr, tp_src1, tp_src2, tp_nEIP, tp_EIP, tp_bp_tgt, tp_segRc, tp_segRc_lim, 
tp_imm8, tp_opSz, tp_dr1, tp_dr2, tp_drSeg, tp_bp_taken, tp_Dflag, tp_bpFieldId, tp_v, memstall, tlbentry, pagefault, clk, rst);

MP M(mp_CS, mp_phys_addr, mp_src1, mp_src2, mp_nEIP, mp_EIP, mp_bp_tgt, mp_imm8, 
mp_opSz, mp_dr1, mp_dr2, mp_drSeg, 
mp_bp_taken, mp_Dflag, mp_reqSize, mp_spill, mp_false_of, mp_bpFieldId, mp_v, {mpo_CS, mpo_phys_addr, 
mpo_src1, mpo_src2, mpo_nEIP, mpo_EIP, mpo_bp_tgt, mpo_imm8, mpo_opSz, mpo_dr1, mpo_dr2, mpo_drSeg, mpo_bp_taken, 
mpo_Dflag, mpo_reqSize, mpo_spill, mpo_false_of, mpo_bpFieldId, mpo_v}, clk, rst, memstall);

mem_pipe mp(exo_CS, exo_PA1, exo_PA2, exo_op1, exo_op2, exo_nEIP, exo_EIP, exo_bp_tgt, 
exo_imm8, exo_opSz, exo_dr1, exo_dr2, exo_drSeg, exo_bp_taken, exo_Dflag, exo_size1, exo_size2, exo_spill, exo_bpFieldId, exo_v, 
memstall,
mp_CS, mp_phys_addr, mp_src1, mp_src2, mp_nEIP, mp_EIP, mp_bp_tgt, mp_imm8, mp_opSz, mp_dr1, mp_dr2, mp_drSeg, 
mp_bp_taken, mp_Dflag, mp_reqSize, mp_spill, mp_false_of, mp_bpFieldId, mp_v, dcache_data, dcache_v, 1'b0, 
exstall, clk, rst);

EX E(ex_CS, ex_PA1, ex_PA2, ex_op1, ex_op2, ex_nEIP, ex_EIP, ex_bp_tgt, ex_imm8, ex_opSz, ex_dr1, ex_dr2, ex_drSeg, 
ex_bp_taken, ex_Dflag, ex_size1, ex_size2, ex_spill, ex_bpFieldId, ex_v, {exo_CS, exo_PA1, exo_PA2, exo_op1, 
exo_op2, exo_nEIP, exo_EIP, exo_bp_tgt, exo_imm8, exo_opSz, exo_dr1, exo_dr2, exo_drSeg, exo_bp_taken, exo_Dflag, 
exo_size1, exo_size2, exo_spill, exo_bpFieldId, exo_v}, clk, rst, exstall);

exec e(wbo_CS, wbo_data1, wbo_data2, wbo_EIP, wbo_nEIP, wbo_PA1, wbo_PA2, wbo_PA3, wbo_PA4, 
wbo_size1, wbo_size2, wbo_eflags, wbo_opSz, wbo_dr1, wbo_dr2, wbo_drSeg, 
wbo_spill, wbo_Dflag, wbo_v, b_tgt_v, bp_correct, exstall, ex_br_taken, ex_br_tgt, ex_mispred, ex_br_valid,
ex_CS, ex_PA1, ex_PA2, ex_op1, ex_op2, ex_nEIP, ex_EIP, ex_bp_tgt, ex_imm8, ex_opSz, ex_dr1, ex_dr2, ex_drSeg, 
ex_bp_taken, ex_Dflag, ex_size1, ex_size2, ex_spill, ex_bpFieldId, ex_v, wbstall, clk, rst, code_segment, wb_v, wb_dr1, 
wb_eflags, wb_PA1, wb_PA2, wb_spill, wb_nEIP, wb_data1, wb_size1, wb_size2, eflags[5:0], wb_Dflag, wb_dr2);

WB W(wb_CS, wb_data1, wb_data2, wb_EIP, wb_nEIP, wb_PA1, wb_PA2, wb_PA3, wb_PA4, wb_size1, 
wb_size2, wb_eflags, wb_opSz, wb_dr1, wb_dr2, wb_drSeg, wb_spill, wb_Dflag, wb_v, 
{wbo_CS, wbo_data1, wbo_data2, wbo_EIP, wbo_nEIP, wbo_PA1, wbo_PA2, wbo_PA3, wbo_PA4, 
wbo_size1, wbo_size2, wbo_eflags, wbo_opSz, wbo_dr1, wbo_dr2, wbo_drSeg, 
wbo_spill, wbo_Dflag, wbo_v}, clk, rst, wbstall);

wire wbR, empty, writestall, read, o_en_vld;
wire [2:0] o_en_size;
wire [14:0] o_en_addr;
wire [31:0] o_en_eip, o_en_data;
wire [127:0] o_eip;
wire [59:0] o_addr;
wire [11:0] o_size;
wire [3:0] o_alloc;
write_back wb(gpr_data, segr_data, xmm_data, mem_data, gpr_dr, seg_dr, xmm_dr, mem_addr, 
grpWen, segWen, xmmWen, wrV, EIP, EFlag, v, mem_size[1:0], opSize, wbstall, wbR, 
wb_CS, wb_data1, wb_data2, wb_EIP, wb_nEIP, wb_PA1, wb_PA2, wb_PA3, wb_PA4, wb_size1, 
wb_size2, wb_eflags, wb_opSz, wb_dr1, wb_dr2, wb_drSeg, wb_spill, wb_Dflag, wb_v, clk, rst, writestall, empty);

tlb TLB(addr_tlb, tlbentry, pagefault);
dcache DC(dcache_rreq, req_rvalid, dcache_data, dcache_v, mem_data, o_en_addr, o_en_size[1:0], o_en_vld, read);
wb_buffer_d4 wb_buf(clk, rst, wbR, wrV, EIP, mem_addr, mem_data, mem_size, mp_EIP, mp_CS[17], o_en_vld, o_en_addr, o_en_data, o_en_eip, o_en_size, o_alloc, o_eip, o_addr, o_size, read, empty, writestall);

endmodule

module tlb(input [31:0] addr, output [25:0] entry, output pagefault);

	xor2n #(26) x1(addr[25:0], 26'h390d2ab, entry);
	mux2$ m1(pagefault, 1'b0, 1'b1, 1'b0);

endmodule

module dcache(input [14:0] readaddr, input readV, output reg [31:0] data, output reg v, input [31:0] wrData, input [14:0] wrAddr, input [1:0] wrSize, input wrV, output ack);

	reg i;
	//reg [31:0] data;
	initial
		begin
			#5 data = 32'b0;
			v = 1'b0;
	 forever begin
		#5
		data = 32'h12345678;
		v = 1'b1;
		#3
		v = 1'b0;
		#10
		data = 32'h9abc5678;
		v = 1'b1;
		#6
		v = 1'b0;
	 end
	end

endmodule