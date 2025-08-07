module top(
    input mclk, ext_rst,    //12MHz clk(L17) is mclk, btn0(A18) is ext_rst
    output ld1,ld2,ld0_r,ld0_g,ld0_b,   //on board leds
    input uart_rx,  //J17
    output uart_tx, //J18
    input btn1 //B18
    );
    logic clk,locked;
    logic [1:0]gpio_out;
    assign ld1=gpio_out[0];
    assign ld2=gpio_out[1];
    assign ld0_r=1;
    assign ld0_g=1;
    assign ld0_b=1;
    
    clk_wiz_0 mmcm(
        .clk_out1(clk),     // output clk_out1
        .reset(ext_rst), // input reset
        .locked(locked),       // output locked
        .clk_in1(mclk)
    );
    
    axi_jtag_wrapper sub_top(
        .clk(clk),
        .rst(locked),
        .gpio_in(btn1),
        .gpio_out(gpio_out)
    );
    assign uart_tx=uart_tx;
    
    /*
    uart2axi_gpio_wrapper sub_top(
        .clk(clk),
        .rst(locked),
        .gpio_in(btn1),
        .gpio_out(gpio_out),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );
    */
endmodule
