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
module clkdiv(
			clk,rst_n,
			clk_div	
		);

input clk;		//50MHz
input rst_n;	//�͵�ƽ��λ�ź�

output clk_div;	//��Ƶ�źţ����ӵ�������

//---------------------------------------------------
reg[19:0] cnt;	//��Ƶ������

always @ (posedge clk or negedge rst_n)	//�첽��λ
	if(!rst_n) cnt <= 20'd0;
	else cnt <= cnt+1'b1;	//�Ĵ���cnt 20msѭ������

//----------------------------------------------------
reg clk_div_r;	//clk_div�ź�ֵ�Ĵ���

always @ (posedge clk or negedge rst_n) 
	if(!rst_n) clk_div_r <= 1'b0;
	else if(cnt == 20'hfffff) clk_div_r <= ~clk_div_r;	//ÿ20ms��clk_div_rֵ��תһ��

assign clk_div = clk_div_r;	

endmodule

