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
// Description	: ����M4K����һ��256*8bit�ĵ���RAM
//				
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module mem_cof(
			clk,rst_n,
			ram_wr,ram_addr,ram_din,ram_dout
		);

input clk;		//ϵͳ����ʱ�ӣ�25M
input rst_n;	//ϵͳ�����źţ�����Ч

input ram_wr;			//RAMд��ʹ���źţ��߱�ʾд��
input[11:0] ram_addr;	//RAM��ַ����

input[7:0]  ram_din;		//RAMд����������
output[7:0] ram_dout;		//RAM������������


//����M4K���ɵ�RAM
sys_ram 	uut_ram(
				.address(ram_addr),
				.clock(clk),
				.data(ram_din),
				.wren(ram_wr),
				.q(ram_dout)
			);


endmodule

