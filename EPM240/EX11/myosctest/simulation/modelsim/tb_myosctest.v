`timescale 1ns/1ns

module tb_myosctest;

reg rst_n;	//�͵�ƽ��λ�ź�
wire clkdiv;	//�������8��Ƶ�ź�


myosctest	myosctest(
				.rst_n(rst_n),
				.clkdiv(clkdiv)
			);

initial begin
	rst_n = 0;
	#1000;
	rst_n = 1;
	#50000;
	$stop;
end



endmodule


