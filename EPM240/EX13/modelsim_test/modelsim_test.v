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
module modelsim_test(
				clk,rst_n,div
				);
	
input clk;		//ϵͳʱ��	
input rst_n;		//��λ�źţ�����Ч

output div;		//2��Ƶ�ź�

reg div;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) div <= 1'b0;
	else div <= ~div;
	

endmodule

