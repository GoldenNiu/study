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


module encrypt#(
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
output            e_s_axi_ready,
input      [63:0] e_s_axi_data,
input             e_s_axi_last,
input             e_s_axi_valid,
output            e_m_axi_valid,
output     [63:0] e_m_axi_data,
output            e_m_axi_last,
input             e_m_axi_ready,     
// AXI read address channel signals
output reg [C_AXI_ADDR_WIDTH-1:0]       e_axi_raddr,      // Read address
output reg                              e_axi_rvalid,     // Read address valid

// AXI read data channel signals   
input                               e_axi_rd_rvalid,  // Read reponse valid
input  [C_AXI_DATA_WIDTH-1:0]       e_axi_rd_data,    // Read data
input                               e_axi_rd_last    // Read last

    );
wire  [64:0]  e_din;
wire          e_wr_en;
wire          e_rd_en;
wire [64:0]  e_dout;
wire         e_full;
wire         e_empty;
wire [9:0]   e_data_count;

reg          e_delay_fifo;
reg [127:0]  e_key_addr_in_r;
integer       e_i_data_cnt;
reg [64:0]    e_i_data_r;
reg [64:0]    clr_data_r,clr_data_r1;
reg [64:0]    encrypt_data_r;
wire [64:0]   encrypt_data;
wire [63:0]    e_key;
reg [63:0]    e_key_r;
wire [19:0]   e_key_addr;
wire          e_addr_valid;
reg  [19:0]   e_key_addr_r;
reg           e_key_addr_resq;
reg           e_key_addr_resq_flag;
reg           e_fifo_read_flag;
reg           e_axi_rvalid_flag;
reg           encrypt_flag;
reg           encrypt_complete;
reg           e_i_data_cnt_flag;
reg           e_compute_resq;
reg           e_compute_resq_flag;
reg           e_paket_end_flag;
integer       e_head_cnt;
reg           e_h_wr_en;
wire          e_h_rd_en;
reg [64:0]    e_h_din;
wire [64:0]   e_h_dout;
wire          e_h_empty,e_h_full;     
reg           e_h_end_flag;   
reg           e_h_fifo_read_flag;
reg           e_k_rd_en;
wire          e_k_empty,e_k_full;
reg           e_k_fifo_read_flag;
reg [4:0]     e_end_flag_cnt;
reg e_out_wr_en;
wire e_out_rd_en;
wire [64:0] out_encrypt_data;
wire e_out_full,e_out_empty;
reg e_out_fifo_read_flag;
integer       e_in_cnt;
wire         encrypt_data_valid;
integer       e_out_cnt;
reg [15:0] e_p_len;
reg [15:0] e_f_p_len;
reg [1:0] e_m_cnt;
//reg e_m_ready_init;
assign e_s_axi_ready = (~e_full);
assign e_rd_en =(~e_empty)&&(!(((e_i_data_cnt > 9) && (~encrypt_flag)&&(e_f_p_len > 100)) | (e_out_full) |(e_dout[64]&&(e_paket_end_flag))));
assign e_h_rd_en = (~e_h_empty)&&(!(e_h_dout[64]&&e_h_end_flag));
assign e_out_rd_en = (~e_out_empty)&&(e_m_axi_ready|(e_m_cnt == 0));
assign e_wr_en = e_s_axi_valid&&e_s_axi_ready;
assign e_din = {e_s_axi_last,e_s_axi_data};
assign e_m_axi_valid = (e_m_cnt > 0) ? 1:0;
assign e_m_axi_last = out_encrypt_data[64];
assign e_m_axi_data = out_encrypt_data[63:0];
always @(posedge aclk) begin
    if(areset) begin
    //    e_m_axi_valid          <= 0;
  //      e_m_axi_data           <= 0;
  //      e_m_axi_last           <= 0;
       // e_din                  <= 0;
      //  e_wr_en                <= 0;
        e_delay_fifo           <= 1;
        e_i_data_cnt           <= 0;
        e_key_addr_resq        <= 0;
        e_key_addr_resq_flag   <= 0;
        e_axi_rvalid_flag      <= 0;
        e_axi_raddr            <= 0;
        e_axi_rvalid           <= 0;
        e_fifo_read_flag       <= 0;
        encrypt_flag           <= 0;
        encrypt_complete       <= 0;
        e_i_data_cnt_flag      <= 0;
        e_compute_resq_flag    <= 0;
        e_compute_resq         <= 0;
        e_paket_end_flag       <= 1;
        e_head_cnt             <= 0;
        e_h_wr_en              <= 0;
        e_h_din                <= 0;    
        e_h_end_flag           <= 1;
        e_h_fifo_read_flag     <= 0;
        e_k_rd_en              <= 0;
        e_k_fifo_read_flag     <= 0;
        e_in_cnt               <= 0;
        e_out_cnt              <= 0;
        e_end_flag_cnt         <= 0;
        e_out_fifo_read_flag   <= 0;
        e_out_wr_en            <= 0;
        e_m_cnt                <= 0;
 //       e_m_ready_init         <= 1;
    end
    else begin
    
/*���� ready �ź�  */
        
            
/*���ܼ������д��FIFO*/        
       /* if(e_s_axi_valid&&e_s_axi_ready) begin
           // if(~full) begin
                if(e_s_axi_last) begin
                    e_din <= {1'b1,e_s_axi_data};
						//  e_full1 <= 1;
					 end
                else  
                    e_din <= {1'b0,e_s_axi_data};   
                    
                e_wr_en <= 1'b1;
					 
          //  end
        end
        else 
            e_wr_en <= 1'b0;  */
/*��UserIDд��FIFO*/            
        if(e_s_axi_valid&&e_s_axi_ready) begin
            if(e_s_axi_last)
                e_head_cnt <= 0;
            else 
                e_head_cnt <= e_head_cnt + 1;
            if(e_head_cnt == 2) 
					e_p_len <= {e_s_axi_data[7:0],e_s_axi_data[15:8]};
					//e_p_len <= e_s_axi_data[15:0];
				if(e_p_len > 100)	begin
					if(e_head_cnt == 9) begin
						e_h_din <= {1'b0,e_s_axi_data};
						e_h_wr_en <= 1;
					end
					else if(e_head_cnt == 10) begin
						e_h_din <= {1'b1,e_s_axi_data};   
						e_h_wr_en <= 1'b1;    
					end
					else 
						e_h_wr_en <= 0;
				end
        end
        else 
            e_h_wr_en <= 1'b0; 
/*��USerID��FIFO�ж���*/            
         if(e_h_rd_en) 
               e_h_fifo_read_flag <= 1;   
         else
               e_h_fifo_read_flag <= 0;        
          
          if(e_h_fifo_read_flag) begin
                e_h_end_flag <= 1;
               if(e_h_dout[64]) begin
                   e_key_addr_in_r[127:64] <= e_h_dout[63:0];
                   e_key_addr_resq_flag <= 1;
               end
               else
                   e_key_addr_in_r[63:0] <= e_h_dout[63:0];
          end
/*��FIFO������ݰ�*/    
            
         if(e_rd_en) 
            e_fifo_read_flag <= 1;   
         else
            e_fifo_read_flag <= 0;
            
         if(e_fifo_read_flag) begin
            e_i_data_r <= e_dout;
                  
            if(e_dout[64]) begin
                e_i_data_cnt <= 0;
            end
            else begin
                e_i_data_cnt <= e_i_data_cnt + 1;   //�ж��Ƿ���ĳ��������һ��64bit���
            end   
				if(e_i_data_cnt == 2)
					e_f_p_len <= {e_dout[7:0],e_dout[15:8]};
					//e_f_p_len <= e_dout[15:0];
					
				if(e_i_data_cnt == 1)
               e_paket_end_flag <= 1;
				
            if(e_i_data_cnt < 11) begin 
               encrypt_data_r <= e_dout[64:0];
					e_i_data_cnt_flag <= 0;
            end
				else if(e_f_p_len < 100) begin
					encrypt_data_r <= e_dout[64:0];
					e_i_data_cnt_flag <= 0;
				end
				else begin
					clr_data_r <= e_dout[64:0];   
					e_i_data_cnt_flag <= 1;	
				end  
         end				
         else begin
            e_i_data_cnt_flag <= 0;
         end
            

 /*����key��ַ*/       
        if(e_key_addr_resq_flag) begin
            e_key_addr_resq <= 1'b1;
            e_key_addr_resq_flag <= 1'b0;
        end
        else 
            e_key_addr_resq <= 1'b0;
        
        if(e_addr_valid) begin
            e_key_addr_r <= e_key_addr;
            e_axi_rvalid_flag <= 1'b1;
            e_h_end_flag <= 0;
        end    
/*���ڴ��ж���key*/         
       
         if(e_axi_rvalid_flag) begin
            e_axi_rvalid <= 1'b1;
            e_axi_rvalid_flag <= 1'b0;
            e_axi_raddr <= {12'b000000000000,e_key_addr_r[13:0],6'b000000};
         end 
         else 
            e_axi_rvalid <= 1'b0;     
          
          if((~e_k_empty)&&(~encrypt_flag)&&e_delay_fifo&&(e_i_data_cnt > 8)&&(e_f_p_len >100)) begin
               e_k_rd_en <= 1;
               e_delay_fifo <= 0;
           end 
           else
                e_k_rd_en <= 0;  
                
           if(e_k_rd_en)
               e_k_fifo_read_flag <= 1;
            else 
               e_k_fifo_read_flag <= 0;  
                
           if(e_k_fifo_read_flag) begin
               e_key_r <= e_key;
               encrypt_flag <= 1;
               e_delay_fifo <= 1;
           end
               
          
                           
 /*�������*/            
          if(encrypt_flag&&(((e_i_data_cnt == 0)|(e_i_data_cnt - 1)>10)&&(e_f_p_len > 100))&&e_i_data_cnt_flag) begin
             e_compute_resq <= 1;
             clr_data_r1 <= clr_data_r;
          end
          else 
            e_compute_resq <= 0;
            
          if(encrypt_data_valid) begin
             encrypt_data_r <= encrypt_data;   
          end
          
          if((e_fifo_read_flag&&((e_i_data_cnt < 11)|(e_f_p_len < 100)))|encrypt_data_valid)
              e_out_wr_en <= 1;
           else
              e_out_wr_en <= 0;        
            
/*������*/      
       if(e_out_rd_en&&e_m_axi_ready&&(e_m_cnt==0))
           e_m_cnt <= 1;
       else if(e_out_rd_en&&e_m_axi_ready)
           e_m_cnt <= e_m_cnt;
       else if(e_out_rd_en)
           e_m_cnt <= e_m_cnt + 1;
       else if(e_m_axi_ready)
           e_m_cnt <= (e_m_cnt>0) ? (e_m_cnt - 1) : 0;
  /*       if(e_m_axi_ready) begin 
              if(e_out_rd_en) begin
                  e_out_fifo_read_flag <= 1;
 //                 e_m_ready_init <= 0;   
              end
              else
                  e_out_fifo_read_flag <= 0;         
        
              if(e_out_fifo_read_flag) begin
                    e_m_axi_data <= out_encrypt_data[63:0];
                    e_m_axi_valid <= 1'b1;
                   if(out_encrypt_data[64]) begin
                        e_m_axi_last <= 1;
                        encrypt_flag <= 0;
                    end
              end  
              else
                   e_m_axi_valid <= 1'b0;
              
         end  
     */           
     
          if(e_m_axi_last&&e_m_axi_ready&&e_m_axi_valid) begin
            e_paket_end_flag <= 0;
            encrypt_flag <= 0;
            end   
            
            if(e_m_axi_last)
                e_out_cnt <= e_out_cnt + 1;
            if(e_s_axi_last)
                e_in_cnt <= e_in_cnt + 1;                   
      end
 end
 fifo_cryp e_fifo_data(
     .clk            (aclk),
     .rst            (areset), 
     .din            (e_din),
     .wr_en          (e_wr_en),
     .rd_en          (e_rd_en),
     .dout           (e_dout),
     .full           (e_full),
     .empty          (e_empty),
     .data_count     (e_data_count)
     );
 fifo_cryp e_h_fifo_data(
     .clk            (aclk),
     .rst            (areset), 
     .din            (e_h_din),
     .wr_en          (e_h_wr_en),
     .rd_en          (e_h_rd_en),
     .dout           (e_h_dout),
     .full           (e_h_full),
     .empty          (e_h_empty),
     .data_count     ()
         );

wire   [64:0]         e_k_fifo_data_dout;
assign e_key = e_k_fifo_data_dout[63:0];

 fifo_cryp e_k_fifo_data(
     .clk            (aclk),
     .rst            (areset), 
     .din            ({1'b0,e_axi_rd_data[63:0]}),
     .wr_en          (e_axi_rd_rvalid),
     .rd_en          (e_k_rd_en),
     .dout           (e_k_fifo_data_dout),
     .full           (e_k_full),
     .empty          (e_k_empty),
     .data_count     ()
                 );
 fifo_cryp e_out_fifo_data(
     .clk            (aclk),
     .rst            (areset), 
     .din            (encrypt_data_r),
     .wr_en          (e_out_wr_en),
     .rd_en          (e_out_rd_en),
     .dout           (out_encrypt_data),
     .full           (e_out_full),
     .empty          (e_out_empty),
     .data_count     ()
     ); 
 key_addr e_keyaddr(
     .clk            (aclk),
     .reset          (areset),
     .key_addr_resq  (e_key_addr_resq),
     .key_addr_in    (e_key_addr_in_r),
     .key_addr       (e_key_addr),
     .addr_valid     (e_addr_valid)
 ); 
 encrypt_compute encrypt_compute1(
 .clk                (aclk),
 .reset              (areset),
 .compute_resq       (e_compute_resq),
 .key                (e_key_r),
 .clr_data           (clr_data_r1),
 .encrypt_data       (encrypt_data),
 .encrypt_data_valid     (encrypt_data_valid)
     );
endmodule
