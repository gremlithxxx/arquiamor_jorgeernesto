module burrito(
	input [4:0] AR1,//entrada a alu
	input [4:0] AR2,//entrada a alu
	input [4:0] AW,//conectar a datain
	input [4:0] DirEscritura,
	input [2:0] sel
);

wire [31:0] C1, C2, C3;

ALU tortilla (
	.a(C1),
	.b(C2),
	.result(C3)
);

BR relleno(
	.AR1(Dir1),
	.AR2(Dir2),
	.AW(DirEscritura),
	.WriteData(C3),
	.Regwrite(1),
	.RD1(C1),
	.RD2(C2)
);

endmodule