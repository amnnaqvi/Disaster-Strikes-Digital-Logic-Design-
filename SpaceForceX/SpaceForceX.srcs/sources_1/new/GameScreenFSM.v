`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 03:12:04 PM
// Design Name: 
// Module Name: GameScreenFSM
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
module game_state_fsm(
    input wire clk, 
    input wire reset, 
    input wire tank_hit,       // Signal when tank is hit by alien
    input wire all_aliens_destroyed, // Signal when no aliens remain
    input wire start_game,     // Input to start the game from start screen
    output reg [1:0] game_state, // 00: start screen, 01: playing, 10: win, 11: lose
    output reg [1:0] current_level, // Tracks the current level
    output reg level_reset
);
    // Updated state encoding
    localparam START_SCREEN   = 2'b00, 
               PLAYING        = 2'b01, 
               LEVEL_1_WIN    = 2'b10, 
               LEVEL_2_WIN    = 2'b11, 
               LOSE           = 2'b11;

    // Level constants
    localparam LEVEL_1 = 2'b01, LEVEL_2 = 2'b10;
    
    // State and level registers
    reg [1:0] current_state, next_state;
    
    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Always reset to start screen with Level 1
            current_state <= START_SCREEN;
            current_level <= LEVEL_1;
            level_reset <= 1'b1;
        end else begin
            current_state <= next_state;
            
            // Level reset logic
            if (next_state != current_state || 
                (current_state == LOSE && start_game) || 
                (current_state == LEVEL_1_WIN && start_game) ||
                (current_state == LEVEL_2_WIN && start_game) ||
                (current_state == PLAYING && (tank_hit || all_aliens_destroyed))) begin
                level_reset <= 1'b1;
            end else begin
                level_reset <= 1'b0;
            end
        end
    end
    
    // Next state logic with detailed game flow
    always @* begin
        // Default assignments
        next_state = current_state;
        
        case (current_state)
            START_SCREEN: begin
                // Only transition to playing when space is pressed
                if (start_game) begin
                    next_state = PLAYING;
                end
            end
            
            PLAYING: begin
                // Lose condition - tank hit in any level
                if (tank_hit) begin
                    next_state = LOSE;
                end else if (all_aliens_destroyed) begin
                    // Level 1 completed, transition to Level 1 Win screen
                    if (current_level == LEVEL_1) begin
                        next_state = LEVEL_1_WIN;
                    end 
                    // Level 2 completed, go to Level 2 Win screen
                    else if (current_level == LEVEL_2) begin
                        next_state = LEVEL_2_WIN;
                    end
                end
            end
            
            LEVEL_1_WIN: begin
                // Start Level 2 when space is pressed
                if (start_game) begin
                    next_state = PLAYING;
                end
            end
            
            LEVEL_2_WIN: begin
                // Return to start screen when space is pressed
                if (start_game) begin
                    next_state = START_SCREEN;
                end
            end
            
            LOSE: begin
                // Return to start screen when space is pressed
                if (start_game) begin
                    next_state = START_SCREEN;
                end
            end
        endcase
    end
    
    // Level progression logic
    always @(posedge clk) begin
        if (reset) begin
            // Always start at Level 1 when reset
            current_level <= LEVEL_1;
        end else if (current_state == LEVEL_1_WIN && start_game) begin
            // Transition to Level 2 from Level 1 Win screen
            current_level <= LEVEL_2;
        end else if (current_state == START_SCREEN) begin
            // Reset to Level 1 when returning to start screen
            current_level <= LEVEL_1;
        end
    end
    
    // Output assignment
    always @(posedge clk) begin
        game_state <= current_state;
    end
endmodule