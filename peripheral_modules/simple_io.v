/////////////////////////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////////////////////////
module simple_io #(parameter DELAY = 100, parameter INTV = 13,
					parameter MM_ADDR = 32'h0)(
	input clk,
	input rst,
	//Output to bus.
	output [63:0] o_io1,
	output o_vld,
	input i_gnt);
	reg part,o_vld_t;
	
	assign o_io1[31:0] = INTV;
	assign o_io1[46:32] = MM_ADDR[14:0];
	assign o_io1[49:47] = 3'b0;
	assign o_io1[50] = 1'b0;
	assign o_io1[51] = 1'b1;
	assign o_io1[52] = 1'b0;
	assign o_io1[54:53] = 2'b10;
	assign o_io1[56:55] =  part ? 2'b10 : 2'b11;
	assign o_io1[58:57] = 2'b00;
	assign o_io1[59] = 1'b1;
	assign o_io1[62:60] = 3'b0;
	assign o_io1[63] = part ? 1'b1 : 1'b0;
	assign o_vld = o_vld_t;
	
	initial begin
		part = 1'b0;
		o_vld_t = 1'b0;
		#(DELAY)
		@(posedge clk)
		o_vld_t = 1'b1;
		wait(~i_gnt)
		@(posedge clk)
		o_vld_t = 1'b0;
		part = 1'b1;
	end
endmodule
	