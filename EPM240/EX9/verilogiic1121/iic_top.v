`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:
// Design Name:    
// Module Name:    iic_top
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
module iic_top(
			clk,rst_n,
			sw1,sw2,
			scl,sda,
			sm_cs1_n,sm_cs2_n,sm_db
		);
		
input clk;		// 50MHz
input rst_n;	//��λ�źţ�����Ч
input sw1,sw2;	//����1��2,(1����ִ��д�������2����ִ�ж�����)
output scl;		// 24C02��ʱ�Ӷ˿�
inout sda;		// 24C02�����ݶ˿�

output sm_cs1_n,sm_cs2_n;	//�����Ƭѡ�źţ�����Ч
output[6:0] sm_db;	//7������ܣ�������С���㣩


wire[7:0] dis_data;		//�����������ʾ��16������

iic_com		iic_com(
				.clk(clk),
				.rst_n(rst_n),
				.sw1(sw1),
				.sw2(sw2),
				.scl(scl),
				.sda(sda),
				.dis_data(dis_data)
				);

led_seg7	led_seg7(
				.clk(clk),
				.rst_n(rst_n),
				.dis_data(dis_data),
				.sm_cs1_n(sm_cs1_n),
				.sm_cs2_n(sm_cs2_n),
				.sm_db(sm_db)	
				);
	
		

endmodule		
