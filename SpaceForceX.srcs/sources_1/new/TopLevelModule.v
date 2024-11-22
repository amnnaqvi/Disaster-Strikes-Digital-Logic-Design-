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
    input clk,                    
    input reset,                  // Reset input
    input left_switch,            // Left movement switch
    input right_switch,           // Right movement switch 
    input up_switch,              // Shoot button
    input center_switch,          // Pause button
    output h_sync,                
    output v_sync,                
    output [3:0] red,             
    output [3:0] green,           
    output [3:0] blue             
);
    // Internal wires
    wire clk_d;                   
    wire [9:0] h_count;           
    wire [9:0] v_count;           
    wire [9:0] pixel_x;           
    wire [9:0] pixel_y;           
    wire video_on;                
    wire trig_v;                  
    
    wire alien_pixel_on;         
    wire tank_pixel_on;           
    wire bullet_pixel_on;         
    wire [9:0] tank_x;            
    wire bullet_active;    
    reg [3:0] red_reg, green_reg, blue_reg;  
    
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
        .center_switch(center_switch),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_on(alien_pixel_on)
    );
    
    // Tank control module
    tank_control tankCtrl (
        .clk(clk_d),
        .reset(reset),
        .left_switch(left_switch),
        .right_switch(right_switch),
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
        .up_switch(up_switch),
        .center_switch(center_switch),
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
                // Yellow color for tank
                red_reg <= 4'hF;
                green_reg <= 4'hF;
                blue_reg <= 4'h0;
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
