module  my_gen_data (
    input   wire                   ui_clk ,
    input   wire                   rst ,
    
    input   wire                   empty ,
    input   wire                   full ,
    input   wire                   data_req ,
    
    output  wire                   wr_en ,
    output  wire    [255:0]        wr_data  
);
    reg                       wr_en_r ;
    reg     [255:0]           wr_data_r  ;
    
    assign                 wr_en      =   wr_en_r ;
    assign                 wr_data    = wr_data_r  ;

// ------------------ wr_start_r --------------    
    always @ (posedge ui_clk )
        begin    
            if(rst == 1'b1)
                wr_en_r <= 1'b0 ;
            else if ( full )
                wr_en_r <= 1'b0 ;
            else if( empty)
                wr_en_r <= 1'b1 ;
            else 
                wr_en_r <= wr_en_r ;
        end 
        
// --------------------- wr_data_r -------------------
    always @ ( posedge ui_clk )
        begin 
            if(rst == 1'b1)
                wr_data_r <= 1'b0 ;
            else if ( data_req )
                wr_data_r <= wr_data_r + 256'b1 ;
            else 
                wr_data_r <= wr_data_r ;
        end 
 endmodule 