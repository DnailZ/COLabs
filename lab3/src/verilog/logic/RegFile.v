`timescale 1ns / 1ps

/// code(regfile) until endmodule
/// 寄存器文件描述如下
module RegFile
#(
    parameter SIGNAL_W = 11,
    parameter REG_W = 5,
    parameter WIDTH = 32,
    parameter FUNCT_W = 6,
    parameter OPCODE_W = 6,
    parameter ALUOP_W = 3
)
(
    input  clk, 
    input  rst, 

    input [REG_W-1:0] ra0,       // 读端口输入
    output [WIDTH-1:0] rd0,      // 读端口输出
                                 
    input [REG_W-1:0] ra1,       // 读端口输入
    output [WIDTH-1:0] rd1,      // 读端口输出
                                 
    input [REG_W-1:0] wa,        // 写端口输入
    input  we,                   // 写端口使能
    input [WIDTH-1:0] wd,        //	写端口输入数据

    input [REG_W-1:0] m_rf_addr, 
    output [WIDTH-1:0] rf_data 
);
    localparam REGFILE_SIZE = (1 << REG_W);
    reg [WIDTH-1:0] registers [REGFILE_SIZE-1:0];
    
    initial
        $readmemh( "Y://Course/COLabs/lab3/test/RegFile_init(1).vec", registers);
    assign rd0 = registers[ra0];
    assign rd1 = registers[ra1];

    assign rf_data = registers[m_rf_addr];
    
    always@(posedge clk)begin
        if(we && wa != 0) begin
            registers[wa] <= wd;
        end
    end

    `ifndef SYSTHESIS
    always @(posedge clk) begin
        if(~rst) begin
            if(we) begin
                if(wa == 0) $display("[regfile] attempt write to $0", registers[wa], wa, wd);
                $display("[regfile] write %h at %h to %h", registers[wa], wa, wd);
            end
        end
    end
    `endif

endmodule

