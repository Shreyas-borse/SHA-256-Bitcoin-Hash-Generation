module bitcoin_hash #(parameter MSG_SIZE = 32'd640)
					(input logic        clk, reset_n, start,
                     input logic [15:0] message_addr, output_addr,
                    output logic        done, mem_clk, mem_we,
                    output logic [15:0] mem_addr,
                    output logic [31:0] mem_write_data,
                     input logic [31:0] mem_read_data);

enum logic [ 3:0] {IDLE, READ, READ_DELAY, PHASE1, WAIT_PHASE1, PHASE2, WAIT_PHASE2, PHASE3, WAIT_PHASE3, WRITE, COMPLETE} state;
logic [31:0] w0[16], w1[16], w2[16], w3[16], w4[16], w5[16], w6[16], w7[16], w8[16], w9[16], w10[16], w11[16], w12[16], w13[16], w14[16], w15[16];
logic [31:0] message[32];
logic [31:0] h0[8], h1[8], h2[8], h3[8], h4[8], h5[8], h6[8], h7[8], h8[8], h9[8], h10[8], h11[8], h12[8], h13[8], h14[8], h15[8], h16[8];
logic [ 4:0] offset; 
logic        cur_we;
logic [15:0] cur_addr;
logic [31:0] cur_write_data;
logic [1:0] start_int;
logic [1:0] switch;
logic [16:0] done_int;

assign mem_clk = clk;
assign mem_addr = cur_addr + offset;
assign mem_we = cur_we;
assign mem_write_data = cur_write_data;

localparam int k[0:63] = '{
   32'h428a2f98,32'h71374491,32'hb5c0fbcf,32'he9b5dba5,32'h3956c25b,32'h59f111f1,32'h923f82a4,32'hab1c5ed5,
   32'hd807aa98,32'h12835b01,32'h243185be,32'h550c7dc3,32'h72be5d74,32'h80deb1fe,32'h9bdc06a7,32'hc19bf174,
   32'he49b69c1,32'hefbe4786,32'h0fc19dc6,32'h240ca1cc,32'h2de92c6f,32'h4a7484aa,32'h5cb0a9dc,32'h76f988da,
   32'h983e5152,32'ha831c66d,32'hb00327c8,32'hbf597fc7,32'hc6e00bf3,32'hd5a79147,32'h06ca6351,32'h14292967,
   32'h27b70a85,32'h2e1b2138,32'h4d2c6dfc,32'h53380d13,32'h650a7354,32'h766a0abb,32'h81c2c92e,32'h92722c85,
   32'ha2bfe8a1,32'ha81a664b,32'hc24b8b70,32'hc76c51a3,32'hd192e819,32'hd6990624,32'hf40e3585,32'h106aa070,
   32'h19a4c116,32'h1e376c08,32'h2748774c,32'h34b0bcb5,32'h391c0cb3,32'h4ed8aa4a,32'h5b9cca4f,32'h682e6ff3,
   32'h748f82ee,32'h78a5636f,32'h84c87814,32'h8cc70208,32'h90befffa,32'ha4506ceb,32'hbef9a3f7,32'hc67178f2
}; 
always_ff @(posedge clk, negedge reset_n)
begin
  if (!reset_n) begin
    cur_we <= 1'b0;
    state <= IDLE;
	start_int <= 2'b0;
	switch <= 2'b0;
  end 
  else case (state)
   IDLE: begin 
       if(start) begin
			cur_addr <= message_addr;
			cur_we <= 1'b0;
			offset <= 5'b0;
			start_int <= 2'b0;
			switch <= 2'b0;
			state <= READ;
       end
    end

	READ: begin
		if(offset < 21) begin
			message[offset-1] <= mem_read_data;
			offset <= offset + 5'b1;
			state <= READ;
		end
		else begin
			message[offset-1] <= mem_read_data;
			offset <= offset + 5'b1;
			state <= READ_DELAY;
		end
	end			
		
	READ_DELAY:begin
		for(int n=0; n<16; n++) 
				w0[n] <= message[n];
		message[20] <= 32'h80000000;
		message[31] <= 32'd640;
		for(int n = 21; n<31; n++) message[n] <= 32'h0;
		offset <= 5'b0;
		if (offset != 5'b0) 
			state <= READ_DELAY;
		else
			state <= PHASE1;
    end 
		
    PHASE1: begin
				start_int[0] <= 1'b1;
				switch[0] <= 1'b0;
				state <= WAIT_PHASE1;
    end

	WAIT_PHASE1: begin
		start_int[0] <= 1'b0;
		if(done_int[0]) begin
			for(int n=0;n<3;n++) 
			begin
				w0[n] <= message[n+16];
				w1[n] <= message[n+16];
				w2[n] <= message[n+16];
				w3[n] <= message[n+16];
				w4[n] <= message[n+16];
				w5[n] <= message[n+16];
				w6[n] <= message[n+16];
				w7[n] <= message[n+16];
				w8[n] <= message[n+16];
				w9[n] <= message[n+16];
				w10[n] <= message[n+16];
				w11[n] <= message[n+16];
				w12[n] <= message[n+16];
				w13[n] <= message[n+16];
				w14[n] <= message[n+16];
				w15[n] <= message[n+16];
			end
				w0[3] <= 32'd0;
				w1[3] <= 32'd1;
				w2[3] <= 32'd2;
				w3[3] <= 32'd3;
				w4[3] <= 32'd4;
				w5[3] <= 32'd5;
				w6[3] <= 32'd6;
				w7[3] <= 32'd7;
				w8[3] <= 32'd8;
				w9[3] <= 32'd9;
				w10[3] <= 32'd10;
				w11[3] <= 32'd11;
				w12[3] <= 32'd12;
				w13[3] <= 32'd13;
				w14[3] <= 32'd14;
				w15[3] <= 32'd15;
			for(int n=4;n<16;n++) 
			begin
				w0[n] <= message[n+16];
				w1[n] <= message[n+16];
				w2[n] <= message[n+16];
				w3[n] <= message[n+16];
				w4[n] <= message[n+16];
				w5[n] <= message[n+16];
				w6[n] <= message[n+16];
				w7[n] <= message[n+16];
				w8[n] <= message[n+16];
				w9[n] <= message[n+16];
				w10[n] <= message[n+16];
				w11[n] <= message[n+16];
				w12[n] <= message[n+16];
				w13[n] <= message[n+16];
				w14[n] <= message[n+16];
				w15[n] <= message[n+16];
			end
			state <= PHASE2;
		end
		else begin
			state <= WAIT_PHASE1;
		end
	end
	
	PHASE2: begin
			start_int[1] <= 1'b1;
			switch[1] <= 1'b1;
			state <= WAIT_PHASE2;
    end

	WAIT_PHASE2: begin
		start_int[1] <= 1'b0;
		if(done_int[1]) begin
			for(int n=0;n<8;n++) 
			begin
				w0[n] <= h1[n];
				w1[n] <= h2[n];
				w2[n] <= h3[n];
				w3[n] <= h4[n];
				w4[n] <= h5[n];
				w5[n] <= h6[n];
				w6[n] <= h7[n];
				w7[n] <= h8[n];
				w8[n] <= h9[n];
				w9[n] <= h10[n];
				w10[n] <= h11[n];
				w11[n] <= h12[n];
				w12[n] <= h13[n];
				w13[n] <= h14[n];
				w14[n] <= h15[n];
				w15[n] <= h16[n];
			end
				w0[8] <= 32'h80000000;
				w1[8] <= 32'h80000000;
				w2[8] <= 32'h80000000;
				w3[8] <= 32'h80000000;
				w4[8] <= 32'h80000000;
				w5[8] <= 32'h80000000;
				w6[8] <= 32'h80000000;
				w7[8] <= 32'h80000000;
				w8[8] <= 32'h80000000;
				w9[8] <= 32'h80000000;
				w10[8] <= 32'h80000000;
				w11[8] <= 32'h80000000;
				w12[8] <= 32'h80000000;
				w13[8] <= 32'h80000000;
				w14[8] <= 32'h80000000;
				w15[8] <= 32'h80000000;
			for(int n=9; n<15; n++) 
			begin
				w0[n] <= 32'h0;
				w1[n] <= 32'h0;
				w2[n] <= 32'h0;
				w3[n] <= 32'h0;
				w4[n] <= 32'h0;
				w5[n] <= 32'h0;
				w6[n] <= 32'h0;
				w7[n] <= 32'h0;
				w8[n] <= 32'h0;
				w9[n] <= 32'h0;
				w10[n] <= 32'h0;
				w11[n] <= 32'h0;
				w12[n] <= 32'h0;
				w13[n] <= 32'h0;
				w14[n] <= 32'h0;
				w15[n] <= 32'h0;
			end
				w0[15] <= 32'd256;
				w1[15] <= 32'd256;
				w2[15] <= 32'd256;
				w3[15] <= 32'd256;
				w4[15] <= 32'd256;
				w5[15] <= 32'd256;
				w6[15] <= 32'd256;
				w7[15] <= 32'd256;
				w8[15] <= 32'd256;
				w9[15] <= 32'd256;
				w10[15] <= 32'd256;
				w11[15] <= 32'd256;
				w12[15] <= 32'd256;
				w13[15] <= 32'd256;
				w14[15] <= 32'd256;
				w15[15] <= 32'd256;
			state <= PHASE3;
		end
		else begin
			state <= WAIT_PHASE2;
		end
	end
	
	PHASE3: begin
			start_int[1] <= 1'b1;
			switch[1] <= 1'b0;
			state <= WAIT_PHASE3;
    end

	WAIT_PHASE3: begin
		start_int[1] <= 1'b0;
		if(done_int[1]) begin
			cur_addr <= output_addr;
			cur_we <= 1'b1;
			cur_write_data <= h1[0];
			offset <= 5'b0;
			state <= WRITE;
		end
		else begin
			state <= WAIT_PHASE3;
		end
	end
		
	WRITE: begin
		if(offset < 15) begin
			case(offset)
			    0: cur_write_data  <= h2[0];
			    1: cur_write_data  <= h3[0];
			    2: cur_write_data  <= h4[0];
			    3: cur_write_data  <= h5[0];
			    4: cur_write_data  <= h6[0];
			    5: cur_write_data  <= h7[0];
			    6: cur_write_data  <= h8[0];
			    7: cur_write_data  <= h9[0];
				8: cur_write_data  <= h10[0];
			    9 : cur_write_data <= h11[0];
			    10: cur_write_data <= h12[0];
			    11: cur_write_data <= h13[0];
			    12: cur_write_data <= h14[0];
			    13: cur_write_data <= h15[0];
			    14: cur_write_data <= h16[0];
			    default: cur_write_data <= h1[0];
			endcase
			offset <= offset + 5'b1;
			state <= WRITE;
		end
		else begin
			state <= COMPLETE;
		end
    end
	
	COMPLETE: begin
		state <= IDLE;
	end
	
	default: begin
		state <= IDLE;
	end
	
   endcase
  end
	
assign done = (state == COMPLETE);	

simplified_sha256 #(.NUM_OF_WORDS(16)) sha0_phase1 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[0]),
	.message(w0),
	.in(h0),
	.switch(1'b0),
	.done(done_int[0]),
	.sha256_result(h0)
	);

	simplified_sha256 #(.NUM_OF_WORDS(16)) sha1_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w0),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[1]),
	.sha256_result(h1)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha2_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w1),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[2]),
	.sha256_result(h2)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha3_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w2),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[3]),
	.sha256_result(h3)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha4_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w3),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[4]),
	.sha256_result(h4)
	);
	
	
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha5_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w4),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[5]),
	.sha256_result(h5)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha6_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w5),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[6]),
	.sha256_result(h6)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha7_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w6),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[7]),
	.sha256_result(h7)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha8_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w7),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[8]),
	.sha256_result(h8)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha9_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w8),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[9]),
	.sha256_result(h9)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha10_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w9),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[10]),
	.sha256_result(h10)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha11_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w10),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[11]),
	.sha256_result(h11)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha12_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w11),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[12]),
	.sha256_result(h12)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha13_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w12),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[13]),
	.sha256_result(h13)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha14_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w13),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[14]),
	.sha256_result(h14)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha15_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w14),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[15]),
	.sha256_result(h15)
	);
	
	simplified_sha256 #(.NUM_OF_WORDS(16)) sha16_phase2_3 (
	.clk(clk),
	.reset_n(reset_n),
	.start(start_int[1]),
	.message(w15),
	.in(h0),
	.switch(switch[1]),
	.done(done_int[16]),
	.sha256_result(h16)
	);
	
endmodule