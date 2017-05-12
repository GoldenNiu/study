/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * DMA request receiver designed for PCIe BD read Request filter and
 * check whether such a request is hit in BD buffer 
 * Module name: dma_request_recv 
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.05
 *===========================================================================
 *
 * Version History:
 * v0.0.1: Initialization version 2017.01.11
 * v0.0.2: 1. Using 32-bit BD host BASE/HIGH/SIZE registers; 2. Fixed the
 * logic circuits of address filtering, BD Buffer checking, updated valid tag
 * calculation with the value of software pointer register for each DMA
 * channel 2017.01.13
 * v0.0.3: Added 1-bit tdest signal to the rq_from_rec AXI-STREAM channel
 *===========================================================================
 */

`timescale 1ns/1ps

module dma_request_recv (
	input wire				user_clk,
	input wire				user_reset,

	//From DMA RQ channel
	input wire				s_axis_dma_rq_tvalid,
	output wire				s_axis_dma_rq_tready,
	input wire				s_axis_dma_rq_tlast,
	input wire	[7:0]		s_axis_dma_rq_tkeep,
	input wire	[255:0]		s_axis_dma_rq_tdata,
	input wire	[59:0]		s_axis_dma_rq_tuser,

	//Output RQ channel to PCIe interface module
	output wire				m_axis_rq_from_rec_tvalid,
	input wire				m_axis_rq_from_rec_tready,
	output wire				m_axis_rq_from_rec_tlast,
	output wire				m_axis_rq_from_rec_tdest,
	output wire	[7:0]		m_axis_rq_from_rec_tkeep,
	output wire	[255:0]		m_axis_rq_from_rec_tdata,
	output wire	[59:0]		m_axis_rq_from_rec_tuser,

	//BD buffer status
    input wire	[22:0]		bd_buf_ch0_s2c_addr,
	input wire	[22:0]		bd_buf_ch0_c2s_addr,
	input wire	[22:0]		bd_buf_ch1_s2c_addr,
	input wire	[22:0]		bd_buf_ch1_c2s_addr,
	input wire	[15:0]		bd_buf_ch0_s2c_valid,
	input wire	[15:0]		bd_buf_ch0_c2s_valid,
	input wire	[15:0]		bd_buf_ch1_s2c_valid,
	input wire	[15:0]		bd_buf_ch1_c2s_valid,

	//Command to BD Buffer
	output wire [43:0]		m_axis_buffer_cmd_tdata,
	output wire				m_axis_buffer_cmd_tvalid,
	output wire	[1:0]		m_axis_buffer_cmd_tdest,

	//cpld header to Response Queue
	output wire [95:0]		m_axis_cpld_header_tdata,
	output wire [1:0]		m_axis_cpld_header_tdest,
	output wire				m_axis_cpld_header_tvalid,

	//DMA BD address and total size in host memory
	input wire	[26:0]		ch0_s2c_bd_base,
	input wire	[26:0]		ch0_s2c_bd_high,
	input wire	[26:0]		ch0_c2s_bd_base,
	input wire	[26:0]		ch0_c2s_bd_high,
	input wire	[26:0]		ch1_s2c_bd_base,
	input wire	[26:0]		ch1_s2c_bd_high,
	input wire	[26:0]		ch1_c2s_bd_base,
	input wire	[26:0]		ch1_c2s_bd_high,

	//software pointer for each DMA channel
	input wire	[26:0]		ch0_s2c_sw_ptr,
	input wire	[26:0]		ch0_c2s_sw_ptr,
	input wire	[26:0]		ch1_s2c_sw_ptr,
	input wire	[26:0]		ch1_c2s_sw_ptr
);

//internal wire and register
  reg					dma_req_first_beat;
 
  //BD request address filter related signals
  wire [3:0]			bd_req_tmp;
  wire [3:0]			bd_req;
  wire					dma_req_type;
  wire					dma_bd_type;
  reg [1:0]				channel_num;

  //BD Buffer checking related signals
  wire [3:0]			bd_base_hit;
  reg [15:0]			bd_entry_mask;
  wire [3:0]			bd_entry_hit;

  //DMA hw/sw pointer
  wire [26:0]			dma_hw_ptr;
  wire [26:0]			dma_sw_ptr;
  wire					sw_backword_hw;
  wire					sw_hw_in_diff_batch;
  
  //BD PCIe non-posted request size
  wire [26:0]			dma_bd_base;
  wire [26:0]			dma_bd_high;
  wire					is_last_bd_batch;

  //BD Buffer updated valid tag related signals
  wire					small_bd_size;
  reg [15:0]			hw_bd_buf_valid_mask;
  reg [15:0]			sw_bd_buf_valid_mask;
  wire [15:0]			sw_ahead_hw_valid_tag;
  wire [15:0]			sw_backword_hw_valid_tag;

  //BD Buffer CMD and PCIe non-posted request related calculation results
  wire					bd_buf_op_type;
  wire [3:0]			bd_entry_offset;
  wire [4:0]			bd_batch_size;
  wire [15:0]			bd_buf_valid_tag;

/*a tag to detect the first beat of each DMA RQ request
* 0 indicates the first beat of each request
* 1 indicates other beats
*/
  always @ (posedge user_clk)
  begin
	  if(user_reset)
		  dma_req_first_beat <= 1'b1;
	  else if(s_axis_dma_rq_tvalid & s_axis_dma_rq_tready)
		  dma_req_first_beat <= s_axis_dma_rq_tlast;
	  else
		  dma_req_first_beat <= dma_req_first_beat;
  end

/*BD Request Filter*/

  //detect whether current request is a BD access request according to the
  //request address
  assign bd_req_tmp[0] = (s_axis_dma_rq_tdata[31:5] >= ch0_s2c_bd_base) & (s_axis_dma_rq_tdata[31:5] <= ch0_s2c_bd_high);
  assign bd_req_tmp[1] = (s_axis_dma_rq_tdata[31:5] >= ch0_c2s_bd_base) & (s_axis_dma_rq_tdata[31:5] <= ch0_c2s_bd_high);
  assign bd_req_tmp[2] = (s_axis_dma_rq_tdata[31:5] >= ch1_s2c_bd_base) & (s_axis_dma_rq_tdata[31:5] <= ch1_s2c_bd_high);
  assign bd_req_tmp[3] = (s_axis_dma_rq_tdata[31:5] >= ch1_c2s_bd_base) & (s_axis_dma_rq_tdata[31:5] <= ch1_c2s_bd_high);

  //dma read or write request
  assign dma_req_type = s_axis_dma_rq_tdata[75];
  //dma bd request
  assign dma_bd_type = s_axis_dma_rq_tdata[100];

  //only filter DMA BD read PCIe request
  assign bd_req = bd_req_tmp & {4{(dma_req_first_beat & dma_bd_type & (~dma_req_type) & s_axis_dma_rq_tvalid)}};

  //channel number of BD access request
  always @ (bd_req)
  begin
	  case (bd_req)
		  4'b0001: channel_num = 2'b00;
		  4'b0010: channel_num = 2'b01;
		  4'b0100: channel_num = 2'b10;
		  4'b1000: channel_num = 2'b11;
		  default: channel_num = 2'b00;
	  endcase
  end

  //Base address comparison
  assign bd_base_hit[0] = ~(|(bd_buf_ch0_s2c_addr ^ s_axis_dma_rq_tdata[31:9])); 
  assign bd_base_hit[1] = ~(|(bd_buf_ch0_c2s_addr ^ s_axis_dma_rq_tdata[31:9])); 
  assign bd_base_hit[2] = ~(|(bd_buf_ch1_s2c_addr ^ s_axis_dma_rq_tdata[31:9])); 
  assign bd_base_hit[3] = ~(|(bd_buf_ch1_c2s_addr ^ s_axis_dma_rq_tdata[31:9])); 

  //valid tag checking
  assign bd_entry_offset = s_axis_dma_rq_tdata[8:5];

  always @ (bd_entry_offset)
  begin
	  case (bd_entry_offset)
		  4'd0: bd_entry_mask = 16'b0000_0000_0000_0001;
		  4'd1: bd_entry_mask = 16'b0000_0000_0000_0010;
		  4'd2: bd_entry_mask = 16'b0000_0000_0000_0100;
		  4'd3: bd_entry_mask = 16'b0000_0000_0000_1000;
		  4'd4: bd_entry_mask = 16'b0000_0000_0001_0000;
		  4'd5: bd_entry_mask = 16'b0000_0000_0010_0000;
		  4'd6: bd_entry_mask = 16'b0000_0000_0100_0000;
		  4'd7: bd_entry_mask = 16'b0000_0000_1000_0000;
		  4'd8: bd_entry_mask = 16'b0000_0001_0000_0000;
		  4'd9: bd_entry_mask = 16'b0000_0010_0000_0000;
		  4'd10: bd_entry_mask = 16'b0000_0100_0000_0000;
		  4'd11: bd_entry_mask = 16'b0000_1000_0000_0000;
		  4'd12: bd_entry_mask = 16'b0001_0000_0000_0000;
		  4'd13: bd_entry_mask = 16'b0010_0000_0000_0000;
		  4'd14: bd_entry_mask = 16'b0100_0000_0000_0000;
		  4'd15: bd_entry_mask = 16'b1000_0000_0000_0000;
		  default: bd_entry_mask = 16'b0000_0000_0000_0000;
	  endcase
  end

  assign bd_entry_hit[0] = |(bd_entry_mask & bd_buf_ch0_s2c_valid);
  assign bd_entry_hit[1] = |(bd_entry_mask & bd_buf_ch0_c2s_valid);
  assign bd_entry_hit[2] = |(bd_entry_mask & bd_buf_ch1_s2c_valid);
  assign bd_entry_hit[3] = |(bd_entry_mask & bd_buf_ch1_c2s_valid);

  //op_type for BD Buffer CMD 1 for read hit, 0 for read miss
  assign bd_buf_op_type = |(bd_base_hit & bd_entry_hit & bd_req);

/*updated BD Buffer valid tag and PCIe non-posted request size calculation*/
  assign dma_hw_ptr = s_axis_dma_rq_tdata[31:5];
  assign dma_sw_ptr = ({27{bd_req[0]}} & ch0_s2c_sw_ptr) |
					  ({27{bd_req[1]}} & ch0_c2s_sw_ptr) |
					  ({27{bd_req[2]}} & ch1_s2c_sw_ptr) |
					  ({27{bd_req[3]}} & ch1_c2s_sw_ptr);

  assign dma_bd_base = ({27{bd_req[0]}} & ch0_s2c_bd_base) |
					   ({27{bd_req[1]}} & ch0_c2s_bd_base) |
					   ({27{bd_req[2]}} & ch1_s2c_bd_base) |
					   ({27{bd_req[3]}} & ch1_c2s_bd_base);

  assign dma_bd_high = ({27{bd_req[0]}} & ch0_s2c_bd_high) |
					   ({27{bd_req[1]}} & ch0_c2s_bd_high) |
					   ({27{bd_req[2]}} & ch1_s2c_bd_high) |
					   ({27{bd_req[3]}} & ch1_c2s_bd_high);

  //PCIe BD non-posted request size for the miss batch
  assign is_last_bd_batch = ~|(dma_bd_high[26:4] ^ dma_hw_ptr[26:4]);
  assign bd_batch_size = is_last_bd_batch ? ({1'b0, (dma_bd_high[3:0] + (~dma_hw_ptr[3:0]))} + 5'd2)
											: ({1'b0, ~dma_hw_ptr[3:0]} + 5'd1);

  //BD size arrange 1 (bd_size register value is 0) to 16 (bd_size register value is 15) 
  //is defined as small bd size
  assign small_bd_size = ~|(dma_bd_base[26:4] ^ dma_bd_high[26:4]);

  //software pointer is a full loop ahead of hardware pointer
  assign sw_backword_hw = (dma_sw_ptr < dma_hw_ptr);

  assign sw_hw_in_diff_batch = |(dma_hw_ptr[26:4] ^ dma_sw_ptr[26:4]); 

  always @ (dma_hw_ptr[3:0])
  begin
	  case(dma_hw_ptr[3:0])
		  4'd0: hw_bd_buf_valid_mask = 16'b1111_1111_1111_1111;
		  4'd1: hw_bd_buf_valid_mask = 16'b1111_1111_1111_1110;
		  4'd2: hw_bd_buf_valid_mask = 16'b1111_1111_1111_1100;
		  4'd3: hw_bd_buf_valid_mask = 16'b1111_1111_1111_1000;
		  4'd4: hw_bd_buf_valid_mask = 16'b1111_1111_1111_0000;
		  4'd5: hw_bd_buf_valid_mask = 16'b1111_1111_1110_0000;
		  4'd6: hw_bd_buf_valid_mask = 16'b1111_1111_1100_0000;
		  4'd7: hw_bd_buf_valid_mask = 16'b1111_1111_1000_0000;
		  4'd8: hw_bd_buf_valid_mask = 16'b1111_1111_0000_0000;
		  4'd9: hw_bd_buf_valid_mask = 16'b1111_1110_0000_0000;
		  4'd10: hw_bd_buf_valid_mask = 16'b1111_1100_0000_0000;
		  4'd11: hw_bd_buf_valid_mask = 16'b1111_1000_0000_0000;
		  4'd12: hw_bd_buf_valid_mask = 16'b1111_0000_0000_0000;
		  4'd13: hw_bd_buf_valid_mask = 16'b1110_0000_0000_0000;
		  4'd14: hw_bd_buf_valid_mask = 16'b1100_0000_0000_0000;
		  4'd15: hw_bd_buf_valid_mask = 16'b1000_0000_0000_0000;
		  default: hw_bd_buf_valid_mask = 16'b0000_0000_0000_0000;
	  endcase
  end

  always @ (dma_sw_ptr[3:0])
  begin
	  case(dma_sw_ptr[3:0])
		  4'd0: sw_bd_buf_valid_mask = 16'b0000_0000_0000_0000;
		  4'd1: sw_bd_buf_valid_mask = 16'b0000_0000_0000_0001;
		  4'd2: sw_bd_buf_valid_mask = 16'b0000_0000_0000_0011;
		  4'd3: sw_bd_buf_valid_mask = 16'b0000_0000_0000_0111;
		  4'd4: sw_bd_buf_valid_mask = 16'b0000_0000_0000_1111;
		  4'd5: sw_bd_buf_valid_mask = 16'b0000_0000_0001_1111;
		  4'd6: sw_bd_buf_valid_mask = 16'b0000_0000_0011_1111;
		  4'd7: sw_bd_buf_valid_mask = 16'b0000_0000_0111_1111;
		  4'd8: sw_bd_buf_valid_mask = 16'b0000_0000_1111_1111;
		  4'd9: sw_bd_buf_valid_mask = 16'b0000_0001_1111_1111;
		  4'd10: sw_bd_buf_valid_mask = 16'b0000_0011_1111_1111;
		  4'd11: sw_bd_buf_valid_mask = 16'b0000_0111_1111_1111;
		  4'd12: sw_bd_buf_valid_mask = 16'b0000_1111_1111_1111;
		  4'd13: sw_bd_buf_valid_mask = 16'b0001_1111_1111_1111;
		  4'd14: sw_bd_buf_valid_mask = 16'b0011_1111_1111_1111;
		  4'd15: sw_bd_buf_valid_mask = 16'b0111_1111_1111_1111;
		  default: sw_bd_buf_valid_mask = 16'b0000_0000_0000_0000;
	  endcase
  end

  //If hardware pointer is smaller than software pointer
  //using hw valid mask only if two pointers in different batch,
  //or otherwise using sw valid mask AND hw valid mask
  assign sw_ahead_hw_valid_tag = (hw_bd_buf_valid_mask) & 
								 ({16{sw_hw_in_diff_batch}} | sw_bd_buf_valid_mask);

  //If hardware pointer is larger than software pointer
  //using hw valid mask only if total BD size is larger than 16,
  //or otherwise using sw valid mask OR hw valid mask
  assign sw_backword_hw_valid_tag = (hw_bd_buf_valid_mask) | 
									({16{small_bd_size}} & sw_bd_buf_valid_mask);

  assign bd_buf_valid_tag = sw_backword_hw ? sw_backword_hw_valid_tag :
							 sw_ahead_hw_valid_tag;

/*AXI-STREAM interface*/

  //signals for PCIe Interface
  assign m_axis_rq_from_rec_tdata = (~|bd_req) ? s_axis_dma_rq_tdata :
									({256{~bd_buf_op_type}} & {s_axis_dma_rq_tdata[255:100],
															  channel_num,
															  s_axis_dma_rq_tdata[97:75], 3'd0,
															  bd_batch_size, 3'd0,
															  s_axis_dma_rq_tdata[63:0]});
  assign m_axis_rq_from_rec_tvalid = ~bd_buf_op_type & s_axis_dma_rq_tvalid;
  assign m_axis_rq_from_rec_tlast = s_axis_dma_rq_tlast;
  assign m_axis_rq_from_rec_tuser = s_axis_dma_rq_tuser;
  assign m_axis_rq_from_rec_tkeep = s_axis_dma_rq_tkeep;
  assign m_axis_rq_from_rec_tdest = (|bd_req);
  assign s_axis_dma_rq_tready = m_axis_rq_from_rec_tready;

  //BD buffer command
  assign m_axis_buffer_cmd_tdata = {s_axis_dma_rq_tdata[31:9], bd_entry_offset, 
									bd_buf_op_type, bd_buf_valid_tag};
  assign m_axis_buffer_cmd_tvalid = (|bd_req) & s_axis_dma_rq_tready;
  assign m_axis_buffer_cmd_tdest = channel_num;

  //cpld_header to Response Queue module
  assign m_axis_cpld_header_tdata = {1'b0, s_axis_dma_rq_tdata[126:121], 
									1'b0, s_axis_dma_rq_tdata[119:80],
									16'h0008, 16'h4020, 
									4'h0, s_axis_dma_rq_tdata[11:0]};
  assign m_axis_cpld_header_tvalid = (|bd_req) & s_axis_dma_rq_tready;
  assign m_axis_cpld_header_tdest  = channel_num;

endmodule

