/////////////////////////////////////////////////////////////
/////           TRANSLATION LOOKASIDE BUFFER            /////
///// PTE format: pte[0]:= r/w                          /////
/////              pte[1]:= present                     /////
/////              pte[2]:= valid                       /////
/////              pte[22:3]:= PPN                      /////
/////              pte[42:23]:= VPN                     /////
/////             pte[43]:=Cacheable                    /////
///// If we try to write to a read only page, that's a  /////
///// General protection exception. That is not detected/////
///// here, and must be written in the TLB/RR/DEC stage./////
///// TIMING: Output present 2.35ns after request.      /////
/////////////////////////////////////////////////////////////

module tlb #(parameter PTE_WIDTH = 44)(
    input [31:0] i_fetch_va,
    input i_fetch_vld,
    output [PTE_WIDTH-1:0] o_fetch_pte,
    output fetch_hit,
    
    input [31:0] i_tlb_va,
    input i_tlb_vld,
    output [PTE_WIDTH-1:0] o_tlb_pte,
    output tlb_hit,
    
    //Values exposed to TOP for initialization.
    input [PTE_WIDTH*8-1:0] tlb_reg_in);
    reg [PTE_WIDTH-1:0] tlb_reg [7:0];
    
    /* Hardcoded assignment, use for the time being.
    always tlb_reg[0] =  {20'h0,20'h0,1'b1,1'b1,1'b0};
    always tlb_reg[1] =  {20'h2000,20'h2,1'b1,1'b1,1'b1};
    always tlb_reg[2] =  {20'h4000,20'h5,1'b1,1'b1,1'b1};
    always tlb_reg[3] =  {20'hb000,20'h4,1'b1,1'b1,1'b1};
    always tlb_reg[4] =  {20'hc000,20'h7,1'b1,1'b1,1'b1};
    always tlb_reg[5] =  {20'ha000,20'h5,1'b1,1'b1,1'b1};
    always tlb_reg[6] =  {20'h8000,20'h1,1'b1,1'b1,1'b1};
    always tlb_reg[7] =  {20'h9000,20'h3,1'b1,1'b1,1'b1};*/
    
    /*Use this once initialization from TOP is set up.*/
    genvar i;
    generate
        for(i=0;i<8;i=i+1) begin :l1
            always@(tlb_reg_in) tlb_reg[i] = tlb_reg_in[i*PTE_WIDTH +: PTE_WIDTH];
        end
    endgenerate
    /*End of initialization.*/
    
    wire [7:0] fi,ti;
    generate
        for(i=0;i<8;i=i+1) begin: l2
            comp_eq24 a1({4'b0,i_fetch_va[31:12]},{4'b0,tlb_reg[i][42:23]},fi[i]);
            comp_eq24 a2({4'b0,i_tlb_va[31:12]},{4'b0,tlb_reg[i][42:23]},ti[i]);
        end
    endgenerate
    
    //Create a 8-1 simple encoder.
    wire [2:0] fetch_sel,tlb_sel;
    or4$    o1(fetch_sel[0],fi[1],fi[3],fi[5],fi[7]),
            o2(fetch_sel[1],fi[2],fi[3],fi[6],fi[7]),
            o3(fetch_sel[2],fi[4],fi[5],fi[6],fi[7]);
    or4$    o4(tlb_sel[0],ti[1],ti[3],ti[5],ti[7]),
            o5(tlb_sel[1],ti[2],ti[3],ti[6],ti[7]),
            o6(tlb_sel[2],ti[4],ti[5],ti[6],ti[7]);    
    
    //Generate hit (i.e. 1 VA match, & that one is present & valid).
    wire [7:0] w1,w2;
	wire [7:0] w11,w21;
    generate
        for(i=0;i<8;i=i+1) begin : l3
            and2$   a1(w11[i],tlb_reg[i][1],tlb_reg[i][2]),
                    a3(w21[i],tlb_reg[i][1],tlb_reg[i][2]);
        end
    endgenerate
    
	and2n #(8)	a3(w11,fi,w1),
				a4(w21,ti,w2);
				
    wire [1:0] w3,w4;
	wire fh,th;
    nor4$    o7(w3[0],w1[0],w1[1],w1[2],w1[3]),
             o8(w3[1],w1[4],w1[5],w1[6],w1[7]),
             o9(w4[0],w2[0],w2[1],w2[2],w2[3]),
             o10(w4[1],w2[4],w2[5],w2[6],w2[7]);
    nand2$   o11(fh,w3[0],w3[1]),
            o12(th,w4[0],w4[1]);
	and2$	a1(fetch_hit,fh,i_fetch_vld),
			a2(tlb_hit,th,i_tlb_vld);
    
    //Multiplex PTEs based on simple encoder output.
    mux8n #(PTE_WIDTH) m1(tlb_reg[0],tlb_reg[1],tlb_reg[2],tlb_reg[3],tlb_reg[4],tlb_reg[5],
                            tlb_reg[6],tlb_reg[7],fetch_sel,o_fetch_pte);
    mux8n #(PTE_WIDTH) m2(tlb_reg[0],tlb_reg[1],tlb_reg[2],tlb_reg[3],tlb_reg[4],tlb_reg[5],
                            tlb_reg[6],tlb_reg[7],tlb_sel,o_tlb_pte);
endmodule