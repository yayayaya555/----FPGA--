`timescale 1ns/1ns
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:45:36 04/01/2009
// Design Name:   cpu_cpld
// Module Name:   D:/verilog_prj/KS7_CPU_SIM/testbech_prj/cpu_cpld/print_task.v
// Project Name:  cpu_cpld
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu_cpld
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sys_ctrl_task(
					clk,rst_n
					);

output reg clk;	//ʱ���ź�
output reg rst_n;	//��λ�ź�

parameter 	PERIOD 	= 40;		//ʱ�����ڣ���λns 
parameter 	RST_ING = 1'b0;		//��Ч��λֵ��Ĭ�ϵ͵�ƽ��λ 				

//----------------------------------------------------------------------//
//ϵͳʱ���źŲ���
//----------------------------------------------------------------------//		
initial begin
	clk = 0;
	forever
		#(PERIOD/2) clk = ~clk;
end
 		
//----------------------------------------------------------------------//
//ϵͳ��λ�����װ
//----------------------------------------------------------------------//		
task sys_reset;
	input[31:0] reset_time; //��λʱ�����룬��λns
	begin
		rst_n = RST_ING;		//��λ��
		#reset_time;			//��λʱ��
		rst_n = ~RST_ING;		//������λ
	end
endtask		
		
		
endmodule

