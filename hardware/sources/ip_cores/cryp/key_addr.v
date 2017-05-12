`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/03/24 14:20:39
// Design Name: 
// Module Name: key_addr
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


module key_addr(
input              clk,
input              reset,
input              key_addr_resq,
input      [127:0] key_addr_in,
output     [19:0]  key_addr,
output reg         addr_valid
    );
reg compute_flag;
reg [20:0] xor_addr;
reg [127:0] key_addr_in_r1;
reg addr_valid_flag;
assign key_addr = xor_addr;
always @(posedge clk) begin
    if(reset) begin
        key_addr_in_r1 <= 0;
        addr_valid <= 0;
        compute_flag <= 0;
        addr_valid_flag <= 0;
    end
    else begin
        if(key_addr_resq) begin
            key_addr_in_r1 <= key_addr_in;
            compute_flag <= 1'b1;
            addr_valid_flag <= 1'b1;
        end
        if(compute_flag) begin
            
	        xor_addr <= key_addr_in_r1[29:16]^key_addr_in_r1[43:30]^key_addr_in_r1[57:44]^key_addr_in_r1[71:58]^key_addr_in_r1[85:72]^key_addr_in_r1[99:86]^key_addr_in_r1[113:100]^key_addr_in_r1[127:114];
            if(addr_valid_flag) begin
					addr_valid <= 1'b1;
					addr_valid_flag <= 1'b0;
            end
            else begin
					addr_valid <= 1'b0;
					compute_flag <= 1'b0;
            end

        end
		  
    end
end
endmodule

