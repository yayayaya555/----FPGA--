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
module ufmtest(
			databus,addr,
			nerase,nread,nwrite,
			data_valid,nbusy
		);


inout[15:0] databus;	//Flash��������

input[8:0] addr;		//Flash��ַ����
input nerase;			//����Flashĳһ�����ź�
input nread;			//��Flash�ź�
input nwrite;			//дFlash�ź�
output data_valid;		//Flash���������Ч�ź�
output nbusy;			//Flashæ�ź�


assign databus = nwrite ? dataout:16'hzzzz; 	//д�ź���Чʱ��Flash����������Ϊ����
assign datain = databus;	//д��Flash������������

wire[15:0] datain;		//Flashд������
wire[15:0] dataout;		//Flash��������


//����UFM��Flash��ģ��
para_ufm	para_ufm_inst (
	.addr ( addr ),
	.datain ( datain ),
	.nerase ( nerase),
	.nread ( nread ),
	.nwrite ( nwrite),
	.data_valid ( data_valid ),
	.dataout ( dataout ),
	.nbusy ( nbusy )
	);



endmodule

