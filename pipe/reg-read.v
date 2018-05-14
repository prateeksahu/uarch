
module reg_read(
output [50:0] o_CS,        output [31:0] o_addr1,     output [31:0] o_addr2,     
output [31:0] o_src1,      output [31:0] o_src2,      output [31:0] o_nEIP,      
output [31:0] o_EIP,       output [31:0] o_bp_tgt,    output [15:0] o_segRc1,    
output [19:0] o_limit,     output [7:0]  o_imm8,      output [2:0]  o_segR1,
output [1:0]  o_opSize,    output [2:0]  o_dr1,       output [2:0]  o_dr2,       
output [2:0]  o_drSeg,     output        o_bp_taken,  output        o_indir,     
output        o_Dflag,     output [3:0]  o_br_fetchID,output        o_v,         
output [2:0]  rf1, output [2:0] rf2, output [2:0] srf1, output [2:0] srf2,
output gprR1, output gprR2, output xmrR1, output xmrR2, output srfR1, output srfR2,
output xmmReadMask, output stall, output [1:0] sz1, output [1:0] sz2,
input [50:0] i_CS,        input [31:0] i_imm,       input [31:0] i_disp,      
input [1:0]  i_immSize,   input [1:0]  i_dispSize,  input        i_isSIB,
input [1:0]  i_scale,     input        i_baseRen,   input        i_idxRen,    
input [31:0] i_nEIP,      input [31:0] i_EIP,       input [31:0] i_bp_tgt,    
input [7:0]  i_imm8,      input [1:0]  i_opSize,    input [2:0]  i_sr1,       
input [2:0]  i_sr2,       input [2:0]  i_base,      input [2:0]  i_idx,       
input [2:0]  i_segR1,     input [2:0]  i_segR2,     input        i_bp_taken,  
input        i_indir,     input        i_Dflag,     input [3:0]  i_br_fetchID,
input        i_v,         input        i_inv,
input [31:0] src1, input [31:0] src2, input [31:0] xrc1, input [31:0] xrc2,
input [15:0] segrc1, input [15:0] segrc2, input [19:0] limit, input clk, input rst, input [1:0] src1_sel, input [1:0] src2_sel, input [1:0] segrc1_sel, input [1:0] segrc2_sel, input [31:0] wb_data1, input [31:0] wb_data2, input dep, input istall, input mx1, input mx2, input [31:0] agSrc1);

wire [1:0] xmmOp, uOpNo;
wire [2:0] aluOp;
wire r1Ren, r2Ren, segR1Ren, segR2Ren, memRen, dr1Wen, dr2Wen, segDWen, memWen, passAB, lastuop, isJMP, isCALL, isPUSH, isPOP, isEXCH, isCMPE, isSIMD, isSAT, isSHUF, isDAA, isRET;
wire [5:0] flags_mod, flags_cmp, flags_used;

    assign r1Ren      = i_CS[0];   //
    assign r2Ren      = i_CS[1];   //
    assign segR1Ren   = i_CS[2];     //
    assign segR2Ren   = i_CS[3];     //
    assign memRen     = i_CS[4]; 
    assign dr1Wen     = i_CS[5]; 
    assign dr2Wen     = i_CS[6]; 
    assign segDWen    = i_CS[7]; 
    assign memWen     = i_CS[8]; 
    assign xmmOp      = {i_CS[9],i_CS[10]}; //
    assign uOpNo      = {i_CS[11],i_CS[12]}; 
    assign aluOp      = {i_CS[13],i_CS[14],i_CS[15]}; 
    assign passAB     = i_CS[16]; 
    assign lastuop    = i_CS[17]; 
    assign isJMP      = i_CS[18];    //
    assign isCALL     = i_CS[19]; 
    assign isPUSH     = i_CS[20]; 
    assign isPOP      = i_CS[21]; 
    assign isEXCH     = i_CS[22]; 
    assign isCMPE     = i_CS[23]; 
    assign isSIMD     = i_CS[24]; 
    assign isSAT      = i_CS[25]; 
    assign isSHUF     = i_CS[26]; 
    assign isDAA      = i_CS[27]; 
    assign isRET      = i_CS[28]; 
    assign isCMPS     = i_CS[29];
    assign flags_mod  = {i_CS[30],i_CS[31],i_CS[32],i_CS[33],i_CS[34],i_CS[35]};
    assign flags_cmp  = {i_CS[36],i_CS[37],i_CS[38],i_CS[39],i_CS[40],i_CS[41]};
    assign flags_used = {i_CS[42],i_CS[43],i_CS[44],i_CS[45],i_CS[46],i_CS[47]};
    assign interrupt  = i_CS[48];
    assign o_CS = i_CS;
    assign o_EIP = i_EIP;
    assign o_nEIP = i_nEIP;
    assign o_bp_tgt = i_bp_tgt;
    assign o_bp_taken = i_bp_taken;
    assign o_imm8 = i_imm8;
    assign o_Dflag = i_Dflag;
    assign o_indir = i_indir;
    assign o_limit = limit;
    assign o_br_fetchID = i_br_fetchID;
    wire t_v, n_v, wait1;
    nor2$ i10(wait1, stall, i_inv);
    and2$ a11(o_v, i_v, wait1);
    assign o_segR1 = i_segR1;
    inv1$ afa1(n_v, i_v);

// Next State Logic
parameter IDLE = 1'b0, TWO_CY = 1'b1;

wire t1, t2, t3, t4, sel1, sel2;
wire next, cst;
wire n_2cycle, cond1;
and2$ a1(t1, r1Ren, i_baseRen),
      a2(t2, r2Ren, i_idxRen);
nor2$ n1(n_2cycle, t1, t2);
xnor2$ x1(t3, n_2cycle, cst);
or3$ n2(t4, dep, istall, t3);
and2$ a3(stall, t4, i_v);
nor3$ n3(cond1, n_2cycle, dep, n_v);
//or2$ o1(sel1, cond1, dep);
nor2$ o2(sel2, istall, dep);
or2$ o8(sel1, sel2, i_inv);
mux2$ m11(stI, IDLE, TWO_CY, cond1);
mux2$ m12(stT, TWO_CY, IDLE, sel1);
//inv1$ i1(t3, cst[0]);
//and3$ a3(t4, stall, i_v, t3);
//mux2$ m14(two_cycle, t4, two_cycle, cst[1]);
//mux3n #(2) m1(IDLE, TWO_CY, DEP, {dep,two_cycle}, next);
mux2$ m1(next, stI, stT, cst);

// Current State Logic
dffn #(1) state1(next, clk, rst, cst);

// Output Logic
wire [2:0] sr1_b, sr2_idx;
wire [1:0] opsz;
wire srren1, srren2, memOp, normalReg, n_isSIB;
assign rf1 = sr1_b;
assign rf2 = sr2_idx;
assign srf1 = i_segR1;
assign srf2 = i_segR2;
inv1$ i2(not_xmm_op1, xmmOp[1]);
inv1$ i7(n_isSIB, i_isSIB);
inv1$ i8(gprRd1, ngprRd1);
nor2$ afo1(ngprRd1, not_xmm_op1, normalReg);
inv1$ i9(ngprRd2, gprRd2);
nor2$ afo2(tRd2, n_isSIB, cst);
nand2$ afa2(gprRd2, xmmOp[1], tRd2);
and2$ a8(gprR1, gprRd1, srren1);
and2$ a9(gprR2, gprRd2, srren2);
assign srfR1 = segR1Ren;
assign srfR2 = segR2Ren;
or2$ o102(memOp, memRen, memWen);
and2$ a103(normalReg, memOp, isSIMD);
and2$ a4(xmrR1, ngprRd1, srren1);
and2$ a5(xmrR2, ngprRd2, srren2);
assign xmmReadMask = xmmOp[0];
mux2n #(2) m23(opsz, 2'h3, memOp, sz1);
assign sz2 = opsz;
assign o_opSize = i_opSize;

wire sel;
xnor2$ x2(sel, cst, i_isSIB);
mux2n #(1) m17(i_baseRen, r1Ren, sel, srren1);
mux2n #(1) m18(i_idxRen , r2Ren, sel, srren2);
mux2n #(3) m2(i_base, i_sr1, sel, sr1_b);
mux2n #(3) m3(i_idx, i_sr2, sel, sr2_idx);
mux2n #(2) m22(2'b11, i_opSize, sel, opsz);

nor3$ afo3(SIBsinglecycle, n_isSIB, r1Ren, r2Ren);
mux2n #(3) nux1(sr2_idx, i_sr2, SIBsinglecycle, o_dr2);
assign o_dr1 = sr1_b;
assign o_drSeg = i_segR2;

wire [31:0] source1, source2, source1_1, source2_1, tdisp32, disp32, i_disp_8, i_disp_16, i_imm_8, i_imm_16, temp_src2, dispPush;
wire realPush, ssSel;
sext8 s1(i_disp_8, i_disp),
      s2(i_imm_8, i_imm);
sext16 s3(i_disp_16, i_disp),
       s4(i_imm_16, i_imm);
mux4n #(32) m4(32'b0, i_disp_8, i_disp_16, i_disp, i_dispSize, tdisp32),
            m5(source2, i_imm_8, i_imm_16, i_imm, i_immSize, temp_src2),
            m6(src1, xrc1, wb_data1, wb_data2, src1_sel, source1_1),
            m7(src2, xrc2, wb_data1, wb_data2, src2_sel, source2_1);

mux2n #(32) m26(source1_1, agSrc1, mx1, source1),
            m27(source2_1, agSrc1, mx2, source2);
and2$ a10(src1sel, isJMP, i_CS[49]);
mux2n #(32) m19(source1, disp32, src1sel, o_src1);

//push op disp -4/-2
wire uop0, uop1, uop2;
comp_eq2 com0(uOpNo, 2'b0, uop0);
comp_eq2 com1(uOpNo, 2'b1, uop1);
comp_eq2 com2(uOpNo, 2'b10, uop2);
or2$ o10(uop2_0, uop2, uop0);
and2$ a12(realPush, isPUSH, uop2_0);
or3$ o9(ssSel, realPush, interrupt, isCALL);
mux2n #(32) m24(32'hfffffffe, 32'hfffffffc, i_opSize[0], dispPush);
mux2n #(32) m25(tdisp32, dispPush, ssSel, disp32);

wire [31:0] s_i, sib;
mux4n #(32) m8(source2, {source2[30:0],1'b0}, {source2[29:0],2'b0}, {source2[28:0],3'b0}, i_scale, s_i);

add_32b a6(sib, , source1, s_i, 1'b0, 2'b11);

wire [31:0] o_addr2_saved, o_addr2_curr;
mux2n #(32) m9(source1, sib, i_isSIB, o_addr2_curr);
regn #(32) r1(o_addr2, clk, rst, next, o_addr2_saved);

mux2n #(32) m13(o_addr2_curr, o_addr2_saved, cst, o_addr2);

wire [15:0] temp_segRc2;
mux4n #(16) m10(segrc1, segrc1, wb_data1[15:0], wb_data2[15:0], segrc1_sel, o_segRc1),
            m16(segrc2, segrc2, wb_data1[15:0], wb_data2[15:0], segrc2_sel, temp_segRc2);
mux2n #(32) m15(temp_src2, {16'b0,temp_segRc2}, segR2Ren, o_src2);

wire [31:0] t_addr1;
add_16b a7(t_addr1[31:16], , , o_segRc1, disp32[31:16], 1'b0);
assign t_addr1[15:0] = disp32[15:0];

mux2n #(32) m21(t_addr1, i_disp, interrupt, o_addr1);

endmodule

module dependency_checker(
            rr_s1, rr_s2, rr_seg, rr_se2, re_s1, re_s2, re_x1, re_x2, re_seg, re_se2, xmmReadMask, rrEIP, rrv, rrsz1, rrsz2,
            ag_s1, ag_s2, ag_seg, agw_s1, agw_s2, agw_seg, agxmm, agv, agEIP, agsz,
            tp_s1, tp_s2, tp_seg, tpw_s1, tpw_s2, tpw_seg, tpxmm, tpv, tpsz,
            mm_s1, mm_s2, mm_seg, mmw_s1, mmw_s2, mmw_seg, mmxmm, mmv, mmsz,
            e_s1, e_s2, e_seg, ew_s1, ew_s2, ew_seg, exmm, ev, esz,
            wb_s1, wb_s2, wb_seg, wbwe_s1, wbwe_s2, wbwe_seg, wbxmm, wbv, wbsz,
            datadep, sel1, sel2, m3_2, m4_2, mx1, mx2);

    input [2:0] rr_s1, rr_s2, rr_seg, rr_se2, ag_s1, ag_s2, ag_seg, tp_s1, tp_s2, tp_seg, mm_s1, mm_s2, mm_seg, e_s1, e_s2, e_seg, wb_s1, wb_s2, wb_seg;

    input re_s1, re_s2, re_x1, re_x2, re_seg, re_se2, agxmm, tpxmm, mmxmm, exmm, wbxmm, xmmReadMask;
    input [1:0] wbwe_s1, wbwe_s2, wbwe_seg, wbsz, rrsz1, rrsz2, agsz, tpsz, mmsz, esz;
    input agw_s1, agw_s2, agw_seg, tpw_s1, tpw_s2, tpw_seg, mmw_s1, mmw_s2, mmw_seg, ew_s1, ew_s2, ew_seg, agv, tpv, mmv, ev, wbv, rrv;
    input [31:0] rrEIP, agEIP;
    output datadep, mx1, mx2;
    output [2:0] sel1, sel2;
    output [1:0] m3_2, m4_2;

    xor2$ x08(wbw_s1, wbwe_s1[0], wbwe_s1[1]),
          x09(wbw_s2, wbwe_s2[0], wbwe_s2[1]),
          x14(wbw_seg, wbwe_seg[0], wbwe_seg[1]);

    wire n_agxmm, n_tpxmm, n_mmxmm, n_exmm, n_wbxmm;
    inv1$ i1(n_agxmm, agxmm),
          i2(n_tpxmm, tpxmm),
          i3(n_mmxmm, mmxmm),
          i4(n_exmm,   exmm),
          i5(n_wbxmm, wbxmm);

    wire [2:0] rrs1, rrs2, ags1, ags2, tps1, tps2, mms1, mms2, es1, es2, wbs1, wbs2;

    wire [39:0] t, s;
    dep d01(t[01], s[01], rr_s1, re_s1, ag_s1, agw_s1, n_agxmm, agv, rrsz1, agsz),
        d02(t[02], s[02], rr_s1, re_s1, ag_s2, agw_s2, n_agxmm, agv, rrsz1, agsz),
        d03(t[03], s[03], rr_s1, re_s1, tp_s1, tpw_s1, n_tpxmm, tpv, rrsz1, tpsz),
        d04(t[04], s[04], rr_s1, re_s1, tp_s2, tpw_s2, n_tpxmm, tpv, rrsz1, tpsz),
        d05(t[05], s[05], rr_s1, re_s1, mm_s1, mmw_s1, n_mmxmm, mmv, rrsz1, mmsz),
        d06(t[06], s[06], rr_s1, re_s1, mm_s2, mmw_s2, n_mmxmm, mmv, rrsz1, mmsz),
        d07(t[07], s[07], rr_s1, re_s1,  e_s1,  ew_s1,  n_exmm,  ev, rrsz1,  esz),
        d08(t[08], s[08], rr_s1, re_s1,  e_s2,  ew_s2,  n_exmm,  ev, rrsz1,  esz),
        d09(t[09], s[09], rr_s1, re_s1, wb_s1, wbw_s1, n_wbxmm, wbv, rrsz1, wbsz),
        d00(t[00], s[00], rr_s1, re_s1, wb_s2, wbw_s2, n_wbxmm, wbv, rrsz1, wbsz),
        d11(t[11], s[11], rr_s2, re_s2, ag_s1, agw_s1, n_agxmm, agv, rrsz2, agsz),
        d12(t[12], s[12], rr_s2, re_s2, ag_s2, agw_s2, n_agxmm, agv, rrsz2, agsz),
        d13(t[13], s[13], rr_s2, re_s2, tp_s1, tpw_s1, n_tpxmm, tpv, rrsz2, tpsz),
        d14(t[14], s[14], rr_s2, re_s2, tp_s2, tpw_s2, n_tpxmm, tpv, rrsz2, tpsz),
        d15(t[15], s[15], rr_s2, re_s2, mm_s1, mmw_s1, n_mmxmm, mmv, rrsz2, mmsz),
        d16(t[16], s[16], rr_s2, re_s2, mm_s2, mmw_s2, n_mmxmm, mmv, rrsz2, mmsz),
        d17(t[17], s[17], rr_s2, re_s2,  e_s1,  ew_s1,  n_exmm,  ev, rrsz2,  esz),
        d18(t[18], s[18], rr_s2, re_s2,  e_s2,  ew_s2,  n_exmm,  ev, rrsz2,  esz),
        d19(t[19], s[19], rr_s2, re_s2, wb_s1, wbw_s1, n_wbxmm, wbv, rrsz2, wbsz),
        d10(t[10], s[10], rr_s2, re_s2, wb_s2, wbw_s2, n_wbxmm, wbv, rrsz2, wbsz),
        d21(t[21], s[21], rr_s1, re_x1, ag_s2, agw_s2, agxmm, agv, 2'h3, 2'h3),
        d22(t[22], s[22], rr_s1, re_x1, tp_s2, tpw_s2, tpxmm, tpv, 2'h3, 2'h3),
        d23(t[23], s[23], rr_s1, re_x1, mm_s2, mmw_s2, mmxmm, mmv, 2'h3, 2'h3),
        d24(t[24], s[24], rr_s1, re_x1,  e_s2,  ew_s2,  exmm,  ev, 2'h3, 2'h3),
        d25(t[25], s[25], rr_s1, re_x1, wb_s2, wbw_s2, wbxmm, wbv, 2'h3, 2'h3),
        d26(t[26], s[26], rr_s2, re_x2, ag_s2, agw_s2, agxmm, agv, 2'h3, 2'h3),
        d27(t[27], s[27], rr_s2, re_x2, tp_s2, tpw_s2, tpxmm, tpv, 2'h3, 2'h3),
        d28(t[28], s[28], rr_s2, re_x2, mm_s2, mmw_s2, mmxmm, mmv, 2'h3, 2'h3),
        d29(t[29], s[29], rr_s2, re_x2,  e_s2,  ew_s2,  exmm,  ev, 2'h3, 2'h3),
        d20(t[20], s[20], rr_s2, re_x2, wb_s2, wbw_s2, wbxmm, wbv, 2'h3, 2'h3),
        d31(t[31], s[31], rr_seg, re_seg, ag_seg, agw_seg, 1'b1, agv, 2'h2, 2'h2),
        d32(t[32], s[32], rr_seg, re_seg, tp_seg, tpw_seg, 1'b1, tpv, 2'h2, 2'h2),
        d33(t[33], s[33], rr_seg, re_seg, mm_seg, mmw_seg, 1'b1, mmv, 2'h2, 2'h2),
        d34(t[34], s[34], rr_seg, re_seg,  e_seg,  ew_seg, 1'b1,  ev, 2'h2, 2'h2),
        d35(t[35], s[35], rr_seg, re_seg, wb_seg, wbw_seg, 1'b1, wbv, 2'h2, 2'h2),
        d36(t[36], s[36], rr_se2, re_se2, ag_seg, agw_seg, 1'b1, agv, 2'h2, 2'h2),
        d37(t[37], s[37], rr_se2, re_se2, tp_seg, tpw_seg, 1'b1, tpv, 2'h2, 2'h2),
        d38(t[38], s[38], rr_se2, re_se2, mm_seg, mmw_seg, 1'b1, mmv, 2'h2, 2'h2),
        d39(t[39], s[39], rr_se2, re_se2,  e_seg,  ew_seg, 1'b1,  ev, 2'h2, 2'h2),
        d30(t[30], s[30], rr_se2, re_se2, wb_seg, wbw_seg, 1'b1, wbv, 2'h2, 2'h2);

    wire temp_datadep, tdatadep, temp1_datadep, wbxmmdep;
    zflag z1(, temp1_datadep, {t[8:1],t[18:11],t[24:21],t[29:26],t[34:31],t[39:36]});
    or2$ blah(wbxmmdep, t[20], t[25]); // optimize this part?
    or2$ blah1(temp_datadep, temp1_datadep, wbxmmdep);
    //Aggressive DataForward
    comp_eq32 comp1(rrEIP, agEIP, eq);
    or2$ o101(dep_ag, t[1], t[11]);
    //datadep = temp_datadep & !(eq&dep_ag)
    nand4$ a101(n_resolvable, eq, dep_ag, agv, rrv);
    inv1$ afi1(resolvable, n_resolvable);
    and2$ a102(tdatadep, temp_datadep, (n_resolvable));
    and2$ a103(mx1, t[1], (resolvable));
    and2$ a104(mx2, t[11], (resolvable));

    wire m1_1, m1_2, m1_3, m1_4, m2_1, m2_2, m2_3, m2_4, eq1, eq2, wb_dep1, wb_dep2;
    //WB size probs
    comp_eq2 comp2(rrsz1, wbsz, eq1);
    comp_eq2 comp3(rrsz2, wbsz, eq2);
    or2$ o102(wb_dep1, m1_4, m1_3);
    or2$ o103(wb_dep2, m2_4, m2_3);

    inv1$ inv1(ns9, s[9]),
          inv2(ns0, s[0]),
          inv3(ns10, s[10]),
          inv4(ns19, s[19]),
          inv5(neq1, eq1),
          inv6(neq2, eq2),
          inv7(nwbxmm, wbxmm);

    and2$ and0(tns9, t[9], ns9),
          and1(tns0, t[0], ns0),
          and2(tns10, t[10], ns10),
          and3(tns19, t[19], ns19),
          and4(ts9, t[9], s[9]),
          and5(ts0, t[0], s[0]),
          and6(ts10, t[10], s[10]),
          and7(ts19, t[19], s[19]),
          and8(ts25, t[25], s[25]),
          and9(ts20, t[20], s[20]),
          and10(d1ne1, neq1, wb_dep1),
          and11(d2ne2, neq2, wb_dep2),
          and12(d1s1res, nwbxmm, wbwe_s1[0]),
          and13(d1s2res, nwbxmm, wbwe_s2[0]),
          and14(d2s1res, nwbxmm, wbwe_s1[1]),
          and15(d2s2res, nwbxmm, wbwe_s2[1]);

    or4$ o106(nonforwardable, tns9, tns0, tns10, tns19);
    or4$ a105(datadep, tdatadep, d1ne1, d2ne2, nonforwardable);

    //wire [1:0] m3_2, m4_2;
    //or2$ o1(m1_2, re_x1, re_x2);
    //assign m2_2 = m1_2;
    assign m1_2 = re_x1;
    assign m2_2 = re_x2;

    nor2$ n1(m1_1, re_x1, re_x2);
    assign m2_1 = m1_1;

    inv1$ i6(nxmmReadMask, xmmReadMask);
    or3$ o2(sr1_bypass, t[9], t[25], t[0]);
    and2$ a1(t1, ts9, d1s1res);
    and2$ a2(t2, ts25, nxmmReadMask);
    and2$ a3(t3, ts0, d1s2res);
    and2$ a4(t4, ts9, d2s1res);
    and2$ a5(t5, ts25, xmmReadMask);
    and2$ a6(t6, ts0, d2s2res);
    or3$ o4(m1_3, t1, t2, t3);
    or3$ o5(m1_4, t4, t5, t6);

      or3$ o3(sr2_bypass, t[19], t[20], t[10]);
    and2$ b1(s1, ts19, d1s1res);
    and2$ b2(s2, ts20, nxmmReadMask);
    and2$ b3(s3, ts10, d1s2res);
    and2$ b4(s4, ts19, d2s1res);
    and2$ b5(s5, ts20, xmmReadMask);
    and2$ b6(s6, ts10, d2s2res);
    or3$ o6(m2_3, s1, s2, s3);
    or3$ o7(m2_4, s4, s5, s6);

    mux4n #(2) s1m(2'b0, 2'b0, 2'b01, 2'b10, {t[35],wbwe_seg[0]},m3_2);
    mux4n #(2) s2m(2'b0, 2'b0, 2'b01, 2'b10, {t[30],wbwe_seg[0]},m4_2);

    wire v1, v2;
    pencoder8_3v$ p1(1'b0, {4'b0,m1_4, m1_3, m1_2, m1_1}, sel1, v1),
                  p2(1'b0, {4'b0,m2_4, m2_3, m2_2, m2_1}, sel2, v2);


endmodule

module dep(o, fwd, read1, readv, write1, writev, type, latchv, readsz, writesz);
    input [2:0] read1, write1;
    input readv, writev, type, latchv;
    input [1:0] readsz, writesz;
    output o, fwd;

    wire [2:0] t1read1, t1write1;
    inv1$ i1(nreadsz, readsz[1]);
    inv1$ i2(nwritesz, writesz[1]);
    comp_eq2 c1(readsz, writesz, fwd);
    mux3n #(3) m1(read1, {1'b0,read1[1:0]}, read1, {fwd,nreadsz}, t1read1);
    mux3n #(3) m2(write1, {1'b0,write1[1:0]}, write1, {fwd,nwritesz}, t1write1);

  wire eq;
  wire [2:0] t1;
    xor2n #(3) x1(t1read1, t1write1, t1);
  nor3$ n1(eq, t1[0], t1[1], t1[2]);
  and2$ a1(wv, writev, latchv);
    and4$ a2(o, eq, readv, wv, type);

endmodule


module sext8(o, i);
  input [31:0] i;
  output [31:0] o;

  assign o[31:8] = {24{i[7]}};
  assign o[7:0] = i[7:0];

endmodule

module sext16(o, i);
  input [31:0] i;
  output [31:0] o;

  assign o[31:16] = {16{i[15]}};
  assign o[15:0] = i[15:0];

endmodule
