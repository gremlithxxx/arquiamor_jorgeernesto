`timescale 1ns/1ns

module TB();

// Declaración de señales
reg [3:0] A_tb, B_tb;
wire [3:0] result_tb;
wire zero_tb;

// Instanciación del módulo ALU
ALU DUT (
    .A(A_tb),
    .B(B_tb),
    .result(result_tb),
    .zero(zero_tb)
);

initial begin
    // Inicializar entradas
    A_tb = 4'b0000;
    B_tb = 4'b0000;
    #100;
    
    // Test case 1: Suma (0 + 0)
    A_tb = 4'b0000;
    B_tb = 4'b0000;
    #100;
    
    // Test case 2: Suma (5 + 3)
    A_tb = 4'b0101;
    B_tb = 4'b0011;
    #100;
    
    // Test case 3: Suma (15 + 1) - overflow
    A_tb = 4'b1111;
    B_tb = 4'b0001;
    #100;
    
    // Test case 4: AND (5 & 3)
    A_tb = 4'b0101;
    B_tb = 4'b0011;
    #100;
    
    // Test case 5: AND (0 & 15) - prueba bandera zero
    A_tb = 4'b0000;
    B_tb = 4'b1111;
    #100;

    $finish;
end

endmodule