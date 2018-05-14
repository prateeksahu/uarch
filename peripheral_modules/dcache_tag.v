module dcache_tag_bank(
    input clk,
    input clk_dn,
    input rst,
    input rden,
    input mem_wren,
    input wb_wren,
    input [14:0] addr,
    input [1:0] update_way,
	output [14:0] tag_out,
    output [1:0] hit_way,
    output hit,
	input [2:0] valid);
    
    wire [2:0] wmask,wmask1,wmask2;
    wire wrn,wr;
	
    //Delay the data so that it changes after the wren.
    wire [6:0] wd1,wd2,wd3,wd4;
    assign wd4 = addr[14:8];
	
    wire clk_n1,wx;
    inv1$    i1(clk_n1,clk);
    nand2$   n1(wx,clk_n1,clk_dn); //wx has a short negative pulse.
    
    wire vld;
    inv1$    n2(vld,mem_wren); //vld = !(wren)
    mux3n #(3) m2(3'b110,3'b101,3'b011,update_way,wmask1);    //wmask1=!(wmask)
    or3n  #(3) n3({wx,wx,wx},{vld,vld,vld},wmask1,wmask2);
    
    mux4n #(3) m3(3'b111,3'b111,wmask2,3'b111,{rst,clk},wmask);
    
    wire [7:0] tag0,tag1,tag2;
    ram8b8w$ t0(addr[5:3],{1'b0,wd4},1'b0,wmask[0],tag0);    
    ram8b8w$ t1(addr[5:3],{1'b0,wd4},1'b0,wmask[1],tag1);    
    ram8b8w$ t2(addr[5:3],{1'b0,wd4},1'b0,wmask[2],tag2);    
    
	wire [7:0] tag_int;
	mux3n #(8) mx1(tag0,tag1,tag2,update_way,tag_int);
	assign tag_out = {tag_int,2'b00,addr[5:3],3'b0};
	
    //Compare tags of all the ways.
    wire e1,e2,e3;
    comp_eq7  c1(tag0[6:0],addr[14:8],e1),
              c2(tag1[6:0],addr[14:8],e2),
              c3(tag2[6:0],addr[14:8],e3);
    
	wire f1,f2,f3;
	nand2$	c4(f1,e1,valid[0]),
			c5(f2,e2,valid[1]),
			c6(f3,e3,valid[2]);
			
    //Generate hit & hit way.
    nand3$    o1(hit,f1,f2,f3);
    
    //{e3,e2,e1}: 000->00,001->00,010->01,100->10.
    wire f3n,f2n;
    inv1$	it1(f3n,f3),
		it2(f2n,f2);
    assign hit_way = {f3n,f2n};
//	mux8n #(2) hwm(2'b0,2'h2,2'h1,2'h1,2'b0,2'b0,2'b0,2'b0,{f1,f2,f3},hit_way);
    
	wire [7:0] w00,w10,w20,w30,w40,w50,w60,w70;
	assign w00 = t0.mem[0];
	assign w10 = t0.mem[1];
	assign w20 = t0.mem[2];
	assign w30 = t0.mem[3];
	assign w40 = t0.mem[4];
	assign w50 = t0.mem[5];
	assign w60 = t0.mem[6];
	assign w70 = t0.mem[7];
	
	wire [7:0] w01,w11,w21,w31,w41,w51,w61,w71;
	assign w01 = t1.mem[0];
	assign w11 = t1.mem[1];
	assign w21 = t1.mem[2];
	assign w31 = t1.mem[3];
	assign w41 = t1.mem[4];
	assign w51 = t1.mem[5];
	assign w61 = t1.mem[6];
	assign w71 = t1.mem[7];
	
	wire [7:0] w02,w12,w22,w32,w42,w52,w62,w72;
	assign w02 = t2.mem[0];
	assign w12 = t2.mem[1];
	assign w22 = t2.mem[2];
	assign w32 = t2.mem[3];
	assign w42 = t2.mem[4];
	assign w52 = t2.mem[5];
	assign w62 = t2.mem[6];
	assign w72 = t2.mem[7];
endmodule
