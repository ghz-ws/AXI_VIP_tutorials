`timescale 1ns / 1ps
import axi_vip_pkg::*;
import axi4f_mst_axi_vip_0_0_pkg::*;    //mst
import axi4f_mst_axi_vip_1_0_pkg::*;    //slv
module tb_axi4f_mst();
    bit clk, rst;
    logic[127:0] rdata, wdata={$random,$random,$random,$random}, mem_data;
    parameter base_addr=32'h44a0_0000;      //slave base address
    
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
    
    axi4f_mst_axi_vip_0_0_mst_t mst_ag;    //master agent name is mst_ag.
    axi4f_mst_axi_vip_1_0_slv_mem_t slv_ag;    //slave agent name is slv_ag.
    
    always #5ns clk<=!clk;  //gen. 100MHz clk
    initial begin
        #10ns
        rst<=1; //gen. rst. AXI is LO reset.
    end
    
    //main test
    initial begin
        mst_ag=new("mst vip",dut.axi4f_mst_i.axi_vip_0.inst.IF);
        slv_ag=new("slv vip",dut.axi4f_mst_i.axi_vip_1.inst.IF);
        mst_ag.start_master();
        slv_ag.start_slave();
        
        //start AXI transactions
        #50ns
        mst_ag.AXI4_WRITE_BURST(1,base_addr,3,size,BurstType,lock,CacheType,prot,region,QOS,AWUSER,wdata,WUSER,Bresp);  //master write to slave
        #50ns
        mem_data[31:0]=slv_ag.mem_model.backdoor_memory_read(base_addr);    //read slave memory
        mem_data[63:32]=slv_ag.mem_model.backdoor_memory_read(base_addr+4);
        mem_data[95:64]=slv_ag.mem_model.backdoor_memory_read(base_addr+8);
        mem_data[127:96]=slv_ag.mem_model.backdoor_memory_read(base_addr+12);
        $display("Master write=%x,Slave memory=%x",wdata,mem_data);
        
        #50ns
        mem_data={$random,$random,$random,$random};
        slv_ag.mem_model.backdoor_memory_write(base_addr,mem_data[31:0],4'b1111);    //write slave memory
        slv_ag.mem_model.backdoor_memory_write(base_addr+4,mem_data[63:32],4'b1111);
        slv_ag.mem_model.backdoor_memory_write(base_addr+8,mem_data[95:64],4'b1111);
        slv_ag.mem_model.backdoor_memory_write(base_addr+12,mem_data[127:96],4'b1111);
        mst_ag.AXI4_READ_BURST(1,base_addr,3,size,BurstType,lock,CacheType,prot,region,QOS,ARUSER,rdata,Rresp,RUSER);
        $display("Master read=%x, Slave memory=%x",rdata,mem_data);
        #50ns
        $finish;
    end
    axi4f_mst_wrapper dut(.*);  //DUT instanciation
endmodule
