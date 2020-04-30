
module assert(input clk, input rst, input test);
    always @(posedge clk)
    begin
        if (test !== 1 && !rst)
        begin
            $display("ASSERTION FAILED in %m");
            $finish;
        end
    end
endmodule

module tb_ALU;

    reg clk = 1;
    always #5 clk = ~clk;

    reg rst = 1;
    initial #10 rst = 0;

    parameter WIDTH = 3;
    parameter ALUOP_W = 3;

    reg Word alu_a, alu_b;
    reg ALUop alu_m;

    @impl ALU alu ["alu_a", "alu_b", "alu_m"] #(.WIDTH(WIDTH))
    
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
    localparam VALUE_MAX = (1 << (WIDTH-1)) -1;
    localparam VALUE_MIN = - (1 << (WIDTH-1));
    initial begin
        // 加法的测试
        alu_m = 0;
        for(alu_a = VALUE_MIN; alu_a < VALUE_MAX; alu_a = alu_a + 1) begin
            for(alu_b = VALUE_MIN; alu_b < VALUE_MAX; alu_b = alu_b + 1) begin
                #10; show_add(); // 输出结果
            end
             #10; show_add();
        end
        #10; show_add();

        // 减法的测试
        alu_m = 1;
        for(alu_a = VALUE_MIN; alu_a < VALUE_MAX; alu_a = alu_a + 1) begin
            for(alu_b = VALUE_MIN; alu_b < VALUE_MAX; alu_b = alu_b + 1) begin
                #10; show_sub();
            end
            #10; show_sub();
        end
         #10; show_sub();
    end

    // 当条件不满足的时候，会终止仿真。这令用一个恒等式检查。
    assert a0(clk, rst, alu_of ^ alu_cf == alu_y[WIDTH-1]);

    /// 得到的仿真波形如下图所示：
    /// 
    /// ![](lab1.assets/wave.png)
    ///
endmodule
