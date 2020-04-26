`timescale 1ns / 1ps


/// code(Ctrl) until endmodule
/// 采用三段式写法编写即可
/// 
module Control
#(
    parameter ORDER_DESCEND = 0      // 递增/递减
)                                    
(                                    
    input  clk,                      
    input  rst,                      
                                     
    input  input_en,                 // 输入数据的使能
    output reg [1:0] alu_a_mux,      
    output reg [1:0] alu_b_mux,      
    input  alu_cf,                   
                                     
    output reg  s0_wr_en,            
    output reg  s1_wr_en,            
    output reg  s2_wr_en,            
    output reg  s3_wr_en,            
                                     
    output reg [1:0] s0_mux,         
    output reg [1:0] s1_mux,         
    output reg [1:0] s2_mux,         
    output reg [1:0] s3_mux,         
                                     
    output  done                     // 结束信号
);
    
    localparam STATE_W = 3;
    localparam [STATE_W-1:0] IDLE = 3'b000;
    localparam [STATE_W-1:0] SWAP0_1 = 3'b001;
    localparam [STATE_W-1:0] SWAP2_3 = 3'b010;
    localparam [STATE_W-1:0] SWAP0_2 = 3'b011;
    localparam [STATE_W-1:0] SWAP1_3 = 3'b100;
    localparam [STATE_W-1:0] SWAP1_2 = 3'b101;
    

    // 采用三段式
    reg [STATE_W-1:0] next, current;

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
    // 给出 alu mux 的输出
    always @(*) begin
        alu_a_mux = 0;
        alu_b_mux = 0;
        case(current)
            SWAP0_1: begin
                alu_a_mux = 0; alu_b_mux = 1;
            end
            /// doc_omit begin
            SWAP2_3: begin
                alu_a_mux = 2; alu_b_mux = 3;
            end
            SWAP0_2: begin
                alu_a_mux = 0; alu_b_mux = 2;
            end
            SWAP1_3: begin
                alu_a_mux = 1; alu_b_mux = 3;
            end
            SWAP1_2: begin
                alu_a_mux = 1; alu_b_mux = 2;
            end
            default: ;
            /// doc_omit end
        endcase
    end

    // 给出寄存器mux的输出
    always @(*) begin
        {s0_mux, s1_mux, s2_mux, s3_mux} = 0;
        {s0_wr_en, s1_wr_en, s2_wr_en, s3_wr_en} = 0;
        // ORDER_ASCEND 选择在 alu_cf 为 1 还是为 0 时进行交换
        if (alu_cf == ORDER_DESCEND) begin
            case(current)
                SWAP0_1: begin
                    s0_mux = 1; s1_mux = 0;
                    s0_wr_en = 1; s1_wr_en = 1;
                end
                /// doc_omit begin
                SWAP2_3: begin
                    s2_mux = 3; s3_mux = 2;
                    s2_wr_en = 1; s3_wr_en = 1;
                end
                SWAP0_2: begin
                    s0_mux = 2; s2_mux = 0;
                    s0_wr_en = 1; s2_wr_en = 1;
                end
                SWAP1_3: begin
                    s1_mux = 3; s3_mux = 1;
                    s1_wr_en = 1; s3_wr_en = 1;
                end
                SWAP1_2: begin
                    s1_mux = 2; s2_mux = 1;
                    s1_wr_en = 1; s2_wr_en = 1;
                end
                default: ;
                /// doc_omit end
            endcase
        end
    end

    assign done = (current == IDLE);

    `ifndef SYNTHESIS
    always @(posedge clk) begin
        // 调试输出
        /// doc_omit begin
        case (current)
            IDLE: if(input_en) ;//$display("[Control] IDLE: input_en: %d", input_en);
            SWAP0_1: begin
                // $display("[Control] current SWAP0_1");
            end
            SWAP2_3: begin
                // $display("[Control] current SWAP2_3");
            end
            SWAP0_2: begin
                // $display("[Control] current SWAP0_2");
            end
            SWAP1_3: begin
                // $display("[Control] current SWAP1_3");
            end
            SWAP1_2: begin
                // $display("[Control] current SWAP1_2");
            end
            default;
        endcase
        if(current != IDLE) begin
            // $display("[Control] alu_cf ^ ORDER_ASCEND = %d" , alu_cf ^ ORDER_ASCEND);
        end
        /// doc_omit end
    end
    `endif

endmodule

