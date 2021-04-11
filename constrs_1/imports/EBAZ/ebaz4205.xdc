set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports clk]; # TXCLK
create_clock -add -name uart_clk -period 400.00 [get_ports clk];
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports tx]; # DATA1-5

set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports lpc_clk]; # DATA1-6
create_clock -add -name lpc_clk -period 30.00 [get_ports lpc_clk];

set_clock_groups -asynchronous -group {uart_clk} -group {lpc_clk};

set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS33} [get_ports {lpc_ad[0]}]; # DATA1-7
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports {lpc_ad[1]}]; # DATA1-8
set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33} [get_ports {lpc_ad[2]}]; # DATA1-9
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {lpc_ad[3]}]; # DATA1-14
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports lpc_reset]; # DATA1-19
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports lpc_frame]; # DATA1-17
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports reset_all]; # J3_3

set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports fifo_full_led]; # Red LED
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports led_green]; # Green LED
