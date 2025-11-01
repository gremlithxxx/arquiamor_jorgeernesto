//definicion del modulo
module ROM(direccion, datos_s,clk);

input [7:0]direccion;
output reg [7:0] datos_s;
input clk;

//2.componentes internos 
//Creacion del modulo 
reg[7:0] ROM[0:10];
//3. Cuerpo dle modulo 
initial
begin 
 ROM[0] = 8'd95;
 ROM[1] = 8'd90;
 ROM[2] = 8'd96;
 ROM[3] = 8'd98;
 ROM[4] = 8'd93;
 ROM[5] = 8'd94;
 ROM[6] = 8'd97;
 ROM[7] = 8'd103;
 ROM[8] = 8'd56;
 ROM[9] = 8'd97;
 ROM[10] =8'd77;
 
end
always @(posedge clk)
begin 
datos_s <= ROM[direccion];
end
endmodule