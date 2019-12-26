//testbench for logic_analysis.prj
`timescale 1ns/1ns

module tb_logic_analysis;

//print_task.v�����������Ϣ��ӡ�����װ
print_task	print();

//sys_ctrl_task.v�����ϵͳʱ�Ӳ�����Ԫ��ϵͳ��λ����
sys_ctrl_task	sys_ctrl(
						.clk(clk),
						.rst_n(rst_n)
					);

//input
wire clk;		//FPAG����ʱ���ź�25MHz
wire rst_n;		//ϵͳ��λ�ź�
reg[3:0] signal;	//4·�����ź�
reg trigger;		//1·�����źţ�������Ϊ�����ػ����½��ش���
reg tri_mode;		//�����ź�ģʽѡ��1--�����ش�����0--�½��ش���
reg[2:0] sampling_mode;	//����ģʽѡ��,mode=001--MODE1��mode=010--MODE2��mode=100--MODE3
reg sampling_clr_n;		//��������źţ����������ǰ�������ݣ�����Ч

//output
wire hsync;	//��ͬ���ź�
wire vsync;	//��ͬ���ź�
wire vga_r;
wire vga_g;
wire vga_b;

//���������Թ��̵��ڲ��źŽ��й۲�
/*wire clk_100m = uut.clk_100m;	//PLL���100MHz
wire clk_25m = uut.clk_25m;		//PLL���25MHz
wire[31:0] topic_data = uut.topic_data;		//����ROM��������
wire[7:0] topic_addr = uut.topic_addr;		//����ROM��ַ����
wire[15:0] char_data = uut.char_data;		//char ROM��������
wire[8:0] char_addr = uut.char_addr;		//char ROM��ַ����
*/

logic_analysis		uut(
					.clk(clk),
					.rst_n(rst_n),
					.signal(signal),
					.trigger(trigger),
					//.tri_mode(tri_mode),
					//.sampling_mode(sampling_mode),		
					.add_key(add_key),
					.dec_key(dec_key),
					.sampling_clr_n(sampling_clr_n),			
					.hsync(hsync),
					.vsync(vsync),
					.vga_r(vga_r),
					.vga_g(vga_g),
					.vga_b(vga_b)
				);
				
integer i;		
parameter	MODE1	= 3'b001,	//����MODE1	
			MODE2	= 3'b010,	//����MODE2
			MODE3	= 3'b100;	//����MODE3
parameter	POS_TRI	= 1'b1,		//�����ش���
			NEG_TRI = 1'b0;		//�½��ش���	
			
//������������	
task test_ing_task;
	input[2:0] test_tri_mode;	//����ģʽ����
	input test_sap_mode;		//����ģʽ����
	begin
		tri_mode = test_sap_mode;	
		sampling_mode = test_tri_mode;
		
		trigger = ~test_sap_mode;	//�����źŸ�λ
		#10;		
		
		for(i=0;i<100;i=i+1) begin
				@(posedge clk);
				signal = {$random}>>28;	//��������������ź�
			end
		
		trigger = test_sap_mode;	//�����źŴ���
		#10;
		
		for(i=0;i<100;i=i+1) begin
				@(posedge clk);
				signal = {$random}>>28;	//��������������ź�
			end		
		
		#1000;		//delay 1us	
	end
endtask		
		
//����Ѵ�����ʾ����
task wave_clr_task;
	begin
		sampling_clr_n = 1'b0;
		#200;
		sampling_clr_n = 1'b1;		
		#200;
	end
endtask


//���������
initial begin
	signal = 4'h0;	
	trigger = 1'b0;
	tri_mode = 3'bzzz;	
	sampling_mode = 1'bz;
	sampling_clr_n = 1'b1;

	sys_ctrl.sys_reset(200);	//��Ч��λ200ns
	
	#3_000;	//delay 3us
	
		//�ֱ���Բ�ͬ�Ĵ���ģʽ�Ͳ�ͬ�Ĳ���ģʽ����Ƿ����Ҫ��
	wave_clr_task;		//����Ѵ�����ʾ		
	test_ing_task(MODE1,POS_TRI);	//ģʽ1�������ش�������
	
	wave_clr_task;		//����Ѵ�����ʾ
	test_ing_task(MODE1,NEG_TRI);	//ģʽ1���½��ش�������

	wave_clr_task;		//����Ѵ�����ʾ
	test_ing_task(MODE2,POS_TRI);	//ģʽ2�������ش�������

	wave_clr_task;		//����Ѵ�����ʾ	
	test_ing_task(MODE2,NEG_TRI);	//ģʽ2���½��ش�������
	
	wave_clr_task;		//����Ѵ�����ʾ
	test_ing_task(MODE3,POS_TRI);	//ģʽ3�������ش�������

	wave_clr_task;		//����Ѵ�����ʾ		
	test_ing_task(MODE3,NEG_TRI);	//ģʽ3���½��ش�������
	
	#1000;	
	$stop;	
end



endmodule

