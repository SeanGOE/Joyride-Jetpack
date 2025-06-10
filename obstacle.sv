// Description: This module generates two sets of obstacles with random gaps
// using a linear feedback shift register (LFSR) for randomness.
// Input: clk, reset
// Output: obs1_x, obs2_x (obstacle positions), obs1_pos, obs2_pos (obstacle vertical positions),
// 				 type1, type2 (obstacle types), flick1, flick2 (flicker states)
// Parameter N: Number of bits for the counter (default 10)
module obstacle #(parameter N = 10) (
	input logic clk, reset, 
	input logic [1:0] game_state,
	output logic [9:0] obs1_x, obs2_x,
	output logic [1:0] obs1_pos, obs2_pos,
	output logic [1:0] type1, type2,
	output logic flick1, flick2, incr
	);
	
	logic [2:0] random, random2;
	logic [1:0] ypos1, ypos2;
	logic [6:0] incr_bus;
	assign incr = incr_bus[6];

	// instatiate LFSRs for generating random numbers
	lfsr #(2) t1 (.clk, .reset, .out(ypos1));
	lfsr #(2) t2 (.clk, .reset, .out(ypos2));

	lfsr #(3) y1 (.clk, .reset, .out(random));
	lfsr #(3) y2 (.clk, .reset, .out(random2));
	
	logic [N-1:0] counter;
	
	// FSM-like behavior to control obstacle movement
	always_ff @(posedge clk) 
		if (reset | game_state != 2'b01) begin
			obs1_x <= 10'd740;
			obs2_x <= 10'd380;
			obs1_pos <= 'd0;
			obs2_pos <= 'd1;
			type1 <= 2'b00;
			type2 <= 2'b10;
			flick1 <= 1'b0;
			flick2 <= 1'b1;
			incr_bus <= 'b0; // Reset increment bus
			counter <= 'b0; // Reset counter
		end else if (counter == ('1)) begin
			if (obs1_x <= '0) begin
				obs1_pos <= ypos1;
				type1 <= random[1:0];
				obs1_x <= 10'd740; // Reset position after reaching the left edge
			end 
			else begin
				obs1_x <= obs1_x - 1'b1; // Move obstacle 1 left
			end
			if (obs2_x <= '0) begin
				obs2_pos <= ypos2;
				type2 <= random2[1:0];
				obs2_x <= 10'd740; // Reset position after reaching the left edge
			end
			else begin
				obs2_x <= obs2_x - 1'b1; // Move obstacle 2 left
			end

			incr_bus <= incr_bus+ 1'b1; // Increment flag for other logic

			// Toggle flicker states
			flick1 <= ~flick1;
			flick2 <= ~flick2;
			counter <= 'b0;
		end else begin
			obs1_x <= obs1_x;
			obs2_x <= obs2_x;
			obs1_pos <= obs1_pos;
			obs2_pos <= obs2_pos;
			type1 <= type1;
			type2 <= type2;
			flick1 <= flick1;
			flick2 <= flick2;
			incr_bus <= incr_bus;
			counter <= counter+1'b1;
		end
endmodule  // obstacle

// Testbench for the obstacle module
// This testbench initializes the obstacle module and simulates its behavior
// by generating clock signals and resetting the module.
module obstacle_tb ();
	logic clk, reset, incr;
	logic [9:0] obs1_x, obs2_x;
	logic [1:0] obs1_pos, obs2_pos, game_state;
	logic [1:0] type1, type2;
	logic flick1, flick2;
	
	obstacle #(2) dut(.*);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		reset <= 1'b1; game_state <= 2'b00; @(posedge clk); 
		reset = 1'b0; @(posedge clk);
		repeat(2) @(posedge clk);
		
		game_state = 2'b01; @(posedge clk);
		
		// slow obstacle movement
		for (int i = 0; i < 16000; i++) begin
			@(posedge clk);
		end
	$stop;
	end
endmodule  // obstacle_tb