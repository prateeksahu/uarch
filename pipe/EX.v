module EX( output o_cachable,
output [50:0] o_CS,        output [14:0] o_PA1,       output [14:0] o_PA2,      
output [31:0] o_op1,       output [31:0] o_op2,       output [31:0] o_nEIP,      
output [31:0] o_EIP,       output [31:0] o_bp_tgt,    output [7:0]  o_imm8,      
output [1:0]  o_opSize,    output [2:0]  o_dr1,       output [2:0]  o_dr2,       
output [2:0]  o_drSeg,     output        o_bp_taken,  output        o_Dflag,     
output [1:0]  o_size1,     output [1:0]  o_size2,     output        o_spill,     
output [3:0]  o_br_fetchID,output        o_v,   
/* input cachable,
input [50:0] i_CS,        input [14:0] i_PA1,       input [14:0] i_PA2,      
input [31:0] i_op1,       input [31:0] i_op2,       input [31:0] i_nEIP,      
input [31:0] i_EIP,       input [31:0] i_bp_tgt,    input [7:0]  i_imm8,      
input [1:0]  i_opSize,    input [2:0]  i_dr1,       input [2:0]  i_dr2,       
input [2:0]  i_drSeg,     input        i_bp_taken,  input        i_Dflag,     
input [1:0]  i_size1,     input [1:0]  i_size2,     input        i_spill,     
input [3:0]  i_br_fetchID,input        i_v,*/

input [272:0] in, input clk, input rst, input stall, input inv);

wire [272:0] o;

inv1$ i1(nstall, stall);
or2$ o2(write, nstall, inv);
regn #(273) ex(in, clk, rst, write, o);

assign o_cachable    = o[272:272];
assign o_CS        = o[271:221];
assign o_PA1       = o[220:206];        
assign o_PA2       = o[205:191];      
assign o_op1       = o[190:159];       
assign o_op2       = o[158:127];      
assign o_nEIP      = o[126:095];      
assign o_EIP       = o[094:063];
assign o_bp_tgt    = o[062:031]; 
assign o_imm8      = o[030:023];
assign o_opSize    = o[022:021];
assign o_dr1       = o[020:018];       
assign o_dr2       = o[017:015];       
assign o_drSeg     = o[014:012];     
assign o_bp_taken  = o[011:011];  
assign o_Dflag     = o[010:010];   
assign o_size1     = o[009:008];
assign o_size2     = o[007:006];
assign o_spill     = o[005:005];  
assign o_br_fetchID= o[004:001];   
assign o_v         = o[000:000]; 

endmodule

