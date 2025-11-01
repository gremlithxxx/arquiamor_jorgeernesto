module queka(
	input clk,
	output [31:0] inst
);

wire [31:0] C1, C2;

PC queso (
	.clk(clk),
	.next(C1),
	.IA(C2)
);

MdI tortilla(
	.Dir(C1),
	.ia(inst)
);

sum salsa(
	.op1(31'd4),
	.op2(C1),
	.res(C2)
);

endmodule