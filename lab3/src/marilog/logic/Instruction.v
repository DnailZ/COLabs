
@py
def def_funct(name, funct_num, alu_m="ADD", comment=""):
    global functs
    print(functs,name)
    funct_num = "6'b" + funct_num
    alu_m = "`ALU_" + alu_m
    if len(comment) > 2:
        comment = comment[2:]
    wr("// funct {name}({funct_num}) {comment}")
    functs[name] = (funct_num, alu_m)
@end

`define ALU_ADD  3'b000
`define ALU_SUB  3'b001
`define ALU_AND  3'b010
`define ALU_OR  3'b011
`define ALU_XOR  3'b100

// Functs:
@def_funct add 100000 ADD
@def_funct addu 100001 ADD
@def_funct sub 100010 SUB
@def_funct subu 100011 SUB
@def_funct and 100100 AND
@def_funct or 100101 OR
@def_funct xor 100110 XOR

// def_funct nor 100111 NOR
// def_funct slt 101010 SUB
// def_funct sltu 101011 SUB
// def_funct sll 000000 SHL
// def_funct srl 000010 SHR
// def_funct sra 000011 SHRA
// def_funct sllv 000100 SHL
// def_funct srlv 000110 SHR
// def_funct srav 000111 SHRA


@struct Signal
@e jump
@e branch
@e mem_read 1/x
@e mem_write

@e reg_write
@e reg_dst 1/x
`define RegDst_Rd 1'b1
`define RegDst_Rt 1'b0
@e mem_toreg 1/x
`define MemToReg_Mem 1'b1
`define MemToReg_ALU 1'b0

@e aluop 3/x
`define ALUOp_CMD_ADD 3'b01
`define ALUOp_CMD_SUB 3'b10
`define ALUOp_CMD_RTYPE 3'b00
@e alu_src2 1/x
`define ALUSrc2_Reg 1'b0
`define ALUSrc2_Imm 1'b1
@endstruct



@defdict rtype_instruction
@dt reg_dst `RegDst_Rd
@dt reg_write 1
@dt mem_toreg `MemToReg_ALU
@dt aluop `ALUOp_CMD_RTYPE
@dt alu_src2 `ALUSrc2_Reg
@enddict

@defdict lw_instruction
@dt mem_read 1

@dt reg_dst `RegDst_Rt
@dt reg_write 1
@dt mem_toreg `MemToReg_Mem
@dt aluop `ALUOp_CMD_ADD
@dt alu_src2 `ALUSrc2_Imm
@enddict

@defdict sw_instruction
@dt mem_read 0
@dt mem_write 1

@dt aluop `ALUOp_CMD_ADD
@dt alu_src2 `ALUSrc2_Imm
@enddict

@defdict addi_instruction
@dt reg_dst `RegDst_Rt
@dt reg_write 1
@dt mem_toreg `MemToReg_ALU
@dt aluop `ALUOp_CMD_ADD
@dt alu_src2 `ALUSrc2_Imm
@enddict

@defdict beq_instruction
@dt jump 0
@dt branch 1

@dt aluop `ALUOp_CMD_SUB
@dt alu_src2 `ALUSrc2_Reg
@enddict

@defdict j_instruction
@dt jump 1
@enddict

@py
def def_instruction(name, opcode, signal, comment=""):
    global instructions
    opcode = "6'b" + opcode
    if len(comment) > 2:
        comment = comment[2:]
    wr("// opcode {name} {comment}")
    instructions[name] = (opcode, signal)
@end
// instrucitons:
@def_instruction rtype 000000 rtype_instruction
@def_instruction addi 001000 addi_instruction
@def_instruction lw 100011 lw_instruction
@def_instruction sw 101011 sw_instruction
@def_instruction beq 000100 beq_instruction
@def_instruction j 000010 j_instruction




