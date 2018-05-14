
module addr_gen(
output [48:0] o_CS,        output [31:0] o_virt_addr, output [31:0] o_src1,      
output [31:0] o_src2,      output [31:0] o_nEIP,      output [31:0] o_EIP,       
output [31:0] o_bp_tgt,    output [15:0] o_segRc,     output [31:0] o_segRc_lim, 
output [7:0]  o_imm8,      output [1:0]  o_opSize,    output [2:0]  o_dr1,       
output [2:0]  o_dr2,       output [2:0]  o_drSeg,     output        o_bp_taken,  
output        o_Dflag,     output [3:0]  o_br_fetchID,output        o_v,          
output stall,
input [48:0] i_CS,        input [31:0] i_addr1,     input [31:0] i_addr2,     
input [31:0] i_src1,      input [31:0] i_src2,      input [31:0] i_nEIP,      
input [31:0] i_EIP,       input [31:0] i_bp_tgt,    input [15:0] i_segRc1,    
input [19:0] i_limit,     input [7:0]  i_imm8,      input [1:0]  i_opSize,    
input [2:0]  i_dr1,       input [2:0]  i_dr2,       input [2:0]  i_drSeg,     
input        i_bp_taken,  input        i_indir,     input        i_Dflag,
input [3:0]  i_br_fetchID,input        i_v,         input istall
input        i_inv);

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
  assign o_src2 = i_src2;
  assign o_EIP = i_EIP;
  assign o_nEIP = i_nEIP;
  assign o_bp_tgt = i_bp_tgt;
  assign o_segRc = i_segRc1;
  assign o_bp_taken = i_bp_taken;
  assign o_imm8 = i_imm8;
  assign o_opSize = i_opSize;
  assign o_Dflag = i_Dflag;
  assign o_dr1 = i_dr1;
  assign o_dr2 = i_dr2;
  assign o_drSeg = i_drSeg;
  assign stall = istall;
  assign o_br_fetchID = i_br_fetchID;
  wire n_v;
  inv1$ i10(n_v, i_v);
  nor2$ a11(o_v, t_v, i_inv);
    
  wire [31:0] t1, t2, t3, t4, t5, t6, t7, t8, t9, lim_1, lim;
  //wire push_pop, c, b0, b1; 
  wire c1, c2;
  wire [1:0] sel;

  // virt-adder calc
  add_32b add1(t1,,i_addr1, i_addr2, 1'b0, 2'b11);
  //add_16b add2(t2[31:16],,i_src2[31:16], segRc2, 1'b0);
  //assign t2[15:0] = i_src2[15:0];
  mux2n #(32) m4(i_addr1, t1, i_indir, o_virt_addr);
  
  // esp/esi/edi +- n calculation
  inc_32b inc1(t2,,i_src1);
  inc2_32b inc2(t3,,i_src1);
  inc4_32b inc3(t4,,i_src1);
  dec_32b dec1(t5,,i_src1);
  dec2_32b dec2(t6,,i_src1);
  dec4_32b dec3(t7,,i_src1);

  mux4n #(32) m1(t2, t2, t3, t4, i_opSize, t8),
              m2(t5, t5, t6, t7, i_opSize, t9);

  inv1$ i2(n_Dflag, i_Dflag);
  and2$ a1(c1, n_Dflag, isCMPS);
  and2$ a2(c2, i_Dflag, isCMPS);
  or2$ o1(sel[0], isPOP, c1);
  or2$ o2(sel[1], isPUSH, c2);
  mux3n #(32) m3(i_src1, t8, t9, sel, o_src1);

  dec_32b dec4(lim_1,,{12'b0,i_limit});
  mux4n #(32) m7({lim_1[19:0],12'hfff}, {lim_1[19:0],12'hfff}, {lim_1[19:0],12'hffe}, {lim_1[19:0],12'hffc}, i_opSize, lim);

  add_16b add3(o_segRc_lim[31:16],,,i_segRc1,lim[31:16],1'b0); 
  assign o_segRc_lim[15:0] = lim[15:0];

endmodule





  