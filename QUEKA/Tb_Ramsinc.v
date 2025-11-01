`timescale 1ns/1ps

module tb_RAM_sync;

    reg clk;
    reg we;
    reg [3:0] addr;
    reg [7:0] data_in;
    wire [7:0] data_out;

    // Instancia de la RAM
    RAM_sync uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Generador de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Periodo de 10 ns
    end

    // Proceso de prueba
    initial begin
        // Inicializacin
        we = 0; addr = 0; data_in = 0;

        // Escritura de 5 casos
        @(posedge clk); addr = 4'd0; data_in = 8'd55; we = 1;
        @(posedge clk); addr = 4'd1; data_in = 8'd99; we = 1;
        @(posedge clk); addr = 4'd2; data_in = 8'd150; we = 1;
        @(posedge clk); addr = 4'd3; data_in = 8'd200; we = 1;
        @(posedge clk); addr = 4'd4; data_in = 8'd77; we = 1;

        // Terminar escritura
        @(posedge clk); we = 0;

        // Lectura de los 5 valores
        @(posedge clk); addr = 4'd0;
        @(posedge clk); addr = 4'd1;
        @(posedge clk); addr = 4'd2;
        @(posedge clk); addr = 4'd3;
        @(posedge clk); addr = 4'd4;

        #20 $finish;
    end

endmodule

