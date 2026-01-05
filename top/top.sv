 import uvm_pkg::*;
		`include "uvm_macros.svh"
		//`include "ahb_pkg.sv"
		
  		`include "ahb_if.sv"
        `include "ahb_xtn.sv"
        `include "master_config.sv"
        `include "slave_config.sv"
        `include "ahb_env_config.sv"


        `include "master_driver.sv"
        `include "master_monitor.sv"
        `include "master_seqr.sv"
        `include "master_agent.sv"
        `include "master_agent_top.sv"
        `include "master_seqs.sv"

        //`include "read_xtn.sv"
        `include "slave_driver.sv"
        `include "slave_monitor.sv"
        `include "slave_seqr.sv"
        `include "slave_agent.sv"
        `include "slave_agent_top.sv"
        `include "slave_seqs.sv"

        //`include "fifo_virtual_sequencer.sv"
        //`include "fifo_virtual_seqs.sv"
        `include "ahb_sb.sv"
		`include "ahb_cov.sv"
        `include "ahb_tb.sv"

        `include "test.sv"
       
	
module top;
	
	//import ahb_pkg::*;
	//import uvm_pkg::*;
	bit hclk;
	bit HRESETn;
  
	always
		#5 hclk=~hclk;
  
	initial 
      begin
  		HRESETn=1;
  			#20;
  		HRESETn=0;
      end
  
  	ahb_if in(hclk,HRESETn);

  		
//    ahb dut(.hclk(in.hclk),.hresetn(in.HRESETn),.hwrite(in.HWRITE),.hready(in.HREADY),.hburst(in.HBURST),.hsize(in.HSIZE),.haddr(in.HADDR),.hwdata(in.HWDATA),.htrans(in.HTRANS),.hrdata(in.HRDATA),.hresp(in.HRESP),.hreadyout(in.HREADYOUT));
   ahb dut(.HCLK(in.hclk),.HRESETn(in.HRESETn),.HWRITE(in.HWRITE),.HREADY(in.HREADY),.HBURST(in.HBURST),.HSIZE(in.HSIZE),.HADDR(in.HADDR),.HWDATA(in.HWDATA),.HTRANS(in.HTRANS),.HRDATA(in.HRDATA),.HRESP(in.HRESP));//.HREADYOUT(in.HREADYOUT));
  
	initial begin
      uvm_config_db #(virtual ahb_if)::set(uvm_root::get(),"*","ahb_if",in); 
      run_test("wrap_test");
    end  
    
	initial 
      begin 
    $dumpvars(0,top);
    $dumpfile("dump.vcd"); 
  	end

endmodule
