// Description: A simple animator module that changes color based on coordinates
// Input: 
//   - x, y coordinates and barry bounds (x0, x1, y0, y1)
//   - Obstacle coordinates, types, and pos for two obstacles
// Output: RGB color values and game over signal
module animator(
    input logic clk, reset, on, flick1, flick2,
    input logic [9:0] x, barry_x0, barry_x1,
    input logic [8:0] y, barry_y0, barry_y1,
    input logic [1:0] obs1_type, obs2_type, obs1_pos, obs2_pos,
    input logic [9:0] obs1_x, obs2_x,
    output logic [7:0] r, g, b,
    output logic [1:0] game_state, // 00: start, 01: playing, 10: game over
    output logic game_over
    );

    // instantiate the rom for obstacle coordinates
    // The roms are assumed to be defined elsewhere, providing the x and y offsets
    // for the obstacles based on their type.
    logic [9:0] obs1_x0, obs2_x0, obs1_x1, obs2_x1;
    logic [8:0] obs1_y0, obs2_y0, obs1_y1, obs2_y1;
    logic [9:0] add_x0_1, add_x0_2, add_x1_1, add_x1_2;
    logic [8:0] add_y0_1, add_y0_2, add_y1_1, add_y1_2;
    
    rom_x0 x0_1(.address(obs1_type), .q(add_x0_1), .clock(clk));
    rom_x0 x0_2(.address(obs2_type), .q(add_x0_2), .clock(clk));
    rom_y0 y0_1(.address(obs1_type), .q(add_y0_1), .clock(clk));
    rom_y0 y0_2(.address(obs2_type), .q(add_y0_2), .clock(clk));

    rom_x1 x1_1(.address(obs1_type), .q(add_x1_1), .clock(clk));
    rom_x1 x1_2(.address(obs2_type), .q(add_x1_2), .clock(clk));
    rom_y1 y1_1(.address(obs1_type), .q(add_y1_1), .clock(clk));
    rom_y1 y1_2(.address(obs2_type), .q(add_y1_2), .clock(clk));

    // Calculate the coordinates of the obstacles based on type and position
    always_comb begin
        obs1_x0 = obs1_x - 'd100 + add_x0_1;
        obs2_x0 = obs2_x - 'd100 + add_x0_2;
        obs1_x1 = obs1_x - 'd100 + add_x1_1;
        obs2_x1 = obs2_x - 'd100 + add_x1_2;

        // Calculate the y-coordinates based on the position type
        case (obs1_pos)
            2'b00: begin // top
                obs1_y0 = add_y0_1;
                obs1_y1 = add_y1_1;
            end
            2'b01: begin // middle
                obs1_y0 = 'd140 + add_y0_1;
                obs1_y1 = 'd140 + add_y1_1;
            end
            2'b10: begin // bottom
                obs1_y0 = 'd379 + add_y0_1;
                obs1_y1 = 'd379 + add_y1_1;
            end
            default: begin // should never happen
                obs1_y0 = 'X;
                obs1_y1 = 'X;
            end
        endcase

        case (obs2_pos)
            2'b00: begin // top
                obs2_y0 = add_y0_2;
                obs2_y1 = add_y1_2;
            end
            2'b01: begin // middle
                obs2_y0 = 'd140 + add_y0_2;
                obs2_y1 = 'd140 + add_y1_2;
            end
            2'b10: begin // bottom
                obs2_y0 = 'd379 + add_y0_2;
                obs2_y1 = 'd379 + add_y1_2;
            end
            2'b11: begin // should never happen
                obs2_y0 = 'X;
                obs2_y1 = 'X;
            end
        endcase

        // obs1_y0 = add_y0_1;
        // obs1_y1 = add_y0_1 + add_y1_1;
        // obs2_y0 = add_y0_2;
        // obs2_y1 = add_y0_2 + add_y1_2;
    end

    // Status signals (really awful sorry)
    logic inside_barry, inside_jetpack, inside_torso, inside_head, inside_fire,
          inside_obs1, inside_obs2, dead_obs1, dead_obs2;
    assign inside_barry = inside_jetpack | inside_torso | inside_head;

    assign game_over = dead_obs1 | dead_obs2;

    // assign inside_jetpack = 
    //     x >= barry_x0 & x <= barry_x0 +'d10 &
    //     y >= barry_y0 + 'd15 & y <= barry_y0+ 'd45 &
    //     (barry_y1 - 'd15 - y) * 'd10 <= (x - barry_x0) * 'd30;
    

    // tspmo icl
    assign inside_jetpack = 
        x >= barry_x0 & x <= barry_x0 +'d10 &
        y <= barry_y0 + 'd45 & 
         y >= (x - barry_x0) * (x - (barry_x0 + 10)) + (barry_y0 + 10) - ((barry_x0 + 5 - barry_x0) * (barry_x0 + 5 - (barry_x0 + 10)));
        
    
    assign inside_fire = 
        x >= barry_x0 & x <= barry_x0 + 'd10 & 
        y >= barry_y0+'d45 & y <= barry_y1 &
        (barry_y1 - y) * 'd10 >= (x-barry_x0) * 'd15 &
        'd10 * (y - (barry_y1 - 'd15)) <= 'd15 * (x - barry_x0);
    
    assign inside_torso = 
        x <= barry_x1 & x >= barry_x0 + 'd10 &
        y <= barry_y1 & y >= barry_y0 + 'd15;

    assign inside_head = 
        x <= barry_x1 & x >= barry_x0 + 'd10 &
        y <= barry_y0 + 'd15 & y >= barry_y0;

    always_comb begin
        case (obs1_type) 
            2'b00: begin // flat
                inside_obs1 = obs1_x1 > 'd100 ? 
                    (x <= obs1_x1 & x >= obs1_x0) &
                    y <= obs1_y1 & y >= obs1_y0 :
                    (x <= obs1_x1) & 
                    y <= obs1_y1 & y >= obs1_y0;
            end
            2'b01: begin // tall
                inside_obs1 = obs1_x1 > 'd50 ? 
                    (x <= obs1_x1 & x >= obs1_x0) &
                    y <= obs1_y1 & y >= obs1_y0 :
                    (x <= obs1_x1) & 
                    y <= obs1_y1 & y >= obs1_y0;
            end
            2'b10: begin // falling triangle
                inside_obs1 = obs1_x1 > 'd100 ? 
                    (x <= obs1_x1 & x >= obs1_x0) &
                    y <= obs1_y1 & y >= obs1_y0 & 
                    (y - (obs1_y0)) <= (x - obs1_x0) :
                    (x <= obs1_x1) &
                    y <= obs1_y1 & y >= obs1_y0 &  
                    (y - (obs1_y0)) <= (x - obs1_x0);
            end
            2'b11: begin // rising triangle
                inside_obs1 = obs1_x1 > 'd100 ? 
                    (x >= obs1_x0 & x <= obs1_x1) &
                    y <= obs1_y1 & 
                    y + (x - obs1_x0) >= obs1_y1 :
                    (x <= obs1_x1) &
                    y <= obs1_y1 & 
                    y + (x - obs1_x0) >= obs1_y1;
            end
            default: begin // should never happen
                inside_obs1 = 'X;  
            end
        endcase

        case (obs2_type) 
            2'b00: begin // flat
                inside_obs2 = obs2_x1 > 'd100 ? 
                    (x <= obs2_x1 & x >= obs2_x0) &
                    y <= obs2_y1 & y >= obs2_y0 :
                    (x <= obs2_x1) & 
                    y <= obs2_y1 & y >= obs2_y0;
            end
            2'b01: begin // tall
                inside_obs2 = obs2_x1 > 'd50 ? 
                    (x <= obs2_x1 & x >= obs2_x0) &
                    y <= obs2_y1 & y >= obs2_y0 :
                    (x <= obs2_x1) & 
                    y <= obs2_y1 & y >= obs2_y0;
            end
            2'b10: begin // falling triangle
                inside_obs2 = obs2_x1 > 'd100 ? 
                    (x <= obs2_x1 & x >= obs2_x0) &
                    y <= obs2_y1 & y >= obs2_y0 & 
                    (y - (obs2_y0)) <= (x - obs2_x0) :
                    (x <= obs2_x1) &
                    y <= obs2_y1 & y >= obs2_y0 &  
                    (y - (obs2_y0)) <= (x - obs2_x0);
            end
            2'b11: begin // rising triangle
                inside_obs2 = obs2_x1 > 'd100 ? 
                    (x >= obs2_x0 & x <= obs2_x1) &
                    y <= obs2_y1 & 
                    y + (x - obs2_x0) >= obs2_y1 :
                    (x <= obs2_x1) &
                    y <= obs2_y1 & 
                    y + (x - obs2_x0) >= obs2_y1;
            end
            default: begin // should never happen
                inside_obs2 = 'X; 
            end
        endcase
    end

    // collision detection with obstacles
    assign dead_obs1 = inside_obs1 & inside_barry;
    assign dead_obs2 = inside_obs2 & inside_barry;
    game_state gs(.clk, .reset, .game_over, .start(on), .game_state);

    // Combinational logic for state transitions and output
    always_comb begin
        r = 8'hf0; g = 8'hf0; b = 8'hf0;
        case(game_state)
            2'b00: begin
                if (inside_obs1) begin
                   if (flick1) begin
                       r = 8'hff; g = 8'h80; b = 0; // orange
                   end else begin
                       r = 8'hff; g = 8'hff; b = 0; // yellow
                   end
               end
               else if (inside_obs2) begin
                   if (flick2) begin
                       r = 8'hff; g = 8'h80; b = 0; // orange
                   end else begin
                       r = 8'hff; g = 8'hff; b = 0; // yellow
                   end
               end 
               else 
                // if (inside_barry) begin
                    r = 8'h00; g = 8'hff; b = 8'h00; // green screen
                // end
            end
            2'b01: begin
                if (inside_jetpack) begin
                    r = 8'd20; g = 8'd20; b = 8'd20; 
                end 
                if (inside_torso) begin
                    r = 8'd10; g = 8'd10; b = 8'd128; 
                end 
                if (inside_head) begin
                    r = 8'd164; g = 8'd103; b = 8'd74; 
                end 
                if (inside_fire & on) begin
                    r = 8'hff; g = 8'h80; b = 8'h0;
                end
               if (inside_obs1) begin
                   if (flick1) begin
                       r = 8'hff; g = 8'h80; b = 0; // orange
                   end else begin
                       r = 8'hff; g = 8'hff; b = 0; // yellow
                   end
               end
               if (inside_obs2) begin
               
                   if (flick2) begin
                       r = 8'hff; g = 8'h80; b = 0; // orange
                   end else begin
                       r = 8'hff; g = 8'hff; b = 0; // yellow
                   end
               end
            end
           2'b10: begin
                if (inside_obs1) begin
                   if (flick1) begin
                       r = 8'hff; g = 8'h80; b = 0; // orange
                   end else begin
                       r = 8'hff; g = 8'hff; b = 0; // yellow
                   end
                end
                else if (inside_obs2) begin
                   if (flick2) begin
                       r = 8'hff; g = 8'h80; b = 0; // orange
                   end else begin
                       r = 8'hff; g = 8'hff; b = 0; // yellow
                   end
               end 
               else 
               // if (inside_barry) begin
                   r = 8'h00; g = 8'h00; b = 8'hff; // blue screen
               // end
           end
        endcase
    end
endmodule  // animator

// Testbench for the animator module
`timescale 1 ps / 1 ps
module animator_tb();
    logic clk, reset, on, flick1, flick2;
    logic [9:0] x, barry_x0, barry_x1;
    logic [8:0] y, barry_y0, barry_y1;
    logic [1:0] obs1_type, obs2_type, obs1_pos, obs2_pos;
    logic [9:0] obs1_x, obs2_x;
    logic [7:0] r, g, b;
    logic [1:0] game_state; // 00: start, 01: playing, 10: game over
    logic game_over;
    
    // instantiate the clock
    parameter CLK_PERIOD = 100; // Clock period in time units
    initial begin
        clk <= 0;
        forever #(CLK_PERIOD/2) clk <= ~clk; // Clock period of 10 time units
    end

    // Instantiate the animator module
    animator dut (.*);

    initial begin
        @(posedge clk);  reset <= 1;
        @(posedge clk);  reset <= 0; on <= 0;
        barry_x0 <= 10'd20; barry_x1 <= 10'd50;
        barry_y0 <= 9'd420; barry_y1 <= 9'd480;
        x <= 10'd0; y <= 9'd0; on <= 1;
		repeat (5) @(posedge clk);

        // test for barry rendering
        on <= 0; obs1_type <= 2'b00; obs2_type <= 2'b01;
		  obs1_pos <= 2'b00; obs2_pos <= 2'b01;
		  obs1_x <= 10'd740; obs2_x <= 10'd380;
		  flick1 <= 0; flick2 <= 0;
        for (int a = 0; a < 'd1; a++) begin  // barry stay still
            for (int i = 0; i < 'd480; i++) begin
                for (int j = 0; j < 'd640; j++) begin
                    @(posedge clk); x <= j; y <= i;
                end
            end
        end
		  
		  obs1_pos <= 2'b10; obs1_x <= 10'd100; @(posedge clk);
		  for (int i = 0; i < 'd480; i++) begin
				 for (int j = 0; j < 'd640; j++) begin
					  @(posedge clk); x <= j; y <= i;
				 end
			end
        
        // test game over state
		@(posedge clk); 
		  repeat (5) @(posedge clk);
    $stop;  // pause the simulation
    end
endmodule