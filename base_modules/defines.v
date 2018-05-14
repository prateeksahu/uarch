/////////////////////////////////////////////////////////////////////////////////////
/////                 VERILOG FILE CONTAINING ALL DEFINES.                    ///////
///// Add any `defines here and compile this file before any of the others.   ///////
/////                   The defines are global in scope.                      ///////
/////////////////////////////////////////////////////////////////////////////////////

//This defines ceil(log2(x)). Extend definition if needed.
`define CLOG2N(x) (x <= 2) ? 1 : (x <= 4) ? 2 : (x <= 8) ? 3 : (x <= 16) ? 4 : \
					(x <= 32) ? 5 : (x <= 64) ? 6 : (x <= 128) ? 7 : (x <= 256) ? 8 : -1
					
//This defines ceil(x/8). Extend definition if larger bit widths needed. 
`define CEIL_N_8(x) (x <= 8) ? 1 : (x <= 16) ? 2 : (x <= 24) ? 3 : (x <= 32) ? 4 : \
					(x <= 40) ? 5 : (x <= 48) ? 6 : (x <= 56) ? 7 : (x <= 64) ? 8 : -1  

