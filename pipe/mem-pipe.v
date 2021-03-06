module mem_pipe(output o_cachable,
output [50:0] o_CS,        output [14:0] o_PA1,       output [14:0] o_PA2,      
output [31:0] o_op1,       output [31:0] o_op2,       output [31:0] o_nEIP,      
output [31:0] o_EIP,       output [31:0] o_bp_tgt,    output [7:0]  o_imm8,      
output [1:0]  o_opSize,    output [2:0]  o_dr1,       output [2:0]  o_dr2,       
output [2:0]  o_drSeg,     output        o_bp_taken,  output        o_Dflag,     
output [1:0]  o_size1,     output [1:0]  o_size2,     output        o_spill,     
output [3:0]  o_br_fetchID,output        o_v,         output        stall, 
output        o_inv,       output        memWrV,
input i_cachable,
input [50:0] i_CS,        input [14:0] data_req_addr,input [14:0] i_phys_addr, 
input [31:0] i_src1,      input [31:0] i_src2,       input [31:0] i_nEIP,       
input [31:0] i_EIP,       input [31:0] i_bp_tgt,     input [7:0]  i_imm8,       
input [1:0]  i_opSize,    input [2:0]  i_dr1,        input [2:0]  i_dr2,        
input [2:0]  i_drSeg,     input        i_bp_taken,   input        i_Dflag,      
input [1:0]  i_reqSize,   input        i_spill,      input        i_false_of,   
input [3:0]  i_br_fetchID,input        i_v,          input [31:0] dcache_data,  
input        dcache_v,    input        istall,       input        clk,          
input        rst,         input        i_inv,        input        uopInv,       
input [31:0] invUopEIP,   input [14:0] data_addr,    input        exPopStack, input   exMisPredInv, input csMisPredInv);

  parameter REQ1 = 1'b0, REQ2 = 1'b1;

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
	  assign o_cachable = i_cachable;
    assign interrupt  = i_CS[48];
    assign farJMP     = i_CS[49];
    assign popStack   = i_CS[50];
  assign o_CS = i_CS;
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
  // Valid Latch?
  wire t_v, n_v, eq, next;
  wire realInvalidate, popStackByEx;
  comp_eq32 comp1(invUopEIP, i_EIP, eq);
  and2$ na1(invalidateMemReq, eq, uopInv);
  inv1$ i10(n_v, t_v);
  mux2$ m20(t_v, i_v, 1'b0, stall);
  nor4$ a11(o_v, n_v, realInvalidate, invalidateMemReq, next);
  //nor3$ a11(o_v, n_v, i_inv, invalidateMemReq);
  assign o_spill = i_spill;
  assign o_inv = i_inv;

  inv1$ afi2(ncsMisPredInv, csMisPredInv);
  nand3$ aps(popStackByEx, exPopStack, exMisPredInv, ncsMisPredInv);
  and2$ aps1(realInvalidate, popStackByEx, i_inv);

  and2$ a12(memWrV, i_v, memWen);

  // Next State Logic
  wire dcache_v_bar, data_r, data_r_bar, treq_valid, n_req_valid, stall1, stallv, n_stallp, req_valid, stI, eq1, stR;
  comp_eq16 comp2({1'b0,data_req_addr}, {1'b0,data_addr}, eq1);
  inv1$ i1(dcache_v_bar, dcache_v);
  and2$ a0(data_r, dcache_v, eq1);
  //assign data_r = dcache_v; //BUG!!!!!!!!!
  or2$ nso1(treq_valid, memRen, memWen);
  nand2$ nsna1(n_req_valid, treq_valid, i_v);
  inv1$ nsi1(req_valid, n_req_valid);
  inv1$ i2(data_r_bar, data_r);
  nor2$ nso2(resetState, i_inv, invalidateMemReq);
  and2$ nsa1(stall1, data_r_bar, req_valid);
  and4$ nsa2(stI, i_spill, req_valid, data_r, resetState); //resetState
  nor2$ nsno1(n_stallp, stall1, istall);
  nor2$ nsi2(stall, n_stallp, invalidateMemReq);
  and2$ nsa3(stR, stallv, resetState); //resetState
  or2$ nsno2(stallv, stall, n_v);
  mux2$ m1(next, stI, stR, cst);
  //mux3$ m1(next, REQ1, REQ2, cst, i_spill, data_r_bar);
  //assign stall = data_r_bar;

  // Current State Logic  
  dffn #(1) state1(next, clk, rst, cst);

  // Output Logic
  wire save0;
  wire [31:0] dcdata, data1, data2, data3, data4, mem_data;
  wire [14:0] PA;
  wire [1:0] savesz;
  inv1$ afi1(ncst, cst);
  and3$ a1(save0, dcache_v, i_spill, ncst);
  //and3$ a1(save0, dcache_v, i_spill, clk);
  //and2$ a2(save1, save0, i_reqSize[0]);
  //and2$ a3(save2, save0, i_reqSize[1]);
  //and3$ a4(save4, save0, i_reqSize[0], i_reqSize[1]);
  //ioreg8$ reg1(save, dcdata, data1,, 1'b1, 1'b1);
  regn #(32) reg1(dcdata, clk, rst, save0, data1);
  regn #(15) reg2(i_phys_addr, clk, rst, save0, PA);
  regn #(2) reg3(i_reqSize, clk, rst, save0, savesz);

  mux2n #(15) m6(i_phys_addr, PA, cst, o_PA1);
  mux2n #(15) m7(15'b0, i_phys_addr, cst, o_PA2);
  mux2n #(2) m8(i_reqSize, savesz, cst, o_size1);
  mux2n #(2) m9(2'b0, i_reqSize, cst, o_size2);

  assign data2 = {dcache_data[7:0],data1[23:0]};
  assign data3 = {dcache_data[15:0],data1[15:0]};
  assign data4 = {dcache_data[23:0],data1[7:0]};

  wire [1:0] sel1, sel2;
  and2$ a5(sel1[0], i_false_of, i_phys_addr[0]),
        a6(sel1[1], i_false_of, i_phys_addr[1]),
        a7(sel2[0], cst, PA[0]),
        a8(sel2[1], cst, PA[1]);

  mux4n #(32) m2(dcache_data, {8'b0,dcache_data[31:8]}, {16'b0,dcache_data[31:16]},  {24'b0,dcache_data[31:24]}, sel1, dcdata);

  //mux4n #(2) m2(2'b11, 2'b11, 1'b10, i_reqSize, {cst, i_opSize[0]}, sel);
  mux4n #(32) m3(dcdata, data2, data3, data4, sel2, mem_data);

  wire nselmem, selmem, sel1m, sel2m;
  wire [31:0] norm_op1, norm_op2;
  nor3$ no1(nselmem, isPOP, isCMPS, isJMP);
  inv1$ i3(selmem, nselmem);
  and2$ a9(sel1m, nselmem, memRen);
  and2$ a10(sel2m, selmem, memRen);
  mux2n #(32) m4(i_src1, mem_data, sel1m, norm_op1);
  mux2n #(32) m5(i_src2, mem_data, sel2m, norm_op2);

  //Interrupt
  wire [31:0] interruptEIP;
  wire [15:0] interruptCS;
  //mux2n #(32) m10(dcdata,interruptEIP);
  //assign interruptEIP = data1;              
  assign interruptEIP = {dcache_data[31:16],data1[15:0]};
  //assign interruptCS  = dcache_data[15:0];  
  assign interruptCS = data1[31:16];
  mux2n #(32) m11(norm_op2, interruptEIP, interrupt, o_op2);
  mux2n #(32) m12(norm_op1, {16'b0,interruptCS}, interrupt, o_op1);

endmodule



