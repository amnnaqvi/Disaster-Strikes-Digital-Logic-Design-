module counter(input clk, reset, output [13:0] out);
    reg [26:0] counter;  // For 1Hz clock
    reg [13:0] number;   // Stores numbers 0 to 9999
    wire tick;

    // 1Hz clock tick
    always @(posedge clk or posedge reset) begin
        if (reset) counter <= 0;
        else counter <= (counter == 99999999) ? 0 : counter + 1;
    end
    assign tick = (counter == 99999999);

    // Increment number
    always @(posedge clk or posedge reset) begin
        if (reset) number <= 0;
        else if (tick) number <= (number == 9999) ? 0 : number + 1;
    end

    assign out = number;  // Output the 14-bit value
endmodule
