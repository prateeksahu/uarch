module tlb_pipe( output o_cachable,
output [50:0] o_CS,        output [14:0] o_phys_addr, output [31:0] o_src1,      
output [31:0] o_src2,      output [31:0] o_nEIP,      output [31:0] o_EIP,       
output [31:0] o_bp_tgt,    output [7:0]  o_imm8,      output [1:0]  o_opSize,   
output [2:0]  o_dr1,       output [2:0]  o_dr2,       output [2:0]  o_drSeg,     
output        o_bp_taken,  output        o_Dflag,     output [1:0]  o_reqSize,
output        o_spill,     output        o_false_of,  output [3:0]  o_br_fetchID,
output        o_v,         output        stall,       output [14:0] cache_req,   
output [31:0] addr_tlb,    output        gp,          output        o_glb_inv,     
output        wb_inv,      output        req_valid,   output        opf,
output        tlb_accessV,
input [50:0] i_CS,        input [31:0] i_virt_addr, inpUt [31:0] i_src1,      
input [31:0] i_src2,      input [31:0] i_nEIP,      input [31:0] i_EIP,       
input [31:0] i_bp_tgt,    input [15:0] i_segRc,     input [31:0] i_segRc_lim, 
input [7:0]  i_imm8,      input [2:0]  i_segR1,     input [1:0]  i_opSize,    input [2:0]  i_dr1,       
input [2:0]  i_dr2,       input [2:0]  i_drSeg,     input        i_bp_taken,  
input        i_Dflag,     input [3:0]  i_br_fetchID,input        i_v,         
input        i_stall,      input [43:0] tlbEntry,    input        npfault,      
input        clk,         input        rst,         input        i_glb_inv,
input        touch,       input        dep);

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
  assign o_src1 = i_src1;
  assign o_src2 = i_src2;
  assign o_EIP = i_EIP;
  assign o_nEIP = i_nEIP;
  assign o_bp_tgt = i_bp_tgt;
  assign o_bp_taken = i_bp_taken;
  assign o_imm8 = i_imm8;
  assign o_opSize = i_opSize;
  assign o_Dflag = i_Dflag;
  assign o_dr1 = i_dr1;
  assign o_dr2 = i_dr2;
  assign o_drSeg = i_drSeg;
  assign o_br_fetchID = i_br_fetchID;
  assign o_cachable = tlbEntry[43];

  parameter IDLE = 1'b0, STALL = 1'b1;
  
  wire agb, agb1, agb2, bga, bga1, bga2, eq1, eq2, t0, t1, t2, cst, next, c1, c2, c3, n1, n2, excp, treq_valid, tgp, t_spill, istall, no_glb_inv;
  wire [31:0] virt_addr_1;

  // Next State Logic
  or2$ nso1(treq_valid, memRen, memWen);
  and2$ afa1(vDepReq, dep, tlb_accessV);
  and2$ afa2(vIntr, i_v, interrupt);
  and2$ afa3(vDepReq, dep, tlb_accessV);
  or2$ nso2(istall, i_stall, vDepReq); //change to (memRen&i_v) for perf
  nor2$ afn2(invTlbReq_b, interrupt, i_glb_inv);
  and2$ nsa1(tlb_accessV, treq_valid, i_v);
  or2$ afo1(memReqV, tlb_accessV, vIntr);
  inv1$ afi5(nistall, istall);
  and4$ nsa3(req_valid, memReqV, no_glb_inv, nistall, invTlbReq_b);
  mag_comp4$ co2(i_virt_addr[3:0], 4'b1100, agb, bga);
  comp_eq8 co3(i_virt_addr[11:4], 8'hff, eq2);
  inv1$ i1(t0, i_opSize[0]);
  inv1$ i2(t1, istall);
  comp_eq16 co1({4'b0,i_virt_addr[11:0]}, {4'b0,12'hfff}, eq1);
  and2$ a1(c1, i_opSize[1], t0),
        a2(c2, i_opSize[1], i_opSize[0]),
        a3(c3, eq2, agb);
  nand2$ na1(n1, c1, eq1),
         na2(n2, c2, c3);
  nand2$ na3(t2, n1, n2);
  and2$ a4(t_spill, t2, tlb_accessV);
  or2$ o(o_spill, t_spill, interrupt);
  and2$ afa4(waitSt, istall, no_glb_inv);
  nor2$ afn1(stIt, istall, o_glb_inv);
  and3$ nsa2(stI, o_spill, stIt, i_v);    //TODO
  mux2$ m3(next, stI, waitSt, cst);

  // Current State Logic  
  dffn #(1) state1(next, clk, rst, cst);

  // Output Logic
  wire [31:0] virt_addr_4;
  inc_32b vap1(virt_addr_1, , {12'b0,i_virt_addr[31:12]});
  inc4_32b vap4(virt_addr_4, , i_virt_addr);
  mux4n #(32) m4(i_virt_addr, {virt_addr_1[19:0],12'b0}, i_virt_addr, virt_addr_4, {interrupt, cst}, addr_tlb);
  //TLB tlb(addr_tlb, tlbEntry, pfault);

  wire glb_inv, pfault, writegp;
  inv1$ i6(tpfault, npfault);
  and2$ a12(pfault, tpfault, tlb_accessV);
  mag_comp32 com1(addr_tlb, {i_segRc,16'b0}, agb1, bga1),
             com2(addr_tlb, i_segRc_lim, agb2, bga2);
  or2$ o1(tgp, bga1, agb2);
  wire nocheck;
  comp_eq3 com3(i_segR1, 3'h2, nocheck);
  inv1$ afi3(nocheck_b, nocheck);
  inv1$ afi4(writeAllw, tlbEntry[0]);
  and3$ a14(limitgp, tgp, nocheck_b, tlb_accessV);
  and3$ a13(writegp, memWen, writeAllw, tlb_accessV);
  or2$ a7(gp, limitgp, writegp);
  or2$ o2(excp, gp, pfault);
  and2$ a5(glb_inv, excp, i_v);
  nor2$ o3(no_glb_inv, glb_inv, i_glb_inv);
  inv1$ i10(o_glb_inv, no_glb_inv);
  //and2$ a9(opf, pfault, i_v);
  assign opf = pfault;

  wire p1, p4;
  wire [1:0] p2, p3, in4;
  nor2$ x1(p1, o_spill, cst);
  invn #(2) i3(i_virt_addr[1:0], p2);
  xor2$ x2(p4, i_virt_addr[1], i_virt_addr[0]);
  xor2$ x3(p3[1], p4, cst);
  inv1$ i4(p3[0], i_virt_addr[0]);

  mux3n #(2) m6(2'b11, p2, p3, {cst,o_spill}, in4);

  wire [1:0] t_reqSize;
  mux4n #(2) m8(2'b0, 2'b0, {1'b0,p1}, in4, i_opSize, t_reqSize);

  wire [1:0] intr_reqSize;
  //mux2n #(2) m9(2'h3, 2'h1, cst, intr_reqSize);
  mux2n #(2) m10(t_reqSize, 2'h3, interrupt, o_reqSize);

  wire [14:0] i_phys_addr;
  nor2$ no1(zero, uOpNo[0], uOpNo[1]);
  inv1$ i5(nonzero, zero);
  and2$ a8(wb_inv, glb_inv, i_v); // (&& uop!=0);
  assign i_phys_addr = {tlbEntry[5:3],addr_tlb[11:0]};
  mux2n #(15) m12(i_phys_addr, addr_tlb[14:0], interrupt, o_phys_addr);

  wire fo, fo1, fo2;
  nand3$ na4(fo1, addr_tlb[1], addr_tlb[0], i_opSize[1]);
  nand2$ na5(fo2, i_opSize[1], i_opSize[0]);
  and3$ a6  (fo, addr_tlb[2], fo1, fo2);
  mux3n #(15) m11(i_phys_addr, {i_phys_addr[14:2],2'b0}, addr_tlb[14:0], {interrupt,fo}, cache_req);
  assign o_false_of = fo;

  wire tstall;
  wire n_v ;
  xor2$ xo1(spillStall, o_spill, cst);
  nor2$ o11(tstall, spillStall, istall);
  nor2$ a11(stall, tstall, n_v);

  inv1$ i9(n_v, i_v);
  nor3$ n16(o_v, n_v, o_glb_inv, vDepReq); //??
endmodule

/*module mem_dep_beh(
  req_pa, req_sz, reqv, mem_pa, mem_sz, memv, ex_pa1, ex_sz1, ex_pa2, ex_sz2, exv, exspill, wb_pa1, wb_sz1, wb_pa2, wb_sz2, wb_pa3, wb_sz3, wb_pa4, wb_sz4, wbv1, wbspill1, wbv3, wbspill2, buf_pa1, buf_sz1, bufv1, buf_pa2, buf_sz2, bufv2, buf_pa3, buf_sz3, bufv3, buf_pa4, buf_sz4, bufv4, dep);

        input [14:0] req_pa, mem_pa, ex_pa1, ex_pa2, wb_pa1, wb_pa2, wb_pa3, wb_pa4, buf_pa1, buf_pa2, buf_pa3, buf_pa4;
        input [1:0]  req_sz, mem_sz, ex_sz1, ex_sz2, wb_sz1, wb_sz2, wb_sz3, wb_sz4, buf_sz1, buf_sz2, buf_sz3, buf_sz4;
        input        reqv,   memv,   exv,  exspill,  wbv1, wbspill1, wbv3, wbspill2, bufv1,   bufv2,   bufv3,   bufv4;
        output dep;

        wire c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11;
        wire [14:0] req_pam, mem_pam, ex_pa1m, ex_pa2m, wb_pa1m, wb_pa2m, wb_pa3m, wb_pa4m, buf_pa1m, buf_pa2m, buf_pa3m, buf_pa4m;
    

    assign req_pam = req_pa + req_sz;
    assign mem_pam = mem_pa + mem_sz;
    assign ex_pa1m = ex_pa1 + ex_sz1;
    assign ex_pa2m = ex_pa2 + ex_sz2;
    assign wb_pa1m = wb_pa1 + ((wb_sz1 & {wbspill1,wbspill1}) | (3 & {~wbspill1, ~wbspill1}));
    assign wb_pa2m = wb_pa2 + ((wb_sz2 & {wbspill1,wbspill1}) | (0 & {~wbspill1, ~wbspill1}));
    assign wb_pa3m = wb_pa3 + ((wb_sz3 & {wbspill2,wbspill2}) | (3 & {~wbspill2, ~wbspill2}));
    assign wb_pa4m = wb_pa4 + ((wb_sz4 & {wbspill2,wbspill2}) | (0 & {~wbspill2, ~wbspill2}));
    assign buf_pa1m = buf_pa1 + buf_sz1;
    assign buf_pa2m = buf_pa2 + buf_sz2;
    assign buf_pa3m = buf_pa3 + buf_sz3;
    assign buf_pa4m = buf_pa4 + buf_sz4;
    
    wire [10:0] comp1;
    assign comp1[10] = (req_pa <= mem_pam && req_pam >= mem_pa);
    assign comp1[9] = (req_pa <= ex_pa1m && req_pam >= ex_pa1);
    assign comp1[8] = (req_pa <= ex_pa2m && req_pam >= ex_pa2);
    assign comp1[7] = (req_pa <= wb_pa1m && req_pam >= wb_pa1);
    assign comp1[6] = (req_pa <= wb_pa2m && req_pam >= wb_pa2);
    assign comp1[5] = (req_pa <= wb_pa3m && req_pam >= wb_pa3);
    assign comp1[4] = (req_pa <= wb_pa4m && req_pam >= wb_pa4);
    assign comp1[3] = (req_pa <= buf_pa1m && req_pam >= buf_pa1);
    assign comp1[2] = (req_pa <= buf_pa2m && req_pam >= buf_pa2);
    assign comp1[1] = (req_pa <= buf_pa3m && req_pam >= buf_pa3);
    assign comp1[0] = (req_pa <= buf_pa4m && req_pam >= buf_pa4);
    
    wire [10:0] vld;
    assign vld = {memv, exv, exspill & exv, wbv1, wbv1 & wbspill1, wbv3, wbv3 & wbspill2, bufv1, bufv2, bufv3, bufv4};
    assign dep = |(vld & comp1);
endmodule*/

module mem_dep_beh(
        req_pa, req_sz, reqv, mem_pa, mem_sz, memv, ex_pa1, ex_sz1, ex_pa2, ex_sz2, exv, exspill, wb_pa1, wb_sz1, wb_pa2, wb_sz2, wb_pa3, wb_sz3, wb_pa4, wb_sz4, wbv1, wbspill1, wbv3, wbspill2, buf_pa1, buf_sz1, bufv1, buf_pa2, buf_sz2, bufv2, buf_pa3, buf_sz3, bufv3, buf_pa4, buf_sz4, bufv4, dep);

        input [14:0] req_pa, mem_pa, ex_pa1, ex_pa2, wb_pa1, wb_pa2, wb_pa3, wb_pa4, buf_pa1, buf_pa2, buf_pa3, buf_pa4;
        input [1:0]  req_sz, mem_sz, ex_sz1, ex_sz2, wb_sz1, wb_sz2, wb_sz3, wb_sz4, buf_sz1, buf_sz2, buf_sz3, buf_sz4;
        input        reqv,   memv,   exv,  exspill,  wbv1, wbspill1, wbv3, wbspill2, bufv1,   bufv2,   bufv3,   bufv4;
        output dep;

        wire c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11;
        wire [14:0] req_pam, mem_pam, ex_pa1m, ex_pa2m, wb_pa1m, wb_pa2m, wb_pa3m, wb_pa4m, buf_pa1m, buf_pa2m, buf_pa3m, buf_pa4m;
        wire [1:0] wb_sz1_up,wb_sz2_up,wb_sz3_up,wb_sz4_up;
		
		/*add_16b add0({c0,req_pam}, , , {1'b0,req_pa}, {14'b0,req_sz}, 1'b0),
                add1({c1,mem_pam}, , , {1'b0,mem_pa}, {14'b0,mem_sz}, 1'b0),
                add2({c2,ex_pa1m}, , , {1'b0,ex_pa1}, {14'b0,ex_sz1}, 1'b0),
                add3({c3,ex_pa2m}, , , {1'b0,ex_pa2}, {14'b0,ex_sz2}, 1'b0),
				
                add4({c4,wb_pa1m}, , , {1'b0,wb_pa1}, {14'b0,wb_sz1_up}, 1'b0),
                add5({c5,wb_pa2m}, , , {1'b0,wb_pa2}, {14'b0,wb_sz2_up}, 1'b0),
                add6({c6,wb_pa3m}, , , {1'b0,wb_pa3}, {14'b0,wb_sz3_up}, 1'b0),
                add7({c7,wb_pa4m}, , , {1'b0,wb_pa4}, {14'b0,wb_sz4_up}, 1'b0),
				
                add8({c8,buf_pa1m}, , , {1'b0,buf_pa1}, {14'b0,buf_sz1}, 1'b0),
                add9({c9,buf_pa2m}, , , {1'b0,buf_pa2}, {14'b0,buf_sz2}, 1'b0),
                add10({c10,buf_pa3m}, , , {1'b0,buf_pa3}, {14'b0,buf_sz3}, 1'b0),
                add11({c11,buf_pa4m}, , , {1'b0,buf_pa4}, {14'b0,buf_sz4}, 1'b0);*/

      add_size add0(req_pam, req_pa, req_sz),
               add1(mem_pam, mem_pa, mem_sz),
               add2(ex_pa1m, ex_pa1, ex_sz1),
               add3(ex_pa2m, ex_pa2, ex_sz2),
       
               add4(wb_pa1m, wb_pa1, wb_sz1_up),
               add5(wb_pa2m, wb_pa2, wb_sz2_up),
               add6(wb_pa3m, wb_pa3, wb_sz3_up),
               add7(wb_pa4m, wb_pa4, wb_sz4_up),
       
               add8(buf_pa1m, buf_pa1, buf_sz1),
               add9(buf_pa2m, buf_pa2, buf_sz2),
               add10(buf_pa3m, buf_pa3, buf_sz3),
               add11(buf_pa4m, buf_pa4, buf_sz4);

		mux2n #(2) mw1(2'b11,wb_sz1,wbspill1,wb_sz1_up);
		mux2n #(2) mw2(2'b0,wb_sz2,wbspill1,wb_sz2_up);
		mux2n #(2) mw3(2'b11,wb_sz3,wbspill2,wb_sz3_up);
		mux2n #(2) mw4(2'b0,wb_sz4,wbspill2,wb_sz4_up);

		wire l1n, l2n, l3n, l4n, l5n, l6n, l7n;
		
		wire [10:0] g, l, gn, ln;
        mag_comp16 comp_1({1'b0,req_pa}, {1'b0,mem_pam},gn[10],l[10]),
                   comp_2({1'b0,req_pam},  {1'b0,mem_pa},g[10],ln[10]),
				       
				   comp_3({1'b0,req_pa}, {1'b0,ex_pa1m},gn[9],l[9]),
				   comp_4({1'b0,req_pam},  {1'b0,ex_pa1},g[9],ln[9]),
				       
				   comp_5({1'b0,req_pa}, {1'b0,ex_pa2m},gn[8],l[8]),
				   comp_6({1'b0,req_pam},  {1'b0,ex_pa2},g[8],ln[8]),
				       
				   comp_7({1'b0,req_pa}, {1'b0,wb_pa1m},gn[7],l[7]),
				   comp_8({1'b0,req_pam},  {1'b0,wb_pa1},g[7],ln[7]),
				       
				   comp_9({1'b0,req_pa}, {1'b0,wb_pa2m},gn[6],l[6]),
				   comp_10({1'b0,req_pam},  {1'b0,wb_pa2},g[6],ln[6]),
				       
				   comp_11({1'b0,req_pa}, {1'b0,wb_pa3m},gn[5],l[5]),
				   comp_12({1'b0,req_pam},  {1'b0,wb_pa3},g[5],ln[5]),
				       
				   comp_13({1'b0,req_pa}, {1'b0,wb_pa4m},gn[4],l[4]),
				   comp_14({1'b0,req_pam},  {1'b0,wb_pa4},g[4],ln[4]),
				       
				   comp_15({1'b0,req_pa}, {1'b0,buf_pa1m},gn[3],l[3]),
				   comp_16({1'b0,req_pam},  {1'b0,buf_pa1},g[3],ln[3]),
				       
				   comp_17({1'b0,req_pa}, {1'b0,buf_pa2m},gn[2],l[2]),
				   comp_18({1'b0,req_pam},  {1'b0,buf_pa2},g[2],ln[2]),
				       
				   comp_19({1'b0,req_pa}, {1'b0,buf_pa3m},gn[1],l[1]),
				   comp_20({1'b0,req_pam},  {1'b0,buf_pa3},g[1],ln[1]),
				   
				   comp_21({1'b0,req_pa}, {1'b0,buf_pa4m},gn[0],l[0]),
				   comp_22({1'b0,req_pam},  {1'b0,buf_pa4},g[0],ln[0]);

			
	
		wire[10:0] s3, s4, comp1;
    nor2n #(11) nor3(gn,ln,comp1);
		
		wire exv1, wbv11, wbv21;
		and2$	an1(exv1,exspill, exv),
				an2(wbv11,wbv1, wbspill1),
				an3(wbv21, wbv3, wbspill2);
				
		wire [10:0] vld;
		assign vld = {memv, exv, exv1, wbv1, wbv11, wbv3, wbv21, bufv1, bufv2, bufv3, bufv4};
		
		wire [10:0] dep_t1;
		wire dep_1,dep_2,dep_3;
		
		nand2n #(11) nan1(vld,comp1,dep_t1);
		and4$	nan2(dep_1,dep_t1[0],dep_t1[1],dep_t1[2],dep_t1[3]),
				nan3(dep_2,dep_t1[4],dep_t1[5],dep_t1[6],dep_t1[7]),
				nan4(dep_3,dep_t1[8],dep_t1[9],dep_t1[10],1'b1);
		nand3$	nan5(dep,dep_1,dep_2,dep_3);

	
endmodule

module add_size(output [14:0] addrMaz, input [14:0] addr, input [1:0] size);

  assign addrMaz = addr + size;
  /*wire [15:0] S, val;
  inc4_16b inc(S, , {1'b0,addr});

  wire s0, s1;
  modified_full_adder mfa1(s0,p0,g0,addr[0],size[0],1'b0);
  modified_full_adder mfa2(s1,p1,g1,addr[1],size[1],g0);
  carryout carry(cout, p1, g1, g0);

  mux2n #(16) mux({1'b0,addr}, S, cout, val);

  assign addrMaz = {val[14:2],s1,s0};*/

endmodule
