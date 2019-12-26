`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: ��Ȩ franchise.3
// Create Date	: 2009.04.20
// Design Name	: cyclone_PLL_top
// Module Name	: cyclone_PLL_top
// Project Name	: cyclone_PLL_top
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: ����PLL����һ��100Mʱ�Ӻ�һ��25Mʱ�ӣ�
//					ͬʱ����LED��˸���������ǹ۲�PLL�����Ч��					
// Revision		: V1.0
// Additional Comments	:  
// ��ӭ����EDN��FPGA/CPLD��ѧС��һ�����ۣ�http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module cyclone_PLL_top(
				clk,rst_n,
				led0,led1
			);

input clk;		//25MHz
input rst_n;	//low reset signal

output led0,led1;

wire clk_100m;	//����ʱ�ӵ�4��Ƶ,100MHz	
wire clk_25m;	//����ʱ�ӵ�1��Ƶ,25MHz	
wire locked;	//PLL�����Ч��־λ,����Ч

//PLL����ģ��
//����һ��ϵͳ����ʱ��2/5��Ƶ������90�ȵ�ʱ��
PLL_ctrl	PLL_ctrl_inst (
				.areset(!rst_n),	//PLL�첽��λ�ź�
				.inclk0(clk),		//PLL����ʱ��
				.c0(clk_100m),		//����ʱ�ӵ�4��Ƶ,100MHz	
				.c1(clk_25m),		//����ʱ�ӵ�1��Ƶ,25MHz					
				.locked(locked)		//PLL�����Ч��־λ,����Ч
			);


//ʹ��PLL���ʱ��100M����1s�ķ�����led0
reg[26:0] cnt_100m;
always @ (posedge clk_100m or negedge rst_n) begin
	if(!rst_n) cnt_100m <= 27'd0;
	else if(cnt_100m == 27'd100_000_000) cnt_100m <= 27'd0;
	else cnt_100m <= cnt_100m+1'b1;
end

assign led0 = cnt_100m[26];

//ʹ��PLL���ʱ��25M����1s�ķ�����led1
reg[24:0] cnt_25m;
always @ (posedge clk_25m or negedge rst_n) begin
	if(!rst_n) cnt_25m <= 25'd0;
	else if(cnt_25m == 25'd25_000_000) cnt_25m <= 25'd0;
	else cnt_25m <= cnt_25m+1'b1;
end

assign led1 = cnt_25m[24];


endmodule

