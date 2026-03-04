
// 按键（消抖）

module KeyDebounce(
    input           clk,
    input           rst_n,
    input           key,            // 输入的按键
    output  reg     key_filter      // 按键消抖后的值
);

parameter CNT_MAX = 18'd240000;     // 20ms 拍数 20/1000/(1/12e6) = 240000

reg [17:0]  cnt;
reg         key_d0; // 延迟一个时钟周期的信号
reg         key_d1; // 延迟两个时钟周期的信号

// 按键延迟两拍
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_d0 <= 1'b1;
        key_d1 <= 1'b1;
    end else begin
        key_d0 <= key;
        key_d1 <= key_d0;
    end
end

// 按键值消抖
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 18'd0;
    else begin
        if(key_d1!=key_d0) // 按键发生变化，重置寄存器
            cnt <= CNT_MAX;
        else begin          // 按键值没有变化，计数器递减到0
            if(cnt > 18'd0)
                cnt <= cnt - 1'b1;
            else
                cnt <= 18'd0;
        end
    end
end

// 将消抖后的按键值输出
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        key_filter <= 1'b1;
    else if(cnt == 18'd1) // 计数器递减到1，按键有效
        key_filter <= key_d1;
    else
        key_filter <= key_filter;
end

endmodule
