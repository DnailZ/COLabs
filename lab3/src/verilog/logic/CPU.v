module CPU
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
    input  run, 
    input [7:0] m_rf_addr, 
    output [235:0] status, 
    output [WIDTH-1:0] m_data, 
    output [WIDTH-1:0] rf_data 
);
    // -----------------------------------
    // FETCH INSTRUCITON
    // -----------------------------------
    reg [WIDTH-1:0] PC;
    wire [WIDTH-1:0] instruction;
    dist_mem_gen_0 ins_RAM(
        .clk(clk),
        .a(PC[9:2]),
        .spo(instruction),
        .we(0)
    );
    reg [WIDTH-1:0] next_PC;
    always@(posedge clk or posedge rst) begin
        if(rst)
            PC <= 0;
        else if(run)
            PC <= next_PC;
    end

    // -----------------------------------
    // DECODE INSTRUCITON
    // -----------------------------------

    wire [SIGNAL_W-1:0] sgn;
    Control ctrl (
        .clk(clk),
        .rst(rst),
    	.opcode(instruction [31:26] ),
    	.sgn(sgn)
    );
    wire sgn_jump;
    wire sgn_branch;
    wire sgn_mem_read;
    wire sgn_mem_write;
    wire sgn_reg_write;
    wire sgn_reg_dst;
    wire sgn_mem_toreg;
    wire [2:0] sgn_aluop;
    wire sgn_alu_src2;
    assign { sgn_jump, sgn_branch, sgn_mem_read, sgn_mem_write, sgn_reg_write, sgn_reg_dst, sgn_mem_toreg, sgn_aluop, sgn_alu_src2} = sgn;

    wire [WIDTH-1:0] regfile_rd0;
    wire [WIDTH-1:0] regfile_rd1;
    wire [REG_W-1:0] regfile_wa;
    wire  regfile_we;
    wire [WIDTH-1:0] regfile_wd;
    RegFile regfile (
    	.clk(clk),
    	.rst(rst),
    	.m_rf_addr(m_rf_addr),
    	.rf_data(rf_data),
    	.ra0(instruction [25:21] ),
    	.ra1(instruction [20:16] ),
    	.rd0(regfile_rd0),
    	.rd1(regfile_rd1),
    	.wa(regfile_wa),
    	.we(regfile_we),
    	.wd(regfile_wd)
    );
    
    wire [15:0] Imm = instruction [15:0] ;
    wire [WIDTH-1:0] signed_Imm = {{16{Imm[15]}}, Imm};

    // -----------------------------------
    // EXECUTE INSTRUCITON
    // -----------------------------------

    wire [ALUOP_W-1:0] aluctrl_alu_m;
    ALU_control aluctrl (
    	.aluop(sgn_aluop),
    	.funct(instruction [5:0] ),
    	.alu_m(aluctrl_alu_m)
    );

    wire [WIDTH-1:0] alu_a = regfile_rd0;
    wire [WIDTH-1:0] alu_b = (sgn_alu_src2 == `ALUSrc2_Reg)? regfile_rd1 : signed_Imm;
    wire [WIDTH-1:0] alu_y;
    wire  alu_zf;
    wire  alu_cf;
    wire  alu_of;
    ALU alu (
    	.a(alu_a),
    	.b(alu_b),
    	.m(aluctrl_alu_m),
    	.y(alu_y),
    	.zf(alu_zf),
    	.cf(alu_cf),
    	.of(alu_of)
    );
    
    wire [WIDTH-1:0] nPC = PC + 4;
    always @(*) begin
        if(sgn_jump)
            next_PC = {nPC[31:28], instruction [25:0] , 2'b00};
        else if(sgn_branch & alu_zf)
            next_PC = {signed_Imm[29:0], 2'b00} + nPC;
        else
            next_PC = nPC;
    end

    // -----------------------------------
    // MEMORY
    // -----------------------------------

    wire mem_write = sgn_mem_write & run;
    wire [WIDTH-1:0] mem_rd;
    dist_mem_gen_1 data_RAM(
        .clk(clk),
        .a(alu_y[9:2]),
        .d(regfile_rd1),
        .we(mem_write),
        .spo(mem_rd),
        .dpra(m_rf_addr),
        .dpo(m_data)
    );
    
    // -----------------------------------
    // WRITEBACK
    // -----------------------------------

    assign regfile_wa = (sgn_reg_dst == `RegDst_Rt)? instruction [20:16] : instruction [15:11] ;
    assign regfile_we = sgn_reg_write;
    assign regfile_wd = (sgn_mem_toreg == `MemToReg_Mem)? mem_rd : alu_y;

    // -----------------------------------
    // DEBUG MESSAGE
    // -----------------------------------

    `ifndef SYSTHESIS
    always @(posedge clk) begin
        if(~rst & run) begin
            $display("[cpu] executing instruction: %h", instruction);
            $display("[cpu] PC update to: %h", next_PC);
            $display("[cpu] ------------------------------------------------------------------- ");
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(sgn_mem_read) begin
                $display("[lw] $%d <- %h ($%d)", instruction [20:16] , alu_y, instruction [25:21] );
                #1 $display("[lw] read from dcache: %h", mem_rd);
            end
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(mem_write) begin
                $display("[sw] $%d (%d) -> %h", instruction [20:16], regfile_rd1, alu_y);
                #1 $display("[sw] write to dcache: %h", regfile_rd1);
            end
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(sgn_branch) begin
                $display("[beq] signed_Imm:", signed_Imm);
                $display("[beq] alu_zf: %d PC move to %h", alu_zf, next_PC);
            end
        end
    end
    `endif

endmodule
