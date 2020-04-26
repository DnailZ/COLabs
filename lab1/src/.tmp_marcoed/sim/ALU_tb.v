
module tb_ALU;

    parameter WIDTH = 3;
    parameter ALUOP_W = 3;

    reg [WIDTH-1:0] alu_a, alu_b;
    reg [ALUOP_W-1:0] alu_m;

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
    
    /// code(tb_ALU2)
    /// 不过波形图不便于观察一些细节，这里还通过 `$display`输出进行了测试
    ///
    /// 编写的输出测试代码如下
    task show_add();
    begin
        $display("(+) a:%d b:%d m:%d y:%d zf:%d cf:%d of:%d",alu_a,alu_b,alu_m,alu_y,alu_zf,alu_cf,alu_of);
    end
    endtask

    task show_sub();
    begin
        $display("(-) a:%d b:%d m:%d y:%d zf:%d cf:%d of:%d",alu_a,alu_b,alu_m,alu_y,alu_zf,alu_cf,alu_of);
    end
    endtask
    /// 测试结果如图：
    ///
    /// ![](lab1.assets/console.png)
    ///

    /// code(tb_ALU)
    /// 这里，对 ALU 在 `WIDTH = 3` 进行了测试，测试样例子编写如下：
    ///
    initial begin
        // 加法的测试
        alu_m = 0;
        for(alu_a = 0; alu_a < (1 << WIDTH)-1; alu_a = alu_a + 1) begin
            for(alu_b = 0; alu_b < (1 << WIDTH)-1; alu_b = alu_b + 1) begin
                show_add(); #10; // 输出结果
            end
            show_add(); #10;
        end
        show_add();#10;

        // 减法的测试
        alu_m = 1;
        for(alu_a = 0; alu_a < (1 << WIDTH)-1; alu_a = alu_a + 1) begin
            for(alu_b = 0; alu_b < (1 << WIDTH)-1; alu_b = alu_b + 1) begin
                show_sub(); #10;
            end
            show_sub(); #10;
        end
        show_sub(); #10;
    end
    /// 得到的仿真波形如下图所示：
    /// 
    /// ![](lab1.assets/wave.png)
    ///
endmodule
