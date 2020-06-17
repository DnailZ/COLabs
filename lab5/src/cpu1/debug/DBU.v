/// code(dbu) until endmodule
@module DBU
#(
    @defparam_struct Status_t
    @defparam
) (
    @ninput clk,
    @ninput rst,
    @Input succ,
    @Input step,
    @Input sel [2:0],
    @Input m_rf,
    @Input inc,
    @Input dec,
    @output seg [7:0],
    @output an [2:0],
    @outputr data_display [31:0],
    @outputr led [16:0]
);
    // 本来是需要对这些信号做除抖动的，这里为了仿真暂时省略
    @inst RisingDetect step ["step"]
    @inst RisingDetect inc ["inc"]
    @inst RisingDetect dec ["dec"]

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
    wire Status status;
    wire Word m_data, rf_data;
    CPU CPU_debug (
        .clk(clk),
        .rst(rst),
        .run(run),
        .m_rf_addr(m_rf_addr),
        .status(status),
        .m_data(m_data),
        .rf_data(rf_data)
    );

    @decompose Status_t status

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
    @impl Display display ["data_display"]
    
endmodule
