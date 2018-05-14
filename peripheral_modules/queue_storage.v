module queue_8 #(parameter WIDTH = 95)(
    input clk,
    input rst,
    input [WIDTH-1:0] i_data,
    input i_vld,
    input read,
    output o_vld,
    output [WIDTH-33:0] o_data,
    output queue_full);
   
    wire [2:0] wrptr,rdptr;
    wire [3:0] rd_i1,wr_i1;
    wire [7:0] vld;
    wire [WIDTH-1:0] o_data1, data [7:0];
    wire wn1,wn2,eq,w1,w2,half;
    wire [7:0] wren,rden;
    wire [7:0] wmask0,wmask1,mask;
	wire halfn;
	
	inv1$	iv1(halfn,half);
        
    inc_4b     i1(rd_i1,,{1'b0,rdptr}),
            i2(wr_i1,,{1'b0,wrptr});
    regn #(3) r1(wr_i1[2:0],clk,rst,i_vld,wrptr);
    regn #(3) r2(rd_i1[2:0],clk,rst,w1,rdptr);
   
    assign o_data[63] = 1'b0; 
    assign o_data[62:52] = o_data1[94:84];
    assign o_data[51] = halfn;
	assign o_data[50:32] = o_data1[82:64];
    
    mux2n #(32) m1(o_data1[31:0],o_data1[63:32],half,o_data[31:0]);
    and4$    o1(wn1,vld[0],vld[1],vld[2],vld[3]),
            o2(wn2,vld[4],vld[5],vld[6],vld[7]);
    and2$    o3(queue_full,wn1,wn2);
    
    mux8n #(1) m2(vld[0],vld[1],vld[2],vld[3],vld[4],vld[5],vld[6],vld[7],rdptr,o_vld);
    mux8n #(WIDTH) m3(data[0],data[1],data[2],data[3],data[4],data[5],data[6],data[7],rdptr,o_data1);
    
    xnor2$    x1(eq,half,o_data1[92]);    //half == o_data.reqCycles[0].
    and3$    a1(w1,o_vld,read,eq);
    and3$    a4(w2,o_vld,read,o_data1[92]);
    

    decoder3_8$    d1(wrptr,wren,),
                d2(rdptr,rden,);
    
    and2n #(8)     a2(wren,{8{i_vld}},wmask0),
                a3(rden,{8{w1}},wmask1);
    or2n #(8)    o4(wmask0,wmask1,mask);
    
    regn #(1)     h(halfn,clk,rst,w2,half);
    
	genvar i;
    generate
        for(i=0;i<8;i=i+1) begin :l
            regn #(1) rv1(wren[i],clk,rst,mask[i],vld[i]);
            regn #(WIDTH)rv4(i_data,clk,rst,wmask0[i],data[i]);
        end
    endgenerate

	wire [WIDTH-1:0] db0,db1,db2,db3,db4,db5,db6,db7;
	assign db0 = data[0];
	assign db1 = data[1];
	assign db2 = data[2];
	assign db3 = data[3];
	assign db4 = data[4];
	assign db5 = data[5];
	assign db6 = data[6];
	assign db7 = data[7];
	
    /*always @(posedge clk){
        if(~rst){
            rdptr <= 0;
            wrptr <= 0;
            half <= 0;
        } else {
            if(vld){
                data[wrptr] <= di;
                v[wrptr] <= 1;
                wrptr++;
            }
            if(o_vld & read){
                if(half == reqCycles[0]){
                    v[rdptr] <= 0;
                    reptr++;
                }
                if(reqCycles[0])    half <= ~half;
            }
        }
    }*/
    
endmodule

module icache_collect(
    input clk,
    input rst,
    input i_vld,
    input i_1st,
    input [31:0] i_data,
    input [14:0] i_addr,
    output o_vld,
    output [255:0] o_data,
    output [14:0] o_addr);
    
    wire v;
    wire [3:0] cnti;
    wire [2:0] cnt;
    wire [7:0] regwr1,regwr;
    wire [14:0] addr;
    wire [31:0] data [7:0];
    wire vldn,c1,c2,ovldn;
    inv1$	iv1(ovldn,o_vld);
	
    regn #(3)     c(cnti[2:0],clk,rst,i_vld,cnt);
    regn #(15)    ad(i_addr,clk,rst,c2,addr);
    
	regn #(1)    vld(ovldn,clk,rst,i_vld,v);
    
    inc_4b i1(cnti,,{1'b0,cnt});
    decoder3_8$ d(cnt,regwr1,);
    and2n #(8)	ad1(regwr1,{8{i_vld}},regwr);
	
    genvar i;
    generate
        for(i=0;i<8;i=i+1) begin : k
            regn #(32) r(i_data,clk,rst,regwr[i],data[i]);
        end
    endgenerate
    
    and3$    a1(c1,cnt[0],cnt[1],cnt[2]);
    and2$    a2(o_vld,i_vld,c1);
    and2$	 a3(c2,i_vld,i_1st);
	
    assign o_addr = addr;
    assign o_data = {i_data,data[6],data[5],data[4],data[3],data[2],data[1],data[0]};
endmodule

module dcache_collect(
    input clk,
    input rst,
    input i_vld,
    input i_1st,
    input i_ca,
    input [31:0] i_data,
    input [14:0] i_addr,
    output o_vld,
    output o_ca,
    output [63:0] o_data,
    output [14:0] o_addr,
    input read);
    
    wire [1:0] rdptr,wrptr;
    wire [3:0] vld;
    wire [3:0] ca;
    wire [14:0] addr [3:0];
    wire [31:0] data0 [3:0],data1 [3:0];
    
    mux4n #(1) m1(vld[0],vld[1],vld[2],vld[3],rdptr,o_vld);
    mux4n #(1) m2(ca[0],ca[1],ca[2],ca[3],rdptr,o_ca);
    mux4n #(15) m3(addr[0],addr[1],addr[2],addr[3],rdptr,o_addr);
    mux4n #(32) m4(data0[0],data0[1],data0[2],data0[3],rdptr,o_data[31:0]);
    mux4n #(32) m5(data1[0],data1[1],data1[2],data1[3],rdptr,o_data[63:32]);
    
    wire w1,w2,w3,wv,_1stn;
	inv1$	i1(_1stn,i_1st);
    and2$    a1(w1,o_vld,read);
    and2$    a2(w2,i_vld,_1stn);
    and2$    a4(w3,i_vld,i_1st);
    or2$    a3(wv,w1,w2);
    
    wire [3:0] wren,rden;
    decoder2_4$    d1(wrptr,wren,),
                d2(rdptr,rden,);
                
    wire [3:0] wmask0,wmask1,rdmask,mask;
    and2n #(4)     a5(wren,{4{w3}},wmask0),
                a6(wren,{4{w2}},wmask1),
                a7(rden,{4{w1}},rdmask);
    or2n #(4)   a8(wmask1,rdmask,mask);
    
    wire [1:0] rdi,wri;
    mux4n #(2)     m6(2'h1,2'h2,2'h3,2'h0,rdptr,rdi),
                m7(2'h1,2'h2,2'h3,2'h0,wrptr,wri);
                
    regn #(2) rd(rdi,clk,rst,w1,rdptr);
    regn #(2) wr(wri,clk,rst,w2,wrptr);
    
    genvar i;
    generate
        for(i=0;i<4;i=i+1) begin :l
            regn #(1) rv1(wren[i],clk,rst,mask[i],vld[i]);
            regn #(1) rv2(i_ca,clk,rst,wmask0[i],ca[i]);
            regn #(15)rv3(i_addr,clk,rst,wmask0[i],addr[i]);
            regn #(32)rv4(i_data,clk,rst,wmask0[i],data0[i]);
            regn #(32)rv5(i_data,clk,rst,wmask1[i],data1[i]);
        end
    endgenerate
    
    /*always @(posedge clk){
        if(~rst){
            rdptr <= 0;
            wrptr <= 0;
        } else {
            if(vld){
                if(1st)
                    data0[wrptr] <= di;
                else
                    data1[wrptr] <= di;
                    v[wrptr] <= 1;
                    wrptr++;
            }
            if(o_vld & read){
                v[rdptr] <= 0;
                rdptr ++;
            }
        }
    }*/
endmodule
