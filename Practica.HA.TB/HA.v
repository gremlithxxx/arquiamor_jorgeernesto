//fag
//1.-Definicion de modulo, entradas y salidas
module AH (input x, input y, output s, output as);

//2.-Declarar señales/elementos internos
//No aplica

//3.-comportamieto del modulo (asignaciones, instancias, conexiones)

//and
assign s=x&y;
//xor
assign as=x^y;

endmodule //Termino de modulo