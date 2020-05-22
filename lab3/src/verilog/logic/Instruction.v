

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
// funct accm(6'b101000) 
`define FUNCT_ACCM 6'b101000
// codeend

// ALUSignal's structure
// -  alu_m (3) : the real ALU operations
`define ALU_ADD  3'd0
`define ALU_SUB  3'd1
`define ALU_AND  3'd2
`define ALU_OR  3'd3
`define ALU_XOR  3'd4
// -  alu_src1 (2) 
`define ALUSrc1_Rs  3'd0
`define ALUSrc1_Shamt 3'd1
`define ALUSrc1_Mem 3'd2
// -  mem_addr_mux (1) : just for accm funct
`define MemAddrMux_ALU 3'd0
`define MemAddrMux_Rs 3'd1


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
// -  jump (1) : 跳转指令专用（j，jal）
// -  branch (1) : branch 指令专用
// -  reg_write (1) 
// -  reg_dst (1) 
`define RegDst_Rd 1'b1
`define RegDst_Rt 1'b0
// -  mem_read (1) 
// -  mem_toreg (1) : DCache出口处的mux
`define MemToReg_Mem 1'b1
`define MemToReg_ALU 1'b0
// -  mem_write (1) 
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
// -  branch_neq (1) 
// codeend


/// code(instr) until codeend
// instrucitons:
// opcode rtype 
`define OPCODE_RTYPE = 6'b000000

// opcode addi 
`define OPCODE_ADDI = 6'b001000

// opcode lw 
`define OPCODE_LW = 6'b100011


// opcode sw 
`define OPCODE_SW = 6'b101011

// opcode beq 
`define OPCODE_BEQ = 6'b000100

// opcode j 
`define OPCODE_J = 6'b000010
// codeend 
