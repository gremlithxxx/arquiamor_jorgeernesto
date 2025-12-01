// ALU Control - MIPS Pipeline
// Genera el codigo de control para la ALU basandose en:
//   - ALUOp (2 bits) de la Unidad de Control
//   - Campo Funct (6 bits) de la instrucción (para R-type)
//   - Opcode (6 bits) para instrucciones I-type especiales
//
// Códigos de salida (ALUControl):
//   0000 = AND
//   0001 = OR
//   0010 = ADD
//   0011 = XOR
//   0110 = SUB
//   0111 = SLT

module ALUControl (
    input  [1:0] ALUOp,        // Codigo de operacion de Control Unit
    input  [5:0] Funct,        // Campo funct de la instrucción (bits [5:0])
    input  [5:0] Opcode,       // Opcode para I-type especiales
    output reg [3:0] ALUCtrl   // Señal de control para la ALU
);
    // Definición de códigos Funct para R-type
    // ========================================================================
    localparam FUNCT_ADD = 6'b100000;  // 32
    localparam FUNCT_SUB = 6'b100010;  // 34
    localparam FUNCT_AND = 6'b100100;  // 36
    localparam FUNCT_OR  = 6'b100101;  // 37
    localparam FUNCT_SLT = 6'b101010;  // 42

    // Definicion de Opcodes para I-type
    // ========================================================================
    localparam OP_ANDI = 6'b001100;
    localparam OP_ORI  = 6'b001101;
    localparam OP_XORI = 6'b001110;
    localparam OP_SLTI = 6'b001010;

    // Códigos de control de la ALU
    // ========================================================================
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;

    // Logica de ALU Control
    always @(*) begin
        case (ALUOp)
            // ALUOp = 00: LW, SW, ADDI (y algunas I-type)
            2'b00: begin
                // Verificar si es una instrucción I-type especial
                case (Opcode)
                    OP_ANDI: ALUCtrl = ALU_AND;  // ANDI
                    OP_ORI:  ALUCtrl = ALU_OR;   // ORI
                    OP_XORI: ALUCtrl = ALU_XOR;  // XORI
                    default: ALUCtrl = ALU_ADD;  // LW, SW, ADDI -> ADD
                endcase
            end

            // ALUOp = 01: BEQ (resta para comparar)
            2'b01: begin
                ALUCtrl = ALU_SUB;  // Subtract para generar Zero flag
            end
            // ALUOp = 10: R-type (depende del campo Funct)
            2'b10: begin
                case (Funct)
                    FUNCT_ADD: ALUCtrl = ALU_ADD;  // ADD
                    FUNCT_SUB: ALUCtrl = ALU_SUB;  // SUB
                    FUNCT_AND: ALUCtrl = ALU_AND;  // AND
                    FUNCT_OR:  ALUCtrl = ALU_OR;   // OR
                    FUNCT_SLT: ALUCtrl = ALU_SLT;  // SLT
                    default:   ALUCtrl = ALU_ADD;  // Default: ADD
                endcase
            end
            // ALUOp = 11: SLTI (Set Less Than Immediate)
            2'b11: begin
                ALUCtrl = ALU_SLT;
            end
            // Default
            default: begin
                ALUCtrl = ALU_ADD;
            end
        endcase
    end

endmodule
