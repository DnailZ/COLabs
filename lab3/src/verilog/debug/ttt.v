
module DisplayClock
#(
    parameter SIGNAL_W = 13,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 3
) (
    input  clk, 
    output reg  display 
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
