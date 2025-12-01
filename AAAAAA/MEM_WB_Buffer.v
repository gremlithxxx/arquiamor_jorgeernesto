// Buffer MEM/WB - Pipeline MIPS
// ============================================================================
// Almacena los datos entre las etapas MEM (Memory) y WB (Write Back)
// Señales que pasan:
//   - Señales de control WB
//   - Dato leido de memoria
//   - Resultado de la ALU
//   - Registro destino
module MEM_WB_Buffer (
    input         clk,
    input reset,
    // Señales de Control de entrada (WB)
    input MEM_RegWrite,
    input MEM_MemtoReg,
    // Datos de entrada
    input  [31:0] MEM_ReadData,     // Dato leido de memoria (para LW)
    input  [31:0] MEM_ALUResult,    // Resultado de la ALU
    input  [4:0]  MEM_WriteReg,     // Registro destino
    // Señales de Control de salida (WB)
    output reg       WB_RegWrite,
    output reg       WB_MemtoReg,
    // Datos de salida
    output reg [31:0] WB_ReadData,
    output reg [31:0] WB_ALUResult,
    output reg [4:0]  WB_WriteReg
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset: limpiar buffer
            WB_RegWrite  <= 1'b0;
            WB_MemtoReg  <= 1'b0;
            WB_ReadData  <= 32'b0;
            WB_ALUResult <= 32'b0;
            WB_WriteReg  <= 5'b0;
        end
        else begin
            // Normal: pasar los valores
            WB_RegWrite  <= MEM_RegWrite;
            WB_MemtoReg  <= MEM_MemtoReg;
            WB_ReadData  <= MEM_ReadData;
            WB_ALUResult <= MEM_ALUResult;
            WB_WriteReg  <= MEM_WriteReg;
        end
    end

endmodule
