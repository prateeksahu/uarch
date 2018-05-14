////////////////////////////////////////////////////////////////////////////////
/////                       FIFOS & BUFFERS.                              //////
///// 1. fifo8_1r1w: FIFO of depth 8, 1 read & 1 write per cycle. Keeps 3 //////
///// pointers, 1 read, 1 write & 1 request. The request pointer can be u-//////
///// to keep track of anything that increases by 1 based on some signal, //////
///// but which does not change the valid state of the buffer. vld_1r1w_d8//////
///// provides the structure of the associated valid buffer.              //////
///// 2. buf8_allread: A structure of depth 8, that gets filled in element//////
///// by element,and is then concatenated and read out all at once. vld8_ //////
///// allread provides the associated valid array.                        //////
///// 3. buf2_fullread: Similar to the above, for a depth of 2.           //////
///// These are NOT truly generic structures. Please check with me before //////
///// trying to use them.                                                 //////
///// 4. rf_d32_2r2w: A register file of arbitary width, with 2 reads & 2 //////
///// writes per cycle. Has a depth of 32.                                //////
///// 5. rf_d32_2r1w: Same as above, but supporting 1 write instead.      //////
///// 6.rf_d32_2r1w_lp: Same as above, but using library parts instead.   //////
////////////////////////////////////////////////////////////////////////////////

module vld_1r1w_d8 (
   input clk,
   input rst,
   input [2:0] wraddr,
   input [2:0] rdaddr,
   input [2:0] reqaddr, //HACK for making it work for Load queue!
   input push,
   input pop,
   output reqvld,
   output full,
   output empty_n);
   
   
   wire [7:0] valid,in,mask,in1,in2,in3,in4,in5;
   wire rv1,rv2;
   
   regn_bit_enable #(8) rv(.clk(clk),.rst(rst),.in(in),.mask(mask),.o(valid));
   
   
   mux4n #(8) m2(8'h1,8'h2,8'h4,8'h8,wraddr[1:0],in1),
             m3(8'h10,8'h20,8'h40,8'h80,wraddr[1:0],in2),
             m4(8'h0,8'h0,in1,in2,{push,wraddr[2]},in);
   
   mux4n #(8) m5(8'h1,8'h2,8'h4,8'h8,rdaddr[1:0],in3),
              m6(8'h10,8'h20,8'h40,8'h80,rdaddr[1:0],in4),
              m7(8'h0,8'h0,in3,in4,{pop,rdaddr[2]},in5);
   
   mux4n #(1) m8(valid[0],valid[1],valid[2],valid[3],reqaddr[1:0],rv1),
              m9(valid[4],valid[5],valid[6],valid[7],reqaddr[1:0],rv2);
            
   mux2n #(1) m0(rv1,rv2,reqaddr[2],reqvld);
   
   or2n  #(8) o1(in,in5,mask);
   
   wire a1,a2;
   and4$   an1(a1,valid[0],valid[1],valid[2],valid[3]),
           an2(a2,valid[4],valid[5],valid[6],valid[7]);
   and2$   an3(full,a1,a2);
   
   wire e1,e2;
   or4$   on1(e1,valid[0],valid[1],valid[2],valid[3]),
          on2(e2,valid[4],valid[5],valid[6],valid[7]);
   or2$   on3(empty_n,e1,e2);
endmodule

module fifo8_1r1w #(parameter WIDTH = 32) (
    input clk,
    input rst,
    input push,
    input [WIDTH-1:0] in_data,
    input pop,
    input bus_gnt,       //HACK to make it work for Load Buffer. Don't change this!
    output [WIDTH-1:0] out_data,
    output out_data_vld,
    output full
); 
   parameter iter = `CEIL_N_8(WIDTH);
   
    wire [2:0] wrptr,rdptr,reqptr;
    wire w1,w2,full_n,empty_n;
    wire [3:0] wrptr_n,rdptr_n,reqptr_n;
    wire e1,e1n;
   
   inv1$    i1(full_n,full);
   and2$    a1(w1,push,full_n);
   and2$    a2(w2,pop,empty_n);
   
   
   comp_eq3    c1(wrptr,reqptr,e1);
   inv1$       i2(e1n,e1);
   and2$       a3(w3,e1n,bus_gnt);
   
   vld_1r1w_d8 vld(clk,rst,wrptr,rdptr,reqptr,push,pop,out_data_vld,full,empty_n);
    
    inc_4b     d1(.S(rdptr_n),.cout(),.A({1'b0,rdptr})),
               d2(.S(wrptr_n),.cout(),.A({1'b0,wrptr})),
               d3(.S(reqptr_n),.cout(),.A({1'b0,reqptr}));
            
    regn #(3) wr(.clk(clk),.rst(rst),.in(wrptr_n[2:0]),.wren(w1),.o(wrptr)),
              rd(.clk(clk),.rst(rst),.in(rdptr_n[2:0]),.wren(w2),.o(rdptr)),
              rq(.clk(clk),.rst(rst),.in(reqptr_n[2:0]),.wren(w3),.o(reqptr));
           
    genvar i;
    generate
        for(i=0; i<iter; i=i+1) begin : l
            regfile8x8$    REG(.IN0(in_data[i*8+:8]),
                            .R1(rdptr),
                            .R2(reqptr),
                            .RE1(1'b1),
                            .RE2(1'b1),
                            .W(wrptr),
                            .WE(w1),
                            .OUT1(),
                            .OUT2(out_data[i*8+:8]),
                            .CLOCK(clk));
        end
    endgenerate
endmodule                    

module vld8_allread (
   input clk,
   input rst,
   input [2:0] wraddr,
   input wrvld,
   input invalidate,
   output full);
   
   
   wire [7:0] valid,in,mask,in1,in2,inw;
   regn_bit_enable #(8) rv(.clk(clk),.rst(rst),.in(in),.mask(mask),.o(valid));
   
   
   mux4n #(8) m1(8'h1,8'h2,8'h4,8'h8,wraddr[1:0],in1),
              m2(8'h10,8'h20,8'h40,8'h80,wraddr[1:0],in2);
   mux2n #(8) m3(in1,in2,wraddr[2],inw);
   
   mux4n #(8) m4(8'h0,inw,8'hff,8'hff,{invalidate,wrvld},mask);
   mux4n #(8) m5(8'h0,inw,8'h0,inw,{invalidate,wrvld},in);
   
   wire a1,a2;
   and4$   an1(a1,valid[0],valid[1],valid[2],valid[3]),
           an2(a2,valid[4],valid[5],valid[6],valid[7]);
   and2$   an3(full,a1,a2);
endmodule

module buf8_allread #(parameter WIDTH = 32)(
   input clk,
   input rst,
   input [WIDTH-1:0] inp,
   input inp_vld,
   output [WIDTH*8-1:0] o,
   output o_vld);
   
   wire [7:0] wren,in1,in2,in3;
   wire [2:0] ptr;
   wire [3:0] ptr_n;
   wire invalidate,full;
   wire i1;
   
   inv1$   ia1(i1,invalidate);
   and2$   a1(o_vld,full,i1);
   
   vld8_allread vld(clk,rst,ptr,inp_vld,invalidate,full);
   
   dffn #(1)  df1(o_vld,clk,rst,invalidate);
   
   inc_4b     d1(.S(ptr_n),.cout(),.A({1'b0,ptr}));            
    regn #(3)  wr(.clk(clk),.rst(rst),.in(ptr_n[2:0]),.wren(inp_vld),.o(ptr));
   
   mux4n #(8) m1(8'h1,8'h2,8'h4,8'h8,ptr[1:0],in1),
            m2(8'h10,8'h20,8'h40,8'h80,ptr[1:0],in2);
   mux2n #(8) m3(in1,in2,ptr[2],in3);
   mux2n #(8) m4(8'h0,in3,inp_vld,wren);
   
   genvar i;        
   generate 
      for(i=0;i<8;i=i+1) begin: l
         regn #(WIDTH) r(inp,clk,rst,wren[i],o[WIDTH*i +: WIDTH]);
      end
   endgenerate
   
endmodule

module vld2_fullread (
    input clk,
    input rst,
   input wraddr,
   input wrvld,
   input invalidate,
   output full);
   
   
   wire [1:0] valid,in,mask,inw;
   regn_bit_enable #(2) rv(.clk(clk),.rst(rst),.in(in),.mask(mask),.o(valid));
   
   mux2n #(2) m1(2'b01,2'b10,wraddr,inw);
   
   mux4n #(2) m2(2'h0,inw,2'b11,2'b11,{invalidate,wrvld},mask);
   mux4n #(2) m3(2'h0,inw,2'b0,inw,{invalidate,wrvld},in);
   
   and2$   an3(full,valid[0],valid[1]);
endmodule

module buf2_fullread #(parameter WIDTH = 32)(
   input clk,
   input rst,
   input [WIDTH-1:0] inp,
   input inp_vld,
   output [WIDTH*2-1:0] o,
   output o_vld);
   
   wire [1:0] wren;
   wire ptr,ptr_n,inv,full,ix1;
   
   vld2_fullread vld(clk,rst,ptr,inp_vld,inv,full);
   
   inv1$   ia1(ix1,inv);
   and2$   a1(o_vld,full,ix1);
   
   dffn #(1)     df1(o_vld,clk,rst,inv);
      
   inv1$      i1(ptr_n,ptr);           
    regn #(1)     wr(.clk(clk),.rst(rst),.in(ptr_n),.wren(inp_vld),.o(ptr));
      
   mux4n #(2)    m1(2'b0,2'b0,2'b01,2'b10,{inp_vld,ptr},wren);
   
   genvar i;        
   generate 
      for(i=0;i<2;i=i+1) begin: l
         regn #(WIDTH) r(clk,rst,inp,wren[i],o[WIDTH*i +: WIDTH]);
      end
   endgenerate
   
endmodule
   
module rf_d32_2r2w #(parameter WIDTH = 8)(
	input clk,
	input rst,
	input rden0,
	input [4:0] rdaddr0,
	input rden1,
	input [4:0] rdaddr1,
	input wren0,
	input [4:0] wraddr0,
	input [WIDTH-1:0] wrdata0,
	input wren1,
	input [4:0] wraddr1,
	input [WIDTH-1:0] wrdata1,
	output [WIDTH-1:0] rddata0,
	output [WIDTH-1:0] rddata1);
	
	wire [31:0] o [WIDTH-1:0];
	wire [31:0] in [WIDTH-1:0];
	wire [31:0] wren,w1,w2,w3,w4;
	
	mux32n #(WIDTH) m1(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],o[8],o[9],o[10],
					o[11],o[12],o[13],o[14],o[15],o[16],o[17],o[18],o[19],o[20],
					o[21],o[22],o[23],o[24]o[25]o[26],o[27],o[28],o[29],o[30],o[31],rdaddr0,rddata0);
	
	mux32n #(WIDTH) m2(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],o[8],o[9],o[10],
					o[11],o[12],o[13],o[14],o[15],o[16],o[17],o[18],o[19],o[20],
					o[21],o[22],o[23],o[24]o[25]o[26],o[27],o[28],o[29],o[30],o[31],rdaddr1,rddata1);
					
	mux32n #(32)    m3(32'h1,32'h2,32'h4,32'h8,32'h10,32'h20,32'h40,32'h80,32'h100,32'h200,32'h400,32'h800,
						32'h1000,32'h2000,32'h4000,32'h8000,32'h1_0000,32'h2_0000,32'h4_0000,32'h8_0000,32'h10_0000
						,32'h20_0000,32'h40_0000,32'h80_0000,32'h100_0000,32'h200_0000,32'h400_0000,32'h800_0000,
						32'h1000_0000,32'h2000_0000,32'h4000_0000,32'h8000_0000,wraddr0,w1);
	
	mux32n #(32)    m4(32'h1,32'h2,32'h4,32'h8,32'h10,32'h20,32'h40,32'h80,32'h100,32'h200,32'h400,32'h800,
						32'h1000,32'h2000,32'h4000,32'h8000,32'h1_0000,32'h2_0000,32'h4_0000,32'h8_0000,32'h10_0000
						,32'h20_0000,32'h40_0000,32'h80_0000,32'h100_0000,32'h200_0000,32'h400_0000,32'h800_0000,
						32'h1000_0000,32'h2000_0000,32'h4000_0000,32'h8000_0000,wraddr1,w2);
						
	mux2n #(32)		m5(32'b0,w1,wren0,w3),
					m6(32'b0,w2,wrren1,w4);
	or2n #(32)		o1(w3,w4,wren);
					
	genvar i;
	generate
		for(i=0;i<32;i=i+1) begin: k
			mux4n #(WIDTH) mx(o[i],wrdata1,wrdata0,wrdata0,{w1[i],w2[i]},in[i]);
			regn #(WIDTH) r(.clk(clk),.rst(rst),.in(in[i]),.wren(wren[i]),.o(o[i]));
		end
	endgenerate
	
	
endmodule

module rf_d8_2r2w #(parameter WIDTH = 8)(
	input clk,
	input rst,
	input rden0,
	input [2:0] rdaddr0,
	input rden1,
	input [2:0] rdaddr1,
	input wren0,
	input [2:0] wraddr0,
	input [WIDTH-1:0] wrdata0,
	input wren1,
	input [2:0] wraddr1,
	input [WIDTH-1:0] wrdata1,
	output [WIDTH-1:0] rddata0,
	output [WIDTH-1:0] rddata1);
	
	wire [7:0] o [WIDTH-1:0];
	wire [7:0] in [WIDTH-1:0];
	wire [7:0] wren,w1,w2,w3,w4;
	
	
	mux8n #(WIDTH) m1(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],rdaddr0,rddata0);
	
	mux8n #(WIDTH) m2(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],rdaddr1,rddata1);
					
	mux32n #(8)    m3(8'h1,8'h2,8'h4,8'h8,8'h10,8'h20,8'h40,8'h80,wraddr0,w1);
	
	mux32n #(8)    m4(8'h1,8'h2,8'h4,8'h8,8'h10,8'h20,8'h40,8'h80,wraddr1,w2);
						
	mux2n #(8)		m5(8'b0,w1,wren0,w3),
					m6(8'b0,w2,wrren1,w4);
	or2n #(8)		o1(w3,w4,wren);
					
	genvar i;
	generate
		for(i=0;i<8;i=i+1) begin: k
			mux4n #(WIDTH) mx(o[i],wrdata1,wrdata0,wrdata0,{w1[i],w2[i]},in[i]);
			regn #(WIDTH) r(.clk(clk),.rst(rst),.in(in[i]),.wren(wren[i]),.o(o[i]));
		end
	endgenerate
	
	
endmodule

module rf_d32_2r1w #(parameter WIDTH = 8)(
	input clk,
	input rst,
	input rden0,
	input [4:0] rdaddr0,
	input rden1,
	input [4:0] rdaddr1,
	input wren,
	input [4:0] wraddr,
	input [WIDTH-1:0] wrdata,
	output [WIDTH-1:0] rddata0,
	output [WIDTH-1:0] rddata1);
	
	wire [31:0] o [WIDTH-1:0];
	wire [31:0] in [WIDTH-1:0];
	wire [31:0] wmask,w1;
	
	mux32n #(WIDTH) m1(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],o[8],o[9],o[10],
					o[11],o[12],o[13],o[14],o[15],o[16],o[17],o[18],o[19],o[20],
					o[21],o[22],o[23],o[24]o[25]o[26],o[27],o[28],o[29],o[30],o[31],rdaddr0,rddata0);
	
	mux32n #(WIDTH) m2(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],o[8],o[9],o[10],
					o[11],o[12],o[13],o[14],o[15],o[16],o[17],o[18],o[19],o[20],
					o[21],o[22],o[23],o[24]o[25]o[26],o[27],o[28],o[29],o[30],o[31],rdaddr1,rddata1);
					
	mux32n #(32)    m3(32'h1,32'h2,32'h4,32'h8,32'h10,32'h20,32'h40,32'h80,32'h100,32'h200,32'h400,32'h800,
						32'h1000,32'h2000,32'h4000,32'h8000,32'h1_0000,32'h2_0000,32'h4_0000,32'h8_0000,32'h10_0000
						,32'h20_0000,32'h40_0000,32'h80_0000,32'h100_0000,32'h200_0000,32'h400_0000,32'h800_0000,
						32'h1000_0000,32'h2000_0000,32'h4000_0000,32'h8000_0000,wraddr,w1);
						
	mux2n #(32)		m5(32'b0,w1,wren,wmask);
	genvar i;
	generate
		for(i=0;i<32;i=i+1) begin: k
			regn #(WIDTH) r(.clk(clk),.rst(rst),.in(wrdata),.wren(wmask[i]),.o(o[i]));
		end
	endgenerate
endmodule


module rf_d32_2r1w_lp #(parameter WIDTH = 8)(
	input clk,
	input rst,
	input rden0,
	input [4:0] rdaddr0,
	input rden1,
	input [4:0] rdaddr1,
	input wren,
	input [4:0] wraddr,
	input [WIDTH-1:0] wrdata,
	input [`CEIL_N_8(WIDTH)-1:0] wrmask,
	output [WIDTH-1:0] rddata0,
	output [WIDTH-1:0] rddata1);
	
	wire [3:0] wren_in,w1;
	wire [WIDTH-1:0] data00,data01,data02,data03,data10,data11,data12,data13;
	wire [`CEIL_N_8(WIDTH)-1:0] wrmask_in0,wrmask_in1,wrmask_in2,wrmask_in3;
	
	mux4n #(4) m1(4'b0001,4'b0010,4'b0100,4'b1000,wraddr[4:3],w1);
	mux2n #(4) m2(4'b0,w1,wren,wren_in);
	mux4n #(WIDTH) m3(data00,data01,data02,data03,rdaddr0[4:3],rddata0),
				   m4(data10,data11,data12,data13,rdaddr1[4:3],rddata1);
				  
	genvar j;
	generate
		for(j=0;j<`CEIL_N_8(WIDTH);j=j+1) begin : m
			and2$	a1(wrmask_in0[j],wrmask[j],wren_in[0]),
					a2(wrmask_in1[j],wrmask[j],wren_in[1]),
					a3(wrmask_in2[j],wrmask[j],wren_in[2]),
					a4(wrmask_in3[j],wrmask[j],wren_in[3]);
					
			regfile8x8$    REG0(.IN0(wrdata[j*8+:8]),.R1({2'b0,rdptr0[2:0]}),.R2({2'b0,rdptr0[2:0]}),
						   .RE1(rden0),.RE2(rden1),.W({2'b0,wrptr[2:0]}),.WE(wrmask_in0[j]),
						   .OUT1(data00[j*8+:8]),.OUT2(data10[j*8+:8]),.CLOCK(clk));
			regfile8x8$    REG1(.IN0(wrdata[j*8+:8]),.R1({2'b1,rdptr0[2:0]}),.R2({2'b1,rdptr0[2:0]}),
						   .RE1(rden0),.RE2(rden1),.W({2'b1,wrptr[2:0]}),.WE(wrmask_in1[j]),
						   .OUT1(data01[j*8+:8]),.OUT2(data11[j*8+:8]),.CLOCK(clk));
			regfile8x8$    REG2(.IN0(wrdata[j*8+:8]),.R1({2'b10,rdptr0[2:0]}),.R2({2'b10,rdptr0[2:0]}),
						   .RE1(rden0),.RE2(rden1),.W({2'b10,wrptr[2:0]}),.WE(wrmask_in2[j]),
						   .OUT1(data02[j*8+:8]),.OUT2(data12[j*8+:8]),.CLOCK(clk));
			regfile8x8$    REG3(.IN0(wrdata[j*8+:8]),.R1({2'b11,rdptr0[2:0]}),.R2({2'b11,rdptr0[2:0]}),
						   .RE1(rden0),.RE2(rden1),.W({2'b11,wrptr[2:0]}),.WE(wrmask_in3[j]),
						   .OUT1(data03[j*8+:8]),.OUT2(data13[j*8+:8]),.CLOCK(clk));			   
		end
	endgenerate
	
	
endmodule

 module rf_d8_2r1w #(parameter WIDTH = 8)(
	input clk,
	input rst,
	input rden0,
	input [2:0] rdaddr0,
	input rden1,
	input [2:0] rdaddr1,
	input wren,
	input [2:0] wraddr,
	input [WIDTH-1:0] wrdata,
	output [WIDTH-1:0] rddata0,
	output [WIDTH-1:0] rddata1);
	
	wire [7:0] o [WIDTH-1:0];
	wire [7:0] in [WIDTH-1:0];
	wire [7:0] wmask,w1;
	
	mux8n #(WIDTH) m1(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],rdaddr0,rddata0);
	
	mux8n #(WIDTH) m2(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],rdaddr1,rddata1);
					
	mux8n #(8)    m3(8'h1,8'h2,8'h4,8'h8,8'h10,8'h20,8'h40,8'h80,wraddr,w1);
						
	mux2n #(8)		m5(8'b0,w1,wren,wmask);
	genvar i;
	generate
		for(i=0;i<8;i=i+1) begin: k
			regn #(WIDTH) r(.clk(clk),.rst(rst),.in(wrdata),.wren(wmask[i]),.o(o[i]));
		end
	endgenerate
endmodule