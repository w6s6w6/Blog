`timescale 1ns/1ns
module tb_gen_data ( );
    reg             ui_clk ;
    reg             rst    ;
    reg             empty  ;
    reg             full   ;
    wire            wr_en  ;
    wire  [255:0]   wr_data ;
    
    parameter T = 4 ;
        
    always # (T/2)  ui_clk = ~ui_clk ;
    
    initial  begin 
      ui_clk <= 1'b0 ;
      rst    <= 1'b0 ;
      full   <= 1'b1 ;
      empty  <= 1'b0 ;
      # (100*T)
      rst    <= 1'b1 ;
      # (100*T)
      full  <= 1'b0 ;
      empty <= 1'b1 ;
      
    end 
    
    my_gen_data   u_gen (
        .ui_clk (ui_clk) ,
        .rst    (rst),
        .empty (empty),
        .full  (full) ,
        .wr_en (wr_en) ,
        .wr_data(wr_data)
    );
        
        endmodule 
    