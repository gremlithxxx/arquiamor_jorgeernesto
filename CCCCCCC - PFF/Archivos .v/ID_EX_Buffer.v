// Buffer ID/EX - Pipeline MIPS
// ============================================================================
// Almacena los datos entre las etapas ID (Decode) y EX (Execute)
//
// Señales que pasan:
//   - Señales de control (WB, MEM, EX)
//   - PC+4
//   - Datos leidos del banco de registros
//   - Inmediato extendido
//   - Campos de la instrucción (rs, rt, rd, funct, opcode)
module ID_EX_Buffer (
    input clk,
    input reset,
    input flush,            // Para hazards
    // Señales de Control de entrada (desde Control Unit)
    // Señales WB (Write Back)
    input ID_RegWrite,
    input ID_MemtoReg,
    // Señales MEM (Memory)
    input ID_MemRead,
    input ID_MemWrite,
    input ID_Branch,
    
    // Señales EX (Execute)
    input [1:0] ID_ALUOp,
    input ID_ALUSrc,
    input ID_RegDst,
    // Datos de entrada
    input  [31:0] ID_PC_Plus4,
    input  [31:0] ID_ReadData1,     // Dato del registro rs
    input  [31:0] ID_ReadData2,     // Dato del registro rt
    input  [31:0] ID_SignExtImm,    // Inmediato extendido
    input  [4:0]  ID_Rs,            // instruction[25:21]
    input  [4:0]  ID_Rt,            // instruction[20:16]
    input  [4:0]  ID_Rd,            // instruction[15:11]
    input  [5:0]  ID_Funct,         // instruction[5:0]
    input  [5:0]  ID_Opcode,        // instruction[31:26]
    // Señales de Control de salida
    // Señales WB
    output reg EX_RegWrite,
    output reg EX_MemtoReg,
    // Señales MEM
    output reg EX_MemRead,
    output reg EX_MemWrite,
    output reg EX_Branch,
    // Señales EX
    output reg [1:0] EX_ALUOp,
    output reg EX_ALUSrc,
    output reg EX_RegDst,
    // Datos de salida
    output reg [31:0] EX_PC_Plus4,
    output reg [31:0] EX_ReadData1,
    output reg [31:0] EX_ReadData2,
    output reg [31:0] EX_SignExtImm,
    output reg [4:0]  EX_Rs,
    output reg [4:0]  EX_Rt,
    output reg [4:0]  EX_Rd,
    output reg [5:0]  EX_Funct,
    output reg [5:0]  EX_Opcode
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            // Reset o Flush: insertar burbuja (NOP)
            // Señales de control
            EX_RegWrite  <= 1'b0;
            EX_MemtoReg  <= 1'b0;
            EX_MemRead   <= 1'b0;
            EX_MemWrite  <= 1'b0;
            EX_Branch    <= 1'b0;
            EX_ALUOp     <= 2'b00;
            EX_ALUSrc    <= 1'b0;
            EX_RegDst    <= 1'b0;
            
            // Datos
            EX_PC_Plus4   <= 32'b0;
            EX_ReadData1  <= 32'b0;
            EX_ReadData2  <= 32'b0;
            EX_SignExtImm <= 32'b0;
            EX_Rs         <= 5'b0;
            EX_Rt         <= 5'b0;
            EX_Rd         <= 5'b0;
            EX_Funct      <= 6'b0;
            EX_Opcode     <= 6'b0;
        end
        else begin
            // Normal: pasar los valores
            // Señales de control
            EX_RegWrite  <= ID_RegWrite;
            EX_MemtoReg  <= ID_MemtoReg;
            EX_MemRead   <= ID_MemRead;
            EX_MemWrite  <= ID_MemWrite;
            EX_Branch    <= ID_Branch;
            EX_ALUOp     <= ID_ALUOp;
            EX_ALUSrc    <= ID_ALUSrc;
            EX_RegDst    <= ID_RegDst;
            
            // Datos
            EX_PC_Plus4   <= ID_PC_Plus4;
            EX_ReadData1  <= ID_ReadData1;
            EX_ReadData2  <= ID_ReadData2;
            EX_SignExtImm <= ID_SignExtImm;
            EX_Rs         <= ID_Rs;
            EX_Rt         <= ID_Rt;
            EX_Rd         <= ID_Rd;
            EX_Funct      <= ID_Funct;
            EX_Opcode     <= ID_Opcode;
        end
    end

endmodule
