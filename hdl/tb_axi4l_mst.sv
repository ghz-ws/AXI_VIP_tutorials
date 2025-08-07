`timescale 1ns / 1ps
import axi_vip_pkg::*;
import axi4l_mst_axi_vip_0_0_pkg::*;    //mst
import axi4l_mst_axi_vip_1_0_pkg::*;    //slv
module tb_axi4l_mst();
    bit clk, rst;
    logic [31:0]mem_data, rdata, wdata=$random;
    parameter base_addr=32'h44a0_0000;      //slave base address
    
    //VIP preparation
    xil_axi_resp_t resp;       //interface type declaration.
    axi4l_mst_axi_vip_0_0_mst_t mst_ag;     //master agent name is mst_ag.
    axi4l_mst_axi_vip_1_0_slv_mem_t slv_ag; //slave agent name is slv_ag.
    
    always #5ns clk<=!clk;  //gen. 100MHz clk
    initial begin
        #10ns
        rst<=1; //gen. rst. AXI is LO reset.
    end
    
    //main test
    initial begin
        //agent preparation
        mst_ag=new("mst vip",dut.axi4l_mst_i.axi_vip_0.inst.IF);   //create new master agent
        slv_ag=new("slv vip",dut.axi4l_mst_i.axi_vip_1.inst.IF);   //create new slave agent
        mst_ag.start_master();    //start master agent
        slv_ag.start_slave();    //start slave agent
        
        //start AXI transactions
        #50ns
        mst_ag.AXI4LITE_WRITE_BURST(base_addr+'h0,0,wdata,resp); //master write to slave
        #50ns
        mem_data=slv_ag.mem_model.backdoor_memory_read(base_addr+'h0);    //read slave memory
        $display("Master write=%d,Slave memory=%d",wdata,mem_data);
        
        #50ns
        mem_data=$random;
        slv_ag.mem_model.backdoor_memory_write(base_addr+'h8,mem_data,4'b1111);    //write slave memory
        mst_ag.AXI4LITE_READ_BURST(base_addr+'h8,0,rdata,resp); //master read from slave
        $display("Master read=%d, Slave memory=%d",rdata,mem_data);
        
        #50ns
        $finish;
    end
    
    //DUT instanciation
    axi4l_mst_wrapper dut(.*);

endmodule
