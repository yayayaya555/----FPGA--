`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.05
// Design Name	: 
// Module Name	: spi_ctrl
// Project Name	: sdrsvgaprj
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module spi_ctrl(
			clk,rst_n,
			spi_miso,spi_mosi,spi_clk,
			spi_tx_en,spi_tx_rdy,spi_rx_en,spi_rx_rdy,spi_tx_db,spi_rx_db
			);

input clk;		//FPAG����ʱ���ź�25MHz
input rst_n;	//FPGA���븴λ�ź�

input spi_miso;		//SPI��������ӻ���������ź�
output spi_mosi;	//SPI��������ӻ����������ź�
output spi_clk;		//SPIʱ���źţ�����������

input spi_tx_en;		//SPI���ݷ���ʹ���źţ�����Ч
output spi_tx_rdy;		//SPI���ݷ�����ɱ�־λ������Ч
input spi_rx_en;		//SPI���ݽ���ʹ���źţ�����Ч
output spi_rx_rdy;		//SPI���ݽ�����ɱ�־λ������Ч
input[7:0] spi_tx_db;	//SPI���ݷ��ͼĴ���
output[7:0] spi_rx_db;	//SPI���ݽ��ռĴ���


//ģ��SPI��ʱ��ģʽΪCPOL=1, CPHA=1,ģ������Ϊ25Mbit

//-------------------------------------------------
//SPIʱ����Ƽ�����������SPIʱ���ɸü�����ֵ����
reg[4:0] cnt8;	//SPIʱ����Ƽ�����,������Χ��0-18

always @(posedge clk or negedge rst_n)
	if(!rst_n) cnt8 <= 5'd0;
	else if(spi_tx_en || spi_rx_en) begin
			if(cnt8 < 5'd18)cnt8 <= cnt8+1'b1;	//SPI����ʹ��
			else ;	//������18ֹͣ���ȴ�����spiʹ��
		end
	else cnt8 <= 5'd0;	//SPI�رգ�����ֹͣ

//-------------------------------------------------
//SPIʱ���źŲ���
reg spi_clkr;	//SPIʱ���źţ�����������

always @(posedge clk or negedge rst_n)
	if(!rst_n) spi_clkr <= 1'b1;
	else if(cnt8 > 5'd1 && cnt8 < 5'd18) spi_clkr <= ~spi_clkr;	//��cnt8����2-17ʱSPIʱ����Ч��ת

assign spi_clk = spi_clkr;

//-------------------------------------------------
//SPI����������ݿ���
reg spi_mosir;	//SPI��������ӻ����������ź�

always @(posedge clk or negedge rst_n)
	if(!rst_n) spi_mosir <= 1'b1;
	else if(spi_tx_en) begin
			case(cnt8[4:1])		//��������8bit����
				4'd1: spi_mosir <= spi_tx_db[7];	//����bit7
				4'd2: spi_mosir <= spi_tx_db[6];	//����bit6
				4'd3: spi_mosir <= spi_tx_db[5];	//����bit5
				4'd4: spi_mosir <= spi_tx_db[4];	//����bit4
				4'd5: spi_mosir <= spi_tx_db[3];	//����bit3
				4'd6: spi_mosir <= spi_tx_db[2];	//����bit2
				4'd7: spi_mosir <= spi_tx_db[1];	//����bit1
				4'd8: spi_mosir <= spi_tx_db[0];	//����bit0
				default: spi_mosir <= 1'b1;	//spi_mosiû�����ʱӦ���ָߵ�ƽ
				endcase
		end
	else spi_mosir <= 1'b1;	//spi_mosiû�����ʱӦ���ָߵ�ƽ

assign spi_mosi = spi_mosir;

//-------------------------------------------------
//SPI�����������ݿ���
reg[7:0] spi_rx_dbr;	//SPI��������ӻ�����������߼Ĵ���

always @(posedge clk or negedge rst_n)
	if(!rst_n) spi_rx_dbr <= 8'hff;
	else if(spi_rx_en) begin
			case(cnt8)		//�������ղ�����8bit����
				5'd3: spi_rx_dbr[7] <= spi_miso;	//����bit7
				5'd5: spi_rx_dbr[6] <= spi_miso;	//����bit6
				5'd7: spi_rx_dbr[5] <= spi_miso;	//����bit5
				5'd9: spi_rx_dbr[4] <= spi_miso;	//����bit4
				5'd11: spi_rx_dbr[3] <= spi_miso;	//����bit3
				5'd13: spi_rx_dbr[2] <= spi_miso;	//����bit2
				5'd15: spi_rx_dbr[1] <= spi_miso;	//����bit1
				5'd17: spi_rx_dbr[0] <= spi_miso;	//����bit0
				default: ;
				endcase
		end

assign spi_rx_db = spi_rx_dbr;

//-------------------------------------------------
//SPI���ݷ�����ɱ�־λ������Ч
assign spi_tx_rdy = (cnt8 == 5'd18)/* & spi_tx_en)*/;

//-------------------------------------------------
//SPI���ݽ�����ɱ�־λ������Ч
assign spi_rx_rdy = (cnt8 == 5'd18)/* & spi_rx_en)*/;


endmodule
