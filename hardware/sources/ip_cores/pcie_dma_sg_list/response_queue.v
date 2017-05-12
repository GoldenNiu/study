/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * arbitrate bd read cpld and other cpld to 
 * RC channel of DMA
 * Module name: response_queue 
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.23
 *===========================================================================
 *
 * Version History:
 * v0.0.1: Initialization version 2017.01.23
 *===========================================================================
 */

`timescale 1ns/1ps

module response_queue (
	input wire				user_clk,
	input wire				user_reset,

	//cpld header from Request Receiver
	input wire [95:0]		m_axis_cpld_header_tdata,
	input wire				m_axis_cpld_header_tvalid,
	input wire [1:0]		m_axis_cpld_header_tdest,
	
	//bd data from bd buffer
	input wire [255:0]		m_axis_bd_from_buffer_S2C0_tdata,
	input wire				m_axis_bd_from_buffer_S2C0_tvalid,
	input wire [255:0]		m_axis_bd_from_buffer_C2S0_tdata,
	input wire				m_axis_bd_from_buffer_C2S0_tvalid,
	input wire [255:0]		m_axis_bd_from_buffer_S2C1_tdata,
	input wire				m_axis_bd_from_buffer_S2C1_tvalid,
	input wire [255:0]		m_axis_bd_from_buffer_C2S1_tdata,
	input wire				m_axis_bd_from_buffer_C2S1_tvalid,

	//non bd cpld from PCIe interface
	input wire				s_axis_rc_bp_tvalid,
	output wire				s_axis_rc_bp_tready,
	input wire				s_axis_rc_bp_tlast,
	input wire	[7:0]		s_axis_rc_bp_tkeep,
	input wire	[255:0]		s_axis_rc_bp_tdata,
	input wire	[74:0]		s_axis_rc_bp_tuser,
	
	//DMA RC channel
	output wire [255:0]		m_axis_dma_rc_tdata,
	output wire				m_axis_dma_rc_tvalid,
	input wire				m_axis_dma_rc_tready,
	output wire				m_axis_dma_rc_tlast,
	output wire [74:0]		m_axis_dma_rc_tuser,
	output wire [7:0]		m_axis_dma_rc_tkeep

);
  
  wire [255:0]			s_axis_bd_read_cpld_S2C0_tdata;
  wire					s_axis_bd_read_cpld_S2C0_tvalid;
  wire					s_axis_bd_read_cpld_S2C0_tready;
  wire					s_axis_bd_read_cpld_S2C0_tlast;
  wire [74:0]			s_axis_bd_read_cpld_S2C0_tuser;
  wire [7:0]			s_axis_bd_read_cpld_S2C0_tkeep;

  wire [255:0]			s_axis_bd_read_cpld_C2S0_tdata;
  wire					s_axis_bd_read_cpld_C2S0_tvalid;
  wire					s_axis_bd_read_cpld_C2S0_tready;
  wire					s_axis_bd_read_cpld_C2S0_tlast;
  wire [74:0]			s_axis_bd_read_cpld_C2S0_tuser;
  wire [7:0]			s_axis_bd_read_cpld_C2S0_tkeep;

  wire [255:0]			s_axis_bd_read_cpld_S2C1_tdata;
  wire					s_axis_bd_read_cpld_S2C1_tvalid;
  wire					s_axis_bd_read_cpld_S2C1_tready;
  wire					s_axis_bd_read_cpld_S2C1_tlast;
  wire [74:0]			s_axis_bd_read_cpld_S2C1_tuser;
  wire [7:0]			s_axis_bd_read_cpld_S2C1_tkeep;

  wire [255:0]			s_axis_bd_read_cpld_C2S1_tdata;
  wire					s_axis_bd_read_cpld_C2S1_tvalid;
  wire					s_axis_bd_read_cpld_C2S1_tready;
  wire					s_axis_bd_read_cpld_C2S1_tlast;
  wire [74:0]			s_axis_bd_read_cpld_C2S1_tuser;
  wire [7:0]			s_axis_bd_read_cpld_C2S1_tkeep;
  
  wire [20:0]			m_axis_dma_rc_tuser_high;

  reg [3:0]				cpld_header_channel_mask;


  always @ (m_axis_cpld_header_tdest)
  begin
	  case(m_axis_cpld_header_tdest)
		  2'b00:  cpld_header_channel_mask = 4'b0001;
		  2'b01:  cpld_header_channel_mask = 4'b0010;
		  2'b10:  cpld_header_channel_mask = 4'b0100;
		  2'b11:  cpld_header_channel_mask = 4'b1000;
		  default:  cpld_header_channel_mask = 4'b0000;
	  endcase
  end

  cpld_packager  cpld_packager_s2c0 (
	  .user_clk							(user_clk),
	  .user_reset						(user_reset),

	  .m_axis_cpld_header_tdata			({256{cpld_header_channel_mask[0]}} & m_axis_cpld_header_tdata),
	  .m_axis_cpld_header_tvalid		(cpld_header_channel_mask[0] & m_axis_cpld_header_tvalid),

	  .m_axis_bd_from_buffer_tdata		(m_axis_bd_from_buffer_S2C0_tdata),
	  .m_axis_bd_from_buffer_tvalid		(m_axis_bd_from_buffer_S2C0_tvalid),

	  .s_axis_bd_read_cpld_tdata		(s_axis_bd_read_cpld_S2C0_tdata),
	  .s_axis_bd_read_cpld_tvalid		(s_axis_bd_read_cpld_S2C0_tvalid),
	  .s_axis_bd_read_cpld_tready		(s_axis_bd_read_cpld_S2C0_tready),
	  .s_axis_bd_read_cpld_tlast		(s_axis_bd_read_cpld_S2C0_tlast),
	  .s_axis_bd_read_cpld_tuser		(s_axis_bd_read_cpld_S2C0_tuser),
	  .s_axis_bd_read_cpld_tkeep		(s_axis_bd_read_cpld_S2C0_tkeep)
  );
  


  cpld_packager  cpld_packager_c2s0 (
	  .user_clk							(user_clk),
	  .user_reset						(user_reset),

	  .m_axis_cpld_header_tdata			({256{cpld_header_channel_mask[1]}} & m_axis_cpld_header_tdata),
	  .m_axis_cpld_header_tvalid		(cpld_header_channel_mask[1] & m_axis_cpld_header_tvalid),

	  .m_axis_bd_from_buffer_tdata		(m_axis_bd_from_buffer_C2S0_tdata),
	  .m_axis_bd_from_buffer_tvalid		(m_axis_bd_from_buffer_C2S0_tvalid),

	  .s_axis_bd_read_cpld_tdata		(s_axis_bd_read_cpld_C2S0_tdata),
	  .s_axis_bd_read_cpld_tvalid		(s_axis_bd_read_cpld_C2S0_tvalid),
	  .s_axis_bd_read_cpld_tready		(s_axis_bd_read_cpld_C2S0_tready),
	  .s_axis_bd_read_cpld_tlast		(s_axis_bd_read_cpld_C2S0_tlast),
	  .s_axis_bd_read_cpld_tuser		(s_axis_bd_read_cpld_C2S0_tuser),
	  .s_axis_bd_read_cpld_tkeep		(s_axis_bd_read_cpld_C2S0_tkeep)
  );
  


  cpld_packager  cpld_packager_s2c1 (
	  .user_clk							(user_clk),
	  .user_reset						(user_reset),

	  .m_axis_cpld_header_tdata			({256{cpld_header_channel_mask[2]}} & m_axis_cpld_header_tdata),
	  .m_axis_cpld_header_tvalid		(cpld_header_channel_mask[2] & m_axis_cpld_header_tvalid),

	  .m_axis_bd_from_buffer_tdata		(m_axis_bd_from_buffer_S2C1_tdata),
	  .m_axis_bd_from_buffer_tvalid		(m_axis_bd_from_buffer_S2C1_tvalid),

	  .s_axis_bd_read_cpld_tdata		(s_axis_bd_read_cpld_S2C1_tdata),
	  .s_axis_bd_read_cpld_tvalid		(s_axis_bd_read_cpld_S2C1_tvalid),
	  .s_axis_bd_read_cpld_tready		(s_axis_bd_read_cpld_S2C1_tready),
	  .s_axis_bd_read_cpld_tlast		(s_axis_bd_read_cpld_S2C1_tlast),
	  .s_axis_bd_read_cpld_tuser		(s_axis_bd_read_cpld_S2C1_tuser),
	  .s_axis_bd_read_cpld_tkeep		(s_axis_bd_read_cpld_S2C1_tkeep)
  );
  


  cpld_packager  cpld_packager_c2s1 (
	  .user_clk							(user_clk),
	  .user_reset						(user_reset),

	  .m_axis_cpld_header_tdata			({256{cpld_header_channel_mask[3]}} & m_axis_cpld_header_tdata),
	  .m_axis_cpld_header_tvalid		(cpld_header_channel_mask[3] & m_axis_cpld_header_tvalid),

	  .m_axis_bd_from_buffer_tdata		(m_axis_bd_from_buffer_C2S1_tdata),
	  .m_axis_bd_from_buffer_tvalid		(m_axis_bd_from_buffer_C2S1_tvalid),

	  .s_axis_bd_read_cpld_tdata		(s_axis_bd_read_cpld_C2S1_tdata),
	  .s_axis_bd_read_cpld_tvalid		(s_axis_bd_read_cpld_C2S1_tvalid),
	  .s_axis_bd_read_cpld_tready		(s_axis_bd_read_cpld_C2S1_tready),
	  .s_axis_bd_read_cpld_tlast		(s_axis_bd_read_cpld_C2S1_tlast),
	  .s_axis_bd_read_cpld_tuser		(s_axis_bd_read_cpld_C2S1_tuser),
	  .s_axis_bd_read_cpld_tkeep		(s_axis_bd_read_cpld_C2S1_tkeep)
  );

  //5:1 DEMUX to DMA RC interface
  axis_ic_5x1_rc	axis_ic_rc (
	  .ACLK							(user_clk),
	  .ARESETN						(~user_reset),

	  .S00_AXIS_ACLK				(user_clk),
	  .S00_AXIS_ARESETN				(~user_reset),
	  .S00_AXIS_TVALID				(s_axis_rc_bp_tvalid),
	  .S00_AXIS_TREADY				(s_axis_rc_bp_tready),
	  .S00_AXIS_TLAST				(s_axis_rc_bp_tlast),
	  .S00_AXIS_TKEEP				(s_axis_rc_bp_tkeep),
	  .S00_AXIS_TDATA				(s_axis_rc_bp_tdata),
	  .S00_AXIS_TUSER				({21'd0, s_axis_rc_bp_tuser}),
	  .S00_ARB_REQ_SUPPRESS			(1'b0),

	  .S01_AXIS_ACLK				(user_clk),
	  .S01_AXIS_ARESETN				(~user_reset),
	  .S01_AXIS_TVALID				(s_axis_bd_read_cpld_S2C0_tvalid),
	  .S01_AXIS_TREADY				(s_axis_bd_read_cpld_S2C0_tready),
	  .S01_AXIS_TLAST				(s_axis_bd_read_cpld_S2C0_tlast),
	  .S01_AXIS_TKEEP				(s_axis_bd_read_cpld_S2C0_tkeep),
	  .S01_AXIS_TDATA				(s_axis_bd_read_cpld_S2C0_tdata),
	  .S01_AXIS_TUSER				({21'd0, s_axis_bd_read_cpld_S2C0_tuser}),
	  .S01_ARB_REQ_SUPPRESS			(1'b0),

	  .S02_AXIS_ACLK				(user_clk),
	  .S02_AXIS_ARESETN				(~user_reset),
	  .S02_AXIS_TVALID				(s_axis_bd_read_cpld_C2S0_tvalid),
	  .S02_AXIS_TREADY				(s_axis_bd_read_cpld_C2S0_tready),
	  .S02_AXIS_TLAST				(s_axis_bd_read_cpld_C2S0_tlast),
	  .S02_AXIS_TKEEP				(s_axis_bd_read_cpld_C2S0_tkeep),
	  .S02_AXIS_TDATA				(s_axis_bd_read_cpld_C2S0_tdata),
	  .S02_AXIS_TUSER				({21'd0, s_axis_bd_read_cpld_C2S0_tuser}),
	  .S02_ARB_REQ_SUPPRESS			(1'b0),

	  .S03_AXIS_ACLK				(user_clk),
	  .S03_AXIS_ARESETN				(~user_reset),
	  .S03_AXIS_TVALID				(s_axis_bd_read_cpld_S2C1_tvalid),
	  .S03_AXIS_TREADY				(s_axis_bd_read_cpld_S2C1_tready),
	  .S03_AXIS_TLAST				(s_axis_bd_read_cpld_S2C1_tlast),
	  .S03_AXIS_TKEEP				(s_axis_bd_read_cpld_S2C1_tkeep),
	  .S03_AXIS_TDATA				(s_axis_bd_read_cpld_S2C1_tdata),
	  .S03_AXIS_TUSER				({21'd0, s_axis_bd_read_cpld_S2C1_tuser}),
	  .S03_ARB_REQ_SUPPRESS			(1'b0),
	  
	  .S04_AXIS_ACLK				(user_clk),
	  .S04_AXIS_ARESETN				(~user_reset),
	  .S04_AXIS_TVALID				(s_axis_bd_read_cpld_C2S1_tvalid),
	  .S04_AXIS_TREADY				(s_axis_bd_read_cpld_C2S1_tready),
	  .S04_AXIS_TLAST				(s_axis_bd_read_cpld_C2S1_tlast),
	  .S04_AXIS_TKEEP				(s_axis_bd_read_cpld_C2S1_tkeep),
	  .S04_AXIS_TDATA				(s_axis_bd_read_cpld_C2S1_tdata),
	  .S04_AXIS_TUSER				({21'd0, s_axis_bd_read_cpld_C2S1_tuser}),
	  .S04_ARB_REQ_SUPPRESS			(1'b0),
	  
	  .M00_AXIS_ACLK				(user_clk),
	  .M00_AXIS_ARESETN				(~user_reset),
	  .M00_AXIS_TVALID				(m_axis_dma_rc_tvalid),
	  .M00_AXIS_TREADY				(m_axis_dma_rc_tready),
	  .M00_AXIS_TLAST				(m_axis_dma_rc_tlast),
	  .M00_AXIS_TKEEP				(m_axis_dma_rc_tkeep),
	  .M00_AXIS_TDATA				(m_axis_dma_rc_tdata),
	  .M00_AXIS_TUSER				({m_axis_dma_rc_tuser_high, m_axis_dma_rc_tuser})
  );




endmodule

