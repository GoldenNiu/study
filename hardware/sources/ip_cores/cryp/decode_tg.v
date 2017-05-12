`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:35 03/17/2016 
// Design Name: 
// Module Name:    decode_tg 
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

module decode_tg(
input             clk,
input             reset,
input             m_axi_ready,
output reg        m_axi_valid,
output     [63:0] m_axi_data,
output reg        m_axi_last
    );
parameter write = 0;
parameter delay = 1;
reg current_state;
reg [63:0] rdata1;
reg [31:0] rdata2;
reg [5:0]  blen;
integer data_cnt;
reg [4:0] delay_cnt; 
assign m_axi_data = {rdata2,rdata1};
always @(posedge clk) begin
	if(reset) begin
		m_axi_valid <= 0;
		m_axi_last <= 0;
		blen <= 6;
		data_cnt <= 0;
		rdata1 <= 0;
		rdata2 <= 0;
		delay_cnt <= 0;
		current_state <= 0;
		
	end
	else begin
		case(current_state)
			write: 
			begin
				if(m_axi_ready) begin
					
					if(data_cnt < (blen + 1)) begin
					    rdata1 <= rdata1 + 1;
                        m_axi_valid <= 1'b1;
                    end
                    else begin
                        m_axi_valid <= 1'b0;
                        current_state <= delay;
                        delay_cnt <= 0;
                    end
					if(data_cnt == blen) begin
						m_axi_last <= 1'b1;
				   end
				   else begin
						m_axi_last <= 1'b0;
					end
					data_cnt <= data_cnt + 1;
				end
			end
			delay:
			begin
				if(delay_cnt < 8)
					delay_cnt <= delay_cnt + 1;
				else begin
					current_state <= write;
					data_cnt <= 0;
					//blen <= 8+ {$random} % 17;
					blen <= 25;
				end
			end
		endcase
	end
end

endmodule
