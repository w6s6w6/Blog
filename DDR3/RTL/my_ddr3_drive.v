module my_ddr3_drive (
 
    input   wire                    ui_clk       ,
    input   wire                    rst        ,
// top   
    input   wire    [255:0]         wr_data      ,
    input   wire                    wr_en        ,
    output  wire    [255:0]         rd_data      ,
    output  wire                    rd_vld       ,
    output  wire                    full         ,
    output  wire                    empty        ,
    output  wire                    data_req     ,
// MIG 
    output  wire    [28:0]          app_addr     ,
    output  wire    [2:0]           app_cmd      ,
    output  wire                    app_en       ,
    output  wire    [255:0]         app_wdf_data ,
    output  wire                    app_wdf_end  ,
    output  wire    [31:0]          app_wdf_mask ,
    output  wire                    app_wdf_wren ,
    input   wire                    app_rdy      , 
    input   wire    [255:0]         app_rd_data  ,
    input   wire                    app_rd_data_end ,
    input   wire                    app_rd_data_vld ,
    input   wire                    app_wdf_rdy  ,
  
    input   wire                   init_calib_complete

);
// -------------  reg define ------------------
    reg     [27:0]                  addr    ;       // bank [2:0]     row [14:0]   col [9:0]
    reg     [3:0]                   state   ;
    
    
// ------------  parameter  ----------------------
    parameter               INIT = 4'd0 ;
    parameter               IDLE = 4'd1 ;
    parameter                WR  = 4'd2 ;
    parameter          ADDR_RSET = 4'd3 ;
    parameter                RD  = 4'd4 ;
    parameter              DONE  = 4'd5 ;
    
    parameter        TOTAL_PIXEL = 1024 * 768 - 8 ;
    parameter        BURST_LEN   = 64 - 1 ; 

// -------------------- assign -------------- 
    assign                          app_addr     = {1'b0,addr} ;
    assign                          app_cmd      = (state == RD ||state == ADDR_RSET )  ? 3'b001 : 3'b000 ;
    assign                          app_en       =  app_wdf_wren | state == RD ;
    assign                          app_wdf_data =  wr_data ;
    assign                          app_wdf_end  =  app_wdf_wren ;
    assign                          app_wdf_wren =  ((state == WR ) && app_rdy  && app_wdf_rdy) ? 1'b1 : 1'b0 ;
    assign                          app_wdf_mask =  31'b0 ;
  
    assign                          full     =    (state == ADDR_RSET || state == RD  || state == DONE || state == INIT ) ? 1'b1 : 1'b0 ;
    assign                          empty    =   ( state == IDLE && app_wdf_rdy &&app_rdy)? 1'b1 : 1'b0  ;
    assign                          data_req =   ( state == WR && app_wdf_rdy && app_rdy )? 1'b1 : 1'b0 ;  
    assign                          rd_data  = app_rd_data ;
    assign                          rd_vld   = app_rd_data_vld ;
    
// --------------------- fsm - 1 -----------------------
    always @ (posedge ui_clk )
        begin 
            if(rst == 1'b1)
                state <= INIT ;
            else 
                begin 
                    case ( state )
                        INIT :
                            begin 
                                if(init_calib_complete)
                                    state <= IDLE ;
                                else 
                                    state <= INIT  ;
                            end 
                        
                        IDLE : 
                            begin
                                if(wr_en)
                                    state <= WR ;
                                else 
                                    state <= IDLE ;
                            end 
                            
                        WR :    
                            begin 
                                if((addr == 'd80) && app_rdy ) 
                                    state <= ADDR_RSET ;
                                else 
                                    state <= WR ;
                            end 
                        
                        ADDR_RSET :
                            begin 
                                state <= RD ;
                            end 
                            
                        RD :  
                            begin 
                                if ((addr == 'd80) && app_rdy)
                                    state <= DONE ;
                                else 
                                    state <= RD ;
                            end 
                        
                        DONE :
                            state <= INIT ;
                        default : state <= INIT ;
                    endcase 
                end 
        end 
        
/*
    always @ ( * )
        begin 
            case ( c_state ) 
                INIT : n_state = init_calib_complete ? IDLE : INIT ;
                IDLE : n_state =  wr_en  ? WR : IDLE ;
                WR   : n_state =   ((addr == 'd80) && app_rdy ) ? ADDR_RSET : WR  ;
           ADDR_RSET : n_state = app_rdy ? RD : ADDR_RSET ;
                RD   : n_state = ((addr == 'd80) && app_rdy) ? DONE : RD ;
                DONE : n_state = IDLE ;
             default : n_state = IDLE ;
            endcase  
        end 
 
 */
 
    always @ (posedge ui_clk )
        begin 
            case (state )
                INIT :
                    begin 
                        addr    <= 28'b0 ;
                    end 
                    
                IDLE :
                    begin 
                        addr <= 28'b0    ;
                    end 
                WR : 
                    begin 
                        if(app_rdy && app_wdf_rdy)
                            addr <= addr + 8 ;
                        else 
                           addr <= addr ;
                    end 
                    
              ADDR_RSET : 
                    begin 
                         addr <= 28'b0 ;
                    end 
                    
                RD : 
                    begin 
                            if(app_rdy && app_en )
                                addr <= addr + 8 ;
                            else 
                                addr <= addr ;
                    end 
                        
                DONE :
                    begin 
                        addr <= 28'b0 ;
                    end 
                default : 
                    begin                       
                        addr <= 28'b0 ;
                    end 
            endcase 
        end 
   endmodule