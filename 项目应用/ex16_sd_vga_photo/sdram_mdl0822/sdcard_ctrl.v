`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.07
// Design Name	: 
// Module Name	: sdcard_ctrl
// Project Name	: sdrsvgaprj
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sdcard_ctrl(
			clk,rst_n,
			spi_miso,spi_mosi,spi_clk,spi_cs_n,
			sd_dout,sd_fifowr,sdwrad_clr
			);

input clk;		//FPAG����ʱ���ź�25MHz
input rst_n;	//FPGA���븴λ�ź�

input spi_miso;		//SPI��������ӻ���������ź�
output spi_mosi;	//SPI��������ӻ����������ź�
output spi_clk;		//SPIʱ���źţ�����������
output spi_cs_n;	//SPI���豸ʹ���źţ������豸����

output[7:0] sd_dout;	//��SD�����Ĵ�����FIFO����
output sd_fifowr;		//sd��������д��FIFOʹ���źţ�����Ч
output sdwrad_clr;		//SDRAMд��������ź����㸴λ�źţ�����Ч

//output[3:0] led;	//����ʹ��

//----------------------------------------------------------------
wire spi_tx_en;		//SPI���ݷ���ʹ���źţ�����Ч
wire spi_tx_rdy;		//SPI���ݷ�����ɱ�־λ������Ч
wire spi_rx_en;		//SPI���ݽ���ʹ���źţ�����Ч
wire spi_rx_rdy;		//SPI���ݽ�����ɱ�־λ������Ч
wire[7:0] spi_tx_db;	//SPI���ݷ��ͼĴ���
wire[7:0] spi_rx_db;	//SPI���ݽ��ռĴ���


//----------------------------------------------------------------
//����SPI�������ģ��
spi_ctrl		uut_spictrl(
					.clk(clk),
					.rst_n(rst_n),
					.spi_miso(spi_miso),
					.spi_mosi(spi_mosi),
					.spi_clk(spi_clk),
					.spi_tx_en(spi_tx_en),
					.spi_tx_rdy(spi_tx_rdy),
					.spi_rx_en(spi_rx_en),
					.spi_rx_rdy(spi_rx_rdy),
					.spi_tx_db(spi_tx_db),
					.spi_rx_db(spi_rx_db)
				);

//����SD�������ģ��
sd_ctrl			uut_sdctrl(
					.clk(clk),
					.rst_n(rst_n),
					.spi_cs_n(spi_cs_n),
					.spi_tx_en(spi_tx_en),
					.spi_tx_rdy(spi_tx_rdy),
					.spi_rx_en(spi_rx_en),
					.spi_rx_rdy(spi_rx_rdy),
					.spi_tx_db(spi_tx_db),
					.spi_rx_db(spi_rx_db),
					.sd_dout(sd_dout),
					.sd_fifowr(sd_fifowr),
					.sdwrad_clr(sdwrad_clr)
				);

endmodule
