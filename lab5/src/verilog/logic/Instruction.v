
`define REGFILE_PATH "Y://Course/COLabs/lab3/test/RegFile_init(1).vec"

// ALUSignal's structure
// -  alu_m (3) : the real ALU operations
`define ALU_ADD  3'd0
`define ALU_SUB  3'd1
`define ALU_AND  3'd2
`define ALU_OR  3'd3
`define ALU_XOR  3'd4


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
// codeend

/// code(sig) until codeend
// IdSig's structure
// -  jump (1) : 跳转指令专用（j，jal）
// -  detect_lduse_rs (1) 
// -  detect_lduse_rt (1) 

// ExSig's structure
// -  aluop (3) : 传入ALU_Control
`define ALUOp_CMD_RTYPE 3'd0
`define ALUOp_CMD_ADD 3'd1
`define ALUOp_CMD_SUB 3'd2
`define ALUOp_CMD_AND 3'd3
`define ALUOp_CMD_OR 3'd4
`define ALUOp_CMD_XOR 3'd5
`define ALUOp_CMD_NOR 3'd6
`define ALUOp_CMD_LU 3'd7
// -  alu_src2 (2) 
`define ALUSrc2_Reg 2'd0
`define ALUSrc2_SImm 2'd1
`define ALUSrc2_UImm 2'd2
// -  reg_dst (1) 
`define RegDst_Rd 1'b1
`define RegDst_Rt 1'b0
// -  branch (1) : branch 指令专用

// MemSig's structure
// -  mem_read (1) 
// -  mem_write (1) 

// WbSig's structure
// -  reg_write (1) 
// -  mem_toreg (1) : DCache出口处的mux
`define MemToReg_Mem 1'b1
`define MemToReg_ALU 1'b0

// Signal's structure
// -  jump (1) : 跳转指令专用（j，jal）
// -  detect_lduse_rs (1) 
// -  detect_lduse_rt (1) 
// -  aluop (3) : 传入ALU_Control
// -  alu_src2 (2) 
// -  reg_dst (1) 
// -  branch (1) : branch 指令专用
// -  mem_read (1) 
// -  mem_write (1) 
// -  reg_write (1) 
// -  mem_toreg (1) : DCache出口处的mux
// codeend


/// code(instr) until codeend
// instrucitons:
// opcode rtype 
`define OPCODE_RTYPE 6'b000000

// opcode addi 
`define OPCODE_ADDI 6'b001000

// opcode lw 
`define OPCODE_LW 6'b100011



// opcode sw 
`define OPCODE_SW 6'b101011


// opcode beq 
`define OPCODE_BEQ 6'b000100

// opcode j 
`define OPCODE_J 6'b000010


// codeend
