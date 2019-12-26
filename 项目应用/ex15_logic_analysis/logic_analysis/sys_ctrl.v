`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchise.3
// Create Date	: 2009.04.09
// Design Name	: 
// Module Name	: sys_ctrl
// Project Name	: logic_analysis
// Target Device: Cyclone EP1C3T144C8
// Tool versions: Quartus II 8.1
// Description	: DIY�߼������Ǹ�λ�Լ�PLL����ģ��
//					
// Revision		: V1.0
// Additional Comments	:  ���������˵��Ͷ��ɹ���
//				δ�����������ϴ�Դ�룬лл����֧��
////////////////////////////////////////////////////////////////////////////////
module sys_ctrl(
				clk,rst_n,sys_rst_n,
				clk_25m,clk_100m
			);

input clk;		//FPAG����ʱ���ź�25MHz
input rst_n;	//ϵͳ��λ�ź�

output sys_rst_n;	//ϵͳ��λ�źţ�����Ч

output clk_25m;		//PLL���25MHzʱ��
output clk_100m;	//PLL���100MHzʱ��
wire locked;		//PLL�����Ч��־λ���߱�ʾPLL�����Ч

//----------------------------------------------
//PLL��λ�źŲ���������Ч
//�첽��λ��ͬ���ͷ�
wire pll_rst;	//PLL��λ�źţ�����Ч

reg rst_r1,rst_r2;

always @(posedge clk or negedge rst_n)
	if(!rst_n) rst_r1 <= 1'b1;
	else rst_r1 <= 1'b0;

always @(posedge clk or negedge rst_n)
	if(!rst_n) rst_r2 <= 1'b1;
	else rst_r2 <= rst_r1;

assign pll_rst = rst_r2;

//----------------------------------------------
//ϵͳ��λ�źŲ���������Ч
//�첽��λ��ͬ���ͷ�
wire sys_rst_n;	//ϵͳ��λ�źţ�����Ч
wire sysrst_nr0;
reg sysrst_nr1,sysrst_nr2;

assign sysrst_nr0 = rst_n & locked;	//ϵͳ��λֱ��PLL��Ч���

always @(posedge clk_100m or negedge sysrst_nr0)
	if(!sysrst_nr0) sysrst_nr1 <= 1'b0;
	else sysrst_nr1 <= 1'b1;

always @(posedge clk_100m or negedge sysrst_nr0)
	if(!sysrst_nr0) sysrst_nr2 <= 1'b0;
	else sysrst_nr2 <= sysrst_nr1;

assign sys_rst_n = sysrst_nr2;

//----------------------------------------------
//����PLL����ģ��
PLL_ctrl 		uut_PLL_ctrl(
					.areset(pll_rst),	//PLL��λ�ź�,�ߵ�ƽ��λ
					.inclk0(clk),		//PLL����ʱ�ӣ�25MHz
					.c0(clk_25m),		//PLL���25MHzʱ��			
					.c1(clk_100m),		//PLL���100MHzʱ��
					.locked(locked)		//PLL�����Ч��־λ���߱�ʾPLL�����Ч
				);
				

endmodule

