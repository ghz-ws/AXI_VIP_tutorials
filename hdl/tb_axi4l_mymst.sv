`timescale 1ns / 1ps
import axi_vip_pkg::*;
import axi4l_mymst_axi_vip_0_0_pkg::*;
module tb_axi4l_mymst();
    bit clk, rst, txn, rw;
    logic rvalid,busy;
    logic [31:0]addr=32'h44a0_0000, rdata, wdata=$random;
    
    xil_axi_resp_t resp;       //interface type declaration.
    axi4l_mymst_axi_vip_0_0_slv_mem_t slv_ag;   //agent name is slv_ag.
    
    always #5ns clk<=!clk;  //gen. 100MHz clk
    initial begin
        #10ns
        rst<=1; //gen. rst. AXI is LO reset.
    end
    
    initial begin
        slv_ag=new("slv vip",dut.axi4l_mymst_i.axi_vip_0.inst.IF);
        slv_ag.start_slave();
        
        #50ns
        txn<=1; //write
        #10ns
        txn<=0;
        #100ns
        rw<=1;  //read
        txn<=1;
        #10ns
        txn<=0;
        #150ns
        $display("Master write=%x,Master read=%x",wdata,rdata);
        #50ns
        $finish;
    end
    axi4l_mymst_wrapper dut(.*);    //DUT instanciation
endmodule
