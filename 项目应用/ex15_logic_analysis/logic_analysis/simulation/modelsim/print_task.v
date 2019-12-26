
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:45:36 04/01/2009
// Design Name:   cpu_cpld
// Module Name:   D:/verilog_prj/KS7_CPU_SIM/testbech_prj/cpu_cpld/print_task.v
// Project Name:  cpu_cpld
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu_cpld
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module print_task;


//----------------------------------------------------------------------//
//������Ϣ��ӡ�����װ
//----------------------------------------------------------------------//		
//������Ϣ��ӡ����
task warning;
	input[80*8:1] msg;
	begin
		$write("WARNING at %t : %s",$time,msg);
	end
endtask

//������Ϣ��ӡ����
task error;
	input[80*8:1] msg;
	begin
		$write("ERROR at %t : %s",$time,msg);
	end
endtask

//���������ӡ��ֹͣ��������
task fatal;
	input[80*8:1] msg;
	begin
		$write("FATAL at %t : %s",$time,msg);
		$write("Simulation false\n");
		$stop;
	end
endtask

//��ɷ�������
task terminate;	
	begin
		$write("Simulation Successful\n");
		$stop;		
	end
endtask	
      		

		
endmodule

