@py
print(functs)
def FunctLogic():
    global functs
    for name in functs:
        funct, alu_m = functs[name]
        wr("{funct}: alu_m = {alu_m}; // {name}")
@end

@module ALU_control
#(
    @defparam
) (
    @Input aluop [2:0],
    @Input funct Funct,
    @outputr alu_m ALUop 
);
    always@(*) begin
        alu_m = 3'bxxx;
        case(aluop)
        `ALUOp_CMD_RTYPE: begin
            case(funct)
                @FunctLogic
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
