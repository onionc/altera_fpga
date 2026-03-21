// 检查信号（用迟滞窗口） <600 >620

module CheckSignal(
    input           clk,
    input           rst_n,
    input   [9:0]   ad_val,    // 信号数值
    output  reg [9:0] ad_cnt,
    output  reg [1:0]  unit, // 单位：0-Hz 1-KHz 2-Mhz
    output reg [9:0] vpp
    
);

reg [9:0]   min = 10'd600;
reg [9:0]   max = 10'd700;
reg [27:0] clk_cnt;

reg [2:0] state;



always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state <= 3'd0;
    else begin
        case(state)
        3'd0:  // 当前认为是正半周
            if(ad_val < min)
                state <= 3'd1;
        3'd1:  // 当前认为是正半周
            if(ad_val > max)
                state <= 3'd2;
        3'd2:  // 当前认为是负半周
            if(ad_val < min)
                state <= 3'd0;
        default: // 特殊情况下回到0
            state <= 3'd0;
        endcase
    end
end

reg [2:0] state_d;

always @(posedge clk)
    state_d <= state;

wire zero_cross = (state==3'd0) && (state_d==3'd2);

reg [31:0] ad_cnt_v;
wire [31:0] ad_cnt_v_div1K;
wire [31:0] ad_cnt_v_div1M;
assign ad_cnt_v_div1K = (ad_cnt_v * 32'd4194) >> 22; // 除1000,误差可能差1
assign ad_cnt_v_div1M = (ad_cnt_v_div1K * 32'd4194) >> 22;

// 计算vpp
reg [9:0] max_val;
reg [9:0] min_val;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_val <= 10'd0;
        min_val <= 10'h3FF;
    end else begin
        if (clk_cnt == 28'd24000000-1) begin
            max_val <= 10'd0;
            min_val <= 10'h3FF;
        end 
        
        if(ad_val > max_val)
            max_val <= ad_val;
        if(ad_val < min_val)
            min_val <= ad_val;
    end
end

// 每秒计算一次
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        clk_cnt <= 28'b0;
        ad_cnt <= 10'b0;
        ad_cnt_v <= 0;
        unit <= 2'b0;
        //vpp <= 0;
    end else if(clk_cnt == 28'd12000000-1) begin
        clk_cnt <= 28'b0;
        
        if(ad_cnt_v > 'd1000000) begin
            ad_cnt <= ad_cnt_v_div1M;
            unit <= 2'd2;
        end if(ad_cnt_v > 'd1000) begin
            ad_cnt <= ad_cnt_v_div1K;
            unit <= 2'b1;
        end else begin
            ad_cnt <= ad_cnt_v;
            unit <= 2'b0;
        end
        ad_cnt_v <= 0;

        vpp <= max_val - min_val;   

    end else begin
        clk_cnt <= clk_cnt + 28'b1;
        //ad_cnt <= ad_cnt;

        if(zero_cross == 1'b1)
            ad_cnt_v <= ad_cnt_v+'b1;
        //else
            //ad_cnt_v <= ad_cnt_v;
    end
end

endmodule