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
module johnson(
			clk,rst_n,
			key1,key2,key3,
			led0,led1,led2,led3
		);

input clk;		//��ʱ�ӣ�50MHz
input rst_n;	//�͵�ƽ��λ
input key1,key2,key3;			// �����ӿ�
output led0,led1,led2,led3;		// LED�Ƚӿ�

//------------------------------------
reg[23:0] delay;	//��ʱ������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) delay <= 0;
	else delay <= delay+1;	//���ϼ���������Ϊ320ms

reg[2:0] key_value;		//��ֵ�Ĵ���

always @ (posedge clk or negedge rst_n)
	if(!rst_n) key_value <= 3'b111;	
	else if(delay == 24'hffffff) key_value <= {key3,key2,key1};	//delay 320ms��������ֵ

//-------------------------------------
reg[2:0] key_value_r;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) key_value_r <= 3'b111;
	else key_value_r <= key_value;

wire[2:0] key_change;	//�ж�ǰ��20ms�ļ�ֵ�Ƿ����˸ı䣬���ǣ���key_change�ø�

assign key_change = key_value_r & (~key_value);	//check key_value negedge per clk
//------------------------------------
reg stop_start,left_right;	//��ˮ�ƿ���λ

always @ (posedge clk or negedge rst_n)
	if(!rst_n) begin 
		stop_start <= 1;
		left_right <= 1;
		end
	else
		if(key_change[2]) stop_start <= ~stop_start;	//��ʼ��������λ
		else if(key_change[1]) left_right <= 1;			//��ˮ�Ʒ������
		else if(key_change[0]) left_right <= 0;			//��ˮ�Ʒ������

//-------------------------------------
reg[3:0] led_value_r;	// LEDֵ�Ĵ���

always @ (posedge clk or negedge rst_n)
	if(!rst_n) led_value_r <= 4'b1110;
	else if(delay == 24'h3fffff && stop_start)	//��ˮ�ƿ���
		case (left_right)	//�������
			1: led_value_r <= {led_value_r[2:0],led_value_r[3]};	//����
 		    0: led_value_r <= {led_value_r[0],led_value_r[3:1]};	//����
			default: ;
			endcase

assign {led3,led2,led1,led0} = ~led_value_r;

endmodule
