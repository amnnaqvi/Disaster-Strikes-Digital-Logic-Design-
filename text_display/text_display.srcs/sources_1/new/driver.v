`timescale 1ns/1ps
module vga_test
    (
        input wire clk, reset,
        output wire hsync, vsync,
        output wire [11:0] rgb
    );
    
    // VGA Synchronization
    wire video_on;
    wire [9:0] x, y; // Current pixel location
    
    vga_sync vga_sync_unit (
        .clk(clk), 
        .reset(reset), 
        .hsync(hsync), 
        .vsync(vsync),
        .video_on(video_on), 
        .x(x), 
        .y(y)
    );
    
    // Counter for live data
    wire [13:0] counterValue;
    counter counter1 (
        .clk(clk), 
        .reset(reset), 
        .out(counterValue)
    );
    
    // Extract digits from the 4-digit counter value
    wire [3:0] thousands, hundreds, tens, ones;
    assign thousands = (counterValue / 1000) % 10;
    assign hundreds  = (counterValue / 100) % 10;
    assign tens      = (counterValue / 10) % 10;
    assign ones      = counterValue % 10;

    // Instantiate text generation modules for each digit
    wire [6:0] a[3:0]; // Holds ASCII data for each digit
    wire d[3:0];       // Display signals for each digit
    
    textGeneration c0 (
        .clk(clk), 
        .reset(reset), 
        .asciiData(a[0]), 
        .ascii_In(thousands + 7'h30), 
        .x(x), 
        .y(y), 
        .displayContents(d[0]), 
        .x_desired(10'd80), 
        .y_desired(10'd80)
    );

    textGeneration c1 (
        .clk(clk), 
        .reset(reset), 
        .asciiData(a[1]), 
        .ascii_In(hundreds + 7'h30), 
        .x(x), 
        .y(y), 
        .displayContents(d[1]), 
        .x_desired(10'd88), 
        .y_desired(10'd80)
    );

    textGeneration c2 (
        .clk(clk), 
        .reset(reset), 
        .asciiData(a[2]), 
        .ascii_In(tens + 7'h30), 
        .x(x), 
        .y(y), 
        .displayContents(d[2]), 
        .x_desired(10'd96), 
        .y_desired(10'd80)
    );

    textGeneration c3 (
        .clk(clk), 
        .reset(reset), 
        .asciiData(a[3]), 
        .ascii_In(ones + 7'h30), 
        .x(x), 
        .y(y), 
        .displayContents(d[3]), 
        .x_desired(10'd104), 
        .y_desired(10'd80)
    );

    // Display contents logic
    wire displayContents;
    assign displayContents = d[0] || d[1] || d[2] || d[3];

    wire [6:0] ascii;
    assign ascii = d[0] ? a[0] :
                   d[1] ? a[1] :
                   d[2] ? a[2] :
                   d[3] ? a[3] : 7'h30; // Default to '0'

    // ASCII ROM
    wire [10:0] rom_addr;
    wire [3:0] rom_row;
    wire [2:0] rom_col;
    wire [7:0] rom_data;
    wire rom_bit;

    ascii_rom rom1 (
        .clk(clk), 
        .rom_addr(rom_addr), 
        .data(rom_data)
    );

    assign rom_row = y[3:0];
    assign rom_addr = {ascii, rom_row};
    assign rom_col = x[2:0];
    assign rom_bit = rom_data[~rom_col];

    // Set RGB values
    assign rgb = video_on ? (rom_bit ? (displayContents ? 12'hFFF : 12'h008) : 12'h008) : 12'b0; // Blue background, white text
endmodule
