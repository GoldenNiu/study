/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * cpld packager designed for PCIe BD read cpld package
 * and send to Mux in Response Queue
 * sub module of Response Queue
 * Module name: cpld_packager 
 * Author: Zhao Zhang (zhangzhao02@ict.ac.cn)
 * Date: 2017.01.23
 *===========================================================================
 *
 * Version History:
 * v0.0.1: Initialization version 2017.01.23
 *===========================================================================
 */

`timescale 1ns/1ps

module cpld_packager (
	input wire				user_clk,
	input wire				user_reset,

	//cpld header from Request Receiver
	input wire [95:0]		m_axis_cpld_header_tdata,
	input wire				m_axis_cpld_header_tvalid,
	
	//bd data from bd buffer
	input wire [255:0]		m_axis_bd_from_buffer_tdata,
	input wire				m_axis_bd_from_buffer_tvalid,

	//bd read cpld to mux in Response Queue
	output wire [255:0]		s_axis_bd_read_cpld_tdata,
	output wire				s_axis_bd_read_cpld_tvalid,
	output wire				s_axis_bd_read_cpld_tready,
	output wire				s_axis_bd_read_cpld_tlast,
	output wire [74:0]		s_axis_bd_read_cpld_tuser,
	output wire [7:0]		s_axis_bd_read_cpld_tkeep


);

  reg [95:0]					cpld_bd_second;
  reg [255:0]					cpld_bd;
  reg							cpld_head;
  reg							cpld_valid;
  wire [31:0]					parity;

  always @ (posedge user_clk)
  begin
	  if(user_reset)
	  begin
		  cpld_bd <= 256'd0;
		  cpld_bd_second <= 96'd0;
		  cpld_head <= 1'b1;
		  cpld_valid <= 1'b0;
	  end

	  else if (m_axis_cpld_header_tvalid)
		  cpld_bd[95:0] <= m_axis_cpld_header_tdata;

	  else if (m_axis_bd_from_buffer_tvalid)
	  begin
		  cpld_bd[255:96] <= m_axis_bd_from_buffer_tdata[159:0];
		  cpld_bd_second <= m_axis_bd_from_buffer_tdata[255:160];
		  cpld_head	<= 1'b1;
		  cpld_valid <= 1'b1;
	  end

	  else if (s_axis_bd_read_cpld_tvalid & s_axis_bd_read_cpld_tready & (~s_axis_bd_read_cpld_tlast))
	  begin
		  cpld_bd <= {160'd0, cpld_bd_second};
		  cpld_head <= 1'b0;
	  end

	  else if (s_axis_bd_read_cpld_tvalid & s_axis_bd_read_cpld_tready & s_axis_bd_read_cpld_tlast)
	  begin
		  cpld_head <= 1'b1;
		  cpld_valid <= 1'b0;
	  end

	  else 
	  begin
		  cpld_bd <= cpld_bd;
		  cpld_bd_second <= cpld_bd_second;
		  cpld_head <= cpld_head;
		  cpld_valid <= cpld_valid;
	  end


  end

  //calculate parity check bit in tuser
  assign parity[0] = ~^cpld_bd[7:0];
  assign parity[1] = ~^cpld_bd[15:8];
  assign parity[2] = ~^cpld_bd[23:16];
  assign parity[3] = ~^cpld_bd[31:24];
  assign parity[4] = ~^cpld_bd[39:32];
  assign parity[5] = ~^cpld_bd[47:40];
  assign parity[6] = ~^cpld_bd[55:48];
  assign parity[7] = ~^cpld_bd[63:56];
  assign parity[8] = ~^cpld_bd[71:64];
  assign parity[9] = ~^cpld_bd[79:72];
  assign parity[10] = ~^cpld_bd[87:80];
  assign parity[11] = ~^cpld_bd[95:88];
  assign parity[12] = ~^cpld_bd[103:96];
  assign parity[13] = ~^cpld_bd[111:104];
  assign parity[14] = ~^cpld_bd[119:112];
  assign parity[15] = ~^cpld_bd[127:120];
  assign parity[16] = ~^cpld_bd[135:128];
  assign parity[17] = ~^cpld_bd[143:136];
  assign parity[18] = ~^cpld_bd[151:144];
  assign parity[19] = ~^cpld_bd[159:152];
  assign parity[20] = ~^cpld_bd[167:160];
  assign parity[21] = ~^cpld_bd[175:168];
  assign parity[22] = ~^cpld_bd[183:176];
  assign parity[23] = ~^cpld_bd[191:184];
  assign parity[24] = ~^cpld_bd[199:192];
  assign parity[25] = ~^cpld_bd[207:200];
  assign parity[26] = ~^cpld_bd[215:208];
  assign parity[27] = ~^cpld_bd[223:216];
  assign parity[28] = ~^cpld_bd[231:224];
  assign parity[29] = ~^cpld_bd[239:232];
  assign parity[30] = ~^cpld_bd[247:240];
  assign parity[31] = ~^cpld_bd[255:248];

  assign s_axis_bd_read_cpld_tlast = ~cpld_head;
  assign s_axis_bd_read_cpld_tdata = cpld_bd;
  assign s_axis_bd_read_cpld_tvalid = cpld_valid;
  assign s_axis_bd_read_cpld_tkeep = {{5{cpld_head}},3'b111};
  assign s_axis_bd_read_cpld_tuser = {parity, 10'd0, cpld_head, {20{cpld_head}}, {12{~cpld_head}}};

endmodule

