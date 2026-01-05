interface ahb_if(input bit hclk,input bit HRESETn);
	//logic HRESETn;
	logic HREADY;
	//logic HREADYOUT;
	logic HWRITE;
  	logic [31:0] HWDATA;
  	logic [31:0] HADDR;
  	logic [31:0] HRDATA;
  	logic [1:0] HRESP;
  	logic [1:0] HTRANS;
  	logic [2:0] HSIZE;
  	logic [2:0] HBURST;
	
  clocking mas_drv_cb@(posedge hclk);
      default input #0 output #0;
    	
		input  HRESETn;
		input  HREADY;
		output  HSIZE;
		output  HBURST;
		output  HWDATA;
		output  HADDR;
      	output  HTRANS;
    	output  HWRITE;
		input   HRDATA;
      	input   HRESP;
		//input   HREADYOUT;
 	endclocking 

  clocking mas_mon_cb@(posedge hclk);
      default input #1;
		//input  HRESETn;
		input  HREADY;
		input  HSIZE;
		input  HBURST;
		input  HWDATA;
		input  HADDR;
      	input  HTRANS;
    	input  HWRITE;
		input   HRDATA;
      	input   HRESP;
		//input   HREADYOUT;
 	endclocking 

  clocking slv_drv_cb@(posedge hclk);
		//output  HRESETn;
		input  HREADY;
		output  HSIZE;
		output  HBURST;
		output  HWDATA;
		output  HADDR;
      	output  HTRANS;
    	output  HWRITE;
		input   HRDATA;
      	input   HRESP;
		//input   HREADYOUT;
	endclocking 
  clocking slv_mon_cb@(posedge hclk);
      //default input #1 output #1;
		//input  HRESETn;
		input  HREADY;
		input  HSIZE;
		input  HBURST;
		input  HWDATA;
		input  HADDR;
      	input  HTRANS;
    	input  HWRITE;
		input   HRDATA;
      	input   HRESP;
		//input   HREADYOUT;
	endclocking 
	

  	modport mas_drv_mp(clocking mas_drv_cb);
    modport mas_mon_mp(clocking mas_mon_cb);
    modport slv_drv_mp(clocking slv_drv_cb);	
    modport slv_mon_mp(clocking slv_mon_cb);

endinterface
     
// if resten is active then transfer type is IDLE and transfer response is okay 
      property IDLEandOKAYafterRESET;
        @(posedge HCLK) {Hrestn==1} |-> {(HTRANS == 2'b00) && (HRESP == 2'b00)};
      endproperty
// if transfer type is nonseq and hburst is single then on the next cycles the transfer type is not seq and transfer is not busy
      property single_burst;
        @(posedge HCLK) disable iff (HRESETn) 
        {(HTRANS == 2'b11) && (HBURST==3'b000)} |=> {(HTRANS == ! 2'b3) && (HRESP == !2'b01)};
      endproperty
//if the transfer type is IDLE then on the next cycle the transfer might be IDLE or non seq
      property transfertype;
        @(posedge HCLK) disable iff(HRESETn)
        {HTRANS == 2'b00} |-> {(HTRANS == 2'b00) || (HTRANS==2'b10)};
      endproperty
//if htrans is busy when hready is high on the next corresponding cycle hresp has to be okay by making the hready high 
      property oakyresp_busytrans;
        @(posedge HCLK) disable iff(HRESETn)
        {(HTRANS == 2'b10) && (HREADY == 1'b1)} |-> {(HRESP == 2'b00) && (HREADY == 1'b1)};
      endproperty
//if htrans is okay when hready is high on the next corresponding cycle hresp hresp has to be okay by making hready high
      property okayresp_idletrans;
        @(posedge HCLK) disable iff(HRESTn)
        {(HTRANS == 2'b00) && (HREADY ==1'b1) |-> {(HRESP == 2'b00) && (HREADY == 1'b1)};
       endproperty 
// if hresp is not okay and hready is llow and the next cycle the hresp is still not okay but hready must be high
         property hrespunchangedwhenhreadyishigh;
           @(posedge HCLK) disable iff(HRESETn) 
           {(HRESP !== 2'b00) && (HREADY !==1'b0)} |=> {(HRESP !== 2'b00) && (HREADY ==1'b1)};
         endproperty
 //if the response is split or retry then next cycle transfer type has to IDLE
         property split_retry_IDLE;
           @(posedge HCLK) disable iff(HRESETn)
           {(HRESP == 2'b10 || HRESP == 2'b11) && HREADY == 1'b0} |-> Htrans == 2'b00;
         endproperty
// if the transfer type are busy or seq then the control signals has to be same as the previous transfer 
         property prev_controls;
           @(posedge HCLK) disable iff(HRESETn)
           {(HTRANS == 2'b10) || (HTRANS == 2'b11)} |-> {HSIZE == $past(HSIZE,1), 
                                                         HWRITE == $past(HWRITE,1), 
                                                         HBURST == $past(HBURST,1) };
     	  endproperty
// if okay response comes and hready  is low the data then the data and addr phase   need to extend     
         property wait_states;
           @(posedge HCLK) disable iff(HRESETn)
           {(HREADY ==0) && (HRESP == 2'b00)} |=> { (HADDR 	== $past(HADDR,1),
                                                     HSIZE	== $past(HSIZE,1),
                                                     HTRANS == $past(HTRANS,1),
                                                     HBURST == $past(HBURST,1),
                                                     HWRITE == $past(HWRITE,1)};
         endproperty
//seq or non seq transfer type when hready is low in the same cycle the addr and data phase need to extend 
        property seq_nonseq_wait;
          @(posedge HCLK) disable iff(HRESETn)
          {(HREADY==0) && (HWRITE ==1'b1) && (HTRANS == 2'b10 || HTRANS == 2'b11)} |-> 
          																			{HWDATA == $past(HWDATA,1),
                                                                                     HADDR ==$past(HADDR,1),
                                                                                     HSIZE == $past(HSIZE,1),
                                                                                     HBURST == $past(HBURST,1)};
        endproperty
//if transfer type is busy  the addr wont change 
         property busy_addr;
           @(posedge HCLK) disable iff(HRESETn) 
           {(HTRANS == 2'b01) } |=> {HADDR == $past(HADDR,1)
                                     HWDATA == $past(HWDATA,1)};
         endproperty
 //if IDLE transfer type is comes then next cycles dont need to generate seq or busy
         property idle_notseqbusy;
           @(posedge HCLK) disable iff(HRESETn)
           {(HTRANS == 2'b00)} |=> {(HTRANS == !2'b01) || (HTRANS == !2'b11)};
         endproperty
//  RETRY is always asserted for two cycles unless reset is asserted 
         property retryfortwocycles;
           @(posedge HCLK) disable iff(HRESETn)
           (HRESP == 2'b10)[*2];
          endproperty 
//  SPLIT is always asserted for two cycles unless reset is asserted 
         property retryfortwocycles;
           @(posedge HCLK) disable iff(HRESETn)
           (HRESP == 2'b11)[*2];
          endproperty 
//  ERROR is always asserted for two cycles unless reset is asserted 
         property retryfortwocycles;
           @(posedge HCLK) disable iff(HRESETn)
           (HRESP == 2'b01)[*2];
          endproperty 
// if the burst is not incr and not idle the number of beats must not exceeded
         property burstisnottoolong;
           int length;
           @(posedge HCLK) disable iff(HRESETn)
           {(HBURST !== 3'b001) && (HTRANS !== 2'b00)} |-> 
           {(HBURST == 3'b000) && (length == 1) ||
            (HBURST == 3'b010) && (length == 4) ||
            (HBURST == 3'b011) && (length == 4) ||
            (HBURST == 3'b100) && (length == 8) ||
            (HBURST == 3'b101) && (length == 8) ||
            (HBURST == 3'b110) && (length == 16) ||
            (HBURST == 3'b111) && (length == 16)};
         endproperty                                                                              
// for generating the aligned address                                            
         property alignedaddr;
           @(posedge HCLK) disable iff(HRESETn)
           {(HSIZE == 3'b000) && (HSIZE = 3'b001) && (HADDR[0] == 1'b0;) ||
            (HSIZE == 3'b010) && (HADDR[1:0] == 2'b00;) ||
            (HSIZE == 3'b011) && (HADDR[2:0] == 3'b00;) };
         endproperty 
// wait states not more than 16 
        property waitstates;
          @(posedge HCLK) disable iff(HRESETn)
          {(HREADY == 1'b0) |=> ##[1:16] (HREADY == 1'b1)};
        endproperty 
//address increment by size for increment burst mode 
       property incr-addr;
         @(posedge HCLK) disable iff(HRESETn)
         {(HBURST == 3'b011) || (HBURST == 3'b101) || (HBURAT == 3'b111)} |->
         {(HTRANS == 2'b11) || (HTRANS == 2'b01)} |-> 
         {(HTRANS !== 2'b01 || HREADY !== 0)} |=>
         { HADDR == ($past(1,HADDR) + 2**HSIZE)};
       endproperty
