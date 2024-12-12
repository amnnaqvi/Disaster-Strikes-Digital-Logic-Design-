`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 08:15:44 AM
// Design Name: 
// Module Name: v_counter
// Project Name: 
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


module v_sync (clk, enable_v, v_count);
input clk;
input enable_v;
output [9:0] v_count;
reg [9:0] v_count;
initial v_count=0;
always@ (posedge clk) 
begin
if (v_count < 524) 
begin
if (enable_v == 1)
begin
v_count <= v_count+1;
end
else 
begin
v_count <= v_count;
end
end
else 
begin
v_count<=0;
end
end endmodule
