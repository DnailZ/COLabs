`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/04 12:35:49
// Design Name: 
// Module Name: DM_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DM_sim();
    reg [3:0] a;
    reg [7:0] d;
    reg clk;
    reg we;
    wire [7:0] spo;
    
    dist_mem_gen_1 dist_mem
    (
        .a(a),
        .d(d),
        .clk(clk),
        .we(we),
        .spo(spo)
    );
    
    initial clk <= 1;
    always #5 clk <= ~clk;
    
    reg [8*14:1] stringvar; 
    initial begin
    a <= 0; d <= 0; we <= 0;
    #10 a <= 3; we <= 0;                stringvar = "read 3";
    #10 a <= 3; d <= 8'hAA; we <= 1;    stringvar = "write 3";
    #10 a <= 3; we <= 0;                stringvar = "read 3";
    #10 a <= 1; d <= 8'hAA; we <= 1;    stringvar = "write 1";
    #10 a <= 3; we <= 0;                stringvar = "read 3";
    #10 a <= 1; we <= 0;                stringvar = "read 1";
    end
    
endmodule
