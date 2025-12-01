// Memoria de Instrucciones (Instruction Memory) - MIPS Pipeline
// Características:
//   - Memoria de solo lectura (ROM)
//   - 256 palabras de 32 bits
//   - Dirección alineada a palabra (los 2 bits menos significativos se ignoran)
//   - Se carga desde archivo "instrucciones.txt" generado por el decodificador Python
// ============================================================================

module MemoriaInstrucciones (
    input  [31:0] Address,       // Direccion de la instruccion (PC)
    output [31:0] Instruction    // Instrucción de 32 bits
);
    // Memoria: 256 palabras de 32 bits
    reg [31:0] memory [0:255];
    
    // Inicializacion desde archivo
    initial begin
        // Inicializar toda la memoria con NOP (0x00000000)
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'h00000000;
        end
        // Cargar instrucciones desde archivo
        $readmemb("instrucciones.txt", memory);
    end

    // Lectura combinacional
    // Se usa Address[9:2] para direccionamiento por palabra (ignora los 2 LSB)
    assign Instruction = memory[Address[9:2]];

endmodule
