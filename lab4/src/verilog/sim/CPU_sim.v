`timescale 1ns / 1ps

module CPU_sim
#(
    parameter STATUS_W = 247,
    parameter SIGNAL_W = 23,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 4
)();
    reg clk, rst;
    reg run;
    
    initial begin
        rst = 1;
        #10 rst = 0;
    end
    
    initial clk = 1;
    always #5 clk = ~clk;
    
    initial  run = 1;
    wire [WIDTH-1:0] mem_rd_addr = 8;
    wire [STATUS_W-1:0] cpu_status;
    wire [WIDTH-1:0] cpu_m_data;
    wire [WIDTH-1:0] cpu_rf_data;
    
    CPU cpu (
    	.clk(clk),
    	.rst(rst),
    	.run(run),
    	.m_rf_addr(mem_rd_addr[9:2]),
    	.status(cpu_status),
    	.m_data(cpu_m_data),
    	.rf_data(cpu_rf_data)
    );

endmodule
