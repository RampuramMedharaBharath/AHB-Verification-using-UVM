class master_agent_top extends uvm_env;
  `uvm_component_utils(master_agent_top)
	ahb_env_config ecfg;
	master_agent agt[];
	
  function new(string name="master_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
			super.build_phase(phase);
      if(!uvm_config_db #(ahb_env_config)::get(this," ","ahb_env_config",ecfg))
			`uvm_fatal(get_type_name(),"getting fatal")
          agt=new[ecfg.no_of_master_agents];
		foreach(agt[i])
			begin 
              agt[i]=master_agent::type_id::create($sformatf("agt[%0d]",i),this);
              uvm_config_db #(master_config)::set(this,"*","master_config",ecfg.mcfg[i]);
			end
		
	endfunction 
endclass

