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
    @Outputr sig Signal // signals
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
        slet("Signal_t", "sig", signal)
    spaces = spaces[:-4]
    wr("/// doc_omit end")
    wr("default:")
    spaces += "    "
    slet("Signal_t", "sig", "dict()")
def print_opcode():
    global instructions
    for name in instructions:
        opcode, signal = instructions[name]
        wr('''{opcode}: $display("[ctrl] opcode : {name}");''')
def str_output():
    global instructions
    for name in instructions:
        opcode, signal = instructions[name]
        name = name[:-12]
        wr('''{opcode}: instruction_name = "{name}";''')
@end
    always @(*) begin
        sig = 0;
        case(opcode)
            @CtrlUnitLogic
        endcase
    end

    `ifndef SYSTHESIS
    reg [40:0] instruction_name;
    always @(*) begin
        case(opcode)
            @str_output
        endcase
    end
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
