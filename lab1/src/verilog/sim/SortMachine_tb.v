
/// code(tb_SortMachine) until endmodule
/// 接下来对上述排序电路进行仿真。（综合使用文本输出和波形两种方式）
module tb_SortMachine;
    /// doc_omit begin
    parameter WIDTH = 32;
    reg clk = 1;
    always #5 clk = ~clk;

    reg rst = 1;
    initial begin
       #10 rst = 0; 
    end

    reg input_en = 0;
    reg [WIDTH-1:0] sort_r0, sort_r1, sort_r2, sort_r3;

    wire [WIDTH-1:0] sort_s0;
    wire [WIDTH-1:0] sort_s1;
    wire [WIDTH-1:0] sort_s2;
    wire [WIDTH-1:0] sort_s3;
    wire  sort_done;
    SortMachine#(.WIDTH(WIDTH)) sort (
    	.clk(clk),
    	.rst(rst),
    	.input_en(input_en),
    	.i0(sort_r0),
    	.i1(sort_r1),
    	.i2(sort_r2),
    	.i3(sort_r3),
    	.s0(sort_s0),
    	.s1(sort_s1),
    	.s2(sort_s2),
    	.s3(sort_s3),
    	.done(sort_done)
    );
    /// doc_omit end

    always @(posedge clk) begin
        // 当之前的工作完成后执行（此处done同ready）
        if(sort_done) begin
            // 输出上次随机数的结果
            $display("[**] i0=%2d i1=%2d i2=%2d i3=%2d s0=%2d s1=%2d s2=%2d s3=%2d",
                sort_r0,sort_r1,sort_r2,sort_r3,
                sort_s0,sort_s1,sort_s2,sort_s3
            );
            // 生成随机数
            sort_r0 = $random % 60;
            sort_r1 = $random % 60;
            sort_r2 = $random % 60;
            sort_r3 = $random % 60;
            // 此时打开使能，实现握手
            input_en = 1;
        end
    end
endmodule // SortMachine   
