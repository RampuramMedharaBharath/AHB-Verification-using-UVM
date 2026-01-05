class slave_agent extends uvm_agent;
  `uvm_component_utils(slave_agent)
		slave_config scfg;
	slave_driver drvh;
	slave_monitor monh;
	slave_seqr seqrh;


  function new(string name="slave_agent",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      if(!uvm_config_db #(slave_config)::get(this,"","slave_config",scfg))
			`uvm_fatal(get_type_name(),"getiing fatal")
			
		monh=slave_monitor::type_id::create("monh",this);
      if(scfg.is_active==UVM_ACTIVE)
		 begin  
		drvh=slave_driver::type_id::create("drvh",this);
		seqrh=slave_seqr::type_id::create("seqrh",this);
		 end  
	endfunction  
  function void connect_phase(uvm_phase phase);
    if(scfg.is_active==UVM_ACTIVE)
      drvh.seq_item_port.connect(seqrh.seq_item_export);
  endfunction 
endclass 

