module icache_store (
    input clk,
    input rst,
    input [14:0] addr,
    input rdvld,
    input [255:0] wrdata,
    input wrvld,
    output hit,
    output [255:0] rddata);

    wire [7:0] tagout;
    wire wrvld_n,h1,vldb;
    wire [7:0] vldo;
    
    wire [14:0] v1;
	//wire v2,v3,v4;
    
	inv1$	ij1(v1[0],wrvld),
			ij2(v1[1],v1[0]),
			ij3(v1[2],v1[1]),
			ij4(v1[3],v1[2]),
			ij5(v1[4],v1[3]),
			ij6(v1[5],v1[4]),
			ij7(v1[6],v1[5]),
			ij8(v1[7],v1[6]),
			ij9(v1[8],v1[7]),
			ij10(v1[9],v1[8]),
			ij11(v1[10],v1[9]),
			ij12(v1[11],v1[10]),
			ij13(v1[12],v1[11]),
			ij14(v1[13],v1[12]),
			ij15(v1[14],v1[13]);
			
	mux4n #(1) m4(1'b1,1'b1,1'b1,v1[14],{rst,wrvld},wrvld_n);
	
	/*xor2$    xx(v1,wrvld,1'b1),
            xx1(v2,v1,1'b1),
            xx2(v3,v2,1'b1);
    and2$    xx3(v4,v3,1'b1);
    mux3$    xx4(wrvld_n,v4,1'b1,1'b1,1'b0,1'b0);
    */
	
    //inv1$    ix(wrvld_n,wrvld);
    //inv1$    ix1(wrvld_2,wrvld_1);
    //inv1$    xi2(wrvld_n,wrvld_2);
    
    //Create a write mask to update vld.
    wire [7:0] mask_i,mask;
    mux8n #(8) m1(8'h1,8'h2,8'h4,8'h8,8'h10,8'h20,8'h40,8'h80,addr[7:5],mask_i);
    mux2n #(8) m2(8'h0,mask_i,wrvld,mask);
    mux8n #(1) m3(vldo[0],vldo[1],vldo[2],vldo[3],vldo[4],vldo[5],vldo[6],vldo[7],addr[7:5],vldb);

    //Declare storage elements.
    ram8b8w$ tag(addr[7:5],{1'b0,addr[14:8]},1'b0,wrvld_n,tagout);
    regn_bit_enable #(8) vld(.clk(clk),.rst(rst),.in(8'hff),.mask(mask),.o(vldo));
    
    genvar i;
    generate
        for(i=0;i<32;i=i+1) begin: data
            ram8b8w$ data(addr[7:5],wrdata[i*8+:8],1'b0,wrvld_n,rddata[i*8+:8]);
        end
    endgenerate
    
    //Generate hit.
    wire w1;
    inv1$     i1(w1,wrvld);
    comp_eq7 c(.in1(tagout[6:0]),.in2(addr[14:8]),.equal(h1));
    and4$    a(hit,h1,rdvld,w1,vldb);
    
endmodule