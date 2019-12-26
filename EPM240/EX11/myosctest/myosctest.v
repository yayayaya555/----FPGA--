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
module myosctest(
			rst_n,
			clkdiv
			);

input rst_n;	//�͵�ƽ��λ�ź�
output clkdiv;	//�������8��Ƶ�ź�

wire cscena = 1'b1;	//ʼ��ʹ���ڲ���������
wire clk;			//�����ڲ���ʱ��,3.3M~5.6M(����ʱ��5.56M)

internal_osc 	internal_osc(
						.oscena(cscena),
						.osc(clk)
					);

//8��Ƶ����//
reg[2:0] cnt;

always @(posedge clk or negedge rst_n)
	if(!rst_n) cnt <= 3'd0;
	else cnt <= cnt+1'b1;
assign clkdiv = cnt[2];

endmodule


