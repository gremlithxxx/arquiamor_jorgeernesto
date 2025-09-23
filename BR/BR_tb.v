`timescale 1ns/1ns

module BR_tb();
    reg [4:0] RR1, RR2, Writereg;
    reg [31:0] WriteData;
    reg Regwrite;
    wire [31:0] RD1, RD2;
    
    BR uut (
        .RR1(RR1),
        .RR2(RR2),
        .Writereg(Writereg),
        .WriteData(WriteData),
        .Regwrite(Regwrite),
        .RD1(RD1),
        .RD2(RD2)
    );
    
    initial begin
        RR1 = 0;
        RR2 = 0;
        Writereg = 0;
        WriteData = 0;
        Regwrite = 0;
        
        #10;
        
        Regwrite = 1;
        Writereg = 10;
        WriteData = 32'hABCDEF01;
        RR1 = 10;
        RR2 = 9;
        #10;
        
        Regwrite = 1;
        Writereg = 1;
        WriteData = 32'h11111111;
        #10;

        Writereg = 2;
        WriteData = 32'h22222222;
        #10;
        
        Writereg = 3;
        WriteData = 32'h33333333;
        #10;
        
        Regwrite = 0;
        RR1 = 1;
        RR2 = 2;
        #10;

        RR1 = 3;
        RR2 = 20;
        #10;
        
        Regwrite = 0;
        Writereg = 9;
        WriteData = 32'hFACE1234;
        #10;
        
        RR1 = 9;
        #10;
        
        Regwrite = 1;
        #10;
        
        RR1 = 9;
        #10;
        
        $finish;
    end
    
endmodule