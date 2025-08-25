

// 1.- Definicion de modulo y entradas y salidas
module todas_las_compuertas(
    input a,
    input b,
    output c_not,   // Salida NOT (solo usa entrada a)
    output c_and,   // Salida AND
    output c_nand,  // Salida NAND
    output c_or,    // Salida OR
    output c_nor,   // Salida NOR
    output c_xor,   // Salida XOR
    output c_xnor   // Salida XNOR
);

    // 2.- Declarar señales/elementos internos
    // No se necesitan señales internas

    // 3.- Comportamiento del modulo (asignaciones continuas)
    assign c_not = ~a;          // Compuerta NOT (solo una entrada)
    assign c_and = a & b;       // Compuerta AND
    assign c_nand = ~(a & b);   // Compuerta NAND
    assign c_or = a | b;        // Compuerta OR
    assign c_nor = ~(a | b);    // Compuerta NOR
    assign c_xor = a ^ b;       // Compuerta XOR
    assign c_xnor = ~(a ^ b);   // Compuerta XNOR

endmodule // Termino de modulo
