`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.15
// Design Name	: 
// Module Name	: vga_ctrl
// Project Name	: 
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module vga_ctrl(	
				clk,rst_n,
				disp_ctrl,
				dis_data,vga_valid,rdf_rdreq,
				hsync,vsync,vga_r,vga_g,vga_b
			);

input clk;		// 50MHz
input rst_n;	//�͵�ƽ��λ

input[7:0] dis_data;	//VGA��ʾ����
input disp_ctrl;		//�ⲿ����LCD��ʾʹ���ź�
output vga_valid;		//����Ч������ʹ��SDRAM�����ݵ�Ԫ����Ѱַ���ַ����
output rdf_rdreq;			//sdram���ݶ�������FIFO����������󣬸���Ч

	// FPGA��VGA�ӿ��ź�
output hsync;	//��ͬ���ź�
output vsync;	//��ͬ���ź�
output[2:0] vga_r;
output[2:0] vga_g;
output[1:0] vga_b;

//--------------------------------------------------
	// �������
reg[10:0] x_cnt;	//������0-1039
reg[9:0] y_cnt;		//������0-665

always @ (posedge clk or negedge rst_n)
	if(!rst_n) x_cnt <= 11'd0;
	else if(!disp_ctrl) x_cnt <= 11'd0;	//����ʾ
	else if(x_cnt == 11'd1039) x_cnt <= 11'd0;
	else x_cnt <= x_cnt+1'b1;			//x�������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) y_cnt <= 10'd0;
	else if(!disp_ctrl) y_cnt <= 10'd0;	//����ʾ
	else if(y_cnt == 10'd665) y_cnt <= 10'd0;
	else if(x_cnt == 11'd1039) y_cnt <= y_cnt+1'b1;	//y�������

//--------------------------------------------------
	//��Ч��ʾ��־λ����
reg valid_yr;	//����ʾ��Ч�ź�

always @ (posedge clk or negedge rst_n)
	if(!rst_n) valid_yr <= 1'b0;
	else if(y_cnt == 10'd31) valid_yr <= 1'b1;	//����Ч��ʾ��
	else if(y_cnt == 10'd631) valid_yr <= 1'b0;	

reg valid_r;
wire valid;		//��Ч��ʾ����־

always @ (posedge clk or negedge rst_n)
	if(!rst_n) valid_r <= 1'b0;
	else if(x_cnt == 11'd187) valid_r <= 1'b1;	//����Ч��ʾ��
	else if(x_cnt == 11'd987) valid_r <= 1'b0;
	
assign valid = valid_r & valid_yr;	// VGA��Ч��ʾ����־λ

//--------------------------------------------------
	// VGA��ͬ��,��ͬ���ź�
reg hsync_r,vsync_r;	//ͬ���ź�

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
	//��FIFO����ʹ�ܣ�����ʾ����

assign rdf_rdreq = ((x_cnt >= 11'd183) & (x_cnt < 11'd983) 
					& (y_cnt > 10'd30) & (y_cnt <= 10'd630));

//--------------------------------------------------
	//ʹ��SDRAM�����ݵ�Ԫ����Ѱַ���ַ����
assign vga_valid = (y_cnt >= 10'd30) & (y_cnt <= 10'd630);

//-------------------------------------------------- 
	// VGAɫ���źŲ���
reg[7:0] vga_rgb;	// VGAɫ����ʾ�Ĵ���

always @ (posedge clk)
	if(!valid) vga_rgb <= 8'd0;
	else vga_rgb <= dis_data;

	//r,g,b����Һ������ɫ��ʾ
assign vga_r = vga_rgb[2:0];
assign vga_g = vga_rgb[5:3];
assign vga_b = vga_rgb[7:6];

endmodule
