module DBU
    (
        input clk, rst,
        input succ, step,
        input [2:0] sel,
        input m_rf, inc, dec,
        output [7:0] led, 
        output [2:0] an,
        output reg [31:0] data_display,
        output [11:0] seg
    );
    wire step_edg, inc_edg, dec_edg;
    wire [31:0] next_PC, PC, Instruction, rd1, rd2, ALU_result, Mem_rd;
    //reg [31:0] data_display;
    wire [235:0] status;
    wire [32:0] m_data, rf_data;
    reg [7:0] m_rf_addr;
    wire run;

    CPU CPU_debug
    (
        .clk(clk),
        .rst(rst),
        .run(run),
        .m_rf_addr(m_rf_addr),
        .status(status),
        .m_data(m_data),
        .rf_data(rf_data)
    );
    
    assign { next_PC, PC, Instruction, rd1,
                rd2, ALU_result, Mem_rd } = status;
    
    EDG EDG_step
    (
        .y(step),
        .p(step_edg),
        .clk(clk), .rst(rst)
    );
    
    EDG EDG_inc
    (
        .y(inc),
        .p(inc_edg),
        .clk(clk), .rst(rst)
    );
    
    EDG EDG_dec
    (
        .y(dec),
        .p(dec_edg),
        .clk(clk), .rst(rst)
    );
    
    assign run = succ | step_edg;
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            m_rf_addr <= 0;
        else if(inc_edg)
            m_rf_addr <= m_rf_addr + 1;
        else if(dec_edg)
            m_rf_addr <= m_rf_addr - 1;
        else
            m_rf_addr <= m_rf_addr;
    end
    
    always@(*) begin
        case(sel)
        0: begin
            if(m_rf)
                data_display = m_data;
            else
                data_display = rf_data;
        end
        1: data_display = next_PC;
        2: data_display = PC;
        3: data_display = Instruction;
        4: data_display = rd1;
        5: data_display = rd2;
        6: data_display = ALU_result;
        7: data_display = Mem_rd;
        endcase
    end
    
    assign seg = status[235:224]; 
    
    NixieTube_display Display_unit
    (
        .led(led),
        .an(an),
        .clk(clk),
        .data_display(data_display)
    );
    
endmodule
