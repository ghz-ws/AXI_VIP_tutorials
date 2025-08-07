`timescale 1ns / 1ps
import axi_vip_pkg::*;
import axi4_inter_axi_vip_0_0_pkg::*;    //mst1
import axi4_inter_axi_vip_0_1_pkg::*;    //mst2
import axi4_inter_axi_vip_2_0_pkg::*;    //slv1
import axi4_inter_axi_vip_2_1_pkg::*;    //slv2
module tb_axi4_inter();
    bit clk1, clk2, rst;
    logic [31:0]rdata1, rdata2, wdata1=$random, wdata2=$random;
    parameter base_addr=32'h44a0_0000;      //slave base address
    
    //VIP preparation
    xil_axi_resp_t resp;       //interface type declaration.
    axi4_inter_axi_vip_0_0_mst_t mst_ag1;    //agent name is mst_ag1.
    axi4_inter_axi_vip_0_1_mst_t mst_ag2;    //agent name is mast_ag2.
    axi4_inter_axi_vip_2_0_slv_mem_t slv_ag1;    //agent name is slv_ag1.
    axi4_inter_axi_vip_2_1_slv_mem_t slv_ag2;    //agent name is slv_ag2.
    
    always #5ns clk1<=!clk1;  //gen. 100MHz clk
    always #10ns clk2<=!clk2;  //gen. 50MHz clk
    initial begin
        #20ns
        rst<=1; //gen. rst. AXI is LO reset.
    end
    
    //main test
    initial begin
        mst_ag1=new("mst vip1",dut.axi4_inter_i.axi_vip_0.inst.IF);
        mst_ag2=new("mst vip2",dut.axi4_inter_i.axi_vip_1.inst.IF);
        slv_ag1=new("slv vip1",dut.axi4_inter_i.axi_vip_2.inst.IF);
        slv_ag2=new("slv vip2",dut.axi4_inter_i.axi_vip_3.inst.IF);
        mst_ag1.start_master();
        mst_ag2.start_master();
        slv_ag1.start_slave();
        slv_ag2.start_slave();
        
        //start AXI transactions
        #50ns
        mst_ag1.AXI4LITE_WRITE_BURST(base_addr+'h10000,0,wdata1,resp); //master1 write to slave1
        mst_ag2.AXI4LITE_WRITE_BURST(base_addr,0,wdata2,resp); //master2 write to slave2
        #100ns
        mst_ag1.AXI4LITE_READ_BURST(base_addr,0,rdata1,resp); //master1 read from slave2
        mst_ag2.AXI4LITE_READ_BURST(base_addr+'h10000,0,rdata2,resp); //master2 read from slave1
        $display("Master1 write=%d,Master2 write=%d, Master1 read=%d, Master2 read=%d",wdata1,wdata2,rdata1,rdata2);
        #50ns
        $finish;
    end
    axi4_inter_wrapper dut(.*); //DUT instanciation
endmodule
