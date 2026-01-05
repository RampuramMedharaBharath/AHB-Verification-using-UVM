class slave_agent_top extends uvm_env;
  `uvm_component_utils(slave_agent_top)
	ahb_env_config ecfg;
	slave_agent agt[];
	
  function new(string name="slave_agent_top",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      if(!uvm_config_db #(ahb_env_config)::get(this," ","ahb_env_config",ecfg))
			`uvm_fatal(get_type_name(),"getting fatal")
          agt=new[ecfg.no_of_slave_agents];
		foreach(agt[i])
			begin 
              agt[i]=slave_agent::type_id::create($sformatf("agt[%0d]",i),this);
              uvm_config_db #(slave_config)::set(this,"*","slave_config",ecfg.scfg[i]);
			end
		
	endfunction 
	 
endclass 

