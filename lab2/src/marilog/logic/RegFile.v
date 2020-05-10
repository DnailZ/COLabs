`timescale 1ns / 1ps

/// code(regfile) until endmodule
/// 寄存器文件描述如下
@module RegFile
#(
    parameter WIDTH = 32,
    parameter REGFILE_WIDTH = 5
)
(
    @ninput clk,
    @ninput rst,

    @input ra0 RegId, //[ 读端口输入
    @output rd0 Word, //| 读端口输出

    @input ra1 RegId, 	//| 读端口输入
    @output rd1 Word,//| 读端口输出

    @input wa RegId, //| 写端口输入
    @input we,   //| 写端口使能
    @input wd Word  //]	写端口输入数据
);
    localparam REGFILE_SIZE = (1 << REGFILE_WIDTH);
    reg Word registers [REGFILE_SIZE-1:0];
    
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

