// module that creates two synchronous dual port rams to create a "ping-pong" memory scheme where
// results are read from one memory bank and written to the other within a given stage
// each set is latge enough to hold all of the data but since the ping pong scheme is used, 
// only one bank is needed at a given time. So intially, one bank is filled with samples in their
// natural order. This module writes the samples to the second memory bank in bit reversed order



module reverser(start_gen, clk, addr, addr_cnt, done_gen);
parameter N = 8;
parameter BITS_PER_ROW = 3;

input clk;
input start_gen;

// data bus for addresses
//current address (for testing just having it spit out addresses in sucession)
output reg [0:BITS_PER_ROW-1] addr;
output reg [0:BITS_PER_ROW-1] addr_cnt;
output reg done_gen=0;

// create a chunk of memory that will ultimately hold the address sequence
//reg[0:N] seq_init[0:BITS_PER_ROW];
reg [0:BITS_PER_ROW-1] out1[0:N/2-1];
reg [0:BITS_PER_ROW-1] out2[0:N/2-1];
reg [0:BITS_PER_ROW-1] seq_init[0:N-1];

// variables to track stages of permutation process
reg sub_seq;
reg new_seq;

// loop counters
integer i;
integer j;
integer k;

// initial sequence is two long (0,1)
integer sub_size=2;
integer seq_size=4;

always @(posedge clk, posedge start_gen) begin
	sub_seq <= 0;
	new_seq <= 0;
end

//output adresses in sucession
always@(posedge  clk) begin
	if (done_gen) begin
		for (j = 0; j<N; j = j+1) begin
			if (j==addr_cnt) begin
				addr[0:BITS_PER_ROW-1] <= seq_init[j][0:BITS_PER_ROW-1]; 
			end	
		end	
	end
end

always @(posedge clk) begin
	if (done_gen) begin
		addr_cnt[0:BITS_PER_ROW-1] <= addr_cnt[0:BITS_PER_ROW-1]+1;
	end
end

always @(posedge start_gen) begin
	// initialize first two elements with 0 and 1
	seq_init[0][0:BITS_PER_ROW-1]<= 0;
	seq_init[1][0:BITS_PER_ROW-1]<= 1;
	sub_seq <=1;
	addr_cnt[0:BITS_PER_ROW-1] <= 0;
end


always@(posedge sub_seq) begin
	if (sub_size<=N/2) begin
		for (k = 0; k<N/2; k= k+1)
			if (k<sub_size) begin
				out1[k][0:BITS_PER_ROW-1]  <= 2*seq_init[k][0:BITS_PER_ROW-1] ;
				out2[k][0:BITS_PER_ROW-1] <= 2*seq_init[k][0:BITS_PER_ROW-1]+1;
			end
			else if (k >= sub_size) begin
				out1[k][0:BITS_PER_ROW-1]  <= 0 ;
				out2[k][0:BITS_PER_ROW-1] <= 0;
			end
		end
	new_seq <= 1;
	sub_seq<=0;
	sub_size <= sub_size*2;
end

always @(posedge sub_seq) begin
	if (sub_size == N) begin
		done_gen <= 1;
	end
end

always @(posedge new_seq) begin
	if (seq_size<=N) begin
		for (i=0; i<N; i= i+1) begin
			if (i < seq_size/2) begin
				seq_init[i][0:BITS_PER_ROW-1] <= out1[i][0:BITS_PER_ROW-1];
			end
			else if (i >= seq_size/2) begin
					seq_init[i][0:BITS_PER_ROW-1] <= out2[i-seq_size/2][0:BITS_PER_ROW-1];
			end
		end
	sub_seq <= 1;
	new_seq <=0;
	seq_size <= seq_size*2;
	end
end

endmodule



				

