// Description: A simple animator module that changes color based on coordinates
// Input: x, y coordinates and their bounds (x0, x1, y0, y1)
// Output: RGB color values and game over signal
module animator(
    input logic clk, reset, on,
    input logic [9:0] x, barry_x0, barry_x1,
//    input logic [9:0] obs1_x0, obs1_x1, obs2_x0, obs2_x1,
//    input logic [8:0] obs2_y0, obs2_y1, obs1_y0, obs1_y1,
    input logic [8:0] y, barry_y0, barry_y1,
    output logic [7:0] r, g, b,
    output logic game_over
    );

    // State definitions
    enum logic [1:0] {s_barry, s_obs1, s_obs2, done} ps, ns;

    // Status signals
    logic inside_xy;
    // assign inside_xy = x <= x1 & 
    //                    x >= x0 &
    //                    y <= y1 & 
    //                    y >= y0;
//    assign game_over = dead_obs1 | dead_obs2;
    logic inside_jetpack, inside_torso, inside_head, inside_fire;
    assign inside_jetpack = 
        x >= barry_x0 & x <= barry_x0 +'d10 &
        y >= barry_y0 + 'd15 & y <= barry_y0+ 'd45 &
        (barry_y1 - 'd15 - y) * 'd10 <= (x - barry_x0) * 'd30;
        // (y - barry_y0 + 'd15) >= (x - barry_x0) * 'd3;
        // x <= barry_x1 - (2 * (barry_x1 - barry_x0)) / 3 &&
        // x >= barry_x0 &&
        // y >= barry_y0 + ((barry_y1 - (barry_y0 / 2)) / (barry_x1 - barry_x0)) &&
        // y <= barry_y0 + (1 * (barry_y1 - barry_y0)) / 4;
    
    assign inside_fire = 
        x >= barry_x0 & x <= barry_x0 + 'd10 & 
        y >= barry_y0+'d45 & y <= barry_y1 &
        (barry_y1 - y) * 'd10 >= (x-barry_x0) * 'd15;
    
    assign inside_torso = 
        x <= barry_x1 &
        x >= barry_x0 + 'd10 &
        y <= barry_y1 &
        y >= barry_y0 + 'd15;

    assign inside_head = 
        x <= barry_x1 &
        x >= barry_x0 + 'd10 &
        y <= barry_y0 + 'd15 &
        y >= barry_y0;

    // Check if the point (x, y) is inside the two triangular obstacles
    // inspiration taken from https://stackoverflow.com/questions/2049582/how-to-determine-if-a-point-is-in-a-2d-triangle
    // logic signed [1:0] d11, d12, d13, d21, d22, d23;
    // logic inside_obs1, inside_obs2;

    // assign d11 = (x - obs1_x1) * (obs1_y0 - obs1_y1) - (obs1_x0 - obs1_x1) * (y - obs1_y1);
    // assign d12 = (x - obs1_x2) * (obs1_y1 - obs1_y2) - (obs1_x1 - obs1_x2) * (y - obs1_y2);
    // assign d13 = (x - obs1_x0) * (obs1_y2 - obs1_y0) - (obs1_x2 - obs1_x0) * (y - obs1_y0);

    // assign d21 = (x - obs2_x1) * (obs2_y0 - obs2_y1) - (obs2_x0 - obs2_x1) * (y - obs2_y1);
    // assign d22 = (x - obs2_x2) * (obs2_y1 - obs2_y2) - (obs2_x1 - obs2_x2) * (y - obs2_y2);
    // assign d23 = (x - obs2_x0) * (obs2_y2 - obs2_y0) - (obs2_x2 - obs2_x0) * (y - obs2_y0);
    // assign inside_obs1 =    x <= obs1_x1 & x >= obs1_x0 & y <= obs1_y1 & y >= obs1_y0 | (is_triangle &
    //                         ((d11 < 0) & (d12 < 0) & (d13 < 0)) | ((d11 > 0) & (d12 > 0) & (d13 > 0)));
    // assign inside_obs2 =    x <= obs2_x1 & x >= obs2_x0 & y <= obs2_y1 & y >= obs2_y0 | (is_triangle &
    //                         ((d21 < 0) & (d22 < 0) & (d23 < 0)) | ((d21 > 0) & (d22 > 0) & (d23 > 0)));
//     float sign (fPoint p1, fPoint p2, fPoint p3)
// {
//     return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
// }

// bool PointInTriangle (fPoint pt, fPoint v1, fPoint v2, fPoint v3)
// {
//     float d1, d2, d3;
//     bool has_neg, has_pos;

//     d1 = sign(pt, v1, v2);
//     d2 = sign(pt, v2, v3);
//     d3 = sign(pt, v3, v1);

//     has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
//     has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);

//     return !(has_neg && has_pos);
// }

    

    // collision detection with obstacles
//    logic dead_obs1, dead_obs2;
//    assign dead_obs1 = inside_obs1 & inside_xy;
//    assign dead_obs2 = inside_obs2 & inside_xy;

    // State transition logic
    always_ff @(posedge clk) begin
      if (reset) begin
        ps <= s_barry;
        ns <= s_barry;
      end
      else begin
        ps <= ns;
      end
    end

    // Next state logic
//    always_comb
//        case (ps)
//            s_barry:   ns = s_obs1;
//            s_obs1:    ns = dead_obs1 ? done : s_obs2;
//            s_obs2:    ns = dead_obs2 ? done : s_barry;
//            done:      ns = done;
//        endcase

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
            end
//            s_obs1: begin
//                if (inside_obs1) begin
//                    if (flick1) begin
//                        r = 8'hff; g = 8'h80; b = 0; // orange
//                    end else begin
//                        r = 8'hff; g = 8'hff; b = 0; // yellow
//                    end
//                end
//            end
//            s_obs2: begin
//                if (inside_obs2) begin
//                    if (flick2) begin
//                        r = 8'hff; g = 8'h80; b = 0; // orange
//                    end else begin
//                        r = 8'hff; g = 8'hff; b = 0; // yellow
//                    end
//                end
//            end
//            done: begin
//                if (inside_xy) begin
//                    r = 8'h00; g = 8'h00; b = 8'hff; // blue dead
//                end
//            end
//            default: begin
//            end
        endcase
    end
endmodule  // animator

  