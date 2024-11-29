`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: // Project Name: 
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
   output reg [15:0] LED,
   output reg is_x,
   output reg is_y
//   output [3:0] an,
//   output dp,
//   output [6:0] seg 
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
   reg [3:0] Vrx; // this can be used in the game logic to get x values (the values are from 01-15)
   reg [3:0] Vry; // this can be used in the game logic to get y values
   reg sw;
   reg [32:0] delay;
   


   //xadc instantiation connect the eoc_out .den_in to get continuous conversion
   xadc_wiz_0  XLXI_7 (
    .daddr_in(Address_in),
    .dclk_in(CLK100MHZ),
    .den_in(enable),
    .di_in(), // Connect if needed
    .dwe_in(), // Connect if needed
    .busy_out(),
    .vauxp6(vauxp6),
    .vauxn6(vauxn6),
    .vauxp7(vauxp7),
    .vauxn7(vauxn7),
    .vauxp14(vauxp14),
    .vauxn14(vauxn14),
    .vauxp15(vauxp15),
    .vauxn15(vauxn15),
    .vn_in(), // Connect if needed
    .vp_in(), // Connect if needed
    .alarm_out(),
    .do_out(data),
    .eoc_out(enable),
    .channel_out(),
    .drdy_out(ready),
    .eos_out() // Explicitly connect if needed
);

                     
         
    
    initial
    begin
        sw = 0;
        is_x = 0;
        is_y = 0;
    end
      //led visual dmm  (for visulaizing the input voltage in form of an led bar)            
      always @( posedge(CLK100MHZ))
      begin            
        if(ready == 1'b1)
        begin
          case (data[15:12])
            1:  LED <= 16'b11;
            2:  LED <= 16'b111;
            3:  LED <= 16'b1111;
            4:  LED <= 16'b11111;
            5:  LED <= 16'b111111;
            6:  LED <= 16'b1111111; 
            7:  LED <= 16'b11111111;
            8:  LED <= 16'b111111111;
            9:  LED <= 16'b1111111111;
            10: LED <= 16'b11111111111;
            11: LED <= 16'b111111111111;
            12: LED <= 16'b1111111111111;
            13: LED <= 16'b11111111111111;
            14: LED <= 16'b111111111111111;
            15: LED <= 16'b1111111111111111;                        
           default: LED <= 16'b1;
           
           endcase
           
        end 

          
      end
      
     reg [32:0] count; 
     //binary to decimal conversion
      always @ (posedge(CLK100MHZ))
      begin
      
        if(count == 10000000)begin
        
        decimal = data >> 4;
        if(decimal >= 4093)
        begin
            dig0 = 0;
            dig1 = 0;
            dig2 = 0;
            dig3 = 0;
            dig4 = 0;
            dig5 = 0;
            dig6 = 1;
            count = 0;
        end
        else 
        begin
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
            decimal = decimal / 10; 
            
            count = 0;
        end
       end
       
      count = count + 1;
               
      end
      
      always @(posedge(CLK100MHZ))
      begin
        if (delay == 50000000)
//        if (delay == 100000000) // the huge value of this delay is for testing purposes. for using the joystick in the game, teh value should be reduced to check x and y values more frequently.
            begin
            sw = ~sw; 
            delay = 0;
            end
        else
            delay = delay+1;
     end
        
        
      
      
      always @(posedge(CLK100MHZ))
begin
    Vrx <= 4'b0;
    Vry <= 4'b0;
    case(sw)
    0:  begin
        Address_in <= 8'h16;
        Vrx <= data[15:12];
        Vry <= 4'b0;
    end
    
    1: begin
        Address_in <= 8'h1e;
        Vry <= data[15:12];
        Vrx <= 4'b0;
    end
    endcase

    // Hysteresis for X-axis
    if (is_x == 0 && Vrx >= 4'hA) 
        is_x <= 1;
    else if (is_x == 1 && Vrx <= 4'h6) 
        is_x <= 0;

    // Hysteresis for Y-axis  
    if (is_y == 0 && Vry >= 4'hA) 
        is_y <= 1;
    else if (is_y == 1 && Vry <= 4'h6) 
        is_y <= 0;
end
      
//      // This is for debugging and testing the values
//      DigitToSeg segment1(.in1(dig3),
//                         .in2(dig4),
//                         .in3(dig5),
//                         .in4(dig6),
//                         .in5(),
//                         .in6(),
//                         .in7(),
//                         .in8(),
//                         .mclk(CLK100MHZ),
//                         .an(an),
//                         .dp(dp),
//                         .seg(seg));  
endmodule
