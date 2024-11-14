`timescale 1ns / 1ps
module joystick(
    input wire clk,               // Clock input
    input wire [9:0] x_pos,       // X-axis position (0-1023 from ADC)
    input wire [9:0] y_pos,       // Y-axis position (0-1023 from ADC)
    input wire switch,            // Switch input (active low or high, depending on the joystick setup)
    output reg [1:0] AB           // AB output where A is MSB and B is LSB
);

// Define a threshold to detect significant movement.
parameter THRESHOLD = 10'd50; // Adjust as necessary for joystick sensitivity
parameter MIDPOINT = 10'd512;  // Midpoint for neutral joystick position (for a 10-bit ADC range)

// Calculate z, x, y as per input positions
wire z = switch;  // Button press from the joystick
wire x = (x_pos >= (MIDPOINT + THRESHOLD)) || (x_pos <= (MIDPOINT - THRESHOLD)); // Detect significant x movement
wire y = (y_pos >= (MIDPOINT + THRESHOLD)) || (y_pos <= (MIDPOINT - THRESHOLD)); // Detect significant y movement

always @(posedge clk) begin
    // Calculate A and B based on the given logic equations
    AB[1] <= z | (~x & y);  // A = z + x'y
    AB[0] <= z | (x & ~y);  // B = z + xy'
end

// Console message simulation for movement direction
always @(posedge clk) begin
    case (AB)
        2'b10: $display("10 - y movement");
        2'b01: $display("01 - x movement");
        2'b11: $display("11 - z movement");
        default: $display("00 - no movement");
    endcase
end

endmodule
