
module ALU (
    input [3:0] A,          // Operando A de 4 bits
    input [3:0] B,          // Operando B de 4 bits
    input sel,              // Selector de operación (0: Suma, 1: AND)
    output reg [3:0] result,// Resultado de 4 bits
    output reg zero         // Bandera zero (1 si resultado = 0)
);

    always @(*) begin
        case (sel)
            1'b0: result = A + B;      // Suma
            1'b1: result = A & B;      // AND lógico
            default: result = 4'b0000; // Default
        endcase
        
        // Bandera zero
        zero = (result == 4'b0000) ? 1'b1 : 1'b0;
    end

endmodule