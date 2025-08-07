`timescale 1ns / 1ps
module tb_top();
    bit mclk,ext_rst,btn1=1;
    logic ld1,ld2,ld0_r,ld0_g,ld0_b;
    bit act,clk,rst=1;
    logic t2r,r2t,busy_dummy;
    bit [7:0]tx_data;
    parameter base_addr=32'h4000_0000;      //slave base address
    
    always #42ns mclk<=!mclk;   //gen. 12MHz clk
    always #5ns clk<=!clk;  //gen 100MHz clk
    
    //main test
    initial begin
        #10ns
        rst<=0;
        @(posedge dut.locked);
        #10us
        
        //start AXI transactions
        #100ns
        send(8'b01000000);  //cmd
        four_byte_send(base_addr+8);    //addr
        four_byte_send('b11);
        #300us
        send(8'b10000000);  //cmd
        four_byte_send(base_addr);    //addr
        #300us
        $finish;
    end
    
    //DUT instanciation
    top dut(
        .mclk(mclk),
        .ext_rst(ext_rst),
        .uart_rx(t2r),
        .uart_tx(r2t),
        .ld1(ld1),
        .ld2(ld2),
        .ld0_r(ld0_r),
        .ld0_g(ld0_g),
        .ld0_b(ld0_b),
        .btn1(btn1)
        );
        
    uart_tx tx(.*,.act(act),.tx_data(tx_data),.tx_line(t2r),.busy(busy_dummy));
    uart_rx rx(.*,.rx_line(r2t),.busy(),.valid(),.err(),.rx_data());
    
    task send;
        input [7:0]data;
        begin
            tx_data<=data;
            #10ns
            act<=1;
            #20ns
            act<=0;
            @(negedge busy_dummy);
            #20ns
            act<=0;
        end
    endtask
    
    task four_byte_send;
        input [31:0]data;
        begin
            send(data[7:0]);
            send(data[15:8]);
            send(data[23:16]);
            send(data[31:24]);
            $display("Send: %x",data);
        end
    endtask
        
endmodule
