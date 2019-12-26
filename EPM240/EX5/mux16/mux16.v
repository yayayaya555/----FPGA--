`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    23:08:36 04/21/08
// Design Name:    
// Module Name:    mux_16bit
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
module mux16(
			clk,rst_n,
			start,ain,bin,yout,done
		);
		
input clk;		//оƬ��ʱ���źš�
input rst_n;	//�͵�ƽ��λ�������źš�����Ϊ0��ʾоƬ��λ������Ϊ1��ʾ��λ�ź���Ч��
input start; 	//оƬʹ���źš�����Ϊ0��ʾ�ź���Ч������Ϊ1��ʾоƬ��������ܽŵó����ͱ������������˻���λ���㡣
input[15:0] ain;	//����a������������������λ��Ϊ16bit.
input[15:0] bin;	//����b����������������λ��Ϊ16bit.
output[31:0] yout;	//�˻������������λ��Ϊ32bit.
output done;		//оƬ�����־�źš�����Ϊ1��ʾ�˷��������.

reg[15:0] areg;	//����a�Ĵ���
reg[15:0] breg;	//����b�Ĵ���
reg[31:0] yout_r;	//�˻��Ĵ���
reg done_r;
reg[4:0] i;		//��λ�����Ĵ���


//------------------------------------------------
//����λ����
always @(posedge clk or negedge rst_n)
	if(!rst_n) i <= 5'd0;
	else if(start && i < 5'd17) i <= i+1'b1; 
	else if(!start) i <= 5'd0;

//------------------------------------------------
//�˷�������ɱ�־�źŲ���
always @(posedge clk or negedge rst_n)
	if(!rst_n) done_r <= 1'b0;
	else if(i == 5'd16) done_r <= 1'b1;		//�˷�������ɱ�־
	else if(i == 5'd17) done_r <= 1'b0;		//��־λ����

assign done = done_r;

//------------------------------------------------
//ר�üĴ���������λ�ۼ�����
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin 
			areg <= 16'h0000;
			breg <= 16'h0000;
			yout_r <= 32'h00000000;
		end
	else if(start) begin		//��������
			if(i == 5'd0) begin	//���������������
					areg <= ain;
					breg <= bin;
				end
			else if(i > 5'd0 && i < 5'd16) begin
					if(areg[i-1]) yout_r = {1'b0,yout[30:15]+breg,yout_r[14:1]};	//�ۼӲ���λ
					else yout_r <= yout_r>>1;	//��λ���ۼ�
				end
			else if(i == 5'd16 && areg[15]) yout_r[31:16] <= yout_r[31:16]+breg;	//�ۼӲ���λ
		end
end

assign yout = yout_r;

endmodule

