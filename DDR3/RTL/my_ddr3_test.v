// 2020-03-04 , 15:18   把ddr3当作fifo来写,然后测试其输入输出信�?, 
module my_ddr3_test ( 

    inout [31:0]            ddr3_dq     	,
   	inout [3:0]             ddr3_dqs_n  	,
   	inout [3:0]             ddr3_dqs_p  	,		
   	// Outputs	
   	output [14:0]           ddr3_addr   	,
   	output [2:0]            ddr3_ba     	,
   	output                  ddr3_ras_n  	,
   	output                  ddr3_cas_n  	,
   	output                  ddr3_we_n   	,
   	output                  ddr3_reset_n	,
   	output [0:0]            ddr3_ck_p   	,
   	output [0:0]            ddr3_ck_n   	,
   	output [0:0]            ddr3_cke    	,
   	output [0:0]            ddr3_cs_n   	,
   	output [3:0]            ddr3_dm     	,
   	output [0:0]            ddr3_odt    	, 
    
   	//system port
   	input 	wire			      sys_clk_p 		,
   	input   wire			      sys_clk_n 	,
   	input   wire                  rst_n   	 
);
    
     wire   sys_clk ;
     wire   rst ;
     
   

     
     //差分时钟转单端时�?
    IBUFDS sys_clock(
      .O(sys_clk),
      .I(sys_clk_p),
      .IB(sys_clk_n)
    );      
    
    //---------------------------------------------
    //mig related port
    //---------------------------------------------
    wire 				      init_calib_complete   ;   //初始化完�?
    wire	[28:0]		      app_addr 			    ;   //读写内存地址
    wire	[2:0]		      app_cmd 			    ;   //读写命令
    wire				      app_en 				;   //命令使能
    wire	[255:0]		      app_wdf_data		    ;   //写入内存的数�?
    wire				      app_wdf_end 		    ;   //当前数据是一次内存突发的�?后一个数�?
    wire				      app_wdf_wren 	     	;   //写入数据使能
    wire	[255:0]		      app_rd_data 		    ;   //从内存中读出的数�?
    wire				      app_rd_data_end 	    ;   //当前数据是一次内存突发的�?后一个数�?
    wire				      app_rd_data_vld 	    ;   //读出数据有效信号
    wire				      app_rdy 			    ;   //内存命令通道处于空闲状�??
    wire				      app_wdf_rdy 		    ;   //内存写数据�?�道处于空闲状�??
    wire				      app_sr_active 		;
    wire				      app_ref_ack 		    ;
    wire				      app_zq_ack 			;
    wire				      ui_clk 				;   //100M ddr控制器提供的时钟
    wire				      ui_clk_sync_rst 	    ;   //ddr时钟复位完成
    wire	[31:0]		      app_wdf_mask 		    ;   //写数据掩�?
      assign  rst = ~init_calib_complete ;
    
    // my drive related port 
    wire   [255:0]            wr_data           ;
    wire                      wr_en             ;
    wire   [255:0]            rd_data           ;
    wire                      rd_vld            ;
    wire                      full              ;
    wire                      empty             ;
    wire                      data_req          ;

ila_0 your_instance_name (
	.clk(sys_clk), // input wire clk


	.probe0(wr_data), // input wire [255:0]  probe0  
	.probe1(rd_data), // input wire [255:0]  probe1 
	.probe2(wr_en), // input wire [0:0]  probe2 
	.probe3(rd_vld), // input wire [0:0]  probe3 
	.probe4(full), // input wire [0:0]  probe4 
	.probe5(empty), // input wire [0:0]  probe5 
	.probe6(data_req), // input wire [0:0]  probe6 
	.probe7(rst) // input wire [0:0]  probe7
);

    my_ddr3_drive   u_my_drive ( 
        .ui_clk          (ui_clk)       ,
        .rst             (rst)          ,
        
        .wr_data         (wr_data)      ,
        .wr_en           (wr_en)        ,
        .rd_data         (rd_data)      ,
        .rd_vld          (rd_vld)       ,
        .full            (full)         ,
        .empty           (empty)        ,
        .data_req        (data_req)     ,
    
        .app_addr       (app_addr)      ,
        .app_cmd        (app_cmd)       ,
        .app_en         (app_en)        ,
        .app_wdf_data   (app_wdf_data)  ,
        .app_wdf_end    (app_wdf_end)   ,
        .app_wdf_mask   (app_wdf_mask)  ,
        .app_wdf_wren   (app_wdf_wren)  ,
        .app_rdy        (app_rdy)       ,
        .app_rd_data    (app_rd_data)   ,
        .app_rd_data_vld(app_rd_data_vld) ,
        .app_wdf_rdy    (app_wdf_rdy)   ,
        .app_rd_data_end(app_rd_data_end),
        .init_calib_complete (init_calib_complete)
    );
    
        //DDR3 控制�? MIG
ip_ddr3 u_ip (
    // Memory interface ports
    .ddr3_addr                      (ddr3_addr),  	        // output [14:0]		ddr3_addr
    .ddr3_ba                        (ddr3_ba),  	          // output [2:0]		ddr3_ba
    .ddr3_cas_n                     (ddr3_cas_n),  	        // output			ddr3_cas_n
	 .ddr3_ck_n                      (ddr3_ck_n),  	        // output [0:0]		ddr3_ck_n
    .ddr3_ck_p                      (ddr3_ck_p),  	        // output [0:0]		ddr3_ck_p
    .ddr3_cke                       (ddr3_cke),  	          // output [0:0]		ddr3_cke
    .ddr3_ras_n                     (ddr3_ras_n),  	        // output			ddr3_ras_n
    .ddr3_reset_n                   (ddr3_reset_n),         // output			ddr3_reset_n
    .ddr3_we_n                      (ddr3_we_n),  	        // output			ddr3_we_n
    .ddr3_dq                        (ddr3_dq),  	          // inout [31:0]		ddr3_dq
    .ddr3_dqs_n                     (ddr3_dqs_n),  	        // inout [3:0]		ddr3_dqs_n
    .ddr3_dqs_p                     (ddr3_dqs_p),  	        // inout [3:0]		ddr3_dqs_p
    .init_calib_complete            (init_calib_complete),  // output			init_calib_complete
	 .ddr3_cs_n                      (ddr3_cs_n),  	        // output [0:0]		ddr3_cs_n
    .ddr3_dm                        (ddr3_dm),  	          // output [3:0]		ddr3_dm
    .ddr3_odt                       (ddr3_odt),  	          // output [0:0]		ddr3_odt
    // Application interface ports
    .app_addr                       (app_addr),  		        // input [28:0]		app_addr
    .app_cmd                        (app_cmd),  		        // input [2:0]		app_cmd
    .app_en                         (app_en),  			        // input				app_en
    .app_wdf_data                   (app_wdf_data), 	      // input [255:0]		app_wdf_data
    .app_wdf_end                    (app_wdf_end),  	      // input				app_wdf_end
    .app_wdf_wren                   (app_wdf_wren), 	      // input				app_wdf_wren
    .app_rd_data                    (app_rd_data),  	      // output [255:0]		app_rd_data
    .app_rd_data_end                (app_rd_data_end),      // output			app_rd_data_end
    .app_rd_data_valid              (app_rd_data_vld),      // output			app_rd_data_valid
    .app_rdy                        (app_rdy),  		        // output			app_rdy
    .app_wdf_rdy                    (app_wdf_rdy),  	      // output			app_wdf_rdy
    .app_sr_req                     (1'b0),  			          // input			app_sr_req
    .app_ref_req                    (1'b0),  			          // input			app_ref_req
    .app_zq_req                     (1'b0),  			          // input			app_zq_req
    .app_sr_active                  (app_sr_active),	      // output			app_sr_active
    .app_ref_ack                    (app_ref_ack),  	      // output			app_ref_ack
    .app_zq_ack                     (app_zq_ack),  		      // output			app_zq_ack
    .ui_clk                         (ui_clk),  			        // output			ui_clk
    .ui_clk_sync_rst                (ui_clk_sync_rst),      // output			ui_clk_sync_rst
    .app_wdf_mask                   (app_wdf_mask),  	      // input [31:0]		app_wdf_mask
    // System Clock Ports
    .sys_clk_i                      (sys_clk),
    .sys_rst                        (rst_n) 			          // input sys_rst
     
    );
  
    my_gen_data  u_gen (
       .ui_clk (ui_clk) ,
       .rst(rst),
       .empty(empty) ,
       .full (full) ,
       .wr_en(wr_en),
       .wr_data (wr_data),
       .data_req(data_req)
    );
 
    endmodule 