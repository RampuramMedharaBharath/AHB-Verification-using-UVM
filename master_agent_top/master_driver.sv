class master_driver extends uvm_driver#(ahb_xtn);
  `uvm_component_utils(master_driver)

	virtual ahb_if.mas_drv_mp vif;
	master_config mcfg;

  function new(string name="master_driver",uvm_component parent);
		super.new(name,parent);
	endfunction 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      if(!uvm_config_db #(master_config)::get(this,"","master_config",mcfg))
			`uvm_fatal(get_type_name(),"NOT GETTING CONFIG")
	endfunction
 
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif=mcfg.vif;
	endfunction 
	
	task run_phase(uvm_phase phase);
//       @(vif.mas_drv_cb);
//     	vif.mas_drv_cb.HRESETn<=1;
//       @(vif.mas_drv_cb);
//       wait(vif.HRESETn==0);
      @(negedge vif.mas_drv_cb.HRESETn);
    forever 
      begin
      seq_item_port.get_next_item(req);
      send_to_dut(req);
      seq_item_port.item_done();   
    	end
    endtask
  
  task send_to_dut(ahb_xtn req);
      begin
        //@(vif.mas_drv_cb);
        //wait(vif.mas_drv_cb.HREADY == 1'b1);
      	// @(vif.mas_drv_cb);
		vif.mas_drv_cb.HADDR <= req.HADDR;
		vif.mas_drv_cb.HWRITE <= req.HWRITE;
		vif.mas_drv_cb.HTRANS <= req.HTRANS;
        vif.mas_drv_cb.HBURST <= req.HBURST;
		vif.mas_drv_cb.HSIZE <= req.HSIZE;
        
                	 @(vif.mas_drv_cb);

        	if(req.HWRITE === 1'b1) 
				vif.mas_drv_cb.HWDATA <= req.HWDATA; 
			else 
          		req.HRDATA = vif.mas_drv_cb.HRDATA;  
             	
        wait(vif.mas_drv_cb.HREADY== 1'b1);
        
         //`uvm_info(get_type_name(),$sformatf("driver write seq_item:\n%s time=%0t", req.sprint(),$time),UVM_MEDIUM) 
      end	
  	endtask 
  
endclass 

