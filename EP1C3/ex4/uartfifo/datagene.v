`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.12
// Design Name	: 
// Module Name	: datagene
// Project Name	: uartfifo
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 232�������ݲ���ģ��
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module datagene(
				clk,rst_n,
				wrf_din,wrf_wrreq
			);

input clk;		//FPAG����ʱ���ź�25MHz
input rst_n;	//FPGA���븴λ�ź�

	//wrFIFO������ƽӿ�
output[7:0] wrf_din;		//����д�뻺��FIFO������������
output wrf_wrreq;			//����д�뻺��FIFO�����������󣬸���Ч


//------------------------------------------
//ÿ1sд��16��8bit���ݵ�fifo��
reg[24:0] cntwr;	//дsdram��ʱ������

always @(posedge clk or negedge rst_n)
	if(!rst_n) cntwr <= 25'd0;
	else cntwr <= cntwr+1'b1;

assign wrf_wrreq = (cntwr >= 25'h1fffff0) && (cntwr <= 25'h1ffffff);	//FIFOд��Ч�ź�

//------------------------------------------
//дfifo�����źŲ�������wrfifo��д����Ч�ź�
reg[7:0] wrf_dinr;	//wrfifo��д������

always @(posedge clk or negedge rst_n)
	if(!rst_n) wrf_dinr <= 8'd0;
	else if((cntwr >= 25'h1fffff0) && (cntwr <= 25'h1ffffff))
		wrf_dinr <= wrf_dinr+1'b1;	//д�����ݵ���

assign wrf_din = wrf_dinr;

endmodule
