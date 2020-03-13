
module uart_rx (
    input   wire      sys_clk ,
    input   wire      sys_rst_n ,
    input   wire      rx_port ,
    output  reg  [7:0] data_reg ,
    output  reg       rx_done 
 );
    parameter   CLK_PER_BIT = 20832 ;     // 200M / 9600 Baud
    parameter   IDLE = 4'd0 ;
    parameter   LOAD = 4'd1 ;
    parameter   DONE = 4'd2 ;
    
    reg         delaya ;
    reg         delayb ;
    reg         rx_flag ;
    reg  [19:0]  clk_cnt ;
    reg  [7:0]   data_cnt ;
    reg  [3:0]   current_state ;
    reg  [3:0]   next_state ;
    
    wire        start_flag ;
        
    //------- capture start_bit--------- 
    assign  start_flag = ~delaya && delayb ; 
    
    // ------- delaya / delayb --------
    always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                begin 
                    delaya <= 1'b0 ;
                    delayb <= 1'b0 ;
                end 
            else 
                begin 
                    delaya <= rx_port;
                    delayb <= delaya ;
                end 
        end 
        
    // ---------- rx_flag --------------
    always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                rx_flag <= 1'b0 ;
            else if (start_flag )
                rx_flag <= 1'b1 ;
            else if ((clk_cnt == CLK_PER_BIT /2) && (data_cnt == 8'd9 ) )
                rx_flag <= 1'b0 ;
            else 
                rx_flag <= rx_flag ;
        end 
    
    // -------------- clk_cnt / data_cnt------------------
    always @ (posedge sys_clk or negedge sys_rst_n)    
        begin 
            if(!sys_rst_n)
                begin 
                    clk_cnt <= 20'd0 ;
                    data_cnt <= 8'd0 ;
                end 
            else 
                begin 
                    if(rx_flag)
                        begin 
                            if(clk_cnt <= CLK_PER_BIT - 1 )
                                begin 
                                    clk_cnt <= clk_cnt + 20'd1 ;
                                    data_cnt <= data_cnt ;
                                end 
                            else
                                begin 
                                    clk_cnt <= 20'd0 ;
                                    data_cnt <= data_cnt + 8'd1 ;
                                end 
                          end 
                    else 
                        begin 
                            clk_cnt <= 20'd0 ;
                            data_cnt <= 8'd0 ;
                        end 
                end 
        end          
       
    // ---------------- fsm - 1  ---------------
    always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                current_state <= IDLE ;
           else 
                current_state <= next_state ;
        end 
        
    // ---------------- fsm-2  ------------------
    
    always @ (*)
        begin 
            case (current_state)
                IDLE : next_state = rx_flag ? LOAD : IDLE ;
                LOAD : next_state = !rx_flag ? DONE : LOAD ;
                DONE : next_state = IDLE ;
                default : next_state = IDLE ;
            endcase 
        end 
        
    // -------------- FSM-3 -------------------
    always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                begin 
                    rx_done <= 1'b0 ;
                    data_reg <= 8'd0 ;
                end 
            else 
                begin 
                    case (next_state) 
                        IDLE : 
                            begin 
                                rx_done <= 1'b0 ;
                                data_reg <= data_reg ;
          
                            end 
                         
                         LOAD :
                            begin 
                                rx_done <= 1'b0 ;
                                if(clk_cnt == CLK_PER_BIT /2 )
                                    case (data_cnt)
                                    8'd1 : data_reg[0] <= rx_port ;
                                    8'd2 : data_reg[1] <= rx_port ;
                                    8'd3 : data_reg[2] <= rx_port ;
                                    8'd4 : data_reg[3] <= rx_port ;
                                    8'd5 : data_reg[4] <= rx_port ;
                                    8'd6 : data_reg[5] <= rx_port ;
                                    8'd7 : data_reg[6] <= rx_port ;
                                    8'd8 : data_reg[7] <= rx_port ;
                                    default :  ;
                                 endcase
                                else 
                                    data_reg <= data_reg ; 
                             end 
                             
                          DONE :
                            begin 
                               data_reg <= data_reg ;
                               rx_done <= 1'b1 ;
                            end                            
                        default :
                            begin 
                                rx_done <= 1'b0 ;
                                data_reg <= data_reg ;
                            end 
                     endcase
                end 
        end 
     
        
    endmodule 