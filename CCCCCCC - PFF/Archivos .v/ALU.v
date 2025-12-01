// Codigos de operacionMIPS estandar:
//   0000 = AND
//   0001 = OR
//   0010 = ADD
//   0011 = XOR
//   0110 = SUB
//   0111 = SLT (Set on Less Than)

module ALU (
    input      [31:0] A,           // Operando 1 (Read Data 1 del BR)
    input      [31:0] B,           // Operando 2 (Read Data 2 o Inmediato)
    input      [3:0]  ALUControl,  // Código de operación
    output reg [31:0] ALUResult,   // Resultado de la operación
    output            Zero         // Flag Zero (1 si resultado = 0)
);

    // Flag Zero: se activa cuando el resultado es cero
    // Útil para instrucciones de branch (BEQ)
    assign Zero = (ALUResult == 32'b0);

    // Lógica combinacional de la ALU
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A & B;                      // AND
            4'b0001: ALUResult = A | B;                      // OR
            4'b0010: ALUResult = A + B;                      // ADD
            4'b0011: ALUResult = A ^ B;                      // XOR
            4'b0110: ALUResult = A - B;                      // SUB
            4'b0111: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;  // SLT (signed)
            default: ALUResult = 32'b0;                      // Default
        endcase
    end

endmodule
