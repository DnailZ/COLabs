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
    @outputr alu_m ALUop
);
    always@(*) begin
        alu_m = 3'bxxx;
        // alu_src1 = `ALUSrc1_Rs;
        // mem_addr_mux = `MemAddrMux_ALU;
        case(aluop)
        `ALUOp_CMD_RTYPE: begin
            case(funct)
                @FunctLogic
                default:;
            endcase
        end
        `ALUOp_CMD_ADD: alu_m = `ALU_ADD;
        `ALUOp_CMD_SUB: alu_m = `ALU_SUB;
        default;
        endcase
    end
    
endmodule
