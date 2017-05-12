

/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * Buffer for buffer descriptor (BD) storage in each channel 
 * submodule of BD Buffer
 * Module name: Buffer per Channel
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.19
 *===========================================================================
 *
 * Version History:
 * v0.0.1:	Initialization version
 *===========================================================================
 */

`timescale 1ns/1ps

  module buffer_per_channel (
	  input wire			user_clk,
	  input wire			user_reset,
	  
	  //output to Request Recv
	  output reg [22:0]		bd_buf_addr,
	  output reg [15:0]		bd_buf_valid,
	  
	  //command from Request Recv
	  input wire [43:0]		m_axis_buffer_cmd_tdata,
	  input wire			m_axis_buffer_cmd_tvalid,
	  
	  //BD data to Response Queue
	  output wire [255:0]	m_axis_bd_from_buffer_tdata,
	  output wire			m_axis_bd_from_buffer_tvalid,
	  
	  //signals from PCIe Interface for BD update
	  input wire [3:0]		m_from_pcie_bd_tuser,
	  input wire [255:0]	m_from_pcie_bd_tdata,
	  input wire			m_from_pcie_bd_tvalid,
	  input wire			m_from_pcie_bd_tlast
  ); 

  localparam [2:0]		FSM_IDLE	= 3'b001,
						FSM_BD_HIT	= 3'b010,
						FSM_BD_MISS	= 3'b100;

  reg [2:0]				fsm_cs;
  reg [2:0]				fsm_ns;

  reg	[255:0]			bd_buffer[0:15];
  wire	[255:0]			bd_to_queue;

  reg	[15:0]			bd_buf_valid;
  reg	[3:0]			entry_offset;
  reg	[22:0]			bd_buf_addr;
  reg	[15:0]			entry_offset_mask;

  wire	[3:0]			entry_offset_addr;

  wire					op_type;

  assign		op_type = m_axis_buffer_cmd_tdata[16];

  assign		m_axis_bd_from_buffer_tdata = bd_to_queue;
  assign		m_axis_bd_from_buffer_tvalid = (fsm_cs==FSM_BD_HIT);

  assign		entry_offset_addr = ({4{m_from_pcie_bd_tvalid}} & m_from_pcie_bd_tuser)
									| ({4{fsm_cs == FSM_BD_HIT}} & entry_offset);

  assign		bd_to_queue = {256{fsm_cs == FSM_BD_HIT}} & bd_buffer[entry_offset_addr];
  
  always @ (posedge user_clk)
  begin
	  if(m_from_pcie_bd_tvalid)
		  bd_buffer[entry_offset_addr] <= m_from_pcie_bd_tdata;
  end

  always @ (entry_offset)
  begin
	  case(entry_offset)
		  4'h0: entry_offset_mask = 16'b1111_1111_1111_1110;
		  4'h1: entry_offset_mask = 16'b1111_1111_1111_1101;
		  4'h2: entry_offset_mask = 16'b1111_1111_1111_1011;
		  4'h3: entry_offset_mask = 16'b1111_1111_1111_0111;
		  4'h4: entry_offset_mask = 16'b1111_1111_1110_1111;
		  4'h5: entry_offset_mask = 16'b1111_1111_1101_1111;
		  4'h6: entry_offset_mask = 16'b1111_1111_1011_1111;
		  4'h7: entry_offset_mask = 16'b1111_1111_0111_1111;
		  4'h8: entry_offset_mask = 16'b1111_1110_1111_1111;
		  4'h9: entry_offset_mask = 16'b1111_1101_1111_1111;
		  4'ha: entry_offset_mask = 16'b1111_1011_1111_1111;
		  4'hb: entry_offset_mask = 16'b1111_0111_1111_1111;
		  4'hc: entry_offset_mask = 16'b1110_1111_1111_1111;
		  4'hd: entry_offset_mask = 16'b1101_1111_1111_1111;
		  4'he: entry_offset_mask = 16'b1011_1111_1111_1111;
		  4'hf: entry_offset_mask = 16'b0111_1111_1111_1111;
		  default: entry_offset_mask = 16'b1111_1111_1111_1111;
	  endcase
  end

  always @ (posedge user_clk)
  begin
	  if(user_reset)
	  begin
		  entry_offset <= 4'd0;
		  bd_buf_addr <= 23'd0;
		  bd_buf_valid <= 16'd0;
	  end
	  else
	  begin
		  if((fsm_cs == FSM_IDLE) & m_axis_buffer_cmd_tvalid & op_type)
		  begin
			  entry_offset <= m_axis_buffer_cmd_tdata[20:17];
			  bd_buf_addr <= bd_buf_addr;
			  bd_buf_valid <= bd_buf_valid;
		  end
		  else if((fsm_cs == FSM_IDLE) & m_axis_buffer_cmd_tvalid & (!op_type))
		  begin
			  entry_offset <= m_axis_buffer_cmd_tdata[20:17];
			  bd_buf_addr <= m_axis_buffer_cmd_tdata[43:21];
			  bd_buf_valid <= m_axis_buffer_cmd_tdata[15:0];
		  end
		  else if(fsm_cs == FSM_BD_HIT)
		  begin
			  entry_offset <= 'd0;
			  bd_buf_addr <= bd_buf_addr;
			  bd_buf_valid <= (bd_buf_valid & entry_offset_mask);
		  end
		  else
		  begin
			  entry_offset <= entry_offset;
			  bd_buf_addr <= bd_buf_addr;
			  bd_buf_valid <= bd_buf_valid;
		  end
	  end
  end


  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  fsm_cs <= FSM_IDLE;
	  else
		  fsm_cs <= fsm_ns;
  end

  always @ (fsm_cs or m_axis_buffer_cmd_tvalid or op_type or m_from_pcie_bd_tlast)
  begin
	  case(fsm_cs)
		  FSM_IDLE: begin
			  if(m_axis_buffer_cmd_tvalid & op_type)
				  fsm_ns = FSM_BD_HIT;
			  else if(m_axis_buffer_cmd_tvalid & (!op_type))
				  fsm_ns = FSM_BD_MISS;
			  else
				  fsm_ns = FSM_IDLE;
		  end
		  FSM_BD_HIT: fsm_ns = FSM_IDLE;
		  FSM_BD_MISS: begin
			  if(m_from_pcie_bd_tlast)
				  fsm_ns = FSM_BD_HIT;
			  else
				  fsm_ns = FSM_BD_MISS;
		  end
		  default: fsm_ns =FSM_IDLE;	
	  endcase
  end

endmodule

