`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: XADCdemo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: XADC-based joystick interface for reading analog signals
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module XADCdemo(
   input CLK100MHZ,
   input vauxp6,
   input vauxn6,
   input vauxp7,
   input vauxn7,
   input vauxp15,
   input vauxn15,
   input vauxp14,
   input vauxn14,
   input switch,
   output reg [3:0] x, // Updated to reg since it is driven in always block
   output reg [3:0] y, // Updated to reg since it is driven in always block
   output reg z        // Updated to reg since it is driven in always block
);

   wire enable;  
   wire ready;
   wire [15:0] data;   
   reg [6:0] Address_in;     
   reg [32:0] decimal;   
   reg [3:0] dig0;
   reg [3:0] dig1;
   reg [3:0] dig2;
   reg [3:0] dig3;
   reg [3:0] dig4;
   reg [3:0] dig5;
   reg [3:0] dig6;
   reg [3:0] Vrx; // X-axis value
   reg [3:0] Vry; // Y-axis value
   reg sw;
   reg [32:0] delay;
   reg [32:0] count; // Added reg for count variable

   // Instantiate XADC Wizard
   xadc_wiz_0 XLXI_7 (
       .daddr_in(Address_in), // DRP address
       .dclk_in(CLK100MHZ), 
       .den_in(enable), 
       .di_in(0),          // Input data (not used)
       .dwe_in(0),         // Write enable (not used)
       .busy_out(),                    
       .vauxp6(vauxp6),
       .vauxn6(vauxn6),
       .vauxp7(vauxp7),
       .vauxn7(vauxn7),
       .vauxp14(vauxp14),
       .vauxn14(vauxn14),
       .vauxp15(vauxp15),
       .vauxn15(vauxn15),
       .vn_in(0),          // Negative input (not used)
       .vp_in(0),          // Positive input (not used)
       .alarm_out(), 
       .do_out(data), 
       .eoc_out(enable),   // End of conversion signal
       .channel_out(), 
       .drdy_out(ready)    // Data ready signal
   );
   
   // Initialization
   initial begin
      sw = 0;
      count = 0;
      delay = 0;
   end

   // Binary to Decimal Conversion
   always @ (posedge CLK100MHZ) begin
      if (count == 10000000) begin
         decimal = data >> 4;
         if (decimal >= 4093) begin
            dig0 = 0;
            dig1 = 0;
            dig2 = 0;
            dig3 = 0;
            dig4 = 0;
            dig5 = 0;
            dig6 = 1;
         end else begin
            decimal = decimal * 250000;
            decimal = decimal >> 10;
            dig0 = decimal % 10;
            decimal = decimal / 10;
            dig1 = decimal % 10;
            decimal = decimal / 10;
            dig2 = decimal % 10;
            decimal = decimal / 10;
            dig3 = decimal % 10;
            decimal = decimal / 10;
            dig4 = decimal % 10;
            decimal = decimal / 10;
            dig5 = decimal % 10;
            decimal = decimal / 10; 
            dig6 = decimal % 10;
         end
         count = 0;
      end else begin
         count = count + 1;
      end
   end

   // Toggle Switch for Channel Selection
   always @ (posedge CLK100MHZ) begin
      if (delay == 100000000) begin
         sw = ~sw; 
         delay = 0;
      end else begin
         delay = delay + 1;
      end
   end

   // Address and Data Assignment
   always @ (posedge CLK100MHZ) begin
      case (sw)
         1'b0: begin
            Address_in <= 7'h16;
            Vrx <= data[15:12];
            Vry <= 4'b0;
         end
         1'b1: begin
            Address_in <= 7'h1E;
            Vry <= data[15:12];
            Vrx <= 4'b0;
         end
      endcase
   end

   // Output Assignments
   always @ (posedge CLK100MHZ) begin
      x <= Vrx;
      y <= Vry;
      z <= switch;
   end

endmodule
