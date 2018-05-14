module modified_full_adder(s,p,g,a,b,cin);
	input a,b,cin;
	output s,p,g;

	wire t1;

	or2$  or1 (p,a,b);
	and2$ and1(g,a,b);
	xor2$ xor1(t1,a,b);
	xor2$ xor2(s,t1,cin);

endmodule

module carryout(cout,p,g,cin);
	input p,g,cin;
	output cout;

	wire t;

	and2$ and1(t1,p,cin);
	or2$  or1 (cout,t1,g);

endmodule

module add_1b(s,cout,a,b,cin);
	input a,b,cin;
	output s,cout;

	wire p,g;

	modified_full_adder mfa(s,p,g,a,b,cin);
	carryout carry(cout,p,g,cin);

endmodule

module lookahead_logic(pout,gout,c1,c2,c3,p0,g0,p1,g1,p2,g2,p3,g3,cin);
	input p0,g0,p1,g1,p2,g2,p3,g3,cin;
	output pout,gout,c1,c2,c3;

	wire ta,tb,tc,td,te,tf,tg,th,ti;

	and4$ and1(pout,p0,p1,p2,p3);
	and4$ and2(ta,g0,p1,p2,p3);
	and4$ and3(tb,p0,p1,p2,cin);
	and3$ and4(tc,g1,p2,p3);
	and3$ and5(td,g0,p1,p2);
	and3$ and6(te,p0,p1,cin);
	and2$ and7(tf,g2,p3);
	and2$ and8(tg,g1,p2);
	and2$ and9(th,g0,p1);
	and2$ and13(ti,p0,cin);
	or4$  or1(gout,g3,tf,tc,ta);
	or4$  or2(c3,g2,tg,td,tb);
	or3$  or3(c2,g1,th,te);
	or2$  or4(c1,g0,ti);

endmodule

module cla_4b(S,p,g,cn_1,A,B,cin);
	input [3:0] A,B;
	input cin;
	output [3:0] S;
	output p,g,cn_1;

	wire p0,p1,p2,p3,g0,g1,g2,g3,c1,c2,c3;
	assign cn_1 = c3;

	modified_full_adder mfa1(S[0],p0,g0,A[0],B[0],cin);
	modified_full_adder mfa2(S[1],p1,g1,A[1],B[1],c1);
	modified_full_adder mfa3(S[2],p2,g2,A[2],B[2],c2);
	modified_full_adder mfa4(S[3],p3,g3,A[3],B[3],c3);
	lookahead_logic la(p,g,c1,c2,c3,p0,g0,p1,g1,p2,g2,p3,g3,cin);

endmodule

module add_4b(S,cout,A,B,cin);
	input [3:0] A,B;
	input cin;
	output [3:0] S;
	output cout;

	wire p,g;

	cla_4b c1(S,p,g,,A,B,cin);
	carryout carry(cout,p,g,cin);
	
endmodule

module cla_8b(S,p,g,A,B,cin);
	input [7:0] A,B;
	input cin;
	output [7:0] S;
	output p,g;

	wire p30,p74,g30,g74,c4;

	cla_4b C1(S[3:0],p30,g30,,A[3:0],B[3:0],cin);
	cla_4b C2(S[7:4],p74,g74,,A[7:4],B[7:4],c4);
	lookahead_logic la(p,g,c4,,,p30,g30,p74,g74,1'b0,1'b0,1'b0,1'b0,cin);

endmodule

module add_8b(S,cout,A,B,cin);
	input [7:0] A,B;
	input cin;
	output [7:0] S;
	output cout;

	wire p,g;

	wire p30,p74,g30,g74,c4;

	cla_4b C1(S[3:0],p30,g30,,A[3:0],B[3:0],cin);
	cla_4b C2(S[7:4],p74,g74,,A[7:4],B[7:4],c4);
	lookahead_logic la(p,g,c4,cout,,p30,g30,p74,g74,1'b0,1'b0,1'b0,1'b0,cin);
	
endmodule

module cla_16b(S,p,g,A,B,cin,flag,size);
	input [15:0] A,B;
	input cin, size;
	output [15:0] S;
	output p,g;
	output [2:0] flag;

	wire p30,p74,p118,p1512,g30,g74,g118,g1512,c4,c8,c12,cout;
	wire is8b_add_of, is16b_add_of, eb_add_of, sb_add_of;

	assign flag[0] = c4;
	cla_4b C1(S[3:0],p30,g30,,A[3:0],B[3:0],cin);
	cla_4b C2(S[7:4],p74,g74,eb_add_of,A[7:4],B[7:4],c4);
	cla_4b C3(S[11:8],p118,g118,,A[11:8],B[11:8],c8);
	cla_4b C4(S[15:12],p1512,g1512,sb_add_of,A[15:12],B[15:12],c12);
	lookahead_logic la(p,g,c4,c8,c12,p30,g30,p74,g74,p118,g118,p1512,g1512,cin);
	carryout carry(cout,p,g,cin);

	xnor2$ x1(is8b_add_of, eb_add_of, c8);
	xnor2$ x2(is16b_add_of, sb_add_of, cout);
	mux2$ m1(flag[2], c8, cout, size),
		  m2(flag[1], is8b_add_of, is16b_add_of, size);

endmodule

module add_16b(S,cout,cout_1,A,B,cin);
	input [15:0] A,B;
	input cin;
	output [15:0] S;
	output cout, cout_1;

	wire p,g;
	wire [2:0] flag;
	assign cout_1 = flag[1];

	cla_16b c1(S,p,g,A,B,cin,flag,1'b1);
	carryout carry(cout,p,g,cin);
	
endmodule

module cla_32b(S,p,g,A,B,cin);
	input [31:0] A,B;
	input cin;
	output [31:0] S;
	output p,g;

	wire p150,p3116,g150,g3116,c16;

	cla_16b c1(S[15:0],p150,g150,A[15:0],B[15:0],cin,,);
	cla_16b c2(S[31:16],p3116,g3116,A[31:16],B[31:16],c16,,);
	lookahead_logic la(p,g,c16,,,p150,g150,p3116,g3116,1'b0,1'b0,1'b0,1'b0,cin);

endmodule

//flag : 0 - AF, 1 - OF, 2 - CF
module add_32b(S,flag,A,B,cin,opSize);
	input [31:0] A,B;
	input [1:0] opSize;
	input cin;
	output [31:0] S;
	output [2:0] flag;

	wire p,g,cout, cn_1;
	wire [2:0] f1, f2;
	wire p150,p3116,g150,g3116,c16;

	cla_16b c1(S[15:0],p150,g150,A[15:0],B[15:0],cin,f1,opSize[1]);
	cla_16b c2(S[31:16],p3116,g3116,A[31:16],B[31:16],c16,f2,opSize[1]);
	lookahead_logic la(p,g,c16,cout,,p150,g150,p3116,g3116,1'b0,1'b0,1'b0,1'b0,cin);

	comp_eq2 com(opSize, 2'h3, size3);
	mux2$ m1(cn_1, f1[1], f2[1], size3),
	      m2(cf_8_16, f1[2], c16, opSize[1]),
	      m3(flag[2], cf_8_16, cout, size3);

	assign flag[0] = f1[0];
	//assign flag[1] = cn_1;
	//xor2$ x1(flag[1], flag[2], cn_1);
	xor2$ x1(of321, A[31], B[31]);
	xor2$ x2(of322, S[31], B[31]);
	xor2$ x3(of161, A[15], B[15]);
	xor2$ x4(of162, S[15], B[15]);
	xor2$ x5(of81, A[7], B[7]);
	xor2$ x6(of82, S[7], B[7]);
	mux2n #(1) m11(of322, 1'b0, of321, of32);
	mux2n #(1) m21(of162, 1'b0, of161, of16);
	mux2n #(1) m31(of82, 1'b0, of81, of8);
	mux4n #(1) m41(1'b0, of8, of16, of32, opSize, flag[1]);




endmodule

module modified_full_adder_inc(s,a,cin);
	input a,cin;
	output s;

	wire t1,t2,t3;

	xor2$ xor1(s,a,cin);

endmodule

module modified_full_adder_inc_0(s,a);
	input a;
	output s;

	inv1$ inv1(s,a);

endmodule

module carryout_inc(cout,p,cin);
	input p,cin;
	output cout;

	and2$ and1(cout,p,cin);

endmodule

module inc_1b(s,cout,a);
	input a;
	output s,cout;

	modified_full_adder_inc_0 mfa(s,a);
	assign cout = a;

endmodule

module lookahead_logic_inc(pout,c1,c2,c3,p0,p1,p2,p3,cin);
	input p0,p1,p2,p3,cin;
	output pout,c1,c2,c3;

	and4$ and1(pout,p0,p1,p2,p3);
	and4$ and2(c3,p0,p1,p2,cin);
	and3$ and3(c2,p0,p1,cin);
	and2$ and4(c1,p0,cin);

endmodule

module lookahead_logic_inc_c0(pout,c1,c2,c3,p0,p1,p2,p3);
	input p0,p1,p2,p3;
	output pout,c1,c2,c3;

	and4$ and1(pout,p0,p1,p2,p3);
	and3$ and3(c3,p0,p1,p2);
	and2$ and6(c2,p0,p1);
	assign c1 = p0;

endmodule

module cla_4b_inc(S,p,A,cin);
	input [3:0] A;
	input cin;
	output [3:0] S;
	output p;

	wire c1,c2,c3;

	modified_full_adder_inc mfa1(S[0],A[0],cin);
	modified_full_adder_inc mfa2(S[1],A[1],c1);
	modified_full_adder_inc mfa3(S[2],A[2],c2);
	modified_full_adder_inc mfa4(S[3],A[3],c3);
	lookahead_logic_inc la(p,c1,c2,c3,A[0],A[1],A[2],A[3],cin);

endmodule

module cla_4b_inc_b0(S,p,A);
	input [3:0] A;
	output [3:0] S;
	output p;

	wire c1,c2,c3;

	modified_full_adder_inc_0 mfa1(S[0],A[0]);
	modified_full_adder_inc mfa2(S[1],A[1],c1);
	modified_full_adder_inc mfa3(S[2],A[2],c2);
	modified_full_adder_inc mfa4(S[3],A[3],c3);
	lookahead_logic_inc_c0 la(p,c1,c2,c3,A[0],A[1],A[2],A[3]);

endmodule

module inc_4b(S,cout,A);
	input [3:0] A;
	output [3:0] S;
	output cout;

	wire p;

	cla_4b_inc_b0 c1(S,p,A);
	assign cout=p;
	
endmodule

module inc_8b (S,cout,A);
	input [7:0] A;
	output [7:0] S;
	output cout;

	wire p,g;

	wire p30,p74,c4;

	cla_4b_inc_b0 C1(S[3:0],p30,A[3:0]);
	cla_4b_inc C2(S[7:4],p74,A[7:4],c4);
	lookahead_logic_inc_c0 la(p,c4,cout,,p30,p74,1'b0,1'b0);
	
endmodule

module cla_16b_inc(S,p,A,cin);
	input [15:0] A;
	input cin;
	output [15:0] S;
	output p;

	wire p30,p74,p118,p1512,c4,c8,c12;

	cla_4b_inc C1(S[3:0],p30,A[3:0],cin);
	cla_4b_inc C2(S[7:4],p74,A[7:4],c4);
	cla_4b_inc C3(S[11:8],p118,A[11:8],c8);
	cla_4b_inc C4(S[15:12],p1512,A[15:12],c12);
	lookahead_logic_inc la(p,c4,c8,c12,p30,p74,p118,p1512,cin);

endmodule

module cla_16b_inc_b0(S,p,A);
	input [15:0] A;
	output [15:0] S;
	output p;

	wire p30,p74,p118,p1512,c4,c8,c12;

	cla_4b_inc_b0 C1(S[3:0],p30,A[3:0]);
	cla_4b_inc C2(S[7:4],p74,A[7:4],c4);
	cla_4b_inc C3(S[11:8],p118,A[11:8],c8);
	cla_4b_inc C4(S[15:12],p1512,A[15:12],c12);
	lookahead_logic_inc_c0 la(p,c4,c8,c12,p30,p74,p118,p1512);

endmodule

module inc_16b(S,cout,A);
	input [15:0] A;
	output [15:0] S;
	output cout;

	wire p;

	cla_16b_inc_b0 c1(S,p,A);
	assign cout=p;
	
endmodule

module cla_32b_inc(S,p,A,cin);
	input [31:0] A;
	input cin;
	output [31:0] S;
	output p;

	wire p150,p3116,c16;

	cla_16b_inc c1(S[15:0],p150,A[15:0],cin);
	cla_16b_inc c2(S[31:16],p3116,A[31:16],c16);
	lookahead_logic_inc la(p,c16,,,p150,p3116,1'b0,1'b0,cin);

endmodule

module cla_32b_inc_b0(S,p,A);
	input [31:0] A;
	output [31:0] S;
	output p;

	wire p150,p3116,c16;

	cla_16b_inc_b0 c1(S[15:0],p150,A[15:0]);
	cla_16b_inc c2(S[31:16],p3116,A[31:16],c16);
	lookahead_logic_inc_c0 la(p,c16,,,p150,p3116,1'b0,1'b0);

endmodule

module inc_32b(S,cout,A);
	input [31:0] A;
	output [31:0] S;
	output cout;

	wire p;

	wire p150,p3116,c16;

	cla_16b_inc_b0 c1(S[15:0],p150,A[15:0]);
	cla_16b_inc c2(S[31:16],p3116,A[31:16],c16);
	lookahead_logic_inc_c0 la(p,c16,cout,,p150,p3116,1'b0,1'b0);
	
endmodule

module inc2_4b(S,cout,A);
	input [3:0] A;
	output [3:0] S;
	output cout;

	wire [3:0] partial;
	wire p;

	cla_4b_inc_b0 c1(partial,p,{1'b0,A[3:1]});
	assign cout=partial[3];
	assign S = {partial[2:0],A[0]};
	
endmodule

module inc2_8b (S,cout,A);
	input [7:0] A;
	output [7:0] S;
	output cout;

	wire p,g;
	wire [7:0] partial;

	wire p30,p74,c4;

	cla_4b_inc_b0 C1(partial[3:0],p30,A[4:1]);
	cla_4b_inc C2(partial[7:4],p74,{1'b0,A[7:5]},c4);
	lookahead_logic_inc_c0 la(p,c4,,,p30,p74,1'b0,1'b0);
	assign cout = partial[7];
	assign S = {partial[6:0],A[0]};
	
endmodule

module inc2_16b (S,cout,A);
	input [15:0] A;
	output [15:0] S;
	output cout;

	wire [15:0] partial;
	wire p;

	cla_16b_inc_b0 c1(partial,p,{1'b0,A[15:1]});
	assign cout=partial[15];
	assign S = {partial[14:0],A[0]};
	
endmodule

module inc2_32b(S,cout,A);
	input [31:0] A;
	output [31:0] S;
	output cout;

	wire p;
	wire [31:0] partial;
	wire p150,p3116,c16;

	cla_16b_inc_b0 c1(partial[15:0],p150,A[16:1]);
	cla_16b_inc c2(partial[31:16],p3116,{1'b0,A[31:17]},c16);
	lookahead_logic_inc_c0 la(p,c16,,,p150,p3116,1'b0,1'b0);
	assign cout = partial[31];
	assign S = {partial[30:0],A[0]};
	
endmodule

module inc4_4b (S,cout,A);
	input [3:0] A;
	output [3:0] S;
	output cout;

	wire [3:0] partial;
	wire p;

	cla_4b_inc_b0 c1(partial,p,{2'b0,A[3:2]});
	assign cout=partial[2];
	assign S = {partial[1:0],A[1:0]};
	
endmodule

module inc4_8b (S,cout,A);
	input [7:0] A;
	output [7:0] S;
	output cout;

	wire p,g;
	wire [7:0] partial;

	wire p30,p74,c4;

	cla_4b_inc_b0 C1(partial[3:0],p30,A[5:2]);
	cla_4b_inc C2(partial[7:4],p74,{2'b0,A[7:6]},c4);
	lookahead_logic_inc_c0 la(p,c4,,,p30,p74,1'b0,1'b0);
	assign cout = partial[6];
	assign S = {partial[5:0],A[1:0]};
	
endmodule

module inc4_16b (S,cout,A);
	input [15:0] A;
	output [15:0] S;
	output cout;

	wire [15:0] partial;
	wire p;

	cla_16b_inc_b0 c1(partial,p,{2'b0,A[15:2]});
	assign cout=partial[14];
	assign S = {partial[13:0],A[1:0]};
	
endmodule

module inc4_32b (S,cout,A);
	input [31:0] A;
	output [31:0] S;
	output cout;

	wire p;
	wire [31:0] partial;
	wire p150,p3116,c16;

	cla_16b_inc_b0 c1(partial[15:0],p150,A[17:2]);
	cla_16b_inc c2(partial[31:16],p3116,{2'b0,A[31:18]},c16);
	lookahead_logic_inc_c0 la(p,c16,,,p150,p3116,1'b0,1'b0);
	assign cout = partial[30];
	assign S = {partial[29:0],A[1:0]};
	
endmodule

////////////////////////////////////////////////////////////////////////////

module modified_full_adder_dec(s,a,cin);
	input a,cin;
	output s;

	wire t1,t2,t3;

	xnor2$ xnor1(s,a,cin);

endmodule

module modified_full_adder_dec_0(s,a);
	input a;
	output s;

	inv1$ inv1(s,a);

endmodule

module carryout_dec(cout,g,cin);
	input g,cin;
	output cout;

	or2$ or1(cout,g,cin);

endmodule

module dec_1b (s,cout,a);
	input a;
	output s,cout;

	modified_full_adder_inc_0 mfa(s,a);
	assign cout = a;

endmodule

module lookahead_logic_dec(gout,c1,c2,c3,g0,g1,g2,g3,cin);
	input g0,g1,g2,g3,cin;
	output gout,c1,c2,c3;

	or4$ or1(gout,g0,g1,g2,g3);
	or4$ or2(c3,g0,g1,g2,cin);
	or3$ or3(c2,g0,g1,cin);
	or2$ or4(c1,g0,cin);

endmodule

module lookahead_logic_dec_c0(gout,c1,c2,c3,g0,g1,g2,g3);
	input g0,g1,g2,g3;
	output gout,c1,c2,c3;

	or4$ or1(gout,g0,g1,g2,g3);
	or3$ or3(c3,g0,g1,g2);
	or2$ or6(c2,g0,g1);
	assign c1 = g0;

endmodule

module cla_4b_dec(S,g,A,cin);
	input [3:0] A;
	input cin;
	output [3:0] S;
	output g;

	wire c1,c2,c3;

	modified_full_adder_dec mfa1(S[0],A[0],cin);
	modified_full_adder_dec mfa2(S[1],A[1],c1);
	modified_full_adder_dec mfa3(S[2],A[2],c2);
	modified_full_adder_dec mfa4(S[3],A[3],c3);
	lookahead_logic_dec la(g,c1,c2,c3,A[0],A[1],A[2],A[3],cin);

endmodule

module cla_4b_dec_b0(S,g,A);
	input [3:0] A;
	output [3:0] S;
	output g;

	wire c1,c2,c3;

	modified_full_adder_dec_0 mfa1(S[0],A[0]);
	modified_full_adder_dec mfa2(S[1],A[1],c1);
	modified_full_adder_dec mfa3(S[2],A[2],c2);
	modified_full_adder_dec mfa4(S[3],A[3],c3);
	lookahead_logic_dec_c0 la(g,c1,c2,c3,A[0],A[1],A[2],A[3]);

endmodule

module dec_4b (S,cout,A);
	input [3:0] A;
	output [3:0] S;
	output cout;

	wire g;

	cla_4b_dec_b0 c1(S,g,A);
	assign cout=g;
	
endmodule

module dec_8b (S,cout,A);
	input [7:0] A;
	output [7:0] S;
	output cout;

	wire g;

	wire g30,g74,c4;

	cla_4b_dec_b0 C1(S[3:0],g30,A[3:0]);
	cla_4b_dec C2(S[7:4],g74,A[7:4],c4);
	lookahead_logic_dec_c0 la(g,c4,cout,,g30,g74,1'b0,1'b0);
	
endmodule

module cla_16b_dec(S,g,A,cin);
	input [15:0] A;
	input cin;
	output [15:0] S;
	output g;

	wire g30,g74,g118,g1512,c4,c8,c12;

	cla_4b_dec C1(S[3:0],g30,A[3:0],cin);
	cla_4b_dec C2(S[7:4],g74,A[7:4],c4);
	cla_4b_dec C3(S[11:8],g118,A[11:8],c8);
	cla_4b_dec C4(S[15:12],g1512,A[15:12],c12);
	lookahead_logic_dec la(g,c4,c8,c12,g30,g74,g118,g1512,cin);

endmodule

module cla_16b_dec_b0(S,g,A);
	input [15:0] A;
	output [15:0] S;
	output g;

	wire g30,g74,g118,g1512,c4,c8,c12;

	cla_4b_dec_b0 C1(S[3:0],g30,A[3:0]);
	cla_4b_dec C2(S[7:4],g74,A[7:4],c4);
	cla_4b_dec C3(S[11:8],g118,A[11:8],c8);
	cla_4b_dec C4(S[15:12],g1512,A[15:12],c12);
	lookahead_logic_dec_c0 la(g,c4,c8,c12,g30,g74,g118,g1512);

endmodule

module dec_16b (S,cout,A);
	input [15:0] A;
	output [15:0] S;
	output cout;

	wire g;

	cla_16b_dec_b0 c1(S,g,A);
	assign cout=g;
	
endmodule

module cla_32b_dec(S,g,A,cin);
	input [31:0] A;
	input cin;
	output [31:0] S;
	output g;

	wire g150,g3116,c16;

	cla_16b_dec c1(S[15:0],g150,A[15:0],cin);
	cla_16b_dec c2(S[31:16],g3116,A[31:16],c16);
	lookahead_logic_dec la(g,c16,,,g150,g3116,1'b0,1'b0,cin);

endmodule

module cla_32b_dec_b0(S,g,A);
	input [31:0] A;
	output [31:0] S;
	output g;

	wire g150,g3116,c16;

	cla_16b_dec_b0 c1(S[15:0],g150,A[15:0]);
	cla_16b_dec c2(S[31:16],g3116,A[31:16],c16);
	lookahead_logic_dec_c0 la(g,c16,,,g150,g3116,1'b0,1'b0);

endmodule

module dec_32b (S,cout,A);
	input [31:0] A;
	output [31:0] S;
	output cout;

	wire g;

	wire g150,g3116,c16;

	cla_16b_dec_b0 c1(S[15:0],g150,A[15:0]);
	cla_16b_dec c2(S[31:16],g3116,A[31:16],c16);
	lookahead_logic_dec_c0 la(g,c16,cout,,g150,g3116,1'b0,1'b0);
	
endmodule

module dec2_4b (S,cout,A);
	input [3:0] A;
	output [3:0] S;
	output cout;

	wire [3:0] partial;
	wire g;

	cla_4b_dec_b0 c1(partial,g,{1'b0,A[3:1]});
	assign cout=partial[3];
	assign S = {partial[2:0],A[0]};
	
endmodule

module dec2_8b (S,cout,A);
	input [7:0] A;
	output [7:0] S;
	output cout;

	wire g;
	wire [7:0] partial;

	wire g30,g74,c4;

	cla_4b_dec_b0 C1(partial[3:0],g30,A[4:1]);
	cla_4b_dec C2(partial[7:4],g74,{1'b0,A[7:5]},c4);
	lookahead_logic_dec_c0 la(g,c4,,,g30,g74,1'b0,1'b0);
	assign cout = partial[7];
	assign S = {partial[6:0],A[0]};
	
endmodule

module dec2_16b (S,cout,A);
	input [15:0] A;
	output [15:0] S;
	output cout;

	wire [15:0] partial;
	wire g;

	cla_16b_dec_b0 c1(partial,g,{1'b0,A[15:1]});
	assign cout=partial[15];
	assign S = {partial[14:0],A[0]};
	
endmodule

module dec2_32b (S,cout,A);
	input [31:0] A;
	output [31:0] S;
	output cout;

	wire g;
	wire [31:0] partial;
	wire g150,g3116,c16;

	cla_16b_dec_b0 c1(partial[15:0],g150,A[16:1]);
	cla_16b_dec c2(partial[31:16],g3116,{1'b0,A[31:17]},c16);
	lookahead_logic_dec_c0 la(g,c16,,,g150,g3116,1'b0,1'b0);
	assign cout = partial[31];
	assign S = {partial[30:0],A[0]};
	
endmodule

module dec4_4b (S,cout,A);
	input [3:0] A;
	output [3:0] S;
	output cout;

	wire [3:0] partial;
	wire g;

	cla_4b_dec_b0 c1(partial,g,{2'b0,A[3:2]});
	assign cout=partial[2];
	assign S = {partial[1:0],A[1:0]};
	
endmodule

module dec4_8b (S,cout,A);
	input [7:0] A;
	output [7:0] S;
	output cout;

	wire g;
	wire [7:0] partial;

	wire g30,g74,c4;

	cla_4b_dec_b0 C1(partial[3:0],g30,A[5:2]);
	cla_4b_dec C2(partial[7:4],g74,{2'b0,A[7:6]},c4);
	lookahead_logic_inc_c0 la(g,c4,,,g30,g74,1'b0,1'b0);
	assign cout = partial[6];
	assign S = {partial[5:0],A[1:0]};
	
endmodule

module dec4_16b (S,cout,A);
	input [15:0] A;
	output [15:0] S;
	output cout;

	wire [15:0] partial;
	wire g;

	cla_16b_dec_b0 c1(partial,g,{2'b0,A[15:2]});
	assign cout=partial[14];
	assign S = {partial[13:0],A[1:0]};
	
endmodule

module dec4_32b (S,cout,A);
	input [31:0] A;
	output [31:0] S;
	output cout;

	wire g;
	wire [31:0] partial;
	wire p150,p3116,c16;

	cla_16b_dec_b0 c1(partial[15:0],g150,A[17:2]);
	cla_16b_dec c2(partial[31:16],g3116,{2'b0,A[31:18]},c16);
	lookahead_logic_dec_c0 la(g,c16,,,g150,g3116,1'b0,1'b0);
	assign cout = partial[30];
	assign S = {partial[29:0],A[1:0]};
	
endmodule