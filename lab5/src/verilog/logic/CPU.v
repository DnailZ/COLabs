/// code(cpu) until endmodule
/// CPU设计的代码和思路具体见（https://github.com/DnailZ/COLabs/blob/master/lab3/src/verilog/logic/CPU.v）
module CPU
#(
    parameter STATUS_W = 238,
    parameter SIGNAL_W = 14,
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
    reg ldPC;

    wire ld_jump_pc;
    wire [WIDTH-1:0] jump_pc;
    wire ld_branch_pc;
    wire [WIDTH-1:0] branch_pc;

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
    reg [WIDTH-1:0] fi_ir;
    reg [WIDTH-1:0] fi_npc;
    always @(posedge clk) begin            
        if((rst || clear_fi)) begin        
            fi_ir <= 0;                    
            fi_npc <= 0;                   
        end                                
        else if ((run && ld_fi)) begin     
            fi_ir <= instruction;          
            fi_npc <= (PC + 4);            
        end                                
    end                                    

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

    wire [SIGNAL_W-1:0] sig; // sig 表示 signal
    Control ctrl (
        .clk(clk), // 控制单元需要时钟同步来输出 TCL Console 中的文本调试信息。
        .rst(rst),
        .run(run),
    	.opcode(fi_ir [31:26] ),
    	.sig(sig)
    );
    wire sig_jump;
    wire sig_detect_lduse_rs;
    wire sig_detect_lduse_rt;
    wire [2:0] sig_aluop;
    wire [1:0] sig_alu_src2;
    wire sig_reg_dst;
    wire sig_branch;
    wire sig_mem_read;
    wire sig_mem_write;
    wire sig_reg_write;
    wire sig_mem_toreg;
    assign { sig_jump, sig_detect_lduse_rs, sig_detect_lduse_rt, sig_aluop, sig_alu_src2, sig_reg_dst, sig_branch, sig_mem_read, sig_mem_write, sig_reg_write, sig_mem_toreg} = sig;

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
    	.ra0(fi_ir [25:21] ),
    	.ra1(fi_ir [20:16] ),
    	.rd0(regfile_rd0),
    	.rd1(regfile_rd1),
    	.wa(regfile_wa),
    	.we(regfile_we),
    	.wd(regfile_wd)
    );
    
    wire [15:0] Imm = fi_ir [15:0] ;
    wire [WIDTH-1:0] signed_Imm = {{16{Imm[15]}}, Imm};
    wire [WIDTH-1:0] unsigned_Imm = {{16{1'b0}}, Imm}; // 无符号数扩展

    assign ld_jump_pc = sig_jump; // 当 sig_jump 时，PC的值更新为 jump_pc
    assign jump_pc = {PC[31:28], fi_ir [25:0] , 2'd0};

    // --------- 段寄存器 ---------

    reg clear_id_sig;
    reg [2:0] id_sig_ex_aluop;
    reg [1:0] id_sig_ex_alu_src2;
    reg id_sig_ex_reg_dst;
    reg id_sig_ex_branch;
    reg id_sig_mem_mem_read;
    reg id_sig_mem_mem_write;
    reg id_sig_wb_reg_write;
    reg id_sig_wb_mem_toreg;
    always @(posedge clk) begin                         
        if((rst | clear_id_sig)) begin                  
            id_sig_ex_aluop <= 3'bxxx;                  // aluop (by default)
            id_sig_ex_alu_src2 <= 2'bxx;                // alu_src2 (by default)
            id_sig_ex_reg_dst <= 1'bx;                  // reg_dst (by default)
            id_sig_ex_branch <= 1'b0;                   // branch (by default)
            id_sig_mem_mem_read <= 1'bx;                // mem_read (by default)
            id_sig_mem_mem_write <= 1'b0;               // mem_write (by default)
            id_sig_wb_reg_write <= 1'b0;                // reg_write (by default)
            id_sig_wb_mem_toreg <= 1'bx;                // mem_toreg (by default)
        end                                             
        else if (run) begin                             
            id_sig_ex_aluop <= sig_aluop;               // aluop
            id_sig_ex_alu_src2 <= sig_alu_src2;         // alu_src2
            id_sig_ex_reg_dst <= sig_reg_dst;           // reg_dst
            id_sig_ex_branch <= sig_branch;             // branch
            id_sig_mem_mem_read <= sig_mem_read;        // mem_read
            id_sig_mem_mem_write <= sig_mem_write;      // mem_write
            id_sig_wb_reg_write <= sig_reg_write;       // reg_write
            id_sig_wb_mem_toreg <= sig_mem_toreg;       // mem_toreg
        end                                             
    end                                                 

    reg [WIDTH-1:0] id_reg_a;
    reg [WIDTH-1:0] id_reg_b;
    reg [WIDTH-1:0] id_simm;
    reg [WIDTH-1:0] id_uimm;

    reg [REG_W-1:0] id_rs;
    reg [REG_W-1:0] id_rt;
    reg [REG_W-1:0] id_rd;
    reg [FUNCT_W-1:0] id_funct;

    reg [WIDTH-1:0] id_npc;
    always @(posedge clk) begin             
        if(rst) begin                       
            id_reg_a <= 0;                  
            id_reg_b <= 0;                  
            id_simm <= 0;                   
            id_uimm <= 0;                   
            id_rs <= 0;                     
            id_rt <= 0;                     
            id_rd <= 0;                     
            id_funct <= 0;                  
            id_npc <= 0;                    
        end                                 
        else if (run) begin                 
            id_reg_a <= regfile_rd0;        
            id_reg_b <= regfile_rd1;        
            id_simm <= signed_Imm;          
            id_uimm <= unsigned_Imm;        
            id_rs <= (fi_ir [25:21] );      
            id_rt <= (fi_ir [20:16] );      
            id_rd <= (fi_ir [15:11] );      
            id_funct <= (fi_ir [5:0] );     
            id_npc <= fi_npc;               
        end                                 
    end                                     

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
    // ALU控制单元（https://github.com/DnailZ/COLabs/blob/master/lab3/src/verilog/logic/CPU.v）
    ALU_control aluctrl (
    	.aluop(id_sig_ex_aluop),
    	.funct(id_funct),
    	.alu_m(aluctrl_alu_m)
    );

    reg [WIDTH-1:0] forwarding_a; // 旁路的相关代码见后面 Forwarding 小节
    reg [WIDTH-1:0] forwarding_b;

    wire [WIDTH-1:0] alu_a = forwarding_a;
    reg [WIDTH-1:0] alu_b;
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
        // `ALUSrc1_Shamt: alu_a = instruction [10:6];
        // `ALUSrc1_Mem: alu_a = mem_rd; // especially for accm instruction
        // default: alu_a = 0;
        // endcase
    end

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

    assign ld_branch_pc = id_sig_ex_branch & alu_zf;
    assign branch_pc = id_npc + (id_simm << 2);

    // --------- 段寄存器 ---------

    reg ex_sig_mem_mem_read;
    reg ex_sig_mem_mem_write;
    reg ex_sig_wb_reg_write;
    reg ex_sig_wb_mem_toreg;
    always @(posedge clk) begin                                
        if(rst) begin                                          
            ex_sig_mem_mem_read <= 1'bx;                       // mem_read (by default)
            ex_sig_mem_mem_write <= 1'b0;                      // mem_write (by default)
            ex_sig_wb_reg_write <= 1'b0;                       // reg_write (by default)
            ex_sig_wb_mem_toreg <= 1'bx;                       // mem_toreg (by default)
        end                                                    
        else if (run) begin                                    
            ex_sig_mem_mem_read <= id_sig_mem_mem_read;        // mem_read
            ex_sig_mem_mem_write <= id_sig_mem_mem_write;      // mem_write
            ex_sig_wb_reg_write <= id_sig_wb_reg_write;        // reg_write
            ex_sig_wb_mem_toreg <= id_sig_wb_mem_toreg;        // mem_toreg
        end                                                    
    end                                                        

    reg [WIDTH-1:0] ex_aluout;
    reg [WIDTH-1:0] ex_alu_b;
    wire [REG_W-1:0] id_wb_addr = id_sig_ex_reg_dst == `RegDst_Rd ? id_rd : id_rt;
    reg [REG_W-1:0] ex_wb_addr;
    always @(posedge clk) begin           
        if(rst) begin                     
            ex_aluout <= 0;               
            ex_alu_b <= 0;                
            ex_wb_addr <= 0;              
        end                               
        else if (run) begin               
            ex_aluout <= alu_y;           
            ex_alu_b <= forwarding_b;     
            ex_wb_addr <= id_wb_addr;     
        end                               
    end                                   

    /// ##### MEM 段
    ///
    /// MEM 段，编写 DCache （DCache 用 dist_mem_gen 实现），同时求出 `next_PC`
    // -----------------------------------
    // MEMORY
    // -----------------------------------

    wire mem_write = ex_sig_mem_mem_write & run;
    wire [WIDTH-1:0] mem_rd;
    wire [WIDTH-1:0] mem_addr = ex_aluout;
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

    reg mem_sig_wb_reg_write;
    reg mem_sig_wb_mem_toreg;
    always @(posedge clk) begin                               
        if(rst) begin                                         
            mem_sig_wb_reg_write <= 1'b0;                     // reg_write (by default)
            mem_sig_wb_mem_toreg <= 1'bx;                     // mem_toreg (by default)
        end                                                   
        else if (run) begin                                   
            mem_sig_wb_reg_write <= ex_sig_wb_reg_write;      // reg_write
            mem_sig_wb_mem_toreg <= ex_sig_wb_mem_toreg;      // mem_toreg
        end                                                   
    end                                                       

    reg [WIDTH-1:0] mem_mem_rd;
    reg [WIDTH-1:0] mem_aluout;
    reg [REG_W-1:0] mem_wb_addr;
    always @(posedge clk) begin            
        if(rst) begin                      
            mem_mem_rd <= 0;               
            mem_aluout <= 0;               
            mem_wb_addr <= 0;              
        end                                
        else if (run) begin                
            mem_mem_rd <= mem_rd;          
            mem_aluout <= ex_aluout;       
            mem_wb_addr <= ex_wb_addr;     
        end                                
    end                                    

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
    wire lduse_harzard_rs =  sig_detect_lduse_rs && lduse_harzard_possible && fi_ir [25:21] == id_wb_addr;
    wire lduse_harzard_rt = sig_detect_lduse_rt && lduse_harzard_possible && fi_ir [20:16] == id_wb_addr;
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

    assign status = {      
        sig,               // signal
        next_PC,           // next_pc
        PC,                // pc
        instruction,       // instruction
        regfile_rd1,       // regfile_rd0
        regfile_rd1,       // regfile_rd1
        alu_y,             // alu_out
        mem_rd             // mem_rd
    };                     

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
