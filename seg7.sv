// module for the HEX displays on DE1 board
// input: bcd (represents the number in hex)
// output: led, 7-segment display output
module seg7 (
  input  logic [4:0] bcd,
  output logic [6:0] led
  );

  always_comb
    case (bcd)
      //          Light: 6543210
      4'b0000: led = ~7'b0111111; // 0
      4'b0001: led = ~7'b0000110; // 1
      4'b0010: led = ~7'b1011011; // 2
      4'b0011: led = ~7'b1001111; // 3
      4'b0100: led = ~7'b1100110; // 4
      4'b0101: led = ~7'b1101101; // 5
      4'b0110: led = ~7'b1111101; // 6
      4'b0111: led = ~7'b0000111; // 7
      4'b1000: led = ~7'b1111111; // 8
      4'b1001: led = ~7'b1101111; // 9
      default: led = 7'bX;
    endcase

endmodule  // seg7

// Testbench for the seg7 module
// This testbench will cycle through all BCD values from 0 to 9
module seg7_tb ();
	logic [4:0] bcd;
	logic [6:0] led;
	
	seg7 dut (.*);
	
	integer i;
	initial begin
	
		for(i = 0; i < 8; i++) begin
			bcd = i; #10;
		end
		$stop;
	end
endmodule  // seg7_tb
