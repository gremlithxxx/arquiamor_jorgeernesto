`timescale 1ns/1ns
module BURRITO_tb();

reg [4:0] Dir1_tb, Dir2_tb, DirEscritura_tb;
//reg [17:0] instruccion; //[17:15]OPE, [14:10]OP1, [10:5]OP2, [4:0]RR

burrito DLU(
	.Dir1(Dir1_tb),
	.Dir2(Dir2_tb),
	.DirEscritura(DirEscritura_tb)
);

initial begin
	Dir1_tb=5'b0;
	Dir2_tb=5'd2;
	DirEscritura_tb=5'd20;
	#10;
	$stop;
end

	reg [17:0] instruccion [0:9];
	
initial begin
	$readmemb("instrucciones.txt", instruccion);
end

endmodule