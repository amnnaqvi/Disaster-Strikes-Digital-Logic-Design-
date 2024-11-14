## Clock Constraint
set_property PACKAGE_PIN V17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.00 [get_ports clk]

## Power and Ground Connections (Note: Power and GND connections typically don't need explicit constraints)
# JXADC6 is the 3.3V power supply pin, and JXADC5 is the GND pin.

## Joystick X and Y Axis Analog Inputs
set_property PACKAGE_PIN N2 [get_ports x_pos]  ; # JXADC4
set_property IOSTANDARD LVCMOS33 [get_ports x_pos]

set_property PACKAGE_PIN M2 [get_ports y_pos]  ; # JXADC3
set_property IOSTANDARD LVCMOS33 [get_ports y_pos]

## Joystick Switch Input (Z-axis, Button)
set_property PACKAGE_PIN L3 [get_ports switch]  ; # JXADC2
set_property IOSTANDARD LVCMOS33 [get_ports switch]

## AB Output Signals (for LEDs to display movement)
set_property PACKAGE_PIN V13 [get_ports {AB[1]}] ; # Connects to LED0 on Basys 3
set_property IOSTANDARD LVCMOS33 [get_ports {AB[1]}]

set_property PACKAGE_PIN U14 [get_ports {AB[0]}] ; # Connects to LED1 on Basys 3
set_property IOSTANDARD LVCMOS33 [get_ports {AB[0]}]
