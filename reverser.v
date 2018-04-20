// module that creates two synchronous dual port rams to create a "ping-pong" memory scheme where
// results are read from one memory bank and written to the other within a given stage
// each set is latge enough to hold all of the data but since the ping pong scheme is used, 
// only one bank is needed at a given time. So intially, one bank is filled with samples in their
// natural order. This module writes the samples to the second memory bank in bit reversed order



module reverser(start_gen, clk, addr, addr_cnt, done_gen, done_output);

// N = length of transform. Assumed power of two
parameter N = 8;
// log base two of N-1
parameter BITS_PER_ROW = 3;
// clock
input clk;
//input that touches off generation of bit reversed sequence
input start_gen;

// data bus for addresses
//current address (for testing just having it spit out addresses in sucession)
output reg [0:BITS_PER_ROW-1] addr;
// one extra bit for the address count since it starts at one instead of zero
output reg [0:BITS_PER_ROW] addr_cnt;
// outputs that indicate when sequence is generated (done_gen) and when all addresses 
// have been output (done_output)
output reg done_gen = 0;
output reg done_output = 0;

// memory for sub-sequences and for final sequence. Made full length to start
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

//output adresses in sucession if they're done being generated and have not yet been output
always@(posedge  clk) begin
	for (j = 0; j<N; j = j+1) begin
		if (addr_cnt == j && done_gen && !done_output) begin
			addr[0:BITS_PER_ROW-1] <= seq_init[j][0:BITS_PER_ROW-1]; 
		end		
	end	
end

// when addr_cnt reaches N, set done_output to high
always @(posedge clk) begin
	if (addr_cnt == N-1) begin
		done_output<=1;
	end
end

// add one to addr_cnt as long as the address sequence is done being generated and all addresses have not yet been output
always @(posedge clk) begin
	if (done_gen && !done_output) begin
		addr_cnt[0:BITS_PER_ROW] <= addr_cnt[0:BITS_PER_ROW] + 1;
	end
end

// initialize the sequence for the first permutation stage at start_gen signal. Also initialize
// sub_seq, whose rising edge sets off permutation and initialize addr_cnt to zero
always @(posedge start_gen) begin
	// initialize first two elements with 0 and 1
	seq_init[0][0:BITS_PER_ROW-1]<= 0;
	seq_init[1][0:BITS_PER_ROW-1]<= 1;
	sub_seq <=1;
	new_seq <=0;
	addr_cnt[0:BITS_PER_ROW] <= 0;
end

// when the sub-sequence that generates the next permutation is done, fill the next set of sub-sequences
always@(posedge sub_seq) begin
	// as long as the size of the subsequence is less than half the final size
	if (sub_size<=N/2) begin
		// loop N/s times regardless of stage
		for (k = 0; k<N/2; k= k+1)
			// if k is less than half the size of the next sequence
			if (k<sub_size) begin
				out1[k][0:BITS_PER_ROW-1]  <= 2*seq_init[k][0:BITS_PER_ROW-1] ;
				out2[k][0:BITS_PER_ROW-1] <= 2*seq_init[k][0:BITS_PER_ROW-1]+1;
			end
			// if k is greater than half the size of the next sequence write 0
			else if (k >= sub_size) begin
				out1[k][0:BITS_PER_ROW-1]  <= 0 ;
				out2[k][0:BITS_PER_ROW-1] <= 0;
			end
		end
	// set new_seq whose rising edge touches off the combination of out1 and out2 into the next permutation
	new_seq <= 1;
	// un-set sub_seq so it can be set again and it's rising edge can touch off this always
	sub_seq<=0;
	// double the size of the sub-sequences
	sub_size <= sub_size*2;
end

// put done_gen high if the end of the permutation has been reached
always @(posedge sub_seq) begin
	if (sub_size == N || seq_size == N*2) begin
		done_gen <= 1;
	end
end

// combine out1 and out2 into next permutation
always @(posedge new_seq) begin
	// if the size is still less than or equal to N
	if (seq_size<=N) begin
		for (i=0; i<N; i= i+1) begin
			// if i is <= half sub-sequence size fill from out1
			if (i < seq_size/2) begin
				seq_init[i][0:BITS_PER_ROW-1] <= out1[i][0:BITS_PER_ROW-1];
			end
			// if i is more than half sub-sequence size fill from out2
			else if (i >= seq_size/2) begin
					seq_init[i][0:BITS_PER_ROW-1] <= out2[i-seq_size/2][0:BITS_PER_ROW-1];
			end
		end
	// set sub_seq to one so its rising edge will touch off next stage
	sub_seq <= 1;
	// set new_seq to zero so next stage can create a rising edge
	new_seq <=0;
	// double the sequence size
	seq_size <= seq_size*2;
	end
end

endmodule



				

