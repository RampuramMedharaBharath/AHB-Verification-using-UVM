       htrans_reg <= htrans;
      end
  end

endmodule*/
 module ahb(
   input logic   		HCLK, //AHB Clock
   input logic   		HRESETn,//Active low reset
   input logic 	[1:0] 	HTRANS, //Transfer type
   input logic 	[2:0] 	HBURST, //Burst type
   input logic   		HWRITE, //write control signal
   input logic 	[2:0] 	HSIZE, //Size of the transfer
   input logic 	[31:0]  HADDR, //Adress bus
   input logic 	[31:0]  HWDATA, //Write data bus
   output logic [31:0] 	HRDATA, //Read data bus
   output logic [1:0] 	HRESP, //Response
   output logic   		HREADY);//Ready output
  
   reg [31:0]mem[0:8191];//simple Memory
  
  reg [31:0]addr; // Address register for internal  use
  reg [1:0] trans; // Transfer type
  reg [2:0] burst; // Burst_type
  reg [2:0] size; // Size of the transfer
  reg  write; // Write control signal
  
  always @(posedge HCLK or negedge HRESETn)begin
    if(HRESETn)begin
      HREADY <= 1'b0;
      HRESP  <= 1'b0;
      HRDATA <= 32'h0;
    end
    if(!HRESETn) begin
          HRESP  <= 1'b0;
      		HREADY <=1'b1;
      if (HTRANS[1]) 
        begin
          if(write) 
          begin
            case (size)
            	3'b000:begin
                	mem[addr] <= {24'b0, HWDATA[7:0]};    
            	end
            	3'b001:begin
                	mem[addr] <= {16'b0, HWDATA[15:0]};
            	end
            	3'b010:begin
                	mem[addr] <= HWDATA;    
              	end
            	default: begin
              		mem[addr]	<= HWDATA;
              		HRESP <=0;
            	end
            endcase
          end
          if(!HWRITE)
            begin
              case (HSIZE)
            	3'b000:begin
                  HRDATA <= {24'b0, mem[HADDR][7:0]};
            		end
            	3'b001:begin
                	HRDATA <= mem[HADDR][15:0];
            		end
            	3'b010:begin
                	HRDATA <= mem[HADDR];  
              		end
            	default: begin
              		HRDATA <= mem[HADDR];
              		HRESP <=0;
            		end
          	  endcase
        	end
        end
        else 
          begin
          	HRESP <=1'b0;
        end
    end
  end
    always_ff @(posedge HCLK, negedge HRESETn)
      begin
      
        addr <= HADDR;
        size <= HSIZE;
        burst <= HBURST;
        trans <= HTRANS;
        write <= HWRITE;
      
    end
endmodule
