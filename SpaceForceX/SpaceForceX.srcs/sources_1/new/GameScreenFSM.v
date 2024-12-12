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
    input clk,
    input reset,
    input tank_hit,
    input all_aliens_destroyed,
    input start_game,
    output reg [2:0] game_state,
    output reg [1:0] current_level,
    output reg level_reset
);
    // Game state definitions
    localparam [2:0]
        START_SCREEN     = 3'b000,
        PLAYING_LEVEL1   = 3'b001,
        LEVEL1_WIN       = 3'b010,
        PLAYING_LEVEL2   = 3'b011,
        GAME_OVER        = 3'b100,
        GAME_WIN         = 3'b101;  // New state for game win screen

    // Initialize game state and level
    initial begin
        game_state = START_SCREEN;
        current_level = 2'b00;
        level_reset = 0;
    end

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            game_state <= START_SCREEN;
            current_level <= 2'b00;
            level_reset <= 1;
        end else begin
            // Default reset signal
            level_reset <= 0;
            case (game_state)
                START_SCREEN: begin
                    if (start_game) begin
                        // Transition to Level 1
                        game_state <= PLAYING_LEVEL1;
                        current_level <= 2'b01;
                        level_reset <= 1;
                    end
                end
                PLAYING_LEVEL1: begin
                    if (tank_hit) begin
                        // Player loses in Level 1
                        game_state <= GAME_OVER;
                        current_level <= 2'b00;
                    end else if (all_aliens_destroyed) begin
                        // Transition to Level 1 Win Screen
                        game_state <= LEVEL1_WIN;
                    end
                end
                LEVEL1_WIN: begin
                    if (start_game) begin
                        // Transition to Level 2
                        game_state <= PLAYING_LEVEL2;
                        current_level <= 2'b10;
                        level_reset <= 1;
                    end
                end
                PLAYING_LEVEL2: begin
                    if (tank_hit) begin
                        // Player loses in Level 2
                        game_state <= GAME_OVER;
                        current_level <= 2'b00;
                    end else if (all_aliens_destroyed) begin
                        // Transition to Game Win Screen
                        game_state <= GAME_WIN;
                        current_level <= 2'b00;
                    end
                end
                GAME_WIN: begin
                    if (start_game) begin
                        // Return to start screen
                        game_state <= START_SCREEN;
                        current_level <= 2'b00;
                        level_reset <= 1;
                    end
                end
                GAME_OVER: begin
                    if (start_game) begin
                        // Return to start screen
                        game_state <= START_SCREEN;
                        current_level <= 2'b00;
                        level_reset <= 1;
                    end
                end
                default: begin
                    game_state <= START_SCREEN;
                    current_level <= 2'b00;
                end
            endcase
        end
    end
endmodule