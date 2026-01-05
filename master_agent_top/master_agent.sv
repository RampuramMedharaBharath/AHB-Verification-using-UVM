class master_agent extends uvm_agent;
  `uvm_component_utils(master_agent)
	master_config mcfg;
	master_driver drvh;
	master_monitor monh;
	master_seqr seqrh;

  function new(string name="master_agent",uvm_component parent);
		super.new(name,parent);
	endfunction 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      if(!uvm_config_db #(master_config)::get(this,"","master_config",mcfg))
			`uvm_fatal(get_type_name(),"getiing fatal")
			
		monh=master_monitor::type_id::create("monh",this);
      if(mcfg.is_active==UVM_ACTIVE)
		begin
		drvh=master_driver::type_id::create("drvh",this);
		seqrh=master_seqr::type_id::create("seqrh",this);
		end
	endfunction 			
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
      if(mcfg.is_active==UVM_ACTIVE)
		drvh.seq_item_port.connect(seqrh.seq_item_export);	endfunction 
endclass 

	
