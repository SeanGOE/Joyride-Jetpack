// Description: A simple game state machine in SystemVerilog
// This module manages the game states: start, playing, and game over.
// Input: clk, reset, game_over, start
// Output: game_state (2-bit signal representing the current state)
module game_state (
    input logic clk, reset, game_over, start,
    output logic [1:0] game_state // 00: start, 01: playing, 10: game over
    );

    enum logic [1:0] {START, PLAYING, GAME_OVER} ps, ns;
    
    logic out;
    pulse p(.clk, .reset, .in(start), .out);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            ps <= START;
        else
            ps <= ns;
    end

    always_comb begin
        case (ps)
            START: ns = out ? PLAYING : START;
            PLAYING: ns = game_over ? GAME_OVER : PLAYING;
            GAME_OVER: ns = out ? START : GAME_OVER; // or some other logic to restart
            default: ns = START;
        endcase
    end

    always_comb begin
        case (ps)
            START: game_state = 2'b00;
            PLAYING: game_state = 2'b01;
            GAME_OVER: game_state = 2'b10;
            default: game_state = 2'b00;
        endcase
    end

endmodule  // game_state

// Testbench for the game_state module
module game_state_tb();
    logic clk, reset, game_over, start;
    logic [1:0] game_state;

    // instantiate the clock
    parameter CLK_PERIOD = 100; // Clock period in time units
    initial begin
        clk <= 0;
        forever #(CLK_PERIOD/2) clk <= ~clk; // Clock period of 10 time units
    end

    // Instantiate the barry module
    game_state dut (.*);

    initial begin
        @(posedge clk);  reset <= 1;
        @(posedge clk);  reset <= 0; game_over <= 0; start <= 0;
		  
		  repeat (5) @(posedge clk);

        @(posedge clk);  start <= 1;
		  repeat (5) @(posedge clk);
		  
		  @(posedge clk);  game_over <= 1;
		  repeat (5) @(posedge clk);
		  
		  
    
    $stop;  // pause the simulation
    end
endmodule
