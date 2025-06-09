// Description: DE1 SoC top-level module for playing joyride jetpack (TM)
// Inputs: CLOCK_50, KEY, SW
// Outputs: VGA signals, HEX displays, LEDR
// Parameter which_clock: Selects which divided clock to use for the game logic
module DE1_SoC #(parameter which_clock = 11) (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;

	//==START OUR CODE HERE==//

	// Internal signals
	logic reset, flick1, flick2, clk, incr, game_over, on;
	logic [1:0] game_state;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;

	// Clock divider to generate multiple clock signals
	logic [31:0] divided_clocks;
	clock_divider clk_div (.clock(CLOCK_50), .divided_clocks);

	assign clk = divided_clocks[which_clock];
	assign reset = ~KEY[3];
	
	// metastability thingy
	synch sync(.clk, .reset, .in(~KEY[0]), .out(on));
	
	// video driver
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

	logic [9:0] x0, x1, score;
	logic [8:0] y0, y1;
	logic [9:0] obs1_x, obs2_x;
	logic [1:0] obs1_pos, obs2_pos;
	logic [1:0] obs1_type, obs2_type;

	// barry positions
  assign x0 = 'd20;
	assign y1 = y0 + 9'd60; // Set y1 coordinate based on y0
	assign x1 = x0 + 10'd30; // Set x1 coordinate based on x0
    
	// screen rendering
	barry #(8) b1(.clk, .*);
	obstacle #(7) obs(.type1(obs1_type), .type2(obs2_type), .*);
	animator owa_owa_meow_meow (
        .clk(CLOCK_50),
        .barry_x0(x0), .barry_x1(x1),
        .barry_y0(y0), .barry_y1(y1), .*,
  ); 

	// HEX score counter
	counter count(.on(incr), .screen(game_state == 2'b00), .rst(reset), .*);
	seg7 s0(.bcd(score % 10), .led(HEX0));
	seg7 s1(.bcd((score/10)%10), .led(HEX1));
	seg7 s2(.bcd((score/100)), .led(HEX2));
	
endmodule  // DE1_SoC

// Testbench for DE1_SoC
// Description: Simulates the DE1 SoC module for testing purposes
`timescale 1 ps / 1 ps
module DE1_SoC_testbench ();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR, SW;
	logic [3:0] KEY;
	logic CLOCK_50;
	logic [7:0] VGA_R, VGA_G, VGA_B;
	logic VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;
	
	// instantiate module
	DE1_SoC dut (.*);
	
	// create simulated clock
	parameter T = 20;
	initial begin
		CLOCK_50 <= 0;
		forever #(T/2) CLOCK_50 <= ~CLOCK_50;
	end  // clock initial
	
	// simulated inputs
	initial begin
		
		$stop();
	end  // inputs initial
	
endmodule  // DE1_SoC_testbench