module dcache_bank(
    input clk,
	input clk_dn,
    input rst,
    input rden,
    input mem_wren,
    input wb_wren,
    input [14:0] addr,
    input [63:0] wrdata,
    input [1:0] wrsize,
    input [1:0] way,
    
    output [31:0] rddata,
	output [63:0] full_out);
    
    wire [63:0] rddata_t0,rddata_t1,rddata_t2;
    wire [23:0] wmask0;
	wire [23:0] wmask1,wmask2;
	wire [7:0] wm,wm1,wm2,wm3,wm4,wm5;
	
    wire clk_n1,wx;
    inv1$    i1(clk_n1,clk);
    or2$   n1(wx,clk,clk_dn);   //wx has a short negative pulse.
    
	//Generate write mask wmask2. wmask == 1 iff vld & correct_way && correct_row.
    wire vld;
    or2$    n2(vld,mem_wren,wb_wren); //vld = (wren)
    mux3n  #(24)  m2({16'b0,8'hff},{8'b0,8'hff,8'b0},{8'hff,16'b0},way,wmask0);   
	nand3n #(24) m3(wmask0,{wm,wm,wm},{24{vld}},wmask1);
    mux4n #(24)  m4({24{1'b1}},{24{1'b1}},wmask1,{24{1'b1}},{rst,clk},wmask2);  
			
	mux8n #(8) 	mw1(8'h1,8'h2,8'h4,8'h8,8'h10,8'h20,8'h40,8'h80,addr[2:0],wm1),
				mw2(8'h3,8'h6,8'hc,8'h18,8'h30,8'h60,8'hc0,8'h80,addr[2:0],wm2),
				mw3(8'h7,8'he,8'h1c,8'h38,8'h70,8'he0,8'hc0,8'h80,addr[2:0],wm3),
				mw4(8'hf,8'h1e,8'h3c,8'h78,8'hf0,8'he0,8'hc0,8'h80,addr[2:0],wm4);
	mux4n #(8)  mw5(wm1,wm2,wm3,wm4,wrsize,wm5);
	mux2n #(8)  mw6(wm5,8'hff,mem_wren,wm);
	
	//Shift the data left according to address.
	wire [63:0] data0,data1,data;
	mux4n #(64) m6(wrdata,{wrdata[55:0],8'b0},{wrdata[47:0],16'b0},{wrdata[39:0],24'b0},addr[1:0],data0);
	mux4n #(64) m7({wrdata[31:0],32'b0},{wrdata[23:0],40'b0},{wrdata[15:0],48'b0},{wrdata[7:0],56'b0},addr[1:0],data1);
	mux4n #(64) m8(data0,data1,wrdata,wrdata,{mem_wren,addr[2]},data);
	
	//Shift the read data right according to addr.
	wire [63:0] rd0,rd1,rd2,rdx;
	mux8n #(64) m13(rddata_t0,{8'b0,rddata_t0[63:8]},{16'b0,rddata_t0[63:16]},{24'b0,rddata_t0[63:24]},
				{32'b0,rddata_t0[63:32]},{40'b0,rddata_t0[63:40]},{48'b0,rddata_t0[63:48]},
				{56'b0,rddata_t0[63:56]},addr[2:0],rd0);
	mux8n #(64) m14(rddata_t1,{8'b0,rddata_t1[63:8]},{16'b0,rddata_t1[63:16]},{24'b0,rddata_t1[63:24]},
				{32'b0,rddata_t1[63:32]},{40'b0,rddata_t1[63:40]},{48'b0,rddata_t1[63:48]},
				{56'b0,rddata_t1[63:56]},addr[2:0],rd1);
	mux8n #(64) m15(rddata_t2,{8'b0,rddata_t2[63:8]},{16'b0,rddata_t2[63:16]},{24'b0,rddata_t2[63:24]},
				{32'b0,rddata_t2[63:32]},{40'b0,rddata_t2[63:40]},{48'b0,rddata_t2[63:48]},
				{56'b0,rddata_t2[63:56]},addr[2:0],rd2);
				
	mux3n #(64) m16(rd0,rd1,rd2,way,rdx);
	mux3n #(64) m17(rddata_t0,rddata_t1,rddata_t2,way,full_out);
	
	assign rddata = rdx[31:0];
	
	genvar i;
    generate
        for(i=0;i<8;i=i+1) begin : way0
            ram8b8w$ r(addr[5:3],data[i*8+:8],1'b0,wmask2[i],rddata_t0[i*8+:8]);    
        end
        for(i=0;i<8;i=i+1) begin : way1
            ram8b8w$ r(addr[5:3],data[i*8+:8],1'b0,wmask2[8+i],rddata_t1[i*8+:8]);    
        end
        for(i=0;i<8;i=i+1) begin : way2
            ram8b8w$ r(addr[5:3],data[i*8+:8],1'b0,wmask2[16+i],rddata_t2[i*8+:8]);    
        end
    endgenerate
endmodule