`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:		 ��Ȩ
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

//˵��������������������ĳһ�������º���Ӧ��LED��������
//		�ٴΰ��º�LEDϨ�𣬰�������LED����

module sw_debounce(
    		clk,rst_n,
			sw1_n,sw2_n,sw3_n,
	   		led_d1,led_d2,led_d3
    		);

input   clk;	//��ʱ���źţ�50MHz
input   rst_n;	//��λ�źţ�����Ч
input   sw1_n,sw2_n,sw3_n; 	//���������������ͱ�ʾ����
output  led_d1,led_d2,led_d3;	//��������ܣ��ֱ��ɰ�������

//---------------------------------------------------------------------------
reg[2:0] key_rst;  

always @(posedge clk  or negedge rst_n)
    if (!rst_n) key_rst <= 3'b111;
    else key_rst <= {sw3_n,sw2_n,sw1_n};

reg[2:0] key_rst_r;       //ÿ��ʱ�����ڵ������ؽ�low_sw�ź����浽low_sw_r��

always @ ( posedge clk  or negedge rst_n )
    if (!rst_n) key_rst_r <= 3'b111;
    else key_rst_r <= key_rst;
   
//���Ĵ���key_rst��1��Ϊ0ʱ��led_an��ֵ��Ϊ�ߣ�ά��һ��ʱ������ 
wire[2:0] key_an = key_rst_r & ( ~key_rst);

//---------------------------------------------------------------------------
reg[19:0]  cnt;	//�����Ĵ���

always @ (posedge clk  or negedge rst_n)
    if (!rst_n) cnt <= 20'd0;	//�첽��λ
	else if(key_an) cnt <=20'd0;
    else cnt <= cnt + 1'b1;
  
reg[2:0] low_sw;

always @(posedge clk  or negedge rst_n)
    if (!rst_n) low_sw <= 3'b111;
    else if (cnt == 20'hfffff) 	//��20ms��������ֵ���浽�Ĵ���low_sw��	 cnt == 20'hfffff
      low_sw <= {sw3_n,sw2_n,sw1_n};
      
//---------------------------------------------------------------------------
reg  [2:0] low_sw_r;       //ÿ��ʱ�����ڵ������ؽ�low_sw�ź����浽low_sw_r��

always @ ( posedge clk  or negedge rst_n )
    if (!rst_n) low_sw_r <= 3'b111;
    else low_sw_r <= low_sw;
   
//���Ĵ���low_sw��1��Ϊ0ʱ��led_ctrl��ֵ��Ϊ�ߣ�ά��һ��ʱ������ 
wire[2:0] led_ctrl = low_sw_r[2:0] & ( ~low_sw[2:0]);

reg d1;
reg d2;
reg d3;
  
always @ (posedge clk or negedge rst_n)
    if (!rst_n) begin
        d1 <= 1'b0;
        d2 <= 1'b0;
        d3 <= 1'b0;
      end
    else begin		//ĳ������ֵ�仯ʱ��LED��������ת
        if ( led_ctrl[0] ) d1 <= ~d1;	
        if ( led_ctrl[1] ) d2 <= ~d2;
        if ( led_ctrl[2] ) d3 <= ~d3;
      end

assign led_d3 = d1 ? 1'b1 : 1'b0;		//LED��ת���
assign led_d2 = d2 ? 1'b1 : 1'b0;
assign led_d1 = d3 ? 1'b1 : 1'b0;
  
endmodule

