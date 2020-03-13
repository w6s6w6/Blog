// --------------------------------------------------------------------
// Copyright (c) 2019 by MicroPhase Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   MicroPhase grants permission to use and modify this code for use
//   in synthesis for all MicroPhase Development Boards.
//   Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  MicroPhase provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     MicroPhase Technologies Inc
//                     Shanghai, China
//
//                     web: http://www.microphase.cn/   
//                     email: support@microphase.cn
//
// --------------------------------------------------------------------
// --------------------------------------------------------------------
//
// Major Functions:	
//
// --------------------------------------------------------------------
// --------------------------------------------------------------------
//
//  Revision History:
//  Date          By            Revision    Change Description
//---------------------------------------------------------------------
//2019-12-07      Chaochen Wei  1.0          Original
//2019/                         1.1          
// --------------------------------------------------------------------
// --------------------------------------------------------------------

`timescale 1ns / 1ps
module hdmi_top(
	input	wire			sys_clk_n	,
	input	wire			sys_clk_p	,
	input 	wire 			rst_n 		,
	output 	wire 			hdmi_tx_clk	,
	output 	wire 			hdmi_tx_de 	,
	output 	wire   			hdmi_tx_vs	,
	output 	wire 			hdmi_tx_hs	,
	output 	wire 	[23:0]	hdmi_td 	,

	output 	wire 			scl 		,
	inout 	wire 			sda 		
    );

parameter       CNT_MAX = 26000000;

wire 			sys_clk 	;
wire 			rst 		;
wire 			locked 		;
wire 			ready 		;
reg 	[24:0]	cnt 		;

assign rst = ~locked;

	IBUFDS input_clock(
		.O(sys_clk),
		.I(sys_clk_p),
		.IB(sys_clk_n)
		);

  	clock inst_clock(
    	// Clock out ports
    	.clk_out1(clk_200m),     // output clk_out1
    	.clk_out2(clk_50m),     // output clk_out2
    	// Status and control signals
    	.reset(~rst_n), // input reset
    	.locked(locked),       // output locked
   		// Clock in ports
    	.clk_in1(sys_clk)// input clk_in1
    );      

always@(posedge clk_50m )begin
    if(locked==1'b0)
        cnt <= 'd0;
    else if(cnt <CNT_MAX)
        cnt <= cnt + 1'b1;
    else
        cnt <= cnt;
end
assign  ready = (cnt==CNT_MAX)?1'b1:1'b0;

	i2c_cfg inst_i2c_cfg (
			.clk          (clk_50m),
			.rst          (rst),
			.scl          (scl),
			.sda          (sda)
		);

	vga_shift  inst_vga_shift (
			.clk_50m   (clk_50m),
			.rst      (rst),
			.vpg_pclk (hdmi_tx_clk),
			.vpg_de   (hdmi_tx_de),
			.vpg_hs   (hdmi_tx_hs),
			.vpg_vs   (hdmi_tx_vs),
			.rgb      (hdmi_td)
		);



endmodule
