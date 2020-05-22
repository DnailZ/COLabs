
module ALU_control
#(
    parameter SIGNAL_W = 13,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 3
) (
    input [2:0] aluop, 
    input [FUNCT_W-1:0] funct, 
    output reg [ALUOP_W-1:0] alu_m, 
    output reg [1:0] alu_src1, 
    output reg  mem_addr_mux 
);
    always@(*) begin
        alu_m = 3'bxxx;
        alu_src1 = `ALUSrc1_Rs;
        mem_addr_mux = `MemAddrMux_ALU;
        case(aluop)
        `ALUOp_CMD_RTYPE: begin
            case(funct)
                `FUNCT_ADD: begin            //
                    alu_m = `ALU_ADD,        // alu_m
                    alu_src1 = 2'b00,        // alu_src1 (by default)
                    mem_addr_mux = 1'b0      // mem_addr_mux (by default)
                end                          //
                `FUNCT_ADDU: begin           //
                    alu_m = `ALU_ADD,        // alu_m
                    alu_src1 = 2'b00,        // alu_src1 (by default)
                    mem_addr_mux = 1'b0      // mem_addr_mux (by default)
                end                          //
                `FUNCT_SUB: begin            //
                    alu_m = `ALU_SUB,        // alu_m
                    alu_src1 = 2'b00,        // alu_src1 (by default)
                    mem_addr_mux = 1'b0      // mem_addr_mux (by default)
                end                          //
                `FUNCT_SUBU: begin           //
                    alu_m = `ALU_SUB,        // alu_m
                    alu_src1 = 2'b00,        // alu_src1 (by default)
                    mem_addr_mux = 1'b0      // mem_addr_mux (by default)
                end                          //
                `FUNCT_AND: begin            //
                    alu_m = `ALU_AND,        // alu_m
                    alu_src1 = 2'b00,        // alu_src1 (by default)
                    mem_addr_mux = 1'b0      // mem_addr_mux (by default)
                end                          //
                `FUNCT_OR: begin             //
                    alu_m = `ALU_OR,         // alu_m
                    alu_src1 = 2'b00,        // alu_src1 (by default)
                    mem_addr_mux = 1'b0      // mem_addr_mux (by default)
                end                          //
                `FUNCT_XOR: begin            //
                    alu_m = `ALU_XOR,        // alu_m
                    alu_src1 = 2'b00,        // alu_src1 (by default)
                    mem_addr_mux = 1'b0      // mem_addr_mux (by default)
                end                          //
                `FUNCT_ACCM: begin                     //
                    alu_m = `ALU_ADD,                  // alu_m
                    alu_src1 = `ALUSrc1_Mem,           // alu_src1
                    mem_addr_mux = `MemAddrMux_Rs      // mem_addr_mux
                end                                    //
                default:;
            endcase
        end
        `ALUOp_CMD_ADD: alu_m = `ALU_ADD;
        `ALUOp_CMD_SUB: alu_m = `ALU_SUB;
        default;
        endcase
    end
    
endmodule
