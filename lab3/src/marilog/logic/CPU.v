@module CPU
#(
    @defparam
) (
    @ninput clk,
    @ninput rst,
    @Input run,
    @Input m_rf_addr [7:0],
    @output status [235:0],
    @output m_data Word,
    @output rf_data Word
);
    // -----------------------------------
    // FETCH INSTRUCITON
    // -----------------------------------
    reg Word PC;
    wire Word instruction;
    dist_mem_gen_0 ins_RAM(
        .clk(clk),
        .a(PC[9:2]),
        .spo(instruction),
        .we(0)
    );
    reg Word next_PC;
    always@(posedge clk or posedge rst) begin
        if(rst)
            PC <= 0;
        else if(run)
            PC <= next_PC;
    end

    // -----------------------------------
    // DECODE INSTRUCITON
    // -----------------------------------

    wire Signal sgn;
    Control ctrl (
        .clk(clk),
        .rst(rst),
    	.opcode(instruction [31:26] ),
    	.sgn(sgn)
    );
    @decompose Signal_t sgn

    @impl RegFile regfile ["instruction [Rs] ", "instruction [Rt] "]
    
    wire [15:0] Imm = instruction [Imm] ;
    wire Word signed_Imm = {{16{Imm[15]}}, Imm};

    // -----------------------------------
    // EXECUTE INSTRUCITON
    // -----------------------------------

    @impl ALU_control aluctrl ["sgn_aluop", "instruction [Funct] "]

    wire Word alu_a = regfile_rd0;
    wire Word alu_b = (sgn_alu_src2 == `ALUSrc2_Reg)? regfile_rd1 : signed_Imm;
    @impl ALU alu ["alu_a", "alu_b", "aluctrl_alu_m"]
    
    wire Word nPC = PC + 4;
    always @(*) begin
        if(sgn_jump)
            next_PC = {nPC[31:28], instruction [Addr] , 2'b00};
        else if(sgn_branch & alu_zf)
            next_PC = {signed_Imm[29:0], 2'b00} + nPC;
        else
            next_PC = nPC;
    end

    // -----------------------------------
    // MEMORY
    // -----------------------------------

    wire mem_write = sgn_mem_write & run;
    wire Word mem_rd;
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

    assign regfile_wa = (sgn_reg_dst == `RegDst_Rt)? instruction [Rt] : instruction [Rd] ;
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
                $display("[lw] $%d <- %h ($%d)", instruction [Rt] , alu_y, instruction [Rs] );
                #1 $display("[lw] read from dcache: %h", mem_rd);
            end
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(mem_write) begin
                $display("[sw] $%d (%d) -> %h", instruction [Rt], regfile_rd1, alu_y);
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
