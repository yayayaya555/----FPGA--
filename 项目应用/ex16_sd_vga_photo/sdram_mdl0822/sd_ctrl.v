`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.05
// Design Name	: 
// Module Name	: sd_ctrl
// Project Name	: sdrsvgaprj
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sd_ctrl(
			clk,rst_n,
			spi_cs_n,
			spi_tx_en,spi_tx_rdy,spi_rx_en,spi_rx_rdy,
			spi_tx_db,spi_rx_db,
			sd_dout,sd_fifowr,sdwrad_clr
		);

input clk;		//FPAG����ʱ���ź�25MHz
input rst_n;	//FPGA���븴λ�ź�

output spi_cs_n;	//SPI���豸ʹ���źţ������豸����

output spi_tx_en;		//SPI���ݷ���ʹ���źţ�����Ч
input spi_tx_rdy;		//SPI���ݷ�����ɱ�־λ������Ч
output spi_rx_en;		//SPI���ݽ���ʹ���źţ�����Ч
input spi_rx_rdy;		//SPI���ݽ�����ɱ�־λ������Ч
output[7:0] spi_tx_db;	//SPI���ݷ��ͼĴ���
input[7:0] spi_rx_db;	//SPI���ݽ��ռĴ���

output[7:0] sd_dout;	//��SD�����Ĵ�����FIFO����
output sd_fifowr;		//sd��������д��FIFOʹ���źţ�����Ч
output sdwrad_clr;		//SDRAMд��������ź����㸴λ�źţ�����Ч

/*��������*/
//���ڲ�ͬ��SD���ļ�ϵͳ�п���ΪFAT16/32���洢����СҲ�п��ܲ�ͬ���ճ��������ݵ�ַ�Ĳ�ͬ
//�ù���û�ж��ļ�ϵͳ��������ƣ�������Ҫ�����winhex�¶�����ʹ�õ�SD�������²������������
//Ҫ��SD��ʹ��ǰ��ø�ʽ����Ȼ�����10��800*600��8λͼƬ
parameter	P0_ADDR		= 32'h0004_6600,		//��һ��ͼƬP0����������ַ
			P_MEM		= 32'h0007_5800,		//һ��800*600��8λͼƬ��ʽ��SD������ռ�õĵ�ַ�ռ�
			LAST_ADDR	= 32'h004d_d600;		//10��ͼƬ�����һ����ַ
			
//assign sdwrad_clr = done_5s;
//------------------------------------------------------
//SD�ϵ��ʼ��
//	1. �ʵ���ʱ�ȴ�SD����
//	2. ����74+��spi_clk���ұ���spi_cs_n=1,spi_mosi=1 
//	3. ����CMD0����ȴ���ӦR1=8'h01: ������λ��IDLE״̬
//	4. ����CMD1����ȴ���ӦR1=8'h00: ����ĳ�ʼ������
//	5. ����CMD16����ȴ���ӦR1=8'h00: ����һ�ζ�дBLOCK�ĳ���Ϊ512���ֽ�
//SD���ݶ�ȡ����
//	1. ��������CMD17
//	2. ���ն�������ʼ����0xfe
//	3. ��ȡ512Byte�����Լ�2Byte��CRC
//------------------------------------------------------
//�ϵ���ʱ�ȴ�����
reg[9:0] delay_cnt;	//10bit��ʱ��������������1000��40ns*1000=40us	

always @(posedge clk or negedge rst_n)
	if(!rst_n) delay_cnt <= 10'd0;
	else if(delay_cnt < 10'd1000) delay_cnt <= delay_cnt+1'b1;

wire delay_done = (delay_cnt == 10'd1000);	//40us��ʱʱ����ɱ�־λ������Ч	

//------------------------------------------------------
//sd״̬������
reg[3:0] sdinit_cstate;		//sd��ʼ����ǰ״̬�Ĵ���
reg[3:0] sdinit_nstate;		//sd��ʼ����һ״̬�Ĵ���

parameter	SDINIT_RST	= 4'd0,		//��λ�ȴ�״̬
			SDINIT_CLK	= 4'd1,		//74+ʱ�Ӳ���״̬
			SDINIT_CMD0 = 4'd2,		//����CMD0����״̬
			SDINIT_CMD55 = 4'd3,	//����CMD55����״̬
			SDINIT_ACMD41 = 4'd4,	//����ACMD41����״̬
			SDINIT_CMD1 = 4'd5,		//����CMD1����״̬
			SDINIT_CMD16 = 4'd6,	//����CMD16����״̬
			SD_IDLE 	= 4'd7,		//sd��ʼ�������������״̬
			SD_RD_PT	= 4'd8,		//sd��ȡPartition Table
			SD_RD_BPB	= 4'd9,		//sd��ȡ������״̬
			SD_DELAY	= 4'd10;	//sd���������ʱ�ȴ�״̬

//״̬ת��
always @(posedge clk or negedge rst_n)
	if(!rst_n) sdinit_cstate <= SDINIT_RST;
	else sdinit_cstate <= sdinit_nstate;

//״̬����
always @(sdinit_cstate or retry_rep or delay_done or nclk_cnt 
			or cmd_rdy or spi_rx_dbr or arg or arg_r or done_5s) begin
	case(sdinit_cstate)
		SDINIT_RST: begin
			if(delay_done) sdinit_nstate <= SDINIT_CLK;	//�ϵ��40us��ʱ��ɣ�����74+CLK״̬
			else sdinit_nstate <= SDINIT_RST;	//�ȴ��ϵ��40us��ʱ���
		end
		SDINIT_CLK:	begin
			if(cmd_rdy) sdinit_nstate <= SDINIT_CMD0;	//74+CLK���
			else sdinit_nstate <= SDINIT_CLK;
		end
		SDINIT_CMD0: begin
			if(cmd_rdy && (spi_rx_dbr == 8'h01)) sdinit_nstate <= SDINIT_CMD55;
			else sdinit_nstate <= SDINIT_CMD0;
		end
		SDINIT_CMD55: begin
			if(cmd_rdy && (spi_rx_dbr == 8'h01)) sdinit_nstate <= SDINIT_ACMD41;
			else sdinit_nstate <= SDINIT_CMD55;
		end
		SDINIT_ACMD41: begin
			if(retry_rep == 8'hff) sdinit_nstate <= SDINIT_CMD55;	///////////��Ӧ��ʱ������IDLE���·������� 
			else if(cmd_rdy && spi_rx_dbr == 8'h01) sdinit_nstate <= SDINIT_CMD55; 
			else if(cmd_rdy && spi_rx_dbr == 8'h00) sdinit_nstate <= SDINIT_CMD16;
			else sdinit_nstate <= SDINIT_ACMD41;	
		end
	/*	SDINIT_CMD1: begin
			if(cmd_rdy) sdinit_nstate <= SDINIT_CMD16;
			else sdinit_nstate <= SDINIT_CMD1;
		end*/
		SDINIT_CMD16: begin
			if(cmd_rdy && (spi_rx_dbr == 8'h00)) sdinit_nstate <= SD_IDLE;
			else sdinit_nstate <= SDINIT_CMD16;
		end
		SD_IDLE: sdinit_nstate <= SD_RD_PT;
		SD_RD_PT: begin
			if(cmd_rdy) sdinit_nstate <= SD_RD_BPB;
			else sdinit_nstate <= SD_RD_PT;
		end
		SD_RD_BPB: begin
			if(cmd_rdy && arg == arg_r+P_MEM-32'h0000_0200) sdinit_nstate <= SD_DELAY;
			else sdinit_nstate <= SD_RD_BPB;
		end
		SD_DELAY: begin
			if(done_5s) sdinit_nstate <= SD_IDLE;	//��ʾ��һ��ͼƬ
			else sdinit_nstate <= SD_DELAY;
		end
	default: sdinit_nstate <= SDINIT_RST;
	endcase
end

//���ݿ���
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			cmd <= 6'd0;	//��������Ĵ���
			arg <= 32'd0;	//���Ͳ����Ĵ���
			crc <= 8'd0;	//����CRCУ����
		end
	else
		case(sdinit_nstate)
			SDINIT_CMD0: begin
				cmd <= 6'd0;	//��������Ĵ���CMD0
				arg <= 32'd0;	//���Ͳ����Ĵ���	
				crc <= 8'h95;	//����CMD0 CRCУ����				
			end		
			SDINIT_CMD55: begin
				cmd <= 6'd55;	//��������Ĵ���CMD55
				arg <= 32'd0;	//���Ͳ����Ĵ���
				//crc <= 8'hff;	//����CRCУ����		
			end
			SDINIT_ACMD41: begin
				cmd <= 6'd41;	//��������Ĵ���ACMD41
				arg <= 32'd0;	//���Ͳ����Ĵ���
				//crc <= 8'hff;	//����CRCУ����		
			end	
			SDINIT_CMD1: begin
				cmd <= 6'd1;	//��������Ĵ���
				arg <= 32'd0;	//���Ͳ����Ĵ���
				//crc <= 8'hff;	//����CRCУ����					
			end
			SDINIT_CMD16: begin
				cmd <= 6'd16;	//��������Ĵ���CMD16
				arg <= 32'd512;	//���Ͳ����Ĵ���512Byte		
				crc <= 8'hff;				
			end	
			SD_IDLE: begin
				cmd <= 6'd0;	
				if(cmd_rdy) arg <= P0_ADDR;//32'h0004_6600;	//��bmp0���ݴ�ŵĵ�1������ַ			
			end		
			SD_RD_PT: begin
				cmd <= 6'd17;	//��������CMD17		
				arg_r <= arg;
				//if(cmd_rdy) arg <= arg+32'h0000_0200;
			end
			SD_RD_BPB: begin
				cmd <= 6'd17;	//��������CMD17
				if(cmd_rdy) arg <= arg+32'h0000_0200;	//������ȡbmp���ݴ�ŵĵ�2-03ABH����	
			end
			SD_DELAY: begin
				cmd <= 6'd0;
				//arg <= 32'h0004_6600;	//��ȡbmp���ݴ�ŵĵ�1����	
				//arg <= 32'h000b_be00;
				if(sdwrad_clr) begin	//��ʾ��һ��ͼƬ,�̶�10��ͼƬѭ����ʾ
					if(arg == LAST_ADDR-32'h0000_0200) arg <= P0_ADDR;//32'h0004_6600;
					else arg <= arg_r+P_MEM;
				end
			end
		default: begin
					cmd <= 6'd0;	//��������Ĵ���
					arg <= 32'd0;	//���Ͳ����Ĵ���			
				end
		endcase
end

//------------------------------------------------------
//2009.05.19	���5.4s��ʱ�л�ͼƬָ��
reg[27:0] cnt5s;	//5.4s��ʱ������
reg[31:0] arg_r;	//��ʼ������ַ�Ĵ���

	//5.4s����
always @(posedge clk or negedge rst_n)
	if(!rst_n) cnt5s <= 28'd0;
	else if(sdinit_nstate == SD_DELAY) cnt5s <= cnt5s+1'b1;
	else cnt5s <= 28'd0;

wire sdwrad_clr = (cnt5s == 28'hffffff0);	//SDRAMд��������ź����㸴λ�źţ�����Ч
wire done_5s = (cnt5s == 28'hfffffff);	//5.4s��ʱ��������Чһ��ʱ������

//------------------------------------------------------
//SD����CMD���Ϳ���
//	1. ����8��ʱ������
//  2. SD��ƬѡCS����,��Ƭѡ��Ч
//  3. ��������6���ֽ�����
//	4. ����1���ֽ���Ӧ����
//	5. SD��ƬѡCS����,���ر�SD��
/*		�����ܹ�6���ֽ������ʽ:
        0 -- start bit 
        1 -- host
        bit5-0 --  command
        bit31-0 -- argument
        bit6-0 -- CRC7
        1 -- end bit   
*/
//------------------------------------------------------
//����sd����״̬������
reg[5:0] cmd;	//��������Ĵ���
reg[31:0] arg;	//���Ͳ����Ĵ���
reg[7:0] crc;	//����CRCУ����

reg spi_cs_nr;	//SPI���豸ʹ���źţ������豸����
reg spi_tx_enr;	//SPI���ݷ���ʹ���źţ�����Ч
reg spi_rx_enr;	//SPI���ݽ���ʹ���źţ�����Ч
reg[7:0] spi_tx_dbr;	//SPI���ݷ��ͼĴ���
reg[7:0] spi_rx_dbr;	//SPI���ݽ��ռĴ���
reg[3:0] nclk_cnt;		//74+CLK�������ڼ�����
reg[7:0] wait_cnt8;		//�����������ȴ�������
reg[9:0] cnt512;	//��ȡ512B������
reg[7:0] retry_rep;		//�ظ���ȡrespone������
reg[7:0] retry_cmd;		//�ظ���ǰ���������

assign spi_cs_n = spi_cs_nr;
assign spi_tx_en = spi_tx_enr;
assign spi_rx_en = spi_rx_enr;
assign spi_tx_db = spi_tx_dbr;
assign sd_dout = spi_rx_dbr;
	//ÿ����һ���ֽ����ݣ���λ�ø�һ��ʱ�����ڣ���512B
assign sd_fifowr = (spi_rx_rdy & ~spi_rx_enr & (cmd_cstate == CMD_RD) & (cnt512 < 10'd513));

wire cmd_clk = (sdinit_cstate == SDINIT_CLK);	//�����ϵ��ʼ��ʱ��74+CLK����״̬��־λ
wire cmd_en = ((sdinit_cstate == SDINIT_CMD0) | (sdinit_cstate == SDINIT_CMD55) | (sdinit_cstate == SDINIT_ACMD41)//(sdinit_cstate == SDINIT_CMD1) 
					| (sdinit_cstate == SDINIT_CMD16));	//�����ʹ�ܱ�־λ,����Ч
wire cmd_rdboot_en = (sdinit_cstate == SD_RD_BPB) | (sdinit_cstate == SD_RD_PT);	//��ȡSD������ʹ���źţ�����Ч	
wire cmd_rdy = ((cmd_nstate == CMD_CLKE) & spi_tx_rdy & spi_tx_enr);	//�������ɱ�־λ,����Ч

reg[3:0] cmd_cstate;	//�������ǰ״̬�Ĵ���
reg[3:0] cmd_nstate;	//����������һ״̬�Ĵ���
parameter	CMD_IDLE	= 4'd0,		//������ͣ��ȴ�״̬
			CMD_NCLK	= 4'd1,		//�ϵ��ʼ��ʱ��Ҫ����74+CLK״̬
			CMD_CLKS	= 4'd2,		//����8��CLK״̬
			CMD_STAR	= 4'd3,		//������ʼ�ֽ�״̬
			CMD_ARG1	= 4'd4,		//����arg[31:24]״̬
			CMD_ARG2	= 4'd5,		//����arg[23:16]״̬
			CMD_ARG3	= 4'd6,		//����arg[15:8]״̬
			CMD_ARG4	= 4'd7,		//����arg[7:0]״̬
			CMD_END		= 4'd8,		//���ͽ����ֽ�״̬
			CMD_RES		= 4'd9,		//������Ӧ�ֽ�
			CMD_CLKE	= 4'd10,	//����8��CLK״̬
			CMD_RD		= 4'd11,	//��512Byte״̬
			CMD_DELAY	= 4'd12;	//��д���������ʱ�ȴ�״̬

//״̬ת��
always @(posedge clk or negedge rst_n)
	if(!rst_n) cmd_cstate <= CMD_IDLE;
	else cmd_cstate <= cmd_nstate;

//״̬����
always @(cmd_cstate or wait_cnt8 or cmd_clk or cmd_en or spi_tx_rdy or spi_rx_rdy or nclk_cnt or retry_rep
			or sdinit_cstate or spi_tx_enr or spi_rx_enr or cmd_rdboot_en or cnt512 or spi_rx_dbr) begin
	case(cmd_cstate)
			CMD_IDLE: begin
				if(wait_cnt8 == 8'hff)
					if(cmd_clk) cmd_nstate <= CMD_NCLK;
					else if(cmd_en | cmd_rdboot_en) cmd_nstate <= CMD_STAR;
					else cmd_nstate <= CMD_IDLE; 
				else cmd_nstate <= CMD_IDLE;
			end
			CMD_NCLK: begin
				if(spi_tx_rdy && (nclk_cnt == 4'd11) && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_CLKE;
				else cmd_nstate <= CMD_NCLK;
			end
			CMD_CLKS: begin
				if(spi_tx_rdy && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_STAR;
				else cmd_nstate <= CMD_CLKS;
			end
			CMD_STAR: begin
				if(spi_tx_rdy && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_ARG1;
				else cmd_nstate <= CMD_STAR;
			end
			CMD_ARG1: begin
				if(spi_tx_rdy && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_ARG2;
				else cmd_nstate <= CMD_ARG1;
			end
			CMD_ARG2: begin
				if(spi_tx_rdy && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_ARG3;
				else cmd_nstate <= CMD_ARG2;
			end
			CMD_ARG3: begin
				if(spi_tx_rdy && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_ARG4;
				else cmd_nstate <= CMD_ARG3;
			end
			CMD_ARG4: begin
				if(spi_tx_rdy && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_END;
				else cmd_nstate <= CMD_ARG4;
			end
			CMD_END: begin
				if(spi_tx_rdy && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_RES;
				else cmd_nstate <= CMD_END;
			end
			CMD_RES: begin
				if(retry_rep == 8'hff) cmd_nstate <= CMD_IDLE;	//��Ӧ��ʱ������IDLE���·�������
				if(spi_rx_rdy && (!spi_tx_enr & !spi_rx_enr)) begin
					case(sdinit_cstate) 		
						SD_RD_PT,SD_RD_BPB: 
									if(spi_rx_dbr == 8'hfe) cmd_nstate <= CMD_RD;	//���յ�RD�������ʼ�ֽ�8'hfe,������ȡ�����512B
									else cmd_nstate <= CMD_RES; 
						SDINIT_CMD0,SDINIT_CMD55,SDINIT_ACMD41,SDINIT_CMD16:
									if(spi_rx_dbr == 8'hff) cmd_nstate <= CMD_RES;	
									else cmd_nstate <= CMD_CLKE;	//������ȷ��Ӧ,������ǰ����
						default: cmd_nstate <= CMD_CLKE;
						endcase
				end
				else cmd_nstate <= CMD_RES;			
			end
			CMD_CLKE: begin
				if(spi_tx_rdy && (!spi_tx_enr & !spi_rx_enr)) cmd_nstate <= CMD_IDLE;
				else cmd_nstate <= CMD_CLKE;
			end
			CMD_RD: begin
				if(cnt512 == 10'd514) cmd_nstate <= CMD_DELAY;	//ֱ����ȡ512�ֽ�+2�ֽ�CRC���
				else cmd_nstate <= CMD_RD;
			end
			CMD_DELAY: begin
				cmd_nstate <= CMD_CLKE;
			end
		default: ;
		endcase
end

//���ݿ���
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			spi_cs_nr <= 1'b1;
			spi_tx_enr <= 1'b0;
			spi_rx_enr <= 1'b0;
			spi_tx_dbr <= 8'hff;
			nclk_cnt <= 4'd0;	//74+CLK�������ڼ���������
			wait_cnt8 <= 8'hff;	//�����������ȴ�������
			cnt512 <= 10'd0;
			retry_rep <= 8'd0;
			retry_cmd <= 8'd0;	//��ǰCMD���ʹ�������������
		end
	else 
		case(cmd_nstate)
			CMD_IDLE: begin
				wait_cnt8 <= wait_cnt8+1'b1;
				if(wait_cnt8 > 8'hfd) begin	
					if(cmd_clk) begin
						spi_cs_nr <= 1'b1;
						spi_tx_enr <= 1'b0;
						spi_rx_enr <= 1'b0;
						spi_tx_dbr <= 8'hff;
						cnt512 <= 10'd0;
						end
					else if(cmd_en | cmd_rdboot_en) begin
						cnt512 <= 10'd0;
						spi_cs_nr <= 1'b1;	//SD��ƬѡCS��Ч
						spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
						spi_rx_enr <= 1'b0;
						spi_tx_dbr <= {2'b01,cmd};	//��ʼ�ֽ������������ݷ��ͼĴ���						
						end
					end
				else begin
					spi_cs_nr <= 1'b1;
					spi_tx_enr <= 1'b0;
					spi_rx_enr <= 1'b0;
					spi_tx_dbr <= 8'hff;
					cnt512 <= 10'd0;	
					retry_rep <= 8'd0;			
					end
			end
			CMD_NCLK: begin
				if(spi_tx_rdy) begin
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					if(spi_tx_enr) nclk_cnt <= nclk_cnt+1'b1;	//74+CLK�������ڼ���������
					end
				else if(!spi_tx_enr) begin
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����				
					end			
			end			
			CMD_CLKS: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					spi_rx_enr <= 1'b0;
					if(spi_tx_enr) spi_tx_dbr <= {2'b01,cmd};	//��ʼ�ֽ������������ݷ��ͼĴ���
					end
				else begin
					spi_cs_nr <= 1'b1;
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����
					spi_rx_enr <= 1'b0;				
					end
			end
			CMD_STAR: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					spi_rx_enr <= 1'b0;
					if(spi_tx_enr) spi_tx_dbr <= arg[31:24];	//arg[31:24]�����������ݷ��ͼĴ���
					end
				else begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����
					spi_rx_enr <= 1'b0;					
					end
			end
			CMD_ARG1: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					spi_rx_enr <= 1'b0;
					if(spi_tx_enr) spi_tx_dbr <= arg[23:16];	//arg[23:16]�����������ݷ��ͼĴ���
					end
				else begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����
					spi_rx_enr <= 1'b0;					
					end
			end
			CMD_ARG2: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					spi_rx_enr <= 1'b0;
					if(spi_tx_enr) spi_tx_dbr <= arg[15:8];	//arg[15:8]�����������ݷ��ͼĴ���
					end
				else begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����
					spi_rx_enr <= 1'b0;					
					end
			end
			CMD_ARG3: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					spi_rx_enr <= 1'b0;
					if(spi_tx_enr) spi_tx_dbr <= arg[7:0];	//arg[7:0]�����������ݷ��ͼĴ���					
					end
				else begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����
					spi_rx_enr <= 1'b0;					
					end
			end
			CMD_ARG4: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					spi_rx_enr <= 1'b0;
					if(spi_tx_enr) spi_tx_dbr <= crc;	//����CRCУ����		//8'h95;	//������RESET��Ч��CRCЧ����
					end
				else begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����
					spi_rx_enr <= 1'b0;					
					end
			end	
			CMD_END: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					spi_rx_enr <= 1'b0;
					if(spi_tx_enr) begin
						spi_tx_dbr <= 8'hff;
						retry_cmd <= retry_cmd+1'b1;	//��ǰCMD���ʹ�����������1
						end
					end
				else begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����
					spi_rx_enr <= 1'b0;					
					end
			end						
			CMD_RES: begin
				if(spi_rx_rdy) begin
					spi_cs_nr <= 1'b0;
					spi_tx_enr <= 1'b0;	
					spi_rx_enr <= 1'b0;	//SPI����ʹ�ܹر�
					spi_tx_dbr <= 8'hff;					
					spi_rx_dbr <= spi_rx_db;	//����SPI��Ӧ�ֽ�����
					if(spi_rx_enr) retry_rep <= retry_rep+1'b1;
					end
				else begin
					spi_cs_nr <= 1'b0;	//SD��ƬѡCS��Ч	
					spi_tx_enr <= 1'b1;	//SPI����ʹ�ܿ���	
					spi_rx_enr <= 1'b1;	//SPI����ʹ�ܿ���				
					end
			end
			CMD_CLKE: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b1;
					spi_tx_enr <= 1'b0;	//SPI����ʹ����Чλ��ʱ�ر�
					spi_rx_enr <= 1'b0;
					if(spi_tx_enr) spi_tx_dbr <= 8'hff;
					retry_cmd <= 8'd0;	//��ǰCMD���ʹ�������������
					end
				else begin
					spi_cs_nr <= 1'b1;
					spi_tx_enr <= 1'b1;	//SPI����ʹ����Чλ����
					spi_rx_enr <= 1'b0;
					spi_tx_dbr <= 8'hff;
					wait_cnt8 <= 4'd0;
					end
			end
			CMD_RD: begin
				if(spi_tx_rdy) begin
					spi_cs_nr <= 1'b0;
					spi_tx_enr <= 1'b0;	
					spi_rx_enr <= 1'b0;		//SPI����ʹ����ʱ�ر�
					spi_tx_dbr <= 8'hff;			
					spi_rx_dbr <= spi_rx_db;	//����SPI��Ӧ�ֽ�����
					if(spi_rx_enr) cnt512 <= cnt512+1'b1;					
				end
				else begin
					spi_cs_nr <= 1'b0;
					spi_tx_enr <= 1'b0;	
					spi_rx_enr <= 1'b1;	//SPI����ʹ�ܿ���
					spi_tx_dbr <= 8'hff;							
				end
			end
			CMD_DELAY: begin
				spi_cs_nr <= 1'b1;
				spi_tx_enr <= 1'b0;
				spi_rx_enr <= 1'b0;
				spi_tx_dbr <= 8'hff;		
			end
		default: begin
			spi_cs_nr <= 1'b1;
			spi_tx_enr <= 1'b0;
			spi_rx_enr <= 1'b0;
			spi_tx_dbr <= 8'hff;
		end
		endcase
end

//------------------------------------------------------
//


//------------------------------------------------------
//















endmodule
