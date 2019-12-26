`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.11
// Design Name	: 
// Module Name	: sdr_test
// Project Name	: 
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module sdr_test(
				clk,rst_n,
				sdram_clk,sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n,
				sdram_ba,sdram_addr,sdram_data,//sdram_udqm,sdram_ldqm	
				spi_miso,spi_mosi,spi_clk,spi_cs_n,
				hsync,vsync,vga_r,vga_g,vga_b
			);

input clk;			//ϵͳʱ�ӣ�25MHz
input rst_n;		//��λ�źţ��͵�ƽ��Ч

	// FPGA��SDRAMӲ���ӿ�
output sdram_clk;			//	SDRAMʱ���ź�
output sdram_cke;			//  SDRAMʱ����Ч�ź�
output sdram_cs_n;			//	SDRAMƬѡ�ź�
output sdram_ras_n;			//	SDRAM�е�ַѡͨ����
output sdram_cas_n;			//	SDRAM�е�ַѡͨ����
output sdram_we_n;			//	SDRAMд����λ
output[1:0] sdram_ba;		//	SDRAM��L-Bank��ַ��
output[11:0] sdram_addr;	//  SDRAM��ַ����
//output sdram_udqm;			// SDRAM���ֽ�����
//output sdram_ldqm;			// SDRAM���ֽ�����
inout[15:0] sdram_data;		// SDRAM��������

	// SDӲ���ӿ�
input spi_miso;		//SPI��������ӻ���������ź�
output spi_mosi;	//SPI��������ӻ����������ź�
output spi_clk;		//SPIʱ���źţ�����������
output spi_cs_n;	//SPI���豸ʹ���źţ������豸����

	// FPGA��VGA�ӿ��ź�
output hsync;	//��ͬ���ź�
output vsync;	//��ͬ���ź�
output[2:0] vga_r;
output[2:0] vga_g;
output[1:0] vga_b;

	// SDRAM�ķ�װ�ӿ�
wire sdram_wr_req;			//ϵͳдSDRAM�����ź�
wire sdram_rd_req;			//ϵͳ��SDRAM�����ź�
wire sdram_wr_ack;			//ϵͳдSDRAM��Ӧ�ź�,��ΪwrFIFO�������Ч�ź�
wire sdram_rd_ack;			//ϵͳ��SDRAM��Ӧ�ź�,��ΪrdFIFO����д��Ч�ź�	
wire[8:0] sdwr_byte = 9'd256;		//ͻ��дSDRAM�ֽ�����1-256����
wire[8:0] sdrd_byte = 9'd32;		//ͻ����SDRAM�ֽ�����1-256����
wire[21:0] sys_wraddr;		//дSDRAMʱ��ַ�ݴ�����(bit21-20)L-Bank��ַ:(bit19-8)Ϊ�е�ַ��(bit7-0)Ϊ�е�ַ 
wire[21:0] sys_rdaddr;		//��SDRAMʱ��ַ�ݴ�����(bit21-20)L-Bank��ַ:(bit19-8)Ϊ�е�ַ��(bit7-0)Ϊ�е�ַ 
wire[15:0] sys_data_in;		//дSDRAMʱ�����ݴ���

wire[15:0] sys_data_out;	//sdram���ݶ�������FIFO������������
//wire sdram_busy;			// SDRAMæ��־���߱�ʾSDRAM���ڹ�����
//wire sys_dout_rdy;			// SDRAM���������ɱ�־

	//wrFIFO������ƽӿ�
wire[15:0] wrf_din;		//sdram����д�뻺��FIFO������������
wire wrf_wrreq;			//sdram����д�뻺��FIFO�����������󣬸���Ч
wire sdwrad_clr;		//SDRAMд��������ź����㸴λ�źţ�����Ч

	//rdFIFO������ƽӿ�
//wire[15:0] rdf_dout;		//sdram���ݶ�������FIFO�����������	
wire rdf_rdreq;			//sdram���ݶ�������FIFO����������󣬸���Ч

	//ϵͳ��������źŽӿ�
wire clk_50m;	//PLL���50MHzʱ��
wire clk_100m;	//PLL���100MHzʱ��
wire sys_rst_n;	//ϵͳ��λ�źţ�����Ч

wire vga_valid;		//����Ч������ʹ��SDRAM�����ݵ�Ԫ����Ѱַ���ַ����
wire[7:0] dis_data;	//VGA��ʾ����

//------------------------------------------------
//����ϵͳ��λ�źź�PLL����ģ��
sys_ctrl		uut_sysctrl(
					.clk(clk),
					.rst_n(rst_n),
					.sys_rst_n(sys_rst_n),
					.clk_50m(clk_50m),
					.clk_100m(clk_100m),
					.sdram_clk(sdram_clk)
					);

//------------------------------------------------
//����SDRAM��װ����ģ��
sdram_top		uut_sdramtop(				// SDRAM
							.clk(clk_100m),
							.rst_n(sys_rst_n),
							.sdram_wr_req(sdram_wr_req),
							.sdram_rd_req(sdram_rd_req),
							.sdram_wr_ack(sdram_wr_ack),
							.sdram_rd_ack(sdram_rd_ack),	
							.sys_wraddr(sys_wraddr),
							.sys_rdaddr(sys_rdaddr),
							.sys_data_in(sys_data_in),
							.sys_data_out(sys_data_out),
							.sdwr_byte(sdwr_byte),
							.sdrd_byte(sdrd_byte),	
							//.sdram_clk(sdram_clk),
							//.sdram_busy(sdram_busy),
							.sdram_cke(sdram_cke),
							.sdram_cs_n(sdram_cs_n),
							.sdram_ras_n(sdram_ras_n),
							.sdram_cas_n(sdram_cas_n),
							.sdram_we_n(sdram_we_n),
							.sdram_ba(sdram_ba),
							.sdram_addr(sdram_addr),
							.sdram_data(sdram_data)
						//	.sdram_udqm(sdram_udqm),
						//	.sdram_ldqm(sdram_ldqm)
					);
	

//------------------------------------------------
//��дSDRAM���ݻ���FIFOģ������	
sdfifo_ctrl			uut_sdffifoctrl(
						.clk_50m(clk_50m),
						.clk_100m(clk_100m),
						.rst_n(sys_rst_n),
						.wrf_din(wrf_din),
						.wrf_wrreq(wrf_wrreq),
						.sdram_wr_ack(sdram_wr_ack),
						.sys_wraddr(sys_wraddr),
						.sys_rdaddr(sys_rdaddr),
						.sys_data_in(sys_data_in),
						.sdram_wr_req(sdram_wr_req),
						.sys_data_out(sys_data_out),
						.rdf_rdreq(rdf_rdreq),
						.sdram_rd_ack(sdram_rd_ack),
						.sdram_rd_req(sdram_rd_req),
						.vga_valid(vga_valid),
						.dis_data(dis_data),
						.sdwrad_clr(sdwrad_clr)
						);	
						
//------------------------------------------------
//����VGA��ʾģ��
vga_ctrl		uut_vgactrl(	
						.clk(clk_50m),
						.rst_n(sys_rst_n),
						.disp_ctrl(1'b1),	//ʼ�տ���ʾ
						.dis_data(dis_data),
						.vga_valid(vga_valid),
						.rdf_rdreq(rdf_rdreq),
						.hsync(hsync),
						.vsync(vsync),
						.vga_r(vga_r),
						.vga_g(vga_g),
						.vga_b(vga_b)
					);

//------------------------------------------------
//����sd����ģ��
sdcard_ctrl		uut_sdcartctrl(
					.clk(clk_50m),
					.rst_n(sys_rst_n),
					.spi_miso(spi_miso),
					.spi_mosi(spi_mosi),
					.spi_clk(spi_clk),
					.spi_cs_n(spi_cs_n),
					.sd_dout(wrf_din[7:0]),		//8bit
					.sd_fifowr(wrf_wrreq),
					.sdwrad_clr(sdwrad_clr)
				);

endmodule
