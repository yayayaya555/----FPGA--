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
module sram_test(
				clk,rst_n,led,
				sram_addr,sram_wr_n,sram_data
			);

input clk;		// 50MHz
input rst_n;	//�͵�ƽ��λ
output led;		// LED1

	// CPLD��SRAM�ⲿ�ӿ�
output[14:0] sram_addr;	// SRAM��ַ����
output sram_wr_n;		// SRAMдѡͨ
inout[7:0] sram_data;	// SRAM��������

//-------------------------------------------------------
reg[25:0] delay;	//��ʱ������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) delay <= 26'd0;
	else delay <= delay+1;	//���ϼ���������ԼΪ1.28s
	
//-------------------------------------------------------
reg[7:0] wr_data;	// SRAMд����������	
reg[7:0] rd_data;	// SRAM�������� 
reg[14:0] addr_r;	// SRAM��ַ����
wire sram_wr_req;	// SRAMд�����ź�
wire sram_rd_req;	// SRAM�������ź�
reg led_r;			// LED�Ĵ���

assign sram_wr_req = (delay == 26'd9999);	//����д�����ź�
assign sram_rd_req = (delay == 26'd19999);	//�����������ź�
	
always @ (posedge clk or negedge rst_n)
	if(!rst_n) wr_data <= 8'd0;
	else if(delay == 26'd29999) wr_data <= wr_data+1'b1;	//д������ÿ1.28s����1
always @ (posedge clk or negedge rst_n)
	if(!rst_n) addr_r <= 15'd0;
	else if(delay == 26'd29999) addr_r <= addr_r+1'b1;	//д���ַÿ1.28s����1
	
always @ (posedge clk or negedge rst_n)
	if(!rst_n) led_r <= 1'b0;
	else if(delay == 26'd20099) begin	//ÿ1.28s�Ƚ�һ��ͬһ��ַд��Ͷ���������
			if(wr_data == rd_data) led_r <= 1'b1;	//д��Ͷ�������һ�£�LED����
			else led_r <= 1'b0;						//д��Ͷ������ݲ�ͬ��LEDϨ��
		end
assign led = led_r;

//-------------------------------------------------------
`define	DELAY_80NS		(cnt==3'd7)

reg[2:0] cnt;	//��ʱ������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt <= 3'd0;
	else if(cstate == IDLE) cnt <= 3'd0;
	else cnt <= cnt+1'b1;
			
//------------------------------------
parameter	IDLE	= 4'd0,
			WRT0	= 4'd1,
			WRT1	= 4'd2,
			REA0	= 4'd3,
			REA1	= 4'd4;

reg[3:0] cstate,nstate;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cstate <= IDLE;
	else cstate <= nstate;

always @ (cstate or sram_wr_req or sram_rd_req or cnt)
	case (cstate)
			IDLE: if(sram_wr_req) nstate <= WRT0;		//����д״̬
				  else if(sram_rd_req) nstate <= REA0;	//�����״̬
				  else nstate <= IDLE;
			WRT0: if(`DELAY_80NS) nstate <= WRT1;
				  else nstate <= WRT0;				//��ʱ�ȴ�160ns	
			WRT1: nstate <= IDLE;			//д����������
			REA0: if(`DELAY_80NS) nstate <= REA1;
				  else nstate <= REA0;				//��ʱ�ȴ�160ns
			REA1: nstate <= IDLE;			//������������
		default: nstate <= IDLE;
		endcase
			
//-------------------------------------

assign sram_addr = addr_r;	// SRAM��ַ��������

//-------------------------------------			
reg sdlink;				// SRAM�������߿����ź�

always @ (posedge clk or negedge rst_n)
	if(!rst_n) rd_data <= 8'd0;
	else if(cstate == REA1) rd_data <= sram_data;		//��������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) sdlink <=1'b0;
	else
		case (cstate)
			IDLE: if(sram_wr_req) sdlink <= 1'b1;		//��������д״̬
				  else if(sram_rd_req) sdlink <= 1'b0;	//���뵥�ֽڶ�״̬
				  else sdlink <= 1'b0;
			WRT0: sdlink <= 1'b1;
			default: sdlink <= 1'b0;
			endcase

assign sram_data = sdlink ? wr_data : 8'hzz;	// SRAM��ַ��������			
assign sram_wr_n = ~sdlink;
			
endmodule
