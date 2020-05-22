`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/04 12:35:49
// Design Name: 
// Module Name: BM_sim
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


module BM_sim();
    reg clka;
    reg wea;
    reg [3:0] addra;
    reg [7:0] dina;
    wire [7:0] douta;
    reg ena;

    blk_mem_gen_0 BM(
        .clka(clka),   
        .wea(wea),     
        .addra(addra), 
        .dina(dina),   
        .douta(douta), 
        .ena(ena)
    );
    
    initial clka <= 1;
    always #5 clka <= ~clka;
    
    initial ena = 1;

    reg [8*14:1] stringvar; 
    initial begin
    addra <= 0; dina <= 0; wea <= 0;
    #10 addra <= 3; wea <= 0;                stringvar = "read 3";
    #10 addra <= 3; dina <= 8'hAA; wea <= 1; stringvar = "write 3";
    #10 addra <= 3; wea <= 0;                stringvar = "read 3";
    #10 addra <= 1; dina <= 8'hAA; wea <= 1; stringvar = "write 1";
    #10 addra <= 3; wea <= 0;                stringvar = "read 3";
    #10 addra <= 1; wea <= 0;                stringvar = "read 1";
    end

endmodule
