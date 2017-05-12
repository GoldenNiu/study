/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * PCIe Interface for BD read request send, CPLD receive
 * and write BD into Buffer
 * Module name: PCIe Interface
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.10
 *===========================================================================
 *
 * Version History:
 * v0.0.1:	Initialization version
 *===========================================================================
 */

`timescale 1ns/1ps

module pcie_if (
	input wire				user_clk,
	input wire				user_reset,

	//RQ signals from DMA request receiver
	input wire				m_axis_rq_from_rec_tvalid,
	output wire				m_axis_rq_from_rec_tready,
	input wire				m_axis_rq_from_rec_tlast,
	input wire [7:0]		m_axis_rq_from_rec_tkeep,
	input wire [255:0]		m_axis_rq_from_rec_tdata,
	input wire [59:0]		m_axis_rq_from_rec_tuser,
	input wire				m_axis_rq_from_rec_tdest,

	//RQ signals to PCIe EP
	output wire				s_axis_rq_pcie_tvalid,
	input wire				s_axis_rq_pcie_tready,
	output wire				s_axis_rq_pcie_tlast,
	output wire	[7:0]		s_axis_rq_pcie_tkeep,
	output wire	[255:0]		s_axis_rq_pcie_tdata,
	output wire	[59:0]		s_axis_rq_pcie_tuser,
	
	//RC signals from PCIe EP
	input wire				m_axis_rc_pcie_tvalid,
	output wire				m_axis_rc_pcie_tready,
	input wire				m_axis_rc_pcie_tlast,
	input wire  [7:0]		m_axis_rc_pcie_tkeep,
	input wire	[255:0]		m_axis_rc_pcie_tdata,
	input wire	[74:0]		m_axis_rc_pcie_tuser,
	
	//RC signals to Response Queue (bypassed response)
	output wire				s_axis_rc_bp_tvalid,
	input wire				s_axis_rc_bp_tready,
	output wire				s_axis_rc_bp_tlast,
	output wire	[7:0]		s_axis_rc_bp_tkeep,
	output wire	[255:0]		s_axis_rc_bp_tdata,
	output wire	[74:0]		s_axis_rc_bp_tuser,

	//RC signals to BD Buffer (BD read cpld)
	output wire [3:0]		m_from_pcie_bd_S2C0_tuser,
	output wire [255:0]		m_from_pcie_bd_S2C0_tdata,
	output wire		 		m_from_pcie_bd_S2C0_tvalid,
	output wire				m_from_pcie_bd_S2C0_tlast,
	
	output wire [3:0]		m_from_pcie_bd_C2S0_tuser,
	output wire [255:0]		m_from_pcie_bd_C2S0_tdata,
	output wire				m_from_pcie_bd_C2S0_tvalid,
	output wire				m_from_pcie_bd_C2S0_tlast,
	
	output wire [3:0]		m_from_pcie_bd_S2C1_tuser,
	output wire [255:0]		m_from_pcie_bd_S2C1_tdata,
	output wire		 		m_from_pcie_bd_S2C1_tvalid,
	output wire				m_from_pcie_bd_S2C1_tlast,
	
	output wire [3:0]		m_from_pcie_bd_C2S1_tuser,
	output wire [255:0]		m_from_pcie_bd_C2S1_tdata,
	output wire				m_from_pcie_bd_C2S1_tvalid,
	output wire				m_from_pcie_bd_C2S1_tlast,
	
	//CQ signals from PCIe EP
	input wire				m_axis_cq_pcie_tvalid,
	input wire				m_axis_cq_pcie_tready,
	input wire [255:0]		m_axis_cq_pcie_tdata,
	input wire [7:0]		m_axis_cq_pcie_tkeep,

	//PCIe configuration signals
    input wire [2:0]		cfg_max_payload_size,
	input wire [2:0]		cfg_max_rd_req_size,

	//software pointer register of each DMA channel
	output reg [26:0]		ch0_s2c_sw_ptr,
	output reg [26:0]		ch0_c2s_sw_ptr,
	output reg [26:0]		ch1_s2c_sw_ptr,
	output reg [26:0]		ch1_c2s_sw_ptr
);

/*Internal wire and reg signals*/

  //DMA RQ interface MUX
  reg [3:0]		bd_read_mask;
  wire [3:0]	bd_read_req;
  
  //Request Generator output signals to Mux
  wire			axis_rq_bd_out_s2c0_tvalid;
  wire			axis_rq_bd_out_s2c0_tready;
  wire			axis_rq_bd_out_s2c0_tlast;
  wire [255:0]	axis_rq_bd_out_s2c0_tdata;
  
  wire			axis_rq_bd_out_c2s0_tvalid;
  wire			axis_rq_bd_out_c2s0_tready;
  wire			axis_rq_bd_out_c2s0_tlast;
  wire [255:0]	axis_rq_bd_out_c2s0_tdata;
  
  wire			axis_rq_bd_out_s2c1_tvalid;
  wire			axis_rq_bd_out_s2c1_tready;
  wire			axis_rq_bd_out_s2c1_tlast;
  wire [255:0]	axis_rq_bd_out_s2c1_tdata;
  
  wire			axis_rq_bd_out_c2s1_tvalid;
  wire			axis_rq_bd_out_c2s1_tready;
  wire			axis_rq_bd_out_c2s1_tlast;
  wire [255:0]	axis_rq_bd_out_c2s1_tdata;
  
  wire			axis_rq_bd_read_s2c0_tready;
  wire			axis_rq_bd_read_c2s0_tready;
  wire			axis_rq_bd_read_s2c1_tready;
  wire			axis_rq_bd_read_c2s1_tready;
  wire			axis_rq_bp_tready;
  wire			axis_rq_bd_read_tready;
  
  
  wire [3:0]	s_axis_rq_pcie_tuser_high; 
  
  //DMA BD size in current DMA request
  //ranges from 0 (1 BD) to 15 (16 BDs)
  wire [3:0]	bd_size_for_cpld_s2c0;
  wire [3:0]	bd_size_for_cpld_c2s0;
  wire [3:0]	bd_size_for_cpld_s2c1;
  wire [3:0]	bd_size_for_cpld_c2s1;

  reg			cpld_first_beat;

  //tag for BD cpld muxing in the first valid
  //beat of a valid PCIe RC transaction
  wire 			cpld_bd;
  wire [1:0]	cpld_bd_channel_tag;

  //tag for BD cpld muxing in the remain beats
  //of a valid PCIe RC transaction
  reg			cpld_bd_sel;
  reg [1:0]		cpld_bd_channel_sel;

  wire [1:0]	cpld_bd_channel;
  reg [3:0]		cpld_bd_channel_mask;

  //MUX value used for PCIe RC interface
  wire			cpld_bd_mux;
  wire [3:0]	cpld_bd_channel_mux;

/*DMA RQ request dispatch and re-generation*/
  always @ (m_axis_rq_from_rec_tdata[99:98])
  begin
	  case(m_axis_rq_from_rec_tdata[99:98])
		  2'b00:	bd_read_mask = 4'b0001;
		  2'b01:	bd_read_mask = 4'b0010;
		  2'b10:	bd_read_mask = 4'b0100;
		  2'b11:	bd_read_mask = 4'b1000;
		  default: bd_read_mask = 4'b0000;
	  endcase
  end
  
  assign bd_read_req = {4{m_axis_rq_from_rec_tdest}} & bd_read_mask;

  assign axis_rq_bd_read_tready = |(bd_read_req & 
									{axis_rq_bd_read_c2s1_tready, 
									 axis_rq_bd_read_s2c1_tready,
									 axis_rq_bd_read_c2s0_tready,
									 axis_rq_bd_read_s2c0_tready});

  assign m_axis_rq_from_rec_tready = (~m_axis_rq_from_rec_tdest & axis_rq_bp_tready) |
									  axis_rq_bd_read_tready;

  request_gen	request_gen_ch0_s2c (
	  .user_clk						(user_clk),
	  .user_reset					(user_reset),
	  
	  .cfg_max_rd_req_size			(cfg_max_rd_req_size),
	  .bd_size_for_cpld				(bd_size_for_cpld_s2c0),

	  .axis_rq_bd_read_tvalid		(bd_read_req[0] & m_axis_rq_from_rec_tvalid),
	  .axis_rq_bd_read_tready		(axis_rq_bd_read_s2c0_tready),
	  .axis_rq_bd_read_tdata		({256{bd_read_req[0]}} & m_axis_rq_from_rec_tdata),
	  
	  .axis_rq_bd_out_tvalid		(axis_rq_bd_out_s2c0_tvalid),
	  .axis_rq_bd_out_tlast			(axis_rq_bd_out_s2c0_tlast),
	  .axis_rq_bd_out_tdata			(axis_rq_bd_out_s2c0_tdata),
	  .axis_rq_bd_out_tready		(axis_rq_bd_out_s2c0_tready)
  );

  request_gen	request_gen_ch0_c2s (
	  .user_clk						(user_clk),
	  .user_reset					(user_reset),

	  .cfg_max_rd_req_size			(cfg_max_rd_req_size),
	  .bd_size_for_cpld				(bd_size_for_cpld_c2s0),

	  .axis_rq_bd_read_tvalid		(bd_read_req[1] & m_axis_rq_from_rec_tvalid),
	  .axis_rq_bd_read_tready		(axis_rq_bd_read_c2s0_tready),
	  .axis_rq_bd_read_tdata		({256{bd_read_req[1]}} & m_axis_rq_from_rec_tdata),
	  
	  .axis_rq_bd_out_tvalid		(axis_rq_bd_out_c2s0_tvalid),
	  .axis_rq_bd_out_tlast			(axis_rq_bd_out_c2s0_tlast),
	  .axis_rq_bd_out_tdata			(axis_rq_bd_out_c2s0_tdata),
	  .axis_rq_bd_out_tready		(axis_rq_bd_out_c2s0_tready)
  );

  request_gen	request_gen_ch1_s2c (
	  .user_clk						(user_clk),
	  .user_reset					(user_reset),

	  .cfg_max_rd_req_size			(cfg_max_rd_req_size),
	  .bd_size_for_cpld				(bd_size_for_cpld_s2c1),

	  .axis_rq_bd_read_tvalid		(bd_read_req[2] & m_axis_rq_from_rec_tvalid),
	  .axis_rq_bd_read_tready		(axis_rq_bd_read_s2c1_tready),
	  .axis_rq_bd_read_tdata		({256{bd_read_req[2]}} & m_axis_rq_from_rec_tdata),
	  
	  .axis_rq_bd_out_tvalid		(axis_rq_bd_out_s2c1_tvalid),
	  .axis_rq_bd_out_tlast			(axis_rq_bd_out_s2c1_tlast),
	  .axis_rq_bd_out_tdata			(axis_rq_bd_out_s2c1_tdata),
	  .axis_rq_bd_out_tready		(axis_rq_bd_out_s2c1_tready)
  );

  request_gen	request_gen_ch1_c2s (
	  .user_clk						(user_clk),
	  .user_reset					(user_reset),

	  .cfg_max_rd_req_size			(cfg_max_rd_req_size),
	  .bd_size_for_cpld				(bd_size_for_cpld_c2s1),

	  .axis_rq_bd_read_tvalid		(bd_read_req[3] & m_axis_rq_from_rec_tvalid),
	  .axis_rq_bd_read_tready		(axis_rq_bd_read_c2s1_tready),
	  .axis_rq_bd_read_tdata		({256{bd_read_req[3]}} & m_axis_rq_from_rec_tdata),
	  
	  .axis_rq_bd_out_tvalid		(axis_rq_bd_out_c2s1_tvalid),
	  .axis_rq_bd_out_tlast			(axis_rq_bd_out_c2s1_tlast),
	  .axis_rq_bd_out_tdata			(axis_rq_bd_out_c2s1_tdata),
	  .axis_rq_bd_out_tready		(axis_rq_bd_out_c2s1_tready)
  );

  //5:1 DEMUX to PCIe RQ interface
 axis_ic_5x1_rq	axis_ic_rq (
	  .ACLK							(user_clk),
	  .ARESETN						(~user_reset),

	  .S00_AXIS_ACLK				(user_clk),
	  .S00_AXIS_ARESETN				(~user_reset),
	  .S00_AXIS_TVALID				((~m_axis_rq_from_rec_tdest) & m_axis_rq_from_rec_tvalid),
	  .S00_AXIS_TREADY				(axis_rq_bp_tready),
	  .S00_AXIS_TLAST				((~m_axis_rq_from_rec_tdest) & m_axis_rq_from_rec_tlast),
	  .S00_AXIS_TKEEP				({8{~m_axis_rq_from_rec_tdest}} & m_axis_rq_from_rec_tkeep),
	  .S00_AXIS_TDATA				({256{~m_axis_rq_from_rec_tdest}} & m_axis_rq_from_rec_tdata),
	  .S00_AXIS_TUSER				({4'd0, {{60{~m_axis_rq_from_rec_tdest}} & m_axis_rq_from_rec_tuser}}),
	  .S00_ARB_REQ_SUPPRESS			(1'b0),

	  .S01_AXIS_ACLK				(user_clk),
	  .S01_AXIS_ARESETN				(~user_reset),
	  .S01_AXIS_TVALID				(axis_rq_bd_out_s2c0_tvalid),
	  .S01_AXIS_TREADY				(axis_rq_bd_out_s2c0_tready),
	  .S01_AXIS_TLAST				(axis_rq_bd_out_s2c0_tlast),
	  .S01_AXIS_TKEEP				(8'h0F),
	  .S01_AXIS_TDATA				(axis_rq_bd_out_s2c0_tdata),
	  .S01_AXIS_TUSER				(64'hFF),
	  .S01_ARB_REQ_SUPPRESS			(1'b0),

	  .S02_AXIS_ACLK				(user_clk),
	  .S02_AXIS_ARESETN				(~user_reset),
	  .S02_AXIS_TVALID				(axis_rq_bd_out_c2s0_tvalid),
	  .S02_AXIS_TREADY				(axis_rq_bd_out_c2s0_tready),
	  .S02_AXIS_TLAST				(axis_rq_bd_out_c2s0_tlast),
	  .S02_AXIS_TKEEP				(8'h0F),
	  .S02_AXIS_TDATA				(axis_rq_bd_out_c2s0_tdata),
	  .S02_AXIS_TUSER				(64'hFF),
	  .S02_ARB_REQ_SUPPRESS			(1'b0),

	  .S03_AXIS_ACLK				(user_clk),
	  .S03_AXIS_ARESETN				(~user_reset),
	  .S03_AXIS_TVALID				(axis_rq_bd_out_s2c1_tvalid),
	  .S03_AXIS_TREADY				(axis_rq_bd_out_s2c1_tready),
	  .S03_AXIS_TLAST				(axis_rq_bd_out_s2c1_tlast),
	  .S03_AXIS_TKEEP				(8'h0F),
	  .S03_AXIS_TDATA				(axis_rq_bd_out_s2c1_tdata),
	  .S03_AXIS_TUSER				(64'hFF),
	  .S03_ARB_REQ_SUPPRESS			(1'b0),
	  
	  .S04_AXIS_ACLK				(user_clk),
	  .S04_AXIS_ARESETN				(~user_reset),
	  .S04_AXIS_TVALID				(axis_rq_bd_out_c2s1_tvalid),
	  .S04_AXIS_TREADY				(axis_rq_bd_out_c2s1_tready),
	  .S04_AXIS_TLAST				(axis_rq_bd_out_c2s1_tlast),
	  .S04_AXIS_TKEEP				(8'h0F),
	  .S04_AXIS_TDATA				(axis_rq_bd_out_c2s1_tdata),
	  .S04_AXIS_TUSER				(64'hFF),
	  .S04_ARB_REQ_SUPPRESS			(1'b0),
	  
	  .M00_AXIS_ACLK				(user_clk),
	  .M00_AXIS_ARESETN				(~user_reset),
	  .M00_AXIS_TVALID				(s_axis_rq_pcie_tvalid),
	  .M00_AXIS_TREADY				(s_axis_rq_pcie_tready),
	  .M00_AXIS_TLAST				(s_axis_rq_pcie_tlast),
	  .M00_AXIS_TKEEP				(s_axis_rq_pcie_tkeep),
	  .M00_AXIS_TDATA				(s_axis_rq_pcie_tdata),
	  .M00_AXIS_TUSER				({s_axis_rq_pcie_tuser_high, s_axis_rq_pcie_tuser})
  );

/*BD cpld and other cpld transaction muxing on the PCIe RC interface*/
  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  cpld_first_beat <= 1'b1;
	  
	  else if(m_axis_rc_pcie_tvalid & m_axis_rc_pcie_tready)
		  cpld_first_beat <= m_axis_rc_pcie_tlast;
	  
	  else
		  cpld_first_beat <= cpld_first_beat;
  end
  
  assign cpld_bd = cpld_first_beat & m_axis_rc_pcie_tdata[68] & m_axis_rc_pcie_tvalid;
  assign cpld_bd_channel_tag = {2{cpld_bd}} & m_axis_rc_pcie_tdata[67:66];
  
  always @ (posedge user_clk)
  begin
	  if (user_reset)
	  begin
		  cpld_bd_sel <= 1'b0;
		  cpld_bd_channel_sel <= 2'b00;
	  end
	  
	  else if (~cpld_bd_sel & m_axis_rc_pcie_tvalid & m_axis_rc_pcie_tready)
	  begin
		  cpld_bd_sel <= (~m_axis_rc_pcie_tlast) & cpld_bd;
		  cpld_bd_channel_sel <= {2{~m_axis_rc_pcie_tlast}} & cpld_bd_channel_tag;
	  end

	  else if (cpld_bd_sel & m_axis_rc_pcie_tvalid & m_axis_rc_pcie_tready)
	  begin
		  cpld_bd_sel <= (~m_axis_rc_pcie_tlast) & cpld_bd_sel;
		  cpld_bd_channel_sel <= {2{~m_axis_rc_pcie_tlast}} & cpld_bd_channel_sel;
	  end
	  
	  else
	  begin
		  cpld_bd_sel <= cpld_bd_sel;
		  cpld_bd_channel_sel <= cpld_bd_channel_sel;
	  end
  end
  
  assign cpld_bd_mux = cpld_bd | cpld_bd_sel;
  assign cpld_bd_channel = ({2{cpld_bd}} & cpld_bd_channel_tag) |
							 ({2{cpld_bd_sel}} & cpld_bd_channel_sel);

  always @ (cpld_bd_channel)
  begin
	  case (cpld_bd_channel)
		  2'b00: cpld_bd_channel_mask = 4'b0001;
		  2'b01: cpld_bd_channel_mask = 4'b0010;
		  2'b10: cpld_bd_channel_mask = 4'b0100;
		  2'b11: cpld_bd_channel_mask = 4'b1000;
		  default: cpld_bd_channel_mask = 4'b0000;
	  endcase
  end
  
  assign cpld_bd_channel_mux = {4{cpld_bd_mux}} & cpld_bd_channel_mask;

  //tready output signal for PCIe RC interface
  assign m_axis_rc_pcie_bd_tready = |(cpld_bd_channel_mux & 
									  {axis_rc_bd_cpld_c2s1_tready,
									   axis_rc_bd_cpld_s2c1_tready,
									   axis_rc_bd_cpld_c2s0_tready,
									   axis_rc_bd_cpld_s2c0_tready});

  assign m_axis_rc_pcie_tready = (~cpld_bd_mux & s_axis_rc_bp_tready) |
								 m_axis_rc_pcie_bd_tready;

  //Bypassed RC signals to Response Queue
  assign s_axis_rc_bp_tvalid = (~cpld_bd_mux) & m_axis_rc_pcie_tvalid;
  assign s_axis_rc_bp_tlast = (~cpld_bd_mux) & m_axis_rc_pcie_tlast;
  assign s_axis_rc_bp_tkeep = {8{~cpld_bd_mux}} & m_axis_rc_pcie_tkeep;
  assign s_axis_rc_bp_tdata = {256{~cpld_bd_mux}} & m_axis_rc_pcie_tdata;
  assign s_axis_rc_bp_tuser = {75{~cpld_bd_mux}} & m_axis_rc_pcie_tuser;

  //BD cpld recv module for each DMA channel
  bd_cpld_recv	bd_cpld_recv_s2c0 (
	  .user_clk					(user_clk),
	  .user_reset				(user_reset),

	  .cpld_first_beat			(cpld_first_beat),
	  .axis_rc_bd_cpld_tvalid	(cpld_bd_channel_mux[0] & m_axis_rc_pcie_tvalid),
	  .axis_rc_bd_cpld_tready	(axis_rc_bd_cpld_s2c0_tready),
	  .axis_rc_bd_cpld_tdata	({256{cpld_bd_channel_mux[0]}} & m_axis_rc_pcie_tdata),
	  .axis_rc_bd_cpld_tlast	(cpld_bd_channel_mux[0] & m_axis_rc_pcie_tlast),

	  .bd_size_for_cpld			(bd_size_for_cpld_s2c0),
	  .cfg_max_payload_size		(cfg_max_payload_size),

	  .m_from_pcie_bd_tvalid	(m_from_pcie_bd_S2C0_tvalid),
	  .m_from_pcie_bd_tlast		(m_from_pcie_bd_S2C0_tlast),
	  .m_from_pcie_bd_tdata		(m_from_pcie_bd_S2C0_tdata),
	  .m_from_pcie_bd_tuser 	(m_from_pcie_bd_S2C0_tuser)
  );
  
  bd_cpld_recv	bd_cpld_recv_c2s0 (
	  .user_clk					(user_clk),
	  .user_reset				(user_reset),

	  .cpld_first_beat			(cpld_first_beat),
	  .axis_rc_bd_cpld_tvalid	(cpld_bd_channel_mux[1] & m_axis_rc_pcie_tvalid),
	  .axis_rc_bd_cpld_tready	(axis_rc_bd_cpld_c2s0_tready),
	  .axis_rc_bd_cpld_tdata	({256{cpld_bd_channel_mux[1]}} & m_axis_rc_pcie_tdata),
	  .axis_rc_bd_cpld_tlast	(cpld_bd_channel_mux[1] & m_axis_rc_pcie_tlast),

	  .bd_size_for_cpld			(bd_size_for_cpld_c2s0),
	  .cfg_max_payload_size		(cfg_max_payload_size),

	  .m_from_pcie_bd_tvalid	(m_from_pcie_bd_C2S0_tvalid),
	  .m_from_pcie_bd_tlast		(m_from_pcie_bd_C2S0_tlast),
	  .m_from_pcie_bd_tdata		(m_from_pcie_bd_C2S0_tdata),
	  .m_from_pcie_bd_tuser 	(m_from_pcie_bd_C2S0_tuser)
  );

  bd_cpld_recv	bd_cpld_recv_s2c1 (
	  .user_clk					(user_clk),
	  .user_reset				(user_reset),

	  .cpld_first_beat			(cpld_first_beat),
	  .axis_rc_bd_cpld_tvalid	(cpld_bd_channel_mux[2] & m_axis_rc_pcie_tvalid),
	  .axis_rc_bd_cpld_tready	(axis_rc_bd_cpld_s2c1_tready),
	  .axis_rc_bd_cpld_tdata	({256{cpld_bd_channel_mux[2]}} & m_axis_rc_pcie_tdata),
	  .axis_rc_bd_cpld_tlast	(cpld_bd_channel_mux[2] & m_axis_rc_pcie_tlast),

	  .bd_size_for_cpld			(bd_size_for_cpld_s2c1),
	  .cfg_max_payload_size		(cfg_max_payload_size),

	  .m_from_pcie_bd_tvalid	(m_from_pcie_bd_S2C1_tvalid),
	  .m_from_pcie_bd_tlast		(m_from_pcie_bd_S2C1_tlast),
	  .m_from_pcie_bd_tdata		(m_from_pcie_bd_S2C1_tdata),
	  .m_from_pcie_bd_tuser 	(m_from_pcie_bd_S2C1_tuser)
  );
  
  bd_cpld_recv	bd_cpld_recv_c2s1 (
	  .user_clk					(user_clk),
	  .user_reset				(user_reset),

	  .cpld_first_beat			(cpld_first_beat),
	  .axis_rc_bd_cpld_tvalid	(cpld_bd_channel_mux[3] & m_axis_rc_pcie_tvalid),
	  .axis_rc_bd_cpld_tready	(axis_rc_bd_cpld_c2s1_tready),
	  .axis_rc_bd_cpld_tdata	({256{cpld_bd_channel_mux[3]}} & m_axis_rc_pcie_tdata),
	  .axis_rc_bd_cpld_tlast	(cpld_bd_channel_mux[3] & m_axis_rc_pcie_tlast),

	  .bd_size_for_cpld			(bd_size_for_cpld_c2s1),
	  .cfg_max_payload_size		(cfg_max_payload_size),

	  .m_from_pcie_bd_tvalid	(m_from_pcie_bd_C2S1_tvalid),
	  .m_from_pcie_bd_tlast		(m_from_pcie_bd_C2S1_tlast),
	  .m_from_pcie_bd_tdata		(m_from_pcie_bd_C2S1_tdata),
	  .m_from_pcie_bd_tuser 	(m_from_pcie_bd_C2S1_tuser)
  );

/*Software pointer register for each DMA channel
* by snooping the PCIe CQ interface*/
  always @ (posedge user_clk)
  begin
	  if(m_axis_cq_pcie_tvalid & m_axis_cq_pcie_tready)
	  begin
		  if(m_axis_cq_pcie_tdata[15:0] == 16'h000c)
			  ch0_s2c_sw_ptr <= m_axis_cq_pcie_tdata[159:133];
		  else
			  ch0_s2c_sw_ptr <= ch0_s2c_sw_ptr;
	  end
  end

  always @ (posedge user_clk)
  begin
	  if(m_axis_cq_pcie_tvalid & m_axis_cq_pcie_tready)
	  begin
		  if(m_axis_cq_pcie_tdata[15:0] == 16'h200c)
			  ch0_c2s_sw_ptr <= m_axis_cq_pcie_tdata[159:133];
		  else
			  ch0_c2s_sw_ptr <= ch0_c2s_sw_ptr;
	  end
  end
		
  always @ (posedge user_clk)
  begin
	  if(m_axis_cq_pcie_tvalid & m_axis_cq_pcie_tready)
	  begin
		  if(m_axis_cq_pcie_tdata[15:0] == 16'h010c)
			  ch1_s2c_sw_ptr <= m_axis_cq_pcie_tdata[159:133];
		  else
			  ch1_s2c_sw_ptr <= ch1_s2c_sw_ptr;
	  end
  end

		
  always @ (posedge user_clk)
  begin
	  if(m_axis_cq_pcie_tvalid & m_axis_cq_pcie_tready)
	  begin
		  if(m_axis_cq_pcie_tdata[15:0] == 16'h210c)
			  ch1_c2s_sw_ptr <= m_axis_cq_pcie_tdata[159:133];
		  else
			  ch1_c2s_sw_ptr <= ch1_c2s_sw_ptr;
	  end
  end


endmodule	

