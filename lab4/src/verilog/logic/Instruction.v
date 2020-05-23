// ALUSignal's structure
// -  ALUSignal_t (4) : the real ALU operations
`define ALU_ADD  4'd0
`define ALU_SUB  4'd1
`define ALU_AND  4'd2
`define ALU_OR  4'd3
`define ALU_XOR  4'd4
`define ALU_NOR  4'd5
`define ALU_SHL  4'd6
`define ALU_SHRL  4'd7
`define ALU_SHRA  4'd8
`define ALU_LU  4'd9
// -  ALUSignal_t (1) 
`define ALUSrc1_Orig  3'd0
`define ALUSrc1_Shamt 3'd1
// -  ALUSignal_t (2) 
`define ALUOut_Orig  3'd0
`define ALUOut_LT 3'd1
`define ALUOut_LTU 3'd2
// -  ALUSignal_t (1) 



/// code(funct) until codeend
// Functs:
// funct add(6'b100000) 
`define FUNCT_ADD 6'b100000
// funct addu(6'b100001) 
`define FUNCT_ADDU 6'b100001
// funct sub(6'b100010) 
`define FUNCT_SUB 6'b100010
// funct subu(6'b100011) 
`define FUNCT_SUBU 6'b100011
// funct and(6'b100100) 
`define FUNCT_AND 6'b100100
// funct or(6'b100101) 
`define FUNCT_OR 6'b100101
// funct xor(6'b100110) 
`define FUNCT_XOR 6'b100110
// funct nor(6'b100111) 
`define FUNCT_NOR 6'b100111
// funct sllv(6'b000100) 
`define FUNCT_SLLV 6'b000100
// funct srlv(6'b000110) 
`define FUNCT_SRLV 6'b000110
// funct srav(6'b000111) 
`define FUNCT_SRAV 6'b000111
// funct sll(6'b000000) 
`define FUNCT_SLL 6'b000000
// funct srl(6'b000010) 
`define FUNCT_SRL 6'b000010
// funct sra(6'b000011) 
`define FUNCT_SRA 6'b000011
// funct sra(6'b000011) 
`define FUNCT_SRA 6'b000011
// funct slt(6'b101010) 
`define FUNCT_SLT 6'b101010
// funct sltu(6'b101011) 
`define FUNCT_SLTU 6'b101011
// funct jr(6'b001000) 
`define FUNCT_JR 6'b001000

// codeend


// def_funct nor 100111 NOR
// def_funct slt 101010 SUB
// def_funct sltu 101011 SUB
// def_funct sll 000000 SHL
// def_funct srl 000010 SHR
// def_funct sra 000011 SHRA
// def_funct sllv 000100 SHL
// def_funct srlv 000110 SHR
// def_funct srav 000111 SHRA

/// code(sgn) until codeend
// Signal's structure
// -  Signal_t (1) 
// -  Signal_t (1) 
// -  Signal_t (1) 
`define MemAddr_I 1'b1
`define MemAddr_D 1'b0
// -  Signal_t (1) 
// -  Signal_t (2) : DCache出口处的mux
`define MemToReg_Mem 2'd1
`define MemToReg_ALU 2'd0
`define MemToReg_PC 2'd2
// -  Signal_t (1) 
// -  Signal_t (1) 

// -  Signal_t (1) 
// -  Signal_t (2) 
`define RegDst_Rd 2'd1
`define RegDst_Rt 2'd0
`define RegDst_RA 2'd2
// -  Signal_t (3) : 传入ALU_Control
`define ALUOp_CMD_RTYPE 3'd0
`define ALUOp_CMD_ADD 3'd1
`define ALUOp_CMD_SUB 3'd2
`define ALUOp_CMD_AND 3'd3
`define ALUOp_CMD_OR 3'd4
`define ALUOp_CMD_XOR 3'd5
`define ALUOp_CMD_NOR 3'd6
`define ALUOp_CMD_LU 3'd7
// -  Signal_t (2) 
// -  Signal_t (3) 
`define ALUSrc2_Reg 3'd0
`define ALUSrc2_4 3'd1
`define ALUSrc2_SImm 3'd2
`define ALUSrc2_SAddr 3'd3
`define ALUSrc2_UImm 3'd4
// -  Signal_t (1) 
`define ALUSrc1_PC 2'd0
`define ALUSrc1_OprA 2'd1
// -  Signal_t (2) 
`define PCSource_NPC 2'd0
`define PCSource_Beq 2'd1
`define PCSource_Jump 2'd2
// -  Signal_t (1) 
// codeend


/// code(instr) until codeend
// instrucitons:
// opcode rtype 
`define OPCODE_RTYPE 6'b000000

// opcode addi 
`define OPCODE_ADDI 6'b001000

// opcode addiu 
`define OPCODE_ADDIU 6'b001001
// opcode andi 
`define OPCODE_ANDI 6'b001100
// opcode ori 
`define OPCODE_ORI 6'b001101
// opcode xori 
`define OPCODE_XORI 6'b001110
// opcode lui 
`define OPCODE_LUI 6'b001111
// opcode slti 
`define OPCODE_SLTI 6'b001010
// opcode sltiu 
`define OPCODE_SLTIU 6'b001011

// opcode bne 
`define OPCODE_BNE 6'b000101

// opcode lw 
`define OPCODE_LW 6'b100011


// opcode sw 
`define OPCODE_SW 6'b101011

// opcode beq 
`define OPCODE_BEQ 6'b000100

// opcode j 
`define OPCODE_J 6'b000010
// opcode jal 
`define OPCODE_JAL 6'b000011
// codeend 
