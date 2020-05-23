/// code(cpu) until endmodule
/// CPU设计的代码和思路具体见（https://github.com/DnailZ/COLabs/blob/master/lab4/src/verilog/logic/CPU.v）
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
    wire Signal sgn; // sgn 表示 signal
    // 控制单元
    Control ctrl (
        .clk(clk), // 控制单元需要时钟同步来输出 TCL Console 中的文本调试信息。
        .rst(rst),
        .run(run),
    	.opcode(instruction [Opcode] ),
    	.sgn(sgn)
    );
    // 拆开 sgn
    @decompose Signal_t sgn

    // 下将 CPU 分为五个阶段分别编写，会在下面的章节逐个展开
    /// doc_omit begin
    /// code(stages) until codeend
    /// ##### FI 段
    ///
    /// FI 段，编写 PC 和 mdr / ir。
    ///
    // -----------------------------------
    // FETCH INSTRUCTION
    // -----------------------------------
    reg Word PC;
    reg Word operandA, operandB;
    reg Word alu_out;

    wire mem_write = sgn_mem_write & run;
    wire Word mem_rd;
    // 内存地址选择器 IorD
    wire Word mem_addr = (sgn_i_or_d == `MemAddr_I)? PC : alu_out;
    
    dist_mem_gen_0 cache(
        .clk(clk),
        .a(mem_addr[9:2]),
        .d(operandB),
        .we(mem_write),
        .spo(mem_rd),
        .dpra(m_rf_addr),
        .dpo(m_data)
    );
    reg Word mdr;
    reg Word instruction;
    always @(posedge clk) begin
        if(rst) begin
            mdr <= 0; instruction <= 0;
        end else begin
            // 这里 sgn_mem_read 用于写入 mdr， sgn_ir_write 用于写入 ir
            if(run && sgn_mem_read) begin
                mdr <= mem_rd;
            end
            if(run && sgn_ir_write) begin
                instruction <= mem_rd;
            end
        end
    end

    // next_PC 和 PCwe 提供给后面使用
    reg Word next_PC;
    wire PCwe;
    always@(posedge clk or posedge rst) begin
        if(rst)
            PC <= 0;
        else if(run & PCwe)
            PC <= next_PC;
    end

    /// ##### ID 段
    ///
    /// ID 段，编写寄存器文件。
    ///
    /// 除此之外，ID 段还应该完成立即数的符号扩展。（在这里保持良好的可扩展性，添加了无符号扩展，可以对 `andi`, `ori` 等指令提供支持）
    ///
    /// 注：这里用 `sgn` 表示 CPU 的控制信号
    // -----------------------------------
    // DECODE INSTRUCTION
    // -----------------------------------

    @impl RegFile regfile ["instruction [Rs] ", "instruction [Rt] "]
    always @(posedge clk) begin
        if(rst) begin
            {operandA, operandB} <= 0;
        end
        else if(run) begin
            operandA <= regfile_rd0;
            operandB <= regfile_rd1;
        end
    end

    wire [15:0] Imm = instruction [Imm] ;
    wire Word signed_Imm = {{16{Imm[15]}}, Imm}; //[ 为 addi addiu 等提供支持
    wire Word signed_shifted_Imm = signed_Imm << 2; //| 可以为 beq 指令提供支持
    wire Word unsigned_Imm = {16'b0, Imm}; //| 无符号数扩展，可以对 `andi`, `ori` 等指令提供支持
    wire Word imm_addr = {PC[31:28] , instruction [Addr] , 2'b0}; //] 为 jump 提供支持

    /// ##### EX 段
    /// EX 段，编写 ALU 以及其控制模块，
    ///
    /// ALU 控制模块将会将 `funct` 和控制模块的 `aluop` 转化为 ALU 的 `alu_m`。
    ///
    /// 这里 ALUSrc1 的输入选择器有两个：
    ///
    /// - 一个是从控制模块 `Control` 发送来的，可以选择PC，为地址更新和计算提供支持。
    /// - 另一个从ALU控制模块发送过来的，可以选择 `instruction[Shamt]` ，为位移操作指令提供支持。（我把所以funct的译码全部放在aluctrl中，方便管理）
    ///
    /// 除此之外，ALU的出口出还有一个选择器，用于选择输出的结果还是比较判断的结果，为 `slt` 指令提供支持。
    ///
    // -----------------------------------
    // EXECUTE INSTRUCTION
    // -----------------------------------

    @impl ALU_control aluctrl ["sgn_aluop", "instruction [Funct] "]  // ALU控制单元（https://github.com/DnailZ/COLabs/blob/master/lab4/src/verilog/logic/CPU.v）

    // ALUSrc1 的两个选择器。
    // 从控制模块 `Control` 发送来的，可以选择PC，为地址更新和计算提供支持。
    wire Word alu_a_orig = sgn_alu_src1 == `ALUSrc1_OprA ? operandA : PC;
    // 从ALU控制模块发送过来的，可以选择 `instruction[Shamt]` ，为位移操作指令提供支持。
    wire Word alu_a = aluctrl_alu_src1 == `ALUSrc1_Orig ? alu_a_orig : instruction [Shamt] ;

    // ALUSrc2 的选择器，增加来无符号扩展，为 `andi` 等指令提供支持。
    reg Word alu_b;
    always @(*) begin
        alu_b = 0;
        case(sgn_alu_src2)
        `ALUSrc2_Reg: alu_b = operandB;
        `ALUSrc2_4:    alu_b = 4;
        `ALUSrc2_SAddr: alu_b = signed_shifted_Imm;
        `ALUSrc2_SImm: alu_b = signed_Imm;
        `ALUSrc2_UImm: alu_b = unsigned_Imm;
        default: alu_b = 0;
        endcase
    end

    // 例化一个ALU
    @impl ALU alu ["alu_a", "alu_b", "aluctrl_alu_m"] 

    // ALUOut 选择器，为 `slt` 指令提供支持。
    always @(posedge clk) begin
        if(rst)
            alu_out <= 0;
        else if (run) begin
            case(aluctrl_alu_out_mux)
            `ALUOut_Orig: alu_out <= alu_y;  
            `ALUOut_LT: alu_out <= alu_y[WIDTH-1];
            `ALUOut_LTU: alu_out <= alu_cf; // 无符号数比较
            default: alu_out <= alu_y;
            endcase
        end
    end

    /// ##### MEM 段
    ///
    /// Memory已经在FI段编写了，这里只需要更新PC
    ///
    /// 对于 jr 指令，需要在原有的 `pc_source` 选择器之外另加一个选择器。（由于我把funct的译码全部放在aluctrl里面，这样实现最为方便）
    // -----------------------------------
    // MEMORY
    // -----------------------------------

    wire Word nPC = alu_y;
    always @(*) begin
        next_PC = 0;
        // PC_Srouce 选择器
        case(sgn_pc_source)
        `PCSource_NPC: next_PC = nPC;
        `PCSource_Beq: next_PC = alu_out;
        `PCSource_Jump: next_PC = imm_addr;
        default: next_PC = 0;
        endcase
        // jr指令的特殊处理
        if(aluctrl_is_jr_funct)
            next_PC = operandA;
    end
    // jr 的优先级最高
    assign PCwe = aluctrl_is_jr_funct || sgn_pc_write || sgn_pc_write_cond && alu_zf || sgn_pc_write_notcond && ~alu_zf;

    /// ##### WB 段
    ///
    /// WB 段，regfile 写入的内容。
    /// 
    /// RegDst_RA 和 MemToReg_PC 这两项用于简单地提供对 `jal` 指令对 $ra 的保存。
    // -----------------------------------
    // WRITEBACK
    // -----------------------------------

    assign regfile_wa = (sgn_reg_dst == `RegDst_Rt)? instruction [Rt] :
                        (sgn_reg_dst == `RegDst_Rd)? instruction [Rd] :
                        (sgn_reg_dst == `RegDst_RA)? 5'b11111 : 0; // jal 指令
    assign regfile_we = sgn_reg_write;
    assign regfile_wd = (sgn_mem_toreg == `MemToReg_Mem)? mdr :
                        (sgn_mem_toreg == `MemToReg_ALU)? alu_out :
                        (sgn_mem_toreg == `MemToReg_PC)? PC : 0; // jal 指令

    /// ##### Debug 信息
    ///
    /// DBU 所需要的 status 和指令信息。**仿真时输出，不会影响综合效果**
    // -----------------------------------
    // DEBUG MESSAGE （仿真时输出，不会影响综合效果）
    // -----------------------------------

    @a_slet Status_t status ['sgn', 'next_PC', 'PC', 'instruction', 'operandA', 'operandB', 'alu_out', 'mdr']

    // （仿真时输出，不会影响综合效果）
    `ifndef SYSTHESIS
    always @(posedge clk) begin
        if(~rst & run) begin
            $display("[cpu] executing instruction: %h", instruction);
            if(PCwe) $display("[cpu] PC update to: %h", next_PC);
            $display("[cpu] ------------------------------------------------------------------- ");
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(sgn_mem_read) begin
                $display("[lw] $%d <- %h ($%d)", instruction [Rt] , alu_out, instruction [Rs] );
                #1 $display("[lw] read from dcache: %h", mdr);
            end
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(sgn_mem_write) begin
                $display("[sw] $%d (%d) -> %h", instruction [Rt], operandA, alu_out);
                #1 $display("[sw] write to dcache: %h", operandB);
            end
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(sgn_pc_write_cond) begin
                $display("[beq] signed_Imm:", signed_Imm);
                $display("[beq] alu_zf: %d PC move to %h", alu_zf, next_PC);
            end
        end
    end
    `endif
    // codeend

    /// doc_omit end
endmodule
