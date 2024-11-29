`timescale 1ns/1ps

module keyboard_1 (
    input wire clk, reset,
    input wire ps2d, ps2c,
    output SPACE,
    output UP,
    output DOWN,
    output LEFT,
    output RIGHT,
    output PAUSE,
    output RESET,
    output SPECIAL,
    output reg state,
    output reg key_release
);

// Declare variables
wire [7:0] dout;
wire rx_done_tick;
wire rx_en = 1'b1; // Always enable receiver

// Instantiate PS/2 receiver
ps2_rx ps2_receiver (
    .clk(clk), 
    .reset(reset), 
    .ps2d(ps2d), 
    .ps2c(ps2c), 
    .rx_en(rx_en), 
    .rx_done_tick(rx_done_tick), 
    .dout(dout)
);
 
// Sequential logic
reg [7:0] key;
always @(posedge clk, posedge reset)
begin
    if (reset) begin
        key <= 16'h00;
        key_release <= 1'b0;
        state <= 1'b0;
    end
    else if (rx_done_tick)
    begin 
        key <= dout; // key is one rx cycle behind dout
        if (key == 16'hf0) // check if the key has been released
            key_release <= 1'b1;
        else
            key_release <= 1'b0;
    end
end


// Key Assignments
assign SPACE = (key == 16'h29) & !key_release; // Space Bar
assign UP = (key == 16'h1D) & !key_release;    // W
assign DOWN = (key == 16'h1B) & !key_release;  // S
assign LEFT = (key == 16'h1C) & !key_release;  // A
assign RIGHT = (key == 16'h23) & !key_release; // D
assign PAUSE = (key == 16'h4D) & !key_release; // P
assign RESET = (key == 16'h2D) & !key_release; // R
assign SPECIAL = (key == 16'h22) & !key_release; // X

// State change logic
always @(posedge clk) begin
    if (rx_done_tick) begin
        case(key)
            16'h5A : state <= 1'b1; // Enter key
            16'h66 : state <= 1'b0; // Backspace key
            default: state <= state;
        endcase
    end
end
endmodule
