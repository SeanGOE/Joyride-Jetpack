// Description: Two flip-flop synchronizer
module synch (input logic clk, reset, in, output logic out);

  logic mid;  // output of first FF, could be named anything

  always_ff @(posedge clk)
    if (reset)
      {mid, out} <= 2'b00;
    else
      {mid, out} <= {in, mid};

endmodule  // synch

module synch_tb();
	logic clk, reset, in, out;
	
	synch dut (.*);
	
	// set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
	   forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Set up the inputs to the design. Each line is a clock cycle.
   initial begin
    // Defining ALL input signals at t = 0 will avoid red (undefined) signals
    // in your simulation.
	 @(posedge clk);  reset <= 1;     
    @(posedge clk);  reset <= 0;
	 @(posedge clk);  in <= 0; 	 
    @(posedge clk);  in <= 1;                         
    @(posedge clk);  in <= 1;           
	 @(posedge clk);                         
    @(posedge clk);  in <= 0; 	 
	 @(posedge clk); 
	 @(posedge clk);  in <= 1; 
	 @(posedge clk);  in <= 0; 
	 @(posedge clk);  in <= 1; 
	 @(posedge clk);  in <= 0; 
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 $stop;
	 
	end
endmodule