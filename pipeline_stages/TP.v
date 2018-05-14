
module TP(
output [48:0] o_CS,        output [31:0] o_virt_addr, output [31:0] o_src1,      
output [31:0] o_src2,      output [31:0] o_nEIP,      output [31:0] o_EIP,       
output [31:0] o_bp_tgt,    output [15:0] o_segRc,     output [31:0] o_segRc_lim, 
output [7:0]  o_imm8,      output [1:0]  o_opSize,    output [2:0]  o_dr1,       
output [2:0]  o_dr2,       output [2:0]  o_drSeg,     output        o_bp_taken,  
output        o_Dflag,     output [3:0]  o_br_fetchID,output        o_v,          
/*
input [48:0] i_CS,        input [31:0] i_virt_addr, input [31:0] i_src1,      
input [31:0] i_src2,      input [31:0] i_nEIP,      input [31:0] i_EIP,       
input [31:0] i_bp_tgt,    input [15:0] i_segRc,     input [31:0] i_segRc_lim, 
input [7:0]  i_imm8,      input [1:0]  i_opSize,    input [2:0]  i_dr1,       
input [2:0]  i_dr2,       input [2:0]  i_drSeg,     input        i_bp_taken,  
input        i_Dflag,     input [3:0]  i_br_fetchID,input        i_v,          
*/

input [314:0] in, input clk, input rst, input stall);

wire [314:0] o;

inv1$ i1(nstall, stall);
regn #(315) tp(in, clk, rst, nstall, o);

assign o_CS        = o[314:266];        
assign o_virt_addr = o[265:234];      
assign o_src1      = o[233:202];       
assign o_src2      = o[201:170];      
assign o_nEIP      = o[169:138];      
assign o_EIP       = o[137:106];
assign o_bp_tgt    = o[105:074];    
assign o_segRc     = o[073:058];    
assign o_segRc_lim = o[057:026];    
assign o_imm8      = o[025:018];
assign o_opSize    = o[017:016];
assign o_dr1       = o[015:013];       
assign o_dr2       = o[012:010];     
assign o_drSeg     = o[009:007];     
assign o_bp_taken  = o[006:006];  
assign o_Dflag     = o[005:005];  
assign o_br_fetchID= o[004:001];   
assign o_v         = o[000:000]; 

endmodule





  