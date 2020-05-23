`timescale 1ns / 1ps

module CPU_sim
#(
    @defparam_struct Status_t
    @defparam
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
    wire Word mem_rd_addr = 8;
    @impl CPU cpu ["run", "mem_rd_addr[9:2]"]

endmodule
