module plru(
    input [8:0] i_lru,
    input [2:0] i_vld,
    input [1:0] hit_way,
	input hit,
	input rd,
    input wb,
    input mem,
	output isevict,
    output [8:0] o_lru,
    output [1:0] lru_way
    );
	
	wire [2:0] w [2:0],wo [3:0];
	wire [2:0] wx;
	
	assign w[0] = i_lru[2:0];
	assign w[1] = i_lru[5:3];
	assign w[2] = i_lru[8:6];
	assign o_lru[2:0] = wo[0];
	assign o_lru[5:3] = wo[1];
	assign o_lru[8:6] = wo[2];
	
	genvar i;
	generate
		for(i=0;i<3;i=i+1) begin : l
			nor3$	n(wx[i],w[i][0],w[i][1],w[i][2]);
		end
	endgenerate
	
	wire [1:0] wx1,wx2,lw_1,lw_2,way,lru_way_t;
	wire allvn,ie1;
	//mux2n #(2) m1(2'b0,2'b1,wx[1],wx1);
	mux2n #(2) m2({1'b0,wx[1]},2'h2,wx[2],lru_way_t);
	
	mux3n #(1) m6(i_vld[0],i_vld[1],i_vld[2],lru_way_t,ie1);
	
	wire hitn;
	inv1$	iv1(hitn,hit);
	and3$	a1(isevict,mem,hitn,ie1);
	
	//If update/evict, way is referenced (variable way).
	//The way referenced is hit_way (if hit), lru_way_t otherwise.
    mux2n #(2) m7(lru_way_t,hit_way,hit,way);
    //    mux2n #(2) m7(hit_way,lru_way_t,mem,way);
	
	mux3n #(3) 	m8(3'b110,{w[0][2],1'b0,w[0][0]},{1'b0,w[0][1:0]},way,wo[0]),
				m9({w[1][2:1],1'b0},3'b101,{1'b0,w[1][1:0]},way,wo[1]),
				m10({w[2][2:1],1'b0},{w[2][2],1'b0,w[2][0]},3'b011,way,wo[2]);
				
	assign lru_way = way;
endmodule
