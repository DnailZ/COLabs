/// code(cpu) until endmodule
/// CPU设计的代码和思路具体见（https://github.com/DnailZ/COLabs/blob/master/lab3/src/verilog/logic/CPU.v）
module CPU
#(
    parameter STATUS_W = 237,
    parameter SIGNAL_W = 13,
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
    output [STATUS_W-1:0] status, 
    output [WIDTH-1:0] m_data, 
    output [WIDTH-1:0] rf_data 
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
    reg [WIDTH-1:0] PC;
    wire [WIDTH-1:0] instruction;
    dist_mem_gen_0 icache(
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

    wire [SIGNAL_W-1:0] sgn; // sgn 表示 signal
    Control ctrl (
        .clk(clk),
        .rst(rst),
        .run(run),
    	.opcode(instruction [31:26] ),
    	.sgn(sgn)
    );
    wire sgn_jump;
    wire sgn_branch;
    wire sgn_reg_write;
    wire sgn_reg_dst;
    wire sgn_mem_read;
    wire sgn_mem_toreg;
    wire sgn_mem_write;
    wire [2:0] sgn_aluop;
    wire [1:0] sgn_alu_src2;
    wire sgn_branch_neq;
    assign { sgn_jump, sgn_branch, sgn_reg_write, sgn_reg_dst, sgn_mem_read, sgn_mem_toreg, sgn_mem_write, sgn_aluop, sgn_alu_src2, sgn_branch_neq} = sgn;

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
    wire [WIDTH-1:0] unsigned_Imm = {{16{0}}, Imm}; // 无符号数扩展

    /// ##### EX 段
    /// EX 段，编写 ALU 以及其控制模块，
    ///
    /// ALU 控制模块将会将 `funct` 和控制模块的 `aluop` 转化为 ALU 的 `alu_m`。
    ///
    /// `alu_src2` 处应当有一个选择 `alu_b` 的选择器
    // -----------------------------------
    // EXECUTE INSTRUCTION
    // -----------------------------------

    wire [ALUOP_W-1:0] aluctrl_alu_m;
    wire [1:0] aluctrl_alu_src1;
    wire  aluctrl_mem_addr_mux;
    
    ALU_control aluctrl (
    	.aluop(sgn_aluop),
    	.funct(instruction [5:0] ),
    	.alu_m(aluctrl_alu_m),
    	.alu_src1(aluctrl_alu_src1),
    	.mem_addr_mux(aluctrl_mem_addr_mux)
    );

    reg [WIDTH-1:0] alu_a;
    reg [WIDTH-1:0] alu_b;
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
        `ALUSrc1_Shamt: alu_a = instruction [10:6];
        `ALUSrc1_Mem: alu_a = mem_rd; // especially for accm instruction
        default: alu_a = 0;
        endcase
    end

    wire [WIDTH-1:0] alu_y;
    wire  alu_zf;
    wire  alu_cf;
    wire  alu_of;
    // ALU控制单元（https://github.com/DnailZ/COLabs/blob/master/lab3/src/verilog/logic/CPU.v）
    ALU alu (
    	.a(alu_a),
    	.b(alu_b),
    	.m(aluctrl_alu_m),
    	.y(alu_y),
    	.zf(alu_zf),
    	.cf(alu_cf),
    	.of(alu_of)
    );
    wire [WIDTH-1:0] alu_out = alu_y;

    /// ##### MEM 段
    ///
    /// MEM 段，编写 DCache （DCache 用 dist_mem_gen 实现），同时求出 `next_PC`
    // -----------------------------------
    // MEMORY
    // -----------------------------------

    wire mem_write = sgn_mem_write & run;
    wire [WIDTH-1:0] mem_rd;
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

    wire [WIDTH-1:0] nPC = PC + 4;
    always @(*) begin
        if(sgn_jump)
            next_PC = {nPC[31:28], instruction [25:0] , 2'b00};
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

    assign regfile_wa = (sgn_reg_dst == `RegDst_Rt)? instruction [20:16] : instruction [15:11] ;
    assign regfile_we = sgn_reg_write;
    assign regfile_wd = (sgn_mem_toreg == `MemToReg_Mem)? mem_rd : alu_out;

    /// ##### Debug 信息
    ///
    /// DBU 所需要的 status 和指令信息。
    // -----------------------------------
    // DEBUG MESSAGE
    // -----------------------------------

    assign status = {      //
        sgn,               // signal
        next_PC,           // next_pc
        PC,                // pc
        instruction,       // instruction
        regfile_rd1,       // regfile_rd0
        regfile_rd1,       // regfile_rd1
        alu_out,           // alu_out
        mem_rd             // mem_rd
    };                     //

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
                $display("[lw] $%d <- %h ($%d)", instruction [20:16] , alu_out, instruction [25:21] );
                #1 $display("[lw] read from dcache: %h", mem_rd);
            end
        end
    end
    always @(posedge clk) begin
        if(~rst & run) begin
            if(mem_write) begin
                $display("[sw] $%d (%d) -> %h", instruction [20:16], regfile_rd1, alu_out);
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
