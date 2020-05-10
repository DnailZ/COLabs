`timescale 1ns / 1ps

module RegFile_tb();
    localparam WIDTH = 32;
    localparam REGFILE_WIDTH = 5;
    localparam REGFILE_MAX = (1 << REGFILE_WIDTH) - 1;

    reg clk = 1;
    always #5 clk = ~clk;

    reg rst = 1;
    initial #10 rst = 0;

    @reglize ra0
    @reglize ra1
    @reglize wa
    @reglize wd
    @reglize we
    @impl RegFile regfile []
    /// code(regfile_tb)
    /// 接下来进行寄存器文件的仿真。这里仿真代码首先逐一读取寄存器文件中初始化的内容，然后向寄存器倒序写入整数：31、30、29……，然后重新将这些数据读入。
    integer i;
    initial begin
        regfile_we = 0;
        #10;
        $display("--- first read regfile ---"); 
        for(i = 0; i < 32; i=i+1) begin//[ 首先逐一读取寄存器文件中初始化的内容
            regfile_ra0 = i;
            regfile_ra1 = i+1;
            #10;
            $display("read %d at %d", regfile_rd0, i);
        end
        $display("--- write to read regfile ---"); 
        regfile_we = 1;
        for(i = 0; i < 32; i=i+1) begin //| 倒序写入整数
            regfile_wa = i;
            regfile_wd = 31 - i;
            #10;
            $display("write %d to %d", 31 - i, i);
        end
        regfile_we = 0;
        $display("--- read the writed regfile ---");
        for(i = 0; i < 32; i=i+1) begin //] 检查写入的结果
            regfile_ra0 = i;
            regfile_ra1 = i+1;
            #10;
            $display("read %d at %d", regfile_rd0, i);
        end
        $finish;
    end
    /// 仿真得到的波形和文本如下：
    /// 
    /// ![](./lab2.assets/wave1.png)
    ///
    /// ![](./lab2.assets/text1_0.png)
    ///
    /// ![](./lab2.assets/text1_1.png)
    ///
    
endmodule


