
module ALU_control
#(
    parameter SIGNAL_W = 11,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 3
) (
    input [2:0] aluop, 
    input [FUNCT_W-1:0] funct, 
    output reg [ALUOP_W-1:0] alu_m 
);
    always@(*) begin
        alu_m = 3'bxxx;
        case(aluop)
        `ALUOp_CMD_RTYPE: begin
            case(funct)
                6'b100000: alu_m = `ALU_ADD; // add
                6'b100001: alu_m = `ALU_ADD; // addu
                6'b100010: alu_m = `ALU_SUB; // sub
                6'b100011: alu_m = `ALU_SUB; // subu
                6'b100100: alu_m = `ALU_AND; // and
                6'b100101: alu_m = `ALU_OR; // or
                6'b100110: alu_m = `ALU_XOR; // xor
                default:
                    alu_m = 3'bxxx;
            endcase
        end
        `ALUOp_CMD_ADD: alu_m = `ALU_ADD;
        `ALUOp_CMD_SUB: alu_m = `ALU_SUB;
        default;
        endcase
    end
    
endmodule
