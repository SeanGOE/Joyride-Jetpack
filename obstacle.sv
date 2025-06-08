// Description: This module generates two sets of obstacles with random gaps
// using a linear feedback shift register (LFSR) for randomness.

module obstacle #(parameter N = 10) (
	input logic clk, reset, 
	output logic [9:0] obs1_x, obs2_x,
	output logic [1:0] obs1_pos, obs2_pos,
	output logic [1:0] type1, type2,
	output logic flick1, flick2
	);
	
	logic [2:0] random, random2;
	logic [2:0] ypos1, ypos2;
	
	lfsr #(3) t1 (.clk, .reset, .out(ypos1));
	lfsr #(3) t2 (.clk, .reset, .out(ypos2));

	lfsr #(3) y1 (.clk, .reset, .out(random));
	lfsr #(3) y2 (.clk, .reset, .out(random2));
	
	logic [N-1:0] counter = 0;
	
	always_ff @(posedge clk) 
		if (reset) begin
			obs1_x <= 10'd740;
			obs2_x <= 10'd380;
			obs1_pos <= 'd0;
			obs2_pos <= 'd1;
			type1 <= 2'b00;
			type2 <= 2'b10;
			flick1 <= 1'b0;
			flick2 <= 1'b1;
		end else if (counter == ('1)) begin
			if (obs1_x == '0) begin
				obs1_pos <= ypos1[1:0];
				type1 <= random[1:0];
				obs1_x <= 10'd740; // Reset position after reaching the left edge
			end 
			else begin
				obs1_x <= obs1_x - 1'b1; // Move obstacle 1 left
			end
			if (obs2_x == '0) begin
				obs2_pos <= ypos2[1:0];
				type2 <= random2[1:0];
				obs2_x <= 10'd740; // Reset position after reaching the left edge
			end
			else begin
				obs2_x <= obs2_x - 1'b1; // Move obstacle 2 left
			end

			// Toggle flicker states
			flick1 <= ~flick1;
			flick2 <= ~flick2;
			counter <= 'b0;
		end else begin
			obs1_x <= obs1_x;
			obs2_x <= obs2_x;
			counter <= counter+1'b1;
		end
endmodule

module obstacle_tb ();
	logic clk, reset;
	logic [9:0] obs1_x, obs2_x;
	logic [1:0] obs1_pos, obs2_pos;
	logic [1:0] type1, type2;
	logic flick1, flick2;
	
	obstacle #(2) dut(.*);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	
	
	initial begin
		reset <= 1'b1; @(posedge clk);
		reset = 1'b0; @(posedge clk);
		
		// slow obstacle movement
		for (int i = 0; i < 16000; i++) begin
			@(posedge clk);
		end
	$stop;
	end
endmodule