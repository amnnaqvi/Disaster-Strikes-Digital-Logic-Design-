`timescale 1ns / 1ps
module level2_win_screen(
    input clk,                    // System clock
    input reset,                  // Reset input
    output h_sync,                // Horizontal sync for VGA
    output v_sync,                // Vertical sync for VGA
    output [3:0] red,         // Red color output
    output [3:0] green,       // Green color output
    output [3:0] blue         // Blue color output
);

// Internal wires
wire clk_d;                     
wire [9:0] h_count;             
wire [9:0] v_count;             
wire video_on;                  
wire trig_v;                    
wire [9:0] x_loc;              
wire [9:0] y_loc;              

// Clock divider
clk_div clkDivider (
    .clk(clk),
    .clk_d(clk_d)
);

// Horizontal sync generator
h_sync horizontalCounter (
    .clk(clk_d),
    .h_count(h_count),
    .trig_v(trig_v)
);

// Vertical sync generator
v_sync verticalCounter (
    .clk(clk_d),
    .enable_v(trig_v),
    .v_count(v_count)
);

// VGA sync generator
vga_sync v1 (
    .h_count(h_count),
    .v_count(v_count),
    .h_sync(h_sync),
    .v_sync(v_sync),
    .video_on(video_on),
    .x_loc(x_loc),
    .y_loc(y_loc)
);

// VGA pixel output
level2_win_bitmap_display display (
    .clk(clk),
    .reset(reset),
    .pixel_x(x_loc),
    .pixel_y(y_loc),
    .red(red),
    .green(green),
    .blue(blue)
);

endmodule
