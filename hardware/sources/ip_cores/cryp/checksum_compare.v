`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/22 21:30:58
// Design Name: 
// Module Name: checksum_compare
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


module checksum_compare(
input                                   clk,
input                                   areset,
input                                   s_axi_valid,
input        [63:0]                     s_axi_data,
input        [7:0]                      s_axi_keep,
input                                   s_axi_last,
input                                   s_axi_ready,
input                                   comp_result_req,
output  reg                             csum_compare_r,
output                                   pkt_err,
output  reg  [63:0]                     lose_pkt_cnt
    );
wire [15:0]  d_s_checkSum_data_o;
wire         d_s_checkSum_valid_o;
reg   [15:0] d_s_data_cnt;
wire         former_csum_wr_en;
wire         csum_rd_en;
wire         former_csum_empty;
wire [15:0]  former_csum_din;
wire [15:0]  former_csum_dout;
wire         later_csum_wr_en;
wire         later_csum_empty;
wire [15:0]  later_csum_din;
wire [15:0]  later_csum_dout;
reg          rd_csum_flag;
reg          rd_en_flag;
reg          csum_compare_r_valid;

assign pkt_err = (csum_compare_r_valid&&(~csum_compare_r));

assign former_csum_wr_en = (s_axi_valid&&s_axi_ready)&&(d_s_data_cnt == 6);
assign former_csum_din = s_axi_data[31:16];
assign csum_rd_en = ((~former_csum_empty)&&(~later_csum_empty)&&rd_en_flag);
always @(posedge clk) begin
    if(areset) begin
        csum_compare_r <= 0;
        d_s_data_cnt   <= 0;
        rd_en_flag     <= 1;
        rd_csum_flag   <= 0;
        lose_pkt_cnt   <= 0;
        csum_compare_r_valid <= 0;
    end
    else begin
        if(s_axi_valid&&s_axi_ready&&s_axi_last) 
            d_s_data_cnt <= 0;
        else if(s_axi_valid&&s_axi_ready)
            d_s_data_cnt <= d_s_data_cnt + 1;
            
        if(comp_result_req)
            rd_en_flag <= 1'b1;
        else if(csum_rd_en) 
            rd_en_flag <= 1'b0; 
              
        if(csum_rd_en) begin
            rd_csum_flag <= 1'b1;
        end
        else
            rd_csum_flag <= 1'b0;
         
         if(rd_csum_flag)
            csum_compare_r <= (former_csum_dout == later_csum_dout) ? 1'b1 : 1'b0;
            
         if(csum_compare_r_valid)
            csum_compare_r_valid <= 1'b0;
         else if(rd_csum_flag)
            csum_compare_r_valid <= 1'b1;
            
         if(csum_compare_r_valid&&(~csum_compare_r))
            lose_pkt_cnt <= lose_pkt_cnt + 1; 
    end
end

    checkSum d_s_checkSum_compute(
    .clk                   (clk),
    .areset                (areset),
    .m_axi_valid           (s_axi_valid),
    .m_axi_data            (s_axi_data),
    .m_axi_tkeep           (s_axi_keep),
    .m_axi_last            (s_axi_last),
    .m_axi_ready           (s_axi_ready),
    .checksum_data         (d_s_checkSum_data_o),
    .checksum_valid        (d_s_checkSum_valid_o)
      );
  IND_FIFO16bx64 former_csum_fifo (
         .clk            (clk),
         .rst            (areset), 
         .din            (former_csum_din),
         .wr_en          (former_csum_wr_en),
         .rd_en          (csum_rd_en),
         .dout           (former_csum_dout),
         .full           (),
         .empty          (former_csum_empty),
         .data_count     ()
         ); 
  IND_FIFO16bx64 later_csum_fifo (
         .clk            (clk),
         .rst            (areset), 
         .din            ({d_s_checkSum_data_o[7:0],d_s_checkSum_data_o[15:8]}),
         .wr_en          (d_s_checkSum_valid_o),
         .rd_en          (csum_rd_en),
         .dout           (later_csum_dout),
         .full           (),
         .empty          (later_csum_empty),
         .data_count     ()
         ); 
endmodule
