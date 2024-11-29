`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 08:18:04 AM
// Design Name: 
// Module Name: aliens_movement
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
module aliens_movement(
    input wire clk,              
    input wire reset,            
    input wire center_switch,     
    input wire [9:0] pixel_x,    
    input wire [9:0] pixel_y,    
    output reg pixel_on         
);

    // State definitions
    localparam [1:0]
        MOVING = 2'b00,
        PAUSED = 2'b01;

    // State registers
    reg [1:0] current_state, next_state;

    // Parameters for game configuration 
    parameter ALIEN_WIDTH = 32;
    parameter ALIEN_HEIGHT = 32;
    parameter NUM_COLUMNS = 5;
    parameter ALIENS_PER_COLUMN = 3;
    parameter SCREEN_HEIGHT = 480;
    parameter MOVE_SPEED = 1;    
    parameter COLUMN_SPACING = 100;
    
    // Clock divider for controlling alien movement speed
    reg [19:0] move_counter = 0;
    parameter MOVE_INTERVAL = 1000000; 
    
    // Array to store alien positions
    reg [9:0] alien_x [0:NUM_COLUMNS-1];
    reg [9:0] alien_y [0:NUM_COLUMNS-1][0:ALIENS_PER_COLUMN-1];
    
    reg [6:0] column_offset [0:NUM_COLUMNS-1];
    
    // Alien sprite 32 by 32 bitmap
    reg [31:0] alien [0:31];
    
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
    
    initial begin
        // Column offsets
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
            end
        end
        current_state = MOVING;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= MOVING;
        else
            current_state <= next_state;
    end

    // Next state:
    always @* begin
        next_state = current_state;
        
        case (current_state)
            MOVING: begin
                if (center_switch)
                    next_state = PAUSED;
            end
            
            PAUSED: begin
                if (center_switch)
                    next_state = MOVING;
            end
            
            default: next_state = MOVING;
        endcase
    end
    
    // Movement: 
    always @(posedge clk) begin
        if (reset) begin
            // Reset alien positions
            for (i = 0; i < NUM_COLUMNS; i = i + 1) begin
                for (j = 0; j < ALIENS_PER_COLUMN; j = j + 1) begin
                    alien_y[i][j] <= column_offset[i] + (j * 50);
                end
            end
            move_counter <= 0;
        end else begin
            // Update movement when not paused
            if (current_state == MOVING) begin
                move_counter <= move_counter + 1;
                if (move_counter >= MOVE_INTERVAL) begin
                    move_counter <= 0;
                    // Move aliens down
                    for (i = 0; i < NUM_COLUMNS; i = i + 1) begin
                        for (j = 0; j < ALIENS_PER_COLUMN; j = j + 1) begin
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
        
        if (in_alien_region) begin
            pixel_on = alien[rel_y][rel_x];
        end
    end

endmodule