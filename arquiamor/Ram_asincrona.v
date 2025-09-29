//Definicion d emodulo
module RAM_async (
    input [3:0] addr,       // Dirección (16 posiciones)
    input [7:0] data_in,    // Datos de entrada
    input we,               // Write Enable (1 = escribir)
    input clk,              // Reloj para escritura
    output [7:0] data_out   // Datos de salida
);

    reg [7:0] mem [0:15];   // Memoria interna

    // Escritura 
    always @(posedge clk) begin
        if (we)
            mem[addr] <= data_in;
    end

    // Lectura 
    assign data_out = mem[addr];

endmodule

