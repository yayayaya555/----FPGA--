`timescale 1ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:31:52 09/11/2008
// Design Name:   test_top
// Module Name:   vtf_test1.v
// Project Name:  top_dram
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: test_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module vtf_test;

reg clk;		//оƬ��ʱ���źš�
reg rst_n;	//�͵�ƽ��λ�������źš�����Ϊ0��ʾоƬ��λ������Ϊ1��ʾ��λ�ź���Ч��
reg start; 	//оƬʹ���źš�����Ϊ0��ʾ�ź���Ч������Ϊ1��ʾоƬ��������ܽŵó����ͱ������������˻���λ���㡣
reg[15:0] ain;	//����a������������������λ��Ϊ16bit.
reg[15:0] bin;	//����b����������������λ��Ϊ16bit.

wire[31:0] yout;	//�˻������������λ��Ϊ32bit.
wire done;		//оƬ�����־�źš�����Ϊ1��ʾ�˷��������.

mux16	uut(
			.clk(clk),
			.rst_n(rst_n),
			.start(start),
			.ain(ain),
			.bin(bin),
			.yout(yout),
			.done(done)
		);

initial begin
	clk = 0;
	forever 
	#10 clk = ~clk;	//����50MHz��ʱ��
end

initial begin
	rst_n = 1'b0;
	start = 1'b0;
	ain = 16'd0;
	bin = 16'd0;
	#1000;
	rst_n = 1'b1;	//�ϵ��1us��λ�ź�
	
	#1000;
	ain = 8'd89;
	bin = 8'd33;
	#100;
	start = 1'b1;
	#4500;
	start = 1'b0;
	#1000_000;
	$stop;
end
      
endmodule

