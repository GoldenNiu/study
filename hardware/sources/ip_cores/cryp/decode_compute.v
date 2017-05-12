`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/04/09 17:19:23
// Design Name: 
// Module Name: decode_compute
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


module decode_compute(
input      clk,
input      reset,
input      compute_resq,
input      [64:0] encrypt_data,
input      [63:0] key,
output     [64:0] clr_data,
output     clr_data_valid
    );
parameter IV = 16'h1234;

reg  [3:0]  one_cnt0_s1,one_cnt1_s1,one_cnt2_s1,one_cnt3_s1;
reg  [15:0] xor_r10_s1,xor_r11_s1,xor_r12_s1,xor_r13_s1;
wire [31:0] lp_right_r0,lp_right_r1,lp_right_r2,lp_right_r3;
reg  [15:0] xor_r20_s2,xor_r21_s2,xor_r22_s2,xor_r23_s2;
reg  [64:0] encrypt_data_s1,encrypt_data_s2;
reg  [0:0]  valid_s1,valid_s2;

always @(posedge clk) begin
   xor_r10_s1 <= encrypt_data[15:0]  ^ key[15:0];
   xor_r11_s1 <= encrypt_data[31:16] ^ key[31:16];
   xor_r12_s1 <= encrypt_data[47:32] ^ key[47:32];
   xor_r13_s1 <= encrypt_data[63:48] ^ key[63:48];
end

assign lp_right_r0 = {xor_r10_s1,16'h0000} >> one_cnt0_s1;
assign lp_right_r1 = {xor_r11_s1,16'h0000} >> one_cnt1_s1;
assign lp_right_r2 = {xor_r12_s1,16'h0000} >> one_cnt2_s1;
assign lp_right_r3 = {xor_r13_s1,16'h0000} >> one_cnt3_s1;

always @(posedge clk) begin
   one_cnt0_s1 <= key[0]  + key[1]  + key[2]  + key[3]  + key[4]  + key[5]  + key[6]  + key[7] +
                  key[8]  + key[9]  + key[10] + key[11] + key[12] + key[13] + key[14] + key[15];
   one_cnt1_s1 <= key[16] + key[17] + key[18] + key[19] + key[20] + key[21] + key[22] + key[23] +
                  key[24] + key[25] + key[26] + key[27] + key[28] + key[29] + key[30] + key[31];
   one_cnt2_s1 <= key[32] + key[33] + key[34] + key[35] + key[36] + key[37] + key[38] + key[39] +
                  key[40] + key[41] + key[42] + key[43] + key[44] + key[45] + key[46] + key[47];
   one_cnt3_s1 <= key[48] + key[49] + key[50] + key[51] + key[52] + key[53] + key[54] + key[55] + 
                  key[56] + key[57] + key[58] + key[59] + key[60] + key[61] + key[62] + key[63];
   xor_r20_s2  <= lp_right_r0[31:16] ^ lp_right_r0[15:0] ^ IV;
   xor_r21_s2  <= lp_right_r1[31:16] ^ lp_right_r1[15:0] ^ encrypt_data_s1[15:0];
   xor_r22_s2  <= lp_right_r2[31:16] ^ lp_right_r2[15:0] ^ encrypt_data_s1[31:16];
   xor_r23_s2  <= lp_right_r3[31:16] ^ lp_right_r3[15:0] ^ encrypt_data_s1[48:32];
end

assign clr_data = {encrypt_data_s2[64],xor_r23_s2,xor_r22_s2,xor_r21_s2,xor_r20_s2};
assign clr_data_valid = valid_s2;

always @(posedge clk) begin
   if(reset) begin
      valid_s1 <= 0;
   end
   else begin
      valid_s1 <= compute_resq;
      valid_s2 <= valid_s1;
      encrypt_data_s1 <= encrypt_data;
      encrypt_data_s2 <= encrypt_data_s1;
   end
end

endmodule

