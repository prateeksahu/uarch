////////////////////////////////////////////////////////////////////////////////
/////                     BUS & BUS CONTROLLER.                             /////
///// Bus Description:     bus[31:0] := data                                ///// 
/////                      bus[46:32] := addr                               /////
/////                      bus[49:47] := size                               /////
/////                      bus[50] := start                                 /////
/////                      bus[51] := _1st                                  /////
/////                      bus[52] := cacheable                             /////
/////                      bus[54:53] := rdwr                               /////
/////                      bus[56:55] := dst                                /////
/////                      bus[58:57] := src                                /////
/////                      bus[59] := vld                                   /////
/////                      bus[62:60] := reqCycles                          /////
/////                      bus[63] := interrupt                             /////
///// Src/dst encoding: 00- I/O1 (simple), 01-I/O2 (complex), 10- processor /////
/////                   11-memory.                                          /////
///// Grant logic: If 1 valid, give grant to that for reqCycles #cycles. If /////
///// multiple valids,use static priority & give grant. Higher encoding has /////
///// higher priority.                                                      /////
/////////////////////////////////////////////////////////////////////////////////

module bus_ctrl(
    input clk,
    input rst,
    
    //Inputs from units.
    input [63:0] i_io1,
    input [63:0] i_io2,
    input [63:0] i_proc,
    input [63:0] i_mem,
    input io1_vld,
    input io2_vld,
    input proc_vld,
    input mem_vld,
    input mem_stall,
    
    //Gnts to units.
    output io1_gnt,
    output io2_gnt,
    output proc_gnt,
    output mem_gnt,
    
    //Outputs to units.
    output [63:0] bus);
    
    wire [2:0] cnt;
    wire [3:0] gnt_p,gnt_mask;
    wire [63:0] bus_t;
    
    genvar i;
    generate
        for(i=0;i<4;i=i+1) begin : l
            tristate_bus_driver16$    t1(io1_gnt,i_io1[i*16+:16],bus_t[i*16+:16]);
            tristate_bus_driver16$    t2(io2_gnt,i_io2[i*16+:16],bus_t[i*16+:16]);
            tristate_bus_driver16$    t3(proc_gnt,i_proc[i*16+:16],bus_t[i*16+:16]);
            tristate_bus_driver16$    t4(mem_gnt,i_mem[i*16+:16],bus_t[i*16+:16]);
        end
    endgenerate
    
    wire any_gnt;
    or4$    or1(any_gnt,io1_vld,io2_vld,proc_vld,mem_vld);
    mux2n #(1) mo1(1'b0,bus_t[59],any_gnt,bus[59]);
    
    assign bus[58:0] = bus_t[58:0];
    assign bus[63:60] = bus_t[63:60];
    
    
    assign io1_gnt = gnt_mask[0];
    assign io2_gnt = gnt_mask[1];
    assign proc_gnt = gnt_mask[2];
    assign mem_gnt = gnt_mask[3];
    
    wire c1;
    nor3$    o1(c1,cnt[0],cnt[1],cnt[2]);    //c1 = (cnt == 0)
    
    wire [3:0] w1,w2,w3,w4;
    mux2n #(4)  m1(4'hf,4'he,io1_vld,w1),
                m2(w1,4'hd,io2_vld,w2),
                m3(w2,4'hb,proc_vld,w3),
                m4(w3,4'h7,mem_vld,w4);

    wire [1:0] w5,w6,w7,gnt_enc,gnt_encp;
    mux2n #(2)  m5(2'h0,2'h1,io2_vld,w5),
                m6(w5,2'h2,proc_vld,w6),
                m7(w6,2'h3,mem_vld,w7);
                
    //Arbitrate to give grant.
    mux4n #(4) m8(gnt_p,w4,4'h7,4'h7,{mem_stall,c1},gnt_mask);
    mux4n #(2) m9(gnt_encp,w7,2'h3,2'h3,{mem_stall,c1},gnt_enc);
    
    regn #(4) r1(gnt_mask,clk,rst,1'b1,gnt_p);
    regn #(2) r2(gnt_enc,clk,rst,1'b1,gnt_encp);
    
    //Set count according to grant.
    wire [3:0] w11,w21,cnti;
    wire [2:0] reqCycles;
    wire _1st,valid,wr1;
    mux4n #(1) m10(i_io1[51],i_io2[51],i_proc[51],i_mem[51],gnt_enc,_1st);
    mux4n #(1) m11(io1_vld,io2_vld,proc_vld,mem_vld,gnt_enc,valid);
    mux4n #(3) m12(i_io1[62:60],i_io2[62:60],i_proc[62:60],i_mem[62:60],gnt_enc,reqCycles);
    and2$    a1(wr1,_1st,valid);
    
    dec_4b d1(w11,,{1'b0,cnt});
    mux2n #(4) m13(w11,4'b0,w11[3],w21);
    mux2n #(4) m14(w21, {1'b0,reqCycles},wr1,cnti);
    
    regn #(3) rc(cnti[2:0],clk,rst,valid,cnt);
    
    /*always @(posedge clk){
        if(~rst)    cnt <= 0;
        else begin
            if(vld & _1st)
                cnt <= reqCycles;
            else
                cnt <= max(cnt-1,0);
        end
    end*/
    
endmodule
