module uart_top(
        input   wire    clk_n ,
        input   wire    clk_p ,
        input   wire    rx_port ,
        input   wire    sys_rst_n,
        output  wire     tx_port 
    );
    wire [7:0] rx_data ;
    wire done_flag ;

    uart_rx u_rx (
        .sys_clk (sys_clk),
        .sys_rst_n(sys_rst_n),
        .rx_port(rx_port),
        .data_reg(rx_data),
        .rx_done(done_flag)
    );
    
    clk_gen u_clk (
        .clk_p(clk_p),
        .clk_n(clk_n),
        .sys_clk(sys_clk)
    );
    
    uart_tx  u_tx(
        .sys_clk(sys_clk),
        .rx_data (rx_data),
        .rx_done(done_flag),
        .sys_rst_n(sys_rst_n),
        .tx_port(tx_port)
        
    );
    
    endmodule 