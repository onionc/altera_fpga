module top(
    input               clk,        //12MHz系统时钟
    input               rst_n,      //系统复位，低有效

  
    output  wire        oled_csn,   //OLCD液晶屏使能
    output  wire        oled_rst,   //OLCD液晶屏复位
    output  wire        oled_dcn,   //OLCD数据指令控制
    output  wire        oled_clk,   //OLCD时钟信号
    output  wire        oled_dat,    //OLCD数据信号

    input               key         // 按键
);


reg [3:0] sw;
wire key_result;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        sw <= 4'd0;
    else if(key_result==0) 
        sw <= 4'd1;
    else
        sw <= 4'd2;
end

Oled oled_inst(
    .clk     (clk     ), 
    .rst_n   (rst_n   ), 
    .sw      (sw      ),
    .oled_csn(oled_csn),
    .oled_rst(oled_rst),
    .oled_dcn(oled_dcn),
    .oled_clk(oled_clk),
    .oled_dat(oled_dat)
);


KeyDebounce key_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    .key        (key),
    .key_filter (key_result)
);

endmodule
