

/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * BD Buffer for buffer descriptor (BD) storage
 * Module name: BD Buffer
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.19
 *===========================================================================
 *
 * Version History:
 * v0.0.1:	Initialization version
 *===========================================================================
 */

`timescale 1ns/1ps

  module bd_buffer (
	  input wire			user_clk,
	  input wire			user_reset,
	  
	  //BD Buffer status--output to req_recv
	  output wire [22:0]	bd_buf_ch0_s2c_addr,
	  output wire [22:0]	bd_buf_ch0_c2s_addr,
	  output wire [22:0]	bd_buf_ch1_s2c_addr,
	  output wire [22:0]	bd_buf_ch1_c2s_addr,
	  output wire [15:0]	bd_buf_ch0_s2c_valid,
	  output wire [15:0]	bd_buf_ch0_c2s_valid,
	  output wire [15:0]	bd_buf_ch1_s2c_valid,
	  output wire [15:0]	bd_buf_ch1_c2s_valid,
	  
	  //Command from req_recv
	  input wire [43:0]		m_axis_buffer_cmd_tdata,
	  input wire			m_axis_buffer_cmd_tvalid,
	  input wire [1:0]		m_axis_buffer_cmd_tdest,
	  
	  //BD data to Response Queue
	  output wire [255:0]	m_axis_bd_from_buffer_S2C0_tdata,
	  output wire			m_axis_bd_from_buffer_S2C0_tvalid,
	  output wire [255:0]	m_axis_bd_from_buffer_C2S0_tdata,
	  output wire			m_axis_bd_from_buffer_C2S0_tvalid,
	  output wire [255:0]	m_axis_bd_from_buffer_S2C1_tdata,
	  output wire			m_axis_bd_from_buffer_S2C1_tvalid,
	  output wire [255:0]	m_axis_bd_from_buffer_C2S1_tdata,
	  output wire			m_axis_bd_from_buffer_C2S1_tvalid,
	  
	  //signals from PCIe Interface for BD update
	  input wire [3:0]		m_from_pcie_bd_S2C0_tuser,
	  input wire [255:0]	m_from_pcie_bd_S2C0_tdata,
	  input wire			m_from_pcie_bd_S2C0_tvalid,
	  input wire			m_from_pcie_bd_S2C0_tlast,
	  
	  input wire [3:0]		m_from_pcie_bd_C2S0_tuser,
	  input wire [255:0]	m_from_pcie_bd_C2S0_tdata,
	  input wire			m_from_pcie_bd_C2S0_tvalid,
	  input wire			m_from_pcie_bd_C2S0_tlast,
	  
	  input wire [3:0]		m_from_pcie_bd_S2C1_tuser,
	  input wire [255:0]	m_from_pcie_bd_S2C1_tdata,
	  input wire			m_from_pcie_bd_S2C1_tvalid,
	  input wire			m_from_pcie_bd_S2C1_tlast,
	  
	  input wire [3:0]		m_from_pcie_bd_C2S1_tuser,
	  input wire [255:0]	m_from_pcie_bd_C2S1_tdata,
	  input wire			m_from_pcie_bd_C2S1_tvalid,
	  input wire			m_from_pcie_bd_C2S1_tlast
  ); 

  wire [1:0]			channel_num;
  reg [3:0]				channel_mask;


  assign				channel_num = m_axis_buffer_cmd_tdest;

  always @ (channel_num)
  begin
	  case(channel_num)
		  2'b00: channel_mask = 4'b0001;
		  2'b01: channel_mask = 4'b0010;
		  2'b10: channel_mask = 4'b0100;
		  2'b11: channel_mask = 4'b1000;
		  default: channel_mask = 4'b0000;
	  endcase
  end

  buffer_per_channel buffer_s2c0 (
	  .user_clk							(user_clk),
	  .user_reset						(user_reset),

	  .m_axis_buffer_cmd_tdata			({44{channel_mask[0]}} & m_axis_buffer_cmd_tdata),
	  .m_axis_buffer_cmd_tvalid			(channel_mask[0] & m_axis_buffer_cmd_tvalid),

	  .m_axis_bd_from_buffer_tdata		(m_axis_bd_from_buffer_S2C0_tdata),
	  .m_axis_bd_from_buffer_tvalid		(m_axis_bd_from_buffer_S2C0_tvalid),

	  .m_from_pcie_bd_tuser				(m_from_pcie_bd_S2C0_tuser),
	  .m_from_pcie_bd_tdata				(m_from_pcie_bd_S2C0_tdata),
	  .m_from_pcie_bd_tvalid			(m_from_pcie_bd_S2C0_tvalid),
	  .m_from_pcie_bd_tlast				(m_from_pcie_bd_S2C0_tlast),

	  .bd_buf_addr						(bd_buf_ch0_s2c_addr),
	  .bd_buf_valid						(bd_buf_ch0_s2c_valid)

  );
  
  buffer_per_channel buffer_c2s0 (
	  .user_clk							(user_clk),
	  .user_reset						(user_reset),

	  .m_axis_buffer_cmd_tdata			({44{channel_mask[1]}} & m_axis_buffer_cmd_tdata),
	  .m_axis_buffer_cmd_tvalid			(channel_mask[1] & m_axis_buffer_cmd_tvalid),

	  .m_axis_bd_from_buffer_tdata		(m_axis_bd_from_buffer_C2S0_tdata),
	  .m_axis_bd_from_buffer_tvalid		(m_axis_bd_from_buffer_C2S0_tvalid),

	  .m_from_pcie_bd_tuser				(m_from_pcie_bd_C2S0_tuser),
	  .m_from_pcie_bd_tdata				(m_from_pcie_bd_C2S0_tdata),
	  .m_from_pcie_bd_tvalid			(m_from_pcie_bd_C2S0_tvalid),
	  .m_from_pcie_bd_tlast				(m_from_pcie_bd_C2S0_tlast),

	  .bd_buf_addr						(bd_buf_ch0_c2s_addr),
	  .bd_buf_valid						(bd_buf_ch0_c2s_valid)

  );

  buffer_per_channel buffer_s2c1 (
	  .user_clk							(user_clk),
	  .user_reset						(user_reset),

	  .m_axis_buffer_cmd_tdata			({44{channel_mask[2]}} & m_axis_buffer_cmd_tdata),
	  .m_axis_buffer_cmd_tvalid			(channel_mask[2] & m_axis_buffer_cmd_tvalid),

	  .m_axis_bd_from_buffer_tdata		(m_axis_bd_from_buffer_S2C1_tdata),
	  .m_axis_bd_from_buffer_tvalid		(m_axis_bd_from_buffer_S2C1_tvalid),

	  .m_from_pcie_bd_tuser				(m_from_pcie_bd_S2C1_tuser),
	  .m_from_pcie_bd_tdata				(m_from_pcie_bd_S2C1_tdata),
	  .m_from_pcie_bd_tvalid			(m_from_pcie_bd_S2C1_tvalid),
	  .m_from_pcie_bd_tlast				(m_from_pcie_bd_S2C1_tlast),

	  .bd_buf_addr						(bd_buf_ch1_s2c_addr),
	  .bd_buf_valid						(bd_buf_ch1_s2c_valid)

  );

  buffer_per_channel buffer_c2s1 (
	  .user_clk							(user_clk),
	  .user_reset						(user_reset),

	  .m_axis_buffer_cmd_tdata			({44{channel_mask[3]}} & m_axis_buffer_cmd_tdata),
	  .m_axis_buffer_cmd_tvalid			(channel_mask[3] & m_axis_buffer_cmd_tvalid),

	  .m_axis_bd_from_buffer_tdata		(m_axis_bd_from_buffer_C2S1_tdata),
	  .m_axis_bd_from_buffer_tvalid		(m_axis_bd_from_buffer_C2S1_tvalid),

	  .m_from_pcie_bd_tuser				(m_from_pcie_bd_C2S1_tuser),
	  .m_from_pcie_bd_tdata				(m_from_pcie_bd_C2S1_tdata),
	  .m_from_pcie_bd_tvalid			(m_from_pcie_bd_C2S1_tvalid),
	  .m_from_pcie_bd_tlast				(m_from_pcie_bd_C2S1_tlast),

	  .bd_buf_addr						(bd_buf_ch1_c2s_addr),
	  .bd_buf_valid						(bd_buf_ch1_c2s_valid)

  );


endmodule


