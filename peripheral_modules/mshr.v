module dcache_mshr(
    input clk,
    input rst,
    input mem_vld,
    input [14:0] mem_addr,
    input [31:0] mem_data,
    input cache_vld,
    input [14:0] cache_addr,
    input [31:0] cache_data,
    input req_vld,
    output req_rd,
    input [14:0] req_addr,
	input tlb_cacheable,
	
    output ret_vld,
    output [14:0] ret_addr,
    output [31:0] ret_data,
    
    output ca_req_v,
    input ca_req_rd,
    output [14:0] ca_req_addr,
	output req_cacheable,
    output mshr_full,
	input lsq_full);
							
    wire [7:0] vld;
    wire [3:0] alloc;
    
    wire mshr_n;
    and4$    an1(mshr_full,alloc[0],alloc[1],alloc[2],alloc[3]);
    nand4$    nan1(mshr_n,alloc[0],alloc[1],alloc[2],alloc[3]);
    
    //Delay ret_vld for pointer updates. DON'T CHANGE!!!!
    wire ret_vld_d,ca_req_d;
    wire f1;
    dffn #(1) df1(ret_vld,clk,rst,ret_vld_d);
    dffn #(1) df2(f1,clk,rst,ca_req_d);
    
    //Declare the pointers.
    wire [2:0] wrptr,rdptr,cacheptr,memptr;
    wire [3:0] wri,rdi,cpi,mmi;
	
    and2$    af1(f1,ca_req_rd,ca_req_v);
    regn #(3)  r1(wri[2:0],clk,rst,req_rd,wrptr),
               r2(rdi[2:0],clk,rst,ret_vld,rdptr),
               r3(cpi[2:0],clk,rst,f1,cacheptr),
               r4(mmi[2:0],clk,rst,vm,memptr);
    
    //Declare the storage.
    wire [14:0] addr [3:0], adi [3:0];
    wire [1:0] spl [3:0],spi;
    wire [31:0] data [3:0], di [3:0], di1 [3:0];
    wire [3:0] adw,dw,sw;
	wire [3:0] cac_out;
	
    genvar i;
    generate
        for(i=0;i<4;i=i+1) begin : in
            regn #(15) add(req_addr,clk,rst,adw[i],addr[i]);
            regn #(32) dat(di[i],clk,rst,dw[i],data[i]);
            regn #(2)  split(spi,clk,rst,sw[i],spl[i]);
			regn #(1)  cac(tlb_cacheable,clk,rst,adw[i],cac_out[i]);
        end
    endgenerate
    
    //Declare the control bits.
    wire [7:0] vldi,vwren;
    wire [3:0] alloc_mask;
    wire [3:0] rqi,rqo;
    wire [3:0] midx1,widx1,cidx1,midx,cidx,widx;
    regn_bit_enable #(8) valid(clk,rst,vldi,vwren,vld);
    regn_bit_enable #(4) all(clk,rst,widx,alloc_mask,alloc);
    
    //rq[cacheptr[2:1]] = 1 if(f1 & (!cpi[0])), rq[rdptr[2:1]] = 0 if(ret_vld).
    wire ox,ox1,oi1;
    wire [3:0] mqa,mqb,mqc,cadx;

	inv1$	xo2(oi1,cpi[0]);
	and2$	xo3(ox1,f1,oi1);
    or2$    xo1(ox,ox1,ret_vld);
    mux4n #(4) mq4(4'h1,4'h2,4'h4,4'h8,rdptr[2:1],cadx);
    mux4n #(4) mq1({rqo[3:1],1'b1},{rqo[3:2],1'b1,rqo[0]},{rqo[3],1'b1,rqo[1:0]},{1'b1,rqo[2:0]},cacheptr[2:1],mqa);
    mux4n #(4) mq2({rqo[3:1],1'b0},{rqo[3:2],1'b0,rqo[0]},{rqo[3],1'b0,rqo[1:0]},{1'b0,rqo[2:0]},rdptr[2:1],mqb);
    
    generate
        for(i=0;i<4;i=i+1) begin: i3
            mux2n #(1) m(mqa[i],mqb[i],cadx[i],mqc[i]);
        end
    endgenerate
    mux4n #(4) mq3(rqo,mqb,mqa,mqc,{f1,ret_vld},rqi);
    regn #(4) rq1(rqi,clk,rst,ox,rqo);
    
    //DATA RETURN: Select the correct alloc & vld bits for returning data.
    //ret_vld = [{(v0[rdptr]|v1[rdptr]) & (cache_vld|mem_vld)}|(v0 & v1)}] & alloc.
    wire [1:0] vdx;
    wire alx,vdx1,vdx2,vdx3,vdx4,vx1;
    wire wj;
    
    comp_eq2n ce(rdptr[2:1],cacheptr[2:1],wj);
    mux2n #(1) ce1(cache_vld,mem_vld,wj,vdx2);
    mux4n #(2) m1({vld[1],vld[0]},{vld[3],vld[2]},{vld[5],vld[4]},
                    {vld[7],vld[6]},rdptr[2:1],vdx);
    or2$    o1(vdx1,vdx[0],vdx[1]);
    nand2$    o3(vdx3,vdx1,vdx2);
    nand2$    o4(vdx4,vdx[0],vdx[1]);
    nand2$    o5(vx1,vdx4,vdx3);
    and2$    o6(ret_vld,vx1,alx);
    
    mux4n #(1) m2(alloc[0],alloc[1],alloc[2],alloc[3],rdptr[2:1],alx);
    
    mux4n #(15) m3(addr[0],addr[1],addr[2],addr[3],rdptr[2:1],ret_addr);
    mux4n #(32) m4(di[0],di[1],di[2],di[3],rdptr[2:1],ret_data);
    
    //DATA REQUEST: Select the bits for sending cache request.
    //Cache request is sent if (alloc & !vld & !requested).
    wire vdy,aly;
    wire [14:0] ad1;
    wire [15:0] ad2;
    wire rqox,rqon;
	wire vdyn;
	inv1$	iv1(vdyn,vdy);
	
    mux4n #(1) mx3(rqo[0],rqo[1],rqo[2],rqo[3],cacheptr[2:1],rqox);
    inv1$    ix1(rqon,rqox);
    mux8n #(1) m5(vld[0],vld[1],vld[2],vld[3],vld[4],vld[5],vld[6],
                  vld[7],cacheptr,vdy);
    mux4n #(1) m6(alloc[0],alloc[1],alloc[2],alloc[3],cacheptr[2:1],aly);
    mux4n #(15) m7(addr[0],addr[1],addr[2],addr[3],cacheptr[2:1],ad1);
    inc_16b inc1(ad2,,{4'b0,ad1[14:3]});
    
    mux2n #(15) m8(ad1,{ad2[11:0],3'b0},cacheptr[0],ca_req_addr);
	
	mux4n #(1)  mc1(cac_out[0],cac_out[1],cac_out[2],cac_out[3],cacheptr[2:1],req_cacheable);
    and3$   a2(ca_req_v,vdyn,aly,rqon);
    
    //POINTER UPDATES.
    //If(~cacheptr[0] & v1[cacheptr[2:1]])    cacheptr += 2;
    //else    cacheptr += 1;
    //cacheptr is updated whenever a cache access occurs.
    wire [3:0] cx1,cx2;
    wire sel;
    inc2_4b incc1(cx1,,{1'b0,cacheptr});
    inc_4b incc2(cx2,,{1'b0,cacheptr});
    
    wire i1,i2;
    mux4n #(1) mu1(vld[1],vld[3],vld[5],vld[7],cacheptr[2:1],i2);
    inv1$      in1(i1,cacheptr[0]);
    nand2$     nn1(sel,i2,i1);
    mux2n #(4) mu2(cx1,cx2,sel,cpi);
    
	wire [14:0] addr0,addr1,addr2,addr3;
	assign addr0 = addr[0];
	assign addr1 = addr[1];
	assign addr2 = addr[2];
	assign addr3 = addr[3];
	
    //If (req_vld & !full)    req_read;
    //wrptr += 2
    //wrptr is updated whenever req_read. Data is also zeroed out.
	wire lsq_fulln;
	inv1$	iv2(lsq_fulln,lsq_full);
    and3$    a3(req_rd,req_vld,mshr_n,lsq_fulln);
    inc2_4b inc2(wri,,{1'b0,wrptr});
    
    //If (ret_vld)    rdptr += 2;
    inc2_4b incc3(rdi,,{1'b0,rdptr});
    
    //Memptr update.
    //Shift the vld & alloc arrays according to memptr.
    //If(vld[memptr] | mem_vld) -> move to next non-valid location. (i.e. if mem_vld, move to next available location)
    //If(memptr[2:1] == cacheptr[2:1] && cache_vld) -> move memptr to next row. (i.e. if cache_vld && mem_ptr == cache_ptr, move mem_ptr to the cache_ptr updated locn.)
    //Should be replaced by if(memptr == cacheptr && cache_vld) mmi = cpi.
    wire vm1,wd1,eqn;
    wire [3:0] inc_m,mmi1;
    inc_4b im(inc_m,,{2'b0,memptr[2:1]});
    
    //comp_eq2n cm(memptr[2:1],cacheptr[2:1],eqn);
    comp_eq3    cm(memptr,cacheptr,eqn);
    //inv1$      ims(wd1,cache_vld);
    //nor2$      nm(vm1,wd1,eqn);
    and2$   nm(vm1,eqn,cache_vld);

    or2$    amm1(vm,vm1,mem_vld);
    
    //mux2n #(4) amm2({1'b0,inc_m[1:0],1'b0},mmi1,mem_vld,mmi);
    mux2n #(4) amm2(cpi,mmi1,mem_vld,mmi);
    
    wire [7:0] w1,w1f;
    mux8n #(8) ml1({vld[0],vld[7:1]},{vld[1:0],vld[7:2]},{vld[2:0],vld[7:3]},
                {vld[3:0],vld[7:4]},{vld[4:0],vld[7:5]},{vld[5:0],vld[7:6]},
                {vld[6:0],vld[7]},vld,memptr,w1);
    
    assign w1f = {w1[0],w1[1],w1[2],w1[3],w1[4],w1[5],w1[6],w1[7]};
    wire [2:0] w1_idx;
    
    pencoder8_3$    al1(1'b0,w1f,w1_idx);
    wire [3:0] wmptr;
    inc_4b ig(wmptr,,{1'b0,memptr});
    add_4b ig1(mmi1,,wmptr,{1'b0,w1_idx},1'b0);

    //STORAGE UPDATES.
    //If(req_rd)    update split.
    assign sw = widx;
    mux2n #(2) max2(req_addr[1:0],2'b0,split_n1,spi);
    
    //If(req_rd)   alloc[wrptr] = 1.
    //If(ret_vld)    alloc[rdptr] = 0.
    wire [3:0] rm;
    mux4n #(4) mm2(4'h1,4'h2,4'h4,4'h8,rdptr[2:1],rm);
    
    wire [3:0] mask0;
    or2n #(4) om1(widx1,rm,mask0);
    mux4n #(4) mm5(4'b0,rm,widx1,mask0,{req_rd,ret_vld},alloc_mask);
    
    
    //If(req_vld & split)     v[wrptr+1] = 1
    //If(hit)                v[cacheptr] = 1
    //If(mem_vld)            v[memptr] = 1
    //If(ret_vld)            v[rdptr+:2] = 0
    wire split_n,k1,k7,k8;
    wire [3:0] k9,k10;
    wire [7:0] k2,k3,k31,k4,k41,vldix;
    or2$    ml2(k1,req_addr[0],req_addr[1]);
    nand2$    am1(split_n1,k1,req_addr[2]);
    and2$      am2(split_n,split_n1,req_rd);
    inv1$    ik1(k7,cacheptr[0]);
    inv1$    ik2(k8,memptr[0]);
    
    decoder2_4$    dd(rdptr[2:1],k9,);
    and2n #(4) am3(k9,{4{ret_vld}},k10);
    
    mux4n #(8) mdd5({6'b0,split_n,1'b0},{4'b0,split_n,3'b0},{2'b0,split_n,5'b0},{split_n,7'b0},wrptr[2:1],k2);
    assign k31 = {{2{midx[3]}},{2{midx[2]}},{2{midx[1]}},{2{midx[0]}}};
    assign k41 = {{2{cidx[3]}},{2{cidx[2]}},{2{cidx[1]}},{2{cidx[0]}}};
    and2n #(8)    add1(k31,{4{memptr[0],k8}},k3),
                  add2(k41,{4{cacheptr[0],k7}},k4);
    
    or4n #(8)     odd1(k2,k3,k4,{{2{k10[3]}},{2{k10[2]}},{2{k10[1]}},{2{k10[0]}}},vwren);        
    mux4n #(8)    mdd15(8'b1111_1100,8'b1111_0011,8'b1100_1111,8'b0011_1111,rdptr[2:1],vldix);
    mux2n #(8)       mdd16(8'hff,vldix,ret_vld,vldi);
    
    //If(req_rd)            addr[wrptr] = addr
    wire [3:0] adw1;
    mux4n #(4) mad1(4'b1,4'h2,4'h4,4'h8,wrptr[2:1],adw1);
    mux2n #(4) mad2(4'b0,adw1,req_rd,adw);
    
    
    //If(mem_vld)            update data[memptr]
    //If(cache_vld)          update data[cacheptr].
    //If(req_vld)            update data[wrptr].
    wire [31:0] d_m,d_c;
    wire [1:0] sp_m,sp_c;
    mux4n #(32) mdd1(data[0],data[1],data[2],data[3],memptr[2:1],d_m);
    mux4n #(32) mdd2(data[0],data[1],data[2],data[3],cacheptr[2:1],d_c);
    mux4n #(2) mdd3(spl[0],spl[1],spl[2],spl[3],memptr[2:1],sp_m);
    mux4n #(2) mdd4(spl[0],spl[1],spl[2],spl[3],cacheptr[2:1],sp_c);
    
    wire [31:0] d_m1,d_m2,d_c1,d_c2;
    //Split: #bytes to be taken from the 2nd request. (0/1/2/3), hence typically 0.
    mux4n #(32) mm7(mem_data,{d_m[31:24],mem_data[23:0]},{d_m[31:16],mem_data[15:0]},{d_m[31:8],mem_data[7:0]},sp_m,d_m1);
    mux4n #(32) mm8(d_m,{mem_data[7:0],d_m[23:0]},{mem_data[15:0],d_m[15:0]},{mem_data[23:0],d_m[7:0]},sp_m,d_m2);
    mux4n #(32) mm9(cache_data,{d_c[31:24],cache_data[23:0]},{d_c[31:16],cache_data[15:0]},{d_c[31:8],cache_data[7:0]},sp_c,d_c1);
    mux4n #(32) mm10(d_c,{cache_data[7:0],d_c[23:0]},{cache_data[15:0],d_c[15:0]},{cache_data[23:0],d_c[7:0]},sp_c,d_c2);
    
    wire [31:0] d_mn1,d_cn1;
    mux2n #(32) mm11(d_m1,d_m2,memptr[0],d_mn1);
    mux2n #(32) mm12(d_c1,d_c2,cacheptr[0],d_cn1);
    
    decoder2_4$    dc1(memptr[2:1],midx1,),
                dc2(wrptr[2:1],widx1,),
                dc3(cacheptr[2:1],cidx1,);
                
    and2n #(4)  ac1(midx1,{4{mem_vld}},midx),
                ac2(widx1,{4{req_rd}},widx),
                ac3(cidx1,{4{cache_vld}},cidx);
                
    generate
        for(i=0;i<4;i=i+1) begin : ix
            mux2n #(32) mx1(data[i],d_cn1,cidx[i],di1[i]);
            mux2n #(32) mx2(di1[i],d_mn1,midx[i],di[i]);
        end
    endgenerate
    or3n #(4) oxn(midx,widx,cidx,dw);    
endmodule