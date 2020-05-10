`timescale 1ns / 1ps

module FIFO_tb();
    localparam WIDTH = 8;
    localparam MEM_ADDR_WIDTH = 4;

    reg clk = 1;
    always #5 clk = ~clk;

    reg rst = 1;
    initial #10 rst = 0;

    reg en_in, en_out;
    reg [WIDTH-1:0] fifo_din;

    wire [WIDTH-1:0] fifo_dout;
    wire [MEM_ADDR_WIDTH:0] fifo_count;
    FIFO fifo (
    	.clk(clk),
    	.rst(rst),
    	.en_in(en_in),
    	.din(fifo_din),
    	.en_out(en_out),
    	.dout(fifo_dout),
    	.count(fifo_count)
    );

    reg [WIDTH-1:0] i;


    /// code(fifo_tb)
    ///
    /// 下面对fifo队列进行仿真，代码如下：
    task assert; // 用于测试
    input test;
    begin
        if(~test) begin
            $display("assert failed");
            $finish;
        end
    end
    endtask
    
    initial begin
        en_in = 0;  en_out=0;
        #10;
        // 将16个数逐个入队
        for(i = 0; i < 16; i=i+1) begin
            en_in = 1; fifo_din = i; en_out = 0;
            assert(fifo_count == i);
            #10;
            en_in = 0; en_out = 0;
            #10;
        end
        assert(fifo_count == 16);                // 已经入队了16个
        // 尝试入队第17个                              
        en_in = 1; fifo_din = i; en_out = 0;     
        #10;                                     
        en_in = 0; en_out = 0;                   
        #10;                                     
                                                 
        assert(fifo_count == 16);                // 第17个无法入队
                                                 
         // 取出16个数                               
        for(i = 0; i < 16; i=i+1) begin          
            en_in = 0; en_out = 1;               
            assert(fifo_count == 16 - i);        
            #10;                                 
            en_in = 0; en_out = 0;               
            $display("get %d", fifo_dout);       
            assert(fifo_dout == i);              // 检验读出的结果
            #10;                                 
        end                                      
        assert(fifo_count == 0);                 // 队列已空
    end
    /// 以上 `assert` 全部通过，得到波形如下图所示：
    ///
    /// ![](./lab2.assets/wave2.png)
    ///
    /// 并且有完整的文本输出：
    ///
    /// ![](lab2.assets/text2.png)
    ///


endmodule
