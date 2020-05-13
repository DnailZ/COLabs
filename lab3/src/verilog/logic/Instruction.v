

`define ALU_ADD  3'b000
`define ALU_SUB  3'b001
`define ALU_AND  3'b010
`define ALU_OR  3'b011
`define ALU_XOR  3'b100

// Functs:
// funct add(6'b100000) 
// funct addu(6'b100001) 
// funct sub(6'b100010) 
// funct subu(6'b100011) 
// funct and(6'b100100) 
// funct or(6'b100101) 
// funct xor(6'b100110) 

// def_funct nor 100111 NOR
// def_funct slt 101010 SUB
// def_funct sltu 101011 SUB
// def_funct sll 000000 SHL
// def_funct srl 000010 SHR
// def_funct sra 000011 SHRA
// def_funct sllv 000100 SHL
// def_funct srlv 000110 SHR
// def_funct srav 000111 SHRA


// Signal's structure
// -  jump (1) 
// -  branch (1) 
// -  mem_read (1) 
// -  mem_write (1) 

// -  reg_write (1) 
// -  reg_dst (1) 
`define RegDst_Rd 1'b1
`define RegDst_Rt 1'b0
// -  mem_toreg (1) 
`define MemToReg_Mem 1'b1
`define MemToReg_ALU 1'b0

// -  aluop (3) 
`define ALUOp_CMD_ADD 3'b01
`define ALUOp_CMD_SUB 3'b10
`define ALUOp_CMD_RTYPE 3'b00
// -  alu_src2 (1) 
`define ALUSrc2_Reg 1'b0
`define ALUSrc2_Imm 1'b1












// instrucitons:
// opcode rtype 
// opcode addi 
// opcode lw 
// opcode sw 
// opcode beq 
// opcode j 




