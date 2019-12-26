`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchise.3
// Create Date	: 2009.04.20
// Design Name	: mem_cof
// Module Name	: mem_cof
// Project Name	: mem_cof
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: ����M4K����һ��4*4*8bit����λ�Ĵ���
//				
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module mem_cof(
			clk,rst_n,
			shift_din,shift_dout,//shift_all_data
			taps0x,taps1x,taps2x,taps3x,taps4x,taps5x,taps6x,taps7x
		);

input clk;		//ϵͳ����ʱ�ӣ�25M
input rst_n;	//ϵͳ�����źţ�����Ч

input[3:0] shift_din;					//��λRAM��������
output[3:0] shift_dout;				//��λRAM�������
//output[31:0] shift_all_data;	//��λRAMȫ��64bit����
output	[3:0]  taps0x;
output	[3:0]  taps1x;
output	[3:0]  taps2x;
output	[3:0]  taps3x;
output	[3:0]  taps4x;
output	[3:0]  taps5x;
output	[3:0]  taps6x;
output	[3:0]  taps7x;

//����M4K���ɵ���λRAM
shift_ram 	uut_shift(
				.clken(rst_n),		//��λRAMʹ���źţ�����Ч
				.clock(clk),
				.shiftin(shift_din),
				.shiftout(shift_dout),
				//.taps(shift_all_data)
				.taps0x(taps0x),
				.taps1x(taps1x),
				.taps2x(taps2x),
				.taps3x(taps3x),
				.taps4x(taps4x),
				.taps5x(taps5x),
				.taps6x(taps6x),
				.taps7x(taps7x)
				);


endmodule

