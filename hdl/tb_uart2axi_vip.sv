`timescale 1ns / 1ps
import axi_vip_pkg::*;
import uart2axi_vip_axi_vip_0_0_pkg::*;    //slv vip
module tb_uart2axi_vip();
    bit clk,rst=1,act;
    logic t2r,r2t,busy_dummy;
    bit [7:0]tx_data, rx_data;
    logic [31:0]mem_data;
    parameter base_addr=32'h44a0_0000;      //slave base address
    
    xil_axi_resp_t resp;       //interface type declaration.
    uart2axi_vip_axi_vip_0_0_slv_mem_t slv_ag;    //agent name is slv_ag.
    
    always #5ns clk<=!clk;  //gen. 100MHz clk
    initial begin
        #10ns
        rst<=0; //gen. rst. AXI is LO reset. other is HI rst.
    end
    
    //main test
    initial begin
        slv_ag=new("slv vip",dut.uart2axi_vip_i.axi_vip_0.inst.IF);
        slv_ag.start_slave();
        
        //start AXI transactions
        #50ns
        send(8'b01000010);  //write cmd
        four_byte_send( base_addr);    //addr
        four_byte_send($random);
        four_byte_send($random);
        four_byte_send($random);
        #500us
        slv_disp(base_addr);
        slv_disp(base_addr+4);
        slv_disp(base_addr+8);
        #1us
        send(8'b10000010);  //read cmd
        four_byte_send(base_addr);    //addr
        #1.5ms
        $finish;
    end
    
    uart2axi_vip_wrapper dut(   //DUT instanciation
        .clk(clk),
        .rst(!rst),
        .uart_rx(t2r),
        .uart_tx(r2t)
        );
        
    uart_tx tx(.*,.act(act),.tx_data(tx_data),.tx_line(t2r),.busy(busy_dummy));
    uart_rx rx(.*,.rx_line(r2t),.busy(),.valid(),.err(),.rx_data(rx_data));
    
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
    
    task slv_disp;
        input [31:0]addr;
        begin
            mem_data=slv_ag.mem_model.backdoor_memory_read(addr);    //read slave memory
            $display("Slave Addr=%x,Data=%x",addr,mem_data);
        end
    endtask
endmodule
