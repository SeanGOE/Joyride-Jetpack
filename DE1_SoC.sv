// Description: DE1 SoC top-level module for playing joyride jetpack (TM)
// Inputs: CLOCK_50, KEY, SW
// Outputs: VGA signals, HEX displays, LEDR
// Dependencies: clock_divider, barry, animator, video_driver
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

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;

	logic [31:0] divided_clocks;
	clock_divider clk_div (.clock(CLOCK_50), .divided_clocks);

	logic clk;
	assign clk = divided_clocks[which_clock];
	
	assign reset = ~KEY[3];
	logic game_over;
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;

    logic [9:0] x0, x1;
    logic [8:0] y0, y1;

    assign x0 = 'd20;
	assign y1 = y0 + 9'd10; // Set y1 coordinate based on y0
	assign x1 = x0 + 10'd10; // Set x1 coordinate based on x0
    
    barry #(8) b1(.clk, .in(~KEY[0]), .*);
    
	animator owa_owa_meow_meow (
        .clk(CLOCK_50), .reset,
        .x, .x0, .x1,
        .y, .y0, .y1,
        .r, .g, .b, 
        .game_over
    ); 
	
endmodule  // DE1_SoC


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