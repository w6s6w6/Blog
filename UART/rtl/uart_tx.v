module uart_tx (
    input   wire [7:0]  rx_data , 
    input   wire        rx_done ,
    input   wire        sys_clk ,
    input   wire        sys_rst_n ,
    output  reg        tx_port  
);
    parameter CLK_PER_BIT = 20833 ;   // 200M / 9600
    parameter IDLE   = 4'd0 ;
    parameter LOAD   = 4'd1 ;
    parameter DONE   = 4'd2 ;
    
    wire start_flag ;
    
    reg  delay_a ;
    reg  delay_b ;
    reg  [7:0]   data_reg ;
    reg  [19:0]  clk_cnt ;
    reg  [7:0]   data_cnt ;
    reg  tx_flag ;
    reg  [3:0]  current_state ;
    reg  [3:0]  next_state ;
    
    //------- delay_a / delay_b ------
    //-------- delay two clk periods , remove metastability ---- 
    always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                begin 
                    delay_a <= 1'b0 ;
                    delay_b <= 1'b0 ;
                end 
            else 
                begin 
                    delay_a <= rx_done ;
                    delay_b <= delay_a ;
                end 
        end 
        
    //------------- data_reg --------------------    
    always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                data_reg <= 8'd0 ;
            else if(tx_flag)
                data_reg <= rx_data ;
            else if(!tx_flag)
                data_reg <= 8'd0 ;
            else 
                data_reg <= data_reg ;
        end 
                
        
   // --------- start_flag -----------
    assign start_flag = delay_a && ~delay_b ;
    
  //  ---------- tx_flag -------------
    always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                tx_flag <= 1'b0 ;
            else if (start_flag)
                tx_flag <= 1'b1 ;
            else if ((clk_cnt == CLK_PER_BIT /2 ) && (data_cnt == 4'd9 ))
                tx_flag <= 1'b0 ;
            else 
                tx_flag <= tx_flag ;
        end 
        
   // ---------- clk_cnt / data_cnt  ----------
   always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                begin 
                    clk_cnt <= 20'd0 ;
                    data_cnt <= 4'd0 ;
                end 
            else if (tx_flag)
                begin 
                    if(clk_cnt < CLK_PER_BIT - 1)
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
            
   // -------- FSM - 1 ------------------
        always @ (posedge sys_clk or negedge sys_rst_n)
            begin 
                if(!sys_rst_n)
                    current_state <= IDLE ;
                else 
                    current_state <= next_state ;
            end 
          
   // --------- FSM-2 ---------------------
    always @ (*)
        begin 
            case (current_state)
                IDLE :   next_state = tx_flag? LOAD : IDLE ;
                LOAD :   next_state = !tx_flag ? DONE : LOAD ;
                DONE :   next_state = IDLE ;
                default: next_state =IDLE ;
            endcase 
        end 
        
   // -------- FSM-3 -----------------------
    always @ (posedge sys_clk or negedge sys_rst_n)
        begin 
            if(!sys_rst_n)
                tx_port <= 1'b1 ;
            else 
                begin 
                    case (next_state)
                        IDLE :
                            tx_port <= 1'b1 ;
                        
                        LOAD :
                                case (data_cnt)
                                    8'd0 : tx_port <= 1'b0 ;
                                    8'd1 : tx_port <= data_reg [0] ;
                                    8'd2 : tx_port <= data_reg [1] ;
                                    8'd3 : tx_port <= data_reg [2] ;
                                    8'd4 : tx_port <= data_reg [3] ;
                                    8'd5 : tx_port <= data_reg [4] ;
                                    8'd6 : tx_port <= data_reg [5] ;
                                    8'd7 : tx_port <= data_reg [6] ;
                                    8'd8 : tx_port <= data_reg [7] ;
                                    8'd9 : tx_port <= 1'b1 ;
                                   default : ;
                                endcase 
                               
                       DONE :
                            tx_port <= 1'b1 ;
                    default : tx_port <= 1'b1 ;
                    endcase 
                end  
        end 
        
        ila_0 uart_rx_ila (
            .clk(sys_clk), // input wire clk


            .probe0(tx_flag), // input wire [0:0]  probe0  
            .probe1(start_flag), // input wire [0:0]  probe1 
            .probe2(rx_done), // input wire [0:0]  probe2 
            .probe3(tx_port), // input wire [0:0]  probe3 
            .probe4(data_reg), // input wire [7:0]  probe4 
            .probe5(data_cnt), // input wire [7:0]  probe5 
            .probe6(clk_cnt), // input wire [19:0]  probe6 
            .probe7(current_state) // input wire [3:0]  probe7
        );
        
        
    endmodule     
    
              
              
                    
                            
                        