//Also contains instruction specific logic that need not be added to the control store
module	control_store
	(
	input	[7:0]	opcode1,
	input	[7:0]	opcode2,
	input	[0:0]	has_op2, 
	input	[2:0]	mod_ext,
	input	[1:0]	mod,
	
	input	[7:0]	uop_ptr,
	
	output	[127:0]	control_bits,
	output	[0:0]	op_br,
	output	[0:0]	op_fptr,
	output	[0:0]	op_fptr_s,
	output	[0:0]	novr_r1Ren_uop0,
	output	[0:0]	novr_r1Ren_uop1,
	output	[0:0]	op_jmp_reg,
	output	[0:0]	op_movq_reg,
	output	[0:0]	op_pop_reg,
	output	[0:0]	op_push_reg
	);
	
	//Op comparators
	wire	[0:0]	mod_ext_0;
	wire	[0:0]	mod_ext_1;
	wire	[0:0]	mod_ext_2;
	wire	[0:0]	mod_ext_4;
	wire	[0:0]	mod_ext_6;
	wire	[0:0]	mod_ext_7;

	wire	[0:0]	op1_04;
	wire	[0:0]	op1_05;
	wire	[0:0]	op1_80;
	wire	[0:0]	op1_81;
	wire	[0:0]	op1_83;
	wire	[0:0]	op1_00;
	wire	[0:0]	op1_01;
	wire	[0:0]	op1_02;
	wire	[0:0]	op1_03;
	wire	[0:0]	op1_24;
	wire	[0:0]	op1_25;
	wire	[0:0]	op1_20;
	wire	[0:0]	op1_21;
	wire	[0:0]	op1_22;
	wire	[0:0]	op1_23;
	wire	[0:0]	op1_E8;
	wire	[0:0]	op1_FF;
	wire	[0:0]	op1_9A;
	wire	[0:0]	op1_FC;
	wire	[0:0]	op2_42;
	wire	[0:0]	op2_B0;
	wire	[0:0]	op2_B1;
	wire	[0:0]	op1_27;
	wire	[0:0]	op1_F4;
	wire	[0:0]	op1_FE;
	wire	[0:0]	op1_40;
	wire	[0:0]	op1_CF;
	wire	[0:0]	op1_77;
	wire	[0:0]	op1_75;
	wire	[0:0]	op2_87;
	wire	[0:0]	op2_85;
	wire	[0:0]	op1_EB;
	wire	[0:0]	op1_E9;
	wire	[0:0]	op1_EA;
	wire	[0:0]	op1_88;
	wire	[0:0]	op1_89;
	wire	[0:0]	op1_8A;
	wire	[0:0]	op1_8B;
	wire	[0:0]	op1_8C;
	wire	[0:0]	op1_8E;
	wire	[0:0]	op1_B0;
	wire	[0:0]	op1_B8;
	wire	[0:0]	op1_C6;
	wire	[0:0]	op1_C7;
	wire	[0:0]	op2_6F;
	wire	[0:0]	op2_7F;
	wire	[0:0]	op1_A6;
	wire	[0:0]	op1_A7;
	wire	[0:0]	op1_F6;
	wire	[0:0]	op1_F7;
	wire	[0:0]	op1_0C;
	wire	[0:0]	op1_0D;
	wire	[0:0]	op1_08;
	wire	[0:0]	op1_09;
	wire	[0:0]	op1_0A;
	wire	[0:0]	op1_0B;
	wire	[0:0]	op2_FD;
	wire	[0:0]	op2_FE;
	wire	[0:0]	op2_ED;
	wire	[0:0]	op1_8F;
	wire	[0:0]	op1_58;
	wire	[0:0]	op1_1F;
	wire	[0:0]	op1_07;
	wire	[0:0]	op1_17;
	wire	[0:0]	op2_A1;
	wire	[0:0]	op2_A9;
	wire	[0:0]	op2_70;
	wire	[0:0]	op1_50;
	wire	[0:0]	op1_6A;
	wire	[0:0]	op1_68;
	wire	[0:0]	op1_0E;
	wire	[0:0]	op1_16;
	wire	[0:0]	op1_1E;
	wire	[0:0]	op1_06;
	wire	[0:0]	op2_A0;
	wire	[0:0]	op2_A8;
	wire	[0:0]	op1_C3;
	wire	[0:0]	op1_CB;
	wire	[0:0]	op1_C2;
	wire	[0:0]	op1_CA;
	wire	[0:0]	op1_D0;	
	wire	[0:0]	op1_D2;
	wire	[0:0]	op1_C0;
	wire	[0:0]	op1_D1;
	wire	[0:0]	op1_D3;
	wire	[0:0]	op1_C1;
	wire	[0:0]	op1_FD;
	wire	[0:0]	op1_90;
	wire	[0:0]	op1_86;
	wire	[0:0]	op1_87;
	wire	[0:0]	op1_AA;
	wire	[0:0]	op1_BB;
	wire	[0:0]	op1_CC;
	
	wire	[0:0]	op1_80_0;
	wire	[0:0]	op1_80_1;
	wire	[0:0]	op1_80_4;
	wire	[0:0]	op1_81_0;
	wire	[0:0]	op1_81_1;
	wire	[0:0]	op1_81_4;
	wire	[0:0]	op1_83_0;
	wire	[0:0]	op1_83_1;
	wire	[0:0]	op1_83_4;
	wire	[0:0]	op1_FF_0;
	wire	[0:0]	op1_FF_2;
	wire	[0:0]	op1_FF_4;
	wire	[0:0]	op1_FF_6;
	wire	[0:0]	op1_D0_4;
	wire	[0:0]	op1_D0_7;
	wire	[0:0]	op1_D2_4;
	wire	[0:0]	op1_D2_7;
	wire	[0:0]	op1_C0_4;
	wire	[0:0]	op1_C0_7;
	wire	[0:0]	op1_D1_4;
	wire	[0:0]	op1_D1_7;
	wire	[0:0]	op1_D3_4;
	wire	[0:0]	op1_D3_7;
	wire	[0:0]	op1_C1_4;
	wire	[0:0]	op1_C1_7;
	
	wire	[0:0]	op1_FF_6_m;
	wire	[0:0]	op1_8F_m;
	
	
	//List of comparators
	comp_eq3		bb0(mod_ext, 3'b000, mod_ext_0);
	comp_eq3		bb1(mod_ext, 3'b001, mod_ext_1);
	comp_eq3		bb2(mod_ext, 3'b010, mod_ext_2);
	comp_eq3		bb3(mod_ext, 3'b100, mod_ext_4);
	comp_eq3		bb4(mod_ext, 3'b110, mod_ext_6);
	comp_eq3		bb5(mod_ext, 3'b111, mod_ext_7);
	
	//1 byte inst
	comp_eq8		c00(opcode1, 8'h04, op1_04);
	comp_eq8		c01(opcode1, 8'h05, op1_05);
	comp_eq8		c02(opcode1, 8'h80, op1_80);
	comp_eq8		c03(opcode1, 8'h81, op1_81);
	comp_eq8		c04(opcode1, 8'h83, op1_83);
	comp_eq8		c05(opcode1, 8'h00, op1_00);
	comp_eq8		c06(opcode1, 8'h01, op1_01);
	comp_eq8		c07(opcode1, 8'h02, op1_02);
	comp_eq8		c08(opcode1, 8'h03, op1_03);
	comp_eq8		c09(opcode1, 8'h24, op1_24);
	comp_eq8		c0a(opcode1, 8'h25, op1_25);
	comp_eq8		c0b(opcode1, 8'h20, op1_20);
	comp_eq8		c0c(opcode1, 8'h21, op1_21);
	comp_eq8		c0d(opcode1, 8'h22, op1_22);
	comp_eq8		c0e(opcode1, 8'h23, op1_23);
	comp_eq8		c0f(opcode1, 8'hE8, op1_E8);
	comp_eq8		c0g(opcode1, 8'hFF, op1_FF);
	comp_eq8		c0h(opcode1, 8'h9A, op1_9A);
	comp_eq8		c0i(opcode1, 8'hFC, op1_FC);
	comp_eq8		c0j(opcode1, 8'h27, op1_27);
	comp_eq8		c0k(opcode1, 8'hF4, op1_F4);
	comp_eq8		c0l(opcode1, 8'hFE, op1_FE);
	comp_eq8		c0m(opcode1, 8'hCF, op1_CF);
	comp_eq8		c0n(opcode1, 8'h77, op1_77);
	comp_eq8		c0o(opcode1, 8'h75, op1_75);
	comp_eq8		c0p(opcode1, 8'hEB, op1_EB);
	comp_eq8		c0q(opcode1, 8'hE9, op1_E9);
	comp_eq8		c0r(opcode1, 8'hEA, op1_EA);
	comp_eq8		c0s(opcode1, 8'h88, op1_88);
	comp_eq8		c0t(opcode1, 8'h89, op1_89);
	comp_eq8		c0u(opcode1, 8'h8A, op1_8A);
	comp_eq8		c0v(opcode1, 8'h8B, op1_8B);
	comp_eq8		c0w(opcode1, 8'h8C, op1_8C);
	comp_eq8		c0x(opcode1, 8'h8E, op1_8E);
	comp_eq8		c0y(opcode1, 8'hC6, op1_C6);
	comp_eq8		c0z(opcode1, 8'hC7, op1_C7);
	comp_eq8		c10(opcode1, 8'hA6, op1_A6);
	comp_eq8		c11(opcode1, 8'hA7, op1_A7);
	comp_eq8		c12(opcode1, 8'hF6, op1_F6);
	comp_eq8		c13(opcode1, 8'hF7, op1_F7);
	comp_eq8		c14(opcode1, 8'h0C, op1_0C);
	comp_eq8		c15(opcode1, 8'h0D, op1_0D);
	comp_eq8		c16(opcode1, 8'h08, op1_08);
	comp_eq8		c17(opcode1, 8'h09, op1_09);
	comp_eq8		c18(opcode1, 8'h0A, op1_0A);
	comp_eq8		c19(opcode1, 8'h0B, op1_0B);
	comp_eq8		c1b(opcode1, 8'h1F, op1_1F);
	comp_eq8		c1c(opcode1, 8'h07, op1_07);
	comp_eq8		c1d(opcode1, 8'h17, op1_17);
	comp_eq8		c1e(opcode1, 8'h6A, op1_6A);
	comp_eq8		c1f(opcode1, 8'h68, op1_68);
	comp_eq8		c1g(opcode1, 8'h0E, op1_0E);
	comp_eq8		c1h(opcode1, 8'h16, op1_16);
	comp_eq8		c1i(opcode1, 8'h1E, op1_1E);
	comp_eq8		c1j(opcode1, 8'h06, op1_06);
	comp_eq8		c1k(opcode1, 8'hC3, op1_C3);
	comp_eq8		c1l(opcode1, 8'hCB, op1_CB);
	comp_eq8		c1m(opcode1, 8'hC2, op1_C2);
	comp_eq8		c1n(opcode1, 8'hCA, op1_CA);
	comp_eq8		c1o(opcode1, 8'hD0, op1_D0);
	comp_eq8		c1p(opcode1, 8'hD2, op1_D2);
	comp_eq8		c1q(opcode1, 8'hC0, op1_C0);
	comp_eq8		c1r(opcode1, 8'hD1, op1_D1);
	comp_eq8		c1s(opcode1, 8'hD3, op1_D3);
	comp_eq8		c1t(opcode1, 8'hC1, op1_C1);
	comp_eq8		c1u(opcode1, 8'hFD, op1_FD);
	comp_eq8		c1v(opcode1, 8'h86, op1_86);
	comp_eq8		c1w(opcode1, 8'h87, op1_87);
	comp_eq8		c1x(opcode1, 8'hAA, op1_AA);
	comp_eq8		c1y(opcode1, 8'hBB, op1_BB);
	comp_eq8		c1z(opcode1, 8'hCC, op1_CC);
	
	
	//byte+reg
	comp_eq5		cc0(opcode1[7:3], {4'h4, 1'b0}, op1_40);
	comp_eq5		cc1(opcode1[7:3], {4'hB, 1'b0}, op1_B0);
	comp_eq5		cc2(opcode1[7:3], {4'hB, 1'b1}, op1_B8);
	comp_eq5		cc3(opcode1[7:3], {4'h5, 1'b1}, op1_58);
	comp_eq5		cc4(opcode1[7:3], {4'h5, 1'b0}, op1_50);
	comp_eq5		cc5(opcode1[7:3], {4'h9, 1'b0}, op1_90);
	
	//2-byte
	wire	[0:0]	op2_42_t;
	wire	[0:0]	op2_B0_t;
	wire	[0:0]	op2_B1_t;
	wire	[0:0]	op2_87_t;
	wire	[0:0]	op2_85_t;
	wire	[0:0]	op2_6F_t;
	wire	[0:0]	op2_7F_t;
	wire	[0:0]	op2_FD_t;
	wire	[0:0]	op2_FE_t;
	wire	[0:0]	op2_ED_t;
	wire	[0:0]	op2_A1_t;
	wire	[0:0]	op2_A9_t;
	wire	[0:0]	op2_70_t;
	wire	[0:0]	op2_A0_t;
	wire	[0:0]	op2_A8_t;
	
	comp_eq8		cc6(opcode2, 8'h42, op2_42_t);
	comp_eq8		cc7(opcode2, 8'hB0, op2_B0_t);
	comp_eq8		cc8(opcode2, 8'hB1, op2_B1_t);
	comp_eq8		cc9(opcode2, 8'h87, op2_87_t);
	comp_eq8		cca(opcode2, 8'h85, op2_85_t);
	comp_eq8		ccb(opcode2, 8'h6F, op2_6F_t);
	comp_eq8		ccc(opcode2, 8'h7F, op2_7F_t);
	comp_eq8		ccd(opcode2, 8'hFD, op2_FD_t);
	comp_eq8		cce(opcode2, 8'hFE, op2_FE_t);
	comp_eq8		ccf(opcode2, 8'hED, op2_ED_t);
	comp_eq8		ccg(opcode2, 8'hA1, op2_A1_t);
	comp_eq8		cch(opcode2, 8'hA9, op2_A9_t);
	comp_eq8		cci(opcode2, 8'h70, op2_70_t);
	comp_eq8		ccj(opcode2, 8'hA0, op2_A0_t);
	comp_eq8		cck(opcode2, 8'hA8, op2_A8_t);
	
	and2n	#(1)	a0(op2_42_t, has_op2, op2_42);
	and2n	#(1)	a1(op2_B0_t, has_op2, op2_B0);
	and2n	#(1)	a2(op2_B1_t, has_op2, op2_B1);
	and2n	#(1)	a3(op2_87_t, has_op2, op2_87);
	and2n	#(1)	a4(op2_85_t, has_op2, op2_85);
	and2n	#(1)	a5(op2_6F_t, has_op2, op2_6F);
	and2n	#(1)	a6(op2_7F_t, has_op2, op2_7F);
	and2n	#(1)	a7(op2_FD_t, has_op2, op2_FD);
	and2n	#(1)	a8(op2_FE_t, has_op2, op2_FE);
	and2n	#(1)	a9(op2_ED_t, has_op2, op2_ED);
	and2n	#(1)	aa(op2_A1_t, has_op2, op2_A1);
	and2n	#(1)	ab(op2_A9_t, has_op2, op2_A9);
	and2n	#(1)	ac(op2_70_t, has_op2, op2_70);
	and2n	#(1)	ad(op2_A0_t, has_op2, op2_A0);
	and2n	#(1)	ae(op2_A8_t, has_op2, op2_A8);
	
	//Mod ext
	and2n	#(1)	b0(op1_80, mod_ext_0, op1_80_0);
	and2n	#(1)	b1(op1_80, mod_ext_1, op1_80_1);
	and2n	#(1)	b2(op1_80, mod_ext_4, op1_80_4);
	and2n	#(1)	b3(op1_81, mod_ext_0, op1_81_0);
	and2n	#(1)	b4(op1_81, mod_ext_1, op1_81_1);
	and2n	#(1)	b5(op1_81, mod_ext_4, op1_81_4);
	and2n	#(1)	b6(op1_83, mod_ext_0, op1_83_0);
	and2n	#(1)	b7(op1_83, mod_ext_1, op1_83_1);
	and2n	#(1)	b8(op1_83, mod_ext_4, op1_83_4);
	and2n	#(1)	b9(op1_FF, mod_ext_0, op1_FF_0);
	and2n	#(1)	ba(op1_FF, mod_ext_2, op1_FF_2);
	and2n	#(1)	bb(op1_FF, mod_ext_4, op1_FF_4);
	and2n	#(1)	bd(op1_D0, mod_ext_4, op1_D0_4);
	and2n	#(1)	be(op1_D0, mod_ext_7, op1_D0_7);
	and2n	#(1)	bf(op1_D2, mod_ext_4, op1_D2_4);
	and2n	#(1)	bg(op1_D2, mod_ext_7, op1_D2_7);
	and2n	#(1)	bh(op1_C0, mod_ext_4, op1_C0_4);
	and2n	#(1)	bj(op1_C0, mod_ext_7, op1_C0_7);
	and2n	#(1)	bk(op1_D1, mod_ext_4, op1_D1_4);
	and2n	#(1)	bl(op1_D1, mod_ext_7, op1_D1_7);
	and2n	#(1)	bm(op1_D3, mod_ext_4, op1_D3_4);
	and2n	#(1)	bn(op1_D3, mod_ext_7, op1_D3_7);
	and2n	#(1)	bo(op1_C1, mod_ext_4, op1_C1_4);
	and2n	#(1)	bp(op1_C1, mod_ext_7, op1_C1_7);
	
	//PUSH, POP
	wire	[0:0]	mod_m;
	wire	[0:0]	mod_m_n;
	
	wire	[0:0]	t0;
	wire	[0:0]	t1;
	and2n	#(1)	x2(mod[0], mod[1], mod_m_n);
	nand2n	#(1)	x3(mod[0], mod[1], mod_m);
	
	wire	[0:0]	op1_8F_t;
	
	comp_eq8		c1a(opcode1, 8'h8F, op1_8F_t);
	and2n	#(1)	x4(op1_8F_t, mod_m_n, op1_8F);
	and2n	#(1)	x5(op1_8F_t, mod_m, op1_8F_m);
	
	and3n	#(1)	bc(op1_FF, mod_ext_6, mod_m_n, op1_FF_6);
	and3n	#(1)	bx(op1_FF, mod_ext_6, mod_m, op1_FF_6_m);
	
	//Extending for addresses selection
	
	wire[7:0]	op1_04_ext;
	wire[7:0]	op1_05_ext;
	wire[7:0]	op1_80_0_ext;
	wire[7:0]	op1_81_0_ext;
	wire[7:0]	op1_83_0_ext;
	wire[7:0]	op1_00_ext;
	wire[7:0]	op1_01_ext;
	wire[7:0]	op1_02_ext;
	wire[7:0]	op1_03_ext;
	wire[7:0]	op1_24_ext;
	wire[7:0]	op1_25_ext;
	wire[7:0]	op1_80_4_ext;
	wire[7:0]	op1_81_4_ext;
	wire[7:0]	op1_83_4_ext;
	wire[7:0]	op1_20_ext;
	wire[7:0]	op1_21_ext;
	wire[7:0]	op1_22_ext;
	wire[7:0]	op1_23_ext;
	wire[7:0]	op1_E8_ext;
	wire[7:0]	op1_FF_2_ext;
	wire[7:0]	op1_9A_ext;
	wire[7:0]	op1_FC_ext;
	wire[7:0]	op2_42_ext;
	wire[7:0]	op2_B0_ext;
	wire[7:0]	op2_B1_ext;
	wire[7:0]	op1_27_ext;
	wire[7:0]	op1_F4_ext;
	wire[7:0]	op1_FE_ext;
	wire[7:0]	op1_FF_0_ext;
	wire[7:0]	op1_40_ext;
	wire[7:0]	op1_CF_ext;
	wire[7:0]	op1_77_ext;
	wire[7:0]	op1_75_ext;
	wire[7:0]	op2_87_ext;
	wire[7:0]	op2_85_ext;
	wire[7:0]	op1_EB_ext;
	wire[7:0]	op1_E9_ext;
	wire[7:0]	op1_FF_4_ext;
	wire[7:0]	op1_EA_ext;
	wire[7:0]	op1_88_ext;
	wire[7:0]	op1_89_ext;
	wire[7:0]	op1_8A_ext;
	wire[7:0]	op1_8B_ext;
	wire[7:0]	op1_8C_ext;
	wire[7:0]	op1_8E_ext;
	wire[7:0]	op1_B0_ext;
	wire[7:0]	op1_B8_ext;
	wire[7:0]	op1_C6_ext;
	wire[7:0]	op1_C7_ext;
	wire[7:0]	op2_6F_ext;
	wire[7:0]	op2_7F_ext;
	wire[7:0]	op1_F6_ext;
	wire[7:0]	op1_F7_ext;
	wire[7:0]	op1_0C_ext;
	wire[7:0]	op1_0D_ext;
	wire[7:0]	op1_80_1_ext;
	wire[7:0]	op1_81_1_ext;
	wire[7:0]	op1_83_1_ext;
	wire[7:0]	op1_08_ext;
	wire[7:0]	op1_09_ext;
	wire[7:0]	op1_0A_ext;
	wire[7:0]	op1_0B_ext;
	wire[7:0]	op2_FD_ext;
	wire[7:0]	op2_FE_ext;
	wire[7:0]	op2_ED_ext;
	wire[7:0]	op1_8F_m_ext;
	wire[7:0]	op1_8F_ext;
	wire[7:0]	op1_58_ext;
	wire[7:0]	op1_1F_ext;
	wire[7:0]	op1_07_ext;
	wire[7:0]	op1_17_ext;
	wire[7:0]	op2_A1_ext;
	wire[7:0]	op2_A9_ext;
	wire[7:0]	op2_70_ext;
	wire[7:0]	op1_FF_6_m_ext;
	wire[7:0]	op1_FF_6_ext;
	wire[7:0]	op1_50_ext;
	wire[7:0]	op1_6A_ext;
	wire[7:0]	op1_68_ext;
	wire[7:0]	op1_0E_ext;
	wire[7:0]	op1_16_ext;
	wire[7:0]	op1_1E_ext;
	wire[7:0]	op1_06_ext;
	wire[7:0]	op2_A0_ext;
	wire[7:0]	op2_A8_ext;
	wire[7:0]	op1_A6_ext;
	wire[7:0]	op1_A7_ext;
	wire[7:0]	op1_C3_ext;
	wire[7:0]	op1_CB_ext;
	wire[7:0]	op1_C2_ext;
	wire[7:0]	op1_CA_ext;
	wire[7:0]	op1_D0_4_ext;
	wire[7:0]	op1_D2_4_ext;
	wire[7:0]	op1_C0_4_ext;
	wire[7:0]	op1_D1_4_ext;
	wire[7:0]	op1_D3_4_ext;
	wire[7:0]	op1_C1_4_ext;
	wire[7:0]	op1_D0_7_ext;
	wire[7:0]	op1_D2_7_ext;
	wire[7:0]	op1_C0_7_ext;
	wire[7:0]	op1_D1_7_ext;
	wire[7:0]	op1_D3_7_ext;
	wire[7:0]	op1_C1_7_ext;
	wire[7:0]	op1_FD_ext;
	wire[7:0]	op1_90_ext;
	wire[7:0]	op1_86_ext;
	wire[7:0]	op1_87_ext;
	wire[7:0]	op1_AA_ext;
	wire[7:0]	op1_BB_ext;
	wire[7:0]	op1_CC_ext;


	assign	op1_04_ext		= {8{op1_04}};
	assign	op1_05_ext		= {8{op1_05}};
	assign	op1_80_0_ext		= {8{op1_80_0}};
	assign	op1_81_0_ext		= {8{op1_81_0}};
	assign	op1_83_0_ext		= {8{op1_83_0}};
	assign	op1_00_ext		= {8{op1_00}};
	assign	op1_01_ext		= {8{op1_01}};
	assign	op1_02_ext		= {8{op1_02}};
	assign	op1_03_ext		= {8{op1_03}};
	assign	op1_24_ext		= {8{op1_24}};
	assign	op1_25_ext		= {8{op1_25}};
	assign	op1_80_4_ext		= {8{op1_80_4}};
	assign	op1_81_4_ext		= {8{op1_81_4}};
	assign	op1_83_4_ext		= {8{op1_83_4}};
	assign	op1_20_ext		= {8{op1_20}};
	assign	op1_21_ext		= {8{op1_21}};
	assign	op1_22_ext		= {8{op1_22}};
	assign	op1_23_ext		= {8{op1_23}};
	assign	op1_E8_ext		= {8{op1_E8}};
	assign	op1_FF_2_ext		= {8{op1_FF_2}};
	assign	op1_9A_ext		= {8{op1_9A}};
	assign	op1_FC_ext		= {8{op1_FC}};
	assign	op2_42_ext		= {8{op2_42}};
	assign	op2_B0_ext		= {8{op2_B0}};
	assign	op2_B1_ext		= {8{op2_B1}};
	assign	op1_27_ext		= {8{op1_27}};
	assign	op1_F4_ext		= {8{op1_F4}};
	assign	op1_FE_ext		= {8{op1_FE}};
	assign	op1_FF_0_ext		= {8{op1_FF_0}};
	assign	op1_40_ext		= {8{op1_40}};
	assign	op1_CF_ext		= {8{op1_CF}};
	assign	op1_77_ext		= {8{op1_77}};
	assign	op1_75_ext		= {8{op1_75}};
	assign	op2_87_ext		= {8{op2_87}};
	assign	op2_85_ext		= {8{op2_85}};
	assign	op1_EB_ext		= {8{op1_EB}};
	assign	op1_E9_ext		= {8{op1_E9}};
	assign	op1_FF_4_ext		= {8{op1_FF_4}};
	assign	op1_EA_ext		= {8{op1_EA}};
	assign	op1_88_ext		= {8{op1_88}};
	assign	op1_89_ext		= {8{op1_89}};
	assign	op1_8A_ext		= {8{op1_8A}};
	assign	op1_8B_ext		= {8{op1_8B}};
	assign	op1_8C_ext		= {8{op1_8C}};
	assign	op1_8E_ext		= {8{op1_8E}};
	assign	op1_B0_ext		= {8{op1_B0}};
	assign	op1_B8_ext		= {8{op1_B8}};
	assign	op1_C6_ext		= {8{op1_C6}};
	assign	op1_C7_ext		= {8{op1_C7}};
	assign	op2_6F_ext		= {8{op2_6F}};
	assign	op2_7F_ext		= {8{op2_7F}};
	assign	op1_F6_ext		= {8{op1_F6}};
	assign	op1_F7_ext		= {8{op1_F7}};
	assign	op1_0C_ext		= {8{op1_0C}};
	assign	op1_0D_ext		= {8{op1_0D}};
	assign	op1_80_1_ext		= {8{op1_80_1}};
	assign	op1_81_1_ext		= {8{op1_81_1}};
	assign	op1_83_1_ext		= {8{op1_83_1}};
	assign	op1_08_ext		= {8{op1_08}};
	assign	op1_09_ext		= {8{op1_09}};
	assign	op1_0A_ext		= {8{op1_0A}};
	assign	op1_0B_ext		= {8{op1_0B}};
	assign	op2_FD_ext		= {8{op2_FD}};
	assign	op2_FE_ext		= {8{op2_FE}};
	assign	op2_ED_ext		= {8{op2_ED}};
	assign	op1_8F_m_ext		= {8{op1_8F_m}};
	assign	op1_8F_ext		= {8{op1_8F}};
	assign	op1_58_ext		= {8{op1_58}};
	assign	op1_1F_ext		= {8{op1_1F}};
	assign	op1_07_ext		= {8{op1_07}};
	assign	op1_17_ext		= {8{op1_17}};
	assign	op2_A1_ext		= {8{op2_A1}};
	assign	op2_A9_ext		= {8{op2_A9}};
	assign	op2_70_ext		= {8{op2_70}};
	assign	op1_FF_6_m_ext		= {8{op1_FF_6_m}};
	assign	op1_FF_6_ext		= {8{op1_FF_6}};
	assign	op1_50_ext		= {8{op1_50}};
	assign	op1_6A_ext		= {8{op1_6A}};
	assign	op1_68_ext		= {8{op1_68}};
	assign	op1_0E_ext		= {8{op1_0E}};
	assign	op1_16_ext		= {8{op1_16}};
	assign	op1_1E_ext		= {8{op1_1E}};
	assign	op1_06_ext		= {8{op1_06}};
	assign	op2_A0_ext		= {8{op2_A0}};
	assign	op2_A8_ext		= {8{op2_A8}};
	assign	op1_A6_ext		= {8{op1_A6}};
	assign	op1_A7_ext		= {8{op1_A7}};
	assign	op1_C3_ext		= {8{op1_C3}};
	assign	op1_CB_ext		= {8{op1_CB}};
	assign	op1_C2_ext		= {8{op1_C2}};
	assign	op1_CA_ext		= {8{op1_CA}};
	assign	op1_D0_4_ext		= {8{op1_D0_4}};
	assign	op1_D2_4_ext		= {8{op1_D2_4}};
	assign	op1_C0_4_ext		= {8{op1_C0_4}};
	assign	op1_D1_4_ext		= {8{op1_D1_4}};
	assign	op1_D3_4_ext		= {8{op1_D3_4}};
	assign	op1_C1_4_ext		= {8{op1_C1_4}};
	assign	op1_D0_7_ext		= {8{op1_D0_7}};
	assign	op1_D2_7_ext		= {8{op1_D2_7}};
	assign	op1_C0_7_ext		= {8{op1_C0_7}};
	assign	op1_D1_7_ext		= {8{op1_D1_7}};
	assign	op1_D3_7_ext		= {8{op1_D3_7}};
	assign	op1_C1_7_ext		= {8{op1_C1_7}};
	assign	op1_FD_ext		= {8{op1_FD}};
	assign	op1_90_ext		= {8{op1_90}};
	assign	op1_86_ext		= {8{op1_86}};
	assign	op1_87_ext		= {8{op1_87}};
	assign	op1_AA_ext		= {8{op1_AA}};
	assign	op1_BB_ext		= {8{op1_BB}};
	assign	op1_CC_ext		= {8{op1_CC}};
	
	wire[7:0]	 ad00;
	wire[7:0]	 ad01;
	wire[7:0]	 ad02;
	wire[7:0]	 ad03;
	wire[7:0]	 ad04;
	wire[7:0]	 ad05;
	wire[7:0]	 ad06;
	wire[7:0]	 ad07;
	wire[7:0]	 ad08;
	wire[7:0]	 ad09;
	wire[7:0]	 ad10;
	wire[7:0]	 ad11;
	wire[7:0]	 ad12;
	wire[7:0]	 ad13;
	wire[7:0]	 ad14;
	wire[7:0]	 ad15;
	wire[7:0]	 ad16;
	wire[7:0]	 ad17;
	wire[7:0]	 ad18;
	wire[7:0]	 ad19;
	wire[7:0]	 ad20;
	wire[7:0]	 ad21;
	wire[7:0]	 ad22;
	wire[7:0]	 ad23;
	wire[7:0]	 ad24;
	wire[7:0]	 ad25;
	wire[7:0]	 ad26;
	wire[7:0]	 ad27;
	wire[7:0]	 ad28;
	wire[7:0]	 ad29;
	wire[7:0]	 ad30;
	wire[7:0]	 ad31;
	wire[7:0]	 ad32;
	wire[7:0]	 ad33;
	wire[7:0]	 ad34;
	wire[7:0]	 ad35;
	wire[7:0]	 ad36;
	wire[7:0]	 ad37;
	wire[7:0]	 ad38;
	wire[7:0]	 ad39;
	wire[7:0]	 ad40;
	wire[7:0]	 ad41;
	wire[7:0]	 ad42;
	wire[7:0]	 ad43;
	wire[7:0]	 ad44;
	wire[7:0]	 ad45;
	wire[7:0]	 ad46;
	wire[7:0]	 ad47;
	wire[7:0]	 ad48;
	wire[7:0]	 ad49;
	wire[7:0]	 ad50;
	wire[7:0]	 ad51;
	wire[7:0]	 ad52;
	wire[7:0]	 ad53;
	wire[7:0]	 ad54;
	wire[7:0]	 ad55;
	wire[7:0]	 ad56;
	wire[7:0]	 ad57;
	wire[7:0]	 ad58;
	wire[7:0]	 ad59;
	wire[7:0]	 ad60;
	wire[7:0]	 ad61;
	wire[7:0]	 ad62;
	wire[7:0]	 ad63;
	wire[7:0]	 ad64;
	wire[7:0]	 ad65;
	wire[7:0]	 ad66;
	wire[7:0]	 ad67;
	wire[7:0]	 ad68;
	wire[7:0]	 ad69;
	wire[7:0]	 ad70;
	wire[7:0]	 ad71;
	wire[7:0]	 ad72;
	wire[7:0]	 ad73;
	wire[7:0]	 ad74;
	wire[7:0]	 ad75;
	wire[7:0]	 ad76;
	wire[7:0]	 ad77;
	wire[7:0]	 ad78;
	wire[7:0]	 ad79;
	wire[7:0]	 ad80;
	wire[7:0]	 ad81;
	wire[7:0]	 ad82;
	wire[7:0]	 ad83;
	wire[7:0]	 ad84;
	wire[7:0]	 ad85;
	wire[7:0]	 ad86;
	wire[7:0]	 ad87;
	wire[7:0]	 ad88;
	wire[7:0]	 ad89;
	wire[7:0]	 ad90;
	wire[7:0]	 ad91;
	wire[7:0]	 ad92;
	wire[7:0]	 ad93;
	wire[7:0]	 ad94;
	wire[7:0]	 ad95;
	wire[7:0]	 ad96;
	wire[7:0]	 ad97;
	wire[7:0]	 ad98;
	wire[7:0]	 ad99;
	wire[7:0]	 ad100;
	wire[7:0]	 ad101;
	wire[7:0]	 ad102;
	wire[7:0]	 ad103;
	wire[7:0]	 ad104;
	wire[7:0]	 ad105;
	wire[7:0]	 ad106;
	wire[7:0]	 ad107;
	wire[7:0]	 ad108;
	wire[7:0]	 ad109;


	and2n	#(8)	ma00(op1_04_ext, 8'h00, ad00);
	and2n	#(8)	ma01(op1_05_ext, 8'h01, ad01);
	and2n	#(8)	ma02(op1_80_0_ext, 8'h02, ad02);
	and2n	#(8)	ma03(op1_81_0_ext, 8'h03, ad03);
	and2n	#(8)	ma04(op1_83_0_ext, 8'h04, ad04);
	and2n	#(8)	ma05(op1_00_ext, 8'h05, ad05);
	and2n	#(8)	ma06(op1_01_ext, 8'h06, ad06);
	and2n	#(8)	ma07(op1_02_ext, 8'h07, ad07);
	and2n	#(8)	ma08(op1_03_ext, 8'h08, ad08);
	and2n	#(8)	ma09(op1_24_ext, 8'h09, ad09);
	and2n	#(8)	ma10(op1_25_ext, 8'h0a, ad10);
	and2n	#(8)	ma11(op1_80_4_ext, 8'h0b, ad11);
	and2n	#(8)	ma12(op1_81_4_ext, 8'h0c, ad12);
	and2n	#(8)	ma13(op1_83_4_ext, 8'h0d, ad13);
	and2n	#(8)	ma14(op1_20_ext, 8'h0e, ad14);
	and2n	#(8)	ma15(op1_21_ext, 8'h0f, ad15);
	and2n	#(8)	ma16(op1_22_ext, 8'h10, ad16);
	and2n	#(8)	ma17(op1_23_ext, 8'h11, ad17);
	and2n	#(8)	ma18(op1_E8_ext, 8'h12, ad18);
	and2n	#(8)	ma19(op1_FF_2_ext, 8'h14, ad19);
	and2n	#(8)	ma20(op1_9A_ext, 8'h16, ad20);
	//WARNING: Addr of IRetD needs to be changed to end of CS for filling in
	and2n	#(8)	ma21(op1_FC_ext, 8'h8d, ad21);
	and2n	#(8)	ma22(op2_42_ext, 8'h1a, ad22);
	and2n	#(8)	ma23(op2_B0_ext, 8'h1b, ad23);
	and2n	#(8)	ma24(op2_B1_ext, 8'h1d, ad24);
	and2n	#(8)	ma25(op1_27_ext, 8'h1f, ad25);
	and2n	#(8)	ma26(op1_F4_ext, 8'h20, ad26);
	and2n	#(8)	ma27(op1_FE_ext, 8'h21, ad27);
	and2n	#(8)	ma28(op1_FF_0_ext, 8'h22, ad28);
	and2n	#(8)	ma29(op1_40_ext, 8'h23, ad29);
	and2n	#(8)	ma30(op1_CF_ext, 8'h24, ad30);
	and2n	#(8)	ma31(op1_77_ext, 8'h25, ad31);
	and2n	#(8)	ma32(op1_75_ext, 8'h26, ad32);
	and2n	#(8)	ma33(op2_87_ext, 8'h27, ad33);
	and2n	#(8)	ma34(op2_85_ext, 8'h28, ad34);
	and2n	#(8)	ma35(op1_EB_ext, 8'h29, ad35);
	and2n	#(8)	ma36(op1_E9_ext, 8'h2a, ad36);
	and2n	#(8)	ma37(op1_FF_4_ext, 8'h2b, ad37);
	and2n	#(8)	ma38(op1_EA_ext, 8'h2c, ad38);
	and2n	#(8)	ma39(op1_88_ext, 8'h2d, ad39);
	and2n	#(8)	ma40(op1_89_ext, 8'h2e, ad40);
	and2n	#(8)	ma41(op1_8A_ext, 8'h2f, ad41);
	and2n	#(8)	ma42(op1_8B_ext, 8'h30, ad42);
	and2n	#(8)	ma43(op1_8C_ext, 8'h31, ad43);
	and2n	#(8)	ma44(op1_8E_ext, 8'h32, ad44);
	and2n	#(8)	ma45(op1_B0_ext, 8'h33, ad45);
	and2n	#(8)	ma46(op1_B8_ext, 8'h34, ad46);
	and2n	#(8)	ma47(op1_C6_ext, 8'h35, ad47);
	and2n	#(8)	ma48(op1_C7_ext, 8'h36, ad48);
	and2n	#(8)	ma49(op2_6F_ext, 8'h37, ad49);
	and2n	#(8)	ma50(op2_7F_ext, 8'h39, ad50);
	and2n	#(8)	ma51(op1_F6_ext, 8'h3b, ad51);
	and2n	#(8)	ma52(op1_F7_ext, 8'h3c, ad52);
	and2n	#(8)	ma53(op1_0C_ext, 8'h3d, ad53);
	and2n	#(8)	ma54(op1_0D_ext, 8'h3e, ad54);
	and2n	#(8)	ma55(op1_80_1_ext, 8'h3f, ad55);
	and2n	#(8)	ma56(op1_81_1_ext, 8'h40, ad56);
	and2n	#(8)	ma57(op1_83_1_ext, 8'h41, ad57);
	and2n	#(8)	ma58(op1_08_ext, 8'h42, ad58);
	and2n	#(8)	ma59(op1_09_ext, 8'h43, ad59);
	and2n	#(8)	ma60(op1_0A_ext, 8'h44, ad60);
	and2n	#(8)	ma61(op1_0B_ext, 8'h45, ad61);
	and2n	#(8)	ma62(op2_FD_ext, 8'h46, ad62);
	and2n	#(8)	ma63(op2_FE_ext, 8'h48, ad63);
	and2n	#(8)	ma64(op2_ED_ext, 8'h4a, ad64);
	and2n	#(8)	ma65(op1_8F_m_ext, 8'h4c, ad65);
	and2n	#(8)	ma66(op1_8F_ext, 8'h4e, ad66);
	and2n	#(8)	ma67(op1_58_ext, 8'h4f, ad67);
	and2n	#(8)	ma68(op1_1F_ext, 8'h50, ad68);
	and2n	#(8)	ma69(op1_07_ext, 8'h51, ad69);
	and2n	#(8)	ma70(op1_17_ext, 8'h52, ad70);
	and2n	#(8)	ma71(op2_A1_ext, 8'h53, ad71);
	and2n	#(8)	ma72(op2_A9_ext, 8'h54, ad72);
	and2n	#(8)	ma73(op2_70_ext, 8'h55, ad73);
	and2n	#(8)	ma74(op1_FF_6_m_ext, 8'h57, ad74);
	and2n	#(8)	ma75(op1_FF_6_ext, 8'h59, ad75);
	and2n	#(8)	ma76(op1_50_ext, 8'h5a, ad76);
	and2n	#(8)	ma77(op1_6A_ext, 8'h5b, ad77);
	and2n	#(8)	ma78(op1_68_ext, 8'h5c, ad78);
	and2n	#(8)	ma79(op1_0E_ext, 8'h5d, ad79);
	and2n	#(8)	ma80(op1_16_ext, 8'h5e, ad80);
	and2n	#(8)	ma81(op1_1E_ext, 8'h5f, ad81);
	and2n	#(8)	ma82(op1_06_ext, 8'h60, ad82);
	and2n	#(8)	ma83(op2_A0_ext, 8'h61, ad83);
	and2n	#(8)	ma84(op2_A8_ext, 8'h62, ad84);
	and2n	#(8)	ma85(op1_A6_ext, 8'h63, ad85);
	and2n	#(8)	ma86(op1_A7_ext, 8'h65, ad86);
	and2n	#(8)	ma87(op1_C3_ext, 8'h67, ad87);
	and2n	#(8)	ma88(op1_CB_ext, 8'h69, ad88);
	and2n	#(8)	ma89(op1_C2_ext, 8'h6c, ad89);
	and2n	#(8)	ma90(op1_CA_ext, 8'h6e, ad90);
	and2n	#(8)	ma91(op1_D0_4_ext, 8'h71, ad91);
	and2n	#(8)	ma92(op1_D2_4_ext, 8'h72, ad92);
	and2n	#(8)	ma93(op1_C0_4_ext, 8'h73, ad93);
	and2n	#(8)	ma94(op1_D1_4_ext, 8'h74, ad94);
	and2n	#(8)	ma95(op1_D3_4_ext, 8'h75, ad95);
	and2n	#(8)	ma96(op1_C1_4_ext, 8'h76, ad96);
	and2n	#(8)	ma97(op1_D0_7_ext, 8'h77, ad97);
	and2n	#(8)	ma98(op1_D2_7_ext, 8'h78, ad98);
	and2n	#(8)	ma99(op1_C0_7_ext, 8'h79, ad99);
	and2n	#(8)	ma100(op1_D1_7_ext, 8'h7a, ad100);
	and2n	#(8)	ma101(op1_D3_7_ext, 8'h7b, ad101);
	and2n	#(8)	ma102(op1_C1_7_ext, 8'h7c, ad102);
	and2n	#(8)	ma103(op1_FD_ext, 8'h7d, ad103);
	and2n	#(8)	ma104(op1_90_ext, 8'h7e, ad104);
	and2n	#(8)	ma105(op1_86_ext, 8'h7f, ad105);
	and2n	#(8)	ma106(op1_87_ext, 8'h80, ad106);
	and2n	#(8)	ma107(op1_AA_ext, 8'h81, ad107);
	and2n	#(8)	ma108(op1_BB_ext, 8'h85, ad108);
	and2n	#(8)	ma109(op1_CC_ext, 8'h89, ad109);
	
	wire	[7:0]	temp0[27:0];
	wire	[7:0]	temp1[6:0];
	wire	[7:0]	temp2[1:0];
	
	or4n	#(8)	o0(ad00, ad01, ad02, ad03, temp0[0]);
	or4n	#(8)	o1(ad04, ad05, ad06, ad07, temp0[1]);
	or4n	#(8)	o2(ad08, ad09, ad10, ad11, temp0[2]);
	or4n	#(8)	o3(ad12, ad13, ad14, ad15, temp0[3]);
	or4n	#(8)	o4(ad16, ad17, ad18, ad19, temp0[4]);
	or4n	#(8)	o5(ad20, ad21, ad22, ad23, temp0[5]);
	or4n	#(8)	o6(ad24, ad25, ad26, ad27, temp0[6]);
	or4n	#(8)	o7(ad28, ad29, ad30, ad31, temp0[7]);
	or4n	#(8)	o8(ad32, ad33, ad34, ad35, temp0[8]);
	or4n	#(8)	o9(ad36, ad37, ad38, ad39, temp0[9]);
	or4n	#(8)	o10(ad40, ad41, ad42, ad43, temp0[10]);
	or4n	#(8)	o11(ad44, ad45, ad46, ad47, temp0[11]);
	or4n	#(8)	o12(ad48, ad49, ad50, ad51, temp0[12]);
	or4n	#(8)	o13(ad52, ad53, ad54, ad55, temp0[13]);
	or4n	#(8)	o14(ad56, ad57, ad58, ad59, temp0[14]);
	or4n	#(8)	o15(ad60, ad61, ad62, ad63, temp0[15]);
	or4n	#(8)	o16(ad64, ad65, ad66, ad67, temp0[16]);
	or4n	#(8)	o17(ad68, ad69, ad70, ad71, temp0[17]);
	or4n	#(8)	o18(ad72, ad73, ad74, ad75, temp0[18]);
	or4n	#(8)	o19(ad76, ad77, ad78, ad79, temp0[19]);
	or4n	#(8)	o20(ad80, ad81, ad82, ad83, temp0[20]);
	or4n	#(8)	o21(ad84, ad85, ad86, ad87, temp0[21]);
	or4n	#(8)	o22(ad88, ad89, ad90, ad91, temp0[22]);
	or4n	#(8)	o23(ad92, ad93, ad94, ad95, temp0[23]);
	or4n	#(8)	o24(ad96, ad97, ad98, ad99, temp0[24]);
	or4n	#(8)	o25(ad100, ad101, ad102, ad103, temp0[25]);
	or4n	#(8)	o26(ad104, ad105, ad106, ad107, temp0[26]);
	or2n	#(8)	o2k(ad108, ad109, temp0[27]);

	
	or4n 	#(8)	o27(temp0[0], temp0[1], temp0[2], temp0[3], temp1[0]);
	or4n 	#(8)	o28(temp0[4], temp0[5], temp0[6], temp0[7], temp1[1]);
	or4n 	#(8)	o29(temp0[8], temp0[9], temp0[10], temp0[11], temp1[2]);
	or4n 	#(8)	o30(temp0[12], temp0[13], temp0[14], temp0[15], temp1[3]);
	or4n 	#(8)	o31(temp0[16], temp0[17], temp0[18], temp0[19], temp1[4]);
	or4n 	#(8)	o32(temp0[20], temp0[21], temp0[22], temp0[23], temp1[5]);
	or4n 	#(8)	o33(temp0[24], temp0[25], temp0[26], temp0[27], temp1[6]);
	
	or3n	#(8)	o34(temp1[0], temp1[1], temp1[2], temp2[0]);
	or4n	#(8)	o35(temp1[3], temp1[4], temp1[5], temp1[6], temp2[1]);
	
	wire	[7:0]	rom_addr;
	or2n	#(8)	o36(temp2[0], temp2[1], rom_addr);
	
	wire	[7:0]	uop_addr;
	
	//Add uop ptr to address for multiple uops
	add_8b	ad0(uop_addr, , rom_addr, uop_ptr, 1'b0);
	
	rom256_128		rm(uop_addr, 1'b1, control_bits);
	
	//Instruction specific logic
	//branches!
	wire	[3:0]	br_temp;
	or4n	#(1)	ob0(op1_E8, op1_FF_2, op1_9A, op1_CF, br_temp[0]);
	or4n	#(1)	ob1(op1_77, op1_75, op2_87, op2_85, br_temp[1]); 
	or4n	#(1)	ob2(op1_EB, op1_E9, op1_FF_4, op1_EA, br_temp[2]); 
	or4n	#(1)	ob3(op1_C3, op1_CB, op1_C2, op1_CA, br_temp[3]); 
	or4n	#(1)	ob4(br_temp[0], br_temp[1], br_temp[2], br_temp[3], op_br);
	
	//Far pointer insts
	or2n	#(1)	ofp0(op1_EA, op1_9A, op_fptr);
	assign	op_fptr_s	= op1_EA;
	
	//r1Ren don't override!
	
	wire	[0:0]	move_q;
	or2n	#(1)	ofp1(op2_6F, op2_7F, move_q);
	or2n	#(1)	ofp2(op1_8F_m, 1'b0, novr_r1Ren_uop0);
	or3n	#(1)	ofp3(op1_FF_6_m, op2_B0, op2_B1, novr_r1Ren_uop1);
	
	//Jump
	and3n	#(1)	ofp4(mod[1], mod[0], op1_FF_4, op_jmp_reg);
	//Mov1
	and3n	#(1)	ofp5(mod[1], mod[0], op2_7F, op_movq_reg);
	//Pop reg
	assign 	op_pop_reg	= op1_8F;
	assign 	op_push_reg	= op1_FF_6;
	
endmodule


module 	rom256_128
	(
	input	[7:0]	rom_addr,
	input	[0:0]	enable,
	output	[127:0]	d_out
	);

	wire	[63:0]	d_out_0h;
	wire	[63:0]	d_out_0l;	
	wire	[63:0]	d_out_1h;
	wire	[63:0]	d_out_1l;	
	wire	[63:0]	d_out_2h;
	wire	[63:0]	d_out_2l;	
	wire	[63:0]	d_out_3h;
	wire	[63:0]	d_out_3l;
	wire	[63:0]	d_out_4h;
	wire	[63:0]	d_out_4l;	
	wire	[63:0]	d_out_5h;
	wire	[63:0]	d_out_5l;	
	wire	[63:0]	d_out_6h;
	wire	[63:0]	d_out_6l;	
	wire	[63:0]	d_out_7h;
	wire	[63:0]	d_out_7l;
	
	rom64b32w$	rm0h(rom_addr[4:0], enable, d_out_0h);
	rom64b32w$	rm0l(rom_addr[4:0], enable, d_out_0l);
	
	rom64b32w$	rm1h(rom_addr[4:0], enable, d_out_1h);
	rom64b32w$	rm1l(rom_addr[4:0], enable, d_out_1l);
	
	rom64b32w$	rm2h(rom_addr[4:0], enable, d_out_2h);
	rom64b32w$	rm2l(rom_addr[4:0], enable, d_out_2l);
	
	rom64b32w$	rm3h(rom_addr[4:0], enable, d_out_3h);
	rom64b32w$	rm3l(rom_addr[4:0], enable, d_out_3l);
	
	rom64b32w$	rm4h(rom_addr[4:0], enable, d_out_4h);
	rom64b32w$	rm4l(rom_addr[4:0], enable, d_out_4l);
	
	rom64b32w$	rm5h(rom_addr[4:0], enable, d_out_5h);
	rom64b32w$	rm5l(rom_addr[4:0], enable, d_out_5l);
	
	rom64b32w$	rm6h(rom_addr[4:0], enable, d_out_6h);
	rom64b32w$	rm6l(rom_addr[4:0], enable, d_out_6l);
	
	rom64b32w$	rm7h(rom_addr[4:0], enable, d_out_7h);
	rom64b32w$	rm7l(rom_addr[4:0], enable, d_out_7l);
	
	wire	[63:0]	d_out_h;
	wire	[63:0]	d_out_l;
	
	mux8n	#(64)	m0(d_out_0h, d_out_1h, d_out_2h, d_out_3h, d_out_4h, d_out_5h, d_out_6h, d_out_7h, rom_addr[7:5], d_out_h);
	mux8n	#(64)	m1(d_out_0l, d_out_1l, d_out_2l, d_out_3l, d_out_4l, d_out_5l, d_out_6l, d_out_7l, rom_addr[7:5], d_out_l);
	
	assign	d_out	= {d_out_h, d_out_l};
	
endmodule