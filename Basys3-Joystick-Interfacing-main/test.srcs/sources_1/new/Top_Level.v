`timescale 1ns/1ps

module Top_Level(
    input CLK100MHZ,
    input vauxp6,
    input vauxn6,
    input vauxp7,
    input vauxn7,
    input vauxp15,
    input vauxn15,
    input vauxp14,
    input vauxn14,
    output reg is_x,
    output reg is_y
);

    wire x; // Changed from reg to wire
    wire y; // Changed from reg to wire
    wire [15:0] magnitude;

    // Instantiating the XADCdemo module
    XADCdemo x1 (
        .CLK100MHZ(CLK100MHZ),
        .vauxp6(vauxp6),
        .vauxn6(vauxn6),
        .vauxp7(vauxp7),
        .vauxn7(vauxn7),
        .vauxp15(vauxp15),
        .vauxn15(vauxn15),
        .vauxp14(vauxp14),
        .vauxn14(vauxn14),
        .LED(magnitude),
        .is_x(x),
        .is_y(y)
    );

    always @(posedge CLK100MHZ) begin
        if (x ^ y) begin  // Use XOR condition correctly with grouped statements
            is_x <= x;
            is_y <= y;
        end
    end

endmodule
