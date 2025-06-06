// Description: This module generates two sets of obstacles with random gaps
// using a linear feedback shift register (LFSR) for randomness.


module obstacle (
	input logic clk, reset, 
	input logic [3:0] clkSpeed,
	output logic [2:0] gap, gap2,
	output logic [3:0] start, start2
	);
	
	logic [2:0] random, random2;
	
	lfsr l1(.clk, .reset, .out(random));
	lfsr l2(.clk, .reset, .out(random2));
	
	logic [7:0] counter = 0;
	
	always_ff @(posedge clk) 
		if (reset) begin
			start <= 4'b0;
			start2 <= 8;
			gap <= 3'b0;
			gap2 <= 3'b101;
		end else if (counter == (8'b11111111 - {clkSpeed, 4'b0})) begin
			if (start == 15) gap <= random;
			if (start2 == 15) gap2 <= random2;
			
			
			start <= start + 1'b1;
			start2 <= start2 + 1'b1;
			counter <= 8'b0;
		end else begin
			start <= start;
			start2 <= start2;
			counter <= counter+1'b1;
		end
endmodule

module obstacle_tb ();
	logic clk, reset;
	logic [2:0] gap, gap2;
	logic [3:0] start, start2, clkSpeed;
	
	obstacle dut(.*);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	
	
	initial begin
		reset = 1'b1; gap = 3'b000; gap2 = 3'b000; 
		clkSpeed = 4'b0000; @(posedge clk);
		reset = 1'b0; @(posedge clk);
		
		// slow obstacle movement
		for (int i = 0; i < 256 * 30; i++) begin
			@(posedge clk);
		end
		
		clkSpeed = 4'b1111;
		// fast obstacle movement
		for (int i = 0; i < 256 * 30; i++) begin
			@(posedge clk);
		end
	$stop;
	end
endmodule