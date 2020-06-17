/// code(dbu) until endmodule
module DBU
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
    input  succ, 
    input  step, 
    input [2:0] sel, 
    input  m_rf, 
    input  inc, 
    input  dec, 
    output [7:0] seg, 
    output [2:0] an, 
    output reg [31:0] data_display, 
    output reg [16:0] led 
);
    // 本来是需要对这些信号做除抖动的，这里为了仿真暂时省略
    wire  step_rising;
    RisingDetect step_inst (
    	.clk(clk),
    	.rst(rst),
    	.y(step),
    	.rising(step_rising)
    );
    wire  inc_rising;
    RisingDetect inc_inst (
    	.clk(clk),
    	.rst(rst),
    	.y(inc),
    	.rising(inc_rising)
    );
    wire  dec_rising;
    RisingDetect dec_inst (
    	.clk(clk),
    	.rst(rst),
    	.y(dec),
    	.rising(dec_rising)
    );

    // m_rf_addr 的增加和减少。
    reg [7:0] m_rf_addr;
    always@(posedge clk or posedge rst) begin
        if(rst)
            m_rf_addr <= 0;
        else if(inc_rising)
            m_rf_addr <= m_rf_addr + 1;
        else if(dec_rising)
            m_rf_addr <= m_rf_addr - 1;
        else
            m_rf_addr <= m_rf_addr;
    end

    wire run = succ | step_rising;
    wire [STATUS_W-1:0] status;
    wire [WIDTH-1:0] m_data, rf_data;
    CPU CPU_debug (
        .clk(clk),
        .rst(rst),
        .run(run),
        .m_rf_addr(m_rf_addr),
        .status(status),
        .m_data(m_data),
        .rf_data(rf_data)
    );

    wire [13:0] status_signal;
    wire [31:0] status_next_pc;
    wire [31:0] status_pc;
    wire [31:0] status_instruction;
    wire [31:0] status_regfile_rd0;
    wire [31:0] status_regfile_rd1;
    wire [31:0] status_alu_out;
    wire [31:0] status_mem_rd;
    assign { status_signal, status_next_pc, status_pc, status_instruction, status_regfile_rd0, status_regfile_rd1, status_alu_out, status_mem_rd} = status;

    // data_display 的选择。
    always@(*) begin
        case(sel)
            0: begin
                if(m_rf)
                    data_display = m_data;
                else
                    data_display = rf_data;
            end
            1: data_display = status_next_pc;
            2: data_display = status_pc;
            3: data_display = status_instruction;
            4: data_display = status_regfile_rd0;
            5: data_display = status_regfile_rd1;
            6: data_display = status_alu_out;
            7: data_display = status_mem_rd;
        endcase
    end
    
    // LED 输出
    always @(*) begin
        if(sel == 0) 
            led = m_rf_addr;
        else led = status_signal;
    end
    
    // 管子输出
    
    Display display (
    	.clk(clk),
    	.seg(seg),
    	.an(an),
    	.data_display(data_display)
    );
    
endmodule
