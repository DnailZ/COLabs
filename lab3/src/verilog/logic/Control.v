`timescale 1ns / 1ps

/// code(ctrl) until endmodule
/// ##### 控制单元
module Control
#(
    /// doc_omit begin
    parameter SIGNAL_W = 13,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 3
    /// doc_omit end
) (
    input  clk, 
    input  rst, 
    input  run, 
    input [5:0] opcode, 
    output reg [SIGNAL_W-1:0] sgn // signals
);

    always @(*) begin
        sgn = 0;
        case(opcode)
    `OPCODE_RTYPE:
         sgn = {                   //
            1'b0,                  // jump (by default)
            1'b0,                  // branch (by default)
            1'h1,                  // reg_write
            `RegDst_Rd,            // reg_dst
            1'bx,                  // mem_read (by default)
            `MemToReg_ALU,         // mem_toreg
            1'b0,                  // mem_write (by default)
            `ALUOp_CMD_RTYPE,      // aluop
            `ALUSrc2_Reg,          // alu_src2
            1'b0                   // branch_neq (by default)
        };                         //
    `OPCODE_ADDI:
         sgn = {                 //
            1'b0,                // jump (by default)
            1'b0,                // branch (by default)
            1'h1,                // reg_write
            `RegDst_Rt,          // reg_dst
            1'bx,                // mem_read (by default)
            `MemToReg_ALU,       // mem_toreg
            1'b0,                // mem_write (by default)
            `ALUOp_CMD_ADD,      // aluop
            `ALUSrc2_SImm,       // alu_src2
            1'b0                 // branch_neq (by default)
        };                       //
        /// doc_omit begin
    `OPCODE_LW:
         sgn = {                 //
            1'b0,                // jump (by default)
            1'b0,                // branch (by default)
            1'h1,                // reg_write
            `RegDst_Rt,          // reg_dst
            1'h1,                // mem_read
            `MemToReg_Mem,       // mem_toreg
            1'b0,                // mem_write (by default)
            `ALUOp_CMD_ADD,      // aluop
            `ALUSrc2_SImm,       // alu_src2
            1'b0                 // branch_neq (by default)
        };                       //
    `OPCODE_SW:
         sgn = {                 //
            1'b0,                // jump (by default)
            1'b0,                // branch (by default)
            1'b0,                // reg_write (by default)
            1'bx,                // reg_dst (by default)
            1'h0,                // mem_read
            1'bx,                // mem_toreg (by default)
            1'h1,                // mem_write
            `ALUOp_CMD_ADD,      // aluop
            `ALUSrc2_SImm,       // alu_src2
            1'b0                 // branch_neq (by default)
        };                       //
    `OPCODE_BEQ:
         sgn = {                 //
            1'h0,                // jump
            1'h1,                // branch
            1'b0,                // reg_write (by default)
            1'bx,                // reg_dst (by default)
            1'bx,                // mem_read (by default)
            1'bx,                // mem_toreg (by default)
            1'b0,                // mem_write (by default)
            `ALUOp_CMD_SUB,      // aluop
            `ALUSrc2_Reg,        // alu_src2
            1'b0                 // branch_neq (by default)
        };                       //
    `OPCODE_J:
         sgn = {         //
            1'h1,        // jump
            1'b0,        // branch (by default)
            1'b0,        // reg_write (by default)
            1'bx,        // reg_dst (by default)
            1'bx,        // mem_read (by default)
            1'bx,        // mem_toreg (by default)
            1'b0,        // mem_write (by default)
            3'bxxx,      // aluop (by default)
            2'bxx,       // alu_src2 (by default)
            1'b0         // branch_neq (by default)
        };               //
    /// doc_omit end
    default:
         sgn = {         //
            1'b0,        // jump (by default)
            1'b0,        // branch (by default)
            1'b0,        // reg_write (by default)
            1'bx,        // reg_dst (by default)
            1'bx,        // mem_read (by default)
            1'bx,        // mem_toreg (by default)
            1'b0,        // mem_write (by default)
            3'bxxx,      // aluop (by default)
            2'bxx,       // alu_src2 (by default)
            1'b0         // branch_neq (by default)
        };               //
        endcase
    end

    `ifndef SYSTHESIS
    // 调试输出
    always @(posedge clk) begin
        if(~rst & run) begin
            case(opcode)
            `OPCODE_RTYPE: $display("[ctrl] opcode : rtype_instruction");
            `OPCODE_ADDI: $display("[ctrl] opcode : addi_instruction");
            `OPCODE_LW: $display("[ctrl] opcode : lw_instruction");
            `OPCODE_SW: $display("[ctrl] opcode : sw_instruction");
            `OPCODE_BEQ: $display("[ctrl] opcode : beq_instruction");
            `OPCODE_J: $display("[ctrl] opcode : j_instruction");
            default:;
            endcase
        end
    end
    `endif
    
endmodule
