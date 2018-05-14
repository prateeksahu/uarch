module WB(
output [52:0] o_CS,       output [31:0] o_data1,    output [31:0] o_data2,    
output [31:0] o_EIP,      output [31:0] o_nEIP,     output [14:0] o_PA1,      
output [14:0] o_PA2,      output [14:0] o_PA3,      output [14:0] o_PA4,      
output [1:0]  o_size1,    output [1:0]  o_size2,    output [5:0]  o_eflags,   
output [1:0]  o_opSize,   
output [2:0]  o_dr1,      output [2:0]  o_dr2,      output [2:0]  o_drSeg,    
output [1:0]  o_spill,    output        o_Dflag,    output        o_v,  
/*input [52:0] i_CS,       input [31:0] i_data1,    input [31:0] i_data2,    
input [31:0] i_EIP,      input [31:0] i_nEIP,     input [14:0] i_PA1,      
input [14:0] i_PA2,      input [14:0] i_PA3,      input [14:0] i_PA4,      
input [1:0]  i_size1,    input [1:0]  i_size2,    input [5:0]  i_eflags,   
input [2:0]  i_dr1,      input [2:0]  i_dr2,      input [2:0]  i_drSeg,    
input [1:0]  i_spill,    input        i_Dflag,    input        i_v, */

input [265:0] in, input clk, input rst, input stall);

wire [265:0] o;

inv1$ i1(nstall, stall);
regn #(266) wb(in, clk, rst, nstall, o);

assign o_CS        = o[265:213];
assign o_data1     = o[212:181];       
assign o_data2     = o[180:149];      
assign o_EIP       = o[148:117];      
assign o_nEIP      = o[116:085];
assign o_PA1       = o[084:070];        
assign o_PA2       = o[069:055];      
assign o_PA3       = o[054:040]; 
assign o_PA4       = o[039:025];       
assign o_size1     = o[024:023]; 
assign o_size2     = o[022:021];  
assign o_eflags    = o[020:015];  
assign o_opSize    = o[014:013];
assign o_dr1       = o[012:010];       
assign o_dr2       = o[009:007];       
assign o_drSeg     = o[006:004];     
assign o_spill     = o[003:002];  
assign o_Dflag     = o[001:001];  
assign o_v         = o[000:000]; 

endmodule