
module reg_read(
output [48:0] o_CS,        output [31:0] o_addr1,     output [31:0] o_addr2,     
output [31:0] o_src1,      output [31:0] o_src2,      output [31:0] o_nEIP,      
output [31:0] o_EIP,       output [31:0] o_bp_tgt,    output [15:0] o_segRc1,    
output [19:0] o_limit,     output [7:0]  o_imm8,      
output [1:0]  o_opSize,    output [2:0]  o_dr1,       output [2:0]  o_dr2,       
output [2:0]  o_drSeg,     output        o_bp_taken,  output        o_indir,     
output        o_Dflag,     output [3:0]  o_br_fetchID,output        o_v,         
output [2:0]  rf1, output [2:0] rf2, output [2:0] srf1, output [2:0] srf2,
output gprR1, output gprR2, output xmrR1, output xmrR2, output srfR1, output srfR2,
output xmmReadMask, output stall, output [1:0] sz,
input [48:0] i_CS,        input [31:0] i_imm,       input [31:0] i_disp,      
input [1:0]  i_immSize,   input [1:0]  i_dispSize,  input        i_isSIB,
input [1:0]  i_scale,     input        i_baseRen,   input        i_idxRen,    
input [31:0] i_nEIP,      input [31:0] i_EIP,       input [31:0] i_bp_tgt,    
input [7:0]  i_imm8,      input [1:0]  i_opSize,    input [2:0]  i_sr1,       
input [2:0]  i_sr2,       input [2:0]  i_base,      input [2:0]  i_idx,       
input [2:0]  i_segR1,     input [2:0]  i_segR2,     input        i_bp_taken,  
input        i_indir,     input        i_Dflag,     input [3:0]  i_br_fetchID,
input        i_v,         input        i_inv,
input [31:0] src1, input [31:0] src2, input [31:0] xrc1, input [31:0] xrc2,
input [15:0] segrc1, input [15:0] segrc2, input [19:0] limit, input clk, input rst, input [1:0] src1_sel, input [1:0] src2_sel, input [1:0] segrc1_sel, input [1:0] segrc2_sel, input [31:0] wb_data1, input [31:0] wb_data2, input dep, input istall);

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
    assign xmmOp      = i_CS[10:9]; //
    assign uOpNo      = i_CS[12:11]; 
    assign aluOp      = i_CS[15:13]; 
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
    assign flags_mod  = i_CS[35:30];
    assign flags_cmp  = i_CS[41:36];
    assign flags_used = i_CS[47:42];
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
    wire t_v, n_v;
    inv1$ i10(n_v, t_v);
    mux2$ m20(t_v, i_v, 1'b0, stall);
    nor2$ a11(o_v, t_v, i_inv);

// Next State Logic
parameter IDLE = 1'b0, TWO_CY = 1'b1;

wire t1, t2, t3, t4;
wire next, cst;
wire n_2cycle, cond1;
and2$ a1(t1, r1Ren, i_baseRen),
      a2(t2, r2Ren, i_idxRen);
nor2$ n1(n_2cycle, t1, t2);
xnor2$ x1(t3, n_2cycle, cst);
or3$ n2(t4, dep, istall, t3);
and2$ a3(stall, t4, i_v);
nor2$ n3(cond1, n_2cycle, dep);
//or2$ o1(sel1, cond1, dep);
nor2$ o2(sel2, istall, dep);
mux2$ m11(stI, IDLE, TWO_CY, cond1);
mux2$ m12(stT, TWO_CY, IDLE, sel2);
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
wire srren1, srren2;
assign rf1 = sr1_b;
assign rf2 = sr2_idx;
assign srf1 = i_segR1;
assign srf2 = i_segR2;
inv1$ i2(not_xmm_op1, xmmOp[1]);
and2$ a8(gprR1, not_xmm_op1, srren1);
and2$ a9(gprR2, not_xmm_op1, srren2);
assign srfR1 = segR1Ren;
assign srfR2 = segR2Ren;
and2$ a4(xmrR1, xmmOp[1], srren1);
and2$ a5(xmrR2, xmmOp[1], srren2);
assign xmmReadMask = xmmOp[0];
assign sz = opsz;
assign o_opSize = i_opSize;

wire sel;
xor2$ x2(sel, cst, n_2cycle);
mux2n #(1) m17(i_baseRen, r1Ren, sel, srren1);
mux2n #(1) m18(i_idxRen , r2Ren, sel, srren2);
mux2n #(3) m2(i_base, i_sr1, sel, sr1_b);
mux2n #(3) m3(i_idx, i_sr2, sel, sr2_idx);
mux2n #(2) m22(2'b11, i_opSize, sel, opsz);

assign o_dr2 = sr2_idx;
assign o_dr1 = sr1_b;
assign o_drSeg = i_segR2;

wire [31:0] source1, source2, disp32, i_disp_8, i_disp_16, i_imm_8, i_imm_16, temp_src2;
sext8 s1(i_disp_8, i_disp),
      s2(i_imm_8, i_imm);
sext16 s3(i_disp_16, i_disp),
       s4(i_imm_16, i_imm);
mux4n #(32) m4(32'b0, i_disp_8, i_disp_16, i_disp, i_dispSize, disp32),
            m5(source2, i_imm_8, i_imm_16, i_imm, i_immSize, temp_src2),
            m6(src1, xrc1, wb_data1, wb_data2, src1_sel, source1),
            m7(src2, xrc2, wb_data1, wb_data2, src2_sel, source2);
//and2$ a10(src1sel, isJMP, i_drSegWen);
mux2n #(32) m19(source1, disp32, isJMP, o_src1);

wire [31:0] s_i, sib;
mux4n #(32) m8(source2, {source2[30:0],1'b0}, {source2[29:0],2'b0}, {source2[28:0],3'b0}, i_scale, s_i);

add_32b a6(sib, , source1, s_i, 1'b0, 2'b11);

wire [31:0] o_addr2_saved, o_addr2_curr;
mux2n #(32) m9(source1, sib, i_isSIB, o_addr2_curr);
regn #(32) r1(o_addr2, clk, rst, next, o_addr2_saved);

mux2n #(32) m13(o_addr2_curr, o_addr2_saved, cst, o_addr2);

wire [15:0] temp_segRc2;
mux3n #(16) m10(segrc1, wb_data1[15:0], wb_data2[15:0], segrc1_sel, o_segRc1),
            m16(segrc2, wb_data1[15:0], wb_data2[15:0], segrc2_sel, temp_segRc2);
mux2n #(32) m15(temp_src2, {16'b0,temp_segRc2}, segR2Ren, o_src2);

wire [31:0] t_addr1;
add_16b a7(t_addr1[31:16], , , o_segRc1, disp32[31:16], 1'b0);
assign t_addr1[15:0] = disp32[15:0];

mux2n #(32) m21(t_addr1, i_imm, interrupt, o_addr1);

endmodule

module dependency_checker(
            rr_s1, rr_s2, rr_seg, rr_se2, re_s1, re_s2, re_x1, re_x2, re_seg, re_se2, xmmReadMask,
            ag_s1, ag_s2, ag_seg, agw_s1, agw_s2, agw_seg, agxmm, agv,
            tp_s1, tp_s2, tp_seg, tpw_s1, tpw_s2, tpw_seg, tpxmm, tpv,
            mm_s1, mm_s2, mm_seg, mmw_s1, mmw_s2, mmw_seg, mmxmm, mmv,
            e_s1, e_s2, e_seg, ew_s1, ew_s2, ew_seg, exmm, ev,
            wb_s1, wb_s2, wb_seg, wbwe_s1, wbwe_s2, wbwe_seg, wbxmm, wbv,
            datadep, sel1, sel2, m3_2, m4_2);

    input [2:0] rr_s1, rr_s2, rr_seg, rr_se2, ag_s1, ag_s2, ag_seg, tp_s1, tp_s2, tp_seg, mm_s1, mm_s2, mm_seg, e_s1, e_s2, e_seg, wb_s1, wb_s2, wb_seg;

    input re_s1, re_s2, re_x1, re_x2, re_seg, re_se2, agxmm, tpxmm, mmxmm, exmm, wbxmm, xmmReadMask;
    input [1:0] wbwe_s1, wbwe_s2, wbwe_seg;
    input agw_s1, agw_s2, agw_seg, tpw_s1, tpw_s2, tpw_seg, mmw_s1, mmw_s2, mmw_seg, ew_s1, ew_s2, ew_seg, agv, tpv, mmv, ev, wbv;

    output datadep;
    output [2:0] sel1, sel2;
    output [1:0] m3_2, m4_2;

    //wire agw_s1, agw_s2, tpw_s1, tpw_s2, mmw_s1, mmw_s2, ew_s1, ew_s2, wbw_s1, wbw_s2, agw_seg, tpw_seg, mmw_seg, ew_seg, wbw_seg;
    //xor2$ x00(agw_s1, agwe_s1[0], agwe_s1[1]),
    //      x01(agw_s2, agwe_s2[0], agwe_s2[1]),
    //      x02(tpw_s1, tpwe_s1[0], tpwe_s1[1]),
    //      x03(tpw_s2, tpwe_s2[0], tpwe_s2[1]),
    //      x04(mmw_s1, mmwe_s1[0], mmwe_s1[1]),
    //      x05(mmw_s2, mmwe_s2[0], mmwe_s2[1]),
    //      x06( ew_s1,  ewe_s1[0],  ewe_s1[1]),
    //      x07( ew_s2,  ewe_s2[0],  ewe_s2[1]),
    xor2$ x08(wbw_s1, wbwe_s1[0], wbwe_s1[1]),
          x09(wbw_s2, wbwe_s2[0], wbwe_s2[1]),
    //      x10(agw_seg, agwe_seg[0], agwe_seg[1]),
    //      x11(tpw_seg, tpwe_seg[0], tpwe_seg[1]),
    //      x12(mmw_seg, mmwe_seg[0], mmwe_seg[1]),
    //      x13( ew_seg,  ewe_seg[0],  ewe_seg[1]),
          x14(wbw_seg, wbwe_seg[0], wbwe_seg[1]);

    wire n_agxmm, n_tpxmm, n_mmxmm, n_exmm, n_wbxmm;
    inv1$ i1(n_agxmm, agxmm),
          i2(n_tpxmm, tpxmm),
          i3(n_mmxmm, mmxmm),
          i4(n_exmm,   exmm),
          i5(n_wbxmm, wbxmm);

    wire [39:0] t;
    dep d01(t[01], rr_s1, re_s1, ag_s1, agw_s1, n_agxmm, agv),
        d02(t[02], rr_s1, re_s1, ag_s2, agw_s2, n_agxmm, agv),
        d03(t[03], rr_s1, re_s1, tp_s1, tpw_s1, n_tpxmm, tpv),
        d04(t[04], rr_s1, re_s1, tp_s2, tpw_s2, n_tpxmm, tpv),
        d05(t[05], rr_s1, re_s1, mm_s1, mmw_s1, n_mmxmm, mmv),
        d06(t[06], rr_s1, re_s1, mm_s2, mmw_s2, n_mmxmm, mmv),
        d07(t[07], rr_s1, re_s1,  e_s1,  ew_s1,  n_exmm,  ev),
        d08(t[08], rr_s1, re_s1,  e_s2,  ew_s2,  n_exmm,  ev),
        d09(t[09], rr_s1, re_s1, wb_s1, wbw_s1, n_wbxmm, wbv),
        d00(t[00], rr_s1, re_s1, wb_s2, wbw_s2, n_wbxmm, wbv),
        d11(t[11], rr_s2, re_s2, ag_s1, agw_s1, n_agxmm, agv),
        d12(t[12], rr_s2, re_s2, ag_s2, agw_s2, n_agxmm, agv),
        d13(t[13], rr_s2, re_s2, tp_s1, tpw_s1, n_tpxmm, tpv),
        d14(t[14], rr_s2, re_s2, tp_s2, tpw_s2, n_tpxmm, tpv),
        d15(t[15], rr_s2, re_s2, mm_s1, mmw_s1, n_mmxmm, mmv),
        d16(t[16], rr_s2, re_s2, mm_s2, mmw_s2, n_mmxmm, mmv),
        d17(t[17], rr_s2, re_s2,  e_s1,  ew_s1,  n_exmm,  ev),
        d18(t[18], rr_s2, re_s2,  e_s2,  ew_s2,  n_exmm,  ev),
        d19(t[19], rr_s2, re_s2, wb_s1, wbw_s1, n_wbxmm, wbv),
        d10(t[10], rr_s2, re_s2, wb_s2, wbw_s2, n_wbxmm, wbv),
        d21(t[21], rr_s1, re_x1, ag_s2, agw_s2, agxmm, agv),
        d22(t[22], rr_s1, re_x1, tp_s2, tpw_s2, tpxmm, tpv),
        d23(t[23], rr_s1, re_x1, mm_s2, mmw_s2, mmxmm, mmv),
        d24(t[24], rr_s1, re_x1,  e_s2,  ew_s2,  exmm,  ev),
        d25(t[25], rr_s1, re_x1, wb_s2, wbw_s2, wbxmm, wbv),
        d26(t[26], rr_s2, re_x2, ag_s2, agw_s2, agxmm, agv),
        d27(t[27], rr_s2, re_x2, tp_s2, tpw_s2, tpxmm, tpv),
        d28(t[28], rr_s2, re_x2, mm_s2, mmw_s2, mmxmm, mmv),
        d29(t[29], rr_s2, re_x2,  e_s2,  ew_s2,  exmm,  ev),
        d20(t[20], rr_s2, re_x2, wb_s2, wbw_s2, wbxmm, wbv),
		d31(t[31], rr_seg, re_seg, ag_seg, agw_seg, 1'b1, agv),
        d32(t[32], rr_seg, re_seg, tp_seg, tpw_seg, 1'b1, tpv),
        d33(t[33], rr_seg, re_seg, mm_seg, mmw_seg, 1'b1, mmv),
        d34(t[34], rr_seg, re_seg,  e_seg,  ew_seg, 1'b1,  ev),
        d35(t[35], rr_seg, re_seg, wb_seg, wbw_seg, 1'b1, wbv),
        d36(t[36], rr_se2, re_se2, ag_seg, agw_seg, 1'b1, agv),
        d37(t[37], rr_se2, re_se2, tp_seg, tpw_seg, 1'b1, tpv),
        d38(t[38], rr_se2, re_se2, mm_seg, mmw_seg, 1'b1, mmv),
        d39(t[39], rr_se2, re_se2,  e_seg,  ew_seg, 1'b1,  ev),
        d30(t[30], rr_se2, re_se2, wb_seg, wbw_seg, 1'b1, wbv);

    zflag z1(, datadep, {t[8:1],t[18:11],t[24:21],t[29:26],t[34:31],t[39:36]});

    wire m1_1, m1_2, m1_3, m1_4, m2_1, m2_2, m2_3, m2_4;
    //wire [1:0] m3_2, m4_2;
    or2$ o1(m1_2, re_x1, re_x2);
    assign m2_2 = m1_2;

    nor2$ n1(m1_1, re_x1, re_x2);
    assign m2_1 = m1_1;

    inv1$ i6(nxmmReadMask, xmmReadMask);
    or3$ o2(sr1_bypass, t[9], t[25], t[0]);
    and2$ a1(t1, t[9], wbwe_s1[0]);
    and2$ a2(t2, t[25], nxmmReadMask);
    and2$ a3(t3, t[0], wbwe_s2[0]);
    and2$ a4(t4, t[9], wbwe_s1[1]);
    and2$ a5(t5, t[25], xmmReadMask);
    and2$ a6(t6, t[0], wbwe_s2[1]);
    or3$ o4(m1_3, t1, t2, t3);
    or3$ o5(m1_4, t4, t5, t6);

	  or3$ o3(sr2_bypass, t[19], t[20], t[10]);
    and2$ b1(s1, t[19], wbwe_s1[0]);
    and2$ b2(s2, t[20], nxmmReadMask);
    and2$ b3(s3, t[10], wbwe_s2[0]);
    and2$ b4(s4, t[19], wbwe_s1[1]);
    and2$ b5(s5, t[20], xmmReadMask);
    and2$ b6(s6, t[10], wbwe_s2[1]);
    or3$ o6(m2_3, s1, s2, s3);
    or3$ o7(m2_4, s4, s5, s6);

    mux4n #(2) s1m(2'b0, 2'b0, 2'b01, 2'b10, {t[35],wbwe_seg[0]},m3_2);
    mux4n #(2) s2m(2'b0, 2'b0, 2'b01, 2'b10, {t[30],wbwe_seg[0]},m4_2);

    wire v1, v2;
    pencoder8_3v$ p1(1'b0, {4'b0,m1_4, m1_3, m1_2, m1_1}, sel1, v1),
                  p2(1'b0, {4'b0,m2_4, m2_3, m2_2, m2_1}, sel2, v2);


endmodule

module dep(o, read1, readv, write1, writev, type, latchv);
	input [2:0] read1, write1;
	input readv, writev, type, latchv;
	output o;

  wire eq;
  wire [2:0] t1;
	xor2n #(3) x1(read1, write1, t1);
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