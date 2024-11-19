`timescale 1ns / 1ps
module tb_jstick;

    reg clk = 0;
    reg [9:0] x_in = 512;
    reg [9:0] y_in = 512;
    reg z_in = 0;
    wire [1:0] o;

    // Instantiate the joystick module
    jstick uut (
        .clk(clk),
        .x_in(x_in),
        .y_in(y_in),
        .z_in(z_in),
        .o(o)
    );

    // Generate clock
    always #5 clk = ~clk; // 100MHz clock

    initial begin
        // Neutral position
        #10;

        // Move joystick in X positive direction
        x_in = 600; y_in = 512; z_in = 0;
        #10;

        // Move joystick in Y negative direction
        x_in = 512; y_in = 400; z_in = 0;
        #10;

        // Press button (Z-axis)
        x_in = 512; y_in = 512; z_in = 1;
        #10;

        // Return to neutral
        x_in = 512; y_in = 512; z_in = 0;
        #10;

        $finish;
    end
endmodule
