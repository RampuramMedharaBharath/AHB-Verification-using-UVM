class master_seqs extends uvm_sequence #(ahb_xtn);
	
  `uvm_object_utils(master_seqs)
	
  function new(string name="master_seqs");
		super.new(name);
	endfunction
	
	bit[31:0] haddr;
	bit[2:0]  hburst;
	bit[1:0] hsize;
	bit hwrite;    
  	bit [1:0] htrans;
	bit [9:0]len; 
  
  ahb_xtn que[$],xtn,gtn;
  int prev_addr;
  ahb_xtn xtn_copy;

	/*task body();

		req=ahb_xtn::type_id::create("req");
      repeat(5) begin
      	start_item(req);
        assert(req.randomize() with {HBURST==3'b000;
										HWRITE==1'b1;
										HTRANS==2'b10;
                                    	HSIZE==3'b010;});
//         if(req.HWRITE == 1)
//           		req.HRDATA =0;
        
		finish_item(req);
        
      	haddr= req.HADDR ;
	  	hburst=req.HBURST;
		hwrite=req.HWRITE;
      	htrans=req.HTRANS;
		hsize=req.HSIZE;
        
      	start_item(req);
        assert(req.randomize() with {HBURST==3'b000;
										HWRITE==1'b0;
										HTRANS==2'b10;
                                    	HSIZE==3'b010;
                                    	HADDR ==haddr;});
//         if(req.HWRITE == 0)
//           		req.HWDATA =0;
		finish_item(req);
      end
	endtask*/
  
  task body();
  ahb_xtn xtn_copy;
  ahb_xtn req_read;

  // -------------------- WRITE PHASE --------------------
    repeat(5) begin
    req = ahb_xtn::type_id::create("req");
    start_item(req);

//     $display("WRITE BEFORE RANDOMIZE: HADDR=%h", req.HADDR);

    assert(req.randomize() with {
      HBURST == 3'b000;
      //HADDR <=2048;
      HWRITE == 1'b1;
      HTRANS == 2'b10;
      HSIZE  == 3'b010;
    });

//     $display("WRITE AFTER RANDOMIZE:  HADDR=%h", req.HADDR);

    finish_item(req);

    // Create a fresh copy each time
    xtn_copy = ahb_xtn::type_id::create("xtn_copy");
    xtn_copy.copy(req);

    // Store unique copy into queue
    que.push_back(xtn_copy);
  end
#20;
  // -------------------- READ PHASE --------------------
    repeat(5) begin
    xtn = que.pop_front();   // fetch matching write item

    req_read = ahb_xtn::type_id::create("req_read");
    start_item(req_read);

    assert(req_read.randomize() with {
      HBURST == 3'b000;
      HWRITE == 1'b0;
      HTRANS == 2'b10;
      HSIZE  == 3'b010;
      HADDR  == xtn.HADDR;   // read from same address
    });

    $display("READ ADDR=%h (matching write addr)", req_read.HADDR);

    finish_item(req_read);
  end
endtask

    	/*task body();
          repeat(5) begin 
        `uvm_do_with(req,				{req.HWRITE==1'b1;
										req.HTRANS==2'b11;
                                        req.HSIZE==2;
                     					req.HBURST==0;})
        que.push_back(req);
      	end
      
        repeat(5) begin
        xtn = que.pop_front();
        `uvm_do_with(req,{req.HBURST==0;
										req.HWRITE==1'b0;
										req.HTRANS==2'b11;
                                    	req.HSIZE==2;
                          req.HADDR == xtn.HADDR;})
          
      end
    endtask*/
endclass

class unincr_seqs extends uvm_sequence #(ahb_xtn);
	
  `uvm_object_utils(unincr_seqs)
	
  function new(string name="unincr_seqs");
		super.new(name);
	endfunction
	
	bit[31:0] haddr;
	bit[2:0]  hburst;
	bit[1:0] hsize;
	bit hwrite;    
  	bit [1:0] htrans;
	bit [9:0]len;  
	
  	ahb_xtn xtn_copy;
  	ahb_xtn req_read;
  	ahb_xtn que[$],xtn,gtn;
  
      task body();
        int addr;
			begin
			req=ahb_xtn::type_id::create("req");
              
              repeat(1)
              begin 
              `uvm_do_with(req,{req.HWRITE==1'b1;req.HTRANS==2'b10;req.HBURST ==3'b001;})
      				haddr=req.HADDR;
					hburst=req.HBURST;
					hsize=req.HSIZE;
					len =req.length;
     		 		que.push_back(req);
      			for(int i=1 ;i<len;i++)begin
        		`uvm_do_with(req,{req.HWRITE==1'b1;
	  					req.HTRANS==2'b11;
                        req.HADDR ==haddr+2**hsize;
                        req.HBURST == hburst;
                        req.HSIZE == hsize;})
              		haddr=req.HADDR; 
      			end
    		end
            repeat(1)begin
      			xtn=que.pop_front();
      			`uvm_do_with(req,{req.HWRITE==1'b0;
                        req.HTRANS==2'b10;req.HBURST == xtn.HBURST;req.HADDR == xtn.HADDR; req.HSIZE == xtn.HSIZE;})
      			addr=req.HADDR;
      			for(int i=1; i<xtn.length; i++)begin
        		`uvm_do_with(req,{req.HBURST== xtn.HBURST;
						req.HWRITE==1'b0;
						req.HTRANS==2'b11;
                        req.HSIZE== xtn.HSIZE;
                        req.HADDR== addr+2**xtn.HSIZE;})
        				addr=req.HADDR;
            	end
            end
         end
			/*start_item(req);
              assert(req.randomize() with {HBURST== 3'b001;
										HWRITE==1'b1;
										HTRANS==2'b10;});
			finish_item(req);
              
			haddr=req.HADDR;
			hburst=req.HBURST;
			hwrite=req.HWRITE;
			hsize=req.HSIZE;
			len =req.length;
            
            start_item(req);
              assert(req.randomize() with {HBURST== 3'b001;
										HWRITE==1'b0;
										HTRANS==2'b10;
                                         HADDR==haddr;});
			finish_item(req);
			end
			  
			for(int i=0;i<len-1;i++) 
			begin
			start_item(req);
              assert(req.randomize() with {HBURST==3'b001;
							HTRANS==2'b11;
							HWRITE==1'b1;
							HADDR==(haddr+(3'b001<<(hsize)));
							HSIZE==hsize;});
			finish_item(req);
	
			
//             haddr=req.HADDR;
// 			hburst=req.HBURST;
// 			hwrite=req.HWRITE;
// 			hsize=req.HSIZE;
// 			len =req.length;
            
            start_item(req);
              assert(req.randomize() with {HBURST== 3'b001;
										HWRITE==1'b0;
										HTRANS==2'b11;
                                         HADDR==(haddr+(3'b001<<(hsize)));
                                          HSIZE==hsize;});
			finish_item(req);
              
            haddr=req.HADDR;
			end*/
	endtask

endclass

class incr_seqs extends uvm_sequence #(ahb_xtn);
	
  `uvm_object_utils(incr_seqs)
	
  function new(string name="incr_seqs");
		super.new(name);
	endfunction
	
	bit[31:0] haddr;
  bit[31:0] haddr_r;
	bit[2:0]  hburst;
	bit[1:0] hsize;
	bit hwrite;    
  	bit [1:0] htrans;
	bit [9:0]len;  
  
  ahb_xtn xtn_copy;
  ahb_xtn req_read;
  ahb_xtn que[$],xtn,gtn;


      /*task body();
        	int a=2;
			begin
			req=ahb_xtn::type_id::create("req");
              repeat(a)
                begin 
                  `uvm_do_with(req,{req.HWRITE==1'b1;req.HTRANS==2'b10;req.HBURST inside {3,5,7};})
                  //que.push_back(req);
      					haddr=req.HADDR;
						hburst=req.HBURST;
						hsize=req.HSIZE;
						len =req.length;
                  `uvm_do_with(req,{req.HWRITE==1'b0;req.HTRANS==2'b10;req.HBURST==hburst;req.HSIZE==hsize;req.HADDR==haddr;})
                  
                  for(int i=0;i<len-1;i++)
                      begin
        		  	`uvm_do_with(req,{req.HWRITE==1'b1;
	  								req.HTRANS==2'b11;
                      			    req.HADDR ==haddr+2**hsize;
                       			    req.HBURST == hburst;
                       			    req.HSIZE == hsize;})
                        
                    `uvm_do_with(req,{req.HWRITE==1'b0;
	  								req.HTRANS==2'b11;
                      			    req.HADDR ==haddr+2**hsize;
                       			    req.HBURST == hburst;
                       			    req.HSIZE == hsize;})
              		haddr=req.HADDR;
      				end
                end
            end
	endtask*/
  task body();
    int a = 5;
    int b[$];
    int c;
    int addr,size;  
    repeat(a)begin 
      `uvm_do_with(req,{req.HWRITE==1'b1;req.HTRANS==2'b10;req.HBURST inside {3,5,7};})
      		haddr=req.HADDR;
			hburst=req.HBURST;
			hsize=req.HSIZE;
			len =req.length;
      que.push_back(req);
      for(int i=1 ;i<len;i++)begin
        `uvm_do_with(req,{req.HWRITE==1'b1;
	  					req.HTRANS==2'b11;
                        req.HADDR ==haddr+2**hsize;
                        req.HBURST == hburst;
                        req.HSIZE == hsize;})
              		haddr=req.HADDR;
        
      end
    
    end
   // #11;
    repeat(a)begin
      xtn=que.pop_front();
      `uvm_do_with(req,{req.HWRITE==1'b0;
                        req.HTRANS==2'b10;req.HBURST == xtn.HBURST;req.HADDR == xtn.HADDR; req.HSIZE == xtn.HSIZE;})
      			addr=req.HADDR;
      for(int i=1; i<xtn.length; i++)begin
        `uvm_do_with(req,{req.HBURST== xtn.HBURST;
						req.HWRITE==1'b0;
						req.HTRANS==2'b11;
                        req.HSIZE== xtn.HSIZE;
                        req.HADDR== addr+2**xtn.HSIZE;})
              			addr=req.HADDR;
      end
    end
  endtask

endclass

class wrap_seqs extends uvm_sequence #(ahb_xtn);
	
  `uvm_object_utils(wrap_seqs)
	
  function new(string name="wrap_seqs");
		super.new(name);
	endfunction
	
	bit[31:0] haddr;
	bit[2:0]  hburst;
	bit[1:0] hsize;
	bit hwrite;    
  	bit [1:0] htrans;
	bit [9:0]len;  
  	
  	int start_addr,boundary_addr,c,addr;
  	int b[$];
    
  	ahb_xtn xtn_copy;
  	ahb_xtn req_read;
  	ahb_xtn que[$],xtn,gtn;
  
      /*task body();
			begin
			req=ahb_xtn::type_id::create("req");
              repeat(5) begin
			start_item(req);
                assert(req.randomize() with {HBURST inside {2,4,6};
										HWRITE==1'b1;
										HTRANS==2'b10;});
			finish_item(req);
              
			haddr=req.HADDR;
			hburst=req.HBURST;
			hwrite=req.HWRITE;
			hsize=req.HSIZE;
			len =req.length;
            
            start_item(req);
              assert(req.randomize() with {HBURST== hburst;
										HWRITE==1'b0;
										HTRANS==2'b10;
                                         HADDR==haddr;});
			finish_item(req);
			
			  
        start_addr =int'((haddr)/((2**hsize)*(len)))*((2**hsize)*len);
        boundary_addr =start_addr + ((2**hsize)*(len));
       
        
			for(int i=0;i<len-1;i++) 
			begin
              
              if(haddr==boundary_addr)
          			haddr= start_addr;
              
			start_item(req);
              assert(req.randomize() with {HBURST==hburst;
							HTRANS==2'b11;
							HWRITE==1'b1;
							HADDR==(haddr+(3'b001<<(hsize)));
							HSIZE==hsize;});
			finish_item(req);

            
            start_item(req);
              assert(req.randomize() with {HBURST== hburst;
										HWRITE==1'b0;
										HTRANS==2'b11;
                                         HADDR==(haddr+(3'b001<<(hsize)));
                                          HSIZE==hsize;});
			finish_item(req);
              
            haddr=req.HADDR;
			end
            end
            end
	endtask*/
  
  task body();
    int a=5;
    begin
      repeat(a)
        begin 
          `uvm_do_with(req,{req.HWRITE==1'b1;req.HTRANS==2'b10;req.HBURST inside {2,4,6};})
          	haddr=req.HADDR;
			hburst=req.HBURST;
			hsize=req.HSIZE;
			len =req.length;
          
          	que.push_back(req);
          
           	start_addr =int'((haddr)/((2**hsize)*(len)))*((2**hsize)*len);
        	boundary_addr =start_addr + ((2**hsize)*(len));
          
          	if(haddr==boundary_addr)
          			haddr= start_addr;
          	
          for(int i=0;i<len-1;i++)
              begin
        		`uvm_do_with(req,{req.HWRITE==1'b1;
	  					req.HTRANS==2'b11;
                        req.HADDR ==haddr+2**hsize;
                        req.HBURST == hburst;
                        req.HSIZE == hsize;})
              		haddr=req.HADDR;
      		  end
          //b.push_back(len);
        end
      repeat(a)
        begin 
          xtn=que.pop_front();
          //c=b.pop_front();
          `uvm_do_with(req,{req.HWRITE==1'b0;
                        req.HTRANS==2'b10;req.HBURST == xtn.HBURST;req.HADDR == xtn.HADDR; req.HSIZE == xtn.HSIZE;})
          
          	addr = req.HADDR;
          
          start_addr =int'((addr)/((2**xtn.HSIZE)*(xtn.length)))*((2**xtn.HSIZE)*xtn.length);
          boundary_addr =start_addr + ((2**xtn.HSIZE)*(xtn.length));
          
          	if(addr==boundary_addr)
          			addr= start_addr;
          	
          for(int i=0;i<xtn.length-1;i++)
              begin
                `uvm_do_with(req,{req.HWRITE==1'b0;
	  					req.HTRANS==2'b11;
                        req.HADDR ==addr+2**xtn.HSIZE;
                        req.HBURST ==xtn.HBURST;
                        req.HSIZE == xtn.HSIZE;})
              		addr=req.HADDR;
      		  end
        end
    end
  endtask 

endclass


