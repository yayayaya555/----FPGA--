`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchise.3
// Create Date	: 2009.05.21
// Design Name	: cyclone_PLL_top
// Module Name	: cyclone_PLL_top
// Project Name	: cyclone_PLL_top
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: �����1s������
//							
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module seg7(
			clk,rst_n,
			ds_stcp,ds_shcp,ds_data
		);

input clk;	//25M����ʱ���ź�
input rst_n;	//��λ�ź����룬����Ч

output ds_stcp;		//74HC595�Ĳ���ʱ�����룬�����ؽ���ǰ�����������ݲ������
output ds_shcp;		//74HC595�Ĵ���ʱ�����룬���������浱ǰ������������
output ds_data;		//74HC595�Ĵ�����������


//-------------------------------------------------
//��������

//�������ʾ 0~F ��Ӧ��ѡ���
parameter 	SEG_NUM0 	= 8'h3f,//c0,
			SEG_NUM1 	= 8'h06,//f9,
			SEG_NUM2 	= 8'h5b,//a4,
			SEG_NUM3 	= 8'h4f,//b0,
			SEG_NUM4 	= 8'h66,//99,
			SEG_NUM5 	= 8'h6d,//92,
			SEG_NUM6 	= 8'h7d,//82,
			SEG_NUM7 	= 8'h07,//F8,
			SEG_NUM8 	= 8'h7f,//80,
			SEG_NUM9 	= 8'h6f,//90,
			SEG_NUMA 	= 8'h77,//88,
			SEG_NUMB 	= 8'h7c,//83,
			SEG_NUMC 	= 8'h39,//c6,
			SEG_NUMD 	= 8'h5e,//a1,
			SEG_NUME 	= 8'h79,//86,
			SEG_NUMF 	= 8'h71;//8e;

//�����λѡ 0~3 ��Ӧ���
parameter	SEG_WE0		= 4'b1110,
			SEG_WE1		= 4'b1101,
			SEG_WE2		= 4'b1011,
			SEG_WE3		= 4'b0111;

//-------------------------------------------------
//�������ݲ�����Ԫ
reg[24:0] cnt_1s;	//1s��������0-24999999
reg[15:0] dis_data;	//�������ʾ���ݣ�16λ

	//1s��ʱ����
always @(posedge clk or negedge rst_n)
	if(!rst_n) cnt_1s <= 25'd0;
	else if(cnt_1s == 25'd24_999_999) cnt_1s <= 25'd0;
	else cnt_1s <= cnt_1s+1'b1;

wire done_1s = (cnt_1s == 25'd24_999_999);	//1s��ʱ����־λ������Чһ��ʱ������

	//��ʾ����ÿ�����
always @(posedge clk or negedge rst_n)
	if(!rst_n) dis_data <= 16'd0;
	else if(done_1s) dis_data <= dis_data+1'b1;

//-------------------------------------------------
//��ʱ��ʾ���ݿ��Ƶ�Ԫ
reg[7:0] seg_num;	//��ǰ��ʾ����
reg[7:0] seg_duan;	//7������ܶ�ѡ�źţ�����С����Ϊ8�Σ�
reg[3:0] seg_wei;	//7�������λѡ�ź�

reg[7:0] cnt_4;		//��ʱ������

	//��ʱ������
always @(posedge clk or negedge rst_n)
	if(!rst_n) cnt_4 <= 8'd0;
	else cnt_4 <= cnt_4+1'b1;

	//��ʾ����
always @(posedge clk or negedge rst_n)
	if(!rst_n) seg_num <= 8'h00;
	else 
		case(cnt_4[7:6])
				2'b00: seg_num <= dis_data[3:0];
				2'b01: seg_num <= dis_data[7:4];
				2'b10: seg_num <= dis_data[11:8];
				2'b11: seg_num <= dis_data[15:12];
			default:  seg_num <= 8'h00;
			endcase

	//��ѡ��������
always @(posedge clk or negedge rst_n)
	if(!rst_n) seg_duan <= 8'h00;
	else
		case(seg_num) 
			4'h0: seg_duan <= SEG_NUM0;
			4'h1: seg_duan <= SEG_NUM1;
			4'h2: seg_duan <= SEG_NUM2;
			4'h3: seg_duan <= SEG_NUM3;
			4'h4: seg_duan <= SEG_NUM4;
			4'h5: seg_duan <= SEG_NUM5;
			4'h6: seg_duan <= SEG_NUM6;
			4'h7: seg_duan <= SEG_NUM7;
			4'h8: seg_duan <= SEG_NUM8;
			4'h9: seg_duan <= SEG_NUM9;
			4'ha: seg_duan <= SEG_NUMA;
			4'hb: seg_duan <= SEG_NUMB;
			4'hc: seg_duan <= SEG_NUMC;
			4'hd: seg_duan <= SEG_NUMD;
			4'he: seg_duan <= SEG_NUME;
			4'hf: seg_duan <= SEG_NUMF;
		default: ;
		endcase

	//λѡ����
always @(cnt_4[7:6])
	case(cnt_4[7:6])
			2'b00: seg_wei <= SEG_WE0;
			2'b01: seg_wei <= SEG_WE1;
			2'b10: seg_wei <= SEG_WE2;
			2'b11: seg_wei <= SEG_WE3;
		default:  seg_wei <= 4'b1111;
		endcase

//-------------------------------------------------
//74HC95��������			
reg ds_stcpr;	//74HC595�Ĳ���ʱ�����룬�����ؽ���ǰ�����������ݲ������
reg ds_shcpr;	//74HC595�Ĵ���ʱ�����룬���������浱ǰ������������
reg ds_datar;	//74HC595�Ĵ�����������
			
	//������λʱ�Ӳ���	
always @(posedge clk or negedge rst_n)			
	if(!rst_n) ds_shcpr <= 1'b0;
	else if((cnt_4 > 8'h02 && cnt_4 <= 8'h22) || (cnt_4 > 8'h42 && cnt_4 <= 8'h62)
			|| (cnt_4 > 8'h82 && cnt_4 <= 8'ha2) || (cnt_4 > 8'hc2 && cnt_4 <= 8'he2)) 
		ds_shcpr <= ~ds_shcpr;
			
	//������λ���ݲ���
always @(posedge clk or negedge rst_n)			
	if(!rst_n) ds_datar <= 1'b0;
	else 
		case(cnt_4)
			8'h02,8'h42,8'h82,8'hc2: ds_datar <= seg_duan[7];
			8'h04,8'h44,8'h84,8'hc4: ds_datar <= seg_duan[6];
			8'h06,8'h46,8'h86,8'hc6: ds_datar <= seg_duan[5];
			8'h08,8'h48,8'h88,8'hc8: ds_datar <= seg_duan[4];
			8'h0a,8'h4a,8'h8a,8'hca: ds_datar <= seg_duan[3];
			8'h0c,8'h4c,8'h8c,8'hcc: ds_datar <= seg_duan[2];
			8'h0e,8'h4e,8'h8e,8'hce: ds_datar <= seg_duan[1];
			8'h10,8'h50,8'h90,8'hd0: ds_datar <= seg_duan[0];
			8'h1a,8'h5a,8'h9a,8'hda: ds_datar <= seg_wei[0];
			8'h1c,8'h5c,8'h9c,8'hdc: ds_datar <= seg_wei[1];
			8'h1e,8'h5e,8'h9e,8'hde: ds_datar <= seg_wei[2];
			8'h20,8'h60,8'ha0,8'he0: ds_datar <= seg_wei[3];
			default: ;
			endcase

	//������λʱ�Ӳ���
always @(posedge clk or negedge rst_n)			
	if(!rst_n) ds_stcpr <= 1'b0;
	else if((cnt_4 == 8'h02) || (cnt_4 == 8'h42) || (cnt_4 == 8'h82) || (cnt_4 == 8'hc2)) ds_stcpr <= 1'b0;
	else if((cnt_4 == 8'h23) || (cnt_4 == 8'h63) || (cnt_4 == 8'ha3) || (cnt_4 == 8'he3)) ds_stcpr <= 1'b1;

wire ds_stcp = ds_stcpr;
wire ds_shcp = ds_shcpr;
wire ds_data = ds_datar;			

endmodule
