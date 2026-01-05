class master_monitor extends uvm_monitor;
  `uvm_component_utils(master_monitor)
	master_config mcfg;
  ahb_xtn xtn,xtn_copy;
  int temp_write,temp_addr;
  int que[$];
	virtual ahb_if.mas_mon_mp vif;
  uvm_analysis_port #(ahb_xtn) ap;

  function new(string name="master_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
      if(!uvm_config_db #(master_config)::get(this,"","master_config",mcfg))
				`uvm_fatal(get_type_name(),"GETTING FAILED")
        ap=new("ap",this);
	endfunction 

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif=mcfg.vif;
	endfunction 
  /*task run_phase(uvm_phase phase);  
      forever 
        begin
     		//@(vif.mas_mon_cb);
        //if(vif.mas_mon_cb.HREADYOUT ==1'b1);
        xtn = ahb_xtn::type_id::create("xtn");
         
          wait(vif.mas_mon_cb.HTRANS == 2'b10 || vif.mas_mon_cb.HTRANS == 2'b11)
          begin
			xtn.HADDR = vif.mas_mon_cb.HADDR;
			xtn.HWRITE = vif.mas_mon_cb.HWRITE;
			xtn.HTRANS = vif.mas_mon_cb.HTRANS;
			xtn.HSIZE =vif.mas_mon_cb.HSIZE;
			xtn.HREADY = vif.mas_mon_cb.HREADY;
            //`uvm_info("address phase",$sformatf("write monitor seq_item:\n%s time=%0t", xtn.sprint(), $time),UVM_MEDIUM) 
          end
              	@(vif.mas_mon_cb);
          
            		if(vif.mas_mon_cb.HREADY == 1'b1)
             		 begin
            			if(vif.mas_mon_cb.HWRITE == 1'b1)
							xtn.HWDATA = vif.mas_mon_cb.HWDATA;
          				else
							xtn.HRDATA = vif.mas_mon_cb.HRDATA;
                 `uvm_info(get_type_name(),$sformatf("write monitor seq_item:\n%s time=%0t", xtn.sprint(), $time),UVM_MEDIUM) 

              		  end
                ap.write(xtn);
             end
         
  	endtask*/
    /*task run_phase(uvm_phase phase);
      
      forever 
        begin
     		@(vif.mas_mon_cb);
        //if(vif.mas_mon_cb.HREADYOUT ==1'b1);
        xtn = ahb_xtn::type_id::create("xtn");
         
          if(vif.mas_mon_cb.HTRANS == 2'b10 )
          begin
            if(vif.mas_mon_cb.HREADY == 1'b1)
              begin
			xtn.HADDR = vif.mas_mon_cb.HADDR;
			xtn.HWRITE = vif.mas_mon_cb.HWRITE;
			xtn.HTRANS = vif.mas_mon_cb.HTRANS;
			xtn.HSIZE =vif.mas_mon_cb.HSIZE;
			xtn.HREADY = vif.mas_mon_cb.HREADY;
            temp_write= vif.mas_mon_cb.HWRITE;
              end
          end
            //$display("jkhk;l");
				//@(vif.mas_mon_cb);
            while(vif.mas_mon_cb.HTRANS == 2'b11  || vif.mas_mon_cb.HTRANS == 2'b01)
            begin
              	@(vif.mas_mon_cb);
          if(vif.mas_mon_cb.HTRANS == 2'b11)// &&  vif.mas_mon_cb.HTRANS != 2'b01)
          		begin
                  	 //$display("lmlmlmk");
            		if(vif.mas_mon_cb.HREADY == 1'b1)
             		 begin
            			if(temp_write == 1'b1)
							xtn.HWDATA = vif.mas_mon_cb.HWDATA;
          				else
							xtn.HRDATA = vif.mas_mon_cb.HRDATA;
              		  end
           `uvm_info(get_type_name(),$sformatf("write monitor seq_item:\n%s time=%0t", xtn.sprint(), $time),UVM_MEDIUM) 
                ap.write(xtn);
                end
          	 end
         end
      
  	endtask*/ 
 task run_phase(uvm_phase phase);
  ahb_xtn xtn;
  bit [1:0] prev_htrans;
  bit [31:0] prev_haddr;
  bit prev_hwrite;
  bit [2:0] prev_hsize;

  // Initialize previous values
  prev_htrans = 2'b00;
  prev_haddr  = '0;
  prev_hwrite = 1'b0;
  prev_hsize  = 3'b000;

  forever begin
    @(vif.mas_mon_cb);

    // --------------------------------------------------
    // Data phase sampling
    // --------------------------------------------------
    // If previous cycle had NONSEQ or SEQ (valid address phase)
    // and HREADY=1 in current cycle => valid data phase
    if ((prev_htrans == 2'b10 || prev_htrans == 2'b11) &&
        (vif.mas_mon_cb.HREADY == 1'b1)) begin

      xtn = ahb_xtn::type_id::create("xtn");

      // Capture address/control info from previous cycle
      xtn.HADDR  = prev_haddr;
      xtn.HWRITE = prev_hwrite;
      xtn.HTRANS = prev_htrans;
      xtn.HSIZE  = prev_hsize;
      xtn.HREADY = vif.mas_mon_cb.HREADY;

      // Capture corresponding data from current cycle
      if (prev_hwrite)
        xtn.HWDATA = vif.mas_mon_cb.HWDATA;
      else
        xtn.HRDATA = vif.mas_mon_cb.HRDATA;

      // Deep copy (avoid data overwrite by next iteration)
      xtn_copy = ahb_xtn::type_id::create("xtn_copy");
      xtn_copy.copy(xtn);

      // Print & send to analysis
      //`uvm_info(get_type_name(),$sformatf("Monitor captured transfer:\n%s time=%0t", xtn_copy.sprint(), $time),UVM_MEDIUM)

      ap.write(xtn_copy);
    end

    // --------------------------------------------------
    // Save current values for next cycle
    // --------------------------------------------------
    prev_htrans = vif.mas_mon_cb.HTRANS;
    prev_haddr  = vif.mas_mon_cb.HADDR;
    prev_hwrite = vif.mas_mon_cb.HWRITE;
    prev_hsize  = vif.mas_mon_cb.HSIZE;
  end
endtask


endclass
