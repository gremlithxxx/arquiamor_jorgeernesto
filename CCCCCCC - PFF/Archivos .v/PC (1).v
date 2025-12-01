// PC (Program Counter) - MIPS Pipeline
// Función: Almacena la dirección de la instrucción actual
// El PC se actualiza en cada flanco positivo del reloj
// ============================================================================

module PC (
    input         clk,          // Reloj del sistema
    input         reset,        // Reset asíncrono (activo en alto)
    input         enable,       // Habilitador (para stalls del pipeline)
    input  [31:0] PC_in,        // Nueva dirección (PC+4 o dirección de salto)
    output reg [31:0] PC_out    // Dirección actual de instrucción
);

    // Comportamiento del PC
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_out <= 32'h00000000;  // Inicializa en dirección 0
        end
        else if (enable) begin
            PC_out <= PC_in;         // Actualiza con nueva dirección
        end
        // Si enable = 0, mantiene el valor actual (stall)
    end

endmodule
