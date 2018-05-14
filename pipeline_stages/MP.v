module MP(
output [48:0] o_CS,        output [14:0] o_phys_addr, output [31:0] o_src1,      
output [31:0] o_src2,      output [31:0] o_nEIP,      output [31:0] o_EIP,       
output [31:0] o_bp_tgt,    output [7:0]  o_imm8,      output [1:0]  o_opSize,   
output [2:0]  o_dr1,       output [2:0]  o_dr2,       output [2:0]  o_drSeg,     
output        o_bp_taken,  output        o_Dflag,     output [1:0]  o_reqSize,
output        o_spill,     output        o_false_of,  output [3:0]  o_br_fetchID,
output        o_v,     
/*
input [48:0] i_CS,        input [14:0] i_phys_addr, input [31:0] i_src1,      
input [31:0] i_src2,      input [31:0] i_nEIP,      input [31:0] i_EIP,       
input [31:0] i_bp_tgt,    input [7:0]  i_imm8,      input [1:0]  i_opSize,   
input [2:0]  i_dr1,       input [2:0]  i_dr2,       input [2:0]  i_drSeg,     
input        i_bp_taken,  input        i_Dflag,     input [1:0]  i_reqSize,
input        i_spill,     input        i_false_of,  input [3:0]  i_br_fetchID,
input        i_v,

output [253:0] o,*/ input [253:0] in, input clk, input rst, input stall);

wire [253:0] o;

inv1$ i1(nstall, stall);
regn #(254) mp(in, clk, rst, nstall, o);

assign o_CS        = o[253:205];        
assign o_phys_addr = o[204:190];      
assign o_src1      = o[189:158];       
assign o_src2      = o[157:126];      
assign o_nEIP      = o[125:094];      
assign o_EIP       = o[093:062];
assign o_bp_tgt    = o[061:030];    
assign o_imm8      = o[029:022];  
assign o_opSize    = o[021:020];
assign o_dr1       = o[019:017];       
assign o_dr2       = o[016:014];       
assign o_drSeg     = o[013:011];     
assign o_bp_taken  = o[010:010];  
assign o_Dflag     = o[009:009];   
assign o_reqSize   = o[008:007];
assign o_spill     = o[006:006];
assign o_false_of  = o[005:005];  
assign o_br_fetchID= o[004:001];   
assign o_v         = o[000:000];

endmodule





  