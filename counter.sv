// Description: A simple counter that increments the score when an on signal is detected.
// Input: clk, rst, on
// Output: score (10-bit)
module counter (
	input clk, rst,
	input on,
	output logic [9:0] score,
	input logic screen
	);
	
	logic on_filtered;
	
	pulse p1 (.clk, .reset(rst), .in(on), .out(on_filtered));
  
  always_ff @(posedge clk) begin
    if (rst | screen) begin
		 score <= 0;
	 end
    else if (on_filtered) begin
		 score <= score + 1'b1;
	 end
	 else begin
		 score <= score;
	 end
  end
		
		 
endmodule

module counter_tb();
	logic clk, rst, on;
	logic [9:0] score;
	logic screen;
	
	counter dut (.*);
	
	// set up the clk
	parameter clk_PERIOD = 100;
	initial begin
		clk <= 0;
	   forever #(clk_PERIOD/2) clk <= ~clk;
	end

	
   initial begin
	  @(posedge clk);  rst <= 1;     
     @(posedge clk);  rst <= 0;
	  
	  for (int i = 0; i < 100; i++) begin
			@(posedge clk);  on <= 0;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);  on <= 1;
	  end
	
	  
	 $stop;  // pause the simulation
  end
	
endmodule
