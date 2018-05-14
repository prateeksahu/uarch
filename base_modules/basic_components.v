///////////////////////////////////////////////////////////////////////
////         LIST OF BASIC COMPONENTS DECLARED HERE.               ////
////         1. Equality checker (3,4,7,8,10,16,32 bit).           ////
////         2. Parameterized width gates (NOT, AND2, OR2).        ////
////         3. Parameterized width muxes (MUX2,MUX3,MUX4).        ////
////         4. Parameterized width DFF.                           ////
////         5. (Semi-parameterized) Barrel shifter (see below)    ////
////         6. Parameterized width Register (byte- & all-enable). ////
///////////////////////////////////////////////////////////////////////

module comp_eq2(
	input [1:0] in1,
	input [1:0] in2,
	output equal);
	//Total delay: 0.25 + 0.35 = 0.6ns
	wire [1:0] w1;
	
	genvar i;
	generate
		for(i=0; i<2; i=i+1) begin: eq2
			xnor2$ xn(w1[i],in1[i],in2[i]);
		end
	endgenerate
	
	and2$	ac(equal,w1[0],w1[1]);
endmodule

module comp_eq2n(
    input [1:0] in1,
    input [1:0] in2,
    output equaln);
    //Total delay: 0.25 + 0.35 = 0.6ns
    wire [1:0] w1;
    
    genvar i;
    generate
        for(i=0; i<2; i=i+1) begin: eq7
            xnor2$ xn(w1[i], in1[i], in2[i]);
        end
    endgenerate
    
    nand2$    aa(equaln,w1[0],w1[1]);
endmodule

module comp_eq3(
	input [2:0] in1,
	input [2:0] in2,
	output equal);
	//Total delay: 0.25 + 0.35 = 0.6ns
	wire [2:0] w1;
	
	genvar i;
	generate
		for(i=0; i<3; i=i+1) begin: eq3
			xnor2$ xn(w1[i], in1[i], in2[i]);
		end
	endgenerate
	
	and3$	ac(equal,w1[0],w1[1],w1[2]);
endmodule

module comp_eq4(
	input [3:0] in1,
	input [3:0] in2,
	output equal);
	//Total delay: 0.25 + 0.4 = 0.55ns
	wire [3:0] w1;
	
	genvar i;
	generate
		for(i=0; i<4; i=i+1) begin: eq4
			xnor2$ xn(w1[i], in1[i], in2[i]);
		end
	endgenerate
	
	and4$	aa(equal,w1[0],w1[1],w1[2],w1[3]);
endmodule

module comp_eq5(
	input [4:0] in1,
	input [4:0] in2,
	output equal);
	//Total delay: 0.25 + 0.4 = 0.55ns
	wire [4:0] w1;
	
	genvar i;
	generate
		for(i=0; i<5; i=i+1) begin: eq4
			xnor2$ xn(w1[i], in1[i], in2[i]);
		end
	endgenerate
	
	wire [0:0] temp0;	
	wire [0:0] temp1;	

	and3$	a0(temp0,w1[0],w1[1],w1[2]);
	and2$	a1(temp1,w1[3],w1[4]);
	and2$	a2(equal,temp0,temp1);
endmodule

module comp_eq7(
    input [6:0] in1,
    input [6:0] in2,
    output equal);
    //Total delay: 0.25 + 0.25 + 0.2 = 0.7ns
    wire [6:0] w1;
    wire [1:0] w2;
    
    genvar i;
    generate
        for(i=0; i<7; i=i+1) begin: eq7
            xnor2$ xn(w1[i], in1[i], in2[i]);
        end
    endgenerate
    
    nand4$   aa(w2[0],w1[0],w1[1],w1[2],w1[3]),
             ab(w2[1],w1[4],w1[5],w1[6],1'b1);
    nor2$    ac(equal,w2[0],w2[1]);
endmodule

module comp_eq8(
    input [7:0] in1,
    input [7:0] in2,
    output equal);
    //Total delay: 0.25 + 0.25 + 0.2 = 0.7ns
    wire [7:0] w1;
    wire [1:0] w2;
    
    genvar i;
    generate
        for(i=0; i<8; i=i+1) begin: eq8
            xnor2$ xn(w1[i], in1[i], in2[i]);
        end
    endgenerate
    
    nand4$   aa(w2[0],w1[0],w1[1],w1[2],w1[3]),
             ab(w2[1],w1[4],w1[5],w1[6],w1[7]);
    nor2$    ac(equal,w2[0],w2[1]);
endmodule

module comp_eq10(
    input [9:0] in1,
    input [9:0] in2,
    output equal);
    //Total delay: 0.25 + 0.2 + 0.35 = 0.8ns
    wire [9:0] w1;
    wire [3:0] w2;
    
    genvar i;
    generate
        for(i=0; i<10; i=i+1) begin: eq10
            xnor2$ xn(w1[i], in1[i], in2[i]);
        end
    endgenerate
    
    nand3$   aa(w2[0],w1[0],w1[1],w1[2]),
             ab(w2[1],w1[3],w1[4],w1[5]),
             ac(w2[2],w1[6],w1[7],w1[8]),
             ad(w2[3],w1[9],1'b1,1'b1);
    nor4$    ae(equal,w2[0],w2[1],w2[2],w2[3]);
            
endmodule

module comp_eq16(
    input [15:0] in1,
    input [15:0] in2,
    output equal);
    //Total delay: 0.25+0.25+0.35=0.85ns
    wire [15:0] w1;
    wire [3:0] w2;
    
    genvar i;
    generate
        for(i=0; i<16; i=i+1) begin: eq16
            xnor2$ xn(w1[i], in1[i], in2[i]);
        end
    endgenerate
    
    nand4$  aa(w2[0],w1[0],w1[1],w1[2],w1[3]),
            ab(w2[1],w1[4],w1[5],w1[6],w1[7]),
            ac(w2[2],w1[8],w1[9],w1[10],w1[11]),
            ad(w2[3],w1[12],w1[13],w1[14],w1[15]);
    nor4$   ae(equal,w2[0],w2[1],w2[2],w2[3]);
            
endmodule

module comp_eq24(
    input [23:0] in1,
    input [23:0] in2,
    output equal);
    //Total delay: 0.25+0.25+0.4+0.25 = 1.15ns
    wire [23:0] w1;
    wire [5:0] w2;
    wire [2:0] w3;
    
    genvar i;
    generate
        for(i=0; i<24; i=i+1) begin: eq16
            xnor2$ xn(w1[i], in1[i], in2[i]);
        end
    endgenerate
    
    nand4$  aa(w2[0],w1[0],w1[1],w1[2],w1[3]),
            ab(w2[1],w1[4],w1[5],w1[6],w1[7]),
            ac(w2[2],w1[8],w1[9],w1[10],w1[11]),
            ad(w2[3],w1[12],w1[13],w1[14],w1[15]),
            ae(w2[4],w1[16],w1[17],w1[18],w1[19]),
            af(w2[5],w1[20],w1[21],w1[22],w1[23]);
    or2$    ag(w3[0],w2[0],w2[1]),
            ah(w3[1],w2[2],w2[3]),
			al(w3[2],w2[4],w2[5]);
    nor3$   ai(equal,w3[0],w3[1],w3[2]);
            
endmodule

module comp_eq20(
	input [19:0] in1,
	input [19:0] in2,
	output equal);
	//Total delay: 0.3 + 2(0.4) = 1.1ns
	wire [19:0] w1;
	wire [4:0] w2;
	wire [0:0] w3;
	
	genvar i;
	generate
		for(i=0; i<20; i=i+1) begin: eq16
			xnor2$ xn(w1[i], in1[i], in2[i]);
		end
	endgenerate
	
	and4$	aa(w2[0],w1[0],w1[1],w1[2],w1[3]),
		ab(w2[1],w1[4],w1[5],w1[6],w1[7]),
		ac(w2[2],w1[8],w1[9],w1[10],w1[11]),
		ad(w2[3],w1[12],w1[13],w1[14],w1[15]),
		ae(w2[4],w1[16],w1[17],w1[18],w1[19]),	
		af(w3[0],w2[0],w2[1],w2[2],w2[3]);
	and2$	ag(equal,w3[0],w2[4]);
			
endmodule

module comp_eq32(
    input [31:0] in1,
    input [31:0] in2,
    output equal);
    //Total delay: 0.25+0.25+0.4+0.25 = 1.15ns
    wire [31:0] w1;
    wire [7:0] w2;
    wire [2:0] w3;
    
    genvar i;
    generate
        for(i=0; i<32; i=i+1) begin: eq32
            xnor2$ xn(w1[i], in1[i], in2[i]);
        end
    endgenerate
    
    nand4$  aa(w2[0],w1[0],w1[1],w1[2],w1[3]),
            ab(w2[1],w1[4],w1[5],w1[6],w1[7]),
            ac(w2[2],w1[8],w1[9],w1[10],w1[11]),
            ad(w2[3],w1[12],w1[13],w1[14],w1[15]),
            ae(w2[4],w1[16],w1[17],w1[18],w1[19]),
            af(w2[5],w1[20],w1[21],w1[22],w1[23]),
            ag(w2[6],w1[24],w1[25],w1[26],w1[27]),
            ah(w2[7],w1[28],w1[29],w1[30],w1[31]);
    or3$    ai(w3[0],w2[0],w2[1],w2[2]),
            aj(w3[1],w2[3],w2[4],w2[5]),
			ak(w3[2],w2[6],w2[7],1'b0);
            
    nor3$   al(equal,w3[0],w3[1],w3[2]);
endmodule

module invn #(parameter N = 8)(
    input [N-1:0] in,
    output [N-1:0] o);
    
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: inv
            inv1$    d(o[i],in[i]);
        end
    endgenerate
    
endmodule

module nand2n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: nand2
			nand2$	d(o[i],in1[i],in2[i]);
		end
	endgenerate
	
endmodule

module nand3n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: nand3
			nand3$	d(o[i],in1[i],in2[i],in3[i]);
		end
	endgenerate
	
endmodule

module nand4n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: nand4
			nand4$	d(o[i],in1[i],in2[i],in3[i],in4[i]);
		end
	endgenerate
	
endmodule

module nor2n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: nor2
			nor2$	d(o[i],in1[i],in2[i]);
		end
	endgenerate
	
endmodule

module nor3n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: nor3
			nor3$	d(o[i],in1[i],in2[i],in3[i]);
		end
	endgenerate
	
endmodule

module nor4n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: nor4
			nor4$	d(o[i],in1[i],in2[i],in3[i],in4[i]);
		end
	endgenerate
	
endmodule

module and2n #(parameter N = 8)(
    input [N-1:0] in1,
    input [N-1:0] in2,
    output [N-1:0] o);
    
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: and2
            and2$    d(o[i],in1[i],in2[i]);
        end
    endgenerate
    
endmodule

module and3n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
    output [N-1:0] o);
    
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: and3
            and3$    d(o[i],in1[i],in2[i],in3[i]);
        end
    endgenerate
    
endmodule

module and4n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: and4
			and4$	d(o[i],in1[i],in2[i],in3[i],in4[i]);
		end
	endgenerate
	
endmodule

module or2n #(parameter N = 8)(
    input [N-1:0] in1,
    input [N-1:0] in2,
    output [N-1:0] o);
    
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: or2
            or2$    d(o[i],in1[i],in2[i]);
        end
    endgenerate
    
endmodule

module or3n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: or3
			or3$	d(o[i],in1[i],in2[i],in3[i]);
		end
	endgenerate
	
endmodule

module or4n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: or4
			or4$	d(o[i],in1[i],in2[i],in3[i],in4[i]);
		end
	endgenerate
	
endmodule
    
module xor3n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	output [N-1:0] o);
	
	wire	[N-1:0] temp;
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: xor3
			xor2$	d0(temp[i],in1[i],in2[i]);
			xor2$	d1(o[i],temp[i],in3[i]);
		end
	endgenerate
	
endmodule

module xnor2n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: or2
			xnor2$	d(o[i],in1[i],in2[i]);
		end
	endgenerate
	
endmodule


module dffn #(parameter N = 8)(
    input [N-1:0] in,
    input clk,
    input rst,
    output [N-1:0] o);
    
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: dff
            dff$    d(.clk(clk),.d(in[i]),.q(o[i]),.qbar(),.r(rst),.s(1'b1));
        end
    endgenerate
    
endmodule


module mux14n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [N-1:0] in5,
	input [N-1:0] in6,
	input [N-1:0] in7,
	input [N-1:0] in8,
	input [N-1:0] in9,
	input [N-1:0] in10,
	input [N-1:0] in11,
	input [N-1:0] in12,
	input [N-1:0] in13,
	input [3:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	
	wire [N-1:0] temp2;	
	wire [N-1:0] temp3;	

	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux14
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux4$ mb(temp1[i],in4[i],in5[i],in6[i],in7[i],sel[0],sel[1]);
			mux4$ mc(temp2[i],in8[i],in9[i],in10[i],in11[i],sel[0],sel[1]);	
			mux2$ md(temp3[i],in12[i],in13[i],sel[0]);	
			mux4$ me(o[i],temp0[i],temp1[i],temp2[i],temp3[i],sel[2],sel[3]);
		end
	endgenerate
endmodule

module mux13n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [N-1:0] in5,
	input [N-1:0] in6,
	input [N-1:0] in7,
	input [N-1:0] in8,
	input [N-1:0] in9,
	input [N-1:0] in10,
	input [N-1:0] in11,
	input [N-1:0] in12,
	input [3:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	
	wire [N-1:0] temp2;	
	wire [N-1:0] temp3;	
	assign temp3 = in12;

	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux13
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux4$ mb(temp1[i],in4[i],in5[i],in6[i],in7[i],sel[0],sel[1]);
			mux4$ mc(temp2[i],in8[i],in9[i],in10[i],in11[i],sel[0],sel[1]);	
			mux4$ md(o[i],temp0[i],temp1[i],temp2[i],temp3[i],sel[2],sel[3]);
		end
	endgenerate
endmodule

module mux12n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [N-1:0] in5,
	input [N-1:0] in6,
	input [N-1:0] in7,
	input [N-1:0] in8,
	input [N-1:0] in9,
	input [N-1:0] in10,
	input [N-1:0] in11,
	input [3:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	
	wire [N-1:0] temp2;	

	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux12
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux4$ mb(temp1[i],in4[i],in5[i],in6[i],in7[i],sel[0],sel[1]);
			mux4$ mc(temp2[i],in8[i],in9[i],in10[i],in11[i],sel[0],sel[1]);	
			mux3$ md(o[i],temp0[i],temp1[i],temp2[i],sel[2],sel[3]);
		end
	endgenerate
endmodule

module mux11n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [N-1:0] in5,
	input [N-1:0] in6,
	input [N-1:0] in7,
	input [N-1:0] in8,
	input [N-1:0] in9,
	input [N-1:0] in10,
	input [3:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	
	wire [N-1:0] temp2;	

	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux11
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux4$ mb(temp1[i],in4[i],in5[i],in6[i],in7[i],sel[0],sel[1]);
			mux3$ mc(temp2[i],in8[i],in9[i],in10[i],sel[0],sel[1]);	
			mux3$ md(o[i],temp0[i],temp1[i],temp2[i],sel[2],sel[3]);
		end
	endgenerate
endmodule

module mux10n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [N-1:0] in5,
	input [N-1:0] in6,
	input [N-1:0] in7,
	input [N-1:0] in8,
	input [N-1:0] in9,
	input [3:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	
	wire [N-1:0] temp2;	

	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux10
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux4$ mb(temp1[i],in4[i],in5[i],in6[i],in7[i],sel[0],sel[1]);
			mux2$ mc(temp2[i],in8[i],in9[i],sel[0]);	
			mux3$ md(o[i],temp0[i],temp1[i],temp2[i],sel[2],sel[3]);
		end
	endgenerate
endmodule

module mux9n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [N-1:0] in5,
	input [N-1:0] in6,
	input [N-1:0] in7,
	input [N-1:0] in8,
	input [3:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	
	wire [N-1:0] temp2;
	assign temp2 = in8;	

	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux9
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux4$ mb(temp1[i],in4[i],in5[i],in6[i],in7[i],sel[0],sel[1]);
			mux3$ mc(o[i],temp0[i],temp1[i],temp2[i],sel[2],sel[3]);
		end
	endgenerate
endmodule

module mux7n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [N-1:0] in5,
	input [N-1:0] in6,
	input [2:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	

	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux7
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux3$ mb(temp1[i],in4[i],in5[i],in6[i],sel[0],sel[1]);
			mux2$ mc(o[i],temp0[i],temp1[i],sel[2]);
		end
	endgenerate
endmodule

module mux6n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [N-1:0] in5,
	input [2:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	

	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux6
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux2$ mb(temp1[i],in4[i],in5[i],sel[0]);
			mux2$ mc(o[i],temp0[i],temp1[i],sel[2]);
		end
	endgenerate
endmodule

module mux5n #(parameter N = 8)(
	input [N-1:0] in0,
	input [N-1:0] in1,
	input [N-1:0] in2,
	input [N-1:0] in3,
	input [N-1:0] in4,
	input [2:0] sel,
	output [N-1:0] o);

	wire [N-1:0] temp0;	
	wire [N-1:0] temp1;	
	assign temp1 = in4;
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: mux5
			mux4$ ma(temp0[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
			mux2$ mc(o[i],temp0[i],temp1[i],sel[2]);
		end
	endgenerate
endmodule

module mux4n #(parameter N = 8)(
    input [N-1:0] in0,
    input [N-1:0] in1,
    input [N-1:0] in2,
    input [N-1:0] in3,
    input [1:0] sel,
    output [N-1:0] o);
    
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: mux4
            mux4$ ma(o[i],in0[i],in1[i],in2[i],in3[i],sel[0],sel[1]);
        end
    endgenerate
endmodule

module mux8n #(parameter N = 8)(
    input [N-1:0] in0,
    input [N-1:0] in1,
    input [N-1:0] in2,
    input [N-1:0] in3,
    input [N-1:0] in4,
    input [N-1:0] in5,
    input [N-1:0] in6,
    input [N-1:0] in7,
    
    input [2:0] sel,
    output [N-1:0] o);
    //Critical path delay = 0.8ns
    
    wire [N-1:0] w1,w2,w3,w4,w5,w6,w7,w8,w9,w10;
    
    mux4n #(N) ma(in0,in1,in2,in3,sel[1:0],w1),
               mb(in4,in5,in6,in7,sel[1:0],w2);
    mux2n #(N) mk(w1,w2,sel[2],o);
endmodule

module mux32n #(parameter N = 8)(
    input [N-1:0] in0,
    input [N-1:0] in1,
    input [N-1:0] in2,
    input [N-1:0] in3,
    input [N-1:0] in4,
    input [N-1:0] in5,
    input [N-1:0] in6,
    input [N-1:0] in7,
    input [N-1:0] in8,
    input [N-1:0] in9,
    input [N-1:0] in10,
    input [N-1:0] in11,
    input [N-1:0] in12,
    input [N-1:0] in13,
    input [N-1:0] in14,
    input [N-1:0] in15,
    input [N-1:0] in16,
    input [N-1:0] in17,
    input [N-1:0] in18,
    input [N-1:0] in19,
    input [N-1:0] in20,
    input [N-1:0] in21,
    input [N-1:0] in22,
    input [N-1:0] in23,
    input [N-1:0] in24,
    input [N-1:0] in25,
    input [N-1:0] in26,
    input [N-1:0] in27,
    input [N-1:0] in28,
    input [N-1:0] in29,
    input [N-1:0] in30,
    input [N-1:0] in31,
    
    input [4:0] sel,
    output [N-1:0] o);
    //Critical path delay = 1.3ns
    
    wire [N-1:0] w1,w2,w3,w4,w5,w6,w7,w8,w9,w10;
    
    mux4n #(N) ma(in0,in1,in2,in3,sel[1:0],w1),
               mb(in4,in5,in6,in7,sel[1:0],w2),
               mc(in8,in9,in10,in11,sel[1:0],w3),
               md(in12,in13,in14,in15,sel[1:0],w4),
               me(in16,in17,in18,in19,sel[1:0],w5),
               mf(in20,in21,in22,in23,sel[1:0],w6),
               mg(in24,in25,in26,in27,sel[1:0],w7),
               mh(in28,in29,in30,in31,sel[1:0],w8),
               mi(w1,w2,w3,w4,sel[3:2],w9),
               mj(w5,w6,w7,w8,sel[3:2],w10);
    mux2n #(N) mk(w9,w10,sel[4],o);
endmodule

module mux3n #(parameter N = 8)(
    input [N-1:0] in0,
    input [N-1:0] in1,
    input [N-1:0] in2,
    input [1:0] sel,
    output [N-1:0] o);
    
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: mux3
            mux3$ ma(o[i],in0[i],in1[i],in2[i],sel[0],sel[1]);
        end
    endgenerate
endmodule

module mux2n #(parameter N = 8)(
    input [N-1:0] in0,
    input [N-1:0] in1,
    input sel,
    output [N-1:0] o);
    
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: mux2
            mux2$ ma(o[i],in0[i],in1[i],sel);
        end
    endgenerate
endmodule

module regn_bit_enable #(parameter N = 8)(
    input clk,
    input rst,
    input [N-1:0] in,
    input [N-1:0] mask,
    output [N-1:0] o);
    //N-bit register with bit-wise write enable.
    wire [N-1:0] reg_in;
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin: reg_1
            mux2$    ma(reg_in[i],o[i],in[i],mask[i]);
            dff$    d(.clk(clk),.d(reg_in[i]),.q(o[i]),.qbar(),.r(rst),.s(1'b1));
        end
    endgenerate
endmodule
    
    
module regn #(parameter N = 8)(
    input [N-1:0] in,
	input clk,
	input rst,
	input wren,
	output [N-1:0] o);
	//N-bit register with single write enable.
	
	wire [N-1:0] reg_in;
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: reg_1
			mux2$	ma(reg_in[i],o[i],in[i],wren);
			dff$	d(.clk(clk),.d(reg_in[i]),.q(o[i]),.qbar(),.s(1'b1),.r(rst));
		end
	endgenerate
endmodule

module regn_byte_enable #(parameter N = 32)(
    input [N-1:0] in,
    input clk,
    input rst,
    input [`CEIL_N_8(N)-1:0] wren,
    output [N-1:0] o);
    //N bit register with byte enable. N does not need to be a multiple of 8.
    
    parameter iter = `CEIL_N_8(N);
    wire [N-1:0] reg_in;
    genvar i,j;
    generate
        for(i=0; i<iter-1; i=i+1) begin: reg_2o
            for(j=0; j<8; j=j+1) begin: reg_2i
                mux2$    ma(reg_in[i*8+j],o[i*8+j],in[i*8+j],wren[i]);
                dff$    d(.clk(clk),.d(reg_in[i*8+j]),.q(o[i*8+j]),.qbar(),.r(rst),.s(1'b1));
            end
        end
        for(j = (iter-1)*8; j < N; j=j+1) begin: reg_2l
            mux2$    ma(reg_in[j],o[j],in[j],wren[iter-1]);
            dff$    d(.clk(clk),.d(reg_in[j]),.q(o[j]),.qbar(),.r(rst),.s(1'b1));
        end
    endgenerate
endmodule

module bshfrlogic_5b #(parameter WIDTH = 8)(
    input [32*WIDTH-1:0] in,
    input [4:0] shf_val,
    output [32*WIDTH-1:0] o);
    
    //Do not try to parameterize this.
    //Barrel shifter (right shift) for  shifting a 32B piece of data by [0,1,...31] places.
    //NOTE: Unpacked arrays (in_temp, o_temp) are not loaded in DVE by default.
    //TODO: Figure out a way of dumping unpacked arrays. OR Change to a 1D array.
    
    //Create wires.
    wire [7:0] w1 [31:0],w2 [31:0],w3 [31:0],w4 [31:0],w5 [31:0],
            w6 [31:0],w7 [31:0],w8 [31:0],w9 [31:0];
            
    wire [WIDTH-1:0] in_temp [31:0];
    wire [WIDTH-1:0] o_temp [31:0];
    
    genvar i,j;
    
    generate
        for(i=0; i<32; i=i+1) begin: assignl
            for(j=0; j<WIDTH; j=j+1) begin: assign2
                assign in_temp[i][j] = in[i*WIDTH+j];
                assign o[i*WIDTH+j] = o_temp[i][j];
            end
        end
    endgenerate
    
    generate
        //w1 = in >> 16.
        for(i=0; i<16; i=i+1) begin: l1
            assign w1[i] = in_temp[i+16];
        end
        for(i=16; i<32; i=i+1) begin: l2
            assign w1[i] = 8'b0;
        end
        //w3 = w2 >> 4.
        for(i=0; i<28; i=i+1) begin: l3
            assign w3[i] = w2[i+4];
        end
        for(i=28; i<32; i=i+1) begin: l4
            assign w3[i] = 8'b0;
        end
        //w4 = w2 >> 8.
        for(i=0; i<24; i=i+1) begin: l5
            assign w4[i] = w2[i+8];
        end
        for(i=24; i<32; i=i+1) begin: l6
            assign w4[i] = 8'b0;
        end
        //w5 = w2 >> 12.
        for(i=0; i<20; i=i+1) begin: l7
            assign w5[i] = w2[i+12];
        end
        for(i=20; i<32; i=i+1) begin: l8
            assign w5[i] = 8'b0;
        end
        //w7 = w6 >> 1.
        for(i=0; i<31; i=i+1) begin: l9
            assign w7[i] = w6[i+1];
        end
        assign w7[31] = 8'b0;
        //w8 = w6 >> 2.
        for(i=0; i<30; i=i+1) begin: l10
            assign w8[i] = w6[i+2];
        end
        for(i=30; i<32; i=i+1) begin: l11
            assign w8[i] = 8'b0;
        end
        //w9 = w6 >> 3.
        for(i=0; i<29; i=i+1) begin: l12
            assign w9[i] = w6[i+3];
        end
        for(i=29; i<32; i=i+1) begin: l13
            assign w9[i] = 8'b0;
        end
    endgenerate
    
    //Create multiplexers.
    genvar k;
    generate
        for(j=0; j<32; j=j+1) begin: shf_o
            for(k=0; k<WIDTH; k=k+1) begin: shf_i
                mux2$ ma(w2[j][k],in_temp[j][k],w1[j][k],shf_val[4]);
                mux4$     mb(w6[j][k],w2[j][k],w3[j][k],w4[j][k],w5[j][k],shf_val[2],shf_val[3]),
                        mc(o_temp[j][k],w6[j][k],w7[j][k],w8[j][k],w9[j][k],shf_val[0],shf_val[1]);
            end
        end
    endgenerate
endmodule

module mag_comp32 (A, B, AGB, BGA);

	input [31:0] A,B;
	output AGB, BGA;

	wire agbHH, bgaHH, agbHL, bgaHL, agbLH, bgaLH, agbLL, bgaLL;

	mag_comp8$ ll(A[7:0], B[7:0], agbLL, bgaLL),
	           lh(A[15:8], B[15:8], agbLH, bgaLH),
	           hl(A[23:16], B[23:16], agbHL, bgaHL),
	           hh(A[31:24], B[31:24], agbHH, bgaHH);

	mag_comp4$ comp({agbHH, agbHL, agbLH, agbLL}, {bgaHH, bgaHL, bgaLH, bgaLL}, AGB, BGA);
endmodule


module mag_comp16 (A, B, AGB, BGA);

	input [15:0] A,B;
	output AGB, BGA;

	wire agbH, bgaH, agbL, bgaL;

	mag_comp8$ ll(A[7:0], B[7:0], agbL, bgaL),
	           lh(A[15:8], B[15:8], agbH, bgaH);

	nm b(agbH, agbL, bgaH, bgaL, AGB, BGA);
	//mag_comp4$ comp({2'b0, agbH, agbL}, {2'b0, bgaH, bgaL}, AGB, BGA);

endmodule

module xor2n #(parameter N = 8)(
	input [N-1:0] in1,
	input [N-1:0] in2,
	output [N-1:0] o);
	
	genvar i;
	generate
		for(i=0; i<N; i=i+1) begin: and2
			xor2$	d(o[i],in1[i],in2[i]);
		end
	endgenerate
	
endmodule

module nm(a, b, c, d, g, l);
	input a,b,c,d;
	output g,l;

	wire a_bar, b_bar, c_bar, d_bar;

	xnor2$ g1(t1, a, c);
	nor2$  g2(t2, d, b_bar);
	nand2$ g3(t3, t2, t1);
	nand2$  g4(t4, a, c_bar);
	nand2$  g5(g, t3, t4);

	nor2$  g6(t5, b, d_bar);
	nand2$ g7(t6, t5, t1);
	nand2$  g8(t7, c, a_bar);
	nand2$  g9(l, t6, t7);


	inv1$ i1(a_bar, a),
		  i2(b_bar, b),
		  i3(c_bar, c),
		  i4(d_bar, d);

	wire G1, L1;
	assign G1 = ({a,b}>{c,d}) ? 1:0;
	assign L1 = ({a,b}<{c,d}) ? 1:0;

	/*nor2$  n1(x, a_bar, c),
	       n2(y, a, c_bar);
	nand2$ n3(x_bar, a, c_bar),
	       n4(y_bar, a_bar, c);

	nand2$ n5(t1, b_bar, y_bar),
	       n6(t2, d_bar, y_bar),
	       n7(g, t1, x_bar),
	       n8(l, t2, x_bar);*/
endmodule


module fifo8	#(parameter N = 8)(
	input [N-1:0] in,
	input [0:0] wr,
	input [0:0] rd,
	input [0:0] clk,
	input [0:0] reset,
	output[N-1:0] out);

	wire	[2:0]	ptr_in;
	wire	[2:0]	ptr_out;
	wire	[0:0]	ptr_en;
	
	regn	#(3)	r1(ptr_in, clk, reset, ptr_en, ptr_out);

	wire	[N-1:0]	r_in [7:0];	
	wire	[N-1:0]	r_out [7:0];	
	wire	[0:0]	r_en;

	assign 	r_in[0] = in;
	assign 	r_en = wr;
	genvar i;
	generate
		for(i=0; i<7; i=i+1) begin: regs
			regn	#(N)	rr(r_in[i], clk, reset, r_en, r_out[i]);
			assign	r_in[i+1] = r_out[i];
		end
	endgenerate
	regn	#(N)	r2(r_in[7], clk, reset, r_en, r_out[7]);

	//Write	
	wire	[3:0]	ptr_in_inc;
	wire	[3:0]	ptr_in_dec;
	add_4b	add0(ptr_in_inc, , {1'b0, ptr_out}, 4'b0001, 1'b0);
	add_4b	add1(ptr_in_dec, , {1'b0, ptr_out}, 4'b1111, 1'b0);
	mux2n	#(3)	m0(ptr_in_dec[2:0], ptr_in_inc[2:0], wr, ptr_in);	

	or2n	#(1)	a0(rd, wr, ptr_en);
 
	//Read
	mux8n	#(N)	m1(r_out[0], r_out[1], r_out[2], r_out[3], r_out[4], r_out[5], r_out[6], r_out[7], ptr_in_dec[2:0], out);
		

endmodule

module	enc4
	(
	input 	[3:0] in,
	output	[1:0] out
	);

	wire	[0:0]	i0_n;
	wire	[0:0]	i1_n;
	invn	#(1)	i0(i0_n, in[0]);
	invn	#(1)	i1(i1_n, in[1]);
	and2$		a0(out[1], i0_n, i1_n);
	or2$		a1(out[0], in[3], i1_n);

endmodule

module	enc8
	(
	input 	[7:0] in,
	output	[2:0] out
	);

	or4n	#(1)	o0(in[1], in[3], in[5], in[7], out[0]);
	or4n	#(1)	o1(in[2], in[3], in[6], in[7], out[1]);
	or4n	#(1)	o2(in[5], in[5], in[6], in[7], out[2]);

endmodule

module	enc16
	(
	input 	[15:0] in,
	output	[3:0] out
	);

	wire	[0:0]	sel_a;
	wire	[0:0]	sel_b;
	wire	[0:0]	sel;

	or4n	#(1)	o0(in[8], in[9], in[10], in[11], sel_a);
	or4n	#(1)	o1(in[12], in[13], in[14], in[15], sel_b);
	or2n	#(1)	o2(sel_a, sel_b, sel);

	wire	[2:0]	a;
	wire	[2:0]	b;
	enc8	e0(in[7:0], a);
	enc8	e1(in[15:8], b); 

	wire	[2:0]	out_t;
	mux2n	#(3)	m0(a, b, sel, out_t);
	assign	out	= {sel, out_t}; 

endmodule
