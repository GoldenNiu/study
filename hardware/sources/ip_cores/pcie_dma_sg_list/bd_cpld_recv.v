/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * receive bd cpld from PCIe RC Channel, and send bd to buffer
 * sub module of PCIe Interface
 * Module name: bd cpld receiver
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.18
 *===========================================================================
 *
 * Version History:
 * v0.0.1:	Initialization version
 *===========================================================================
 */

`timescale 1ns/1ps

module bd_cpld_recv (
	input wire			user_clk,
	input wire			user_reset,
	  
	input wire			cpld_first_beat,
	input wire			axis_rc_bd_cpld_tvalid,
	output wire			axis_rc_bd_cpld_tready,
	input wire [255:0]	axis_rc_bd_cpld_tdata,
	input wire			axis_rc_bd_cpld_tlast,
	  
	input wire [2:0]	cfg_max_payload_size,
	input wire [3:0]	bd_size_for_cpld,					
	  
	output wire			m_from_pcie_bd_tvalid,
	output wire			m_from_pcie_bd_tlast,
	output wire [255:0]	m_from_pcie_bd_tdata,
	output reg [3:0]	m_from_pcie_bd_tuser 
); 

  reg [1:0]			cpld_num;
  reg [1:0]			cpld_cnt;

  reg [159:0]		bd_last_data;

  always @ (bd_size_for_cpld or cfg_max_payload_size)
  begin
	  case(cfg_max_payload_size)
		  3'b000: cpld_num = bd_size_for_cpld[3:2];
		  3'b001: cpld_num = {1'b0, bd_size_for_cpld[3]};
		  default: cpld_num = 2'b00;
	  endcase
  end

  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  cpld_cnt <= 2'b00;
	  
	  else if ( ( cpld_cnt == cpld_num ) & axis_rc_bd_cpld_tvalid & axis_rc_bd_cpld_tready & axis_rc_bd_cpld_tlast )
		  cpld_cnt <= 2'b00;
	  
	  else if (axis_rc_bd_cpld_tvalid & axis_rc_bd_cpld_tready & axis_rc_bd_cpld_tlast)
		  cpld_cnt <= cpld_cnt + 2'b01;
	  
	  else
		  cpld_cnt <= cpld_cnt;
  end
	
  always @ (posedge user_clk)
  begin
	  if(user_reset)
	  begin
		  m_from_pcie_bd_tuser <= 'd0;
		  bd_last_data <= 'd0;
	  end
	  
	  else if(axis_rc_bd_cpld_tvalid & axis_rc_bd_cpld_tready)
	  begin
		  m_from_pcie_bd_tuser <= cpld_first_beat ? axis_rc_bd_cpld_tdata[8:5] : 
									(m_from_pcie_bd_tuser + 4'd1);
		  bd_last_data <= axis_rc_bd_cpld_tdata[255:96];
	  end
	  
	  else
	  begin
		  bd_last_data <= bd_last_data;
		  m_from_pcie_bd_tuser <= m_from_pcie_bd_tuser;
	  end
  end

  assign m_from_pcie_bd_tdata = {axis_rc_bd_cpld_tdata[95:0], bd_last_data} ;
  assign m_from_pcie_bd_tlast = (cpld_cnt == cpld_num) & axis_rc_bd_cpld_tlast;
  assign m_from_pcie_bd_tvalid = axis_rc_bd_cpld_tvalid & (~cpld_first_beat);

  assign axis_rc_bd_cpld_tready = 1'b1;

endmodule

