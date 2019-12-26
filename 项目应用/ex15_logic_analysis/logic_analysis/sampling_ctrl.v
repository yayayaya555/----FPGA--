`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchise.3
// Create Date	: 2009.04.09
// Design Name	: 
// Module Name	: sampling_ctrl
// Project Name	: logic_analysis
// Target Device: Cyclone EP1C3T144C8
// Tool versions: Quartus II 8.1
// Description	: DIY�߼��������źŲɼ�ģ��
//					
// Revision		: V1.0
// Additional Comments	:  ���������˵��Ͷ��ɹ���
//				δ�����������ϴ�Դ�룬лл����֧��
////////////////////////////////////////////////////////////////////////////////
module sampling_ctrl(
				clk_100m,rst_n,
				signal,trigger,
				tri_mode,sampling_mode,add_key,dec_key,sampling_clr_n,
				disp_ctrl,sampling_rate,
				sft_r0,sft_r1,sft_r2,sft_r3,sft_r4,sft_r5,sft_r6,sft_r7,
				sft_r8,sft_r9,sft_ra,sft_rb,sft_rc,sft_rd,sft_re,sft_rf
			);

input clk_100m;	//FPAG����ʱ���ź�100MHz
input rst_n;	//ϵͳ��λ�ź�

input[15:0] signal;	//16·�����ź�
input trigger;		//1·�����źţ�������Ϊ�����ػ����½��ش���
input tri_mode;		//�����ź�ģʽѡ��1--�����ش�����0--�½��ش���
input[2:0] sampling_mode;	//����ģʽѡ��,mode[0]--MODE1��mode[1]--MODE2��mode[2]--MODE3
input add_key;		//�������ڿ��Ʋ������ڵ���ߣ��͵�ƽ��ʾ����
input dec_key;		//�������ڿ��Ʋ������ڵļ��ͣ��͵�ƽ��ʾ����
input sampling_clr_n;		//��������źţ����������ǰ�������ݣ�����Ч

output disp_ctrl;			//VGA�����Ҳ�����ɣ���ʾ����ʹ��
output[3:0] sampling_rate;	//���������üĴ�����0-100M��1-50M��������9-10K
output[63:0] sft_r0;		//��λ�Ĵ�����0,�͸�VGA��ʾ������
output[63:0] sft_r1;		//��λ�Ĵ�����1,�͸�VGA��ʾ������
output[63:0] sft_r2;		//��λ�Ĵ�����2,�͸�VGA��ʾ������
output[63:0] sft_r3;		//��λ�Ĵ�����3,�͸�VGA��ʾ������
output[63:0] sft_r4;		//��λ�Ĵ�����4,�͸�VGA��ʾ������
output[63:0] sft_r5;		//��λ�Ĵ�����5,�͸�VGA��ʾ������
output[63:0] sft_r6;		//��λ�Ĵ�����6,�͸�VGA��ʾ������
output[63:0] sft_r7;		//��λ�Ĵ�����7,�͸�VGA��ʾ������
output[63:0] sft_r8;		//��λ�Ĵ�����8,�͸�VGA��ʾ������
output[63:0] sft_r9;		//��λ�Ĵ�����9,�͸�VGA��ʾ������
output[63:0] sft_ra;		//��λ�Ĵ�����a,�͸�VGA��ʾ������
output[63:0] sft_rb;		//��λ�Ĵ�����b,�͸�VGA��ʾ������
output[63:0] sft_rc;		//��λ�Ĵ�����c,�͸�VGA��ʾ������
output[63:0] sft_rd;		//��λ�Ĵ�����d,�͸�VGA��ʾ������
output[63:0] sft_re;		//��λ�Ĵ�����e,�͸�VGA��ʾ������
output[63:0] sft_rf;		//��λ�Ĵ�����f,�͸�VGA��ʾ������

wire sampling_start;			//��λ�Ĵ���ʹ���źţ�����Ч
//wire[3:0] shiftout;		//��λ�Ĵ������,(������в�ʹ�ã�û������)

//----------------------------------------------
//����Ƶ�����ÿ��ư������
reg[20:0] delay;	//��ʱ������
reg[1:0] key_valuer1,key_valuer2;	//��ֵ�Ĵ���,ÿ20ms����һ�Σ����ڼ�ֵ�ı���
wire[1:0] key_change;	//�ж�ǰ��20ms�ļ�ֵ�Ƿ����˸ı䣬���ǣ���key_change�ø�

	//20ms������
always @ (posedge clk_100m or negedge rst_n)
	if(!rst_n) delay <= 21'd0;
	else delay <= delay+1'b1;	//���ϼ���������Ϊ20ms����

	//ÿ20ms����һ�μ�ֵ����
always @ (posedge clk_100m or negedge rst_n)
	if(!rst_n) begin
			key_valuer1 <= 2'b11;	
			key_valuer2 <= 2'b11;
		end
	else if(delay == 21'h1fffff) begin
			key_valuer1 <= {add_key,dec_key};	//delay 20ms��������ֵ
			key_valuer2 <= key_valuer1;
		end

assign key_change = (delay == 21'd1) ? (key_valuer1 & (~key_valuer2)) : 2'b00;//check key_value negedge 1 clk_100m

//----------------------------------------------
//����Ƶ�����ÿ����߼�
/*	��ģ���ʱ�Ӽ������Ĳ���ʱ��ΪPLL_c0 = 100MHz
	�ɵ��Ĳ���Ƶ���Լ������������£� ��10��
Ƶ�ʣ�	100M	50M		25M		10M		2M		1M		500K	200K	100K	10K
���ڣ�	10ns	20ns	40ns	100ns	500ns	1us		2us		5us		10us	100us
������	0		1		3		9		49		99		199		499		999		9999
	����ΪPLL_c0����ֵ��ʹ��ʱ��ʹ�ܷ�ʽ���Ʋ���ʱ��
*/
reg[13:0] sapdiv_cnt;	//�����ʷ�Ƶ������ 0-9999
reg[3:0] sampling_rate;	//���������üĴ�����0-100M��1-50M��������9-10K
reg[13:0] sapdiv_max;	//�����ʶ�Ӧ�ķ�Ƶ����ֵ
wire sapdiv_end;		//�����㵽�ø�һ��ʱ������

	//����Ƶ�ʿ��ư�������
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sampling_rate <= 4'd0;
	else if(key_change[1] && (sampling_rate < 4'd9)) sampling_rate <= sampling_rate+1'b1;	//��������ģʽ���9
	else if(key_change[0] && (sampling_rate > 4'd0)) sampling_rate <= sampling_rate-1'b1;	//��������ģʽ��С��0

	//��������ʶ�Ӧ�ķ�Ƶ����ֵ
always @(sampling_rate)
		case(sampling_rate)
			4'd0: sapdiv_max <= 14'd0;
			4'd1: sapdiv_max <= 14'd1;
			4'd2: sapdiv_max <= 14'd3;
			4'd3: sapdiv_max <= 14'd9; 
			4'd4: sapdiv_max <= 14'd49; 
			4'd5: sapdiv_max <= 14'd99; 
			4'd6: sapdiv_max <= 14'd199; 
			4'd7: sapdiv_max <= 14'd499; 
			4'd8: sapdiv_max <= 14'd999; 
			4'd9: sapdiv_max <= 14'd9999; 
			default: sapdiv_max <= 14'd0;
			endcase
			
	//����Ƶ�ʷ�Ƶ����
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sapdiv_cnt <= 14'd0;
	else if(sapdiv_cnt == sapdiv_max) sapdiv_cnt <= 14'd0;	//�����ʼ������ֵ��
	else sapdiv_cnt <= sapdiv_cnt+1'b1; 	

assign sapdiv_end = (sapdiv_cnt == 14'd0);	//�����㵽

//----------------------------------------------
//����64*16����λ�Ĵ���
reg[63:0] sft_r0;		//��λ�Ĵ�����0
reg[63:0] sft_r1;		//��λ�Ĵ�����1
reg[63:0] sft_r2;		//��λ�Ĵ�����2
reg[63:0] sft_r3;		//��λ�Ĵ�����3
reg[63:0] sft_r4;		//��λ�Ĵ�����4
reg[63:0] sft_r5;		//��λ�Ĵ�����5
reg[63:0] sft_r6;		//��λ�Ĵ�����6
reg[63:0] sft_r7;		//��λ�Ĵ�����7
reg[63:0] sft_r8;		//��λ�Ĵ�����8
reg[63:0] sft_r9;		//��λ�Ĵ�����9
reg[63:0] sft_ra;		//��λ�Ĵ�����a
reg[63:0] sft_rb;		//��λ�Ĵ�����b
reg[63:0] sft_rc;		//��λ�Ĵ�����c
reg[63:0] sft_rd;		//��λ�Ĵ�����d
reg[63:0] sft_re;		//��λ�Ĵ�����e
reg[63:0] sft_rf;		//��λ�Ĵ�����f

//�ɼ��ź�signal[0]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r0 <= 64'd0;
	else if(sampling_start) sft_r0 <= {signal[0],sft_r0[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[1]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r1 <= 64'd0;
	else if(sampling_start) sft_r1 <= {signal[1],sft_r1[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[2]	
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r2 <= 64'd0;
	else if(sampling_start) sft_r2 <= {signal[2],sft_r2[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[3]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r3 <= 64'd0;
	else if(sampling_start) sft_r3 <= {signal[3],sft_r3[63:1]};	//������λ�����λ����������		
//�ɼ��ź�signal[4]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r4 <= 64'd0;
	else if(sampling_start) sft_r4 <= {signal[4],sft_r4[63:1]};	//������λ�����λ����������		
//�ɼ��ź�signal[5]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r5 <= 64'd0;
	else if(sampling_start) sft_r5 <= {signal[5],sft_r5[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[6]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r6 <= 64'd0;
	else if(sampling_start) sft_r6 <= {signal[6],sft_r6[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[7]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r7 <= 64'd0;
	else if(sampling_start) sft_r7 <= {signal[7],sft_r7[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[8]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r8 <= 64'd0;
	else if(sampling_start) sft_r8 <= {signal[8],sft_r8[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[9]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_r9 <= 64'd0;
	else if(sampling_start) sft_r9 <= {signal[9],sft_r9[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[10]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_ra <= 64'd0;
	else if(sampling_start) sft_ra <= {signal[10],sft_ra[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[11]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_rb <= 64'd0;
	else if(sampling_start) sft_rb <= {signal[11],sft_rb[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[12]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_rc <= 64'd0;
	else if(sampling_start) sft_rc <= {signal[12],sft_rc[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[13]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_rd <= 64'd0;
	else if(sampling_start) sft_rd <= {signal[13],sft_rd[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[14]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_re <= 64'd0;
	else if(sampling_start) sft_re <= {signal[14],sft_re[63:1]};	//������λ�����λ����������
//�ɼ��ź�signal[15]
always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sft_rf <= 64'd0;
	else if(sampling_start) sft_rf <= {signal[15],sft_rf[63:1]};	//������λ�����λ����������
		
//----------------------------------------------
//������trigger���ؼ��
reg trigger_r1,trigger_r2,trigger_r3;
wire pos_tri;	//trigger�����ر�־λ������Чһ��ʱ������
wire neg_tri;	//trigger�½��ر�־λ������Чһ��ʱ������

always @(posedge clk_100m or negedge rst_n) 
	if(!rst_n) begin
		trigger_r1 <= 1'b0;
		trigger_r2 <= 1'b0;
		trigger_r3 <= 1'b0;
		end
	else begin
		trigger_r1 <= trigger;
		trigger_r2 <= trigger_r1;
		trigger_r3 <= trigger_r2;
		end

assign pos_tri = trigger_r2 & ~trigger_r3;
assign neg_tri = ~trigger_r2 & trigger_r3;

//----------------------------------------------
//������Ч�ź�trigger_valid����߼�
reg trigger_valid;	//�趨�Ĵ������������,�ñ�־λ����

always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) trigger_valid <= 1'b0;
	else if(!sampling_clr_n) trigger_valid <= 1'b0;			//��λ������Ч�źţ��ȴ���һ�δ���
	else if(tri_mode && pos_tri) trigger_valid <= 1'b1;		//�����ش���
	else if(!tri_mode && neg_tri) trigger_valid <= 1'b1;	//�½��ش���
	
//----------------------------------------------
//���������ź�sampling_end�����߼�
//sampling_end��ʱ��Ϊ��λ�Ĵ���ʱ��ʹ���źţ���ʱ��ΪVGA��ʾ��λ�Ĵ��������ź�
reg sampling_end;	//���ض��Ĳ���ģʽ�²��������������㣬�����߸üĴ���
reg[5:0] cnt;		//64�����Ĵ���

always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) cnt <= 6'd0;
	else if(!sampling_clr_n) cnt <= 6'd0;	////��λ���������ȴ���һ�μ�������
	else if(trigger_valid) cnt <= cnt+1'b1;	//һ����������������

always @(posedge clk_100m or negedge rst_n)
	if(!rst_n) sampling_end <= 1'b0;
	else if(!sampling_clr_n) sampling_end <= 1'b0;		//��λ���������źţ��ȴ���һ�β�������
	else if((sampling_mode == 3'b001) && (cnt == 6'd63)) sampling_end <= 1'b1;
	else if((sampling_mode == 3'b010) && (cnt == 6'd31)) sampling_end <= 1'b1;
	else if((sampling_mode == 3'b100) && (cnt == 6'd1)) sampling_end <= 1'b1;
		
//----------------------------------------------
//��λ�Ĵ���ʹ���ź�sampling_start�����߼�
assign sampling_start = ~sampling_end & sapdiv_end;

//----------------------------------------------
//����������ʾ��־λdis_ctrl�����߼�
assign disp_ctrl = sampling_end;

endmodule

