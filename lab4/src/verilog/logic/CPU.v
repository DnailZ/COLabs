/// code(cpu) until endmodule
/// CPU设计的代码和思路具体见（https://github.com/DnailZ/COLabs/blob/master/lab4/src/verilog/logic/CPU.v）
module CPU
#(
    parameter STATUS_W = 247,
    parameter SIGNAL_W = 23,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 4
) (
    input  clk, 
    input  rst, 
    input  run, 
    input [7:0] m_rf_addr, 
    output [STATUS_W-1:0] status, 
    output [WIDTH-1:0] m_data, 
    output [WIDTH-1:0] rf_data 
);
    wire [SIGNAL_W-1:0] sgn; // sgn 表示 signal
    // 控制单元
    Control ctrl (
        .clk(clk), // 控制单元需要时钟同步来输出 TCL Console 中的文本调试信息。
        .rst(rst),
        .run(run),
    	.opcode(instruction [31:26] ),
    	.sgn(sgn)
    );
    // 拆开 sgn
    wire sgn_pc_write;
    wire sgn_pc_write_cond;
    wire sgn_pc_write_notcond;
    wire [1:0] sgn_pc_source;
    wire sgn_i_or_d;
    wire sgn_mem_write;
    wire sgn_mem_read;
    wire sgn_ir_write;
    wire [1:0] sgn_mem_toreg;
    wire sgn_reg_write;
    wire [1:0] sgn_reg_dst;
    wire [2:0] sgn_aluop;
    wire [1:0] sgn_alu_out_mux;
    wire [2:0] sgn_alu_src2;
    wire sgn_alu_src1;
    assign { sgn_pc_write, sgn_pc_write_cond, sgn_pc_write_notcond, sgn_pc_source, sgn_i_or_d, sgn_mem_write, sgn_mem_read, sgn_ir_write, sgn_mem_toreg, sgn_reg_write, sgn_reg_dst, sgn_aluop, sgn_alu_out_mux, sgn_alu_src2, sgn_alu_src1} = sgn;

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
    reg [WIDTH-1:0] PC;
    reg [WIDTH-1:0] operandA, operandB;
    reg [WIDTH-1:0] alu_out;

    wire mem_write = sgn_mem_write & run;
    wire [WIDTH-1:0] mem_rd;
    // 内存地址选择器 IorD
    wire [WIDTH-1:0] mem_addr = (sgn_i_or_d == `MemAddr_I)? PC : alu_out;
    
    dist_mem_gen_0 cache(
        .clk(clk),
        .a(mem_addr[9:2]),
        .d(operandB),
        .we(mem_write),
        .spo(mem_rd),
        .dpra(m_rf_addr),
        .dpo(m_data)
    );
    reg [WIDTH-1:0] mdr;
    reg [WIDTH-1:0] instruction;
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
    reg [WIDTH-1:0] next_PC;
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
    always @(posedge clk) begin
        if(rst) begin
            {operandA, operandB} <= 0;
        end
        else if(run) begin
            operandA <= regfile_rd0;
            operandB <= regfile_rd1;
        end
    end

    wire [15:0] Imm = instruction [15:0] ;
    wire [WIDTH-1:0] signed_Imm = {{16{Imm[15]}}, Imm};                       // 为 addi addiu 等提供支持
    wire [WIDTH-1:0] signed_shifted_Imm = signed_Imm << 2;                    // 可以为 beq 指令提供支持
    wire [WIDTH-1:0] unsigned_Imm = {16'b0, Imm};                             // 无符号数扩展，可以对 `andi`, `ori` 等指令提供支持
    wire [WIDTH-1:0] imm_addr = {PC[31:28] , instruction [25:0] , 2'b0};      // 为 jump 提供支持

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

    wire [ALUOP_W-1:0] aluctrl_alu_m;
    wire  aluctrl_alu_src1;
    wire [1:0] aluctrl_alu_out_mux;
    wire  aluctrl_is_jr_funct;
    // ALU控制单元（https://github.com/DnailZ/COLabs/blob/master/lab4/src/verilog/logic/CPU.v）
    ALU_control aluctrl (
    	.sgn_alu_out_mux(sgn_alu_out_mux),
    	.aluop(sgn_aluop),
    	.funct(instruction [5:0] ),
    	.alu_m(aluctrl_alu_m),
    	.alu_src1(aluctrl_alu_src1),
    	.alu_out_mux(aluctrl_alu_out_mux),
    	.is_jr_funct(aluctrl_is_jr_funct)
    );

    // ALUSrc1 的两个选择器。
    // 从控制模块 `Control` 发送来的，可以选择PC，为地址更新和计算提供支持。
    wire [WIDTH-1:0] alu_a_orig = sgn_alu_src1 == `ALUSrc1_OprA ? operandA : PC;
    // 从ALU控制模块发送过来的，可以选择 `instruction[Shamt]` ，为位移操作指令提供支持。
    wire [WIDTH-1:0] alu_a = aluctrl_alu_src1 == `ALUSrc1_Orig ? alu_a_orig : instruction [10:6] ;

    // ALUSrc2 的选择器，增加来无符号扩展，为 `andi` 等指令提供支持。
    reg [WIDTH-1:0] alu_b;
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

    wire [WIDTH-1:0] nPC = alu_y;
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

    assign regfile_wa = (sgn_reg_dst == `RegDst_Rt)? instruction [20:16] :
                        (sgn_reg_dst == `RegDst_Rd)? instruction [15:11] :
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

    assign status = {      //
        sgn,               // signal
        next_PC,           // next_pc
        PC,                // pc
        instruction,       // instruction
        operandA,          // regfile_rd0
        operandB,          // regfile_rd1
        alu_out,           // alu_out
        mdr                // mem_rd
    };                     //

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
                $display("[lw] $%d <- %h ($%d)", instruction [20:16] , alu_out, instruction [25:21] );
                #1 $display("[lw] read from dcache: %h", mdr);
            end
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(sgn_mem_write) begin
                $display("[sw] $%d (%d) -> %h", instruction [20:16], operandA, alu_out);
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
