// test bench for reverser module

//timescale 
`timescale 1ns/1ns

//test module for reverser module
module reverser_tb();
parameter BITS_PER_ROW = 3;
//toggle clock (period 70 time units)
reg clk;
reg start_gen;

wire [0:BITS_PER_ROW-1] addr;
wire [0:BITS_PER_ROW-1] addr_cnt;
wire done_gen;

initial begin
	clk = 0;
	repeat(100) begin
		 #50 clk = ~clk;
	end
end

initial begin
	start_gen = 0;
	#7 start_gen = 1;
end




//declare module under test
reverser test_reverser(.start_gen(start_gen),.clk(clk),.addr(addr), .addr_cnt(addr_cnt), .done_gen(done_gen));
 
endmodule