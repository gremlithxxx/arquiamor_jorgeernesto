//fag
`timescale 1ns/1ns

module TB();

//2
reg x_tb, y_tb;
wire s_tb, as_tb;


HA DUT (.x(x_tb),.y(y_tb),.s(s_tb),.as(as_tb));

initial		//valida las diferentes entradas
begin
x_tb=0;	
y_tb=0;	
#100;		
x_tb=0;
y_tb=1;
#100;
x_tb=1;
y_tb=0;
#100;
x_tb=1;
y_tb=1;
#100;

end

endmodule
