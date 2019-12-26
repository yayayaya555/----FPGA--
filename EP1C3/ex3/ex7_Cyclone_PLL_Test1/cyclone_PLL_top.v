`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchise.3
// Create Date	: 2009.04.20
// Design Name	: cyclone_PLL_top
// Module Name	: cyclone_PLL_top
// Project Name	: cyclone_PLL_top
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: ����PLL����һ��ϵͳ����ʱ��2��Ƶ������0�ȵ�ʱ��
//					
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module cyclone_PLL_top(
				clk,rst_n,
				clkdiv,locked
			);

input clk;		//25MHzϵͳ�ⲿ����ʱ��
input rst_n;	//ϵͳ��λ�źţ��͵�ƽ��Ч

output clkdiv;	//PLL���ʱ��
output locked;	//�ȶ�PLL�����־λ������Ч

//PLL����ģ��
//����һ��ϵͳ����ʱ��2��Ƶ������0�ȵ�ʱ��
PLL_ctrl	PLL_ctrl_inst (
				.areset(~rst_n),	//PLL�첽��λ�ź�,����Ч
				.inclk0(clk),		//PLL����ʱ��
				.c0(clkdiv),		//PLL���ʱ��
				.locked(locked)		//�ȶ�PLL�����־λ������Ч
			);


endmodule

