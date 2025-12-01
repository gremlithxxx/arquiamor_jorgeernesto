// Banco de Registros (Register File) - MIPS 32 registros x 32 bits
// Caracteristicas:
//   - 32 registros de 32 bits cada uno
//   - 2 puertos de lectura (combinacional)
//   - 1 puerto de escritura (síncrono, flanco negativo)
//   - Registro $0 siempre vale 0
//   - Escritura en flanco negativo para evitar hazards estructurales
module BancoRegistros (
    input         clk,           // Reloj del sistema
    input         reset,         // Reset asíncrono
    input         RegWrite,      // Habilitador de escritura
    input  [4:0]  ReadReg1,      // Direccion registro a leer 1 (rs)
    input  [4:0]  ReadReg2,      // Direccion registro a leer 2 (rt)
    input  [4:0]  WriteReg,      // Direccion registro a escribir (rd o rt)
    input  [31:0] WriteData,     // Dato a escribir
    output [31:0] ReadData1,     // Dato leido del registro 1
    output [31:0] ReadData2      // Dato leido del registro 2
);

    // Arreglo de 32 registros de 32 bits
    reg [31:0] registers [0:31];
    
    // Variable para inicialización
    integer i;

    // Inicialización de registros (todos en 0)
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // LECTURA - Combinacional (asincrona)
    assign ReadData1 = (ReadReg1 == 5'b0) ? 32'b0 :  // $0 siempre es 0
                       (RegWrite && (WriteReg == ReadReg1) && (WriteReg != 5'b0)) ? WriteData :
                       registers[ReadReg1];
                       
    assign ReadData2 = (ReadReg2 == 5'b0) ? 32'b0 :  // $0 siempre es 0
                       (RegWrite && (WriteReg == ReadReg2) && (WriteReg != 5'b0)) ? WriteData :
                       registers[ReadReg2];
    // ESCRITURA - Sincrona (flanco negativo del reloj)
    // ========================================================================
    // Se usa flanco negativo para que el dato este disponible en la primera
    // mitad del ciclo siguiente, evitando conflictos con la etapa WB
    
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            // Reset: todos los registros a 0
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end
        else if (RegWrite && (WriteReg != 5'b0)) begin
            // Escribir si RegWrite esta activo y no es el registro $0
            registers[WriteReg] <= WriteData;
        end
    end

endmodule
