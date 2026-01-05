class ahb_env_config extends uvm_object;

  `uvm_object_utils(ahb_env_config)
  	function new(string name="ahb_env_config");
		super.new(name);
	endfunction

	bit has_master_agent=1;
	bit has_slave_agent=1;
	int no_of_master_agents=1;
	int no_of_slave_agents=1;
	bit has_scoreboard=1;
  	bit has_coverage=1;
	bit has_virtual_sequencer =1;

	slave_config scfg[];
	master_config mcfg[];

	uvm_active_passive_enum is_active;
  
endclass
