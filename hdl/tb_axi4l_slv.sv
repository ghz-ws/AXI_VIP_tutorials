`timescale 1ns / 1ps
import axi_vip_pkg::*;
import axi4l_slv_axi_vip_0_0_pkg::*;
module tb_axi4l_slv();
    bit clk, rst;
    logic [31:0]gpio_in=$random, gpio_out, rdata, wdata=$random;
    parameter base_addr=32'h4000_0000;      //slave base address
    
    //VIP preparation
    xil_axi_resp_t resp;       //interface type declaration.
    axi4l_slv_axi_vip_0_0_mst_t mst_ag;    //declare master agent. agent name is mst_ag.
    
    always #5ns clk<=!clk;  //gen. 100MHz clk
    initial begin
        #10ns
        rst<=1; //gen. rst. AXI is LO reset.
    end
    
    //main test
    initial begin
        //agent preparation
        mst_ag=new("mst vip",dut.axi4l_slv_i.axi_vip_0.inst.IF);   //create new master agent
        mst_ag.start_master();    //start master agent
        
        //start AXI transactions
        #50ns
        mst_ag.AXI4LITE_READ_BURST(base_addr+'h0,0,rdata,resp);  //GPIO IN read
        $display("GPIO IN=%d, GPIO state=%d",rdata, gpio_in);
        
        #50ns
        mst_ag.AXI4LITE_WRITE_BURST(base_addr+'h8,0,wdata,resp); //GPIO OUT write
        $display("GPIO OUT=%d, GPIO state=%d",wdata, gpio_out);
        
        #50ns
        $finish;
    end
    
    //DUT instanciation
    axi4l_slv_wrapper dut(.*);
endmodule
