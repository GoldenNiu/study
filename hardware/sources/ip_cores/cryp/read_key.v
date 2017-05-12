`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/04/28 16:36:20
// Design Name: 
// Module Name: read_key
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module read_key#(
parameter  AXI_STM_DATA_WIDTH      = 32,
    
parameter C_AXI_ID_WIDTH           = 4, // The AXI id width used for read and write
                                         // This is an integer between 1-16
parameter C_AXI_ADDR_WIDTH         = 32, // This is AXI address width for all 
                                          // SI and MI slots
parameter C_AXI_DATA_WIDTH         = 512 // Width of the AXI write and read data

)
(
input                                   aclk,
input                                   areset,

input                                   d_axi_rvalid,
input      [C_AXI_ADDR_WIDTH-1:0]       d_axi_raddr,
output reg                              d_axi_rd_rvalid,
output reg [C_AXI_DATA_WIDTH-1:0]       d_axi_rd_data,  
output reg                              d_axi_rd_last,  

input                                   e_axi_rvalid,
input      [C_AXI_ADDR_WIDTH-1:0]       e_axi_raddr,
output reg                              e_axi_rd_rvalid,
output reg [C_AXI_DATA_WIDTH-1:0]       e_axi_rd_data,  
output reg                              e_axi_rd_last, 

input                                   key_axi_rvalid,
input      [C_AXI_ADDR_WIDTH-1:0]       key_axi_raddr,
output reg                              key_axi_rd_rvalid,
output reg [C_AXI_DATA_WIDTH-1:0]       key_axi_rd_data,  
output reg                              key_axi_rd_last, 

input                                   axi_rready,     // Read address ready
output reg [C_AXI_ID_WIDTH-1:0]         axi_rid,        // Read ID
output reg [C_AXI_ADDR_WIDTH-1:0]       axi_raddr,      // Read address
output reg [7:0]                        axi_rlen,       // Read Burst Length
output reg [2:0]                        axi_rsize,      // Read Burst size
output reg [1:0]                        axi_rburst,     // Read Burst type
output reg [1:0]                        axi_rlock,      // Read lock type
output reg [3:0]                        axi_rcache,     // Read Cache type
output reg [2:0]                        axi_rprot,      // Read Protection type
output reg                              axi_rvalid,     // Read address valid

// AXI read data channel signals   
input  [C_AXI_ID_WIDTH-1:0]             axi_rd_bid,     // Response ID
input  [1:0]                            axi_rd_rresp,   // Read response
input                                   axi_rd_rvalid,  // Read reponse valid
input  [C_AXI_DATA_WIDTH-1:0]           axi_rd_data,    // Read data
input                                   axi_rd_last,    // Read last
output reg                              axi_rd_rready  // Read Response ready
);
reg                              d_axi_rvalid_flag;
reg [C_AXI_ADDR_WIDTH-1:0]       d_axi_raddr_r;
reg                              e_axi_rvalid_flag;
reg [C_AXI_ADDR_WIDTH-1:0]       e_axi_raddr_r;

reg                              key_axi_rvalid_flag;
reg [C_AXI_ADDR_WIDTH-1:0]       key_axi_raddr_r;
always @(posedge aclk) begin
	if(areset) begin
		axi_rid            <= 0;
      axi_raddr          <= 0;
      axi_rlen           <= 0;
      axi_rsize          <= 0;
      axi_rburst         <= 0;
      axi_rlock          <= 0;
      axi_rcache         <= 0;
      axi_rprot          <= 0;
      axi_rvalid         <= 0;
      axi_rd_rready      <= 0;  
		
		d_axi_rd_rvalid    <= 0;
		d_axi_rd_data      <= 0;
		d_axi_rd_last      <= 0;
		
		e_axi_rd_rvalid    <= 0;
		e_axi_rd_data      <= 0;
		e_axi_rd_last      <= 0;
		
	    key_axi_rd_rvalid    <= 0;
        key_axi_rd_data      <= 0;
        key_axi_rd_last      <= 0;
		
		d_axi_rvalid_flag  <= 0;
        d_axi_raddr_r      <= 0;
        e_axi_rvalid_flag  <= 0;
        e_axi_raddr_r      <= 0;
	end
	else begin
	    if(key_axi_rvalid) begin
            key_axi_rvalid_flag <= 1;
            key_axi_raddr_r <= key_axi_raddr;
        end
	
		if(d_axi_rvalid) begin
			d_axi_rvalid_flag <= 1;
			d_axi_raddr_r <= d_axi_raddr;
		end
		
			
		if(e_axi_rvalid) begin
			e_axi_rvalid_flag <= 1;
			e_axi_raddr_r <= e_axi_raddr;
		end
		
       if(key_axi_rvalid_flag&&(~axi_rvalid)) begin
            if(axi_rready) begin
                key_axi_rvalid_flag <= 0;
                axi_rvalid <= 1'b1;
                axi_raddr  <= key_axi_raddr;
                axi_rid    <= 2;
                axi_rlen   <= 255;
            end
        end
	   else if(d_axi_rvalid_flag&&(~axi_rvalid)) begin
			if(axi_rready) begin
				d_axi_rvalid_flag <= 0;
				axi_rvalid <= 1'b1;
				axi_raddr  <= d_axi_raddr;
				axi_rid    <= 0;
				axi_rlen   <= 0;
			end
		end
		else if(e_axi_rvalid_flag&&(~axi_rvalid)) begin
			if(axi_rready) begin
				e_axi_rvalid_flag <= 0;
				axi_rvalid <= 1'b1;
				axi_raddr  <= e_axi_raddr;
				axi_rid    <= 1;
				axi_rlen   <= 0;
			end
		end
		else begin
			axi_rvalid <= 1'b0;
		end
		  
      if(axi_rvalid)
			axi_rd_rready <= 1'b1;
		
		
      if((axi_rd_bid == 2) && axi_rd_rvalid) begin
            key_axi_rd_rvalid    <= 1;
            key_axi_rd_data      <= axi_rd_data;
            key_axi_rd_last      <= axi_rd_last;
      end
      else
            key_axi_rd_rvalid    <= 0;
                       			
	   if((axi_rd_bid == 0) && axi_rd_rvalid) begin
			d_axi_rd_rvalid    <= 1;
			d_axi_rd_data      <= axi_rd_data;
			d_axi_rd_last      <= axi_rd_last;
		end
		else
			d_axi_rd_rvalid    <= 0;
			
		if((axi_rd_bid == 1) && axi_rd_rvalid) begin
			e_axi_rd_rvalid    <= 1;
			e_axi_rd_data      <= axi_rd_data;
			e_axi_rd_last      <= axi_rd_last;
		end
		else begin
			e_axi_rd_rvalid    <= 0;
		end
	end
end

endmodule
