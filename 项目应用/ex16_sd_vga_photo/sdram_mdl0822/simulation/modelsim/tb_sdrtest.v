//testbench for vgasdram


`timescale 1ns/1ns


module tb_sdrtest;

//print_task.v�����������Ϣ��ӡ�����װ
print_task	print();

//sys_ctrl_task.v�����ϵͳʱ�Ӳ�����Ԫ��ϵͳ��λ����
sys_ctrl_task	sys_ctrl(
						.clk(clk),
						.rst_n(rst_n)
					);
					
	//input				
wire clk;		//ϵͳʱ��,25MHz
wire rst_n;		//��λ�źţ��͵�ƽ��Ч

	//output
	// FPGA��SDRAMӲ���ӿ�
wire sdram_clk;				// SDRAMʱ���ź�
wire sdram_cke;				// SDRAMʱ����Ч�ź�
wire sdram_cs_n;			// SDRAMƬѡ�ź�
wire sdram_ras_n;			// SDRAM�е�ַѡͨ����
wire sdram_cas_n;			// SDRAM�е�ַѡͨ����
wire sdram_we_n;			// SDRAMд����λ
wire[1:0] sdram_ba;			// SDRAM��L-Bank��ַ��
wire[11:0] sdram_addr;		// SDRAM��ַ����
//wire rs232_tx;				// �������ݷ���

//inout
wire[15:0] sdram_data;		// SDRAM��������

	// SDӲ���ӿ�
reg spi_miso;		//SPI��������ӻ���������ź�
wire spi_mosi;	//SPI��������ӻ����������ź�
wire spi_clk;		//SPIʱ���źţ�����������
wire spi_cs_n;	//SPI���豸ʹ���źţ������豸����

	// FPGA��VGA�ӿ��ź�
wire hsync;	//��ͬ���ź�
wire vsync;	//��ͬ���ź�
wire[1:0] vga_r;
wire[2:0] vga_g;
wire[2:0] vga_b;

sdr_test	sd(
			.clk(clk),
			.rst_n(rst_n),
			.sdram_clk(sdram_clk),
			.sdram_cke(sdram_cke),
			.sdram_cs_n(sdram_cs_n),
			.sdram_ras_n(sdram_ras_n),
			.sdram_cas_n(sdram_cas_n),
			.sdram_we_n(sdram_we_n),
			.sdram_ba(sdram_ba),
			.sdram_addr(sdram_addr),
			.sdram_data(sdram_data),
			.spi_miso(spi_miso),
			.spi_mosi(spi_mosi),
			.spi_clk(spi_clk),
			.spi_cs_n(spi_cs_n),
			.hsync(hsync),
			.vsync(vsync),
			.vga_r(vga_r),
			.vga_g(vga_g),
			.vga_b(vga_b)

		);


reg[15:0] sdram_datar;
reg sdatalink;				
assign sdram_data = sdatalink ? sdram_datar:16'hzzzz;

//integer write_232rx_file;	//�����ļ�ָ��	
//integer cnt512;			//512����

initial begin
		//�������ݽ����ļ���ʼ��
//	write_232rx_file = $fopen("write_232rx_file.txt");//txt�ļ���ʼ��
//	$fdisplay(write_232rx_file,"rx232 receive data display:\n");
//	cnt512 = 0;
	spi_miso = 1;
	sdatalink = 0;
		//SDRAM����ӿڳ�ʼ��
	//sdatalink = 0;

		//ϵͳ��λ
	sys_ctrl.sys_reset(400);	//��Ч��λ400ns

	#200_000;	//�ȴ�200us

	//sdram_wr_task;
	#20_000;	//�ȴ�30us
	//sdram_rd_task;

		//�ȴ���ϵͳ�������
	#30_000_000;		//�ȴ�30ms	
	print.terminate;		
end


//ģ��sdram�洢д������
reg[15:0] memd[7:0];	//256��16bit����
integer cntwr;
always @(posedge sdram_clk) begin
	if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10011) begin	//��ѡͨ
		@(posedge sdram_clk); 
		@(posedge sdram_clk); 
		if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10100) begin	//д����
			for(cntwr=0;cntwr<8;cntwr=cntwr+1) begin
				memd[cntwr] = sdram_data;
				@(posedge sdram_clk);
			end	
		end
	end
end


//ģ��sdram�����ݶ�ʱ�������ͳ�
integer cntrd;
always @(posedge sdram_clk) begin
	if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10011) begin	//��ѡͨ
		@(posedge sdram_clk); 
		@(posedge sdram_clk); 
		if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10101) begin	//������
			@(posedge sdram_clk); 
			@(posedge sdram_clk); 
			sdatalink = 1'b1;
			for(cntrd=0;cntrd<8;cntrd=cntrd+1) begin
				#2;
				sdram_datar = memd[cntrd];
				@(posedge sdram_clk);
			end
			@(posedge sdram_clk);
			sdatalink = 1'b0;	
		end
	end
end

/*
//ģ�⴮�ڽ���
integer cntbit;		
reg[7:0] rxdata;	//���ڽ������ݼĴ���
parameter	BPS9600		= 104_167;		//9600bps������
parameter	BPS9600_2	= 52_083;		//9600bps������
always @(negedge rs232_tx) begin
	if(!rs232_tx) begin
		#BPS9600;		//��ʼλ�ȴ�
		#BPS9600_2;		//���������м�
		for(cntbit=0;cntbit<8;cntbit=cntbit+1) begin	//����8bit����
			rxdata[cntbit] = rs232_tx;
			#BPS9600;		//�ȴ���һλ
		end
		if(!rs232_tx) print.error("rs232_tx stop bit error");	//����λ������
		else #BPS9600_2;		//�ȴ�����λ���
		$fdisplay(write_232rx_file,"Receive data %d  :  %d\n",cnt512,rxdata);		//����ǰ���յ��Ĵ������������write_232rx_file.txt��
		$write("current receive data is %d\n",rxdata);
		cnt512 = cnt512+1;
	end
	
end
*/

//ģ��sd�������
integer i;
reg[9:0] j;
reg[7:0] rx_cmd;
reg[31:0] rx_arg;
reg[7:0] rx_crc;
always @(negedge spi_cs_n) begin	//ģ��SD�ӻ�
	//����8λcmd
	for(i=0;i<8;i=i+1) begin	
		@(posedge spi_clk); #2;
		rx_cmd[7-i] = spi_mosi;
	end
	//����32λarg
	for(i=0;i<32;i=i+1) begin	
		@(posedge spi_clk); #2;
		rx_arg[31-i] = spi_mosi;
	end
	//����8λCRC
	for(i=0;i<8;i=i+1) begin	
		@(posedge spi_clk); #2;
		rx_crc[7-i] = spi_mosi;
	end		
	//8CLK wait
	for(i=0;i<8;i=i+1) begin	
		@(posedge spi_clk); #2;
	end		
	//��ͬ����Ӧ
	if(rx_cmd[5:0] == 6'd0) begin		//CMD0��Ӧ
			//8CLK wait test
			repeat(10) begin
				for(i=0;i<8;i=i+1) begin	
					@(posedge spi_clk); #2;
				end		
			end
		for(i=0;i<8;i=i+1) begin	//respone
			@(negedge spi_clk); #2;
			if(i==7) spi_miso = 1'b1;	//CMD0��Ӧ0x01
			else spi_miso = 1'b0;
		end		
	end
	else begin	//������Ӧ
		for(i=0;i<8;i=i+1) begin	//respone
			@(negedge spi_clk); #2;
			spi_miso = 1'b0;
		end
	end

	//����������
	if(rx_cmd[5:0] == 6'd17) begin	
		//8CLK wait
		@(posedge spi_clk); #2;		
		for(i=0;i<8;i=i+1) begin	
			@(posedge spi_clk); #2;	
		end
		//CMD17������������ʼ�ֽ�
		for(i=0;i<8;i=i+1) begin	
			@(negedge spi_clk); #2;
			if(i==7) spi_miso = 1'b0;	//CMD17��Ӧ0xfe
			else spi_miso = 1'b1;
		end
		//512B���ݶ�ȡ
		for(j=512;j>0;j=j-1) begin
			for(i=0;i<8;i=i+1) begin	
				@(negedge spi_clk); #2;
					spi_miso = j[7-i];
			end
		end
	end	
	
	@(posedge spi_clk); #2;	//over
	for(i=0;i<8;i=i+1) begin	//8CLK wait
		@(posedge spi_clk); #2;
	end
	spi_miso = 1'b1;
			
end


endmodule

