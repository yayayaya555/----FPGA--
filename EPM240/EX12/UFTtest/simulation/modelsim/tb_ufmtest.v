


`timescale 1ns/1ns
module tb_ufmtest();

//inout
wire[15:0] databus;		//Flash��������

//input
wire data_valid;		//Flash���������Ч�ź�
wire nbusy;				//Flashæ�ź�

//output
reg[8:0] addr;			//Flash��ַ����
reg nerase;				//����Flashĳһ�����ź�
reg nread;				//��Flash�ź�
reg nwrite;				//дFlash�ź�

reg[15:0] databus_r;	//����ģ���������߼Ĵ���
reg[15:0] rdback_data;	//����ģ�������������ݻض��Ĵ���

assign databus = nwrite ? 16'hzzzz:databus_r;

ufmtest		ufmtest(
				.databus(databus),
				.addr(addr),
				.nerase(nerase),
				.nread(nread),
				.nwrite(nwrite),
				.data_valid(data_valid),
				.nbusy(nbusy)
			);


parameter	DELAY_600US	= 600_000,		//600us��ʱ
			DELAY_2US	= 2_000,		//2us��ʱ
			DELAY_5US	= 5_000;		//5us��ʱ


initial begin
		nerase = 1;
		nread = 1;
		nwrite = 1;
		addr = 0;
		databus_r = 0;
	
	#DELAY_600US;	//0��ַд������99
		databus_r = 99;
		addr = 9'd0;
		nwrite = 0;
		#DELAY_5US;		
		nwrite = 1;		
		@ (posedge nbusy);

			
	#DELAY_5US;	//0��ַ�������ݣ����浽�Ĵ���rdback_data��
		databus_r = 16'hff;
		addr = 9'd0;
		nread = 0;
		#DELAY_5US;		
		nread = 1;		
		@ (posedge data_valid);
		rdback_data = databus; 
			
	#DELAY_600US;
	$stop;		
end


endmodule
