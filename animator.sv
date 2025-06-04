// Description: A simple animator module that changes color based on coordinates
// Input: x, y coordinates and their bounds (x0, x1, y0, y1)
// Output: RGB color values and game over signal
module animator(
    input logic clk, reset,
    input logic [9:0] x, x0, x1,
    input logic [8:0] y, y0, y1,
    output logic [7:0] r, g, b,
    output logic game_over
    );

    // State definitions
    enum logic {s_repeat, done} ps, ns;

    // Status signals
    logic inside_xy;
    assign inside_xy = x <= x1 & 
                       x >= x0 &
                       y <= y1 & 
                       y >= y0;
    assign game_over = 0;

    // State transition logic
    always_ff @(posedge clk) begin
      if (reset) begin
        ps <= s_repeat;
      end
      else begin
        ps <= ns;
      end
    end

    // Next state logic
    always_comb
        case(ps)
            s_repeat:   ns = done;
            done:       ns = s_repeat;
        endcase

    // Combinational logic for state transitions and output
    always_comb begin
        r = 8'h00; g = 8'h00; b = 8'h00;
        case(ps)
            s_repeat: begin
                if (inside_xy) begin
                    r = 8'hff;
                end
            end
            default: begin
            end
        endcase
    end
endmodule  // animator

  