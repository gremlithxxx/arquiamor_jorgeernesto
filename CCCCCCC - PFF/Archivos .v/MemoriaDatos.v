// Memoria de Datos (Data Memory) - MIPS Pipeline
// Características:
//   - 256 palabras de 32 bits
//   - Lectura combinacional (asíncrona)
//   - Escritura síncrona (flanco positivo)
//   - Usada por instrucciones LW (load word) y SW (store word)
// ============================================================================

module MemoriaDatos (
    input         clk,           // Reloj del sistema
    input         MemRead,       // Habilitador de lectura
    input         MemWrite,      // Habilitador de escritura
    input  [31:0] Address,       // Dirección de memoria
    input  [31:0] WriteData,     // Dato a escribir (para SW)
    output [31:0] ReadData       // Dato leído (para LW)
);

    // Memoria: 256 palabras de 32 bits
    reg [31:0] memory [0:255];
    
    // Inicialización
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'b0;
        end
        // Cargar datos iniciales desde archivo
        $readmemb("datos.txt", memory);
    end
    // LECTURA - Combinacional
    // Se usa Address[9:2] para direccionamiento por palabra
    assign ReadData = (MemRead) ? memory[Address[9:2]] : 32'b0;
    // ESCRITURA - Sincrona
    always @(posedge clk) begin
        if (MemWrite) begin
            memory[Address[9:2]] <= WriteData;
        end
    end

endmodule
