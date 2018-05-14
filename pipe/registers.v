//////////////////////////////////////////////////////////////////////////////////////////////////
////                      REGISTERS MODULE CONTAINING ALL ARCH. STATE                        /////
////                                                                                         /////
////Things to note:                                                                          /////
////  1. gpr_rdmask encoding- 00: bits[7:0], 01: bits[15:8], 10:bits[15:0], 11:bits[31:0]    /////
////  2. mmx_rdmask encoding- 0: bits[31:0], 1: bits[63:32]                                  /////
////  3. gpr_rddata, mmx_rddata - Output values are sign extended to 32b.                    /////
////  4. gpr_wrmask, mmx_wrmask - Same convention followed as for read mask.                 /////
////  5. gpr_wrdata, mmx_wrdata - Required value is read off the LSBs of the input.          /////
////  6. eflags_wrmask - 1b mask for each bit of the register, 1: Write, 0: Don't write.     /////
//// --------------------------------------------------------------------------------------  /////
//// Timings:                                                                                 /////
//// For read: GPRF Read = 0.252 ns, MMX Read = 0.150ns, SegRF Read = 0.13 ns                /////
//// For write: st = "standard" setup time.                                                  /////
//// GPRF setup = st+0.85ns, SegRF setup = st, MMX setup = st+0.5ns                          /////
//////////////////////////////////////////////////////////////////////////////////////////////////
module registers(
    input clk,
    input rst,
    
    //GPRF Read wires.
    input gpr_rden0,
    input [2:0] gpr_rdaddr0,
	input [1:0] gpr_rdsize0,
    output [31:0] gpr_rddata0,
	
    input gpr_rden1,
    input [2:0] gpr_rdaddr1,
	input [1:0] gpr_rdsize1,
    output [31:0] gpr_rddata1,
    
    //SegRF Read wires.
    input segr_rden0,
    input [2:0] segr_rdaddr0,
    output [15:0] segr_rddata0,
    output [19:0] segr_limit,
    
    input segr_rden1,
    input [2:0] segr_rdaddr1,
    output [15:0] segr_rddata1,
    
    //MMX RF Read wires.
    input mmx_rden0,
    input [2:0] mmx_rdaddr0,
    input mmx_rdmask0,
    output [31:0] mmx_rddata0,
    
    input mmx_rden1,
    input [2:0] mmx_rdaddr1,
    input mmx_rdmask1,
    output [31:0] mmx_rddata1,
    
    //EIP Read wires.
    output [31:0] eip,
    
    //EFLAGS Read wires.
    output [31:0] eflags,
    
    //GPRF Write wires.
    input gpr_wren,
    input [2:0] gpr_wraddr,
    input [1:0] gpr_wrsize,
    input [31:0] gpr_wrdata,
    
    //SegRF Write wires.
    input segr_wren,
    input [2:0] segr_wraddr,
    input [15:0] segr_wrdata,
    
    //MMX RF Write wires.
    input mmx_wren,
    input [2:0] mmx_wraddr,
    input mmx_wrmask,
    input [63:0] mmx_wrdata,
    
    //EIP Write wires.
    input eip_wren,
    input [31:0] eip_wrdata,
    
    //EFLAGS Write wires.
    input eflags_wren,
    input [31:0] eflags_wrmask,
    input [31:0] eflags_wrdata,

    //CS value output.
    output [15:0] CS_out
    );

    //---------------------------------EFLAGS REGISTER-------------------------------------------//
    
    wire [31:0] eflags_mask;
    mux2n #(32) em(.in0(32'b0),.in1(eflags_wrmask),.sel(eflags_wren),.o(eflags_mask));
    regn_bit_enable #(32) EFLAGS_REG(.clk(clk),.rst(rst),.in(eflags_wrdata),.mask(eflags_mask),.o(eflags));
    
    //---------------------------------EIP REGISTER---------------------------------------------//
    
    reg32e$    EIP_REG(.CLK(clk),.Din(eip_wrdata),.Q(eip),.QBAR(),.CLR(rst),.PRE(1'b1),.en(eip_wren));
    
    //---------------------------------MMX REGISTER FILE---------------------------------------//
    
    wire [63:0] mmx_data0, mmx_data1;
    //Select required half of read data.
    mux2n #(32) mm1(.in0(mmx_data0[31:0]),.in1(mmx_data0[63:32]),.sel(mmx_rdmask0),.o(mmx_rddata0));
    mux2n #(32) mm2(.in0(mmx_data1[31:0]),.in1(mmx_data1[63:32]),.sel(mmx_rdmask1),.o(mmx_rddata1));
    
    //Set write mask to write required half, and not write anything if en = 0.
    wire [7:0] mmx_wrmask_t;
    mux4n #(8) mm3(.in0(8'b0),.in1(8'b0),.in2(8'b0000_1111),.in3(8'b1111_0000),.sel({mmx_wren,mmx_wrmask}),.o(mmx_wrmask_t));
    
    //DUplicate write data to form the data bus.
    wire [63:0] mmx_wrdata_t;
    assign mmx_wrdata_t[31:0] = mmx_wrdata;
    assign mmx_wrdata_t[63:32] = mmx_wrdata;
    
    wire [63:0] mmx_data0_t,mmx_data1_t;
    genvar i;
    generate
        for(i=0; i<8; i=i+1) begin: MMX
            regfile8x8$    REG(.IN0(mmx_wrdata[i*8+:8]),
                            .R1(mmx_rdaddr0),
                            .R2(mmx_rdaddr1),
                            .RE1(mmx_rden0),
                            .RE2(mmx_rden1),
                            .W(mmx_wraddr),
                            .WE(mmx_wren),
                            .OUT1(mmx_data0_t[i*8+:8]),
                            .OUT2(mmx_data1_t[i*8+:8]),
                            .CLOCK(clk));
        end
    endgenerate

    wire [7:0] mmx_wr,mmx_m1,mmx_m2;
    decoder3_8$	dm1(mmx_wraddr,mmx_m1,);
    and2n #(8) dm2(mmx_m1,{8{mmx_wren}},mmx_m2);
    generate 
    	for(i=0; i<8; i=i+1) begin: wr1
		regn #(1) wr(1'b1,clk,rst,mmx_m2[i],mmx_wr[i]);
	end
    endgenerate
    mux2n #(64) mj1(64'b0,mmx_data0_t,mmx_wr[mmx_rdaddr0],mmx_data0);
    mux2n #(64) mj2(64'b0,mmx_data1_t,mmx_wr[mmx_rdaddr1],mmx_data1);

    //-----------------------------------SEGMENT REGISTER FILE -------------------------------------------//
    wire [15:0] segr_rddata0_t,segr_rddata1_t;
    wire [23:0] segr_limit_t;
    assign segr_limit = segr_limit_t[19:0];
    assign segr_rddata0 = segr_rddata0_t;
    assign segr_rddata1 = segr_rddata1_t;
    
    assign CS_out = {SEGR[1].REG.REG1,SEGR[0].REG.REG1};
    generate
        for(i=0; i<2; i=i+1) begin: SEGR
            regfile8x8$    REG(.IN0(segr_wrdata[i*8+:8]),
                            .R1(segr_rdaddr0),
                            .R2(segr_rdaddr1),
                            .RE1(segr_rden0),
                            .RE2(segr_rden1),
                            .W(segr_wraddr),
                            .WE(segr_wren),
                            .OUT1(segr_rddata0_t[i*8+:8]),
                            .OUT2(segr_rddata1_t[i*8+:8]),
                            .CLOCK(clk));
        end
    endgenerate

        generate
        for(i=0; i<3; i=i+1) begin: LIMIT
            regfile8x8$    REG(.IN0(),
                            .R1(segr_rdaddr0),
                            .R2(segr_rdaddr1),
                            .RE1(segr_rden0),
                            .RE2(segr_rden1),
                            .W(),
                            .WE(1'b0),
                            .OUT1(segr_limit_t[i*8+:8]),
                            .OUT2(),
                            .CLOCK(clk));
        end
    endgenerate
    
    //------------------------------------GENERAL PURPOSE REGISTER FILE-----------------------------------//
    
    wire wg1,wg2,wg3,wg4,wgsel0;
    wire wg11,wg21,wg31,wg41,wgsel1;
    wire [31:0] gpr_data0,gpr_data1,fill0,fill1;
	
	//Generate read masks.
	wire [3:0] gpr_rdmask0,gpr_rdmask1,rm0,rm1;
	mux2n #(4)  mk1(4'b0011,4'b1111,gpr_rdsize0[0],rm0);
	mux4n #(4)	mk2(4'b0001,4'b0010,rm0,rm0,{gpr_rdsize0[1],gpr_rdaddr0[2]},gpr_rdmask0);
	mux2n #(4)  mk3(4'b0011,4'b1111,gpr_rdsize1[0],rm1);
	mux4n #(4)	mk4(4'b0001,4'b0010,rm1,rm1,{gpr_rdsize1[1],gpr_rdaddr1[2]},gpr_rdmask1);
	
	//Generate addresses.
	wire [2:0] rdaddr0,rdaddr1;
	mux2n #(3) mk5({1'b0,gpr_rdaddr0[1:0]},gpr_rdaddr0,gpr_rdsize0[1],rdaddr0);
	mux2n #(3) mk6({1'b0,gpr_rdaddr1[1:0]},gpr_rdaddr1,gpr_rdsize1[1],rdaddr1);
    
	//Clean up and sign extend read data as required.
	wire [31:0] w1,w2,data0,data1;
	mux2n #(32) ma({{24{gpr_data0[7]}},gpr_data0[7:0]},{{24{gpr_data0[15]}},gpr_data0[15:8]},gpr_rdaddr0[2],w1);
	mux4n #(32) mb(gpr_data0,w1,{{16{gpr_data0[15]}},gpr_data0[15:0]},gpr_data0,gpr_rdsize0,data0);
	mux2n #(32) mc({{24{gpr_data1[7]}},gpr_data1[7:0]},{{24{gpr_data1[15]}},gpr_data1[15:8]},gpr_rdaddr1[2],w2);
	mux4n #(32) md(gpr_data1,w2,{{16{gpr_data1[15]}},gpr_data1[15:0]},gpr_data1,gpr_rdsize1,data1);
	
	assign gpr_rddata0 = data0;
	assign gpr_rddata1 = data1;
	
    wire [3:0] gpr_wrmask_t,mask_w1,mask_w2;
    wire wg12,is10;
    wire [31:0] gpr_wrdata_t;
	
    //Shift write data left by 1B to cover the case of wrmask=xx10. Generate the 4b mask.
	wire [3:0] gpr_wrmask,wm1;
	mux2n #(4)  mj1x(4'b0011,4'b1111,gpr_wrsize[0],wm1);
	mux4n #(4)	mj2x(4'b0001,4'b0010,wm1,wm1,{gpr_wrsize[1],gpr_wraddr[2]},gpr_wrmask);
    inv1$    ig1(wg12,gpr_wrmask[0]);
    and2$    ag5(is10,wg12,gpr_wrmask[1]);
    mux2n #(32) mg5(.in0(gpr_wrdata),.in1({gpr_wrdata[23:0],8'b0}),.sel(is10),.o(gpr_wrdata_t));
    
    //AND mask with valid.
	and2n #(4) ag6(gpr_wrmask,{4{gpr_wren}},gpr_wrmask_t);
    
	wire [2:0] wraddr;
	wire [31:0] gpr_data0_t,gpr_data1_t;
	mux2n #(3) mg6({1'b0,gpr_wraddr[1:0]},gpr_wraddr,gpr_wrsize[1],wraddr);
    generate
        for(i=0; i<4; i=i+1) begin: GPR
            regfile8x8$    REG(.IN0(gpr_wrdata_t[i*8+:8]),
                            .R1(rdaddr0),
                            .R2(rdaddr1),
                            .RE1(gpr_rden0),
                            .RE2(gpr_rden1),
                            .W(wraddr),
                            .WE(gpr_wrmask_t[i]),
                            .OUT1(gpr_data0_t[i*8+:8]),
                            .OUT2(gpr_data1_t[i*8+:8]),
                            .CLOCK(clk));
        end
    endgenerate
    wire [7:0] gpr_wr,gpr_m1,gpr_m2;
    decoder3_8$	dm3(gpr_wraddr,gpr_m1,);
    and2n #(8) dm4(gpr_m1,{8{gpr_wren}},gpr_m2);
    generate 
    	for(i=0; i<8; i=i+1) begin: wr2
		regn #(1) wr(1'b1,clk,rst,gpr_m2[i],gpr_wr[i]);
	end
    endgenerate
	
	wire v0,v1;
	mux8n #(1) mj3x(gpr_wr[0],gpr_wr[1],gpr_wr[2],gpr_wr[3],gpr_wr[4],gpr_wr[5],gpr_wr[6],gpr_wr[7],rdaddr0,v0);
	mux8n #(1) mj4x(gpr_wr[0],gpr_wr[1],gpr_wr[2],gpr_wr[3],gpr_wr[4],gpr_wr[5],gpr_wr[6],gpr_wr[7],rdaddr1,v1);
	
    mux2n #(32) mj5x(32'b0,gpr_data0_t,v0,gpr_data0);
    mux2n #(32) mj6x(32'b0,gpr_data1_t,v1,gpr_data1);
endmodule    
