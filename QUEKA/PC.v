//`timescale 1ns/1ns
 module PC(				//Cuando clk=posedge
	input clk,
	input [31:0] next,
	output reg [31:0] IA
 );
 
initial begin
	IA=32'b0;
end
 
always @(posedge clk) begin
	IA=next;
end
 endmodule