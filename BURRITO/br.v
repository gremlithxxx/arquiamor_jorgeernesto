module br(//definicion del modulo
	input [4:0] RR1,		//leector de regstro 1
	input [4:0] RR2,		//leector de registro 2
	input [4:0] Writereg, 	//escritura de  registro
	input [31:0] WriteData, //escribir datos
	input Regwrite, 		//1 bit de entrada
	output reg [31:0] RD1,	//salida 1 tipo registro 
	output reg [31:0] RD2	//salida 2
);
//Componentes del BR
reg [31:0] BR [0:31];

//CUerpo del modulo
always @* begin
	if(Regwrite)begin			//Si Regwrite es exactamente igual a 1 hace (escribir), booleano
		BR[Writereg]=WriteData;//escribir
	end 
	RD1=BR[RR1];			//siempre lee
	RD2=BR[RR2];			//siempre lee
	
end
endmodule