`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/04/09 17:20:23
// Design Name: 
// Module Name: encrypt_compute
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


module encrypt_compute(
input      clk,
input      reset,
input      compute_resq,
input      [63:0] key,
input      [64:0] clr_data,
output     [64:0] encrypt_data,
output     encrypt_data_valid
    );
parameter IV = 16'h1234;

reg  [64:0] clr_data_s1,clr_data_s2,clr_data_s3,clr_data_s4;
reg  [63:0] key_s1,key_s2,key_s3,key_s4;
reg  [15:0] xor_r20,xor_r21,xor_r22,xor_r23;
reg  [15:0] xor_r20_s3,xor_r20_s4,xor_r20_s5;
reg  [15:0] xor_r21_s4,xor_r21_s5;
reg  [15:0] xor_r22_s5;

reg  [0:0]  valid_s1,valid_s2,valid_s3,valid_s4,valid_s5;
reg  [0:0]  last_s1,last_s2,last_s3,last_s4,last_s5;

wire [15:0] xor_r10,xor_r11,xor_r12,xor_r13;
wire [31:0] lp_left_r0,lp_left_r1,lp_left_r2,lp_left_r3;

reg [3:0]  one_cnt0_s1,one_cnt1_s1,one_cnt2_s1,one_cnt3_s1;
reg [3:0]  one_cnt0_s2,one_cnt1_s2,one_cnt2_s2,one_cnt3_s2;
reg [3:0]  one_cnt0_s3,one_cnt1_s3,one_cnt2_s3,one_cnt3_s3;
reg [3:0]  one_cnt0_s4,one_cnt1_s4,one_cnt2_s4,one_cnt3_s4;

assign xor_r10 = IV ^ clr_data_s1[15:0];
assign xor_r11 = xor_r20 ^ clr_data_s2[31:16];
assign xor_r12 = xor_r21 ^ clr_data_s3[47:32];
assign xor_r13 = xor_r22 ^ clr_data_s4[63:48];

assign lp_left_r0 = {16'h0000,xor_r10} << one_cnt0_s1;
assign lp_left_r1 = {16'h0000,xor_r11} << one_cnt1_s2;
assign lp_left_r2 = {16'h0000,xor_r12} << one_cnt2_s3;
assign lp_left_r3 = {16'h0000,xor_r13} << one_cnt3_s4;

always @(posedge clk) begin
   xor_r20 <= lp_left_r0[31:16] ^lp_left_r0[15:0] ^ key_s1[15:0];
   xor_r21 <= lp_left_r1[31:16] ^lp_left_r1[15:0] ^ key_s2[31:16];
   xor_r22 <= lp_left_r2[31:16] ^lp_left_r2[15:0] ^ key_s3[47:32];
   xor_r23 <= lp_left_r3[31:16] ^lp_left_r3[15:0] ^ key_s4[63:48];
end
always @(posedge clk) begin
   one_cnt0_s1 <= key[0]  + key[1]  + key[2]  + key[3]  + key[4]  + key[5]  + key[6]  + key[7] +
                  key[8]  + key[9]  + key[10] + key[11] + key[12] + key[13] + key[14] + key[15];
   one_cnt1_s1 <= key[16] + key[17] + key[18] + key[19] + key[20] + key[21] + key[22] + key[23] +
                  key[24] + key[25] + key[26] + key[27] + key[28] + key[29] + key[30] + key[31];
   one_cnt2_s1 <= key[32] + key[33] + key[34] + key[35] + key[36] + key[37] + key[38] + key[39] +
                  key[40] + key[41] + key[42] + key[43] + key[44] + key[45] + key[46] + key[47];
   one_cnt3_s1 <= key[48] + key[49] + key[50] + key[51] + key[52] + key[53] + key[54] + key[55] + 
                  key[56] + key[57] + key[58] + key[59] + key[60] + key[61] + key[62] + key[63];
   one_cnt0_s2 <= one_cnt0_s1;
   one_cnt0_s3 <= one_cnt0_s2;
   one_cnt0_s4 <= one_cnt0_s3;
   one_cnt1_s2 <= one_cnt1_s1;
   one_cnt1_s3 <= one_cnt1_s2;
   one_cnt1_s4 <= one_cnt1_s3;
   one_cnt2_s2 <= one_cnt2_s1;
   one_cnt2_s3 <= one_cnt2_s2;
   one_cnt2_s4 <= one_cnt2_s3;
   one_cnt3_s2 <= one_cnt3_s1;
   one_cnt3_s3 <= one_cnt3_s2;
   one_cnt3_s4 <= one_cnt3_s3;
   clr_data_s1 <= clr_data;
   clr_data_s2 <= clr_data_s1;
   clr_data_s3 <= clr_data_s2;
   clr_data_s4 <= clr_data_s3;
   key_s1      <= key;
   key_s2      <= key_s1;
   key_s3      <= key_s2;
   key_s4      <= key_s3;
   xor_r20_s3  <= xor_r20;
   xor_r20_s4  <= xor_r20_s3;
   xor_r20_s5  <= xor_r20_s4;
   xor_r21_s4  <= xor_r21;
   xor_r21_s5  <= xor_r21_s4;
   xor_r22_s5  <= xor_r22;
end


assign encrypt_data       = {last_s5,xor_r23,xor_r22_s5,xor_r21_s5,xor_r20_s5};
assign encrypt_data_valid = valid_s5;

always @(posedge clk) begin
   if (reset) begin
      valid_s1 <= 0;
      last_s1 <= 0;
   end
   else begin
      valid_s1 <= compute_resq;
      valid_s2 <= valid_s1;
      valid_s3 <= valid_s2;
      valid_s4 <= valid_s3;
      valid_s5 <= valid_s4;
      last_s1  <= clr_data[64];
      last_s2  <= last_s1;
      last_s3  <= last_s2;
      last_s4  <= last_s3;
      last_s5  <= last_s4;
   end
end


endmodule

