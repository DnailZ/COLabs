`timescale 1ns / 1ps

/// code(fifo) until endmodule
/// 接下来编写队列模块
@module FIFO
#(
    parameter WIDTH = 8,
    parameter MEM_ADDR_WIDTH = 4
)
(
    @ninput clk,
    @ninput rst,    

    @Input en_in,    //[ 入队使能信号（同步上升沿有效）
    @Input din Word,//| 入队数据

    @Input en_out,	//| 出队使能信号（同步上升沿有效）
    @output dout Word, //| 出队数据

    @outputr count [MEM_ADDR_WIDTH:0] //] 队列元素个数
);
    reg Addr head, tail;
    wire push;

    // 上升信号检测电路
    @inst rising_detect en_in ["en_in"]
    @inst rising_detect en_out ["en_out"]
    
    dist_mem_gen_0 dist_mem_gen_0 (
        .a(head),
        .d(din),
        .dpra(tail),
        .clk(clk),
        .dpo(dout),
        .we(push)
    );
    
    // 计算队列元素个数
    always@(*) begin
        if(full)
            count = 16;
        else if(head < tail)
            count = 16 + head - tail;
        else
            count = head - tail;
    end

    // push表示何时入队
    assign push = en_in_rising && !full;
    
    // full 信号用来在 head == tail 时区分空和满两种情况。
    reg full;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            head <= 0;
            full <= 0;
            tail <= 0;
        end
        else if(en_out_rising && count != 0) begin
            // 出队
            tail <= tail + 1;
            if(full)
                full <= 0;
        end
        else if(en_in_rising && !full) begin
            // 入队
            head <= head + 1;
            if(count == 15)
                full <= 1;
        end
    end
    
endmodule
