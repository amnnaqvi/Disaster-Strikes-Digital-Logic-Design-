## Clock Signal
set_property PACKAGE_PIN W5 [get_ports clk]                            
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
    create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## PS/2 Keyboard Signals (using USB-to-PS/2 Adapter)
set_property PACKAGE_PIN B17 [get_ports ps2d]                        
    set_property IOSTANDARD LVCMOS33 [get_ports ps2d]
    set_property PULLUP true [get_ports ps2d]

set_property PACKAGE_PIN C17 [get_ports ps2c]                        
    set_property IOSTANDARD LVCMOS33 [get_ports ps2c]
    set_property PULLUP true [get_ports ps2c]
    
set_property PACKAGE_PIN L1 [get_ports SPACE]
    set_property IOSTANDARD LVCMOS33 [get_ports SPACE]

set_property PACKAGE_PIN P1 [get_ports UP]
    set_property IOSTANDARD LVCMOS33 [get_ports UP]
set_property PACKAGE_PIN N3 [get_ports DOWN]
    set_property IOSTANDARD LVCMOS33 [get_ports DOWN]

set_property PACKAGE_PIN P3 [get_ports LEFT]
    set_property IOSTANDARD LVCMOS33 [get_ports LEFT]
set_property PACKAGE_PIN U3 [get_ports RIGHT]
    set_property IOSTANDARD LVCMOS33 [get_ports RIGHT]
    
   set_property PACKAGE_PIN W3 [get_ports SPECIAL]
    set_property IOSTANDARD LVCMOS33 [get_ports SPECIAL]

set_property PACKAGE_PIN V3 [get_ports PAUSE]
    set_property IOSTANDARD LVCMOS33 [get_ports PAUSE]
set_property PACKAGE_PIN V13 [get_ports RESET]
    set_property IOSTANDARD LVCMOS33 [get_ports RESET]

## Additional Signals
## Use an external button or switch for reset
set_property PACKAGE_PIN U18 [get_ports reset]
    set_property IOSTANDARD LVCMOS33 [get_ports reset]

## Key Release and State can be mapped to an additional LED or left unconnected
set_property PACKAGE_PIN U15 [get_ports key_release]
    set_property IOSTANDARD LVCMOS33 [get_ports key_release]
set_property PACKAGE_PIN W18 [get_ports state]
    set_property IOSTANDARD LVCMOS33 [get_ports state]
