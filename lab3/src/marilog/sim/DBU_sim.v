`timescale 1ns / 1ps

module DBU_sim();
    reg clk, rst;
    reg succ, step;
    reg [2:0] sel;
    reg m_rf, inc, dec;
    wire [7:0] led;
    wire [2:0] an;
    wire [11:0] seg;
    wire [31:0] data_display;
    
    DBU DBU_test
    (
        .clk(clk),
        .rst(rst),
        .succ(succ),
        .step(step),
        .sel(sel),
        .m_rf(m_rf),
        .inc(inc),
        .dec(dec),
        .led(led), 
        .an(an),
        .data_display(data_display),
        .seg(seg)
    );
    
    initial begin
        rst = 1;
        #3 rst = 0;
    end
    
    initial  clk = 0;
    always #5 clk = ~clk;
    
    initial sel = 0;
    always #10 sel = sel + 1;
    
    initial begin
        inc = 0; dec = 0;
    end
    
    initial begin
        m_rf = 0;
        #5 m_rf = ~m_rf;
    end
    
    initial begin
        succ = 0; step = 1;
    end
    
    always #40 step = ~step;
    
endmodule
