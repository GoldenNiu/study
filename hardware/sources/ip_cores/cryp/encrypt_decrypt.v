`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/04/28 16:37:22
// Design Name: 
// Module Name: encrypt_decrypt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module encrypt_decrypt#(
  
parameter C_AXI_ID_WIDTH           = 4, // The AXI id width used for read and write
                                         // This is an integer between 1-16
parameter C_AXI_ADDR_WIDTH         = 32, // This is AXI address width for all 
                                          // SI and MI slots
parameter C_AXI_DATA_WIDTH         = 512 // Width of the AXI write and read data

)
(
input                                   aclk,
input                                   areset,
input                                   mig_clk,
input                                   mig_rst,

output                                  d_s_axi_ready,
input      [63:0]                       d_s_axi_data,
input                                   d_s_axi_last,
input                                   d_s_axi_valid,
output                                  d_m_axi_valid,
output     [63:0]                       d_m_axi_data,
output                                  d_m_axi_last,
input                                   d_m_axi_ready,

output                                  e_s_axi_ready,
input      [63:0]                       e_s_axi_data,
input                                   e_s_axi_last,
input                                   e_s_axi_valid,
output                                  e_m_axi_valid,
output     [63:0]                       e_m_axi_data,
output                                  e_m_axi_last,
input                                   e_m_axi_ready,

input                                   init_cmptd, // Initialization completed
input                                   axi_wready, // Indicates slave is ready to accept a 
output     [C_AXI_ID_WIDTH-1:0]         axi_wid,    // Write ID
output     [C_AXI_ADDR_WIDTH-1:0]       axi_waddr,  // Write address
output     [7:0]                        axi_wlen,   // Write Burst Length
output     [2:0]                        axi_wsize,  // Write Burst size
output     [1:0]                        axi_wburst, // Write Burst type
output     [0:0]                        axi_wlock,  // Write lock type
output     [3:0]                        axi_wcache, // Write Cache type
output     [2:0]                        axi_wprot,  // Write Protection type
output                                  axi_wvalid, // Write address valid

// AXI write data channel signals
input                                   axi_wd_wready,  // Write data ready
output     [C_AXI_ID_WIDTH-1:0]         axi_wd_wid,     // Write ID tag
output     [C_AXI_DATA_WIDTH-1:0]       axi_wd_data,    // Write data
output     [C_AXI_DATA_WIDTH/8-1:0]     axi_wd_strb,    // Write strobes
output                                  axi_wd_last,    // Last write transaction   
output                                  axi_wd_valid,   // Write valid

// AXI write response channel signals
input      [C_AXI_ID_WIDTH-1:0]         axi_wd_bid,     // Response ID
input      [1:0]                        axi_wd_bresp,   // Write response
input                                   axi_wd_bvalid,  // Write reponse valid
output                                  axi_wd_bready,  // Response ready
output                                  init_key_complete,
output                                  write_key_err,
// AXI read address channel signals
input                                   axi_rready,     // Read address ready
output     [C_AXI_ID_WIDTH-1:0]         axi_rid,        // Read ID
output     [C_AXI_ADDR_WIDTH-1:0]       axi_raddr,      // Read address
output     [7:0]                        axi_rlen,       // Read Burst Length
output     [2:0]                        axi_rsize,      // Read Burst size
output     [1:0]                        axi_rburst,     // Read Burst type
output     [0:0]                        axi_rlock,      // Read lock type
output     [3:0]                        axi_rcache,     // Read Cache type
output     [2:0]                        axi_rprot,      // Read Protection type
output                                  axi_rvalid,     // Read address valid

// AXI read data channel signals   
input  [C_AXI_ID_WIDTH-1:0]             axi_rd_bid,     // Response ID
input  [1:0]                            axi_rd_rresp,   // Read response
input                                   axi_rd_rvalid,  // Read reponse valid
input  [C_AXI_DATA_WIDTH-1:0]           axi_rd_data,    // Read data
input                                   axi_rd_last,    // Read last
output                                  axi_rd_rready // Read Response ready
);

wire [C_AXI_ADDR_WIDTH-1:0] e_axi_raddr_macclk;
wire                        e_axi_rvalid_macclk;
wire                        e_axi_rd_rvalid_macclk;
wire [C_AXI_DATA_WIDTH-1:0] e_axi_rd_data_macclk;
wire                        e_axi_rd_last_macclk;

wire [C_AXI_ADDR_WIDTH-1:0] d_axi_raddr_macclk;
wire                        d_axi_rvalid_macclk;
wire                        d_axi_rd_rvalid_macclk;
wire [C_AXI_DATA_WIDTH-1:0] d_axi_rd_data_macclk;
wire                        d_axi_rd_last_macclk;

wire [C_AXI_ADDR_WIDTH-1:0] e_axi_raddr;
wire                        e_axi_rvalid;
wire                        e_axi_rd_rvalid;
wire [C_AXI_DATA_WIDTH-1:0] e_axi_rd_data;
wire                        e_axi_rd_last;

wire [C_AXI_ADDR_WIDTH-1:0] d_axi_raddr;
wire                        d_axi_rvalid;
wire                        d_axi_rd_rvalid;
wire [C_AXI_DATA_WIDTH-1:0] d_axi_rd_data;
wire                        d_axi_rd_last;

wire [C_AXI_ADDR_WIDTH-1:0] key_axi_raddr;
wire                        key_axi_rvalid;
wire                        key_axi_rd_rvalid;
wire [C_AXI_DATA_WIDTH-1:0] key_axi_rd_data;
wire                        key_axi_rd_last;

wire   [71:0]         d_ar_dout;
assign d_axi_raddr = d_ar_dout[31:0];
   IND_FIFO72bx512 d_ar(
     .wr_clk(aclk),
     .rd_clk(mig_clk),
     .rst(mig_rst),
     .din({40'b0,d_axi_raddr_macclk}),
     .wr_en(d_axi_rvalid_macclk),
     .rd_en(1'b1),
     .dout(d_ar_dout),
     .full(),
     .empty(),
     .valid(d_axi_rvalid)
  );

wire   [575:0]         d_r_dout;
assign d_axi_rd_last_macclk = d_r_dout[512];
assign d_axi_rd_data_macclk = d_r_dout[511:0];
   IND_FIFO576bx512 d_r(
     .wr_clk(mig_clk),
     .rd_clk(aclk),
     .rst(mig_rst),
     .din({63'b0,d_axi_rd_last,d_axi_rd_data}),
     .wr_en(d_axi_rd_rvalid),
     .rd_en(1'b1),
     .dout(d_r_dout),
     .full(),
     .empty(),
     .valid(d_axi_rd_rvalid_macclk)
  );

wire   [71:0]         e_ar_dout;
assign e_axi_raddr = e_ar_dout[31:0];
   IND_FIFO72bx512 e_ar(
     .wr_clk(aclk),
     .rd_clk(mig_clk),
     .rst(mig_rst),
     .din({40'b0,e_axi_raddr_macclk}),
     .wr_en(e_axi_rvalid_macclk),
     .rd_en(1'b1),
     .dout(e_ar_dout),
     .full(),
     .empty(),
     .valid(e_axi_rvalid)
  );

wire   [575:0]         e_r_dout;
assign e_axi_rd_last_macclk = e_r_dout[512];
assign e_axi_rd_data_macclk = e_r_dout[511:0];
   IND_FIFO576bx512 e_r(
     .wr_clk(mig_clk),
     .rd_clk(aclk),
     .rst(mig_rst),
     .din({63'b0,e_axi_rd_last,e_axi_rd_data}),
     .wr_en(e_axi_rd_rvalid),
     .rd_en(1'b1),
     .dout(e_r_dout),
     .full(),
     .empty(),
     .valid(e_axi_rd_rvalid_macclk)
  );

key_init  key_init1
        (
          .aclk                             (mig_clk),
          .aresetn                          (~mig_rst),
     
     // Input control signals
          .init_cmptd                       (init_cmptd),
     
     // AXI write address channel signals
          .axi_wready                       (axi_wready),
          .axi_wid                          (axi_wid),
          .axi_waddr                        (axi_waddr),
          .axi_wlen                         (axi_wlen),
          .axi_wsize                        (axi_wsize),
          .axi_wburst                       (axi_wburst),
          .axi_wlock                        (axi_wlock),
          .axi_wcache                       (axi_wcache),
          .axi_wprot                        (axi_wprot),
          .axi_wvalid                       (axi_wvalid),
     
     // AXI write data channel signals
          .axi_wd_wready                    (axi_wd_wready),
          .axi_wd_wid                       (axi_wd_wid),
          .axi_wd_data                      (axi_wd_data),
          .axi_wd_strb                      (axi_wd_strb),
          .axi_wd_last                      (axi_wd_last),
          .axi_wd_valid                     (axi_wd_valid),
     
     // AXI write response channel signals
          .axi_wd_bid                       (axi_wd_bid),
          .axi_wd_bresp                     (axi_wd_bresp),
          .axi_wd_bvalid                    (axi_wd_bvalid),
          .axi_wd_bready                    (axi_wd_bready),

          .key_axi_rvalid                   (key_axi_rvalid),
          .key_axi_raddr                    (key_axi_raddr),
          .key_axi_rd_rvalid                (key_axi_rd_rvalid),
          .key_axi_rd_data                  (key_axi_rd_data),  
          .key_axi_rd_last                  (key_axi_rd_last), 
          .write_key_err                    (write_key_err),
          .complete                         (init_key_complete)
    
     );

  encrypt  encrypt1
        (
          .aclk                             (aclk),
          .areset                           (areset),
     
     // Input control signals
     
          .e_s_axi_ready                      (e_s_axi_ready ),
          .e_s_axi_data                       (e_s_axi_data),
          .e_s_axi_last                       (e_s_axi_last),
          .e_s_axi_valid                      (e_s_axi_valid),
          
          .e_m_axi_valid                      (e_m_axi_valid),
          .e_m_axi_data                       (e_m_axi_data),
          .e_m_axi_last                       (e_m_axi_last),
          .e_m_axi_ready                      (e_m_axi_ready),  
     // AXI read address channel signals
          .e_axi_raddr                        (e_axi_raddr_macclk),
          .e_axi_rvalid                       (e_axi_rvalid_macclk),
     
     // AXI read data channel signals
          .e_axi_rd_rvalid                    (e_axi_rd_rvalid_macclk),
          .e_axi_rd_data                      (e_axi_rd_data_macclk),
          .e_axi_rd_last                      (e_axi_rd_last_macclk)
     );
  decode  decode1
    (
      .aclk                             (aclk),
      .areset                           (areset),
 
 // Input control signals
 
      .d_s_axi_ready                      (d_s_axi_ready),
      .d_s_axi_data                       (d_s_axi_data),
      .d_s_axi_last                       (d_s_axi_last),
      .d_s_axi_valid                      (d_s_axi_valid),
      
      .d_m_axi_valid                      (d_m_axi_valid),
      .d_m_axi_data                       (d_m_axi_data),
      .d_m_axi_last                       (d_m_axi_last),
      .d_m_axi_ready                      (d_m_axi_ready),  
 // AXI read address channel signals
 
      .d_axi_raddr                        (d_axi_raddr_macclk),
      .d_axi_rvalid                       (d_axi_rvalid_macclk),
 
 // AXI read data channel signals
      .d_axi_rd_rvalid                    (d_axi_rd_rvalid_macclk),
      .d_axi_rd_data                      (d_axi_rd_data_macclk),
      .d_axi_rd_last                      (d_axi_rd_last_macclk)

 );
 
 read_key read_key1 
	(
	  .aclk                             (mig_clk),
     .areset                           (mig_rst),

     .d_axi_rvalid                     (d_axi_rvalid),
     .d_axi_raddr                      (d_axi_raddr), 
     .d_axi_rd_rvalid                  (d_axi_rd_rvalid), 
     .d_axi_rd_data                    (d_axi_rd_data),    
     .d_axi_rd_last                    (d_axi_rd_last),     

     .e_axi_rvalid                     (e_axi_rvalid),
     .e_axi_raddr                      (e_axi_raddr),
     .e_axi_rd_rvalid                  (e_axi_rd_rvalid),
     .e_axi_rd_data                    (e_axi_rd_data),  
     .e_axi_rd_last                    (e_axi_rd_last), 
     
     .key_axi_rvalid                   (key_axi_rvalid),
     .key_axi_raddr                    (key_axi_raddr),
     .key_axi_rd_rvalid                (key_axi_rd_rvalid),
     .key_axi_rd_data                  (key_axi_rd_data),  
     .key_axi_rd_last                  (key_axi_rd_last), 

     .axi_rready                       (axi_rready),     // Read address ready
     .axi_rid                          (axi_rid),        // Read ID
     .axi_raddr                        (axi_raddr),      // Read address
     .axi_rlen                         (axi_rlen),       // Read Burst Length
     .axi_rsize                        (axi_rsize),      // Read Burst size
     .axi_rburst                       (axi_rburst),     // Read Burst type
     .axi_rlock                        (axi_rlock),      // Read lock type
     .axi_rcache                       (axi_rcache),     // Read Cache type
     .axi_rprot                        (axi_rprot),      // Read Protection type
     .axi_rvalid                       (axi_rvalid),     // Read address valid

// AXI read data channel signals   
     .axi_rd_bid                       (axi_rd_bid),     // Response ID
     .axi_rd_rresp                     (axi_rd_rresp),   // Read response
     .axi_rd_rvalid                    (axi_rd_rvalid),  // Read reponse valid
     .axi_rd_data                      (axi_rd_data),    // Read data
     .axi_rd_last                      (axi_rd_last),    // Read last
     .axi_rd_rready                    (axi_rd_rready)  // Read Response ready
	); 
endmodule
