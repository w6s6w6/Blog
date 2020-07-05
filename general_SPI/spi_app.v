`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:26:06 06/23/2020 
// Design Name: 
// Module Name:    spi_app 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_app #( 
	parameter   SPI_MAX =  14 ,
	parameter   DATA_WIDTH =  16 , 
	parameter   DELAY_TIME =  20 ,   //  50 M  = 20ns ;  200us = 200_000 ns ; delay for LDO stable 
	
	
	parameter   CS_WIDTH   =  1000		  //   x clk_period 
  
)
(
		input    wire                clk   ,   
		input    wire    				  rst_n      ,
 	   
		input	   wire                spi_finish  ,
		
      output   reg  [DATA_WIDTH  - 1:0]  spi_data	 ,
		output	reg					      spi_start  

   // output   reg                 config_done 		 
);

// ------- reg  define -----------
		reg     [24:0]   init_time  ;  
		reg     [3:0]    spi_cnt    ;
		reg     [31:0]   cs_width_cnt ;
      reg     [3:0]    data_flag  ;
		 
		reg     [3:0]    c_state    ;
      reg     [3:0]    n_state    ;
		
// -------- parameter define -----
		parameter    IDLE  = 4'd0 ;
		parameter    SHIFT = 4'd1 ;
		parameter    DONE  = 4'd2 ;
		
		parameter    REGISTER_0  = 16'h0E_00 ;
		parameter    REGISTER_1  = 16'h0D_00 ;
		parameter    REGISTER_2  = 16'h0C_07 ;
		parameter    REGISTER_3  = 16'h0B_02 ;
		parameter    REGISTER_4  = 16'h0A_10 ;
		parameter    REGISTER_5  = 16'h09_00 ;
		parameter    REGISTER_6  = 16'h08_00 ;
		parameter    REGISTER_7  = 16'h07_32 ;
		parameter    REGISTER_8  = 16'h06_10 ;
		parameter    REGISTER_9  = 16'h05_00 ;
		parameter    REGISTER_10  = 16'h04_0F ;
		parameter    REGISTER_11 = 16'h03_00 ;
		parameter    REGISTER_12 = 16'h02_00 ;
		parameter    REGISTER_13 = 16'h01_00 ;
		parameter    REGISTER_14 = 16'h00_00 ;

// -------- FSM - 1 ----------
		always @ (posedge clk )
			begin 
				if(!rst_n)
					c_state <= IDLE ;
				else 
				   c_state <= n_state ;
			end 

// --------- FSM - 2 ----------
		always @ (*)
			begin 
				case (c_state )
					IDLE  : n_state = ( init_time  == DELAY_TIME ) ? SHIFT : IDLE ;
					SHIFT : n_state = ( spi_cnt == SPI_MAX + 1  ) ? DONE : SHIFT ;
					DONE  : n_state = DONE ;
				 default : n_state = IDLE ;
				endcase 
			end 
 
 
// ------  init_time ----------
	always @ (posedge clk )
		begin 
			if( !rst_n )
				init_time <= 'd0 ;
			else if ( n_state == IDLE )
				begin 
					if( init_time < DELAY_TIME )
						init_time <= init_time + 'd1 ;
					else 
						init_time <= init_time  ;
				end 
			else 
				init_time <= init_time ;
		end 
		
// ------ spi_cnt ------------ 
	always @ (posedge clk )
		begin 
			if(!rst_n)
				spi_cnt <= 'd0 ;
			else if (spi_finish)
				spi_cnt <= spi_cnt + 'd1 ;
			else 
				spi_cnt <= spi_cnt ;
		end 

// ------ cs_width_cnt ---------
	always @ (posedge clk )
		begin 
			if(!rst_n)
				cs_width_cnt <= 'd0 ;
			else if ( n_state == SHIFT )
				if(spi_finish)
					cs_width_cnt <= 'd0 ;
				else if (cs_width_cnt < CS_WIDTH  ) 
					cs_width_cnt <= cs_width_cnt + 'd1 ;
				else 
					cs_width_cnt <= cs_width_cnt ;
			else 
				cs_width_cnt <= 'd0 ;
		end 


// ------- spi_start ---------
	always @ (posedge clk )
		begin 
			if(!rst_n)
				spi_start <= 1'b0 ;
			else if ( n_state == SHIFT)
				if( cs_width_cnt == CS_WIDTH - 1 )
					spi_start <= 1'b1 ;
				else 
					spi_start <= 1'b0 ; 
			else 
				spi_start <= 1'b0 ;
		end 
		
// ------- data_flag -------
	always @ ( posedge clk )
		begin 
			if(!rst_n)
				data_flag <= 'd0 ;
			else if ( spi_finish )
				data_flag <= data_flag + 'd1 ;
			else  
				data_flag <= data_flag ;
		end 
		
// ------ spi_data --------
	always @ (posedge clk )
		begin 
			if( !rst_n )
				spi_data <= 40'hff_ff_ff_ff_ff ;
			else if (n_state == SHIFT )
				case (data_flag)
					'd0 : spi_data <= REGISTER_0 ;
					'd1 : spi_data <= REGISTER_1 ;
					'd2 : spi_data <= REGISTER_2 ;
					'd3 : spi_data <= REGISTER_3 ;
					'd4 : spi_data <= REGISTER_4 ;
					'd5 : spi_data <= REGISTER_5 ;
					'd6 : spi_data <= REGISTER_6 ;
					'd7 : spi_data <= REGISTER_7 ;
					'd8 : spi_data <= REGISTER_8 ;
					'd9 : spi_data <= REGISTER_9 ;
					'd10 : spi_data <= REGISTER_10 ;
					'd11 : spi_data <= REGISTER_11 ;
					'd12 : spi_data <= REGISTER_12 ;
					'd13 : spi_data <= REGISTER_13 ;
					'd14 : spi_data <= REGISTER_14 ;
					
					
				default : data_flag <= data_flag ;
				endcase 
			else 
				spi_data <= 40'hff_ff_ff_ff_ff ;
	end 

endmodule
