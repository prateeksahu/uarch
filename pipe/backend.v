module backend( output o_cachable, output mpo_cachable,
output [31:0] o_en_data, output [14:0] o_en_addr,    output [2:0]  o_en_size, 
output        o_en_vld,  output [14:0] dcache_raddr, output        dcache_rvalid, 
output [31:0] addr_tlb,  output        v_tlb,        output        gp,           
output        o_pagefault, 
output [31:0] tp_EIP,    output [31:0] ex_nEIP,      output [31:0] wb_nEIP, 
output        cs_inv,    output        ex_mispred,   output        rrstall, 
output [15:0] code_segment, output     ex_br_taken,  output        ex_br_valid,
output [31:0] ex_br_tgt, output pipe_clean, output tp_Dflag, output ex_Dflag, output wb_Dflag, output term,
input [61:0] i_CS,      input [31:0] i_imm,      input [31:0] i_disp,       
input [1:0]  i_immSize, input [1:0]  i_dispSize, input        i_isSIB,   
input [1:0]  i_scale,   input        i_baseRen,  input        i_idxRen, 
input [31:0] i_nEIP,    input [31:0] i_EIP,      input [31:0] i_bp_tgt, 
input [7:0]  i_imm8,    input [1:0]  i_opSize,   input [2:0]  i_sr1, 
input [2:0]  i_sr2,     input [2:0]  i_base,     input [2:0]  i_idx, 
input [2:0]  i_segR1,   input [2:0]  i_segR2,    input        i_bp_taken, 
input        i_indir,   input        i_Dflag,    input [3:0]  i_bpFieldId, 
input        i_v,       input        clk,        input        rst,
input [43:0] tlbentry,  input        pagefault,  input [31:0] dcache_data,
input        dcache_v,  input        read,       input        dcache_wr_addrfetch,
input [14:0] cacheAddrOut);
//tlb TLB(addr_tlb, tlbentry, pagefault);
//dcache DC(dcache_rreq, req_rvalid, dcache_data, dcache_v, mem_data, o_en_addr, o_en_size[1:0], o_en_vld, read);

// Wire definitions ------------------------------------------------------------------------
wire wbR, empty, writestall;
wire [31:0] o_en_eip;
wire [127:0] o_eip;
wire [59:0] o_addr;
wire [11:0] o_size;
wire [3:0] o_alloc;
wire [63:0] xmm_data; 

wire [54:0] wb_CS, wbo_CS;

wire [50:0] ex_CS, exo_CS, mp_CS, mpo_CS, tp_CS, tpo_CS, ag_CS, ago_CS, rr_CS;

wire [31:0] 
gpr_data, mem_data, EIP, EFlag, wb_data1, wb_data2, wb_EIP, wbo_data1, wbo_data2, wbo_EIP, wbo_nEIP, ex_op1, ex_op2, ex_EIP, ex_bp_tgt, eflags, exo_op1, exo_op2, exo_nEIP, exo_EIP, exo_bp_tgt, mp_src1, mp_src2, mp_nEIP, mp_EIP, mp_bp_tgt, mpo_src1, mpo_src2, mpo_nEIP, mpo_EIP, mpo_bp_tgt, tp_virt_addr, tp_src1, tp_src2, tp_nEIP, tp_bp_tgt, tpo_virt_addr, tp_segRc_lim, tpo_src1, tpo_src2, tpo_nEIP, tpo_EIP, tpo_bp_tgt, tpo_segRc_lim, ag_addr1, ag_addr2, ag_src1, ag_src2, ag_nEIP, ag_EIP, ag_bp_tgt, ago_addr1, ago_addr2, ago_src1, ago_src2, ago_nEIP, ago_EIP, ago_bp_tgt, src1, src2, xrc1, xrc2, rr_imm, rr_disp, rr_EIP, rr_nEIP, rr_bp_tgt;

wire [19:0] limit, ago_limit, ag_limit;

wire [15:0] segr_data, tp_segRc, tpo_segRc, ag_segRc1, ago_segRc1, segrc1, segrc2;

wire [14:0] mem_addr, wb_PA1, wb_PA2, wb_PA3, wb_PA4, wbo_PA1, wbo_PA2, wbo_PA3, wbo_PA4, ex_PA1, ex_PA2, exo_PA1, exo_PA2, mp_req_addr, mp_phys_addr, mpo_phys_addr;

wire [7:0] ex_imm8, exo_imm8, mp_imm8, mpo_imm8, tp_imm8, excp_id, tpo_imm8, ag_imm8, ago_imm8, rr_imm8;

wire [5:0] wb_eflags, wbo_eflags; 

wire [2:0] src1_sel, src2_sel;

wire [2:0] gpr_dr, seg_dr, xmm_dr, wb_dr1, wb_dr2, wb_drSeg, wbo_dr1, wbo_dr2, wbo_drSeg, ex_dr1, ex_dr2, ex_drSeg, exo_dr1, exo_dr2, exo_drSeg, mp_dr1, mp_dr2, mp_drSeg, mpo_dr1, mpo_dr2, mpo_drSeg, tp_dr1, tp_dr2, tp_drSeg, tp_segR1, tpo_dr1, tpo_dr2, tpo_drSeg, tpo_segR1, ag_dr1, ag_dr2, ag_drSeg, ag_segR1, ago_dr1, ago_dr2, ago_drSeg, ago_segR1, rf1, rf2, srf1, srf2, rr_sr1, rr_sr2, rr_base, rr_idx, rr_segR1, rr_segR2;

wire [2:0] mem_size;

wire [1:0] opSize, wb_size1, wb_size2, wb_opSz, wb_spill, wbo_opSz, wbo_size1, wbo_size2, wbo_spill, ex_opSz, ex_size1, ex_size2, exo_opSz, exo_size1, exo_size2, mp_opSz, mp_reqSize, mpo_opSz, tp_opSz, mpo_reqSize, tpo_opSz, ag_opSz, ago_opSz, sz1, sz2, segrc1_sel, segrc2_sel, rr_immSize, rr_dispSize, rr_scale, rr_opSize;

wire [3:0] wb_bpFieldId,  wbo_bpFieldId, ex_bpFieldId, exo_bpFieldId, mp_bpFieldId, mpo_bpFieldId, tp_bpFieldId, tpo_bpFieldId, ag_bpFieldId, ago_bpFieldId, rr_bpFieldId;

wire 
grpWen, segWen, xmmWen, v, wb_v, wbo_Dflag, wbo_v, ex_bp_taken, ex_spill, ex_v, wbstall, exo_bp_taken, exo_Dflag, exo_spill, exo_v, mp_bp_taken, mp_Dflag, mp_spill, mp_false_of, mp_v, exstall, mpo_bp_taken, mpo_Dflag, mpo_spill, mpo_false_of, mpo_v, glb_inv, wb_inv, tp_bp_taken, tp_v, memstall, tpo_bp_taken, tpo_Dflag, tpo_v, agstall, ag_bp_taken, ag_indir, ag_Dflag, ag_v, tpstall, ago_bp_taken, ago_indir, ago_Dflag, ago_v, gprR1, gprR2, xmrR1, xmrR2, srfR1, srfR2, xmmReadMask, rdep, rr_bp_taken, rr_indir, rr_Dflag, rr_v, rr_baseRen, rr_idxRen, rr_isSIB, mx1, mx2, cachable, mp_cachable, exo_cachable, ex_cachable, wbo_cachable, wb_cachable;

//-------------------------------------------------------------------------------------
//assign o_pagefault = pagefault;
wire [31:0] cEIP;
registers globalRF(clk, rst, 
gprR1, rf1, sz1, src1,
gprR2, rf2, sz2, src2, 
srfR1, srf1, segrc1, limit,
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

dependency_checker regdep(rf1, rf2, srf1, srf2, gprR1, gprR2, xmrR1, xmrR2, srfR1, srfR2, xmmReadMask, rr_EIP, rr_v, sz1, sz2, ag_dr1, ag_dr2, ag_drSeg, ag_CS[5], ag_CS[6], ag_CS[7], ag_CS[9], ag_v, ag_EIP, ag_opSz, tp_dr1, tp_dr2, tp_drSeg, tp_CS[5], tp_CS[6], tp_CS[7], tp_CS[9], tp_v, tp_opSz, mp_dr1, mp_dr2, mp_drSeg, mp_CS[5], mp_CS[6], mp_CS[7], mp_CS[9], mp_v, mp_opSz, ex_dr1, ex_dr2, ex_drSeg, ex_CS[5], ex_CS[6], ex_CS[7], ex_CS[9], ex_v, ex_opSz, wb_dr1, wb_dr2, wb_drSeg, wb_CS[6:5], wb_CS[8:7], wb_CS[10:9], wb_CS[13], wb_v, wb_opSz, rdep, src1_sel, src2_sel, segrc1_sel, segrc2_sel, mx1, mx2);

mem_dep_beh mdep(mpo_phys_addr, mpo_reqSize, dcache_rvalid, mp_phys_addr, mp_reqSize, mem_memWrV, ex_PA1, ex_size1, ex_PA2, ex_size2, ex_memWrV, ex_spill, wb_PA1, wb_size1, wb_PA2, wb_size2, wb_PA3, wb_size1, wb_PA4, wb_size2, wb_memWrV1, wb_spill[0], wb_memWrV2, wb_spill[1], o_addr[14:0], o_size[1:0], o_alloc[0], o_addr[29:15], o_size[4:3], o_alloc[1], o_addr[44:30], o_size[7:6], o_alloc[2], o_addr[59:45], o_size[10:9], o_alloc[3], memdep);

RR R(
rr_CS, rr_imm, rr_disp, rr_immSize, rr_dispSize, rr_isSIB, rr_scale, rr_baseRen, rr_idxRen, rr_nEIP, rr_EIP, rr_bp_tgt, rr_imm8, rr_opSize,rr_sr1, rr_sr2, rr_base, rr_idx, rr_segR1, rr_segR2, rr_bp_taken, rr_indir, rr_Dflag, rr_bpFieldId, rr_v,
{i_CS, i_imm, i_disp, i_immSize, i_dispSize, i_isSIB, i_scale, i_baseRen, i_idxRen, i_nEIP, i_EIP, i_bp_tgt, i_imm8, i_opSize,i_sr1, i_sr2, i_base, i_idx, 
i_segR1, i_segR2, i_bp_taken, i_indir, i_Dflag, i_bpFieldId, i_v}, clk, rst, rrstall, tpInv);

reg_read r(ago_CS, ago_addr1, ago_addr2, ago_src1, ago_src2, ago_nEIP, ago_EIP, ago_bp_tgt, ago_segRc1, ago_limit, ago_imm8, ago_segR1, ago_opSz, ago_dr1, ago_dr2, ago_drSeg, ago_bp_taken, ago_indir, ago_Dflag, ago_bpFieldId, ago_v, rf1, rf2, srf1, srf2, gprR1, gprR2, xmrR1, xmrR2, srfR1, srfR2, xmmReadMask, rrstall, sz1, sz2,
rr_CS, rr_imm, rr_disp, rr_immSize, rr_dispSize, rr_isSIB, rr_scale, rr_baseRen, rr_idxRen, rr_nEIP, rr_EIP, rr_bp_tgt, rr_imm8, rr_opSize,rr_sr1, rr_sr2, rr_base, rr_idx, rr_segR1, rr_segR2, rr_bp_taken, rr_indir, rr_Dflag, rr_bpFieldId, rr_v, tpInv, src1, src2, xrc1, xrc2, segrc1, segrc2, limit, clk, rst, src1_sel[1:0], src2_sel[1:0], segrc1_sel, segrc2_sel, wb_data1, wb_data2, rdep, agstall, mx1, mx2, tpo_src1);

AG A(ag_CS, ag_addr1, ag_addr2, ag_src1, ag_src2, ag_nEIP, ag_EIP, ag_bp_tgt, ag_segRc1, 
ag_limit, ag_imm8, ag_segR1, ag_opSz, ag_dr1, ag_dr2, ag_drSeg, ag_bp_taken, ag_indir, ag_Dflag, ag_bpFieldId, ag_v, {ago_CS, ago_addr1, 
ago_addr2, ago_src1, ago_src2, ago_nEIP, ago_EIP, ago_bp_tgt, ago_segRc1, ago_limit, 
ago_imm8, ago_segR1, ago_opSz, ago_dr1, ago_dr2, ago_drSeg, ago_bp_taken, ago_indir, ago_Dflag, ago_bpFieldId, ago_v}, clk, rst, agstall, tpInv);

addr_gen a(tpo_CS, tpo_virt_addr, tpo_src1, tpo_src2, tpo_nEIP, tpo_EIP, tpo_bp_tgt, 
tpo_segRc, tpo_segRc_lim, tpo_imm8, tpo_segR1, tpo_opSz, tpo_dr1, tpo_dr2, tpo_drSeg, tpo_bp_taken, tpo_Dflag, tpo_bpFieldId, tpo_v, agstall,
ag_CS, ag_addr1, ag_addr2, ag_src1, ag_src2, ag_nEIP, ag_EIP, ag_bp_tgt, ag_segRc1, 
ag_limit, ag_imm8, ag_segR1, ag_opSz, ag_dr1, ag_dr2, ag_drSeg, ag_bp_taken, ag_indir, ag_Dflag, ag_bpFieldId, ag_v, tpstall, tpInv);

or2$ or12(tlbInv, mpInv, tpInv);
TP T(tp_CS, tp_virt_addr, tp_src1, tp_src2, tp_nEIP, tp_EIP, tp_bp_tgt, tp_segRc, 
tp_segRc_lim, tp_imm8, tp_segR1, tp_opSz, tp_dr1, tp_dr2, tp_drSeg, tp_bp_taken, tp_Dflag, tp_bpFieldId, tp_v, {tpo_CS, tpo_virt_addr, tpo_src1, 
tpo_src2, tpo_nEIP, tpo_EIP, tpo_bp_tgt, tpo_segRc, tpo_segRc_lim, tpo_imm8, tpo_segR1, tpo_opSz, tpo_dr1, tpo_dr2, tpo_drSeg, 
tpo_bp_taken, tpo_Dflag, tpo_bpFieldId, tpo_v}, clk, rst, tpstall, tlbInv);

tlb_pipe tp(mpo_cachable, mpo_CS, mpo_phys_addr, mpo_src1, mpo_src2, mpo_nEIP, mpo_EIP, mpo_bp_tgt, 
mpo_imm8, mpo_opSz, mpo_dr1, mpo_dr2, mpo_drSeg, mpo_bp_taken, mpo_Dflag, mpo_reqSize, mpo_spill, mpo_false_of, mpo_bpFieldId, 
mpo_v, tpstall, dcache_raddr, addr_tlb, gp, tpInv, wb_inv, dcache_rvalid, o_pagefault, v_tlb,
tp_CS, tp_virt_addr, tp_src1, tp_src2, tp_nEIP, tp_EIP, tp_bp_tgt, tp_segRc, tp_segRc_lim, 
tp_imm8, tp_segR1, tp_opSz, tp_dr1, tp_dr2, tp_drSeg, tp_bp_taken, tp_Dflag, tp_bpFieldId, tp_v, memstall, tlbentry, pagefault, clk, rst, mpInv, dcache_wr_addrfetch, memdep);

MP M(mp_cachable, mp_CS, mp_req_addr, mp_phys_addr, mp_src1, mp_src2, mp_nEIP, mp_EIP, mp_bp_tgt, mp_imm8, 
mp_opSz, mp_dr1, mp_dr2, mp_drSeg, 
mp_bp_taken, mp_Dflag, mp_reqSize, mp_spill, mp_false_of, mp_bpFieldId, mp_v, {mpo_cachable, mpo_CS, dcache_raddr, mpo_phys_addr, 
mpo_src1, mpo_src2, mpo_nEIP, mpo_EIP, mpo_bp_tgt, mpo_imm8, mpo_opSz, mpo_dr1, mpo_dr2, mpo_drSeg, mpo_bp_taken, 
mpo_Dflag, mpo_reqSize, mpo_spill, mpo_false_of, mpo_bpFieldId, mpo_v}, clk, rst, memstall, exInv);

mem_pipe mp(exo_cachable, exo_CS, exo_PA1, exo_PA2, exo_op1, exo_op2, exo_nEIP, exo_EIP, exo_bp_tgt, 
exo_imm8, exo_opSz, exo_dr1, exo_dr2, exo_drSeg, exo_bp_taken, exo_Dflag, exo_size1, exo_size2, exo_spill, exo_bpFieldId, exo_v, 
memstall, mpInv, mem_memWrV, 
mp_cachable, mp_CS, mp_req_addr, mp_phys_addr, mp_src1, mp_src2, mp_nEIP, mp_EIP, mp_bp_tgt, mp_imm8, mp_opSz, mp_dr1, mp_dr2, mp_drSeg, 
mp_bp_taken, mp_Dflag, mp_reqSize, mp_spill, mp_false_of, mp_bpFieldId, mp_v, dcache_data, dcache_v, 
exstall, clk, rst, exInv, wb_inv, tp_EIP, cacheAddrOut, ex_CS[50], ex_mispred, cs_inv);

EX E(ex_cachable, ex_CS, ex_PA1, ex_PA2, ex_op1, ex_op2, ex_nEIP, ex_EIP, ex_bp_tgt, ex_imm8, ex_opSz, ex_dr1, ex_dr2, ex_drSeg, 
ex_bp_taken, ex_Dflag, ex_size1, ex_size2, ex_spill, ex_bpFieldId, ex_v, {exo_cachable, exo_CS, exo_PA1, exo_PA2, exo_op1, 
exo_op2, exo_nEIP, exo_EIP, exo_bp_tgt, exo_imm8, exo_opSz, exo_dr1, exo_dr2, exo_drSeg, exo_bp_taken, exo_Dflag, 
exo_size1, exo_size2, exo_spill, exo_bpFieldId, exo_v}, clk, rst, exstall, cs_inv);

exec e(wbo_cachable, wbo_CS, wbo_data1, wbo_data2, wbo_EIP, wbo_nEIP, wbo_PA1, wbo_PA2, wbo_PA3, wbo_PA4, 
wbo_size1, wbo_size2, wbo_eflags, wbo_opSz, wbo_dr1, wbo_dr2, wbo_drSeg, 
wbo_spill, wbo_Dflag, wbo_v, exstall, ex_br_taken, ex_br_tgt, ex_mispred, ex_br_valid, exInv, ex_memWrV, term, 
ex_cachable, ex_CS, ex_PA1, ex_PA2, ex_op1, ex_op2, ex_nEIP, ex_EIP, ex_bp_tgt, ex_imm8, ex_opSz, ex_dr1, ex_dr2, ex_drSeg, 
ex_bp_taken, ex_Dflag, ex_size1, ex_size2, ex_spill, ex_bpFieldId, ex_v, wbstall, clk, rst, code_segment, wb_v, wb_dr1, 
wb_eflags, wb_PA1, wb_PA2, wb_spill, wb_nEIP, wb_data1, wb_size1, wb_size2, eflags[5:0], wb_Dflag, wb_dr2, cs_inv, wb_inv, tp_EIP, wb_CS[54]);

WB W(wb_cachable, wb_CS, wb_data1, wb_data2, wb_EIP, wb_nEIP, wb_PA1, wb_PA2, wb_PA3, wb_PA4, wb_size1, 
wb_size2, wb_eflags, wb_opSz, wb_dr1, wb_dr2, wb_drSeg, wb_spill, wb_Dflag, wb_v, 
{wbo_cachable, wbo_CS, wbo_data1, wbo_data2, wbo_EIP, wbo_nEIP, wbo_PA1, wbo_PA2, wbo_PA3, wbo_PA4, 
wbo_size1, wbo_size2, wbo_eflags, wbo_opSz, wbo_dr1, wbo_dr2, wbo_drSeg, 
wbo_spill, wbo_Dflag, wbo_v}, clk, rst, wbstall);

write_back wb(cachable, gpr_data, segr_data, xmm_data, mem_data, gpr_dr, seg_dr, xmm_dr, mem_addr, 
grpWen, segWen, xmmWen, wrV, EIP, EFlag, v, mem_size[1:0], opSize, wbstall, wbR, cs_inv, wb_memWrV1, wb_memWrV2,
wb_cachable, wb_CS, wb_data1, wb_data2, wb_EIP, wb_nEIP, wb_PA1, wb_PA2, wb_PA3, wb_PA4, wb_size1, 
wb_size2, wb_eflags, wb_opSz, wb_dr1, wb_dr2, wb_drSeg, wb_spill, wb_Dflag, wb_v, clk, rst, writestall, empty);

wb_buffer_d4 wb_buf(clk, rst, cachable, wrV, 1'b1, EIP, mem_addr, mem_data, mem_size, mp_EIP, mp_CS[17], o_cachable, o_en_vld, o_en_addr, o_en_data, o_en_eip, o_en_size, o_alloc, o_eip, o_addr, o_size, read, empty, writestall);

wire t1, t2, t3;
nor2$ o1(t1, rr_v, ag_v),
     o2(t2, tp_v, mp_v),
     o3(t3, ex_v, wb_v);
nand3$ o4(pipe_clean, t1, t2, t3);

endmodule
