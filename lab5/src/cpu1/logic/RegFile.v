`timescale 1ns / 1ps

/// code(regfile) until endmodule
/// 寄存器文件描述如下
@module RegFile
#(
    @defparam
)
(
    @ninput clk,
    @ninput rst,

    @Input ra0 RegId, //[ 读端口输入
    @output rd0 Word, //| 读端口输出

    @Input ra1 RegId, 	//| 读端口输入
    @output rd1 Word,//| 读端口输出

    @input wa RegId, //| 写端口输入
    @input we,   //| 写端口使能
    @input wd Word,  //]	写端口输入数据

    @ninput m_rf_addr RegId,
    @noutput rf_data Word
);
    localparam REGFILE_SIZE = (1 << REG_W);
    reg Word registers [REGFILE_SIZE - 1:0];
    
    initial
        $readmemh(`REGFILE_PATH , registers);
    assign rd0 = registers[ra0];
    assign rd1 = registers[ra1];

    assign rf_data = registers[m_rf_addr];
    
    always@(negedge clk)begin
        if(we && wa != 0) begin
            registers[wa] <= wd;
        end
    end

    `ifndef SYSTHESIS
    always @(negedge clk) begin
        if(~rst) begin
            if(we) begin
                if(wa == 0) $display("[regfile] attempt write to $0", registers[wa], wa, wd);
                $display("[regfile] write %h: %h -> %h", wa, registers[wa], wd);
            end
        end
    end
    `endif

endmodule

