`timescale 1ns/1ns
module TB();
	reg clk = 1, rst = 1;
	TopModule UUT(.clk(clk) , .rst(rst));
	
	always #50 clk = ~clk;
	initial begin
	#70 rst = 0;
	#10000 $stop;
	end
endmodule;
