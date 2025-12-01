// Sign Extend - Extensor de Signo (16 bits -> 32 bits)
// Funcion: Extiende el campo inmediato de 16 bits a 32 bits
//          preservando el signo (bit 15 se replica en bits 31:16)
// Uso: Instrucciones tipo I (ADDI, LW, SW, BEQ, SLTI, etc.)
module SignExtend (
    input  [15:0] Imm16,      // Inmediato de 16 bits (instruction[15:0])
    output [31:0] Imm32       // Inmediato extendido a 32 bits
);

    // Extension de signo: replica el bit 15 en los bits superiores
    // Si bit 15 = 0 -> bits 31:16 = 0000...0000
    // Si bit 15 = 1 -> bits 31:16 = 1111...1111
    assign Imm32 = {{16{Imm16[15]}}, Imm16};

endmodule
