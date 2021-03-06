// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module dma_back_end_axi(rst_n, clk, testmode, s_axis_rq_tlast, s_axis_rq_tdata, s_axis_rq_tuser, s_axis_rq_tkeep, s_axis_rq_tready, s_axis_rq_tvalid, m_axis_rc_tdata, m_axis_rc_tuser, m_axis_rc_tlast, m_axis_rc_tkeep, m_axis_rc_tvalid, m_axis_rc_tready, m_axis_cq_tdata, m_axis_cq_tuser, m_axis_cq_tlast, m_axis_cq_tkeep, m_axis_cq_tvalid, m_axis_cq_tready, s_axis_cc_tdata, s_axis_cc_tuser, s_axis_cc_tlast, s_axis_cc_tkeep, s_axis_cc_tvalid, s_axis_cc_tready, mgmt_mst_en, mgmt_msi_en, mgmt_msix_en, mgmt_msix_table_offset, mgmt_msix_pba_offset, mgmt_msix_function_mask, mgmt_max_payload_size, mgmt_max_rd_req_size, mgmt_clk_period_in_ns, mgmt_version, mgmt_pcie_version, mgmt_user_version, mgmt_cfg_id, mgmt_interrupt, user_interrupt, cfg_interrupt_int, cfg_interrupt_pending, cfg_interrupt_sent, cfg_interrupt_msi_int, cfg_interrupt_msi_sent, mgmt_ch_infinite, mgmt_cd_infinite, mgmt_ch_credits, mgmt_cd_credits, mgmt_adv_cpl_timeout_disable, mgmt_adv_cpl_timeout_value, mgmt_cpl_timeout_disable, mgmt_cpl_timeout_value, err_cpl_to_closed_tag, err_cpl_timeout, cpl_tag_active, err_pkt_poison, err_pkt_ur, err_pkt_header, s2c_cfg_constants, s2c_areset_n, s2c_aclk, s2c_fifo_addr_n, s2c_awvalid, s2c_awready, s2c_awaddr, s2c_awlen, s2c_awusereop, s2c_awsize, s2c_wvalid, s2c_wready, s2c_wdata, s2c_wstrb, s2c_wlast, s2c_wusereop, s2c_wusercontrol, s2c_bvalid, s2c_bready, s2c_bresp, c2s_cfg_constants, c2s_areset_n, c2s_aclk, c2s_fifo_addr_n, c2s_arvalid, c2s_arready, c2s_araddr, c2s_arlen, c2s_arsize, c2s_rvalid, c2s_rready, c2s_rdata, c2s_rresp, c2s_rlast, c2s_ruserstatus, c2s_ruserstrb, m_areset_n, m_aclk, m_awvalid, m_awready, m_awaddr, m_wvalid, m_wready, m_wdata, m_wstrb, m_bvalid, m_bready, m_bresp, m_arvalid, m_arready, m_araddr, m_rvalid, m_rready, m_rdata, m_rresp, m_interrupt, t_areset_n, t_aclk, t_awvalid, t_awready, t_awregion, t_awaddr, t_awlen, t_awsize, t_wvalid, t_wready, t_wdata, t_wstrb, t_wlast, t_bvalid, t_bready, t_bresp, t_arvalid, t_arready, t_arregion, t_araddr, t_arlen, t_arsize, t_rvalid, t_rready, t_rdata, t_rresp, t_rlast);
  input rst_n;
  input clk;
  input testmode;
  output s_axis_rq_tlast;
  output [255:0]s_axis_rq_tdata;
  output [59:0]s_axis_rq_tuser;
  output [7:0]s_axis_rq_tkeep;
  input s_axis_rq_tready;
  output s_axis_rq_tvalid;
  input [255:0]m_axis_rc_tdata;
  input [74:0]m_axis_rc_tuser;
  input m_axis_rc_tlast;
  input [7:0]m_axis_rc_tkeep;
  input m_axis_rc_tvalid;
  output m_axis_rc_tready;
  input [255:0]m_axis_cq_tdata;
  input [84:0]m_axis_cq_tuser;
  input m_axis_cq_tlast;
  input [7:0]m_axis_cq_tkeep;
  input m_axis_cq_tvalid;
  output m_axis_cq_tready;
  output [255:0]s_axis_cc_tdata;
  output [32:0]s_axis_cc_tuser;
  output s_axis_cc_tlast;
  output [7:0]s_axis_cc_tkeep;
  output s_axis_cc_tvalid;
  input s_axis_cc_tready;
  input mgmt_mst_en;
  input mgmt_msi_en;
  input mgmt_msix_en;
  input [31:0]mgmt_msix_table_offset;
  input [31:0]mgmt_msix_pba_offset;
  input mgmt_msix_function_mask;
  input [2:0]mgmt_max_payload_size;
  input [2:0]mgmt_max_rd_req_size;
  input [7:0]mgmt_clk_period_in_ns;
  output [31:0]mgmt_version;
  input [31:0]mgmt_pcie_version;
  input [31:0]mgmt_user_version;
  input [15:0]mgmt_cfg_id;
  input [31:0]mgmt_interrupt;
  input user_interrupt;
  output cfg_interrupt_int;
  output [1:0]cfg_interrupt_pending;
  input cfg_interrupt_sent;
  output cfg_interrupt_msi_int;
  input cfg_interrupt_msi_sent;
  input mgmt_ch_infinite;
  input mgmt_cd_infinite;
  input [7:0]mgmt_ch_credits;
  input [11:0]mgmt_cd_credits;
  output mgmt_adv_cpl_timeout_disable;
  output [3:0]mgmt_adv_cpl_timeout_value;
  input mgmt_cpl_timeout_disable;
  input [3:0]mgmt_cpl_timeout_value;
  output err_cpl_to_closed_tag;
  output err_cpl_timeout;
  output cpl_tag_active;
  output err_pkt_poison;
  output err_pkt_ur;
  output [127:0]err_pkt_header;
  input [255:0]s2c_cfg_constants;
  output [3:0]s2c_areset_n;
  input [3:0]s2c_aclk;
  input [3:0]s2c_fifo_addr_n;
  output [3:0]s2c_awvalid;
  input [3:0]s2c_awready;
  output [143:0]s2c_awaddr;
  output [15:0]s2c_awlen;
  output [3:0]s2c_awusereop;
  output [11:0]s2c_awsize;
  output [3:0]s2c_wvalid;
  input [3:0]s2c_wready;
  output [1023:0]s2c_wdata;
  output [127:0]s2c_wstrb;
  output [3:0]s2c_wlast;
  output [3:0]s2c_wusereop;
  output [255:0]s2c_wusercontrol;
  input [3:0]s2c_bvalid;
  output [3:0]s2c_bready;
  input [7:0]s2c_bresp;
  input [255:0]c2s_cfg_constants;
  output [3:0]c2s_areset_n;
  input [3:0]c2s_aclk;
  input [3:0]c2s_fifo_addr_n;
  output [3:0]c2s_arvalid;
  input [3:0]c2s_arready;
  output [143:0]c2s_araddr;
  output [15:0]c2s_arlen;
  output [11:0]c2s_arsize;
  input [3:0]c2s_rvalid;
  output [3:0]c2s_rready;
  input [1023:0]c2s_rdata;
  input [7:0]c2s_rresp;
  input [3:0]c2s_rlast;
  input [255:0]c2s_ruserstatus;
  input [127:0]c2s_ruserstrb;
  input m_areset_n;
  input m_aclk;
  input m_awvalid;
  output m_awready;
  input [15:0]m_awaddr;
  input m_wvalid;
  output m_wready;
  input [31:0]m_wdata;
  input [3:0]m_wstrb;
  output m_bvalid;
  input m_bready;
  output [1:0]m_bresp;
  input m_arvalid;
  output m_arready;
  input [15:0]m_araddr;
  output m_rvalid;
  input m_rready;
  output [31:0]m_rdata;
  output [1:0]m_rresp;
  output [8:0]m_interrupt;
  input t_areset_n;
  input t_aclk;
  output t_awvalid;
  input t_awready;
  output [2:0]t_awregion;
  output [31:0]t_awaddr;
  output [3:0]t_awlen;
  output [2:0]t_awsize;
  output t_wvalid;
  input t_wready;
  output [255:0]t_wdata;
  output [31:0]t_wstrb;
  output t_wlast;
  input t_bvalid;
  output t_bready;
  input [1:0]t_bresp;
  output t_arvalid;
  input t_arready;
  output [2:0]t_arregion;
  output [31:0]t_araddr;
  output [3:0]t_arlen;
  output [2:0]t_arsize;
  input t_rvalid;
  output t_rready;
  input [255:0]t_rdata;
  input [1:0]t_rresp;
  input t_rlast;
endmodule
