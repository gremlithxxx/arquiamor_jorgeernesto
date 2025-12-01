// Unidad de Control (Control Unit) - MIPS Pipeline
// Genera las señales de control basándose en el opcode de la instruccion
//
// Instrucciones soportadas:
//   R-TYPE (opcode=000000): ADD, SUB, AND, OR, SLT
//   I-TYPE: ADDI, ANDI, ORI, XORI, SLTI, BEQ, LW, SW
//   J-TYPE: J=

module ControlUnit (
    input  [5:0] Opcode,       // Opcode de la instruccion (instruction[31:26])
    
    // Señales de control de salida
    output reg       RegDst,    // 0: rt (I-type), 1: rd (R-type)
    output reg       ALUSrc,    // 0: ReadData2, 1: Inmediato extendido
    output reg       MemtoReg,  // 0: ALUResult, 1: MemReadData
    output reg       RegWrite,  // 1: Escribir en banco de registros
    output reg       MemRead,   // 1: Leer de memoria de datos
    output reg       MemWrite,  // 1: Escribir en memoria de datos
    output reg       Branch,    // 1: Instrucción de branch
    output reg [1:0] ALUOp,     // Código de operación para ALU Control
    output reg       Jump       // 1: Instrucción de salto incondicional
);
    // Definicion de Opcodes MIPS
    localparam OP_RTYPE = 6'b000000;  // Instrucciones R-type
    localparam OP_J     = 6'b000010;  // Jump
    localparam OP_BEQ   = 6'b000100;  // Branch if Equal
    localparam OP_ADDI  = 6'b001000;  // Add Immediate
    localparam OP_SLTI  = 6'b001010;  // Set Less Than Immediate
    localparam OP_ANDI  = 6'b001100;  // AND Immediate
    localparam OP_ORI   = 6'b001101;  // OR Immediate
    localparam OP_XORI  = 6'b001110;  // XOR Immediate
    localparam OP_LW    = 6'b100011;  // Load Word
    localparam OP_SW    = 6'b101011;  // Store Word
    // Logica de Control
    always @(*) begin
        // Valores por defecto (NOP / instrucción no reconocida)
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;
        Jump     = 1'b0;

        case (Opcode)
            // R-TYPE: ADD, SUB, AND, OR, SLT
            OP_RTYPE: begin
                RegDst   = 1'b1;    // Destino: rd
                ALUSrc   = 1'b0;    // Fuente: ReadData2
                MemtoReg = 1'b0;    // Resultado: ALU
                RegWrite = 1'b1;    // Escribir resultado
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'b10;   // ALU Control usa campo funct
                Jump     = 1'b0;    // No es jump
            end
            // LW (Load Word)
            OP_LW: begin
                RegDst   = 1'b0;    // Destino: rt
                ALUSrc   = 1'b1;    // Fuente: Inmediato (offset)
                MemtoReg = 1'b1;    // Resultado: Memoria
                RegWrite = 1'b1;    // Escribir en registro
                MemRead  = 1'b1;    // Leer de memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'b00;   // ADD para calcular dirección
                Jump     = 1'b0;    // No es jump
            end
            // SW (Store Word)
            OP_SW: begin
                RegDst   = 1'bx;    // No importa (no escribe registro)
                ALUSrc   = 1'b1;    // Fuente: Inmediato (offset)
                MemtoReg = 1'bx;    // No importa
                RegWrite = 1'b0;    // No escribir registro
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b1;    // Escribir en memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'b00;   // ADD para calcular dirección
                Jump     = 1'b0;    // No es jump
            end
            // BEQ (Branch if Equal)
            OP_BEQ: begin
                RegDst   = 1'bx;    // No importa
                ALUSrc   = 1'b0;    // Fuente: ReadData2 (para comparar)
                MemtoReg = 1'bx;    // No importa
                RegWrite = 1'b0;    // No escribir registro
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b1;    // Es branch
                ALUOp    = 2'b01;   // SUB para comparar (Zero flag)
                Jump     = 1'b0;    // No es jump
            end
            // J (Jump)
            OP_J: begin
                RegDst   = 1'bx;    // No importa
                ALUSrc   = 1'bx;    // No importa
                MemtoReg = 1'bx;    // No importa
                RegWrite = 1'b0;    // No escribir registro
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'bxx;   // No importa
                Jump     = 1'b1;    // Es jump
            end
            // ADDI (Add Immediate)
            OP_ADDI: begin
                RegDst   = 1'b0;    // Destino: rt
                ALUSrc   = 1'b1;    // Fuente: Inmediato
                MemtoReg = 1'b0;    // Resultado: ALU
                RegWrite = 1'b1;    // Escribir resultado
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'b00;   // ADD
                Jump     = 1'b0;    // No es jump
            end
            // SLTI (Set Less Than Immediate)
            OP_SLTI: begin
                RegDst   = 1'b0;    // Destino: rt
                ALUSrc   = 1'b1;    // Fuente: Inmediato
                MemtoReg = 1'b0;    // Resultado: ALU
                RegWrite = 1'b1;    // Escribir resultado
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'b11;   // SLT directo
                Jump     = 1'b0;    // No es jump
            end
            // ANDI (AND Immediate)
            OP_ANDI: begin
                RegDst   = 1'b0;    // Destino: rt
                ALUSrc   = 1'b1;    // Fuente: Inmediato
                MemtoReg = 1'b0;    // Resultado: ALU
                RegWrite = 1'b1;    // Escribir resultado
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'b00;   // Se maneja especial en ALU Control
                Jump     = 1'b0;    // No es jump
            end
            // ORI (OR Immediate)
            OP_ORI: begin
                RegDst   = 1'b0;    // Destino: rt
                ALUSrc   = 1'b1;    // Fuente: Inmediato
                MemtoReg = 1'b0;    // Resultado: ALU
                RegWrite = 1'b1;    // Escribir resultado
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'b00;   // Se maneja especial en ALU Control
                Jump     = 1'b0;    // No es jump
            end
            // XORI (XOR Immediate)
            OP_XORI: begin
                RegDst   = 1'b0;    // Destino: rt
                ALUSrc   = 1'b1;    // Fuente: Inmediato
                MemtoReg = 1'b0;    // Resultado: ALU
                RegWrite = 1'b1;    // Escribir resultado
                MemRead  = 1'b0;    // No leer memoria
                MemWrite = 1'b0;    // No escribir memoria
                Branch   = 1'b0;    // No es branch
                ALUOp    = 2'b00;   // Se maneja especial en ALU Control
                Jump     = 1'b0;    // No es jump
            end
            // Default: NOP o instrucción no reconocida
            default: begin
                RegDst   = 1'b0;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
                Jump     = 1'b0;
            end
        endcase
    end

endmodule
