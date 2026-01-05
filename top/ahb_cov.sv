class ahb_cov extends uvm_subscriber #(ahb_xtn);
  `uvm_component_utils(ahb_cov)
  uvm_tlm_analysis_fifo #(ahb_xtn) m_fifo[];
  uvm_tlm_analysis_fifo #(ahb_xtn) s_fifo[];
  		ahb_xtn xtn;
  		ahb_env_config ecfg;
  
  virtual function void write(ahb_xtn t);
    $cast(t,xtn);
  endfunction
  
  function new(string name="ahb_cov",uvm_component parent);
    super.new(name,parent);
     cg1=new();
  endfunction 
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(ahb_env_config)::get(this," ","ahb_env_config",ecfg))
			`uvm_fatal(get_type_name(),"getting failed in tb")
      m_fifo=new[ecfg.no_of_master_agents];
    s_fifo=new[ecfg.no_of_slave_agents];
    foreach(m_fifo[i])
      m_fifo[i]=new($sformatf("m_fifo[%0d]",i),this);
    foreach(s_fifo[i])
      s_fifo[i]=new($sformatf("s_fifo[%0d]",i),this);
  endfunction
  
  covergroup cg1;
    
    	option.per_instance=1;
		option.auto_bin_max=5;
    
		HADDR:coverpoint xtn.HADDR{
          				bins a1={[0:500]};
          				bins a2={[501:1000]};
          				bins a3={[1001:1500]};
          				bins a4={[1501:2047]};}
		HSIZE:coverpoint xtn.HSIZE{bins s1={0};
									bins s2={1};
									bins s3={2};}
    	HWRITE:coverpoint xtn.HWRITE{bins b1={1};
                                     bins b2={0};}
		HTRANS:coverpoint xtn.HTRANS{bins e1={2};
									bins e2={3};}
		addr_x_trans:cross HTRANS,HADDR;
	endgroup

  task run_phase(uvm_phase phase);
    forever
      begin 
        fork
          begin 
            m_fifo[0].get(xtn);
            cg1.sample();
          end
        join 
      end
  endtask 
        
endclass
