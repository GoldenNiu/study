// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.1 (win64) Build 1215546 Mon Apr 27 19:22:08 MDT 2015
// Date        : Wed Jun 29 17:15:13 2016
// Host        : thinkole-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -mode port F:/Su33/dispatcher_top_stub.v
// Design      : dispatcher_top
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx690tffg1761-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module dispatcher_top(clk, axis_to_mac_tdata_up, axis_to_mac_tkeep_up, axis_to_mac_tvalid_up, axis_from_mac_tready_up, axis_to_mac_tlast_up, rst, axis_from_mac_tdata_down, axis_from_mac_tkeep_down, axis_from_mac_tvalid_down, axis_to_mac_tready_down, axis_from_mac_tlast_down, axis_to_vfifo_tdata_down, axis_to_vfifo_tkeep_down, axis_to_vfifo_tdest_down, axis_to_vfifo_tvalid_down, axis_from_vfifo_tready_down, axis_to_vfifo_tlast_down, axis_from_vfifo_tdata_up, axis_from_vfifo_tkeep_up, axis_from_vfifo_tvalid_up, axis_to_vfifo_tready_up, axis_from_vfifo_tlast_up);
  input clk;
  output [63:0] axis_to_mac_tdata_up;
  output [7:0] axis_to_mac_tkeep_up;
  output axis_to_mac_tvalid_up;
  input axis_from_mac_tready_up;
  output axis_to_mac_tlast_up;
  input rst;
  input [63:0] axis_from_mac_tdata_down;
  input [7:0] axis_from_mac_tkeep_down;
  input axis_from_mac_tvalid_down;
  output axis_to_mac_tready_down;
  input axis_from_mac_tlast_down;
  output [63:0] axis_to_vfifo_tdata_down;
  output [7:0] axis_to_vfifo_tkeep_down;
  output [0:0] axis_to_vfifo_tdest_down;
  output axis_to_vfifo_tvalid_down;
  input axis_from_vfifo_tready_down;
  output axis_to_vfifo_tlast_down;
  input [63:0] axis_from_vfifo_tdata_up;
  input [7:0] axis_from_vfifo_tkeep_up;
  input axis_from_vfifo_tvalid_up;
  output axis_to_vfifo_tready_up;
  input axis_from_vfifo_tlast_up;

endmodule
