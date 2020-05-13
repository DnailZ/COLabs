`timescale 1ns / 1ps

@module Control
#(
    @defparam
) (
    @ninput clk,
    @ninput rst,
    @Input opcode [5:0],
    @Outputr sgn Signal // signals
);
@py
def CtrlUnitLogic():
    global spaces
    for name in instructions:
        opcode, signal = instructions[name]
        spaces = spaces[:-4]
        wr("{opcode}:")
        spaces += "    "
        slet("Signal_t", "sgn", signal)
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
        default:;
        endcase
    end

    `ifndef SYSTHESIS
    always @(posedge clk) begin
        if(~rst)
            case(opcode)
            @print_opcode
            default:;
            endcase
    end
    `endif
    
endmodule
