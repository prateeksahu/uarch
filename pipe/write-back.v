

module write_back(output cachable,
output [31:0] gpr_data, output [15:0] segr_data, output [63:0] xmm_data, 
output [31:0] mem_data, output [2:0] gpr_dr,     output [2:0] seg_dr,
output [2:0]  xmm_dr,   output [14:0] mem_addr,  output grpWen, 
output segWen, output xmmWen, output wrV, output [31:0] EIP, output [31:0] EFlag, output v,
output [1:0] mem_size, output [1:0] opSize, output stall, output wbR,
output o_inv, output memWrV1, output memWrV2,
input i_cachable,
input [54:0] i_CS,       input [31:0] i_data1,    input [31:0] i_data2,    
input [31:0] i_EIP,      input [31:0] i_nEIP,     
input [14:0] i_PA1,      input [14:0] i_PA2,      input [14:0] i_PA3,      
input [14:0] i_PA4,      input [1:0]  i_size1,    input [1:0]  i_size2,
input [5:0]  i_eflags,   input [1:0]  i_opSize,   
input [2:0]  i_dr1,      input [2:0]  i_dr2,      input [2:0]  i_drSeg,    
input [1:0]  i_spill,    input        i_Dflag,    input        i_v, 
input clk,  input rst,  input istall,  input empty);
/*memAddr, memData, wbR, i_EIP, memSize, wbV, uops_v, uops_v_eip, full, empty, mem_addr, mem_data, mem_size, wrV, istall*/
  parameter IDLE = 2'b0, TWOR = 2'b1, TWOM = 2'b10, TWOM_SP=2'b11;
  
wire [1:0] dr1Wen, dr2Wen, segDWen, memWen, xmmOp, uOpNo;
wire [2:0] aluOp;
wire r1Ren, r2Ren, segR1Ren, segR2Ren, memRen, passAB, lastuop, isJMP, isCALL, isPUSH, isPOP, isEXCH, isCMPE, isSIMD, isSAT, isSHUF, isDAA, isRET, n_v;
wire [5:0] flags_mod, flags_cmp, flags_used;

  assign r1Ren      = i_CS[0];   //
  assign r2Ren      = i_CS[1];   //
  assign segR1Ren   = i_CS[2];     //
  assign segR2Ren   = i_CS[3];     //
  assign memRen     = i_CS[4]; 
  assign dr1Wen     = i_CS[6:5];//{i_CS[5],i_CS[6]};
  assign dr2Wen     = i_CS[8:7];//{i_CS[7],i_CS[8]};
  assign segDWen    = i_CS[10:9];//{i_CS[9],i_CS[10]};
  assign memWen     = i_CS[12:11];//{i_CS[11],i_CS[12]};
  assign xmmOp      = {i_CS[13],i_CS[14]};
  assign uOpNo      = {i_CS[15],i_CS[16]};
  assign aluOp      = {i_CS[17],i_CS[18],i_CS[19]};
  assign passAB     = i_CS[20]; 
  assign lastuop    = i_CS[21]; 
  assign isJMP      = i_CS[22];    //
  assign isCALL     = i_CS[23]; 
  assign isPUSH     = i_CS[24]; 
  assign isPOP      = i_CS[25]; 
  assign isEXCH     = i_CS[26]; 
  assign isCMPE     = i_CS[27]; 
  assign isSIMD     = i_CS[28]; 
  assign isSAT      = i_CS[29]; 
  assign isSHUF     = i_CS[30]; 
  assign isDAA      = i_CS[31]; 
  assign isRET      = i_CS[32]; 
  assign isCMPS     = i_CS[33];
  assign flags_mod  = {i_CS[34],i_CS[35],i_CS[36],i_CS[37],i_CS[38],i_CS[39]};
  assign flags_cmp  = {i_CS[40],i_CS[41],i_CS[42],i_CS[43],i_CS[44],i_CS[45]};
  assign flags_used = {i_CS[46],i_CS[47],i_CS[48],i_CS[49],i_CS[50],i_CS[51]};
  assign interrupt  = i_CS[52];
  assign farJMP     = i_CS[53];
  assign popStack   = i_CS[54];
  assign cachable   = i_cachable;
  assign wbR = lastuop;
  or2$ nso1(memW_V, memWen[1], memWen[0]);
  and2$ a14(memWrV1, i_v, memW_V);
  and2$ a15(memWrV2, isSIMD, memWrV1);

  //assign o_CS = {i_CS[38:15],o_memWen, o_drSegWen, o_dr2Wen, o_dr1Wen,i_CS[6:0]};
  assign EIP = i_EIP;
  assign EFlag = {25'b0,i_Dflag,i_eflags};
  //assign o_Dflag = i_Dflag;
  //assign o_drSeg = i_drSeg;
  assign v = i_v;
  assign opSize = i_opSize;

  wire t1, t2, tstall;
  wire dr1w, dr2w, tworeg, zz, ntwomem, zo, oo;
  wire [1:0] n_spill, n_memWen, cst, next, nst, spill_v;

  // Next State Logic
  inv1$ nsi1(n_v, i_v);
  nor2$ n1(dr1w, dr1Wen[0], dr1Wen[1]);
  nor2$ n2(dr2w, dr2Wen[0], dr2Wen[1]);
  nor3$ n3(tworeg, dr1w, dr2w, n_v);
  invn #(2) i1(i_spill, n_spill);
  invn #(2) i2(memWen, n_memWen);
  and2n #(2) a16({i_v,i_v}, i_spill, spill_v);
  or2$ o1(zz, tworeg, spill_v[0]);
  nand2$ n4(ntwomem, memWen[1], memWen[0]);
  nor3$ n5(zo, ntwomem, i_spill[0], n_v);
  nor2$ i3(oo, ntwomem, n_v);
  mux4n #(2) mn1({zo,zz}, {oo,1'b0}, {i_spill[1],i_spill[1]}, IDLE, cst, nst);
  mux2n #(2) mn2(nst, cst, istall, next); 
  or3$ o5(tstall, next[1], next[0], istall);
  and2$ a10(stall, tstall, i_v);

  // Current State Logic  
  dffn #(2) state1(next, clk, rst, cst);

  // Output Logic
  //gpr write
  wire [1:0] drWen, n_xmmOp;
  mux3n #(3) m1(i_dr1, i_dr2, i_dr2, {cst[0],dr1w}, gpr_dr);
  mux3n #(2) m2(dr1Wen, dr2Wen, dr2Wen, {cst[0],dr1w}, drWen);
  or2$ o3(grpWen_t, drWen[0], drWen[1]);
  invn #(2) oi(xmmOp, n_xmmOp);
  and3$ a2(grpWen, grpWen_t, i_v, n_xmmOp[1]);
  mux2n #(32) m3(i_data1, i_data2, drWen[1], gpr_data);

  //Segr write
  or2$ o4(segWen_t, segDWen[0], segDWen[1]);
  and2$ a3(segWen, segWen_t, i_v);
  mux2n #(16) m4(i_data1[15:0], i_data2[15:0], segDWen[1], segr_data);
  assign seg_dr = i_drSeg;
  wire eq;
  comp_eq3 com(seg_dr, 3'b1, eq);
  and2$ a12(o_inv, eq, segWen);

  //xmmr write
  assign xmm_data = {i_data2,i_data1};
  assign xmm_dr = i_dr2;
  and3$ a11(xmmWen, dr2Wen[0], xmmOp[1], i_v);

  //mem write
  wire [1:0] sp1size, sp2size, spl1size, spl2size, ret1size, ret2size;
  wire [31:0] data, st1Data, st2Data, st3Data, st4Data;
  wire [15:0] data16;
  wire uop0;
  wire [1:0] st1Sel, st2Sel, st3Sel, st4Sel;
  wire sel16;
  //and2n #(2) a4({i_spill[0],i_spill[0]}, i_size1, sp1size);
  //and2n #(2) a5({i_spill[1],i_spill[1]}, i_size2, sp2size);
  
  wire [14:0] t_PA1, t_PA2, t_PA3, t_PA4;
  mux2n #(15) m41(i_PA1, i_PA3, isSIMD, t_PA1),
              m42(i_PA2, i_PA4, isSIMD, t_PA2),
              m43(i_PA3, i_PA1, isSIMD, t_PA3),
              m44(i_PA4, i_PA2, isSIMD, t_PA4);

  //and2$ a6(spl1size[0], sp1size[0], i_opSize[0]); 
  //assign spl1size[1] = sp1size[1];                
  //and2$ a7(spl2size[0], sp2size[0], i_opSize[0]); 
  //assign spl2size[1] = sp2size[1];                
  
  //xor2$ x1(t1, sp1size[0], sp1size[1]);  
  //and2$ a8(ret1size[1], t1, i_opSize[0]);
  //assign ret1size[0] = sp1size[0];       
  //xor2$ x2(t2, sp2size[0], sp2size[1]);  
  //and2$ a9(ret2size[1], t1, i_opSize[0]);
  //assign ret2size[0] = sp2size[0];       
  
  mux3n #(2) me(i_size1, 2'b11, i_size1, {i_spill[0],isSIMD}, st1Sel), 
             mg(2'b0, 2'b11, i_size1, {i_spill[1],isSIMD}, st3Sel); 
  mux2n #(2) mf(2'b0, i_size2, i_spill[0], st2Sel), 
             mh(2'b0, i_size2, i_spill[1], st4Sel); 

  wire [7:0] data116, data216;
  mux2n #(32) m5(i_data2, i_data1, memWen[0], data);
  mux2$ m10(sel16, 1'b0, i_opSize[1], i_opSize[0]);
  mux2n #(8)  m6(data[15:8], data[7:0], sel16, data116);
  mux2n #(8)  m0(i_data2[15:8], i_data2[7:0], sel16, data216);
  mux4n #(32) ma({24'b0,data[7:0]}, {16'b0,data[15:0]}, {8'b0,data[23:0]}, data, st1Sel, st1Data),                              
              mc({24'b0,i_data2[7:0]}, {16'b0,i_data2[15:0]}, {8'b0,i_data2[23:0]}, i_data2, st3Sel, st3Data);                 
  mux3n #(32) mb({24'b0,data116}, {16'b0,data[31:16]}, {8'b0,data[31:8]}, st2Sel, st2Data),             
              md({24'b0,data216}, {16'b0,i_data2[31:16]}, {8'b0,i_data2[31:8]}, st4Sel, st4Data); 
  
  mux4n #(32) m7(st1Data, st2Data, st3Data, st4Data, cst, mem_data);
  mux4n #(2)  m8(st1Sel, st2Sel, st3Sel, st4Sel, cst, mem_size);
  mux4n #(15) m9(t_PA1, t_PA2, t_PA3, t_PA4, cst, mem_addr);

  wire wrVt;
  mux2$ m(wrVt, memWen[0], memWen[1], cst[1]);
  and3$ a13(wrV, wrVt, i_v, rst);
  xor2$ x3(t2, uOpNo[0], 1'b0),
        x4(t3, uOpNo[1], 1'b0);
  nor2$ n6(uop0, t2, t3);
  //or3$ o6(wbR, uop0, lastuop, uops_v); // test this for current enquing valid uop
  //wbuffer write_buffer(memAddr, memData, wbR, i_EIP, memSize, wbV, uops_v, uops_v_eip, full, empty, mem_addr, mem_data, mem_size, wrV, istall);

endmodule

module wbuffer(inPA, inData, inV, inEIP, inSize, enq, uopsv, uopsv_eip, full, empty, outPA, outData, outSize, wrV, stall);


  input [14:0] inPA;
  input [31:0] inData, inEIP, uopsv_eip;
  input inV, enq, uopsv;
  input [1:0] inSize;
  output [14:0] outPA;
  output [31:0] outData;
  output [1:0] outSize;
  output full, empty, wrV, stall;

  assign outPA = inPA;
  assign outData = inData;
  assign outSize = inSize;
  assign wrV = inV;
  and2$ a1(stall, inV, 1'b0);

endmodule
