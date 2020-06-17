
module ALU_control
#(
    parameter SIGNAL_W = 14,
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
        // alu_src1 = `ALUSrc1_Rs;
        // mem_addr_mux = `MemAddrMux_ALU;
        case(aluop)
        `ALUOp_CMD_RTYPE: begin
            case(funct)
                `FUNCT_ADD: begin          
                    alu_m = `ALU_ADD;      // alu_m
                end                        
                `FUNCT_ADDU: begin         
                    alu_m = `ALU_ADD;      // alu_m
                end                        
                `FUNCT_SUB: begin          
                    alu_m = `ALU_SUB;      // alu_m
                end                        
                `FUNCT_SUBU: begin         
                    alu_m = `ALU_SUB;      // alu_m
                end                        
                `FUNCT_AND: begin          
                    alu_m = `ALU_AND;      // alu_m
                end                        
                `FUNCT_OR: begin          
                    alu_m = `ALU_OR;      // alu_m
                end                       
                `FUNCT_XOR: begin          
                    alu_m = `ALU_XOR;      // alu_m
                end                        
                default:;
            endcase
        end
        `ALUOp_CMD_ADD: alu_m = `ALU_ADD;
        `ALUOp_CMD_SUB: alu_m = `ALU_SUB;
        default;
        endcase
    end
    
endmodule
