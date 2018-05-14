//FLAGS :: DF,OF,SF,ZF,AF,PF,CF 

module exec(
output [52:0] o_CS,       output [31:0] o_data1,    output [31:0] o_data2,    
output [31:0] o_EIP,      output [31:0] o_nEIP,     output [14:0] o_PA1,      
output [14:0] o_PA2,      output [14:0] o_PA3,      output [14:0] o_PA4,      
output [1:0]  o_size1,    output [1:0]  o_size2,    output [5:0]  o_eflags,   
output [1:0]  o_opSize,   
output [2:0]  o_dr1,      output [2:0]  o_dr2,      output [2:0]  o_drSeg,    
output [1:0]  o_spill,    output        o_Dflag,    output        o_v,  
output        b_tgt_v,    output        bp_correct, output        stall,
output br_taken, output [31:0] br_tgt, output mispred, output br_valid,
output o_inv;
input [48:0] i_CS,        input [14:0] i_PA1,       input [14:0] i_PA2,      
input [31:0] i_op1,       input [31:0] i_op2,       input [31:0] i_nEIP,      
input [31:0] i_EIP,       input [31:0] i_bp_tgt,    input [7:0]  i_imm8,      
input [1:0]  i_opSize,    input [2:0]  i_dr1,       input [2:0]  i_dr2,       
input [2:0]  i_drSeg,     input        i_bp_taken,  input        i_Dflag,     
input [1:0]  i_size1,     input [1:0]  i_size2,     input        i_spill,     
input [3:0]  i_br_fetchID,input        i_v,         
input        istall,      input        clk,         input        rst,         
input [15:0] currCS,      input        wb_valid,    input [2:0]  latchdr1,
input [5:0]  latchEflags, input [14:0] latchedPA1,  input [14:0] latchedPA2,
input [1:0]  latchSpill,  input [31:0] latchnEIP,   input [31:0] latchedD1,
input [1:0]  latchSpSize1,input [1:0]  latchSpSize2,input [5:0]  eflags_reg,
input        latchedDFlag,input [2:0]  latchdr2,    input        i_inv);

	parameter IDLE = 1'b0, SYNC = 1'b1;

wire [1:0] xmmOp, uOpNo;
wire [2:0] aluOp;
wire r1Ren, r2Ren, segR1Ren, segR2Ren, memRen, dr1Wen, dr2Wen, segDWen, memWen, passAB, lastuop, isJMP, isCALL, isPUSH, isPOP, isEXCH, isCMPE, isSIMD, isSAT, isSHUF, isDAA, isRET;
wire [5:0] flag_mod,  flag_cmp,  flag_used ;
wire [1:0] o_memWen, o_drSegWen, o_dr2Wen, o_dr1Wen;

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
  assign flag_mod   = i_CS[35:30];
  assign flag_cmp   = i_CS[41:36];
  assign flag_used  = i_CS[47:42];
  assign interrupt  = i_CS[48];
  assign o_CS = {i_CS[47:13], o_memWen, o_drSegWen, o_dr2Wen, o_dr1Wen, i_CS[4:0]};
  assign o_EIP = i_EIP;
  //assign o_currCS = i_currCS;
  //assign o_bp_tgt = i_bp_tgt;
  //assign o_bp_taken = i_bp_taken;
  assign o_opSize  = i_opSize;
  assign o_Dflag = i_Dflag;
  assign o_drSeg = i_drSeg;
  wire t_v, n_v;
  inv1$ i10(n_v, t_v);
  mux2$ m30(t_v, i_v, 1'b0, stall);
  nor2$ a11(o_v, t_v, i_inv);


	// Next State
	wire cmpi, pp, simd, ncmpi, npp, nsimd, stI, stS, n_v, next, cst, x, uoppp, nuoppp;
	// OR (CMPS, CMPEXCG, SIMD, PUSH, POP) = IDLE's next state
	nor2$ nsna1(ncmpi, isCMPS, isCMPE);
	inv1$ nsi1(cmpi, ncmpi);
	nor2$ nsna2(npp, isPOP, isPUSH);
	inv1$ nsi2(pp, npp);
	inv1$ nsi3(nsimd, isSIMD);
	inv1$ nsi5(nuoppp, uoppp);
	nand3$ nsna3(x, ncmpi, nuoppp, nsimd);
	and2$ nsa1(stI, x, i_v);
	// ! AND (valid in, no stall) = SYNC's next state
	inv1$ nsi4(n_v, i_v);
	or2$ nsno1(stS, n_v, istall);
	mux2$ nsm1(next, stI, stS, cst);
	//stall = (x xnor cst) and istall
	xnor2$ nsx1(t1, x, cst);
	and3$ nsa2(stall, istall, t1, i_v);

	//xor2$ nsx1(t1, i_inst_id[1], 1'b1),
	//      nsx2(t2, i_inst_id[2], 1'b0),
	//      nsx3(t3, i_inst_id[3], 1'b0);
	//nor3$ nsno1(cmpinst, t1, t2, t3);
	//or2$ nso1(sync, i_xmm_op[1], cmpinst);
	//inv1$ nsi1(done, i_last_uOp);
	//mux2$ nsm1(nst, sync, done, cst);
	//mux2$ nsm2(next, nst, cst, istall);

	// Current State
	dffn #(1) state1(next, clk, rst, cst);

	// Output 
    wire [31:0] reg1, reg2, op1_neg;
    wire [31:0] op2_bar, op2, op1;
    invn #(32) i1(reg1, op1_neg);
    mux3n #(32) m1(i_op1, op1_neg, i_nEIP, {isJMP,cmpi}, op1);

    assign op2 = i_op2;

    //ALU
    wire [1:0] opSize;
    wire [31:0] result, jmptgt;
    wire [5:0] oldflags, newflags;
    assign opSize = i_opSize;
    alu compute(op1, op2, aluOp, opSize, cmpi, oldflags, isSAT, passAB, result, newflags, jmptgt);

    //DAA
    wire [7:0] daa_result;
    wire [5:0] daaflags;
    daa dec_adj(op1[7:0], oldflags, daa_result, daaflags);

    //SHUF
    wire [31:0] shufH, shufL;
    shuffle shuf(reg1, i_op1, i_imm8, shufH, shufL);

    // Save ALU output (data1) for operations which needs to be synced over 2 cycles
    // like all cmp instruction (subtract saved data from input in next cycle)
    // push pop instructions which span over 2 cycles. saving for all push pop
    // SIMD operations. necessary for shuf, used for others too. generate whole thing
    wire save;
    or3$ o3(tsave, xmmOp[1], cmpi, pp);
    inv1$ i2(n_cst, cst);
    and3$ a4(save, tsave, n_cst, i_v);
    regn #(32) r1(result, clk, rst, save, reg1);
    // save bypassed value, op1 for pop-mem operation, cmps operation. 
    regn #(32) r2(i_op1, clk, rst, save, reg2);

    wire [31:0] tdata1, tdata2, t1data1, data1, t1data;
    assign tdata1[31:8] = result[31:8];
    mux2n #(8) m2(result[7:0], daa_result, isDAA, tdata1[7:0]);

    // non zero uop
    wire zero, nonzero, ncor, savedD1, uoppop, cmps2, cmpe2, pop2, dr1d2, uop1z, ret1, retn1, retn2, ret3, retn3, n3, saveDr1;
    nor2$ no1(zero, uOpNo[0], uOpNo[1]);
    xor2$ xo1(n3, uOpNo[0], uOpNo[1]);
    inv1$ i3(nonzero, zero);
    nor2$ n1(ncor, isCALL, isRET);
    and3$ a5(uoppp, pp, nonzero, ncor);
    or2$ o5(savedD1, uoppp, isCMPE);
    and3$ a6(uoppop, isPOP, nonzero, ncor);
    and2$ a7(cmps2, isCMPS, uOpNo[1]);
    and2$ a8(cmpe2, isCMPE, uOpNo[1]);
    and2$ a9(pop2, isPOP, uOpNo[1]);
    or3$ a10(dr1d2, pp, cmpe2, cmps2);
    inv1$ i4(uop1z, uOpNo[1]);
    and3$ a11(ret1, isRET, uop1z, uOpNo[0]);
    and2$ a12(retn1, isRET, uOpNo[1]);
    and2$ a13(retn2, isRET, uOpNo[0]);
    and3$ a14(ret3, isRET, uOpNo[1], uOpNo[0]);
    and2$ a15(retn3, isRET, n3);
    or2$ o4(saveDr1, pop2, cmpe2);

    mux3n #(32) m4(tdata1, shufL, reg2, {isCMPS,isSHUF}, t1data);
    mux2n #(32) m5(t1data, reg1, savedD1, t1data1);
    mux3n #(32) m6(i_op1, reg2, reg1, {isSIMD,pop2}, tdata2);
    mux2n #(32) m7(tdata2, shufH, isSHUF, o_data2);
    
    wire [1:0] pushSel;
    and2n #(2) a2({isCALL,isCALL}, uOpNo, pushSel);
    mux4n #(32) m9(t1data1, i_nEIP, {16'b0,currCS}, {25'b0,latchedDFlag,oldflags}, pushSel, data1);

    wire [5:0] to_eflags;
    genvar i;
	generate
		for(i=0; i<6; i=i+1) begin: mux3
			mux3$ ma(to_eflags[i],oldflags[i],newflags[i],daaflags[i],flag_mod[i],isDAA);
		end
	endgenerate
	mux3n #(6) m8(to_eflags, data1[5:0], latchEflags, {retn1,ret1}, o_eflags);

	mux2n #(6) m3(eflags_reg, latchEflags, wb_valid, oldflags);

	wire [5:0] cn, c;
	wire c6,c7,c8;

    //BP stuff
	assign br_taken = c8;
	mux2n #(32) m33(i_nEIP, jmptgt, br_taken, br_tgt);
	//assign br_eip = i_nEIP;
    comp_eq32 c1(jmptgt, i_bp_tgt, ct);
    xor2$ x6(cbp, c8, i_bp_taken);
    nand2$ a01(mispred, cbp, ct);
    assign br_valid = isJMP;
    or2$ o6(o_inv, i_inv, mispred);

	xnor2$ xn0(cn[0], flag_cmp[0], oldflags[0]),
           xn1(cn[1], flag_cmp[1], oldflags[1]),
           xn2(cn[2], flag_cmp[2], oldflags[2]),
           xn3(cn[3], flag_cmp[3], oldflags[3]),
           xn4(cn[4], flag_cmp[4], oldflags[4]),
           xn5(cn[5], flag_cmp[5], oldflags[5]);
	generate
		for(i=0; i<6; i=i+1) begin: mux4
			mux2$ mb(c[i],1'b1,cn[i],flag_used[i]);
		end
	endgenerate
    nand3$ na1(c6, c[0], c[1], c[2]),
    	   na2(c7, c[3], c[4], c[5]);
   	nor2$ na3(c8, c6, c7);

   	wire tdr1Wen, tdr2Wen, tdrSegWen, tmemWen;
   	mux2$ m11(tdr1Wen,1'b0,dr1Wen,c8),
   		  m12(tdr2Wen,1'b0,dr2Wen,c8),
   		  m13(tdrSegWen,1'b0,segDWen,c8),
   		  m14(tmemWen,1'b0,memWen,c8);

   	mux2n #(2) m15({1'b0,tdr1Wen}, {tdr1Wen,1'b0}, dr1d2, o_dr1Wen),
   	           m16({1'b0,tdr2Wen}, {tdr2Wen,1'b0}, isEXCH, o_dr2Wen),
   	           m17({1'b0,tdrSegWen}, {tdrSegWen,1'b0}, isJMP, o_drSegWen),
   	           m18({1'b0,tmemWen}, {tmemWen,memWen}, isSIMD, o_memWen);

   	wire [2:0] t_dr2;
   	mux2n #(3) m19(i_dr1, latchdr1, savedD1, o_dr1),
   	           m20(i_dr1, latchdr2, cmps2, t_dr2),
   	           m31(i_dr2, t_dr2, isCMPS, o_dr2);

   	mux2n #(15) m21(i_PA1, latchedPA1, cst, o_PA1),
   	            m22(i_PA2, latchedPA2, cst, o_PA2),
   	            m23(15'b0, i_PA1, cst, o_PA3),
   	            m24(15'b0, i_PA2, cst, o_PA4);

   	mux2n #(2) m25({1'b0,i_spill}, {latchSpill[0],i_spill}, cst, o_spill);
   	mux2n #(32) m26(data1, latchedD1, retn2, o_data1);
    mux3n #(32) m27(i_nEIP, tdata1, latchnEIP, {retn3,ret3}, o_nEIP);
    mux3n #(2) m28(opSize, i_size1, latchSpSize1, {latchSpill[0],i_spill}, o_size1);
    mux3n #(2) m29(opSize, i_size2, latchSpSize2, {latchSpill[0],i_spill}, o_size2);

endmodule


module alu (SRC1, SRC2, aluk, opSize, cin, oldflags, issat, passAB, RES, newflags, sum);

	input [31:0] SRC1, SRC2;
	input [2:0] aluk;
	input [1:0] opSize;
	input issat, cin, passAB;
	input [5:0] oldflags;

	output [31:0] RES, sum;
	output [5:0] newflags;

	wire [31:0] not1, and1, or1, pass, add, sal, sar, sat;
	wire [5:0] orflag, andflag, addflag, salflag, sarflag;

	invn #(32) invertor(SRC1, not1);

	and2n #(32) bitAnd(SRC1, SRC2, and1);
	assign andflag[5] = 1'b0;
	assign andflag[4] = and1[31];
	zflag zAnd(andflag[3], , and1);
	assign andflag[2] = oldflags[2];
	pflag pAnd(andflag[1], and1[7:0]);
	assign andflag[0] = 1'b0;

	or2n #(32) bitOr(SRC1, SRC2, or1);
	assign orflag[5] = 1'b0;
	assign orflag[4] = or1[31];
	zflag zOr(orflag[3], , or1);
	assign orflag[2] = oldflags[2];
	pflag pOr(orflag[1], or1[7:0]);
	assign orflag[0] = 1'b0;

	mux2n #(32) passmux(SRC1, SRC2 , passAB, pass);

	wire [2:0] outflag;
	add_32b adder(add, outflag, SRC1, SRC2, cin, opSize);
	assign addflag[5] = outflag[0];
	assign addflag[4] = add[31];
	zflag_adder zAdd(addflag[3], add);
	assign addflag[2] = outflag[1];
	pflag pAdd(addflag[1], add[7:0]);
	assign addflag[0] = outflag[2];
	assign sum = add;

	wire shf_amt_not_0, shf_amt_not_1;
	wire t1,t2,t3;

	nor2$ n1(t1, SRC2[4], SRC2[3]);
	nor2$ n2(t2, SRC2[2], SRC2[1]);
	inv1$ i1(t3, SRC2[0]);
	nand3$ n3(shf_amt_not_0, t1, t2, t3);
	nand3$ n4(shf_amt_not_1, t1, t2, SRC2[0]);

	wire cfSal, ofSal, te1, te2;
	mux3$ m1(te1, SRC1[7], SRC1[15], SRC1[31], opSize[0], opSize[1]);
	mux3$ m2(te2, SRC1[6], SRC1[14], SRC1[30], opSize[0], opSize[1]);
	xor2$ x1(ofSal, te1, te2);
	sal_5b shiftLeft(SRC1, SRC2[4:0], sal, cfSal);
	mux2$ m1Sal(salflag[5], oldflags[5], ofSal , shf_amt_not_1);
	assign salflag[4] = sal[31];
	zflag zSal(salflag[3], , sal);
	assign salflag[2] = oldflags[2];
	pflag pSal(salflag[1], sal[7:0]);
	mux2$ m2Sal(salflag[0], oldflags[0], cfSal , shf_amt_not_0);

	wire cfSar;
	sar_5b shiftRight(SRC1, SRC2[4:0], sar, cfSar);
	mux2$ m1Sar(sarflag[5], oldflags[5], 1'b0 , shf_amt_not_1);
	assign sarflag[4] = sar[31];
	zflag zSar(sarflag[3], , sar);
	assign sarflag[2] = oldflags[2];
	pflag pSar(sarflag[1], sar[7:0]);
	mux2$ m2Sar(sarflag[0], oldflags[0], cfSar , shf_amt_not_0);

	sat_adder saturatingAdder(sat, SRC1, SRC2, issat);

	wire [5:0] flag_and_or;
	mux2n #(6) and_or(andflag, orflag, aluk[0], flag_and_or);
	mux4n #(6) flags(flag_and_or, sarflag, addflag, salflag, aluk[2:1], newflags);

	wire [31:0] r1, r2;
	mux4n #(32) alu1(and1, or1, not1, sar, aluk[1:0], r1),
				alu2(add, sat, sal, pass, aluk[1:0], r2);
	mux2n #(32) alu3(r1, r2, aluk[2], RES);

endmodule

module daa (SRC, oldFlags, RES, newFlags);

	input [7:0] SRC;
	input [5:0] oldFlags;
	output [7:0] RES;
	output [5:0] newFlags;

	wire oCF, oAF, nCF, nAF, t1, t2;
	wire [7:0] src1, src2, src3;

	assign newFlags[5] = oldFlags[5];
	assign newFlags[4] = RES[7];
	zflag zDaa(newFlags[3], , {24'b0,RES});
	pflag pDaa(newFlags[1], RES);
	assign oCF = oldFlags[0];
	assign oAF = oldFlags[2];
	assign newFlags[0] = nAF;
	assign newFlags[2] = nCF;

	mag_comp4$ cmp1(SRC[3:0], 4'b1001, nAF,);
	or2$ o1(t1, nAF, oAF);
	mag_comp8$ cmp2(SRC, 8'h99, nCF,);
	or2$ o2(t2, nCF, oCF);

	add_8b a1(src1, , SRC, 8'h6, 1'b0),
	       a2(src2, , SRC, 8'h60, 1'b0),
	       a3(src3, , SRC, 8'h66, 1'b0);

	mux4n #(8) m1(SRC, src1, src2, src3, {t2,t1}, RES);

endmodule

module sat_adder (S, A, B, isSAT);
	input [31:0] A,B;
	output [31:0] S;
	input isSAT;

	wire [15:0] s1, s2;
	wire sat1, sat2, v1, v2, c31, c30, c16, c15, sat1t, sat2t;

	add_16b ad1(s1, c16, c15, A[15:0], B[15:0], 1'b0),
	        ad2(s2, c31, c30, A[31:16], B[31:16], 1'b0);

	xor2$ x1(sat1t, c16, c15);
	xor2$ x2(sat2t, c31, c30);
	and2$ a1(sat1, sat1t, isSAT);
	and2$ a2(sat2, sat2t, isSAT);

	inv1$ i1(v1, A[15]);
	inv1$ i2(v2, A[31]);


	mux2n #(15) m1({15{v1}}, s1[14:0], sat1, S[14:0]),
				m2({15{v2}}, s2[14:0], sat1, S[30:16]);
	mux2$ m3(S[15], A[15], s1[15], sat1),
		  m4(S[31], A[31], s2[15], sat2);

endmodule

module shuffle(input [31:0] inH, input [31:0] inL, input [7:0] imm, output [31:0] outH, output [31:0] outL);

	mux4n #(16) m1(inL[15:0], inL[31:16], inH[15:0], inH[31:16], imm[1:0], outL[15:0]),
	            m2(inL[15:0], inL[31:16], inH[15:0], inH[31:16], imm[3:2], outL[31:16]),
	            m3(inL[15:0], inL[31:16], inH[15:0], inH[31:16], imm[5:4], outH[15:0]),
	            m4(inL[15:0], inL[31:16], inH[15:0], inH[31:16], imm[7:6], outH[31:16]);

endmodule

module zflag(o, o_bar, in);
	input [31:0] in;
	output o, o_bar;

	wire [15:0] t;
	wire [5:0] u;
	wire [2:0] v;

	genvar i;
	generate
		for(i=0; i < 32; i=i+2) begin: l1
			nor2$ o1(t[i/2], in[i], in[i+1]);
		end
	endgenerate

	nand3$ n0(u[0], t[0], t[1], t[2]),
	       n1(u[1], t[3], t[4], t[5]),
	       n2(u[2], t[6], t[7], t[8]),
	       n3(u[3], t[9], t[10], t[11]);
	nand2$ n4(u[4], t[12], t[13]),
	       n5(u[5], t[14], t[15]);

	nor2$ o2(v[0], u[0], u[1]),
	      o3(v[1], u[2], u[3]),
	      o4(v[2], u[4], u[5]);
	nand3$ n6(o_bar, v[0], v[1], v[2]);
	inv1$ i1(o, o_bar);

endmodule

module pflag(o, in);
	input [7:0] in;
	output o;

	wire [3:0] v;
	wire [1:0] w;

	genvar i;
	generate
		for(i=0; i < 4; i=i+1) begin: l1
			xnor2$ x3(v[i], in[2*i], in[2*i+1]);
		end
		for(i=0; i < 2; i=i+1) begin: l2
			xnor2$ x4(w[i], v[2*i], v[2*i+1]);
		end
	endgenerate

	xnor2$ x5(o, w[0], w[1]);

endmodule

module zflag_adder(o, in);
	input [31:0] in;
	output o;

	//wire [31:0] in;

	//invn #(32) invert(i, in);

	or2$ o0(t0, in[0], in[1]);					//6.75
	or3$ o1(t1, t0, in[2], in[3]);				//9.5
	or2$ o2(t2, t1, in[4]);						//11.25
	or3$ o3(t3, t2, in[8], in[12]);				//14
	or2$ o4(t4, in[5], in[6]);					//15
	or3$ o5(t5, t3, in[7], in[16]);				//17
	or2$ o6(t6, t4, in[9]);				 		//16.75
	or3$ o7(t7, in[10], in[13], in[14]);		//17.75
	or3$ o8(t8, t6, in[11], in[15]);			//18.75
	nor3$ no1(t9, t5, in[17], in[20]);			//18.75
	nor3$ no2(t10, t7, in[18], in[24]);			//19
	nor3$ no3(t11, t8, in[19], in[28]);			//20
	nand3$ na1(t12, t9, t10, t11);				//21
	nor4$ no4(t13, t12, in[21], in[22], in[26]);
	nor4$ no5(t14, in[27], in[23], in[29], in[30]);
	nor2$ no6(t15, in[25], in[31]);
	and3$ na2(o, t13, t14, t15);

endmodule