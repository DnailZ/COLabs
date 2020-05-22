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
        #2 rst = 0;
    end
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial #20 run = 1;

    integer i;
    reg [7:0] addr;
    @impl CPU cpu ["run", "2"]

endmodule
