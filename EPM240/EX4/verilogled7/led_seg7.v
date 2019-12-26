`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    
// Design Name:    
// Module Name:    
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module led_seg7(
			clk,rst_n,
			sm_cs1_n,sm_cs2_n,sm_db	
		);

input clk;		// 50MHz
input rst_n;	// ��λ�źţ�����Ч

output sm_cs1_n,sm_cs2_n;	//�����Ƭѡ�źţ�����Ч
output[6:0] sm_db;	//7������ܣ�������С���㣩

reg[24:0] cnt;	//�������������Լ�����2��25�η�*20ns=640ms

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt <= 25'd0;
	else cnt <= cnt+1'b1;	//ѭ������
	
reg[3:0] num;	//��ʾ��ֵ

always @ (posedge clk or negedge rst_n)
	if(!rst_n) num <= 4'd0;
	else if(cnt == 24'hffffff) num <= num+1'b1;	//ÿ640ms��һ

//-------------------------------------------------------------------------------
/*	������ :����С����
              ;0,  1,  2,  3,  4, 5,  6,  7,  
      db      3fh,06h,5bh,4fh,66h,6dh,7dh,07h 
              ;8,  9, a,  b,   c,  d,  e,  f , ��   
      db      7fh,6fh,77h,7ch,39h,5eh,79h,71h,00h*/
parameter	seg0	= 7'h3f,
			seg1	= 7'h06,
			seg2	= 7'h5b,
			seg3	= 7'h4f,
			seg4	= 7'h66,
			seg5	= 7'h6d,
			seg6	= 7'h7d,
			seg7	= 7'h07,
			seg8	= 7'h7f,
			seg9	= 7'h6f,
			sega	= 7'h77,
			segb	= 7'h7c,
			segc	= 7'h39,
			segd	= 7'h5e,
			sege	= 7'h79,
			segf	= 7'h71;

reg[6:0] sm_dbr;		//7������ܣ�������С���㣩
	
always @ (num)
		case (num)	//NUMֵ��ʾ�������������
			4'h0: sm_dbr <= seg0;

			4'h1: sm_dbr <= seg1;
			4'h2: sm_dbr <= seg2;
			4'h3: sm_dbr <= seg3;
			4'h4: sm_dbr <= seg4;
			4'h5: sm_dbr <= seg5;
			4'h6: sm_dbr <= seg6;
			4'h7: sm_dbr <= seg7;
			4'h8: sm_dbr <= seg8;
			4'h9: sm_dbr <= seg9;
			4'ha: sm_dbr <= sega;
			4'hb: sm_dbr <= segb;
			4'hc: sm_dbr <= segc;
			4'hd: sm_dbr <= segd;
			4'he: sm_dbr <= sege;
			4'hf: sm_dbr <= segf;
			default: ;
			endcase

assign sm_db = sm_dbr;
assign sm_cs1_n = 1'b0;		//�����1����
assign sm_cs2_n = 1'b0;		//�����2����
 
endmodule
