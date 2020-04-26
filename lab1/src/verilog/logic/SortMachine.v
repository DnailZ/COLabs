`timescale 1ns / 1ps

/// code(datapath) until endmodule
/// 首先考虑数据通路
module SortMachine
#(parameter WIDTH = 32)
(
    input  clk, 
    input  rst, 

    input  input_en,                // 输入使能信号
    input [WIDTH-1:0] i0,           
    input [WIDTH-1:0] i1,           
    input [WIDTH-1:0] i2,           
    input [WIDTH-1:0] i3,           
                                    
    output reg [WIDTH-1:0] s0,      
    output reg [WIDTH-1:0] s1,      
    output reg [WIDTH-1:0] s2,      
    output reg [WIDTH-1:0] s3,      
    output  done                    // rdy完成信号
);
    
    localparam ALUOP_W = 3;

    // ALU单元
    reg [WIDTH-1:0] alu_a, alu_b;
    wire [ALUOP_W-1:0] alu_m;
    wire [WIDTH-1:0] alu_y;
    wire  alu_zf;
    wire  alu_cf;
    wire  alu_of;
    ALU#(.WIDTH(WIDTH)) alu (
    	.a(alu_a),
    	.b(alu_b),
    	.m(alu_m),
    	.y(alu_y),
    	.zf(alu_zf),
    	.cf(alu_cf),
    	.of(alu_of)
    );
    assign alu_m = alu.OP_SUB;

    // 控制单元
    wire [1:0] ctrl_alu_a_mux;
    wire [1:0] ctrl_alu_b_mux;
    wire  ctrl_s0_wr_en;
    wire  ctrl_s1_wr_en;
    wire  ctrl_s2_wr_en;
    wire  ctrl_s3_wr_en;
    wire [1:0] ctrl_s0_mux;
    wire [1:0] ctrl_s1_mux;
    wire [1:0] ctrl_s2_mux;
    wire [1:0] ctrl_s3_mux;
    Control#(.WIDTH(WIDTH)) ctrl (
    	.clk(clk),
    	.rst(rst),
    	.input_en(input_en),
    	.alu_cf(alu_cf),
    	.done(done),
    	.alu_a_mux(ctrl_alu_a_mux),
    	.alu_b_mux(ctrl_alu_b_mux),
    	.s0_wr_en(ctrl_s0_wr_en),
    	.s1_wr_en(ctrl_s1_wr_en),
    	.s2_wr_en(ctrl_s2_wr_en),
    	.s3_wr_en(ctrl_s3_wr_en),
    	.s0_mux(ctrl_s0_mux),
    	.s1_mux(ctrl_s1_mux),
    	.s2_mux(ctrl_s2_mux),
    	.s3_mux(ctrl_s3_mux)
    );

    // 为控制单元提供一个 ctrl_alu_a_mux, ctrl_alu_b_mux 用于选择alu的输入
    always @(*) begin
        alu_a = 0;
        alu_b = 0;
        case(ctrl_alu_a_mux)
            0: alu_a = s0; // 算法只需要使用部分选择器，这样可以优化电路
            1: alu_a = s1;
            2: alu_a = s2;
            default:;
        endcase
        case(ctrl_alu_b_mux)
            1: alu_b = s1; // 算法只需要使用部分选择器，这样可以优化电路
            2: alu_b = s2;
            3: alu_b = s3;
            default:;
        endcase
    end

    // 实现 s0-s3 的选择器，同样地，不需要实现全部的，可以留一部分供电路优化
    always @(posedge clk or negedge rst) begin
        if(rst) 
            {s3, s2, s1, s0} <= 0;
        else if(input_en && done) 
            {s3, s2, s1, s0} <= {i3, i2, i1, i0};
        else begin
            if(ctrl_s0_wr_en)
                case(ctrl_s0_mux)
                    1: s0 <= s1;
                    2: s0 <= s2;
                    default: ;
                endcase
            /// doc_omit begin
            if(ctrl_s1_wr_en)
                case(ctrl_s1_mux)
                    0: s1 <= s0;
                    2: s1 <= s2;
                    3: s1 <= s3;
                    default: ;
                endcase
            if(ctrl_s2_wr_en)
                case(ctrl_s2_mux)
                    0: s2 <= s0;
                    1: s2 <= s1;
                    3: s2 <= s3;
                    default: ;
                endcase
            if(ctrl_s3_wr_en)
                case(ctrl_s3_mux)
                    1: s3 <= s1;
                    2: s3 <= s2;
                    default: ;
                endcase
            /// doc_omit end
        end
    end

    `ifndef SYNTHESIS
        // 在仿真的情况下，输出调试信息（作为波形的辅助、测试代码正确性）
        always @(posedge clk) begin
            if(!done)
                $display("[SortMachine] {s0=%2d, s1=%2d, s2=%2d, s3=%2d}", s0, s1, s2, s3);
        end
    `endif
    
endmodule
