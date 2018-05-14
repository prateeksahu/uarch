module testbench();

    reg clk, rst, enq, i_vld, i_last_uop, read;
    reg [31:0] i_eip, i_eip_cmp, i_data;
    reg [14:0] i_addr;
    reg [2:0]  i_size;
	
	always #5 clk = ~clk;
    initial
    begin
    	clk = 1'b0;
    	rst = 1'b0;
    	enq = 1'b0;
    	read = 1'b0;
    	#100
    	rst = 1'b1;
    	#20
    	@(posedge clk)
    	enq = 1'b1;
    	i_vld = 1'b1;
    	i_eip = 32'h4766387;
    	i_data = 32'hcbe6783;
    	i_last_uop = 1'b1;
    	i_eip_cmp = 32'h0;
    	read = 1'b0;	
    	i_addr = 15'h1234;
    	i_size = 3'b11;
		@(posedge clk)
    	enq = 1'b0;
		@(posedge clk)
    	enq = 1'b1;
    	i_vld = 1'b0;
    	i_eip = 32'h4766380;
    	i_data = 32'hcbe6a83;
    	i_last_uop = 1'b0;
    	i_eip_cmp = 32'h0;
    	read = 1'b1;
    	i_addr = 15'h1236;
    	i_size = 3'b11;
		@(posedge clk)
    	enq = 1'b0; 
    	read = 1'b1;
    	@(posedge clk)
    	enq = 1'b1;
    	i_vld = 1'b1;
    	i_eip = 32'h4766380;
    	i_data = 32'hcbe6c83;
    	i_last_uop = 1'b1;
    	i_eip_cmp = 32'h4766380;
    	read = 1'b1;
    	i_addr = 15'h1238;
    	i_size = 3'b11;  	
    	#100
    	$finish;
    end

initial
      begin
	 $vcdplusfile("testbench.dump.vpd");
	 $vcdpluson(0, testbench); 
      end // initial begin

    wire o_en_vld, empty, full;
    wire [14:0] o_en_addr;
    wire [31:0] o_en_data, o_en_eip;
    wire [2:0] o_en_size;
    wb_buffer_d4 wb(clk, rst, enq, i_vld, i_eip, i_eip_cmp, i_addr, i_data, i_size, i_last_uop, o_en_vld, o_en_addr, o_en_data, o_en_eip, o_en_size, , , , , read, empty, full);

endmodule