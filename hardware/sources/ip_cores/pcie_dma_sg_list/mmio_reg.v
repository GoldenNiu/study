/*
 *===========================================================================
 * DMA BD Buffer for Multi-channel PCIe DMA engine
 * Developed by ICT, ACS
 * ==========================================================================
 * 
 * MMIO registers for the base and high address of each DMA channel and used
 * for PCIe request filter
 * filled by software via PCIe
 * connected with PCIe EP via AXI-Lite interface
 * Module name: mmio_reg
 * Author: Yisong Chang (changyisong@ict.ac.cn)
 * Date: 2017.01.05
 *===========================================================================
 *
 * Version History:
 * v0.0.1:	Initialization version  2017.01.05
 * v0.0.2:  Added BD size registers. Each channel is required to maintain at
 * most 65536 BDs in the ring buffer. 2017.01.10
 * v0.0.3:  1. Changed BD base and high address with only 27-bit width
 * (32 byte aligned address), which is the same as that used in DMA engine.
 * 2. Changed BD size register as a 32-bit width one for each channel, 
 * in which only 27-bit MSB is used. The BD size range is 
 * 1 (with register value of 0) to 2^27-1 (with register
 * value of 0xFFFFFFE0) 2017.01.13
 *===========================================================================
 */

`timescale 1ns/1ps

  module mmio_reg (
	input wire			user_clk,
	input wire			axi_lite_aresetn,
	
	//AXI-Lite Interface
	input wire			s_axi_lite_awvalid,
	input wire [31:0]	s_axi_lite_awaddr,
	output reg			s_axi_lite_awready,
	
	input wire			s_axi_lite_wvalid,
	input wire [31:0]	s_axi_lite_wdata,
	input wire [31:0]	s_axi_lite_wstrb,
	output reg			s_axi_lite_wready,

	output reg			s_axi_lite_bvalid,
	output reg [1:0]	s_axi_lite_bresp,
	input wire			s_axi_lite_bready,

	input wire			s_axi_lite_arvalid,
	input wire [31:0]	s_axi_lite_araddr,
	output reg			s_axi_lite_arready,

	output reg			s_axi_lite_rvalid,
	output reg [31:0]	s_axi_lite_rdata,
	output reg [1:0]	s_axi_lite_rresp,
	input wire			s_axi_lite_rready,

	//BASE and HIGH register value to request receiver
	output reg [26:0]	ch0_s2c_bd_base,
	output reg [26:0]	ch0_s2c_bd_high,
	output reg [26:0]	ch0_c2s_bd_base,
	output reg [26:0]	ch0_c2s_bd_high,
	output reg [26:0]	ch1_s2c_bd_base,
	output reg [26:0]	ch1_s2c_bd_high,
	output reg [26:0]	ch1_c2s_bd_base,
	output reg [26:0]	ch1_c2s_bd_high,

	output reg [26:0]	ch0_s2c_bd_size,
	output reg [26:0]	ch0_c2s_bd_size,
	output reg [26:0]	ch1_s2c_bd_size,
	output reg [26:0]	ch1_c2s_bd_size
);

//MMIO register selection mask
	localparam [11:0]	REG_NO_SEL			= 12'b000000000000,
						CH0_S2C_BASE_SEL	= 12'b000000000001,
						CH0_S2C_HIGH_SEL	= 12'b000000000010,
						CH0_C2S_BASE_SEL	= 12'b000000000100,
						CH0_C2S_HIGH_SEL	= 12'b000000001000,
						CH1_S2C_BASE_SEL	= 12'b000000010000,
						CH1_S2C_HIGH_SEL	= 12'b000000100000,
						CH1_C2S_BASE_SEL	= 12'b000001000000,
						CH1_C2S_HIGH_SEL	= 12'b000010000000,
						CH0_S2C_BD_SIZE_SEL	= 12'b000100000000,
						CH0_C2S_BD_SIZE_SEL	= 12'b001000000000,
						CH1_S2C_BD_SIZE_SEL	= 12'b010000000000,
						CH1_C2S_BD_SIZE_SEL	= 12'b100000000000;

//Internal signals
	reg [11:0]			mmio_reg_wr_sel;
	wire				mmio_reg_wr_en;

	reg [31:0]			mmio_reg_rd_val;
	wire				mmio_reg_rd_en;

/* 
 * ======================================================================
 * AXI4-lite Interface basic logic
 * ======================================================================
 */

/* AW channel */
  always @ (posedge user_clk)
  begin
	  if( axi_lite_aresetn == 1'b0 )
		  s_axi_lite_awready <= 1'b0;
	 
	  //capturing write address and write data of AXI-Lite IF at the same time
	  //when both channels are valid
	  else if( ~s_axi_lite_awready & s_axi_lite_awvalid & s_axi_lite_wvalid )
		  s_axi_lite_awready <= 1'b1;
	 
	  //maintaining handshake of awvalid and awready for one cycle
	  else
		  s_axi_lite_awready <= 1'b0;
  end

/* W channel */
  always @ (posedge user_clk)
  begin
	  if( axi_lite_aresetn == 1'b0 )
		  s_axi_lite_wready <= 1'b0;
	  
	  //capturing write address and write data of AXI-Lite IF at the same time
	  //when both channels are valid
	  else if( ~s_axi_lite_wready & s_axi_lite_awvalid & s_axi_lite_wvalid )
		  s_axi_lite_wready <= 1'b1;
	  
	  else
		  s_axi_lite_wready <= 1'b0;
  end
  
  assign mmio_reg_wr_en = s_axi_lite_awvalid & s_axi_lite_wvalid;

  //write address decoder
  always @ (s_axi_lite_awaddr[5:2])
  begin
	  case (s_axi_lite_awaddr[5:2])
		  4'd0: mmio_reg_wr_sel = CH0_S2C_BASE_SEL;
		  4'd1: mmio_reg_wr_sel = CH0_S2C_HIGH_SEL;
		  4'd2: mmio_reg_wr_sel = CH0_C2S_BASE_SEL;
		  4'd3: mmio_reg_wr_sel = CH0_C2S_HIGH_SEL;
		  4'd4: mmio_reg_wr_sel = CH1_S2C_BASE_SEL;
		  4'd5: mmio_reg_wr_sel = CH1_S2C_HIGH_SEL;
		  4'd6: mmio_reg_wr_sel = CH1_C2S_BASE_SEL;
		  4'd7: mmio_reg_wr_sel = CH1_C2S_HIGH_SEL;
		  4'd8: mmio_reg_wr_sel = CH0_S2C_BD_SIZE_SEL;
		  4'd9: mmio_reg_wr_sel = CH0_C2S_BD_SIZE_SEL;
		  4'd10: mmio_reg_wr_sel = CH1_S2C_BD_SIZE_SEL;
		  4'd11: mmio_reg_wr_sel = CH1_C2S_BD_SIZE_SEL;
		  default: mmio_reg_wr_sel = REG_NO_SEL;
	  endcase
  end

/* B channel */
  always @ (posedge user_clk)
  begin
	  if (axi_lite_aresetn == 1'b0)
	  begin
		  s_axi_lite_bvalid <= 1'b0;
		  s_axi_lite_bresp <= 2'b0;
	  end
	  
	  else if ( ~s_axi_lite_bvalid & mmio_reg_wr_en & s_axi_lite_awready & s_axi_lite_wready )
	  begin
		  s_axi_lite_bvalid <= 1'b1;
		  s_axi_lite_bresp <= 2'b0;
	  end
	  
	  else if (s_axi_lite_bvalid & s_axi_lite_bready)
	  begin
		  s_axi_lite_bvalid <= 1'b0;
		  s_axi_lite_bresp <= 2'b0;
	  end
	  
	  else
	  begin
		  s_axi_lite_bvalid <= s_axi_lite_bvalid;
		  s_axi_lite_bresp <= s_axi_lite_bresp;
	  end
  end

/* AR channel */
  always @ (posedge user_clk)
  begin
	  if (axi_lite_aresetn == 1'b0)
		  s_axi_lite_arready <= 1'b0;
	  
	  //capturing read address and maintaining arready valid for one cycle
	  else if (~s_axi_lite_arready & s_axi_lite_arvalid)
		  s_axi_lite_arready <= 1'b1;
	  
	  else
		  s_axi_lite_arready <= 1'b0;
  end

  //read address decoder
  always @ (s_axi_lite_araddr[5:2])
  begin
	  case (s_axi_lite_araddr[5:2])
		  4'd0: mmio_reg_rd_val = ch0_s2c_bd_base;
		  4'd1: mmio_reg_rd_val = ch0_s2c_bd_high;
		  4'd2: mmio_reg_rd_val = ch0_c2s_bd_base;
		  4'd3: mmio_reg_rd_val = ch0_c2s_bd_high;
		  4'd4: mmio_reg_rd_val = ch1_s2c_bd_base;
		  4'd5: mmio_reg_rd_val = ch1_s2c_bd_high;
		  4'd6: mmio_reg_rd_val = ch1_c2s_bd_base;
		  4'd7: mmio_reg_rd_val = ch1_c2s_bd_high;
		  4'd8: mmio_reg_rd_val = ch0_s2c_bd_size;
		  4'd9: mmio_reg_rd_val = ch0_c2s_bd_size;
		  4'd10: mmio_reg_rd_val = ch1_s2c_bd_size;  
		  4'd11: mmio_reg_rd_val = ch1_c2s_bd_size; 
		  default: mmio_reg_rd_val = 'd0;
	  endcase
  end

/* R channel */
  always @ (posedge user_clk)
  begin
	  if ( axi_lite_aresetn == 1'b0 )
	  begin
		  s_axi_lite_rvalid <= 1'b0;
		  s_axi_lite_rresp <= 2'd0;
	  end
	 
	  //validating rvalid immidiately as the AR channel negotiation is finished
	  else if ( ~s_axi_lite_rvalid & s_axi_lite_arready & s_axi_lite_arvalid )
	  begin
		  s_axi_lite_rvalid <= 1'b1;
		  s_axi_lite_rresp <= 2'd0;
	  end
	 
	  //when the master end receiving the read data, invalidating rvalid signal
	  else if (s_axi_lite_rvalid & s_axi_lite_rready)
	  begin
		  s_axi_lite_rvalid <= 1'b0;
		  s_axi_lite_rresp <= 2'b0;
	  end
	  
	  else
	  begin
		  s_axi_lite_rvalid <= s_axi_lite_rvalid;
		  s_axi_lite_rresp <= s_axi_lite_rresp;
	  end
  end

  assign mmio_reg_rd_en = ~s_axi_lite_rvalid & s_axi_lite_arready & s_axi_lite_arvalid;

  always @ (posedge user_clk)
  begin
	  if ( axi_lite_aresetn == 1'b0 )
		  s_axi_lite_rdata <= 32'd0;
	  
	  else if (mmio_reg_rd_en)
		  s_axi_lite_rdata <= mmio_reg_rd_val;
	  
	  else
		  s_axi_lite_rdata <= s_axi_lite_rdata;
  end

/* 
 * ======================================================================
 * MMIO registers 
 * ======================================================================
 */
 /*CH0_S2C_BD_BASE*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch0_s2c_bd_base <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[0] )
		 ch0_s2c_bd_base <= s_axi_lite_wdata[31:5];

	 else
		 ch0_s2c_bd_base <= ch0_s2c_bd_base;
 end

 /*CH0_S2C_BD_HIGH*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch0_s2c_bd_high <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[1] )
		 ch0_s2c_bd_high <= s_axi_lite_wdata[31:5];

	 else
		 ch0_s2c_bd_high <= ch0_s2c_bd_high;
 end

 /*CH0_C2S_BD_BASE*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch0_c2s_bd_base <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[2] )
		 ch0_c2s_bd_base <= s_axi_lite_wdata[31:5];

	 else
		 ch0_c2s_bd_base <= ch0_c2s_bd_base;
 end

 /*CH0_C2S_BD_HIGH*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch0_c2s_bd_high <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[3] )
		 ch0_c2s_bd_high <= s_axi_lite_wdata[31:5];

	 else
		 ch0_c2s_bd_high <= ch0_c2s_bd_high;
 end
 
 /*CH1_S2C_BD_BASE*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch1_s2c_bd_base <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[4] )
		 ch1_s2c_bd_base <= s_axi_lite_wdata[31:5];

	 else
		 ch1_s2c_bd_base <= ch1_s2c_bd_base;
 end

 /*CH1_S2C_BD_HIGH*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch1_s2c_bd_high <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[5] )
		 ch1_s2c_bd_high <= s_axi_lite_wdata[31:5];

	 else
		 ch1_s2c_bd_high <= ch1_s2c_bd_high;
 end

 /*CH1_C2S_BD_BASE*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch1_c2s_bd_base <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[6] )
		 ch1_c2s_bd_base <= s_axi_lite_wdata[31:5];

	 else
		 ch1_c2s_bd_base <= ch1_c2s_bd_base;
 end

 /*CH1_C2S_BD_HIGH*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch1_c2s_bd_high <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[7] )
		 ch1_c2s_bd_high <= s_axi_lite_wdata[31:5];

	 else
		 ch1_c2s_bd_high <= ch1_c2s_bd_high;
 end

 /*CH0_S2C_BD_SIZE*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch0_s2c_bd_size <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[8] )
		 ch0_s2c_bd_size <= s_axi_lite_wdata[31:5];

	 else
		 ch0_s2c_bd_size <= ch0_s2c_bd_size;
 end

 /*CH0_C2S_BD_SIZE*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch0_c2s_bd_size <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[9] )
		 ch0_c2s_bd_size <= s_axi_lite_wdata[31:5];

	 else
		 ch0_c2s_bd_size <= ch0_c2s_bd_size;
 end

 /*CH1_S2C_BD_SIZE*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch1_s2c_bd_size <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[10] )
		 ch1_s2c_bd_size <= s_axi_lite_wdata[31:5];

	 else
		 ch1_s2c_bd_size <= ch1_s2c_bd_size;
 end

 /*CH1_C2S_BD_SIZE*/
 always @(posedge user_clk)
 begin
	 if (axi_lite_aresetn == 1'b0)
		 ch1_c2s_bd_size <= 'd0;

	 else if ( mmio_reg_wr_en & mmio_reg_wr_sel[11] )
		 ch1_c2s_bd_size <= s_axi_lite_wdata[31:5];

	 else
		 ch1_c2s_bd_size <= ch1_c2s_bd_size;
 end

endmodule

