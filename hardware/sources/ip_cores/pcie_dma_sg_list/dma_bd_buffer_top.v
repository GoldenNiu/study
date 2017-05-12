/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * DMA BD Buffer for accelerating buffer descriptor(BD) 
 * read process
 * top module of DMA BD Buffer
 * Module name: dma bd buffer top 
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.24
 *===========================================================================
 *
 * Version History:
 * v0.0.1: Initialization version 2017.01.24
 *===========================================================================
 */

`timescale 1ns/1ps

module dma_bd_buffer_top (
	input wire				user_clk,
	input wire				user_reset,

	input wire [2:0]		cfg_max_payload_size,
	input wire [2:0]		cfg_max_rd_req_size,

	//DMA RQ channel
	input wire [255:0]		s_axis_dma_rq_tdata,
	input wire				s_axis_dma_rq_tvalid,
	output wire				s_axis_dma_rq_tready,
	input wire				s_axis_dma_rq_tlast,
	input wire [59:0]		s_axis_dma_rq_tuser,
	input wire [7:0]		s_axis_dma_rq_tkeep,
	
	//DMA RC channel
	output wire [255:0]		m_axis_dma_rc_tdata,
	output wire				m_axis_dma_rc_tvalid,
	input wire				m_axis_dma_rc_tready,
	output wire				m_axis_dma_rc_tlast,
	output wire [74:0]		m_axis_dma_rc_tuser,
	output wire [7:0]		m_axis_dma_rc_tkeep,
	
	//PCIe RQ channel
	output wire [255:0]		s_axis_rq_pcie_tdata,
	output wire				s_axis_rq_pcie_tvalid,
	input wire				s_axis_rq_pcie_tready,
	output wire				s_axis_rq_pcie_tlast,
	output wire [59:0]		s_axis_rq_pcie_tuser,
	output wire [7:0]		s_axis_rq_pcie_tkeep,
	
	//PCIe RC channel
	input wire [255:0]		m_axis_rc_pcie_tdata,
	input wire				m_axis_rc_pcie_tvalid,
	output wire				m_axis_rc_pcie_tready,
	input wire				m_axis_rc_pcie_tlast,
	input wire [74:0]		m_axis_rc_pcie_tuser,
	input wire [7:0]		m_axis_rc_pcie_tkeep,
	
	//PCIe CQ channel signals 
	input wire [255:0]		m_axis_cq_pcie_tdata,
	input wire				m_axis_cq_pcie_tvalid,
	input wire				m_axis_cq_pcie_tready,
	input wire [7:0]		m_axis_cq_pcie_tkeep,
	
	//DMA BD address and total size in host memory
	input wire	[26:0]		ch0_s2c_bd_base,
	input wire	[26:0]		ch0_s2c_bd_high,
	input wire	[26:0]		ch0_c2s_bd_base,
	input wire	[26:0]		ch0_c2s_bd_high,
	input wire	[26:0]		ch1_s2c_bd_base,
	input wire	[26:0]		ch1_s2c_bd_high,
	input wire	[26:0]		ch1_c2s_bd_base,
	input wire	[26:0]		ch1_c2s_bd_high


);
  
  //signals from Req Recv to PCIe IF 
  wire [255:0]			m_axis_rq_from_rec_tdata;
  wire					m_axis_rq_from_rec_tvalid;
  wire					m_axis_rq_from_rec_tready;
  wire					m_axis_rq_from_rec_tlast;
  wire [59:0]			m_axis_rq_from_rec_tuser;
  wire [7:0]			m_axis_rq_from_rec_tkeep;

  //signals from PCIe IF to Resp Queue
  wire [255:0]			s_axis_rc_bp_tdata;
  wire					s_axis_rc_bp_tvalid;
  wire					s_axis_rc_bp_tready;
  wire					s_axis_rc_bp_tlast;
  wire [74:0]			s_axis_rc_bp_tuser;
  wire [7:0]			s_axis_rc_bp_tkeep;

  //signals from PCIe IF to BD Buffer
  wire [255:0]			m_from_pcie_bd_S2C0_tdata;
  wire					m_from_pcie_bd_S2C0_tvalid;
  wire					m_from_pcie_bd_S2C0_tlast;
  wire [3:0]			m_from_pcie_bd_S2C0_tuser;

  wire [255:0]			m_from_pcie_bd_C2S0_tdata;
  wire					m_from_pcie_bd_C2S0_tvalid;
  wire					m_from_pcie_bd_C2S0_tlast;
  wire [3:0]			m_from_pcie_bd_C2S0_tuser;

  wire [255:0]			m_from_pcie_bd_S2C1_tdata;
  wire					m_from_pcie_bd_S2C1_tvalid;
  wire					m_from_pcie_bd_S2C1_tlast;
  wire [3:0]			m_from_pcie_bd_S2C1_tuser;

  wire [255:0]			m_from_pcie_bd_C2S1_tdata;
  wire					m_from_pcie_bd_C2S1_tvalid;
  wire					m_from_pcie_bd_C2S1_tlast;
  wire [3:0]			m_from_pcie_bd_C2S1_tuser;
  
  //software pointer from PCIe CQ IF to Req Recv
  wire [26:0]			ch0_s2c_sw_ptr;
  wire [26:0]			ch0_c2s_sw_ptr;
  wire [26:0]			ch1_s2c_sw_ptr;
  wire [26:0]			ch1_c2s_sw_ptr;
  
  //signals from BD Buffer to Req Recv
  wire [22:0]			bd_buf_ch0_s2c_addr;
  wire [22:0]			bd_buf_ch0_c2s_addr;
  wire [22:0]			bd_buf_ch1_s2c_addr;
  wire [22:0]			bd_buf_ch1_c2s_addr;
  wire [15:0]			bd_buf_ch0_s2c_valid;
  wire [15:0]			bd_buf_ch0_c2s_valid;
  wire [15:0]			bd_buf_ch1_s2c_valid;
  wire [15:0]			bd_buf_ch1_c2s_valid;

  //signals from BD Buffer to Resp Queue
  wire [255:0]			m_axis_bd_from_buffer_S2C0_tdata;
  wire					m_axis_bd_from_buffer_S2C0_tvalid;
  wire [255:0]			m_axis_bd_from_buffer_C2S0_tdata;
  wire					m_axis_bd_from_buffer_C2S0_tvalid;
  wire [255:0]			m_axis_bd_from_buffer_S2C1_tdata;
  wire					m_axis_bd_from_buffer_S2C1_tvalid;
  wire [255:0]			m_axis_bd_from_buffer_C2S1_tdata;
  wire					m_axis_bd_from_buffer_C2S1_tvalid;

  //signals from Req Recv to BD Buffer
  wire [43:0]			m_axis_buffer_cmd_tdata;
  wire					m_axis_buffer_cmd_tvalid;
  wire [1:0]			m_axis_buffer_cmd_tdest;
  
  //signals from Req Recv to Resp Queue
  wire [95:0]			m_axis_cpld_header_tdata;
  wire					m_axis_cpld_header_tvalid;
  wire [1:0]			m_axis_cpld_header_tdest;

  dma_request_recv dma_request_recv (
	  .user_clk						(user_clk),
	  .user_reset					(user_reset),

	  .s_axis_dma_rq_tvalid			(s_axis_dma_rq_tvalid),
	  .s_axis_dma_rq_tready			(s_axis_dma_rq_tready),
	  .s_axis_dma_rq_tlast			(s_axis_dma_rq_tlast),
	  .s_axis_dma_rq_tkeep			(s_axis_dma_rq_tkeep),
	  .s_axis_dma_rq_tdata			(s_axis_dma_rq_tdata),
	  .s_axis_dma_rq_tuser			(s_axis_dma_rq_tuser),

	  .m_axis_rq_from_rec_tvalid    (m_axis_rq_from_rec_tvalid),
	  .m_axis_rq_from_rec_tready	(m_axis_rq_from_rec_tready),
	  .m_axis_rq_from_rec_tlast		(m_axis_rq_from_rec_tlast),
	  .m_axis_rq_from_rec_tdest		(m_axis_rq_from_rec_tdest),
	  .m_axis_rq_from_rec_tkeep		(m_axis_rq_from_rec_tkeep),
	  .m_axis_rq_from_rec_tdata		(m_axis_rq_from_rec_tdata),
	  .m_axis_rq_from_rec_tuser		(m_axis_rq_from_rec_tuser),

	  .bd_buf_ch0_s2c_addr			(bd_buf_ch0_s2c_addr),
	  .bd_buf_ch0_c2s_addr			(bd_buf_ch0_c2s_addr),
	  .bd_buf_ch1_s2c_addr			(bd_buf_ch1_s2c_addr),
	  .bd_buf_ch1_c2s_addr			(bd_buf_ch1_c2s_addr),
	  .bd_buf_ch0_s2c_valid			(bd_buf_ch0_s2c_valid),
	  .bd_buf_ch0_c2s_valid			(bd_buf_ch0_c2s_valid),
	  .bd_buf_ch1_s2c_valid			(bd_buf_ch1_s2c_valid),
	  .bd_buf_ch1_c2s_valid			(bd_buf_ch1_c2s_valid),

	  .m_axis_buffer_cmd_tdata		(m_axis_buffer_cmd_tdata),
	  .m_axis_buffer_cmd_tvalid		(m_axis_buffer_cmd_tvalid),
	  .m_axis_buffer_cmd_tdest		(m_axis_buffer_cmd_tdest),

	  .m_axis_cpld_header_tdata		(m_axis_cpld_header_tdata),
	  .m_axis_cpld_header_tdest		(m_axis_cpld_header_tdest),
	  .m_axis_cpld_header_tvalid	(m_axis_cpld_header_tvalid),

	  .ch0_s2c_bd_base				(ch0_s2c_bd_base),
	  .ch0_s2c_bd_high				(ch0_s2c_bd_high),
	  .ch0_c2s_bd_base				(ch0_c2s_bd_base),
	  .ch0_c2s_bd_high				(ch0_c2s_bd_high),
	  .ch1_s2c_bd_base				(ch1_s2c_bd_base),
	  .ch1_s2c_bd_high				(ch1_s2c_bd_high),
	  .ch1_c2s_bd_base				(ch1_c2s_bd_base),
	  .ch1_c2s_bd_high				(ch1_c2s_bd_high),

	  .ch0_s2c_sw_ptr				(ch0_s2c_sw_ptr),
	  .ch0_c2s_sw_ptr				(ch0_c2s_sw_ptr),
	  .ch1_s2c_sw_ptr				(ch1_s2c_sw_ptr),
	  .ch1_c2s_sw_ptr				(ch1_c2s_sw_ptr)
  );

  bd_buffer bd_buffer (
	  .user_clk								(user_clk),
	  .user_reset							(user_reset),

	  .bd_buf_ch0_s2c_addr					(bd_buf_ch0_s2c_addr),
	  .bd_buf_ch0_c2s_addr					(bd_buf_ch0_c2s_addr),
	  .bd_buf_ch1_s2c_addr					(bd_buf_ch1_s2c_addr),
	  .bd_buf_ch1_c2s_addr					(bd_buf_ch1_c2s_addr),
	  .bd_buf_ch0_s2c_valid					(bd_buf_ch0_s2c_valid),
	  .bd_buf_ch0_c2s_valid					(bd_buf_ch0_c2s_valid),
	  .bd_buf_ch1_s2c_valid					(bd_buf_ch1_s2c_valid),
	  .bd_buf_ch1_c2s_valid					(bd_buf_ch1_c2s_valid),

	  .m_axis_buffer_cmd_tdata				(m_axis_buffer_cmd_tdata),
	  .m_axis_buffer_cmd_tvalid				(m_axis_buffer_cmd_tvalid),
	  .m_axis_buffer_cmd_tdest				(m_axis_buffer_cmd_tdest),

	  .m_axis_bd_from_buffer_S2C0_tdata		(m_axis_bd_from_buffer_S2C0_tdata),
	  .m_axis_bd_from_buffer_S2C0_tvalid	(m_axis_bd_from_buffer_S2C0_tvalid),
	  .m_axis_bd_from_buffer_C2S0_tdata		(m_axis_bd_from_buffer_C2S0_tdata),
	  .m_axis_bd_from_buffer_C2S0_tvalid	(m_axis_bd_from_buffer_C2S0_tvalid),
	  .m_axis_bd_from_buffer_S2C1_tdata		(m_axis_bd_from_buffer_S2C1_tdata),
	  .m_axis_bd_from_buffer_S2C1_tvalid	(m_axis_bd_from_buffer_S2C1_tvalid),
	  .m_axis_bd_from_buffer_C2S1_tdata		(m_axis_bd_from_buffer_C2S1_tdata),
	  .m_axis_bd_from_buffer_C2S1_tvalid	(m_axis_bd_from_buffer_C2S1_tvalid),
  
	  .m_from_pcie_bd_S2C0_tuser			(m_from_pcie_bd_S2C0_tuser),
	  .m_from_pcie_bd_S2C0_tdata			(m_from_pcie_bd_S2C0_tdata),
	  .m_from_pcie_bd_S2C0_tvalid			(m_from_pcie_bd_S2C0_tvalid),
	  .m_from_pcie_bd_S2C0_tlast			(m_from_pcie_bd_S2C0_tlast),
  
	  .m_from_pcie_bd_C2S0_tuser			(m_from_pcie_bd_C2S0_tuser),
	  .m_from_pcie_bd_C2S0_tdata			(m_from_pcie_bd_C2S0_tdata),
	  .m_from_pcie_bd_C2S0_tvalid			(m_from_pcie_bd_C2S0_tvalid),
	  .m_from_pcie_bd_C2S0_tlast			(m_from_pcie_bd_C2S0_tlast),
  
	  .m_from_pcie_bd_S2C1_tuser			(m_from_pcie_bd_S2C1_tuser),
	  .m_from_pcie_bd_S2C1_tdata			(m_from_pcie_bd_S2C1_tdata),
	  .m_from_pcie_bd_S2C1_tvalid			(m_from_pcie_bd_S2C1_tvalid),
	  .m_from_pcie_bd_S2C1_tlast			(m_from_pcie_bd_S2C1_tlast),
  
	  .m_from_pcie_bd_C2S1_tuser			(m_from_pcie_bd_C2S1_tuser),
	  .m_from_pcie_bd_C2S1_tdata			(m_from_pcie_bd_C2S1_tdata),
	  .m_from_pcie_bd_C2S1_tvalid			(m_from_pcie_bd_C2S1_tvalid),
	  .m_from_pcie_bd_C2S1_tlast			(m_from_pcie_bd_C2S1_tlast)
  
  );

  pcie_if pcie_if (
	  .user_clk								(user_clk),
	  .user_reset							(user_reset),

	  .m_axis_rq_from_rec_tvalid			(m_axis_rq_from_rec_tvalid),
	  .m_axis_rq_from_rec_tready			(m_axis_rq_from_rec_tready),
	  .m_axis_rq_from_rec_tlast				(m_axis_rq_from_rec_tlast),
	  .m_axis_rq_from_rec_tdest				(m_axis_rq_from_rec_tdest),
	  .m_axis_rq_from_rec_tkeep				(m_axis_rq_from_rec_tkeep),
	  .m_axis_rq_from_rec_tdata				(m_axis_rq_from_rec_tdata),
	  .m_axis_rq_from_rec_tuser				(m_axis_rq_from_rec_tuser),

	  .s_axis_rq_pcie_tvalid				(s_axis_rq_pcie_tvalid),
	  .s_axis_rq_pcie_tready				(s_axis_rq_pcie_tready),
	  .s_axis_rq_pcie_tlast					(s_axis_rq_pcie_tlast),
	  .s_axis_rq_pcie_tkeep					(s_axis_rq_pcie_tkeep),
	  .s_axis_rq_pcie_tdata					(s_axis_rq_pcie_tdata),
	  .s_axis_rq_pcie_tuser					(s_axis_rq_pcie_tuser),

	  .m_axis_rc_pcie_tvalid				(m_axis_rc_pcie_tvalid),
	  .m_axis_rc_pcie_tready				(m_axis_rc_pcie_tready),
	  .m_axis_rc_pcie_tlast					(m_axis_rc_pcie_tlast),
	  .m_axis_rc_pcie_tkeep					(m_axis_rc_pcie_tkeep),
	  .m_axis_rc_pcie_tdata					(m_axis_rc_pcie_tdata),
	  .m_axis_rc_pcie_tuser					(m_axis_rc_pcie_tuser),

	  .s_axis_rc_bp_tvalid					(s_axis_rc_bp_tvalid),
	  .s_axis_rc_bp_tready					(s_axis_rc_bp_tready),
	  .s_axis_rc_bp_tlast					(s_axis_rc_bp_tlast),
	  .s_axis_rc_bp_tkeep					(s_axis_rc_bp_tkeep),
	  .s_axis_rc_bp_tdata					(s_axis_rc_bp_tdata),
	  .s_axis_rc_bp_tuser					(s_axis_rc_bp_tuser),
  
	  .m_from_pcie_bd_S2C0_tuser			(m_from_pcie_bd_S2C0_tuser),
	  .m_from_pcie_bd_S2C0_tdata			(m_from_pcie_bd_S2C0_tdata),
	  .m_from_pcie_bd_S2C0_tvalid			(m_from_pcie_bd_S2C0_tvalid),
	  .m_from_pcie_bd_S2C0_tlast			(m_from_pcie_bd_S2C0_tlast),
  
	  .m_from_pcie_bd_C2S0_tuser			(m_from_pcie_bd_C2S0_tuser),
	  .m_from_pcie_bd_C2S0_tdata			(m_from_pcie_bd_C2S0_tdata),
	  .m_from_pcie_bd_C2S0_tvalid			(m_from_pcie_bd_C2S0_tvalid),
	  .m_from_pcie_bd_C2S0_tlast			(m_from_pcie_bd_C2S0_tlast),
  
	  .m_from_pcie_bd_S2C1_tuser			(m_from_pcie_bd_S2C1_tuser),
	  .m_from_pcie_bd_S2C1_tdata			(m_from_pcie_bd_S2C1_tdata),
	  .m_from_pcie_bd_S2C1_tvalid			(m_from_pcie_bd_S2C1_tvalid),
	  .m_from_pcie_bd_S2C1_tlast			(m_from_pcie_bd_S2C1_tlast),
  
	  .m_from_pcie_bd_C2S1_tuser			(m_from_pcie_bd_C2S1_tuser),
	  .m_from_pcie_bd_C2S1_tdata			(m_from_pcie_bd_C2S1_tdata),
	  .m_from_pcie_bd_C2S1_tvalid			(m_from_pcie_bd_C2S1_tvalid),
	  .m_from_pcie_bd_C2S1_tlast			(m_from_pcie_bd_C2S1_tlast),
 
	  .m_axis_cq_pcie_tvalid				(m_axis_cq_pcie_tvalid),
	  .m_axis_cq_pcie_tready				(m_axis_cq_pcie_tready),
	  .m_axis_cq_pcie_tdata					(m_axis_cq_pcie_tdata),
	  .m_axis_cq_pcie_tkeep					(m_axis_cq_pcie_tkeep),

	  .cfg_max_payload_size					(cfg_max_payload_size),
	  .cfg_max_rd_req_size					(cfg_max_rd_req_size),

	  .ch0_s2c_sw_ptr						(ch0_s2c_sw_ptr),
	  .ch0_c2s_sw_ptr						(ch0_c2s_sw_ptr),
	  .ch1_s2c_sw_ptr						(ch1_s2c_sw_ptr),
	  .ch1_c2s_sw_ptr						(ch1_c2s_sw_ptr)
  
  );							
		

  response_queue response_queue (
	  .user_clk								(user_clk),
	  .user_reset							(user_reset),

	  .m_axis_cpld_header_tdata				(m_axis_cpld_header_tdata),
	  .m_axis_cpld_header_tdest				(m_axis_cpld_header_tdest),
	  .m_axis_cpld_header_tvalid			(m_axis_cpld_header_tvalid),

	  .m_axis_bd_from_buffer_S2C0_tdata		(m_axis_bd_from_buffer_S2C0_tdata),
	  .m_axis_bd_from_buffer_S2C0_tvalid	(m_axis_bd_from_buffer_S2C0_tvalid),
	  .m_axis_bd_from_buffer_C2S0_tdata		(m_axis_bd_from_buffer_C2S0_tdata),
	  .m_axis_bd_from_buffer_C2S0_tvalid	(m_axis_bd_from_buffer_C2S0_tvalid),
	  .m_axis_bd_from_buffer_S2C1_tdata		(m_axis_bd_from_buffer_S2C1_tdata),
	  .m_axis_bd_from_buffer_S2C1_tvalid	(m_axis_bd_from_buffer_S2C1_tvalid),
	  .m_axis_bd_from_buffer_C2S1_tdata		(m_axis_bd_from_buffer_C2S1_tdata),
	  .m_axis_bd_from_buffer_C2S1_tvalid	(m_axis_bd_from_buffer_C2S1_tvalid),

	  .s_axis_rc_bp_tvalid					(s_axis_rc_bp_tvalid),
	  .s_axis_rc_bp_tready					(s_axis_rc_bp_tready),
	  .s_axis_rc_bp_tlast					(s_axis_rc_bp_tlast),
	  .s_axis_rc_bp_tkeep					(s_axis_rc_bp_tkeep),
	  .s_axis_rc_bp_tdata					(s_axis_rc_bp_tdata),
	  .s_axis_rc_bp_tuser					(s_axis_rc_bp_tuser),
		
	  .m_axis_dma_rc_tdata					(m_axis_dma_rc_tdata),
	  .m_axis_dma_rc_tvalid					(m_axis_dma_rc_tvalid),
	  .m_axis_dma_rc_tready					(m_axis_dma_rc_tready),
	  .m_axis_dma_rc_tlast					(m_axis_dma_rc_tlast),
	  .m_axis_dma_rc_tuser					(m_axis_dma_rc_tuser),
	  .m_axis_dma_rc_tkeep					(m_axis_dma_rc_tkeep)

  );


endmodule

