`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.04
// Design Name	: 
// Module Name	: sdrsvgaprj
// Project Name	: sdrsvgaprj
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sdrsvgaprj(
				clk,rst_n,
				rs232_tx,
				spi_miso,spi_mosi,spi_clk,spi_cs_n,led
			);

input clk;		//FPAG����ʱ���ź�25MHz
input rst_n;	//FPGA���븴λ�ź�

output rs232_tx;	// RS232���������ź�

input spi_miso;		//SPI��������ӻ���������ź�
output spi_mosi;	//SPI��������ӻ����������ź�
output spi_clk;		//SPIʱ���źţ�����������
output spi_cs_n;	//SPI���豸ʹ���źţ������豸����

output[3:0] led;	//����ʹ��

//------------------------------------------------
wire clk_25m;		//PLL���25MHzʱ��
wire clk_100m;	//PLL���100MHzʱ��
wire sys_rst_n;	//ϵͳ��λ�źţ�����Ч

wire tx_start;		//���ڷ�������������־λ������Ч

wire[7:0] fifo232_din;	//FIFOд������
wire fifo232_wrreq;		//FIFOд�����źţ�����Ч
wire fifo232_rdreq;		//FIFO�������źţ�����Ч
wire[7:0] fifo232_dout;	//FIFO�������ݣ������ڴ���������
wire fifo232_empty;	//FIFO�ձ�־λ������Ч


assign tx_start = ~fifo232_empty;	//���FIFO���գ����������ڶ�FIFO����������
//------------------------------------------------
//����ϵͳ��λ�źź�PLL����ģ��
sys_ctrl		uut_sysctrl(
					.clk(clk),
					.rst_n(rst_n),
					.sys_rst_n(sys_rst_n),
					.clk_25m(clk_25m),
					.clk_100m(clk_100m)
					);


//�����������ݷ��Ϳ���ģ��
uart_ctrl		uut_uartctrl(
					.clk(clk_25m),
					.rst_n(sys_rst_n),
					.tx_data(fifo232_dout),
					.tx_start(tx_start),
					.fifo232_rdreq(fifo232_rdreq),
					.rs232_tx(rs232_tx)
					);

//�������ڷ������ݻ���FIFOģ��
sdrd_fifo			sdrd_fifo_inst(
					.data(rdfifo_din),
					.rdclk(clk_25m),
					.rdreq(rdfifo_rdreq),
					.wrclk(clk_100m),
					.wrreq(rdfifo_wrreq),
					.empty(fifo232_empty),
					.q(fifo232_dout)					
					);


//sd����ģ��
sdcard_ctrl		uut_sdcartctrl(
					.clk(clk_25m),
					.rst_n(sys_rst_n),
					.spi_miso(spi_miso),
					.spi_mosi(spi_mosi),
					.spi_clk(spi_clk),
					.spi_cs_n(spi_cs_n),
					.sd_dout(fifo232_din),
					.sd_fifowr(fifo232_wrreq)
					.led(led)
				);


endmodule
