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

    // State definitions
    enum logic {s_barry, done} ps, ns;

    // Status signals (really awful sorry)
    logic inside_barry, inside_jetpack, inside_torso, inside_head, inside_fire,
          inside_obs1, inside_obs2, dead_obs1, dead_obs2;
    assign inside_barry = inside_jetpack | inside_torso | inside_head;

    assign game_over = dead_obs1 | dead_obs2;

    assign inside_jetpack = 
        x >= barry_x0 & x <= barry_x0 +'d10 &
        y >= barry_y0 + 'd15 & y <= barry_y0+ 'd45 &
        (barry_y1 - 'd15 - y) * 'd10 <= (x - barry_x0) * 'd30;
    
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
                obs1_x0 = 'X; 
                obs1_x1 = 'X; 
                obs1_y0 = 'X; 
                obs1_y1 = 'X; 
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
                obs2_x0 = 'X; 
                obs2_x1 = 'X; 
                obs2_y0 = 'X; 
                obs2_y1 = 'X; 
            end
        endcase
    end

    // collision detection with obstacles
   assign dead_obs1 = inside_obs1 & inside_barry;
   assign dead_obs2 = inside_obs2 & inside_barry;

    // State transition logic
    always_ff @(posedge clk) begin
      if (reset) begin
        ps <= s_barry;
      end
      else begin
        ps <= ns;
      end
    end

    // Next state logic
    always_comb
       case (ps)
           s_barry:   ns = game_over ? done : s_barry;
           done:      ns = done;
       endcase

    // Combinational logic for state transitions and output
    always_comb begin
        r = 8'hf0; g = 8'hf0; b = 8'hf0;
        case(ps)
            s_barry: begin
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
           done: begin
               if (inside_barry) begin
                   r = 8'h00; g = 8'h00; b = 8'hff; // blue screen
               end
           end
        endcase
    end
endmodule  // animator

  