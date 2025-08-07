`timescale 1ns / 1ps
module tb_uart2axi_sm();
    bit clk, rst=1, act;
    logic [7:0]tx_data;
    logic axi_busy=0, busy_dummy, rvalid=1, t2r, r2t, txn, rw;
    logic [31:0]addr, wdata, rdata;
    
    always #5ns clk<=!clk;
    
    initial begin
        #20ns
        rst<=0;
        #20ns
        send(8'b01000010);  //cmd
        four_byte_send($random);    //addr
        four_byte_send($random);
        four_byte_send($random);
        four_byte_send($random);
        #1ms
        send(8'b10000001);  //cmd
        four_byte_send($random);    //addr
        #1ms
        $finish;
    end
    
    uart2axi_sm dut(.*,.rx_line(t2r),.tx_line(r2t));
    uart_tx tx(.*,.tx_line(t2r),.busy(busy_dummy));
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
