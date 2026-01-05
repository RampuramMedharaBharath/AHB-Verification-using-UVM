class ahb_tb extends uvm_env;
	
	ahb_env_config ecfg;
	master_agent_top magnt;
	slave_agent_top sagnt;
	ahb_sb  sb;
  	ahb_cov cb;
	
  `uvm_component_utils(ahb_tb)

  function new(string name="ahb_tb", uvm_component parent);
		super.new(name, parent);
	endfunction 
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

      if(!uvm_config_db #(ahb_env_config)::get(this," ","ahb_env_config",ecfg))
			`uvm_fatal(get_type_name(),"getting failed in tb")
	
        if(ecfg.has_master_agent)
          magnt=master_agent_top::type_id::create("magnt",this);
      if(ecfg.has_slave_agent)		
        sagnt=slave_agent_top::type_id::create("sagnt",this);
		if(ecfg.has_scoreboard)
			sb=ahb_sb::type_id::create("sb",this);
        if(ecfg.has_coverage)
          	cb=ahb_cov::type_id::create("cb",this);
			
	endfunction 

	function void connect_phase(uvm_phase phase);
     // super.connect_phase(phase);
      if(ecfg.has_scoreboard)
			begin
              foreach(magnt.agt[i])
                magnt.agt[i].monh.ap.connect(sb.m_fifo[i].analysis_export);
              foreach(sagnt.agt[i])
                sagnt.agt[i].monh.ap.connect(sb.s_fifo[i].analysis_export);
			end
      if(ecfg.has_coverage)
			begin
              foreach(magnt.agt[i])
                magnt.agt[i].monh.ap.connect(cb.m_fifo[i].analysis_export);
              foreach(sagnt.agt[i])
                sagnt.agt[i].monh.ap.connect(cb.s_fifo[i].analysis_export);
			end

	endfunction
	
endclass
