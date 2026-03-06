// 检查信号（用迟滞窗口） <600 >620

module CheckSignal(
    input           clk,
    input           rst_n,
    input   [9:0]   ad_val,    // 信号数值
    output  wire    signal,
    output  reg [9:0] ad_cnt
);

reg [9:0]   min = 10'd600;
reg [9:0]   max = 10'd620;

reg [1:0] flag;
reg [9:0] ad_cnt_v;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        flag <= 2'b0;
    else if(ad_val < min && flag == 2'b0)
        flag <= 2'b1;
    else if(ad_val > max && flag == 2'b1)
        flag <= 2'b10;
    else 
        flag <= 2'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ad_cnt_v <= 10'b0;
    else if(flag == 2'b10)
        ad_cnt_v <= ad_cnt_v + 10'b1;
    else 
        ad_cnt_v <= ad_cnt_v;
end

assign signal = flag==2'b10 ? 1'b0 : 1'b1;

reg [27:0] clk_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        clk_cnt <= 28'b0;
    else if(clk_cnt >= 28'd48000000-1) begin
        clk_cnt <= 28'b0;
        ad_cnt <= ad_cnt_v;
    end else
       clk_cnt <= clk_cnt;
end

endmodule