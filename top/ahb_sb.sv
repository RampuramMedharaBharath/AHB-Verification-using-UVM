class ahb_sb extends uvm_scoreboard;

  `uvm_component_utils(ahb_sb)
  uvm_tlm_analysis_fifo #(ahb_xtn) m_fifo[];
  uvm_tlm_analysis_fifo #(ahb_xtn) s_fifo[];
	
	 ahb_env_config ecfg;

  	ahb_xtn mxtn,sxtn;
  bit [31:0] mem[bit[31:0]];
  bit [31:0] expected_data;
  
  function new(string name="ahb_sb" , uvm_component parent);
		super.new(name,parent);
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
  
  
  task run_phase(uvm_phase phase);
   
    fork
      begin
        forever begin
          fork 
          begin
            	m_fifo[0].get(mxtn);
            //mxtn.print();
            //$display(" master haddr=%0h,hwdata=%0h",mxtn.HADDR,mxtn.HWDATA);
    
          end
          begin
           		s_fifo[0].get(sxtn);
            //sxtn.print();
            //$display(" slave haddr=%0h,hrdata=%0h",sxtn.HADDR,sxtn.HRDATA);
          end
          join
          check_data(mxtn,sxtn);
     
        end
      end
    join
   
  endtask
  
    task check_data(ahb_xtn mas_xtn,ahb_xtn slv_xtn);
			begin:a
              if(mas_xtn.HSIZE==3'b000)
				begin:b 
                          if(mas_xtn.HADDR==slv_xtn.HADDR)
							begin:l
                              `uvm_info("ADDR MATCHED","addr matched",UVM_LOW)
                              if(mas_xtn.HWRITE==1)
                                begin :d
                                  mem[mas_xtn.HADDR]=mas_xtn.HWDATA[7:0];
                                  //$display("wdata=%0h",mem[mas_xtn.HADDR]);
                                  if(mem.exists(mas_xtn.HADDR)) 
                                    $display("ADDR = %0h  DATA = %0h",mas_xtn.HADDR,mem[mas_xtn.HADDR]);
                                end :d
                              else
                                begin:h
                                  if(mem.exists(mas_xtn.HADDR))
                                    begin:g
                                      expected_data=mem[mas_xtn.HADDR];
                                      if(expected_data!= slv_xtn.HRDATA[7:0])
                                        begin:e 
                                          `uvm_info("DATA NOT MATCHED","data not matched",UVM_LOW)
                                          $display("expected data=%0h,rdata =%0h",expected_data,slv_xtn.HRDATA[7:0]);
                                        end:e
                                      else 
                                        begin :f    
                                          `uvm_info("DATA MATCHED","data matched",UVM_LOW)
                                          //$display("expected data=%0h,rdata =%0h",expected_data,slv_xtn.HRDATA[7:0]);
                                        end:f
                                    end:g
                                end:h
            				end :l
						  else
                            `uvm_info("ADDR NOT MATCHED","addr unmatched",UVM_LOW)
 				end:b
              if(mas_xtn.HSIZE==3'b001)
				begin:a5
                          if(mas_xtn.HADDR==slv_xtn.HADDR)
							begin:g5
                              `uvm_info("ADDR MATCHED","addr matched",UVM_LOW)
                              if(mas_xtn.HWRITE==1)
                                begin:b5
                                  mem[mas_xtn.HADDR]=mas_xtn.HWDATA[15:0];
//                                   if(mem.exists(mas_xtn.HADDR)) 
//                                     $display("ADDR = %0h  DATA = %0h",mas_xtn.HADDR,mem[mas_xtn.HADDR]);
                                end :b5
                              else
                                begin:f5
                                  if(mem.exists(mas_xtn.HADDR))
                                    begin :e5
                                      expected_data=mem[mas_xtn.HADDR];
                                      if(expected_data!= slv_xtn.HRDATA[15:0])
                                        begin :c5
                                          `uvm_info("DATA NOT MATCHED","data not matched",UVM_LOW)
                                          //$display("expected data=%0h,rdata =%0h",expected_data,slv_xtn.HRDATA[7:0]);
                                        end:c5
                                      else 
                                        begin :d5
                                          `uvm_info("DATA MATCHED","data matched",UVM_LOW)
                                        end:d5
                                    end:e5
                                end:f5
            				end :g5
						  else
							`uvm_info("ADDR NOT MATCHED","addr unmatched",UVM_LOW)
				end:a5
              if(mas_xtn.HSIZE==3'b010)
				begin:a7
                          if(mas_xtn.HADDR==slv_xtn.HADDR)
							begin :l7
                              `uvm_info("ADDR MATCHED","addr matched",UVM_LOW)
                              if(mas_xtn.HWRITE==1)
                                begin :h7
                                  mem[mas_xtn.HADDR]=mas_xtn.HWDATA;
                                end :h7
                              else
                                begin  :g7
                                  if(mem.exists(mas_xtn.HADDR))
                                    begin :e7
                                      expected_data=mem[mas_xtn.HADDR];
                                      if(expected_data!= slv_xtn.HRDATA)
                                        begin :d7
                                          `uvm_info("DATA NOT MATCHED","data not matched",UVM_LOW)
                                        end :d7
                                      else 
                                        begin :c7
                                          `uvm_info("DATA MATCHED","data matched",UVM_LOW)
                                        end  :c7
                                    end :e7
                                end:g7
            				end :l7
						  else
							`uvm_info("ADDR NOT MATCHED","addr unmatched",UVM_LOW)
				end:a7
		end:a
           
     endtask
endclass
