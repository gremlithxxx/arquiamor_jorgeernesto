// ============================================================================
// MIPS Pipeline de 5 Etapas - Modulo TOP
// ============================================================================
// Arquitectura de Computadoras - Proyecto Final
// Conecta todos los modulos del pipeline:
//   IF  -> IF/ID -> ID -> ID/EX -> EX -> EX/MEM -> MEM -> MEM/WB -> WB
//
// Instrucciones soportadas:
//   R-TYPE: ADD, SUB, AND, OR, SLT
//   I-TYPE: ADDI, ANDI, ORI, XORI, SLTI, BEQ, LW, SW
//   J-TYPE: J
// ============================================================================

module MIPS_Pipeline (
    input clk,
    input reset
);
    // SEÑALES DE INTERCONEXION

    // --- Etapa IF (Instruction Fetch) ---
    wire [31:0] PC_current;
    wire [31:0] PC_next;
    wire [31:0] PC_plus4;
    wire [31:0] Instruction_IF;
    wire [31:0] JumpAddr;
    wire [1:0]  PC_Sel;
    wire        PCSrc;
    
    // --- Buffer IF/ID ---
    wire [31:0] ID_PC_Plus4;
    wire [31:0] ID_Instruction;
    
    // --- Etapa ID (Instruction Decode) ---
    wire [5:0]  Opcode;
    wire [4:0]  Rs, Rt, Rd;
    wire [5:0]  Funct;
    wire [15:0] Immediate;
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] SignExtImm;
    wire [27:0] JumpAddr28;
    
    // Señales de control
    wire        RegDst_ID, ALUSrc_ID, MemtoReg_ID, RegWrite_ID;
    wire        MemRead_ID, MemWrite_ID, Branch_ID, Jump_ID;
    wire [1:0]  ALUOp_ID;
    
    // --- Buffer ID/EX ---
    wire        EX_RegWrite, EX_MemtoReg, EX_MemRead, EX_MemWrite, EX_Branch;
    wire [1:0]  EX_ALUOp;
    wire        EX_ALUSrc, EX_RegDst;
    wire [31:0] EX_PC_Plus4, EX_ReadData1, EX_ReadData2, EX_SignExtImm;
    wire [4:0]  EX_Rs, EX_Rt, EX_Rd;
    wire [5:0]  EX_Funct, EX_Opcode;
    
    // --- Etapa EX (Execute) ---
    wire [31:0] ALU_InputB;
    wire [31:0] ALUResult;
    wire        Zero;
    wire [3:0]  ALUCtrl;
    wire [4:0]  WriteReg_EX;
    wire [31:0] BranchOffset;
    wire [31:0] BranchAddr_EX;
    
    // --- Buffer EX/MEM ---
    wire        MEM_RegWrite, MEM_MemtoReg, MEM_MemRead, MEM_MemWrite, MEM_Branch;
    wire [31:0] MEM_BranchAddr, MEM_ALUResult, MEM_ReadData2;
    wire        MEM_Zero;
    wire [4:0]  MEM_WriteReg;
    
    // --- Etapa MEM ---
    wire [31:0] MemReadData;
    
    // --- Buffer MEM/WB ---
    wire        WB_RegWrite, WB_MemtoReg;
    wire [31:0] WB_ReadData, WB_ALUResult;
    wire [4:0]  WB_WriteReg;
    
    // --- Etapa WB ---
    wire [31:0] WriteBackData;
    
    // --- Control del pipeline ---
    wire        IF_ID_Flush;
    // ========================================================================
    // ETAPA IF
    PC pc_unit (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .PC_in(PC_next),
        .PC_out(PC_current)
    );
    
    Adder pc_adder (
        .A(PC_current),
        .B(32'd4),
        .Result(PC_plus4)
    );
    
    MemoriaInstrucciones imem (
        .Address(PC_current),
        .Instruction(Instruction_IF)
    );
    
    ShiftLeft2_Jump shift_jump (
        .JumpAddr26(ID_Instruction[25:0]),
        .JumpAddr28(JumpAddr28)
    );
    assign JumpAddr = {ID_PC_Plus4[31:28], JumpAddr28};
    
    assign PCSrc = MEM_Branch & MEM_Zero;
    assign PC_Sel = Jump_ID ? 2'b10 : (PCSrc ? 2'b01 : 2'b00);
    
    Mux3to1_32bit pc_mux (
        .In0(PC_plus4),
        .In1(MEM_BranchAddr),
        .In2(JumpAddr),
        .Sel(PC_Sel),
        .Out(PC_next)
    );
    
    assign IF_ID_Flush = PCSrc | Jump_ID;
    // BUFFER IF/ID
    // ========================================================================
    
    IF_ID_Buffer if_id (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .flush(IF_ID_Flush),
        .IF_PC_Plus4(PC_plus4),
        .IF_Instruction(Instruction_IF),
        .ID_PC_Plus4(ID_PC_Plus4),
        .ID_Instruction(ID_Instruction)
    );
   
    // ETAPA ID
    
    assign Opcode    = ID_Instruction[31:26];
    assign Rs        = ID_Instruction[25:21];
    assign Rt        = ID_Instruction[20:16];
    assign Rd        = ID_Instruction[15:11];
    assign Funct     = ID_Instruction[5:0];
    assign Immediate = ID_Instruction[15:0];
    
    ControlUnit control (
        .Opcode(Opcode),
        .RegDst(RegDst_ID),
        .ALUSrc(ALUSrc_ID),
        .MemtoReg(MemtoReg_ID),
        .RegWrite(RegWrite_ID),
        .MemRead(MemRead_ID),
        .MemWrite(MemWrite_ID),
        .Branch(Branch_ID),
        .ALUOp(ALUOp_ID),
        .Jump(Jump_ID)
    );
    
    BancoRegistros regfile (
        .clk(clk),
        .reset(reset),
        .RegWrite(WB_RegWrite),
        .ReadReg1(Rs),
        .ReadReg2(Rt),
        .WriteReg(WB_WriteReg),
        .WriteData(WriteBackData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );
    
    SignExtend sign_ext (
        .Imm16(Immediate),
        .Imm32(SignExtImm)
    );

    // BUFFER ID/EX
    // ========================================================================
    
    ID_EX_Buffer id_ex (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),
        .ID_RegWrite(RegWrite_ID),
        .ID_MemtoReg(MemtoReg_ID),
        .ID_MemRead(MemRead_ID),
        .ID_MemWrite(MemWrite_ID),
        .ID_Branch(Branch_ID),
        .ID_ALUOp(ALUOp_ID),
        .ID_ALUSrc(ALUSrc_ID),
        .ID_RegDst(RegDst_ID),
        .ID_PC_Plus4(ID_PC_Plus4),
        .ID_ReadData1(ReadData1),
        .ID_ReadData2(ReadData2),
        .ID_SignExtImm(SignExtImm),
        .ID_Rs(Rs),
        .ID_Rt(Rt),
        .ID_Rd(Rd),
        .ID_Funct(Funct),
        .ID_Opcode(Opcode),
        .EX_RegWrite(EX_RegWrite),
        .EX_MemtoReg(EX_MemtoReg),
        .EX_MemRead(EX_MemRead),
        .EX_MemWrite(EX_MemWrite),
        .EX_Branch(EX_Branch),
        .EX_ALUOp(EX_ALUOp),
        .EX_ALUSrc(EX_ALUSrc),
        .EX_RegDst(EX_RegDst),
        .EX_PC_Plus4(EX_PC_Plus4),
        .EX_ReadData1(EX_ReadData1),
        .EX_ReadData2(EX_ReadData2),
        .EX_SignExtImm(EX_SignExtImm),
        .EX_Rs(EX_Rs),
        .EX_Rt(EX_Rt),
        .EX_Rd(EX_Rd),
        .EX_Funct(EX_Funct),
        .EX_Opcode(EX_Opcode)
    );
    // ETAPA EX
    // ========================================================================
    
    Mux2to1_5bit regdst_mux (
        .In0(EX_Rt),
        .In1(EX_Rd),
        .Sel(EX_RegDst),
        .Out(WriteReg_EX)
    );
    
    Mux2to1_32bit alusrc_mux (
        .In0(EX_ReadData2),
        .In1(EX_SignExtImm),
        .Sel(EX_ALUSrc),
        .Out(ALU_InputB)
    );
    
    ALUControl alu_ctrl (
        .ALUOp(EX_ALUOp),
        .Funct(EX_Funct),
        .Opcode(EX_Opcode),
        .ALUCtrl(ALUCtrl)
    );
    
    ALU alu_unit (
        .A(EX_ReadData1),
        .B(ALU_InputB),
        .ALUControl(ALUCtrl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );
    
    ShiftLeft2 shift_branch (
        .DataIn(EX_SignExtImm),
        .DataOut(BranchOffset)
    );
    
    Adder branch_adder (
        .A(EX_PC_Plus4),
        .B(BranchOffset),
        .Result(BranchAddr_EX)
    );
    // BUFFER EX/MEM
    // ========================================================================
    
    EX_MEM_Buffer ex_mem (
        .clk(clk),
        .reset(reset),
        .flush(1'b0),
        .EX_RegWrite(EX_RegWrite),
        .EX_MemtoReg(EX_MemtoReg),
        .EX_MemRead(EX_MemRead),
        .EX_MemWrite(EX_MemWrite),
        .EX_Branch(EX_Branch),
        .EX_BranchAddr(BranchAddr_EX),
        .EX_Zero(Zero),
        .EX_ALUResult(ALUResult),
        .EX_ReadData2(EX_ReadData2),
        .EX_WriteReg(WriteReg_EX),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_MemtoReg(MEM_MemtoReg),
        .MEM_MemRead(MEM_MemRead),
        .MEM_MemWrite(MEM_MemWrite),
        .MEM_Branch(MEM_Branch),
        .MEM_BranchAddr(MEM_BranchAddr),
        .MEM_Zero(MEM_Zero),
        .MEM_ALUResult(MEM_ALUResult),
        .MEM_ReadData2(MEM_ReadData2),
        .MEM_WriteReg(MEM_WriteReg)
    );
    // ETAPA MEM
    // ========================================================================
    
    MemoriaDatos dmem (
        .clk(clk),
        .MemRead(MEM_MemRead),
        .MemWrite(MEM_MemWrite),
        .Address(MEM_ALUResult),
        .WriteData(MEM_ReadData2),
        .ReadData(MemReadData)
    );
    // BUFFER MEM/WB
    // ========================================================================
    
    MEM_WB_Buffer mem_wb (
        .clk(clk),
        .reset(reset),
        .MEM_RegWrite(MEM_RegWrite),
        .MEM_MemtoReg(MEM_MemtoReg),
        .MEM_ReadData(MemReadData),
        .MEM_ALUResult(MEM_ALUResult),
        .MEM_WriteReg(MEM_WriteReg),
        .WB_RegWrite(WB_RegWrite),
        .WB_MemtoReg(WB_MemtoReg),
        .WB_ReadData(WB_ReadData),
        .WB_ALUResult(WB_ALUResult),
        .WB_WriteReg(WB_WriteReg)
    );
    // ETAPA WB
    // ========================================================================
    
    Mux2to1_32bit memtoreg_mux (
        .In0(WB_ALUResult),
        .In1(WB_ReadData),
        .Sel(WB_MemtoReg),
        .Out(WriteBackData)
    );

endmodule
