`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 08:12:54 AM
// Design Name: 
// Module Name: TopLevelModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top-level module for a game integrating keyboard inputs and VGA output.
// 
// Dependencies: Requires keyboard, VGA sync, and control modules.
// 
//////////////////////////////////////////////////////////////////////////////////

module TopLevelModule(
    input clk,                    // System clock
    input reset,                  // Reset input
    input wire ps2d, ps2c,        // PS/2 keyboard data and clock
    output h_sync,                // Horizontal sync for VGA
    output v_sync,                // Vertical sync for VGA
    output [3:0] red,             // Red color output
    output [3:0] green,           // Green color output
    output [3:0] blue             // Blue color output
);

    // Internal wires
    wire clk_d;                    // Divided clock for lower frequency operations
    wire [9:0] h_count;            // Horizontal pixel counter
    wire [9:0] v_count;            // Vertical pixel counter
    wire [9:0] pixel_x;            // Current pixel x-coordinate
    wire [9:0] pixel_y;            // Current pixel y-coordinate
    wire video_on;                 // VGA video enable signal
    wire trig_v;                   // Vertical trigger signal for VGA sync
reg [3:0] red_reg, green_reg, blue_reg; // Registers for RGB values

    // Keyboard signals
    wire SPACE, UP, DOWN, LEFT, RIGHT, PAUSE, RESET, SPECIAL;   
    wire key_state, key_release;   // State and release signals from the keyboard module

    // Game object signals
    wire alien_pixel_on;           // Alien pixel rendering signal
    wire tank_pixel_on;            // Tank pixel rendering signal
    wire bullet_pixel_on;          // Bullet pixel rendering signal
    wire [9:0] tank_x;             // Tank position
    wire bullet_active;            // Bullet activity state
    
    
    // Score register (initialize to 0)
    reg [7:0] game_score = 8'd0;

    // Instantiate the keyboard module
    keyboard_1 k1 (
        .clk(clk), 
        .reset(reset), 
        .ps2d(ps2d), 
        .ps2c(ps2c), 
        .SPACE(SPACE), 
        .UP(UP), 
        .DOWN(DOWN), 
        .LEFT(LEFT), 
        .RIGHT(RIGHT), 
        .PAUSE(PAUSE), 
        .RESET(RESET), 
        .SPECIAL(SPECIAL), 
        .state(key_state), 
        .key_release(key_release)
    );
    
    // Clock divider
    clk_div clkDivider (
        .clk(clk),
        .clk_d(clk_d)
    );
    
    // Horizontal counter
    h_counter horizontalCounter (
        .clk(clk_d),
        .h_count(h_count),
        .trig_v(trig_v)
    );
    
    // Vertical counter
    v_counter verticalCounter (
        .clk(clk_d),
        .enable_v(trig_v),
        .v_count(v_count)
    );
    
    // VGA sync module
    vga_sync vgaSync (
        .h_count(h_count),
        .v_count(v_count),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .video_on(video_on),
        .x_loc(pixel_x),
        .y_loc(pixel_y)
    );
    
    // Alien control module
    aliens_movement alienCtrl (
        .clk(clk_d),
        .reset(reset),
        .center_switch(PAUSE),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_on(alien_pixel_on)
    );
    
    // Tank control module
    tank_control tankCtrl (
        .clk(clk_d),
        .reset(reset),
        .left_switch(LEFT),
        .right_switch(RIGHT),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_on(tank_pixel_on),
        .tank_x_pos(tank_x)
    );
    
    // Bullet control module
    bullet_movement bulletCtrl (
        .clk(clk_d),
        .reset(reset),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .up_switch(UP),          // Corrected: UP is used for shooting
        .center_switch(PAUSE),
        .tank_x(tank_x),
        .pixel_on(bullet_pixel_on),
        .bullet_active(bullet_active)
    );
    
    // Game objects rendering
    always @(posedge clk_d) begin
        if (~video_on) begin
            red_reg <= 4'h0;
            green_reg <= 4'h0;
            blue_reg <= 4'h0;
        end
        else begin
            if (alien_pixel_on) begin
                // Pink color for aliens
                red_reg <= 4'hF;
                green_reg <= 4'h8;
                blue_reg <= 4'hF;
            end
            else if (tank_pixel_on) begin
                // Dark blue color for tank
                red_reg <= 4'h0;
                green_reg <= 4'h0;
                blue_reg <= 4'hA;
            end
            else if (bullet_pixel_on) begin
                // White color for bullets
                red_reg <= 4'hF;
                green_reg <= 4'hF;
                blue_reg <= 4'hF;
            end
            else begin
                // Black background
                red_reg <= 4'h0;
                green_reg <= 4'h0;
                blue_reg <= 4'h0;
            end
        end
    end
    
    // Assign RGB outputs
    assign red = red_reg;
    assign green = green_reg;
    assign blue = blue_reg;
    
endmodule
