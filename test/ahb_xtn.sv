
class ahb_xtn extends uvm_sequence_item;

  rand bit [31:0]	HADDR;
  rand bit [1:0]	HTRANS;
  rand bit [31:0]	HWDATA;
  rand bit [2:0]	HSIZE;
  rand bit [2:0]	HBURST;
  rand bit 			HWRITE;
  rand bit [9:0]	length;
	
  bit [31:0]HRDATA;
  bit HRESETn;
  bit HREADY;
  bit HRESP;
 
	
  bit [31:0] TEMP_HADDR;
  function new(string name="ahb_xtn");
    super.new(name);
  endfunction 
  
  `uvm_object_utils_begin(ahb_xtn)
  `uvm_field_int(HADDR,UVM_ALL_ON)
  `uvm_field_int(HWDATA,UVM_ALL_ON)
  `uvm_field_int(HWRITE,UVM_ALL_ON)
  `uvm_field_int(HREADY,UVM_ALL_ON)
  `uvm_field_int(HSIZE,UVM_ALL_ON)
  `uvm_field_int(HBURST,UVM_ALL_ON)
  `uvm_field_int(HTRANS,UVM_ALL_ON)
  `uvm_field_int(HRESP,UVM_ALL_ON)
  `uvm_field_int(HRDATA,UVM_ALL_ON)
  `uvm_object_utils_end
  
  constraint valid_size{HSIZE inside {[0:2]};}

  constraint valid_addr_values{HSIZE==1-> (HADDR%2==0);
                               HSIZE==2-> (HADDR%4==0);}

  constraint valid_length{(HADDR%1024)+(length*(3'b001<<HSIZE))<=1023;}

  constraint valid_Haddr{HADDR inside {[0:2047]};}

  constraint valid_Hburst{{HBURST==7} -> {length==16};
                          {HBURST==5} -> {length==8};
                          {HBURST==3} -> {length==4};}
  
  constraint valid_wHburst{{HBURST==6} -> {length==16};
                          {HBURST==4} -> {length==8};
                          {HBURST==2} -> {length==4};}

endclass

  
 
