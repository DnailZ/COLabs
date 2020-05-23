
module ALU_control
#(
    parameter SIGNAL_W = 23,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 4
) (
    input [2:0] aluop, 
    input [FUNCT_W-1:0] funct, 
    input [1:0] sgn_alu_out_mux, 
    output reg [ALUOP_W-1:0] alu_m, 
    output reg  alu_src1, 
    output reg [1:0] alu_out_mux, 
    output reg  is_jr_funct 
);
    always@(*) begin
        alu_m = 3'bxxx;
        alu_src1 = `ALUSrc1_Orig;
        alu_out_mux = sgn_alu_out_mux;
        is_jr_funct = 0;
        case(aluop)
        `ALUOp_CMD_RTYPE: begin
            case(funct)
                `FUNCT_ADD: begin             //
                    alu_m = `ALU_ADD;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_ADDU: begin            //
                    alu_m = `ALU_ADD;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_SUB: begin             //
                    alu_m = `ALU_SUB;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_SUBU: begin            //
                    alu_m = `ALU_SUB;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_AND: begin             //
                    alu_m = `ALU_AND;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_OR: begin              //
                    alu_m = `ALU_OR;          // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_XOR: begin             //
                    alu_m = `ALU_XOR;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_NOR: begin             //
                    alu_m = `ALU_NOR;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_SLLV: begin            //
                    alu_m = `ALU_SHL;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_SRLV: begin            //
                    alu_m = `ALU_SHRL;        // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_SRAV: begin            //
                    alu_m = `ALU_SHRA;        // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'b0;       // is_jr_funct (by default)
                end                           //
                `FUNCT_SLL: begin                   //
                    alu_m = `ALU_SHL;               // alu_m
                    alu_src1 = `ALUSrc1_Shamt;      // alu_src1
                    alu_out_mux = 2'b00;            // alu_out_mux (by default)
                    is_jr_funct = 1'b0;             // is_jr_funct (by default)
                end                                 //
                `FUNCT_SRL: begin                   //
                    alu_m = `ALU_SHRL;              // alu_m
                    alu_src1 = `ALUSrc1_Shamt;      // alu_src1
                    alu_out_mux = 2'b00;            // alu_out_mux (by default)
                    is_jr_funct = 1'b0;             // is_jr_funct (by default)
                end                                 //
                `FUNCT_SRA: begin                   //
                    alu_m = `ALU_SHRA;              // alu_m
                    alu_src1 = `ALUSrc1_Shamt;      // alu_src1
                    alu_out_mux = 2'b00;            // alu_out_mux (by default)
                    is_jr_funct = 1'b0;             // is_jr_funct (by default)
                end                                 //
                `FUNCT_SLT: begin                  //
                    alu_m = `ALU_SUB;              // alu_m
                    alu_src1 = 1'b0;               // alu_src1 (by default)
                    alu_out_mux = `ALUOut_LT;      // alu_out_mux
                    is_jr_funct = 1'b0;            // is_jr_funct (by default)
                end                                //
                `FUNCT_SLTU: begin                  //
                    alu_m = `ALU_SUB;               // alu_m
                    alu_src1 = 1'b0;                // alu_src1 (by default)
                    alu_out_mux = `ALUOut_LTU;      // alu_out_mux
                    is_jr_funct = 1'b0;             // is_jr_funct (by default)
                end                                 //
                `FUNCT_JR: begin              //
                    alu_m = `ALU_SUB;         // alu_m
                    alu_src1 = 1'b0;          // alu_src1 (by default)
                    alu_out_mux = 2'b00;      // alu_out_mux (by default)
                    is_jr_funct = 1'h1;       // is_jr_funct
                end                           //
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
