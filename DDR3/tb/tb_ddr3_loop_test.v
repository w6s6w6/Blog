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
//2019-12-16      Chaochen Wei  1.0          Original
//2019/                         1.1          
// --------------------------------------------------------------------
// --------------------------------------------------------------------


`timescale 1ns / 1ps
module tb_ddr3_loop_test();

	wire [31:0] ddr3_dq;
	wire  [3:0] ddr3_dqs_n;
	wire  [3:0] ddr3_dqs_p;
	wire [14:0] ddr3_addr;
	wire  [2:0] ddr3_ba;
	wire        ddr3_ras_n;
	wire        ddr3_cas_n;
	wire        ddr3_we_n;
	wire        ddr3_reset_n;
	wire  [0:0] ddr3_ck_p;
	wire  [0:0] ddr3_ck_n;
	wire  [0:0] ddr3_cke;
	wire  [0:0] ddr3_cs_n;
	wire  [3:0] ddr3_dm;
	wire  [0:0] ddr3_odt;
	reg        	sys_clk_p;
	reg        	sys_clk_n;
	reg        	rst_n 		;

	ddr3_test  inst_ddr3_test(
			.ddr3_dq      (ddr3_dq),
			.ddr3_dqs_n   (ddr3_dqs_n),
			.ddr3_dqs_p   (ddr3_dqs_p),
			.ddr3_addr    (ddr3_addr),
			.ddr3_ba      (ddr3_ba),
			.ddr3_ras_n   (ddr3_ras_n),
			.ddr3_cas_n   (ddr3_cas_n),
			.ddr3_we_n    (ddr3_we_n),
			.ddr3_reset_n (ddr3_reset_n),
			.ddr3_ck_p    (ddr3_ck_p),
			.ddr3_ck_n    (ddr3_ck_n),
			.ddr3_cke     (ddr3_cke),
			.ddr3_cs_n    (ddr3_cs_n),
			.ddr3_dm      (ddr3_dm),
			.ddr3_odt     (ddr3_odt),
			.sys_clk_p    (sys_clk_p),
			.sys_clk_n    (sys_clk_n),
			.rst_n        (rst_n),
			.error		  (error)
		);

 genvar r,i;
  generate
    for (r = 0; r < 2; r = r + 1) begin: mem_rnk
      if(32/16) begin: mem
        for (i = 0; i < 2; i = i + 1) begin: gen_mem
          ddr3_model u_comp_ddr3
            (
             .rst_n   (ddr3_reset_n),
             .ck      (ddr3_ck_p),
             .ck_n    (ddr3_ck_n),
             .cke     (ddr3_cke),
             .cs_n    (ddr3_cs_n),
             .ras_n   (ddr3_ras_n),
             .cas_n   (ddr3_cas_n),
             .we_n    (ddr3_we_n),
             .dm_tdqs (ddr3_dm[(2*(i+1)-1):(2*i)]),
             .ba      (ddr3_ba),
             .addr    (ddr3_addr),
             .dq      (ddr3_dq[16*(i+1)-1:16*(i)]),
             .dqs     (ddr3_dqs_p[(2*(i+1)-1):(2*i)]),
             .dqs_n   (ddr3_dqs_n[(2*(i+1)-1):(2*i)]),
             .tdqs_n  (),
             .odt     (ddr3_odt)
             );
        end
      end
    end
  endgenerate
  
	// clock
	initial begin
		sys_clk_n = 0;
		forever #(2.5) sys_clk_n = ~sys_clk_n;
	end

	initial begin
		sys_clk_p = 1;
		forever #(2.5) sys_clk_p = ~sys_clk_p;
	end

	// reset
	initial begin
		rst_n = 0;
		#500;
		rst_n = 1;
	end

endmodule
