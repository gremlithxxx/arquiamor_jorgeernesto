/// Shift Left 2 - Desplazador a la Izquierda (x4)
// ============================================================================
// Función: Desplaza la entrada 2 bits a la izquierda (multiplica por 4)
//          Los 2 bits menos significativos se rellenan con 0
//
// Uso 1: Calculo de dirección de branch (offset * 4)
// Uso 2: Calculo de dirección de jump (address * 4)

module ShiftLeft2 (
    input  [31:0] DataIn,     // Dato de entrada
    output [31:0] DataOut     // Dato desplazado (DataIn << 2)
);

    // Desplazamiento: equivale a multiplicar por 4
    // En MIPS las direcciones están alineadas a palabra (4 bytes)
    assign DataOut = {DataIn[29:0], 2'b00};

endmodule

// Shift Left 2 para Jump (26 bits -> 28 bits)
// Version especial para instrucciones J-type
// Toma los 26 bits de dirección y los desplaza a 28 bits

module ShiftLeft2_Jump (
    input  [25:0] JumpAddr26,    // Dirección de 26 bits (instruction[25:0])
    output [27:0] JumpAddr28     // Dirección desplazada a 28 bits
);

    assign JumpAddr28 = {JumpAddr26, 2'b00};

endmodule
