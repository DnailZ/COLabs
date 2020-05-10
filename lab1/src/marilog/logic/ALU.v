`timescale 1ns/1ps

/// code(ALU_MOD) until endmodule
/// 按照要求编写ALU模块
/// 
/// 首先定义 ALU 模块的接口
/// 
@module ALU
#(
    parameter WIDTH = 32,
    parameter OP_ADD = 3'b000,  //[ 这里将所有ALU符号作为parameter           
    parameter OP_SUB = 3'b001,
    parameter OP_AND = 3'b010,
    parameter OP_OR = 3'b011,
    parameter OP_XOR = 3'b100,
    parameter ALUOP_W = 3   //| ALU 字的长度（想想回头写Cpu的时候怎么都得用4位的）
) (
    @outputr y Word,  //| 输出
    @outputr zf,  //| 0 flag
    @outputr cf,  //| 进位 flag (在不溢出的情况下，表示和/差的正负)
    @outputr of, 	//| 溢出 flag
    @Input a Word,   //| 输入
    @Input b Word,   //| 输入
    @Input m ALUop  //] aluop
);
    // ALU组合逻辑
    /// doc_omit begin
    /// code(ALU_always) until codeend
    /// 编写always block（注意，此处的 `{y, zf, cf, of} = 0;` 可以有效地防止出现综合出锁存器）
    wire a_msb = a[WIDTH-1];
    wire b_msb = b[WIDTH-1];
    wire y_msb = y[WIDTH-1];
    always @(*) begin
        {y, zf, cf, of} = 0; //[ 防止综合出锁存器
        case(m)
            OP_ADD: begin
                {cf, y} = a + b; //| 求和，cf 是有符号数加法运算中多出来的一位，可以用于有符号数比较
                of = (~a_msb & ~b_msb &  y_msb) //| 溢出判断
                    | (a_msb &  b_msb & ~y_msb);
                zf = ~(|y);  //| 0判断
            end
            OP_SUB: begin
                {cf, y} = {a_msb, a} - {b_msb, b};
                of = (~a_msb &  b_msb &  y_msb)
                   | ( a_msb & ~b_msb & ~y_msb);//| 与上面相似
                zf = ~ (|y);
            end
            OP_AND: y = a & b;
            OP_OR: y = a | b;
            OP_XOR: y = a ^ b;
            default: ; //] 这里可以留空
        endcase
    end
    //codeend

    /// doc_omit end


endmodule
@py
print(module_dict["ALU"])
@end

