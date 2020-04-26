`timescale 1ns / 1ps

@py
rep["State"] = "[STATE_W-1:0]"
rep["Muxnum"] = "[MUX_NUM-1:0]"
def paramenters():
    wr("""
localparam STATE_W = 3;
localparam [STATE_W-1:0] IDLE = 3'b000;
localparam [STATE_W-1:0] SWAP0_1 = 3'b001;
localparam [STATE_W-1:0] SWAP2_3 = 3'b010;
localparam [STATE_W-1:0] SWAP0_2 = 3'b011;
localparam [STATE_W-1:0] SWAP1_3 = 3'b100;
localparam [STATE_W-1:0] SWAP1_2 = 3'b101;
""")
@end

/// code(Ctrl) until endmodule
/// 采用三段式写法编写即可
/// 
@module Control
#(
    parameter ORDER_DESCEND = 0 //[ 递增/递减
)
(
    @ninput clk,
    @ninput rst,

    @ninput input_en,   //| 输入数据的使能
    @outputr alu_a_mux [1:0],
    @outputr alu_b_mux [1:0],
    @ninput alu_cf,
    
    @outputr s0_wr_en,
    @outputr s1_wr_en,
    @outputr s2_wr_en,
    @outputr s3_wr_en,

    @outputr s0_mux [1:0],
    @outputr s1_mux [1:0],
    @outputr s2_mux [1:0],
    @outputr s3_mux [1:0],

    @noutput done //] 结束信号
);
    @paramenters

    // 采用三段式
    reg State next, current;

    always @(*) begin
        next = IDLE;
        case(current)
            IDLE: begin
                if(input_en) next = SWAP0_1;
                else next = IDLE;
            end
            default: next = current + 1; // 顺序运行即可
        endcase
    end

    always@(posedge clk or negedge rst)begin
        if(rst) begin
            current <= IDLE;
        end
        else begin
            current <= next;
        end
    end
@py
def alu_mux(a,b):
    wr('''SWAP{a}_{b}: begin
    alu_a_mux = {a}; alu_b_mux = {b};
end''')
@end
    // 给出 alu mux 的输出
    always @(*) begin
        alu_a_mux = 0;
        alu_b_mux = 0;
        case(current)
            @alu_mux 0 1
            /// doc_omit begin
            @alu_mux 2 3
            @alu_mux 0 2
            @alu_mux 1 3
            @alu_mux 1 2
            default: ;
            /// doc_omit end
        endcase
    end
@py
def mux_swap(a,b):
    wr('''SWAP{a}_{b}: begin
    s{a}_mux = {b}; s{b}_mux = {a};
    s{a}_wr_en = 1; s{b}_wr_en = 1;
end''')
@end

    // 给出寄存器mux的输出
    always @(*) begin
        {s0_mux, s1_mux, s2_mux, s3_mux} = 0;
        {s0_wr_en, s1_wr_en, s2_wr_en, s3_wr_en} = 0;
        // ORDER_ASCEND 选择在 alu_cf 为 1 还是为 0 时进行交换
        if (alu_cf == ORDER_DESCEND) begin
            case(current)
                @mux_swap 0 1
                /// doc_omit begin
                @mux_swap 2 3
                @mux_swap 0 2
                @mux_swap 1 3
                @mux_swap 1 2
                default: ;
                /// doc_omit end
            endcase
        end
    end

    assign done = (current == IDLE);

    `ifndef SYNTHESIS
@py
def test(a,b):
    wr('''SWAP{a}_{b}: begin
    // $display("[Control] current SWAP{a}_{b}");
end''')
@end
    always @(posedge clk) begin
        // 调试输出
        /// doc_omit begin
        case (current)
            IDLE: if(input_en) ;//$display("[Control] IDLE: input_en: %d", input_en);
            @test 0 1
            @test 2 3
            @test 0 2
            @test 1 3
            @test 1 2
            default;
        endcase
        if(current != IDLE) begin
            // $display("[Control] alu_cf ^ ORDER_ASCEND = %d" , alu_cf ^ ORDER_ASCEND);
        end
        /// doc_omit end
    end
    `endif

endmodule

