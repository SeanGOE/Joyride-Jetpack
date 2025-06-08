// Description: A simple N-bit Linear Feedback Shift Register (LFSR) in SystemVerilog
module lfsr #(parameter N=3) (
  input logic clk, reset,
  output logic [N-1:0] out
  );
  
  // init states
  logic [N-1:0] ns, ps;
  
  // logic for next state
  assign ns[N-1:0] = {ps[N-2:0], ~(ps[N-1] ^ ps[N-2])};
	

  assign out = ps;
  
  always_ff @(posedge clk) 
		ps <= reset ? 'b0 : ns;
endmodule  // lfsr


// Testbench for the LFSR module
module lfsr_tb();
	logic clk, reset, high;
	logic [2:0] out;
	
	lfsr dut(.clk, .reset, .out);
	
	parameter CLOCK_PERIOD=100;
	
	integer j = 0;
  initial begin
    clk <= 0;
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
  end
	
	initial begin
	
		reset = 1'b1; @(posedge clk);
		reset = 1'b0; @(posedge clk);
		for (int i = 0; i < 10; i++) begin
			high = ~(|out); @(posedge clk);
			j = j+1;
		end
		$stop;
	end
endmodule  // lfsr_tb