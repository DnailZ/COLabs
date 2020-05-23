
@module DisplayClock
#(
    @defparam
) (
    @ninput clk,
    @outputr display
);
    reg [15:0] t;
    
    always@(posedge clk) t = t + 1;
    
    always@(posedge clk) begin
        if(t == 0)
            display <= 1;
        else
            display <= 0;
    end 

endmodule
