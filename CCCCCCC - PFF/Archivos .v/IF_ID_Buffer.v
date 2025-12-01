// Buffer IF/ID - Pipeline MIPS
// ============================================================================
// Almacena los datos entre las etapas IF (Instruction Fetch) e ID (Decode)
// Señales que pasan:
//   - PC+4: Para calculo de direcciones de branch
//   - Instruction: La instrucción leida de memoria
module IF_ID_Buffer (
    input clk,
    input reset,
    input enable,// Para stalls (1 = actualizar, 0 = mantener)
    input flush,// Para flush en branches/jumps
    
    // Entradas desde etapa IF
    input  [31:0] IF_PC_Plus4,      // PC + 4
    input  [31:0] IF_Instruction,   // Instrucción de 32 bits
    // Salidas hacia etapa ID
    output reg [31:0] ID_PC_Plus4,
    output reg [31:0] ID_Instruction
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset: limpiar el buffer
            ID_PC_Plus4    <= 32'b0;
            ID_Instruction <= 32'b0;  // NOP
        end
        else if (flush) begin
            // Flush: insertar burbuja (NOP)
            ID_PC_Plus4    <= 32'b0;
            ID_Instruction <= 32'b0;
        end
        else if (enable) begin
            // Normal: pasar los valores
            ID_PC_Plus4    <= IF_PC_Plus4;
            ID_Instruction <= IF_Instruction;
        end
        // Si enable = 0, mantener valores actuales (stall)
    end

endmodule
