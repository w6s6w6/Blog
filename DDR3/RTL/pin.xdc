set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

########### clock define ##################
create_clock  -period 5 [get_ports sys_clk_p]
set_property PACKAGE_PIN V4 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]



############# reset key ####################
set_property PACKAGE_PIN T20 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]


