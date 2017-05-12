/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * Request Generator for BD read request generation
 * sub module of PCIe Interface
 * Module name: Request Generator
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.18
 *===========================================================================
 *
 * Version History:
 * v0.0.1:	Initialization version
 *===========================================================================
 */

`timescale 1ns/1ps

module request_gen (
	input wire			user_clk,
	input wire			user_reset,
	
	input wire [2:0]	cfg_max_rd_req_size,
	output reg [3:0]	bd_size_for_cpld,
	
	input wire			axis_rq_bd_read_tvalid,
	output reg			axis_rq_bd_read_tready,
	input wire [255:0]	axis_rq_bd_read_tdata,
	
	output reg			axis_rq_bd_out_tvalid,
	output wire			axis_rq_bd_out_tlast,
	output wire [255:0]	axis_rq_bd_out_tdata,
	input wire			axis_rq_bd_out_tready
); 

  wire [4:0]	bd_size;
  wire [4:0]	bd_req_size;
  wire [3:0]	bd_req_addr;
  reg [4:0]		bd_first_req_size;
  reg [4:0]		bd_last_req_size;
  reg [1:0]		bd_max_req_num;						
  
  reg [26:0]	bd_sub_req_addr;
  reg [1:0]		bd_sub_req_cnt;
  reg [255:0]	bd_req_header;
  
  wire [4:0]	bd_sub_req_size;
  reg [4:0]		bd_sub_req_max_size;

/*DMA request receiver*/
  always @ (cfg_max_rd_req_size)
  begin
	  case(cfg_max_rd_req_size)
		  3'b000: bd_sub_req_max_size = 5'd4;
		  3'b001: bd_sub_req_max_size = 5'd8;
		  default: bd_sub_req_max_size = 5'd16;
	  endcase
  end

  //BD SIZE in pcie request subtract 1 
  assign bd_req_size = ({5{axis_rq_bd_read_tvalid}} & axis_rq_bd_read_tdata[71:67]) + 5'h1F;
  //BD request base address
  assign bd_req_addr = ({4{axis_rq_bd_read_tvalid}} & axis_rq_bd_read_tdata[8:5]);
  
  assign bd_size = (cfg_max_rd_req_size == 3'b000)? {{3'b0, bd_req_addr[1:0]} + bd_req_size}
					: ((cfg_max_rd_req_size == 3'b001)? {{2'b0, bd_req_addr[2:0]} + bd_req_size}
					: bd_req_size);
  //store BD size for cpld recv module
  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  bd_size_for_cpld <= 4'd0;
	  else if(axis_rq_bd_read_tvalid & axis_rq_bd_read_tready)
		  bd_size_for_cpld <= bd_size[3:0];
	  else
		  bd_size_for_cpld <= bd_size_for_cpld;
  end

  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  axis_rq_bd_read_tready <= 1'b1;
	  else if (axis_rq_bd_read_tready & axis_rq_bd_read_tvalid)
		  axis_rq_bd_read_tready <= 1'b0;
	  else if ( ~axis_rq_bd_read_tready & (bd_sub_req_cnt == bd_max_req_num) & axis_rq_bd_out_tvalid & axis_rq_bd_out_tready )
		  axis_rq_bd_read_tready <= 1'b1;
	  else
		  axis_rq_bd_read_tready <= axis_rq_bd_read_tready;
  end

  //store BD number in the last PCIe Non-Posted request and 
  //the maximum BD request number
  always @ (posedge user_clk)
  begin
	  if (user_reset)
	  begin
		  bd_first_req_size <= 5'd0;
		  bd_last_req_size <= 5'd0;
		  bd_max_req_num <= 2'b00;
	  end
	  
	  else if (axis_rq_bd_read_tvalid & axis_rq_bd_read_tready)
	  begin
		  case(cfg_max_rd_req_size)
			  3'b000: begin
				  bd_first_req_size <= (|bd_size[3:2])? {2'd0, {{1'b0, ~bd_req_addr[1:0]} + 3'b001}}
														: (bd_req_size + 5'd1);
				  bd_last_req_size <= {2'd0, {{1'b0, bd_size[1:0]} + 3'd1}};
				  bd_max_req_num <= bd_size[3:2];
			  end
			  
			  3'b001: begin
				  bd_first_req_size <= (|bd_size[3])? {1'b0, {{1'b0, ~bd_req_addr[2:0]} + 4'b0001}}
														: (bd_req_size + 5'd1);
				  bd_last_req_size <= {1'b0, {{1'b0, bd_size[2:0]} + 4'd1}};
				  bd_max_req_num <= {1'b0, bd_size[3]};
			  end
			  
			  default: begin
				  bd_first_req_size <= bd_req_size + 5'd1;
				  bd_last_req_size <= bd_req_size + 5'd1;
				  bd_max_req_num <= 2'b00;
			  end
		  endcase
	  end

	  else
	  begin
		  bd_first_req_size <= bd_first_req_size;
		  bd_last_req_size <= bd_last_req_size;
		  bd_max_req_num <= bd_max_req_num;
	  end
  end
  
  //DMA request header
  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  bd_req_header <= 'd0;
	  else if(axis_rq_bd_read_tvalid & axis_rq_bd_read_tready)
		  bd_req_header <= axis_rq_bd_read_tdata;
	  else
		  bd_req_header <= bd_req_header;
  end

/*PCIe non-posted request generation*/
  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  bd_sub_req_addr <= 'd0;
	  else if(axis_rq_bd_read_tvalid & axis_rq_bd_read_tready)
		  bd_sub_req_addr <= axis_rq_bd_read_tdata[31:5];
	  else if(axis_rq_bd_out_tvalid & axis_rq_bd_out_tready)
		  bd_sub_req_addr <= bd_sub_req_addr + {22'd0, bd_sub_req_size};
	  else
		  bd_sub_req_addr <= bd_sub_req_addr;
  end

  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  bd_sub_req_cnt <= 'd0;
	  else if(axis_rq_bd_read_tvalid & axis_rq_bd_read_tready)
		  bd_sub_req_cnt <= 'd0;
	  else if(axis_rq_bd_out_tvalid & axis_rq_bd_out_tready)
		  bd_sub_req_cnt <= bd_sub_req_cnt + 2'd1;
	  else
		  bd_sub_req_cnt <= bd_sub_req_cnt;
  end

  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  axis_rq_bd_out_tvalid <= 'd0;
	  else if(axis_rq_bd_read_tvalid & axis_rq_bd_read_tready)
		  axis_rq_bd_out_tvalid <= 'd1;
	  else if(axis_rq_bd_out_tvalid & axis_rq_bd_out_tready)
		  axis_rq_bd_out_tvalid <= ~(bd_sub_req_cnt == bd_max_req_num);
	  else
		  axis_rq_bd_out_tvalid <= axis_rq_bd_out_tvalid;
  end

  assign bd_sub_req_size = (bd_sub_req_cnt == 'd0)? bd_first_req_size :	
							((bd_sub_req_cnt == bd_max_req_num)? bd_last_req_size :
							bd_sub_req_max_size);

  assign axis_rq_bd_out_tdata = {bd_req_header[255:98], bd_sub_req_cnt, 
								bd_req_header[95:75], 3'd0, bd_sub_req_size, 3'd0, 
								bd_req_header[63:32], bd_sub_req_addr, 5'd0};

  assign axis_rq_bd_out_tlast = axis_rq_bd_out_tvalid;

endmodule

