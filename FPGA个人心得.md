# FPGA个人心得

​	**一定要添加时钟约束**

​			**create_clock -period 5 [get_ports sys_clk_p]**

​            **set_property CFGBVS VCCO [current_design]**

​            **set_property CONFIG_VOLTAGE 3.3 [current_design]**

​	修改下配置参数，加速下载到flash , 方便调试

​			**set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]**

​			**set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]**

​			**set_property CONFIG_MODE SPIx4 [current_design]**