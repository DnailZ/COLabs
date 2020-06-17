`timescale 1ns / 1ps

/// code(ctrl) until endmodule
/// ##### 控制单元
module Control
#(
    /// doc_omit begin
    parameter SIGNAL_W = 14,
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
    output reg [SIGNAL_W-1:0] sig // signals
);

    always @(*) begin
        sig = 0;
        case(opcode)
        `OPCODE_RTYPE:
             sig = {                   
                1'b0,                  // jump (by default)
                1'h1,                  // detect_lduse_rs
                1'h1,                  // detect_lduse_rt
                `ALUOp_CMD_RTYPE,      // aluop
                `ALUSrc2_Reg,          // alu_src2
                `RegDst_Rd,            // reg_dst
                1'b0,                  // branch (by default)
                1'bx,                  // mem_read (by default)
                1'b0,                  // mem_write (by default)
                1'h1,                  // reg_write
                `MemToReg_ALU          // mem_toreg
            };                         
        `OPCODE_ADDI:
             sig = {                 
                1'b0,                // jump (by default)
                1'h1,                // detect_lduse_rs
                1'b0,                // detect_lduse_rt (by default)
                `ALUOp_CMD_ADD,      // aluop
                `ALUSrc2_SImm,       // alu_src2
                `RegDst_Rt,          // reg_dst
                1'b0,                // branch (by default)
                1'bx,                // mem_read (by default)
                1'b0,                // mem_write (by default)
                1'h1,                // reg_write
                `MemToReg_ALU        // mem_toreg
            };                       
            /// doc_omit begin
        `OPCODE_LW:
             sig = {                 
                1'b0,                // jump (by default)
                1'h1,                // detect_lduse_rs
                1'b0,                // detect_lduse_rt (by default)
                `ALUOp_CMD_ADD,      // aluop
                `ALUSrc2_SImm,       // alu_src2
                `RegDst_Rt,          // reg_dst
                1'b0,                // branch (by default)
                1'h1,                // mem_read
                1'b0,                // mem_write (by default)
                1'h1,                // reg_write
                `MemToReg_Mem        // mem_toreg
            };                       
        `OPCODE_SW:
             sig = {                 
                1'b0,                // jump (by default)
                1'h1,                // detect_lduse_rs
                1'h1,                // detect_lduse_rt
                `ALUOp_CMD_ADD,      // aluop
                `ALUSrc2_SImm,       // alu_src2
                1'bx,                // reg_dst (by default)
                1'b0,                // branch (by default)
                1'h0,                // mem_read
                1'h1,                // mem_write
                1'b0,                // reg_write (by default)
                1'bx                 // mem_toreg (by default)
            };                       
        `OPCODE_BEQ:
             sig = {                 
                1'h0,                // jump
                1'h1,                // detect_lduse_rs
                1'h1,                // detect_lduse_rt
                `ALUOp_CMD_SUB,      // aluop
                `ALUSrc2_Reg,        // alu_src2
                1'bx,                // reg_dst (by default)
                1'h1,                // branch
                1'bx,                // mem_read (by default)
                1'b0,                // mem_write (by default)
                1'b0,                // reg_write (by default)
                1'bx                 // mem_toreg (by default)
            };                       
        `OPCODE_J:
             sig = {         
                1'h1,        // jump
                1'b0,        // detect_lduse_rs (by default)
                1'b0,        // detect_lduse_rt (by default)
                3'bxxx,      // aluop (by default)
                2'bxx,       // alu_src2 (by default)
                1'bx,        // reg_dst (by default)
                1'b0,        // branch (by default)
                1'bx,        // mem_read (by default)
                1'b0,        // mem_write (by default)
                1'b0,        // reg_write (by default)
                1'bx         // mem_toreg (by default)
            };               
        /// doc_omit end
        default:
             sig = {         
                1'b0,        // jump (by default)
                1'b0,        // detect_lduse_rs (by default)
                1'b0,        // detect_lduse_rt (by default)
                3'bxxx,      // aluop (by default)
                2'bxx,       // alu_src2 (by default)
                1'bx,        // reg_dst (by default)
                1'b0,        // branch (by default)
                1'bx,        // mem_read (by default)
                1'b0,        // mem_write (by default)
                1'b0,        // reg_write (by default)
                1'bx         // mem_toreg (by default)
            };               
        endcase
    end

    `ifndef SYSTHESIS
    reg [40:0] instruction_name;
    always @(*) begin
        case(opcode)
            `OPCODE_RTYPE: instruction_name = "rtype";
            `OPCODE_ADDI: instruction_name = "addi";
            `OPCODE_LW: instruction_name = "lw";
            `OPCODE_SW: instruction_name = "sw";
            `OPCODE_BEQ: instruction_name = "beq";
            `OPCODE_J: instruction_name = "j";
        endcase
    end
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
