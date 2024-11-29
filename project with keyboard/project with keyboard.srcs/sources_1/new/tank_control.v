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
    parameter TANK_WIDTH = 32;      
    parameter TANK_HEIGHT = 32;     
    parameter MOVE_SPEED = 4;    

    // Tank position
    reg [9:0] tank_x;
    parameter TANK_Y = SCREEN_HEIGHT - 80; // Tank position fixed
    assign tank_x_pos = tank_x;

    // Movement control
    reg [20:0] move_counter = 0;
    parameter MOVE_INTERVAL = 500000; // Movement speed control
    
    // Tank sprite (32x32 bitmap)
    reg [31:0] tank [0:31];
    
    // Initialize tank sprite 
    initial begin
        tank[0]     = 32'b00000000000000011000000000000000;
        tank[1]     = 32'b00000000000000011000000000000000;
        tank[2]     = 32'b00000000000000011000000000000000;
        tank[3]     = 32'b00000000000000011000000000000000;
        tank[4]     = 32'b00000000000001111110000000000000;
        tank[5]     = 32'b00000000000001111110000000000000;
        tank[6]     = 32'b00000000000001111110000000000000;
        tank[7]     = 32'b00000000000001111110000000000000;
        tank[8]     = 32'b00000001100001111110000110000000;
        tank[9]     = 32'b00000001100001111110000110000000;
        tank[10]    = 32'b00000001100001111110000110000000;
        tank[11]    = 32'b00000001100001111110000110000000;
        tank[12]    = 32'b00000001100111111111100110000000;
        tank[13]    = 32'b00000001100111111111100110000000;
        tank[14]    = 32'b00000001111111111111111110000000;
        tank[15]    = 32'b00000001111111111111111110000000;
        tank[16]    = 32'b01100001111111111111111110000110;
        tank[17]    = 32'b01100001111111111111111110000110;
        tank[18]    = 32'b01100001111111111111111110000110;
        tank[19]    = 32'b01100001111111111111111110000110;
        tank[20]    = 32'b01100001111111111111111110000110;
        tank[21]    = 32'b01100001111111111111111110000110;
        tank[22]    = 32'b01100111111111111111111111100110;
        tank[23]    = 32'b01100111111111111111111111100110;
        tank[24]    = 32'b01111111111111111111111111111110;
        tank[25]    = 32'b01111111111111111111111111111110;
        tank[26]    = 32'b01111110011111111111111001111110;
        tank[27]    = 32'b01111110011111111111111001111110;
        tank[28]    = 32'b01111000011110011001111000011110;
        tank[29]    = 32'b01111000011110011001111000011110;
        tank[30]    = 32'b01100000000000011000000000000110;
        tank[31]    = 32'b01100000000000011000000000000110;
    end

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
    reg [9:0] rel_x, rel_y;
    
    always @* begin
        pixel_on = 0;
        
        // Check if current pixel is within tank region
        if (pixel_x >= tank_x && pixel_x < tank_x + TANK_WIDTH &&
            pixel_y >= TANK_Y && pixel_y < TANK_Y + TANK_HEIGHT) begin
            rel_x = pixel_x - tank_x;
            rel_y = pixel_y - TANK_Y;
            pixel_on = tank[rel_y][rel_x];
        end
    end

endmodule
