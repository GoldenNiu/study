`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/04 17:48:53
// Design Name: 
// Module Name: checksum_change
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


module checksum_change#(
   parameter DATA_WIDTH = 73
) (
   input  [0:0]         rst,
   input  [0:0]         clk,
   input    [15:0]      csum_data,
   input                csum_valid,
   input  [DATA_WIDTH-1:0]      input_din,
   input  [0:0]         input_valid,
   output [0:0]         input_rdy,
   output [DATA_WIDTH-1:0]         output_dout,
   output [0:0]         output_valid,
   input  [0:0]         output_rdy
);

parameter      TRAN_DATA = 0;
parameter      STOP      = 1;

reg    [DATA_WIDTH-1:0]         input_din_r;
reg    [DATA_WIDTH-1:0]         input_din_r2;
reg    [0:0]         reg_notempty;
reg    [0:0]         reg2_notempty;
wire   [0:0]         input_ok;
wire   [0:0]         output_ok;

assign input_ok  = input_valid && input_rdy;
assign output_ok = output_valid && output_rdy;

reg [3:0] state;


/*csum*/

reg [7:0] e_data_cnt;
reg [15:0] csum_r;
reg csum_flag;
reg csum_rd_en_flag;
wire csum_rd_en;
wire csum_empty;
wire [15:0] csum_dout;
assign csum_rd_en = (~csum_empty) && csum_flag;
 always @(posedge clk) begin
   if(rst) begin
       e_data_cnt <= 0;
       csum_r <= 0;
       csum_flag <= 1;
       csum_rd_en_flag <= 0;
   end
   else begin
      /* e_m_axi_valid_r <= e_m_axi_valid_i;
       e_m_axi_data_r <= (e_data_cnt == 6) ? {e_m_axi_data_i[63:32],csum_r[15:0],e_m_axi_data_i[15:0]} : e_m_axi_data_i;
       e_m_axi_tkeep_r <= e_m_axi_tkeep_i;
       e_m_axi_last_r <= e_m_axi_last_i;*/
       if(input_valid && input_rdy && input_din[0])
           e_data_cnt <= 0;
       else if(input_valid && input_rdy)
           e_data_cnt <= e_data_cnt + 1;
           
       if(csum_rd_en)
           csum_flag <= 0;
       else if(output_valid && output_rdy && output_dout[0])
           csum_flag <= 1;
        
       if(csum_rd_en)
           csum_rd_en_flag <= 1;
       else
           csum_rd_en_flag <= 0;
       
       if(csum_rd_en_flag) 
           csum_r <= csum_dout;
   end
end

always @ (posedge clk) begin
   if (rst) begin
      state <= TRAN_DATA;
   end
   else begin
      case (state)
         TRAN_DATA:begin
            if (reg_notempty && ~output_rdy)begin
               state <= STOP;
            end
            else begin
               state <= TRAN_DATA;
            end
         end
         STOP:begin
            if (~output_rdy) begin
               state <= STOP;
            end
            else begin
               state <= TRAN_DATA;
            end
         end
      endcase
   end
end

always @ (posedge clk) begin
   if (rst) begin
      input_din_r <= 'b0;
   end
   else if (input_ok) begin
    input_din_r <= (e_data_cnt == 6) ? {input_din[72:41],csum_r[15:0],input_din[24:0]} : input_din;
     // input_din_r <= input_din;
   end
end

always @ (posedge clk) begin
   if (rst) begin
      input_din_r2 <= 'b0;
   end
   else if ((state == TRAN_DATA) && (reg_notempty && ~output_rdy))begin
      input_din_r2 <= input_din_r;
   end
end

always @ (posedge clk) begin
   if (rst) begin
      reg_notempty <= 1'b0;
   end
   else if ((state == TRAN_DATA) && (reg_notempty && ~output_rdy && ~input_ok)) begin
      reg_notempty <= 1'b0;
   end
   else if ((state == TRAN_DATA) && (input_ok && output_ok)) begin
      reg_notempty <= 1'b1;
   end
   else if ((state == TRAN_DATA) && (output_ok)) begin
      reg_notempty <= 1'b0;
   end
   else if (input_ok) begin
      reg_notempty <= 1'b1;
   end
end

always @ (posedge clk) begin
   if (rst) begin
      reg2_notempty <= 1'b0;
   end
   else if ((state == TRAN_DATA) && (reg_notempty && ~output_rdy)) begin
      reg2_notempty <= 1'b1;
   end
   else if ((state == STOP) && output_ok) begin
      reg2_notempty <= 1'b0;
   end
end

assign output_dout = (state == TRAN_DATA) ? input_din_r : input_din_r2;
assign output_valid = reg_notempty || reg2_notempty;
assign input_rdy = (state == TRAN_DATA);

 IND_FIFO16bx64 csum_fifo1 (
    .clk            (clk),
    .rst            (rst), 
    .din            ({csum_data[7:0],csum_data[15:8]}),
    .wr_en          (csum_valid),
    .rd_en          (csum_rd_en),
    .dout           (csum_dout),
    .full           (),
    .empty          (csum_empty),
    .data_count     ()
    ); 
endmodule
