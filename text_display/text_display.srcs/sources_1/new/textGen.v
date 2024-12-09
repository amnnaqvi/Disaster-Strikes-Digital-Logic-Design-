module textGeneration(
    input clk,
    input reset,
    input [6:0] ascii_In,       // Input ASCII value (7 bits)
    input [9:0] x_desired,      // Desired X-coordinate for the character
    input [9:0] y_desired,      // Desired Y-coordinate for the character
    input [9:0] x,              // Current X pixel position from vga_sync
    input [9:0] y,              // Current Y pixel position from vga_sync
    output [6:0] asciiData,     // Buffered output of the input ASCII
    output displayContents      // Signal indicating whether to display content
);
    wire horizontalOn, verticalOn;

    // Buffer the input ASCII value to output
    assign asciiData = ascii_In;

    // Horizontal display range: covers 8 pixels wide
    assign horizontalOn = (x >= x_desired && x < x_desired + 10'd8) ? 1 : 0;

    // Vertical display range: covers 16 pixels high
    assign verticalOn = (y >= y_desired && y < y_desired + 10'd16) ? 1 : 0;

    // Enable display when both horizontal and vertical ranges are active
    assign displayContents = horizontalOn && verticalOn;
endmodule
