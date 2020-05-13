module Display
(
    output [7:0] led,
    output reg [2:0] an,
    input clk,
    input [31:0] data_display
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
    
    dist_mem_gen_2 Char_LED(
        .a(char),
        .spo(led)
    );
    
endmodule
