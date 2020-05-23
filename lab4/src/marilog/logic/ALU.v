`timescale 1ns/1ps

/// code(ALU_MOD) until endmodule
/// 按照要求编写ALU模块
/// 
/// 首先定义 ALU 模块的接口
/// 
@module ALU
#(
    @defparam
) (
    @outputr y Word,  //[ 输出
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

    wire [WIDTH:0] add_result = a + b;
    wire [WIDTH:0] sub_result = a - b;

    always @(*) begin
        {y, zf, cf, of} = 0; //[ 防止综合出锁存器
        case(m)
            `ALU_ADD: begin
                {cf, y} = add_result; //| 求和，cf 是有符号数加法运算中多出来的一位，可以用于有符号数比较
                of = (~a_msb & ~b_msb &  y_msb) //| 溢出判断
                    | (a_msb &  b_msb & ~y_msb);
                zf = ~(|y);  //| 0判断
            end
            `ALU_SUB: begin
                {cf, y} = sub_result;
                of = (~a_msb &  b_msb &  y_msb)
                   | ( a_msb & ~b_msb & ~y_msb);//| 与上面相似
                zf = ~ (|y);
            end
            `ALU_AND: y = a & b;
            `ALU_OR: y = a | b;
            `ALU_XOR: y = a ^ b;
            `ALU_NOR: y = ~(a | b);
            `ALU_SHL: y = b << a;
            `ALU_SHRL: y = b >> a;
            `ALU_SHRA: y = $unsigned($signed(b) >>> a);
            `ALU_LU: y = {b[15:0], 16'b0};
            default: ; //] 这里可以留空
        endcase
    end
    //codeend

    /// doc_omit end


endmodule

