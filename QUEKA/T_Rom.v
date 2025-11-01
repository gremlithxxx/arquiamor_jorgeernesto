`timescale 1ns/1ps

module tb_ROM;

// Señales para el DUT
reg clk;
reg [7:0] direccion;
wire [7:0] datos_s;

// Instancia de la ROM
ROM uut (
    .direccion(direccion),
    .datos_s(datos_s),
    .clk(clk)
);

// Generador de reloj (10 ns de periodo)
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Proceso de prueba con 5 casos
initial begin

    // Caso 1: dirección 0
    direccion = 8'd0;
    @(posedge clk);

    // Caso 2: dirección 3
    direccion = 8'd3;
    @(posedge clk);

    // Caso 3: dirección 5
    direccion = 8'd5;
    @(posedge clk);

    // Caso 4: dirección 8
    direccion = 8'd8;
    @(posedge clk);

    // Caso 5: dirección 10
    direccion = 8'd10;
    @(posedge clk);

    // Finalizar simulación
    #10;
    $finish;
end

endmodule
