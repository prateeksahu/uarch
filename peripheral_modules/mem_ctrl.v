module mem_fifo_d4(
    input clk,
    input rst,
    input i_vld,
    input [63:0] i_pkt,
    input done,
    output [95:0] req_pkt,
    output req_v,
    output [95:0] read_pkt,
    output read_v,
    input taken,
    output stall);
    
    //Declare & assign the previous inputs.
    wire i_1st;    
    assign i_1st = i_pkt[51];
    
    wire [3:0] v,vi,req;
    
    wire [63:0] o_pkt_t [3:0];
    wire [31:0] data1 [3:0], datai;
    
    wire [1:0] wrptr,rdptr,reqptr,wr_i1,rd_i1,rq_i1;
    wire wr,wrn,wr1,sel;
    wire i_vld_t;
	wire stall_n,_1st_n;
	inv1$	iv1(stall_n,stall),
			iv2(_1st_n,i_1st);
	
    and2$    a(i_vld_t,i_vld,stall_n);

    wire [3:0] ma0,ma1,ma2;
    wire [3:0] mask0,mask1,mask2,mask4,mask5,maskx;
    
    and4$    ax(stall,v[0],v[1],v[2],v[3]);
    and2$    a1(wr,i_1st,i_vld_t);
    and2$    a2(wrn,_1st_n,i_vld_t);
    
    decoder2_4$    d1(wrptr,ma0,),
                d2(rdptr,ma1,),
                d3(reqptr,ma2,);
    
    and2n #(4)     ad2(ma0,{4{wr}},mask0),	//i_vld == 1 && 1st
                ad5(ma0,{4{wrn}},mask5),	//i_vld == 1 && ~1st
                ad3(ma1,{4{done}},mask1),	//entry done.
                ad4(ma0,{4{i_vld_t}},mask2);//i_vld is high
    
    wire [3:0] mask_req,mask_rup;
    and2n #(4)  ad6(ma2,{4{taken}},mask_req);
    or2n #(4)    od1(mask_req,mask1,mask_rup);
    
    nor3$        nh1(sel,i_pkt[62],i_pkt[61],i_pkt[60]);
    mux2n #(4)    mh1(mask5,mask0,sel,maskx);
    mux2n #(1)  mh2(wrn,wr,sel,wr1);
    
    or2n #(4)   o1(maskx,mask1,mask4);
    
    mux2n #(32) m00(i_pkt[31:0],32'b0,i_1st,datai);
    
    wire done_n,wv;
	inv1$	iv3(done_n,done);
    and2$	av4(wv,i_vld,stall_n);
	
    genvar i;
    generate
        for(i=0;i<4;i=i+1) begin : l
            mux4n #(1) m(1'b1,done_n,wv,wv,{ma0[i],ma1[i]},vi[i]);
            regn #(1) r_vld(vi[i],clk,rst,mask4[i],v[i]);
            
            regn #(1) r_req(mask_req[i],clk,rst,mask_rup[i],req[i]);
            
            regn #(64) r_pkt(i_pkt,clk,rst,mask0[i],o_pkt_t[i]);
            regn #(32) r_data1(datai,clk,rst,mask2[i],data1[i]);
        end
    endgenerate
    
    mux4n #(96) m1({o_pkt_t[0][63:32],data1[0],o_pkt_t[0][31:0]},{o_pkt_t[1][63:32],data1[1],o_pkt_t[1][31:0]},
                {o_pkt_t[2][63:32],data1[2],o_pkt_t[2][31:0]},{o_pkt_t[3][63:32],data1[3],o_pkt_t[3][31:0]},reqptr,req_pkt);
    
    wire [3:0] vx;
	wire [3:0] reqn;
	invn #(4)	iv4(req,reqn);
	
    and2n #(4)    ax1(v,reqn,vx);
    mux4n #(1)    m2(vx[0],vx[1],vx[2],vx[3],reqptr,req_v);
    
    mux4n #(96) m3({o_pkt_t[0][63:32],data1[0],o_pkt_t[0][31:0]},{o_pkt_t[1][63:32],data1[1],o_pkt_t[1][31:0]},
                {o_pkt_t[2][63:32],data1[2],o_pkt_t[2][31:0]},{o_pkt_t[3][63:32],data1[3],o_pkt_t[3][31:0]},rdptr,read_pkt);
    mux4n #(1)    m4(v[0],v[1],v[2],v[3],rdptr,read_v);
    
    wire al_req;
    mux4n #(1) mf(req[0],req[1],req[2],req[2],reqptr,al_req);
    
    regn #(2) rw(wr_i1,clk,rst,wr1,wrptr);
    regn #(2) rd(rd_i1,clk,rst,done,rdptr);
    regn #(2) rq(rq_i1,clk,rst,taken,reqptr);
    
    mux4n #(2) m6(2'b1,2'h2,2'h3,2'h0,wrptr,wr_i1);
    mux4n #(2) m8(2'b1,2'h2,2'h3,2'h0,rdptr,rd_i1);
    mux4n #(2) m9(2'b1,2'h2,2'h3,2'h0,reqptr,rq_i1);
    
    //debug wires.
    wire [14:0] fd1,fd2,fd3,fd4;
    wire [31:0] fod1,fod2,fod3,fod4;
    assign fd1 = o_pkt_t[0][32+:15];
    assign fd2 = o_pkt_t[1][32+:15];
    assign fd3 = o_pkt_t[2][32+:15];
    assign fd4 = o_pkt_t[3][32+:15];
    assign fod1 = data1[0];
    assign fod2 = data1[1];
    assign fod3 = data1[2];
    assign fod4 = data1[3];
    
	wire [1:0] gd1,gd2,gd3,gd4;
	assign gd1 = o_pkt_t[0][58:57];
	assign gd2 = o_pkt_t[1][58:57];
	assign gd3 = o_pkt_t[2][58:57];
	assign gd4 = o_pkt_t[3][58:57];
	
    /* BEHAVIOURAL MODEL:
    always @(posedge clk) begin
        if(~rst) begin
            v <= 4'b0;
            wrptr <= 2'b0;
            rdptr <= 2'b0;
            reqptr <= 2'b0;
        end
        else begin
            if(i_vld) begin
                if(i_1st) begin
                    v[wrptr] <= 1'b1;
                    addr[wrptr] <= i_addr;
                    data0[wrptr] <= i_data;
                    data1[wrptr] <= 32'b0;
                    req[wrptr] <= i_req;
                    wrptr <= wrptr + 2'b1;
                end
                else begin
                    data1[wrptr-1] <= i_data;
                end
            end
            if(taken)    reqptr <= reqptr + 1'b1;
            if(done) begin
                v[rdptr] <= 1'b0;
                rdptr <= rdptr + 2'b1;
            end
        end
    end*/
endmodule

/////////////////////////////////////////////////////////////////////////////////
///// Bus Description:     bus[31:0] := data                                ///// 
/////                      bus[46:32] := addr                               /////
/////                      bus[49:47] := size                               /////
/////                      bus[50] := ack                                   /////
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
/////////////////////////////////////////////////////////////////////////////////

module memory #(parameter WIDTH = 64) (
    input clk,
    input rst,
    input [WIDTH-1:0] i_bus,
    
    output o_vld,
    output [WIDTH-1:0] o_bus,
    input bus_gnt,
    output mem_stall);
    
    wire i_vld,req_vld;
    wire [3:0] cnt [3:0], cnt_max [3:0];
    
    
    assign i_vld = req_vld;
    
    parameter [3:0] CY_READ = 4'h7;
    parameter [3:0] CY_WRITE = 4'hb;
    
    
    //Declare storage.
    wire [3:0] bank_wr;
    wire [3:0] cm_in;
    wire [2:0] sz_in;
    wire [63:0] data_in;
    wire rdwr_in;
    wire [14:0] addr_in;
    
    wire [14:0] addr [3:0];
    wire [2:0] size [3:0];
    wire [63:0] data_i [3:0], data [3:0];
    wire [3:0] rd_wr;
    wire [3:0] cnt_n1 [3:0], cnt_n [3:0];
    wire [3:0] clk_mem;
    wire [3:0] bank_access;
    
    wire [3:0] cnt_n0,ce,we1,we2,done_mask;
    
    //cnt = cnt++ (if (cnt_n0 & cnt != cnt_max) | (cnt == 0 && bank_access))
	wire [3:0] bank_access_d;
	
	dffn #(4) dff1(bank_access,clk,rst,bank_access_d);
    
	wire [3:0] cen,we3;
	invn #(4)	iv5(ce,cen);
	and2n #(4)	iv6(cen,cnt_n0,we3);
	or2n #(4)	iv7(we3,bank_access,we1);
	//assign we1 = (cnt_n0 & cen) | (bank_access);
    
	//or3n #(4) oy1(cnt_n0,ce,bank_wr,we1); NOT CORRECT.
    or2n #(4) oy2(we1,done_mask,we2);

	wire [3:0] eqx1,eqx2,eqx3,eqx4;
    genvar i;
    generate
        for(i=0;i<4;i=i+1) begin :comp
            or4$    o(cnt_n0[i],cnt[i][0],cnt[i][1],cnt[i][2],cnt[i][3]);
            comp_eq4    c(cnt[i],cnt_max[i],ce[i]);
            inc_4b     d(cnt_n1[i],,cnt[i]);
            mux2n #(4)  m(cnt_n1[i],4'b0,done_mask[i],cnt_n[i]);
            comp_eq4	c1(cnt[i],4'b0,eqx1[i]);
			comp_eq4	c2(cnt[i],4'h1,eqx2[i]);
			comp_eq4	c3(cnt[i],4'h2,eqx3[i]);
			comp_eq4	c4(cnt[i],4'h3,eqx4[i]);
			or4n #(1)	o1(clk_mem[i],eqx1[i],eqx2[i],eqx3[i],eqx4[i]);
            //assign clk_mem[i] = (cnt[i] == 0 || cnt[i] == 1 || cnt[i] == 2 || cnt[i] == 3 || cnt[i] == 4);
        end
    endgenerate
    generate
        for(i=0;i<4;i=i+1) begin :l
            dram_bank bank(clk_mem[i],rst,addr[i],rd_wr[i],size[i],data_i[i],data[i]);
            
            regn #(4)     rc (cnt_n[i],clk,rst,we2[i],cnt[i]);
            regn #(4)     rcm(cm_in,clk,rst,bank_access[i],cnt_max[i]);
            regn #(15)     ra (addr_in,clk,rst,bank_access[i],addr[i]);
            regn #(3)     rsz(sz_in,clk,rst,bank_wr[i],size[i]);
            regn #(64)     rdi(data_in,clk,rst,bank_wr[i],data_i[i]);
            regn #(1)     rrw(rdwr_in,clk,rst,bank_access[i],rd_wr[i]);
        end
    endgenerate

    //Generate the required signals.
    wire [2:0] icache_cnt;
    wire [95:0] req_pkt,read_pkt;
    wire [63:0] o_pkt;
    
    wire [1:0] bank_top, bank_req;
    wire [3:0] cm_banktop,cnt_bank;
    
    wire rdptr_icn,reqptr_icn;
    wire cnt_eq,ic_eq,is_rd,is_wr;
    wire rd_done1,rd_done_ic,rd_done_dc,wr_done;
    wire rdptr_up,rd_vld,data_rdy;
    wire half;
    
    //Send read data out to bus, update readptr.
    wire [3:0] inc1;
	wire rdpn,rd1;
	inv1$	iv8(rdpn,rdptr_icn);
	and2$	iv9(rd1,rd_done1,rdpn);
	
    inc_4b         icc1(inc1,,{1'b0,icache_cnt});
    regn #(3)    icc(inc1[2:0],clk,rst,rd1,icache_cnt);
    comp_eq2n     xc1(read_pkt[86:85],2'b01,rdptr_icn),
                xc2(req_pkt[86:85],2'b01,reqptr_icn);
    
    mux2n #(4)  ma1(CY_READ,CY_WRITE,read_pkt[86],cm_banktop);
    
    assign is_wr = read_pkt[86];
	inv1$	iv10(is_rd,is_wr);
    
    //readpkt.bank = read_pkt[68:67] = read_pkt.addr[4:3].
	wire gntn;
	inv1$	iv11(gntn,bus_gnt);
    assign bank_top = read_pkt[68:67];
    mux4n #(4)  ma2(cnt[0],cnt[1],cnt[2],cnt[3],read_pkt[68:67],cnt_bank);
    
    comp_eq4    c3(cm_banktop,cnt_bank,cnt_eq);
    and4$        as1(rd_done1,is_rd,cnt_eq,gntn,rd_vld);        //cond. c1, update for half.
    and3$        as2(wr_done,is_wr,cnt_eq,rd_vld);                //cond. c2
    
    and3$        as3(ic_eq,icache_cnt[0],icache_cnt[1],icache_cnt[2]);
    and2$        as4(rd_done_ic,rd_done1,ic_eq);            //condition for ICache read done.
    and2$        as5(rd_done_dc,rd_done1,half);            //Condition for DCache read done.
    
    mux2n #(1)  ms1(rd_done_ic,rd_done_dc,rdptr_icn,rd_done);
    or2$        os1(rdptr_up,rd_done,wr_done);            //Condition for writing readptr.
    and3$        as6(data_rdy,is_rd,cnt_eq,rd_vld);        //Signal for o_vld.
    
    wire [3:0] dn1,dn2;
    decoder2_4$ d4(read_pkt[68:67],dn1,);
	mux2n #(4)  m10(4'hf,dn1,rdptr_icn,dn2);
    and2n #(4)  a5(dn2,{4{rdptr_up}},done_mask);
    
    wire icc_0,hlfn;
	inv1$	iv12(hlfn,half);
	
    nor3$    oicc(icc_0,icache_cnt[0],icache_cnt[1],icache_cnt[2]);
    regn #(1)  rh(hlfn,clk,rst,rd_done1 & (icc_0 | ic_eq),half);
    
    //Construct packet.
    wire [2:0] cycles;
    wire [31:0] data_pkt_ic,data_pkt_dc,data_pkt;
    mux8n #(32) ms3(data[0][31:0],data[0][63:32],data[1][31:0],data[1][63:32],data[2][31:0],data[2][63:32],
                    data[3][31:0],data[3][63:32],icache_cnt,data_pkt_ic);
	
	wire [31:0] k1,k2,k3,k4;
	mux2n #(32) mk11(data[0][31:0],data[0][63:32],half,k1),
				mk12(data[1][31:0],data[1][63:32],half,k2),
				mk13(data[2][31:0],data[2][63:32],half,k3),
				mk14(data[3][31:0],data[3][63:32],half,k4);
	mux4n #(32) ms4(k1,k2,k3,k4,bank_top,data_pkt_dc);
    /*mux8n #(32) ms4(data[0][31:0],data[0][63:32],data[1][31:0],data[1][63:32],data[2][31:0],data[2][63:32],
                    data[3][31:0],data[3][63:32],{bank_top,half},data_pkt_dc);
    */
	
    mux2n #(32)    ms5(data_pkt_ic,data_pkt_dc,rdptr_icn,data_pkt);
    mux2n #(3) ms2(3'h7,3'h1,rdptr_icn,cycles);
    
	wire mem_stall_n;
	inv1$	im(mem_stall_n,mem_stall);
    assign o_pkt[31:0] = data_pkt;
    assign o_pkt[50:32] = read_pkt[82:64]; 
    assign o_pkt[51] = hlfn;
    assign o_pkt[54:52] = read_pkt[86:84];
    assign o_pkt[56:55] = read_pkt[90:89];
    assign o_pkt[58:57] = 2'b11;
    assign o_pkt[59] = o_vld;
    assign o_pkt[62:60] = cycles;
    assign o_pkt[63] = 1'b0;
    
    assign o_bus = o_pkt;
    assign o_vld = data_rdy;
    
    //wrptr update signal.
    wire wrp_up;
    and3$    af(wrp_up,i_bus[56],i_bus[55],i_bus[59]);        //cond. c3
    
    
    //Sending new requests to bank.
    wire [3:0] cnt_0;
    wire bank_rdy,all_rdy,rdy,send;
    generate
        for(i=0;i<4;i=i+1) begin : log
            nor4$    a(cnt_0[i],cnt[i][0],cnt[i][1],cnt[i][2],cnt[i][3]);
        end
    endgenerate
    
    mux4n #(1)  mb2(cnt_0[0],cnt_0[1],cnt_0[2],cnt_0[3],req_pkt[68:67],bank_rdy);
    and4$        aa1(all_rdy,cnt_0[0],cnt_0[1],cnt_0[2],cnt_0[3]);
    mux2n #(1)  mb1(all_rdy,bank_rdy,reqptr_icn,rdy);
    and2$        aa2(send,rdy,i_vld);                    //cond. to update reqptr. cond. c4
    
    wire [3:0] j,j1;
    decoder2_4$ dj(req_pkt[68:67],j,);
    mux2n #(4)    mk1(4'hf,j,reqptr_icn,j1);
    and2n #(4)    ak1(j1,{4{send}},bank_access);
    
    //Bank in which to update input.
    wire [3:0] w11,w21,w31;
    decoder2_4$ d1(req_pkt[68:67],w11,);
    and2n #(4)    ad1(w11,{4{send}},w21),
                ad2({4{reqptr_icn}},{4{send}},w31);
    mux2n #(4)    md1(w31,w21,reqptr_icn,bank_wr);
    
    wire [3:0] cm_1;
    mux2n #(4)  mb3(CY_READ,CY_WRITE,req_pkt[86],cm_1);
    
    assign cm_in = cm_1;
    assign sz_in = req_pkt[81:79];
    assign data_in = req_pkt[63:0];
    assign rdwr_in = req_pkt[86];
    assign addr_in = req_pkt[78:64];
    
    
    //Store entire transaction in FIFO. Keep a 2nd FIFO of width 32 to accumulate the next cycle of the transaction.
    mem_fifo_d4    mem_buf(clk,rst,wrp_up,i_bus,rdptr_up,req_pkt,req_vld,read_pkt,rd_vld,send,mem_stall);
    
    //Debug wires.
    wire [3:0] db1,db2,db3,db4;
    assign db1 = cnt[0];
    assign db2 = cnt[1];
    assign db3 = cnt[2];
    assign db4 = cnt[3];
    
    wire [3:0] da1,da2,da3,da4;
    assign da1 = cnt_max[0];
    assign da2 = cnt_max[1];
    assign da3 = cnt_max[2];
    assign da4 = cnt_max[3];
    
    wire [63:0] db_dt1,db_dt2,db_dt3,db_dt4;
    assign db_dt1 = data[0];
    assign db_dt2 = data[1];
    assign db_dt3 = data[2];
    assign db_dt4 = data[3];
    
    wire [14:0] kd1,kd2,kd3,kd4;
	assign kd1 = addr[0];
    assign kd2 = addr[1];
    assign kd3 = addr[2];
    assign kd4 = addr[3];
	
    /*always @(posedge clk) begin
        if(~rst){        
            reg_v <= 4'b0;
        }
        else {
            if(rdptr.icache){
                if(cnt_max[bank_top] == cnt[bank_top] && readpkt.rd && bus_gnt){ //cond. c1
                    icache_cnt += 1;
                    construct pkt;
                    if(icache_cnt == 7)    rdptr++;
                }
            } else {
                if(cnt_max[bank_top] == cnt[bank_top] && readpkt.rd && bus_gnt){ //cond. c1
                    half <= ~half;
                    if(half)    rdptr++;
                    construct pkt;
                }
                if(cnt_max[bank_top] == cnt[bank_top] && readpkt.wr)            //cond. c2
                    rdptr++;
            }
            
            for(i=0;i<4;i++){
                if(cnt[i] == 0 && i_vld[i])        cnt[i]++;
                else if(cnt[i] != cnt_max)        cnt[i]++;
                else if(cnt[i] == cnt_max && cnt_max == 4){
                    if(half && bus_gnt)            cnt[i] = 0;
                }
            }
            if(i_bus.dst == mem & i_bus.vld === 1'b1)                            //cond. c3
                wrptr++;
                
            if(reqptr.icache){                                                    //cond. c4
                if(all_idle && reqptr.vld == 1){
                    update_all_inputs;
                    reqptr++;
                }
            }
            else{        
                if(cnt[bank_req] == 0 && reqptr.vld == 1){
                    update inputs;
                    reqptr++;
                }
            }
        }
    end*/
endmodule
