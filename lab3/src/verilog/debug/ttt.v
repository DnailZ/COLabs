
module ttt
    (input clk,
    output  reg clk_display
    );
    reg [15:0] t;
    
    always@(posedge clk) t = t + 1;
    
    always@(posedge clk) begin
        if(t == 0)
            clk_display <= 1;
        else
            clk_display <= 0;
    end 

endmodule
