`timescale 1ns / 1ps

/// code(ctrl) until endmodule
/// ##### 控制单元
@module Control
#(
    /// doc_omit begin
    @defparam
    /// doc_omit end
) (
    @ninput clk,
    @ninput rst,
    @ninput run,
    @Input opcode [5:0],
    @Output sgn Signal // signals
);
    @venum State
    @tag IDLE
    @tag FI
    @tag ID
    @tag EX
    @tag RTYPE_WB
    @tag MEM_ADDR
    @tag MEM_RD
    @tag MEM_WR
    @tag MEM_WB
    @tag BRANCH
    @tag BRANCH_NOT
    @tag JUMP
    @tag JUMP_AND_LINK
    @tag ADDI
    @tag ADDIU
    @tag ANDI
    @tag ORI
    @tag XORI
    @tag LUI
    @tag SLTI
    @tag SLTIU
    @tag IMM_WB
    @endenum 
    reg State current, next;
@py
def goto(state):
    wr("next = STATE_{state};")

def write_alu_m_to_pc():
    wr("sgn_pc_write = 1;")
    wr("sgn_pc_source = `PCSource_NPC;")
def branch_pc():
    wr("sgn_pc_write_cond = 1;")
    wr("sgn_pc_source = `PCSource_Beq;")
def branch_pc_if_not():
    wr("sgn_pc_write_notcond = 1;")
    wr("sgn_pc_source = `PCSource_Beq;")
def jump_pc():
    wr("sgn_pc_write = 1;")
    wr("sgn_pc_source = `PCSource_Jump;")

def mem_fetch():
    wr("sgn_i_or_d = `MemAddr_I;")
    wr("sgn_ir_write = 1;")
    wr("sgn_mem_read = 1;")
def mem_read():
    wr("sgn_i_or_d = `MemAddr_D;")
    wr("sgn_mem_read = 1;")
def mem_write():
    wr("sgn_i_or_d = `MemAddr_D;")
    wr("sgn_mem_write = 1;")
def read_regfile():
    pass
def alu_for_npc():
    wr("sgn_aluop = `ALUOp_CMD_ADD;")
    wr("sgn_alu_src2 = `ALUSrc2_4;")
    wr("sgn_alu_src1 = `ALUSrc1_PC;")
def alu_for_rtype():
    wr("sgn_aluop = `ALUOp_CMD_RTYPE;")
    wr("sgn_alu_src2 = `ALUSrc2_Reg;")
    wr("sgn_alu_src1 = `ALUSrc1_OprA;")
def alu_for_cmp():
    wr("sgn_aluop = `ALUOp_CMD_SUB;")
    wr("sgn_alu_src2 = `ALUSrc2_Reg;")
    wr("sgn_alu_src1 = `ALUSrc1_OprA;")
def alu_for_simm(op):
    wr("sgn_aluop = `ALUOp_CMD_{op};")
    wr("sgn_alu_src2 = `ALUSrc2_SImm;")
    wr("sgn_alu_src1 = `ALUSrc1_OprA;")
def alu_for_uimm(op):
    wr("sgn_aluop = `ALUOp_CMD_{op};")
    wr("sgn_alu_src2 = `ALUSrc2_UImm;")
    wr("sgn_alu_src1 = `ALUSrc1_OprA;")
def alu_for_iaddr(base):
    wr("sgn_aluop = `ALUOp_CMD_ADD;")
    wr("sgn_alu_src2 = `ALUSrc2_SAddr;")
    wr("sgn_alu_src1 = `ALUSrc1_{base};")

def write_reg(pos, data):
    wr("sgn_reg_write = 1;");
    wr("sgn_reg_dst = `RegDst_{pos};") # Rt/Rd
    wr("sgn_mem_toreg = `MemToReg_{data};") # Mem/Addr
@end
    @construct Signal_t sgn reg
    @compose_assign Signal_t sgn

    // 这里使用和之前单周期相同的 Signal 数据
    always @(*) begin
        @vlet Signal_t sgn dict()
        case(current)
        // -----------------------------------
        // Basic States
        // -----------------------------------
        STATE_IDLE:
            @goto FI
        STATE_FI: begin
            @mem_fetch
            @alu_for_npc
            @write_alu_m_to_pc
            @goto ID
        end
        STATE_ID: begin
            @alu_for_iaddr PC
            case(opcode)
            `OPCODE_RTYPE: 
                @goto EX
            // 这里省略其他的 opcode 定义
            /// doc_omit begin
            `OPCODE_LW: 
                @goto MEM_ADDR
            `OPCODE_SW: 
                @goto MEM_ADDR
            `OPCODE_BEQ: 
                @goto BRANCH
            `OPCODE_BNE: 
                @goto BRANCH_NOT
            `OPCODE_J: 
                @goto JUMP
            `OPCODE_JAL: 
                @goto JUMP_AND_LINK
            `OPCODE_ADDI: 
                @goto ADDI
            `OPCODE_ANDI: 
                @goto ANDI
            `OPCODE_ORI: 
                @goto ORI
            `OPCODE_XORI: 
                @goto XORI
            `OPCODE_LUI: 
                @goto LUI
            `OPCODE_ADDIU:
                @goto ADDIU
            `OPCODE_SLTI: 
                @goto SLTI
            `OPCODE_SLTIU:
                @goto SLTIU
            /// doc_omit end
            default:
                @goto IDLE
            endcase
        end
        // -----------------------------------
        // RTYPE 
        // -----------------------------------
        STATE_EX: begin
            @alu_for_rtype
            @goto RTYPE_WB
        end
        STATE_RTYPE_WB: begin
            @write_reg Rd ALU
            @goto FI
        end
        // -----------------------------------
        // LW and SW
        // -----------------------------------
        STATE_MEM_ADDR: begin
            @alu_for_simm ADD
            if(opcode == `OPCODE_LW) begin
                @goto MEM_RD
            end else begin
                @goto MEM_WR
            end
        end
        
        STATE_MEM_RD: begin
            @mem_read
            @goto MEM_WB
        end
        STATE_MEM_WR: begin
            @mem_write
            @goto FI
        end
        STATE_MEM_WB: begin
            @write_reg Rt Mem
            @goto FI
        end
        // 其他还有 Branch、Jump指令，这里全都省略（完整版参考）
        /// doc_omit begin
        // -----------------------------------
        // Branch and Jump
        // -----------------------------------
        STATE_BRANCH: begin
            @alu_for_cmp
            @branch_pc
            @goto FI
        end
        STATE_BRANCH_NOT: begin
            @alu_for_cmp
            @branch_pc_if_not
            @goto FI
        end
        STATE_JUMP: begin
            @jump_pc
            @goto FI
        end
        STATE_JUMP_AND_LINK: begin
            @jump_pc
            @write_reg RA PC
            @goto FI
        end
        // -----------------------------------
        // Immediate Instrutions
        // -----------------------------------
        STATE_ADDI: begin
            @alu_for_simm ADD
            @goto IMM_WB
        end
        STATE_ADDIU: begin
            @alu_for_simm ADD
            @goto IMM_WB
        end
        STATE_ANDI: begin
            @alu_for_uimm AND
            @goto IMM_WB
        end
        STATE_ORI: begin
            @alu_for_uimm OR
            @goto IMM_WB
        end
        STATE_XORI: begin
            @alu_for_uimm XOR
            @goto IMM_WB
        end
        STATE_LUI: begin
            @alu_for_uimm LU
            @goto IMM_WB
        end
        STATE_SLTI: begin
            @alu_for_simm SUB
            sgn_alu_out_mux = `ALUOut_LT;
            @goto IMM_WB
        end
        STATE_SLTIU: begin
            @alu_for_simm SUB
            sgn_alu_out_mux = `ALUOut_LTU;
            @goto IMM_WB
        end
        STATE_IMM_WB: begin
            @write_reg Rt ALU
            @goto FI
        end
        /// doc_omit end
        default:;
        endcase
    end

    always @(posedge clk or negedge rst) begin
        if(rst) begin
            current = STATE_IDLE;
        end else if(run) begin
            current = next;
        end
    end

    `ifndef SYSTHESIS

    reg [10*8:0] state_string;
    always @(*) begin
        @enum_getname State_t current state_string
    end

    // 调试输出
    always @(posedge clk) begin
        if(~rst & run) begin
            $display("[ctrl] current_state %s (%h)", state_string, opcode);
        end
    end
    `endif
    
endmodule
