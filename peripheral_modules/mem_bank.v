module dram_bank(
    input clk_mem,
    input rst,
    input [14:0] addr,
    input rd_wr,    //1:wr, 0:rd.
    input [2:0] data_size, //data_size = wr_size - 1.
    input [63:0] data_i,
    output [63:0] data_o);
    
    wire [7:0] wm,wmf1,wmf,pages;
    wire [7:0] write_mask [7:0],write_mask_t [7:0];
    wire [63:0] io [7:0];
    wire [63:0] di_shf;
    
    wire [14:0] addr_t;
    //Delay the address to take care of behaviour at init.
    or2n #(15)  oh(15'h0,addr,addr_t);
    
    mux8n #(8)     m4(8'h1,8'h3,8'h7,8'hf,8'h1f,8'h3f,8'h7f,8'hff,data_size,wm);
    decoder3_8$    d2(addr[14:12],pages,);
    
    mux8n #(8)    m1(wm,{wm[6:0],1'b0},{wm[5:0],2'b0},{wm[4:0],3'b0},{wm[3:0],4'b0},{wm[2:0],5'b0},{wm[1:0],6'b0},{wm[0],7'b0},addr[2:0],wmf1);
    and2n #(8)    a1(wmf1,{8{rd_wr}},wmf);
    
    //Read off the data from the correct page.
    mux8n #(64) m2(io[0],io[1],io[2],io[3],io[4],io[5],io[6],io[7],addr[14:12],data_o);
    
    //Shift the input data according to the address.
    mux8n #(64) m3(data_i,{data_i[55:0],8'b0},{data_i[47:0],16'b0},{data_i[39:0],24'b0},{data_i[31:0],32'b0},
                    {data_i[23:0],40'b0},{data_i[15:0],48'b0},{data_i[7:0],56'b0},addr[2:0],di_shf);
    
    //Drive the wire io using a tristate driver.
    genvar i,j;
    generate 
        for(i=0;i<8;i=i+1) begin : pagein
            for(j=0;j<8;j=j+1) begin : chipin
                tristate8H$    trin(write_mask_t[i][j],di_shf[j*8+:8],io[i][j*8+:8]);
            end
        end
    endgenerate
    
    generate
        for(i=0;i<8;i=i+1) begin : m
            nand2n #(8) n({8{pages[i]}},wmf,write_mask_t[i]);
            mux4n #(8)  n1(8'hff,8'hff,write_mask_t[i],8'hff,{rst,clk_mem},write_mask[i]);
        end
    endgenerate
    
    generate
        for(i=0;i<8;i=i+1) begin: page
            for(j=0;j<8;j=j+1) begin: chip 
                sram128x8$    c(addr_t[11:5],io[i][j*8+:8],1'b0,write_mask[i][j],1'b0);
            end
        end
    endgenerate
    
    //wires for verification.
    wire [63:0] pg0,pg1,pg2,pg3,pg4,pg5,pg6,pg7;
    assign pg0 = io[0];
    assign pg1 = io[1];
    assign pg2 = io[2];
    assign pg3 = io[3];
    assign pg4 = io[4];
    assign pg5 = io[5];
    assign pg6 = io[6];
    assign pg7 = io[7];
    
    wire [7:0] wam0,wam1,wam2,wam3,wam4,wam5,wam6,wam7;
    assign wam0 = write_mask[0];
    assign wam1 = write_mask[1];
    assign wam2 = write_mask[2];
    assign wam3 = write_mask[3];
    assign wam4 = write_mask[4];
    assign wam5 = write_mask[5];
    assign wam6 = write_mask[6];
    assign wam7 = write_mask[7];
endmodule