`timescale 1ps/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/03/11 14:03:00
// Design Name: 
// Module Name: decode
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


module decode#(
parameter  AXI_STM_DATA_WIDTH      = 32,
    
parameter C_AXI_ID_WIDTH           = 4, // The AXI id width used for read and write
                                         // This is an integer between 1-16
parameter C_AXI_ADDR_WIDTH         = 32, // This is AXI address width for all 
                                          // SI and MI slots
parameter C_AXI_DATA_WIDTH         = 512 // Width of the AXI write and read data


)
(
input             aclk,
input             areset,
output            d_s_axi_ready,
input      [63:0] d_s_axi_data,
input             d_s_axi_last,
input             d_s_axi_valid,
output reg        d_m_axi_valid,
output reg [63:0] d_m_axi_data,
output reg        d_m_axi_last,
input             d_m_axi_ready,     
// AXI read address channel signals

output reg [C_AXI_ADDR_WIDTH-1:0]       d_axi_raddr,      // Read address
output reg                              d_axi_rvalid,     // Read address valid

// AXI read data channel signals   
input                               d_axi_rd_rvalid,  // Read reponse valid
input  [C_AXI_DATA_WIDTH-1:0]       d_axi_rd_data,    // Read data
input                               d_axi_rd_last   // Read last


    );
wire  [64:0]  din;
wire          wr_en;
wire          rd_en;
wire [64:0]  dout;
wire         full;
wire         empty;
wire [9:0]   data_count;

reg          delay_fifo;
reg          e_i_data_flag,e_i_data_flag_r1,e_i_data_flag_r2,e_i_data_flag_r3;
reg [127:0]  key_addr_in_r;
integer       i_data_cnt;
reg [64:0]    i_data_r;
reg [64:0]    encrypt_data_r,encrypt_data_r1;
reg [64:0]    clr_data_r;
wire [64:0]   clr_data;
wire [63:0]    key;
reg [63:0]    key_r;
wire [19:0]   key_addr;
wire          addr_valid;
reg  [19:0]   key_addr_r;
reg           key_addr_resq;
wire         clr_data_valid;
reg           key_addr_resq_flag;
reg           fifo_read_flag;
reg           d_axi_rvalid_flag;
reg           decode_flag;
reg           decode_complete;
reg           d_m_axi_valid_flag;
reg           compute_data_flag;
reg           d_m_axi_last_flag;
reg           i_data_cnt_flag;
reg           compute_resq;
reg           compute_resq_flag;
reg           paket_end_flag;
integer       head_cnt;
reg           h_wr_en;
wire          h_rd_en;
reg [64:0]    h_din;
wire [64:0]   h_dout;
wire          h_empty,h_full;     
reg           h_end_flag;   
reg           h_fifo_read_flag;
reg           k_rd_en;
wire          k_empty,k_full;
reg           k_fifo_read_flag;
reg   [4:0]       end_flag_cnt;
reg out_wr_en;
wire out_rd_en;
wire [64:0] out_clr_data;
wire out_full,out_empty;
reg out_fifo_read_flag;
integer       in_cnt;
integer       out_cnt;
reg [15:0] d_p_len;
reg [15:0] d_f_p_len;
assign d_s_axi_ready = ~full;
assign rd_en =(~empty)&&(!(((i_data_cnt > 9) && (~decode_flag)&&(d_f_p_len > 100)) | (out_full) |(dout[64]&&(paket_end_flag))));
assign h_rd_en = (~h_empty)&&(!(h_dout[64]&&h_end_flag));
assign out_rd_en = (~out_empty)&&(d_m_axi_ready);
assign wr_en = d_s_axi_valid&&d_s_axi_ready;
assign din = {d_s_axi_last,d_s_axi_data};
always @(posedge aclk) begin
    if(areset) begin
       
        d_m_axi_valid        <= 0;
        d_m_axi_data         <= 0;
        d_m_axi_last         <= 0;
       // din                  <= 0;
       // wr_en                <= 0;
      //  rd_en                <= 0;
        delay_fifo           <= 1;
        e_i_data_flag        <= 1'b0;
        e_i_data_flag_r1     <= 1'b0;
        e_i_data_flag_r2     <= 1'b0;
        e_i_data_flag_r3     <= 1'b0;
        i_data_cnt           <= 0;
        key_addr_resq        <= 0;
        key_addr_resq_flag   <= 0;
        
        d_axi_raddr          <= 0;
        d_axi_rvalid         <= 0;  
        fifo_read_flag       <= 0;
        d_axi_rvalid_flag    <= 0;
        decode_flag          <= 0;
        decode_complete      <= 0;
        d_m_axi_valid_flag   <= 0;
        compute_data_flag    <= 0;
        d_m_axi_last_flag    <= 0;
        i_data_cnt_flag      <= 0;
        compute_resq_flag    <= 0;
        compute_resq         <= 0;
        paket_end_flag       <= 1;
        head_cnt             <= 0;
        h_wr_en              <= 0;
      //  h_rd_en              <= 0;
        h_din                <= 0;    
        h_end_flag           <= 1;
        h_fifo_read_flag     <= 0;
        k_rd_en              <= 0;
        k_fifo_read_flag     <= 0;
        in_cnt               <= 0;
        out_cnt              <= 0;
        end_flag_cnt         <= 0;
        out_fifo_read_flag   <= 0;
        out_wr_en <= 0;
    end
    else begin
    
/*���� ready �ź�  */
        
            
/*���ܼ������д��FIFO*/        
      /*  if(d_s_axi_valid) begin
           // if(~full) begin
                if(d_s_axi_last) 
                    din <= {1'b1,d_s_axi_data};
                else  
                    din <= {1'b0,d_s_axi_data};   
                    
                wr_en <= 1'b1;
          //  end
        end
        else 
            wr_en <= 1'b0;  */
            
        if(d_s_axi_valid&&d_s_axi_ready) begin
            if(d_s_axi_last)
                head_cnt <= 0;
            else 
                head_cnt <= head_cnt + 1;
					 
            if(head_cnt == 2) 
					d_p_len <= {d_s_axi_data[7:0],d_s_axi_data[15:8]};
					//d_p_len <= d_s_axi_data[15:0];
				
				if(d_p_len > 100) begin
					if(head_cnt == 9) begin
						h_din <= {1'b0,d_s_axi_data};
						h_wr_en <= 1;
					end
					else if(head_cnt == 10) begin
						h_din <= {1'b1,d_s_axi_data};   
						h_wr_en <= 1'b1;    
					end
					else 
						h_wr_en <= 0;
				end
        end
        else 
            h_wr_en <= 1'b0; 
            
         if(h_rd_en) 
               h_fifo_read_flag <= 1;   
         else
               h_fifo_read_flag <= 0;        
          
          if(h_fifo_read_flag) begin
                h_end_flag <= 1;
               if(h_dout[64]) begin
                   key_addr_in_r[127:64] <= h_dout[63:0];
                   key_addr_resq_flag <= 1;
               end
               else
                   key_addr_in_r[63:0] <= h_dout[63:0];
          end
/*��FIFO�����������*/    

            
         if(rd_en) 
            fifo_read_flag <= 1;   
         else
            fifo_read_flag <= 0;
            
         if(fifo_read_flag) begin
            i_data_r <= dout;
                  
            if(dout[64]) begin
                i_data_cnt <= 0;
                e_i_data_flag <= 1'b1; 
            end
            else begin
                i_data_cnt <= i_data_cnt + 1;   //�ж��Ƿ���ĳ��������һ��64bit���
                e_i_data_flag <= 1'b0;
            end 
				if(i_data_cnt == 2)
					d_f_p_len <= {dout[7:0],dout[15:8]};
					//d_f_p_len <= dout[15:0];
					
				if(i_data_cnt == 1)
                paket_end_flag <= 1;	
				
            if(i_data_cnt < 11) begin 
                clr_data_r <= dout[64:0];
					 i_data_cnt_flag <= 0;
            end
				else if(d_f_p_len < 100) begin
					 clr_data_r <= dout[64:0];
					 i_data_cnt_flag <= 0;
				end
            else begin
                encrypt_data_r <= dout[64:0];
                i_data_cnt_flag <= 1;
             end   
         end   
         else begin
            i_data_cnt_flag <= 0;
         end
            
         
/*������ݴ���*/

 /*����key��ַ*/       
        if(key_addr_resq_flag) begin
            key_addr_resq <= 1'b1;
            key_addr_resq_flag <= 1'b0;
        end
        else 
            key_addr_resq <= 1'b0;
        
        if(addr_valid) begin
            key_addr_r <= key_addr;
            d_axi_rvalid_flag <= 1'b1;
            h_end_flag <= 0;
        end    
/*���ڴ��ж���key*/         
       
         if(d_axi_rvalid_flag) begin
            d_axi_rvalid <= 1'b1;
            d_axi_rvalid_flag <= 1'b0;
            d_axi_raddr <= {12'b000000000000,key_addr_r[13:0],6'b000000};
         end 
         else 
            d_axi_rvalid <= 1'b0;     
                             
          
          if((~k_empty)&&(~decode_flag)&&delay_fifo&&(i_data_cnt > 8)&&(d_f_p_len > 100)) begin
               k_rd_en <= 1;
               delay_fifo <= 0;
           end 
           else
                k_rd_en <= 0;  
           if(k_rd_en)
               k_fifo_read_flag <= 1;
            else 
                k_fifo_read_flag <= 0;  
           if(k_fifo_read_flag) begin
               key_r <= key;
               decode_flag <= 1;
               delay_fifo <= 1;
           end
               
          
                                
 /*�������*/            
          if(decode_flag&&(((i_data_cnt == 0)|(i_data_cnt - 1)>10)&&(d_f_p_len > 100))&&i_data_cnt_flag) begin
             compute_resq <= 1;
             encrypt_data_r1 <= encrypt_data_r;
             e_i_data_flag_r1 <= e_i_data_flag;
          end
          else 
            compute_resq <= 0;
            
          if(clr_data_valid) begin
             clr_data_r <= clr_data;  
          end
         
        if((fifo_read_flag&&((i_data_cnt < 11)|(d_f_p_len < 100)))|clr_data_valid)
            out_wr_en <= 1;
         else
            out_wr_en <= 0;
             
/*������*/    
       if(d_m_axi_ready) begin 
        if(out_rd_en) 
              out_fifo_read_flag <= 1;   
        else
              out_fifo_read_flag <= 0;         
               
         if(out_fifo_read_flag) begin
            d_m_axi_data <= out_clr_data[63:0];
            d_m_axi_valid <= 1'b1;
                if(out_clr_data[64]) begin
                    d_m_axi_last <= 1;
                    decode_flag <= 0;
                end
           end  
           else
             d_m_axi_valid <= 1'b0;
        end   
        
          if(d_m_axi_last&&d_m_axi_valid&&d_m_axi_ready) begin
            d_m_axi_last <= 0; 
            paket_end_flag <= 0;
            end_flag_cnt <= 0;
            end   
            
            if(d_m_axi_last)
                out_cnt <= out_cnt + 1;
            if(d_s_axi_last)
                in_cnt <= in_cnt + 1;
           /*  if(d_m_axi_valid_flag) begin
                d_m_axi_valid <= 1;
                if(d_m_axi_ready) begin
                    d_m_axi_valid_flag <= 0;
                    if(e_i_data_flag) begin
                        d_m_axi_last <= 1'b1;                                                     //һ�ֽ��� 
                        e_i_data_flag <= 1'b0;
                        decode_flag <= 1'b0;
                        d_m_axi_last_flag <= 1;
                    end
                    delay_fifo <= 1'b1;
                end
             end
             else
                d_m_axi_valid <= 0;
                
             if(d_m_axi_last_flag) begin
                 d_m_axi_last <= 1'b0;
                 d_m_axi_last_flag <= 0;
             end     */    
                      
      end
 end
 fifo_cryp d_fifo_data(
     .clk            (aclk),
     .rst            (areset), 
     .din            (din),
     .wr_en          (wr_en),
     .rd_en          (rd_en),
     .dout           (dout),
     .full           (full),
     .empty          (empty),
     .data_count     (data_count)
     );
 fifo_cryp h_fifo_data(
     .clk            (aclk),
     .rst            (areset), 
     .din            (h_din),
     .wr_en          (h_wr_en),
     .rd_en          (h_rd_en),
     .dout           (h_dout),
     .full           (h_full),
     .empty          (h_empty),
     .data_count     ()
         );
wire   [64:0]         k_fifo_data_dout;
assign key = k_fifo_data_dout[63:0];
 fifo_cryp k_fifo_data(
     .clk            (aclk),
     .rst            (areset), 
     .din            ({1'b0,d_axi_rd_data[63:0]}),
     .wr_en          (d_axi_rd_rvalid),
     .rd_en          (k_rd_en),
     .dout           (k_fifo_data_dout),
     .full           (k_full),
     .empty          (k_empty),
     .data_count     ()
                 );
 fifo_cryp out_fifo_data(
     .clk            (aclk),
     .rst            (areset), 
     .din            (clr_data_r),
     .wr_en          (out_wr_en),
     .rd_en          (out_rd_en),
     .dout           (out_clr_data),
     .full           (out_full),
     .empty          (out_empty),
     .data_count     ()
        );   
 key_addr d_keyaddr(
     .clk            (aclk),
     .reset          (areset),
     .key_addr_resq  (key_addr_resq),
     .key_addr_in    (key_addr_in_r),
     .key_addr       (key_addr),
     .addr_valid     (addr_valid)
 ); 
 decode_compute decode_compute1(
 .clk                (aclk),
 .reset              (areset),
 .compute_resq       (compute_resq),
 .encrypt_data       (encrypt_data_r1),
 .key                (key_r),
 .clr_data           (clr_data),
 .clr_data_valid     (clr_data_valid)
     );
endmodule
