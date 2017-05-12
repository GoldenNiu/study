add_wave  /board/dut/user_clk
add_wave  /board/dut/user_reset
add_wave  /board/dut/user_lnk_up
add_wave  -radix hex /board/dut/cfg_phy_link_status
add_wave  -radix hex /board/dut/cfg_negotiated_width
add_wave  -radix hex /board/dut/cfg_current_speed
add_wave  -radix hex /board/dut/cfg_function_status
add_wave  /board/dut/clk_ref_200
add_wave_divider PCIe
add_wave -radix hex /board/dut/s_axis_rq_tlast
add_wave -radix hex /board/dut/s_axis_rq_tdata
add_wave -radix hex /board/dut/s_axis_rq_tuser
add_wave -radix hex /board/dut/s_axis_rq_tkeep
add_wave -radix hex /board/dut/s_axis_rq_tready
add_wave -radix hex /board/dut/s_axis_rq_tvalid
add_wave -radix hex /board/dut/m_axis_rc_tdata
add_wave -radix hex /board/dut/m_axis_rc_tuser
add_wave -radix hex /board/dut/m_axis_rc_tlast
add_wave -radix hex /board/dut/m_axis_rc_tkeep
add_wave -radix hex /board/dut/m_axis_rc_tvalid
add_wave -radix hex /board/dut/m_axis_rc_tready
add_wave -radix hex /board/dut/m_axis_rc_tready_i
add_wave -radix hex /board/dut/m_axis_cq_tdata
add_wave -radix hex /board/dut/m_axis_cq_tuser
add_wave -radix hex /board/dut/m_axis_cq_tlast
add_wave -radix hex /board/dut/m_axis_cq_tkeep
add_wave -radix hex /board/dut/m_axis_cq_tvalid
add_wave -radix hex /board/dut/m_axis_cq_tready
add_wave -radix hex /board/dut/m_axis_cq_tready_i
add_wave -radix hex /board/dut/s_axis_cc_tdata
add_wave -radix hex /board/dut/s_axis_cc_tuser
add_wave -radix hex /board/dut/s_axis_cc_tlast
add_wave -radix hex /board/dut/s_axis_cc_tkeep
add_wave -radix hex /board/dut/s_axis_cc_tvalid
add_wave -radix hex /board/dut/s_axis_cc_tready
add_wave_divider AXI4LITE
add_wave -radix hex /board/dut/axi4lite_s_awaddr
add_wave -radix hex /board/dut/axi4lite_s_awvalid
add_wave -radix hex /board/dut/axi4lite_s_awready
add_wave -radix hex /board/dut/axi4lite_s_wdata
add_wave -radix hex /board/dut/axi4lite_s_wstrb
add_wave -radix hex /board/dut/axi4lite_s_wvalid
add_wave -radix hex /board/dut/axi4lite_s_wready
add_wave -radix hex /board/dut/axi4lite_s_bvalid
add_wave -radix hex /board/dut/axi4lite_s_bready
add_wave -radix hex /board/dut/axi4lite_s_bresp
add_wave -radix hex /board/dut/axi4lite_s_araddr
add_wave -radix hex /board/dut/axi4lite_s_arready
add_wave -radix hex /board/dut/axi4lite_s_arvalid
add_wave -radix hex /board/dut/axi4lite_s_rdata
add_wave -radix hex /board/dut/axi4lite_s_rresp
add_wave -radix hex /board/dut/axi4lite_s_rready
add_wave -radix hex /board/dut/axi4lite_s_rvalid
add_wave_divider DMA_S2C_C2S_0
add_wave -radix hex /board/dut/axi_str_s2c0_tuser
add_wave -radix hex /board/dut/axi_str_s2c0_tlast
add_wave -radix hex /board/dut/axi_str_s2c0_tdata
add_wave -radix hex /board/dut/axi_str_s2c0_tkeep
add_wave -radix hex /board/dut/axi_str_s2c0_tvalid
add_wave -radix hex /board/dut/axi_str_s2c0_tready
add_wave -radix hex /board/dut/axi_str_s2c0_aresetn
add_wave -radix hex /board/dut/axi_str_c2s0_tuser
add_wave -radix hex /board/dut/axi_str_c2s0_tlast
add_wave -radix hex /board/dut/axi_str_c2s0_tdata
add_wave -radix hex /board/dut/axi_str_c2s0_tkeep
add_wave -radix hex /board/dut/axi_str_c2s0_tvalid
add_wave -radix hex /board/dut/axi_str_c2s0_tready
add_wave -radix hex /board/dut/axi_str_c2s0_aresetn
add_wave_divider DMA_S2C_C2S_1
add_wave -radix hex /board/dut/axi_str_s2c1_tuser
add_wave -radix hex /board/dut/axi_str_s2c1_tlast
add_wave -radix hex /board/dut/axi_str_s2c1_tdata
add_wave -radix hex /board/dut/axi_str_s2c1_tkeep
add_wave -radix hex /board/dut/axi_str_s2c1_tvalid
add_wave -radix hex /board/dut/axi_str_s2c1_tready
add_wave -radix hex /board/dut/axi_str_s2c1_aresetn
add_wave -radix hex /board/dut/axi_str_c2s1_tuser
add_wave -radix hex /board/dut/axi_str_c2s1_tlast
add_wave -radix hex /board/dut/axi_str_c2s1_tdata
add_wave -radix hex /board/dut/axi_str_c2s1_tkeep
add_wave -radix hex /board/dut/axi_str_c2s1_tvalid
add_wave -radix hex /board/dut/axi_str_c2s1_tready
add_wave -radix hex /board/dut/axi_str_c2s1_aresetn
add_wave_divider DMA_S2C_C2S_2
add_wave -radix hex /board/dut/axi_str_s2c2_tuser
add_wave -radix hex /board/dut/axi_str_s2c2_tlast
add_wave -radix hex /board/dut/axi_str_s2c2_tdata
add_wave -radix hex /board/dut/axi_str_s2c2_tkeep
add_wave -radix hex /board/dut/axi_str_s2c2_tvalid
add_wave -radix hex /board/dut/axi_str_s2c2_tready
add_wave -radix hex /board/dut/axi_str_s2c2_aresetn
add_wave -radix hex /board/dut/axi_str_c2s2_tuser
add_wave -radix hex /board/dut/axi_str_c2s2_tlast
add_wave -radix hex /board/dut/axi_str_c2s2_tdata
add_wave -radix hex /board/dut/axi_str_c2s2_tkeep
add_wave -radix hex /board/dut/axi_str_c2s2_tvalid
add_wave -radix hex /board/dut/axi_str_c2s2_tready
add_wave_divider DMA_S2C_C2S_3
add_wave -radix hex /board/dut/axi_str_s2c3_tuser
add_wave -radix hex /board/dut/axi_str_s2c3_tlast
add_wave -radix hex /board/dut/axi_str_s2c3_tdata
add_wave -radix hex /board/dut/axi_str_s2c3_tkeep
add_wave -radix hex /board/dut/axi_str_s2c3_tvalid
add_wave -radix hex /board/dut/axi_str_s2c3_tready
add_wave -radix hex /board/dut/axi_str_s2c3_aresetn
add_wave -radix hex /board/dut/axi_str_c2s3_tuser
add_wave -radix hex /board/dut/axi_str_c2s3_tlast
add_wave -radix hex /board/dut/axi_str_c2s3_tdata
add_wave -radix hex /board/dut/axi_str_c2s3_tkeep
add_wave -radix hex /board/dut/axi_str_c2s3_tvalid
add_wave -radix hex /board/dut/axi_str_c2s3_tready
add_wave -radix hex /board/dut/axi_str_c2s3_aresetn


