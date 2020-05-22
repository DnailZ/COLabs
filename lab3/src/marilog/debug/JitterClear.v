/*
 * 去抖动电路
 */

@module JitterClear
#(
    parameter jitter_clr_bit = 18 // 采用18位计数器 -> 10MHz下约1ms
)
(
    @ninput clk,
    @Input button,
    @output clean
);


reg [jitter_clr_bit:0] cnt;

always@(posedge clk) begin
    if(button == 0)
        cnt <= 0;
    else if(cnt < (1 << jitter_clr_bit))
        cnt <= cnt + 1;
end

assign clean = cnt[jitter_clr_bit];

endmodule
