

module write_back(
output [31:0] gpr_data, output [15:0] segr_data, output [63:0] xmm_data, 
output [31:0] mem_data, output [2:0] gpr_dr,     output [2:0] seg_dr,
output [2:0]  xmm_dr,   output [14:0] mem_addr,  output grpWen, 
output segWen, output xmmWen, output wrV, output [31:0] EIP, output [31:0] EFlag, output v,
output [1:0] mem_size, output [1:0] opSize, output stall, output wbR,
output o_inv,
input [52:0] i_CS,       input [31:0] i_data1,    input [31:0] i_data2,    
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
wire r1Ren, r2Ren, segR1Ren, segR2Ren, memRen, passAB, lastuop, isJMP, isCALL, isPUSH, isPOP, isEXCH, isCMPE, isSIMD, isSAT, isSHUF, isDAA, isRET;
wire [5:0] flags_mod, flags_cmp, flags_used;

  assign r1Ren      = i_CS[0];   //
  assign r2Ren      = i_CS[1];   //
  assign segR1Ren   = i_CS[2];     //
  assign segR2Ren   = i_CS[3];     //
  assign memRen     = i_CS[4]; 
  assign dr1Wen     = i_CS[6:5]; 
  assign dr2Wen     = i_CS[8:7]; 
  assign segDWen    = i_CS[10:9]; 
  assign memWen     = i_CS[12:11]; 
  assign xmmOp      = i_CS[14:13]; //
  assign uOpNo      = i_CS[16:15]; 
  assign aluOp      = i_CS[19:17]; 
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
  assign flags_mod  = i_CS[39:34];
  assign flags_cmp  = i_CS[45:40];
  assign flags_used = i_CS[51:46];
  assign interrupt  = i_CS[48];

  //assign o_CS = {i_CS[38:15],o_memWen, o_drSegWen, o_dr2Wen, o_dr1Wen,i_CS[6:0]};
  assign EIP = i_nEIP;
  assign EFlag = {25'b0,i_Dflag,i_eflags};
  //assign o_Dflag = i_Dflag;
  //assign o_drSeg = i_drSeg;
  assign v = i_v;
  assign opSize = i_opSize;

  wire t1, t2, tstall;
  wire dr1w, dr2w, tworeg, zz, ntwomem, zo, oo;
  wire [1:0] n_spill, n_memWen, cst, next, nst;

  // Next State Logic
  nor2$ n1(dr1w, dr1Wen[0], dr1Wen[1]);
  nor2$ n2(dr2w, dr2Wen[0], dr2Wen[1]);
  nor2$ n3(tworeg, dr1w, dr2w);
  invn #(2) i1(i_spill, n_spill);
  invn #(2) i2(memWen, n_memWen);
  or2$ o1(zz, tworeg, i_spill[0]);
  nand2$ n4(ntwomem, memWen[1], memWen[0]);
  nor2$ n5(zo, ntwomem, i_spill[0]);
  inv1$ i3(oo, ntwomem);
  mux4n #(2) mn1({zo,zz}, {oo,1'b0}, {i_spill[1],i_spill[1]}, IDLE, cst, nst);
  mux2n #(2) mn2(nst, cst, istall, next); 
  or3$ o5(tstall, next[1], next[0], istall);
  and2$ a10(stall, tstall, i_v);

  // Current State Logic  
  dffn #(2) state1(next, clk, rst, cst);

  // Output Logic
  //gpr write
  wire [1:0] drWen;
  mux3n #(3) m1(i_dr1, i_dr2, i_dr2, {cst[0],dr1w}, gpr_dr);
  mux3n #(2) m2(dr1Wen, dr2Wen, dr2Wen, {cst[0],dr1w}, drWen);
  or2$ o3(grpWen_t, drWen[0], drWen[1]);
  and2$ a2(grpWen, grpWen_t, i_v);
  mux2n #(32) m3(i_data1, i_data2, drWen[1], gpr_data);

  //Segr write
  or2$ o4(segWen_t, segDWen[0], segDWen[1]);
  and2$ a3(segWen, segWen_t, i_v);
  mux2n #(16) m4(i_data1[15:0], i_data2[15:0], segDWen[1], segr_data);
  assign seg_dr = i_drSeg;
  wire eq;
  comp_eq3 com(seg_dr, 3'b0, eq);
  and2$ a12(o_inv, eq, segWen);

  //xmmr write
  assign xmm_data = {i_data1,i_data2};
  assign xmm_dr = i_dr1;
  and2$ a11(xmmWen, dr2Wen[0], xmmOp[1]);

  //mem write
  wire [1:0] sp1size, sp2size, spl1size, spl2size, ret1size, ret2size;
  wire [31:0] data, st1Data, st2Data, st3Data, st4Data;
  wire [15:0] data16;
  wire uop0;
  wire [1:0] st1Sel, st2Sel, st3Sel, st4Sel;
  wire sel16;
  and2n #(2) a4({i_spill[0],i_spill[0]}, i_size1, sp1size);
  and2n #(2) a5({i_spill[1],i_spill[1]}, i_size2, sp2size);
  
  and2$ a6(spl1size[0], sp1size[0], i_opSize[0]);
  assign spl1size[1] = sp1size[1];  
  and2$ a7(spl2size[0], sp2size[0], i_opSize[0]);
  assign spl2size[1] = sp2size[1];
  
  xor2$ x1(t1, sp1size[0], sp1size[1]);
  and2$ a8(ret1size[1], t1, i_opSize[0]);
  assign ret1size[0] = sp1size[0];
  xor2$ x2(t2, sp2size[0], sp2size[1]);
  and2$ a9(ret2size[1], t1, i_opSize[0]);
  assign ret2size[0] = sp2size[0];
  
  mux2n #(32) m5(i_data2, i_data1, memWen[0], data);
  mux2n #(16) m6(16'b0, data[23:8], i_opSize[0], data16);
  mux4n #(32) 
              ma(data, {24'b0,data[7:0]}, {16'b0,data[15:0]}, {8'b0,data[23:0]}, ret1size, st1Data),
              mb({24'b0,data[15:8]}, {24'b0,data[31:24]}, {16'b0,data[31:16]}, {8'b0,data[31:8]}, spl1size, st2Data),
              mc(i_data2, {24'b0,i_data2[7:0]}, {16'b0,i_data2[15:0]}, {8'b0,i_data2[23:0]}, ret2size, st3Data),
              md({24'b0,i_data2[15:8]}, {24'b0,i_data2[31:24]}, {16'b0,i_data2[31:16]}, {8'b0,i_data2[31:8]}, spl2size, st4Data);
  mux2$ m10(sel16, 1'b0, i_opSize[1], i_opSize[0]);
  mux4n #(2) me(i_opSize, 2'b1, 2'b10, 2'b11, ret1size, st1Sel),
             mf(2'b1, 2'b1, 2'b10, 2'b11, spl1size, st2Sel),
             mg(i_opSize, 2'b1, 2'b10, 2'b11, ret2size, st3Sel),
             mh(2'b1, 2'b1, 2'b10, 2'b11, spl2size, st4Sel);
  mux4n #(32) m7(st1Data, st2Data, st3Data, st4Data, cst, mem_data);
  mux4n #(2)  m8(st1Sel, st2Sel, st3Sel, st4Sel, cst, mem_size);
  mux4n #(15) m9(i_PA1, i_PA2, i_PA3, i_PA4, cst, mem_addr);

  mux2$ m(wbV, memWen[0], memWen[1], cst[1]);
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