/// code(cpu) until endmodule
/// CPU设计的代码和思路具体见（https://github.com/DnailZ/COLabs/blob/master/lab3/src/verilog/logic/CPU.v）
@module CPU
#(
    @defparam_struct Status_t
    @defparam
) (
    @ninput clk,
    @ninput rst,
    @Input run,
    @Input m_rf_addr [7:0],
    @output status Status,
    @output m_data Word,
    @output rf_data Word
);
    // 下将 CPU 分为五个阶段分别编写，会在下面的章节逐个展开
    /// doc_omit begin

    /// code(stages) until codeend
    /// ##### FI 段
    ///
    /// FI 段，编写 PC 和 ICache（ICache 用 dist_mem_gen 实现），并且将 `next_PC` 写入PC。
    // -----------------------------------
    // FETCH INSTRUCTION
    // -----------------------------------
    reg Word PC;
    wire Word instruction;
    dist_mem_gen_0 icache(
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
    /// ##### ID 段
    ///
    /// ID 段，编写控制模块和寄存器文件
    ///
    /// 除此之外，ID 段还应该完成立即数的符号扩展。（在这里保持良好的可扩展性，添加了无符号扩展，可以对 `andi`, `ori` 等指令提供支持）
    ///
    /// 注：这里用 `sgn` 表示 CPU 的控制信号
    // -----------------------------------
    // DECODE INSTRUCTION
    // -----------------------------------

    wire Signal sgn; // sgn 表示 signal
    Control ctrl (
        .clk(clk),
        .rst(rst),
        .run(run),
    	.opcode(instruction [Opcode] ),
    	.sgn(sgn)
    );
    @decompose Signal_t sgn

    @impl RegFile regfile ["instruction [Rs] ", "instruction [Rt] "]
    
    wire [15:0] Imm = instruction [Imm] ;
    wire Word signed_Imm = {{16{Imm[15]}}, Imm};
    wire Word unsigned_Imm = {{16{0}}, Imm}; // 无符号数扩展

    /// ##### EX 段
    /// EX 段，编写 ALU 以及其控制模块，
    ///
    /// ALU 控制模块将会将 `funct` 和控制模块的 `aluop` 转化为 ALU 的 `alu_m`。
    ///
    /// `alu_src2` 处应当有一个选择 `alu_b` 的选择器
    // -----------------------------------
    // EXECUTE INSTRUCTION
    // -----------------------------------

    @impl ALU_control aluctrl ["sgn_aluop", "instruction [Funct] "]

    reg Word alu_a;
    reg Word alu_b;
    always @(*) begin
        alu_a = 0;
        alu_b = 0;
        case(sgn_alu_src2)
        `ALUSrc2_Reg: alu_b = regfile_rd1;
        `ALUSrc2_SImm: alu_b = signed_Imm;
        `ALUSrc2_UImm: alu_b = unsigned_Imm;
        default: alu_b = 0;
        endcase
        case(aluctrl_alu_src1)
        `ALUSrc1_Rs: alu_a = regfile_rd0;
        `ALUSrc1_Shamt: alu_a = instruction [Shamt];
        `ALUSrc1_Mem: alu_a = mem_rd; // especially for accm instruction
        default: alu_a = 0;
        endcase
    end

    @impl ALU alu ["alu_a", "alu_b", "aluctrl_alu_m"]  // ALU控制单元（https://github.com/DnailZ/COLabs/blob/master/lab3/src/verilog/logic/CPU.v）
    wire Word alu_out = alu_y;

    /// ##### MEM 段
    ///
    /// MEM 段，编写 DCache （DCache 用 dist_mem_gen 实现），同时求出 `next_PC`
    // -----------------------------------
    // MEMORY
    // -----------------------------------

    wire mem_write = sgn_mem_write & run;
    wire Word mem_rd;
    wire mem_addr =
        (aluctrl_mem_addr_mux == `MemAddrMux_ALU)? alu_out : regfile_rd0;
    dist_mem_gen_1 dcache(
        .clk(clk),
        .a(mem_addr[9:2]),
        .d(regfile_rd1),
        .we(mem_write),
        .spo(mem_rd),
        .dpra(m_rf_addr),
        .dpo(m_data)
    );

    wire Word nPC = PC + 4;
    always @(*) begin
        if(sgn_jump)
            next_PC = {nPC[31:28], instruction [Addr] , 2'b00};
        else if(sgn_branch & alu_zf)
            next_PC = {signed_Imm[29:0], 2'b00} + nPC;
        else
            next_PC = nPC;
    end
    /// ##### WB 段
    ///
    /// WB 段，regfile 写入的内容。
    // -----------------------------------
    // WRITEBACK
    // -----------------------------------

    assign regfile_wa = (sgn_reg_dst == `RegDst_Rt)? instruction [Rt] : instruction [Rd] ;
    assign regfile_we = sgn_reg_write;
    assign regfile_wd = (sgn_mem_toreg == `MemToReg_Mem)? mem_rd : alu_out;

    /// ##### Debug 信息
    ///
    /// DBU 所需要的 status 和指令信息。
    // -----------------------------------
    // DEBUG MESSAGE
    // -----------------------------------

    @a_slet Status_t status ['sgn', 'next_PC', 'PC', 'instruction', 'regfile_rd1', 'regfile_rd1', 'alu_out', 'mem_rd']

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
                $display("[lw] $%d <- %h ($%d)", instruction [Rt] , alu_out, instruction [Rs] );
                #1 $display("[lw] read from dcache: %h", mem_rd);
            end
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(mem_write) begin
                $display("[sw] $%d (%d) -> %h", instruction [Rt], regfile_rd1, alu_out);
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
    // codeend

    /// doc_omit end
endmodule
