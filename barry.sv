// This module creates a renderer of where Barry is located.
// It takes in an input signal `input` and outputs 4 points:
// - x0, y0: the top-left corner of the rectangle
// - x1, y1: the bottom-right corner of the rectangle
module barry #(parameter N = 8) (
    input logic in, clk, reset,
    output logic [8:0] y0 // 10-bit outputs for rectangle pos
    );

    logic [N-1:0] counter;
    logic [1:0] gravity;

    enum logic {UP, DOWN} ps, ns;

	always_comb
		case (ps)
			UP: 	if (in) 	ns = UP;
					else 		ns = DOWN;
			DOWN: if (in) 	ns = UP;
					else 		ns = DOWN;
	    endcase
	
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= DOWN;
			y0 <= 'd419;
			counter <= 'b0;
			gravity <= 'b0;
		end
		else if (counter == ('d255 - {gravity, 6'd0}) & ps == UP & y0 > 'd4) begin
            ps <= ns;
            counter <= 0;
            y0 <= y0 - 'd3;
            gravity <= 2'b0;
        end
		else if (counter == ('d255 - {gravity, 6'd0}) & ps == DOWN & y0 < 'd420) begin
			ps <= ns;
            counter <= 0;
			y0 <= y0 + 1'b1;
		    if (gravity < '1) gravity <= gravity + 1'b1;
		end
		else begin
			counter = counter + 1'b1;
			ps <= ns;
		end
	end
endmodule

// Testbench for the barry module
module barry_tb();
    logic in, reset, clk;
    logic [8:0] y0;

    // instantiate the clock
    parameter CLK_PERIOD = 100; // Clock period in time units
    initial begin
        clk <= 0;
        forever #(CLK_PERIOD/2) clk <= ~clk; // Clock period of 10 time units
    end

    // Instantiate the barry module
    barry #(8) dut (.*);

    initial begin
        @(posedge clk);  reset <= 1;
        @(posedge clk);  reset <= 0;

        for(int i = 0; i < 500; i++) begin
            @(posedge clk);  in <= 1;
        end
        @(posedge clk);  in <= 1;
        for(int i = 0; i < 100; i++) begin
            @(posedge clk);  in <= 0;
            @(posedge clk);  in <= 0;
        end
        for(int i = 0; i < 20; i++) begin
            @(posedge clk);  in <= 1;
        end
    
    $stop;  // pause the simulation
    end
endmodule
