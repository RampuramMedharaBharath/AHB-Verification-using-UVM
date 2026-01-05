class slave_driver extends uvm_driver#(ahb_xtn);
  `uvm_component_utils(slave_driver)
	slave_config d_cfg;
	virtual ahb_if.slv_drv_mp vif;
	
  function new(string name="slave_driver",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
			super.build_phase(phase);
      if(!uvm_config_db #(slave_config)::get(this,"","slave_config",d_cfg))
			`uvm_fatal(get_type_name(),"gtting failed")
	 endfunction 
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif=d_cfg.vif;
	endfunction 
	/*task run_phase(uvm_phase phase);	
		forever begin 

			//send_to_src();	
			
			end
	endtask
	task send_to_src();
		req=apb_xtn::type_id::create("req");
		begin
		   if(vif.dst_drv_cb.presetn==1'b0)	
			begin 
			$display("hjhjhjuh ,ndhsafdkfj");
			vif.dst_drv_cb.paddr	<=32'h0;
			vif.dst_drv_cb.pwdata	<=32'h0;
			vif.dst_drv_cb.pwrite	<=1'b0;
			vif.dst_drv_cb.psel	<=1'b0;
			vif.dst_drv_cb.penable	<=1'b0;
			vif.dst_drv_cb.pready	<=1'b0;
			end
		else if(vif.dst_drv_cb.pwrite==1'b1) 
			vif.dst_drv_cb.pready	<=1'b1;
		else if(vif.dst_drv_cb.pwrite==1'b0)
			vif.dst_drv_cb.pready	<=1'b1;
			vif.dst_drv_cb.prdata	<={$random}%60;
		end
	endtask */

endclass 
