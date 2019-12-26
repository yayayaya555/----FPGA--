`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchises3
// Create Date	: 2009.05.27
// Design Name	: vga_char
// Module Name	: vga_char
// Project Name	: vga_char
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: ����SF-EP1C6�������VGA�ӿں͵���Һ������
//					��ʾ�ַ�"EDN"
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module vga_char(	
				clk_25m,rst_n,	//ϵͳ����
				hsync,vsync,vga_r,vga_g,vga_b	// VGA����
			);

input clk_25m;	// 25MHz
input rst_n;	//�͵�ƽ��λ

	// FPGA��VGA�ӿ��ź�
output hsync;	//��ͬ���ź�
output vsync;	//��ͬ���ź�
output[2:0] vga_r;
output[2:0] vga_g;
output[1:0] vga_b;

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

//wire[9:0] x_dis;		//��������ʾ��Ч�����������ֵ0-639
wire[9:0] y_dis;		//��������ʾ��Ч�����������ֵ0-479

//assign x_dis = x_cnt - 10'd142;
assign y_dis = y_cnt - 10'd33;
//--------------------------------------------------

//-------------------------------------------------- 
	// VGAɫ���źŲ���
/*
RGB = 000  	��ɫ	RGB = 100	��ɫ
	= 001  	��ɫ		= 101	��ɫ
	= 010	��ɫ		= 110	��ɫ
	= 011	��ɫ		= 111	��ɫ
*/	

/*EDN��ģ����*/
parameter 	char_line0 = 24'h000000,
			char_line1 = 24'h000000,
			char_line2 = 24'h000000,
			char_line3 = 24'hfcf8c7,
			char_line4 = 24'h424462,
			char_line5 = 24'h484262,
			char_line6 = 24'h484252,
			char_line7 = 24'h784252,
			char_line8 = 24'h48424a,
			char_line9 = 24'h48424a,
			char_linea = 24'h40424a,
			char_lineb = 24'h424246,
			char_linec = 24'h424446,
			char_lined = 24'hfcf8e2,
			char_linee = 24'h000000,
			char_linef = 24'h000000;

reg[4:0] char_bit;	//��ʾλ����

always @(posedge clk_25m or negedge rst_n)
	if(!rst_n) char_bit <= 5'h1f;
	else if(x_cnt == 10'd442) char_bit <= 5'd23;	//��ʾ���λ����
	else if(x_cnt > 10'd442 && x_cnt < 10'd466) char_bit <= char_bit-1'b1;	//������ʾ���������
	
reg[7:0] vga_rgb;	// VGAɫ����ʾ�Ĵ���

always @ (posedge clk_25m)
	if(!valid) vga_rgb <= 8'd0;
	else if(x_cnt > 10'd442 && x_cnt < 10'd467) begin
		case(y_dis)
			10'd231: if(char_line0[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_11100;	//��ɫ
			10'd232: if(char_line1[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd233: if(char_line2[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd234: if(char_line3[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd235: if(char_line4[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd236: if(char_line5[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd237: if(char_line6[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd238: if(char_line7[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd239: if(char_line8[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd240: if(char_line9[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ
			10'd241: if(char_linea[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ		 		 		 		 		 
			10'd242: if(char_lineb[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ			 
			10'd243: if(char_linec[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ	
			10'd244: if(char_lined[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ	
			10'd245: if(char_linee[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ	
			10'd246: if(char_linef[char_bit]) vga_rgb <= 8'b111_000_00;	//��ɫ
					 else vga_rgb <= 8'b000_111_00;	//��ɫ			 		 		 		 
		default: vga_rgb <= 8'h00;
		endcase
	end
	else vga_rgb <= 8'h00;

	//r,g,b����Һ������ɫ��ʾ
assign vga_r = vga_rgb[7:5];
assign vga_g = vga_rgb[4:2];
assign vga_b = vga_rgb[1:0];

endmodule
