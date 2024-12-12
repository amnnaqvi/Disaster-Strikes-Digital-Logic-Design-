`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 01:17:19 PM
// Design Name: 
// Module Name: bullet_movement
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
module bullet_movement(
    input wire clk,              
    input wire reset,           
    input wire [9:0] pixel_x,    
    input wire [9:0] pixel_y,   
    input wire up_switch,        
    input wire center_switch,       
    input wire [9:0] tank_x,     
    input wire bullet_hit,       
    output reg pixel_on,         
    output reg bullet_active,
    output reg [9:0] bullet_x,   
    output reg [9:0] bullet_y    
);

    parameter SCREEN_WIDTH = 640;     
    parameter SCREEN_HEIGHT = 480;    
    parameter BULLET_WIDTH = 2;       
    parameter BULLET_HEIGHT = 10;    
    parameter TANK_WIDTH = 32;       
    parameter TANK_Y = SCREEN_HEIGHT - 80;  
    parameter MOVE_INTERVAL = 100000;  
    parameter SHOT_COOLDOWN = 1000000; 

    localparam [2:0] 
        IDLE = 3'b000,          
        SHOT = 3'b001,          
        MOVING = 3'b010,        
        COOLDOWN = 3'b011,      
        PAUSED = 3'b100;        

    // State tracking registers
    reg [2:0] current_state, next_state;
    reg [2:0] pre_pause_state;  
    
    // Timing counters
    reg [20:0] move_counter;    
    reg [20:0] shot_cooldown;   


    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @* begin
        next_state = current_state;  
        
        case (current_state)
            IDLE: begin
                if (center_switch)
                    next_state = PAUSED;
                else if (shot_cooldown >= SHOT_COOLDOWN && up_switch)
                    next_state = SHOT;
            end
            
            SHOT: begin
                if (center_switch)
                    next_state = PAUSED;
                else
                    next_state = MOVING;
            end
            
            MOVING: begin
                if (center_switch)
                    next_state = PAUSED;
                else if (move_counter >= MOVE_INTERVAL) begin
                    if (!bullet_active || bullet_hit)           
                        next_state = COOLDOWN;
                    else
                        next_state = MOVING;
                end
            end
            
            COOLDOWN: begin
                if (center_switch)               
                    next_state = PAUSED;
                else if (shot_cooldown >= SHOT_COOLDOWN)
                    next_state = IDLE;
            end
            
            PAUSED: begin
                if (center_switch)
                    next_state = pre_pause_state;   
            end
            
            default: next_state = IDLE;
        endcase
    end

    // State actions and bullet management
    always @(posedge clk) begin
        if (reset) begin           
            bullet_active <= 0; 
            bullet_x <= 0;
            bullet_y <= 0;
            move_counter <= 0;
            shot_cooldown <= 0;
            pre_pause_state <= IDLE;
        end
        else begin
            if (current_state != PAUSED) begin    
                move_counter <= move_counter + 1;
                shot_cooldown <= shot_cooldown + 1;
            end
            
            // Save state before pausing
            if (next_state == PAUSED && current_state != PAUSED)
                pre_pause_state <= current_state;
            
            case (current_state)
                IDLE: begin
                    // wait for input, counters still increment
                end
                
                SHOT: begin     
                    if (!bullet_active) begin
                        // Center the bullet on the tank's barrel (adjusted for new sprite)
                        bullet_x <= tank_x + (TANK_WIDTH / 2) - (BULLET_WIDTH / 2);  
                        bullet_y <= TANK_Y - 10;  // Position just above the tank                
                        bullet_active <= 1;
                    end
                    shot_cooldown <= 0;  // Reset cooldown
                end
                
                MOVING: begin    
                    if (move_counter >= MOVE_INTERVAL) begin
                        move_counter <= 0;
                        if (bullet_active && !bullet_hit) begin
                            bullet_y <= bullet_y - 5;  // Move up
                            if (bullet_y < 10) begin   // Deactivate if reached top
                                bullet_active <= 0;
                            end
                        end
                    end
                end
                
                COOLDOWN: begin
                    // wait for cooldown timer
                end
                
                PAUSED: begin
                    // All updates frozen
                end
            endcase
        end
    end

    // Pixel rendering logic
    always @* begin
        pixel_on = 0;  // Default: pixel is off
        // Check if current pixel intersects with the active bullet
        if (bullet_active && 
            pixel_x >= bullet_x && pixel_x < bullet_x + BULLET_WIDTH &&
            pixel_y >= bullet_y && pixel_y < bullet_y + BULLET_HEIGHT) begin
            pixel_on = 1;
        end
    end

endmodule