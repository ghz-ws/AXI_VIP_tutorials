`timescale 1ns / 1ps
import axi_vip_pkg::*;
import axi4f_slv_axi_vip_0_0_pkg::*;
module tb_axi4f_slv();
    bit clk, rst;
    logic[127:0] rdata, wdata={$random,$random,$random,$random}; //32bit*4
    parameter base_addr=32'hC000_0000;      //slave base address
    
    //VIP IF
    xil_axi_size_t size=XIL_AXI_SIZE_4BYTE; //bus width = 4byte
    xil_axi_burst_t BurstType=XIL_AXI_BURST_TYPE_INCR;  //burst address increment
    xil_axi_lock_t lock=XIL_AXI_ALOCK_NOLOCK;
    xil_axi_cache_t CacheType=0; xil_axi_prot_t prot=3'b000;
    xil_axi_region_t region=4'b000;
    xil_axi_qos_t QOS=4'b0000;
    xil_axi_user_beat AWUSER='h0;
    xil_axi_data_beat [255:0]WUSER='b0;
    xil_axi_resp_t Bresp;
    xil_axi_user_beat ARUSER='h0;
    xil_axi_resp_t [255:0]Rresp;
    xil_axi_data_beat [255:0]RUSER;
    
    axi4f_slv_axi_vip_0_0_mst_t mst_ag;    //agent name is mst_ag.
    
    always #5ns clk<=!clk;  //gen. 100MHz clk
    initial begin
        #10ns
        rst<=1; //gen. rst. AXI is LO reset.
    end
    
    //main test
    initial begin
        mst_ag=new("mst vip",dut.axi4f_slv_i.axi_vip_0.inst.IF);
        mst_ag.start_master();
        
        //start AXI transactions
        #50ns
        mst_ag.AXI4_WRITE_BURST(1,base_addr,3,size,BurstType,lock,CacheType,prot,region,QOS,AWUSER,wdata,WUSER,Bresp);
        #50ns
        mst_ag.AXI4_READ_BURST(1,base_addr,3,size,BurstType,lock,CacheType,prot,region,QOS,ARUSER,rdata,Rresp,RUSER);
        $display("Write=%x, Read=%x",wdata,rdata);
        #50ns
        $finish;
    end
    axi4f_slv_wrapper dut(.*);  //DUT instanciation
endmodule
