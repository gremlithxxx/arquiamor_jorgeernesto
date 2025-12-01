// Buffer EX/MEM - Pipeline MIPS
// ============================================================================
// Almacena los datos entre las etapas EX (Execute) y MEM (Memory Access)
//
// Señales que pasan:
//   - Señales de control (WB, MEM)
//   - Dirección de branch calculada
//   - Zero flag de la ALU
//   - Resultado de la ALU
//   - Dato a escribir en memoria (ReadData2)
//   - Registro destino
module EX_MEM_Buffer (
    input clk,
    input reset,
    input flush,
    // Señales de Control de entrada
    // Señales WB
    input EX_RegWrite,
    input EX_MemtoReg,
    // Señales MEM
    input EX_MemRead,
    input EX_MemWrite,
    input EX_Branch,
    // Datos de entrada
    input  [31:0] EX_BranchAddr,    // Dirección de branch (PC+4 + offset*4)
    input         EX_Zero,          // Zero flag de la ALU
    input  [31:0] EX_ALUResult,     // Resultado de la ALU
    input  [31:0] EX_ReadData2,     // Dato para SW (valor a escribir)
    input  [4:0]  EX_WriteReg,      // Registro destino (rd o rt)

    // ========================================================================
    // Señales de Control de salida
    // Señales WB
    output reg       MEM_RegWrite,
    output reg       MEM_MemtoReg,  
    // Señales MEM
    output reg       MEM_MemRead,
    output reg       MEM_MemWrite,
    output reg       MEM_Branch,
    // Datos de salida
    output reg [31:0] MEM_BranchAddr,
    output reg        MEM_Zero,
    output reg [31:0] MEM_ALUResult,
    output reg [31:0] MEM_ReadData2,
    output reg [4:0]  MEM_WriteReg
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Reset o Flush: insertar burbuja
            // Señales de control
            MEM_RegWrite  <= 1'b0;
            MEM_MemtoReg  <= 1'b0;
            MEM_MemRead   <= 1'b0;
            MEM_MemWrite  <= 1'b0;
            MEM_Branch    <= 1'b0;
            
            // Datos
            MEM_BranchAddr <= 32'b0;
            MEM_Zero       <= 1'b0;
            MEM_ALUResult  <= 32'b0;
            MEM_ReadData2  <= 32'b0;
            MEM_WriteReg   <= 5'b0;
        end
        else begin
            // Normal: pasar los valores
            // Señales de control
            MEM_RegWrite  <= EX_RegWrite;
            MEM_MemtoReg  <= EX_MemtoReg;
            MEM_MemRead   <= EX_MemRead;
            MEM_MemWrite  <= EX_MemWrite;
            MEM_Branch    <= EX_Branch;
            
            // Datos
            MEM_BranchAddr <= EX_BranchAddr;
            MEM_Zero       <= EX_Zero;
            MEM_ALUResult  <= EX_ALUResult;
            MEM_ReadData2  <= EX_ReadData2;
            MEM_WriteReg   <= EX_WriteReg;
        end
    end

endmodule
