`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 08:14:17 AM
// Design Name: 
// Module Name: aliens_movement_level1
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


module aliens_movement_level1(
    input wire clk,              
    input wire reset,
    input wire level_reset,                
    input wire center_switch,     
    input wire [9:0] pixel_x,    
    input wire [9:0] pixel_y,    
    input wire bullet_hit,       
    input wire [9:0] bullet_x,   
    input wire [9:0] bullet_y,   
    output reg pixel_on,
    output reg bullet_collision_confirmed  
);

    // State definitions
    localparam [2:0]
        MOVING = 3'b000,
        PAUSED = 3'b001,
        ALIEN_HIT = 3'b010;      


    reg alien_destroyed;
    // State registers
    reg [2:0] current_state, next_state;

    // Parameters for game configuration 
    parameter ALIEN_WIDTH = 32;
    parameter ALIEN_HEIGHT = 32;
    parameter NUM_COLUMNS = 5;
    parameter ALIENS_PER_COLUMN = 4;
    parameter SCREEN_HEIGHT = 480;
    parameter MOVE_SPEED = 1;    
    parameter COLUMN_SPACING = 100;
    
    // Clock divider for controlling alien movement speed
    reg [19:0] move_counter = 0;
    parameter MOVE_INTERVAL = 1000000; 
    
    // Array to store alien positions and hit status
    reg [9:0] alien_x [0:NUM_COLUMNS-1];
    reg [9:0] alien_y [0:NUM_COLUMNS-1][0:ALIENS_PER_COLUMN-1];
    reg alien_alive [0:NUM_COLUMNS-1][0:ALIENS_PER_COLUMN-1];
    
    reg [6:0] column_offset [0:NUM_COLUMNS-1];
    
    // Alien sprite 32 by 32 bitmap
    reg [31:0] alien [0:31];
    
    // Collision tracking
    reg [4:0] hit_column;
    reg [4:0] hit_row;
    
    // Initialize alien sprite
    initial begin
        alien[0]  = 32'b00000000000000000000000000000000;
        alien[1]  = 32'b00000000000000000000000000000000;
        alien[2]  = 32'b00000000000000000000000000000000;
        alien[3]  = 32'b00000000000000000000000000000000;
        alien[4]  = 32'b00000000000000000000000000000000;
        alien[5]  = 32'b00000000000000000000000000000000;
        alien[6]  = 32'b00000000000000000000000000000000;
        alien[7]  = 32'b00000000000000000000000000000000;
        alien[8]  = 32'b00000000011000000000011000000000;
        alien[9]  = 32'b00000000011000000000011000000000;
        alien[10] = 32'b00000000000110000001100000000000;
        alien[11] = 32'b00000000000110000001100000000000;
        alien[12] = 32'b00000000011111111111111000000000;
        alien[13] = 32'b00000000011111111111111000000000;
        alien[14] = 32'b00000001111001111110011110000000;
        alien[15] = 32'b00000001111001111110011110000000;
        alien[16] = 32'b00000111111111111111111111100000;
        alien[17] = 32'b00000111111111111111111111100000;
        alien[18] = 32'b00000110011111111111111001100000;
        alien[19] = 32'b00000110011111111111111001100000;
        alien[20] = 32'b00000110011000000000011001100000;
        alien[21] = 32'b00000110011000000000011001100000;
        alien[22] = 32'b00000000000111100111100000000000;
        alien[23] = 32'b00000000000111100111100000000000;
        alien[24] = 32'b00000000000000000000000000000000;
        alien[25] = 32'b00000000000000000000000000000000;
        alien[26] = 32'b00000000000000000000000000000000;
        alien[27] = 32'b00000000000000000000000000000000;
        alien[28] = 32'b00000000000000000000000000000000;
        alien[29] = 32'b00000000000000000000000000000000;
        alien[30] = 32'b00000000000000000000000000000000;
        alien[31] = 32'b00000000000000000000000000000000;
    end
    
    // Initialize column offsets
    initial begin
        column_offset[0] = 8'd30;   
        column_offset[1] = 8'd50;  
        column_offset[2] = 8'd20; 
        column_offset[3] = 8'd60;  
        column_offset[4] = 8'd70;   
    end
    
    // Initialize alien positions
    integer i, j;
    initial begin
        for (i = 0; i < NUM_COLUMNS; i = i + 1) begin
            alien_x[i] = 100 + (i * COLUMN_SPACING);
        end
        
        for (i = 0; i < NUM_COLUMNS; i = i + 1) begin
            for (j = 0; j < ALIENS_PER_COLUMN; j = j + 1) begin
                alien_y[i][j] = column_offset[i] + (j * 50);
                alien_alive[i][j] = 1'b1;  // All aliens start alive
            end
        end
        
        current_state = MOVING;
        alien_destroyed = 0;
    end

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= MOVING;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @* begin
        next_state = current_state;
        
        case (current_state)
            MOVING: begin
                if (center_switch)
                    next_state = PAUSED;
                else if (bullet_hit)
                    next_state = ALIEN_HIT;
            end
            
            PAUSED: begin
                if (center_switch)
                    next_state = MOVING;
            end
            
            ALIEN_HIT: begin
                next_state = MOVING;
            end
            
            default: next_state = MOVING;
        endcase
    end

    reg hit_found;
    
            
    // movement and collision detection logic
    always @(posedge clk) begin
        if (reset || level_reset) begin
            // Reset all previous logic
            for (i = 0; i < NUM_COLUMNS; i = i + 1) begin
                for (j = 0; j < ALIENS_PER_COLUMN; j = j + 1) begin
                    alien_y[i][j] <= column_offset[i] + (j * 50);
                    alien_alive[i][j] <= 1'b1;
                end
            end
            move_counter <= 0;
            alien_destroyed <= 0;
            bullet_collision_confirmed <= 0;
            hit_column = 0;
            hit_row = 0;
            current_state <= MOVING;
        end else begin
            // Reset collision confirmation each clock cycle
            bullet_collision_confirmed <= 0;
            
            // Update movement when not paused
            if (current_state == MOVING) begin
                move_counter <= move_counter + 1;
                if (move_counter >= MOVE_INTERVAL) begin
                    move_counter <= 0;
                    // Move aliens down
                    for (i = 0; i < NUM_COLUMNS; i = i + 1) begin
                        for (j = 0; j < ALIENS_PER_COLUMN; j = j + 1) begin
                            if (alien_alive[i][j]) begin
                                if (alien_y[i][j] < SCREEN_HEIGHT) begin
                                    alien_y[i][j] <= alien_y[i][j] + MOVE_SPEED;
                                end else begin
                                    alien_y[i][j] <= column_offset[i] + (j * 50);
                                end
                            end
                        end
                    end
                end
            end
            
            // collision detection logic
            if (bullet_hit) begin
                // Flag to track if a hit was found
                hit_found = 0;
                
                // Iterate through all aliens to find the first hit
                for (i = 0; i < NUM_COLUMNS && !hit_found; i = i + 1) begin
                    for (j = 0; j < ALIENS_PER_COLUMN && !hit_found; j = j + 1) begin
                        // Check if the bullet is within the alien's bounding box
                        // AND the alien is still alive
                        if (alien_alive[i][j] &&
                            bullet_x >= alien_x[i] && 
                            bullet_x < alien_x[i] + ALIEN_WIDTH &&
                            bullet_y >= alien_y[i][j] && 
                            bullet_y < alien_y[i][j] + ALIEN_HEIGHT) begin
                            
                            // Mark this specific alien as not alive
                            alien_alive[i][j] <= 1'b0;
                            
                            // Confirm collision for bullet deactivation
                            bullet_collision_confirmed <= 1;
                            
                            // Store hit location for rendering
                            hit_column = i;
                            hit_row = j;

                            // Set hit_found to exit loops
                            hit_found = 1;
                        end
                    end
                end
            end
        end
    end

    // Pixel rendering 
    reg [9:0] rel_x, rel_y;
    reg in_alien_region;
    integer current_alien_col, current_alien_row;
    
    always @* begin
        pixel_on = 0;
        in_alien_region = 0;
        
        for (i = 0; i < NUM_COLUMNS; i = i + 1) begin
            for (j = 0; j < ALIENS_PER_COLUMN; j = j + 1) begin
                // Check if pixel is in alien region
                if (pixel_x >= alien_x[i] && pixel_x < alien_x[i] + ALIEN_WIDTH &&
                    pixel_y >= alien_y[i][j] && pixel_y < alien_y[i][j] + ALIEN_HEIGHT) begin
                    rel_x = pixel_x - alien_x[i];
                    rel_y = pixel_y - alien_y[i][j];
                    in_alien_region = 1;
                    current_alien_col = i;
                    current_alien_row = j;
                end
            end
        end
        
        // When an alien is hit, return black 
        if (in_alien_region && 
            !alien_alive[current_alien_col][current_alien_row]) begin
            pixel_on = 0;  // Always black when hit
        end else if (in_alien_region) begin
            pixel_on = alien_alive[current_alien_col][current_alien_row] && alien[rel_y][rel_x];
        end
    end

endmodule
