module alu(
    input [31:0] a,
    input [31:0] b,
    input [3:0] opcode,
    output reg [31:0] result,
    output reg zero,
    output reg carry
);

    wire [8:0] sum_result;
    wire [8:0] sub_result;
    
    // Sumador y restador
    assign sum_result = a + b;
    assign sub_result = a - b;
    
    always @(*) begin
        zero = 0;
        carry = 0;
        
        case (opcode)
            // Suma
            4'b0000: begin
                result = sum_result[7:0];
                carry = sum_result[8];
                zero = (result == 8'b0);
            end
            
            // Resta
            4'b0001: begin
                result = sub_result[7:0];
                carry = sub_result[8];
                zero = (result == 8'b0);
            end
            
            // AND
            4'b0010: begin
                result = a & b;
                zero = (result == 8'b0);
            end
            
            // OR
            4'b0011: begin
                result = a | b;
                zero = (result == 8'b0);
            end
            
            // XOR
            4'b0100: begin
                result = a ^ b;
                zero = (result == 8'b0);
            end
            
            // NOT A
            4'b0101: begin
                result = ~a;
                zero = (result == 8'b0);
            end
            
            // Comparación A == B
            4'b0110: begin
                result = (a == b) ? 8'b1 : 8'b0;
                zero = (a == b);
            end
            
            // Comparación A > B
            4'b0111: begin
                result = (a > b) ? 8'b1 : 8'b0;
                zero = (a > b);
            end
            
            // Desplazamiento izquierda
            4'b1000: begin
                carry = a[7];
                result = a << 1;
            end
            
            // Desplazamiento derecha
            4'b1001: begin
                carry = a[0];
                result = a >> 1;
            end
            
            // Multiplicación (solo LSB)
            4'b1010: begin
                result = a * b;
                zero = (result == 8'b0);
            end
            
            default: begin
                result = 8'b0;
                zero = 1'b1;
            end
        endcase
    end

endmodule