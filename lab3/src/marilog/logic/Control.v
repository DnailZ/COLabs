`timescale 1ns / 1ps

/// code(ctrl) until endmodule
/// ##### 控制单元
@module Control
#(
    /// doc_omit begin
    @defparam
    /// doc_omit end
) (
    @ninput clk,
    @ninput rst,
    @ninput run,
    @Input opcode [5:0],
    @Outputr sgn Signal // signals
);

@py
def CtrlUnitLogic():
    global spaces
    for i, name in enumerate(instructions):
        if i == 2:
            wr("/// doc_omit begin")
        opcode, signal = instructions[name]
        spaces = spaces[:-4]
        wr("{opcode}:")
        print(signal)
        spaces += "    "
        slet("Signal_t", "sgn", signal)
    spaces = spaces[:-4]
    wr("/// doc_omit end")
    wr("default:")
    spaces += "    "
    slet("Signal_t", "sgn", "dict()")
def print_opcode():
    global instructions
    print(instructions)
    for name in instructions:
        opcode, signal = instructions[name]
        wr('''{opcode}: $display("[ctrl] opcode : {name}");''')
@end
    always @(*) begin
        sgn = 0;
        case(opcode)
        @CtrlUnitLogic
        endcase
    end

    `ifndef SYSTHESIS
    // 调试输出
    always @(posedge clk) begin
        if(~rst & run) begin
            case(opcode)
            @print_opcode
            default:;
            endcase
        end
    end
    `endif
    
endmodule
