//testbench for vgasdram


`timescale 1ns/1ns


module tb_sdrtest;
/*
sdram	sd_model(
				.clk(sdram_clk),
				.csb(sdram_cs_n), 
				.cke(sdram_cke), 
				.ba(sdram_ba), 
				.ad(sdram_addr), 
				.rasb(sdram_ras_n), 
				.casb(sdram_cas_n), 
				.web(sdram_we_n), 
				.dqm(2'b00), 
				.dqi(sdram_data)
				);
*/

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
wire rs232_tx;				// �������ݷ���

//inout
wire[15:0] sdram_data;		// SDRAM��������


////////////////////////////////////////////////
	// SDRAM�ķ�װ�ӿڲ�������
/*wire sdram_rd_ack;		//ϵͳ��SDRAM��Ӧ�ź�	
wire sdram_wr_ack;

wire[15:0] sys_data_in;
wire[15:0] sys_data_out;	//��SDRAMʱ�����ݴ���,(��ʽͬ��)
wire sdram_busy;			// SDRAMæ��־���߱�ʾSDRAM���ڹ�����
wire sys_dout_rdy;			// SDRAM���������ɱ�־

wire[15:0] rdf_dout;		//sdram���ݶ�������FIFO�����������	
wire rdf_rdreq;			//sdram���ݶ�������FIFO����������󣬸���Ч
*/
////////////////////////////////////////////////

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
			.rs232_tx(rs232_tx)/*,
			.sdram_rd_req(sdram_rd_req),
			.sdram_wr_ack(sdram_wr_ack),
			.sdram_rd_ack(sdram_rd_ack),
			.sys_data_in(sys_data_in),
			.sys_data_out(sys_data_out),
			.sdram_busy(sdram_busy),
			.sys_dout_rdy(sys_dout_rdy),
			.rdf_dout(rdf_dout),
			.rdf_rdreq(rdf_rdreq)*/
		);


reg[15:0] sdram_datar;
reg sdatalink;				
assign sdram_data = sdatalink ? sdram_datar:16'hzzzz;

integer write_232rx_file;	//�����ļ�ָ��	
integer cnt512;			//512����

initial begin
		//�������ݽ����ļ���ʼ��
	write_232rx_file = $fopen("write_232rx_file.txt");//txt�ļ���ʼ��
	$fdisplay(write_232rx_file,"rx232 receive data display:\n");
	cnt512 = 0;
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
reg[15:0] memd[255:0];	//256��16bit����
integer cnt;
always @(posedge sdram_clk) begin
	if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10011) begin	//��ѡͨ
		@(posedge sdram_clk); 
		@(posedge sdram_clk); 
		if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10100) begin	//д����
			for(cnt=0;cnt<256;cnt=cnt+1) begin
				memd[cnt] = sdram_data;
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
			for(cntrd=0;cntrd<256;cntrd=cntrd+1) begin
				#5;
				sdram_datar = memd[cntrd];
				@(posedge sdram_clk);
			end
			@(posedge sdram_clk);
			sdatalink = 1'b0;	
		end
	end
end


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



endmodule

