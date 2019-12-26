`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.21
// Design Name	: 
// Module Name	: uartfifo
// Project Name	: uartfifo
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module uartfifo(
				clk,rst_n,
				rs232_tx
			);

input clk;			// 25MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�

output rs232_tx;		//RS232���������ź�


wire[7:0] wrf_din;	//����д�뻺��FIFO������������
wire wrf_wrreq;		//����д�뻺��FIFO�����������󣬸���Ч
wire[7:0] tx_data;	//���ڴ���������
wire tx_start;		//���ڷ�������������־λ������Ч
wire fifo232_rdreq;	//FIFO�������źţ�����Ч
wire fifo_empty;	//FIFO�ձ�־λ������Ч

assign tx_start = ~fifo_empty;	//fifo�����ݼ���������ģ�鷢������

//����232�������ݲ���ģ��
datagene		uut_datagene(
						.clk(clk),
						.rst_n(rst_n),
						.wrf_din(wrf_din),
						.wrf_wrreq(wrf_wrreq)
						);
						
//����FIFO						
fifo232			fifo232_inst (
						.clock(clk),
						.data(wrf_din),
						.rdreq(fifo232_rdreq),
						.wrreq(wrf_wrreq),
						.empty(fifo_empty),
						.q(tx_data)
						);						


//�������ڷ���ģ��
uart_ctrl		uut_uartfifo(
						.clk(clk),
						.rst_n(rst_n),
						.tx_data(tx_data),
						.tx_start(tx_start),
						.fifo232_rdreq(fifo232_rdreq),
						.rs232_tx(rs232_tx)
						);





endmodule
