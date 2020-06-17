module Display
#(
    parameter SIGNAL_W = 14,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 3
)(
    input  clk, 
    input [WIDTH-1:0] data_display, 
    output [7:0] seg, 
    output reg [2:0] an 
);
    wire clk_display;
    reg [3:0] char;
    
    ttt ttt(
        .clk(clk),
        .clk_display(clk_display)
    );
    
    initial an = 0;
    
    always@(posedge clk) begin
        if(clk_display)
            an <= an + 1;
        else
            an <= an;
    end
    
    always@(*) begin
        case(an)
            0: char = data_display[3:0];
            1: char = data_display[7:4];
            2: char = data_display[11:8];
            3: char = data_display[15:12];
            4: char = data_display[19:16];
            5: char = data_display[23:20];
            6: char = data_display[27:24];
            7: char = data_display[31:28];
            default:char = data_display[3:0];
        endcase
    end
    
    dist_mem_gen_2 Char_seg(
        .a(char),
        .spo(seg)
    );
    
endmodule
