`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/02 11:28:57
// Design Name: 
// Module Name: checkSum
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


module checkSum(
input                                   clk,
input                                   areset,
input                                   m_axi_valid,
input      [63:0]                       m_axi_data,
input      [7:0]                        m_axi_tkeep,
input                                   m_axi_last,
input                                   m_axi_ready,
output     [15:0]                       checksum_data,
output reg                              checksum_valid
    );
    
assign checksum_data = checksum_valid ? (~(checksum_r[15:0] + checksum_r[18:16])) : 16'h0000;
reg [18:0] checksum_r;   
reg [7:0]  data_count;
    always @(posedge clk) begin
        if(areset) begin
            checksum_valid <= 0; 
            checksum_r     <= 0;
            data_count   <= 0;
        end
        else begin
            
            if(m_axi_valid && m_axi_ready && m_axi_last) begin
                checksum_valid <= 1'b1;
                data_count   <= 0;
                checksum_r <= {{8{m_axi_tkeep[0]}} & m_axi_data[7:0]   , {8{m_axi_tkeep[1]}} & m_axi_data[15:8]   } + 
                              {{8{m_axi_tkeep[2]}} & m_axi_data[23:16] , {8{m_axi_tkeep[3]}} & m_axi_data[31:24] } + 
                              {{8{m_axi_tkeep[4]}} & m_axi_data[39:32] , {8{m_axi_tkeep[5]}} & m_axi_data[47:40] } + 
                              {{8{m_axi_tkeep[6]}} & m_axi_data[55:48] , {8{m_axi_tkeep[7]}} & m_axi_data[63:56] } + checksum_r[18:16] + checksum_r[15:0];
            end
            else if(m_axi_valid && m_axi_ready)  begin
               if(data_count == 0) begin
                    checksum_r     <= 0;
                    checksum_valid <= 0;
               end
               else  if(data_count == 2)
                    checksum_r <= ({m_axi_data[7:0],m_axi_data[15:8]} - 20) + {8'h00,m_axi_data[63:56]} + checksum_r[18:16] + checksum_r[15:0];
                else if(data_count == 3)
                    checksum_r <= {m_axi_data[55:48],m_axi_data[63:56]} + {m_axi_data[39:32],m_axi_data[47:40]} + {m_axi_data[23:16],m_axi_data[31:24]} + checksum_r[18:16] + checksum_r[15:0]; 
                else if(data_count == 6)
                    checksum_r <= {m_axi_data[7:0],m_axi_data[15:8]}  + {m_axi_data[39:32],m_axi_data[47:40]} + {m_axi_data[55:48],m_axi_data[63:56]} + checksum_r[18:16] + checksum_r[15:0];
                else if(data_count > 3)
                    checksum_r <= {m_axi_data[7:0],m_axi_data[15:8]}  + {m_axi_data[23:16],m_axi_data[31:24]} + {m_axi_data[39:32],m_axi_data[47:40]} + {m_axi_data[55:48],m_axi_data[63:56]} + checksum_r[18:16] + checksum_r[15:0];       
                else 
                    checksum_r <= checksum_r;          
                
                data_count <= data_count + 1;
            end 
            else if(checksum_valid) begin
                checksum_r     <= 0;
                checksum_valid <= 0;
            end
                
        end
    end
endmodule
