// Multiplexores (MUX) - MIPS Pipeline
// Coleccion de multiplexores usados en el datapath MIPS
// MUX 2:1 de 5 bits - Para RegDst
// Selecciona el registro destino de escritura:
//   Sel=0: rt (instruction[20:16]) - Para instrucciones I-type (LW, ADDI, etc.)
//   Sel=1: rd (instruction[15:11]) - Para instrucciones R-type (ADD, SUB, etc.)

module Mux2to1_5bit (
    input  [4:0] In0,// Entrada 0
    input  [4:0] In1,// Entrada 1
    input Sel,// Selector
    output [4:0] Out // Salida
);
    assign Out = (Sel) ? In1 : In0;
endmodule
// MUX 2:1 de 32 bits - Uso General

// Usado para:
//   - ALUSrc: Selecciona entre ReadData2 o Inmediato extendido
//   - MemtoReg: Selecciona entre ALUResult o MemReadData
//   - PCSrc: Selecciona entre PC+4 o BranchAddress

module Mux2to1_32bit (
    input  [31:0] In0,        // Entrada 0
    input  [31:0] In1,        // Entrada 1
    input         Sel,        // Selector
    output [31:0] Out         // Salida
);

    assign Out = (Sel) ? In1 : In0;

endmodule

// MUX 3:1 de 32 bits - Para selección de PC (con Jump)
// Selecciona la siguiente dirección del PC:
//   Sel=00: PC+4 (siguiente instrucción secuencial)
//   Sel=01: BranchAddr (dirección de branch)
//   Sel=10: JumpAddr (dirección de jump)

module Mux3to1_32bit (
    input  [31:0] In0,        // Entrada 0: PC+4
    input  [31:0] In1,        // Entrada 1: Branch Address
    input  [31:0] In2,        // Entrada 2: Jump Address
    input  [1:0]  Sel,        // Selector
    output reg [31:0] Out     // Salida
);

    always @(*) begin
        case (Sel)
            2'b00:   Out = In0;   // PC + 4
            2'b01:   Out = In1;   // Branch
            2'b10:   Out = In2;   // Jump
            default: Out = In0;   // Default: PC + 4
        endcase
    end

endmodule
// MUX 4:1 de 32 bits - Para Forwarding Unit (hazards)
// Usado en la unidad de forwarding para resolver data hazards
//   Sel=00: Valor original del registro
//   Sel=01: Forward desde EX/MEM
//   Sel=10: Forward desde MEM/WB
//   Sel=11: Reservado
module Mux4to1_32bit (
    input  [31:0] In0,        // Entrada 0
    input  [31:0] In1,        // Entrada 1
    input  [31:0] In2,        // Entrada 2
    input  [31:0] In3,        // Entrada 3
    input  [1:0]  Sel,        // Selector
    output reg [31:0] Out     // Salida
);

    always @(*) begin
        case (Sel)
            2'b00:   Out = In0;
            2'b01:   Out = In1;
            2'b10:   Out = In2;
            2'b11:   Out = In3;
            default: Out = In0;
        endcase
    end

endmodule
