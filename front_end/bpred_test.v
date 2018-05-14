module bpred_testbench;

	reg	[0:0]	CLK;
	reg	[0:0]	reset;
	reg	[31:0]	pred_pc;
	
	reg	[0:0] 	pred_taken;
	reg	[31:0] 	update_eip;
	reg	[31:0] 	update_target;
	reg 	[0:0]	update_taken;
	reg	[0:0]	update_valid;
	
	wire	[31:0]	pred_target_curr;
	wire	[0:0]	pred_taken_curr;
	wire	[0:0]	pred_hit_curr;
	
	always
	begin
		#10 CLK = !CLK;
	end
	
	initial 
	begin
	
		CLK = 0;
		reset = 0;
		
		pred_pc		= 0;	
		pred_taken	= 0;		
		update_eip	= 0;	
		update_target	= 0;	
		update_taken	= 0;	
		update_valid	= 0;	
	
		//Init bp
		#20
		reset 		= 1;
	
		pred_taken	= 0;		
		update_eip	= 16;
		update_target 	= 45;
		update_taken	= 1;
		update_valid 	= 1;		
		
		#20
		pred_taken	= 0;		
		update_eip	= 64;
		update_target 	= 25;
		update_taken	= 0;
		update_valid 	= 1;		
	
		#20
		update_valid	= 0;
		pred_pc 	= 16;

		#20
		pred_pc 	= 64;
		
		//$finish;
	end
	
endmodule
