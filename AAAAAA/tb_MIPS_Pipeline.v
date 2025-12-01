// ============================================================================
// Testbench - MIPS Pipeline (Compatible con ModelSim)
// ============================================================================
`timescale 1ns / 1ps

module tb_MIPS_Pipeline;

    // Señales
    reg clk;
    reg reset;
    
    // Instanciar el procesador
    MIPS_Pipeline uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Generador de reloj
    initial begin
        clk = 0;
    end
    
    always begin
        #5 clk = ~clk;
    end
    
    // Proceso principal
    initial begin
        // Reset
        reset = 1;
        #20;
        reset = 0;
        
        // Ejecutar 500 ciclos
        #5000;
        
        // Mostrar resultados
        $display("=== RESULTADOS ===");
        $display("PC = %h", uut.PC_current);
        $display("=================");
        
        $stop;
    end

endmodule
