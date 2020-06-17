`timescale 1ns / 1ps

module CPU_sim
#(
    parameter STATUS_W = 238,
    parameter SIGNAL_W = 14,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 3
)();
    reg clk, rst;
    reg run = 0;
    
    initial begin
        rst = 1;
        #10 rst = 0;
    end
    
    initial clk = 1;
    always #5 clk = ~clk;
    
    initial #20 run = 1;

    integer i;
    reg [7:0] addr;
    wire [STATUS_W-1:0] cpu_status;
    wire [WIDTH-1:0] cpu_m_data;
    wire [WIDTH-1:0] cpu_rf_data;
    
    CPU cpu (
    	.clk(clk),
    	.rst(rst),
    	.run(run),
    	.m_rf_addr(9),
    	.status(cpu_status),
    	.m_data(cpu_m_data),
    	.rf_data(cpu_rf_data)
    );

endmodule
