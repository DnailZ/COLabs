
@py
def def_funct(name, funct_num, alu_m, comment=""):
    global functs
    funct_num = "6'b" + funct_num
    if len(comment) > 2:
        comment = comment[2:]
    wr("// funct {name}({funct_num}) {comment}")
    uname = name.upper()
    wr("`define FUNCT_{uname} {funct_num}")
    
    name = inter("{name}_funct")
    defdict(name)
    dt("alu_m", inter("`ALU_{alu_m}"))
    functs[name] = (inter("`FUNCT_{uname}"), inter("cur_dict[\'{name}_t\']"))
@end

/// code(funct) until codeend
// Functs:
@def_funct add 100000 ADD
@enddict
@def_funct addu 100001 ADD
@enddict
@def_funct sub 100010 SUB
@enddict
@def_funct subu 100011 SUB
@enddict
@def_funct and 100100 AND
@enddict
@def_funct or 100101 OR
@enddict
@def_funct xor 100110 XOR
@enddict
@def_funct accm 101000 ADD
@dt alu_src1 `ALUSrc1_Mem
@dt mem_addr_mux `MemAddrMux_Rs
@enddict
// codeend

@struct ALUSignal
@e alu_m 3/x // the real ALU operations
`define ALU_ADD  3'd0
`define ALU_SUB  3'd1
`define ALU_AND  3'd2
`define ALU_OR  3'd3
`define ALU_XOR  3'd4
@e alu_src1 2
`define ALUSrc1_Rs  3'd0
`define ALUSrc1_Shamt 3'd1
`define ALUSrc1_Mem 3'd2
@e mem_addr_mux 1 // just for accm funct
`define MemAddrMux_ALU 3'd0
`define MemAddrMux_Rs 3'd1
@endstruct


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
@struct Signal
@e jump // 跳转指令专用（j，jal）
@e branch // branch 指令专用
@e reg_write
@e reg_dst 1/x
`define RegDst_Rd 1'b1
`define RegDst_Rt 1'b0
@e mem_read 1/x
@e mem_toreg 1/x // DCache出口处的mux
`define MemToReg_Mem 1'b1
`define MemToReg_ALU 1'b0
@e mem_write
@e aluop 3/x // 传入ALU_Control
`define ALUOp_CMD_RTYPE 3'd0
`define ALUOp_CMD_ADD 3'd1
`define ALUOp_CMD_SUB 3'd2
`define ALUOp_CMD_AND 3'd3
`define ALUOp_CMD_OR 3'd4
`define ALUOp_CMD_XOR 3'd5
`define ALUOp_CMD_NOR 3'd6
`define ALUOp_CMD_LU 3'd7
@e alu_src2 2/x 
`define ALUSrc2_Reg 2'd0
`define ALUSrc2_SImm 2'd1
`define ALUSrc2_UImm 2'd2
@e branch_neq
@endstruct
// codeend

@py
def def_instruction(name, opcode, comment=""):
    global instructions
    opcode = "6'b" + opcode
    if len(comment) > 2:
        comment = comment[2:]
    wr("// opcode {name} {comment}")
    uname = name.upper()
    wr("`define OPCODE_{uname} = {opcode}")
    name = inter("{name}_instruction")
    defdict(name)
    instructions[name] = (inter("`OPCODE_{uname}"), inter("cur_dict[\'{name}_t\']"))
@end

/// code(instr) until codeend
// instrucitons:
@def_instruction rtype 000000
@dt reg_dst `RegDst_Rd
@dt reg_write 1
@dt mem_toreg `MemToReg_ALU
@dt aluop `ALUOp_CMD_RTYPE
@dt alu_src2 `ALUSrc2_Reg
@enddict

@def_instruction addi 001000
@dt reg_dst `RegDst_Rt
@dt reg_write 1
@dt mem_toreg `MemToReg_ALU
@dt aluop `ALUOp_CMD_ADD
@dt alu_src2 `ALUSrc2_SImm
@enddict

@def_instruction lw 100011
@dt mem_read 1

@dt reg_dst `RegDst_Rt
@dt reg_write 1
@dt mem_toreg `MemToReg_Mem
@dt aluop `ALUOp_CMD_ADD
@dt alu_src2 `ALUSrc2_SImm
@enddict

@def_instruction sw 101011
@dt mem_read 0
@dt mem_write 1
@_
@dt aluop `ALUOp_CMD_ADD
@dt alu_src2 `ALUSrc2_SImm
@enddict

@def_instruction beq 000100
@dt jump 0
@dt branch 1
@_
@dt aluop `ALUOp_CMD_SUB
@dt alu_src2 `ALUSrc2_Reg
@enddict

@def_instruction j 000010
@dt jump 1
@enddict
// codeend 
