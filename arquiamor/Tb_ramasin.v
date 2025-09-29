`timescale 1ns/1ps

module tb_RAM_async;

    reg clk;
    reg we;
    reg [3:0] addr;
    reg [7:0] data_in;
    wire [7:0] data_out;

    // Instancia de la RAM
    RAM_async uut (
        .addr(addr),
        .data_in(data_in),
        .we(we),
        .clk(clk),
        .data_out(data_out)
    );

    // Generador de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Proceso de prueba
    initial begin
        // Inicialización
        we = 0; addr = 0; data_in = 0;

        // Escritura de 5 casos
        @(posedge clk); addr = 4'd0; data_in = 8'd55; we = 1;
        @(posedge clk); addr = 4'd1; data_in = 8'd99; we = 1;
        @(posedge clk); addr = 4'd2; data_in = 8'd150; we = 1;
        @(posedge clk); addr = 4'd3; data_in = 8'd200; we = 1;
        @(posedge clk); addr = 4'd4; data_in = 8'd77; we = 1;

        // Terminar escrituras
        @(posedge clk); we = 0;

        // Lectura de los 5 valores escritos
        #2 addr = 4'd0; #2;
        #2 addr = 4'd1; #2;
        #2 addr = 4'd2; #2;
        #2 addr = 4'd3; #2;
        #2 addr = 4'd4; #2;

        #20 $finish;
    end

endmodule

