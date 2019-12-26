//testbench for logic_analysis.prj
`timescale 1ns/1ns

module tb_seg7;

//print_task.v�����������Ϣ��ӡ�����װ
print_task	print();

//sys_ctrl_task.v�����ϵͳʱ�Ӳ�����Ԫ��ϵͳ��λ����
sys_ctrl_task	sys_ctrl(
						.clk(clk),
						.rst_n(rst_n)
					);
//input
wire clk;	//FPAG����ʱ���ź�25MHz
wire rst_n;	//FPGA���븴λ�ź�

//output
wire ds_stcp;		//74HC595�Ĳ���ʱ�����룬�����ؽ���ǰ�����������ݲ������
wire ds_shcp;		//74HC595�Ĵ���ʱ�����룬���������浱ǰ������������
wire ds_data;		//74HC595�Ĵ�����������


seg7		uut(
					.clk(clk),
					.rst_n(rst_n),
					.ds_stcp(ds_stcp),
					.ds_shcp(ds_shcp),
					.ds_data(ds_data)
				);

//--------------------------------------------------

//���������

initial begin

		//ϵͳ��λ
	sys_ctrl.sys_reset(400);	//��Ч��λ400ns
	
	
		//�ȴ���ϵͳ�������
	#300_000;	
	print.terminate;	
end


	
endmodule
