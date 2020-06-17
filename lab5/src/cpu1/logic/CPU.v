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
    reg ldPC;

    wire ld_jump_pc;
    wire Word jump_pc;
    wire ld_branch_pc;
    wire Word branch_pc;

    always@(posedge clk or posedge rst) begin
        if(rst)
            PC <= 0;
        else if(run & ldPC) begin
            if(ld_branch_pc) begin
                PC <= branch_pc;
            end
            else if(ld_jump_pc) begin
                PC <= jump_pc;
            end
            else begin
                PC <= PC + 4;
            end
        end
    end

    // --------- 段寄存器 ---------
    reg ld_fi;
    reg clear_fi;
    @regnext fi_ir Word instruction
    @regnext fi_npc Word (PC + 4)
    @always_for_regs (run && ld_fi) (rst || clear_fi)

    /// ##### ID 段
    ///
    /// ID 段，编写控制模块和寄存器文件
    ///
    /// 除此之外，ID 段还应该完成立即数的符号扩展。（在这里保持良好的可扩展性，添加了无符号扩展，可以对 `andi`, `ori` 等指令提供支持）
    ///
    /// 注：这里用 `sig` 表示 CPU 的控制信号
    // -----------------------------------
    // DECODE INSTRUCTION
    // -----------------------------------

    wire Signal sig; // sig 表示 signal
    Control ctrl (
        .clk(clk), // 控制单元需要时钟同步来输出 TCL Console 中的文本调试信息。
        .rst(rst),
        .run(run),
    	.opcode(fi_ir [Opcode] ),
    	.sig(sig)
    );
    @decompose Signal_t sig

    @impl RegFile regfile ["fi_ir [Rs] ", "fi_ir [Rt] "]
    
    wire [15:0] Imm = fi_ir [Imm] ;
    wire Word signed_Imm = {{16{Imm[15]}}, Imm};
    wire Word unsigned_Imm = {{16{1'b0}}, Imm}; // 无符号数扩展

    assign ld_jump_pc = sig_jump; // 当 sig_jump 时，PC的值更新为 jump_pc
    assign jump_pc = {PC[31:28], fi_ir [Addr] , 2'd0};

    // --------- 段寄存器 ---------

    reg clear_id_sig;
    @regnext id_sig_ex ExSig_t dictgen("sig")
    @regnext id_sig_mem MemSig_t dictgen("sig")
    @regnext id_sig_wb WbSig_t dictgen("sig")
    @always_for_regs run (rst | clear_id_sig)

    @regnext id_reg_a Word regfile_rd0
    @regnext id_reg_b Word regfile_rd1
    @regnext id_simm Word signed_Imm
    @regnext id_uimm Word unsigned_Imm

    @regnext id_rs RegId (fi_ir [Rs] )
    @regnext id_rt RegId (fi_ir [Rt] )
    @regnext id_rd RegId (fi_ir [Rd] )
    @regnext id_funct Funct (fi_ir [Funct] )

    @regnext id_npc Word fi_npc
    @always_for_regs run

    /// ##### EX 段
    /// EX 段，编写 ALU 以及其控制模块，
    ///
    /// ALU 控制模块将会将 `funct` 和控制模块的 `aluop` 转化为 ALU 的 `alu_m`。
    ///
    /// `alu_src2` 处应当有一个选择 `alu_b` 的选择器
    // -----------------------------------
    // EXECUTE INSTRUCTION
    // -----------------------------------

    @impl ALU_control aluctrl ["id_sig_ex_aluop", "id_funct"]  // ALU控制单元（https://github.com/DnailZ/COLabs/blob/master/lab3/src/verilog/logic/CPU.v）

    reg Word forwarding_a; // 旁路的相关代码见后面 Forwarding 小节
    reg Word forwarding_b;

    wire Word alu_a = forwarding_a;
    reg Word alu_b;
    always @(*) begin
        // alu_a = 0;
        alu_b = 0;
        case(id_sig_ex_alu_src2)
        `ALUSrc2_Reg: alu_b = forwarding_b;
        `ALUSrc2_SImm: alu_b = id_simm;
        `ALUSrc2_UImm: alu_b = id_uimm;
        default: alu_b = 0;
        endcase
        // case(aluctrl_alu_src1)
        // `ALUSrc1_Rs: alu_a = regfile_rd0;
        // `ALUSrc1_Shamt: alu_a = instruction [Shamt];
        // `ALUSrc1_Mem: alu_a = mem_rd; // especially for accm instruction
        // default: alu_a = 0;
        // endcase
    end

    @impl ALU alu ["alu_a", "alu_b", "aluctrl_alu_m"] 

    assign ld_branch_pc = id_sig_ex_branch & alu_zf;
    assign branch_pc = id_npc + (id_simm << 2);

    // --------- 段寄存器 ---------

    @regnext ex_sig_mem MemSig_t dictgen("id_sig_mem")
    @regnext ex_sig_wb WbSig_t dictgen("id_sig_wb")
    @always_for_regs run

    @regnext ex_aluout Word alu_y
    @regnext ex_alu_b Word forwarding_b
    wire RegId id_wb_addr = id_sig_ex_reg_dst == `RegDst_Rd ? id_rd : id_rt;
    @regnext ex_wb_addr RegId id_wb_addr
    @always_for_regs run

    /// ##### MEM 段
    ///
    /// MEM 段，编写 DCache （DCache 用 dist_mem_gen 实现），同时求出 `next_PC`
    // -----------------------------------
    // MEMORY
    // -----------------------------------

    wire mem_write = ex_sig_mem_mem_write & run;
    wire Word mem_rd;
    wire Word mem_addr = ex_aluout;
    dist_mem_gen_1 dcache(
        .clk(clk),
        .a(mem_addr[9:2]),
        .d(ex_alu_b),
        .we(mem_write),
        .spo(mem_rd),
        .dpra(m_rf_addr),
        .dpo(m_data)
    );

    // --------- 段寄存器 ---------

    @regnext mem_sig_wb WbSig_t dictgen("ex_sig_wb")
    @always_for_regs run

    @regnext mem_mem_rd Word mem_rd
    @regnext mem_aluout Word ex_aluout
    @regnext mem_wb_addr RegId ex_wb_addr
    @always_for_regs run

    /// ##### WB 段
    ///
    /// WB 段，regfile 写入的内容。
    // -----------------------------------
    // WRITEBACK
    // -----------------------------------

    assign regfile_wa = mem_wb_addr;
    assign regfile_we = mem_sig_wb_reg_write;
    assign regfile_wd = (mem_sig_wb_mem_toreg == `MemToReg_Mem)? mem_mem_rd : mem_aluout;

    /// ##### Forwarding 旁路
    ///
    /// a
    // -----------------------------------
    // Forwarding
    // -----------------------------------

    always @(*) begin
        forwarding_a = id_reg_a;
        forwarding_b = id_reg_b;

        if(mem_sig_wb_reg_write) begin
            if(mem_wb_addr != 0) begin
                if(id_rs == mem_wb_addr) begin
                    forwarding_a = regfile_wd;
                end
                if(id_rt == mem_wb_addr) begin
                    forwarding_b = regfile_wd;
                end
            end
        end
        if(ex_sig_wb_reg_write) begin
            if(ex_wb_addr != 0) begin
                if(id_rs == ex_wb_addr) begin
                    forwarding_a = ex_aluout;
                end
                if(id_rt == ex_wb_addr) begin
                    forwarding_b = ex_aluout;
                end
            end
        end
    end

    /// ##### 处理冲突和分支预测
    ///
    /// a
    // -----------------------------------
    // Harzard Detection & Branch
    // -----------------------------------
    wire lduse_harzard_possible = id_sig_mem_mem_read && id_sig_wb_reg_write;
    wire lduse_harzard_rs =  sig_detect_lduse_rs && lduse_harzard_possible && fi_ir [Rs] == id_wb_addr;
    wire lduse_harzard_rt = sig_detect_lduse_rt && lduse_harzard_possible && fi_ir [Rt] == id_wb_addr;
    always @(*) begin
        ldPC = 1;
        ld_fi = 1;
        clear_id_sig = 0;
        clear_fi = 0;
        if(lduse_harzard_rs | lduse_harzard_rt) begin
            ld_fi = 0;
            ldPC = 0;
            clear_id_sig = 1;
        end
        // 分支预测：当 branch 选择跳转时，清空 fi 和 id（只用清楚部分信号） 的段寄存器
        if(ld_branch_pc) begin
            clear_fi = 1;
            clear_id_sig = 1;
        end
    end

    /// ##### Debug 信息
    ///
    /// DBU 所需要的 status 和指令信息。
    // -----------------------------------
    // DEBUG MESSAGE
    // -----------------------------------

    @a_slet Status_t status ['sig', 'next_PC', 'PC', 'instruction', 'regfile_rd1', 'regfile_rd1', 'alu_y', 'mem_rd']

    `ifndef SYNTHESIS
    always @(posedge clk) begin
        if(run & !rst) begin
            $display("[cpu] --------- new cycle -----------", PC);
            $display("[cpu] PC = %h", PC);
            if(ld_jump_pc)
                $display("[jump] jump to %h", jump_pc);
            if(id_sig_ex_branch) begin
                if(ld_branch_pc)
                    $display("[branch] branch to %h", branch_pc);
                else 
                    $display("[branch] failed");
            end
            if(ex_sig_mem_mem_read)
                $display("[memory] read %h: %h", mem_addr, mem_rd);
            if(mem_write)
                $display("[memory] write %h: -> %h", mem_addr, mem_rd, ex_alu_b);
        end
    end
    `endif
    /// doc_omit end
endmodule
