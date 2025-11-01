`timescale 1ns/1ns 
module queka_tb(
	//No tiene ni entradas ni salidas, porque es un test bench
);

reg clk;
wire [31:0] IQ_tb;

queka DUV(
	.clk(clk),
	.inst(IQ_tb)
);

initial begin
	clk = 0;
end

always # (100/2) clk=~clk;

initial begin
	#350;
	$stop;
end

endmodule