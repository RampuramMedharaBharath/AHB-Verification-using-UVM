class test extends uvm_test;
        `uvm_component_utils(test)
        ahb_tb envh;
        ahb_env_config ecfg;
        master_config mcfg[];
        slave_config scfg[];

        bit has_master_agent=1;
        bit has_slave_agent=1;
        int no_of_master_agents=1;
        int no_of_slave_agents=1;
        bit has_scoreboard=1;


        function new(string name="test", uvm_component parent);
                super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);

                ecfg=ahb_env_config::type_id::create("ecfg");
          mcfg=new[ecfg.no_of_master_agents];
          ecfg.mcfg=new[ecfg.no_of_master_agents];
          		if(has_master_agent)
                        begin
                          foreach(mcfg[i])
                                begin
       							mcfg[i]=master_config::type_id::create($sformatf("mcfg[%0d]",i));
                                mcfg[i].is_active=UVM_ACTIVE;
                                  if(!uvm_config_db #(virtual ahb_if)::get(this," ","ahb_if",mcfg[i].vif))
                                    `uvm_fatal(get_type_name(),"the interface is not getting");
                                  ecfg.mcfg[i]=mcfg[i];
                                end


                        end

          scfg=new[ecfg.no_of_slave_agents];
          ecfg.scfg=new[ecfg.no_of_slave_agents];
          		if(has_slave_agent)
                        begin
                          foreach(scfg[i])
                                begin
                                scfg[i]=slave_config::type_id::create($sformatf("scfg[%0d]",i));
                                  scfg[i].is_active=UVM_ACTIVE;
                                  if(!uvm_config_db #(virtual ahb_if)::get(this," ","ahb_if",scfg[i].vif))
                                    `uvm_fatal(get_type_name(),"the interface is not getting");
                                  ecfg.scfg[i]=scfg[i];
                                end
                        end

                envh=ahb_tb::type_id::create("envh",this);

                ecfg.has_master_agent=has_master_agent;
                ecfg.has_slave_agent=has_slave_agent;
                ecfg.has_scoreboard=has_scoreboard;
              	ecfg.no_of_master_agents=no_of_master_agents;
                ecfg.no_of_slave_agents=no_of_slave_agents;
          
          uvm_config_db #(ahb_env_config)::set(this,"*","ahb_env_config",ecfg);
        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
                //uvm_top.print_topology();
        endfunction

endclass


class write_test extends test;
  `uvm_component_utils(write_test)
  master_seqs s1;
  function new(string name="write_test",uvm_component parent);
    super.new(name,parent);
  endfunction 
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    s1=master_seqs::type_id::create("s1");
    s1.start(envh.magnt.agt[0].seqrh);
    phase.phase_done.set_drain_time(this,150);
    phase.drop_objection(this);
    //#100;
  endtask 
endclass

class unincr_test extends test;
  `uvm_component_utils(unincr_test)
  unincr_seqs s1;
  function new(string name="unincr_test",uvm_component parent);
    super.new(name,parent);
  endfunction 
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    s1=unincr_seqs::type_id::create("s1");
    s1.start(envh.magnt.agt[0].seqrh);
    //phase.phase_done.set_drain_time(this,30);
    phase.drop_objection(this);
  endtask 
endclass

class incr_test extends test;
  `uvm_component_utils(incr_test)
  incr_seqs s1;
  function new(string name="incr_test",uvm_component parent);
    super.new(name,parent);
  endfunction 
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    s1=incr_seqs::type_id::create("s1");
    s1.start(envh.magnt.agt[0].seqrh); 
    phase.phase_done.set_drain_time(this,20);
    phase.drop_objection(this);
  endtask 
endclass

class wrap_test extends test;
  `uvm_component_utils(wrap_test)
  wrap_seqs s1;
  function new(string name="wrap_test",uvm_component parent);
    super.new(name,parent);
  endfunction 
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    s1=wrap_seqs::type_id::create("s1");
    s1.start(envh.magnt.agt[0].seqrh);
    phase.phase_done.set_drain_time(this,500);
    phase.drop_objection(this);
  endtask 
endclass

class regress_test extends test;
  `uvm_component_utils(regress_test)
   master_seqs 	s1;
   unincr_seqs 	s2;
   incr_seqs 	s3;
   wrap_seqs 	s4;
  function new(string name="regress_test",uvm_component parent);
    super.new(name,parent);
  endfunction 
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    s1=master_seqs::type_id::create("s1");
    s2=unincr_seqs::type_id::create("s2");
    s3=incr_seqs::type_id::create("s1");
    s4=wrap_seqs::type_id::create("s4");
    fork
    s1.start(envh.magnt.agt[0].seqrh);
    s2.start(envh.magnt.agt[0].seqrh);
    s3.start(envh.magnt.agt[0].seqrh);
    s4.start(envh.magnt.agt[0].seqrh);
    join
    phase.phase_done.set_drain_time(this,20);
    phase.drop_objection(this);
  endtask 
endclass
