
module alu_tb;
    reg [7:0] a;
    reg [7:0] b;
    reg [3:0] opcode;
    wire [7:0] result;
    wire zero;
    wire carry;
    
    alu uut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .zero(zero),
        .carry(carry)
    );
    
    initial begin
        // Test de suma
        a = 8'd10; b = 8'd20; opcode = 4'b0000;
        #10;
        
        // Test de resta
        a = 8'd30; b = 8'd15; opcode = 4'b0001;
        #10;
        
        // Test AND
        a = 8'b11001100; b = 8'b10101010; opcode = 4'b0010;
        #10;
        
        // Test OR
        a = 8'b11001100; b = 8'b10101010; opcode = 4'b0011;
        #10;
        
        // Test XOR
        a = 8'b11001100; b = 8'b10101010; opcode = 4'b0100;
        #10;
        
        // Test comparación igualdad
        a = 8'd25; b = 8'd25; opcode = 4'b0110;
        #10;
        
        // Test comparación mayor que
        a = 8'd30; b = 8'd25; opcode = 4'b0111;
        #10;
        
        // Test desplazamiento izquierda
        a = 8'b00001111; opcode = 4'b1000;
        #10;
        
        // Test desplazamiento derecha
        a = 8'b11110000; opcode = 4'b1001;
        #10;
        
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t, A=%b, B=%b, OpCode=%b, Result=%b, Zero=%b, Carry=%b",
                 $time, a, b, opcode, result, zero, carry);
    end

endmodule