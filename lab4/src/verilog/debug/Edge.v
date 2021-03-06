`timescale 1ns / 1ps

/// code(rising_detect) until endmodule
/// 编写上升沿检测电路如下：
module RisingDetect
(
    input  clk, 
    input  rst, 
    input  y, 
    output  rising 
);
    reg pre, current;
    
    always @(posedge clk) begin
        if(rst) begin
            current <= 0;
            pre <= 0;
        end
        else begin
            current <= y;
            pre <= current;
        end
    end
    
    assign rising = (~pre) && current;
endmodule

