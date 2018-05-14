module bpred_testbench;

	reg	[0:0]	CLK;
	reg	[0:0]	reset;
	reg	[31:0]	pred_pc;
	
	reg	[31:0] 	update_neip;
	reg	[31:0] 	update_target;
	reg 	[0:0]	update_taken;
	reg 	[0:0]	update_mispred;
	reg	[0:0]	update_valid;
	
	wire	[31:0]	pred_target_curr;
	wire	[0:0]	pred_taken_curr;
	wire	[0:0]	pred_hit_curr;
	
	always
	begin
		#10 CLK = !CLK;
	end
	
	bpred 	bp(CLK, reset, pred_pc, update_neip, update_target, update_taken, update_mispred, update_valid, pred_target_curr, pred_taken_curr, pred_hit_curr);
	
	initial 
	begin
	
		CLK = 0;
		reset = 0;
		
		pred_pc		= 0;	
		update_neip	= 0;	
		update_target	= 0;	
		update_taken	= 0;
		update_mispred	= 0;			
		update_valid	= 0;	
	
		//Init bp
		#20
		reset 		= 1;
	
		update_neip	= 16;
		update_target 	= 45;
		update_taken	= 1;
		update_mispred	= 1;
		update_valid 	= 1;		
		
		#20	
		update_neip	= 64;
		update_target 	= 25;
		update_taken	= 0;
		update_mispred	= 1;	
		update_valid 	= 1;		
	
		#20
		update_valid	= 0;
		pred_pc 	= 16;

		#20
		pred_pc 	= 64;
		
		//$finish;
	end
	
endmodule
