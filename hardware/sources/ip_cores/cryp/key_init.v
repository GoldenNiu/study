`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/03/19 21:18:42
// Design Name: 
// Module Name: key_init
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


module key_init #(
parameter  AXI_STM_DATA_WIDTH      = 32,
    
parameter C_AXI_ID_WIDTH           = 4, // The AXI id width used for read and write
                                         // This is an integer between 1-16
parameter C_AXI_ADDR_WIDTH         = 32, // This is AXI address width for all 
                                          // SI and MI slots
parameter C_AXI_DATA_WIDTH         = 512 // Width of the AXI write and read data


)
(
input                               aclk,
input                               aresetn,
input                               init_cmptd, // Initialization completed

// AXI write address channel signals
input                               axi_wready, // Indicates slave is ready to accept a 
output reg [C_AXI_ID_WIDTH-1:0]         axi_wid,    // Write ID
output reg [C_AXI_ADDR_WIDTH-1:0]       axi_waddr,  // Write address
output reg [7:0]                        axi_wlen,   // Write Burst Length
output reg [2:0]                        axi_wsize,  // Write Burst size
output reg [1:0]                        axi_wburst, // Write Burst type
output reg [0:0]                        axi_wlock,  // Write lock type
output reg [3:0]                        axi_wcache, // Write Cache type
output reg [2:0]                        axi_wprot,  // Write Protection type
output reg                             axi_wvalid, // Write address valid

// AXI write data channel signals
input                               axi_wd_wready,  // Write data ready
output reg [C_AXI_ID_WIDTH-1:0]         axi_wd_wid,     // Write ID tag
output reg [C_AXI_DATA_WIDTH-1:0]       axi_wd_data,    // Write data
output reg [C_AXI_DATA_WIDTH/8-1:0]     axi_wd_strb,    // Write strobes
output reg                             axi_wd_last,    // Last write transaction   
output reg                             axi_wd_valid,   // Write valid

// AXI write response channel signals
input  [C_AXI_ID_WIDTH-1:0]         axi_wd_bid,     // Response ID
input  [1:0]                        axi_wd_bresp,   // Write response
input                               axi_wd_bvalid,  // Write reponse valid
output reg                          axi_wd_bready,  // Response ready

output reg [C_AXI_ADDR_WIDTH-1:0]       key_axi_raddr,      // Read address
output reg                              key_axi_rvalid,     // Read address valid

// AXI read data channel signals   
input                               key_axi_rd_rvalid,  // Read reponse valid
input  [C_AXI_DATA_WIDTH-1:0]       key_axi_rd_data,    // Read data
input                               key_axi_rd_last,    // Read last

(* mark_debug = "True" *) output reg                          write_key_err,
output reg complete
    );
    reg axi_wvalid_flag;
    reg axi_wready_flag;
    reg axi_wd_last_flag;
    reg key_axi_rvalid_flag;
    reg axi_rd_rready_flag;
    integer axi_wdata_cnt;
    parameter write = 2'b00;
    parameter read  = 2'b01;
    parameter key_complete = 2'b10;
    parameter key_err = 2'b11;
    reg [1:0] current_state;  
    reg read_flag;
    reg rd_judgment;
    reg [63:0] key_r1;
    wire [63:0] out_key_data;
    wire key_out_full;
    wire key_out_empty;
    parameter waddr_max = 20'hfffff;
    //parameter waddr_max = 20'hffff;
parameter prbs_seed = 64'h0000000000000002;  
reg [63:0]      prbs;  
reg [64:1]      lfsr_q;
always @(posedge aclk) begin
     if(~aresetn) begin
        complete <= 0;
        lfsr_q <= {prbs_seed + 64'h5555555555555555};
        prbs <= prbs_seed;
        axi_wid       <= 0;
        axi_waddr     <= 0;
        axi_wlen      <= 255;
        axi_wsize     <= 3'b110;
        axi_wburst    <= 2'b01;
        axi_wlock     <= 0;
        axi_wcache    <= 0;
        axi_wprot     <= 0;
        axi_wvalid    <= 0;

        axi_wd_wid    <= 0;
        axi_wd_data   <= 15;
        axi_wd_strb   <= 0;
        axi_wd_last   <= 0;   
        axi_wd_valid  <= 0;
        axi_wd_bready <= 0;
        axi_wready_flag <=1;
        axi_wvalid_flag <= 1;
        axi_wd_last_flag <= 1;
        key_r1 <= 0;
        key_axi_rvalid <= 0;
        key_axi_raddr <= 0;
        key_axi_rvalid_flag <= 0;
        axi_rd_rready_flag <= 1;
        axi_wdata_cnt <= 0;
        current_state <= 0;
        read_flag <= 0;
        rd_judgment <= 1;
         write_key_err <= 0;
    end
    else begin
        if(init_cmptd) begin
            axi_wlen <= 255;
         //   axi_rlen <= 255;
            case(current_state)
                write:
                begin
                    if(axi_wready_flag&&axi_wready) begin
                        axi_wvalid <= 1'b1;
                        axi_wready_flag <= 1'b0;
                    end 
                    else
                        axi_wvalid <= 1'b0;
                        
                    if(axi_wd_wready) begin
                        if(axi_wdata_cnt < (axi_wlen + 1)) begin
                            axi_wd_valid <= 1'b1;
                            axi_wd_strb <=64'hffffffffffffffff;
                            lfsr_q[32:9] <= lfsr_q[31:8];
                            lfsr_q[8]    <= lfsr_q[32] ^ lfsr_q[7];
                            lfsr_q[7]    <= lfsr_q[32] ^ lfsr_q[6];
                            lfsr_q[6:4]  <= lfsr_q[5:3];
                
                            lfsr_q[3]    <= lfsr_q[32] ^ lfsr_q[2];
                            lfsr_q[2]    <= lfsr_q[1] ;
                            lfsr_q[1]    <= lfsr_q[32];
                  
                            lfsr_q[35]    <= lfsr_q[64] ^ lfsr_q[34];
                            lfsr_q[34]    <= lfsr_q[33] ;
                            lfsr_q[33]    <= lfsr_q[64];
                
                            lfsr_q[64:41] <= lfsr_q[63:40];
                            lfsr_q[40]    <= lfsr_q[64] ^ lfsr_q[39];
                            lfsr_q[39]    <= lfsr_q[64] ^ lfsr_q[38];
                            lfsr_q[38:36] <= lfsr_q[37:35];
                            axi_wd_data <= lfsr_q;
                        end
                        else begin
                            axi_wd_valid <= 1'b0;
                            axi_wd_strb <=0;
                        end  
                        axi_wdata_cnt <= axi_wdata_cnt + 1;
                         if(axi_wdata_cnt == axi_wlen)
                            axi_wd_last <= 1'b1;
                         else
                            axi_wd_last <= 1'b0;
                     end  
                        
                     if(axi_wdata_cnt > axi_wlen) 
                        axi_wd_bready <= 1'b1;
                             
                     if(axi_wd_bvalid) begin
                        
                        axi_wd_bready <= 1'b0;
                        axi_wready_flag <= 1'b1;
                        axi_wdata_cnt <= 0;
                        axi_wid <= axi_wid + 1;
                        axi_wd_wid <= axi_wd_wid + 1; 
                        axi_waddr <= axi_waddr + 16384;
                        key_axi_rvalid_flag <= 1;
                        current_state <= read;
                      end                     
                end
                read:
                begin    

                     if(key_axi_rvalid_flag) begin
                        key_axi_rvalid <= 1'b1;
                        key_axi_rvalid_flag <= 1'b0;
                     end 
                     else 
                        key_axi_rvalid <= 1'b0;    
                        
                    if(key_axi_rd_rvalid)    
                        key_r1 <= key_axi_rd_data[63:0];
                        
                    if(key_r1!=out_key_data) begin
                        write_key_err <= 1;
                        current_state <= key_err;
                    end
                    
                     if(key_axi_rd_rvalid&&key_axi_rd_last) begin     
                        key_axi_raddr <= key_axi_raddr + 16384;    
                        if(axi_waddr > waddr_max) begin
                            current_state <= key_complete;
                            complete <= 1'b1;
                            axi_wready_flag <= 1'b0;
                        end       
                        else
                            current_state <= write;        
                     end  
               end  
               key_complete:begin
                    current_state <= key_complete;
               end
               key_err:begin
                    current_state <= key_err;
               end
            endcase
        end     
    end
end
wire   [64:0]         key_fifo_dout;
assign out_key_data = key_fifo_dout[63:0];

 fifo_cryp key_fifo(
    .clk            (aclk),
    .rst            (~aresetn), 
    .din            ({1'b0,axi_wd_data[63:0]}),
    .wr_en          (axi_wd_valid&&axi_wd_wready),
    .rd_en          (key_axi_rd_rvalid),
    .dout           (key_fifo_dout),
    .full           (key_out_full),
    .empty          (key_out_empty),
    .data_count     ()
    ); 
endmodule
