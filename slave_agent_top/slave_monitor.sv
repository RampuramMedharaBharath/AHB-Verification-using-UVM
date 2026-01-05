class slave_monitor extends uvm_monitor;
  `uvm_component_utils(slave_monitor)
  slave_config scfg;
  virtual ahb_if.slv_mon_mp vif;
  ahb_xtn xtn,xtn_copy;
  uvm_analysis_port #(ahb_xtn) ap;

  
  function new(string name="slave_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction 
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(slave_config)::get(this,"","slave_config",scfg))
				`uvm_fatal(get_type_name(),"GETTING FAILED")
      ap=new("ap",this);
  endfunction 
      
  function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif=scfg.vif;
  endfunction 
  
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
    @(vif.slv_mon_cb);

    // --------------------------------------------------
    // Data phase sampling
    // --------------------------------------------------
    // If previous cycle had NONSEQ or SEQ (valid address phase)
    // and HREADY=1 in current cycle => valid data phase
    if ((prev_htrans == 2'b10 || prev_htrans == 2'b11) &&
        (vif.slv_mon_cb.HREADY == 1'b1)) begin

      xtn = ahb_xtn::type_id::create("xtn");

      // Capture address/control info from previous cycle
      xtn.HADDR  = prev_haddr;
      xtn.HWRITE = prev_hwrite;
      xtn.HTRANS = prev_htrans;
      xtn.HSIZE  = prev_hsize;
      xtn.HREADY = vif.slv_mon_cb.HREADY;

      // Capture corresponding data from current cycle
      if (prev_hwrite)
        xtn.HWDATA = vif.slv_mon_cb.HWDATA;
      else
        xtn.HRDATA = vif.slv_mon_cb.HRDATA;

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
    prev_htrans = vif.slv_mon_cb.HTRANS;
    prev_haddr  = vif.slv_mon_cb.HADDR;
    prev_hwrite = vif.slv_mon_cb.HWRITE;
    prev_hsize  = vif.slv_mon_cb.HSIZE;
  end
endtask
 
endclass 

