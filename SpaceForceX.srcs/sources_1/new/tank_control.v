`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 08:17:21 AM
// Design Name: 
// Module Name: tank_control
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
module tank_control (
    input wire clk,              
    input wire reset,            
    input wire left_switch,      
    input wire right_switch,     
    input wire [9:0] pixel_x,    
    input wire [9:0] pixel_y,    
    output reg pixel_on,         
    output wire [9:0] tank_x_pos 
);
    // Screen and tank parameters
    parameter SCREEN_WIDTH = 640;
    parameter SCREEN_HEIGHT = 480;

    parameter TANK_WIDTH = 30;      
    parameter TANK_HEIGHT = 10;     
    parameter BARREL_WIDTH = 8;    
    parameter BARREL_HEIGHT = 8;   
    parameter MOVE_SPEED = 4;    // 4 pixels per clock cycle

    // Tank position
    reg [9:0] tank_x;
    parameter TANK_Y = SCREEN_HEIGHT - 50; // Tank position fixed

    assign tank_x_pos = tank_x;

    // Movement control
    reg [20:0] move_counter = 0;
    parameter MOVE_INTERVAL = 500000; // Movement speed control

    // Input handler
    always @(posedge clk) begin
        if (reset) begin
            tank_x <= (SCREEN_WIDTH - TANK_WIDTH) / 2; // Center the tank when reset
            move_counter <= 0;
        end else begin
            // Increment move counter
            move_counter <= move_counter + 1;

            // Movement logic
            if (move_counter >= MOVE_INTERVAL) begin
                move_counter <= 0;

                // Move left
                if (left_switch && !right_switch && tank_x > 0) begin
                    tank_x <= (tank_x > MOVE_SPEED) ? tank_x - MOVE_SPEED : 0;
                end
                // Move right
                else if (right_switch && !left_switch && tank_x < SCREEN_WIDTH - TANK_WIDTH) begin
                    tank_x <= (tank_x + TANK_WIDTH + MOVE_SPEED < SCREEN_WIDTH) ? 
                              tank_x + MOVE_SPEED : SCREEN_WIDTH - TANK_WIDTH;
                end
            end
        end
    end

    // Pixel rendering 
    always @* begin
        pixel_on = 0;

        // Check if current pixel is within tank body region
        if (pixel_x >= tank_x && pixel_x < tank_x + TANK_WIDTH &&
            pixel_y >= TANK_Y && pixel_y < TANK_Y + TANK_HEIGHT) begin
            pixel_on = 1;
        end

        // Check if pixel is within barrel region
        // Barrel is centered on top of tank
        if (pixel_x >= tank_x + (TANK_WIDTH - BARREL_WIDTH) / 2 && 
            pixel_x < tank_x + (TANK_WIDTH + BARREL_WIDTH) / 2 &&
            pixel_y >= TANK_Y - BARREL_HEIGHT && 
            pixel_y < TANK_Y) begin
            pixel_on = 1;
        end
    end
endmodule