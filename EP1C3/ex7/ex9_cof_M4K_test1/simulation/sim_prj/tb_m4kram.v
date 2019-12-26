//testbench for vgasdram
`

`timescale 1ns/1ns


module tb_m4kram;

reg clk;		//ϵͳʱ�ӣ�50MHz
reg rst_n;		//��λ�źţ��͵�ƽ��Ч

reg ram_wr;			//RAMд��ʹ���źţ��߱�ʾд��
reg[11:0] ram_addr;	//RAM��ַ����
reg[7:0]  ram_din;	//RAMд����������

wire[7:0] ram_dout;		//RAM������������

mem_cof	mem_cof(
			.clk(clk),
			.rst_n(rst_n),
			.ram_dout(ram_dout),
			.ram_wr(ram_wr),
			.ram_addr(ram_addr),
			.ram_din(ram_din)
		);


initial begin
	rst_n = 0;
	ram_wr = 0;
	ram_addr = 12'hzzz;
	ram_din = 8'hzz;
	#200;
	rst_n = 1;
	
	#3_000;	//delay 3us
	
	task_wr_ram(12'd0,8'd0);	//0��ַд����0
	task_wr_ram(12'd1,8'd1);	//1��ַд����1
	task_wr_ram(12'd2,8'd2);	//2��ַд����2
	task_wr_ram(12'd3,8'd3);	//3��ַд����3
	
	@(posedge clk);
	ram_addr = 12'd0;	//��0��ַ
	@(posedge clk);	
	ram_addr = 12'd1;	//��1��ַ
	@(posedge clk);
	ram_addr = 12'd2;	//��2��ַ
	@(posedge clk);
	ram_addr = 12'd3;	//��3��ַ
	
	#100;	
	$stop;	
end

initial begin
	clk = 0;
	forever
	#5 clk = ~clk;
end


//д��RAM����
task task_wr_ram;
	input[11:0] t_addr;
	input[7:0] t_data;
	begin
		@(posedge clk);
		fork
		ram_wr = 1;
		ram_addr = t_addr;
		ram_din = t_data;
		join
		@(posedge clk);
		fork
		ram_wr = 0;
		ram_addr = 12'hzzz;
		ram_din = 8'hzz;
		join		
	end
endtask


endmodule

