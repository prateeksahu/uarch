
module AG(
output [48:0] o_CS,        output [31:0] o_addr1,     output [31:0] o_addr2,     
output [31:0] o_src1,      output [31:0] o_src2,      output [31:0] o_nEIP,      
output [31:0] o_EIP,       output [31:0] o_bp_tgt,    output [15:0] o_segRc1,    
output [19:0] o_limit,     output [7:0]  o_imm8,      
output [1:0]  o_opSize,    output [2:0]  o_dr1,       output [2:0]  o_dr2,       
output [2:0]  o_drSeg,     output        o_bp_taken,  output        o_indir,     
output        o_Dflag,     output [3:0]  o_br_fetchID,output        o_v,        
/*
input [48:0] i_CS,        input [31:0] i_addr1,     input [31:0] i_addr2,     
input [31:0] i_src1,      input [31:0] i_src2,      input [31:0] i_nEIP,      
input [31:0] i_EIP,       input [31:0] i_bp_tgt,    input [15:0] i_segRc1,    
input [19:0] i_limit,     input [7:0]  i_imm8,      
input [1:0]  i_opSize,    input [2:0]  i_dr1,       input [2:0]  i_dr2,       
input [2:0]  i_drSeg,     input        i_bp_taken,  input        i_indir,     
input        i_Dflag,     input [3:0]  i_br_fetchID,input        i_v
*/

input [335:0] in, input clk, input rst, input stall);

wire [335:0] o;

inv1$ i1(nstall, stall);
regn #(336) ag(in, clk, rst, nstall, o);

assign o_CS        = o[335:287];
assign o_addr1     = o[286:255];        
assign o_addr2     = o[254:223];      
assign o_src1      = o[222:191];       
assign o_src2      = o[190:159];      
assign o_nEIP      = o[158:127];      
assign o_EIP       = o[126:095];
assign o_bp_tgt    = o[094:063];    
assign o_segRc1    = o[062:047];    
assign o_limit     = o[046:027];    
assign o_imm8      = o[026:019];
assign o_opSize    = o[018:017];
assign o_dr1       = o[016:014];       
assign o_dr2       = o[013:011];     
assign o_drSeg     = o[010:008];     
assign o_bp_taken  = o[007:007];  
assign o_indir     = o[006:006];
assign o_Dflag     = o[005:005];  
assign o_br_fetchID= o[004:001];   
assign o_v         = o[000:000]; 

endmodule