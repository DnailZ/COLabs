`timescale 1ns / 1ps

/// code(ctrl) until endmodule
/// ##### 控制单元
module Control
#(
    /// doc_omit begin
    parameter SIGNAL_W = 23,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 4
    /// doc_omit end
) (
    input  clk, 
    input  rst, 
    input  run, 
    input [5:0] opcode, 
    output [SIGNAL_W-1:0] sgn // signals
);
    localparam STATE_W = 5;
    localparam STATE_IDLE = 5'd0;
    localparam STATE_FI = 5'd1;
    localparam STATE_ID = 5'd2;
    localparam STATE_EX = 5'd3;
    localparam STATE_RTYPE_WB = 5'd4;
    localparam STATE_MEM_ADDR = 5'd5;
    localparam STATE_MEM_RD = 5'd6;
    localparam STATE_MEM_WR = 5'd7;
    localparam STATE_MEM_WB = 5'd8;
    localparam STATE_BRANCH = 5'd9;
    localparam STATE_BRANCH_NOT = 5'd10;
    localparam STATE_JUMP = 5'd11;
    localparam STATE_JUMP_AND_LINK = 5'd12;
    localparam STATE_ADDI = 5'd13;
    localparam STATE_ADDIU = 5'd14;
    localparam STATE_ANDI = 5'd15;
    localparam STATE_ORI = 5'd16;
    localparam STATE_XORI = 5'd17;
    localparam STATE_LUI = 5'd18;
    localparam STATE_SLTI = 5'd19;
    localparam STATE_SLTIU = 5'd20;
    localparam STATE_IMM_WB = 5'd21;
    reg [STATE_W-1:0] current, next;
    reg sgn_pc_write;
    reg sgn_pc_write_cond;
    reg sgn_i_or_d;
    reg sgn_mem_read;
    reg [1:0] sgn_mem_toreg;
    reg sgn_mem_write;
    reg sgn_ir_write;
    reg sgn_reg_write;
    reg [1:0] sgn_reg_dst;
    reg [2:0] sgn_aluop;
    reg [1:0] sgn_alu_out_mux;
    reg [2:0] sgn_alu_src2;
    reg sgn_alu_src1;
    reg [1:0] sgn_pc_source;
    reg sgn_pc_write_notcond;
    assign sgn = { sgn_pc_write, sgn_pc_write_cond, sgn_i_or_d, sgn_mem_read, sgn_mem_toreg, sgn_mem_write, sgn_ir_write, sgn_reg_write, sgn_reg_dst, sgn_aluop, sgn_alu_out_mux, sgn_alu_src2, sgn_alu_src1, sgn_pc_source, sgn_pc_write_notcond};

    // 这里使用和之前单周期相同的 [SIGNAL_W-1:0] 数据
    always @(*) begin
        begin                                 //
            sgn_pc_write = 1'b0;              // pc_write (by default)
            sgn_pc_write_cond = 1'b0;         // pc_write_cond (by default)
            sgn_i_or_d = 1'bx;                // i_or_d (by default)
            sgn_mem_read = 1'bx;              // mem_read (by default)
            sgn_mem_toreg = 2'bxx;            // mem_toreg (by default)
            sgn_mem_write = 1'b0;             // mem_write (by default)
            sgn_ir_write = 1'b0;              // ir_write (by default)
            sgn_reg_write = 1'b0;             // reg_write (by default)
            sgn_reg_dst = 2'bxx;              // reg_dst (by default)
            sgn_aluop = 3'bxxx;               // aluop (by default)
            sgn_alu_out_mux = 2'b00;          // alu_out_mux (by default)
            sgn_alu_src2 = 3'bxxx;            // alu_src2 (by default)
            sgn_alu_src1 = 1'bx;              // alu_src1 (by default)
            sgn_pc_source = 2'bxx;            // pc_source (by default)
            sgn_pc_write_notcond = 1'b0;      // pc_write_notcond (by default)
        end                                   //
        case(current)
        // -----------------------------------
        // Basic States
        // -----------------------------------
        STATE_IDLE:
            next = STATE_FI;
        STATE_FI: begin
            sgn_i_or_d = `MemAddr_I;
            sgn_ir_write = 1;
            sgn_mem_read = 1;
            sgn_aluop = `ALUOp_CMD_ADD;
            sgn_alu_src2 = `ALUSrc2_4;
            sgn_alu_src1 = `ALUSrc1_PC;
            sgn_pc_write = 1;
            sgn_pc_source = `PCSource_NPC;
            next = STATE_ID;
        end
        STATE_ID: begin
            sgn_aluop = `ALUOp_CMD_ADD;
            sgn_alu_src2 = `ALUSrc2_SAddr;
            sgn_alu_src1 = `ALUSrc1_PC;
            case(opcode)
            `OPCODE_RTYPE: 
                next = STATE_EX;
            // 这里省略其他的 opcode 定义
            /// doc_omit begin
            `OPCODE_LW: 
                next = STATE_MEM_ADDR;
            `OPCODE_SW: 
                next = STATE_MEM_ADDR;
            `OPCODE_BEQ: 
                next = STATE_BRANCH;
            `OPCODE_BNE: 
                next = STATE_BRANCH_NOT;
            `OPCODE_J: 
                next = STATE_JUMP;
            `OPCODE_JAL: 
                next = STATE_JUMP_AND_LINK;
            `OPCODE_ADDI: 
                next = STATE_ADDI;
            `OPCODE_ANDI: 
                next = STATE_ANDI;
            `OPCODE_ORI: 
                next = STATE_ORI;
            `OPCODE_XORI: 
                next = STATE_XORI;
            `OPCODE_LUI: 
                next = STATE_LUI;
            `OPCODE_ADDIU:
                next = STATE_ADDIU;
            `OPCODE_SLTI: 
                next = STATE_SLTI;
            `OPCODE_SLTIU:
                next = STATE_SLTIU;
            /// doc_omit end
            default:
                next = STATE_IDLE;
            endcase
        end
        // -----------------------------------
        // RTYPE 
        // -----------------------------------
        STATE_EX: begin
            sgn_aluop = `ALUOp_CMD_RTYPE;
            sgn_alu_src2 = `ALUSrc2_Reg;
            sgn_alu_src1 = `ALUSrc1_OprA;
            next = STATE_RTYPE_WB;
        end
        STATE_RTYPE_WB: begin
            sgn_reg_write = 1;
            sgn_reg_dst = `RegDst_Rd;
            sgn_mem_toreg = `MemToReg_ALU;
            next = STATE_FI;
        end
        // -----------------------------------
        // LW and SW
        // -----------------------------------
        STATE_MEM_ADDR: begin
            sgn_aluop = `ALUOp_CMD_ADD;
            sgn_alu_src2 = `ALUSrc2_SImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            if(opcode == `OPCODE_LW) begin
                next = STATE_MEM_RD;
            end else begin
                next = STATE_MEM_WR;
            end
        end
        
        STATE_MEM_RD: begin
            sgn_i_or_d = `MemAddr_D;
            sgn_mem_read = 1;
            next = STATE_MEM_WB;
        end
        STATE_MEM_WR: begin
            sgn_i_or_d = `MemAddr_D;
            sgn_mem_write = 1;
            next = STATE_FI;
        end
        STATE_MEM_WB: begin
            sgn_reg_write = 1;
            sgn_reg_dst = `RegDst_Rt;
            sgn_mem_toreg = `MemToReg_Mem;
            next = STATE_FI;
        end
        // 其他还有 Branch、Jump指令，这里全都省略（完整版参考）
        /// doc_omit begin
        // -----------------------------------
        // Branch and Jump
        // -----------------------------------
        STATE_BRANCH: begin
            sgn_aluop = `ALUOp_CMD_SUB;
            sgn_alu_src2 = `ALUSrc2_Reg;
            sgn_alu_src1 = `ALUSrc1_OprA;
            sgn_pc_write_cond = 1;
            sgn_pc_source = `PCSource_Beq;
            next = STATE_FI;
        end
        STATE_BRANCH_NOT: begin
            sgn_aluop = `ALUOp_CMD_SUB;
            sgn_alu_src2 = `ALUSrc2_Reg;
            sgn_alu_src1 = `ALUSrc1_OprA;
            sgn_pc_write_notcond = 1;
            sgn_pc_source = `PCSource_Beq;
            next = STATE_FI;
        end
        STATE_JUMP: begin
            sgn_pc_write = 1;
            sgn_pc_source = `PCSource_Jump;
            next = STATE_FI;
        end
        STATE_JUMP_AND_LINK: begin
            sgn_pc_write = 1;
            sgn_pc_source = `PCSource_Jump;
            sgn_reg_write = 1;
            sgn_reg_dst = `RegDst_RA;
            sgn_mem_toreg = `MemToReg_PC;
            next = STATE_FI;
        end
        // -----------------------------------
        // Immediate Instrutions
        // -----------------------------------
        STATE_ADDI: begin
            sgn_aluop = `ALUOp_CMD_ADD;
            sgn_alu_src2 = `ALUSrc2_SImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            next = STATE_IMM_WB;
        end
        STATE_ADDIU: begin
            sgn_aluop = `ALUOp_CMD_ADD;
            sgn_alu_src2 = `ALUSrc2_SImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            next = STATE_IMM_WB;
        end
        STATE_ANDI: begin
            sgn_aluop = `ALUOp_CMD_AND;
            sgn_alu_src2 = `ALUSrc2_UImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            next = STATE_IMM_WB;
        end
        STATE_ORI: begin
            sgn_aluop = `ALUOp_CMD_OR;
            sgn_alu_src2 = `ALUSrc2_UImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            next = STATE_IMM_WB;
        end
        STATE_XORI: begin
            sgn_aluop = `ALUOp_CMD_XOR;
            sgn_alu_src2 = `ALUSrc2_UImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            next = STATE_IMM_WB;
        end
        STATE_LUI: begin
            sgn_aluop = `ALUOp_CMD_LU;
            sgn_alu_src2 = `ALUSrc2_UImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            next = STATE_IMM_WB;
        end
        STATE_SLTI: begin
            sgn_aluop = `ALUOp_CMD_SUB;
            sgn_alu_src2 = `ALUSrc2_SImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            sgn_alu_out_mux = `ALUOut_LT;
            next = STATE_IMM_WB;
        end
        STATE_SLTIU: begin
            sgn_aluop = `ALUOp_CMD_SUB;
            sgn_alu_src2 = `ALUSrc2_SImm;
            sgn_alu_src1 = `ALUSrc1_OprA;
            sgn_alu_out_mux = `ALUOut_LTU;
            next = STATE_IMM_WB;
        end
        STATE_IMM_WB: begin
            sgn_reg_write = 1;
            sgn_reg_dst = `RegDst_Rt;
            sgn_mem_toreg = `MemToReg_ALU;
            next = STATE_FI;
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
        case(current)
        STATE_IDLE: state_string = "IDLE";
        STATE_FI: state_string = "FI";
        STATE_ID: state_string = "ID";
        STATE_EX: state_string = "EX";
        STATE_RTYPE_WB: state_string = "RTYPE_WB";
        STATE_MEM_ADDR: state_string = "MEM_ADDR";
        STATE_MEM_RD: state_string = "MEM_RD";
        STATE_MEM_WR: state_string = "MEM_WR";
        STATE_MEM_WB: state_string = "MEM_WB";
        STATE_BRANCH: state_string = "BRANCH";
        STATE_BRANCH_NOT: state_string = "BRANCH_NOT";
        STATE_JUMP: state_string = "JUMP";
        STATE_JUMP_AND_LINK: state_string = "JUMP_AND_LINK";
        STATE_ADDI: state_string = "ADDI";
        STATE_ADDIU: state_string = "ADDIU";
        STATE_ANDI: state_string = "ANDI";
        STATE_ORI: state_string = "ORI";
        STATE_XORI: state_string = "XORI";
        STATE_LUI: state_string = "LUI";
        STATE_SLTI: state_string = "SLTI";
        STATE_SLTIU: state_string = "SLTIU";
        STATE_IMM_WB: state_string = "IMM_WB";
        endcase
    end

    // 调试输出
    always @(posedge clk) begin
        if(~rst & run) begin
            $display("[ctrl] current_state %s (%h)", state_string, opcode);
        end
    end
    `endif
    
endmodule
