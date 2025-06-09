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
