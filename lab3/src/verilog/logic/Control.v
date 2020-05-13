`timescale 1ns / 1ps

module Control
#(
    parameter SIGNAL_W = 11,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 3
) (
    input  clk, 
    input  rst, 
    input [5:0] opcode, 
    output reg [SIGNAL_W-1:0] sgn // signals
);
    always @(*) begin
        sgn = 0;
        case(opcode)
    6'b000000:
         sgn = {                   //
            1'b0,                  // jump (by default)
            1'b0,                  // branch (by default)
            1'bx,                  // mem_read (by default)
            1'b0,                  // mem_write (by default)
            1'h1,                  // reg_write
            `RegDst_Rd,            // reg_dst
            `MemToReg_ALU,         // mem_toreg
            `ALUOp_CMD_RTYPE,      // aluop
            `ALUSrc2_Reg           // alu_src2
        };                         //
    6'b001000:
         sgn = {                 //
            1'b0,                // jump (by default)
            1'b0,                // branch (by default)
            1'bx,                // mem_read (by default)
            1'b0,                // mem_write (by default)
            1'h1,                // reg_write
            `RegDst_Rt,          // reg_dst
            `MemToReg_ALU,       // mem_toreg
            `ALUOp_CMD_ADD,      // aluop
            `ALUSrc2_Imm         // alu_src2
        };                       //
    6'b100011:
         sgn = {                 //
            1'b0,                // jump (by default)
            1'b0,                // branch (by default)
            1'h1,                // mem_read
            1'b0,                // mem_write (by default)
            1'h1,                // reg_write
            `RegDst_Rt,          // reg_dst
            `MemToReg_Mem,       // mem_toreg
            `ALUOp_CMD_ADD,      // aluop
            `ALUSrc2_Imm         // alu_src2
        };                       //
    6'b101011:
         sgn = {                 //
            1'b0,                // jump (by default)
            1'b0,                // branch (by default)
            1'h0,                // mem_read
            1'h1,                // mem_write
            1'b0,                // reg_write (by default)
            1'bx,                // reg_dst (by default)
            1'bx,                // mem_toreg (by default)
            `ALUOp_CMD_ADD,      // aluop
            `ALUSrc2_Imm         // alu_src2
        };                       //
    6'b000100:
         sgn = {                 //
            1'h0,                // jump
            1'h1,                // branch
            1'bx,                // mem_read (by default)
            1'b0,                // mem_write (by default)
            1'b0,                // reg_write (by default)
            1'bx,                // reg_dst (by default)
            1'bx,                // mem_toreg (by default)
            `ALUOp_CMD_SUB,      // aluop
            `ALUSrc2_Reg         // alu_src2
        };                       //
    6'b000010:
         sgn = {         //
            1'h1,        // jump
            1'b0,        // branch (by default)
            1'bx,        // mem_read (by default)
            1'b0,        // mem_write (by default)
            1'b0,        // reg_write (by default)
            1'bx,        // reg_dst (by default)
            1'bx,        // mem_toreg (by default)
            3'bxxx,      // aluop (by default)
            1'bx         // alu_src2 (by default)
        };               //
        default:;
        endcase
    end

    `ifndef SYSTHESIS
    always @(posedge clk) begin
        if(~rst)
            case(opcode)
            6'b000000: $display("[ctrl] opcode : rtype");
            6'b001000: $display("[ctrl] opcode : addi");
            6'b100011: $display("[ctrl] opcode : lw");
            6'b101011: $display("[ctrl] opcode : sw");
            6'b000100: $display("[ctrl] opcode : beq");
            6'b000010: $display("[ctrl] opcode : j");
            default:;
            endcase
    end
    `endif
    
endmodule
