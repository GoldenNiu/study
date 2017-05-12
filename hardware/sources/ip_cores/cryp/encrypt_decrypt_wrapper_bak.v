`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:24:38 05/11/2016 
// Design Name: 
// Module Name:    encrypt_decrypt_wrapper
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module encrypt_decrypt_wrapper#
  (
   //***************************************************************************
   // AXI4 Shim parameters
   //***************************************************************************
   parameter C_S_AXI_ID_WIDTH              = 4,
                                             // Width of all master and slave ID signals.
                                             // # = >= 1.
   parameter C_S_AXI_ADDR_WIDTH            = 32,
                                             // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                             // M_AXI_ARADDR for all SI/MI slots.
                                             // # = 32.
   parameter C_S_AXI_DATA_WIDTH            = 512
                                             // Width of WDATA and RDATA on SI slot.
                                             // Must be <= APP_DATA_WIDTH.
                                             // # = 32, 64, 128, 256.
   )
  (
     input  [0:0]                            mig_clk,
     input  [0:0]                            mig_rst,
(* mark_debug = "True" *)input  [0:0]       ddr_init_complete,

     input  [0:0]                            mac_clk,
     input  [0:0]                            mac_rst,

 (* mark_debug = "True" *)    output                                  d_s_axi_ready,
 (* mark_debug = "True" *)    input      [63:0]                       d_s_axi_data,
     input      [7:0]                        d_s_axi_tkeep,
 (* mark_debug = "True" *)    input                                   d_s_axi_last,
 (* mark_debug = "True" *)    input                                   d_s_axi_valid,
 (* mark_debug = "True" *)    output                                  d_m_axi_valid,
 (* mark_debug = "True" *)    output     [63:0]                       d_m_axi_data,
     output     [7:0]                        d_m_axi_tkeep,
 (* mark_debug = "True" *)    output                                  d_m_axi_last,
 (* mark_debug = "True" *)   input                                   d_m_axi_ready,
     
 (* mark_debug = "True" *)   output                                  e_s_axi_ready,
 (* mark_debug = "True" *)    input      [63:0]                       e_s_axi_data,
     input      [7:0]                        e_s_axi_tkeep,
 (* mark_debug = "True" *)    input                                   e_s_axi_last,
 (* mark_debug = "True" *)    input                                   e_s_axi_valid,
 (* mark_debug = "True" *)    output                                  e_m_axi_valid,
 (* mark_debug = "True" *)    output     [63:0]                       e_m_axi_data,
     output     [7:0]                        e_m_axi_tkeep,
 (* mark_debug = "True" *)    output                                  e_m_axi_last,
 (* mark_debug = "True" *)    input                                   e_m_axi_ready,
     
 (* mark_debug = "True" *)    input                                   axi_wready, // Indicates slave is ready to accept a 
     output     [C_S_AXI_ID_WIDTH-1:0]       axi_wid,    // Write ID
     output     [C_S_AXI_ADDR_WIDTH-1:0]     axi_waddr,  // Write address
     output     [7:0]                        axi_wlen,   // Write Burst Length
     output     [2:0]                        axi_wsize,  // Write Burst size
     output     [1:0]                        axi_wburst, // Write Burst type
     output     [0:0]                        axi_wlock,  // Write lock type
     output     [3:0]                        axi_wcache, // Write Cache type
     output     [2:0]                        axi_wprot,  // Write Protection type
 (* mark_debug = "True" *)    output                                  axi_wvalid, // Write address valid
     
     // AXI write data channel signals
 (* mark_debug = "True" *)    input                                   axi_wd_wready,  // Write data ready
     output     [C_S_AXI_ID_WIDTH-1:0]       axi_wd_wid,     // Write ID tag
     output     [C_S_AXI_DATA_WIDTH-1:0]     axi_wd_data,    // Write data
     output     [C_S_AXI_DATA_WIDTH/8-1:0]   axi_wd_strb,    // Write strobes
 (* mark_debug = "True" *)    output                                  axi_wd_last,    // Last write transaction   
 (* mark_debug = "True" *)    output                                  axi_wd_valid,   // Write valid
     
     // AXI write response channel signals
     input      [C_S_AXI_ID_WIDTH-1:0]       axi_wd_bid,     // Response ID
     input      [1:0]                        axi_wd_bresp,   // Write response
 (* mark_debug = "True" *)    input                                   axi_wd_bvalid,  // Write reponse valid
 (* mark_debug = "True" *)    output                                  axi_wd_bready,  // Response ready
     // AXI read address channel signals
 (* mark_debug = "True" *)    input                                   axi_rready,     // Read address ready
     output     [C_S_AXI_ID_WIDTH-1:0]       axi_rid,        // Read ID
     output     [C_S_AXI_ADDR_WIDTH-1:0]     axi_raddr,      // Read address
     output     [7:0]                        axi_rlen,       // Read Burst Length
     output     [2:0]                        axi_rsize,      // Read Burst size
     output     [1:0]                        axi_rburst,     // Read Burst type
     output     [0:0]                        axi_rlock,      // Read lock type
     output     [3:0]                        axi_rcache,     // Read Cache type
     output     [2:0]                        axi_rprot,      // Read Protection type
 (* mark_debug = "True" *)    output                                  axi_rvalid,     // Read address valid
     
     // AXI read data channel signals   
     input  [C_S_AXI_ID_WIDTH-1:0]           axi_rd_bid,     // Response ID
     input  [1:0]                            axi_rd_rresp,   // Read response
 (* mark_debug = "True" *)    input                                   axi_rd_rvalid,  // Read reponse valid
     input  [C_S_AXI_DATA_WIDTH-1:0]         axi_rd_data,    // Read data
 (* mark_debug = "True" *)   input                                   axi_rd_last,    // Read last
 (* mark_debug = "True" *)    output                                  axi_rd_rready // Read Response ready
);
(* mark_debug = "True" *) wire init_key_complete;

  // Slave Interface Write Address Ports
  wire [C_S_AXI_ID_WIDTH-1:0]       axi_awid_i;
  wire [C_S_AXI_ADDR_WIDTH-1:0]     axi_awaddr_i;
  wire [7:0]                        axi_awlen_i;
  wire [2:0]                        axi_awsize_i;
  wire [1:0]                        axi_awburst_i;
  wire [0:0]                        axi_awlock_i;
  wire [3:0]                        axi_awcache_i;
  wire [2:0]                        axi_awprot_i;
  wire                              axi_awvalid_i;
  wire                              axi_awready_i;
   // Slave Interface Write Data Ports
  wire [C_S_AXI_ID_WIDTH-1:0]       axi_wid_i;
  wire [C_S_AXI_DATA_WIDTH-1:0]     axi_wdata_i;
  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb_i;
  wire                              axi_wlast_i;
  wire                              axi_wvalid_i;
  wire                              axi_wready_i;
   // Slave Interface Write Response Ports
  wire                              axi_bready_i;
  wire [C_S_AXI_ID_WIDTH-1:0]       axi_bid_i;
  wire [1:0]                        axi_bresp_i;
  wire                              axi_bvalid_i;
   // Slave Interface Read Address Ports
  wire [C_S_AXI_ID_WIDTH-1:0]       axi_arid_i;
  wire [C_S_AXI_ADDR_WIDTH-1:0]     axi_araddr_i;
  wire [7:0]                        axi_arlen_i;
  wire [2:0]                        axi_arsize_i;
  wire [1:0]                        axi_arburst_i;
  wire [0:0]                        axi_arlock_i;
  wire [3:0]                        axi_arcache_i;
  wire [2:0]                        axi_arprot_i;
  wire                              axi_arvalid_i;
  wire                              axi_arready_i;
   // Slave Interface Read Data Ports
  wire                              axi_rready_i;
  wire [C_S_AXI_ID_WIDTH-1:0]       axi_rid_i;
  wire [C_S_AXI_DATA_WIDTH-1:0]     axi_rdata_i;
  wire [1:0]                        axi_rresp_i;
  wire                              axi_rlast_i;
  wire                              axi_rvalid_i;

  wire [7:0] b_din;
  wire [7:0] b_dout;
  wire       b_wr_en;
  wire       b_rd_en;
  wire       b_full;
  wire       b_empty;
  wire       b_valid;

  reg    [0:0]         fifo_rst;
  reg    [0:0]         fifo_rst_sync;
  wire   [0:0]         mac_rst_3cycles;
  reg    [0:0]         mac_rst_r1;
  reg    [0:0]         mac_rst_r2;
  reg    [0:0]         mac_rst_r3;

  assign mac_rst_3cycles = mac_rst_r1 || mac_rst_r2 || mac_rst_r3;

  always @ (posedge mac_clk) begin
     mac_rst_r1 <= mac_rst;
     mac_rst_r2 <= mac_rst_r1;
     mac_rst_r3 <= mac_rst_r2;
  end

  always @ (posedge mig_clk) begin
     fifo_rst_sync <= mac_rst_3cycles;
     fifo_rst <= fifo_rst_sync;
  end


  assign axi_bresp_i    = b_dout[C_S_AXI_ID_WIDTH+1:C_S_AXI_ID_WIDTH];
  assign axi_bid_i      = b_dout[C_S_AXI_ID_WIDTH-1:0];
  assign axi_bvalid_i   = b_valid;
  assign b_rd_en        = axi_bready_i;

  assign b_din = {
      axi_wd_bresp,
      axi_wd_bid
  };
  assign b_wr_en = axi_wd_bvalid;
  assign axi_wd_bready = ~b_full;

   IND_FIFO8bx64 axi_b(
     .wr_clk(mig_clk),
     .rd_clk(mac_clk),
     .rst(fifo_rst),
     .din(b_din),
     .wr_en(b_wr_en),
     .rd_en(b_rd_en),
     .dout(b_dout),
     .full(b_full),
     .empty(),
     .valid(b_valid)
  );


  wire [575:0] r_din;
  wire [575:0] r_dout;
  wire         r_wr_en;
  wire         r_rd_en;
  wire         r_full;
  wire         r_empty;
  wire         r_valid;

   assign axi_rresp_i    = r_dout[C_S_AXI_DATA_WIDTH+C_S_AXI_ID_WIDTH+2:C_S_AXI_DATA_WIDTH+C_S_AXI_ID_WIDTH+1];
   assign axi_rid_i      = r_dout[C_S_AXI_DATA_WIDTH+C_S_AXI_ID_WIDTH:C_S_AXI_DATA_WIDTH+1];
   assign axi_rlast_i    = r_dout[C_S_AXI_DATA_WIDTH];
   assign axi_rdata_i    = r_dout[C_S_AXI_DATA_WIDTH-1:0];
   assign axi_rvalid_i   = r_valid;
   assign r_rd_en        = axi_rready_i;

   assign r_din = {
      axi_rd_rresp,
      axi_rd_bid,
      axi_rd_last,
      axi_rd_data
   };
   assign r_wr_en = axi_rd_rvalid;
   assign axi_rd_rready = ~r_full;

   IND_FIFO576bx512 axi_r(
     .wr_clk(mig_clk),
     .rd_clk(mac_clk),
     .rst(fifo_rst),
     .din(r_din),
     .wr_en(r_wr_en),
     .rd_en(r_rd_en),
     .dout(r_dout),
     .full(r_full),
     .empty(),
     .valid(r_valid)
  );

  wire [575:0] w_din;
  wire [575:0] w_dout;
  wire         w_wr_en;
  wire         w_rd_en;
  wire         w_full;
  wire         w_empty;
  wire         w_valid;


   assign axi_wd_wid     = w_dout[C_S_AXI_DATA_WIDTH+C_S_AXI_ID_WIDTH:C_S_AXI_DATA_WIDTH+1];
   assign axi_wd_last    = w_dout[C_S_AXI_DATA_WIDTH];
   assign axi_wd_data    = w_dout[C_S_AXI_DATA_WIDTH-1:0];
   assign axi_wd_strb    = {(C_S_AXI_DATA_WIDTH/8){1'b1}};
   assign axi_wd_valid   = w_valid;
   assign w_rd_en        = axi_wd_wready;

   assign w_din = {
      axi_wid_i,
      axi_wlast_i,
      axi_wdata_i
   };
   assign w_wr_en = axi_wvalid_i;
   assign axi_wready_i = ~w_full;

   IND_FIFO576bx512 axi_w(
     .wr_clk(mac_clk),
     .rd_clk(mig_clk),
     .rst(fifo_rst),
     .din(w_din),
     .wr_en(w_wr_en),
     .rd_en(w_rd_en),
     .dout(w_dout),
     .full(w_full),
     .empty(),
     .valid(w_valid)
  );

  wire [71:0] aw_din;
  wire [71:0] aw_dout;
  wire        aw_wr_en;
  wire        aw_rd_en;
  wire        aw_full;
  wire        aw_empty;
  wire        aw_valid;


   assign axi_wid        = aw_dout[20+C_S_AXI_ADDR_WIDTH+C_S_AXI_ID_WIDTH:21+C_S_AXI_ADDR_WIDTH];
   assign axi_waddr      = aw_dout[20+C_S_AXI_ADDR_WIDTH:21];
   assign axi_wlen       = aw_dout[20:13];
   assign axi_wsize      = aw_dout[12:10];
   assign axi_wburst     = aw_dout[9:8];
   assign axi_wlock      = aw_dout[7];
   assign axi_wcache     = aw_dout[6:3];
   assign axi_wprot      = aw_dout[2:0];
   assign axi_wvalid     = aw_valid;
   assign aw_rd_en       = axi_wready;

   assign aw_din = {
       axi_awid_i,
       3'b001,
       axi_awaddr_i[28:0],
       axi_awlen_i,
       axi_awsize_i,
       axi_awburst_i,
       axi_awlock_i,
       axi_awcache_i,
       axi_awprot_i
    };
    assign aw_wr_en = axi_awvalid_i;
    assign axi_awready_i = ~aw_full;

   IND_FIFO72bx512 axi_aw(
     .wr_clk(mac_clk),
     .rd_clk(mig_clk),
     .rst(fifo_rst),
     .din(aw_din),
     .wr_en(aw_wr_en),
     .rd_en(aw_rd_en),
     .dout(aw_dout),
     .full(aw_full),
     .empty(),
     .valid(aw_valid)
  );
  
  wire [71:0] ar_din;
  wire [71:0] ar_dout;
  wire        ar_wr_en;
  wire        ar_rd_en;
  wire        ar_full;
  wire        ar_empty;
  wire        ar_valid;
  
   assign axi_rid        = ar_dout[20+C_S_AXI_ADDR_WIDTH+C_S_AXI_ID_WIDTH:21+C_S_AXI_ADDR_WIDTH];
   assign axi_raddr      = ar_dout[20+C_S_AXI_ADDR_WIDTH:21];
   assign axi_rlen       = ar_dout[20:13];
   assign axi_rsize      = ar_dout[12:10];
   assign axi_rburst     = ar_dout[9:8];
   assign axi_rlock      = ar_dout[7];
   assign axi_rcache     = ar_dout[6:3];
   assign axi_rprot      = ar_dout[2:0];
   assign axi_rvalid     = ar_valid;
   assign ar_rd_en       = axi_rready;

   assign ar_din = {
       axi_arid_i,
       3'b001,
       axi_araddr_i[28:0],
       axi_arlen_i,
       axi_arsize_i,
       axi_arburst_i,
       axi_arlock_i,
       axi_arcache_i,
       axi_arprot_i
    };
  assign ar_wr_en = axi_arvalid_i;
  assign axi_arready_i = ~ar_full;

  IND_FIFO72bx512 axi_ar(
     .wr_clk(mac_clk),
     .rd_clk(mig_clk),
     .rst(fifo_rst),
     .din(ar_din),
     .wr_en(ar_wr_en),
     .rd_en(ar_rd_en),
     .dout(ar_dout),
     .full(ar_full),
     .empty(),
     .valid(ar_valid)
  );

   encrypt_decrypt encrypt_decrypt1
       (
       .aclk                             (mac_clk),
       .areset                           (mac_rst),  
       
       .d_s_axi_ready                    (d_s_axi_ready),
       .d_s_axi_data                     (d_s_axi_data),
       .d_s_axi_last                     (d_s_axi_last),
       .d_s_axi_valid                    (d_s_axi_valid),
       .d_m_axi_valid                    (d_m_axi_valid),
       .d_m_axi_data                     (d_m_axi_data),
       .d_m_axi_last                     (d_m_axi_last),
       .d_m_axi_ready                    (d_m_axi_ready),  
       
       .e_s_axi_ready                    (e_s_axi_ready),
       .e_s_axi_data                     (e_s_axi_data),
       .e_s_axi_last                     (e_s_axi_last),
       .e_s_axi_valid                    (e_s_axi_valid),  
       .e_m_axi_valid                    (e_m_axi_valid),
       .e_m_axi_data                     (e_m_axi_data),
       .e_m_axi_last                     (e_m_axi_last),
       .e_m_axi_ready                    (e_m_axi_ready),  
       
       .init_cmptd                       (ddr_init_complete),
       .axi_wready                       (axi_awready_i),
       .axi_wid                          (axi_awid_i),
       .axi_waddr                        (axi_awaddr_i),
       .axi_wlen                         (axi_awlen_i),
       .axi_wsize                        (axi_awsize_i),
       .axi_wburst                       (axi_awburst_i),
       .axi_wlock                        (axi_awlock_i),
       .axi_wcache                       (axi_awcache_i),
       .axi_wprot                        (axi_awprot_i),
       .axi_wvalid                       (axi_awvalid_i),
            
       // AXI write data channel signals
       .axi_wd_wready                    (axi_wready_i),
       .axi_wd_wid                       (axi_wid_i),
       .axi_wd_data                      (axi_wdata_i),
       .axi_wd_strb                      (axi_wstrb_i),
       .axi_wd_last                      (axi_wlast_i),
       .axi_wd_valid                     (axi_wvalid_i),
            
       // AXI write response channel signals
       .axi_wd_bid                       (axi_bid_i),
       .axi_wd_bresp                     (axi_bresp_i),
       .axi_wd_bvalid                    (axi_bvalid_i),
       .axi_wd_bready                    (axi_bready_i),
       .init_key_complete                (init_key_complete),
       .write_key_err                    (write_key_err),
       
       // AXI read address channel signals
       .axi_rready                       (axi_arready_i),
       .axi_rid                          (axi_arid_i),
       .axi_raddr                        (axi_araddr_i),
       .axi_rlen                         (axi_arlen_i),
       .axi_rsize                        (axi_arsize_i),
       .axi_rburst                       (axi_arburst_i),
       .axi_rlock                        (axi_arlock_i),
       .axi_rcache                       (axi_arcache_i),
       .axi_rprot                        (axi_arprot_i),
       .axi_rvalid                       (axi_arvalid_i),
            
       // AXI read data channel signals
       .axi_rd_bid                       (axi_rid_i),
       .axi_rd_rresp                     (axi_rresp_i),
       .axi_rd_rvalid                    (axi_rvalid_i),
       .axi_rd_data                      (axi_rdata_i),
       .axi_rd_last                      (axi_rlast_i),
       .axi_rd_rready                    (axi_rready_i)
);

wire [8:0]  e_tkeep_din;
wire [8:0]  e_tkeep_dout;
wire        e_tkeep_wr_en;
wire        e_tkeep_rd_en;

assign e_tkeep_din = {1'b0,e_s_axi_tkeep};
assign e_tkeep_wr_en = e_s_axi_ready && e_s_axi_valid;
assign e_m_axi_tkeep = e_tkeep_dout[7:0];
assign e_tkeep_rd_en = e_m_axi_valid && e_m_axi_ready;

IND_FIFO9bx1024 e_tkeep_fifo(
   .clk(mac_clk),
   .rst(mac_rst),
   .din(e_tkeep_din),
   .wr_en(e_tkeep_wr_en),
   .rd_en(e_tkeep_rd_en),
   .dout(e_tkeep_dout),
   .full(),
   .empty(),
   .valid()
);

wire [8:0]  d_tkeep_din;
wire [8:0]  d_tkeep_dout;
wire        d_tkeep_wr_en;
wire        d_tkeep_rd_en;

assign d_tkeep_din = {1'b0,d_s_axi_tkeep};
assign d_tkeep_wr_en = d_s_axi_ready && d_s_axi_valid;
assign d_m_axi_tkeep = d_tkeep_dout[7:0];
assign d_tkeep_rd_en = d_m_axi_valid && d_m_axi_ready;

IND_FIFO9bx1024 d_tkeep_fifo(
   .clk(mac_clk),
   .rst(mac_rst),
   .din(d_tkeep_din),
   .wr_en(d_tkeep_wr_en),
   .rd_en(d_tkeep_rd_en),
   .dout(d_tkeep_dout),
   .full(),
   .empty(),
   .valid()
);


endmodule
