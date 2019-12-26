`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchise.3
// Create Date	: 2009.08.31
// Design Name	: johnson
// Module Name	: johnson
// Project Name	: johnson
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: �ù���������ʾAS��JTAG���ط�ʽ
//					
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module johnson(
			clk,rst_n,
			led
		);

input clk;		//��ʱ�ӣ�25MHz
input rst_n;	//�͵�ƽ��λ
output led;		// LED�ӿ�

//------------------------------------
reg[24:0] delay;	//��ʱ������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) delay <= 25'd0;
	else delay <= delay+1'b1;	//���ϼ���������Ϊ1.34s

assign led = delay[24];		//1.34s LED��˸һ��

endmodule

