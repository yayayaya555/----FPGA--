`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchise.3
// Create Date	: 2009.04.09
// Design Name	: 
// Module Name	: vga_ctrl
// Project Name	: logic_analysis
// Target Device: Cyclone EP1C3T144C8
// Tool versions: Quartus II 8.1
// Description	: DIY�߼�������VGA��ʾ��������ģ��
//					
// Revision		: V1.0
// Additional Comments	:  ���������˵��Ͷ��ɹ���
//				δ�����������ϴ�Դ�룬лл����֧��
////////////////////////////////////////////////////////////////////////////////
module vga_ctrl(	
				clk_25m,rst_n,	
				sampling_mode,tri_mode,disp_ctrl,sampling_rate,	
				sft_r0,sft_r1,sft_r2,sft_r3,sft_r4,sft_r5,sft_r6,sft_r7,
				sft_r8,sft_r9,sft_ra,sft_rb,sft_rc,sft_rd,sft_re,sft_rf,	
				hsync,vsync,vga_r,vga_g,vga_b
			);

input clk_25m;	// 25MHz
input rst_n;	//�͵�ƽ��λ

input[2:0] sampling_mode;	//����ģʽѡ��,mode[0]--MODE1��mode[1]--MODE2��mode[2]--MODE3
input tri_mode;			//�����ź�ģʽѡ��1--�����ش�����0--�½��ش���
input disp_ctrl;		//VGA�����Ҳ�����ɣ���ʾ����ʹ��
input[3:0] sampling_rate;	//���������üĴ�����0-100M��1-50M��������9-10K

	// �ڲ���λ�Ĵ�������ź�
input[63:0] sft_r0;		//��λ�Ĵ�����0,�͸�VGA��ʾ������
input[63:0] sft_r1;		//��λ�Ĵ�����1,�͸�VGA��ʾ������
input[63:0] sft_r2;		//��λ�Ĵ�����2,�͸�VGA��ʾ������
input[63:0] sft_r3;		//��λ�Ĵ�����3,�͸�VGA��ʾ������
input[63:0] sft_r4;		//��λ�Ĵ�����4,�͸�VGA��ʾ������
input[63:0] sft_r5;		//��λ�Ĵ�����5,�͸�VGA��ʾ������
input[63:0] sft_r6;		//��λ�Ĵ�����6,�͸�VGA��ʾ������
input[63:0] sft_r7;		//��λ�Ĵ�����7,�͸�VGA��ʾ������
input[63:0] sft_r8;		//��λ�Ĵ�����8,�͸�VGA��ʾ������
input[63:0] sft_r9;		//��λ�Ĵ�����9,�͸�VGA��ʾ������
input[63:0] sft_ra;		//��λ�Ĵ�����a,�͸�VGA��ʾ������
input[63:0] sft_rb;		//��λ�Ĵ�����b,�͸�VGA��ʾ������
input[63:0] sft_rc;		//��λ�Ĵ�����c,�͸�VGA��ʾ������
input[63:0] sft_rd;		//��λ�Ĵ�����d,�͸�VGA��ʾ������
input[63:0] sft_re;		//��λ�Ĵ�����e,�͸�VGA��ʾ������
input[63:0] sft_rf;		//��λ�Ĵ�����f,�͸�VGA��ʾ������

	// FPGA��VGA�ӿ��ź�
output hsync;	//��ͬ���ź�
output vsync;	//��ͬ���ź�
output[2:0] vga_r;
output[2:0] vga_g;
output[1:0] vga_b;

//��ͷ�ļ�����char_rom�ĸ����ַ���Ӧ���׵�ַ
`include "para_define.v"	

//--------------------------------------------------
	// �������
reg[9:0] x_cnt;		//������
reg[9:0] y_cnt;		//������

always @ (posedge clk_25m or negedge rst_n)
	if(!rst_n) x_cnt <= 10'd0;
	else if(x_cnt == 10'd799) x_cnt <= 10'd0;
	else x_cnt <= x_cnt+1'b1;

always @ (posedge clk_25m or negedge rst_n)
	if(!rst_n) y_cnt <= 10'd0;
	else if(y_cnt == 10'd524) y_cnt <= 10'd0;
	else if(x_cnt == 10'd799) y_cnt <= y_cnt+1'b1;

//--------------------------------------------------
	// VGA��ͬ��,��ͬ���ź�
reg hsync_r,vsync_r;	//ͬ���ź�
 
always @ (posedge clk_25m or negedge rst_n)
	if(!rst_n) hsync_r <= 1'b1;								
	else if(x_cnt == 10'd0) hsync_r <= 1'b0;	//����hsync�ź�
	else if(x_cnt == 10'd96) hsync_r <= 1'b1;

always @ (posedge clk_25m or negedge rst_n)
	if(!rst_n) vsync_r <= 1'b1;							  
	else if(y_cnt == 10'd0) vsync_r <= 1'b0;	//����vsync�ź�
	else if(y_cnt == 10'd2) vsync_r <= 1'b1;

assign hsync = hsync_r;
assign vsync = vsync_r;

//--------------------------------------------------
	//��Ч��ʾ��־λ����
reg valid_yr;	//����ʾ��Ч�ź�
always @ (posedge clk_25m or negedge rst_n)
	if(!rst_n) valid_yr <= 1'b0;
	else if(y_cnt == 10'd32) valid_yr <= 1'b1;
	else if(y_cnt == 10'd512) valid_yr <= 1'b0;	

wire valid_y = valid_yr;

reg valid_r;	// VGA��Ч��ʾ����־λ
always @ (posedge clk_25m or negedge rst_n)
	if(!rst_n) valid_r <= 1'b0;
	else if((x_cnt == 10'd141) && valid_y) valid_r <= 1'b1;
	else if((x_cnt == 10'd781) && valid_y) valid_r <= 1'b0;
	
wire valid = valid_r;		

//--------------------------------------------------
	//����������,��ɫ��ʾ����Ļ��
	
	//�ø߸�λ����ʾҪ��ʾ������(���ڲ��ι۲�)
wire coordinate = (y_cnt > 10'd79) && (y_cnt < 481) && (x_cnt[2:0] == 3'd0) 
						&& (x_cnt > 10'd223) && (x_cnt < 10'd737);

//--------------------------------------------------
	//��������ģʽ�Ͳ���ģʽ��ͼ��/�߿�,��ɫ��ʾ����Ļ��

	//�ø߸�λ����ʾҪ��ʾ����ģʽ�Ͳ���ģʽ��ͼ�α߿�
wire dis_rim = ((y_cnt == 10'd489 | y_cnt == 10'd502) & (x_cnt > 10'd320) & (x_cnt < 10'd381))
					| ((x_cnt == 10'd320 | x_cnt == 10'd381 | x_cnt == 10'd638) & (y_cnt > 10'd488) & (y_cnt < 10'd503));

	//����ģʽ1ʱ��ʾ��������־λ������Ч
wire dis_sap_m1 = (x_cnt > 10'd320) & (x_cnt < 10'd351) & (y_cnt > 10'd489) & (y_cnt < 10'd502);
	//����ģʽ2ʱ��ʾ��������־λ������Ч
wire dis_sap_m2 = (x_cnt > 10'd335) & (x_cnt < 10'd365) & (y_cnt > 10'd489) & (y_cnt < 10'd502);
	//����ģʽ3ʱ��ʾ��������־λ������Ч
wire dis_sap_m3 = (x_cnt > 10'd349) & (x_cnt < 10'd381) & (y_cnt > 10'd489) & (y_cnt < 10'd502);	
	//����ģʽ��ʾ��������־λ������Ч
wire dis_sap_fig = (dis_sap_m1 & sampling_mode == 3'b001) | (dis_sap_m2 & sampling_mode == 3'b010)
						| (dis_sap_m3 & sampling_mode == 3'b100);

	//�����ش�����ͼ����ʾ���߱�־λ������Ч
wire dis_tri_m1 = (y_cnt == 10'd502 & x_cnt > 10'd608 & x_cnt < 10'd638)
						| (y_cnt == 10'd489 & x_cnt > 10'd638 & x_cnt < 10'd668);
	//�½��ش�����ͼ����ʾ���߱�־λ������Ч						
wire dis_tri_m0 = (y_cnt == 10'd489 & x_cnt > 10'd608 & x_cnt < 10'd638)
						| (y_cnt == 10'd502 & x_cnt > 10'd638 & x_cnt < 10'd668);
	//������ʽͼ����ʾ���߱�־λ������Ч						
wire dis_tri_fig = (dis_tri_m1 & tri_mode) | (dis_tri_m0 & ~tri_mode);

//--------------------------------------------------
	//16·�����źŸߵ͵�ƽ�Ĳ�����ʾ����
wire sig0_dis_h,sig0_dis_l;		//signal 0	
wire sig1_dis_h,sig1_dis_l;		//signal 1
wire sig2_dis_h,sig2_dis_l;		//signal 2
wire sig3_dis_h,sig3_dis_l;		//signal 3	
wire sig4_dis_h,sig4_dis_l;		//signal 4	
wire sig5_dis_h,sig5_dis_l;		//signal 5
wire sig6_dis_h,sig6_dis_l;		//signal 6
wire sig7_dis_h,sig7_dis_l;		//signal 7	
wire sig8_dis_h,sig8_dis_l;		//signal 8	
wire sig9_dis_h,sig9_dis_l;		//signal 9
wire siga_dis_h,siga_dis_l;		//signal 10
wire sigb_dis_h,sigb_dis_l;		//signal 11	
wire sigc_dis_h,sigc_dis_l;		//signal 12	
wire sigd_dis_h,sigd_dis_l;		//signal 13
wire sige_dis_h,sige_dis_l;		//signal 14
wire sigf_dis_h,sigf_dis_l;		//signal 15	

assign sig0_dis_h = (y_cnt == 10'd96) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig0_dis_l = (y_cnt == 10'd104) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig1_dis_h = (y_cnt == 10'd120) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig1_dis_l = (y_cnt == 10'd128) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig2_dis_h = (y_cnt == 10'd144) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig2_dis_l = (y_cnt == 10'd152) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig3_dis_h = (y_cnt == 10'd168) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig3_dis_l = (y_cnt == 10'd176) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig4_dis_h = (y_cnt == 10'd192) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig4_dis_l = (y_cnt == 10'd200) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig5_dis_h = (y_cnt == 10'd216) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig5_dis_l = (y_cnt == 10'd224) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig6_dis_h = (y_cnt == 10'd240) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig6_dis_l = (y_cnt == 10'd248) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig7_dis_h = (y_cnt == 10'd264) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig7_dis_l = (y_cnt == 10'd272) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig8_dis_h = (y_cnt == 10'd288) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig8_dis_l = (y_cnt == 10'd296) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sig9_dis_h = (y_cnt == 10'd312) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sig9_dis_l = (y_cnt == 10'd320) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign siga_dis_h = (y_cnt == 10'd336) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign siga_dis_l = (y_cnt == 10'd344) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sigb_dis_h = (y_cnt == 10'd360) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sigb_dis_l = (y_cnt == 10'd368) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sigc_dis_h = (y_cnt == 10'd384) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sigc_dis_l = (y_cnt == 10'd392) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sigd_dis_h = (y_cnt == 10'd408) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sigd_dis_l = (y_cnt == 10'd416) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sige_dis_h = (y_cnt == 10'd432) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sige_dis_l = (y_cnt == 10'd440) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

assign sigf_dis_h = (y_cnt == 10'd456) && (x_cnt > 10'd223) && (x_cnt < 10'd737);
assign sigf_dis_l = (y_cnt == 10'd464) && (x_cnt > 10'd223) && (x_cnt < 10'd737);

	//��ʾλ����
wire[6:0] dis_bit = x_cnt[9:3]-7'h1c;

//--------------------------------------------------
	//��ʾ���⡰DIY �߼������ǡ� 32*224
wire[31:0] topic_data;		//����ROM��������
reg[7:0] topic_addr;		//����ROM��ַ����

	//��������ROM����ROM�洢������ģ����
topic_rom		topic_rom_inst(
					.address(topic_addr),
					.clock(clk_25m),
					.q(topic_data)
				);
				
	//topic ROM��ַ����
always @(posedge clk_25m or negedge rst_n)
	if(!rst_n) topic_addr <= 8'd0;
	else if(x_cnt == 10'd242) topic_addr <= 8'd0;
	else topic_addr <= topic_addr+1'b1;

	//��ʾ���������־λ������Ч
wire dis_topic = (y_cnt > 10'd39) & (y_cnt < 10'd72) 
					& (x_cnt > 10'd245) & (x_cnt < 10'd470);

//--------------------------------------------------
	//��ʾ�ַ� 8*16bit
/*	char_rom�洢�ռ�Ϊ 512*8bit,��0��ַ��ʼÿ16���ֽ�Ϊһ���ַ�����ģ����;
	512����ַ�����˴����0-9,a-z,A-Z��62���ַ�����ģ
*/	
wire[15:0] char_data;	//char ROM��������
reg[8:0] char_addr;		//char ROM��ַ����

	//����char_ROM����ROM�洢�ַ���ģ����
char_rom	char_rom_inst(
						.address(char_addr[8:0]),
						.clock(clk_25m),
						.q(char_data)
					);

	//char ROM��ַ����
always @(posedge clk_25m or negedge rst_n) begin
	if(!rst_n) char_addr <= 9'd0;
	else if((y_cnt > 10'd91 & y_cnt < 10'd108) | (y_cnt > 10'd115 & y_cnt < 10'd132)
			| (y_cnt > 10'd139 & y_cnt < 10'd156) | (y_cnt > 10'd163 & y_cnt < 10'd180)
			| (y_cnt > 10'd187 & y_cnt < 10'd204) | (y_cnt > 10'd211 & y_cnt < 10'd228)
			| (y_cnt > 10'd235 & y_cnt < 10'd252) | (y_cnt > 10'd259 & y_cnt < 10'd276)
			| (y_cnt > 10'd283 & y_cnt < 10'd300) | (y_cnt > 10'd307 & y_cnt < 10'd324)
			| (y_cnt > 10'd331 & y_cnt < 10'd348) | (y_cnt > 10'd355 & y_cnt < 10'd372)
			| (y_cnt > 10'd379 & y_cnt < 10'd396) | (y_cnt > 10'd403 & y_cnt < 10'd420)
			| (y_cnt > 10'd427 & y_cnt < 10'd444) | (y_cnt > 10'd451 & y_cnt < 10'd468)) 
		begin
			if(x_cnt == 10'd187) char_addr <= `CHAR_C;		//��'C'��ģ�洢�׵�ַ
			else if(x_cnt == 10'd195) char_addr <= `CHAR_h;	//��'h'��ģ����׵�ַ
			else if(x_cnt == 10'd203) begin
				if(y_cnt > 10'd91 && y_cnt < 10'd108) char_addr <= `CHAR_0;			//��'0'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd115 & y_cnt < 10'd132) char_addr <= `CHAR_1;	//��'1'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd139 & y_cnt < 10'd156) char_addr <= `CHAR_2;	//��'2'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd163 & y_cnt < 10'd180) char_addr <= `CHAR_3;	//��'3'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd187 & y_cnt < 10'd204) char_addr <= `CHAR_4;	//��'4'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd211 & y_cnt < 10'd228) char_addr <= `CHAR_5;	//��'5'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd235 & y_cnt < 10'd252) char_addr <= `CHAR_6;	//��'6'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd259 & y_cnt < 10'd276) char_addr <= `CHAR_7;	//��'7'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd283 & y_cnt < 10'd300) char_addr <= `CHAR_8;	//��'8'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd307 & y_cnt < 10'd324) char_addr <= `CHAR_9;	//��'9'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd331 & y_cnt < 10'd348) char_addr <= `CHAR_a;	//��'a'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd355 & y_cnt < 10'd372) char_addr <= `CHAR_b;	//��'b'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd379 & y_cnt < 10'd396) char_addr <= `CHAR_c;	//��'c'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd403 & y_cnt < 10'd430) char_addr <= `CHAR_d;	//��'d'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd427 & y_cnt < 10'd444) char_addr <= `CHAR_e;	//��'e'��ģ�洢�׵�ַ
				else if(y_cnt > 10'd451 & y_cnt < 10'd468) char_addr <= `CHAR_f;	//��'f'��ģ�洢�׵�ַ				
				end
			else char_addr <= char_addr+1'b1;	//ȡ��һ����ַ����ģ����
		end
	else if(y_cnt > 10'd55 & y_cnt < 10'd72) begin
			case(x_cnt)	
					//��Ļ���Ϸ���ʾ��Sampling Period:��
				10'd572: char_addr <= `CHAR_S;	//��'S'��ģ�洢�׵�ַ 
				10'd580: char_addr <= `CHAR_a;	//��'a'��ģ�洢�׵�ַ
				10'd588: char_addr <= `CHAR_m;	//��'m'��ģ�洢�׵�ַ
				10'd596: char_addr <= `CHAR_p;	//��'p'��ģ�洢�׵�ַ
				10'd604: char_addr <= `CHAR_l;	//��'l'��ģ�洢�׵�ַ
				10'd612: char_addr <= `CHAR_i;	//��'i'��ģ�洢�׵�ַ
				10'd620: char_addr <= `CHAR_n;	//��'n'��ģ�洢�׵�ַ
				10'd628: char_addr <= `CHAR_g;	//��'g'��ģ�洢�׵�ַ
				10'd636: char_addr <= `CHAR_kg;	//��' '��ģ�洢�׵�ַ
				10'd644: char_addr <= `CHAR_P;	//��'P'��ģ�洢�׵�ַ
				10'd652: char_addr <= `CHAR_e;	//��'e'��ģ�洢�׵�ַ
				10'd660: char_addr <= `CHAR_r;	//��'r'��ģ�洢�׵�ַ
				10'd668: char_addr <= `CHAR_i;	//��'i'��ģ�洢�׵�ַ
				10'd676: char_addr <= `CHAR_o;	//��'o'��ģ�洢�׵�ַ
				10'd684: char_addr <= `CHAR_d;	//��'d'��ģ�洢�׵�ַ
				10'd692: char_addr <= `CHAR_mh;	//��':'��ģ�洢�׵�ַ
					//��ʾ�������ڵ���ֵ�͵�λ����500ns
				10'd708: if(sampling_rate == 4'd4) char_addr <= `CHAR_5;	//�Ͱ�λ��ģ�洢�׵�ַ
						 else if(sampling_rate == 4'd3 || sampling_rate == 4'd9) char_addr <= `CHAR_1;
						 else char_addr <= `CHAR_kg;
				10'd716: case(sampling_rate)	//��ʮλ��ģ�洢�׵�ַ
							4'd5,4'd6,4'd7: char_addr <= `CHAR_kg;		
							4'd0,4'd8: char_addr <= `CHAR_1;	
							4'd1: char_addr <= `CHAR_2;	
							4'd2: char_addr <= `CHAR_4;	
							default: char_addr <= `CHAR_0;
							endcase	
				10'd724: case(sampling_rate)	//�͸�λ��ģ�洢�׵�ַ
							4'd5: char_addr <= `CHAR_1;	
							4'd6: char_addr <= `CHAR_2;	
							4'd7: char_addr <= `CHAR_5;	
							default: char_addr <= `CHAR_0;	
							endcase	
				10'd732: if(sampling_rate > 4'd4) char_addr <= `CHAR_u;	//��'u'��ģ�洢�׵�ַ
						 else char_addr <= `CHAR_n;	//��'n'��ģ�洢�׵�ַ
				10'd740: char_addr <= `CHAR_s;	//��'s'��ģ�洢�׵�ַ
				default: char_addr <= char_addr+1'b1;	//ȡ��һ����ַ����ģ����
				endcase
		end
	else if(y_cnt > 10'd488 & y_cnt < 10'd505) begin
			case(x_cnt)
					//��Ļ���·���ʾ��Trigger Mode:��
				10'd199: char_addr <= `CHAR_T;	//��'T'��ģ�洢�׵�ַ 
				10'd207: char_addr <= `CHAR_r;	//��'r'��ģ�洢�׵�ַ
				10'd215: char_addr <= `CHAR_i;	//��'i'��ģ�洢�׵�ַ
				10'd223: char_addr <= `CHAR_g;	//��'g'��ģ�洢�׵�ַ
				10'd231: char_addr <= `CHAR_g;	//��'g'��ģ�洢�׵�ַ
				10'd239: char_addr <= `CHAR_e;	//��'e'��ģ�洢�׵�ַ
				10'd247: char_addr <= `CHAR_r;	//��'r'��ģ�洢�׵�ַ
				10'd255: char_addr <= `CHAR_kg;	//��' '��ģ�洢�׵�ַ
				10'd263: char_addr <= `CHAR_M;	//��'M'��ģ�洢�׵�ַ
				10'd271: char_addr <= `CHAR_o;	//��'o'��ģ�洢�׵�ַ
				10'd279: char_addr <= `CHAR_d;	//��'d'��ģ�洢�׵�ַ
				10'd287: char_addr <= `CHAR_e;	//��'e'��ģ�洢�׵�ַ
				10'd295: char_addr <= `CHAR_mh;	//��':'��ģ�洢�׵�ַ
					//��Ļ���·���ʾ��Sampling Mode:��
				10'd479: char_addr <= `CHAR_S;	//��'S'��ģ�洢�׵�ַ
				10'd487: char_addr <= `CHAR_a;	//��'a'��ģ�洢�׵�ַ
				10'd495: char_addr <= `CHAR_m;	//��'m'��ģ�洢�׵�ַ
				10'd503: char_addr <= `CHAR_p;	//��'p'��ģ�洢�׵�ַ
				10'd511: char_addr <= `CHAR_l;	//��'l'��ģ�洢�׵�ַ
				10'd519: char_addr <= `CHAR_i;	//��'i'��ģ�洢�׵�ַ
				10'd527: char_addr <= `CHAR_n;	//��'n'��ģ�洢�׵�ַ
				10'd535: char_addr <= `CHAR_g;	//��'g'��ģ�洢�׵�ַ
				10'd543: char_addr <= `CHAR_kg;	//��' '��ģ�洢�׵�ַ
				10'd551: char_addr <= `CHAR_M;	//��'M'��ģ�洢�׵�ַ
				10'd559: char_addr <= `CHAR_o;	//��'o'��ģ�洢�׵�ַ
				10'd567: char_addr <= `CHAR_d;	//��'d'��ģ�洢�׵�ַ
				10'd575: char_addr <= `CHAR_e;	//��'e'��ģ�洢�׵�ַ
				10'd583: char_addr <= `CHAR_mh;	//��':'��ģ�洢�׵�ַ				
				default: char_addr <= char_addr+1'b1;	//ȡ��һ����ַ����ģ����
				endcase
		end
end

	//��ʾ'Ch'�Լ����������־λ������Ч
wire dis_ch = ((y_cnt > 10'd91 & y_cnt < 10'd108) | (y_cnt > 10'd115 & y_cnt < 10'd132)
				| (y_cnt > 10'd139 & y_cnt < 10'd156) | (y_cnt > 10'd163 & y_cnt < 10'd180)
				| (y_cnt > 10'd187 & y_cnt < 10'd204) | (y_cnt > 10'd211 & y_cnt < 10'd228)
				| (y_cnt > 10'd235 & y_cnt < 10'd252) | (y_cnt > 10'd259 & y_cnt < 10'd276)
				| (y_cnt > 10'd283 & y_cnt < 10'd300) | (y_cnt > 10'd307 & y_cnt < 10'd324)
				| (y_cnt > 10'd331 & y_cnt < 10'd348) | (y_cnt > 10'd355 & y_cnt < 10'd372)
				| (y_cnt > 10'd379 & y_cnt < 10'd396) | (y_cnt > 10'd403 & y_cnt < 10'd420)
				| (y_cnt > 10'd427 & y_cnt < 10'd444) | (y_cnt > 10'd451 & y_cnt < 10'd468))
				& (x_cnt > 10'd188 & x_cnt < 10'd213);

reg[3:0] ch_bit;	//��ʾChʱ����y_cnt������ʾλbit0-15
always @(posedge clk_25m or negedge rst_n)
	if(!rst_n) ch_bit <= 4'd0;
	else if(x_cnt == 10'd1) begin	//ÿy_cnt�ڼ䣬ֻ����һ��
		if((y_cnt == 10'd92) | (y_cnt == 10'd116) | (y_cnt == 10'd140) | (y_cnt == 164)
			| (y_cnt == 10'd188) | (y_cnt == 10'd212) | (y_cnt == 10'd236) | (y_cnt == 10'd260)
			| (y_cnt == 10'd284) | (y_cnt == 10'd308) | (y_cnt == 10'd332) | (y_cnt == 10'd356)
			| (y_cnt == 10'd380) | (y_cnt == 10'd404) | (y_cnt == 10'd428) | (y_cnt == 10'd452))
			ch_bit <= 4'd15;	//��ַ��λ���ò���������Ϊ������·������Լ��
		else ch_bit <= ch_bit-1'b1;		//����һ��y_cnt������λ����1
	end
	
	//��Ļ���Ϸ���ʾ��Sampling Period:����Ч��־λ,����Ч
wire dis_sap_prd = (y_cnt > 10'd55 & y_cnt < 10'd72) & (x_cnt > 10'd573 & x_cnt < 10'd702);

	//��Ļ���·���ʾ��Trigger Mode:����Ч��־λ,����Ч
wire dis_tri_mod = (y_cnt > 10'd488 & y_cnt < 10'd505) & (x_cnt > 10'd200 & x_cnt < 10'd305);

	//��Ļ���·���ʾ��Sampling Mode:����Ч��־λ,����Ч
wire dis_sap_mod = (y_cnt > 10'd488 & y_cnt < 10'd505) & (x_cnt > 10'd480 & x_cnt < 10'd593);

	//��ʾ��������ֵ�͵�λ��־������Ч
wire dis_prd_value = (x_cnt > 10'd709 & x_cnt < 10'd750) & (y_cnt > 10'd55 & y_cnt < 10'd72);
	
//-------------------------------------------------- 
	// VGAɫ���źŲ���
/*
RGB = 000  	��ɫ	RGB = 100	��ɫ
	= 001  	��ɫ		= 101	��ɫ
	= 010	��ɫ		= 110	��ɫ
	= 011	��ɫ		= 111	��ɫ
*/	
	
reg[2:0] vga_rgb;	// VGAɫ����ʾ�Ĵ���

always @ (posedge clk_25m)
	if(!valid) vga_rgb <= 3'b000;
	else if(coordinate) vga_rgb <= 3'b110;	//����������,��ɫ��ʾ����Ļ��
	else if(dis_rim) vga_rgb <= 3'b101;		//����������,��ɫ��ʾ����Ļ��
	else if(dis_sap_fig) vga_rgb <= 3'b101;		//����ģʽ��ʾ�������,��ɫ��ʾ����Ļ��
	else if(dis_tri_fig) vga_rgb <= 3'b101;		//����ģʽͼ����ʾ����,��ɫ��ʾ����Ļ��
	else if(dis_topic) begin 	//31-(y_cnt-40) = 71-y_cnt
			if(topic_data[10'd71-y_cnt]) vga_rgb <= 3'b001;	//��ʾ����,��ɫ
			else vga_rgb <= 3'b111;
		end
	else if(dis_ch) begin	
			if(char_data[ch_bit]) vga_rgb <= 3'b001;	//��ʾ"Ch0/1/2/3/����",��ɫ
			else vga_rgb <= 3'b111;			
		end
	else if(dis_sap_prd) begin	//15-(y_cnt-56) = 71-y_cnt
			if(char_data[10'd71-y_cnt]) vga_rgb <= 3'b001;	//��ʾ��Sampling Period:��,��ɫ
			else vga_rgb <= 3'b111;				
		end
	else if(dis_tri_mod) begin	//15-(y_cnt-489) = 504-y_cnt
			if(char_data[10'd504-y_cnt]) vga_rgb <= 3'b001;	//��ʾ��Trigger Mode:��,��ɫ
			else vga_rgb <= 3'b111;		
		end
	else if(dis_sap_mod) begin	//15-(y_cnt-489) = 504-y_cnt
			if(char_data[10'd504-y_cnt]) vga_rgb <= 3'b001;	//��ʾ��Sampling Mode:��,��ɫ
			else vga_rgb <= 3'b111;		
		end
	else if(dis_prd_value) begin	//15-(y_cnt-56) = 71-y_cnt
			if(char_data[10'd71-y_cnt]) vga_rgb <= 3'b101;	//��ʾ��Sampling Period:�������ֵ�͵�λ,��ɫ
			else vga_rgb <= 3'b111;		
		end
	else if(disp_ctrl) begin	//��������ʾ����
			if(sig0_dis_h && sft_r0[dis_bit]) vga_rgb <= 3'b010;	//signal0�ߵ�ƽ������ʾ
			else if(sig0_dis_l && !sft_r0[dis_bit]) vga_rgb <= 3'b010;	//signal 0�͵�ƽ������ʾ
			else if(sig1_dis_h && sft_r1[dis_bit]) vga_rgb <= 3'b010;	//signal 1�ߵ�ƽ������ʾ
			else if(sig1_dis_l && !sft_r1[dis_bit]) vga_rgb <= 3'b010;	//signal 1�͵�ƽ������ʾ
			else if(sig2_dis_h && sft_r2[dis_bit]) vga_rgb <= 3'b010;	//signal 2�ߵ�ƽ������ʾ
			else if(sig2_dis_l && !sft_r2[dis_bit]) vga_rgb <= 3'b010;	//signal 2�͵�ƽ������ʾ
			else if(sig3_dis_h && sft_r3[dis_bit]) vga_rgb <= 3'b010;	//signal 3�ߵ�ƽ������ʾ
			else if(sig3_dis_l && !sft_r3[dis_bit]) vga_rgb <= 3'b010;	//signal 3�͵�ƽ������ʾ
			else if(sig4_dis_h && sft_r4[dis_bit]) vga_rgb <= 3'b010;	//signal 4�ߵ�ƽ������ʾ
			else if(sig4_dis_l && !sft_r4[dis_bit]) vga_rgb <= 3'b010;	//signal 4�͵�ƽ������ʾ
			else if(sig5_dis_h && sft_r5[dis_bit]) vga_rgb <= 3'b010;	//signal 5�ߵ�ƽ������ʾ
			else if(sig5_dis_l && !sft_r5[dis_bit]) vga_rgb <= 3'b010;	//signal 5�͵�ƽ������ʾ
			else if(sig6_dis_h && sft_r6[dis_bit]) vga_rgb <= 3'b010;	//signal 6�ߵ�ƽ������ʾ
			else if(sig6_dis_l && !sft_r6[dis_bit]) vga_rgb <= 3'b010;	//signal 6�͵�ƽ������ʾ
			else if(sig7_dis_h && sft_r7[dis_bit]) vga_rgb <= 3'b010;	//signal 7�ߵ�ƽ������ʾ
			else if(sig7_dis_l && !sft_r7[dis_bit]) vga_rgb <= 3'b010;	//signal 7�͵�ƽ������ʾ
			else if(sig8_dis_h && sft_r8[dis_bit]) vga_rgb <= 3'b010;	//signal 8�ߵ�ƽ������ʾ
			else if(sig8_dis_l && !sft_r8[dis_bit]) vga_rgb <= 3'b010;	//signal 8�͵�ƽ������ʾ
			else if(sig9_dis_h && sft_r9[dis_bit]) vga_rgb <= 3'b010;	//signal 9�ߵ�ƽ������ʾ
			else if(sig9_dis_l && !sft_r9[dis_bit]) vga_rgb <= 3'b010;	//signal 9�͵�ƽ������ʾ
			else if(siga_dis_h && sft_ra[dis_bit]) vga_rgb <= 3'b010;	//signal 10�ߵ�ƽ������ʾ
			else if(siga_dis_l && !sft_ra[dis_bit]) vga_rgb <= 3'b010;	//signal 10�͵�ƽ������ʾ
			else if(sigb_dis_h && sft_rb[dis_bit]) vga_rgb <= 3'b010;	//signal 11�ߵ�ƽ������ʾ
			else if(sigb_dis_l && !sft_rb[dis_bit]) vga_rgb <= 3'b010;	//signal 11�͵�ƽ������ʾ
			else if(sigc_dis_h && sft_rc[dis_bit]) vga_rgb <= 3'b010;	//signal 12�ߵ�ƽ������ʾ
			else if(sigc_dis_l && !sft_rc[dis_bit]) vga_rgb <= 3'b010;	//signal 12�͵�ƽ������ʾ
			else if(sigd_dis_h && sft_rd[dis_bit]) vga_rgb <= 3'b010;	//signal 13�ߵ�ƽ������ʾ
			else if(sigd_dis_l && !sft_rd[dis_bit]) vga_rgb <= 3'b010;	//signal 13�͵�ƽ������ʾ
			else if(sige_dis_h && sft_re[dis_bit]) vga_rgb <= 3'b010;	//signal 14�ߵ�ƽ������ʾ
			else if(sige_dis_l && !sft_re[dis_bit]) vga_rgb <= 3'b010;	//signal 14�͵�ƽ������ʾ
			else if(sigf_dis_h && sft_rf[dis_bit]) vga_rgb <= 3'b010;	//signal 15�ߵ�ƽ������ʾ
			else if(sigf_dis_l && !sft_rf[dis_bit]) vga_rgb <= 3'b010;	//signal 15�͵�ƽ������ʾ			
			else vga_rgb <= 3'b111;
		end
	else vga_rgb <= 3'b111;

	//r,g,b����Һ������ɫ��ʾ
assign vga_r[0] = vga_rgb[2];
assign vga_r[1] = vga_rgb[2];
assign vga_r[2] = vga_rgb[2];
assign vga_g[0] = vga_rgb[1];
assign vga_g[1] = vga_rgb[1];
assign vga_g[2] = vga_rgb[1];
assign vga_b[0] = vga_rgb[0];
assign vga_b[1] = vga_rgb[0];


endmodule
