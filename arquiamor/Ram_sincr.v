//Definicion d emodulo
module RAM_sync (
    input clk,              // Reloj
    input we,               // Write Enable (1 = escribir)
    input [3:0] addr,       // Dirección (16 posiciones)
    input [7:0] data_in,    // Datos de entrada
    output reg [7:0] data_out // Datos de salida (lectura síncrona)
);

    reg [7:0] mem [0:15];   // Memoria interna

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= data_in;   // Escritura
        end
        data_out <= mem[addr];      // Lectura síncrona
    end

endmodule

