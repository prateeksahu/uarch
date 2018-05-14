module 	size	(
	input	[0:0]	has_prefix1,
	input	[0:0]	has_prefix2,
	input	[0:0]	has_prefix3,
	input	[0:0]	has_op2,
	input	[0:0]	has_modrm,
	input	[0:0]	has_sib,
	input	[0:0]	has_disp8,
	input	[0:0]	has_disp32,
	input	[0:0]	has_imm8,
	input	[0:0]	has_imm16,
	input	[0:0]	has_imm32,
				
	output 	[3:0]	size
	);

	wire	[0:0]	has_prefix1_n;
	wire	[0:0]	has_prefix2_n;
	wire	[0:0]	has_prefix3_n;
	wire	[0:0]	has_op2_n;
	wire	[0:0]	has_modrm_n;
	wire	[0:0]	has_sib_n;
	wire	[0:0]	has_disp8_n;
	wire	[0:0]	has_disp32_n;
	wire	[0:0]	has_imm8_n;
	wire	[0:0]	has_imm16_n;
	wire	[0:0]	has_imm32_n;

	invn	#(1)	in0(has_prefix1, has_prefix1_n);
	invn	#(1)	in1(has_prefix2, has_prefix2_n);
	invn	#(1)	in2(has_prefix3, has_prefix3_n);
	invn	#(1)	in3(has_op2, has_op2_n);
	invn	#(1)	in4(has_modrm, has_modrm_n);
	invn	#(1)	in5(has_sib, has_sib_n);
	invn	#(1)	in6(has_disp8, has_disp8_n);
	invn	#(1)	in7(has_disp32, has_disp32_n);
	invn	#(1)	in8(has_imm8, has_imm8_n);
	invn	#(1)	in9(has_imm16, has_imm16_n);
	invn	#(1)	in10(has_imm32, has_imm32_n);
	wire	[0:0]	min_0;
	wire	[0:0]	min_0_a;
	wire	[0:0]	min_0_b;
	wire	[0:0]	min_0_c;


	nand4n	#(1)	a0(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2, min_0_a);
	nand3n	#(1)	a1(has_imm8, has_imm16_n, has_imm32_n, min_0_b);
	nand3n	#(1)	a2(has_sib_n, has_disp8, has_disp32_n, min_0_c);
	nor3n	#(1)	a3(min_0_a, min_0_b, min_0_c, min_0);
	wire	[0:0]	min_1;
	wire	[0:0]	min_1_a;
	wire	[0:0]	min_1_b;
	wire	[0:0]	min_1_c;


	nand4n	#(1)	a4(has_prefix1, has_prefix2, has_prefix3_n, has_op2_n, min_1_a);
	nand3n	#(1)	a5(has_imm8_n, has_imm16, has_modrm, min_1_b);
	nand3n	#(1)	a6(has_sib, has_disp8, has_disp32_n, min_1_c);
	nor3n	#(1)	a7(min_1_a, min_1_b, min_1_c, min_1);
	wire	[0:0]	min_2;
	wire	[0:0]	min_2_a;
	wire	[0:0]	min_2_b;
	wire	[0:0]	min_2_c;


	nand4n	#(1)	a8(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2, min_2_a);
	nand4n	#(1)	a9(has_imm8_n, has_imm16_n, has_imm32_n, has_modrm, min_2_b);
	nand3n	#(1)	a10(has_sib, has_disp8, has_disp32_n, min_2_c);
	nor3n	#(1)	a11(min_2_a, min_2_b, min_2_c, min_2);
	wire	[0:0]	min_3;
	wire	[0:0]	min_3_a;
	wire	[0:0]	min_3_b;
	wire	[0:0]	min_3_c;


	nand4n	#(1)	a12(has_prefix1_n, has_prefix2, has_prefix3_n, has_op2_n, min_3_a);
	nand3n	#(1)	a13(has_imm8, has_imm16_n, has_imm32_n, min_3_b);
	nand3n	#(1)	a14(has_sib_n, has_disp8, has_disp32_n, min_3_c);
	nor3n	#(1)	a15(min_3_a, min_3_b, min_3_c, min_3);
	wire	[0:0]	min_4;
	wire	[0:0]	min_4_a;
	wire	[0:0]	min_4_b;
	wire	[0:0]	min_4_c;


	nand4n	#(1)	a16(has_prefix1, has_prefix2, has_prefix3_n, has_op2, min_4_a);
	nand4n	#(1)	a17(has_imm8, has_imm16_n, has_imm32_n, has_modrm, min_4_b);
	nand3n	#(1)	a18(has_sib, has_disp8, has_disp32_n, min_4_c);
	nor3n	#(1)	a19(min_4_a, min_4_b, min_4_c, min_4);
	wire	[0:0]	min_5;
	wire	[0:0]	min_5_a;
	wire	[0:0]	min_5_b;
	wire	[0:0]	min_5_c;


	nand4n	#(1)	a20(has_prefix1_n, has_prefix2, has_prefix3_n, has_op2, min_5_a);
	nand3n	#(1)	a21(has_imm8_n, has_imm16_n, has_imm32_n, min_5_b);
	nand3n	#(1)	a22(has_sib_n, has_disp8, has_disp32_n, min_5_c);
	nor3n	#(1)	a23(min_5_a, min_5_b, min_5_c, min_5);
	wire	[0:0]	min_6;
	wire	[0:0]	min_6_a;
	wire	[0:0]	min_6_b;
	wire	[0:0]	min_6_c;


	nand4n	#(1)	a24(has_prefix1, has_prefix2_n, has_prefix3_n, has_op2, min_6_a);
	nand4n	#(1)	a25(has_imm8, has_imm16_n, has_imm32_n, has_modrm, min_6_b);
	nand3n	#(1)	a26(has_sib, has_disp8, has_disp32_n, min_6_c);
	nor3n	#(1)	a27(min_6_a, min_6_b, min_6_c, min_6);
	wire	[0:0]	min_7;
	wire	[0:0]	min_7_a;
	wire	[0:0]	min_7_b;
	wire	[0:0]	min_7_c;


	nand4n	#(1)	a28(has_prefix1, has_prefix2_n, has_prefix3_n, has_op2_n, min_7_a);
	nand3n	#(1)	a29(has_imm8, has_imm16_n, has_imm32_n, min_7_b);
	nand3n	#(1)	a30(has_sib_n, has_disp8, has_disp32_n, min_7_c);
	nor3n	#(1)	a31(min_7_a, min_7_b, min_7_c, min_7);
	wire	[0:0]	min_8;
	wire	[0:0]	min_8_a;
	wire	[0:0]	min_8_b;
	wire	[0:0]	min_8_c;


	nand4n	#(1)	a32(has_prefix1, has_prefix2_n, has_prefix3_n, has_op2, min_8_a);
	nand3n	#(1)	a33(has_imm8_n, has_imm16_n, has_imm32_n, min_8_b);
	nand3n	#(1)	a34(has_sib_n, has_disp8, has_disp32_n, min_8_c);
	nor3n	#(1)	a35(min_8_a, min_8_b, min_8_c, min_8);
	wire	[0:0]	min_9;
	wire	[0:0]	min_9_a;
	wire	[0:0]	min_9_b;
	wire	[0:0]	min_9_c;


	nand4n	#(1)	a36(has_prefix1, has_prefix2_n, has_prefix3_n, has_op2_n, min_9_a);
	nand4n	#(1)	a37(has_imm8_n, has_imm16, has_imm32_n, has_modrm, min_9_b);
	nand3n	#(1)	a38(has_sib, has_disp8, has_disp32_n, min_9_c);
	nor3n	#(1)	a39(min_9_a, min_9_b, min_9_c, min_9);
	wire	[0:0]	min_10;
	wire	[0:0]	min_10_a;
	wire	[0:0]	min_10_b;
	wire	[0:0]	min_10_c;


	nand4n	#(1)	a40(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2_n, min_10_a);
	nand4n	#(1)	a41(has_imm8, has_imm16_n, has_imm32_n, has_modrm, min_10_b);
	nand3n	#(1)	a42(has_sib, has_disp8, has_disp32_n, min_10_c);
	nor3n	#(1)	a43(min_10_a, min_10_b, min_10_c, min_10);
	wire	[0:0]	min_11;
	wire	[0:0]	min_11_a;
	wire	[0:0]	min_11_b;
	wire	[0:0]	min_11_c;


	nand3n	#(1)	a44(has_prefix1_n, has_prefix3_n, has_op2_n, min_11_a);
	nand3n	#(1)	a45(has_imm8_n, has_imm16_n, has_imm32, min_11_b);
	nand3n	#(1)	a46(has_sib_n, has_disp8_n, has_disp32_n, min_11_c);
	nor3n	#(1)	a47(min_11_a, min_11_b, min_11_c, min_11);
	wire	[0:0]	min_12;
	wire	[0:0]	min_12_a;
	wire	[0:0]	min_12_b;
	wire	[0:0]	min_12_c;


	nand4n	#(1)	a48(has_prefix1, has_prefix2, has_prefix3_n, has_op2_n, min_12_a);
	nand4n	#(1)	a49(has_imm8, has_imm16_n, has_imm32_n, has_modrm, min_12_b);
	nand3n	#(1)	a50(has_sib, has_disp8, has_disp32_n, min_12_c);
	nor3n	#(1)	a51(min_12_a, min_12_b, min_12_c, min_12);
	wire	[0:0]	min_13;
	wire	[0:0]	min_13_a;
	wire	[0:0]	min_13_b;
	wire	[0:0]	min_13_c;


	nand4n	#(1)	a52(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2_n, min_13_a);
	nand3n	#(1)	a53(has_imm16_n, has_imm32_n, has_modrm, min_13_b);
	nand3n	#(1)	a54(has_sib_n, has_disp8_n, has_disp32, min_13_c);
	nor3n	#(1)	a55(min_13_a, min_13_b, min_13_c, min_13);
	wire	[0:0]	min_14;
	wire	[0:0]	min_14_a;
	wire	[0:0]	min_14_b;
	wire	[0:0]	min_14_c;


	nand4n	#(1)	a56(has_prefix1, has_prefix2, has_prefix3_n, has_op2, min_14_a);
	nand4n	#(1)	a57(has_imm8_n, has_imm16_n, has_imm32_n, has_modrm, min_14_b);
	nand3n	#(1)	a58(has_sib, has_disp8, has_disp32_n, min_14_c);
	nor3n	#(1)	a59(min_14_a, min_14_b, min_14_c, min_14);
	wire	[0:0]	min_15;
	wire	[0:0]	min_15_a;
	wire	[0:0]	min_15_b;
	wire	[0:0]	min_15_c;


	nand4n	#(1)	a60(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_imm8_n, min_15_a);
	nand3n	#(1)	a61(has_imm16_n, has_imm32_n, has_modrm, min_15_b);
	nand3n	#(1)	a62(has_sib_n, has_disp8_n, has_disp32, min_15_c);
	nor3n	#(1)	a63(min_15_a, min_15_b, min_15_c, min_15);
	wire	[0:0]	min_16;
	wire	[0:0]	min_16_a;
	wire	[0:0]	min_16_b;
	wire	[0:0]	min_16_c;


	nand4n	#(1)	a64(has_prefix1_n, has_prefix2, has_prefix3_n, has_op2_n, min_16_a);
	nand3n	#(1)	a65(has_imm8_n, has_imm16_n, has_modrm, min_16_b);
	nand3n	#(1)	a66(has_sib, has_disp8, has_disp32_n, min_16_c);
	nor3n	#(1)	a67(min_16_a, min_16_b, min_16_c, min_16);
	wire	[0:0]	min_17;
	wire	[0:0]	min_17_a;
	wire	[0:0]	min_17_b;
	wire	[0:0]	min_17_c;


	nand4n	#(1)	a68(has_prefix1, has_prefix2, has_prefix3_n, has_op2, min_17_a);
	nand3n	#(1)	a69(has_imm8, has_imm16_n, has_imm32_n, min_17_b);
	nand3n	#(1)	a70(has_sib_n, has_disp8, has_disp32_n, min_17_c);
	nor3n	#(1)	a71(min_17_a, min_17_b, min_17_c, min_17);
	wire	[0:0]	min_18;
	wire	[0:0]	min_18_a;
	wire	[0:0]	min_18_b;
	wire	[0:0]	min_18_c;


	nand4n	#(1)	a72(has_prefix1, has_prefix3_n, has_op2_n, has_imm8_n, min_18_a);
	nand3n	#(1)	a73(has_imm16, has_imm32_n, has_modrm, min_18_b);
	nand3n	#(1)	a74(has_sib_n, has_disp8, has_disp32_n, min_18_c);
	nor3n	#(1)	a75(min_18_a, min_18_b, min_18_c, min_18);
	wire	[0:0]	min_19;
	wire	[0:0]	min_19_a;
	wire	[0:0]	min_19_b;
	wire	[0:0]	min_19_c;


	nand4n	#(1)	a76(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2_n, min_19_a);
	nand3n	#(1)	a77(has_imm8_n, has_imm16_n, has_modrm, min_19_b);
	nand3n	#(1)	a78(has_sib_n, has_disp8, has_disp32_n, min_19_c);
	nor3n	#(1)	a79(min_19_a, min_19_b, min_19_c, min_19);
	wire	[0:0]	min_20;
	wire	[0:0]	min_20_a;
	wire	[0:0]	min_20_b;
	wire	[0:0]	min_20_c;


	nand4n	#(1)	a80(has_prefix1_n, has_prefix3_n, has_op2_n, has_imm8_n, min_20_a);
	nand3n	#(1)	a81(has_imm16_n, has_imm32_n, has_modrm, min_20_b);
	nand3n	#(1)	a82(has_sib_n, has_disp8_n, has_disp32, min_20_c);
	nor3n	#(1)	a83(min_20_a, min_20_b, min_20_c, min_20);
	wire	[0:0]	min_21;
	wire	[0:0]	min_21_a;
	wire	[0:0]	min_21_b;
	wire	[0:0]	min_21_c;


	nand4n	#(1)	a84(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2_n, min_21_a);
	nand3n	#(1)	a85(has_imm8_n, has_imm16_n, has_imm32_n, min_21_b);
	nand3n	#(1)	a86(has_modrm, has_disp8_n, has_disp32, min_21_c);
	nor3n	#(1)	a87(min_21_a, min_21_b, min_21_c, min_21);
	wire	[0:0]	min_22;
	wire	[0:0]	min_22_a;
	wire	[0:0]	min_22_b;
	wire	[0:0]	min_22_c;


	nand4n	#(1)	a88(has_prefix1, has_prefix2_n, has_prefix3_n, has_op2_n, min_22_a);
	nand3n	#(1)	a89(has_imm8_n, has_imm16_n, has_modrm, min_22_b);
	nand3n	#(1)	a90(has_sib, has_disp8, has_disp32_n, min_22_c);
	nor3n	#(1)	a91(min_22_a, min_22_b, min_22_c, min_22);
	wire	[0:0]	min_23;
	wire	[0:0]	min_23_a;
	wire	[0:0]	min_23_b;
	wire	[0:0]	min_23_c;


	nand4n	#(1)	a92(has_prefix2, has_prefix3_n, has_op2, has_imm8, min_23_a);
	nand3n	#(1)	a93(has_imm16_n, has_imm32_n, has_modrm, min_23_b);
	nand3n	#(1)	a94(has_sib_n, has_disp8, has_disp32_n, min_23_c);
	nor3n	#(1)	a95(min_23_a, min_23_b, min_23_c, min_23);
	wire	[0:0]	min_24;
	wire	[0:0]	min_24_a;
	wire	[0:0]	min_24_b;
	wire	[0:0]	min_24_c;


	nand4n	#(1)	a96(has_prefix2_n, has_prefix3_n, has_op2_n, has_imm8_n, min_24_a);
	nand3n	#(1)	a97(has_imm16_n, has_imm32_n, has_modrm, min_24_b);
	nand3n	#(1)	a98(has_sib_n, has_disp8_n, has_disp32, min_24_c);
	nor3n	#(1)	a99(min_24_a, min_24_b, min_24_c, min_24);
	wire	[0:0]	min_25;
	wire	[0:0]	min_25_a;
	wire	[0:0]	min_25_b;
	wire	[0:0]	min_25_c;


	nand4n	#(1)	a100(has_prefix1_n, has_prefix2, has_prefix3_n, has_op2, min_25_a);
	nand4n	#(1)	a101(has_imm8, has_imm16_n, has_imm32_n, has_modrm, min_25_b);
	nand3n	#(1)	a102(has_sib, has_disp8, has_disp32_n, min_25_c);
	nor3n	#(1)	a103(min_25_a, min_25_b, min_25_c, min_25);
	wire	[0:0]	min_26;
	wire	[0:0]	min_26_a;
	wire	[0:0]	min_26_b;
	wire	[0:0]	min_26_c;


	nand3n	#(1)	a104(has_prefix2, has_prefix3_n, has_op2_n, min_26_a);
	nand3n	#(1)	a105(has_imm8_n, has_imm16_n, has_imm32, min_26_b);
	nand3n	#(1)	a106(has_sib, has_disp8_n, has_disp32, min_26_c);
	nor3n	#(1)	a107(min_26_a, min_26_b, min_26_c, min_26);
	wire	[0:0]	min_27;
	wire	[0:0]	min_27_a;
	wire	[0:0]	min_27_b;
	wire	[0:0]	min_27_c;


	nand4n	#(1)	a108(has_prefix1_n, has_prefix2, has_prefix3_n, has_op2, min_27_a);
	nand3n	#(1)	a109(has_imm8, has_imm16_n, has_imm32_n, min_27_b);
	nand3n	#(1)	a110(has_modrm, has_sib_n, has_disp8_n, min_27_c);
	nor3n	#(1)	a111(min_27_a, min_27_b, min_27_c, min_27);
	wire	[0:0]	min_28;
	wire	[0:0]	min_28_a;
	wire	[0:0]	min_28_b;


	nand4n	#(1)	a112(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2_n, min_28_a);
	nand4n	#(1)	a113(has_imm8_n, has_imm32, has_sib_n, has_disp32_n, min_28_b);
	nor2n	#(1)	a114(min_28_a, min_28_b, min_28);
	wire	[0:0]	min_29;
	wire	[0:0]	min_29_a;
	wire	[0:0]	min_29_b;
	wire	[0:0]	min_29_c;


	nand4n	#(1)	a115(has_prefix1, has_prefix3_n, has_op2, has_imm8, min_29_a);
	nand3n	#(1)	a116(has_imm16_n, has_imm32_n, has_modrm, min_29_b);
	nand3n	#(1)	a117(has_sib_n, has_disp8, has_disp32_n, min_29_c);
	nor3n	#(1)	a118(min_29_a, min_29_b, min_29_c, min_29);
	wire	[0:0]	min_30;
	wire	[0:0]	min_30_a;
	wire	[0:0]	min_30_b;
	wire	[0:0]	min_30_c;


	nand3n	#(1)	a119(has_prefix2_n, has_prefix3_n, has_op2_n, min_30_a);
	nand3n	#(1)	a120(has_imm8_n, has_imm16_n, has_imm32, min_30_b);
	nand3n	#(1)	a121(has_sib_n, has_disp8_n, has_disp32_n, min_30_c);
	nor3n	#(1)	a122(min_30_a, min_30_b, min_30_c, min_30);
	wire	[0:0]	min_31;
	wire	[0:0]	min_31_a;
	wire	[0:0]	min_31_b;
	wire	[0:0]	min_31_c;


	nand3n	#(1)	a123(has_prefix1, has_prefix3_n, has_op2_n, min_31_a);
	nand3n	#(1)	a124(has_imm8_n, has_imm16_n, has_imm32, min_31_b);
	nand3n	#(1)	a125(has_sib, has_disp8_n, has_disp32, min_31_c);
	nor3n	#(1)	a126(min_31_a, min_31_b, min_31_c, min_31);
	wire	[0:0]	min_32;
	wire	[0:0]	min_32_a;
	wire	[0:0]	min_32_b;
	wire	[0:0]	min_32_c;


	nand4n	#(1)	a127(has_prefix1, has_prefix2, has_prefix3_n, has_imm8, min_32_a);
	nand3n	#(1)	a128(has_imm16_n, has_imm32_n, has_modrm, min_32_b);
	nand3n	#(1)	a129(has_sib_n, has_disp8, has_disp32_n, min_32_c);
	nor3n	#(1)	a130(min_32_a, min_32_b, min_32_c, min_32);
	wire	[0:0]	min_33;
	wire	[0:0]	min_33_a;
	wire	[0:0]	min_33_b;
	wire	[0:0]	min_33_c;


	nand4n	#(1)	a131(has_prefix1, has_prefix2_n, has_prefix3_n, has_op2, min_33_a);
	nand3n	#(1)	a132(has_imm8, has_imm16_n, has_imm32_n, min_33_b);
	nand3n	#(1)	a133(has_modrm, has_sib_n, has_disp8_n, min_33_c);
	nor3n	#(1)	a134(min_33_a, min_33_b, min_33_c, min_33);
	wire	[0:0]	min_34;
	wire	[0:0]	min_34_a;
	wire	[0:0]	min_34_b;
	wire	[0:0]	min_34_c;


	nand4n	#(1)	a135(has_prefix1, has_prefix2, has_prefix3_n, has_op2, min_34_a);
	nand3n	#(1)	a136(has_imm16_n, has_imm32_n, has_modrm, min_34_b);
	nand3n	#(1)	a137(has_sib_n, has_disp8, has_disp32_n, min_34_c);
	nor3n	#(1)	a138(min_34_a, min_34_b, min_34_c, min_34);
	wire	[0:0]	min_35;
	wire	[0:0]	min_35_a;
	wire	[0:0]	min_35_b;
	wire	[0:0]	min_35_c;


	nand3n	#(1)	a139(has_prefix1, has_prefix2, has_prefix3_n, min_35_a);
	nand3n	#(1)	a140(has_op2_n, has_imm8_n, has_imm16_n, min_35_b);
	nand3n	#(1)	a141(has_imm32, has_disp8_n, has_disp32, min_35_c);
	nor3n	#(1)	a142(min_35_a, min_35_b, min_35_c, min_35);
	wire	[0:0]	min_36;
	wire	[0:0]	min_36_a;
	wire	[0:0]	min_36_b;
	wire	[0:0]	min_36_c;


	nand3n	#(1)	a143(has_prefix3_n, has_op2_n, has_imm8_n, min_36_a);
	nand3n	#(1)	a144(has_imm16_n, has_imm32, has_modrm, min_36_b);
	nand3n	#(1)	a145(has_sib, has_disp8, has_disp32_n, min_36_c);
	nor3n	#(1)	a146(min_36_a, min_36_b, min_36_c, min_36);
	wire	[0:0]	min_37;
	wire	[0:0]	min_37_a;
	wire	[0:0]	min_37_b;


	nand4n	#(1)	a147(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2_n, min_37_a);
	nand4n	#(1)	a148(has_imm8_n, has_imm32, has_disp8_n, has_disp32_n, min_37_b);
	nor2n	#(1)	a149(min_37_a, min_37_b, min_37);
	wire	[0:0]	min_38;
	wire	[0:0]	min_38_a;
	wire	[0:0]	min_38_b;
	wire	[0:0]	min_38_c;


	nand4n	#(1)	a150(has_prefix2, has_prefix3_n, has_op2, has_imm8_n, min_38_a);
	nand3n	#(1)	a151(has_imm16_n, has_imm32_n, has_modrm, min_38_b);
	nand3n	#(1)	a152(has_sib, has_disp8, has_disp32_n, min_38_c);
	nor3n	#(1)	a153(min_38_a, min_38_b, min_38_c, min_38);
	wire	[0:0]	min_39;
	wire	[0:0]	min_39_a;
	wire	[0:0]	min_39_b;


	nand4n	#(1)	a154(has_prefix1, has_prefix2_n, has_prefix3, has_op2_n, min_39_a);
	nand4n	#(1)	a155(has_imm8_n, has_imm16_n, has_imm32_n, has_modrm_n, min_39_b);
	nor2n	#(1)	a156(min_39_a, min_39_b, min_39);
	wire	[0:0]	min_40;
	wire	[0:0]	min_40_a;
	wire	[0:0]	min_40_b;
	wire	[0:0]	min_40_c;


	nand4n	#(1)	a157(has_prefix1, has_prefix3_n, has_op2, has_imm8_n, min_40_a);
	nand3n	#(1)	a158(has_imm16_n, has_imm32_n, has_modrm, min_40_b);
	nand3n	#(1)	a159(has_sib_n, has_disp8_n, has_disp32, min_40_c);
	nor3n	#(1)	a160(min_40_a, min_40_b, min_40_c, min_40);
	wire	[0:0]	min_41;
	wire	[0:0]	min_41_a;
	wire	[0:0]	min_41_b;
	wire	[0:0]	min_41_c;


	nand4n	#(1)	a161(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2_n, min_41_a);
	nand3n	#(1)	a162(has_imm8, has_imm16_n, has_imm32_n, min_41_b);
	nand3n	#(1)	a163(has_modrm, has_sib_n, has_disp8_n, min_41_c);
	nor3n	#(1)	a164(min_41_a, min_41_b, min_41_c, min_41);
	wire	[0:0]	min_42;
	wire	[0:0]	min_42_a;
	wire	[0:0]	min_42_b;
	wire	[0:0]	min_42_c;


	nand4n	#(1)	a165(has_prefix2_n, has_prefix3_n, has_op2, has_imm8, min_42_a);
	nand3n	#(1)	a166(has_imm16_n, has_imm32_n, has_modrm, min_42_b);
	nand3n	#(1)	a167(has_sib, has_disp8, has_disp32_n, min_42_c);
	nor3n	#(1)	a168(min_42_a, min_42_b, min_42_c, min_42);
	wire	[0:0]	min_43;
	wire	[0:0]	min_43_a;
	wire	[0:0]	min_43_b;
	wire	[0:0]	min_43_c;


	nand4n	#(1)	a169(has_prefix1, has_prefix3_n, has_op2, has_imm8_n, min_43_a);
	nand3n	#(1)	a170(has_imm16_n, has_imm32_n, has_modrm, min_43_b);
	nand3n	#(1)	a171(has_sib, has_disp8, has_disp32_n, min_43_c);
	nor3n	#(1)	a172(min_43_a, min_43_b, min_43_c, min_43);
	wire	[0:0]	min_44;
	wire	[0:0]	min_44_a;
	wire	[0:0]	min_44_b;
	wire	[0:0]	min_44_c;


	nand3n	#(1)	a173(has_prefix1_n, has_prefix2_n, has_prefix3_n, min_44_a);
	nand3n	#(1)	a174(has_op2, has_imm8, has_imm16_n, min_44_b);
	nand3n	#(1)	a175(has_imm32_n, has_sib, has_disp8_n, min_44_c);
	nor3n	#(1)	a176(min_44_a, min_44_b, min_44_c, min_44);
	wire	[0:0]	min_45;
	wire	[0:0]	min_45_a;
	wire	[0:0]	min_45_b;
	wire	[0:0]	min_45_c;


	nand4n	#(1)	a177(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2, min_45_a);
	nand3n	#(1)	a178(has_imm8_n, has_imm16_n, has_imm32_n, min_45_b);
	nand3n	#(1)	a179(has_modrm, has_sib_n, has_disp8_n, min_45_c);
	nor3n	#(1)	a180(min_45_a, min_45_b, min_45_c, min_45);
	wire	[0:0]	min_46;
	wire	[0:0]	min_46_a;
	wire	[0:0]	min_46_b;


	nand4n	#(1)	a181(has_prefix1, has_prefix3_n, has_op2_n, has_imm8_n, min_46_a);
	nand4n	#(1)	a182(has_imm16, has_modrm, has_disp8_n, has_disp32, min_46_b);
	nor2n	#(1)	a183(min_46_a, min_46_b, min_46);
	wire	[0:0]	min_47;
	wire	[0:0]	min_47_a;
	wire	[0:0]	min_47_b;
	wire	[0:0]	min_47_c;


	nand4n	#(1)	a184(has_prefix1, has_prefix2, has_prefix3_n, has_op2_n, min_47_a);
	nand3n	#(1)	a185(has_imm8, has_imm16_n, has_imm32_n, min_47_b);
	nand3n	#(1)	a186(has_modrm, has_sib_n, has_disp8_n, min_47_c);
	nor3n	#(1)	a187(min_47_a, min_47_b, min_47_c, min_47);
	wire	[0:0]	min_48;
	wire	[0:0]	min_48_a;
	wire	[0:0]	min_48_b;


	nand4n	#(1)	a188(has_prefix1, has_prefix2, has_prefix3, has_op2_n, min_48_a);
	nand4n	#(1)	a189(has_imm8_n, has_imm16_n, has_imm32_n, has_modrm_n, min_48_b);
	nor2n	#(1)	a190(min_48_a, min_48_b, min_48);
	wire	[0:0]	min_49;
	wire	[0:0]	min_49_a;
	wire	[0:0]	min_49_b;
	wire	[0:0]	min_49_c;


	nand3n	#(1)	a191(has_prefix1, has_prefix3_n, has_op2_n, min_49_a);
	nand3n	#(1)	a192(has_imm8_n, has_imm16, has_imm32_n, min_49_b);
	nand3n	#(1)	a193(has_modrm, has_sib, has_disp8_n, min_49_c);
	nor3n	#(1)	a194(min_49_a, min_49_b, min_49_c, min_49);
	wire	[0:0]	min_50;
	wire	[0:0]	min_50_a;
	wire	[0:0]	min_50_b;
	wire	[0:0]	min_50_c;


	nand4n	#(1)	a195(has_prefix1, has_prefix2, has_prefix3_n, has_op2, min_50_a);
	nand3n	#(1)	a196(has_imm8_n, has_imm16_n, has_imm32_n, min_50_b);
	nand3n	#(1)	a197(has_modrm, has_sib_n, has_disp8_n, min_50_c);
	nor3n	#(1)	a198(min_50_a, min_50_b, min_50_c, min_50);
	wire	[0:0]	min_51;
	wire	[0:0]	min_51_a;
	wire	[0:0]	min_51_b;
	wire	[0:0]	min_51_c;


	nand3n	#(1)	a199(has_prefix1, has_prefix2, has_prefix3_n, min_51_a);
	nand3n	#(1)	a200(has_op2_n, has_imm8_n, has_imm16_n, min_51_b);
	nand3n	#(1)	a201(has_sib, has_disp8, has_disp32_n, min_51_c);
	nor3n	#(1)	a202(min_51_a, min_51_b, min_51_c, min_51);
	wire	[0:0]	min_52;
	wire	[0:0]	min_52_a;
	wire	[0:0]	min_52_b;


	nand4n	#(1)	a203(has_prefix1_n, has_prefix2, has_prefix3, has_op2_n, min_52_a);
	nand4n	#(1)	a204(has_imm8_n, has_imm16_n, has_imm32_n, has_modrm_n, min_52_b);
	nor2n	#(1)	a205(min_52_a, min_52_b, min_52);
	wire	[0:0]	min_53;
	wire	[0:0]	min_53_a;
	wire	[0:0]	min_53_b;


	nand4n	#(1)	a206(has_prefix2, has_prefix3_n, has_op2_n, has_imm8_n, min_53_a);
	nand4n	#(1)	a207(has_imm32, has_modrm, has_disp8, has_disp32_n, min_53_b);
	nor2n	#(1)	a208(min_53_a, min_53_b, min_53);
	wire	[0:0]	min_54;
	wire	[0:0]	min_54_a;
	wire	[0:0]	min_54_b;


	nand4n	#(1)	a209(has_prefix1, has_prefix2, has_prefix3_n, has_op2, min_54_a);
	nand4n	#(1)	a210(has_imm8_n, has_imm16, has_imm32_n, has_modrm_n, min_54_b);
	nor2n	#(1)	a211(min_54_a, min_54_b, min_54);
	wire	[0:0]	min_55;
	wire	[0:0]	min_55_a;
	wire	[0:0]	min_55_b;
	wire	[0:0]	min_55_c;


	nand3n	#(1)	a212(has_prefix1, has_prefix2, has_prefix3_n, min_55_a);
	nand3n	#(1)	a213(has_op2_n, has_imm8_n, has_imm16, min_55_b);
	nand3n	#(1)	a214(has_imm32_n, has_modrm, has_disp8_n, min_55_c);
	nor3n	#(1)	a215(min_55_a, min_55_b, min_55_c, min_55);
	wire	[0:0]	min_56;
	wire	[0:0]	min_56_a;
	wire	[0:0]	min_56_b;


	nand4n	#(1)	a216(has_prefix2, has_prefix3_n, has_op2_n, has_imm8_n, min_56_a);
	nand4n	#(1)	a217(has_imm32, has_modrm, has_sib, has_disp32_n, min_56_b);
	nor2n	#(1)	a218(min_56_a, min_56_b, min_56);
	wire	[0:0]	min_57;
	wire	[0:0]	min_57_a;
	wire	[0:0]	min_57_b;


	nand4n	#(1)	a219(has_prefix1, has_prefix3_n, has_op2_n, has_imm8_n, min_57_a);
	nand4n	#(1)	a220(has_imm32, has_modrm, has_disp8, has_disp32_n, min_57_b);
	nor2n	#(1)	a221(min_57_a, min_57_b, min_57);
	wire	[0:0]	min_58;
	wire	[0:0]	min_58_a;
	wire	[0:0]	min_58_b;
	wire	[0:0]	min_58_c;


	nand4n	#(1)	a222(has_prefix2, has_prefix3_n, has_op2_n, has_imm8, min_58_a);
	nand3n	#(1)	a223(has_imm16_n, has_imm32_n, has_modrm, min_58_b);
	nand3n	#(1)	a224(has_sib, has_disp8, has_disp32_n, min_58_c);
	nor3n	#(1)	a225(min_58_a, min_58_b, min_58_c, min_58);
	wire	[0:0]	min_59;
	wire	[0:0]	min_59_a;
	wire	[0:0]	min_59_b;
	wire	[0:0]	min_59_c;


	nand3n	#(1)	a226(has_prefix1_n, has_prefix2, has_prefix3_n, min_59_a);
	nand3n	#(1)	a227(has_op2_n, has_imm8, has_imm16_n, min_59_b);
	nand3n	#(1)	a228(has_imm32_n, has_sib, has_disp8_n, min_59_c);
	nor3n	#(1)	a229(min_59_a, min_59_b, min_59_c, min_59);
	wire	[0:0]	min_60;
	wire	[0:0]	min_60_a;
	wire	[0:0]	min_60_b;


	nand4n	#(1)	a230(has_prefix1, has_prefix3_n, has_op2_n, has_imm8_n, min_60_a);
	nand4n	#(1)	a231(has_imm32, has_modrm, has_sib, has_disp32_n, min_60_b);
	nor2n	#(1)	a232(min_60_a, min_60_b, min_60);
	wire	[0:0]	min_61;
	wire	[0:0]	min_61_a;
	wire	[0:0]	min_61_b;
	wire	[0:0]	min_61_c;


	nand3n	#(1)	a233(has_prefix1, has_prefix2_n, has_prefix3_n, min_61_a);
	nand3n	#(1)	a234(has_op2_n, has_imm8_n, has_imm32_n, min_61_b);
	nand3n	#(1)	a235(has_modrm, has_sib_n, has_disp8_n, min_61_c);
	nor3n	#(1)	a236(min_61_a, min_61_b, min_61_c, min_61);
	wire	[0:0]	min_62;
	wire	[0:0]	min_62_a;
	wire	[0:0]	min_62_b;
	wire	[0:0]	min_62_c;


	nand4n	#(1)	a237(has_prefix1, has_prefix3_n, has_op2_n, has_imm8, min_62_a);
	nand3n	#(1)	a238(has_imm16_n, has_imm32_n, has_modrm, min_62_b);
	nand3n	#(1)	a239(has_sib, has_disp8, has_disp32_n, min_62_c);
	nor3n	#(1)	a240(min_62_a, min_62_b, min_62_c, min_62);
	wire	[0:0]	min_63;
	wire	[0:0]	min_63_a;
	wire	[0:0]	min_63_b;


	nand4n	#(1)	a241(has_prefix1, has_prefix2, has_prefix3_n, has_op2_n, min_63_a);
	nand4n	#(1)	a242(has_imm8_n, has_sib_n, has_disp8, has_disp32_n, min_63_b);
	nor2n	#(1)	a243(min_63_a, min_63_b, min_63);
	wire	[0:0]	min_64;
	wire	[0:0]	min_64_a;
	wire	[0:0]	min_64_b;
	wire	[0:0]	min_64_c;


	nand3n	#(1)	a244(has_prefix1_n, has_prefix2, has_prefix3_n, min_64_a);
	nand3n	#(1)	a245(has_op2, has_imm8_n, has_imm16_n, min_64_b);
	nand3n	#(1)	a246(has_imm32_n, has_sib, has_disp8_n, min_64_c);
	nor3n	#(1)	a247(min_64_a, min_64_b, min_64_c, min_64);
	wire	[0:0]	min_65;
	wire	[0:0]	min_65_a;
	wire	[0:0]	min_65_b;
	wire	[0:0]	min_65_c;


	nand3n	#(1)	a248(has_prefix1, has_prefix2_n, has_prefix3_n, min_65_a);
	nand3n	#(1)	a249(has_op2_n, has_imm8_n, has_imm16_n, min_65_b);
	nand3n	#(1)	a250(has_modrm, has_sib_n, has_disp8_n, min_65_c);
	nor3n	#(1)	a251(min_65_a, min_65_b, min_65_c, min_65);
	wire	[0:0]	min_66;
	wire	[0:0]	min_66_a;
	wire	[0:0]	min_66_b;
	wire	[0:0]	min_66_c;


	nand3n	#(1)	a252(has_prefix1, has_prefix2_n, has_prefix3_n, min_66_a);
	nand3n	#(1)	a253(has_op2_n, has_imm8, has_imm16_n, min_66_b);
	nand3n	#(1)	a254(has_imm32_n, has_sib, has_disp8_n, min_66_c);
	nor3n	#(1)	a255(min_66_a, min_66_b, min_66_c, min_66);
	wire	[0:0]	min_67;
	wire	[0:0]	min_67_a;
	wire	[0:0]	min_67_b;


	nand4n	#(1)	a256(has_prefix2_n, has_prefix3, has_op2_n, has_imm8_n, min_67_a);
	nand3n	#(1)	a257(has_imm16_n, has_imm32_n, has_modrm_n, min_67_b);
	nor2n	#(1)	a258(min_67_a, min_67_b, min_67);
	wire	[0:0]	min_68;
	wire	[0:0]	min_68_a;
	wire	[0:0]	min_68_b;
	wire	[0:0]	min_68_c;


	nand3n	#(1)	a259(has_prefix1, has_prefix2_n, has_prefix3_n, min_68_a);
	nand3n	#(1)	a260(has_op2, has_imm8_n, has_imm16_n, min_68_b);
	nand3n	#(1)	a261(has_imm32_n, has_sib, has_disp8_n, min_68_c);
	nor3n	#(1)	a262(min_68_a, min_68_b, min_68_c, min_68);
	wire	[0:0]	min_69;
	wire	[0:0]	min_69_a;
	wire	[0:0]	min_69_b;
	wire	[0:0]	min_69_c;


	nand3n	#(1)	a263(has_prefix1, has_prefix2, has_prefix3_n, min_69_a);
	nand3n	#(1)	a264(has_op2, has_imm8, has_imm16_n, min_69_b);
	nand3n	#(1)	a265(has_imm32_n, has_sib, has_disp8_n, min_69_c);
	nor3n	#(1)	a266(min_69_a, min_69_b, min_69_c, min_69);
	wire	[0:0]	min_70;
	wire	[0:0]	min_70_a;
	wire	[0:0]	min_70_b;


	nand4n	#(1)	a267(has_prefix3_n, has_op2_n, has_imm8_n, has_imm16_n, min_70_a);
	nand4n	#(1)	a268(has_imm32, has_modrm, has_disp8_n, has_disp32, min_70_b);
	nor2n	#(1)	a269(min_70_a, min_70_b, min_70);
	wire	[0:0]	min_71;
	wire	[0:0]	min_71_a;
	wire	[0:0]	min_71_b;
	wire	[0:0]	min_71_c;


	nand3n	#(1)	a270(has_prefix1_n, has_prefix2_n, has_prefix3_n, min_71_a);
	nand3n	#(1)	a271(has_op2_n, has_imm8_n, has_imm16_n, min_71_b);
	nand3n	#(1)	a272(has_modrm, has_sib, has_disp8_n, min_71_c);
	nor3n	#(1)	a273(min_71_a, min_71_b, min_71_c, min_71);
	wire	[0:0]	min_72;
	wire	[0:0]	min_72_a;
	wire	[0:0]	min_72_b;
	wire	[0:0]	min_72_c;


	nand3n	#(1)	a274(has_prefix2, has_prefix3_n, has_op2, min_72_a);
	nand3n	#(1)	a275(has_imm8, has_imm16_n, has_imm32_n, min_72_b);
	nand3n	#(1)	a276(has_modrm, has_sib, has_disp8_n, min_72_c);
	nor3n	#(1)	a277(min_72_a, min_72_b, min_72_c, min_72);
	wire	[0:0]	min_73;
	wire	[0:0]	min_73_a;
	wire	[0:0]	min_73_b;
	wire	[0:0]	min_73_c;


	nand3n	#(1)	a278(has_prefix1_n, has_prefix2, has_prefix3_n, min_73_a);
	nand3n	#(1)	a279(has_op2_n, has_imm8_n, has_imm16_n, min_73_b);
	nand3n	#(1)	a280(has_modrm, has_sib_n, has_disp8_n, min_73_c);
	nor3n	#(1)	a281(min_73_a, min_73_b, min_73_c, min_73);
	wire	[0:0]	min_74;
	wire	[0:0]	min_74_a;
	wire	[0:0]	min_74_b;


	nand4n	#(1)	a282(has_prefix1, has_prefix3_n, has_op2_n, has_imm8_n, min_74_a);
	nand4n	#(1)	a283(has_imm16, has_imm32_n, has_disp8_n, has_disp32_n, min_74_b);
	nor2n	#(1)	a284(min_74_a, min_74_b, min_74);
	wire	[0:0]	min_75;
	wire	[0:0]	min_75_a;
	wire	[0:0]	min_75_b;
	wire	[0:0]	min_75_c;


	nand3n	#(1)	a285(has_prefix1, has_prefix3_n, has_op2, min_75_a);
	nand3n	#(1)	a286(has_imm8, has_imm16_n, has_imm32_n, min_75_b);
	nand3n	#(1)	a287(has_modrm, has_sib, has_disp8_n, min_75_c);
	nor3n	#(1)	a288(min_75_a, min_75_b, min_75_c, min_75);
	wire	[0:0]	min_76;
	wire	[0:0]	min_76_a;
	wire	[0:0]	min_76_b;
	wire	[0:0]	min_76_c;


	nand3n	#(1)	a289(has_prefix1, has_prefix2, has_prefix3_n, min_76_a);
	nand3n	#(1)	a290(has_imm8, has_imm16_n, has_imm32_n, min_76_b);
	nand3n	#(1)	a291(has_modrm, has_sib, has_disp8_n, min_76_c);
	nor3n	#(1)	a292(min_76_a, min_76_b, min_76_c, min_76);
	wire	[0:0]	min_77;
	wire	[0:0]	min_77_a;
	wire	[0:0]	min_77_b;
	wire	[0:0]	min_77_c;


	nand3n	#(1)	a293(has_prefix1, has_prefix2, has_prefix3_n, min_77_a);
	nand3n	#(1)	a294(has_op2, has_imm16_n, has_imm32_n, min_77_b);
	nand3n	#(1)	a295(has_modrm, has_sib, has_disp8_n, min_77_c);
	nor3n	#(1)	a296(min_77_a, min_77_b, min_77_c, min_77);
	wire	[0:0]	min_78;
	wire	[0:0]	min_78_a;
	wire	[0:0]	min_78_b;
	wire	[0:0]	min_78_c;


	nand3n	#(1)	a297(has_prefix1, has_prefix2, has_prefix3_n, min_78_a);
	nand3n	#(1)	a298(has_op2, has_imm8, has_imm16_n, min_78_b);
	nand3n	#(1)	a299(has_imm32_n, has_modrm, has_disp8_n, min_78_c);
	nor3n	#(1)	a300(min_78_a, min_78_b, min_78_c, min_78);
	wire	[0:0]	min_79;
	wire	[0:0]	min_79_a;
	wire	[0:0]	min_79_b;


	nand4n	#(1)	a301(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2, min_79_a);
	nand4n	#(1)	a302(has_imm8, has_imm16_n, has_imm32_n, has_modrm_n, min_79_b);
	nor2n	#(1)	a303(min_79_a, min_79_b, min_79);
	wire	[0:0]	min_80;
	wire	[0:0]	min_80_a;
	wire	[0:0]	min_80_b;


	nand4n	#(1)	a304(has_prefix1, has_prefix2_n, has_prefix3_n, has_op2_n, min_80_a);
	nand4n	#(1)	a305(has_imm8, has_imm16_n, has_imm32_n, has_modrm_n, min_80_b);
	nor2n	#(1)	a306(min_80_a, min_80_b, min_80);
	wire	[0:0]	min_81;
	wire	[0:0]	min_81_a;
	wire	[0:0]	min_81_b;


	nand4n	#(1)	a307(has_prefix3_n, has_imm8, has_imm16_n, has_imm32_n, min_81_a);
	nand4n	#(1)	a308(has_modrm, has_sib, has_disp8_n, has_disp32, min_81_b);
	nor2n	#(1)	a309(min_81_a, min_81_b, min_81);
	wire	[0:0]	min_82;
	wire	[0:0]	min_82_a;
	wire	[0:0]	min_82_b;


	nand4n	#(1)	a310(has_prefix3_n, has_op2, has_imm16_n, has_imm32_n, min_82_a);
	nand4n	#(1)	a311(has_modrm, has_sib, has_disp8_n, has_disp32, min_82_b);
	nor2n	#(1)	a312(min_82_a, min_82_b, min_82);
	wire	[0:0]	min_83;
	wire	[0:0]	min_83_a;
	wire	[0:0]	min_83_b;


	nand4n	#(1)	a313(has_prefix3_n, has_op2, has_imm8, has_imm16_n, min_83_a);
	nand4n	#(1)	a314(has_imm32_n, has_modrm, has_disp8_n, has_disp32, min_83_b);
	nor2n	#(1)	a315(min_83_a, min_83_b, min_83);
	wire	[0:0]	min_84;
	wire	[0:0]	min_84_a;
	wire	[0:0]	min_84_b;


	nand4n	#(1)	a316(has_prefix1, has_prefix2, has_prefix3_n, has_op2, min_84_a);
	nand4n	#(1)	a317(has_imm8, has_imm16_n, has_imm32_n, has_modrm_n, min_84_b);
	nor2n	#(1)	a318(min_84_a, min_84_b, min_84);
	wire	[0:0]	min_85;
	wire	[0:0]	min_85_a;
	wire	[0:0]	min_85_b;


	nand4n	#(1)	a319(has_prefix2_n, has_prefix3_n, has_op2_n, has_imm8_n, min_85_a);
	nand4n	#(1)	a320(has_imm16_n, has_modrm, has_sib_n, has_disp8_n, min_85_b);
	nor2n	#(1)	a321(min_85_a, min_85_b, min_85);
	wire	[0:0]	min_86;
	wire	[0:0]	min_86_a;
	wire	[0:0]	min_86_b;


	nand4n	#(1)	a322(has_prefix2, has_prefix3_n, has_imm16_n, has_imm32_n, min_86_a);
	nand4n	#(1)	a323(has_modrm, has_sib, has_disp8_n, has_disp32, min_86_b);
	nor2n	#(1)	a324(min_86_a, min_86_b, min_86);
	wire	[0:0]	min_87;
	wire	[0:0]	min_87_a;
	wire	[0:0]	min_87_b;


	nand4n	#(1)	a325(has_prefix2, has_prefix3_n, has_imm8, has_imm16_n, min_87_a);
	nand4n	#(1)	a326(has_imm32_n, has_modrm, has_disp8_n, has_disp32, min_87_b);
	nor2n	#(1)	a327(min_87_a, min_87_b, min_87);
	wire	[0:0]	min_88;
	wire	[0:0]	min_88_a;
	wire	[0:0]	min_88_b;


	nand4n	#(1)	a328(has_prefix2, has_prefix3_n, has_op2, has_imm16_n, min_88_a);
	nand4n	#(1)	a329(has_imm32_n, has_modrm, has_disp8_n, has_disp32, min_88_b);
	nor2n	#(1)	a330(min_88_a, min_88_b, min_88);
	wire	[0:0]	min_89;
	wire	[0:0]	min_89_a;
	wire	[0:0]	min_89_b;


	nand4n	#(1)	a331(has_prefix1, has_prefix3_n, has_imm16_n, has_imm32_n, min_89_a);
	nand4n	#(1)	a332(has_modrm, has_sib, has_disp8_n, has_disp32, min_89_b);
	nor2n	#(1)	a333(min_89_a, min_89_b, min_89);
	wire	[0:0]	min_90;
	wire	[0:0]	min_90_a;
	wire	[0:0]	min_90_b;


	nand4n	#(1)	a334(has_prefix1, has_prefix3_n, has_imm8, has_imm16_n, min_90_a);
	nand4n	#(1)	a335(has_imm32_n, has_modrm, has_disp8_n, has_disp32, min_90_b);
	nor2n	#(1)	a336(min_90_a, min_90_b, min_90);
	wire	[0:0]	min_91;
	wire	[0:0]	min_91_a;
	wire	[0:0]	min_91_b;


	nand4n	#(1)	a337(has_prefix1_n, has_prefix2_n, has_prefix3_n, has_op2_n, min_91_a);
	nand3n	#(1)	a338(has_imm8_n, has_imm16_n, has_modrm_n, min_91_b);
	nor2n	#(1)	a339(min_91_a, min_91_b, min_91);
	wire	[0:0]	min_92;
	wire	[0:0]	min_92_a;
	wire	[0:0]	min_92_b;


	nand4n	#(1)	a340(has_prefix1_n, has_prefix2, has_prefix3_n, has_op2_n, min_92_a);
	nand4n	#(1)	a341(has_imm8, has_imm16_n, has_imm32_n, has_modrm_n, min_92_b);
	nor2n	#(1)	a342(min_92_a, min_92_b, min_92);
	wire	[0:0]	min_93;
	wire	[0:0]	min_93_a;
	wire	[0:0]	min_93_b;


	nand4n	#(1)	a343(has_prefix3_n, has_imm8, has_imm16_n, has_imm32_n, min_93_a);
	nand4n	#(1)	a344(has_modrm, has_sib_n, has_disp8, has_disp32_n, min_93_b);
	nor2n	#(1)	a345(min_93_a, min_93_b, min_93);
	wire	[0:0]	min_94;
	wire	[0:0]	min_94_a;
	wire	[0:0]	min_94_b;


	nand4n	#(1)	a346(has_prefix1, has_prefix2, has_prefix3_n, has_imm16_n, min_94_a);
	nand4n	#(1)	a347(has_imm32_n, has_modrm, has_disp8_n, has_disp32, min_94_b);
	nor2n	#(1)	a348(min_94_a, min_94_b, min_94);
	wire	[0:0]	min_95;
	wire	[0:0]	min_95_a;
	wire	[0:0]	min_95_b;


	nand4n	#(1)	a349(has_prefix3_n, has_op2, has_imm16_n, has_imm32_n, min_95_a);
	nand4n	#(1)	a350(has_modrm, has_sib_n, has_disp8, has_disp32_n, min_95_b);
	nor2n	#(1)	a351(min_95_a, min_95_b, min_95);
	wire	[0:0]	min_96;
	wire	[0:0]	min_96_a;
	wire	[0:0]	min_96_b;


	nand4n	#(1)	a352(has_prefix1_n, has_prefix3_n, has_op2, has_imm8_n, min_96_a);
	nand3n	#(1)	a353(has_imm16_n, has_imm32, has_modrm_n, min_96_b);
	nor2n	#(1)	a354(min_96_a, min_96_b, min_96);
	wire	[0:0]	min_97;
	wire	[0:0]	min_97_a;
	wire	[0:0]	min_97_b;


	nand4n	#(1)	a355(has_prefix1, has_prefix2_n, has_prefix3_n, has_op2, min_97_a);
	nand3n	#(1)	a356(has_imm8_n, has_imm32_n, has_modrm_n, min_97_b);
	nor2n	#(1)	a357(min_97_a, min_97_b, min_97);
	wire	[0:0]	min_98;
	wire	[0:0]	min_98_a;
	wire	[0:0]	min_98_b;


	nand4n	#(1)	a358(has_prefix2, has_prefix3_n, has_imm16_n, has_imm32_n, min_98_a);
	nand4n	#(1)	a359(has_modrm, has_sib_n, has_disp8, has_disp32_n, min_98_b);
	nor2n	#(1)	a360(min_98_a, min_98_b, min_98);
	wire	[0:0]	min_99;
	wire	[0:0]	min_99_a;
	wire	[0:0]	min_99_b;


	nand4n	#(1)	a361(has_prefix1, has_prefix2, has_prefix3_n, has_op2_n, min_99_a);
	nand3n	#(1)	a362(has_imm8_n, has_sib, has_disp8_n, min_99_b);
	nor2n	#(1)	a363(min_99_a, min_99_b, min_99);
	wire	[0:0]	min_100;
	wire	[0:0]	min_100_a;
	wire	[0:0]	min_100_b;


	nand4n	#(1)	a364(has_prefix3_n, has_imm8_n, has_imm16_n, has_imm32_n, min_100_a);
	nand4n	#(1)	a365(has_modrm, has_sib, has_disp8, has_disp32_n, min_100_b);
	nor2n	#(1)	a366(min_100_a, min_100_b, min_100);
	wire	[0:0]	min_101;
	wire	[0:0]	min_101_a;
	wire	[0:0]	min_101_b;


	nand4n	#(1)	a367(has_prefix2_n, has_prefix3_n, has_op2_n, has_imm8, min_101_a);
	nand3n	#(1)	a368(has_imm16_n, has_imm32_n, has_modrm_n, min_101_b);
	nor2n	#(1)	a369(min_101_a, min_101_b, min_101);
	wire	[0:0]	min_102;
	wire	[0:0]	min_102_a;
	wire	[0:0]	min_102_b;


	nand4n	#(1)	a370(has_prefix3_n, has_imm8, has_imm16_n, has_imm32_n, min_102_a);
	nand4n	#(1)	a371(has_modrm, has_sib, has_disp8_n, has_disp32_n, min_102_b);
	nor2n	#(1)	a372(min_102_a, min_102_b, min_102);
	wire	[0:0]	min_103;
	wire	[0:0]	min_103_a;
	wire	[0:0]	min_103_b;


	nand4n	#(1)	a373(has_prefix3_n, has_op2, has_imm16_n, has_imm32_n, min_103_a);
	nand4n	#(1)	a374(has_modrm, has_sib, has_disp8_n, has_disp32_n, min_103_b);
	nor2n	#(1)	a375(min_103_a, min_103_b, min_103);
	wire	[0:0]	min_104;
	wire	[0:0]	min_104_a;
	wire	[0:0]	min_104_b;


	nand4n	#(1)	a376(has_prefix3_n, has_op2, has_imm8, has_imm16_n, min_104_a);
	nand4n	#(1)	a377(has_imm32_n, has_modrm, has_disp8_n, has_disp32_n, min_104_b);
	nor2n	#(1)	a378(min_104_a, min_104_b, min_104);
	wire	[0:0]	min_105;
	wire	[0:0]	min_105_a;
	wire	[0:0]	min_105_b;


	nand4n	#(1)	a379(has_prefix2_n, has_prefix3_n, has_op2, has_imm8_n, min_105_a);
	nand3n	#(1)	a380(has_imm16_n, has_imm32_n, has_modrm_n, min_105_b);
	nor2n	#(1)	a381(min_105_a, min_105_b, min_105);
	wire	[0:0]	min_106;
	wire	[0:0]	min_106_a;
	wire	[0:0]	min_106_b;


	nand4n	#(1)	a382(has_prefix1_n, has_prefix2, has_prefix3_n, has_op2, min_106_a);
	nand3n	#(1)	a383(has_imm8_n, has_imm16_n, has_modrm_n, min_106_b);
	nor2n	#(1)	a384(min_106_a, min_106_b, min_106);
	wire	[0:0]	min_107;
	wire	[0:0]	min_107_a;
	wire	[0:0]	min_107_b;


	nand4n	#(1)	a385(has_prefix2, has_prefix3_n, has_imm16_n, has_imm32_n, min_107_a);
	nand4n	#(1)	a386(has_modrm, has_sib, has_disp8_n, has_disp32_n, min_107_b);
	nor2n	#(1)	a387(min_107_a, min_107_b, min_107);
	wire	[0:0]	min_108;
	wire	[0:0]	min_108_a;
	wire	[0:0]	min_108_b;


	nand4n	#(1)	a388(has_prefix2, has_prefix3_n, has_imm8, has_imm16_n, min_108_a);
	nand4n	#(1)	a389(has_imm32_n, has_modrm, has_disp8_n, has_disp32_n, min_108_b);
	nor2n	#(1)	a390(min_108_a, min_108_b, min_108);
	wire	[0:0]	min_109;
	wire	[0:0]	min_109_a;
	wire	[0:0]	min_109_b;


	nand4n	#(1)	a391(has_prefix2, has_prefix3_n, has_op2, has_imm8, min_109_a);
	nand3n	#(1)	a392(has_imm16_n, has_imm32_n, has_modrm_n, min_109_b);
	nor2n	#(1)	a393(min_109_a, min_109_b, min_109);
	wire	[0:0]	min_110;
	wire	[0:0]	min_110_a;
	wire	[0:0]	min_110_b;


	nand4n	#(1)	a394(has_prefix2, has_prefix3_n, has_op2, has_imm16_n, min_110_a);
	nand4n	#(1)	a395(has_imm32_n, has_modrm, has_disp8_n, has_disp32_n, min_110_b);
	nor2n	#(1)	a396(min_110_a, min_110_b, min_110);
	wire	[0:0]	min_111;
	wire	[0:0]	min_111_a;
	wire	[0:0]	min_111_b;


	nand4n	#(1)	a397(has_prefix1, has_prefix3_n, has_imm8_n, has_imm16_n, min_111_a);
	nand4n	#(1)	a398(has_imm32_n, has_modrm, has_disp8, has_disp32_n, min_111_b);
	nor2n	#(1)	a399(min_111_a, min_111_b, min_111);
	wire	[0:0]	min_112;
	wire	[0:0]	min_112_a;
	wire	[0:0]	min_112_b;


	nand4n	#(1)	a400(has_prefix1, has_prefix3_n, has_imm16_n, has_imm32_n, min_112_a);
	nand4n	#(1)	a401(has_modrm, has_sib, has_disp8_n, has_disp32_n, min_112_b);
	nor2n	#(1)	a402(min_112_a, min_112_b, min_112);
	wire	[0:0]	min_113;
	wire	[0:0]	min_113_a;
	wire	[0:0]	min_113_b;


	nand4n	#(1)	a403(has_prefix1, has_prefix3_n, has_imm8, has_imm16_n, min_113_a);
	nand4n	#(1)	a404(has_imm32_n, has_modrm, has_disp8_n, has_disp32_n, min_113_b);
	nor2n	#(1)	a405(min_113_a, min_113_b, min_113);
	wire	[0:0]	min_114;
	wire	[0:0]	min_114_a;
	wire	[0:0]	min_114_b;


	nand4n	#(1)	a406(has_prefix1, has_prefix3_n, has_op2, has_imm8, min_114_a);
	nand3n	#(1)	a407(has_imm16_n, has_imm32_n, has_modrm_n, min_114_b);
	nor2n	#(1)	a408(min_114_a, min_114_b, min_114);
	wire	[0:0]	min_115;
	wire	[0:0]	min_115_a;
	wire	[0:0]	min_115_b;


	nand4n	#(1)	a409(has_prefix1, has_prefix3_n, has_op2, has_imm16_n, min_115_a);
	nand4n	#(1)	a410(has_imm32_n, has_modrm, has_disp8_n, has_disp32_n, min_115_b);
	nor2n	#(1)	a411(min_115_a, min_115_b, min_115);
	wire	[0:0]	min_116;
	wire	[0:0]	min_116_a;
	wire	[0:0]	min_116_b;


	nand4n	#(1)	a412(has_prefix1, has_prefix2, has_prefix3_n, has_imm8, min_116_a);
	nand3n	#(1)	a413(has_imm16_n, has_imm32_n, has_modrm_n, min_116_b);
	nor2n	#(1)	a414(min_116_a, min_116_b, min_116);
	wire	[0:0]	min_117;
	wire	[0:0]	min_117_a;
	wire	[0:0]	min_117_b;


	nand4n	#(1)	a415(has_prefix1, has_prefix2, has_prefix3_n, has_imm16_n, min_117_a);
	nand4n	#(1)	a416(has_imm32_n, has_modrm, has_disp8_n, has_disp32_n, min_117_b);
	nor2n	#(1)	a417(min_117_a, min_117_b, min_117);
	wire	[0:0]	min_118;
	wire	[0:0]	min_118_a;
	wire	[0:0]	min_118_b;


	nand3n	#(1)	a418(has_prefix1, has_prefix3_n, has_imm8_n, min_118_a);
	nand3n	#(1)	a419(has_imm16, has_imm32_n, has_modrm_n, min_118_b);
	nor2n	#(1)	a420(min_118_a, min_118_b, min_118);
	wire	[0:0]	min_119;
	wire	[0:0]	min_119_a;
	wire	[0:0]	min_119_b;


	nand4n	#(1)	a421(has_prefix1, has_prefix2, has_prefix3_n, has_op2, min_119_a);
	nand3n	#(1)	a422(has_imm16_n, has_imm32_n, has_modrm_n, min_119_b);
	nor2n	#(1)	a423(min_119_a, min_119_b, min_119);
	wire	[0:0]	min_120;
	wire	[0:0]	min_120_a;
	wire	[0:0]	min_120_b;


	nand3n	#(1)	a424(has_prefix1, has_prefix2, has_prefix3_n, min_120_a);
	nand3n	#(1)	a425(has_op2_n, has_imm8_n, has_modrm_n, min_120_b);
	nor2n	#(1)	a426(min_120_a, min_120_b, min_120);
	wire	[0:0]	min_121;
	wire	[0:0]	min_121_a;
	wire	[0:0]	min_121_b;


	nand3n	#(1)	a427(has_prefix3_n, has_op2_n, has_imm8_n, min_121_a);
	nand3n	#(1)	a428(has_imm16_n, has_imm32, has_modrm_n, min_121_b);
	nor2n	#(1)	a429(min_121_a, min_121_b, min_121);
	wire	[0:0]	min_122;
	wire	[0:0]	min_122_a;
	wire	[0:0]	min_122_b;


	nand3n	#(1)	a430(has_prefix1, has_prefix2, has_prefix3_n, min_122_a);
	nand2n	#(1)	a431(has_imm16, has_imm32, min_122_b);
	nor2n	#(1)	a432(min_122_a, min_122_b, min_122);
	wire	[0:0]	min_123;
	wire	[0:0]	min_123_a;
	wire	[0:0]	min_123_b;


	nand3n	#(1)	a433(has_prefix2, has_prefix3_n, has_op2_n, min_123_a);
	nand3n	#(1)	a434(has_imm8_n, has_imm16_n, has_modrm_n, min_123_b);
	nor2n	#(1)	a435(min_123_a, min_123_b, min_123);
	wire	[0:0]	min_124;
	wire	[0:0]	min_124_a;
	wire	[0:0]	min_124_b;


	nand3n	#(1)	a436(has_prefix1, has_prefix3_n, has_op2_n, min_124_a);
	nand3n	#(1)	a437(has_imm8_n, has_imm16_n, has_modrm_n, min_124_b);
	nor2n	#(1)	a438(min_124_a, min_124_b, min_124);
	wire	[0:0]	min_125;
	wire	[0:0]	min_125_a;
	wire	[0:0]	min_125_b;


	nand3n	#(1)	a439(has_prefix1_n, has_prefix2_n, has_prefix3_n, min_125_a);
	nand2n	#(1)	a440(has_imm16, has_imm32, min_125_b);
	nor2n	#(1)	a441(min_125_a, min_125_b, min_125);
	wire	[0:0]	min_126;
	and4n	#(1)	a442(has_prefix2, has_prefix3_n, has_imm16, has_imm32, min_126);
	wire	[0:0]	min_127;
	and4n	#(1)	a443(has_prefix1, has_prefix3_n, has_imm16, has_imm32, min_127);


	wire	[0:0]	inst_s0_st_a0;
	wire	[0:0]	inst_s0_st_a1;
	wire	[0:0]	inst_s0_st_a2;
	wire	[0:0]	inst_s0_st_a3;
	wire	[0:0]	inst_s0_st_a4;
	wire	[0:0]	inst_s0_st_a5;
	wire	[0:0]	inst_s0_st_a6;
	wire	[0:0]	inst_s0_st_a7;
	wire	[0:0]	inst_s0_st_a8;
	wire	[0:0]	inst_s0_st_a9;
	wire	[0:0]	inst_s0_st_a10;
	wire	[0:0]	inst_s0_st_a11;
	wire	[0:0]	inst_s0_st_b0;
	wire	[0:0]	inst_s0_st_b1;
	wire	[0:0]	inst_s0_st_b2;


	nor4n	#(1)	o0(min_0, min_2, min_3, min_5, inst_s0_st_a0);
	nor4n	#(1)	o1(min_6, min_7, min_8, min_9, inst_s0_st_a1);
	nor4n	#(1)	o2(min_10, min_12, min_14, min_16, inst_s0_st_a2);
	nor4n	#(1)	o3(min_17, min_19, min_22, min_25, inst_s0_st_a3);
	nor4n	#(1)	o4(min_27, min_33, min_39, min_41, inst_s0_st_a4);
	nor4n	#(1)	o5(min_44, min_45, min_47, min_50, inst_s0_st_a5);
	nor4n	#(1)	o6(min_52, min_59, min_61, min_63, inst_s0_st_a6);
	nor4n	#(1)	o7(min_64, min_65, min_66, min_68, inst_s0_st_a7);
	nor4n	#(1)	o8(min_69, min_71, min_73, min_79, inst_s0_st_a8);
	nor4n	#(1)	o9(min_80, min_84, min_91, min_92, inst_s0_st_a9);
	nor4n	#(1)	o10(min_97, min_99, min_106, min_120, inst_s0_st_a10);
	nor2n	#(1)	o11(min_122, min_125, inst_s0_st_a11);


	nand4n	#(1)	os00(inst_s0_st_a0, inst_s0_st_a1, inst_s0_st_a2, inst_s0_st_a3, inst_s0_st_b0);
	nand4n	#(1)	os01(inst_s0_st_a4, inst_s0_st_a5, inst_s0_st_a6, inst_s0_st_a7, inst_s0_st_b1);
	nand4n	#(1)	os02(inst_s0_st_a8, inst_s0_st_a9, inst_s0_st_a10, inst_s0_st_a11, inst_s0_st_b2);
	or3n	#(1)	os03(inst_s0_st_b0, inst_s0_st_b1, inst_s0_st_b2, size[0]);


	wire	[0:0]	inst_s1_st_a0;
	wire	[0:0]	inst_s1_st_a1;
	wire	[0:0]	inst_s1_st_a2;
	wire	[0:0]	inst_s1_st_a3;
	wire	[0:0]	inst_s1_st_a4;
	wire	[0:0]	inst_s1_st_a5;
	wire	[0:0]	inst_s1_st_a6;
	wire	[0:0]	inst_s1_st_a7;
	wire	[0:0]	inst_s1_st_a8;
	wire	[0:0]	inst_s1_st_a9;
	wire	[0:0]	inst_s1_st_b0;
	wire	[0:0]	inst_s1_st_b1;
	wire	[0:0]	inst_s1_st_b2;


	nor4n	#(1)	o12(min_9, min_18, min_19, min_23, inst_s1_st_a0);
	nor4n	#(1)	o13(min_25, min_29, min_32, min_34, inst_s1_st_a1);
	nor4n	#(1)	o14(min_38, min_40, min_41, min_42, inst_s1_st_a2);
	nor4n	#(1)	o15(min_43, min_45, min_49, min_51, inst_s1_st_a3);
	nor4n	#(1)	o16(min_52, min_54, min_55, min_58, inst_s1_st_a4);
	nor4n	#(1)	o17(min_62, min_67, min_71, min_72, inst_s1_st_a5);
	nor4n	#(1)	o18(min_73, min_75, min_76, min_77, inst_s1_st_a6);
	nor4n	#(1)	o19(min_78, min_79, min_85, min_92, inst_s1_st_a7);
	nor4n	#(1)	o20(min_96, min_101, min_105, min_106, inst_s1_st_a8);
	nor3n	#(1)	o21(min_123, min_124, min_125, inst_s1_st_a9);


	wire	[0:0]	size1_t;
	nand4n	#(1)	os10(inst_s1_st_a0, inst_s1_st_a1, inst_s1_st_a2, inst_s1_st_a3, inst_s1_st_b0);
	nand3n	#(1)	os11(inst_s1_st_a4, inst_s1_st_a5, inst_s1_st_a6, inst_s1_st_b1);
	nand3n	#(1)	os12(inst_s1_st_a7, inst_s1_st_a8, inst_s1_st_a9, inst_s1_st_b2);
	or3n	#(1)	os13(inst_s1_st_b0, inst_s1_st_b1, inst_s1_st_b2, size1_t);


	wire	[0:0]	inst_s2_st_a0;
	wire	[0:0]	inst_s2_st_a1;
	wire	[0:0]	inst_s2_st_a2;
	wire	[0:0]	inst_s2_st_a3;
	wire	[0:0]	inst_s2_st_a4;
	wire	[0:0]	inst_s2_st_a5;
	wire	[0:0]	inst_s2_st_a6;
	wire	[0:0]	inst_s2_st_a7;
	wire	[0:0]	inst_s2_st_a8;
	wire	[0:0]	inst_s2_st_a9;
	wire	[0:0]	inst_s2_st_a10;
	wire	[0:0]	inst_s2_st_b0;
	wire	[0:0]	inst_s2_st_b1;
	wire	[0:0]	inst_s2_st_b2;


	nor4n	#(1)	o22(min_9, min_10, min_11, min_13, inst_s2_st_a0);
	nor4n	#(1)	o23(min_15, min_18, min_20, min_21, inst_s2_st_a1);
	nor4n	#(1)	o24(min_24, min_25, min_26, min_28, inst_s2_st_a2);
	nor4n	#(1)	o25(min_30, min_31, min_35, min_37, inst_s2_st_a3);
	nor4n	#(1)	o26(min_42, min_48, min_58, min_62, inst_s2_st_a4);
	nor4n	#(1)	o27(min_74, min_93, min_95, min_96, inst_s2_st_a5);
	nor4n	#(1)	o28(min_98, min_100, min_102, min_103, inst_s2_st_a6);
	nor4n	#(1)	o29(min_104, min_107, min_108, min_109, inst_s2_st_a7);
	nor4n	#(1)	o30(min_110, min_111, min_112, min_113, inst_s2_st_a8);
	nor4n	#(1)	o31(min_114, min_115, min_116, min_117, inst_s2_st_a9);
	nor4n	#(1)	o32(min_118, min_119, min_121, min_125, inst_s2_st_a10);


	nand4n	#(1)	os20(inst_s2_st_a0, inst_s2_st_a1, inst_s2_st_a2, inst_s2_st_a3, inst_s2_st_b0);
	nand4n	#(1)	os21(inst_s2_st_a4, inst_s2_st_a5, inst_s2_st_a6, inst_s2_st_a7, inst_s2_st_b1);
	nand3n	#(1)	os22(inst_s2_st_a8, inst_s2_st_a9, inst_s2_st_a10, inst_s2_st_b2);
	or3n	#(1)	os23(inst_s2_st_b0, inst_s2_st_b1, inst_s2_st_b2, size[2]);


	wire	[0:0]	inst_s3_st_a0;
	wire	[0:0]	inst_s3_st_a1;
	wire	[0:0]	inst_s3_st_a2;
	wire	[0:0]	inst_s3_st_a3;
	wire	[0:0]	inst_s3_st_a4;
	wire	[0:0]	inst_s3_st_a5;
	wire	[0:0]	inst_s3_st_b0;
	wire	[0:0]	inst_s3_st_b1;


	nor4n	#(1)	o33(min_1, min_4, min_36, min_40, inst_s3_st_a0);
	nor4n	#(1)	o34(min_46, min_53, min_56, min_57, inst_s3_st_a1);
	nor4n	#(1)	o35(min_60, min_70, min_81, min_82, inst_s3_st_a2);
	nor4n	#(1)	o36(min_83, min_86, min_87, min_88, inst_s3_st_a3);
	nor4n	#(1)	o37(min_89, min_90, min_94, min_126, inst_s3_st_a4);
	invn	#(1)	exp(min_127, inst_s3_st_a5);
	//assign	inst_s3_st_a5 	= min_127;


	nand3n	#(1)	os30(inst_s3_st_a0, inst_s3_st_a1, inst_s3_st_a2, inst_s3_st_b0);
	nand3n	#(1)	os31(inst_s3_st_a3, inst_s3_st_a4, inst_s3_st_a5, inst_s3_st_b1);
	or2n	#(1)	os32(inst_s3_st_b0, inst_s3_st_b1, size[3]);

	//SPECIAL CASE
	wire	[3:0]	sp_term;
	
	nand4n	#(1)	sp0(has_disp8_n, has_disp32, has_imm8_n, has_imm16_n, sp_term[0]);
	nand4n	#(1)	sp1(has_imm32_n, has_modrm, has_op2, has_prefix1, sp_term[1]);
	nand3n	#(1)	sp2(has_prefix2_n, has_prefix3_n, has_sib_n, sp_term[2]);
	or3n	#(1)	sp3(sp_term[0], sp_term[1], sp_term[2], sp_term[3]);
	and2n	#(1)	sp4(size1_t, sp_term[3], size[1]);	
	

endmodule
