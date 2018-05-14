module tlb_pipe(
output [48:0] o_CS,        output [14:0] o_phys_addr, output [31:0] o_src1,      
output [31:0] o_src2,      output [31:0] o_nEIP,      output [31:0] o_EIP,       
output [31:0] o_bp_tgt,    output [7:0]  o_imm8,      output [1:0]  o_opSize,   
output [2:0]  o_dr1,       output [2:0]  o_dr2,       output [2:0]  o_drSeg,     
output        o_bp_taken,  output        o_Dflag,     output [1:0]  o_reqSize,
output        o_spill,     output        o_false_of,  output [3:0]  o_br_fetchID,
output        o_v,         output        stall,       output [14:0] cache_req,   
output [31:0] addr_tlb,    output        gp,          output        o_glb_inv,     
output        wb_inv,      output        req_valid,
input [48:0] i_CS,        input [31:0] i_virt_addr, input [31:0] i_src1,      
input [31:0] i_src2,      input [31:0] i_nEIP,      input [31:0] i_EIP,       
input [31:0] i_bp_tgt,    input [15:0] i_segRc,     input [31:0] i_segRc_lim, 
input [7:0]  i_imm8,      input [1:0]  i_opSize,    input [2:0]  i_dr1,       
input [2:0]  i_dr2,       input [2:0]  i_drSeg,     input        i_bp_taken,  
input        i_Dflag,     input [3:0]  i_br_fetchID,input        i_v,         
input        istall,      input [43:0] tlbEntry,    input        pfault,      
input        clk,         input        rst,         input        i_glb_inv);

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

  parameter IDLE = 1'b0, STALL = 1'b1;
  
  wire agb, agb1, agb2, bga, bga1, bga2, eq1, eq2, t0, t1, t2, cst, next, c1, c2, c3, n1, n2, excp, treq_valid, tgp, t_spill;
  wire [31:0] virt_addr_1;

  // Next State Logic
  or2$ nso1(treq_valid, memRen, memWen);
  and3$ nsa1(req_valid, treq_valid, i_v, i_glb_inv);
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
  and2$ a4(t_spill, t2, req_valid);
  or2$ o(o_spill, t_spill, interrupt);
  and2$ nsa2(stI, o_spill, ~istall);    //TODO
  mux2$ m3(next, stI, istall, cst);

  // Current State Logic  
  dffn #(1) state1(next, clk, rst, cst);

  // Output Logic
  wire [31:0] virt_addr_4;
  inc_32b vap1(virt_addr_1, , {12'b0,i_virt_addr[31:12]});
  inc4_32b vap4(virt_addr_4, , i_virt_addr);
  mux3n #(32) m4(i_virt_addr, {virt_addr_1[19:0],12'b0}, virt_addr_4, {interrupt, cst}, addr_tlb);
  //TLB tlb(addr_tlb, tlbEntry, pfault);

  wire glb_inv;
  mag_comp32 com1(addr_tlb, {i_segRc,16'b0}, agb1, bga1),
             com2(addr_tlb, i_segRc_lim, agb2, bga2);
  or2$ o1(tgp, bga1, agb2);
  and2$ a7(gp, tgp, req_valid);
  mux3n #(8) m5(8'b0, 8'hAA, 8'hBB, {pfault,gp}, excp_id);
  or2$ o2(excp, gp, pfault);
  and2$ a5(glb_inv, excp, i_v);
  or2$ o3(o_glb_inv, glb_inv, i_glb_inv);

  wire p1, p4;
  wire [1:0] p2, p3, in4;
  xnor2$ x1(p1, o_spill, cst);
  invn #(2) i3(i_virt_addr[1:0], p2);
  xor2$ x2(p4, i_virt_addr[1], i_virt_addr[0]);
  xor2$ x3(p3[1], p4, cst);
  inv1$ i4(p3[0], i_virt_addr[0]);

  mux3n #(2) m6(2'b11, p2, p3, {cst,o_spill}, in4);

  wire [1:0] t_reqSize;
  mux4n #(2) m8(2'b0, 2'b0, {1'b0,p1}, in4, i_opSize, t_reqSize);

  wire [1:0] intr_reqSize;
  mux2n #(2) m9(2'h3, 2'h1, cst, intr_reqSize);
  mux2n #(2) m10(t_reqSize, intr_reqSize, interrupt, intr_reqSize);

  nor2$ no1(zero, uOpNo[0], uOpNo[1]);
  inv1$ i5(nonzero, zero);
  and2$ a8(wb_inv, glb_inv, nonzero); // (&& uop!=0);
  assign o_phys_addr = {tlbEntry[5:3],addr_tlb[11:0]};

  wire fo, fo1, fo2;
  nand3$ na4(fo1, addr_tlb[1], addr_tlb[0], i_opSize[1]);
  nand2$ na5(fo2, i_opSize[1], i_opSize[0]);
  and3$ a6  (fo, addr_tlb[2], fo1, fo2);
  mux2n #(15) m9(o_phys_addr, {o_phys_addr[14:2],2'b0}, fo, cache_req);
  assign o_false_of = fo;

  wire tstall;
  or2$ o11(tstall, o_spill, istall);
  and2$ a11(stall, tstall, i_v);

  wire n_v ;
  inv1$ i3(n_v, i_v);
  nor2$ n16(o_v, n_v, o_glb_inv);
endmodule

/*module mem_dependency(
        req_pa, req_sz, reqv, mem_pa, mem_sz, memv, ex_pa1, ex_sz1, ex_pa2, ex_sz2, exv, exspill, wb_pa1, wb_sz1, wb_pa2, wb_sz2, wb_pa3, wb_sz3, wb_pa4, wb_sz4, wbv1, wbspill1, wbv3, wbspill2, buf_pa1, buf_sz1, bufv1, buf_pa2, buf_sz2, bufv2, buf_pa3, buf_sz3, bufv3, buf_pa4, buf_sz4, bufv4, dep);

        input [14:0] req_pa, mem_pa, ex_pa1, ex_pa2, wb_pa1, wb_pa2, wb_pa3, wb_pa4, buf_pa1, buf_pa2, buf_pa3, buf_pa4;
        input [1:0]  req_sz, mem_sz, ex_sz1, ex_sz2, wb_sz1, wb_sz2, wb_sz3, wb_sz4, buf_sz1, buf_sz2, buf_sz3, buf_sz3;
        input        reqv,   memv,   exv,  exspill,  wbv1, wbspill1, wbv3, wbspill2, bufv1,   bufv2,   bufv3,   bufv4;
        output dep;

        wire c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11;
        wire [14:0] req_pam, mem_pam, ex_pa1m, ex_pa2m, wb_pa1m, wb_pa2m, wb_pa3m, wb_pa4m, buf_pa1m, buf_pa2m, buf_pa3m, buf_pa4m;
        add_16b add0({c0,req_pam}, , , {1'b0,req_pa}, {14'b0,req_sz}, 1'b0),
                add1({c1,mem_pam}, , , {1'b0,mem_pa}, {14'b0,mem_sz}, 1'b0),
                add2({c2,ex_pa1m}, , , {1'b0,ex_pa1}, {14'b0,ex_sz1}, 1'b0),
                add3({c3,ex_pa2m}, , , {1'b0,ex_pa2}, {14'b0,ex_sz2}, 1'b0),
                add4({c4,wb_pa1m}, , , {1'b0,wb_pa1}, {14'b0,wb_sz1}, 1'b0),
                add5({c5,wb_pa2m}, , , {1'b0,wb_pa2}, {14'b0,wb_sz2}, 1'b0),
                add6({c6,wb_pa3m}, , , {1'b0,wb_pa3}, {14'b0,wb_sz3}, 1'b0),
                add7({c7,wb_pa4m}, , , {1'b0,wb_pa4}, {14'b0,wb_sz4}, 1'b0),
                add8({c8,buf_pa1m}, , , {1'b0,buf_pa1}, {14'b0,buf_sz1}, 1'b0),
                add9({c9,buf_pa2m}, , , {1'b0,buf_pa2}, {14'b0,buf_sz2}, 1'b0),
                add10({c10,buf_pa3m}, , , {1'b0,buf_pa3}, {14'b0,buf_sz3}, 1'b0),
                add11({c11,buf_pa4m}, , , {1'b0,buf_pa4}, {14'b0,buf_sz4}, 1'b0);

        wire g1, g2, g3, g4, g5, g6, g7;
        mag_comp16 comp1({1'b0,req_pa}, {1'b0,mem_pa1m},g1,),
                   comp1({1'b0,req_pa},  {1'b0,mem_pa1},,l1),
                   comp1({1'b0,req_pa}, {1'b0,ex_pa1m},g2,),
                   comp2({1'b0,req_pa}, {1'b0,ex_pa2m},g3,),
                   comp3({1'b0,req_pam}, {1'b0,ex_pa1},,l2),
                   comp4({1'b0,req_pam}, {1'b0,ex_pa2},,l3),
                   comp5({1'b0,req_pa}, {1'b0,wb_pa1m},g4,),
                   comp6({1'b0,req_pa}, {1'b0,wb_pa2m},g5,),
                   comp6({1'b0,req_pa}, {1'b0,wb_pa3m},g6,),
                   comp6({1'b0,req_pa}, {1'b0,wb_pa4m},g7,),
                   comp7({1'b0,req_pam}, {1'b0,wb_pa1},,l4),
                   comp8({1'b0,req_pam}, {1'b0,wb_pa2},,l5),
                   comp8({1'b0,req_pam}, {1'b0,wb_pa3},,l6),
                   comp8({1'b0,req_pam}, {1'b0,wb_pa4},,l7),
                   comp5({1'b0,req_pa},{1'b0,buf_pa1m},g8,),
                   comp6({1'b0,req_pa},{1'b0,buf_pa2m},g9,),
                   comp6({1'b0,req_pa},{1'b0,buf_pa3m},g10,),
                   comp6({1'b0,req_pa},{1'b0,buf_pa4m},g11,),
                   comp7({1'b0,req_pam},{1'b0,buf_pa1},,l8),
                   comp8({1'b0,req_pam},{1'b0,buf_pa2},,l9),
                   comp8({1'b0,req_pam},{1'b0,buf_pa3},,l10),
                   comp8({1'b0,req_pam},{1'b0,buf_pa4},,l11);
        
        wire gb1, gb2, gb3, gb4, gb5, gb6, gb7;
        inv1$ i1( nreqv,  reqv),
              i2( nmemv,  memv),
              i3(  nexv,   exv),
              i4( nwbv1,  wbv1),
              i5( nwbv3,  wbv3),
              i6(nbufv1, bufv1),
              i7(nbufv2, bufv2),
              i7(nbufv3, bufv3),
              i8(nbufv4, bufv4);
        nand2$ na1(nexv2, exv, exspill),
               na2(nwbv2, wbv1, wbspill1),
               na2(nwbv4, wbv2, wbspill2);

        wire t1, t2, t3, t4, t5, t6;
        nor3$ n1(t1, g1, l1, nmemv),
              n2(t2, g2, l2, nexv),
              n3(t3, g3, l3, nexv2),
              n4(t4, g4, l4, nwbv1),
              n5(t5, g5, l5, nwbv2),
              n6(t6, g6, l6, nwbv3),
              n7(t7, g7, l7, nwbv4),
              n8(t8, g8, l8, bufv1),
              n9(t9, g9, l9, bufv2),
             n10(t10,g10,l10, bufv3),
             n11(t11,g11,l11, bufv4);
        nor4$ n12(t12, t1, t2, t3, t4),
              n13(t13, t5, t6, t7, t8),
        nor3$ n14(t14, t9, t10, t11);
        nand3$ n15(t15, t12, t13, t14);
        and2$ a1(dep, t15, reqv);

endmodule  */