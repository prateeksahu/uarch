module rf_d8_1r1w #(parameter N = 8)(
    input clk,
    input rst,
    input rdvld,
    input [2:0] rdaddr,
    output [N-1:0] rddata,
    input wrvld,
    input [2:0] wraddr,
    input [N-1:0] wrdata);
    
    wire [N-1:0] o [7:0];
    wire [7:0] wren1,wren;
    mux8n #(8) m1(8'h1,8'h2,8'h4,8'h8,8'h10,8'h20,8'h40,8'h80,wraddr,wren1);
	and2n #(8) a1(wren1,{8{wrvld}},wren);
    mux8n #(N) m2(o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],rdaddr,rddata);
    genvar i;
    generate
        for(i=0;i<8;i=i+1) begin: l
            regn #(N) r(wrdata,clk,rst,wren[i],o[i]);
        end
    endgenerate
endmodule

//It is assured that all the three enables are high only if it is possible to perform all three
//in the same cycle.
//No two operations can occur in the same "bank".
module dcache_store(
    input clk,
    input clk_dn,
    input rst,
    input rden,
    input mem_wren,
    input wb_wren,
    input [14:0] rdaddr,
    input [14:0] mem_wraddr,
	input [63:0] mem_wrdata,
	input [14:0] wb_wraddr,
	input [63:0] wb_wrdata,
	input [1:0] wb_size,
	
	output evict,
	output [14:0] evict_addr,
	output [63:0] evict_data,
	
	output [31:0] rddata,
    output [1:0] hit_way_r,
	output [1:0] hit_way_w,
    output rd_hit,
	output wb_hit
	);
    
	wire evict_edge;
	nor2$	nj(evict_edge,clk,clk_dn);
	
    wire hit0,hit1,hit2,hit3;
    wire [1:0] hit_way_in [3:0];
	
	wire [3:0] mw1,ww1,mw,ww,rw1,rw;
	wire mw_en,ww_en,rd_en;
	
	inv1$	i1(mw_en,mem_wren),
			i2(ww_en,wb_wren),
			i3(rd_en,rden);
			
	mux4n #(4) m1(4'b1110,4'b1101,4'b1011,4'b0111,mem_wraddr[7:6],mw1);
	mux4n #(4) m2(4'b1110,4'b1101,4'b1011,4'b0111,wb_wraddr[7:6],ww1);
	mux4n #(4) m3(4'b1110,4'b1101,4'b1011,4'b0111,rdaddr[7:6],rw1);
	
	wire ir;
	//xw = ~(xw1) & ~(xw_en).
	nor2n #(4) n1(mw1,{4{mw_en}},mw),
			   n2(ww1,{4{ww_en}},ww);
	nor3n #(4) n3(rw1,{4{ir}},{4{rd_en}},rw);
	
	inv1$	ir1(ir,rd_hit);
	wire [3:0] wrend,wrenl;
	or2n #(4)  ox1(mw,ww,wrend);
	or3n #(4)  xo2(mw,ww,rw,wrenl);
		
	wire [2:0] i_dirty[3:0],o_dirty[3:0],i_dirty1[3:0],i_dirty2[3:0];
    wire [2:0] i_vld[3:0],o_vld[3:0];
    wire [8:0] i_lru[3:0],o_lru[3:0];
    wire [1:0] lru_way[3:0];
	
	genvar i;
	
	wire [63:0] wrdata[3:0];
	wire [14:0] addr [3:0];
	wire [1:0] size [3:0];
	wire [1:0] way [3:0];
	wire [31:0] rddata_int [3:0];
	
	generate
        for(i=0;i<4;i=i+1) begin: loop
            mux3n #(3) ma1({o_dirty[i][2:1],1'b1},{o_dirty[i][2],1'b1,o_dirty[i][0]},{1'b1,o_dirty[i][1:0]},hit_way_in[i],i_dirty1[i]);
            mux3n #(3) ma2({o_dirty[i][2:1],1'b0},{o_dirty[i][2],1'b0,o_dirty[i][0]},{1'b0,o_dirty[i][1:0]},lru_way[i],i_dirty2[i]);
            mux3n #(3) ma3({o_vld[i][2:1],1'b1},{o_vld[i][2],1'b1,o_vld[i][0]},{1'b1,o_vld[i][1:0]},lru_way[i],i_vld[i]);
            mux2n #(3) ma4(i_dirty1[i],i_dirty2[i],mw[i],i_dirty[i]);
        end
    endgenerate
	
    generate
        for(i=0;i<4;i=i+1) begin : bank
            rf_d8_1r1w #(3) dirty(clk,rst,1'b1,addr[i][5:3],o_dirty[i],wrend[i],addr[i][5:3],i_dirty[i]);
            rf_d8_1r1w #(3) valid(clk,rst,1'b1,addr[i][5:3],o_vld[i],mw[i],addr[i][5:3],i_vld[i]);
            rf_d8_1r1w #(9) lru(clk,rst,1'b1,addr[i][5:3],o_lru[i],wrenl[i],addr[i][5:3],i_lru[i]);
        end
    endgenerate
	
	wire [3:0] isevict;
	wire [1:0] hit_way_m;
	wire [3:0] hit_array;
	assign hit_array = {hit3,hit2,hit1,hit0};
	generate
        for(i=0;i<4;i=i+1) begin : plru_l
            plru pl(o_lru[i],o_vld[i],hit_way_in[i],hit_array[i],rw[i],ww[i],mw[i],isevict[i],i_lru[i],lru_way[i]);
        end
    endgenerate
    	
	wire [3:0] v;
	generate
        for(i=0;i<4;i=i+1) begin : wd_gen
			mux2n #(64) m1(mem_wrdata,wb_wrdata,ww[i],wrdata[i]);
			mux2n #(2)  m2(2'b11,wb_size,ww[i],size[i]);
			mux4n #(15) m3(rdaddr,wb_wraddr,mem_wraddr,wb_wraddr,{mw[i],ww[i]},addr[i]);
			mux3n #(2)  m4(hit_way_in[i],hit_way_in[i],lru_way[i],{mw[i],ww[i]},way[i]);
			mux3n #(1)  m5(o_vld[i][0],o_vld[i][1],o_vld[i][2],hit_way_in[i],v[i]);
        end
    endgenerate
	
	wire [2:0] v0,v1,v2,v3;
	assign v0 = o_vld[0];
	assign v1 = o_vld[1];
	assign v2 = o_vld[2];
	assign v3 = o_vld[3];
	
	wire [14:0] tag_out [3:0];
	wire [63:0] full_out [3:0];
	
    dcache_tag_bank b0(clk,clk_dn,rst,1'b1,mw[0],ww[0],addr[0],lru_way[0],tag_out[0],hit_way_in[0],hit0,v0),
                    b1(clk,clk_dn,rst,1'b1,mw[1],ww[1],addr[1],lru_way[1],tag_out[1],hit_way_in[1],hit1,v1),
                    b2(clk,clk_dn,rst,1'b1,mw[2],ww[2],addr[2],lru_way[2],tag_out[2],hit_way_in[2],hit2,v2),
                    b3(clk,clk_dn,rst,1'b1,mw[3],ww[3],addr[3],lru_way[3],tag_out[3],hit_way_in[3],hit3,v3);
  
	dcache_bank bd0(clk,clk_dn,rst,1'b1,mw[0],ww[0],addr[0],wrdata[0],size[0],way[0],rddata_int[0],full_out[0]),
				bd1(clk,clk_dn,rst,1'b1,mw[1],ww[1],addr[1],wrdata[1],size[1],way[1],rddata_int[1],full_out[1]),
				bd2(clk,clk_dn,rst,1'b1,mw[2],ww[2],addr[2],wrdata[2],size[2],way[2],rddata_int[2],full_out[2]),
				bd3(clk,clk_dn,rst,1'b1,mw[3],ww[3],addr[3],wrdata[3],size[3],way[3],rddata_int[3],full_out[3]);

	wire rd_hit1,wb_hit1,mem_hit1;
	wire [14:0] ea1;
	wire [63:0] ed1;
	mux4n #(1) 	m6(hit0,hit1,hit2,hit3,rdaddr[7:6],rd_hit1),
				m6n(hit0,hit1,hit2,hit3,mem_wraddr[7:6],mem_hit1),
				m7(hit0,hit1,hit2,hit3,wb_wraddr[7:6],wb_hit1);
				
	mux4n #(2)  m8(hit_way_in[0],hit_way_in[1],hit_way_in[2],hit_way_in[3],rdaddr[7:6],hit_way_r),
				m8n(hit_way_in[0],hit_way_in[1],hit_way_in[2],hit_way_in[3],mem_wraddr[7:6],hit_way_m),
				m9(hit_way_in[0],hit_way_in[1],hit_way_in[2],hit_way_in[3],wb_wraddr[7:6],hit_way_w);
	mux4n #(32)	m10(rddata_int[0],rddata_int[1],rddata_int[2],rddata_int[3],rdaddr[7:6],rddata);
	
		    
	wire [3:0] isevict_reg;
	wire [14:0] evict_addr_reg [3:0];
	wire [63:0] evict_data_reg [3:0];
	
	wire clk_test;
	wire [1:0] clk_1;
	inv1$	iclk(clk_1[0],clk),
			iclk1(clk_1[1],clk_1[0]),
			iclk2(clk_test,clk_1[1]);
	generate
		for(i=0;i<4;i=i+1) begin: evict_loop
			dffn #(1) r1(isevict[i],clk_test,rst,isevict_reg[i]);
			dffn #(15) r2(tag_out[i],clk_test,rst,evict_addr_reg[i]);
			dffn #(64) r3(full_out[i],clk_test,rst,evict_data_reg[i]);
		end
	endgenerate
	
	mux4n #(1) m11(isevict_reg[0],isevict_reg[1],isevict_reg[2],isevict_reg[3],mem_wraddr[7:6],evict);
	
	mux4n #(15) m12({evict_addr_reg[0][14:8],2'b00,evict_addr_reg[0][5:0]},{evict_addr_reg[1][14:8],2'b01,evict_addr_reg[1][5:0]},
					{evict_addr_reg[2][14:8],2'b10,evict_addr_reg[2][5:0]},{evict_addr_reg[3][14:8],2'b11,evict_addr_reg[3][5:0]},
					mem_wraddr[7:6],evict_addr);
	mux4n #(64) m13(evict_data_reg[0],evict_data_reg[1],evict_data_reg[2],evict_data_reg[3],mem_wraddr[7:6],evict_data);

	and2$	ax1(rd_hit,rd_hit1,rden),
			ax2(wb_hit,wb_hit1,wb_wren);

       //Debug wires.
       wire [14:0] tj1,tj2,tj3,tj4;
       assign tj1 = tag_out[0];
       assign tj2 = tag_out[1];
       assign tj3 = tag_out[2];
       assign tj4 = tag_out[3];
       
       wire [14:0] tj5,tj6,tj7,tj8;
       assign tj5 = evict_addr_reg[0];
       assign tj6 = evict_addr_reg[1];
       assign tj7 = evict_addr_reg[2];
       assign tj8 = evict_addr_reg[3];
endmodule
