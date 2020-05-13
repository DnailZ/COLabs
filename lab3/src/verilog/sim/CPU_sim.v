`timescale 1ns / 1ps

module CPU_sim();
    localparam WIDTH = 32;
    reg clk, rst;
    reg run;
    
    initial begin
        rst = 1;
        #2 rst = 0;
    end
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial #20 run = 1;

    integer i;
    reg [7:0] addr;
    wire [235:0] cpu_status;
    wire [WIDTH-1:0] cpu_m_data;
    wire [WIDTH-1:0] cpu_rf_data;
    CPU cpu (
    	.clk(clk),
    	.rst(rst),
    	.run(run),
    	.m_rf_addr(2),
    	.status(cpu_status),
    	.m_data(cpu_m_data),
    	.rf_data(cpu_rf_data)
    );

endmodule
