`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 01:22:00 PM
// Design Name: 
// Module Name: score_display
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
module score_display (
    input wire clk,
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    output wire score_pixel_on
);
    // Character codes for "SCORE:"
    reg [7:0] char_codes [0:5];
    initial begin
        char_codes[0] = 8'h53; // S
        char_codes[1] = 8'h43; // C
        char_codes[2] = 8'h4F; // O
        char_codes[3] = 8'h52; // R
        char_codes[4] = 8'h45; // E
        char_codes[5] = 8'h3A; // :
    end

    // ROM for character patterns
    reg [7:0] char_rom [0:2047];
    initial begin
        // Character data for 'S'
        char_rom[11'h530] = 8'b01111100;
        char_rom[11'h531] = 8'b11111110;
        char_rom[11'h532] = 8'b11000000;
        char_rom[11'h533] = 8'b11111100;
        char_rom[11'h534] = 8'b01111110;
        char_rom[11'h535] = 8'b00000110;
        char_rom[11'h536] = 8'b11111110;
        char_rom[11'h537] = 8'b01111100;

        // Character data for 'C'
        char_rom[11'h430] = 8'b01111100;
        char_rom[11'h431] = 8'b11111110;
        char_rom[11'h432] = 8'b11000000;
        char_rom[11'h433] = 8'b11000000;
        char_rom[11'h434] = 8'b11000000;
        char_rom[11'h435] = 8'b11000000;
        char_rom[11'h436] = 8'b11111110;
        char_rom[11'h437] = 8'b01111100;

        // Character data for 'O'
        char_rom[11'h4F0] = 8'b01111100;
        char_rom[11'h4F1] = 8'b11111110;
        char_rom[11'h4F2] = 8'b11000110;
        char_rom[11'h4F3] = 8'b11000110;
        char_rom[11'h4F4] = 8'b11000110;
        char_rom[11'h4F5] = 8'b11000110;
        char_rom[11'h4F6] = 8'b11111110;
        char_rom[11'h4F7] = 8'b01111100;

        // Character data for 'R'
        char_rom[11'h520] = 8'b11111100;
        char_rom[11'h521] = 8'b11111110;
        char_rom[11'h522] = 8'b11000110;
        char_rom[11'h523] = 8'b11000110;
        char_rom[11'h524] = 8'b11111110;
        char_rom[11'h525] = 8'b11111100;
        char_rom[11'h526] = 8'b11011000;
        char_rom[11'h527] = 8'b11000110;

        // Character data for 'E'
        char_rom[11'h450] = 8'b11111110;
        char_rom[11'h451] = 8'b11111110;
        char_rom[11'h452] = 8'b11000000;
        char_rom[11'h453] = 8'b11111100;
        char_rom[11'h454] = 8'b11111100;
        char_rom[11'h455] = 8'b11000000;
        char_rom[11'h456] = 8'b11111110;
        char_rom[11'h457] = 8'b11111110;

        // Character data for ':'
        char_rom[11'h3A0] = 8'b00000000;
        char_rom[11'h3A1] = 8'b00011000;
        char_rom[11'h3A2] = 8'b00011000;
        char_rom[11'h3A3] = 8'b00000000;
        char_rom[11'h3A4] = 8'b00000000;
        char_rom[11'h3A5] = 8'b00011000;
        char_rom[11'h3A6] = 8'b00011000;
        char_rom[11'h3A7] = 8'b00000000;
    end

    // Display parameters
    localparam SCORE_X = 10'd20;        // Starting X position for "SCORE:"
    localparam SCORE_Y = 10'd20;        // Starting Y position
    localparam CHAR_WIDTH = 8;          // Width of each character
    localparam CHAR_HEIGHT = 8;         // Height of each character
    localparam CHAR_SPACING = 4;        // Spacing between characters
    integer char_index;
    // Pixel logic
    reg pixel_on;
    integer rel_x;
    integer rel_y;
    always @(*) begin
        pixel_on = 0;
        if (pixel_y >= SCORE_Y && pixel_y < SCORE_Y + CHAR_HEIGHT) begin
            // Determine character index and relative position
            char_index = (pixel_x - SCORE_X) / (CHAR_WIDTH + CHAR_SPACING);
            rel_x = (pixel_x - SCORE_X) % (CHAR_WIDTH + CHAR_SPACING);
            rel_y = pixel_y - SCORE_Y;

            if (char_index >= 0 && char_index < 6 && rel_x < CHAR_WIDTH) begin
                // Check the ROM for the corresponding pixel
                if (char_rom[{char_codes[char_index], rel_y}][7 - rel_x]) begin
                    pixel_on = 1;
                end
            end
        end
    end

    assign score_pixel_on = pixel_on;
endmodule