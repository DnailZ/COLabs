`timescale 1ns / 1ps

/// code(regfile) until endmodule
/// 寄存器文件描述如下
module RegFile
#(
    parameter WIDTH = 32,
    parameter REGFILE_WIDTH = 5
)
(
    input  clk, 
    input  rst, 

    input [REGFILE_WIDTH-1:0] ra0,      // 读端口输入
    output [WIDTH-1:0] rd0,             // 读端口输出
                                        
    input [REGFILE_WIDTH-1:0] ra1,      // 读端口输入
    output [WIDTH-1:0] rd1,             // 读端口输出
                                        
    input [REGFILE_WIDTH-1:0] wa,       // 写端口输入
    input  we,                          // 写端口使能
    input [WIDTH-1:0] wd                //	写端口输入数据
);
    localparam REGFILE_SIZE = (1 << REGFILE_WIDTH);
    reg [WIDTH-1:0] registers [REGFILE_SIZE-1:0];
    
    initial
        $readmemh("Y://Course/COLabs/lab2/src/marilog/regfile_data.vec", registers);
    
    assign rd0 = registers[ra0];
    assign rd1 = registers[ra1];
    
    always@(posedge clk)begin
        if(we) begin
            registers[wa] <= wd;
        end
    end
endmodule

