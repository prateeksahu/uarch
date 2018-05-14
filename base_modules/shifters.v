module sar_5b (
	input [31:0] in,
	input [4:0] shf_val,
	input [1:0] opSize,
	output [31:0] o,
	output cfl);
	
	//Create wires.
	wire [31:0] w1,w2,w3,w4,w5,w6,w7,w8,w9;
			
	wire [31:0] in_temp;
	wire [31:0] o_temp;
	
	assign in_temp = in;
	assign o = o_temp;

	genvar i;
	
	generate
		//w1 = in >> 16.
		for(i=0; i<16; i=i+1) begin: l1
			assign w1[i] = in_temp[i+16];
		end
		for(i=16; i<32; i=i+1) begin: l2
			assign w1[i] = in_temp[31];
		end
		//w3 = w2 >> 4.
		for(i=0; i<28; i=i+1) begin: l3
			assign w3[i] = w2[i+4];
		end
		for(i=28; i<32; i=i+1) begin: l4
			assign w3[i] = in_temp[31];
		end
		//w4 = w2 >> 8.
		for(i=0; i<24; i=i+1) begin: l5
			assign w4[i] = w2[i+8];
		end
		for(i=24; i<32; i=i+1) begin: l6
			assign w4[i] = in_temp[31];
		end
		//w5 = w2 >> 12.
		for(i=0; i<20; i=i+1) begin: l7
			assign w5[i] = w2[i+12];
		end
		for(i=20; i<32; i=i+1) begin: l8
			assign w5[i] = in_temp[31];
		end
		//w7 = w6 >> 1.
		for(i=0; i<31; i=i+1) begin: l9
			assign w7[i] = w6[i+1];
		end
		assign w7[31] = in_temp[31];
		//w8 = w6 >> 2.
		for(i=0; i<30; i=i+1) begin: l10
			assign w8[i] = w6[i+2];
		end
		for(i=30; i<32; i=i+1) begin: l11
			assign w8[i] = in_temp[31];
		end
		//w9 = w6 >> 3.
		for(i=0; i<29; i=i+1) begin: l12
			assign w9[i] = w6[i+3];
		end
		for(i=29; i<32; i=i+1) begin: l13
			assign w9[i] = in_temp[31];
		end
	endgenerate
	
	//Create multiplexers.
	genvar j;
	generate
		for(j=0; j<32; j=j+1) begin: shf_o
			mux2$ 	ma(w2[j],in_temp[j],w1[j],shf_val[4]);
			mux4$ 	mb(w6[j],w2[j],w3[j],w4[j],w5[j],shf_val[2],shf_val[3]),
					mc(o_temp[j],w6[j],w7[j],w8[j],w9[j],shf_val[0],shf_val[1]);
		end
	endgenerate

	mux2$ 	ma1(cl1,in_temp[15],1'b0,shf_val[4]);
	mux4$ 	mb1(cl2,cl1,w2[3],w2[7],w2[11],shf_val[2],shf_val[3]),
			mc1(cfl1,cl2,w6[0],w6[1],w6[2],shf_val[0],shf_val[1]);

	mux2$ 	ma2(cl1,in_temp[0],1'b0,shf_val[4]);
	mux4$ 	mb2(cl2,cl1,w2[12],w2[8],w2[4],shf_val[2],shf_val[3]),
			mc2(cfl2,cl2,w6[15],w6[14],w6[13],shf_val[0],shf_val[1]);

	mux2$ 	ma3(cl1,1'b0,1'b0,shf_val[4]);
	mux4$ 	mb3(cl2,cl1,w2[4],w2[0],1'b0,shf_val[2],shf_val[3]),
			mc3(cfl3,cl2,w6[7],w6[6],w6[5],shf_val[0],shf_val[1]);
	
	mux4n #(1) fl(1'b0, cfl3, cfl2, cfl1, opSize, cfl);

endmodule

module sal_5b (
	input [31:0] in,
	input [4:0] shf_val,
	input [1:0] opSize,
	output [31:0] o,
	output cfl);
	
	//Create wires.
	wire [31:0] w1,w2,w3,w4,w5,w6,w7,w8,w9;
			
	wire [31:0] in_temp;
	wire [31:0] o_temp;
	
	assign in_temp = in;
	assign o = o_temp;

	genvar i;
	
	generate
		//w1 = in << 16.
		for(i=16; i<32; i=i+1) begin: l1
			assign w1[i] = in_temp[i-16];
		end
		for(i=0; i<16; i=i+1) begin: l2
			assign w1[i] = 1'b0;
		end
		//w3 = w2 << 4.
		for(i=4; i<32; i=i+1) begin: l3
			assign w3[i] = w2[i-4];
		end
		for(i=0; i<4; i=i+1) begin: l4
			assign w3[i] = 1'b0;
		end
		//w4 = w2 << 8.
		for(i=8; i<32; i=i+1) begin: l5
			assign w4[i] = w2[i-8];
		end
		for(i=0; i<8; i=i+1) begin: l6
			assign w4[i] = 1'b0;
		end
		//w5 = w2 << 12.
		for(i=12; i<32; i=i+1) begin: l7
			assign w5[i] = w2[i-12];
		end
		for(i=0; i<12; i=i+1) begin: l8
			assign w5[i] = 1'b0;
		end
		//w7 = w6 << 1.
		for(i=1; i<32; i=i+1) begin: l9
			assign w7[i] = w6[i-1];
		end
		assign w7[0] = 1'b0;
		//w8 = w6 << 2.
		for(i=2; i<32; i=i+1) begin: l10
			assign w8[i] = w6[i-2];
		end
		for(i=0; i<2; i=i+1) begin: l11
			assign w8[i] = 1'b0;
		end
		//w9 = w6 << 3.
		for(i=3; i<32; i=i+1) begin: l12
			assign w9[i] = w6[i-3];
		end
		for(i=0; i<3; i=i+1) begin: l13
			assign w9[i] = 1'b0;
		end
	endgenerate
	
	//Create multiplexers.
	genvar j;
	generate
		for(j=0; j<32; j=j+1) begin: shf_o
			mux2$ 	ma(w2[j],in_temp[j],w1[j],shf_val[4]);
			mux4$ 	mb(w6[j],w2[j],w3[j],w4[j],w5[j],shf_val[2],shf_val[3]),
					mc(o_temp[j],w6[j],w7[j],w8[j],w9[j],shf_val[0],shf_val[1]);
		end
	endgenerate


	mux2$ 	ma1(cl1,in_temp[16],1'b0,shf_val[4]);
	mux4$ 	mb1(cl2,cl1,w2[28],w2[24],w2[20],shf_val[2],shf_val[3]),
			mc1(cfl1,cl2,w6[31],w6[30],w6[29],shf_val[0],shf_val[1]);

	mux2$ 	ma2(cl1,in_temp[0],1'b0,shf_val[4]);
	mux4$ 	mb2(cl2,cl1,w2[12],w2[8],w2[4],shf_val[2],shf_val[3]),
			mc2(cfl2,cl2,w6[15],w6[14],w6[13],shf_val[0],shf_val[1]);

	mux2$ 	ma3(cl1,1'b0,1'b0,shf_val[4]);
	mux4$ 	mb3(cl2,cl1,w2[4],w2[0],1'b0,shf_val[2],shf_val[3]),
			mc3(cfl3,cl2,w6[7],w6[6],w6[5],shf_val[0],shf_val[1]);
	
	mux4n #(1) fl(1'b0, cfl3, cfl2, cfl1, opSize, cfl);

endmodule