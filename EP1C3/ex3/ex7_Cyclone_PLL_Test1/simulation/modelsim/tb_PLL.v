`timescale 1ns/1ns



module tb_PLL();

//input
reg clk;
reg rst_n;

//output
wire clkdiv;
wire locked;


//���������ԵĹ���cyclone_PLL_top
cyclone_PLL_top		u_pll(
						.clk(clk),
						.rst_n(rst_n),
						.clkdiv(clkdiv),
						.locked(locked)
					);

//��λ�źŲ���������Ч
initial begin
	clk = 0;
	rst_n = 0;
	#300;
	rst_n = 1;
	#800;
	$stop;
end

//25Mʱ���źŲ���
always #20 clk = ~clk;



endmodule

