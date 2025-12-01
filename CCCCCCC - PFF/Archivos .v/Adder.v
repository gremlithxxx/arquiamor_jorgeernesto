// Sumador de 32 bits - MIPS Pipeline
module Adder (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] Result
);

    assign Result = A + B;

endmodule
