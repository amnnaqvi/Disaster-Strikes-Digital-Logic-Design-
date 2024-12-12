`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 01:16:06 PM
// Design Name: 
// Module Name: TopLevelModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
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

    // Keyboard signals
    wire SPACE, UP, DOWN, LEFT, RIGHT, PAUSE, RESET, SPECIAL;   
    wire key_state, key_release;   // State and release signals from the keyboard module

    // Game object signals
    wire alien_pixel_on;           // Alien pixel rendering signal
    wire tank_pixel_on;            // Tank pixel rendering signal
    wire bullet_pixel_on;          // Bullet pixel rendering signal
    wire [9:0] tank_x;             // Tank position
    wire bullet_active;            // Bullet activity state
    wire [9:0] bullet_x;           // Bullet x position
    wire [9:0] bullet_y;           // Bullet y position
    wire bullet_collision_confirmed; // Collision confirmation signal
    wire bullet_hit;               // Wire to track bullet hitting an alien
    
    reg [3:0] red_reg, green_reg, blue_reg; // Registers for RGB values
    
    // Game state and level signals
    wire [2:0] game_state;  
    wire [1:0] current_level;
    wire level_reset;  // handle level resets
    wire tank_hit;     // Signal to indicate tank is hit by alien
    wire all_aliens_destroyed;  // Signal to indicate all aliens are destroyed

    // Alien and level-specific signals
    wire alien_pixel_on_level1, alien_pixel_on_level2;
    wire bullet_collision_confirmed_level1, bullet_collision_confirmed_level2;
    wire tank_hit_level1, tank_hit_level2;
    
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
    
//    wire h_sync_wire; 
//    wire v_sync_wire; 
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
    
    // Score register (initialize to 0)
    reg [8:0] game_score = 9'd0;
    
    wire [3:0] thousands, hundreds, tens, ones;
    wire [6:0] a[3:0]; // Holds ASCII data for each digit
    wire d[3:0];       // Display signals for each digit
    wire score_display_on;

    // Calculate digit values from game_score
    assign thousands = (game_score / 1000) % 10;
    assign hundreds  = (game_score / 100) % 10;
    assign tens      = (game_score / 10) % 10;
    assign ones      = game_score % 10;

    // Text Generation Modules for Score Digits
    textGeneration score_thousands (
        .clk(clk), 
        .reset(reset), 
        .asciiData(a[0]), 
        .ascii_In(thousands + 7'h30), 
        .x(pixel_x), 
        .y(pixel_y), 
        .displayContents(d[0]), 
        .x_desired(10'd80),  
        .y_desired(10'd80)   
    );

    textGeneration score_hundreds (
        .clk(clk), 
        .reset(reset), 
        .asciiData(a[1]), 
        .ascii_In(hundreds + 7'h30), 
        .x(pixel_x), 
        .y(pixel_y), 
        .displayContents(d[1]), 
        .x_desired(10'd88), 
        .y_desired(10'd80)
    );

    textGeneration score_tens (
        .clk(clk), 
        .reset(reset), 
        .asciiData(a[2]), 
        .ascii_In(tens + 7'h30), 
        .x(pixel_x), 
        .y(pixel_y), 
        .displayContents(d[2]), 
        .x_desired(10'd96), 
        .y_desired(10'd80)
    );

    textGeneration score_ones (
        .clk(clk), 
        .reset(reset), 
        .asciiData(a[3]), 
        .ascii_In(ones + 7'h30), 
        .x(pixel_x), 
        .y(pixel_y), 
        .displayContents(d[3]), 
        .x_desired(10'd104), 
        .y_desired(10'd80)
    );

    // Score display logic
    wire score_display_pixel;
    wire [3:0] digit_pixels;
    assign score_display_on = d[0] || d[1] || d[2] || d[3];
    wire [6:0] score_ascii;
    assign score_ascii = d[0] ? a[0] :
                         d[1] ? a[1] :
                         d[2] ? a[2] :
                         d[3] ? a[3] : 7'h30; // Default to '0'

    // ASCII ROM for score display
    wire [10:0] rom_addr;
    wire [3:0] rom_row;
    wire [2:0] rom_col;
    wire [7:0] rom_data;
    wire rom_bit;
    
    ascii_rom score_rom (
        .clk(clk), 
        .rom_addr(rom_addr), 
        .data(rom_data)
    );
       
    assign rom_row = pixel_y[3:0];
    assign rom_addr = {score_ascii, rom_row};
    assign rom_col = pixel_x[2:0];
    assign score_display_pixel = rom_data[~rom_col];

    // Score update and reset logic
    always @(posedge clk_d) begin
        if (reset) begin
            // Reset score to 0 when reset or level is reset
            game_score <= 9'd0;
        end else if (bullet_collision_confirmed) begin
            // Increment score when an alien is hit
            game_score <= game_score + 9'd10;
        end
    end
    
    // Level-specific tank hit detection
    assign tank_hit_level1 = (current_level == 2'b01) ? (alien_pixel_on_level1 && tank_pixel_on) : 1'b0;
    assign tank_hit_level2 = (current_level == 2'b10) ? (alien_pixel_on_level2 && tank_pixel_on) : 1'b0;

    // Consolidated tank hit signal
    assign tank_hit = tank_hit_level1 || tank_hit_level2;
    
    // All aliens destroyed logic
assign all_aliens_destroyed = (current_level == 2'b01 && game_score >= 9'd200) || // Level 1 complete
                               (current_level == 2'b10 && game_score >= 9'd350); // Game complete
    
    // Alien movement modules for different levels
    aliens_movement_level1 alienCtrl_Level1 (
        .clk(clk_d),
        .reset(reset),
        .level_reset(level_reset),
        .center_switch(PAUSE),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .bullet_hit(bullet_active),
        .bullet_x(bullet_x),
        .bullet_y(bullet_y),
        .pixel_on(alien_pixel_on_level1),
        .bullet_collision_confirmed(bullet_collision_confirmed_level1)
    );
    
    aliens_movement_level2 alienCtrl_Level2 (
    .clk(clk_d),
    .reset(reset),
    .level_reset(level_reset),  // Map the level_reset signal from game_state_fsm
    .center_switch(PAUSE),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .bullet_hit(bullet_active),
    .bullet_x(bullet_x),
    .bullet_y(bullet_y),
    .pixel_on(alien_pixel_on_level2),
    .bullet_collision_confirmed(bullet_collision_confirmed_level2)
);
    
    // Alien pixel and collision signals based on current level
    assign alien_pixel_on = (current_level == 2'b01) ? alien_pixel_on_level1 : 
                            (current_level == 2'b10) ? alien_pixel_on_level2 : 
                            1'b0;
    
    assign bullet_collision_confirmed = (current_level == 2'b01) ? bullet_collision_confirmed_level1 :
                                        (current_level == 2'b10) ? bullet_collision_confirmed_level2 :
                                        1'b0;
    
    // Game State FSM
    game_state_fsm gameStateMachine (
        .clk(clk),
        .reset(reset),
        .tank_hit(tank_hit),
        .all_aliens_destroyed(all_aliens_destroyed),
        .start_game(SPACE),  // Start game with spacebar
        .game_state(game_state),
        .current_level(current_level),
        .level_reset(level_reset)
    );
    
    // Tank control module
    tank_control tankCtrl (
        .clk(clk_d),
        .reset(reset),
        .left_switch(LEFT),   // A to move LEFT
        .right_switch(RIGHT), // D to move RIGHT
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
        .up_switch(UP),          // W is used for single shot
        .center_switch(PAUSE),
        .tank_x(tank_x),
        .bullet_hit(bullet_collision_confirmed),  // Feedback from aliens module
        .pixel_on(bullet_pixel_on),
        .bullet_active(bullet_active),
        .bullet_x(bullet_x),
        .bullet_y(bullet_y)
    );

    
 // Start Screen Module
    wire start_h_sync, start_v_sync;
    wire [3:0] start_red, start_green, start_blue;
    start_screen startScreen (
        .clk(clk),
        .reset(reset),
        .h_sync(start_h_sync),
        .v_sync(start_v_sync),
        .red(start_red),
        .green(start_green),
        .blue(start_blue)
    );

    // Level 1 Win Screen Module
    wire win1_h_sync, win1_v_sync;
    wire [3:0] win1_red, win1_green, win1_blue;
    level1_win_screen level1Win (
        .clk(clk),
        .reset(reset),
        .h_sync(win1_h_sync),
        .v_sync(win1_v_sync),
        .red(win1_red),
        .green(win1_green),
        .blue(win1_blue)
    );

    // Level 2 Win Screen Module
    wire win2_h_sync, win2_v_sync;
    wire [3:0] win2_red, win2_green, win2_blue;
    level2_win_screen level2Win (
        .clk(clk),
        .reset(reset),
        .h_sync(win2_h_sync),
        .v_sync(win2_v_sync),
        .red(win2_red),
        .green(win2_green),
        .blue(win2_blue)
    );

    // Lose Screen Module
    wire lose_h_sync, lose_v_sync;
    wire [3:0] lose_red, lose_green, lose_blue;
    lose_screen loseScreen (
        .clk(clk),
        .reset(reset),
        .h_sync(lose_h_sync),
        .v_sync(lose_v_sync),
        .red(lose_red),
        .green(lose_green),
        .blue(lose_blue)
    );

    // Remove previous RGB registration
    reg [3:0] red_reg, green_reg, blue_reg; // Keep for internal rendering
    reg h_sync_reg, v_sync_reg; // Add sync registers

    
always @(posedge clk_d) begin
    if (~video_on) begin
            red_reg <= 4'h0;
            green_reg <= 4'h0;
            blue_reg <= 4'h0;
//            h_sync_reg <= h_sync_wire;
//            v_sync_reg <= v_sync_wire;
    end
    else begin
        case (game_state)
                3'b000: begin  // Start Screen
                    h_sync_reg <= start_h_sync;
                    v_sync_reg <= start_v_sync;
                    red_reg <= start_red;
                    green_reg <= start_green;
                    blue_reg <= start_blue;
                end
            
            3'b001: begin  // PLAYING_LEVEL1 state
                if (alien_pixel_on) begin
                    // Pink color for Level 1 aliens
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
                else if (score_display_on && score_display_pixel) begin
                    // White color for score text
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
            
            3'b010: begin  // Level 1 Win Screen
                    h_sync_reg <= win1_h_sync;
                    v_sync_reg <= win1_v_sync;
                    red_reg <= win1_red;
                    green_reg <= win1_green;
                    blue_reg <= win1_blue;
                end
            
            3'b011: begin  // PLAYING_LEVEL2 state
                if (alien_pixel_on) begin
                    // Green color for Level 2 aliens
                    red_reg <= 4'h0;
                    green_reg <= 4'hB;
                    blue_reg <= 4'h0;
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
                else if (score_display_on && score_display_pixel) begin
                    // White color for score text
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
            
            3'b100: begin  // Lose Screen
                    h_sync_reg <= lose_h_sync;
                    v_sync_reg <= lose_v_sync;
                    red_reg <= lose_red;
                    green_reg <= lose_green;
                    blue_reg <= lose_blue;
                end
            
            3'b101: begin  // LEVEL 2 WIN state
                    h_sync_reg <= win2_h_sync;
                    v_sync_reg <= win2_v_sync;
                    red_reg <= win2_red;
                    green_reg <= win2_green;
                    blue_reg <= win2_blue;
                end
            
             default: begin  // Fallback to Start Screen
                    h_sync_reg <= start_h_sync;
                    v_sync_reg <= start_v_sync;
                    red_reg <= start_red;
                    green_reg <= start_green;
                    blue_reg <= start_blue;
                end
            endcase
    end
end
    // Assign RGB outputs   
    assign red = red_reg;
    assign green = green_reg;
    assign blue = blue_reg;
    
endmodule