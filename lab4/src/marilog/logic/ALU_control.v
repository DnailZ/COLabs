@py
print(functs)
def FunctLogic():
    global functs
    for name in functs:
        funct, signal, = functs[name]
        vlet("ALUSignal_t", "", signal, prefix=funct+": ")
@end

@module ALU_control
#(
    @defparam
) (
    @Input aluop [2:0],
    @Input funct Funct,
    @ninput sgn_alu_out_mux [1:0],
    @outputr alu_m ALUop,
    @outputr alu_src1,
    @outputr alu_out_mux [1:0],
    @outputr is_jr_funct
);
    always@(*) begin
        alu_m = 3'bxxx;
        alu_src1 = `ALUSrc1_Orig;
        alu_out_mux = sgn_alu_out_mux;
        is_jr_funct = 0;
        case(aluop)
        `ALUOp_CMD_RTYPE: begin
            case(funct)
                @FunctLogic
                default:;
            endcase
        end
        `ALUOp_CMD_ADD: alu_m = `ALU_ADD;
        `ALUOp_CMD_SUB: alu_m = `ALU_SUB;
        `ALUOp_CMD_AND: alu_m = `ALU_AND;
        `ALUOp_CMD_OR: alu_m = `ALU_OR;
        `ALUOp_CMD_XOR: alu_m = `ALU_XOR;
        `ALUOp_CMD_LU: alu_m = `ALU_LU;
        default;
        endcase
    end
    
endmodule
