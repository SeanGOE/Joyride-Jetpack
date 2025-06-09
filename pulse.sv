// Simple FSM to recognize rising edges.
//
// Our FSM code has four parts:
// 1. variable, net, and state declarations/definitions
// 2. Next State Logic (always_comb)
// 3. Output Logic (assign or always_comb)
// 3. Sequential Logic (always_ff)
module pulse (
  input  logic clk, reset, in,
  output logic out 
  );

  enum logic {ZERO, ONE} ps, ns;

  assign ns = in ? ONE : ZERO;

  always_ff @(posedge clk)
    ps <= reset ? ZERO : ns;

  assign out = (ps == ZERO) & in;

endmodule  // pulse

// Testbench for pulse module
module pulse_tb ();
  logic clk, reset;
  logic in;
  logic out;

  pulse dut (.clk, .reset, .in, .out);

  // Set up the clock
  parameter CLOCK_PERIOD=100;
  initial begin
    clk <= 0;
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
  end

  // Set up the inputs to the design. Each line is a clock cycle.
  initial begin
    // Defining ALL input signals at t = 0 will avoid red (undefined) signals
    // in your simulation.
    reset <= 1; in <= 1'b0; 	@(posedge clk);
										@(posedge clk);
					 in <= 1'b1;	@(posedge clk);
										@(posedge clk);
	 
    reset <= 0; in <= 1'b0; 	@(posedge clk);
										@(posedge clk);
					 in <= 1'b1; 	@(posedge clk);
										@(posedge clk);
					 in <= 1'b0; 	@(posedge clk);
										@(posedge clk);
										
    $stop;  // pause the simulation
  end
endmodule  // pulse_tb