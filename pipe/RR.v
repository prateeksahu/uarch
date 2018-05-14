
module RR(
output [50:0] o_CS,        output [31:0] o_imm,       output [31:0] o_disp,     
output [1:0]  o_immSize,   output [1:0]  o_dispSize,  output        o_isSIB,
output [1:0]  o_scale,     output        o_baseRen,   output        o_idxRen,
output [31:0] o_nEIP,      output [31:0] o_EIP,       output [31:0] o_bp_tgt,    
output [7:0]  o_imm8,      output [1:0]  o_opSize,    output [2:0]  o_sr1,       
output [2:0]  o_sr2,       output [2:0]  o_base,      output [2:0]  o_idx,
output [2:0]  o_SegR1,     output [2:0]  o_SegR2,     output        o_bp_taken,  
output        o_indir,     output        o_Dflag,     output [3:0]  o_brFetchId,
output        o_v,         
/*i_CS,         i_imm,      i_disp,      
i_immSize,      i_dispSize, i_SIB,
i_scale,        i_baseRen,  i_idxRen,
i_nEIP,         i_EIP,      i_bp_tgt,    
i_imm8,         i_opSize,   i_sr1,
i_sr2,          i_base,     i_idx,
i_segR1,        i_segR2,    i_bp_taken,
i_indir_addr,   i_Dflag,    i_br_fetch_id, 
i_v */

input [266:0] in, input clk, input rst, input stall, input inv);

wire [266:0] o;

inv1$ i1(nstall, stall);
or2$ o2(write, nstall, inv);
regn #(267) rr(in, clk, rst, write, o);

wire [61:0] cs;
assign cs[61:59] = o[266:264];
rewire #(59) rw(o[263:205], cs[58:0]); 

assign o_CS        = {cs[61:20],cs[18:16],cs[14:12],cs[8:7],cs[3]};
assign o_imm       = o[204:173];        
assign o_disp      = o[172:141];        
assign o_immSize   = o[140:139];        
assign o_dispSize  = o[138:137];        
assign o_isSIB     = o[136:136];        
assign o_scale     = o[135:134];      
assign o_baseRen   = o[133:133];       
assign o_idxRen    = o[132:132];      
assign o_nEIP      = o[131:100];      
assign o_EIP       = o[099:068];
assign o_bp_tgt    = o[067:036];    
assign o_imm8      = o[035:028];  
assign o_opSize    = o[027:026];
assign o_sr1       = o[025:023];       
assign o_sr2       = o[022:020];       
assign o_base      = o[019:017];     
assign o_idx       = o[016:014];     
assign o_SegR1     = o[013:011];     
assign o_SegR2     = o[010:008];     
assign o_bp_taken  = o[007:007];  
assign o_indir     = o[006:006];
assign o_Dflag     = o[005:005];  
assign o_brFetchId = o[004:001];   
assign o_v         = o[000:000]; 

endmodule

module rewire #(parameter N = 8) (input [N-1:0] in, output [N-1:0] o);
	genvar i;
	generate
		for(i=0;i<N;i=i+1) begin : inv
			assign o[N-i-1] = in[i];
		end
	endgenerate
endmodule