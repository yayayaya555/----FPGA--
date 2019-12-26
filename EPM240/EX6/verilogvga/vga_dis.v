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
module vga_dis(
			clk,rst_n,
			hsync,vsync,
			vga_r,vga_g,vga_b
		);

input clk;		//50MHz
input rst_n;	//�͵�ƽ��λ
output hsync;	//��ͬ���ź�
output vsync;	//��ͬ���ź�
output vga_r;
output vga_g;
output vga_b;

//--------------------------------------------------
reg[10:0] x_cnt;	//������
reg[9:0] y_cnt;	//������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) x_cnt <= 11'd0;
	else if(x_cnt == 11'd1039) x_cnt <= 11'd0;
	else x_cnt <= x_cnt+1'b1;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) y_cnt <= 10'd0;
	else if(y_cnt == 10'd665) y_cnt <= 10'd0;
	else if(x_cnt == 11'd1039) y_cnt <= y_cnt+1'b1;

//--------------------------------------------------
wire valid;	//��Ч��ʾ����־

assign valid = (x_cnt >= 11'd187) && (x_cnt < 11'd987) 
					&& (y_cnt >= 10'd31) && (y_cnt < 10'd631); 

wire[9:0] xpos,ypos;	//��Ч��ʾ������

assign xpos = x_cnt-11'd187;
assign ypos = y_cnt-10'd31;

//--------------------------------------------------
reg hsync_r,vsync_r;	//ͬ���źŲ���

always @ (posedge clk or negedge rst_n)
	if(!rst_n) hsync_r <= 1'b1;
	else if(x_cnt == 11'd0) hsync_r <= 1'b0;	//����hsync�ź�
	else if(x_cnt == 11'd120) hsync_r <= 1'b1;
 
always @ (posedge clk or negedge rst_n)
	if(!rst_n) vsync_r <= 1'b1;
	else if(y_cnt == 10'd0) vsync_r <= 1'b0;	//����vsync�ź�
	else if(y_cnt == 10'd6) vsync_r <= 1'b1;

assign hsync = hsync_r;
assign vsync = vsync_r;

//--------------------------------------------------
	//��ʾһ�����ο�
wire a_dis,b_dis,c_dis,d_dis;	//���ο���ʾ����λ

assign a_dis = ( (xpos>=200) && (xpos<=220) ) 
				&&	( (ypos>=140) && (ypos<=460) );
				
assign b_dis = ( (xpos>=580) && (xpos<=600) )
				&& ( (ypos>=140) && (ypos<=460) );

assign c_dis = ( (xpos>=220) && (xpos<=580) ) 
				&&	( (ypos>140)  && (ypos<=160) );
				
assign d_dis = ( (xpos>=220) && (xpos<=580) )
				&& ( (ypos>=440) && (ypos<=460) );

	//��ʾһ��С����
wire e_rdy;	//���ε���ʾ��Ч��������

assign e_rdy = ( (xpos>=385) && (xpos<=415) )
				&&	( (ypos>=285) && (ypos<=315) );

//-------------------------------------------------- 
	//r,g,b����Һ������ɫ��ʾ��������ʾ��ɫ�����ο���ʾ����ɫ
assign vga_r = valid ? e_rdy : 1'b0;
assign vga_g = valid ?  (a_dis | b_dis | c_dis | d_dis) : 1'b0;
assign vga_b = valid ? ~(a_dis | b_dis | c_dis | d_dis) : 1'b0;	  

endmodule
