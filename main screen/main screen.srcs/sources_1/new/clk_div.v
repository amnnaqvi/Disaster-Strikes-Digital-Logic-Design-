module clk_div (clk, clk_d);
parameter div_value=1;
input clk;  
output clk_d; 
reg clk_d; reg count;
initial
begin
clk_d = 0; count = 0; //initialize clk_d and count to 0
end
always @(posedge clk) //always block is executed at positive edge of clk
begin
if (count == div_value) 
count <= 0; // reset count when it reaches div_value
else
count <= count + 1; // increment count for each clock cycle
end
always @(posedge clk) //always block is executed at positive edge of clk
begin
if (count == div_value)
clk_d <= ~clk_d; //toggle the output clock signal 
end endmodule
